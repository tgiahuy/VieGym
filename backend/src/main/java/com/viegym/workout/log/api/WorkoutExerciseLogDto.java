package com.viegym.workout.log.api;

import java.util.List;

public record WorkoutExerciseLogDto(
        Long id,
        Long exerciseId,
        String exerciseName,
        int sortOrder,
        Integer durationSeconds,
        Double exerciseVolumeKg,
        boolean completed,
        List<WorkoutSetLogDto> sets) {}
