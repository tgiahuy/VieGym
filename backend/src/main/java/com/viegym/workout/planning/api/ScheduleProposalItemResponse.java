package com.viegym.workout.planning.api;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

public record ScheduleProposalItemResponse(
        Long id,
        Integer sortOrder,
        Long sourceDayId,
        LocalDate scheduledDate,
        LocalTime scheduledTime,
        String title,
        Long appliedScheduleId,
        List<ScheduleExercisePlan> exercises) {}
