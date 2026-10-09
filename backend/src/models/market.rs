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
///
/// Claude supplies only `fair_probability` (an unvalidated estimate that the
/// market resolves YES), the self-rated `confidence`, and the research text.
/// Every derived number is backend arithmetic — see `scorer::reprice`.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Score {
    pub fair_probability: f64,
    pub confidence: String,
    /// AI–market probability gap: `fair_probability - mid_price`. A gap is
    /// not demonstrated edge.
    #[serde(default)]
    pub edge: f64,
    /// Expected profit per $1 spent buying YES at the top-of-book ask, *if*
    /// `fair_probability` were correct. Binary $1 payout, before fees, no
    /// depth or slippage. `None` when there is no usable ask.
    #[serde(default)]
    pub ev_yes_per_dollar: Option<f64>,
    /// Same as `ev_yes_per_dollar` for buying NO at the NO ask.
    #[serde(default)]
    pub ev_no_per_dollar: Option<f64>,
    pub rationale: String,
    #[serde(default)]
    pub signals: Vec<String>,
    #[serde(default)]
    pub risks: Vec<String>,
    /// Structured research behind the estimate (prompt v3+). Empty for older
    /// scores. Claims are the model's — sources are not independently checked.
    #[serde(default)]
    pub evidence: Vec<Evidence>,
    #[serde(default = "Utc::now")]
    pub scored_at: DateTime<Utc>,
    /// Market mid when Claude scored it. `edge` is recomputed against the
    /// live mid on every read; this anchors the move-since-scored rescore
    /// check. Absent on scores cached before it existed.
    #[serde(default)]
    pub market_price_at_score: Option<f64>,
}

/// One piece of evidence the model cited for its estimate.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Evidence {
    pub claim: String,
    /// URL, or a non-web source such as "resolution rules".
    #[serde(default)]
    pub source: Option<String>,
    /// Publication/observation date as given by the model (YYYY-MM-DD).
    #[serde(default)]
    pub date: Option<String>,
    /// Which outcome the claim points toward: yes | no | neutral.
    #[serde(default)]
    pub supports: Option<String>,
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
