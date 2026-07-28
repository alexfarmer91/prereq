use chrono::{DateTime, Utc};
use serde::Serialize;
use sqlx::PgPool;
use uuid::Uuid;

use crate::error::AppError;
use crate::middleware::auth::AuthUser;
use crate::models::plan::Plan;

#[derive(Debug, Clone, Serialize, sqlx::FromRow)]
pub struct User {
    pub id: Uuid,
    pub google_user_id: String,
    pub bankroll_dollars: f64,
    /// Product tier: 'free' | 'edge' | 'pro' (constrained by the schema).
    pub plan: String,
    pub email: Option<String>,
    pub email_verified: bool,
    pub display_name: Option<String>,
    pub avatar_url: Option<String>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
    pub last_seen_at: Option<DateTime<Utc>>,
}

impl User {
    /// The typed entitlements view of the `plan` column.
    pub fn plan(&self) -> Plan {
        Plan::from_db(&self.plan)
    }
}

const USER_COLUMNS: &str = "id, google_user_id, bankroll_dollars::float8 AS bankroll_dollars, \
     plan, email, email_verified, display_name, avatar_url, created_at, updated_at, last_seen_at";

/// Upserts on every authenticated request — also keeps profile fields
/// (name/avatar/email) in sync with whatever Google's token carries now.
pub async fn get_or_create(pool: &PgPool, user: &AuthUser) -> Result<User, AppError> {
    let now = Utc::now();
    let row = sqlx::query_as::<_, User>(&format!(
        "INSERT INTO users (google_user_id, email, email_verified, display_name, avatar_url, last_seen_at)
         VALUES ($1, $2, $3, $4, $5, $6)
         ON CONFLICT (google_user_id) DO UPDATE SET
           email = EXCLUDED.email,
           email_verified = EXCLUDED.email_verified,
           display_name = EXCLUDED.display_name,
           avatar_url = EXCLUDED.avatar_url,
           last_seen_at = EXCLUDED.last_seen_at,
           updated_at = NOW()
         RETURNING {USER_COLUMNS}"
    ))
    .bind(&user.google_user_id)
    .bind(&user.email)
    .bind(user.email_verified)
    .bind(&user.display_name)
    .bind(&user.avatar_url)
    .bind(now)
    .fetch_one(pool)
    .await?;
    Ok(row)
}

pub async fn update_bankroll(
    pool: &PgPool,
    google_user_id: &str,
    bankroll_dollars: f64,
) -> Result<User, AppError> {
    let user = sqlx::query_as::<_, User>(&format!(
        "UPDATE users SET bankroll_dollars = $2 WHERE google_user_id = $1
         RETURNING {USER_COLUMNS}"
    ))
    .bind(google_user_id)
    .bind(bankroll_dollars)
    .fetch_one(pool)
    .await?;
    Ok(user)
}
