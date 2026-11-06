from typing import Literal

from pydantic import field_validator, model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    PROJECT_NAME: str = "VieGym AI Service"
    INTERNAL_API_V1_STR: str = "/internal/v1"
    APP_ENV: Literal["local", "test", "staging", "production", "prod"] = "local"
    INTERNAL_SERVICE_TOKEN: str = "local-development-token"
    LOG_LEVEL: str = "INFO"
    AI_PROVIDER: Literal["mock", "gemini"] = "mock"
    AI_MODEL: str = "gemini-3.6-flash"
    AI_PROVIDER_API_KEY: str = ""
    AI_CONNECT_TIMEOUT_SECONDS: float = 3.0
    # Total budget for one /generate call, retries included. Keep it below the backend
    # read timeout (AI_READ_TIMEOUT_MS, 26s in compose) so the backend never times out first.
    AI_READ_TIMEOUT_SECONDS: float = 24.0
    AI_MAX_ATTEMPTS: int = 2
    AI_MAX_CONTEXT_BYTES: int = 32768
    AI_MAX_OUTPUT_TOKENS: int = 2048
    # None keeps the model default (recommended for Gemini 3 models).
    AI_TEMPERATURE: float | None = None
    AI_THINKING_LEVEL: Literal["", "MINIMAL", "LOW", "MEDIUM", "HIGH"] = "MINIMAL"

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    @field_validator("AI_TEMPERATURE", mode="before")
    @classmethod
    def blank_temperature_is_default(cls, value: object) -> object:
        return None if value == "" else value

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
