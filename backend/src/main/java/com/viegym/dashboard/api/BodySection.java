package com.viegym.dashboard.api;

import java.math.BigDecimal;

public record BodySection(BigDecimal currentWeightKg, BigDecimal bmi, String trend) {}
