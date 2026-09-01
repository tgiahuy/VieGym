package com.viegym.exercise.api;

import java.util.List;

public record ExerciseSummaryDto(
        Long id,
        String name,
        String slug,
        String difficulty,
        String description,
        List<ExerciseMuscleGroupDto> muscleGroups,
        List<ExerciseEquipmentDto> equipment,
        List<Object> media) {}
