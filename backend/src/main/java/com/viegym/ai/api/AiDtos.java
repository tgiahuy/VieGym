package com.viegym.ai.api;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
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
}
