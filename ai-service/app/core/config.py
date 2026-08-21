from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    PROJECT_NAME: str = "VieGym AI Service"
    API_V1_STR: str = "/api/v1"
    INTERNAL_API_V1_STR: str = "/internal/v1"
    INTERNAL_SERVICE_TOKEN: str = "dev-secret-token"  # Should be overridden in prod via env vars

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")


settings = Settings()
