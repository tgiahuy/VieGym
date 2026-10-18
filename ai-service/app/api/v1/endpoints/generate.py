import json

from fastapi import APIRouter, Depends, HTTPException, status

from app.core.config import settings
from app.core.security import verify_internal_token
from app.models.schemas import GenerateRequest, GenerateResponse, RequestType, SafetyLevel
from app.services.ai_provider import provider_for_settings

router = APIRouter()


@router.get("/status")
async def provider_status(token: str = Depends(verify_internal_token)) -> dict[str, object]:
    return {
        "provider": settings.AI_PROVIDER,
        "model": settings.AI_MODEL,
        "reachable": True,
    }


@router.post("/generate", response_model=GenerateResponse)
async def generate_recommendation(
    request: GenerateRequest, token: str = Depends(verify_internal_token)
) -> GenerateResponse:
    payload_bytes = len(
        json.dumps(
            {"context": request.context.model_dump(), "candidates": request.candidates},
            ensure_ascii=False,
            default=str,
        ).encode("utf-8")
    )
    if payload_bytes > settings.AI_MAX_CONTEXT_BYTES:
        raise HTTPException(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail="AI context exceeds configured budget",
        )
    try:
        return await provider_for_settings().generate(request)
    except Exception:
        return GenerateResponse(
            correlationId=request.correlationId,
            content=(
                "AI Coach đang tạm thời không phản hồi. Hãy ưu tiên an toàn và thử lại sau."
                if request.requestType == RequestType.CHAT
                else None
            ),
            safetyLevel=SafetyLevel.CAUTION,
            items=[],
            providerMetadata={
                "provider": settings.AI_PROVIDER,
                "model": settings.AI_MODEL,
                "fallback": True,
            },
        )
