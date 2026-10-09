CREATE TABLE workout_program_templates (
    id BIGINT GENERATED ALWAYS AS IDENTITY,
    created_by_admin_id BIGINT NOT NULL,
    name VARCHAR(160) NOT NULL,
    program_type VARCHAR(30) NOT NULL,
    description TEXT,
    difficulty VARCHAR(20),
    goal VARCHAR(40),
    status VARCHAR(20) NOT NULL DEFAULT 'DRAFT',
    version INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_workout_program_templates PRIMARY KEY (id),
    CONSTRAINT fk_workout_program_templates_admin FOREIGN KEY (created_by_admin_id) REFERENCES users (id) ON DELETE RESTRICT,
    CONSTRAINT chk_workout_program_templates_type CHECK (program_type IN ('PPL', 'UPPER_LOWER', 'FULL_BODY', 'CUSTOM')),
    CONSTRAINT chk_workout_program_templates_status CHECK (status IN ('DRAFT', 'PUBLISHED', 'ARCHIVED')),
    CONSTRAINT chk_workout_program_templates_version CHECK (version > 0)
);

CREATE INDEX idx_workout_program_templates_status
    ON workout_program_templates (status, updated_at DESC);

CREATE TABLE workout_template_days (
    id BIGINT GENERATED ALWAYS AS IDENTITY,
    template_id BIGINT NOT NULL,
    day_number SMALLINT NOT NULL,
    name VARCHAR(120) NOT NULL,
    note TEXT,
    CONSTRAINT pk_workout_template_days PRIMARY KEY (id),
    CONSTRAINT fk_workout_template_days_template FOREIGN KEY (template_id) REFERENCES workout_program_templates (id) ON DELETE CASCADE,
    CONSTRAINT chk_workout_template_days_number CHECK (day_number > 0),
    CONSTRAINT uq_workout_template_days_number UNIQUE (template_id, day_number)
);

CREATE TABLE workout_template_exercises (
    id BIGINT GENERATED ALWAYS AS IDENTITY,
    template_day_id BIGINT NOT NULL,
    exercise_id BIGINT NOT NULL,
    sort_order SMALLINT NOT NULL,
    target_sets SMALLINT NOT NULL,
    target_reps_min SMALLINT,
    target_reps_max SMALLINT,
    target_duration_seconds INTEGER,
    rest_seconds INTEGER NOT NULL DEFAULT 60,
    note TEXT,
    CONSTRAINT pk_workout_template_exercises PRIMARY KEY (id),
    CONSTRAINT fk_workout_template_exercises_day FOREIGN KEY (template_day_id) REFERENCES workout_template_days (id) ON DELETE CASCADE,
    CONSTRAINT fk_workout_template_exercises_exercise FOREIGN KEY (exercise_id) REFERENCES exercises (id) ON DELETE RESTRICT,
    CONSTRAINT chk_workout_template_exercises_sort CHECK (sort_order > 0),
    CONSTRAINT chk_workout_template_exercises_sets CHECK (target_sets > 0),
    CONSTRAINT chk_workout_template_exercises_reps_min CHECK (target_reps_min IS NULL OR target_reps_min > 0),
    CONSTRAINT chk_workout_template_exercises_reps_max CHECK (target_reps_max IS NULL OR target_reps_max > 0),
    CONSTRAINT chk_workout_template_exercises_reps CHECK (target_reps_min IS NULL OR target_reps_max IS NULL OR target_reps_min <= target_reps_max),
    CONSTRAINT chk_workout_template_exercises_duration CHECK (target_duration_seconds IS NULL OR target_duration_seconds > 0),
    CONSTRAINT chk_workout_template_exercises_rest CHECK (rest_seconds >= 0),
    CONSTRAINT uq_workout_template_exercises_sort UNIQUE (template_day_id, sort_order)
);

CREATE TABLE workout_schedule_proposals (
    id BIGINT GENERATED ALWAYS AS IDENTITY,
    user_id BIGINT NOT NULL,
    source_type VARCHAR(30) NOT NULL,
    scope VARCHAR(20) NOT NULL,
    source_id BIGINT,
    source_version INTEGER,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    expires_at TIMESTAMPTZ NOT NULL,
    applied_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_workout_schedule_proposals PRIMARY KEY (id),
    CONSTRAINT fk_workout_schedule_proposals_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT chk_workout_schedule_proposals_source CHECK (source_type IN ('MANUAL', 'USER_PROGRAM', 'AI', 'ADMIN_TEMPLATE')),
    CONSTRAINT chk_workout_schedule_proposals_scope CHECK (scope IN ('ONE_DAY', 'WEEK')),
    CONSTRAINT chk_workout_schedule_proposals_status CHECK (status IN ('PENDING', 'APPLIED', 'EXPIRED'))
);

CREATE INDEX idx_workout_schedule_proposals_user_status
    ON workout_schedule_proposals (user_id, status, created_at DESC);

CREATE TABLE workout_schedule_proposal_items (
    id BIGINT GENERATED ALWAYS AS IDENTITY,
    proposal_id BIGINT NOT NULL,
    sort_order SMALLINT NOT NULL,
    source_day_id BIGINT,
    scheduled_date DATE NOT NULL,
    scheduled_time TIME,
    title VARCHAR(160) NOT NULL,
    applied_schedule_id BIGINT,
    CONSTRAINT pk_workout_schedule_proposal_items PRIMARY KEY (id),
    CONSTRAINT fk_workout_schedule_proposal_items_proposal FOREIGN KEY (proposal_id) REFERENCES workout_schedule_proposals (id) ON DELETE CASCADE,
    CONSTRAINT fk_workout_schedule_proposal_items_schedule FOREIGN KEY (applied_schedule_id) REFERENCES workout_schedules (id) ON DELETE SET NULL,
    CONSTRAINT chk_workout_schedule_proposal_items_sort CHECK (sort_order > 0),
    CONSTRAINT uq_workout_schedule_proposal_items_sort UNIQUE (proposal_id, sort_order)
);

CREATE TABLE workout_schedule_proposal_exercises (
    id BIGINT GENERATED ALWAYS AS IDENTITY,
    proposal_item_id BIGINT NOT NULL,
    exercise_id BIGINT NOT NULL,
    sort_order SMALLINT NOT NULL,
    target_sets SMALLINT NOT NULL,
    target_reps_min SMALLINT,
    target_reps_max SMALLINT,
    target_duration_seconds INTEGER,
    rest_seconds INTEGER NOT NULL DEFAULT 60,
    note TEXT,
    CONSTRAINT pk_workout_schedule_proposal_exercises PRIMARY KEY (id),
    CONSTRAINT fk_workout_schedule_proposal_exercises_item FOREIGN KEY (proposal_item_id) REFERENCES workout_schedule_proposal_items (id) ON DELETE CASCADE,
    CONSTRAINT fk_workout_schedule_proposal_exercises_exercise FOREIGN KEY (exercise_id) REFERENCES exercises (id) ON DELETE RESTRICT,
    CONSTRAINT chk_workout_schedule_proposal_exercises_sort CHECK (sort_order > 0),
    CONSTRAINT chk_workout_schedule_proposal_exercises_sets CHECK (target_sets > 0),
    CONSTRAINT chk_workout_schedule_proposal_exercises_reps_min CHECK (target_reps_min IS NULL OR target_reps_min > 0),
    CONSTRAINT chk_workout_schedule_proposal_exercises_reps_max CHECK (target_reps_max IS NULL OR target_reps_max > 0),
    CONSTRAINT chk_workout_schedule_proposal_exercises_reps CHECK (target_reps_min IS NULL OR target_reps_max IS NULL OR target_reps_min <= target_reps_max),
    CONSTRAINT chk_workout_schedule_proposal_exercises_duration CHECK (target_duration_seconds IS NULL OR target_duration_seconds > 0),
    CONSTRAINT chk_workout_schedule_proposal_exercises_rest CHECK (rest_seconds >= 0),
    CONSTRAINT uq_workout_schedule_proposal_exercises_sort UNIQUE (proposal_item_id, sort_order)
);

ALTER TABLE workout_schedules
    ADD COLUMN source_type VARCHAR(30) NOT NULL DEFAULT 'MANUAL',
    ADD COLUMN source_id BIGINT,
    ADD COLUMN source_version INTEGER,
    ADD COLUMN proposal_id BIGINT;

ALTER TABLE workout_schedules
    ADD CONSTRAINT fk_workout_schedules_proposal FOREIGN KEY (proposal_id) REFERENCES workout_schedule_proposals (id) ON DELETE SET NULL,
    ADD CONSTRAINT chk_workout_schedules_source CHECK (source_type IN ('MANUAL', 'USER_PROGRAM', 'AI', 'ADMIN_TEMPLATE'));

CREATE UNIQUE INDEX uq_workout_schedules_planned_slot
    ON workout_schedules (user_id, scheduled_date, scheduled_time)
    WHERE status = 'PLANNED' AND scheduled_time IS NOT NULL;

CREATE UNIQUE INDEX uq_workout_schedules_planned_date_without_time
    ON workout_schedules (user_id, scheduled_date)
    WHERE status = 'PLANNED' AND scheduled_time IS NULL;

CREATE TABLE workout_schedule_exercises (
    id BIGINT GENERATED ALWAYS AS IDENTITY,
    workout_schedule_id BIGINT NOT NULL,
    exercise_id BIGINT NOT NULL,
    exercise_name_snapshot VARCHAR(180) NOT NULL,
    sort_order SMALLINT NOT NULL,
    target_sets SMALLINT NOT NULL,
    target_reps_min SMALLINT,
    target_reps_max SMALLINT,
    target_duration_seconds INTEGER,
    rest_seconds INTEGER NOT NULL DEFAULT 60,
    note TEXT,
    CONSTRAINT pk_workout_schedule_exercises PRIMARY KEY (id),
    CONSTRAINT fk_workout_schedule_exercises_schedule FOREIGN KEY (workout_schedule_id) REFERENCES workout_schedules (id) ON DELETE CASCADE,
    CONSTRAINT fk_workout_schedule_exercises_exercise FOREIGN KEY (exercise_id) REFERENCES exercises (id) ON DELETE RESTRICT,
    CONSTRAINT chk_workout_schedule_exercises_sort CHECK (sort_order > 0),
    CONSTRAINT chk_workout_schedule_exercises_sets CHECK (target_sets > 0),
    CONSTRAINT chk_workout_schedule_exercises_reps_min CHECK (target_reps_min IS NULL OR target_reps_min > 0),
    CONSTRAINT chk_workout_schedule_exercises_reps_max CHECK (target_reps_max IS NULL OR target_reps_max > 0),
    CONSTRAINT chk_workout_schedule_exercises_reps CHECK (target_reps_min IS NULL OR target_reps_max IS NULL OR target_reps_min <= target_reps_max),
    CONSTRAINT chk_workout_schedule_exercises_duration CHECK (target_duration_seconds IS NULL OR target_duration_seconds > 0),
    CONSTRAINT chk_workout_schedule_exercises_rest CHECK (rest_seconds >= 0),
    CONSTRAINT uq_workout_schedule_exercises_sort UNIQUE (workout_schedule_id, sort_order)
);
