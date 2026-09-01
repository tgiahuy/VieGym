package com.viegym.workout.log.api;

import java.time.OffsetDateTime;

public record WorkoutLogSummaryDto(
        Long id,
        Long workoutSessionId,
        Long workoutScheduleId,
        String title,
        OffsetDateTime startedAt,
        OffsetDateTime completedAt,
        int durationSeconds,
        Double totalVolumeKg,
        int totalExercises,
        int prCount) {}
