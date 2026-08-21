from pydantic import BaseModel, Field
from typing import List, Optional

class UserContext(BaseModel):
    user_id: str
    preferences: dict = Field(default_factory=dict)
    health_metrics: dict = Field(default_factory=dict)

class GenerateRequest(BaseModel):
    mode: str = Field(..., description="General or Personalized")
    context: UserContext
    prompt: str

class RecommendationItem(BaseModel):
    title: str
    description: str
    type: str

class GenerateResponse(BaseModel):
    recommendations: List[RecommendationItem]
    status: str = "SUCCESS"
    message: Optional[str] = None
