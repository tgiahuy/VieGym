package com.viegym.workout.program.api;

import java.util.List;

public record WorkoutProgramResponse(
        Long id,
        String name,
        String programType,
        String description,
        String status,
        List<WorkoutDayResponse> days) {}
