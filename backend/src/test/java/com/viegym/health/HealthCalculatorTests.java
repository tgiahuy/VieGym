package com.viegym.health;

import static org.assertj.core.api.Assertions.assertThat;

import com.viegym.health.domain.ActivityLevel;
import com.viegym.health.domain.CalculationSex;
import com.viegym.health.domain.FitnessGoal;
import com.viegym.health.domain.HealthCalculationInput;
import com.viegym.health.domain.HealthCalculationResult;
import com.viegym.health.domain.HealthCalculator;
import com.viegym.health.domain.HealthIncompleteReason;
import java.math.BigDecimal;
import java.time.LocalDate;
import org.junit.jupiter.api.Test;

class HealthCalculatorTests {

    private final HealthCalculator calculator = new HealthCalculator();

    @Test
    void healthV1MatchesCanonicalMaleGainMuscleGoldenFixture() {
        HealthCalculationResult result =
                calculator.calculate(
                        new HealthCalculationInput(
                                LocalDate.of(1998, 5, 20),
                                CalculationSex.MALE,
                                new BigDecimal("172.5"),
                                new BigDecimal("70.2"),
                                ActivityLevel.MODERATE,
                                FitnessGoal.GAIN_MUSCLE),
                        LocalDate.of(2026, 8, 19));

        assertThat(result.complete()).isTrue();
        assertThat(result.bmi()).isEqualByComparingTo("23.59");
        assertThat(result.bmrKcal()).isEqualByComparingTo("1645.13");
        assertThat(result.tdeeKcal()).isEqualByComparingTo("2549.95");
        assertThat(result.nutritionTarget().caloriesKcal()).isEqualByComparingTo("2849.95");
        assertThat(result.nutritionTarget().proteinG()).isEqualByComparingTo("140.40");
        assertThat(result.nutritionTarget().carbsG()).isEqualByComparingTo("393.96");
        assertThat(result.nutritionTarget().fatG()).isEqualByComparingTo("79.17");
    }

    @Test
    void ageUsesWholeYearsAtCalculationDate() {
        HealthCalculationInput input =
                new HealthCalculationInput(
                        LocalDate.of(2000, 8, 20),
                        CalculationSex.MALE,
                        new BigDecimal("180"),
                        new BigDecimal("80"),
                        ActivityLevel.SEDENTARY,
                        FitnessGoal.MAINTAIN_WEIGHT);

        assertThat(calculator.calculate(input, LocalDate.of(2026, 8, 19)).bmrKcal())
                .isEqualByComparingTo("1805.00");
        assertThat(calculator.calculate(input, LocalDate.of(2026, 8, 20)).bmrKcal())
                .isEqualByComparingTo("1800.00");
    }

    @Test
    void returnsExplicitIncompleteReasonsWithoutPublishingTarget() {
        HealthCalculationResult unspecified =
                calculator.calculate(
                        input(CalculationSex.UNSPECIFIED, FitnessGoal.MAINTAIN_WEIGHT),
                        LocalDate.of(2026, 8, 19));
        assertThat(unspecified.incompleteReason())
                .isEqualTo(HealthIncompleteReason.CALCULATION_SEX_REQUIRED);
        assertThat(unspecified.bmi()).isNotNull();
        assertThat(unspecified.bmrKcal()).isNull();
        assertThat(unspecified.nutritionTarget()).isNull();

        HealthCalculationResult minor =
                calculator.calculate(
                        new HealthCalculationInput(
                                LocalDate.of(2010, 1, 1),
                                CalculationSex.FEMALE,
                                new BigDecimal("160"),
                                new BigDecimal("50"),
                                ActivityLevel.LIGHT,
                                FitnessGoal.MAINTAIN_WEIGHT),
                        LocalDate.of(2026, 8, 19));
        assertThat(minor.incompleteReason()).isEqualTo(HealthIncompleteReason.UNSUPPORTED_AGE);
        assertThat(minor.nutritionTarget()).isNull();

        HealthCalculationResult unsafeCalories =
                calculator.calculate(
                        new HealthCalculationInput(
                                LocalDate.of(1940, 1, 1),
                                CalculationSex.FEMALE,
                                new BigDecimal("140"),
                                new BigDecimal("40"),
                                ActivityLevel.SEDENTARY,
                                FitnessGoal.LOSE_WEIGHT),
                        LocalDate.of(2026, 8, 19));
        assertThat(unsafeCalories.incompleteReason())
                .isEqualTo(HealthIncompleteReason.CALORIES_BELOW_SAFETY_THRESHOLD);
        assertThat(unsafeCalories.bmrKcal()).isNotNull();
        assertThat(unsafeCalories.tdeeKcal()).isNotNull();
        assertThat(unsafeCalories.nutritionTarget()).isNull();

        HealthCalculationResult invalidMacro =
                calculator.calculate(
                        new HealthCalculationInput(
                                LocalDate.of(1926, 1, 1),
                                CalculationSex.FEMALE,
                                new BigDecimal("50"),
                                new BigDecimal("200"),
                                ActivityLevel.SEDENTARY,
                                FitnessGoal.LOSE_WEIGHT),
                        LocalDate.of(2026, 8, 19));
        assertThat(invalidMacro.incompleteReason())
                .isEqualTo(HealthIncompleteReason.INVALID_MACRO_RESULT);
        assertThat(invalidMacro.nutritionTarget()).isNull();
    }

    private static HealthCalculationInput input(CalculationSex calculationSex, FitnessGoal goal) {
        return new HealthCalculationInput(
                LocalDate.of(1998, 5, 20),
                calculationSex,
                new BigDecimal("172.5"),
                new BigDecimal("70.2"),
                ActivityLevel.MODERATE,
                goal);
    }
}
