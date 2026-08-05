use crate::error::AppError;

/// Uploads to the `profile_pictures` Supabase Storage bucket via the
/// service-role key, bypassing Storage RLS. There is no Supabase Auth
/// session to scope a client-side upload to (this app authenticates with
/// Google ID tokens verified by our own middleware), so avatar uploads are
/// proxied through this backend rather than done client-direct — the
/// `google_user_id` used as the storage path prefix comes from our own
/// verified `AuthUser`, not from anything the client can control past that.
#[derive(Clone, Default)]
pub struct AvatarStorage {
    project_url: Option<String>,
    service_role_key: Option<String>,
    http: Option<reqwest::Client>,
}

const BUCKET: &str = "profile_pictures";

impl AvatarStorage {
    pub fn new(
        http: reqwest::Client,
        project_url: Option<String>,
        service_role_key: Option<String>,
    ) -> Self {
        AvatarStorage {
            project_url: project_url.filter(|u| !u.is_empty()),
            service_role_key: service_role_key.filter(|k| !k.is_empty()),
            http: Some(http),
        }
    }

    /// Uploads `bytes` to `{google_user_id}/avatar.{ext}` (overwriting any
    /// prior avatar at that path) and returns the bucket's public URL for it.
    pub async fn upload_avatar(
        &self,
        google_user_id: &str,
        content_type: &str,
        bytes: Vec<u8>,
    ) -> Result<String, AppError> {
        let (Some(project_url), Some(key), Some(http)) =
            (&self.project_url, &self.service_role_key, &self.http)
        else {
            return Err(AppError::ServiceUnavailable(
                "Avatar uploads are not configured".to_string(),
            ));
        };

        let ext = match content_type {
            "image/jpeg" => "jpg",
            "image/png" => "png",
            "image/webp" => "webp",
            other => {
                return Err(AppError::BadRequest(format!(
                    "Unsupported image type: {other}"
                )))
            }
        };
        let path = format!("{google_user_id}/avatar.{ext}");

        let resp = http
            .post(format!("{project_url}/storage/v1/object/{BUCKET}/{path}"))
            .header("Authorization", format!("Bearer {key}"))
            .header("apikey", key.as_str())
            .header("Content-Type", content_type)
            .header("x-upsert", "true")
            .body(bytes)
            .send()
            .await
            .map_err(|e| AppError::Internal(format!("Avatar upload failed: {e}")))?;

        if !resp.status().is_success() {
            let status = resp.status();
            let body = resp.text().await.unwrap_or_default();
            return Err(AppError::Internal(format!(
                "Avatar upload failed ({status}): {body}"
            )));
        }

        Ok(format!(
            "{project_url}/storage/v1/object/public/{BUCKET}/{path}"
        ))
    }
}
