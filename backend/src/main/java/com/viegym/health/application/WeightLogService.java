package com.viegym.health.application;

import com.viegym.common.api.FieldViolation;
import com.viegym.common.error.ApiErrorCode;
import com.viegym.common.error.ApiException;
import com.viegym.common.error.ApiValidationException;
import com.viegym.health.api.HealthProfileResponse;
import com.viegym.health.api.UpsertResult;
import com.viegym.health.api.UpsertWeightLogRequest;
import com.viegym.health.api.UpsertWeightLogResponse;
import com.viegym.health.api.WeightLogDto;
import com.viegym.health.api.WeightTrendPoint;
import com.viegym.health.api.WeightTrendResponse;
import com.viegym.health.domain.HealthCalculationInput;
import com.viegym.health.domain.HealthCalculationResult;
import com.viegym.health.domain.HealthCalculator;
import com.viegym.health.domain.HealthProfile;
import com.viegym.health.domain.HealthProfileRepository;
import com.viegym.health.domain.WeightLog;
import com.viegym.health.domain.WeightLogRepository;
import com.viegym.identity.User;
import com.viegym.identity.UserProfile;
import com.viegym.identity.UserProfileRepository;
import com.viegym.identity.UserRepository;
import java.math.BigDecimal;
import java.time.Clock;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.util.List;
import java.util.Optional;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class WeightLogService {

    private final UserRepository users;
    private final UserProfileRepository userProfiles;
    private final HealthProfileRepository healthProfiles;
    private final WeightLogRepository weightLogs;
    private final HealthCalculator calculator;
    private final Clock clock;

    public WeightLogService(
            UserRepository users,
            UserProfileRepository userProfiles,
            HealthProfileRepository healthProfiles,
            WeightLogRepository weightLogs,
            HealthCalculator calculator,
            Clock clock) {
        this.users = users;
        this.userProfiles = userProfiles;
        this.healthProfiles = healthProfiles;
        this.weightLogs = weightLogs;
        this.calculator = calculator;
        this.clock = clock;
    }

    @Transactional
    public UpsertResult<UpsertWeightLogResponse> upsert(
            Long userId, LocalDate loggedDate, UpsertWeightLogRequest request) {
        UserProfile userProfile =
                userProfiles
                        .findByUserId(userId)
                        .orElseThrow(
                                () ->
                                        new ApiException(
                                                ApiErrorCode.RESOURCE_NOT_FOUND,
                                                "User profile not found"));
        ZoneId timezone = ZoneId.of(userProfile.timezone());
        LocalDate today = LocalDate.now(clock.withZone(timezone));
        if (loggedDate.isAfter(today)) {
            throw new ApiValidationException(
                    List.of(
                            new FieldViolation(
                                    "loggedDate",
                                    "PAST_OR_PRESENT",
                                    "loggedDate must not be in the future")));
        }

        User user =
                users.findById(userId)
                        .orElseThrow(
                                () ->
                                        new ApiException(
                                                ApiErrorCode.RESOURCE_NOT_FOUND,
                                                "User profile not found"));

        OffsetDateTime now = OffsetDateTime.now(clock);
        Optional<WeightLog> existing = weightLogs.findByUserIdAndLoggedDate(userId, loggedDate);
        boolean created = existing.isEmpty();

        WeightLog log;
        if (created) {
            log =
                    weightLogs.save(
                            new WeightLog(
                                    user, loggedDate, request.weightKg(), request.note(), now));
        } else {
            log = existing.get();
            log.update(request.weightKg(), request.note(), now);
        }

        // Check if this log is the newest log (by loggedDate DESC, updatedAt DESC)
        WeightLog newest =
                weightLogs.findFirstByUserIdOrderByLoggedDateDescUpdatedAtDesc(userId).orElse(log);

        boolean isNewest = newest.id().equals(log.id());
        boolean metricsUpdated = false;
        HealthProfileResponse.Metrics metrics = null;

        if (isNewest) {
            Optional<HealthProfile> profileOpt = healthProfiles.findByUserId(userId);
            if (profileOpt.isPresent()) {
                HealthProfile profile = profileOpt.get();
                HealthCalculationResult calc =
                        calculator.calculate(
                                new HealthCalculationInput(
                                        profile.dateOfBirth(),
                                        profile.calculationSex(),
                                        profile.heightCm(),
                                        log.weightKg(),
                                        profile.activityLevel(),
                                        profile.fitnessGoal()),
                                today);
                profile.updateCurrentWeight(log.weightKg(), calc, now);
                metricsUpdated = true;
                metrics =
                        new HealthProfileResponse.Metrics(
                                calc.bmi(), calc.bmrKcal(), calc.tdeeKcal());
            }
        }

        UpsertWeightLogResponse response =
                new UpsertWeightLogResponse(toDto(log), metricsUpdated, metrics, false);
        return new UpsertResult<>(response, created);
    }

    @Transactional(readOnly = true)
    public com.viegym.common.api.PageResponse<WeightLogDto> list(
            Long userId,
            LocalDate from,
            LocalDate to,
            org.springframework.data.domain.Pageable pageable) {
        org.springframework.data.domain.Page<WeightLog> page;
        if (from != null && to != null) {
            page =
                    weightLogs.findByUserIdAndLoggedDateBetweenOrderByLoggedDateDescUpdatedAtDesc(
                            userId, from, to, pageable);
        } else if (from != null) {
            page =
                    weightLogs
                            .findByUserIdAndLoggedDateGreaterThanEqualOrderByLoggedDateDescUpdatedAtDesc(
                                    userId, from, pageable);
        } else if (to != null) {
            page =
                    weightLogs
                            .findByUserIdAndLoggedDateLessThanEqualOrderByLoggedDateDescUpdatedAtDesc(
                                    userId, to, pageable);
        } else {
            page = weightLogs.findByUserIdOrderByLoggedDateDescUpdatedAtDesc(userId, pageable);
        }
        return com.viegym.common.api.PageResponse.from(page.map(this::toDto));
    }

    @Transactional(readOnly = true)
    public WeightTrendResponse getTrend(Long userId, Integer daysParam) {
        int days = (daysParam == null || daysParam <= 0) ? 30 : daysParam;
        if (days != 7 && days != 14 && days != 30) {
            days = 30;
        }
        UserProfile userProfile =
                userProfiles
                        .findByUserId(userId)
                        .orElseThrow(
                                () ->
                                        new ApiException(
                                                ApiErrorCode.RESOURCE_NOT_FOUND,
                                                "User profile not found"));
        ZoneId timezone = ZoneId.of(userProfile.timezone());
        LocalDate to = LocalDate.now(clock.withZone(timezone));
        LocalDate from = to.minusDays(days - 1);

        List<WeightLog> logs =
                weightLogs.findByUserIdAndLoggedDateBetweenOrderByLoggedDateAsc(userId, from, to);

        List<WeightTrendPoint> points =
                logs.stream().map(l -> new WeightTrendPoint(l.loggedDate(), l.weightKg())).toList();

        if (points.size() < 2) {
            BigDecimal start = points.isEmpty() ? null : points.getFirst().weightKg();
            BigDecimal current = points.isEmpty() ? null : points.getLast().weightKg();
            return new WeightTrendResponse(
                    days, from, to, start, current, null, null, false, points);
        }

        BigDecimal startWeight = points.getFirst().weightKg();
        BigDecimal currentWeight = points.getLast().weightKg();
        BigDecimal change = currentWeight.subtract(startWeight);

        com.viegym.health.domain.WeightTrendDirection direction;
        if (change.signum() < 0) {
            direction = com.viegym.health.domain.WeightTrendDirection.DOWN;
        } else if (change.signum() > 0) {
            direction = com.viegym.health.domain.WeightTrendDirection.UP;
        } else {
            direction = com.viegym.health.domain.WeightTrendDirection.STABLE;
        }

        return new WeightTrendResponse(
                days, from, to, startWeight, currentWeight, change, direction, true, points);
    }

    private WeightLogDto toDto(WeightLog log) {
        return new WeightLogDto(
                log.id(),
                log.loggedDate(),
                log.weightKg(),
                log.note(),
                log.createdAt(),
                log.updatedAt());
    }
}
