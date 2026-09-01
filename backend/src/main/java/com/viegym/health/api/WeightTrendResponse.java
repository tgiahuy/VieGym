package com.viegym.health.api;

import com.viegym.health.domain.WeightTrendDirection;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

public record WeightTrendResponse(
        int days,
        LocalDate from,
        LocalDate to,
        BigDecimal startWeightKg,
        BigDecimal currentWeightKg,
        BigDecimal changeKg,
        WeightTrendDirection direction,
        boolean sufficientData,
        List<WeightTrendPoint> points) {}
