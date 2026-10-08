use std::collections::HashMap;

use chrono::{DateTime, Utc};
use serde_json::Value;
use sqlx::PgPool;

use crate::error::AppError;
use crate::models::market::Score;

/// One persisted Claude scoring run (see migrations/0008_ai_scores.sql).
pub struct NewScore<'a> {
    pub market_ticker: &'a str,
    pub market_title: &'a str,
    pub score: &'a Score,
    pub market_price_at_score: f64,
    pub model: &'a str,
    pub web_search_enabled: bool,
    pub web_search_count: i32,
    pub input_tokens: i64,
    pub output_tokens: i64,
    pub raw_content: Option<&'a Value>,
    pub context: ForecastContext<'a>,
}

/// What the model was shown and when (migrations/0010_forecast_ledger.sql).
pub struct ForecastContext<'a> {
    pub requested_at: DateTime<Utc>,
    pub prompt_version: &'a str,
    pub event_ticker: &'a str,
    pub category: &'a str,
    pub market_close_time: Option<DateTime<Utc>>,
    pub yes_bid: f64,
    pub yes_ask: f64,
    pub no_bid: f64,
    pub no_ask: f64,
}

/// One failed Claude scoring attempt.
pub struct NewFailure<'a> {
    pub market_ticker: &'a str,
    pub requested_at: DateTime<Utc>,
    pub model: &'a str,
    pub prompt_version: &'a str,
    pub web_search_enabled: bool,
    pub error_kind: &'a str,
    pub error_detail: &'a str,
    pub market_price_at_request: f64,
}

#[derive(sqlx::FromRow)]
struct ScoreRow {
    market_ticker: String,
    fair_probability: f64,
    confidence: String,
    rationale: String,
    signals: String,
    risks: String,
    market_price_at_score: f64,
    scored_at: DateTime<Utc>,
}

impl ScoreRow {
    /// `edge` is left relative to the price at scoring time and EV is unset;
    /// callers recompute both against live quotes (`scorer::reprice`).
    fn into_score(self) -> (String, Score) {
        let score = Score {
            fair_probability: self.fair_probability,
            confidence: self.confidence,
            edge: self.fair_probability - self.market_price_at_score,
            ev_yes_per_dollar: None,
            ev_no_per_dollar: None,
            rationale: self.rationale,
            signals: serde_json::from_str(&self.signals).unwrap_or_default(),
            risks: serde_json::from_str(&self.risks).unwrap_or_default(),
            scored_at: self.scored_at,
            market_price_at_score: Some(self.market_price_at_score),
        };
        (self.market_ticker, score)
    }
}

// JSONB columns round-trip as text so no extra sqlx feature is needed.
const COLUMNS: &str = "market_ticker, fair_probability, confidence, \
    rationale, signals::text AS signals, risks::text AS risks, \
    market_price_at_score, scored_at";

pub async fn insert(pool: &PgPool, new: &NewScore<'_>) -> Result<(), AppError> {
    let signals = serde_json::to_string(&new.score.signals).unwrap_or_else(|_| "[]".into());
    let risks = serde_json::to_string(&new.score.risks).unwrap_or_else(|_| "[]".into());
    let raw = new.raw_content.map(Value::to_string);
    sqlx::query(
        "INSERT INTO ai_scores (
            market_ticker, market_title, fair_probability, confidence,
            rationale, signals, risks, market_price_at_score, model,
            web_search_enabled, web_search_count, input_tokens, output_tokens,
            raw_content, scored_at, requested_at, prompt_version, event_ticker,
            category, market_close_time, yes_bid, yes_ask, no_bid, no_ask
         ) VALUES (
            $1, $2, $3, $4, $5, $6::jsonb, $7::jsonb, $8, $9,
            $10, $11, $12, $13, $14::jsonb, $15, $16, $17, $18,
            $19, $20, $21, $22, $23, $24
         )",
    )
    .bind(new.market_ticker)
    .bind(new.market_title)
    .bind(new.score.fair_probability)
    .bind(&new.score.confidence)
    .bind(&new.score.rationale)
    .bind(signals)
    .bind(risks)
    .bind(new.market_price_at_score)
    .bind(new.model)
    .bind(new.web_search_enabled)
    .bind(new.web_search_count)
    .bind(new.input_tokens)
    .bind(new.output_tokens)
    .bind(raw)
    .bind(new.score.scored_at)
    .bind(new.context.requested_at)
    .bind(new.context.prompt_version)
    .bind(new.context.event_ticker)
    .bind(new.context.category)
    .bind(new.context.market_close_time)
    .bind(new.context.yes_bid)
    .bind(new.context.yes_ask)
    .bind(new.context.no_bid)
    .bind(new.context.no_ask)
    .execute(pool)
    .await?;
    Ok(())
}

pub async fn insert_failure(pool: &PgPool, new: &NewFailure<'_>) -> Result<(), AppError> {
    sqlx::query(
        "INSERT INTO ai_score_failures (
            market_ticker, requested_at, model, prompt_version, web_search_enabled,
            error_kind, error_detail, market_price_at_request
         ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)",
    )
    .bind(new.market_ticker)
    .bind(new.requested_at)
    .bind(new.model)
    .bind(new.prompt_version)
    .bind(new.web_search_enabled)
    .bind(new.error_kind)
    .bind(new.error_detail)
    .bind(new.market_price_at_request)
    .execute(pool)
    .await?;
    Ok(())
}

/// Most recent score for one ticker.
pub async fn latest(pool: &PgPool, ticker: &str) -> Result<Option<Score>, AppError> {
    let row = sqlx::query_as::<_, ScoreRow>(&format!(
        "SELECT {COLUMNS} FROM ai_scores
         WHERE market_ticker = $1 ORDER BY scored_at DESC LIMIT 1"
    ))
    .bind(ticker)
    .fetch_optional(pool)
    .await?;
    Ok(row.map(|r| r.into_score().1))
}

/// Most recent score for each of `tickers`, in one round trip.
pub async fn latest_for(
    pool: &PgPool,
    tickers: &[String],
) -> Result<HashMap<String, Score>, AppError> {
    if tickers.is_empty() {
        return Ok(HashMap::new());
    }
    let rows = sqlx::query_as::<_, ScoreRow>(&format!(
        "SELECT DISTINCT ON (market_ticker) {COLUMNS} FROM ai_scores
         WHERE market_ticker = ANY($1)
         ORDER BY market_ticker, scored_at DESC"
    ))
    .bind(tickers)
    .fetch_all(pool)
    .await?;
    Ok(rows.into_iter().map(ScoreRow::into_score).collect())
}
