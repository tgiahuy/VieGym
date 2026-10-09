package com.viegym.workout.planning.api;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

public record ScheduleProposalItemRequest(
        LocalDate scheduledDate,
        LocalTime scheduledTime,
        String title,
        List<ScheduleExercisePlan> exercises) {}
