package com.viegym.workout.session.api;

import com.viegym.workout.program.api.WorkoutExerciseResponse;
import java.time.OffsetDateTime;
import java.util.List;

public record StartSessionResponse(
        Long id,
        Long workoutScheduleId,
        String status,
        OffsetDateTime startedAt,
        int totalPausedSeconds,
        List<WorkoutExerciseResponse> exercises) {}
