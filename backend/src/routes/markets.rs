use axum::{
    extract::{Path, Query, State},
    Json,
};
use serde::{Deserialize, Serialize};

use crate::{
    error::AppError,
    models::{
        market::{HistoryPoint, Market},
        ApiResponse,
    },
    services::{kalshi, market_store},
    AppState,
};

#[derive(Debug, Deserialize)]
pub struct MarketsQuery {
    pub category: Option<String>,
    pub sort: Option<String>,
    /// Edge-tier horizon filter — drop markets closing further out than this
    /// many days. `None`/absent means no cap (today's behavior, unchanged).
    pub max_days_to_close: Option<i64>,
}

pub async fn list_markets(
    State(state): State<AppState>,
    Query(params): Query<MarketsQuery>,
) -> Result<Json<ApiResponse<Vec<Market>>>, AppError> {
    market_store::ensure_fresh(&state).await?;
    let mut markets = state.markets.all().await;

    if let Some(cat) = params
        .category
        .as_deref()
        .filter(|c| !c.eq_ignore_ascii_case("all"))
    {
        markets.retain(|m| m.category.eq_ignore_ascii_case(cat));
    }

    if let Some(max_days) = params.max_days_to_close {
        let cutoff = chrono::Utc::now() + chrono::Duration::days(max_days);
        markets.retain(|m| {
            chrono::DateTime::parse_from_rfc3339(&m.close_time)
                .map(|t| t < cutoff)
                .unwrap_or(true)
        });
    }

    sort_markets(&mut markets, params.sort.as_deref().unwrap_or("edge"));
    Ok(Json(ApiResponse::ok(markets)))
}

/// edge: highest AI edge first (unscored last) · volume: 24h volume ·
/// close: soonest close first · confidence: high before medium before low
/// (unscored last).
fn sort_markets(markets: &mut [Market], sort: &str) {
    match sort {
        "volume" => markets.sort_by(|a, b| {
            b.volume_24h
                .partial_cmp(&a.volume_24h)
                .unwrap_or(std::cmp::Ordering::Equal)
        }),
        "close" => markets.sort_by(|a, b| a.close_time.cmp(&b.close_time)),
        "confidence" => markets.sort_by(|a, b| {
            let rank = |m: &Market| match m.score.as_ref().map(|s| s.confidence.as_str()) {
                Some("high") => 2,
                Some("medium") => 1,
                Some("low") => 0,
                _ => -1,
            };
            rank(b).cmp(&rank(a))
        }),
        _ => markets.sort_by(|a, b| {
            let edge = |m: &Market| m.score.as_ref().map(|s| s.edge.abs());
            match (edge(a), edge(b)) {
                (Some(ea), Some(eb)) => eb.partial_cmp(&ea).unwrap_or(std::cmp::Ordering::Equal),
                (Some(_), None) => std::cmp::Ordering::Less,
                (None, Some(_)) => std::cmp::Ordering::Greater,
                (None, None) => b
                    .volume_24h
                    .partial_cmp(&a.volume_24h)
                    .unwrap_or(std::cmp::Ordering::Equal),
            }
        }),
    }
}

#[derive(Debug, Serialize)]
pub struct MarketDetail {
    pub market: Market,
    pub event_markets: Vec<Market>,
}

pub async fn get_market(
    State(state): State<AppState>,
    Path(ticker): Path<String>,
) -> Result<Json<ApiResponse<MarketDetail>>, AppError> {
    market_store::ensure_fresh(&state).await?;

    let market = match state.markets.get(&ticker).await {
        Some(m) => m,
        None => {
            let mut fetched = kalshi::fetch_market(&state.http, &ticker)
                .await?
                .ok_or(AppError::NotFound)?;
            // A direct fetch bypasses the scored snapshot — reuse a cached
            // score if one exists.
            if let Some(cached) = state.cache.get(&format!("score:{ticker}")).await {
                fetched.score = serde_json::from_str(&cached).ok();
            }
            fetched
        }
    };

    let mut event_markets = state.markets.by_event(&market.event_ticker).await;
    // The snapshot only holds the most liquid market per event; pull the full
    // strike ladder from Kalshi, keeping snapshot (scored) versions on collision.
    if let Ok(all_strikes) = kalshi::fetch_event_markets(&state.http, &market.event_ticker).await {
        for strike in all_strikes {
            if !event_markets.iter().any(|m| m.ticker == strike.ticker) {
                event_markets.push(strike);
            }
        }
    }
    if !event_markets.iter().any(|m| m.ticker == market.ticker) {
        event_markets.push(market.clone());
    }
    event_markets.sort_by(|a, b| a.ticker.cmp(&b.ticker));

    Ok(Json(ApiResponse::ok(MarketDetail {
        market,
        event_markets,
    })))
}

pub async fn get_history(
    State(state): State<AppState>,
    Path(ticker): Path<String>,
) -> Result<Json<ApiResponse<Vec<HistoryPoint>>>, AppError> {
    let event_ticker = match state.markets.get(&ticker).await {
        Some(m) => m.event_ticker,
        None => ticker
            .rsplit_once('-')
            .map(|(event, _)| event.to_string())
            .unwrap_or_else(|| ticker.clone()),
    };
    let history = kalshi::fetch_history(&state.http, &ticker, &event_ticker).await;
    Ok(Json(ApiResponse::ok(history)))
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::models::market::Score;
    use chrono::Utc;

    fn market(ticker: &str, confidence: Option<&str>) -> Market {
        Market {
            ticker: ticker.into(),
            event_ticker: ticker.into(),
            title: ticker.into(),
            yes_bid: 0.5,
            yes_ask: 0.55,
            no_bid: 0.45,
            no_ask: 0.5,
            mid_price: 0.525,
            spread: 0.05,
            volume_24h: 1000.0,
            close_time: Utc::now().to_rfc3339(),
            rules_primary: None,
            category: "Politics".into(),
            score: confidence.map(|c| Score {
                fair_probability: 0.6,
                confidence: c.into(),
                edge: 0.05,
                ev_per_dollar: 0.05,
                rationale: String::new(),
                signals: vec![],
                risks: vec![],
                scored_at: Utc::now(),
            }),
        }
    }

    #[test]
    fn confidence_sort_orders_high_medium_low_then_unscored() {
        let mut markets = vec![
            market("LOW", Some("low")),
            market("NONE", None),
            market("HIGH", Some("high")),
            market("MED", Some("medium")),
        ];
        sort_markets(&mut markets, "confidence");
        let order: Vec<&str> = markets.iter().map(|m| m.ticker.as_str()).collect();
        assert_eq!(order, vec!["HIGH", "MED", "LOW", "NONE"]);
    }
}
