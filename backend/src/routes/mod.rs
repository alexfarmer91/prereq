use axum::{
    extract::DefaultBodyLimit,
    middleware,
    routing::{delete, get, patch, post},
    Router,
};

use crate::{error::AppError, middleware::auth::auth_middleware, AppState};

pub mod arbs;
pub mod bets;
pub mod health;
pub mod markets;
pub mod me;
pub mod performance;
pub mod watchlist;
pub mod ws;

pub fn app_router(state: AppState) -> Router {
    let protected = Router::new()
        .route("/markets", get(markets::list_markets))
        .route("/markets/{ticker}", get(markets::get_market))
        .route("/markets/{ticker}/history", get(markets::get_history))
        .route("/me", get(me::get_me).patch(me::update_me))
        .route("/me/accept-terms", post(me::accept_terms))
        .route("/me/profile", patch(me::update_profile))
        .route("/me/plan", patch(me::update_plan))
        .route(
            "/me/avatar",
            post(me::upload_avatar).layer(DefaultBodyLimit::max(6 * 1024 * 1024)),
        )
        .route(
            "/watchlist",
            get(watchlist::list_watchlist).post(watchlist::add_to_watchlist),
        )
        .route(
            "/watchlist/{ticker}",
            delete(watchlist::remove_from_watchlist),
        )
        .route("/bets", get(bets::list_bets).post(bets::create_bet))
        .route("/bets/{id}", patch(bets::resolve_bet))
        .route("/performance", get(performance::get_performance))
        .route("/arbs", get(arbs::list_arbs))
        .layer(middleware::from_fn_with_state(
            state.clone(),
            auth_middleware,
        ));

    Router::new()
        .route("/health", get(health::health_check))
        // The WS handler does its own token verification (browsers can't set
        // headers on WebSocket connects).
        .route("/ws/markets", get(ws::ws_markets))
        .merge(protected)
        // Explicit fallback so unmatched paths get an enveloped 404 instead of
        // falling into the protected router's auth layer.
        .fallback(not_found)
        .with_state(state)
}

async fn not_found() -> AppError {
    AppError::NotFound
}
