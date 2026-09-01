package com.viegym.health;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.viegym.common.error.ApiException;
import com.viegym.common.error.ApiValidationException;
import com.viegym.health.api.HealthProfileResponse;
import com.viegym.health.api.UpdateHealthProfileRequest;
import com.viegym.health.application.HealthProfileService;
import com.viegym.health.domain.ActivityLevel;
import com.viegym.health.domain.CalculationSex;
import com.viegym.health.domain.FitnessGoal;
import com.viegym.health.domain.Gender;
import com.viegym.health.domain.HealthCalculationResult;
import com.viegym.health.domain.HealthCalculator;
import com.viegym.health.domain.HealthProfile;
import com.viegym.health.domain.HealthProfileRepository;
import com.viegym.health.domain.NutritionTarget;
import com.viegym.health.domain.NutritionTargetRepository;
import com.viegym.health.domain.TrainingExperience;
import com.viegym.health.domain.WeightLogRepository;
import com.viegym.identity.User;
import com.viegym.identity.UserProfile;
import com.viegym.identity.UserProfileRepository;
import com.viegym.identity.UserRepository;
import java.math.BigDecimal;
import java.time.Clock;
import java.time.Instant;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.Optional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

class HealthProfileServiceTests {

    private UserRepository users;
    private UserProfileRepository userProfiles;
    private HealthProfileRepository healthProfiles;
    private NutritionTargetRepository nutritionTargets;
    private WeightLogRepository weightLogs;
    private HealthCalculator calculator;
    private Clock clock;
    private HealthProfileService service;

    @BeforeEach
    void setUp() {
        users = mock(UserRepository.class);
        userProfiles = mock(UserProfileRepository.class);
        healthProfiles = mock(HealthProfileRepository.class);
        nutritionTargets = mock(NutritionTargetRepository.class);
        weightLogs = mock(WeightLogRepository.class);
        calculator = new HealthCalculator();
        clock = Clock.fixed(Instant.parse("2026-08-31T10:00:00Z"), ZoneOffset.UTC);
        service =
                new HealthProfileService(
                        users,
                        userProfiles,
                        healthProfiles,
                        nutritionTargets,
                        weightLogs,
                        calculator,
                        clock);
    }

    @Test
    @DisplayName(
            "GET /health/profile returns existing profile with calculated metrics and nutrition targets")
    void getReturnsExistingProfile() {
        Long userId = 1L;
        User user = new User("athlete@viegym.vn", "hash");
        HealthCalculationResult calcResult =
                calculator.calculate(
                        new com.viegym.health.domain.HealthCalculationInput(
                                LocalDate.of(1995, 5, 20),
                                CalculationSex.MALE,
                                new BigDecimal("175.00"),
                                new BigDecimal("70.00"),
                                ActivityLevel.ACTIVE,
                                FitnessGoal.GAIN_MUSCLE),
                        LocalDate.of(2026, 8, 31));
        HealthProfile profile =
                new HealthProfile(
                        user,
                        LocalDate.of(1995, 5, 20),
                        Gender.MALE,
                        CalculationSex.MALE,
                        new BigDecimal("175.00"),
                        new BigDecimal("70.00"),
                        ActivityLevel.ACTIVE,
                        FitnessGoal.GAIN_MUSCLE,
                        TrainingExperience.INTERMEDIATE,
                        calcResult,
                        OffsetDateTime.now(clock));
        NutritionTarget target =
                new NutritionTarget(
                        user, profile, calcResult.nutritionTarget(), OffsetDateTime.now(clock));

        when(healthProfiles.findByUserId(userId)).thenReturn(Optional.of(profile));
        when(nutritionTargets.findByUserId(userId)).thenReturn(Optional.of(target));

        HealthProfileResponse response = service.get(userId);

        assertThat(response).isNotNull();
        assertThat(response.calculationStatus()).isEqualTo("COMPLETE");
        assertThat(response.profile().dateOfBirth()).isEqualTo(LocalDate.of(1995, 5, 20));
        assertThat(response.profile().heightCm()).isEqualByComparingTo("175.00");
        assertThat(response.profile().currentWeightKg()).isEqualByComparingTo("70.00");
        assertThat(response.metrics().bmi()).isNotNull();
        assertThat(response.nutritionTarget().caloriesKcal()).isNotNull();
    }

    @Test
    @DisplayName("GET /health/profile throws 404 when profile does not exist")
    void getThrowsNotFoundWhenMissing() {
        Long userId = 99L;
        when(healthProfiles.findByUserId(userId)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.get(userId))
                .isInstanceOf(ApiException.class)
                .hasMessageContaining("Health profile not found");
    }

    @Test
    @DisplayName(
            "PUT /health/profile updates whitelist fields, recalculates targets with preserved weight, and updates in transaction")
    void updateRecalculatesWithPreservedWeight() {
        Long userId = 1L;
        User user = new User("athlete@viegym.vn", "hash");
        UserProfile userProfile = new UserProfile(user, "Athlete");

        HealthCalculationResult initialCalc =
                calculator.calculate(
                        new com.viegym.health.domain.HealthCalculationInput(
                                LocalDate.of(1995, 5, 20),
                                CalculationSex.MALE,
                                new BigDecimal("175.00"),
                                new BigDecimal("70.00"),
                                ActivityLevel.SEDENTARY,
                                FitnessGoal.MAINTAIN_WEIGHT),
                        LocalDate.of(2026, 8, 31));

        HealthProfile profile =
                new HealthProfile(
                        user,
                        LocalDate.of(1995, 5, 20),
                        Gender.MALE,
                        CalculationSex.MALE,
                        new BigDecimal("175.00"),
                        new BigDecimal("70.00"),
                        ActivityLevel.SEDENTARY,
                        FitnessGoal.MAINTAIN_WEIGHT,
                        TrainingExperience.BEGINNER,
                        initialCalc,
                        OffsetDateTime.now(clock));

        NutritionTarget existingTarget =
                new NutritionTarget(
                        user, profile, initialCalc.nutritionTarget(), OffsetDateTime.now(clock));

        when(healthProfiles.findByUserId(userId)).thenReturn(Optional.of(profile));
        when(userProfiles.findByUserId(userId)).thenReturn(Optional.of(userProfile));
        when(nutritionTargets.findByUserId(userId)).thenReturn(Optional.of(existingTarget));

        // Update to ACTIVE and GAIN_MUSCLE (without currentWeightKg in request!)
        UpdateHealthProfileRequest updateRequest =
                new UpdateHealthProfileRequest(
                        LocalDate.of(1995, 5, 20),
                        Gender.MALE,
                        CalculationSex.MALE,
                        new BigDecimal("176.00"),
                        ActivityLevel.ACTIVE,
                        FitnessGoal.GAIN_MUSCLE,
                        TrainingExperience.INTERMEDIATE);

        HealthProfileResponse response = service.update(userId, updateRequest);

        assertThat(response).isNotNull();
        assertThat(response.calculationStatus()).isEqualTo("COMPLETE");
        assertThat(response.profile().heightCm()).isEqualByComparingTo("176.00");
        // Preserved current weight from initial profile!
        assertThat(response.profile().currentWeightKg()).isEqualByComparingTo("70.00");
        assertThat(response.profile().activityLevel()).isEqualTo(ActivityLevel.ACTIVE);
        assertThat(response.profile().fitnessGoal()).isEqualTo(FitnessGoal.GAIN_MUSCLE);

        // TDEE and Calories should be higher due to ACTIVE + GAIN_MUSCLE (+300)
        assertThat(response.metrics().tdeeKcal()).isGreaterThan(initialCalc.tdeeKcal());
        assertThat(response.nutritionTarget().caloriesKcal())
                .isGreaterThan(initialCalc.nutritionTarget().caloriesKcal());
    }

    @Test
    @DisplayName("PUT /health/profile rejects future date of birth")
    void updateRejectsFutureDateOfBirth() {
        Long userId = 1L;
        User user = new User("athlete@viegym.vn", "hash");
        UserProfile userProfile = new UserProfile(user, "Athlete");
        HealthCalculationResult initialCalc =
                calculator.calculate(
                        new com.viegym.health.domain.HealthCalculationInput(
                                LocalDate.of(1995, 5, 20),
                                CalculationSex.MALE,
                                new BigDecimal("175.00"),
                                new BigDecimal("70.00"),
                                ActivityLevel.SEDENTARY,
                                FitnessGoal.MAINTAIN_WEIGHT),
                        LocalDate.of(2026, 8, 31));

        HealthProfile profile =
                new HealthProfile(
                        user,
                        LocalDate.of(1995, 5, 20),
                        Gender.MALE,
                        CalculationSex.MALE,
                        new BigDecimal("175.00"),
                        new BigDecimal("70.00"),
                        ActivityLevel.SEDENTARY,
                        FitnessGoal.MAINTAIN_WEIGHT,
                        TrainingExperience.BEGINNER,
                        initialCalc,
                        OffsetDateTime.now(clock));

        when(healthProfiles.findByUserId(userId)).thenReturn(Optional.of(profile));
        when(userProfiles.findByUserId(userId)).thenReturn(Optional.of(userProfile));

        UpdateHealthProfileRequest updateRequest =
                new UpdateHealthProfileRequest(
                        LocalDate.of(2099, 1, 1),
                        Gender.MALE,
                        CalculationSex.MALE,
                        new BigDecimal("175.00"),
                        ActivityLevel.ACTIVE,
                        FitnessGoal.GAIN_MUSCLE,
                        TrainingExperience.INTERMEDIATE);

        assertThatThrownBy(() -> service.update(userId, updateRequest))
                .isInstanceOf(ApiValidationException.class);
    }

    @Test
    @DisplayName(
            "PUT /health/profile changing calculationSex from MALE to FEMALE decreases BMR by 166 kcal")
    void updateChangingSexRecalculatesBmr() {
        Long userId = 1L;
        User user = new User("athlete@viegym.vn", "hash");
        UserProfile userProfile = new UserProfile(user, "Athlete");
        HealthCalculationResult initialCalc =
                calculator.calculate(
                        new com.viegym.health.domain.HealthCalculationInput(
                                LocalDate.of(1995, 5, 20),
                                CalculationSex.MALE,
                                new BigDecimal("175.00"),
                                new BigDecimal("70.00"),
                                ActivityLevel.MODERATE,
                                FitnessGoal.MAINTAIN_WEIGHT),
                        LocalDate.of(2026, 8, 31));

        HealthProfile profile =
                new HealthProfile(
                        user,
                        LocalDate.of(1995, 5, 20),
                        Gender.MALE,
                        CalculationSex.MALE,
                        new BigDecimal("175.00"),
                        new BigDecimal("70.00"),
                        ActivityLevel.MODERATE,
                        FitnessGoal.MAINTAIN_WEIGHT,
                        TrainingExperience.INTERMEDIATE,
                        initialCalc,
                        OffsetDateTime.now(clock));

        NutritionTarget existingTarget =
                new NutritionTarget(
                        user, profile, initialCalc.nutritionTarget(), OffsetDateTime.now(clock));

        when(healthProfiles.findByUserId(userId)).thenReturn(Optional.of(profile));
        when(userProfiles.findByUserId(userId)).thenReturn(Optional.of(userProfile));
        when(nutritionTargets.findByUserId(userId)).thenReturn(Optional.of(existingTarget));

        UpdateHealthProfileRequest updateRequest =
                new UpdateHealthProfileRequest(
                        LocalDate.of(1995, 5, 20),
                        Gender.FEMALE,
                        CalculationSex.FEMALE,
                        new BigDecimal("175.00"),
                        ActivityLevel.MODERATE,
                        FitnessGoal.MAINTAIN_WEIGHT,
                        TrainingExperience.INTERMEDIATE);

        HealthProfileResponse response = service.update(userId, updateRequest);

        assertThat(response.calculationStatus()).isEqualTo("COMPLETE");
        assertThat(response.profile().gender()).isEqualTo(Gender.FEMALE);
        assertThat(response.profile().calculationSex()).isEqualTo(CalculationSex.FEMALE);
        // Male (+5) to Female (-161) offset difference is exactly 166.00 kcal
        assertThat(initialCalc.bmrKcal().subtract(response.metrics().bmrKcal()))
                .isEqualByComparingTo("166.00");
    }

    @Test
    @DisplayName(
            "PUT /health/profile transitioning COMPLETE to INCOMPLETE deletes nutrition target and sets reason")
    void updateCompleteToIncompleteDeletesTarget() {
        Long userId = 1L;
        User user = new User("athlete@viegym.vn", "hash");
        UserProfile userProfile = new UserProfile(user, "Athlete");
        HealthCalculationResult initialCalc =
                calculator.calculate(
                        new com.viegym.health.domain.HealthCalculationInput(
                                LocalDate.of(1995, 5, 20),
                                CalculationSex.MALE,
                                new BigDecimal("175.00"),
                                new BigDecimal("70.00"),
                                ActivityLevel.MODERATE,
                                FitnessGoal.MAINTAIN_WEIGHT),
                        LocalDate.of(2026, 8, 31));

        HealthProfile profile =
                new HealthProfile(
                        user,
                        LocalDate.of(1995, 5, 20),
                        Gender.MALE,
                        CalculationSex.MALE,
                        new BigDecimal("175.00"),
                        new BigDecimal("70.00"),
                        ActivityLevel.MODERATE,
                        FitnessGoal.MAINTAIN_WEIGHT,
                        TrainingExperience.INTERMEDIATE,
                        initialCalc,
                        OffsetDateTime.now(clock));

        NutritionTarget existingTarget =
                new NutritionTarget(
                        user, profile, initialCalc.nutritionTarget(), OffsetDateTime.now(clock));

        when(healthProfiles.findByUserId(userId)).thenReturn(Optional.of(profile));
        when(userProfiles.findByUserId(userId)).thenReturn(Optional.of(userProfile));
        when(nutritionTargets.findByUserId(userId)).thenReturn(Optional.of(existingTarget));

        // Change calculationSex to UNSPECIFIED
        UpdateHealthProfileRequest updateRequest =
                new UpdateHealthProfileRequest(
                        LocalDate.of(1995, 5, 20),
                        Gender.OTHER,
                        CalculationSex.UNSPECIFIED,
                        new BigDecimal("175.00"),
                        ActivityLevel.MODERATE,
                        FitnessGoal.MAINTAIN_WEIGHT,
                        TrainingExperience.INTERMEDIATE);

        HealthProfileResponse response = service.update(userId, updateRequest);

        assertThat(response.calculationStatus()).isEqualTo("INCOMPLETE");
        assertThat(response.incompleteReason())
                .isEqualTo(
                        com.viegym.health.domain.HealthIncompleteReason.CALCULATION_SEX_REQUIRED);
        assertThat(response.metrics().bmi()).isNotNull();
        assertThat(response.metrics().bmrKcal()).isNull();
        assertThat(response.metrics().tdeeKcal()).isNull();
        assertThat(response.nutritionTarget()).isNull();

        // Verify existing target was deleted from repository
        verify(nutritionTargets).delete(existingTarget);
    }

    @Test
    @DisplayName(
            "PUT /health/profile transitioning INCOMPLETE to COMPLETE creates nutrition target")
    void updateIncompleteToCompleteCreatesTarget() {
        Long userId = 1L;
        User user = new User("athlete@viegym.vn", "hash");
        UserProfile userProfile = new UserProfile(user, "Athlete");
        HealthCalculationResult initialCalc =
                calculator.calculate(
                        new com.viegym.health.domain.HealthCalculationInput(
                                LocalDate.of(1995, 5, 20),
                                CalculationSex.UNSPECIFIED,
                                new BigDecimal("175.00"),
                                new BigDecimal("70.00"),
                                ActivityLevel.MODERATE,
                                FitnessGoal.MAINTAIN_WEIGHT),
                        LocalDate.of(2026, 8, 31));

        HealthProfile profile =
                new HealthProfile(
                        user,
                        LocalDate.of(1995, 5, 20),
                        Gender.OTHER,
                        CalculationSex.UNSPECIFIED,
                        new BigDecimal("175.00"),
                        new BigDecimal("70.00"),
                        ActivityLevel.MODERATE,
                        FitnessGoal.MAINTAIN_WEIGHT,
                        TrainingExperience.INTERMEDIATE,
                        initialCalc,
                        OffsetDateTime.now(clock));

        when(healthProfiles.findByUserId(userId)).thenReturn(Optional.of(profile));
        when(userProfiles.findByUserId(userId)).thenReturn(Optional.of(userProfile));
        when(nutritionTargets.findByUserId(userId)).thenReturn(Optional.empty());

        // Update with CalculationSex.MALE
        UpdateHealthProfileRequest updateRequest =
                new UpdateHealthProfileRequest(
                        LocalDate.of(1995, 5, 20),
                        Gender.MALE,
                        CalculationSex.MALE,
                        new BigDecimal("175.00"),
                        ActivityLevel.MODERATE,
                        FitnessGoal.MAINTAIN_WEIGHT,
                        TrainingExperience.INTERMEDIATE);

        HealthProfileResponse response = service.update(userId, updateRequest);

        assertThat(response.calculationStatus()).isEqualTo("COMPLETE");
        assertThat(response.incompleteReason()).isNull();
        assertThat(response.metrics().bmrKcal()).isNotNull();
        assertThat(response.metrics().tdeeKcal()).isNotNull();
        assertThat(response.nutritionTarget()).isNotNull();
        assertThat(response.nutritionTarget().caloriesKcal()).isNotNull();

        // Verify new target was saved
        verify(nutritionTargets).save(any(NutritionTarget.class));
    }
}
