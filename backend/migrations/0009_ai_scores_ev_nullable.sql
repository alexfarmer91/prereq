-- ev_per_dollar held Claude's own arithmetic. EV is now computed by the
-- backend from the live asks on every read (services::scorer::reprice), so
-- new rows leave this column NULL. Historical values are kept untouched as a
-- record of what the model returned; nothing reads them.
ALTER TABLE ai_scores ALTER COLUMN ev_per_dollar DROP NOT NULL;
