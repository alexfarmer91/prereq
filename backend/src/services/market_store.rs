use std::sync::Arc;
use std::time::Duration;

use tokio::sync::RwLock;

use crate::error::AppError;
use crate::models::market::Market;
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
}

/// Fetch, filter, score, and swap in the new snapshot.
pub async fn refresh(state: &AppState) -> Result<usize, AppError> {
    let mut markets = kalshi::fetch_filtered_markets(&state.http, None).await?;

    if let Some(api_key) = state.anthropic_api_key.as_deref() {
        // Markets arrive sorted by 24h volume descending; score the head.
        for market in markets.iter_mut().take(SCORE_TOP_N) {
            match scorer::get_or_score(&state.http, api_key, &state.cache, market).await {
                Ok(score) => market.score = Some(score),
                Err(e) => {
                    tracing::warn!("Scoring {} failed: {e}", market.ticker);
                }
            }
        }
    } else {
        tracing::debug!("ANTHROPIC_API_KEY not set — serving unscored markets");
    }

    let count = markets.len();
    state.markets.replace(markets).await;
    Ok(count)
}

/// Ensure the snapshot has data, fetching synchronously on first use if the
/// background task hasn't populated it yet.
pub async fn ensure_fresh(state: &AppState) -> Result<(), AppError> {
    if state.markets.is_empty().await {
        refresh(state).await?;
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
