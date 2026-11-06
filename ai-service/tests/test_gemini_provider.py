from __future__ import annotations

import json
from types import SimpleNamespace
from typing import Any

import pytest
from google.genai import errors

from app.models.schemas import GenerateRequest
from app.services.ai_provider import GeminiProvider


class FakeModels:
    def __init__(self, outcomes: list[Any]) -> None:
        self.outcomes = outcomes
        self.calls: list[dict[str, Any]] = []

    async def generate_content(self, **kwargs: Any) -> Any:
        self.calls.append(kwargs)
        outcome = self.outcomes.pop(0)
        if isinstance(outcome, Exception):
            raise outcome
        return SimpleNamespace(text=json.dumps(outcome, ensure_ascii=False), candidates=[])


def provider(outcomes: list[Any]) -> tuple[GeminiProvider, FakeModels]:
    models = FakeModels(outcomes)
    client = SimpleNamespace(aio=SimpleNamespace(models=models))
    return GeminiProvider(client=client), models


def request(request_type: str = "DAILY_RECOMMENDATION") -> GenerateRequest:
    return GenerateRequest.model_validate(
        {
            "schemaVersion": "1.0",
            "correlationId": "corr-gemini-001",
            "requestType": request_type,
            "promptVersion": "daily-v1",
            "renderedPrompt": "Coach rules.\nTarget date: 2026-11-04.",
            "context": {
                "contextVersion": "context-v1",
                "consentMode": "ENABLED",
                "data": {"health": {"tdee_kcal": 2450}},
            },
            "candidates": {
                "foods": [{"id": 205, "name": "Ức gà luộc"}],
                "exercises": [{"id": 118, "name": "Incline Dumbbell Press"}],
            },
            "messages": (
                [
                    {"role": "USER", "content": "Chào coach"},
                    {"role": "ASSISTANT", "content": "Chào bạn"},
                    {"role": "USER", "content": "Hôm nay ăn gì?"},
                ]
                if request_type == "CHAT"
                else []
            ),
            "allowedActions": [
                "NONE",
                "ADD_MEAL_ENTRY_PROPOSAL",
                "CREATE_WORKOUT_SCHEDULE_PROPOSAL",
            ],
        }
    )


def item(proposal: dict[str, Any]) -> dict[str, Any]:
    return {
        "type": "NUTRITION",
        "title": "Bổ sung đạm",
        "content": "Thêm một phần ức gà.",
        "reason": "Còn thiếu 40g protein.",
        "proposal": proposal,
        "sourceMetrics": [{"name": "proteinGap", "value": 40, "unit": "g"}],
    }


async def test_context_candidates_and_history_reach_gemini() -> None:
    gemini, models = provider([{"content": "Ăn thêm ức gà nhé.", "safetyLevel": "NORMAL"}])
    response = await gemini.generate(request("CHAT"))

    assert response.content == "Ăn thêm ức gà nhé."
    call = models.calls[0]
    system = call["config"].system_instruction
    assert "Coach rules." in system
    assert "2450" in system
    assert "Ức gà luộc" in system
    assert [c.role for c in call["contents"]] == ["user", "model", "user"]
    assert call["config"].response_mime_type == "application/json"


async def test_valid_meal_proposal_is_kept_with_backend_target_date() -> None:
    gemini, _ = provider(
        [{"items": [item({"allowedAction": "ADD_MEAL_ENTRY_PROPOSAL", "foodId": 205})]}]
    )
    response = await gemini.generate(request())

    proposal = response.items[0].proposal
    assert proposal == {
        "allowedAction": "ADD_MEAL_ENTRY_PROPOSAL",
        "foodId": 205,
        "mealType": "SNACK",
        "servingMultiplier": 1,
        "targetDate": "2026-11-04",
    }
    assert response.items[0].sourceMetrics == {"proteinGap": 40}


async def test_ids_outside_shortlist_are_downgraded_to_none() -> None:
    gemini, _ = provider(
        [
            {
                "items": [
                    item({"allowedAction": "ADD_MEAL_ENTRY_PROPOSAL", "foodId": 999}),
                    item(
                        {
                            "allowedAction": "CREATE_WORKOUT_SCHEDULE_PROPOSAL",
                            "exercises": [
                                {
                                    "exerciseId": 404,
                                    "targetSets": 3,
                                    "targetRepsMin": 8,
                                    "targetRepsMax": 12,
                                    "restSeconds": 60,
                                }
                            ],
                        }
                    ),
                ]
            }
        ]
    )
    response = await gemini.generate(request())

    assert [i.proposal for i in response.items] == [{"allowedAction": "NONE"}] * 2


async def test_rate_limit_is_retried() -> None:
    gemini, models = provider(
        [
            errors.ClientError(429, {"error": {"message": "quota"}}),
            {"content": "OK", "safetyLevel": "NORMAL"},
        ]
    )
    response = await gemini.generate(request("CHAT"))

    assert response.content == "OK"
    assert len(models.calls) == 2


async def test_bad_request_is_not_retried() -> None:
    gemini, models = provider([errors.ClientError(400, {"error": {"message": "bad"}})])
    with pytest.raises(errors.ClientError):
        await gemini.generate(request("CHAT"))
    assert len(models.calls) == 1


async def test_invalid_schema_output_raises() -> None:
    gemini, _ = provider([{"unexpected": True}])
    with pytest.raises(ValueError):
        await gemini.generate(request("CHAT"))


async def test_only_first_three_recommendations_are_kept() -> None:
    gemini, _ = provider([{"items": [item({"allowedAction": "NONE"})] * 5}])
    response = await gemini.generate(request())
    assert len(response.items) == 3


def plan_request(request_type: str) -> GenerateRequest:
    body = request(request_type).model_dump()
    body["promptVersion"] = "plan-v1"
    body["allowedActions"] = []
    return GenerateRequest.model_validate(body)


async def test_workout_plan_keeps_only_shortlisted_unique_exercises() -> None:
    exercise = {
        "targetSets": 4,
        "targetRepsMin": 8,
        "targetRepsMax": 12,
        "restSeconds": 90,
        "targetWeightKg": 20,
        "coachingTip": "Hạ tạ chậm.",
    }
    gemini, models = provider(
        [
            {
                "planTitle": "Ngực",
                "rationale": "Compound trước.",
                "exercises": [
                    {"exerciseId": 118, **exercise},
                    {"exerciseId": 118, **exercise},
                    {"exerciseId": 999, **exercise},
                ],
            }
        ]
    )
    response = await gemini.generate(plan_request("WORKOUT_PLAN"))

    assert [ex["exerciseId"] for ex in response.plan["exercises"]] == [118]
    assert response.plan["planTitle"] == "Ngực"
    assert "CANDIDATES.exercises" in models.calls[0]["config"].system_instruction


async def test_meal_plan_drops_unknown_foods_and_empty_meals() -> None:
    gemini, _ = provider(
        [
            {
                "rationale": "Đủ đạm.",
                "meals": [
                    {
                        "mealType": "LUNCH",
                        "dishName": "Cơm gà",
                        "coachingReason": "Nhiều đạm.",
                        "items": [
                            {"foodId": 205, "servingMultiplier": 1.5},
                            {"foodId": 999, "servingMultiplier": 1},
                        ],
                    },
                    {
                        "mealType": "DINNER",
                        "dishName": "Lạ",
                        "coachingReason": "-",
                        "items": [{"foodId": 404, "servingMultiplier": 1}],
                    },
                ],
            }
        ]
    )
    response = await gemini.generate(plan_request("MEAL_PLAN"))

    assert response.plan["meals"] == [
        {
            "mealType": "LUNCH",
            "dishName": "Cơm gà",
            "coachingReason": "Nhiều đạm.",
            "items": [{"foodId": 205, "servingMultiplier": 1.5}],
        }
    ]
