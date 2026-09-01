package com.viegym.health;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import com.viegym.common.error.ApiValidationException;
import com.viegym.health.api.UpsertResult;
import com.viegym.health.api.UpsertWeightLogRequest;
import com.viegym.health.api.UpsertWeightLogResponse;
import com.viegym.health.application.WeightLogService;
import com.viegym.health.domain.ActivityLevel;
import com.viegym.health.domain.CalculationSex;
import com.viegym.health.domain.FitnessGoal;
import com.viegym.health.domain.Gender;
import com.viegym.health.domain.HealthCalculationResult;
import com.viegym.health.domain.HealthCalculator;
import com.viegym.health.domain.HealthProfile;
import com.viegym.health.domain.HealthProfileRepository;
import com.viegym.health.domain.TrainingExperience;
import com.viegym.health.domain.WeightLog;
import com.viegym.health.domain.WeightLogRepository;
import com.viegym.identity.User;
import com.viegym.identity.UserProfile;
import com.viegym.identity.UserProfileRepository;
import com.viegym.identity.UserRepository;
import java.lang.reflect.Field;
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

class WeightLogServiceTests {

    private UserRepository users;
    private UserProfileRepository userProfiles;
    private HealthProfileRepository healthProfiles;
    private WeightLogRepository weightLogs;
    private HealthCalculator calculator;
    private Clock clock;
    private WeightLogService service;

    @BeforeEach
    void setUp() {
        users = mock(UserRepository.class);
        userProfiles = mock(UserProfileRepository.class);
        healthProfiles = mock(HealthProfileRepository.class);
        weightLogs = mock(WeightLogRepository.class);
        calculator = new HealthCalculator();
        clock = Clock.fixed(Instant.parse("2026-08-31T10:00:00Z"), ZoneOffset.UTC);
        service =
                new WeightLogService(
                        users, userProfiles, healthProfiles, weightLogs, calculator, clock);
    }

    @Test
    @DisplayName(
            "PUT /weight-logs/{loggedDate} creates new log and syncs newest metrics when date is latest")
    void upsertCreatesNewLogAndSyncsMetrics() {
        Long userId = 1L;
        User user = new User("athlete@viegym.vn", "hash");
        UserProfile userProfile = new UserProfile(user, "Athlete");

        LocalDate today = LocalDate.of(2026, 8, 31);
        OffsetDateTime now = OffsetDateTime.now(clock);

        HealthCalculationResult initialCalc =
                calculator.calculate(
                        new com.viegym.health.domain.HealthCalculationInput(
                                LocalDate.of(1995, 5, 20),
                                CalculationSex.MALE,
                                new BigDecimal("175.00"),
                                new BigDecimal("70.00"),
                                ActivityLevel.MODERATE,
                                FitnessGoal.MAINTAIN_WEIGHT),
                        today);

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
                        now);

        WeightLog createdLog = new WeightLog(user, today, new BigDecimal("72.50"), "Morning", now);
        setId(createdLog, 100L);

        when(userProfiles.findByUserId(userId)).thenReturn(Optional.of(userProfile));
        when(users.findById(userId)).thenReturn(Optional.of(user));
        when(weightLogs.findByUserIdAndLoggedDate(userId, today)).thenReturn(Optional.empty());
        when(weightLogs.save(any(WeightLog.class))).thenReturn(createdLog);
        when(weightLogs.findFirstByUserIdOrderByLoggedDateDescUpdatedAtDesc(userId))
                .thenReturn(Optional.of(createdLog));
        when(healthProfiles.findByUserId(userId)).thenReturn(Optional.of(profile));

        UpsertWeightLogRequest request =
                new UpsertWeightLogRequest(new BigDecimal("72.50"), "Morning");

        UpsertResult<UpsertWeightLogResponse> result = service.upsert(userId, today, request);

        assertThat(result.created()).isTrue();
        assertThat(result.data().weightLog().weightKg()).isEqualByComparingTo("72.50");
        assertThat(result.data().weightLog().note()).isEqualTo("Morning");
        assertThat(result.data().metricsUpdated()).isTrue();
        assertThat(result.data().metrics()).isNotNull();
        assertThat(result.data().nutritionTargetChanged()).isFalse();

        // Profile current weight and BMI should be updated with new weight (72.50 kg)
        assertThat(profile.currentWeightKg()).isEqualByComparingTo("72.50");
        assertThat(profile.bmi()).isEqualByComparingTo("23.67");
    }

    @Test
    @DisplayName("PUT /weight-logs/{loggedDate} updates existing log idempotently")
    void upsertUpdatesExistingLog() {
        Long userId = 1L;
        User user = new User("athlete@viegym.vn", "hash");
        UserProfile userProfile = new UserProfile(user, "Athlete");

        LocalDate today = LocalDate.of(2026, 8, 31);
        OffsetDateTime now = OffsetDateTime.now(clock);

        WeightLog existingLog =
                new WeightLog(user, today, new BigDecimal("70.00"), "Old note", now);
        setId(existingLog, 50L);

        when(userProfiles.findByUserId(userId)).thenReturn(Optional.of(userProfile));
        when(users.findById(userId)).thenReturn(Optional.of(user));
        when(weightLogs.findByUserIdAndLoggedDate(userId, today))
                .thenReturn(Optional.of(existingLog));
        when(weightLogs.findFirstByUserIdOrderByLoggedDateDescUpdatedAtDesc(userId))
                .thenReturn(Optional.of(existingLog));
        when(healthProfiles.findByUserId(userId)).thenReturn(Optional.empty());

        UpsertWeightLogRequest request =
                new UpsertWeightLogRequest(new BigDecimal("70.50"), "Updated note");

        UpsertResult<UpsertWeightLogResponse> result = service.upsert(userId, today, request);

        assertThat(result.created()).isFalse();
        assertThat(existingLog.weightKg()).isEqualByComparingTo("70.50");
        assertThat(existingLog.note()).isEqualTo("Updated note");
    }

    @Test
    @DisplayName("PUT /weight-logs/{loggedDate} rejects future loggedDate")
    void upsertRejectsFutureLoggedDate() {
        Long userId = 1L;
        User user = new User("athlete@viegym.vn", "hash");
        UserProfile userProfile = new UserProfile(user, "Athlete");

        when(userProfiles.findByUserId(userId)).thenReturn(Optional.of(userProfile));

        LocalDate tomorrow = LocalDate.of(2026, 9, 1);
        UpsertWeightLogRequest request =
                new UpsertWeightLogRequest(new BigDecimal("70.00"), "Future note");

        assertThatThrownBy(() -> service.upsert(userId, tomorrow, request))
                .isInstanceOf(ApiValidationException.class)
                .satisfies(
                        ex -> {
                            ApiValidationException vex = (ApiValidationException) ex;
                            assertThat(vex.violations())
                                    .anyMatch(
                                            v ->
                                                    v.field().equals("loggedDate")
                                                            && v.message()
                                                                    .contains(
                                                                            "loggedDate must not be"
                                                                                    + " in the"
                                                                                    + " future"));
                        });
    }

    @Test
    @DisplayName(
            "PUT /weight-logs/{loggedDate} on older date does not change current health profile metrics")
    void upsertOlderDateDoesNotSyncMetrics() {
        Long userId = 1L;
        User user = new User("athlete@viegym.vn", "hash");
        UserProfile userProfile = new UserProfile(user, "Athlete");

        LocalDate today = LocalDate.of(2026, 8, 31);
        LocalDate oldDate = LocalDate.of(2026, 8, 15);
        OffsetDateTime now = OffsetDateTime.now(clock);

        HealthCalculationResult initialCalc =
                calculator.calculate(
                        new com.viegym.health.domain.HealthCalculationInput(
                                LocalDate.of(1995, 5, 20),
                                CalculationSex.MALE,
                                new BigDecimal("175.00"),
                                new BigDecimal("70.00"),
                                ActivityLevel.MODERATE,
                                FitnessGoal.MAINTAIN_WEIGHT),
                        today);

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
                        now);

        WeightLog newestLog = new WeightLog(user, today, new BigDecimal("70.00"), null, now);
        setId(newestLog, 999L);

        WeightLog createdOldLog = new WeightLog(user, oldDate, new BigDecimal("68.00"), "Old", now);
        setId(createdOldLog, 123L);

        when(userProfiles.findByUserId(userId)).thenReturn(Optional.of(userProfile));
        when(users.findById(userId)).thenReturn(Optional.of(user));
        when(weightLogs.findByUserIdAndLoggedDate(userId, oldDate)).thenReturn(Optional.empty());
        when(weightLogs.save(any(WeightLog.class))).thenReturn(createdOldLog);
        when(weightLogs.findFirstByUserIdOrderByLoggedDateDescUpdatedAtDesc(userId))
                .thenReturn(Optional.of(newestLog));

        UpsertWeightLogRequest request = new UpsertWeightLogRequest(new BigDecimal("68.00"), "Old");

        UpsertResult<UpsertWeightLogResponse> result = service.upsert(userId, oldDate, request);

        assertThat(result.created()).isTrue();
        assertThat(result.data().metricsUpdated()).isFalse();
        assertThat(result.data().metrics()).isNull();
        assertThat(result.data().nutritionTargetChanged()).isFalse();

        // Profile current weight remains unchanged (70.00 kg)
        assertThat(profile.currentWeightKg()).isEqualByComparingTo("70.00");
    }

    @Test
    @DisplayName("GET /weight-logs returns paginated list of logs ordered by loggedDate desc")
    void listReturnsPaginatedLogs() {
        Long userId = 1L;
        User user = new User("athlete@viegym.vn", "hash");
        OffsetDateTime now = OffsetDateTime.now(clock);

        WeightLog log1 =
                new WeightLog(
                        user, LocalDate.of(2026, 8, 31), new BigDecimal("70.50"), "Day 2", now);
        setId(log1, 1L);
        WeightLog log2 =
                new WeightLog(
                        user, LocalDate.of(2026, 8, 30), new BigDecimal("71.00"), "Day 1", now);
        setId(log2, 2L);

        org.springframework.data.domain.PageRequest pageRequest =
                org.springframework.data.domain.PageRequest.of(0, 10);
        org.springframework.data.domain.Page<WeightLog> page =
                new org.springframework.data.domain.PageImpl<>(
                        java.util.List.of(log1, log2), pageRequest, 2);

        when(weightLogs.findByUserIdOrderByLoggedDateDescUpdatedAtDesc(userId, pageRequest))
                .thenReturn(page);

        com.viegym.common.api.PageResponse<com.viegym.health.api.WeightLogDto> response =
                service.list(userId, null, null, pageRequest);

        assertThat(response.content()).hasSize(2);
        assertThat(response.totalElements()).isEqualTo(2);
        assertThat(response.content().get(0).weightKg()).isEqualByComparingTo("70.50");
        assertThat(response.content().get(1).weightKg()).isEqualByComparingTo("71.00");
    }

    @Test
    @DisplayName("GET /weight-logs/trend calculates change and direction when >= 2 points exist")
    void getTrendCalculatesTrendWithSufficientData() {
        Long userId = 1L;
        User user = new User("athlete@viegym.vn", "hash");
        UserProfile userProfile = new UserProfile(user, "Athlete");
        OffsetDateTime now = OffsetDateTime.now(clock);

        LocalDate to = LocalDate.of(2026, 8, 31);
        LocalDate from = to.minusDays(29);

        WeightLog log1 =
                new WeightLog(user, LocalDate.of(2026, 8, 10), new BigDecimal("72.00"), null, now);
        WeightLog log2 =
                new WeightLog(user, LocalDate.of(2026, 8, 31), new BigDecimal("70.50"), null, now);

        when(userProfiles.findByUserId(userId)).thenReturn(Optional.of(userProfile));
        when(weightLogs.findByUserIdAndLoggedDateBetweenOrderByLoggedDateAsc(userId, from, to))
                .thenReturn(java.util.List.of(log1, log2));

        com.viegym.health.api.WeightTrendResponse trend = service.getTrend(userId, 30);

        assertThat(trend.sufficientData()).isTrue();
        assertThat(trend.days()).isEqualTo(30);
        assertThat(trend.startWeightKg()).isEqualByComparingTo("72.00");
        assertThat(trend.currentWeightKg()).isEqualByComparingTo("70.50");
        assertThat(trend.changeKg()).isEqualByComparingTo("-1.50");
        assertThat(trend.direction()).isEqualTo(com.viegym.health.domain.WeightTrendDirection.DOWN);
        assertThat(trend.points()).hasSize(2);
    }

    @Test
    @DisplayName("GET /weight-logs/trend returns insufficientData=false when < 2 points exist")
    void getTrendReturnsInsufficientDataWhenFewerThanTwoPoints() {
        Long userId = 1L;
        User user = new User("athlete@viegym.vn", "hash");
        UserProfile userProfile = new UserProfile(user, "Athlete");
        OffsetDateTime now = OffsetDateTime.now(clock);

        LocalDate to = LocalDate.of(2026, 8, 31);
        LocalDate from = to.minusDays(6);

        WeightLog log1 =
                new WeightLog(user, LocalDate.of(2026, 8, 31), new BigDecimal("70.50"), null, now);

        when(userProfiles.findByUserId(userId)).thenReturn(Optional.of(userProfile));
        when(weightLogs.findByUserIdAndLoggedDateBetweenOrderByLoggedDateAsc(userId, from, to))
                .thenReturn(java.util.List.of(log1));

        com.viegym.health.api.WeightTrendResponse trend = service.getTrend(userId, 7);

        assertThat(trend.sufficientData()).isFalse();
        assertThat(trend.days()).isEqualTo(7);
        assertThat(trend.startWeightKg()).isEqualByComparingTo("70.50");
        assertThat(trend.currentWeightKg()).isEqualByComparingTo("70.50");
        assertThat(trend.changeKg()).isNull();
        assertThat(trend.direction()).isNull();
        assertThat(trend.points()).hasSize(1);
    }

    private static void setId(Object entity, Long id) {
        try {
            Field field = entity.getClass().getDeclaredField("id");
            field.setAccessible(true);
            field.set(entity, id);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
