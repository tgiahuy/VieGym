-- AI workout & meal plan generation (POST /api/v1/ai/workouts/generate, /api/v1/ai/meals/generate).
-- Generated plans reuse ai_generation_batches / ai_recommendations so the existing
-- apply/dismiss flow works unchanged; batches are now separated by purpose so plan
-- generation does not consume the daily-recommendation quota.

ALTER TABLE ai_generation_batches
    ADD COLUMN purpose VARCHAR(30) NOT NULL DEFAULT 'DAILY_RECOMMENDATION';

ALTER TABLE ai_generation_batches
    ADD CONSTRAINT chk_ai_generation_purpose
        CHECK (purpose IN ('DAILY_RECOMMENDATION', 'WORKOUT_PLAN', 'MEAL_PLAN'));

ALTER TABLE ai_generation_batches DROP CONSTRAINT uq_ai_generation_user_date_no;
ALTER TABLE ai_generation_batches
    ADD CONSTRAINT uq_ai_generation_user_purpose_date_no
        UNIQUE (user_id, purpose, target_date, generation_no);

-- Per-purpose limits are enforced in code (daily: 3, plans: 10); this is the hard ceiling.
ALTER TABLE ai_generation_batches DROP CONSTRAINT chk_ai_generation_no;
ALTER TABLE ai_generation_batches
    ADD CONSTRAINT chk_ai_generation_no CHECK (generation_no BETWEEN 1 AND 20);
