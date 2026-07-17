use std::sync::Arc;

pub mod config;
pub mod db;
pub mod error;
pub mod middleware;
pub mod models;
pub mod routes;
pub mod services;

use services::{cache::Cache, market_store::MarketStore, telemetry::Telemetry};

#[derive(Clone)]
pub struct AppState {
    pub jwks: Option<Arc<jsonwebtoken::jwk::JwkSet>>,
    pub http: reqwest::Client,
    pub db: Option<sqlx::PgPool>,
    pub cache: Cache,
    pub markets: MarketStore,
    pub anthropic_api_key: Option<String>,
    pub telemetry: Telemetry,
}

impl AppState {
    /// State with no external connections — used by tests and available as a
    /// building block for local tooling.
    pub async fn disconnected() -> Self {
        AppState {
            jwks: None,
            http: reqwest::Client::new(),
            db: None,
            cache: Cache::connect(None).await,
            markets: MarketStore::default(),
            anthropic_api_key: None,
            telemetry: Telemetry::default(),
        }
    }
}
