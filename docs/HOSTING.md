# Hosting & scaling notes

## Current architecture constraint: single-instance only

`main.rs` spawns two long-running background loops in-process (`spawn_refresh_task`,
`spawn_arb_task`) that fetch Kalshi/Polymarket data, call Claude for scoring, and
write into `MarketStore` — an in-memory `Arc<RwLock<Vec<Market>>>` (`services/market_store.rs`).
Redis is only used as a short-TTL cache in front of individual requests, not as the
source of truth for the market snapshot.

This means the backend **must run as exactly one instance**. If it's ever scaled to
2+ replicas without changing the code:

- Each replica independently polls Kalshi and pays for its own Claude scoring calls
  every 5 minutes — duplicated cost, not duplicated value.
- Different users land on different replicas (via the load balancer) and see
  different market snapshots/scores, since state isn't shared.
- WebSocket clients (`/ws/markets`) get served from whichever replica's in-memory
  cache happens to hold their data.

Autoscaling groups (Elastic Beanstalk's default model, ECS/Fargate with desired
count > 1, etc.) assume interchangeable stateless replicas — that assumption is
false for this app today. Any hosting choice must either pin to a single instance
or wait for the decoupling described below.

## Hosting choice (MVP/alpha)

Chosen: single fixed instance (no autoscaling), not Elastic Beanstalk — EB's value
is autoscaled stateless web tiers, which doesn't fit the constraint above and adds
AWS-fixed costs (ALB, NAT gateway) that aren't needed at this stage.

## Future-state architecture (when scaling past one instance matters)

Do this before turning on autoscaling or running >1 replica:

1. **Extract the refresh/arb loops into a dedicated singleton worker service**,
   separate from the API/WS-serving processes. Only that one worker calls Kalshi,
   Polymarket, and Claude, and writes the results.
2. **Move `MarketStore` out of process memory and into Redis (or Postgres)** as
   the shared source of truth. API/WS instances become stateless readers of that
   shared store instead of owning their own snapshot.
3. With state externalized, the API/WS tier can autoscale freely (ALB/target
   group, ECS service, etc.) since any replica reads the same data.
4. The worker itself stays single-instance (or uses a leader-election /
   distributed-lock pattern if redundancy is needed) — it should never be allowed
   to run N times in parallel, since that reintroduces the duplicate-Kalshi/Claude-cost
   problem.

Until this refactor happens, keep deployment configs pinned to a single running
instance of the backend, regardless of which host is used.
