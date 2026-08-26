package com.viegym.health.domain;

import java.math.BigDecimal;
import java.time.LocalDate;

public record HealthCalculationInput(
        LocalDate dateOfBirth,
        CalculationSex calculationSex,
        BigDecimal heightCm,
        BigDecimal weightKg,
        ActivityLevel activityLevel,
        FitnessGoal fitnessGoal) {}
