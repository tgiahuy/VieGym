package com.viegym.exercise.api;

import java.util.List;

public record ExerciseDetailDto(
        Long id,
        String name,
        String slug,
        String difficulty,
        String description,
        List<String> instructionSteps,
        List<String> commonMistakes,
        List<String> safetyNotes,
        List<ExerciseMuscleGroupDto> muscleGroups,
        List<ExerciseEquipmentDto> equipment,
        List<Object> media) {}
