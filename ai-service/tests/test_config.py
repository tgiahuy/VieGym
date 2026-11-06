import pytest
from pydantic import ValidationError

from app.core.config import Settings


def test_production_rejects_mock_provider() -> None:
    with pytest.raises(ValidationError, match="AI_PROVIDER=mock"):
        Settings(
            APP_ENV="production",
            INTERNAL_SERVICE_TOKEN="production-token-that-is-not-a-dev-default",
            AI_PROVIDER="mock",
            AI_MODEL="mock",
        )


def test_production_accepts_explicit_gemini_configuration() -> None:
    settings = Settings(
        APP_ENV="production",
        INTERNAL_SERVICE_TOKEN="production-token-that-is-not-a-dev-default",
        AI_PROVIDER="gemini",
        AI_MODEL="gemini-3.6-flash",
        AI_PROVIDER_API_KEY="test-production-key",
    )
    assert settings.AI_PROVIDER == "gemini"


def test_openai_provider_is_no_longer_accepted() -> None:
    with pytest.raises(ValidationError):
        Settings(AI_PROVIDER="openai")


def test_blank_temperature_uses_model_default() -> None:
    assert Settings(AI_TEMPERATURE="").AI_TEMPERATURE is None
