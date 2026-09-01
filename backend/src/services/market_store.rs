use std::sync::Arc;
use std::time::Duration;

use tokio::sync::{Mutex, RwLock};

use crate::error::AppError;
use crate::models::market::{Market, Score};
use crate::services::{kalshi, scorer};
use crate::AppState;

const REFRESH_INTERVAL: Duration = Duration::from_secs(5 * 60);
/// How many of the most liquid markets get sent to Claude per refresh.
const SCORE_TOP_N: usize = 30;

/// In-process snapshot of the filtered + scored market list. The background
/// refresh task is the only writer; request handlers read.
#[derive(Clone, Default)]
pub struct MarketStore {
    inner: Arc<RwLock<Vec<Market>>>,
    /// Held while a cold-start fetch is in flight so concurrent requests
    /// against an empty store wait for one fetch instead of each launching
    /// their own.
    fetch_lock: Arc<Mutex<()>>,
}

impl MarketStore {
    pub async fn all(&self) -> Vec<Market> {
        self.inner.read().await.clone()
    }

    pub async fn get(&self, ticker: &str) -> Option<Market> {
        self.inner
            .read()
            .await
            .iter()
            .find(|m| m.ticker == ticker)
            .cloned()
    }

    pub async fn by_event(&self, event_ticker: &str) -> Vec<Market> {
        self.inner
            .read()
            .await
            .iter()
            .filter(|m| m.event_ticker == event_ticker)
            .cloned()
            .collect()
    }

    pub async fn is_empty(&self) -> bool {
        self.inner.read().await.is_empty()
    }

    pub async fn replace(&self, markets: Vec<Market>) {
        *self.inner.write().await = markets;
    }

    /// Attach a score to a market already in the snapshot. A no-op if the
    /// snapshot was replaced and the ticker fell out — the score is cached,
    /// so the next fetch re-attaches it.
    pub async fn set_score(&self, ticker: &str, score: Score) {
        let mut guard = self.inner.write().await;
        if let Some(market) = guard.iter_mut().find(|m| m.ticker == ticker) {
            market.score = Some(score);
        }
    }
}

/// Fetch + filter from Kalshi, attach any cached scores, and swap in the new
/// snapshot. Fast (seconds) — no Claude calls happen here, so this is safe to
/// run inside a request handler.
async fn fetch_snapshot(state: &AppState) -> Result<usize, AppError> {
    let mut markets = kalshi::fetch_filtered_markets(&state.http, None).await?;
    for market in markets.iter_mut() {
        if let Some(cached) = state.cache.get(&format!("score:{}", market.ticker)).await {
            market.score = serde_json::from_str(&cached).ok();
        }
    }
    let count = markets.len();
    state.markets.replace(markets).await;
    Ok(count)
}

/// Score the head of the current snapshot through Claude, publishing each
/// score into the store as it lands. Slow (minutes) — background task only.
async fn score_snapshot(state: &AppState) {
    let Some(api_key) = state.anthropic_api_key.as_deref() else {
        tracing::debug!("ANTHROPIC_API_KEY not set — serving unscored markets");
        return;
    };
    // The snapshot is sorted by 24h volume descending; score the head.
    let head: Vec<Market> = state
        .markets
        .all()
        .await
        .into_iter()
        .take(SCORE_TOP_N)
        .collect();
    for market in head {
        match scorer::get_or_score(state, api_key, &market).await {
            Ok(score) => state.markets.set_score(&market.ticker, score).await,
            Err(e) => {
                tracing::warn!("Scoring {} failed: {e}", market.ticker);
            }
        }
    }
}

/// Fetch, filter, score, and publish — the background task's full cycle.
pub async fn refresh(state: &AppState) -> Result<usize, AppError> {
    let count = fetch_snapshot(state).await?;
    score_snapshot(state).await;
    Ok(count)
}

/// Ensure the snapshot has data, fetching synchronously on first use if the
/// background task hasn't populated it yet. Only the fast fetch phase runs
/// here — scoring stays in the background, so a cold start serves unscored
/// markets rather than holding the request through 30 Claude calls.
pub async fn ensure_fresh(state: &AppState) -> Result<(), AppError> {
    if !state.markets.is_empty().await {
        return Ok(());
    }
    let _guard = state.markets.fetch_lock.lock().await;
    // Re-check: a concurrent request may have fetched while we waited.
    if state.markets.is_empty().await {
        fetch_snapshot(state).await?;
    }
    Ok(())
}

pub fn spawn_refresh_task(state: AppState) {
    tokio::spawn(async move {
        loop {
            match refresh(&state).await {
                Ok(count) => tracing::info!("Market refresh complete: {count} markets"),
                Err(e) => tracing::warn!("Market refresh failed: {e}"),
            }
            tokio::time::sleep(REFRESH_INTERVAL).await;
        }
    });
}
