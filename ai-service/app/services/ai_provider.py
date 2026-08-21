from app.models.schemas import GenerateRequest, GenerateResponse, RecommendationItem

class AIProviderService:
    @staticmethod
    async def generate_recommendation(request: GenerateRequest) -> GenerateResponse:
        # Mock logic for AI Provider based on mode
        recommendations = []
        if request.mode == "Personalized":
            recommendations.append(
                RecommendationItem(
                    title="Mock Personalized Workout",
                    description="A workout tailored to your health metrics.",
                    type="WORKOUT"
                )
            )
        else:
            recommendations.append(
                RecommendationItem(
                    title="Mock General Workout",
                    description="A general workout recommendation.",
                    type="WORKOUT"
                )
            )
        
        return GenerateResponse(
            recommendations=recommendations,
            message="Mock generation successful"
        )
