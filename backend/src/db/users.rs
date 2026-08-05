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
    pub is_admin: bool,
    pub terms_accepted: bool,
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
     plan, is_admin, terms_accepted, email, email_verified, display_name, avatar_url, \
     created_at, updated_at, last_seen_at";

/// Upserts on every authenticated request — keeps `email`/`email_verified`
/// in sync with whatever Google's token carries now, since those are tied to
/// the auth identity rather than user preference. `display_name`/`avatar_url`
/// are seeded from Google's token only at creation time (a sane default
/// before onboarding runs) and never touched again here, so a user's
/// onboarding-chosen name/photo can't be silently clobbered by their Google
/// profile changing later. `last_seen_at` is intentionally left NULL on
/// INSERT — it's the "brand new account" signal the frontend's onboarding
/// gate checks (see router.dart), and only starts advancing once the row
/// already exists.
pub async fn get_or_create(pool: &PgPool, user: &AuthUser) -> Result<User, AppError> {
    let row = sqlx::query_as::<_, User>(&format!(
        "INSERT INTO users (google_user_id, email, email_verified, display_name, avatar_url)
         VALUES ($1, $2, $3, $4, $5)
         ON CONFLICT (google_user_id) DO UPDATE SET
           email = EXCLUDED.email,
           email_verified = EXCLUDED.email_verified,
           last_seen_at = NOW(),
           updated_at = NOW()
         RETURNING {USER_COLUMNS}"
    ))
    .bind(&user.google_user_id)
    .bind(&user.email)
    .bind(user.email_verified)
    .bind(&user.display_name)
    .bind(&user.avatar_url)
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

/// Admin-only: overrides the caller's own `plan` so features can be
/// exercised across tiers without a real subscription change. Callers must
/// check `is_admin` themselves before invoking this — it has no gate of its
/// own beyond the schema's plan CHECK constraint.
pub async fn update_plan(
    pool: &PgPool,
    google_user_id: &str,
    plan: &str,
) -> Result<User, AppError> {
    let user = sqlx::query_as::<_, User>(&format!(
        "UPDATE users SET plan = $2, updated_at = NOW() WHERE google_user_id = $1
         RETURNING {USER_COLUMNS}"
    ))
    .bind(google_user_id)
    .bind(plan)
    .fetch_one(pool)
    .await?;
    Ok(user)
}

pub async fn accept_terms(pool: &PgPool, google_user_id: &str) -> Result<User, AppError> {
    let user = sqlx::query_as::<_, User>(&format!(
        "UPDATE users SET terms_accepted = TRUE WHERE google_user_id = $1
         RETURNING {USER_COLUMNS}"
    ))
    .bind(google_user_id)
    .fetch_one(pool)
    .await?;
    Ok(user)
}

pub async fn update_display_name(
    pool: &PgPool,
    google_user_id: &str,
    display_name: &str,
) -> Result<User, AppError> {
    let user = sqlx::query_as::<_, User>(&format!(
        "UPDATE users SET display_name = $2, updated_at = NOW() WHERE google_user_id = $1
         RETURNING {USER_COLUMNS}"
    ))
    .bind(google_user_id)
    .bind(display_name)
    .fetch_one(pool)
    .await?;
    Ok(user)
}

pub async fn update_avatar_url(
    pool: &PgPool,
    google_user_id: &str,
    avatar_url: &str,
) -> Result<User, AppError> {
    let user = sqlx::query_as::<_, User>(&format!(
        "UPDATE users SET avatar_url = $2, updated_at = NOW() WHERE google_user_id = $1
         RETURNING {USER_COLUMNS}"
    ))
    .bind(google_user_id)
    .bind(avatar_url)
    .fetch_one(pool)
    .await?;
    Ok(user)
}
