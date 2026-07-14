use std::time::Duration;

use chrono::Utc;
use reqwest::Client;
use serde::Deserialize;
use serde_json::json;

use crate::error::AppError;
use crate::models::market::{Market, Score};
use crate::services::cache::Cache;

const ANTHROPIC_URL: &str = "https://api.anthropic.com/v1/messages";
const MODEL: &str = "claude-sonnet-4-20250514";
const SCORE_TTL: Duration = Duration::from_secs(30 * 60);

/// Score with cache-aside: Redis/memory first, Claude on miss.
pub async fn get_or_score(
    http: &Client,
    api_key: &str,
    cache: &Cache,
    market: &Market,
) -> Result<Score, AppError> {
    let key = format!("score:{}", market.ticker);

    if let Some(cached) = cache.get(&key).await {
        if let Ok(score) = serde_json::from_str::<Score>(&cached) {
            return Ok(score);
        }
    }

    let score = score_market(http, api_key, market).await?;
    if let Ok(serialized) = serde_json::to_string(&score) {
        cache.set(&key, &serialized, SCORE_TTL).await;
    }
    Ok(score)
}

async fn score_market(http: &Client, api_key: &str, market: &Market) -> Result<Score, AppError> {
    let prompt = build_prompt(market);

    let body = json!({
        "model": MODEL,
        "max_tokens": 1024,
        "messages": [{ "role": "user", "content": prompt }],
    });

    let response = http
        .post(ANTHROPIC_URL)
        .header("x-api-key", api_key)
        .header("anthropic-version", "2023-06-01")
        .json(&body)
        .send()
        .await
        .map_err(|e| AppError::Internal(format!("Anthropic request failed: {e}")))?
        .error_for_status()
        .map_err(|e| AppError::Internal(format!("Anthropic returned error: {e}")))?;

    let payload: AnthropicResponse = response
        .json()
        .await
        .map_err(|e| AppError::Internal(format!("Anthropic response parse error: {e}")))?;

    let text = payload
        .content
        .iter()
        .filter_map(|block| block.text.as_deref())
        .collect::<Vec<_>>()
        .join("");

    let mut score = parse_score(&text)
        .ok_or_else(|| AppError::Internal(format!("Unparseable score for {}", market.ticker)))?;

    // Edge is deterministic given the model's fair probability — don't trust
    // the LLM's arithmetic.
    score.edge = score.fair_probability - market.mid_price;
    score.scored_at = Utc::now();
    Ok(score)
}

fn build_prompt(market: &Market) -> String {
    format!(
        r#"You are a prediction market analyst. Score this market and return ONLY valid JSON.

Market: {title}
Resolution rules: {rules}
Current yes price: ${yes_bid:.2} bid / ${yes_ask:.2} ask
24h volume: ${volume:.2}
Closes: {close}

Return JSON:
{{
  "fair_probability": 0.00,
  "confidence": "low|medium|high",
  "edge": 0.00,
  "ev_per_dollar": 0.00,
  "rationale": "2-3 sentence explanation",
  "signals": ["signal 1", "signal 2"],
  "risks": ["risk 1", "risk 2"]
}}"#,
        title = market.title,
        rules = market.rules_primary.as_deref().unwrap_or("(not provided)"),
        yes_bid = market.yes_bid,
        yes_ask = market.yes_ask,
        volume = market.volume_24h,
        close = market.close_time,
    )
}

/// Extract the first JSON object from model output, tolerating code fences
/// and surrounding prose.
pub fn parse_score(text: &str) -> Option<Score> {
    let start = text.find('{')?;
    let end = text.rfind('}')?;
    if end <= start {
        return None;
    }
    serde_json::from_str::<Score>(&text[start..=end]).ok()
}

#[derive(Debug, Deserialize)]
struct AnthropicResponse {
    content: Vec<ContentBlock>,
}

#[derive(Debug, Deserialize)]
struct ContentBlock {
    #[serde(default)]
    text: Option<String>,
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parses_bare_json() {
        let text = r#"{"fair_probability":0.62,"confidence":"medium","edge":0.05,"ev_per_dollar":0.08,"rationale":"Looks cheap.","signals":["s1"],"risks":["r1"]}"#;
        let score = parse_score(text).expect("should parse");
        assert!((score.fair_probability - 0.62).abs() < 1e-9);
        assert_eq!(score.confidence, "medium");
        assert_eq!(score.signals, vec!["s1"]);
    }

    #[test]
    fn parses_fenced_json_with_prose() {
        let text = "Here is my analysis:\n```json\n{\"fair_probability\":0.4,\"confidence\":\"low\",\"edge\":-0.1,\"ev_per_dollar\":-0.05,\"rationale\":\"Overpriced.\"}\n```\nHope that helps!";
        let score = parse_score(text).expect("should parse");
        assert!((score.fair_probability - 0.4).abs() < 1e-9);
        assert!(score.signals.is_empty());
    }

    #[test]
    fn rejects_garbage() {
        assert!(parse_score("no json here").is_none());
        assert!(parse_score("{not valid}").is_none());
    }
}
