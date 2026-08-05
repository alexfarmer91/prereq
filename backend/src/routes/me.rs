use axum::{
    extract::{Multipart, State},
    Extension, Json,
};
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

#[derive(Debug, Deserialize)]
pub struct UpdateProfile {
    pub display_name: String,
}

pub async fn update_profile(
    State(state): State<AppState>,
    Extension(user): Extension<AuthUser>,
    Json(body): Json<UpdateProfile>,
) -> Result<Json<ApiResponse<User>>, AppError> {
    let display_name = body.display_name.trim();
    if display_name.is_empty() || display_name.chars().count() > 60 {
        return Err(AppError::BadRequest(
            "display_name must be 1-60 characters".into(),
        ));
    }
    let pool = db::require(&state.db)?;
    db::users::get_or_create(pool, &user).await?;
    let me = db::users::update_display_name(pool, &user.google_user_id, display_name).await?;
    Ok(Json(ApiResponse::ok(me)))
}

#[derive(Debug, Deserialize)]
pub struct UpdatePlan {
    pub plan: String,
}

/// Admin-only: lets the caller preview their own account under a different
/// plan tier, so features can be verified across plans without a real
/// subscription. Restricted to the caller's own row — an admin can flip
/// their own plan, never anyone else's.
pub async fn update_plan(
    State(state): State<AppState>,
    Extension(user): Extension<AuthUser>,
    Json(body): Json<UpdatePlan>,
) -> Result<Json<ApiResponse<User>>, AppError> {
    let pool = db::require(&state.db)?;
    let me = db::users::get_or_create(pool, &user).await?;
    if !me.is_admin {
        return Err(AppError::Forbidden("Admin access required".into()));
    }
    if !matches!(body.plan.as_str(), "free" | "edge" | "pro") {
        return Err(AppError::BadRequest(
            "plan must be one of: free, edge, pro".into(),
        ));
    }
    let me = db::users::update_plan(pool, &user.google_user_id, &body.plan).await?;
    Ok(Json(ApiResponse::ok(me)))
}

/// Max upload size for a profile picture.
const MAX_AVATAR_BYTES: usize = 5 * 1024 * 1024;

pub async fn upload_avatar(
    State(state): State<AppState>,
    Extension(user): Extension<AuthUser>,
    mut multipart: Multipart,
) -> Result<Json<ApiResponse<User>>, AppError> {
    let Some(field) = multipart
        .next_field()
        .await
        .map_err(|e| AppError::BadRequest(format!("Invalid upload: {e}")))?
    else {
        return Err(AppError::BadRequest("No file provided".into()));
    };

    let content_type = field
        .content_type()
        .ok_or_else(|| AppError::BadRequest("Missing file content type".into()))?
        .to_string();
    let bytes = field
        .bytes()
        .await
        .map_err(|e| AppError::BadRequest(format!("Invalid upload: {e}")))?;
    if bytes.len() > MAX_AVATAR_BYTES {
        return Err(AppError::BadRequest("Image must be under 5MB".into()));
    }

    let pool = db::require(&state.db)?;
    db::users::get_or_create(pool, &user).await?;
    let avatar_url = state
        .avatar_storage
        .upload_avatar(&user.google_user_id, &content_type, bytes.to_vec())
        .await?;
    let me = db::users::update_avatar_url(pool, &user.google_user_id, &avatar_url).await?;
    Ok(Json(ApiResponse::ok(me)))
}
