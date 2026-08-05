ALTER TABLE users
  ADD COLUMN IF NOT EXISTS is_admin BOOLEAN NOT NULL DEFAULT FALSE;

-- Cap admins at 2. This has to live in the database rather than in app code
-- or RLS: the backend connects as the table owner and bypasses RLS (see
-- 0002_enable_rls.sql), so this is the only enforcement point that can't be
-- routed around by a future code path or a manual SQL edit.
CREATE OR REPLACE FUNCTION enforce_max_admins() RETURNS TRIGGER AS $$
BEGIN
  IF NEW.is_admin AND (TG_OP = 'INSERT' OR NOT OLD.is_admin) THEN
    IF (SELECT COUNT(*) FROM users WHERE is_admin) >= 2 THEN
      RAISE EXCEPTION 'Cannot have more than 2 admin users';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_enforce_max_admins ON users;
CREATE TRIGGER trg_enforce_max_admins
  BEFORE INSERT OR UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION enforce_max_admins();
