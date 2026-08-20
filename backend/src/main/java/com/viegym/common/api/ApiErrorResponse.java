package com.viegym.common.api;

import java.time.Instant;
import java.util.List;

public record ApiErrorResponse(
        boolean success,
        String code,
        String message,
        Object data,
        List<FieldViolation> errors,
        String correlationId,
        Instant timestamp) {

    public ApiErrorResponse {
        errors = List.copyOf(errors);
    }

    public static ApiErrorResponse of(
            String code, String message, List<FieldViolation> errors, String correlationId) {
        return new ApiErrorResponse(
                false, code, message, null, errors, correlationId, Instant.now());
    }
}
