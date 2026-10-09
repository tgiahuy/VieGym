package com.viegym.workout.planning.api;

public record ScheduleExercisePlan(
        Long exerciseId,
        String exerciseName,
        String primaryMuscle,
        Integer sortOrder,
        Integer targetSets,
        Integer targetRepsMin,
        Integer targetRepsMax,
        Integer targetDurationSeconds,
        Integer restSeconds,
        String note) {}
