use axum::{
    extract::{Path, Query, State},
    Extension, Json,
};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

use crate::{
    db::{
        self,
        bets::{Bet, NewBet},
    },
    error::AppError,
    middleware::auth::AuthUser,
    models::ApiResponse,
    AppState,
};

#[derive(Debug, Deserialize)]
pub struct BetsQuery {
    pub outcome: Option<String>,
    pub page: Option<i64>,
    pub per_page: Option<i64>,
}

#[derive(Debug, Serialize)]
pub struct BetsPage {
    pub bets: Vec<Bet>,
    pub total: i64,
    pub page: i64,
    pub per_page: i64,
}

pub async fn list_bets(
    State(state): State<AppState>,
    Extension(user): Extension<AuthUser>,
    Query(params): Query<BetsQuery>,
) -> Result<Json<ApiResponse<BetsPage>>, AppError> {
    if let Some(outcome) = params.outcome.as_deref() {
        if !matches!(outcome, "win" | "loss" | "pending") {
            return Err(AppError::BadRequest(
                "outcome must be win, loss, or pending".into(),
            ));
        }
    }
    let page = params.page.unwrap_or(1).max(1);
    let per_page = params.per_page.unwrap_or(25).clamp(1, 100);

    let pool = db::require(&state.db)?;
    let me = db::users::get_or_create(pool, &user.clerk_user_id).await?;
    let (bets, total) =
        db::bets::list(pool, me.id, params.outcome.as_deref(), page, per_page).await?;

    Ok(Json(ApiResponse::ok(BetsPage {
        bets,
        total,
        page,
        per_page,
    })))
}

#[derive(Debug, Deserialize)]
pub struct CreateBet {
    pub market_ticker: String,
    pub market_title: String,
    pub side: String,
    pub entry_price_dollars: f64,
    pub contracts: i32,
    pub your_probability: f64,
    pub kelly_fraction: Option<f64>,
}

pub async fn create_bet(
    State(state): State<AppState>,
    Extension(user): Extension<AuthUser>,
    Json(body): Json<CreateBet>,
) -> Result<Json<ApiResponse<Bet>>, AppError> {
    if body.market_ticker.trim().is_empty() || body.market_title.trim().is_empty() {
        return Err(AppError::BadRequest(
            "market_ticker and market_title are required".into(),
        ));
    }
    if !matches!(body.side.as_str(), "yes" | "no") {
        return Err(AppError::BadRequest("side must be yes or no".into()));
    }
    if !body.entry_price_dollars.is_finite() || !(0.0..=1.0).contains(&body.entry_price_dollars) {
        return Err(AppError::BadRequest(
            "entry_price_dollars must be between 0 and 1".into(),
        ));
    }
    if body.contracts <= 0 {
        return Err(AppError::BadRequest("contracts must be positive".into()));
    }
    if !body.your_probability.is_finite() || !(0.0..=1.0).contains(&body.your_probability) {
        return Err(AppError::BadRequest(
            "your_probability must be between 0 and 1".into(),
        ));
    }

    let pool = db::require(&state.db)?;
    let me = db::users::get_or_create(pool, &user.clerk_user_id).await?;
    let bet = db::bets::insert(
        pool,
        me.id,
        NewBet {
            market_ticker: body.market_ticker.trim().to_string(),
            market_title: body.market_title.trim().to_string(),
            side: body.side,
            entry_price_dollars: body.entry_price_dollars,
            contracts: body.contracts,
            your_probability: body.your_probability,
            kelly_fraction: body.kelly_fraction,
        },
    )
    .await?;
    Ok(Json(ApiResponse::ok(bet)))
}

#[derive(Debug, Deserialize)]
pub struct ResolveBet {
    pub outcome: String,
    pub exit_price_dollars: Option<f64>,
}

pub async fn resolve_bet(
    State(state): State<AppState>,
    Extension(user): Extension<AuthUser>,
    Path(bet_id): Path<Uuid>,
    Json(body): Json<ResolveBet>,
) -> Result<Json<ApiResponse<Bet>>, AppError> {
    if !matches!(body.outcome.as_str(), "win" | "loss") {
        return Err(AppError::BadRequest("outcome must be win or loss".into()));
    }
    if let Some(exit) = body.exit_price_dollars {
        if !exit.is_finite() || !(0.0..=1.0).contains(&exit) {
            return Err(AppError::BadRequest(
                "exit_price_dollars must be between 0 and 1".into(),
            ));
        }
    }

    let pool = db::require(&state.db)?;
    let me = db::users::get_or_create(pool, &user.clerk_user_id).await?;
    let bet = db::bets::update_outcome(pool, me.id, bet_id, &body.outcome, body.exit_price_dollars)
        .await?;
    Ok(Json(ApiResponse::ok(bet)))
}
