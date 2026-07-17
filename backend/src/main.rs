use std::{net::SocketAddr, sync::Arc};
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

use prereq_backend::{
    config::Config,
    db, routes,
    services::{self, cache::Cache, market_store::MarketStore},
    AppState,
};

#[tokio::main]
async fn main() {
    tracing_subscriber::registry()
        .with(
            tracing_subscriber::EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| "prereq_backend=debug,tower_http=debug".into()),
        )
        .with(tracing_subscriber::fmt::layer())
        .init();

    let config = Config::from_env();

    let jwks = if let Some(ref url) = config.clerk_jwks_url {
        match fetch_jwks(url).await {
            Ok(jwks) => {
                tracing::info!("Loaded {} JWKS key(s) from Clerk", jwks.keys.len());
                Some(Arc::new(jwks))
            }
            Err(e) => {
                tracing::warn!("Failed to fetch JWKS: {e} — protected routes will return 503");
                None
            }
        }
    } else {
        tracing::warn!("CLERK_JWKS_URL not set — protected routes will return 503");
        None
    };

    let db = db::init(config.database_url.as_deref()).await;
    let cache = Cache::connect(config.redis_url.as_deref()).await;

    let http = reqwest::Client::new();
    let state = AppState {
        jwks,
        http: http.clone(),
        db,
        cache,
        markets: MarketStore::default(),
        anthropic_api_key: config
            .anthropic_api_key
            .filter(|k| !k.is_empty() && !k.ends_with("...")),
        telemetry: services::telemetry::Telemetry::new(http, config.mixpanel_token),
    };

    services::market_store::spawn_refresh_task(state.clone());
    services::arb::spawn_arb_task(state.clone());

    let app = routes::app_router(state)
        .layer(tower_http::trace::TraceLayer::new_for_http())
        .layer(tower_http::cors::CorsLayer::permissive());

    let addr = SocketAddr::from(([0, 0, 0, 0], config.port));
    tracing::info!("Listening on {addr}");
    let listener = tokio::net::TcpListener::bind(addr)
        .await
        .expect("failed to bind server address");
    axum::serve(listener, app)
        .await
        .expect("server terminated unexpectedly");
}

async fn fetch_jwks(url: &str) -> Result<jsonwebtoken::jwk::JwkSet, reqwest::Error> {
    reqwest::Client::new().get(url).send().await?.json().await
}
