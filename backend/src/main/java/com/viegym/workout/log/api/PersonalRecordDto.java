package com.viegym.workout.log.api;

import java.time.OffsetDateTime;

public record PersonalRecordDto(
        Long id,
        Long exerciseId,
        String exerciseName,
        String recordType,
        Double value,
        OffsetDateTime achievedAt,
        Long workoutLogId,
        Double previousValue) {}
