CREATE TABLE workout_sessions (
    id BIGINT GENERATED ALWAYS AS IDENTITY,
    user_id BIGINT NOT NULL,
    workout_schedule_id BIGINT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'IN_PROGRESS',
    started_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    paused_at TIMESTAMPTZ,
    finished_at TIMESTAMPTZ,
    discarded_at TIMESTAMPTZ,
    total_paused_seconds INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_workout_sessions PRIMARY KEY (id),
    CONSTRAINT fk_workout_sessions_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT fk_workout_sessions_schedule FOREIGN KEY (workout_schedule_id) REFERENCES workout_schedules (id) ON DELETE CASCADE,
    CONSTRAINT uq_workout_sessions_schedule UNIQUE (workout_schedule_id),
    CONSTRAINT chk_workout_sessions_paused_seconds CHECK (total_paused_seconds >= 0),
    CONSTRAINT chk_workout_sessions_status CHECK (status IN ('IN_PROGRESS', 'PAUSED', 'COMPLETED', 'DISCARDED'))
);

CREATE UNIQUE INDEX uq_workout_sessions_active_user
    ON workout_sessions (user_id)
    WHERE status IN ('IN_PROGRESS', 'PAUSED');

CREATE TABLE workout_logs (
    id BIGINT GENERATED ALWAYS AS IDENTITY,
    user_id BIGINT NOT NULL,
    workout_session_id BIGINT NOT NULL,
    workout_schedule_id BIGINT NOT NULL,
    title_snapshot VARCHAR(160) NOT NULL,
    started_at TIMESTAMPTZ NOT NULL,
    completed_at TIMESTAMPTZ NOT NULL,
    duration_seconds INTEGER NOT NULL,
    total_volume_kg NUMERIC(12,2) NOT NULL DEFAULT 0,
    note TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_workout_logs PRIMARY KEY (id),
    CONSTRAINT fk_workout_logs_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT fk_workout_logs_session FOREIGN KEY (workout_session_id) REFERENCES workout_sessions (id) ON DELETE CASCADE,
    CONSTRAINT fk_workout_logs_schedule FOREIGN KEY (workout_schedule_id) REFERENCES workout_schedules (id) ON DELETE CASCADE,
    CONSTRAINT uq_workout_logs_session UNIQUE (workout_session_id),
    CONSTRAINT chk_workout_logs_duration CHECK (duration_seconds >= 0),
    CONSTRAINT chk_workout_logs_volume CHECK (total_volume_kg >= 0)
);

CREATE INDEX idx_workout_logs_user_completed
    ON workout_logs (user_id, completed_at DESC);

CREATE TABLE workout_exercise_logs (
    id BIGINT GENERATED ALWAYS AS IDENTITY,
    workout_log_id BIGINT NOT NULL,
    exercise_id BIGINT NOT NULL,
    exercise_name_snapshot VARCHAR(180) NOT NULL,
    sort_order SMALLINT NOT NULL,
    duration_seconds INTEGER,
    exercise_volume_kg NUMERIC(12,2) NOT NULL DEFAULT 0,
    completed BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_workout_exercise_logs PRIMARY KEY (id),
    CONSTRAINT fk_workout_exercise_logs_log FOREIGN KEY (workout_log_id) REFERENCES workout_logs (id) ON DELETE CASCADE,
    CONSTRAINT fk_workout_exercise_logs_exercise FOREIGN KEY (exercise_id) REFERENCES exercises (id) ON DELETE RESTRICT,
    CONSTRAINT chk_workout_exercise_logs_sort CHECK (sort_order > 0),
    CONSTRAINT chk_workout_exercise_logs_duration CHECK (duration_seconds IS NULL OR duration_seconds >= 0),
    CONSTRAINT chk_workout_exercise_logs_volume CHECK (exercise_volume_kg >= 0)
);

CREATE TABLE workout_set_logs (
    id BIGINT GENERATED ALWAYS AS IDENTITY,
    workout_exercise_log_id BIGINT NOT NULL,
    set_number SMALLINT NOT NULL,
    reps SMALLINT,
    weight_kg NUMERIC(7,2),
    duration_seconds INTEGER,
    rpe NUMERIC(3,1),
    completed BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_workout_set_logs PRIMARY KEY (id),
    CONSTRAINT fk_workout_set_logs_exercise_log FOREIGN KEY (workout_exercise_log_id) REFERENCES workout_exercise_logs (id) ON DELETE CASCADE,
    CONSTRAINT chk_workout_set_logs_set_number CHECK (set_number > 0),
    CONSTRAINT chk_workout_set_logs_reps CHECK (reps IS NULL OR reps >= 0),
    CONSTRAINT chk_workout_set_logs_weight CHECK (weight_kg IS NULL OR weight_kg >= 0),
    CONSTRAINT chk_workout_set_logs_duration CHECK (duration_seconds IS NULL OR duration_seconds >= 0),
    CONSTRAINT chk_workout_set_logs_rpe CHECK (rpe IS NULL OR (rpe >= 0 AND rpe <= 10)),
    CONSTRAINT uq_workout_set_logs_exercise_set UNIQUE (workout_exercise_log_id, set_number)
);

CREATE TABLE personal_records (
    id BIGINT GENERATED ALWAYS AS IDENTITY,
    user_id BIGINT NOT NULL,
    exercise_id BIGINT NOT NULL,
    record_type VARCHAR(20) NOT NULL,
    value NUMERIC(12,2) NOT NULL,
    achieved_at TIMESTAMPTZ NOT NULL,
    workout_log_id BIGINT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_personal_records PRIMARY KEY (id),
    CONSTRAINT fk_personal_records_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT fk_personal_records_exercise FOREIGN KEY (exercise_id) REFERENCES exercises (id) ON DELETE RESTRICT,
    CONSTRAINT fk_personal_records_log FOREIGN KEY (workout_log_id) REFERENCES workout_logs (id) ON DELETE CASCADE,
    CONSTRAINT chk_personal_records_type CHECK (record_type IN ('MAX_WEIGHT', 'MAX_REPS', 'MAX_VOLUME')),
    CONSTRAINT chk_personal_records_value CHECK (value >= 0),
    CONSTRAINT uq_personal_records_user_exercise_type UNIQUE (user_id, exercise_id, record_type)
);

CREATE INDEX idx_personal_records_user_exercise
    ON personal_records (user_id, exercise_id);
