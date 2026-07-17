-- Defense in depth: deny-by-default RLS on every table.
--
-- The backend connects as the table owner (Supabase `postgres` role), which
-- bypasses RLS, so the API is unaffected. What this blocks is Supabase's
-- auto-generated Data API (PostgREST): the `anon`/`authenticated` roles hold
-- default grants on the `public` schema, and RLS with no policies denies them
-- everything. There are deliberately NO policies — no client should ever
-- reach Postgres except through the backend.
--
-- Do NOT add FORCE ROW LEVEL SECURITY: that would remove the owner bypass
-- and lock the backend out.

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE watchlist ENABLE ROW LEVEL SECURITY;
ALTER TABLE bet_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE calibration_buckets ENABLE ROW LEVEL SECURITY;
