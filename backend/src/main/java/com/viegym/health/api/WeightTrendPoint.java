package com.viegym.health.api;

import java.math.BigDecimal;
import java.time.LocalDate;

public record WeightTrendPoint(LocalDate date, BigDecimal weightKg) {}
