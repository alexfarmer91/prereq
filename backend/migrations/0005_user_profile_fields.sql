-- Profile fields pulled from the verified Google ID token. These are
-- refreshed on every authenticated request (get_or_create upserts them), so
-- they stay in sync if a user changes their name/avatar on Google's side.
ALTER TABLE users
  ADD COLUMN email TEXT,
  ADD COLUMN email_verified BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN display_name TEXT,
  ADD COLUMN avatar_url TEXT,
  ADD COLUMN updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  ADD COLUMN last_seen_at TIMESTAMPTZ;
