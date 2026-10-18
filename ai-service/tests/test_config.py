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


def test_production_accepts_explicit_openai_configuration() -> None:
    settings = Settings(
        APP_ENV="production",
        INTERNAL_SERVICE_TOKEN="production-token-that-is-not-a-dev-default",
        AI_PROVIDER="openai",
        AI_MODEL="gpt-production",
        AI_PROVIDER_API_KEY="test-production-key",
    )
    assert settings.AI_PROVIDER == "openai"
