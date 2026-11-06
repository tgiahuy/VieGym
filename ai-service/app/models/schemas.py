from __future__ import annotations

from enum import StrEnum
from typing import Any, Literal

from pydantic import BaseModel, Field, model_validator


class RequestType(StrEnum):
    CHAT = "CHAT"
    DAILY_RECOMMENDATION = "DAILY_RECOMMENDATION"
    WORKOUT_PLAN = "WORKOUT_PLAN"
    MEAL_PLAN = "MEAL_PLAN"


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


# --- Gemini structured output -------------------------------------------------------------
# Fully typed (no free-form dicts) so the model cannot invent keys. Gemini ignores
# minLength/maxLength in schemas, so responses are validated again with these models.


class ProposalAction(StrEnum):
    NONE = "NONE"
    ADD_MEAL_ENTRY_PROPOSAL = "ADD_MEAL_ENTRY_PROPOSAL"
    CREATE_WORKOUT_SCHEDULE_PROPOSAL = "CREATE_WORKOUT_SCHEDULE_PROPOSAL"


class WorkoutExerciseProposal(BaseModel):
    exerciseId: int
    targetSets: int = Field(ge=1, le=10)
    targetRepsMin: int = Field(ge=1, le=50)
    targetRepsMax: int = Field(ge=1, le=50)
    restSeconds: int = Field(ge=0, le=600)


class ProposalOutput(BaseModel):
    allowedAction: ProposalAction = ProposalAction.NONE
    title: str | None = Field(default=None, max_length=200)
    foodId: int | None = None
    mealType: Literal["BREAKFAST", "LUNCH", "DINNER", "SNACK"] | None = None
    servingMultiplier: float | None = Field(default=None, ge=0.25, le=3)
    exercises: list[WorkoutExerciseProposal] | None = Field(default=None, max_length=12)


class MetricOutput(BaseModel):
    name: str = Field(min_length=1, max_length=60)
    value: float
    unit: str = Field(default="", max_length=20)


class RecommendationOutput(BaseModel):
    type: Literal["WORKOUT", "NUTRITION", "HEALTH", "GENERAL_ADVICE"]
    title: str = Field(min_length=1, max_length=200)
    content: str = Field(min_length=1, max_length=2000)
    reason: str = Field(min_length=1, max_length=1000)
    priority: Literal["LOW", "MEDIUM", "HIGH"] = "MEDIUM"
    safetyLevel: SafetyLevel = SafetyLevel.NORMAL
    proposal: ProposalOutput = Field(default_factory=ProposalOutput)
    sourceMetrics: list[MetricOutput] = Field(default_factory=list, max_length=5)


class ChatOutput(BaseModel):
    content: str = Field(min_length=1, max_length=4000)
    safetyLevel: SafetyLevel = SafetyLevel.NORMAL


class DailyRecommendationOutput(BaseModel):
    # No max_length here: Gemini rejects maxItems on this list combined with the nested item
    # schema (400 INVALID_ARGUMENT). The provider keeps only the first 3 items instead.
    items: list[RecommendationOutput] = Field(default_factory=list)


class GenerateResponse(BaseModel):
    schemaVersion: Literal["1.0"] = "1.0"
    correlationId: str
    content: str | None = None
    safetyLevel: SafetyLevel = SafetyLevel.NORMAL
    items: list[RecommendationItem] = Field(default_factory=list, max_length=3)
    # WORKOUT_PLAN / MEAL_PLAN only: the sanitized plan; the backend validates it again.
    plan: dict[str, Any] | None = None
    providerMetadata: dict[str, Any] = Field(default_factory=dict)


# Plan outputs carry no numeric bounds on purpose: the backend clamps sets/reps/rest and
# serving multipliers, so a slightly out-of-range value adjusts instead of failing the call.
# Outer lists also have no maxItems (Gemini rejects maxItems on nested object lists);
# the provider truncates them instead.


class WorkoutPlanExerciseOutput(BaseModel):
    exerciseId: int
    targetSets: int
    targetRepsMin: int
    targetRepsMax: int
    restSeconds: int
    targetWeightKg: float | None = None
    coachingTip: str | None = None


class WorkoutPlanOutput(BaseModel):
    planTitle: str
    rationale: str
    safetyLevel: SafetyLevel = SafetyLevel.NORMAL
    exercises: list[WorkoutPlanExerciseOutput] = Field(default_factory=list)


class MealItemOutput(BaseModel):
    foodId: int
    servingMultiplier: float


class MealOutput(BaseModel):
    mealType: Literal["BREAKFAST", "LUNCH", "DINNER", "SNACK"]
    dishName: str
    coachingReason: str
    items: list[MealItemOutput] = Field(default_factory=list)


class MealPlanOutput(BaseModel):
    rationale: str
    safetyLevel: SafetyLevel = SafetyLevel.NORMAL
    meals: list[MealOutput] = Field(default_factory=list)
