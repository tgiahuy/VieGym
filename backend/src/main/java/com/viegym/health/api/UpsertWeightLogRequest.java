package com.viegym.health.api;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Digits;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;

public record UpsertWeightLogRequest(
        @NotNull(message = "weightKg is required")
                @DecimalMin(value = "0.01", message = "weightKg must be greater than 0")
                @DecimalMax(value = "9999.99", message = "weightKg exceeds supported precision")
                @Digits(integer = 4, fraction = 2, message = "weightKg supports at most 2 decimals")
                BigDecimal weightKg,
        @Size(max = 500, message = "note supports at most 500 characters") String note) {}
