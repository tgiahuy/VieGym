package com.viegym.ai.infrastructure;

import java.util.List;
import java.util.Map;

public interface AiProviderClient {
    ProviderResponse generate(ProviderRequest request);

    record ProviderRequest(
            String correlationId,
            String requestType,
            String promptVersion,
            String renderedPrompt,
            Map<String, Object> context,
            Map<String, Object> candidates,
            List<Map<String, String>> messages,
            List<String> allowedActions) {}

    record ProviderResponse(
            String correlationId,
            String content,
            String safetyLevel,
            List<Map<String, Object>> items,
            Map<String, Object> providerMetadata) {}
}
