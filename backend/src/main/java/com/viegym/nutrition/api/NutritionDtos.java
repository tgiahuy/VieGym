package com.viegym.nutrition.api;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

public final class NutritionDtos {
    private NutritionDtos() {}

    public record Serving(BigDecimal amount, String unit, BigDecimal gramsPerServing) {}

    public record Nutrition(
            BigDecimal caloriesKcal, BigDecimal proteinG, BigDecimal carbsG, BigDecimal fatG) {
        public static Nutrition zero() {
            return new Nutrition(
                    BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO);
        }
    }

    public record Food(
            Long id,
            String name,
            String slug,
            String category,
            Serving serving,
            Nutrition nutritionPerServing,
            String dataSource,
            String sourceNote,
            boolean estimated,
            boolean selectable,
            List<Object> media) {}

    public record MealEntry(
            Long id,
            Long foodId,
            String foodName,
            String mealType,
            int mealSortOrder,
            BigDecimal servingMultiplier,
            BigDecimal inputAmount,
            String inputUnit,
            BigDecimal servingAmount,
            String servingUnit,
            Nutrition nutrition,
            boolean estimated,
            String note) {}

    public record Meal(
            Long id,
            String mealType,
            String name,
            int sortOrder,
            Nutrition subtotal,
            List<MealEntry> entries) {}

    public record MealPlan(
            Long id,
            LocalDate planDate,
            String targetSource,
            Nutrition target,
            Nutrition consumed,
            Nutrition remaining,
            List<Meal> meals,
            List<String> warnings) {}

    public record TemplateItem(
            Long id,
            Long foodId,
            String foodName,
            String mealType,
            int sortOrder,
            BigDecimal servingMultiplier,
            BigDecimal servingAmount,
            String servingUnit,
            boolean available) {}

    public record MealTemplate(
            Long id,
            String name,
            String description,
            Long sourceMealPlanId,
            List<TemplateItem> items) {}

    public record ApplyTemplateResult(
            boolean applied,
            LocalDate targetDate,
            int copiedItems,
            List<TemplateItem> blockedItems,
            MealPlan mealPlan) {}
}
