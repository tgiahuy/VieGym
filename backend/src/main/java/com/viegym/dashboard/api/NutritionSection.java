package com.viegym.dashboard.api;

public record NutritionSection(
        NutritionMacroSummary target,
        NutritionMacroSummary consumed,
        NutritionMacroSummary remaining,
        boolean hasMealPlan) {}
