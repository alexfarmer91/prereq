use axum::{extract::State, Extension, Json};
use serde::Deserialize;

use crate::{
    db::{self, users::User},
    error::AppError,
    middleware::auth::AuthUser,
    models::ApiResponse,
    AppState,
};

pub async fn get_me(
    State(state): State<AppState>,
    Extension(user): Extension<AuthUser>,
) -> Result<Json<ApiResponse<User>>, AppError> {
    let pool = db::require(&state.db)?;
    let me = db::users::get_or_create(pool, &user).await?;
    Ok(Json(ApiResponse::ok(me)))
}

#[derive(Debug, Deserialize)]
pub struct UpdateMe {
    pub bankroll_dollars: f64,
}

pub async fn update_me(
    State(state): State<AppState>,
    Extension(user): Extension<AuthUser>,
    Json(body): Json<UpdateMe>,
) -> Result<Json<ApiResponse<User>>, AppError> {
    if !body.bankroll_dollars.is_finite() || body.bankroll_dollars < 0.0 {
        return Err(AppError::BadRequest(
            "bankroll_dollars must be a non-negative number".into(),
        ));
    }
    let pool = db::require(&state.db)?;
    db::users::get_or_create(pool, &user).await?;
    let me = db::users::update_bankroll(pool, &user.google_user_id, body.bankroll_dollars).await?;
    Ok(Json(ApiResponse::ok(me)))
}

pub async fn accept_terms(
    State(state): State<AppState>,
    Extension(user): Extension<AuthUser>,
) -> Result<Json<ApiResponse<User>>, AppError> {
    let pool = db::require(&state.db)?;
    db::users::get_or_create(pool, &user).await?;
    let me = db::users::accept_terms(pool, &user.google_user_id).await?;
    Ok(Json(ApiResponse::ok(me)))
}
