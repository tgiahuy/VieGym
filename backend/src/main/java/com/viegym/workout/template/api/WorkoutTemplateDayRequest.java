package com.viegym.workout.template.api;

import com.viegym.workout.planning.api.ScheduleExercisePlan;
import java.util.List;

public record WorkoutTemplateDayRequest(
        Integer dayNumber, String name, String note, List<ScheduleExercisePlan> exercises) {}
