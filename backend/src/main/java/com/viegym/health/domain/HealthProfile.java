package com.viegym.health.domain;

import com.viegym.identity.User;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.OffsetDateTime;

@Entity
@Table(name = "health_profiles")
public class HealthProfile {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "date_of_birth", nullable = false)
    private LocalDate dateOfBirth;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private Gender gender;

    @Enumerated(EnumType.STRING)
    @Column(name = "calculation_sex", nullable = false, length = 20)
    private CalculationSex calculationSex;

    @Column(name = "height_cm", nullable = false, precision = 5, scale = 2)
    private BigDecimal heightCm;

    @Column(name = "current_weight_kg", nullable = false, precision = 6, scale = 2)
    private BigDecimal currentWeightKg;

    @Enumerated(EnumType.STRING)
    @Column(name = "activity_level", nullable = false, length = 20)
    private ActivityLevel activityLevel;

    @Enumerated(EnumType.STRING)
    @Column(name = "fitness_goal", nullable = false, length = 30)
    private FitnessGoal fitnessGoal;

    @Enumerated(EnumType.STRING)
    @Column(name = "training_experience", nullable = false, length = 30)
    private TrainingExperience trainingExperience;

    @Column(nullable = false, precision = 6, scale = 2)
    private BigDecimal bmi;

    @Column(name = "bmr_kcal", precision = 8, scale = 2)
    private BigDecimal bmrKcal;

    @Column(name = "tdee_kcal", precision = 8, scale = 2)
    private BigDecimal tdeeKcal;

    @Column(name = "calculation_version", nullable = false, length = 30)
    private String calculationVersion;

    @Column(name = "calculated_at", nullable = false)
    private OffsetDateTime calculatedAt;

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt;

    protected HealthProfile() {}

    public HealthProfile(
            User user,
            LocalDate dateOfBirth,
            Gender gender,
            CalculationSex calculationSex,
            BigDecimal heightCm,
            BigDecimal currentWeightKg,
            ActivityLevel activityLevel,
            FitnessGoal fitnessGoal,
            TrainingExperience trainingExperience,
            HealthCalculationResult calculation,
            OffsetDateTime now) {
        this.user = user;
        this.dateOfBirth = dateOfBirth;
        this.gender = gender;
        this.calculationSex = calculationSex;
        this.heightCm = heightCm;
        this.currentWeightKg = currentWeightKg;
        this.activityLevel = activityLevel;
        this.fitnessGoal = fitnessGoal;
        this.trainingExperience = trainingExperience;
        this.bmi = calculation.bmi();
        this.bmrKcal = calculation.bmrKcal();
        this.tdeeKcal = calculation.tdeeKcal();
        this.calculationVersion = HealthCalculator.VERSION;
        this.calculatedAt = now;
        this.createdAt = now;
        this.updatedAt = now;
    }

    public Long id() {
        return id;
    }
}
