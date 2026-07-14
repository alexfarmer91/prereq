use chrono::{DateTime, Utc};
use serde::Serialize;
use sqlx::PgPool;
use uuid::Uuid;

use crate::error::AppError;

#[derive(Debug, Clone, Serialize, sqlx::FromRow)]
pub struct WatchlistItem {
    pub id: Uuid,
    pub market_ticker: String,
    pub alert_edge_threshold: Option<f64>,
    pub edge_at_add: Option<f64>,
    pub created_at: DateTime<Utc>,
}

const COLUMNS: &str = "id, market_ticker, \
    alert_edge_threshold::float8 AS alert_edge_threshold, \
    edge_at_add::float8 AS edge_at_add, created_at";

pub async fn list(pool: &PgPool, user_id: Uuid) -> Result<Vec<WatchlistItem>, AppError> {
    let items = sqlx::query_as::<_, WatchlistItem>(&format!(
        "SELECT {COLUMNS} FROM watchlist WHERE user_id = $1 ORDER BY created_at DESC"
    ))
    .bind(user_id)
    .fetch_all(pool)
    .await?;
    Ok(items)
}

pub async fn add(
    pool: &PgPool,
    user_id: Uuid,
    ticker: &str,
    alert_edge_threshold: Option<f64>,
    edge_at_add: Option<f64>,
) -> Result<WatchlistItem, AppError> {
    let item = sqlx::query_as::<_, WatchlistItem>(&format!(
        "INSERT INTO watchlist (user_id, market_ticker, alert_edge_threshold, edge_at_add)
         VALUES ($1, $2, $3, $4)
         ON CONFLICT (user_id, market_ticker)
         DO UPDATE SET alert_edge_threshold = EXCLUDED.alert_edge_threshold
         RETURNING {COLUMNS}"
    ))
    .bind(user_id)
    .bind(ticker)
    .bind(alert_edge_threshold)
    .bind(edge_at_add)
    .fetch_one(pool)
    .await?;
    Ok(item)
}

pub async fn remove(pool: &PgPool, user_id: Uuid, ticker: &str) -> Result<(), AppError> {
    let result = sqlx::query("DELETE FROM watchlist WHERE user_id = $1 AND market_ticker = $2")
        .bind(user_id)
        .bind(ticker)
        .execute(pool)
        .await?;
    if result.rows_affected() == 0 {
        return Err(AppError::NotFound);
    }
    Ok(())
}

/// Tickers across all users — used by the WebSocket/alerting layer.
pub async fn all_watched_tickers(pool: &PgPool) -> Result<Vec<String>, AppError> {
    let rows: Vec<(String,)> =
        sqlx::query_as("SELECT DISTINCT market_ticker FROM watchlist")
            .fetch_all(pool)
            .await?;
    Ok(rows.into_iter().map(|(t,)| t).collect())
}
