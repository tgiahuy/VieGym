ALTER TABLE refresh_tokens
    ADD COLUMN audience VARCHAR(30) NOT NULL DEFAULT 'MOBILE_USER',
    ADD COLUMN csrf_secret_hash VARCHAR(255);

ALTER TABLE refresh_tokens
    ADD CONSTRAINT chk_refresh_tokens_audience
        CHECK (audience IN ('MOBILE_USER', 'ADMIN_WEB')),
    ADD CONSTRAINT chk_refresh_tokens_admin_csrf
        CHECK (audience <> 'ADMIN_WEB' OR csrf_secret_hash IS NOT NULL);

DROP INDEX idx_refresh_tokens_user_status;

CREATE INDEX idx_refresh_tokens_user_audience_status
    ON refresh_tokens (user_id, audience, status, expires_at);

