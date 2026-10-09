package com.viegym.nutrition.api;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;
import java.util.List;

public record CreateMealTemplateRequest(
        @NotBlank @Size(max = 160) String name,
        String description,
        Long sourceMealPlanId,
        List<Item> items) {
    public record Item(
            Long foodId,
            @NotBlank String mealType,
            Integer sortOrder,
            BigDecimal servingMultiplier) {}
}
