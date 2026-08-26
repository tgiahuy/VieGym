package com.viegym.health.domain;

import java.math.BigDecimal;

public enum FitnessGoal {
    LOSE_WEIGHT("-400", "2.0"),
    MAINTAIN_WEIGHT("0", "1.4"),
    GAIN_WEIGHT("400", "1.6"),
    GAIN_MUSCLE("300", "2.0");

    private final BigDecimal calorieOffset;
    private final BigDecimal proteinFactor;

    FitnessGoal(String calorieOffset, String proteinFactor) {
        this.calorieOffset = new BigDecimal(calorieOffset);
        this.proteinFactor = new BigDecimal(proteinFactor);
    }

    public BigDecimal calorieOffset() {
        return calorieOffset;
    }

    public BigDecimal proteinFactor() {
        return proteinFactor;
    }
}
