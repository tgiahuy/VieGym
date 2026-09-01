CREATE TABLE muscle_groups (
    id BIGINT GENERATED ALWAYS AS IDENTITY,
    code VARCHAR(50) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_muscle_groups PRIMARY KEY (id),
    CONSTRAINT uq_muscle_groups_code UNIQUE (code)
);

CREATE TABLE exercises (
    id BIGINT GENERATED ALWAYS AS IDENTITY,
    name VARCHAR(180) NOT NULL,
    search_name VARCHAR(180) NOT NULL,
    slug VARCHAR(200) NOT NULL,
    difficulty VARCHAR(20) NOT NULL,
    description TEXT NOT NULL,
    instruction_steps JSONB NOT NULL DEFAULT '[]'::jsonb,
    common_mistakes JSONB NOT NULL DEFAULT '[]'::jsonb,
    safety_notes JSONB NOT NULL DEFAULT '[]'::jsonb,
    visibility VARCHAR(20) NOT NULL DEFAULT 'PUBLIC',
    created_by BIGINT,
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_exercises PRIMARY KEY (id),
    CONSTRAINT uq_exercises_slug UNIQUE (slug),
    CONSTRAINT fk_exercises_created_by FOREIGN KEY (created_by) REFERENCES users (id),
    CONSTRAINT chk_exercises_difficulty CHECK (difficulty IN ('BEGINNER', 'INTERMEDIATE', 'ADVANCED')),
    CONSTRAINT chk_exercises_visibility CHECK (visibility IN ('PUBLIC', 'HIDDEN'))
);

CREATE INDEX idx_exercises_search_name ON exercises (search_name);
CREATE INDEX idx_exercises_visibility_deleted_at ON exercises (visibility, deleted_at);

CREATE TABLE exercise_muscle_groups (
    exercise_id BIGINT NOT NULL,
    muscle_group_id BIGINT NOT NULL,
    role VARCHAR(10) NOT NULL,
    CONSTRAINT pk_exercise_muscle_groups PRIMARY KEY (exercise_id, muscle_group_id, role),
    CONSTRAINT fk_exercise_muscle_groups_exercise FOREIGN KEY (exercise_id) REFERENCES exercises (id) ON DELETE CASCADE,
    CONSTRAINT fk_exercise_muscle_groups_muscle_group FOREIGN KEY (muscle_group_id) REFERENCES muscle_groups (id) ON DELETE RESTRICT,
    CONSTRAINT chk_exercise_muscle_groups_role CHECK (role IN ('PRIMARY', 'SECONDARY'))
);

CREATE INDEX idx_exercise_muscle_groups_muscle_exercise
    ON exercise_muscle_groups (muscle_group_id, exercise_id);

CREATE TABLE exercise_equipment (
    exercise_id BIGINT NOT NULL,
    equipment_id BIGINT NOT NULL,
    is_required BOOLEAN NOT NULL DEFAULT true,
    CONSTRAINT pk_exercise_equipment PRIMARY KEY (exercise_id, equipment_id),
    CONSTRAINT fk_exercise_equipment_exercise FOREIGN KEY (exercise_id) REFERENCES exercises (id) ON DELETE CASCADE,
    CONSTRAINT fk_exercise_equipment_equipment FOREIGN KEY (equipment_id) REFERENCES equipment (id) ON DELETE RESTRICT
);

CREATE INDEX idx_exercise_equipment_equipment_exercise
    ON exercise_equipment (equipment_id, exercise_id);

CREATE TABLE favorite_exercises (
    user_id BIGINT NOT NULL,
    exercise_id BIGINT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_favorite_exercises PRIMARY KEY (user_id, exercise_id),
    CONSTRAINT fk_favorite_exercises_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT fk_favorite_exercises_exercise FOREIGN KEY (exercise_id) REFERENCES exercises (id) ON DELETE CASCADE
);

CREATE INDEX idx_favorite_exercises_user_created
    ON favorite_exercises (user_id, created_at DESC);
