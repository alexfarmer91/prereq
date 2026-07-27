use axum::{
    extract::{Path, State},
    Extension, Json,
};
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

use crate::{
    db,
    error::AppError,
    middleware::auth::AuthUser,
    models::{market::Market, ApiResponse},
    AppState,
};

/// Watchlist item enriched with the current market snapshot (None when the
/// market has dropped out of the filtered universe).
#[derive(Debug, Serialize)]
pub struct WatchlistEntry {
    pub id: Uuid,
    pub market_ticker: String,
    pub alert_edge_threshold: Option<f64>,
    pub edge_at_add: Option<f64>,
    pub created_at: DateTime<Utc>,
    pub market: Option<Market>,
}

pub async fn list_watchlist(
    State(state): State<AppState>,
    Extension(user): Extension<AuthUser>,
) -> Result<Json<ApiResponse<Vec<WatchlistEntry>>>, AppError> {
    let pool = db::require(&state.db)?;
    let me = db::users::get_or_create(pool, &user.google_user_id).await?;
    let items = db::watchlist::list(pool, me.id).await?;

    let mut entries = Vec::with_capacity(items.len());
    for item in items {
        let market = state.markets.get(&item.market_ticker).await;
        entries.push(WatchlistEntry {
            id: item.id,
            market_ticker: item.market_ticker,
            alert_edge_threshold: item.alert_edge_threshold,
            edge_at_add: item.edge_at_add,
            created_at: item.created_at,
            market,
        });
    }
    Ok(Json(ApiResponse::ok(entries)))
}

#[derive(Debug, Deserialize)]
pub struct AddWatchlistItem {
    pub ticker: String,
    pub alert_edge_threshold: Option<f64>,
}

pub async fn add_to_watchlist(
    State(state): State<AppState>,
    Extension(user): Extension<AuthUser>,
    Json(body): Json<AddWatchlistItem>,
) -> Result<Json<ApiResponse<WatchlistEntry>>, AppError> {
    if body.ticker.trim().is_empty() {
        return Err(AppError::BadRequest("ticker is required".into()));
    }
    if let Some(t) = body.alert_edge_threshold {
        if !t.is_finite() || !(0.0..=1.0).contains(&t) {
            return Err(AppError::BadRequest(
                "alert_edge_threshold must be between 0 and 1".into(),
            ));
        }
    }

    let pool = db::require(&state.db)?;
    let me = db::users::get_or_create(pool, &user.google_user_id).await?;

    let market = state.markets.get(&body.ticker).await;
    let edge_at_add = market
        .as_ref()
        .and_then(|m| m.score.as_ref())
        .map(|s| s.edge);

    let item = db::watchlist::add(
        pool,
        me.id,
        body.ticker.trim(),
        body.alert_edge_threshold,
        edge_at_add,
    )
    .await?;

    Ok(Json(ApiResponse::ok(WatchlistEntry {
        id: item.id,
        market_ticker: item.market_ticker,
        alert_edge_threshold: item.alert_edge_threshold,
        edge_at_add: item.edge_at_add,
        created_at: item.created_at,
        market,
    })))
}

pub async fn remove_from_watchlist(
    State(state): State<AppState>,
    Extension(user): Extension<AuthUser>,
    Path(ticker): Path<String>,
) -> Result<Json<ApiResponse<&'static str>>, AppError> {
    let pool = db::require(&state.db)?;
    let me = db::users::get_or_create(pool, &user.google_user_id).await?;
    db::watchlist::remove(pool, me.id, &ticker).await?;
    Ok(Json(ApiResponse::ok("removed")))
}
