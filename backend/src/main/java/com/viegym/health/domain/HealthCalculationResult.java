package com.viegym.health.domain;

import java.math.BigDecimal;

public record HealthCalculationResult(
        BigDecimal bmi,
        BigDecimal bmrKcal,
        BigDecimal tdeeKcal,
        NutritionTargetValues nutritionTarget,
        HealthIncompleteReason incompleteReason) {

    public boolean complete() {
        return incompleteReason == null;
    }
}
