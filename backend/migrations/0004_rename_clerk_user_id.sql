-- Auth switched from Clerk to direct Google Sign-In; this column now holds
-- the Google ID token's `sub` claim instead of a Clerk user ID. Same kind
-- of stable external identity string, different issuer.
ALTER TABLE users RENAME COLUMN clerk_user_id TO google_user_id;
