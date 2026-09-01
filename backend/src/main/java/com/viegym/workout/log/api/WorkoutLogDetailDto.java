package com.viegym.workout.log.api;

import java.time.OffsetDateTime;
import java.util.List;

public record WorkoutLogDetailDto(
        Long id,
        Long workoutSessionId,
        Long workoutScheduleId,
        String title,
        OffsetDateTime startedAt,
        OffsetDateTime completedAt,
        int durationSeconds,
        Double totalVolumeKg,
        String note,
        List<WorkoutExerciseLogDto> exercises,
        List<PersonalRecordDto> personalRecords) {}
