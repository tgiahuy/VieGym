INSERT INTO equipment (code, name, description) VALUES
    ('ADJUSTABLE_BENCH', 'Ghế tập điều chỉnh', 'Ghế có thể điều chỉnh độ nghiêng')
ON CONFLICT (code) DO NOTHING;

INSERT INTO muscle_groups (code, name, description) VALUES
    ('ABS', 'Cơ bụng', 'Nhóm cơ vùng bụng và core phía trước'),
    ('ABDUCTORS', 'Cơ dạng hông', 'Nhóm cơ đưa chân ra xa đường giữa cơ thể'),
    ('ADDUCTORS', 'Cơ khép hông', 'Nhóm cơ đưa chân về đường giữa cơ thể'),
    ('BICEPS', 'Cơ tay trước', NULL),
    ('CALVES', 'Cơ bắp chân', NULL),
    ('CHEST', 'Cơ ngực', NULL),
    ('FOREARMS', 'Cơ cẳng tay', NULL),
    ('GLUTES', 'Cơ mông', NULL),
    ('HAMSTRINGS', 'Cơ đùi sau', NULL),
    ('LATS', 'Cơ lưng xô', NULL),
    ('LOWER_BACK', 'Cơ lưng dưới', NULL),
    ('NECK', 'Cơ cổ', NULL),
    ('QUADRICEPS', 'Cơ đùi trước', NULL),
    ('SHOULDERS', 'Cơ vai', NULL),
    ('TRAPS', 'Cơ cầu vai', NULL),
    ('TRICEPS', 'Cơ tay sau', NULL),
    ('UPPER_BACK', 'Cơ lưng trên', NULL)
ON CONFLICT (code) DO NOTHING;

CREATE TABLE dataset_import_batches (
    id BIGINT GENERATED ALWAYS AS IDENTITY,
    dataset_type VARCHAR(30) NOT NULL,
    dataset_version VARCHAR(100) NOT NULL,
    source_checksum VARCHAR(64) NOT NULL,
    status VARCHAR(20) NOT NULL,
    total_records INTEGER NOT NULL DEFAULT 0,
    inserted_records INTEGER NOT NULL DEFAULT 0,
    skipped_records INTEGER NOT NULL DEFAULT 0,
    started_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMPTZ,
    error_summary TEXT,
    CONSTRAINT pk_dataset_import_batches PRIMARY KEY (id),
    CONSTRAINT chk_dataset_import_batches_status
        CHECK (status IN ('RUNNING', 'SUCCEEDED', 'FAILED')),
    CONSTRAINT chk_dataset_import_batches_counts
        CHECK (total_records >= 0 AND inserted_records >= 0 AND skipped_records >= 0)
);

CREATE INDEX idx_dataset_import_batches_type_started
    ON dataset_import_batches (dataset_type, started_at DESC);

CREATE TABLE exercise_import_registry (
    source VARCHAR(60) NOT NULL,
    source_external_id VARCHAR(200) NOT NULL,
    exercise_id BIGINT NOT NULL,
    source_version VARCHAR(100) NOT NULL,
    record_checksum VARCHAR(64) NOT NULL,
    last_import_batch_id BIGINT NOT NULL,
    imported_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_exercise_import_registry PRIMARY KEY (source, source_external_id),
    CONSTRAINT fk_exercise_import_registry_exercise
        FOREIGN KEY (exercise_id) REFERENCES exercises (id) ON DELETE RESTRICT,
    CONSTRAINT fk_exercise_import_registry_batch
        FOREIGN KEY (last_import_batch_id) REFERENCES dataset_import_batches (id) ON DELETE RESTRICT
);

CREATE INDEX idx_exercise_import_registry_exercise
    ON exercise_import_registry (exercise_id);
