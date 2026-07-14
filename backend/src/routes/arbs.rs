use axum::{extract::State, Json};

use crate::{
    error::AppError,
    models::ApiResponse,
    services::arb::{self, ArbOpportunity},
    AppState,
};

pub async fn list_arbs(
    State(state): State<AppState>,
) -> Result<Json<ApiResponse<Vec<ArbOpportunity>>>, AppError> {
    Ok(Json(ApiResponse::ok(arb::cached_arbs(&state).await)))
}
