from typing import Literal

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    PROJECT_NAME: str = "VieGym AI Service"
    INTERNAL_API_V1_STR: str = "/internal/v1"
    INTERNAL_SERVICE_TOKEN: str = "dev-secret-token"
    AI_PROVIDER: Literal["mock", "openai"] = "mock"
    AI_MODEL: str = "gpt-5.6-luna"
    AI_PROVIDER_API_KEY: str = ""
    AI_CONNECT_TIMEOUT_SECONDS: float = 3.0
    AI_READ_TIMEOUT_SECONDS: float = 20.0
    AI_MAX_ATTEMPTS: int = 2
    AI_MAX_CONTEXT_BYTES: int = 32768
    AI_MAX_OUTPUT_TOKENS: int = 1024

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")


settings = Settings()
