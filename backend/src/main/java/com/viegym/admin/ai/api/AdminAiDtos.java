package com.viegym.admin.ai.api;

import java.time.OffsetDateTime;
import java.util.List;

public final class AdminAiDtos {
    private AdminAiDtos() {}

    public record PromptTemplate(
            long id,
            String code,
            String useCase,
            String title,
            String description,
            String version,
            String status,
            String model,
            String fallbackModel,
            String content,
            long draftRevision,
            OffsetDateTime updatedAt,
            String author) {}

    public record CreatePromptRequest(
            String code,
            String useCase,
            String title,
            String description,
            String model,
            String fallbackModel,
            String content) {}

    public record SaveDraftRequest(String content, Long expectedRevision) {}

    public record PublishRequest(Long expectedRevision) {}

    public record SafetyRule(
            long id,
            String code,
            String name,
            String category,
            String severity,
            String description,
            String action,
            boolean active,
            long version,
            OffsetDateTime updatedAt) {}

    public record UpdateSafetyRuleRequest(Boolean active, Long expectedVersion) {}

    public record AiMetrics(
            String provider,
            String model,
            boolean serviceReachable,
            long requests24h,
            long succeeded24h,
            long failed24h,
            long blocked24h,
            Double averageLatencyMs,
            List<String> warnings) {}
}
