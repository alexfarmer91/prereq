use std::collections::HashMap;
use std::sync::Arc;
use std::time::{Duration, Instant};

use redis::AsyncCommands;
use tokio::sync::RwLock;

type MemoryStore = Arc<RwLock<HashMap<String, (String, Instant)>>>;

/// String cache backed by Redis when REDIS_URL is set, otherwise an
/// in-process map with the same TTL semantics (fine for a single instance).
#[derive(Clone)]
pub enum Cache {
    Redis(redis::aio::ConnectionManager),
    Memory(MemoryStore),
}

impl Cache {
    pub async fn connect(redis_url: Option<&str>) -> Self {
        if let Some(url) = redis_url.filter(|u| !u.is_empty()) {
            match redis::Client::open(url) {
                Ok(client) => match client.get_connection_manager().await {
                    Ok(manager) => {
                        tracing::info!("Connected to Redis");
                        return Cache::Redis(manager);
                    }
                    Err(e) => {
                        tracing::warn!("Redis unreachable ({e}) — using in-memory cache")
                    }
                },
                Err(e) => tracing::warn!("Invalid REDIS_URL ({e}) — using in-memory cache"),
            }
        } else {
            tracing::warn!("REDIS_URL not set — using in-memory cache");
        }
        Cache::Memory(Arc::new(RwLock::new(HashMap::new())))
    }

    pub async fn get(&self, key: &str) -> Option<String> {
        match self {
            Cache::Redis(manager) => {
                let mut conn = manager.clone();
                conn.get::<_, Option<String>>(key).await.ok().flatten()
            }
            Cache::Memory(map) => {
                let guard = map.read().await;
                match guard.get(key) {
                    Some((value, expires)) if *expires > Instant::now() => Some(value.clone()),
                    _ => None,
                }
            }
        }
    }

    pub async fn set(&self, key: &str, value: &str, ttl: Duration) {
        match self {
            Cache::Redis(manager) => {
                let mut conn = manager.clone();
                if let Err(e) = conn
                    .set_ex::<_, _, ()>(key, value, ttl.as_secs().max(1))
                    .await
                {
                    tracing::warn!("Redis SET failed for {key}: {e}");
                }
            }
            Cache::Memory(map) => {
                let mut guard = map.write().await;
                // Opportunistic purge so the map doesn't grow unbounded.
                guard.retain(|_, (_, expires)| *expires > Instant::now());
                guard.insert(key.to_string(), (value.to_string(), Instant::now() + ttl));
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn memory_cache_respects_ttl() {
        let cache = Cache::Memory(Arc::new(RwLock::new(HashMap::new())));
        cache.set("k", "v", Duration::from_secs(60)).await;
        assert_eq!(cache.get("k").await.as_deref(), Some("v"));

        cache.set("gone", "v", Duration::from_millis(1)).await;
        tokio::time::sleep(Duration::from_millis(10)).await;
        assert_eq!(cache.get("gone").await, None);
    }
}
