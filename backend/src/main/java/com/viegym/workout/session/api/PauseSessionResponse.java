package com.viegym.workout.session.api;

import java.time.OffsetDateTime;

public record PauseSessionResponse(
        Long id, String status, OffsetDateTime pausedAt, int totalPausedSeconds) {}
