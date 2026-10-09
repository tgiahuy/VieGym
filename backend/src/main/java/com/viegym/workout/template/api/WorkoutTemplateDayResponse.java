package com.viegym.workout.template.api;

import com.viegym.workout.planning.api.ScheduleExercisePlan;
import java.util.List;

public record WorkoutTemplateDayResponse(
        Long id,
        Integer dayNumber,
        String name,
        String note,
        List<ScheduleExercisePlan> exercises) {}
