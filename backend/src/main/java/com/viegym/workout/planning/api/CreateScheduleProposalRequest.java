package com.viegym.workout.planning.api;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

public record CreateScheduleProposalRequest(
        String sourceType,
        String scope,
        Long sourceId,
        Long sourceDayId,
        List<LocalDate> targetDates,
        LocalTime scheduledTime,
        List<ScheduleProposalItemRequest> items) {}
