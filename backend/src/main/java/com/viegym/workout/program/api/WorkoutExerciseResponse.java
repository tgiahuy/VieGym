package com.viegym.workout.program.api;

public record WorkoutExerciseResponse(
        Long id,
        Long exerciseId,
        String exerciseName,
        String exerciseSlug,
        boolean hidden,
        int sortOrder,
        int targetSets,
        Integer targetRepsMin,
        Integer targetRepsMax,
        Integer targetDurationSeconds,
        int restSeconds,
        String note) {}
