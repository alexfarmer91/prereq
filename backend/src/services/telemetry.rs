use std::time::{SystemTime, UNIX_EPOCH};

use serde_json::{json, Value};

const TRACK_URL: &str = "https://api.mixpanel.com/track";

/// Server-side events aren't tied to an end user, so they carry a stable
/// service identity instead of a person's distinct_id.
const DISTINCT_ID: &str = "prereq-backend";

/// Fire-and-forget Mixpanel tracking over the HTTP ingestion API. A no-op
/// when MIXPANEL_TOKEN is unset; send failures are logged and never surface
/// to callers.
#[derive(Clone, Default)]
pub struct Telemetry {
    token: Option<String>,
    http: Option<reqwest::Client>,
}

impl Telemetry {
    pub fn new(http: reqwest::Client, token: Option<String>) -> Self {
        Telemetry {
            token: token.filter(|t| !t.is_empty()),
            http: Some(http),
        }
    }

    /// Queue an event. `properties` must be a JSON object; the Mixpanel
    /// envelope fields (token, distinct_id, time, $insert_id) are added here.
    pub fn track(&self, event: &str, mut properties: Value) {
        let (Some(token), Some(http)) = (self.token.clone(), self.http.clone()) else {
            return;
        };
        let event = event.to_string();
        tokio::spawn(async move {
            let now = SystemTime::now()
                .duration_since(UNIX_EPOCH)
                .map(|d| d.as_secs())
                .unwrap_or(0);
            if let Value::Object(map) = &mut properties {
                map.insert("token".into(), json!(token));
                map.insert("distinct_id".into(), json!(DISTINCT_ID));
                map.insert("time".into(), json!(now));
                // Dedup key so Mixpanel drops accidental double-sends.
                map.insert("$insert_id".into(), json!(uuid::Uuid::new_v4().to_string()));
            }
            let body = json!([{ "event": event, "properties": properties }]);
            match http.post(TRACK_URL).json(&body).send().await {
                Ok(resp) if !resp.status().is_success() => {
                    tracing::debug!("Mixpanel track '{event}' returned {}", resp.status());
                }
                Err(e) => tracing::debug!("Mixpanel track '{event}' failed: {e}"),
                _ => {}
            }
        });
    }
}
