package com.viegym.dashboard.api;

import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.List;

public record DashboardResponse(
        LocalDate date,
        NutritionSection nutrition,
        WorkoutSection workout,
        BodySection body,
        List<Object> recommendations,
        List<String> missingData,
        OffsetDateTime generatedAt) {}
