use std::env;

pub struct Config {
    pub port: u16,
    pub clerk_jwks_url: Option<String>,
    pub database_url: Option<String>,
    pub redis_url: Option<String>,
    pub anthropic_api_key: Option<String>,
}

impl Config {
    pub fn from_env() -> Self {
        dotenvy::dotenv().ok();
        Config {
            port: env::var("PORT")
                .unwrap_or_else(|_| "3000".into())
                .parse()
                .expect("PORT must be a valid number"),
            clerk_jwks_url: env::var("CLERK_JWKS_URL").ok(),
            database_url: env::var("DATABASE_URL").ok(),
            redis_url: env::var("REDIS_URL").ok(),
            anthropic_api_key: env::var("ANTHROPIC_API_KEY").ok(),
        }
    }
}
