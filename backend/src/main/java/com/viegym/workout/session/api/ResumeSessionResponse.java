package com.viegym.workout.session.api;

public record ResumeSessionResponse(Long id, String status, int totalPausedSeconds) {}
