use axum::Json;

use crate::models::ApiResponse;

pub async fn health_check() -> Json<ApiResponse<&'static str>> {
    Json(ApiResponse::ok("ok"))
}
