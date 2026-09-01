CREATE TABLE workout_programs (
    id BIGINT GENERATED ALWAYS AS IDENTITY,
    user_id BIGINT NOT NULL,
    name VARCHAR(160) NOT NULL,
    program_type VARCHAR(30) NOT NULL,
    description TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_workout_programs PRIMARY KEY (id),
    CONSTRAINT fk_workout_programs_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT chk_workout_programs_type CHECK (program_type IN ('PPL', 'UPPER_LOWER', 'FULL_BODY', 'CUSTOM')),
    CONSTRAINT chk_workout_programs_status CHECK (status IN ('ACTIVE', 'INACTIVE', 'ARCHIVED'))
);

CREATE UNIQUE INDEX uq_workout_programs_active_user
    ON workout_programs (user_id)
    WHERE status = 'ACTIVE' AND deleted_at IS NULL;

CREATE TABLE workout_days (
    id BIGINT GENERATED ALWAYS AS IDENTITY,
    workout_program_id BIGINT NOT NULL,
    day_number SMALLINT NOT NULL,
    name VARCHAR(120) NOT NULL,
    note TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_workout_days PRIMARY KEY (id),
    CONSTRAINT fk_workout_days_program FOREIGN KEY (workout_program_id) REFERENCES workout_programs (id) ON DELETE CASCADE,
    CONSTRAINT chk_workout_days_number CHECK (day_number > 0),
    CONSTRAINT uq_workout_days_program_day UNIQUE (workout_program_id, day_number)
);

CREATE TABLE workout_exercises (
    id BIGINT GENERATED ALWAYS AS IDENTITY,
    workout_day_id BIGINT NOT NULL,
    exercise_id BIGINT NOT NULL,
    sort_order SMALLINT NOT NULL,
    target_sets SMALLINT NOT NULL,
    target_reps_min SMALLINT,
    target_reps_max SMALLINT,
    target_duration_seconds INTEGER,
    rest_seconds INTEGER NOT NULL DEFAULT 60,
    note TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_workout_exercises PRIMARY KEY (id),
    CONSTRAINT fk_workout_exercises_day FOREIGN KEY (workout_day_id) REFERENCES workout_days (id) ON DELETE CASCADE,
    CONSTRAINT fk_workout_exercises_exercise FOREIGN KEY (exercise_id) REFERENCES exercises (id) ON DELETE RESTRICT,
    CONSTRAINT chk_workout_exercises_sort_order CHECK (sort_order > 0),
    CONSTRAINT chk_workout_exercises_target_sets CHECK (target_sets > 0),
    CONSTRAINT chk_workout_exercises_reps_min CHECK (target_reps_min IS NULL OR target_reps_min > 0),
    CONSTRAINT chk_workout_exercises_reps_max CHECK (target_reps_max IS NULL OR target_reps_max > 0),
    CONSTRAINT chk_workout_exercises_duration CHECK (target_duration_seconds IS NULL OR target_duration_seconds > 0),
    CONSTRAINT chk_workout_exercises_rest CHECK (rest_seconds >= 0),
    CONSTRAINT uq_workout_exercises_day_sort UNIQUE (workout_day_id, sort_order),
    CONSTRAINT chk_workout_exercises_reps CHECK (target_reps_min IS NULL OR target_reps_max IS NULL OR target_reps_min <= target_reps_max)
);

CREATE TABLE workout_schedules (
    id BIGINT GENERATED ALWAYS AS IDENTITY,
    user_id BIGINT NOT NULL,
    workout_program_id BIGINT,
    workout_day_id BIGINT,
    scheduled_date DATE NOT NULL,
    scheduled_time TIME,
    title VARCHAR(160) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PLANNED',
    cancel_reason VARCHAR(500),
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_workout_schedules PRIMARY KEY (id),
    CONSTRAINT fk_workout_schedules_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT fk_workout_schedules_program FOREIGN KEY (workout_program_id) REFERENCES workout_programs (id) ON DELETE SET NULL,
    CONSTRAINT fk_workout_schedules_day FOREIGN KEY (workout_day_id) REFERENCES workout_days (id) ON DELETE SET NULL,
    CONSTRAINT chk_workout_schedules_status CHECK (status IN ('PLANNED', 'COMPLETED', 'MISSED', 'CANCELLED'))
);

CREATE INDEX idx_workout_schedules_user_date_status
    ON workout_schedules (user_id, scheduled_date, status);
