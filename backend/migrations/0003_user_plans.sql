-- Product tiers. Everyone starts on 'free'; paid tiers get set by the
-- billing integration (or manually during UAT). Entitlement checks happen
-- server-side against this column — never trust a client-supplied plan.
--   free: scanner + base AI scores + watchlist + bet log/calibration
--   edge: + arbitrage scanner + alerts
--   pro:  + user-triggered deep research (web search) with metered credits
ALTER TABLE users
  ADD COLUMN plan TEXT NOT NULL DEFAULT 'free'
  CHECK (plan IN ('free', 'edge', 'pro'));
