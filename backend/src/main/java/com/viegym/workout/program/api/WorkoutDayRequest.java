package com.viegym.workout.program.api;

import java.util.List;

public record WorkoutDayRequest(
        Long id, int dayNumber, String name, String note, List<WorkoutExerciseRequest> exercises) {}
