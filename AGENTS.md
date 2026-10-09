# AGENTS.md: orientation for code agents

Read this before changing anything. It covers what exists, where the product
is going, and the rules that are easy to break by accident. Details live in
the linked docs; this file is the map.

## What Prereq is

A prediction-market analytics app for **Kalshi** (Polymarket is used only for
cross-venue arbitrage detection). Users browse a scanner of liquid markets,
read an AI research card per market, watch markets, run a manual Kelly
calculator, log bets, and track their own calibration and P&L.

**Stage:** alpha, free for every signed-in user. Plan tiers are scaffolded in
`backend/src/models/plan.rs` but deliberately **not enforced**. Don't build
billing, paywalls or plan-gated routes yet (`PRODUCT_ROADMAP.md`).

## Direction: the most important thing to understand

We have **not** shown that Claude's probabilities are accurate, calibrated,
or better than the market price. The current work is building the evidence to
find out (`docs/forecast-validation.md`). Until that evidence exists:

- AI probabilities are shown as **"AI estimate — unvalidated"**. A gap from the
  market is labelled **"AI–market gap"**, never "edge" or "opportunity" in
  user-facing copy. Confidence is the model's **self-rating**, not measured
  reliability.
- **Nothing derived from the AI may drive position sizing.** The Kelly sizer
  takes only the user's own probability (`kelly_sizer.dart`). Don't
  re-introduce a prefill or a "use AI estimate" button.
- **The backend owns all arithmetic.** Claude returns a probability and
  research; `scorer::reprice` computes the gap and EV from live quotes. Never
  ask the model for, or trust, edge, EV or sizing numbers.
- **Missing means null, not zero.** For example, EV with no usable ask is
  `null` and displays as "—".
- **No accuracy or profitability claims** anywhere in product or marketing
  until the evaluation criteria in `docs/forecast-validation.md` are met.
  Synthetic results are never evidence.

The roadmap from here: collect prompt-v3 forecasts and outcomes, evaluate
with `tools/forecast_eval`, then (only with enough data) fit an AI/market
blend and run a hypothetical trading evaluation. Open business and legal items
are in `docs/founder-checklist.md`.

## Repo map

```
backend/            Rust + Axum API (SQLx/Postgres, Redis-or-memory cache)
  src/services/
    market_store.rs   5-min background loop: fetch Kalshi → attach stored scores → score top 30
    scorer.rs         Claude scoring: prompt (PROMPT_VERSION), parsing, abstention,
                      reprice (gap/EV), persistence of scores + failures
    outcomes.rs       6-hourly Kalshi settlement sync → market_outcomes
    kalshi.rs         every Kalshi HTTP call (public, unauthenticated endpoints)
    polymarket.rs     Gamma API, arb only
    arb.rs            cross-venue arb detection (title-similarity heuristic)
  src/db/             one module per table group (scores, outcomes, bets, ...)
  src/routes/         HTTP + WebSocket handlers
  migrations/         sqlx migrations, run automatically at boot
frontend/           Flutter (web/iOS/Android): Riverpod, go_router, freezed
  lib/features/       scanner, market_detail (ScoreCard), position_sizer (Kelly),
                      watchlist, performance, auth, shell
  lib/shared/models/  freezed DTOs mirroring backend JSON (snake_case)
tools/forecast_eval/  offline Dart CLI: evaluate / blend / simulate / synthetic
docs/               forecast-validation.md, founder-checklist.md, HOSTING.md
PRODUCT_ROADMAP.md, PRODUCT_TIERS.md   product sequencing and tier definitions
```

`GET_STARTED.md` (the original build spec) is **gitignored**. It exists only
on the maintainer's machine, and parts of it are outdated: it describes the
pre-validation score schema and Clerk auth, but auth is now Google Sign-In.

## Data model you must respect

| Table | Rule |
|---|---|
| `ai_scores` | **Append-only.** One row per successful Claude call, with the ledger context: prompt version, request/completion time, the quotes shown to Claude, close time, evidence. Never update or delete rows. Legacy rows have NULL `prompt_version`; never backfill them. |
| `ai_score_failures` | Every attempt that produced no estimate, including `abstained`. Needed for coverage and failure rates. |
| `market_outcomes` | Only from Kalshi's settlement fields, via `outcomes::resolution`. Never infer an outcome from a market closing or its price nearing 0/1. Finalized rows are frozen. |
| `bets`, `watchlist`, `users` | User data. A user's own bets are separate from AI forecast evaluation; don't mix them. |

Migrations are **additive only**: new nullable columns or new tables. There
are no down-migrations; the rollback plan is to redeploy the previous build.

## Rules when changing scoring

- **Any change to `build_prompt`, its inputs or `MODEL` → bump
  `PROMPT_VERSION`.** Versions are never pooled in evaluation.
- Out-of-range probabilities are **rejected** (recorded as failures), never
  clamped.
- `confidence` must be `low|medium|high`. The app decodes it as a strict enum,
  so any other value breaks the whole market list client-side.
  `parse_output` enforces this.
- `failure_kind` buckets errors by matching the message prefixes produced in
  `scorer.rs`. If you change those messages, update it and its test.
- Scoring is a **shared batch** (the top 30 markets by volume, reused by all
  users). Don't add per-user Claude loops; cost has to scale with markets, not
  users (`PRODUCT_ROADMAP.md`).
- The backend must run as **a single instance**: the background loops live
  in-process (`docs/HOSTING.md`).

## Conventions

- API responses: `{ "data": ..., "error": null }`. Prices in **dollars**
  (0–1). Timestamps UTC ISO-8601.
- Rust: `thiserror`/`AppError`, no `unwrap` in production paths, must pass
  `cargo fmt --check` and `cargo clippy --all-targets -- -D warnings`.
- Flutter: freezed + json_serializable with `field_rename: snake`. After
  editing a model, run `dart run build_runner build --delete-conflicting-outputs`
  and **commit only the generated files for the models you changed**. The
  generator also rewrites unrelated `*.g.dart` hashes; revert those.
- Kalshi quirks: a missing ask is reported as `0` or `1.00` (treat both as "no
  usable ask"). `GET /markets?tickers=a,b` silently omits unknown tickers.
  Markets settled before Kalshi's historical cutoff move to
  `/historical/markets`.
- Comments explain *why*. Match the density of the surrounding code.

## Verifying changes

| What | How |
|---|---|
| Flutter | `cd frontend && flutter analyze && flutter test` (works locally) |
| Offline tooling | `cd tools/forecast_eval && dart analyze && dart test` (works locally) |
| Rust fmt | `cd backend && cargo fmt --check` (works locally) |
| Rust compile, clippy, tests, DB integration | **GitHub Actions CI** (`.github/workflows/ci.yml`) runs on every pull request and on pushes to `main`, with a Postgres service. Open a PR from `dev` → `main` to get it. |
| Deploy | Railway project `insightful-rejoicing`, service `prereq`, builds from `dev`. Confirm that the deployed commit hash matches `dev` HEAD; pushes have silently failed to trigger builds before. |

On the maintainer's Windows machine, **local `cargo build/test` cannot
run** (an endpoint-security policy blocks freshly compiled binaries), and
there is no Python. Don't spend time on local Rust builds there; use CI. Don't
boot the backend locally for manual testing. Point the app at the deployed
backend instead (`frontend/run_railway.sh`).

Agents don't push, deploy or apply production migrations. The maintainer
pushes to `dev`.

## Doc index

| Doc | Read it for |
|---|---|
| `README.md` | Running locally, the API summary, environment variables |
| `docs/forecast-validation.md` | Evaluation policy, export queries, milestones 2–3, what "enough data" means |
| `docs/founder-checklist.md` | Open decisions, legal/permission items, launch blockers |
| `PRODUCT_ROADMAP.md` / `PRODUCT_TIERS.md` | Alpha scope, tier design, open product questions |
| `docs/HOSTING.md` | The single-instance constraint and the future scaling path |
| `tools/forecast_eval/README.md` | The offline evaluation CLI |
| `brand_assets/CLAUDE.md` | Which brand assets are live |
