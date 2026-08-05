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
    /// Base Supabase project URL (e.g. `https://xxxx.supabase.co`) — used to
    /// build Storage REST API calls for avatar uploads.
    pub supabase_project_url: Option<String>,
    /// Supabase service-role key. Server-only — bypasses Storage RLS so the
    /// backend can write to the `profile_pictures` bucket on the
    /// authenticated user's behalf. Never send this to the frontend.
    pub supabase_service_role_key: Option<String>,
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
            supabase_project_url: env::var("SUPABASE_PROJECT_URL").ok(),
            supabase_service_role_key: env::var("SUPABASE_SERVICE_ROLE_KEY").ok(),
        }
    }
}
