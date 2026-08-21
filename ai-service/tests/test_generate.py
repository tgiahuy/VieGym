"""
Tests for POST /internal/v1/ai/generate endpoint (M1-19, M1-20).

Covers:
  - Internal token guard (403 when missing/wrong token)
  - GENERAL mode returns valid schema
  - PERSONALIZED mode returns context-aware recommendations
  - Response always has 1–3 recommendations
"""

from __future__ import annotations

from fastapi.testclient import TestClient

from app.core.config import settings
from app.main import app

client = TestClient(app)

VALID_TOKEN = settings.INTERNAL_SERVICE_TOKEN
GENERATE_URL = "/internal/v1/ai/generate"

GENERAL_PAYLOAD = {
    "mode": "GENERAL",
    "context": {
        "user_id": "test-user-001",
        "health": {},
        "workout": {},
        "nutrition": {},
    },
    "prompt": "Give me a general fitness recommendation.",
    "model_version": "rules-v1",
}

PERSONALIZED_PAYLOAD = {
    "mode": "PERSONALIZED",
    "context": {
        "user_id": "test-user-002",
        "health": {"bmi": 25.1, "tdee": 2100.0, "goal": "LOSE_WEIGHT"},
        "workout": {"recent_sessions": 1, "completion_rate": 0.5, "equipment_ids": []},
        "nutrition": {"daily_calories_target": 1800.0, "average_calories_last7d": 2200.0},
    },
    "prompt": "Generate a personalized recommendation.",
    "model_version": "rules-v1",
    "correlation_id": "corr-abc-123",
}


# ── Auth guard ─────────────────────────────────────────────────────────────────


def test_generate_no_token_returns_403() -> None:
    response = client.post(GENERATE_URL, json=GENERAL_PAYLOAD)
    assert response.status_code == 403


def test_generate_wrong_token_returns_403() -> None:
    response = client.post(
        GENERATE_URL,
        json=GENERAL_PAYLOAD,
        headers={"X-Internal-Token": "wrong-token"},
    )
    assert response.status_code == 403


# ── GENERAL mode ───────────────────────────────────────────────────────────────


def test_generate_general_mode_returns_200() -> None:
    response = client.post(
        GENERATE_URL,
        json=GENERAL_PAYLOAD,
        headers={"X-Internal-Token": VALID_TOKEN},
    )
    assert response.status_code == 200


def test_generate_general_mode_schema() -> None:
    response = client.post(
        GENERATE_URL,
        json=GENERAL_PAYLOAD,
        headers={"X-Internal-Token": VALID_TOKEN},
    )
    body = response.json()
    assert body["status"] == "SUCCESS"
    assert isinstance(body["recommendations"], list)
    assert 1 <= len(body["recommendations"]) <= 3

    for item in body["recommendations"]:
        assert "title" in item
        assert "description" in item
        assert "type" in item


# ── PERSONALIZED mode ──────────────────────────────────────────────────────────


def test_generate_personalized_mode_returns_200() -> None:
    response = client.post(
        GENERATE_URL,
        json=PERSONALIZED_PAYLOAD,
        headers={"X-Internal-Token": VALID_TOKEN},
    )
    assert response.status_code == 200


def test_generate_personalized_mode_1_to_3_items() -> None:
    response = client.post(
        GENERATE_URL,
        json=PERSONALIZED_PAYLOAD,
        headers={"X-Internal-Token": VALID_TOKEN},
    )
    body = response.json()
    count = len(body["recommendations"])
    assert 1 <= count <= 3, f"Expected 1–3 items, got {count}"


def test_generate_personalized_low_sessions_includes_workout_advice() -> None:
    """User with only 1 session should receive workout frequency recommendation."""
    response = client.post(
        GENERATE_URL,
        json=PERSONALIZED_PAYLOAD,
        headers={"X-Internal-Token": VALID_TOKEN},
    )
    types = [item["type"] for item in response.json()["recommendations"]]
    assert "WORKOUT" in types
