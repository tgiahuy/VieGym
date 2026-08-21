from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    PROJECT_NAME: str = "VieGym AI Service"
    API_V1_STR: str = "/api/v1"
    INTERNAL_API_V1_STR: str = "/internal/v1"
    INTERNAL_SERVICE_TOKEN: str = "dev-secret-token"  # Should be overridden in prod via env vars

    class Config:
        env_file = ".env"

settings = Settings()
