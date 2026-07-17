use chrono::{DateTime, Utc};
use serde::Serialize;
use sqlx::PgPool;
use uuid::Uuid;

use crate::error::AppError;
use crate::models::plan::Plan;

#[derive(Debug, Clone, Serialize, sqlx::FromRow)]
pub struct User {
    pub id: Uuid,
    pub clerk_user_id: String,
    pub bankroll_dollars: f64,
    /// Product tier: 'free' | 'edge' | 'pro' (constrained by the schema).
    pub plan: String,
    pub created_at: DateTime<Utc>,
}

impl User {
    /// The typed entitlements view of the `plan` column.
    pub fn plan(&self) -> Plan {
        Plan::from_db(&self.plan)
    }
}

const USER_COLUMNS: &str =
    "id, clerk_user_id, bankroll_dollars::float8 AS bankroll_dollars, plan, created_at";

pub async fn get_or_create(pool: &PgPool, clerk_user_id: &str) -> Result<User, AppError> {
    let user = sqlx::query_as::<_, User>(&format!(
        "INSERT INTO users (clerk_user_id) VALUES ($1)
         ON CONFLICT (clerk_user_id) DO UPDATE SET clerk_user_id = EXCLUDED.clerk_user_id
         RETURNING {USER_COLUMNS}"
    ))
    .bind(clerk_user_id)
    .fetch_one(pool)
    .await?;
    Ok(user)
}

pub async fn update_bankroll(
    pool: &PgPool,
    clerk_user_id: &str,
    bankroll_dollars: f64,
) -> Result<User, AppError> {
    let user = sqlx::query_as::<_, User>(&format!(
        "UPDATE users SET bankroll_dollars = $2 WHERE clerk_user_id = $1
         RETURNING {USER_COLUMNS}"
    ))
    .bind(clerk_user_id)
    .bind(bankroll_dollars)
    .fetch_one(pool)
    .await?;
    Ok(user)
}
