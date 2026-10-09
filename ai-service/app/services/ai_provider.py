from __future__ import annotations

import time
from typing import Protocol

import httpx
from openai import AsyncOpenAI

from app.core.config import settings
from app.models.schemas import (
    GenerateRequest,
    GenerateResponse,
    ProviderStructuredOutput,
    RecommendationItem,
    RequestType,
)


class AIProvider(Protocol):
    async def generate(self, request: GenerateRequest) -> GenerateResponse: ...


class MockAIProvider:
    async def generate(self, request: GenerateRequest) -> GenerateResponse:
        if request.requestType == RequestType.CHAT:
            return GenerateResponse(
                correlationId=request.correlationId,
                content=(
                    "Bạn nên ưu tiên lịch tập đều, tăng tải từ từ và dừng bài tập nếu xuất hiện "
                    "đau bất thường. Đây là hướng dẫn thể chất tổng quát, "
                    "không phải chẩn đoán y khoa."
                ),
                providerMetadata={"provider": "mock", "model": "deterministic-m6", "latencyMs": 0},
            )

        foods = request.candidates.get("foods", [])
        if foods and "ADD_MEAL_ENTRY_PROPOSAL" in request.allowedActions:
            food = foods[0]
            proposal = {
                "allowedAction": "ADD_MEAL_ENTRY_PROPOSAL",
                "foodId": food["id"],
                "mealType": "SNACK",
                "servingMultiplier": 1,
                "targetDate": _target_date(request.renderedPrompt),
            }
            item_type = "NUTRITION"
            title = f"Bổ sung {food['name']}"
            content = "Gợi ý một khẩu phần phù hợp từ danh sách thực phẩm khả dụng."
        else:
            proposal = {"allowedAction": "NONE"}
            item_type = "GENERAL_ADVICE"
            title = "Duy trì thói quen vận động"
            content = "Ưu tiên vận động đều đặn và tăng cường độ một cách từ từ."
        return GenerateResponse(
            correlationId=request.correlationId,
            items=[
                RecommendationItem(
                    type=item_type,
                    title=title,
                    content=content,
                    reason="Đề xuất được tạo từ rules-v1 và candidate shortlist hiện tại.",
                    priority="MEDIUM",
                    proposal=proposal,
                )
            ],
            providerMetadata={"provider": "mock", "model": "deterministic-m6", "latencyMs": 0},
        )


class OpenAIProvider:
    def __init__(self) -> None:
        if not settings.AI_PROVIDER_API_KEY:
            raise RuntimeError("AI_PROVIDER_API_KEY is required when AI_PROVIDER=openai")
        timeout = httpx.Timeout(
            settings.AI_READ_TIMEOUT_SECONDS,
            connect=settings.AI_CONNECT_TIMEOUT_SECONDS,
        )
        self.client = AsyncOpenAI(
            api_key=settings.AI_PROVIDER_API_KEY,
            timeout=timeout,
            max_retries=max(0, settings.AI_MAX_ATTEMPTS - 1),
        )

    async def generate(self, request: GenerateRequest) -> GenerateResponse:
        started = time.monotonic()
        response = await self.client.responses.parse(
            model=settings.AI_MODEL,
            reasoning={"effort": "low"},
            input=request.renderedPrompt,
            text_format=ProviderStructuredOutput,
            max_output_tokens=settings.AI_MAX_OUTPUT_TOKENS,
        )
        parsed = response.output_parsed
        if parsed is None:
            raise ValueError("provider returned no structured output")
        return GenerateResponse(
            correlationId=request.correlationId,
            content=parsed.content,
            safetyLevel=parsed.safetyLevel,
            items=parsed.items,
            providerMetadata={
                "provider": "openai",
                "model": settings.AI_MODEL,
                "latencyMs": round((time.monotonic() - started) * 1000),
            },
        )


def provider_for_settings() -> AIProvider:
    if settings.AI_PROVIDER == "openai":
        return OpenAIProvider()
    return MockAIProvider()


def _target_date(prompt: str) -> str:
    for part in prompt.replace(".", " ").split():
        if len(part) == 10 and part[4] == "-" and part[7] == "-":
            return part
    return "1970-01-01"
