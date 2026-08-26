package com.viegym.health.domain;

import com.viegym.identity.User;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.OffsetDateTime;

@Entity
@Table(name = "nutrition_targets")
public class NutritionTarget {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "health_profile_id", nullable = false)
    private HealthProfile healthProfile;

    @Column(name = "calories_kcal", nullable = false, precision = 8, scale = 2)
    private BigDecimal caloriesKcal;

    @Column(name = "protein_g", nullable = false, precision = 7, scale = 2)
    private BigDecimal proteinG;

    @Column(name = "carbs_g", nullable = false, precision = 7, scale = 2)
    private BigDecimal carbsG;

    @Column(name = "fat_g", nullable = false, precision = 7, scale = 2)
    private BigDecimal fatG;

    @Column(name = "calculation_version", nullable = false, length = 30)
    private String calculationVersion;

    @Column(name = "effective_from", nullable = false)
    private OffsetDateTime effectiveFrom;

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt;

    protected NutritionTarget() {}

    public NutritionTarget(
            User user,
            HealthProfile healthProfile,
            NutritionTargetValues values,
            OffsetDateTime now) {
        this.user = user;
        this.healthProfile = healthProfile;
        this.caloriesKcal = values.caloriesKcal();
        this.proteinG = values.proteinG();
        this.carbsG = values.carbsG();
        this.fatG = values.fatG();
        this.calculationVersion = HealthCalculator.VERSION;
        this.effectiveFrom = now;
        this.createdAt = now;
        this.updatedAt = now;
    }
}
