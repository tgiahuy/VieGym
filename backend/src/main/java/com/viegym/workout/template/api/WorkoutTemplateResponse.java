package com.viegym.workout.template.api;

import java.util.List;

public record WorkoutTemplateResponse(
        Long id,
        String name,
        String programType,
        String description,
        String difficulty,
        String goal,
        String status,
        Integer version,
        List<WorkoutTemplateDayResponse> days) {}
