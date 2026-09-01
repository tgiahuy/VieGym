package com.viegym.workout.log.api;

public record WorkoutSetLogDto(
        int setNumber,
        Integer reps,
        Double weightKg,
        Integer durationSeconds,
        Double rpe,
        boolean completed) {}
