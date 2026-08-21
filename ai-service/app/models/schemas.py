"""
Pydantic request/response contracts for the internal AI generate endpoint.

Contract version: rules-v1 (see ADR-005)
Path: POST /internal/v1/ai/generate

This module defines the canonical data shapes exchanged between the Spring Boot
backend and the FastAPI AI service.  The backend is responsible for:
  - building the prompt from rules-v1 templates
  - providing a minimal context snapshot (field whitelist per ADR-008)
  - supplying candidate shortlist and preference whitelist

The AI service only executes the prompt and parses the structured response;
it does NOT access PostgreSQL, object storage, or any user credential.
"""

from __future__ import annotations

from enum import StrEnum
from typing import Annotated

from pydantic import BaseModel, Field

# ── Enums ────────────────────────────────────────────────────────────────────


class GenerateMode(StrEnum):
    """Conversation / generation mode."""

    GENERAL = "GENERAL"
    """General knowledge mode — no personal user data is sent."""

    PERSONALIZED = "PERSONALIZED"
    """Personalized mode — backend sends allowed context snapshot."""


class RecommendationType(StrEnum):
    WORKOUT = "WORKOUT"
    NUTRITION = "NUTRITION"
    HEALTH = "HEALTH"
    GENERAL_ADVICE = "GENERAL_ADVICE"


# ── Context sub-models ────────────────────────────────────────────────────────


class HealthMetricsContext(BaseModel):
    """Minimal health snapshot — only fields on ADR-008 whitelist."""

    bmi: float | None = Field(None, description="Body Mass Index")
    bmr: float | None = Field(None, description="Basal Metabolic Rate (kcal/day)")
    tdee: float | None = Field(None, description="Total Daily Energy Expenditure (kcal/day)")
    goal: str | None = Field(None, description="User's fitness goal, e.g. LOSE_WEIGHT")


class WorkoutContext(BaseModel):
    """Recent workout summary for recommendation context."""

    recent_sessions: int = Field(0, ge=0, description="Number of sessions in the last 7 days")
    completion_rate: float | None = Field(
        None, ge=0, le=1, description="Schedule completion rate 0–1"
    )
    equipment_ids: list[str] = Field(default_factory=list, description="IDs of available equipment")


class NutritionContext(BaseModel):
    """Nutrition summary for recommendation context."""

    daily_calories_target: float | None = Field(None, gt=0)
    average_calories_last7d: float | None = Field(None, ge=0)


class UserContext(BaseModel):
    """
    Allowed context snapshot sent by the backend.
    Must contain only fields on the ADR-008 whitelist.
    The backend validates this before forwarding to AI service.
    """

    user_id: Annotated[str, Field(min_length=1, description="Opaque user identifier")]
    health: HealthMetricsContext = Field(default_factory=HealthMetricsContext)
    workout: WorkoutContext = Field(default_factory=WorkoutContext)
    nutrition: NutritionContext = Field(default_factory=NutritionContext)


# ── Request / Response ────────────────────────────────────────────────────────


class GenerateRequest(BaseModel):
    """
    Request sent from Spring Boot → FastAPI AI service.

    The `prompt` is rendered by the backend using rules-v1 templates.
    The `context` is included only when `mode == PERSONALIZED` and
    the user's AI consent is ON.
    """

    mode: GenerateMode = Field(..., description="GENERAL or PERSONALIZED")
    context: UserContext = Field(..., description="Minimal user context snapshot")
    prompt: Annotated[str, Field(min_length=1, max_length=8000)]
    model_version: str = Field("rules-v1", description="Prompt/rules version tag")
    correlation_id: str | None = Field(None, description="Request correlation ID from backend")


class RecommendationItem(BaseModel):
    """A single AI-generated recommendation item."""

    title: Annotated[str, Field(min_length=1, max_length=200)]
    description: Annotated[str, Field(min_length=1, max_length=2000)]
    type: RecommendationType
    target_date: str | None = Field(
        None,
        description="ISO 8601 date in user's IANA timezone (YYYY-MM-DD)",
        pattern=r"^\d{4}-\d{2}-\d{2}$",
    )
    metadata: dict[str, str] = Field(
        default_factory=dict,
        description="Domain-specific extra fields (e.g. exercise_id, food_id)",
    )


class GenerateResponse(BaseModel):
    """
    Response from FastAPI AI service → Spring Boot backend.

    The backend validates schema/safety/business rules before persisting.
    """

    recommendations: Annotated[
        list[RecommendationItem],
        Field(min_length=0, max_length=3, description="1–3 items on success"),
    ]
    status: str = Field("SUCCESS", description="SUCCESS or FALLBACK")
    message: str | None = Field(None, description="Human-readable status detail")
    model_version: str = Field("rules-v1")
