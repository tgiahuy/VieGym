package com.viegym.health.api;

import com.viegym.health.domain.ActivityLevel;
import com.viegym.health.domain.CalculationSex;
import com.viegym.health.domain.FitnessGoal;
import com.viegym.health.domain.Gender;
import com.viegym.health.domain.HealthIncompleteReason;
import com.viegym.health.domain.TrainingExperience;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.OffsetDateTime;

public record HealthProfileResponse(
        Profile profile,
        String calculationStatus,
        Metrics metrics,
        NutritionTarget nutritionTarget,
        HealthIncompleteReason incompleteReason) {

    public record Profile(
            LocalDate dateOfBirth,
            Gender gender,
            CalculationSex calculationSex,
            BigDecimal heightCm,
            BigDecimal currentWeightKg,
            ActivityLevel activityLevel,
            FitnessGoal fitnessGoal,
            TrainingExperience trainingExperience,
            String calculationVersion,
            OffsetDateTime calculatedAt) {}

    public record Metrics(BigDecimal bmi, BigDecimal bmrKcal, BigDecimal tdeeKcal) {}

    public record NutritionTarget(
            BigDecimal caloriesKcal, BigDecimal proteinG, BigDecimal carbsG, BigDecimal fatG) {}
}
