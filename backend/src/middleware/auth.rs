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
use std::sync::Arc;

use crate::AppState;

#[derive(Clone, Debug, Deserialize, Serialize)]
pub struct ClerkClaims {
    pub sub: String,
    pub exp: u64,
    pub iat: u64,
}

#[derive(Clone, Debug)]
pub struct AuthUser {
    pub clerk_user_id: String,
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
            clerk_user_id: "dev".to_string(),
        });
        return next.run(req).await;
    }

    let token: Option<String> = req
        .headers()
        .get(AUTHORIZATION)
        .and_then(|v| v.to_str().ok())
        .and_then(|s| s.strip_prefix("Bearer "))
        .map(|s| s.to_owned());

    let jwks = match &state.jwks {
        Some(j) => j.clone(),
        None => {
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

    match verify_jwt(&token, &jwks) {
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
    jwks: &Arc<jsonwebtoken::jwk::JwkSet>,
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

    let token_data = decode::<ClerkClaims>(token, &decoding_key, &validation)
        .map_err(|e| format!("Token verification failed: {e}"))?;

    Ok(AuthUser {
        clerk_user_id: token_data.claims.sub,
    })
}
