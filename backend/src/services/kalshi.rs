use std::collections::HashMap;

use chrono::{DateTime, Utc};
use reqwest::Client;
use serde::Deserialize;
use tokio::time::{sleep, Duration};

use crate::error::AppError;
use crate::models::market::{HistoryPoint, KalshiMarket, Market};

const KALSHI_BASE: &str = "https://external-api.kalshi.com/trade-api/v2";
const PAGE_LIMIT: u32 = 200;
/// Cap for on-demand fetches. Full pagination moves to the background refresh task in step 5.
const MAX_PAGES: usize = 10;

/// Event envelope returned by GET /events?with_nested_markets=true.
/// Using events instead of /markets avoids the thousands of multivariate parlay
/// markets that dominate the /markets pagination order.
#[derive(Debug, Deserialize)]
struct KalshiEvent {
    category: Option<String>,
    markets: Vec<KalshiMarket>,
}

#[derive(Debug, Deserialize)]
struct EventsPage {
    events: Vec<KalshiEvent>,
    cursor: Option<String>,
}

pub async fn fetch_filtered_markets(
    client: &Client,
    category_filter: Option<&str>,
) -> Result<Vec<Market>, AppError> {
    let raw = fetch_all_markets(client).await?;
    tracing::info!("Fetched {} markets from Kalshi events", raw.len());

    let filtered = apply_filters(raw);
    tracing::debug!("{} markets passed filters", filtered.len());

    let grouped = group_by_event(filtered);
    tracing::debug!("{} markets after event grouping", grouped.len());

    let mut markets: Vec<Market> = grouped.into_iter().filter_map(to_market).collect();

    if let Some(cat) = category_filter {
        markets.retain(|m| m.category.eq_ignore_ascii_case(cat));
    }

    markets.sort_by(|a, b| {
        b.volume_24h
            .partial_cmp(&a.volume_24h)
            .unwrap_or(std::cmp::Ordering::Equal)
    });

    Ok(markets)
}

async fn fetch_all_markets(client: &Client) -> Result<Vec<KalshiMarket>, AppError> {
    let mut all = Vec::new();
    let mut cursor: Option<String> = None;
    let mut pages = 0;

    loop {
        let mut url = format!(
            "{KALSHI_BASE}/events?status=open&with_nested_markets=true&limit={PAGE_LIMIT}"
        );
        if let Some(ref c) = cursor {
            url.push_str(&format!("&cursor={c}"));
        }

        let response = client
            .get(&url)
            .send()
            .await
            .map_err(|e| AppError::Internal(format!("Kalshi request failed: {e}")))?;

        if response.status() == reqwest::StatusCode::TOO_MANY_REQUESTS {
            tracing::warn!(
                "Kalshi rate limit hit after {} markets — returning partial results",
                all.len()
            );
            break;
        }

        let page: EventsPage = response
            .error_for_status()
            .map_err(|e| AppError::Internal(format!("Kalshi returned error status: {e}")))?
            .json()
            .await
            .map_err(|e| AppError::Internal(format!("Kalshi response parse error: {e}")))?;

        let next = page.cursor.filter(|c| !c.is_empty());

        // Flatten event.markets, inheriting category from the event level
        for event in page.events {
            let cat = event.category;
            for mut market in event.markets {
                if market.category.is_none() {
                    market.category = cat.clone();
                }
                all.push(market);
            }
        }

        pages += 1;
        if pages >= MAX_PAGES {
            tracing::debug!("Reached {MAX_PAGES}-page cap ({} markets collected)", all.len());
            break;
        }

        match next {
            Some(c) => {
                cursor = Some(c);
                sleep(Duration::from_millis(150)).await;
            }
            None => break,
        }
    }

    Ok(all)
}

fn apply_filters(markets: Vec<KalshiMarket>) -> Vec<KalshiMarket> {
    let now = Utc::now();
    markets
        .into_iter()
        .filter(|m| {
            if m.mve_collection_ticker.is_some() {
                return false;
            }

            let yes_bid: f64 = m.yes_bid_dollars.parse().unwrap_or(0.0);
            let yes_ask: f64 = m.yes_ask_dollars.parse().unwrap_or(0.0);
            let volume_24h: f64 = m
                .volume_24h_fp
                .as_deref()
                .unwrap_or("0")
                .parse()
                .unwrap_or(0.0);
            let spread = yes_ask - yes_bid;

            let hours_to_close = DateTime::parse_from_rfc3339(&m.close_time)
                .map(|t| t.signed_duration_since(now).num_hours())
                .unwrap_or(0);

            volume_24h >= 5000.0
                && spread <= 0.08
                && hours_to_close >= 48
                && yes_bid >= 0.03
                && yes_bid <= 0.97
        })
        .collect()
}

/// Keep only the most-liquid market per event (highest 24h volume).
fn group_by_event(markets: Vec<KalshiMarket>) -> Vec<KalshiMarket> {
    let mut best: HashMap<String, KalshiMarket> = HashMap::new();

    for market in markets {
        let vol: f64 = market
            .volume_24h_fp
            .as_deref()
            .unwrap_or("0")
            .parse()
            .unwrap_or(0.0);

        let entry = best
            .entry(market.event_ticker.clone())
            .or_insert_with(|| market.clone());

        let entry_vol: f64 = entry
            .volume_24h_fp
            .as_deref()
            .unwrap_or("0")
            .parse()
            .unwrap_or(0.0);

        if vol > entry_vol {
            *entry = market;
        }
    }

    best.into_values().collect()
}

/// Fetch one market directly from Kalshi (used when a ticker isn't in the
/// filtered snapshot — e.g. a low-liquidity strike opened from a detail view).
pub async fn fetch_market(client: &Client, ticker: &str) -> Result<Option<Market>, AppError> {
    #[derive(Deserialize)]
    struct MarketResponse {
        market: KalshiMarket,
    }

    let url = format!("{KALSHI_BASE}/markets/{ticker}");
    let response = client
        .get(&url)
        .send()
        .await
        .map_err(|e| AppError::Internal(format!("Kalshi request failed: {e}")))?;

    if response.status() == reqwest::StatusCode::NOT_FOUND {
        return Ok(None);
    }

    let payload: MarketResponse = response
        .error_for_status()
        .map_err(|e| AppError::Internal(format!("Kalshi returned error status: {e}")))?
        .json()
        .await
        .map_err(|e| AppError::Internal(format!("Kalshi response parse error: {e}")))?;

    Ok(to_market(payload.market))
}

/// All markets (strike variants) under one event, unfiltered.
pub async fn fetch_event_markets(
    client: &Client,
    event_ticker: &str,
) -> Result<Vec<Market>, AppError> {
    #[derive(Deserialize)]
    struct EventDetail {
        #[serde(default)]
        category: Option<String>,
        #[serde(default)]
        markets: Option<Vec<KalshiMarket>>,
    }
    #[derive(Deserialize)]
    struct EventResponse {
        event: EventDetail,
        #[serde(default)]
        markets: Option<Vec<KalshiMarket>>,
    }

    let url = format!("{KALSHI_BASE}/events/{event_ticker}?with_nested_markets=true");
    let payload: EventResponse = client
        .get(&url)
        .send()
        .await
        .map_err(|e| AppError::Internal(format!("Kalshi request failed: {e}")))?
        .error_for_status()
        .map_err(|e| AppError::Internal(format!("Kalshi returned error status: {e}")))?
        .json()
        .await
        .map_err(|e| AppError::Internal(format!("Kalshi response parse error: {e}")))?;

    let category = payload.event.category;
    let raw = payload
        .event
        .markets
        .or(payload.markets)
        .unwrap_or_default();

    Ok(raw
        .into_iter()
        .map(|mut m| {
            if m.category.is_none() {
                m.category = category.clone();
            }
            m
        })
        .filter(|m| m.status == "active")
        .filter_map(to_market)
        .collect())
}

/// Hourly price history for the last 7 days. Best effort: any failure returns
/// an empty vec and the frontend hides the chart.
pub async fn fetch_history(client: &Client, ticker: &str, event_ticker: &str) -> Vec<HistoryPoint> {
    // Kalshi series tickers are the event ticker minus its date suffix
    // (KXHIGHNY-26MAY18 -> KXHIGHNY).
    let series = event_ticker.split('-').next().unwrap_or(event_ticker);
    let end = Utc::now().timestamp();
    let start = end - 7 * 24 * 3600;
    let url = format!(
        "{KALSHI_BASE}/series/{series}/markets/{ticker}/candlesticks?start_ts={start}&end_ts={end}&period_interval=60"
    );

    let payload: serde_json::Value = match async {
        client
            .get(&url)
            .send()
            .await?
            .error_for_status()?
            .json::<serde_json::Value>()
            .await
    }
    .await
    {
        Ok(v) => v,
        Err(e) => {
            tracing::debug!("History fetch for {ticker} failed: {e}");
            return Vec::new();
        }
    };

    let Some(candles) = payload.get("candlesticks").and_then(|c| c.as_array()) else {
        return Vec::new();
    };

    candles
        .iter()
        .filter_map(|candle| {
            let ts = candle.get("end_period_ts")?.as_i64()?;
            let close = candle
                .get("price")
                .and_then(|p| p.get("close"))
                .or_else(|| candle.get("yes_bid").and_then(|p| p.get("close")))?;
            let price = parse_price_value(close)?;
            Some(HistoryPoint {
                ts: DateTime::from_timestamp(ts, 0)?.to_rfc3339(),
                yes_price: price,
            })
        })
        .collect()
}

/// Kalshi candlestick prices may arrive as dollar strings, dollar floats, or
/// legacy integer cents — normalize all of them to dollars.
fn parse_price_value(value: &serde_json::Value) -> Option<f64> {
    let raw = match value {
        serde_json::Value::Number(n) => n.as_f64()?,
        serde_json::Value::String(s) => s.parse().ok()?,
        _ => return None,
    };
    let dollars = if raw > 1.5 { raw / 100.0 } else { raw };
    (0.0..=1.0).contains(&dollars).then_some(dollars)
}

pub(crate) fn to_market(m: KalshiMarket) -> Option<Market> {
    let yes_bid: f64 = m.yes_bid_dollars.parse().ok()?;
    let yes_ask: f64 = m.yes_ask_dollars.parse().ok()?;
    let no_bid: f64 = m
        .no_bid_dollars
        .as_deref()
        .unwrap_or("0")
        .parse()
        .unwrap_or(0.0);
    let no_ask: f64 = m
        .no_ask_dollars
        .as_deref()
        .unwrap_or("0")
        .parse()
        .unwrap_or(0.0);
    let volume_24h: f64 = m
        .volume_24h_fp
        .as_deref()
        .unwrap_or("0")
        .parse()
        .ok()?;

    let category = m
        .category
        .unwrap_or_else(|| infer_category(&m.event_ticker));

    Some(Market {
        ticker: m.ticker,
        event_ticker: m.event_ticker,
        title: m.title,
        yes_bid,
        yes_ask,
        no_bid,
        no_ask,
        mid_price: (yes_bid + yes_ask) / 2.0,
        spread: yes_ask - yes_bid,
        volume_24h,
        close_time: m.close_time,
        rules_primary: m.rules_primary,
        category,
        score: None,
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    fn raw(ticker: &str, yes_bid: &str, yes_ask: &str, vol: &str, hours_out: i64) -> KalshiMarket {
        KalshiMarket {
            ticker: ticker.to_string(),
            event_ticker: format!("{ticker}-EV"),
            title: "Test market".into(),
            yes_bid_dollars: yes_bid.into(),
            yes_ask_dollars: yes_ask.into(),
            no_bid_dollars: None,
            no_ask_dollars: None,
            volume_24h_fp: Some(vol.into()),
            volume_fp: None,
            close_time: (Utc::now() + chrono::Duration::hours(hours_out)).to_rfc3339(),
            status: "active".into(),
            rules_primary: None,
            category: None,
            mve_collection_ticker: None,
        }
    }

    #[test]
    fn filters_drop_thin_wide_late_and_extreme_markets() {
        let markets = vec![
            raw("GOOD", "0.50", "0.55", "9000", 100),
            raw("THIN", "0.50", "0.55", "100", 100),     // low volume
            raw("WIDE", "0.50", "0.60", "9000", 100),    // spread > 0.08
            raw("LATE", "0.50", "0.55", "9000", 10),     // closes < 48h
            raw("EXTREME", "0.98", "0.99", "9000", 100), // near resolution
        ];
        let kept = apply_filters(markets);
        assert_eq!(kept.len(), 1);
        assert_eq!(kept[0].ticker, "GOOD");
    }

    #[test]
    fn filters_drop_parlay_markets() {
        let mut parlay = raw("PARLAY", "0.50", "0.55", "9000", 100);
        parlay.mve_collection_ticker = Some("MVE".into());
        assert!(apply_filters(vec![parlay]).is_empty());
    }

    #[test]
    fn grouping_keeps_most_liquid_market_per_event() {
        let mut a = raw("A1", "0.50", "0.55", "9000", 100);
        let mut b = raw("A2", "0.50", "0.55", "20000", 100);
        a.event_ticker = "EV".into();
        b.event_ticker = "EV".into();
        let kept = group_by_event(vec![a, b]);
        assert_eq!(kept.len(), 1);
        assert_eq!(kept[0].ticker, "A2");
    }

    #[test]
    fn to_market_computes_mid_and_spread() {
        let m = to_market(raw("T", "0.40", "0.46", "5000", 100)).expect("valid market");
        assert!((m.mid_price - 0.43).abs() < 1e-9);
        assert!((m.spread - 0.06).abs() < 1e-9);
        assert!(m.score.is_none());
    }

    #[test]
    fn price_values_normalize_cents_and_strings() {
        use serde_json::json;
        assert_eq!(parse_price_value(&json!(0.55)), Some(0.55));
        assert_eq!(parse_price_value(&json!("0.55")), Some(0.55));
        assert_eq!(parse_price_value(&json!(55)), Some(0.55));
        assert_eq!(parse_price_value(&json!(null)), None);
    }

    #[test]
    fn category_inference_from_ticker_prefix() {
        assert_eq!(infer_category("KXHIGHNY-26MAY18"), "Weather");
        assert_eq!(infer_category("FED-25DEC"), "Economics");
        assert_eq!(infer_category("NFLGAME-X"), "Sports");
        assert_eq!(infer_category("XYZ"), "Other");
    }
}

fn infer_category(event_ticker: &str) -> String {
    let t = event_ticker.to_uppercase();
    if t.starts_with("KXHIGH")
        || t.starts_with("KXLOW")
        || t.starts_with("KXPRCP")
        || t.starts_with("KXSNOW")
        || t.starts_with("KXTEMP")
    {
        "Weather"
    } else if t.starts_with("INX")
        || t.starts_with("NDX")
        || t.starts_with("DJIA")
        || t.starts_with("FED")
        || t.starts_with("CPI")
        || t.starts_with("GDP")
        || t.starts_with("BTC")
        || t.starts_with("ETH")
        || t.starts_with("KXBTC")
        || t.starts_with("KXETH")
    {
        "Economics"
    } else if t.starts_with("PRES")
        || t.starts_with("SENATE")
        || t.starts_with("HOUSE")
        || t.starts_with("GOV")
        || t.starts_with("POTUS")
    {
        "Politics"
    } else if t.starts_with("NFL")
        || t.starts_with("NBA")
        || t.starts_with("MLB")
        || t.starts_with("NHL")
        || t.starts_with("NCAAF")
        || t.starts_with("NCAAB")
        || t.starts_with("MLS")
        || t.starts_with("UFC")
        || t.starts_with("FIFA")
    {
        "Sports"
    } else {
        "Other"
    }
    .to_string()
}
