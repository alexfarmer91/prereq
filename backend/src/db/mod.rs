pub mod bets;
pub mod performance;
pub mod users;
pub mod watchlist;

use sqlx::postgres::{PgPool, PgPoolOptions};

use crate::error::AppError;

/// Connect and run migrations. Returns None (with a warning) when DATABASE_URL
/// is unset or unreachable so the server can still serve market data.
pub async fn init(database_url: Option<&str>) -> Option<PgPool> {
    let url = match database_url {
        Some(u) if !u.is_empty() => u,
        _ => {
            tracing::warn!("DATABASE_URL not set — user features (watchlist/bets/performance) will return 503");
            return None;
        }
    };

    let pool = match PgPoolOptions::new()
        .max_connections(10)
        .connect(url)
        .await
    {
        Ok(p) => p,
        Err(e) => {
            tracing::warn!("Could not connect to database: {e} — user features will return 503");
            return None;
        }
    };

    if let Err(e) = sqlx::migrate!("./migrations").run(&pool).await {
        tracing::error!("Migration failed: {e}");
        return None;
    }

    tracing::info!("Database connected, migrations applied");
    Some(pool)
}

/// Extract the pool or fail with a 503 the frontend can present cleanly.
pub fn require(pool: &Option<PgPool>) -> Result<&PgPool, AppError> {
    pool.as_ref().ok_or_else(|| {
        AppError::ServiceUnavailable("Database not configured".to_string())
    })
}
