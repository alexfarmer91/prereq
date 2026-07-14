use std::collections::HashSet;
use std::time::Duration;

use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};

use crate::models::market::Market;
use crate::services::polymarket::{self, PolyMarket};
use crate::AppState;

const ARB_INTERVAL: Duration = Duration::from_secs(5 * 60);
const ARB_CACHE_TTL: Duration = Duration::from_secs(6 * 60);
pub const ARB_CACHE_KEY: &str = "arbs";

/// Buy YES on Kalshi and NO on Polymarket for a combined cost under $0.97
/// (the 3¢ headroom approximates fees) and lock in the difference.
const ARB_THRESHOLD: f64 = 0.97;
/// Minimum title-token overlap to consider two markets equivalent.
const MIN_SIMILARITY: f64 = 0.55;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ArbOpportunity {
    pub kalshi_ticker: String,
    pub kalshi_title: String,
    pub polymarket_id: String,
    pub polymarket_question: String,
    pub kalshi_yes_ask: f64,
    pub polymarket_no_ask: f64,
    pub combined_cost: f64,
    pub edge: f64,
    pub detected_at: DateTime<Utc>,
}

pub fn find_arbs(kalshi: &[Market], poly: &[PolyMarket]) -> Vec<ArbOpportunity> {
    let mut arbs = Vec::new();
    let now = Utc::now();

    for market in kalshi {
        let k_tokens = tokenize(&market.title);
        if k_tokens.is_empty() {
            continue;
        }

        let best = poly
            .iter()
            .map(|p| (similarity(&k_tokens, &tokenize(&p.question)), p))
            .filter(|(sim, _)| *sim >= MIN_SIMILARITY)
            .max_by(|(a, _), (b, _)| a.partial_cmp(b).unwrap_or(std::cmp::Ordering::Equal));

        let Some((_, poly_match)) = best else { continue };

        let combined = market.yes_ask + poly_match.no_price;
        if market.yes_ask > 0.0 && poly_match.no_price > 0.0 && combined < ARB_THRESHOLD {
            arbs.push(ArbOpportunity {
                kalshi_ticker: market.ticker.clone(),
                kalshi_title: market.title.clone(),
                polymarket_id: poly_match.id.clone(),
                polymarket_question: poly_match.question.clone(),
                kalshi_yes_ask: market.yes_ask,
                polymarket_no_ask: poly_match.no_price,
                combined_cost: combined,
                edge: ARB_THRESHOLD - combined,
                detected_at: now,
            });
        }
    }

    arbs.sort_by(|a, b| {
        b.edge
            .partial_cmp(&a.edge)
            .unwrap_or(std::cmp::Ordering::Equal)
    });
    arbs
}

const STOPWORDS: &[&str] = &[
    "will", "the", "be", "in", "on", "at", "a", "an", "of", "to", "by", "for", "is", "or", "and",
];

fn tokenize(title: &str) -> HashSet<String> {
    title
        .to_lowercase()
        .split(|c: char| !c.is_alphanumeric())
        .filter(|t| t.len() > 1 && !STOPWORDS.contains(t))
        .map(|t| t.to_string())
        .collect()
}

fn similarity(a: &HashSet<String>, b: &HashSet<String>) -> f64 {
    if a.is_empty() || b.is_empty() {
        return 0.0;
    }
    let intersection = a.intersection(b).count() as f64;
    let union = a.union(b).count() as f64;
    intersection / union
}

pub fn spawn_arb_task(state: AppState) {
    tokio::spawn(async move {
        loop {
            match run_once(&state).await {
                Ok(count) => tracing::info!("Arb scan complete: {count} opportunities"),
                Err(e) => tracing::warn!("Arb scan failed: {e}"),
            }
            tokio::time::sleep(ARB_INTERVAL).await;
        }
    });
}

async fn run_once(state: &AppState) -> Result<usize, crate::error::AppError> {
    let kalshi_markets = state.markets.all().await;
    if kalshi_markets.is_empty() {
        return Ok(0);
    }
    let poly_markets = polymarket::fetch_markets(&state.http).await?;
    let arbs = find_arbs(&kalshi_markets, &poly_markets);
    let count = arbs.len();

    if let Ok(serialized) = serde_json::to_string(&arbs) {
        state
            .cache
            .set(ARB_CACHE_KEY, &serialized, ARB_CACHE_TTL)
            .await;
    }
    Ok(count)
}

/// Read the cached arb list (empty when the scan hasn't run or found nothing).
pub async fn cached_arbs(state: &AppState) -> Vec<ArbOpportunity> {
    match state.cache.get(ARB_CACHE_KEY).await {
        Some(json) => serde_json::from_str(&json).unwrap_or_default(),
        None => Vec::new(),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn kalshi_market(ticker: &str, title: &str, yes_ask: f64) -> Market {
        Market {
            ticker: ticker.into(),
            event_ticker: ticker.into(),
            title: title.into(),
            yes_bid: yes_ask - 0.02,
            yes_ask,
            no_bid: 0.0,
            no_ask: 0.0,
            mid_price: yes_ask - 0.01,
            spread: 0.02,
            volume_24h: 10_000.0,
            close_time: "2026-12-31T00:00:00Z".into(),
            rules_primary: None,
            category: "Other".into(),
            score: None,
        }
    }

    fn poly(id: &str, question: &str, yes: f64, no: f64) -> PolyMarket {
        PolyMarket {
            id: id.into(),
            question: question.into(),
            yes_price: yes,
            no_price: no,
        }
    }

    #[test]
    fn detects_cross_platform_arb() {
        let kalshi = vec![kalshi_market(
            "FED-25DEC",
            "Will the Fed cut interest rates in December?",
            0.40,
        )];
        let polys = vec![poly(
            "p1",
            "Will the Fed cut interest rates in December?",
            0.55,
            0.50,
        )];
        let arbs = find_arbs(&kalshi, &polys);
        assert_eq!(arbs.len(), 1);
        assert!((arbs[0].combined_cost - 0.90).abs() < 1e-9);
        assert!((arbs[0].edge - 0.07).abs() < 1e-9);
    }

    #[test]
    fn ignores_unprofitable_pairs() {
        let kalshi = vec![kalshi_market(
            "FED-25DEC",
            "Will the Fed cut interest rates in December?",
            0.60,
        )];
        let polys = vec![poly(
            "p1",
            "Will the Fed cut interest rates in December?",
            0.55,
            0.45,
        )];
        assert!(find_arbs(&kalshi, &polys).is_empty());
    }

    #[test]
    fn ignores_dissimilar_markets() {
        let kalshi = vec![kalshi_market(
            "NYC-TEMP",
            "Will the high temp in NYC exceed 90 degrees tomorrow?",
            0.30,
        )];
        let polys = vec![poly(
            "p1",
            "Will the Fed cut interest rates in December?",
            0.55,
            0.20,
        )];
        assert!(find_arbs(&kalshi, &polys).is_empty());
    }

    #[test]
    fn similarity_is_token_jaccard() {
        let a = tokenize("Will the Fed cut interest rates in December?");
        let b = tokenize("Fed cut interest rates December");
        assert!(similarity(&a, &b) > 0.9);
    }
}
