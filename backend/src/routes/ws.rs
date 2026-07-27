use std::collections::HashSet;
use std::time::Duration;

use axum::{
    extract::{
        ws::{Message, WebSocket, WebSocketUpgrade},
        Query, State,
    },
    http::StatusCode,
    response::{IntoResponse, Response},
    Json,
};
use chrono::Utc;
use futures_util::{SinkExt, StreamExt};
use serde::Deserialize;
use serde_json::json;

use crate::{
    middleware::auth,
    models::market::Market,
    services::{arb, kalshi},
    AppState,
};

const PUSH_INTERVAL: Duration = Duration::from_secs(15);
/// Fresh-quote cache TTL — shared across clients so N watchers of the same
/// ticker cost one Kalshi call per interval.
const QUOTE_TTL: Duration = Duration::from_secs(10);

#[derive(Debug, Deserialize)]
pub struct WsQuery {
    pub token: Option<String>,
}

/// Browsers can't set headers on WebSocket connects, so the JWT arrives as a
/// query parameter instead of an Authorization header.
pub async fn ws_markets(
    State(state): State<AppState>,
    Query(query): Query<WsQuery>,
    ws: WebSocketUpgrade,
) -> Response {
    if !auth::skip_auth() {
        let (Some(jwks), Some(client_id)) = (state.jwks.current().await, &state.google_client_id)
        else {
            return (
                StatusCode::SERVICE_UNAVAILABLE,
                Json(json!({ "data": null, "error": "Authentication not configured" })),
            )
                .into_response();
        };
        let Some(token) = query.token else {
            return (
                StatusCode::UNAUTHORIZED,
                Json(json!({ "data": null, "error": "Missing token" })),
            )
                .into_response();
        };
        if let Err(msg) = auth::verify_jwt(&token, &jwks, client_id) {
            return (
                StatusCode::UNAUTHORIZED,
                Json(json!({ "data": null, "error": msg })),
            )
                .into_response();
        }
    }

    ws.on_upgrade(move |socket| handle_socket(socket, state))
}

#[derive(Debug, Deserialize)]
struct ClientMessage {
    #[serde(rename = "type")]
    kind: String,
    #[serde(default)]
    tickers: Vec<String>,
}

async fn handle_socket(socket: WebSocket, state: AppState) {
    let (mut sender, mut receiver) = socket.split();
    let mut subscribed: HashSet<String> = HashSet::new();
    let mut push_timer = tokio::time::interval(PUSH_INTERVAL);
    push_timer.set_missed_tick_behavior(tokio::time::MissedTickBehavior::Delay);

    loop {
        tokio::select! {
            msg = receiver.next() => {
                match msg {
                    Some(Ok(Message::Text(text))) => {
                        if let Ok(parsed) = serde_json::from_str::<ClientMessage>(text.as_str()) {
                            if parsed.kind == "subscribe" {
                                subscribed = parsed.tickers.into_iter().collect();
                                tracing::debug!("WS subscription updated: {} tickers", subscribed.len());
                            }
                        }
                    }
                    Some(Ok(Message::Close(_))) | None => break,
                    Some(Ok(_)) => {}
                    Some(Err(e)) => {
                        tracing::debug!("WS receive error: {e}");
                        break;
                    }
                }
            }
            _ = push_timer.tick() => {
                for ticker in subscribed.iter() {
                    if let Some(market) = current_quote(&state, ticker).await {
                        let update = json!({
                            "type": "price_update",
                            "ticker": market.ticker,
                            "yes_bid": market.yes_bid,
                            "yes_ask": market.yes_ask,
                            "ts": Utc::now().to_rfc3339(),
                        });
                        if sender.send(Message::Text(update.to_string().into())).await.is_err() {
                            return;
                        }
                    }
                }

                let arb_count = arb::cached_arbs(&state).await.len();
                let msg = json!({ "type": "arb_count", "count": arb_count });
                if sender.send(Message::Text(msg.to_string().into())).await.is_err() {
                    return;
                }
            }
        }
    }
}

/// Live quote with a short shared cache in front of Kalshi; falls back to the
/// 5-minute snapshot when the direct fetch fails.
async fn current_quote(state: &AppState, ticker: &str) -> Option<Market> {
    let key = format!("quote:{ticker}");
    if let Some(cached) = state.cache.get(&key).await {
        if let Ok(market) = serde_json::from_str::<Market>(&cached) {
            return Some(market);
        }
    }

    match kalshi::fetch_market(&state.http, ticker).await {
        Ok(Some(market)) => {
            if let Ok(serialized) = serde_json::to_string(&market) {
                state.cache.set(&key, &serialized, QUOTE_TTL).await;
            }
            Some(market)
        }
        _ => state.markets.get(ticker).await,
    }
}
