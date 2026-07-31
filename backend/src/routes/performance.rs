use axum::{extract::State, Extension, Json};

use crate::{
    db::{self, performance::PerformanceReport},
    error::AppError,
    middleware::auth::AuthUser,
    models::ApiResponse,
    AppState,
};

pub async fn get_performance(
    State(state): State<AppState>,
    Extension(user): Extension<AuthUser>,
) -> Result<Json<ApiResponse<PerformanceReport>>, AppError> {
    let pool = db::require(&state.db)?;
    let me = db::users::get_or_create(pool, &user).await?;
    let resolved = db::bets::resolved(pool, me.id).await?;
    Ok(Json(ApiResponse::ok(db::performance::build_report(
        &resolved,
    ))))
}
