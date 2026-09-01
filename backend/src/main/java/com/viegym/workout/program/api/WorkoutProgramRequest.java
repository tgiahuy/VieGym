package com.viegym.workout.program.api;

import java.util.List;

public record WorkoutProgramRequest(
        String name,
        String programType,
        String description,
        String status,
        List<WorkoutDayRequest> days) {}
