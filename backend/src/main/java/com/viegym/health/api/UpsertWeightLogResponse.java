package com.viegym.health.api;

public record UpsertWeightLogResponse(
        WeightLogDto weightLog,
        boolean metricsUpdated,
        HealthProfileResponse.Metrics metrics,
        boolean nutritionTargetChanged) {}
