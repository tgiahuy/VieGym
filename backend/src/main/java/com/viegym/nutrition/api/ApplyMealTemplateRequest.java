package com.viegym.nutrition.api;

import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;

public record ApplyMealTemplateRequest(@NotNull LocalDate targetDate, String mode) {
    public ApplyMealTemplateRequest {
        mode = mode == null ? "MERGE" : mode;
    }
}
