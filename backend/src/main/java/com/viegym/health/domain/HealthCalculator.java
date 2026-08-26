package com.viegym.health.domain;

import java.math.BigDecimal;
import java.math.MathContext;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.Period;
import org.springframework.stereotype.Component;

@Component
public class HealthCalculator {

    public static final String VERSION = "health-v1";
    private static final MathContext MC = MathContext.DECIMAL128;
    private static final BigDecimal ONE_HUNDRED = new BigDecimal("100");
    private static final BigDecimal TEN = new BigDecimal("10");
    private static final BigDecimal SIX_POINT_TWO_FIVE = new BigDecimal("6.25");
    private static final BigDecimal FIVE = new BigDecimal("5");
    private static final BigDecimal FEMALE_OFFSET = new BigDecimal("161");
    private static final BigDecimal MIN_CALORIES = new BigDecimal("1200");
    private static final BigDecimal FAT_RATIO = new BigDecimal("0.25");
    private static final BigDecimal NINE = new BigDecimal("9");
    private static final BigDecimal FOUR = new BigDecimal("4");

    public HealthCalculationResult calculate(
            HealthCalculationInput input, LocalDate calculationDate) {
        BigDecimal heightM = input.heightCm().divide(ONE_HUNDRED, MC);
        BigDecimal bmi = round(input.weightKg().divide(heightM.multiply(heightM, MC), MC));

        if (input.calculationSex() == CalculationSex.UNSPECIFIED) {
            return incomplete(bmi, null, null, HealthIncompleteReason.CALCULATION_SEX_REQUIRED);
        }
        int age = Period.between(input.dateOfBirth(), calculationDate).getYears();
        if (age < 18) {
            return incomplete(bmi, null, null, HealthIncompleteReason.UNSUPPORTED_AGE);
        }

        BigDecimal bmr =
                input.weightKg()
                        .multiply(TEN, MC)
                        .add(input.heightCm().multiply(SIX_POINT_TWO_FIVE, MC), MC)
                        .subtract(BigDecimal.valueOf(age).multiply(FIVE, MC), MC);
        bmr =
                input.calculationSex() == CalculationSex.MALE
                        ? bmr.add(FIVE, MC)
                        : bmr.subtract(FEMALE_OFFSET, MC);
        bmr = round(bmr);
        BigDecimal tdee = round(bmr.multiply(input.activityLevel().factor(), MC));
        BigDecimal calories = round(tdee.add(input.fitnessGoal().calorieOffset(), MC));
        if (calories.compareTo(MIN_CALORIES) < 0) {
            return incomplete(
                    bmi, bmr, tdee, HealthIncompleteReason.CALORIES_BELOW_SAFETY_THRESHOLD);
        }

        BigDecimal protein =
                round(input.weightKg().multiply(input.fitnessGoal().proteinFactor(), MC));
        BigDecimal fat = round(calories.multiply(FAT_RATIO, MC).divide(NINE, MC));
        BigDecimal carbs =
                round(
                        calories.subtract(protein.multiply(FOUR, MC), MC)
                                .subtract(fat.multiply(NINE, MC), MC)
                                .divide(FOUR, MC));
        if (protein.signum() < 0 || fat.signum() < 0 || carbs.signum() < 0) {
            return incomplete(bmi, bmr, tdee, HealthIncompleteReason.INVALID_MACRO_RESULT);
        }
        return new HealthCalculationResult(
                bmi, bmr, tdee, new NutritionTargetValues(calories, protein, carbs, fat), null);
    }

    private static HealthCalculationResult incomplete(
            BigDecimal bmi, BigDecimal bmr, BigDecimal tdee, HealthIncompleteReason reason) {
        return new HealthCalculationResult(bmi, bmr, tdee, null, reason);
    }

    private static BigDecimal round(BigDecimal value) {
        return value.setScale(2, RoundingMode.HALF_UP);
    }
}
