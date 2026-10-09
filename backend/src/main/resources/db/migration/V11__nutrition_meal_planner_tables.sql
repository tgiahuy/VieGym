CREATE TABLE foods (
    id BIGINT GENERATED ALWAYS AS IDENTITY,
    name VARCHAR(180) NOT NULL,
    search_name VARCHAR(180) NOT NULL,
    slug VARCHAR(200) NOT NULL,
    category VARCHAR(100) NOT NULL,
    serving_amount NUMERIC(8,2) NOT NULL,
    serving_unit VARCHAR(30) NOT NULL,
    grams_per_serving NUMERIC(8,2),
    calories_per_serving NUMERIC(8,2) NOT NULL,
    protein_g_per_serving NUMERIC(7,2) NOT NULL,
    carbs_g_per_serving NUMERIC(7,2) NOT NULL,
    fat_g_per_serving NUMERIC(7,2) NOT NULL,
    data_source VARCHAR(255),
    source_note TEXT,
    is_estimated BOOLEAN NOT NULL DEFAULT true,
    visibility VARCHAR(20) NOT NULL DEFAULT 'PUBLIC',
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_foods PRIMARY KEY (id),
    CONSTRAINT uq_foods_slug UNIQUE (slug),
    CONSTRAINT chk_foods_serving_amount CHECK (serving_amount > 0),
    CONSTRAINT chk_foods_grams CHECK (grams_per_serving IS NULL OR grams_per_serving > 0),
    CONSTRAINT chk_foods_nutrition CHECK (
        calories_per_serving >= 0 AND protein_g_per_serving >= 0
        AND carbs_g_per_serving >= 0 AND fat_g_per_serving >= 0
    ),
    CONSTRAINT chk_foods_visibility CHECK (visibility IN ('PUBLIC', 'HIDDEN'))
);

CREATE INDEX idx_foods_public_search ON foods (search_name, id)
    WHERE visibility = 'PUBLIC' AND deleted_at IS NULL;
CREATE INDEX idx_foods_public_category ON foods (category, name, id)
    WHERE visibility = 'PUBLIC' AND deleted_at IS NULL;

CREATE TABLE favorite_foods (
    user_id BIGINT NOT NULL,
    food_id BIGINT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_favorite_foods PRIMARY KEY (user_id, food_id),
    CONSTRAINT fk_favorite_foods_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT fk_favorite_foods_food FOREIGN KEY (food_id) REFERENCES foods (id) ON DELETE CASCADE
);

CREATE INDEX idx_favorite_foods_user_created ON favorite_foods (user_id, created_at DESC);

CREATE TABLE meal_plans (
    id BIGINT GENERATED ALWAYS AS IDENTITY,
    user_id BIGINT NOT NULL,
    plan_date DATE NOT NULL,
    nutrition_target_snapshot JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_meal_plans PRIMARY KEY (id),
    CONSTRAINT fk_meal_plans_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT uq_meal_plans_user_date UNIQUE (user_id, plan_date),
    CONSTRAINT chk_meal_plans_target_snapshot CHECK (jsonb_typeof(nutrition_target_snapshot) = 'object')
);

CREATE INDEX idx_meal_plans_user_date_desc ON meal_plans (user_id, plan_date DESC);

CREATE TABLE meals (
    id BIGINT GENERATED ALWAYS AS IDENTITY,
    meal_plan_id BIGINT NOT NULL,
    meal_type VARCHAR(20) NOT NULL,
    name VARCHAR(120),
    sort_order SMALLINT NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_meals PRIMARY KEY (id),
    CONSTRAINT fk_meals_plan FOREIGN KEY (meal_plan_id) REFERENCES meal_plans (id) ON DELETE CASCADE,
    CONSTRAINT uq_meals_plan_type_order UNIQUE (meal_plan_id, meal_type, sort_order),
    CONSTRAINT chk_meals_type CHECK (meal_type IN ('BREAKFAST', 'LUNCH', 'DINNER', 'SNACK')),
    CONSTRAINT chk_meals_sort_order CHECK (sort_order > 0)
);

CREATE TABLE meal_entries (
    id BIGINT GENERATED ALWAYS AS IDENTITY,
    meal_id BIGINT NOT NULL,
    food_id BIGINT NOT NULL,
    serving_multiplier NUMERIC(7,3) NOT NULL,
    input_amount NUMERIC(8,2),
    input_unit VARCHAR(10),
    food_name_snapshot VARCHAR(180) NOT NULL,
    serving_amount_snapshot NUMERIC(8,2) NOT NULL,
    serving_unit_snapshot VARCHAR(30) NOT NULL,
    calories_snapshot NUMERIC(8,2) NOT NULL,
    protein_g_snapshot NUMERIC(7,2) NOT NULL,
    carbs_g_snapshot NUMERIC(7,2) NOT NULL,
    fat_g_snapshot NUMERIC(7,2) NOT NULL,
    estimated_snapshot BOOLEAN NOT NULL,
    note VARCHAR(500),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_meal_entries PRIMARY KEY (id),
    CONSTRAINT fk_meal_entries_meal FOREIGN KEY (meal_id) REFERENCES meals (id) ON DELETE CASCADE,
    CONSTRAINT fk_meal_entries_food FOREIGN KEY (food_id) REFERENCES foods (id) ON DELETE RESTRICT,
    CONSTRAINT chk_meal_entries_multiplier CHECK (serving_multiplier > 0),
    CONSTRAINT chk_meal_entries_input CHECK (
        (input_amount IS NULL AND input_unit IS NULL)
        OR (input_amount > 0 AND input_unit = 'GRAM')
    ),
    CONSTRAINT chk_meal_entries_serving CHECK (serving_amount_snapshot > 0),
    CONSTRAINT chk_meal_entries_nutrition CHECK (
        calories_snapshot >= 0 AND protein_g_snapshot >= 0
        AND carbs_g_snapshot >= 0 AND fat_g_snapshot >= 0
    )
);

CREATE INDEX idx_meal_entries_meal ON meal_entries (meal_id, created_at, id);

CREATE TABLE meal_templates (
    id BIGINT GENERATED ALWAYS AS IDENTITY,
    user_id BIGINT NOT NULL,
    name VARCHAR(160) NOT NULL,
    description TEXT,
    source_meal_plan_id BIGINT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_meal_templates PRIMARY KEY (id),
    CONSTRAINT fk_meal_templates_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT fk_meal_templates_source_plan FOREIGN KEY (source_meal_plan_id) REFERENCES meal_plans (id) ON DELETE SET NULL
);

CREATE INDEX idx_meal_templates_user_updated ON meal_templates (user_id, updated_at DESC);

CREATE TABLE meal_template_items (
    id BIGINT GENERATED ALWAYS AS IDENTITY,
    meal_template_id BIGINT NOT NULL,
    food_id BIGINT NOT NULL,
    meal_type VARCHAR(20) NOT NULL,
    serving_multiplier NUMERIC(7,3) NOT NULL,
    food_name_snapshot VARCHAR(180) NOT NULL,
    serving_amount_snapshot NUMERIC(8,2) NOT NULL,
    serving_unit_snapshot VARCHAR(30) NOT NULL,
    sort_order SMALLINT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_meal_template_items PRIMARY KEY (id),
    CONSTRAINT fk_meal_template_items_template FOREIGN KEY (meal_template_id) REFERENCES meal_templates (id) ON DELETE CASCADE,
    CONSTRAINT fk_meal_template_items_food FOREIGN KEY (food_id) REFERENCES foods (id) ON DELETE RESTRICT,
    CONSTRAINT chk_meal_template_items_type CHECK (meal_type IN ('BREAKFAST', 'LUNCH', 'DINNER', 'SNACK')),
    CONSTRAINT chk_meal_template_items_multiplier CHECK (serving_multiplier > 0),
    CONSTRAINT chk_meal_template_items_serving CHECK (serving_amount_snapshot > 0),
    CONSTRAINT chk_meal_template_items_sort CHECK (sort_order > 0)
);

CREATE INDEX idx_meal_template_items_template ON meal_template_items (meal_template_id, meal_type, sort_order, id);
