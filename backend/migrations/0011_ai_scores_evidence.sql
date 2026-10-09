-- Prompt v3: structured evidence behind each estimate (claim, source, date,
-- which outcome it supports). Older rows stay NULL; readers treat that as an
-- empty list. Abstentions are not scores — they are recorded in
-- ai_score_failures with error_kind = 'abstained' and the model's reason in
-- error_detail.
ALTER TABLE ai_scores ADD COLUMN IF NOT EXISTS evidence JSONB;
