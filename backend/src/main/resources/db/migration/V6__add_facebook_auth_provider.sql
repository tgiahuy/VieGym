ALTER TABLE users DROP CONSTRAINT IF EXISTS chk_users_auth_provider;
ALTER TABLE users ADD CONSTRAINT chk_users_auth_provider
    CHECK (auth_provider IN ('LOCAL', 'GOOGLE', 'FACEBOOK'));
