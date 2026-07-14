use axum::body::Body;
use axum::http::{Request, StatusCode};
use http_body_util::BodyExt;
use tower::ServiceExt;

use prereq_backend::{routes, AppState};

async fn body_json(response: axum::response::Response) -> serde_json::Value {
    let bytes = response.into_body().collect().await.unwrap().to_bytes();
    serde_json::from_slice(&bytes).unwrap()
}

#[tokio::test]
async fn health_returns_enveloped_ok() {
    let app = routes::app_router(AppState::disconnected().await);
    let response = app
        .oneshot(Request::get("/health").body(Body::empty()).unwrap())
        .await
        .unwrap();

    assert_eq!(response.status(), StatusCode::OK);
    let json = body_json(response).await;
    assert_eq!(json["data"], "ok");
    assert_eq!(json["error"], serde_json::Value::Null);
}

#[tokio::test]
async fn protected_route_without_auth_config_returns_503_envelope() {
    // No JWKS configured and SKIP_AUTH unset → middleware must refuse cleanly.
    let app = routes::app_router(AppState::disconnected().await);
    let response = app
        .oneshot(Request::get("/watchlist").body(Body::empty()).unwrap())
        .await
        .unwrap();

    assert_eq!(response.status(), StatusCode::SERVICE_UNAVAILABLE);
    let json = body_json(response).await;
    assert_eq!(json["data"], serde_json::Value::Null);
    assert!(json["error"].is_string());
}

#[tokio::test]
async fn unknown_route_is_404() {
    let app = routes::app_router(AppState::disconnected().await);
    let response = app
        .oneshot(Request::get("/nope").body(Body::empty()).unwrap())
        .await
        .unwrap();
    assert_eq!(response.status(), StatusCode::NOT_FOUND);
}
