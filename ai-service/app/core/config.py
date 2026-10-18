from typing import Literal

from pydantic import model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    PROJECT_NAME: str = "VieGym AI Service"
    INTERNAL_API_V1_STR: str = "/internal/v1"
    APP_ENV: Literal["local", "test", "staging", "production", "prod"] = "local"
    INTERNAL_SERVICE_TOKEN: str = "local-development-token"
    AI_PROVIDER: Literal["mock", "openai"] = "mock"
    AI_MODEL: str = "gpt-5.6-luna"
    AI_PROVIDER_API_KEY: str = ""
    AI_CONNECT_TIMEOUT_SECONDS: float = 3.0
    AI_READ_TIMEOUT_SECONDS: float = 20.0
    AI_MAX_ATTEMPTS: int = 2
    AI_MAX_CONTEXT_BYTES: int = 32768
    AI_MAX_OUTPUT_TOKENS: int = 1024

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    @model_validator(mode="after")
    def validate_deployment_secrets(self) -> "Settings":
        if self.APP_ENV not in {"production", "prod"}:
            return self
        errors: list[str] = []
        if self.INTERNAL_SERVICE_TOKEN in {"", "dev-secret-token", "local-development-token"}:
            errors.append("INTERNAL_SERVICE_TOKEN must be a production secret")
        if self.AI_PROVIDER == "mock":
            errors.append("AI_PROVIDER=mock is not allowed in production")
        if not self.AI_MODEL or self.AI_MODEL == "mock":
            errors.append("AI_MODEL must name the production model")
        if not self.AI_PROVIDER_API_KEY:
            errors.append("AI_PROVIDER_API_KEY is required in production")
        if errors:
            raise ValueError("; ".join(errors))
        return self


settings = Settings()
