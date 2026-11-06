package com.viegym.ai.api;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Map;

public final class AiDtos {
    private AiDtos() {}

    public record Consent(
            String mode,
            String consentVersion,
            OffsetDateTime acceptedAt,
            OffsetDateTime updatedAt) {}

    public record UpdateConsent(
            @NotBlank String mode, @NotBlank String consentVersion, @NotBlank String source) {}

    public record CreateConversation(
            @NotBlank @Size(max = 160) String title, @NotBlank String requestedMode) {}

    public record SendMessage(@NotBlank @Size(max = 4000) String content) {}

    public record Message(
            Long id,
            String role,
            String content,
            String mode,
            String safetyLevel,
            String disclaimer,
            OffsetDateTime createdAt) {}

    public record Conversation(
            Long id,
            String title,
            String requestedMode,
            String status,
            OffsetDateTime lastMessageAt,
            String preview,
            List<Message> messages) {}

    public record MessageExchange(
            Message userMessage, Message assistantMessage, String mode, String correlationId) {}

    public record Recommendation(
            Long id,
            String type,
            String title,
            String content,
            String reason,
            String priority,
            String status,
            Map<String, Object> sourceMetrics,
            String safetyLevel,
            String allowedAction,
            Map<String, Object> actionPreview,
            int version,
            OffsetDateTime expiresAt) {}

    public record DailyRecommendations(
            LocalDate date,
            boolean personalizationEnabled,
            String generationStatus,
            List<Recommendation> recommendations) {}

    public record GenerateDaily(LocalDate targetDate) {}

    public record ApplyRecommendation(@NotNull Integer expectedVersion) {}

    public record DismissRecommendation(
            @NotNull Integer expectedVersion, @Size(max = 500) String feedback) {}

    public record RecommendationAction(
            Long recommendationId,
            String status,
            String allowedAction,
            Map<String, Object> mutationResult,
            OffsetDateTime actedAt) {}

    /**
     * Equipment may be given as IDs and/or codes (e.g. {@code DUMBBELL}); both empty = use the
     * user's saved equipment.
     */
    public record GenerateWorkout(
            LocalDate targetDate,
            @Size(max = 18) List<String> targetMuscles,
            @Size(max = 20) List<Long> equipmentIds,
            @Size(max = 20) List<String> equipmentCodes,
            Integer durationMinutes,
            String intensity,
            @Size(max = 50) List<Long> excludedExerciseIds) {}

    public record WorkoutPlanExercise(
            Long exerciseId,
            String name,
            String primaryMuscle,
            List<String> equipmentCodes,
            int targetSets,
            int targetRepsMin,
            int targetRepsMax,
            int restSeconds,
            BigDecimal targetWeightKg,
            String coachingTip) {}

    /** Apply with {@code POST /recommendations/{recommendationId}/apply}. */
    public record WorkoutPlan(
            Long recommendationId,
            int version,
            String status,
            LocalDate targetDate,
            String planTitle,
            String rationale,
            int estimatedDurationMinutes,
            List<WorkoutPlanExercise> exercises,
            String proposalAction,
            String generatedBy,
            boolean personalized,
            String safetyLevel,
            OffsetDateTime expiresAt) {}

    /** {@code mealTypes} null/empty = every meal not logged yet on the target date. */
    public record GenerateMeals(
            LocalDate targetDate,
            @Size(max = 4) List<String> mealTypes,
            Integer maxPrepTimeMinutes,
            @Size(max = 300) String customPrompt) {}

    public record MealPlanItem(
            Long foodId,
            String name,
            String servingUnit,
            BigDecimal servingMultiplier,
            BigDecimal calories,
            BigDecimal protein,
            BigDecimal carbs,
            BigDecimal fat) {}

    /** Each meal is its own recommendation so it can be applied or dismissed separately. */
    public record MealPlanMeal(
            Long recommendationId,
            int version,
            String status,
            String mealType,
            String dishName,
            String coachingReason,
            int targetCalories,
            BigDecimal calories,
            BigDecimal protein,
            BigDecimal carbs,
            BigDecimal fat,
            List<MealPlanItem> items,
            String generatedBy) {}

    public record MealPlanSummary(
            int targetCalories,
            BigDecimal generatedCalories,
            BigDecimal generatedProteinGrams,
            BigDecimal generatedCarbsGrams,
            BigDecimal generatedFatGrams,
            BigDecimal remainingCaloriesBeforePlan) {}

    public record MealPlan(
            LocalDate targetDate,
            boolean personalized,
            String generatedBy,
            String rationale,
            MealPlanSummary summary,
            List<MealPlanMeal> meals,
            String proposalAction,
            OffsetDateTime expiresAt) {}
}
