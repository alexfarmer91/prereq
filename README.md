# Prereq

Prediction-market analytics SaaS: find edge, size positions (Kelly), and track calibration across Kalshi (and Polymarket for arb detection). Rust/Axum backend + Flutter frontend. Product spec lives in [GET_STARTED.md](GET_STARTED.md).

## Repo layout

- `backend/` — Rust + Axum API server (SQLx/Postgres, Redis-or-memory cache, Claude scoring, WebSocket)
- `frontend/` — Flutter app (web/iOS/Android; Riverpod, go_router, Google Sign-In, fl_chart)

## Running locally (no external accounts needed)

The backend degrades gracefully: without a database it serves live Kalshi market data and returns clean 503s for user features; without an Anthropic key markets are unscored; without Redis it uses an in-process cache.

```powershell
# Backend — http://localhost:3000
cd backend
copy .env.example .env
# In .env set: SKIP_AUTH=true            (dev only — bypasses the ID token check)
cargo run

# Frontend (web) — talks to the local backend, skips sign-in
cd frontend
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000 --dart-define=DEV_AUTH_BYPASS=true
```

Verification commands:

```powershell
cd backend  && cargo test    && cargo clippy --all-targets -- -D warnings
cd frontend && flutter analyze && flutter test
```

## API summary

All responses use the `{ "data": ..., "error": null }` envelope. Prices are dollars; timestamps are UTC ISO-8601. Everything except `/health` requires `Authorization: Bearer <Google ID token>` (the WebSocket takes `?token=`).

```
GET    /health
GET    /markets?category=&sort=edge|volume|close   scored + filtered Kalshi markets
GET    /markets/:ticker                            detail + all strike variants
GET    /markets/:ticker/history                    price history (may be empty)
GET    /me            PATCH /me                    profile / bankroll
GET    /watchlist     POST /watchlist              DELETE /watchlist/:ticker
GET    /bets          POST /bets                   PATCH /bets/:id
GET    /performance                                calibration + P&L + streaks
GET    /arbs                                       cross-platform arb opportunities
WS     /ws/markets?token=                          live prices for subscribed tickers
```

## Remaining human tasks before UAT

Everything below requires accounts/credentials or judgment a developer can't supply — the code paths are already built and verified around them.

1. **Google Sign-In** — create an OAuth 2.0 Client ID (type: **Web application**) in Google Cloud Console. Register an Authorized JavaScript origin for every place the frontend runs from (e.g. `http://localhost:8765` for the pinned local dev port, plus the deployed frontend's origin). Then:
   - backend `.env`: `GOOGLE_CLIENT_ID=xxx.apps.googleusercontent.com`, set `SKIP_AUTH=false`
   - frontend run/build: `--dart-define=GOOGLE_CLIENT_ID=xxx.apps.googleusercontent.com` (same value)
2. **Supabase (Postgres)** — create a project and put its connection string in `DATABASE_URL`. Migrations in `backend/migrations/` run automatically at boot.
3. **Redis** (optional for single-instance UAT) — provision and set `REDIS_URL`. Without it the in-process cache is used; scores re-generate on restart.
4. **Anthropic** — set `ANTHROPIC_API_KEY` to enable AI scoring (top 30 most liquid markets per 5-minute refresh, cached 30 min). Watch spend during UAT.
5. **Deploy** — the backend is live on Railway at `https://prereq-production-7bb8.up.railway.app`. Point the frontend at it with `--dart-define=API_BASE_URL=https://prereq-production-7bb8.up.railway.app` (or run `frontend/run_railway.sh`, which also sets `GOOGLE_CLIENT_ID` — that backend runs with `SKIP_AUTH=false`, so `DEV_AUTH_BYPASS` won't work against it). `flutter build web` for the web bundle; App/Play Store publishing when ready.
6. **UAT itself** — sign in with Google, browse the scanner, open a detail view, add to watchlist, log a bet via the Kelly sizer, resolve it, and confirm it appears on the performance dashboard.

Known MVP limits (deliberate, per spec): arb matching uses title similarity (heuristic, may miss/false-positive pairs); watchlist alert thresholds are stored but push notifications are not wired; order execution on Kalshi is out of scope.
