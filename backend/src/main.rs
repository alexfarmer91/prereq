use std::net::SocketAddr;
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

use prereq_backend::{
    config::Config,
    db, routes,
    services::{self, cache::Cache, jwks::JwksStore, market_store::MarketStore},
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

    if config.google_client_id.is_none() {
        tracing::warn!("GOOGLE_CLIENT_ID not set — protected routes will return 503");
    }

    let db = db::init(config.database_url.as_deref()).await;
    let cache = Cache::connect(config.redis_url.as_deref()).await;

    let http = reqwest::Client::new();
    let state = AppState {
        jwks: JwksStore::default(),
        google_client_id: config.google_client_id,
        http: http.clone(),
        db,
        cache,
        markets: MarketStore::default(),
        anthropic_api_key: config
            .anthropic_api_key
            .filter(|k| !k.is_empty() && !k.ends_with("...")),
        avatar_storage: services::storage::AvatarStorage::new(
            http.clone(),
            config.supabase_project_url,
            config.supabase_service_role_key,
        ),
        telemetry: services::telemetry::Telemetry::new(http, config.mixpanel_token),
    };

    // Synchronous first fetch so the very first request doesn't 503 waiting
    // on the background refresh loop; Google rotates signing keys, so the
    // loop keeps them current for the life of the process.
    services::jwks::init(&state).await;
    services::jwks::spawn_refresh_task(state.clone());
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
