package com.viegym.workout.session.api;

import java.util.List;

public record FinishSessionRequest(String note, List<FinishExerciseLogRequest> exercises) {}
