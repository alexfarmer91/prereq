pub mod market;
pub mod plan;

use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct ApiResponse<T: Serialize> {
    pub data: Option<T>,
    pub error: Option<String>,
}

impl<T: Serialize> ApiResponse<T> {
    pub fn ok(data: T) -> Self {
        Self {
            data: Some(data),
            error: None,
        }
    }
}

impl ApiResponse<serde_json::Value> {
    pub fn err(message: impl Into<String>) -> Self {
        Self {
            data: None,
            error: Some(message.into()),
        }
    }
}
