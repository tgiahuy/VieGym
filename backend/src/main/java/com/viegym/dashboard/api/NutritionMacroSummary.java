package com.viegym.dashboard.api;

import java.math.BigDecimal;

public record NutritionMacroSummary(
        BigDecimal caloriesKcal, BigDecimal proteinG, BigDecimal carbsG, BigDecimal fatG) {}
