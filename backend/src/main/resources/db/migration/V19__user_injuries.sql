-- Injury flags used by the AI planners to exclude risky exercises
-- (codes: LOWER_BACK, KNEE, SHOULDER, WRIST, ELBOW, NECK, ANKLE, HIP).
ALTER TABLE user_preferences
    ADD COLUMN injuries JSONB NOT NULL DEFAULT '[]';

ALTER TABLE user_preferences
    ADD CONSTRAINT chk_user_preferences_injuries CHECK (jsonb_typeof(injuries) = 'array');
