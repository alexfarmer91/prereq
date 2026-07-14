use reqwest::Client;
use serde::Deserialize;

use crate::error::AppError;

const GAMMA_BASE: &str = "https://gamma-api.polymarket.com";

/// Raw market from the Polymarket Gamma API. Outcome names and prices arrive
/// as JSON-encoded strings inside the JSON (e.g. "[\"Yes\", \"No\"]").
#[derive(Debug, Deserialize)]
struct GammaMarket {
    id: String,
    question: String,
    #[serde(default)]
    outcomes: Option<String>,
    #[serde(rename = "outcomePrices", default)]
    outcome_prices: Option<String>,
}

/// Normalized binary Polymarket market.
#[derive(Debug, Clone)]
pub struct PolyMarket {
    pub id: String,
    pub question: String,
    pub yes_price: f64,
    pub no_price: f64,
}

pub async fn fetch_markets(client: &Client) -> Result<Vec<PolyMarket>, AppError> {
    let url = format!(
        "{GAMMA_BASE}/markets?active=true&closed=false&limit=200&order=volume24hr&ascending=false"
    );

    let raw: Vec<GammaMarket> = client
        .get(&url)
        .send()
        .await
        .map_err(|e| AppError::Internal(format!("Polymarket request failed: {e}")))?
        .error_for_status()
        .map_err(|e| AppError::Internal(format!("Polymarket returned error: {e}")))?
        .json()
        .await
        .map_err(|e| AppError::Internal(format!("Polymarket parse error: {e}")))?;

    Ok(raw.into_iter().filter_map(normalize).collect())
}

fn normalize(m: GammaMarket) -> Option<PolyMarket> {
    let outcomes: Vec<String> = serde_json::from_str(m.outcomes.as_deref()?).ok()?;
    let prices: Vec<String> = serde_json::from_str(m.outcome_prices.as_deref()?).ok()?;
    if outcomes.len() != prices.len() {
        return None;
    }

    let yes_idx = outcomes.iter().position(|o| o.eq_ignore_ascii_case("yes"))?;
    let no_idx = outcomes.iter().position(|o| o.eq_ignore_ascii_case("no"))?;

    let yes_price: f64 = prices[yes_idx].parse().ok()?;
    let no_price: f64 = prices[no_idx].parse().ok()?;
    if !(0.0..=1.0).contains(&yes_price) || !(0.0..=1.0).contains(&no_price) {
        return None;
    }

    Some(PolyMarket {
        id: m.id,
        question: m.question,
        yes_price,
        no_price,
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn normalizes_binary_market() {
        let m = GammaMarket {
            id: "1".into(),
            question: "Will it rain?".into(),
            outcomes: Some(r#"["Yes", "No"]"#.into()),
            outcome_prices: Some(r#"["0.45", "0.55"]"#.into()),
        };
        let p = normalize(m).expect("should normalize");
        assert!((p.yes_price - 0.45).abs() < 1e-9);
        assert!((p.no_price - 0.55).abs() < 1e-9);
    }

    #[test]
    fn skips_non_binary_market() {
        let m = GammaMarket {
            id: "2".into(),
            question: "Who wins?".into(),
            outcomes: Some(r#"["Alice", "Bob"]"#.into()),
            outcome_prices: Some(r#"["0.5", "0.5"]"#.into()),
        };
        assert!(normalize(m).is_none());
    }
}
