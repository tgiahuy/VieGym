package com.viegym.ai.application;

import java.util.Locale;

/** Cheap pre-provider guard against obvious prompt-injection attempts in user text. */
final class AiPromptSafety {
    private AiPromptSafety() {}

    static boolean looksLikePromptInjection(String content) {
        String normalized = content.toLowerCase(Locale.ROOT);
        return normalized.contains("ignore previous")
                || normalized.contains("system prompt")
                || normalized.contains("bỏ qua hướng dẫn")
                || normalized.contains("tiết lộ prompt");
    }
}
