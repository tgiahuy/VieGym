from __future__ import annotations

from enum import StrEnum
from typing import Any, Literal

from pydantic import BaseModel, Field, model_validator


class RequestType(StrEnum):
    CHAT = "CHAT"
    DAILY_RECOMMENDATION = "DAILY_RECOMMENDATION"


class SafetyLevel(StrEnum):
    NORMAL = "NORMAL"
    CAUTION = "CAUTION"
    BLOCKED = "BLOCKED"


class Message(BaseModel):
    role: Literal["USER", "ASSISTANT"]
    content: str = Field(min_length=1, max_length=4000)


class ContextEnvelope(BaseModel):
    contextVersion: Literal["context-v1"] = "context-v1"
    consentMode: Literal["ENABLED", "DISABLED"]
    data: dict[str, Any] = Field(default_factory=dict)

    @model_validator(mode="after")
    def disabled_has_no_personal_data(self) -> ContextEnvelope:
        if self.consentMode == "DISABLED" and self.data:
            raise ValueError("disabled consent must not include personal context")
        return self


class GenerateRequest(BaseModel):
    schemaVersion: Literal["1.0"]
    correlationId: str = Field(min_length=1, max_length=100)
    requestType: RequestType
    promptVersion: str = Field(min_length=1, max_length=40)
    renderedPrompt: str = Field(min_length=1, max_length=8000)
    context: ContextEnvelope
    candidates: dict[str, Any] = Field(default_factory=dict)
    messages: list[Message] = Field(default_factory=list, max_length=30)
    allowedActions: list[str] = Field(default_factory=list, max_length=10)


class RecommendationItem(BaseModel):
    type: Literal["WORKOUT", "NUTRITION", "HEALTH", "GENERAL_ADVICE"]
    title: str = Field(min_length=1, max_length=200)
    content: str = Field(min_length=1, max_length=2000)
    reason: str = Field(min_length=1, max_length=1000)
    priority: Literal["LOW", "MEDIUM", "HIGH"] = "MEDIUM"
    safetyLevel: SafetyLevel = SafetyLevel.NORMAL
    proposal: dict[str, Any] = Field(default_factory=lambda: {"allowedAction": "NONE"})
    sourceMetrics: dict[str, Any] = Field(default_factory=dict)


class ProviderStructuredOutput(BaseModel):
    content: str | None = Field(default=None, max_length=4000)
    safetyLevel: SafetyLevel = SafetyLevel.NORMAL
    items: list[RecommendationItem] = Field(default_factory=list, max_length=3)


class GenerateResponse(BaseModel):
    schemaVersion: Literal["1.0"] = "1.0"
    correlationId: str
    content: str | None = None
    safetyLevel: SafetyLevel = SafetyLevel.NORMAL
    items: list[RecommendationItem] = Field(default_factory=list, max_length=3)
    providerMetadata: dict[str, Any] = Field(default_factory=dict)
