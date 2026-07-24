use std::env;

pub struct Config {
    pub port: u16,
    /// The Google OAuth Web Client ID — checked as the `aud` claim on every
    /// verified ID token. Google's JWKS endpoint itself is a fixed, public
    /// URL (not project-specific), so unlike Clerk there's no per-project
    /// JWKS URL to configure — see `services::jwks`.
    pub google_client_id: Option<String>,
    pub database_url: Option<String>,
    pub redis_url: Option<String>,
    pub anthropic_api_key: Option<String>,
    pub mixpanel_token: Option<String>,
}

impl Config {
    pub fn from_env() -> Self {
        dotenvy::dotenv().ok();
        Config {
            port: env::var("PORT")
                .unwrap_or_else(|_| "3000".into())
                .parse()
                .expect("PORT must be a valid number"),
            google_client_id: env::var("GOOGLE_CLIENT_ID").ok(),
            database_url: env::var("DATABASE_URL").ok(),
            redis_url: env::var("REDIS_URL").ok(),
            anthropic_api_key: env::var("ANTHROPIC_API_KEY").ok(),
            mixpanel_token: env::var("MIXPANEL_TOKEN").ok(),
        }
    }
}
