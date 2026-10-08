use std::collections::HashMap;
use std::time::{Duration, Instant};

use chrono::{DateTime, Utc};
use reqwest::StatusCode;
use serde::Deserialize;
use serde_json::{json, Value};

use crate::db;
use crate::error::AppError;
use crate::models::market::{Market, Score};
use crate::AppState;

const ANTHROPIC_URL: &str = "https://api.anthropic.com/v1/messages";
// claude-sonnet-4-20250514 is deprecated (retires 2026-06-15); Sonnet 5 is
// its documented drop-in replacement and supports the web_search tool.
const MODEL: &str = "claude-sonnet-5";

// --- Rescore policy -------------------------------------------------------
// Every Claude score is persisted to Postgres (`ai_scores`) and reused until
// it is genuinely stale; the 5-minute market refresh only reprices `edge`
// against the live mid. Claude is called again only when:
//   * the score is older than SCORE_MAX_AGE_HOURS (default 24h), or
//   * the market has moved RESCORE_PRICE_MOVE since scoring, and the score is
//     at least MIN_RESCORE_INTERVAL old (so a volatile market can't thrash).
const DEFAULT_MAX_AGE_HOURS: i64 = 24;
const MIN_RESCORE_INTERVAL: chrono::Duration = chrono::Duration::hours(1);
/// Absolute move in the yes mid (dollars) that invalidates a score.
const RESCORE_PRICE_MOVE: f64 = 0.05;
/// After a failed scoring attempt, leave that ticker alone this long.
const FAILURE_BACKOFF: Duration = Duration::from_secs(60 * 60);
/// Billing/auth failures (e.g. "credit balance is too low") pause all scoring.
const BILLING_PAUSE: Duration = Duration::from_secs(30 * 60);
/// Rate-limit / overload responses pause all scoring briefly.
const RATE_LIMIT_PAUSE: Duration = Duration::from_secs(5 * 60);
const PAUSE_KEY: &str = "scorer:paused";
/// Cost cap: web searches allowed per scored market.
const MAX_SEARCHES_PER_SCORE: u32 = 3;
/// Server-side tool turns can pause (`stop_reason: "pause_turn"`); resume at
/// most this many times before treating the turn as final.
const MAX_CONTINUATIONS: u32 = 5;
/// Overrides the shared client's 30s default: a scoring turn with web search
/// legitimately runs minutes, but must never hang forever — a single stuck
/// call used to wedge the refresh loop and 502 every /markets request.
const REQUEST_TIMEOUT: Duration = Duration::from_secs(180);

/// Web search is opt-in (SCORER_WEB_SEARCH=true) for the automated scorer.
/// The product direction is user-triggered research on paid plans; automated
/// background scoring stays cheap and search-free by default. Read per call,
/// matching the `middleware::auth::skip_auth` pattern.
fn web_search_enabled() -> bool {
    std::env::var("SCORER_WEB_SEARCH").as_deref() == Ok("true")
}

fn max_score_age() -> chrono::Duration {
    let hours = std::env::var("SCORE_MAX_AGE_HOURS")
        .ok()
        .and_then(|v| v.parse::<i64>().ok())
        .filter(|h| *h > 0)
        .unwrap_or(DEFAULT_MAX_AGE_HOURS);
    chrono::Duration::hours(hours)
}

fn cache_key(ticker: &str) -> String {
    format!("score:{ticker}")
}

fn failure_key(ticker: &str) -> String {
    format!("score_fail:{ticker}")
}

/// Whether a persisted score should be replaced by a fresh Claude call.
pub fn is_stale(score: &Score, market: &Market, now: DateTime<Utc>) -> bool {
    let age = now - score.scored_at;
    if age >= max_score_age() {
        return true;
    }
    if age < MIN_RESCORE_INTERVAL {
        return false;
    }
    score
        .market_price_at_score
        .is_some_and(|p| (market.mid_price - p).abs() >= RESCORE_PRICE_MOVE)
}

/// Every number derived from the model's probability is backend arithmetic
/// against live quotes — never the model's own math, never the values from
/// scoring time.
///
/// `edge` is the AI–market gap against the mid (a forecasting benchmark, not
/// a price anyone can trade at). EV uses the executable top-of-book asks and
/// assumes a binary contract paying $1, before fees, ignoring depth.
pub fn reprice(score: &mut Score, market: &Market) {
    let q = score.fair_probability;
    score.edge = q - market.mid_price;
    score.ev_yes_per_dollar = ev_per_dollar(q, market.yes_ask);
    score.ev_no_per_dollar = ev_per_dollar(1.0 - q, market.no_ask);
}

/// Expected profit per $1 spent buying a $1-payout contract at `ask` that
/// pays out with probability `p`: `p / ask - 1`. `None` without a usable ask
/// (Kalshi reports a missing NO ask as 0).
pub fn ev_per_dollar(p: f64, ask: f64) -> Option<f64> {
    (valid_probability(p) && ask > 0.0 && ask < 1.0).then(|| p / ask - 1.0)
}

/// A model probability must be a finite number in [0, 1]. Anything else is
/// rejected as a failed score — never clamped into a plausible forecast.
pub fn valid_probability(p: f64) -> bool {
    (0.0..=1.0).contains(&p)
}

/// True while a billing/auth or rate-limit failure has paused all scoring.
pub async fn is_paused(state: &AppState) -> bool {
    state.cache.get(PAUSE_KEY).await.is_some()
}

async fn pause(state: &AppState, reason: &str, ttl: Duration) {
    tracing::error!(
        "Pausing AI scoring for {}m: {reason}",
        ttl.as_secs() / 60
    );
    state.cache.set(PAUSE_KEY, reason, ttl).await;
}

async fn warm_cache(state: &AppState, ticker: &str, score: &Score) {
    if let Ok(serialized) = serde_json::to_string(score) {
        let ttl = max_score_age().to_std().unwrap_or(FAILURE_BACKOFF);
        state.cache.set(&cache_key(ticker), &serialized, ttl).await;
    }
}

/// Latest persisted score for a ticker — hot cache, then Postgres. Never
/// calls Claude. `edge` is relative to the price at scoring time; callers
/// reprice it with [`reprice`].
pub async fn stored_score(state: &AppState, ticker: &str) -> Option<Score> {
    if let Some(cached) = state.cache.get(&cache_key(ticker)).await {
        if let Ok(score) = serde_json::from_str::<Score>(&cached) {
            return Some(score);
        }
    }
    let pool = state.db.as_ref()?;
    match db::scores::latest(pool, ticker).await {
        Ok(Some(score)) => {
            warm_cache(state, ticker, &score).await;
            Some(score)
        }
        Ok(None) => None,
        Err(e) => {
            tracing::warn!("Loading stored score for {ticker} failed: {e}");
            None
        }
    }
}

/// Attach the latest persisted score (repriced to the live mid) to each
/// market. Hot-cache hits are free; misses go to Postgres in one query.
pub async fn attach_stored_scores(state: &AppState, markets: &mut [Market]) {
    let mut misses = Vec::new();
    for market in markets.iter_mut() {
        if let Some(cached) = state.cache.get(&cache_key(&market.ticker)).await {
            market.score = serde_json::from_str(&cached).ok();
        }
        if market.score.is_none() {
            misses.push(market.ticker.clone());
        }
    }

    let from_db: HashMap<String, Score> = match (&state.db, misses.is_empty()) {
        (Some(pool), false) => match db::scores::latest_for(pool, &misses).await {
            Ok(found) => found,
            Err(e) => {
                tracing::warn!("Loading stored scores failed: {e}");
                HashMap::new()
            }
        },
        _ => HashMap::new(),
    };

    for market in markets.iter_mut() {
        if market.score.is_none() {
            if let Some(score) = from_db.get(&market.ticker) {
                warm_cache(state, &market.ticker, score).await;
                market.score = Some(score.clone());
            }
        }
        if let Some(mut score) = market.score.take() {
            reprice(&mut score, market);
            market.score = Some(score);
        }
    }
}

/// Persisted score when it is still fresh; otherwise one Claude call, whose
/// result is written to Postgres and the hot cache before returning.
///
/// `Ok(None)` means no score is available and none was attempted (scoring
/// is paused, or this ticker failed recently). A failed rescore falls back to
/// the stale score rather than dropping it.
pub async fn get_or_score(
    state: &AppState,
    api_key: &str,
    market: &Market,
) -> Result<Option<Score>, AppError> {
    let existing = stored_score(state, &market.ticker).await.map(|mut s| {
        reprice(&mut s, market);
        s
    });
    if let Some(score) = &existing {
        if !is_stale(score, market, Utc::now()) {
            return Ok(existing);
        }
    }

    if is_paused(state).await
        || state.cache.get(&failure_key(&market.ticker)).await.is_some()
    {
        return Ok(existing);
    }

    let started = Instant::now();
    let result = score_market(state, api_key, market).await;
    track_scored(state, market, &result, started.elapsed().as_millis() as u64);

    match result {
        Ok(outcome) => {
            persist(state, market, &outcome).await;
            Ok(Some(outcome.score))
        }
        Err(e) => {
            // A global pause already covers every ticker; only back off this
            // one for ticker-specific failures (bad JSON, timeouts, ...).
            if !is_paused(state).await {
                state
                    .cache
                    .set(&failure_key(&market.ticker), "1", FAILURE_BACKOFF)
                    .await;
            }
            match existing {
                Some(stale) => {
                    tracing::warn!(
                        "Rescoring {} failed, serving previous score: {e}",
                        market.ticker
                    );
                    Ok(Some(stale))
                }
                None => Err(e),
            }
        }
    }
}

async fn persist(state: &AppState, market: &Market, outcome: &ScoreOutcome) {
    warm_cache(state, &market.ticker, &outcome.score).await;
    let Some(pool) = state.db.as_ref() else {
        return;
    };
    let new = db::scores::NewScore {
        market_ticker: &market.ticker,
        market_title: &market.title,
        score: &outcome.score,
        market_price_at_score: market.mid_price,
        model: MODEL,
        web_search_enabled: web_search_enabled(),
        web_search_count: outcome.web_searches as i32,
        input_tokens: outcome.input_tokens as i64,
        output_tokens: outcome.output_tokens as i64,
        raw_content: Some(&outcome.raw_content),
    };
    // The score is already cached, so a DB hiccup only costs durability.
    if let Err(e) = db::scores::insert(pool, &new).await {
        tracing::error!("Persisting score for {} failed: {e}", market.ticker);
    }
}

/// A completed scoring run plus the usage it consumed (for telemetry).
struct ScoreOutcome {
    score: Score,
    input_tokens: u64,
    output_tokens: u64,
    web_searches: u64,
    round_trips: u32,
    /// Every assistant content block across all turns (text, search queries,
    /// results, citations), with opaque `encrypted_*` payloads stripped.
    raw_content: Value,
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
    let mut raw_content: Vec<Value> = Vec::new();

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
            .timeout(REQUEST_TIMEOUT)
            .header("x-api-key", api_key)
            .header("anthropic-version", "2023-06-01")
            .json(&body)
            .send()
            .await
            .map_err(|e| AppError::Internal(format!("Anthropic request failed: {e}")))?;

        let status = response.status();
        if !status.is_success() {
            let body = response.text().await.unwrap_or_default();
            // Account-level failures hit every market identically — stop the
            // whole scoring pass instead of re-sending each one every refresh.
            if let Some(ttl) = pause_for(status, &body) {
                pause(state, &format!("Anthropic returned {status}"), ttl).await;
            }
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
        raw_content.extend(payload.content.iter().cloned());

        // The server-side search loop pauses after its iteration limit; echo
        // the assistant turn back unchanged and it resumes where it left off.
        if payload.stop_reason.as_deref() == Some("pause_turn") && round_trips <= MAX_CONTINUATIONS
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

    if !valid_probability(score.fair_probability) {
        return Err(AppError::Internal(format!(
            "Out-of-range fair_probability {} for {}",
            score.fair_probability, market.ticker
        )));
    }
    reprice(&mut score, market);
    score.scored_at = Utc::now();
    score.market_price_at_score = Some(market.mid_price);

    let mut raw_content = Value::Array(raw_content);
    strip_encrypted(&mut raw_content);
    Ok(ScoreOutcome {
        score,
        input_tokens,
        output_tokens,
        web_searches,
        round_trips,
        raw_content,
    })
}

/// How long to pause all scoring after a non-success Anthropic response, or
/// `None` for failures specific to one request.
fn pause_for(status: StatusCode, body: &str) -> Option<Duration> {
    match status {
        StatusCode::UNAUTHORIZED | StatusCode::FORBIDDEN => Some(BILLING_PAUSE),
        StatusCode::BAD_REQUEST if body.contains("credit balance") => Some(BILLING_PAUSE),
        StatusCode::TOO_MANY_REQUESTS => Some(RATE_LIMIT_PAUSE),
        s if s.as_u16() == 529 => Some(RATE_LIMIT_PAUSE),
        _ => None,
    }
}

/// Web search results carry large opaque `encrypted_*` blobs that are only
/// useful for echoing back to the API; drop them before persisting.
fn strip_encrypted(value: &mut Value) {
    match value {
        Value::Object(map) => {
            map.retain(|k, _| !k.starts_with("encrypted_"));
            map.values_mut().for_each(strip_encrypted);
        }
        Value::Array(items) => items.iter_mut().for_each(strip_encrypted),
        _ => {}
    }
}

fn build_prompt(market: &Market) -> String {
    let research_instruction = if web_search_enabled() {
        "If recent news could change your estimate, use web search to check \
         before scoring."
    } else {
        "Web search is not available for this request — score from the \
         information given."
    };
    format!(
        r#"You are a prediction market analyst. Score this market.

Market: {title}
Resolution rules: {rules}
Current yes price: ${yes_bid:.2} bid / ${yes_ask:.2} ask
24h volume: ${volume:.2}
Closes: {close}

{research_instruction} Respond with ONLY valid JSON, no other text.
"fair_probability" is your probability, from 0 to 1, that this market
resolves YES.
{{
  "fair_probability": 0.00,
  "confidence": "low|medium|high",
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

    fn market_at(mid: f64) -> Market {
        Market {
            ticker: "T".into(),
            event_ticker: "E".into(),
            title: "T".into(),
            yes_bid: mid,
            yes_ask: mid,
            no_bid: 1.0 - mid,
            no_ask: 1.0 - mid,
            mid_price: mid,
            spread: 0.0,
            volume_24h: 0.0,
            close_time: Utc::now().to_rfc3339(),
            rules_primary: None,
            category: "Politics".into(),
            score: None,
        }
    }

    fn score_at(price: f64, age: chrono::Duration) -> Score {
        Score {
            fair_probability: 0.6,
            confidence: "medium".into(),
            edge: 0.6 - price,
            ev_yes_per_dollar: None,
            ev_no_per_dollar: None,
            rationale: String::new(),
            signals: vec![],
            risks: vec![],
            scored_at: Utc::now() - age,
            market_price_at_score: Some(price),
        }
    }

    #[test]
    fn fresh_score_is_reused_even_if_price_moved() {
        let score = score_at(0.50, chrono::Duration::minutes(10));
        assert!(!is_stale(&score, &market_at(0.70), Utc::now()));
    }

    #[test]
    fn score_is_stale_after_max_age() {
        let score = score_at(0.50, chrono::Duration::hours(25));
        assert!(is_stale(&score, &market_at(0.50), Utc::now()));
    }

    #[test]
    fn big_price_move_invalidates_after_min_interval() {
        let score = score_at(0.50, chrono::Duration::hours(2));
        assert!(!is_stale(&score, &market_at(0.52), Utc::now()));
        assert!(is_stale(&score, &market_at(0.56), Utc::now()));
    }

    #[test]
    fn edge_is_repriced_to_live_mid() {
        let mut score = score_at(0.50, chrono::Duration::hours(2));
        reprice(&mut score, &market_at(0.40));
        assert!((score.edge - 0.20).abs() < 1e-9);
    }

    #[test]
    fn ev_uses_each_sides_ask_not_the_mid() {
        // q = 0.6; YES ask 0.45, NO ask 0.58 (mid 0.43 is never used for EV).
        let mut market = market_at(0.43);
        market.yes_ask = 0.45;
        market.no_ask = 0.58;
        let mut score = score_at(0.43, chrono::Duration::hours(2));
        reprice(&mut score, &market);
        // YES: 0.6 / 0.45 - 1 = +33.3%; NO: 0.4 / 0.58 - 1 = -31.0%.
        assert!((score.ev_yes_per_dollar.unwrap() - (0.6 / 0.45 - 1.0)).abs() < 1e-9);
        assert!((score.ev_no_per_dollar.unwrap() - (0.4 / 0.58 - 1.0)).abs() < 1e-9);
        assert!(score.ev_yes_per_dollar.unwrap() > 0.0);
        assert!(score.ev_no_per_dollar.unwrap() < 0.0);
    }

    #[test]
    fn ev_is_unavailable_without_a_usable_ask() {
        assert_eq!(ev_per_dollar(0.6, 0.0), None); // Kalshi's missing-ask value
        assert_eq!(ev_per_dollar(0.6, 1.0), None);
        assert_eq!(ev_per_dollar(0.6, -0.1), None);
        assert_eq!(ev_per_dollar(0.6, f64::NAN), None);
        assert_eq!(ev_per_dollar(1.5, 0.5), None);
        assert!((ev_per_dollar(0.5, 0.5).unwrap()).abs() < 1e-12);
    }

    #[test]
    fn probability_must_be_finite_and_in_range() {
        assert!(valid_probability(0.0));
        assert!(valid_probability(0.5));
        assert!(valid_probability(1.0));
        assert!(!valid_probability(-0.01));
        assert!(!valid_probability(1.01));
        assert!(!valid_probability(62.0)); // percent instead of a fraction
        assert!(!valid_probability(f64::NAN));
        assert!(!valid_probability(f64::INFINITY));
    }

    #[test]
    fn model_supplied_arithmetic_is_ignored() {
        // An old-format response still parses, but its edge/EV never survive
        // a reprice.
        let text = r#"{"fair_probability":0.62,"confidence":"high","edge":0.4,"ev_per_dollar":9.9,"rationale":"x"}"#;
        let mut score = parse_score(text).expect("should parse");
        reprice(&mut score, &market_at(0.50));
        assert!((score.edge - 0.12).abs() < 1e-9);
        assert!((score.ev_yes_per_dollar.unwrap() - (0.62 / 0.5 - 1.0)).abs() < 1e-9);
    }

    #[test]
    fn account_failures_pause_scoring() {
        let credit = r#"{"error":{"message":"Your credit balance is too low"}}"#;
        assert_eq!(
            pause_for(StatusCode::BAD_REQUEST, credit),
            Some(BILLING_PAUSE)
        );
        assert_eq!(pause_for(StatusCode::UNAUTHORIZED, ""), Some(BILLING_PAUSE));
        assert_eq!(
            pause_for(StatusCode::TOO_MANY_REQUESTS, ""),
            Some(RATE_LIMIT_PAUSE)
        );
        assert_eq!(pause_for(StatusCode::BAD_REQUEST, "bad prompt"), None);
        assert_eq!(pause_for(StatusCode::INTERNAL_SERVER_ERROR, ""), None);
    }

    #[test]
    fn strips_encrypted_search_payloads() {
        let mut v = json!([{
            "type": "web_search_tool_result",
            "content": [{"url": "https://x", "title": "X", "encrypted_content": "blob"}],
            "encrypted_index": "blob"
        }]);
        strip_encrypted(&mut v);
        assert_eq!(
            v,
            json!([{
                "type": "web_search_tool_result",
                "content": [{"url": "https://x", "title": "X"}]
            }])
        );
    }

    #[tokio::test]
    async fn stored_score_survives_via_cache_without_db() {
        let state = AppState::disconnected().await;
        assert!(stored_score(&state, "T").await.is_none());
        let score = score_at(0.50, chrono::Duration::minutes(1));
        warm_cache(&state, "T", &score).await;
        let mut markets = vec![market_at(0.45)];
        attach_stored_scores(&state, &mut markets).await;
        let attached = markets[0].score.as_ref().expect("score attached");
        assert!((attached.edge - 0.15).abs() < 1e-9);
        assert!(attached.ev_yes_per_dollar.is_some());
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
