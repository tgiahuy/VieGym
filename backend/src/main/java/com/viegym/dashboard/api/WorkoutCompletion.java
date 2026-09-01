package com.viegym.dashboard.api;

import java.math.BigDecimal;
import java.time.LocalDate;

public record WorkoutCompletion(
        LocalDate windowFrom,
        LocalDate windowTo,
        int scheduledEligible,
        int completedEligible,
        BigDecimal rate) {}
