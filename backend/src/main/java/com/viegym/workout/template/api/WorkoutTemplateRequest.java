package com.viegym.workout.template.api;

import java.util.List;

public record WorkoutTemplateRequest(
        String name,
        String programType,
        String description,
        String difficulty,
        String goal,
        String status,
        List<WorkoutTemplateDayRequest> days) {}
