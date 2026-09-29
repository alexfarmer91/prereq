-- Durable store for every Claude scoring run. Scores used to live only in
-- the Redis/in-memory cache with a 30-minute TTL, so every restart (and every
-- TTL expiry) re-bought the same analysis — including web searches — from the
-- Anthropic API. The scorer now reads the latest row per ticker and only calls
-- Claude again when that row is genuinely stale (see services::scorer).
--
-- Append-only: each rescore inserts a new row, which doubles as a history of
-- the model's calls for later calibration against resolved outcomes.
CREATE TABLE IF NOT EXISTS ai_scores (
  id BIGSERIAL PRIMARY KEY,
  market_ticker TEXT NOT NULL,
  market_title TEXT NOT NULL,
  fair_probability DOUBLE PRECISION NOT NULL,
  confidence TEXT NOT NULL,
  ev_per_dollar DOUBLE PRECISION NOT NULL,
  rationale TEXT NOT NULL,
  signals JSONB NOT NULL DEFAULT '[]'::jsonb,
  risks JSONB NOT NULL DEFAULT '[]'::jsonb,
  -- Market mid when scored: edge is recomputed against the live price on
  -- read, and a large move since scoring triggers a rescore.
  market_price_at_score DOUBLE PRECISION NOT NULL,
  model TEXT NOT NULL,
  web_search_enabled BOOLEAN NOT NULL DEFAULT FALSE,
  web_search_count INTEGER NOT NULL DEFAULT 0,
  input_tokens BIGINT NOT NULL DEFAULT 0,
  output_tokens BIGINT NOT NULL DEFAULT 0,
  -- Full final-turn content blocks from Claude (text, web search queries,
  -- results, citations) so the research is never paid for twice.
  raw_content JSONB,
  scored_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ai_scores_ticker_scored
  ON ai_scores (market_ticker, scored_at DESC);

-- Same deny-by-default posture as every other table (see 0002_enable_rls.sql).
ALTER TABLE ai_scores ENABLE ROW LEVEL SECURITY;
