use std::{net::SocketAddr, sync::Arc};
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

mod config;
mod error;
mod middleware;
mod models;
mod routes;
mod services;

use config::Config;

#[derive(Clone)]
pub struct AppState {
    pub jwks: Option<Arc<jsonwebtoken::jwk::JwkSet>>,
    pub http: reqwest::Client,
}

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

    let state = AppState {
        jwks,
        http: reqwest::Client::new(),
    };

    let app = routes::app_router(state)
        .layer(tower_http::trace::TraceLayer::new_for_http())
        .layer(tower_http::cors::CorsLayer::permissive());

    let addr = SocketAddr::from(([0, 0, 0, 0], config.port));
    tracing::info!("Listening on {addr}");
    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}

async fn fetch_jwks(url: &str) -> Result<jsonwebtoken::jwk::JwkSet, reqwest::Error> {
    reqwest::Client::new().get(url).send().await?.json().await
}
