package com.viegym.observability;

import java.util.UUID;
import org.slf4j.MDC;

public final class CorrelationId {

    public static final String HEADER_NAME = "X-Correlation-Id";
    public static final String MDC_KEY = "correlationId";

    private CorrelationId() {}

    public static String currentOrCreate() {
        String current = MDC.get(MDC_KEY);
        return current == null ? UUID.randomUUID().toString() : current;
    }

    public static String normalizeOrCreate(String candidate) {
        if (candidate != null) {
            try {
                return UUID.fromString(candidate.trim()).toString();
            } catch (IllegalArgumentException ignored) {
                // Invalid client input is replaced to prevent log/header injection.
            }
        }
        return UUID.randomUUID().toString();
    }
}
