use std::time::{Duration, Instant};

use chrono::Utc;
use serde::Deserialize;
use serde_json::{json, Value};

use crate::error::AppError;
use crate::models::market::{Market, Score};
use crate::AppState;

const ANTHROPIC_URL: &str = "https://api.anthropic.com/v1/messages";
// claude-sonnet-4-20250514 is deprecated (retires 2026-06-15); Sonnet 5 is
// its documented drop-in replacement and supports the web_search tool.
const MODEL: &str = "claude-sonnet-5";
const SCORE_TTL: Duration = Duration::from_secs(30 * 60);
/// Cost cap: web searches allowed per scored market.
const MAX_SEARCHES_PER_SCORE: u32 = 3;
/// Server-side tool turns can pause (`stop_reason: "pause_turn"`); resume at
/// most this many times before treating the turn as final.
const MAX_CONTINUATIONS: u32 = 5;

/// Web search is opt-in (SCORER_WEB_SEARCH=true) for the automated scorer.
/// The product direction is user-triggered research on paid plans; automated
/// background scoring stays cheap and search-free by default. Read per call,
/// matching the `middleware::auth::skip_auth` pattern.
fn web_search_enabled() -> bool {
    std::env::var("SCORER_WEB_SEARCH").as_deref() == Ok("true")
}

/// Score with cache-aside: Redis/memory first, Claude on miss.
pub async fn get_or_score(
    state: &AppState,
    api_key: &str,
    market: &Market,
) -> Result<Score, AppError> {
    let key = format!("score:{}", market.ticker);

    if let Some(cached) = state.cache.get(&key).await {
        if let Ok(score) = serde_json::from_str::<Score>(&cached) {
            return Ok(score);
        }
    }

    let started = Instant::now();
    let result = score_market(state, api_key, market).await;
    track_scored(state, market, &result, started.elapsed().as_millis() as u64);

    let score = result?.score;
    if let Ok(serialized) = serde_json::to_string(&score) {
        state.cache.set(&key, &serialized, SCORE_TTL).await;
    }
    Ok(score)
}

/// A completed scoring run plus the usage it consumed (for telemetry).
struct ScoreOutcome {
    score: Score,
    input_tokens: u64,
    output_tokens: u64,
    web_searches: u64,
    round_trips: u32,
}

fn track_scored(
    state: &AppState,
    market: &Market,
    result: &Result<ScoreOutcome, AppError>,
    duration_ms: u64,
) {
    let mut props = json!({
        "market_ticker": market.ticker,
        "market_title": market.title,
        "market_category": market.category.to_lowercase(),
        "model": MODEL,
        "web_search_enabled": web_search_enabled(),
        "duration_ms": duration_ms,
        "succeeded": result.is_ok(),
    });
    match result {
        Ok(outcome) => {
            props["input_tokens"] = json!(outcome.input_tokens);
            props["output_tokens"] = json!(outcome.output_tokens);
            props["web_search_count"] = json!(outcome.web_searches);
            props["api_round_trips"] = json!(outcome.round_trips);
            props["fair_probability"] = json!(outcome.score.fair_probability);
            props["edge"] = json!(outcome.score.edge);
            props["confidence"] = json!(outcome.score.confidence);
        }
        Err(e) => {
            props["error"] = json!(e.to_string().chars().take(200).collect::<String>());
        }
    }
    state.telemetry.track("market_scored", props);
}

async fn score_market(
    state: &AppState,
    api_key: &str,
    market: &Market,
) -> Result<ScoreOutcome, AppError> {
    let mut messages = vec![json!({ "role": "user", "content": build_prompt(market) })];
    let mut input_tokens = 0u64;
    let mut output_tokens = 0u64;
    let mut web_searches = 0u64;
    let mut round_trips = 0u32;

    let payload = loop {
        round_trips += 1;
        let mut body = json!({
            "model": MODEL,
            "max_tokens": 4096,
            "messages": messages,
        });
        if web_search_enabled() {
            body["tools"] = json!([{
                "type": "web_search_20260209",
                "name": "web_search",
                "max_uses": MAX_SEARCHES_PER_SCORE,
            }]);
        }

        let response = state
            .http
            .post(ANTHROPIC_URL)
            .header("x-api-key", api_key)
            .header("anthropic-version", "2023-06-01")
            .json(&body)
            .send()
            .await
            .map_err(|e| AppError::Internal(format!("Anthropic request failed: {e}")))?;

        let status = response.status();
        if !status.is_success() {
            let body = response.text().await.unwrap_or_default();
            return Err(AppError::Internal(format!(
                "Anthropic returned {status}: {body}"
            )));
        }

        let payload: AnthropicResponse = response
            .json()
            .await
            .map_err(|e| AppError::Internal(format!("Anthropic response parse error: {e}")))?;

        input_tokens += payload.usage.input_tokens
            + payload.usage.cache_creation_input_tokens
            + payload.usage.cache_read_input_tokens;
        output_tokens += payload.usage.output_tokens;
        if let Some(server_tools) = &payload.usage.server_tool_use {
            web_searches += server_tools.web_search_requests;
        }

        // The server-side search loop pauses after its iteration limit; echo
        // the assistant turn back unchanged and it resumes where it left off.
        if payload.stop_reason.as_deref() == Some("pause_turn")
            && round_trips <= MAX_CONTINUATIONS
        {
            messages.push(json!({ "role": "assistant", "content": payload.content }));
            continue;
        }
        break payload;
    };

    let text = payload
        .content
        .iter()
        .filter(|block| block.get("type").and_then(Value::as_str) == Some("text"))
        .filter_map(|block| block.get("text").and_then(Value::as_str))
        .collect::<Vec<_>>()
        .join("");

    let mut score = parse_score(&text).ok_or_else(|| {
        let preview: String = text.chars().take(500).collect();
        AppError::Internal(format!(
            "Unparseable score for {}: {preview:?}",
            market.ticker
        ))
    })?;

    // Edge is deterministic given the model's fair probability — don't trust
    // the LLM's arithmetic.
    score.edge = score.fair_probability - market.mid_price;
    score.scored_at = Utc::now();
    Ok(ScoreOutcome {
        score,
        input_tokens,
        output_tokens,
        web_searches,
        round_trips,
    })
}

fn build_prompt(market: &Market) -> String {
    format!(
        r#"You are a prediction market analyst. Score this market.

Market: {title}
Resolution rules: {rules}
Current yes price: ${yes_bid:.2} bid / ${yes_ask:.2} ask
24h volume: ${volume:.2}
Closes: {close}

If recent news could change your estimate, use web search to check before
scoring. Your final message must be ONLY valid JSON:
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
    /// Kept as raw JSON: text blocks are read out, and the whole array is
    /// echoed back verbatim when resuming a paused turn.
    content: Vec<Value>,
    #[serde(default)]
    stop_reason: Option<String>,
    #[serde(default)]
    usage: Usage,
}

#[derive(Debug, Default, Deserialize)]
struct Usage {
    #[serde(default)]
    input_tokens: u64,
    #[serde(default)]
    output_tokens: u64,
    #[serde(default)]
    cache_creation_input_tokens: u64,
    #[serde(default)]
    cache_read_input_tokens: u64,
    #[serde(default)]
    server_tool_use: Option<ServerToolUsage>,
}

#[derive(Debug, Default, Deserialize)]
struct ServerToolUsage {
    #[serde(default)]
    web_search_requests: u64,
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

    #[test]
    fn reads_usage_and_text_from_response_json() {
        let raw = r#"{
            "content": [
                {"type": "server_tool_use", "id": "srvtoolu_1", "name": "web_search", "input": {"query": "fed rate cut"}},
                {"type": "web_search_tool_result", "tool_use_id": "srvtoolu_1", "content": []},
                {"type": "text", "text": "{\"fair_probability\":0.5}"}
            ],
            "stop_reason": "end_turn",
            "usage": {
                "input_tokens": 100,
                "output_tokens": 50,
                "server_tool_use": {"web_search_requests": 2}
            }
        }"#;
        let payload: AnthropicResponse = serde_json::from_str(raw).expect("should deserialize");
        assert_eq!(payload.stop_reason.as_deref(), Some("end_turn"));
        assert_eq!(payload.usage.input_tokens, 100);
        assert_eq!(
            payload.usage.server_tool_use.unwrap().web_search_requests,
            2
        );
        let text = payload
            .content
            .iter()
            .filter(|b| b.get("type").and_then(Value::as_str) == Some("text"))
            .filter_map(|b| b.get("text").and_then(Value::as_str))
            .collect::<Vec<_>>()
            .join("");
        assert_eq!(text, "{\"fair_probability\":0.5}");
    }
}
