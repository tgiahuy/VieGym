package com.viegym.workout.schedule.api;

public record WorkoutScheduleExerciseResponse(
        Long exerciseId,
        String exerciseName,
        String primaryMuscle,
        Integer targetSets,
        Integer targetRepsMin,
        Integer targetRepsMax,
        Integer targetDurationSeconds,
        Integer restSeconds,
        String note) {}
