use axum::{
    body::Body,
    extract::State,
    http::{header::AUTHORIZATION, Request, StatusCode},
    middleware::Next,
    response::{IntoResponse, Response},
    Json,
};
use jsonwebtoken::{decode, decode_header, Algorithm, DecodingKey, Validation};
use serde::{Deserialize, Serialize};
use serde_json::json;

use crate::AppState;

#[derive(Clone, Debug, Deserialize, Serialize)]
pub struct GoogleClaims {
    pub sub: String,
    pub aud: String,
    pub exp: u64,
    pub iat: u64,
}

#[derive(Clone, Debug)]
pub struct AuthUser {
    pub google_user_id: String,
}

/// Dev-only escape hatch — never set in production.
pub fn skip_auth() -> bool {
    std::env::var("SKIP_AUTH").as_deref() == Ok("true")
}

pub async fn auth_middleware(
    State(state): State<AppState>,
    mut req: Request<Body>,
    next: Next,
) -> Response {
    if skip_auth() {
        req.extensions_mut().insert(AuthUser {
            google_user_id: "dev".to_string(),
        });
        return next.run(req).await;
    }

    let token: Option<String> = req
        .headers()
        .get(AUTHORIZATION)
        .and_then(|v| v.to_str().ok())
        .and_then(|s| s.strip_prefix("Bearer "))
        .map(|s| s.to_owned());

    // Both the current key set and the expected audience must be configured
    // to safely verify a token — without a known audience, any Google ID
    // token issued to *any* Google OAuth client would otherwise be accepted.
    let (jwks, client_id) = match (state.jwks.current().await, &state.google_client_id) {
        (Some(jwks), Some(client_id)) => (jwks, client_id.clone()),
        _ => {
            return (
                StatusCode::SERVICE_UNAVAILABLE,
                Json(json!({ "data": null, "error": "Authentication not configured" })),
            )
                .into_response();
        }
    };

    let token = match token {
        Some(t) => t,
        None => {
            return (
                StatusCode::UNAUTHORIZED,
                Json(json!({ "data": null, "error": "Missing authorization header" })),
            )
                .into_response();
        }
    };

    match verify_jwt(&token, &jwks, &client_id) {
        Ok(user) => {
            req.extensions_mut().insert(user);
            next.run(req).await
        }
        Err(msg) => (
            StatusCode::UNAUTHORIZED,
            Json(json!({ "data": null, "error": msg })),
        )
            .into_response(),
    }
}

pub fn verify_jwt(
    token: &str,
    jwks: &jsonwebtoken::jwk::JwkSet,
    client_id: &str,
) -> Result<AuthUser, String> {
    let header = decode_header(token).map_err(|e| format!("Invalid token: {e}"))?;
    let kid = header.kid.ok_or_else(|| "Token missing kid".to_string())?;

    let jwk = jwks
        .keys
        .iter()
        .find(|k| k.common.key_id.as_deref() == Some(&kid))
        .ok_or_else(|| "Unknown signing key".to_string())?;

    let decoding_key = DecodingKey::from_jwk(jwk).map_err(|e| format!("Invalid JWK: {e}"))?;

    let mut validation = Validation::new(Algorithm::RS256);
    validation.validate_exp = true;
    validation.set_audience(&[client_id]);

    let token_data = decode::<GoogleClaims>(token, &decoding_key, &validation)
        .map_err(|e| format!("Token verification failed: {e}"))?;

    Ok(AuthUser {
        google_user_id: token_data.claims.sub,
    })
}
