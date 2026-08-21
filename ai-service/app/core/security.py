from fastapi import Depends, HTTPException, status
from fastapi.security import APIKeyHeader
from app.core.config import settings

api_key_header = APIKeyHeader(name="X-Internal-Token", auto_error=False)

def verify_internal_token(api_key_header: str = Depends(api_key_header)) -> str:
    if api_key_header == settings.INTERNAL_SERVICE_TOKEN:
        return api_key_header
    raise HTTPException(
        status_code=status.HTTP_403_FORBIDDEN,
        detail="Could not validate credentials",
    )
