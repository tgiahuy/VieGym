package com.viegym.workout.program.api;

public record WorkoutProgramSummaryResponse(
        Long id,
        String name,
        String programType,
        String description,
        String status,
        int totalDays) {}
