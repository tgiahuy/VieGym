package com.viegym.nutrition.api;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;

public record MealEntryRequest(
        @NotBlank String mealType,
        @Positive Integer mealSortOrder,
        Long foodId,
        @DecimalMin(value = "0.001") BigDecimal servingMultiplier,
        @DecimalMin(value = "0.01") BigDecimal inputAmount,
        String inputUnit,
        @Size(max = 500) String note) {
    public MealEntryRequest {
        mealSortOrder = mealSortOrder == null ? 1 : mealSortOrder;
    }
}
