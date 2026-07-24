use std::sync::Arc;
use std::time::Duration;

use tokio::sync::RwLock;

use crate::AppState;

/// Google's JWKS endpoint is fixed and public (not project-specific), unlike
/// Clerk's per-tenant URL.
const GOOGLE_JWKS_URL: &str = "https://www.googleapis.com/oauth2/v3/certs";

/// Google rotates its signing keys periodically, so unlike the one-shot
/// startup fetch this replaced, the keys need to stay refreshed for the
/// life of the process. The interval is generous relative to Google's
/// rotation cadence — not worth tuning tighter for an alpha app.
const REFRESH_INTERVAL: Duration = Duration::from_secs(6 * 60 * 60);

/// A runtime-swappable holder for the current JWKS, so the background
/// refresh task can replace it without restarting the process. Reads
/// (on every authenticated request) just clone the `Arc`, not the key set.
#[derive(Clone, Default)]
pub struct JwksStore {
    inner: Arc<RwLock<Option<Arc<jsonwebtoken::jwk::JwkSet>>>>,
}

impl JwksStore {
    pub async fn current(&self) -> Option<Arc<jsonwebtoken::jwk::JwkSet>> {
        self.inner.read().await.clone()
    }

    async fn replace(&self, jwks: jsonwebtoken::jwk::JwkSet) {
        *self.inner.write().await = Some(Arc::new(jwks));
    }
}

async fn fetch() -> Result<jsonwebtoken::jwk::JwkSet, reqwest::Error> {
    reqwest::Client::new()
        .get(GOOGLE_JWKS_URL)
        .send()
        .await?
        .json()
        .await
}

/// Fetch Google's JWKS once, synchronously, before the server starts
/// accepting requests — so the very first request doesn't 503 waiting on
/// the background refresh loop.
pub async fn init(state: &AppState) {
    match fetch().await {
        Ok(jwks) => {
            tracing::info!("Loaded {} JWKS key(s) from Google", jwks.keys.len());
            state.jwks.replace(jwks).await;
        }
        Err(e) => {
            tracing::warn!(
                "Failed to fetch Google JWKS: {e} — protected routes will 503 \
                 until the next refresh"
            );
        }
    }
}

pub fn spawn_refresh_task(state: AppState) {
    tokio::spawn(async move {
        loop {
            tokio::time::sleep(REFRESH_INTERVAL).await;
            match fetch().await {
                Ok(jwks) => {
                    tracing::info!("Refreshed {} JWKS key(s) from Google", jwks.keys.len());
                    state.jwks.replace(jwks).await;
                }
                Err(e) => {
                    tracing::warn!("Google JWKS refresh failed: {e} — keeping previous keys");
                }
            }
        }
    });
}
