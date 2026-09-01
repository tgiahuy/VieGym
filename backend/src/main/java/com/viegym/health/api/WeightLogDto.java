package com.viegym.health.api;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.OffsetDateTime;

public record WeightLogDto(
        Long id,
        LocalDate loggedDate,
        BigDecimal weightKg,
        String note,
        OffsetDateTime createdAt,
        OffsetDateTime updatedAt) {}
