package com.viegym.workout.program.api;

import java.util.List;

public record WorkoutDayResponse(
        Long id,
        int dayNumber,
        String name,
        String note,
        List<WorkoutExerciseResponse> exercises) {}
