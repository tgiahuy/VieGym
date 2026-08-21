from fastapi import FastAPI
from app.core.config import settings
from app.api.v1.api import api_router

app = FastAPI(
    title=settings.PROJECT_NAME,
    version="0.1.0",
)

app.include_router(api_router, prefix=settings.INTERNAL_API_V1_STR)

@app.get("/health", tags=["health"])
async def health() -> dict[str, str]:
    return {"status": "ok"}
