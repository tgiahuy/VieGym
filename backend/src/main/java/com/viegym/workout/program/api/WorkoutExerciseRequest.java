package com.viegym.workout.program.api;

public record WorkoutExerciseRequest(
        Long id,
        Long exerciseId,
        int sortOrder,
        int targetSets,
        Integer targetRepsMin,
        Integer targetRepsMax,
        Integer targetDurationSeconds,
        int restSeconds,
        String note) {}
