//! Settlement ingestion for scored markets. Periodically asks Kalshi for the
//! official lifecycle state of every market in `ai_scores` that isn't
//! finalized yet and records it in `market_outcomes`, so AI forecasts can be
//! evaluated against real outcomes (docs/forecast-validation.md).
//!
//! Outcomes come only from Kalshi's settlement fields — never inferred from
//! a market closing or its price drifting to 0 or 1.

use std::time::Duration;

use crate::db;
use crate::services::kalshi::{self, KalshiSettlement};
use crate::AppState;

const SYNC_INTERVAL: Duration = Duration::from_secs(6 * 60 * 60);
/// Let startup's market refresh and scoring go first.
const STARTUP_DELAY: Duration = Duration::from_secs(5 * 60);
/// Tickers per `GET /markets?tickers=` call.
const BATCH_SIZE: usize = 100;
/// Pause between batches to stay well under Kalshi's public rate limit.
const BATCH_PAUSE: Duration = Duration::from_millis(500);

/// Set OUTCOME_SYNC=false to disable the background sync.
fn sync_enabled() -> bool {
    std::env::var("OUTCOME_SYNC").as_deref() != Ok("false")
}

/// Classify a Kalshi market for the binary forecasting evaluation. Only
/// `yes` / `no` are eligible; everything else is counted and excluded.
pub fn resolution(m: &KalshiSettlement) -> &'static str {
    match m.status.as_str() {
        "finalized" => {}
        "disputed" | "amended" => return "disputed",
        _ => return "pending",
    }
    let result = m.result.as_deref().unwrap_or("");
    if m.market_type.as_deref().is_some_and(|t| t != "binary") || result == "scalar" {
        return "nonbinary";
    }
    // The payout must agree with the result when Kalshi reports one.
    let value = settlement_value(m);
    match (result, value) {
        ("yes", None) => "yes",
        ("no", None) => "no",
        ("yes", Some(v)) if (v - 1.0).abs() < 1e-9 => "yes",
        ("no", Some(v)) if v.abs() < 1e-9 => "no",
        _ => "exception",
    }
}

fn settlement_value(m: &KalshiSettlement) -> Option<f64> {
    m.settlement_value_dollars.as_deref()?.parse().ok()
}

/// One pass over every unfinalized scored market. Returns (checked, missing):
/// tickers Kalshi returned, and tickers it didn't (left untouched).
pub async fn sync(state: &AppState) -> Result<(usize, usize), crate::error::AppError> {
    let Some(pool) = state.db.as_ref() else {
        return Ok((0, 0));
    };
    let tickers = db::outcomes::unfinalized_scored_tickers(pool).await?;
    let mut checked = 0;
    for (i, batch) in tickers.chunks(BATCH_SIZE).enumerate() {
        if i > 0 {
            tokio::time::sleep(BATCH_PAUSE).await;
        }
        for m in kalshi::fetch_settlements(&state.http, batch).await? {
            let value = settlement_value(&m);
            db::outcomes::upsert(
                pool,
                &db::outcomes::OutcomeUpdate {
                    market_ticker: &m.ticker,
                    status: &m.status,
                    market_type: m.market_type.as_deref(),
                    result: m.result.as_deref(),
                    settlement_value: value,
                    settlement_ts: m.settlement_ts,
                    resolution: resolution(&m),
                },
            )
            .await?;
            checked += 1;
        }
    }
    Ok((checked, tickers.len().saturating_sub(checked)))
}

pub fn spawn_sync_task(state: AppState) {
    if state.db.is_none() || !sync_enabled() {
        tracing::info!("Outcome sync disabled (no database or OUTCOME_SYNC=false)");
        return;
    }
    tokio::spawn(async move {
        tokio::time::sleep(STARTUP_DELAY).await;
        loop {
            match sync(&state).await {
                Ok((checked, missing)) => tracing::info!(
                    "Outcome sync complete: {checked} checked, {missing} not returned by Kalshi"
                ),
                Err(e) => tracing::warn!("Outcome sync failed: {e}"),
            }
            tokio::time::sleep(SYNC_INTERVAL).await;
        }
    });
}

#[cfg(test)]
mod tests {
    use super::*;

    fn market(status: &str, kind: &str, result: &str, value: Option<&str>) -> KalshiSettlement {
        KalshiSettlement {
            ticker: "T".into(),
            status: status.into(),
            market_type: Some(kind.into()),
            result: Some(result.into()),
            settlement_value_dollars: value.map(Into::into),
            settlement_ts: None,
        }
    }

    #[test]
    fn finalized_binary_results_are_eligible() {
        assert_eq!(
            resolution(&market("finalized", "binary", "yes", Some("1.0000"))),
            "yes"
        );
        assert_eq!(
            resolution(&market("finalized", "binary", "no", Some("0.0000"))),
            "no"
        );
        assert_eq!(resolution(&market("finalized", "binary", "no", None)), "no");
    }

    #[test]
    fn closed_or_determined_is_not_resolved() {
        // A closed market — even one priced at 0.99 — has no outcome yet.
        assert_eq!(resolution(&market("closed", "binary", "", None)), "pending");
        assert_eq!(resolution(&market("active", "binary", "", None)), "pending");
        assert_eq!(
            resolution(&market("determined", "binary", "yes", Some("1.0000"))),
            "pending"
        );
    }

    #[test]
    fn disputes_and_exceptions_are_excluded() {
        assert_eq!(
            resolution(&market("disputed", "binary", "yes", None)),
            "disputed"
        );
        assert_eq!(
            resolution(&market("amended", "binary", "no", None)),
            "disputed"
        );
        assert_eq!(
            resolution(&market("finalized", "scalar", "scalar", Some("0.4200"))),
            "nonbinary"
        );
        assert_eq!(
            resolution(&market("finalized", "binary", "scalar", Some("0.5000"))),
            "nonbinary"
        );
        // Payout contradicts the result, or no result at all (e.g. voided).
        assert_eq!(
            resolution(&market("finalized", "binary", "yes", Some("0.0000"))),
            "exception"
        );
        assert_eq!(
            resolution(&market("finalized", "binary", "", Some("0.5000"))),
            "exception"
        );
    }

    #[test]
    fn parses_kalshi_settlement_payload() {
        // Shape verified against the live API on 2026-10-07.
        let json = r#"{"ticker":"KXNHL2PTOTAL-26OCT07PITWSH-6","status":"finalized",
            "market_type":"binary","result":"no","settlement_value_dollars":"0.0000",
            "settlement_ts":"2026-10-08T02:00:37.256718Z","yes_bid_dollars":"0.0000"}"#;
        let m: KalshiSettlement = serde_json::from_str(json).unwrap();
        assert_eq!(resolution(&m), "no");
        assert!(m.settlement_ts.is_some());
    }
}
