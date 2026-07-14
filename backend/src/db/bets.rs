use chrono::{DateTime, Utc};
use serde::Serialize;
use sqlx::PgPool;
use uuid::Uuid;

use crate::error::AppError;

#[derive(Debug, Clone, Serialize, sqlx::FromRow)]
pub struct Bet {
    pub id: Uuid,
    pub market_ticker: String,
    pub market_title: String,
    pub side: String,
    pub entry_price_dollars: f64,
    pub contracts: i32,
    pub your_probability: f64,
    pub kelly_fraction: Option<f64>,
    pub outcome: String,
    pub exit_price_dollars: Option<f64>,
    pub placed_at: DateTime<Utc>,
    pub resolved_at: Option<DateTime<Utc>>,
}

const COLUMNS: &str = "id, market_ticker, market_title, side, \
    entry_price_dollars::float8 AS entry_price_dollars, contracts, \
    your_probability::float8 AS your_probability, \
    kelly_fraction::float8 AS kelly_fraction, outcome, \
    exit_price_dollars::float8 AS exit_price_dollars, placed_at, resolved_at";

pub struct NewBet {
    pub market_ticker: String,
    pub market_title: String,
    pub side: String,
    pub entry_price_dollars: f64,
    pub contracts: i32,
    pub your_probability: f64,
    pub kelly_fraction: Option<f64>,
}

pub async fn list(
    pool: &PgPool,
    user_id: Uuid,
    outcome: Option<&str>,
    page: i64,
    per_page: i64,
) -> Result<(Vec<Bet>, i64), AppError> {
    let offset = (page - 1) * per_page;

    let bets = sqlx::query_as::<_, Bet>(&format!(
        "SELECT {COLUMNS} FROM bet_log
         WHERE user_id = $1 AND ($2::text IS NULL OR outcome = $2)
         ORDER BY placed_at DESC LIMIT $3 OFFSET $4"
    ))
    .bind(user_id)
    .bind(outcome)
    .bind(per_page)
    .bind(offset)
    .fetch_all(pool)
    .await?;

    let (total,): (i64,) = sqlx::query_as(
        "SELECT COUNT(*) FROM bet_log
         WHERE user_id = $1 AND ($2::text IS NULL OR outcome = $2)",
    )
    .bind(user_id)
    .bind(outcome)
    .fetch_one(pool)
    .await?;

    Ok((bets, total))
}

pub async fn insert(pool: &PgPool, user_id: Uuid, bet: NewBet) -> Result<Bet, AppError> {
    let row = sqlx::query_as::<_, Bet>(&format!(
        "INSERT INTO bet_log (user_id, market_ticker, market_title, side,
             entry_price_dollars, contracts, your_probability, kelly_fraction)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
         RETURNING {COLUMNS}"
    ))
    .bind(user_id)
    .bind(&bet.market_ticker)
    .bind(&bet.market_title)
    .bind(&bet.side)
    .bind(bet.entry_price_dollars)
    .bind(bet.contracts)
    .bind(bet.your_probability)
    .bind(bet.kelly_fraction)
    .fetch_one(pool)
    .await?;
    Ok(row)
}

pub async fn update_outcome(
    pool: &PgPool,
    user_id: Uuid,
    bet_id: Uuid,
    outcome: &str,
    exit_price_dollars: Option<f64>,
) -> Result<Bet, AppError> {
    let row = sqlx::query_as::<_, Bet>(&format!(
        "UPDATE bet_log
         SET outcome = $3, exit_price_dollars = $4, resolved_at = NOW()
         WHERE id = $2 AND user_id = $1
         RETURNING {COLUMNS}"
    ))
    .bind(user_id)
    .bind(bet_id)
    .bind(outcome)
    .bind(exit_price_dollars)
    .fetch_one(pool)
    .await?;
    Ok(row)
}

/// Resolved bets ordered by resolution time — input for calibration/streaks.
pub async fn resolved(pool: &PgPool, user_id: Uuid) -> Result<Vec<Bet>, AppError> {
    let bets = sqlx::query_as::<_, Bet>(&format!(
        "SELECT {COLUMNS} FROM bet_log
         WHERE user_id = $1 AND outcome IN ('win','loss')
         ORDER BY resolved_at ASC NULLS LAST"
    ))
    .bind(user_id)
    .fetch_all(pool)
    .await?;
    Ok(bets)
}
