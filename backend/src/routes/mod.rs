use axum::{middleware, routing::get, Router};

use crate::{middleware::auth::auth_middleware, AppState};

pub mod health;
pub mod markets;

pub fn app_router(state: AppState) -> Router {
    let protected = Router::new()
        .route("/markets", get(markets::list_markets))
        .layer(middleware::from_fn_with_state(
            state.clone(),
            auth_middleware,
        ));

    Router::new()
        .route("/health", get(health::health_check))
        .merge(protected)
        .with_state(state)
}
