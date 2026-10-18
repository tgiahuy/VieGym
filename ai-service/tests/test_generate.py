from __future__ import annotations

from fastapi.testclient import TestClient

from app.core.config import settings
from app.main import app

client = TestClient(app)
URL = "/internal/v1/ai/generate"
HEADERS = {"X-Internal-Token": settings.INTERNAL_SERVICE_TOKEN}


def payload(request_type: str = "CHAT") -> dict:
    return {
        "schemaVersion": "1.0",
        "correlationId": "corr-test-001",
        "requestType": request_type,
        "promptVersion": "chat-v1" if request_type == "CHAT" else "daily-v1",
        "renderedPrompt": (
            "rules-v1 chat guidance"
            if request_type == "CHAT"
            else "rules-v1 daily recommendation for 2026-09-22"
        ),
        "context": {
            "contextVersion": "context-v1",
            "consentMode": "DISABLED" if request_type == "CHAT" else "ENABLED",
            "data": {} if request_type == "CHAT" else {"workout": {"recentSessions7d": 1}},
        },
        "candidates": {
            "foods": [
                {
                    "id": 205,
                    "name": "Ức gà luộc",
                    "serving_unit": "phần",
                    "calories_kcal": 165,
                    "protein_g": 31,
                }
            ]
        },
        "messages": [{"role": "USER", "content": "Tôi nên tập thế nào?"}],
        "allowedActions": ["NONE", "ADD_MEAL_ENTRY_PROPOSAL"],
    }


def test_internal_token_guard() -> None:
    assert client.post(URL, json=payload()).status_code == 403
    response = client.post(URL, json=payload(), headers={"X-Internal-Token": "wrong"})
    assert response.status_code == 403


def test_status_reports_active_provider() -> None:
    response = client.get("/internal/v1/ai/status", headers=HEADERS)
    assert response.status_code == 200
    assert response.json() == {
        "provider": settings.AI_PROVIDER,
        "model": settings.AI_MODEL,
        "reachable": True,
    }


def test_general_chat_has_no_personal_context_and_returns_structured_response() -> None:
    response = client.post(URL, json=payload(), headers=HEADERS)
    assert response.status_code == 200
    body = response.json()
    assert body["schemaVersion"] == "1.0"
    assert body["correlationId"] == "corr-test-001"
    assert body["content"]
    assert body["items"] == []


def test_disabled_consent_rejects_personal_context() -> None:
    body = payload()
    body["context"]["data"] = {"health": {"bmi": 22}}
    assert client.post(URL, json=body, headers=HEADERS).status_code == 422


def test_daily_recommendation_uses_candidate_id_and_target_date() -> None:
    response = client.post(URL, json=payload("DAILY_RECOMMENDATION"), headers=HEADERS)
    assert response.status_code == 200
    items = response.json()["items"]
    assert 1 <= len(items) <= 3
    assert items[0]["proposal"]["foodId"] == 205
    assert items[0]["proposal"]["targetDate"] == "2026-09-22"


def test_context_budget_is_enforced() -> None:
    body = payload("DAILY_RECOMMENDATION")
    body["context"]["data"] = {"padding": "x" * (settings.AI_MAX_CONTEXT_BYTES + 1)}
    assert client.post(URL, json=body, headers=HEADERS).status_code == 413
