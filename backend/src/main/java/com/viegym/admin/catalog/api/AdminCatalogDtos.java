package com.viegym.admin.catalog.api;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.List;

public final class AdminCatalogDtos {
    private AdminCatalogDtos() {}

    public record MuscleInput(Long muscleGroupId, String role) {}

    public record EquipmentInput(Long equipmentId, boolean required) {}

    public record ExerciseRequest(
            String name,
            String slug,
            String difficulty,
            String description,
            List<String> instructionSteps,
            List<String> commonMistakes,
            List<String> safetyNotes,
            String visibility,
            List<MuscleInput> muscleGroups,
            List<EquipmentInput> equipment,
            Long version) {}

    public record Exercise(
            Long id,
            String name,
            String slug,
            String difficulty,
            String description,
            List<String> instructionSteps,
            List<String> commonMistakes,
            List<String> safetyNotes,
            String visibility,
            List<MuscleInput> muscleGroups,
            List<EquipmentInput> equipment,
            long version,
            OffsetDateTime updatedAt) {}

    public record FoodRequest(
            String name,
            String slug,
            String category,
            BigDecimal servingAmount,
            String servingUnit,
            BigDecimal gramsPerServing,
            BigDecimal caloriesPerServing,
            BigDecimal proteinGPerServing,
            BigDecimal carbsGPerServing,
            BigDecimal fatGPerServing,
            String dataSource,
            String sourceNote,
            boolean estimated,
            String visibility,
            Long version) {}

    public record Food(
            Long id,
            String name,
            String slug,
            String category,
            BigDecimal servingAmount,
            String servingUnit,
            BigDecimal gramsPerServing,
            BigDecimal caloriesPerServing,
            BigDecimal proteinGPerServing,
            BigDecimal carbsGPerServing,
            BigDecimal fatGPerServing,
            String dataSource,
            String sourceNote,
            boolean estimated,
            String visibility,
            long version,
            OffsetDateTime updatedAt) {}

    public record VisibilityRequest(String visibility, Long version) {}
}
