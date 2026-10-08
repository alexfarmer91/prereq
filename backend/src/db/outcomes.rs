use chrono::{DateTime, Utc};
use sqlx::PgPool;

use crate::error::AppError;

/// Settlement state for one scored market (migrations/0010_forecast_ledger.sql).
pub struct OutcomeUpdate<'a> {
    pub market_ticker: &'a str,
    pub status: &'a str,
    pub market_type: Option<&'a str>,
    pub result: Option<&'a str>,
    pub settlement_value: Option<f64>,
    pub settlement_ts: Option<DateTime<Utc>>,
    pub resolution: &'a str,
}

/// Scored tickers whose outcome isn't final yet (or was never checked).
pub async fn unfinalized_scored_tickers(pool: &PgPool) -> Result<Vec<String>, AppError> {
    let rows: Vec<(String,)> = sqlx::query_as(
        "SELECT DISTINCT s.market_ticker
         FROM ai_scores s
         LEFT JOIN market_outcomes o ON o.market_ticker = s.market_ticker
         WHERE o.status IS DISTINCT FROM 'finalized'
         ORDER BY s.market_ticker",
    )
    .fetch_all(pool)
    .await?;
    Ok(rows.into_iter().map(|(t,)| t).collect())
}

/// Insert or refresh a market's outcome. A row already marked `finalized` is
/// never rewritten, so a recorded outcome can't silently change. Idempotent.
pub async fn upsert(pool: &PgPool, update: &OutcomeUpdate<'_>) -> Result<(), AppError> {
    sqlx::query(
        "INSERT INTO market_outcomes (
            market_ticker, status, market_type, result, settlement_value,
            settlement_ts, resolution, first_finalized_seen_at, checked_at
         ) VALUES (
            $1, $2, $3, $4, $5, $6, $7,
            CASE WHEN $2 = 'finalized' THEN NOW() END, NOW()
         )
         ON CONFLICT (market_ticker) DO UPDATE SET
            status = EXCLUDED.status,
            market_type = EXCLUDED.market_type,
            result = EXCLUDED.result,
            settlement_value = EXCLUDED.settlement_value,
            settlement_ts = EXCLUDED.settlement_ts,
            resolution = EXCLUDED.resolution,
            first_finalized_seen_at = EXCLUDED.first_finalized_seen_at,
            checked_at = NOW()
         WHERE market_outcomes.status <> 'finalized'",
    )
    .bind(update.market_ticker)
    .bind(update.status)
    .bind(update.market_type)
    .bind(update.result)
    .bind(update.settlement_value)
    .bind(update.settlement_ts)
    .bind(update.resolution)
    .execute(pool)
    .await?;
    Ok(())
}
