use axum::{
    extract::{Query, State},
    Extension, Json,
};
use serde::Deserialize;

use crate::{
    error::AppError,
    middleware::auth::AuthUser,
    models::{market::Market, ApiResponse},
    services::kalshi,
    AppState,
};

#[derive(Debug, Deserialize)]
pub struct MarketsQuery {
    pub category: Option<String>,
    // `sort` param accepted now; edge sort wired in step 5
    pub sort: Option<String>,
}

pub async fn list_markets(
    State(state): State<AppState>,
    Extension(_user): Extension<AuthUser>,
    Query(params): Query<MarketsQuery>,
) -> Result<Json<ApiResponse<Vec<Market>>>, AppError> {
    let markets =
        kalshi::fetch_filtered_markets(&state.http, params.category.as_deref()).await?;
    Ok(Json(ApiResponse::ok(markets)))
}
