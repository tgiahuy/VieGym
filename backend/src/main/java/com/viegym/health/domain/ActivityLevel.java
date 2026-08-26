package com.viegym.health.domain;

import java.math.BigDecimal;

public enum ActivityLevel {
    SEDENTARY("1.2"),
    LIGHT("1.375"),
    MODERATE("1.55"),
    ACTIVE("1.725"),
    VERY_ACTIVE("1.9");

    private final BigDecimal factor;

    ActivityLevel(String factor) {
        this.factor = new BigDecimal(factor);
    }

    public BigDecimal factor() {
        return factor;
    }
}
