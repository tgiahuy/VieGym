ALTER TABLE exercises ADD COLUMN version BIGINT NOT NULL DEFAULT 0;
ALTER TABLE foods ADD COLUMN version BIGINT NOT NULL DEFAULT 0;

CREATE TABLE media_objects (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    owner_type VARCHAR(30) NOT NULL,
    owner_id BIGINT NOT NULL,
    media_type VARCHAR(20) NOT NULL,
    role VARCHAR(30) NOT NULL,
    sort_order SMALLINT NOT NULL DEFAULT 1,
    object_key VARCHAR(500) NOT NULL UNIQUE,
    original_file_name VARCHAR(255) NOT NULL,
    declared_mime_type VARCHAR(100) NOT NULL,
    mime_type VARCHAR(100),
    expected_size_bytes BIGINT NOT NULL,
    file_size_bytes BIGINT,
    visibility VARCHAR(20) NOT NULL DEFAULT 'PUBLIC',
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING_UPLOAD',
    upload_token_hash VARCHAR(64) NOT NULL,
    upload_expires_at TIMESTAMPTZ NOT NULL,
    uploaded_by BIGINT NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    verified_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_media_owner CHECK (owner_type IN ('EXERCISE', 'FOOD', 'USER_PROFILE')),
    CONSTRAINT chk_media_type CHECK (media_type IN ('IMAGE', 'VIDEO')),
    CONSTRAINT chk_media_role CHECK (role IN ('THUMBNAIL', 'PRIMARY_VIDEO', 'GALLERY', 'AVATAR')),
    CONSTRAINT chk_media_sort CHECK (sort_order > 0),
    CONSTRAINT chk_media_expected_size CHECK (expected_size_bytes > 0),
    CONSTRAINT chk_media_visibility CHECK (visibility IN ('PUBLIC', 'PRIVATE')),
    CONSTRAINT chk_media_status CHECK (status IN ('PENDING_UPLOAD', 'READY', 'FAILED', 'ORPHANED', 'DELETED'))
);
CREATE INDEX idx_media_owner_status ON media_objects(owner_type, owner_id, status);
CREATE INDEX idx_media_pending_expiry ON media_objects(status, upload_expires_at);
CREATE UNIQUE INDEX uq_media_owner_slot ON media_objects(owner_type, owner_id, role, sort_order)
    WHERE status NOT IN ('DELETED', 'ORPHANED', 'FAILED');

CREATE TABLE media_upload_payloads (
    media_id BIGINT PRIMARY KEY REFERENCES media_objects(id) ON DELETE CASCADE,
    payload BYTEA NOT NULL,
    received_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE notifications (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(40) NOT NULL,
    title VARCHAR(180) NOT NULL,
    content VARCHAR(1000) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'SCHEDULED',
    scheduled_at TIMESTAMPTZ NOT NULL,
    sent_at TIMESTAMPTZ,
    read_at TIMESTAMPTZ,
    source_type VARCHAR(50),
    source_id VARCHAR(100),
    deep_link VARCHAR(500),
    idempotency_key VARCHAR(150) NOT NULL,
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_notification_type CHECK (type IN ('WORKOUT_REMINDER', 'MEAL_REMINDER', 'WEIGHT_REMINDER', 'AI_RECOMMENDATION', 'WEEKLY_REVIEW', 'SYSTEM')),
    CONSTRAINT chk_notification_status CHECK (status IN ('SCHEDULED', 'SENT', 'READ', 'FAILED', 'CANCELLED')),
    CONSTRAINT uq_notification_idempotency UNIQUE (user_id, idempotency_key)
);
CREATE INDEX idx_notifications_owner_created ON notifications(user_id, deleted_at, created_at DESC, id DESC);
CREATE INDEX idx_notifications_owner_unread ON notifications(user_id, status) WHERE deleted_at IS NULL;
CREATE INDEX idx_notifications_scheduled ON notifications(status, scheduled_at) WHERE status = 'SCHEDULED';

CREATE TABLE notification_preferences (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    workout_enabled BOOLEAN NOT NULL DEFAULT true,
    meal_enabled BOOLEAN NOT NULL DEFAULT true,
    weight_enabled BOOLEAN NOT NULL DEFAULT true,
    recommendation_enabled BOOLEAN NOT NULL DEFAULT false,
    weekly_review_enabled BOOLEAN NOT NULL DEFAULT false,
    quiet_hours_start TIME,
    quiet_hours_end TIME,
    timezone VARCHAR(80) NOT NULL DEFAULT 'Asia/Ho_Chi_Minh',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_notification_quiet_hours CHECK (
        (quiet_hours_start IS NULL AND quiet_hours_end IS NULL)
        OR (quiet_hours_start IS NOT NULL AND quiet_hours_end IS NOT NULL)
    )
);

ALTER TABLE audit_logs ADD COLUMN actor_role VARCHAR(20);
ALTER TABLE audit_logs ADD COLUMN ip_address VARCHAR(64);
ALTER TABLE audit_logs ADD COLUMN user_agent VARCHAR(255);
CREATE INDEX idx_audit_logs_filter ON audit_logs(target_type, action, result, created_at DESC);
