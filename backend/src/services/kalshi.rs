use std::collections::HashMap;

use chrono::{DateTime, Utc};
use reqwest::Client;
use serde::Deserialize;
use tokio::time::{sleep, Duration};

use crate::error::AppError;
use crate::models::market::{KalshiMarket, Market};

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

fn to_market(m: KalshiMarket) -> Option<Market> {
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
    })
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
