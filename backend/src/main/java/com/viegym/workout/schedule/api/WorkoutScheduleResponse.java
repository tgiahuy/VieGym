package com.viegym.workout.schedule.api;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.OffsetDateTime;

public record WorkoutScheduleResponse(
        Long id,
        Long workoutProgramId,
        Long workoutDayId,
        LocalDate scheduledDate,
        LocalTime scheduledTime,
        String title,
        String status,
        String cancelReason,
        OffsetDateTime completedAt,
        Long activeSessionId) {}
