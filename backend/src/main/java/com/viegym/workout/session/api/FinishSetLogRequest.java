package com.viegym.workout.session.api;

public record FinishSetLogRequest(
        int setNumber,
        Integer reps,
        Double weightKg,
        Integer durationSeconds,
        Double rpe,
        boolean completed) {}
