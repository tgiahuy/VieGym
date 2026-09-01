package com.viegym.dashboard;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import com.viegym.dashboard.api.DashboardResponse;
import com.viegym.dashboard.application.DashboardService;
import com.viegym.health.api.WeightTrendPoint;
import com.viegym.health.api.WeightTrendResponse;
import com.viegym.health.application.WeightLogService;
import com.viegym.health.domain.ActivityLevel;
import com.viegym.health.domain.CalculationSex;
import com.viegym.health.domain.FitnessGoal;
import com.viegym.health.domain.Gender;
import com.viegym.health.domain.HealthCalculationResult;
import com.viegym.health.domain.HealthProfile;
import com.viegym.health.domain.HealthProfileRepository;
import com.viegym.health.domain.NutritionTarget;
import com.viegym.health.domain.NutritionTargetRepository;
import com.viegym.health.domain.TrainingExperience;
import com.viegym.health.domain.WeightTrendDirection;
import com.viegym.identity.User;
import com.viegym.identity.UserProfile;
import com.viegym.identity.UserProfileRepository;
import java.math.BigDecimal;
import java.time.Clock;
import java.time.Instant;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

class DashboardServiceTests {

    private UserProfileRepository userProfiles;
    private HealthProfileRepository healthProfiles;
    private NutritionTargetRepository nutritionTargets;
    private WeightLogService weightLogs;
    private Clock clock;
    private DashboardService service;

    @BeforeEach
    void setUp() {
        userProfiles = mock(UserProfileRepository.class);
        healthProfiles = mock(HealthProfileRepository.class);
        nutritionTargets = mock(NutritionTargetRepository.class);
        weightLogs = mock(WeightLogService.class);
        clock = Clock.fixed(Instant.parse("2026-08-31T10:00:00Z"), ZoneOffset.UTC);
        service =
                new DashboardService(
                        userProfiles, healthProfiles, nutritionTargets, weightLogs, clock);
    }

    @Test
    @DisplayName("GET /dashboard aggregates Health, Weight Trend, and Nutrition target cleanly")
    void getDashboardAggregatesAllSections() {
        Long userId = 1L;
        User user = new User("athlete@viegym.vn", "hash");
        UserProfile userProfile = new UserProfile(user, "Athlete");
        LocalDate today = LocalDate.of(2026, 8, 31);
        OffsetDateTime now = OffsetDateTime.now(clock);

        com.viegym.health.domain.NutritionTargetValues targetValues =
                new com.viegym.health.domain.NutritionTargetValues(
                        new BigDecimal("2157.00"),
                        new BigDecimal("140.00"),
                        new BigDecimal("264.44"),
                        new BigDecimal("59.92"));

        HealthCalculationResult calc =
                new HealthCalculationResult(
                        new BigDecimal("22.86"),
                        new BigDecimal("1650.00"),
                        new BigDecimal("2557.50"),
                        targetValues,
                        null);

        HealthProfile healthProfile =
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
                        calc,
                        now);

        NutritionTarget nutritionTarget =
                new NutritionTarget(user, healthProfile, targetValues, now);

        WeightTrendResponse trend =
                new WeightTrendResponse(
                        30,
                        today.minusDays(29),
                        today,
                        new BigDecimal("71.50"),
                        new BigDecimal("70.00"),
                        new BigDecimal("-1.50"),
                        WeightTrendDirection.DOWN,
                        true,
                        List.of(
                                new WeightTrendPoint(today.minusDays(10), new BigDecimal("71.50")),
                                new WeightTrendPoint(today, new BigDecimal("70.00"))));

        when(userProfiles.findByUserId(userId)).thenReturn(Optional.of(userProfile));
        when(healthProfiles.findByUserId(userId)).thenReturn(Optional.of(healthProfile));
        when(nutritionTargets.findByUserId(userId)).thenReturn(Optional.of(nutritionTarget));
        when(weightLogs.getTrend(userId, 30)).thenReturn(trend);

        DashboardResponse response = service.getDashboard(userId, today);

        assertThat(response.date()).isEqualTo(today);
        assertThat(response.body().currentWeightKg()).isEqualByComparingTo("70.00");
        assertThat(response.body().bmi()).isEqualByComparingTo("22.86");
        assertThat(response.body().trend()).isEqualTo("DOWN");

        assertThat(response.nutrition().target().caloriesKcal()).isEqualByComparingTo("2157.00");
        assertThat(response.nutrition().target().proteinG()).isEqualByComparingTo("140.00");
        assertThat(response.nutrition().hasMealPlan()).isFalse();

        assertThat(response.workout().today()).isEmpty();
        assertThat(response.workout().completion().windowFrom()).isEqualTo(today.minusDays(2));
        assertThat(response.workout().completion().windowTo()).isEqualTo(today);

        assertThat(response.recommendations()).isEmpty();
        assertThat(response.missingData()).containsExactly("MEAL_PLAN", "WORKOUT_SCHEDULE");
    }

    @Test
    @DisplayName(
            "GET /dashboard returns missingData without throwing error when health profile is missing")
    void getDashboardHandlesMissingHealthProfileGracefully() {
        Long userId = 2L;
        User user = new User("athlete2@viegym.vn", "hash");
        UserProfile userProfile = new UserProfile(user, "Athlete 2");
        LocalDate today = LocalDate.of(2026, 8, 31);

        when(userProfiles.findByUserId(userId)).thenReturn(Optional.of(userProfile));
        when(healthProfiles.findByUserId(userId)).thenReturn(Optional.empty());
        when(nutritionTargets.findByUserId(userId)).thenReturn(Optional.empty());

        DashboardResponse response = service.getDashboard(userId, today);

        assertThat(response.body().currentWeightKg()).isNull();
        assertThat(response.body().bmi()).isNull();
        assertThat(response.nutrition().target()).isNull();
        assertThat(response.missingData())
                .containsExactlyInAnyOrder("HEALTH_PROFILE", "MEAL_PLAN", "WORKOUT_SCHEDULE");
    }
}
