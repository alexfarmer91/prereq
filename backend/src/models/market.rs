use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};

/// Raw market shape returned by the Kalshi v2 API.
#[derive(Debug, Clone, Deserialize)]
pub struct KalshiMarket {
    pub ticker: String,
    pub event_ticker: String,
    pub title: String,
    pub yes_bid_dollars: String,
    pub yes_ask_dollars: String,
    #[serde(default)]
    pub no_bid_dollars: Option<String>,
    #[serde(default)]
    pub no_ask_dollars: Option<String>,
    #[serde(default)]
    pub volume_24h_fp: Option<String>,
    #[serde(default)]
    pub volume_fp: Option<String>,
    pub close_time: String,
    pub status: String,
    #[serde(default)]
    pub rules_primary: Option<String>,
    #[serde(default)]
    pub category: Option<String>,
    /// Present on multi-leg parlay markets — we skip these entirely.
    #[serde(default)]
    pub mve_collection_ticker: Option<String>,
}

/// AI score produced by the Claude scoring engine.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Score {
    pub fair_probability: f64,
    pub confidence: String,
    pub edge: f64,
    pub ev_per_dollar: f64,
    pub rationale: String,
    #[serde(default)]
    pub signals: Vec<String>,
    #[serde(default)]
    pub risks: Vec<String>,
    #[serde(default = "Utc::now")]
    pub scored_at: DateTime<Utc>,
}

/// Clean market struct returned by our API.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Market {
    pub ticker: String,
    pub event_ticker: String,
    pub title: String,
    pub yes_bid: f64,
    pub yes_ask: f64,
    pub no_bid: f64,
    pub no_ask: f64,
    pub mid_price: f64,
    pub spread: f64,
    pub volume_24h: f64,
    pub close_time: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub rules_primary: Option<String>,
    pub category: String,
    #[serde(default)]
    pub score: Option<Score>,
}

/// One point of price history for the detail chart.
#[derive(Debug, Clone, Serialize)]
pub struct HistoryPoint {
    pub ts: String,
    pub yes_price: f64,
}
