package com.viegym.workout.session.api;

import java.util.List;

public record FinishExerciseLogRequest(
        Long exerciseId,
        int sortOrder,
        Integer durationSeconds,
        boolean completed,
        List<FinishSetLogRequest> sets) {}
