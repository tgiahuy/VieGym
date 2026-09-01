package com.viegym.health.api;

import com.viegym.health.domain.ActivityLevel;
import com.viegym.health.domain.CalculationSex;
import com.viegym.health.domain.FitnessGoal;
import com.viegym.health.domain.Gender;
import com.viegym.health.domain.TrainingExperience;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Digits;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.LocalDate;

public record UpdateHealthProfileRequest(
        @NotNull(message = "dateOfBirth is required") LocalDate dateOfBirth,
        @NotNull(message = "gender is required") Gender gender,
        CalculationSex calculationSex,
        @NotNull(message = "heightCm is required")
                @DecimalMin(value = "0.01", message = "heightCm must be greater than 0")
                @DecimalMax(value = "999.99", message = "heightCm exceeds supported precision")
                @Digits(integer = 3, fraction = 2, message = "heightCm supports at most 2 decimals")
                BigDecimal heightCm,
        @NotNull(message = "activityLevel is required") ActivityLevel activityLevel,
        @NotNull(message = "fitnessGoal is required") FitnessGoal fitnessGoal,
        @NotNull(message = "trainingExperience is required")
                TrainingExperience trainingExperience) {

    public CalculationSex normalizedCalculationSex() {
        return calculationSex == null ? CalculationSex.UNSPECIFIED : calculationSex;
    }
}
