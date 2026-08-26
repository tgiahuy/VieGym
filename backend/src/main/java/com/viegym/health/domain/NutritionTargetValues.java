package com.viegym.health.domain;

import java.math.BigDecimal;

public record NutritionTargetValues(
        BigDecimal caloriesKcal, BigDecimal proteinG, BigDecimal carbsG, BigDecimal fatG) {}
