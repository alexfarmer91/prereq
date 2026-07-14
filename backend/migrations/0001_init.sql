-- Users are managed by Clerk; we store clerk_user_id as the FK
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  clerk_user_id TEXT UNIQUE NOT NULL,
  bankroll_dollars DECIMAL(12,2) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS watchlist (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  market_ticker TEXT NOT NULL,
  alert_edge_threshold DECIMAL(5,4), -- alert when edge > X
  edge_at_add DECIMAL(6,4),          -- AI edge snapshot when the market was added
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, market_ticker)
);

CREATE TABLE IF NOT EXISTS bet_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  market_ticker TEXT NOT NULL,
  market_title TEXT NOT NULL,
  side TEXT CHECK(side IN ('yes','no')) NOT NULL,
  entry_price_dollars DECIMAL(6,4) NOT NULL,
  contracts INTEGER NOT NULL,
  your_probability DECIMAL(5,4) NOT NULL,  -- user's estimated fair prob at entry
  kelly_fraction DECIMAL(5,4),
  outcome TEXT CHECK(outcome IN ('win','loss','pending')) DEFAULT 'pending',
  exit_price_dollars DECIMAL(6,4),
  placed_at TIMESTAMPTZ DEFAULT NOW(),
  resolved_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_bet_log_user_placed ON bet_log (user_id, placed_at DESC);
CREATE INDEX IF NOT EXISTS idx_watchlist_user ON watchlist (user_id);

-- Derived from bet_log; currently computed on demand by /performance,
-- kept for a future nightly rollup job.
CREATE TABLE IF NOT EXISTS calibration_buckets (
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  bucket_min DECIMAL(3,2), -- e.g. 0.60
  bucket_max DECIMAL(3,2), -- e.g. 0.70
  predicted_count INTEGER,
  actual_win_rate DECIMAL(5,4),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id, bucket_min)
);
