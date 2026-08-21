from fastapi import APIRouter, Depends

from app.core.security import verify_internal_token
from app.models.schemas import GenerateRequest, GenerateResponse
from app.services.ai_provider import AIProviderService

router = APIRouter()


@router.post("/generate", response_model=GenerateResponse)
async def generate_recommendation(
    request: GenerateRequest, token: str = Depends(verify_internal_token)
) -> GenerateResponse:
    """
    Generate recommendations based on user context.
    Protected by internal service token.
    """
    return await AIProviderService.generate_recommendation(request)
