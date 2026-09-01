package com.viegym.dashboard.api;

import java.util.List;

public record WorkoutSection(List<Object> today, Object next, WorkoutCompletion completion) {}
