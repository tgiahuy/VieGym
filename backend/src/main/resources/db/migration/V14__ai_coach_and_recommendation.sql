CREATE TABLE ai_consents (
    user_id BIGINT PRIMARY KEY REFERENCES users (id) ON DELETE CASCADE,
    mode VARCHAR(20) NOT NULL DEFAULT 'DISABLED',
    consent_version VARCHAR(20) NOT NULL DEFAULT 'v1.0',
    accepted_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_ai_consents_mode CHECK (mode IN ('ENABLED', 'DISABLED'))
);

CREATE TABLE ai_consent_history (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    previous_mode VARCHAR(20),
    new_mode VARCHAR(20) NOT NULL,
    consent_version VARCHAR(20) NOT NULL,
    source VARCHAR(30) NOT NULL,
    changed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_ai_consent_history_mode CHECK (new_mode IN ('ENABLED', 'DISABLED'))
);
CREATE INDEX idx_ai_consent_history_user_changed
    ON ai_consent_history (user_id, changed_at DESC);

CREATE TABLE ai_conversations (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    title VARCHAR(160) NOT NULL,
    requested_mode VARCHAR(30) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    last_message_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_ai_conversations_mode
        CHECK (requested_mode IN ('GENERAL_KNOWLEDGE', 'PERSONALIZED')),
    CONSTRAINT chk_ai_conversations_status CHECK (status IN ('ACTIVE', 'ARCHIVED'))
);
CREATE INDEX idx_ai_conversations_user_last_message
    ON ai_conversations (user_id, last_message_at DESC NULLS LAST, id DESC);

CREATE TABLE ai_messages (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    conversation_id BIGINT NOT NULL REFERENCES ai_conversations (id) ON DELETE CASCADE,
    role VARCHAR(20) NOT NULL,
    content TEXT NOT NULL,
    effective_mode VARCHAR(30) NOT NULL,
    safety_level VARCHAR(20) NOT NULL DEFAULT 'NORMAL',
    disclaimer VARCHAR(500),
    correlation_id VARCHAR(100),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_ai_messages_role CHECK (role IN ('USER', 'ASSISTANT')),
    CONSTRAINT chk_ai_messages_mode
        CHECK (effective_mode IN ('GENERAL_KNOWLEDGE', 'PERSONALIZED')),
    CONSTRAINT chk_ai_messages_safety CHECK (safety_level IN ('NORMAL', 'CAUTION')),
    CONSTRAINT chk_ai_messages_content_size CHECK (char_length(content) BETWEEN 1 AND 4000)
);
CREATE INDEX idx_ai_messages_conversation_created
    ON ai_messages (conversation_id, created_at, id);

CREATE TABLE ai_context_snapshots (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    purpose VARCHAR(40) NOT NULL,
    context_version VARCHAR(30) NOT NULL,
    snapshot JSONB NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_ai_context_snapshot_object CHECK (jsonb_typeof(snapshot) = 'object')
);
CREATE INDEX idx_ai_context_snapshots_retention ON ai_context_snapshots (expires_at);

CREATE TABLE ai_requests (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    request_type VARCHAR(40) NOT NULL,
    correlation_id VARCHAR(100) NOT NULL,
    prompt_version VARCHAR(30) NOT NULL,
    model_name VARCHAR(100),
    status VARCHAR(20) NOT NULL,
    failure_code VARCHAR(80),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMPTZ,
    CONSTRAINT uq_ai_requests_correlation UNIQUE (correlation_id),
    CONSTRAINT chk_ai_requests_status CHECK (status IN ('STARTED', 'SUCCEEDED', 'FAILED', 'BLOCKED'))
);

CREATE TABLE ai_validation_events (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ai_request_id BIGINT NOT NULL REFERENCES ai_requests (id) ON DELETE CASCADE,
    validation_type VARCHAR(40) NOT NULL,
    result VARCHAR(20) NOT NULL,
    reason_code VARCHAR(80),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_ai_validation_result CHECK (result IN ('PASSED', 'REJECTED'))
);

CREATE TABLE ai_generation_batches (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    target_date DATE NOT NULL,
    generation_no SMALLINT NOT NULL,
    idempotency_key VARCHAR(100) NOT NULL,
    request_hash VARCHAR(64) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'STARTED',
    correlation_id VARCHAR(100) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMPTZ,
    CONSTRAINT uq_ai_generation_user_date_no UNIQUE (user_id, target_date, generation_no),
    CONSTRAINT uq_ai_generation_user_key UNIQUE (user_id, idempotency_key),
    CONSTRAINT chk_ai_generation_no CHECK (generation_no BETWEEN 1 AND 3),
    CONSTRAINT chk_ai_generation_status CHECK (status IN ('STARTED', 'SUCCEEDED', 'FAILED', 'BLOCKED'))
);

CREATE TABLE ai_recommendations (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    generation_batch_id BIGINT NOT NULL REFERENCES ai_generation_batches (id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    recommendation_date DATE NOT NULL,
    type VARCHAR(30) NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    reason VARCHAR(1000) NOT NULL,
    priority VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    safety_level VARCHAR(20) NOT NULL,
    allowed_action VARCHAR(50) NOT NULL,
    action_preview JSONB NOT NULL DEFAULT '{}',
    source_metrics JSONB NOT NULL DEFAULT '{}',
    version INTEGER NOT NULL DEFAULT 0,
    feedback VARCHAR(500),
    expires_at TIMESTAMPTZ NOT NULL,
    applied_at TIMESTAMPTZ,
    dismissed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_ai_recommendation_status
        CHECK (status IN ('PENDING', 'APPLIED', 'DISMISSED', 'EXPIRED')),
    CONSTRAINT chk_ai_recommendation_safety CHECK (safety_level IN ('NORMAL', 'CAUTION')),
    CONSTRAINT chk_ai_recommendation_priority CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH')),
    CONSTRAINT chk_ai_recommendation_preview CHECK (jsonb_typeof(action_preview) = 'object'),
    CONSTRAINT chk_ai_recommendation_metrics CHECK (jsonb_typeof(source_metrics) = 'object')
);
CREATE INDEX idx_ai_recommendations_user_date
    ON ai_recommendations (user_id, recommendation_date, status, created_at DESC);

CREATE TABLE ai_recommendation_actions (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    recommendation_id BIGINT NOT NULL REFERENCES ai_recommendations (id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    action_type VARCHAR(20) NOT NULL,
    idempotency_key VARCHAR(100) NOT NULL,
    request_hash VARCHAR(64) NOT NULL,
    result JSONB NOT NULL DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_ai_recommendation_action_key UNIQUE (user_id, idempotency_key),
    CONSTRAINT chk_ai_recommendation_action_type CHECK (action_type IN ('APPLY', 'DISMISS')),
    CONSTRAINT chk_ai_recommendation_action_result CHECK (jsonb_typeof(result) = 'object')
);

CREATE TABLE audit_logs (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    actor_user_id BIGINT REFERENCES users (id) ON DELETE SET NULL,
    action VARCHAR(80) NOT NULL,
    target_type VARCHAR(50) NOT NULL,
    target_id VARCHAR(100),
    result VARCHAR(20) NOT NULL,
    correlation_id VARCHAR(100),
    metadata JSONB NOT NULL DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_audit_metadata CHECK (jsonb_typeof(metadata) = 'object')
);
CREATE INDEX idx_audit_logs_actor_created ON audit_logs (actor_user_id, created_at DESC);
