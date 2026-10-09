-- Forecast ledger: enough context on every Claude call to evaluate the AI
-- probability against the market and the real outcome later. See
-- docs/forecast-validation.md for how these tables are used.
--
-- All new ai_scores columns are nullable. Rows written before this migration
-- leave them NULL and are treated as legacy/incomplete — nothing is
-- backfilled or guessed.
ALTER TABLE ai_scores
  -- When the Claude call started (scored_at is when it completed).
  ADD COLUMN IF NOT EXISTS requested_at TIMESTAMPTZ,
  -- services::scorer::PROMPT_VERSION; bumped whenever the prompt or its
  -- inputs change so forecasts from different prompts are never pooled.
  ADD COLUMN IF NOT EXISTS prompt_version TEXT,
  ADD COLUMN IF NOT EXISTS event_ticker TEXT,
  ADD COLUMN IF NOT EXISTS category TEXT,
  ADD COLUMN IF NOT EXISTS market_close_time TIMESTAMPTZ,
  -- Top-of-book quotes shown to Claude (dollars). market_price_at_score is
  -- their YES mid, the forecasting benchmark.
  ADD COLUMN IF NOT EXISTS yes_bid DOUBLE PRECISION,
  ADD COLUMN IF NOT EXISTS yes_ask DOUBLE PRECISION,
  ADD COLUMN IF NOT EXISTS no_bid DOUBLE PRECISION,
  ADD COLUMN IF NOT EXISTS no_ask DOUBLE PRECISION;

-- Failed scoring attempts, so coverage and failure rates can't silently
-- vanish from evaluation. Successful attempts live in ai_scores.
CREATE TABLE IF NOT EXISTS ai_score_failures (
  id BIGSERIAL PRIMARY KEY,
  market_ticker TEXT NOT NULL,
  requested_at TIMESTAMPTZ NOT NULL,
  failed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  model TEXT NOT NULL,
  prompt_version TEXT NOT NULL,
  web_search_enabled BOOLEAN NOT NULL,
  -- parse_failure | invalid_probability | provider_error | request_failed | other
  error_kind TEXT NOT NULL,
  -- Truncated error message; never contains credentials.
  error_detail TEXT NOT NULL,
  market_price_at_request DOUBLE PRECISION
);

CREATE INDEX IF NOT EXISTS idx_ai_score_failures_ticker
  ON ai_score_failures (market_ticker, requested_at DESC);

-- Official settlement state for every market we have scored, from Kalshi's
-- market lifecycle fields (services::outcomes). Kept separate from the
-- immutable forecasts in ai_scores. Once status is 'finalized' the row is
-- never rewritten.
CREATE TABLE IF NOT EXISTS market_outcomes (
  market_ticker TEXT PRIMARY KEY,
  venue TEXT NOT NULL DEFAULT 'kalshi',
  -- Kalshi lifecycle status at the last check, verbatim.
  status TEXT NOT NULL,
  market_type TEXT,
  -- Kalshi `result` verbatim: yes | no | scalar | ''.
  result TEXT,
  settlement_value DOUBLE PRECISION,
  settlement_ts TIMESTAMPTZ,
  -- Our classification (services::outcomes::resolution):
  --   yes | no      finalized binary market, result consistent with payout
  --   pending       not finalized yet (active, closed, determined, ...)
  --   disputed      disputed or amended
  --   nonbinary     scalar market or scalar result
  --   exception     finalized but not a clean yes/no (e.g. voided)
  -- Only yes/no rows enter the binary forecasting evaluation.
  resolution TEXT NOT NULL,
  first_finalized_seen_at TIMESTAMPTZ,
  checked_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Same deny-by-default posture as every other table (see 0002_enable_rls.sql).
ALTER TABLE ai_score_failures ENABLE ROW LEVEL SECURITY;
ALTER TABLE market_outcomes ENABLE ROW LEVEL SECURITY;
