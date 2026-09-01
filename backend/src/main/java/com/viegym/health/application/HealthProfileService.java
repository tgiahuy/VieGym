package com.viegym.health.application;

import com.viegym.common.api.FieldViolation;
import com.viegym.common.error.ApiErrorCode;
import com.viegym.common.error.ApiException;
import com.viegym.common.error.ApiValidationException;
import com.viegym.health.api.CreateHealthProfileRequest;
import com.viegym.health.api.HealthProfileResponse;
import com.viegym.health.domain.CalculationSex;
import com.viegym.health.domain.HealthCalculationInput;
import com.viegym.health.domain.HealthCalculationResult;
import com.viegym.health.domain.HealthCalculator;
import com.viegym.health.domain.HealthIncompleteReason;
import com.viegym.health.domain.HealthProfile;
import com.viegym.health.domain.HealthProfileRepository;
import com.viegym.health.domain.NutritionTarget;
import com.viegym.health.domain.NutritionTargetRepository;
import com.viegym.health.domain.NutritionTargetValues;
import com.viegym.health.domain.WeightLog;
import com.viegym.health.domain.WeightLogRepository;
import com.viegym.identity.User;
import com.viegym.identity.UserProfile;
import com.viegym.identity.UserProfileRepository;
import com.viegym.identity.UserRepository;
import java.time.Clock;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class HealthProfileService {

    private final UserRepository users;
    private final UserProfileRepository userProfiles;
    private final HealthProfileRepository healthProfiles;
    private final NutritionTargetRepository nutritionTargets;
    private final WeightLogRepository weightLogs;
    private final HealthCalculator calculator;
    private final Clock clock;

    public HealthProfileService(
            UserRepository users,
            UserProfileRepository userProfiles,
            HealthProfileRepository healthProfiles,
            NutritionTargetRepository nutritionTargets,
            WeightLogRepository weightLogs,
            HealthCalculator calculator,
            Clock clock) {
        this.users = users;
        this.userProfiles = userProfiles;
        this.healthProfiles = healthProfiles;
        this.nutritionTargets = nutritionTargets;
        this.weightLogs = weightLogs;
        this.calculator = calculator;
        this.clock = clock;
    }

    @Transactional
    public HealthProfileResponse create(Long userId, CreateHealthProfileRequest request) {
        if (healthProfiles.existsByUserId(userId)) {
            throw new ApiException(
                    ApiErrorCode.INVALID_STATE_TRANSITION, "Health profile already exists");
        }
        User user =
                users.findById(userId)
                        .orElseThrow(
                                () ->
                                        new ApiException(
                                                ApiErrorCode.RESOURCE_NOT_FOUND,
                                                "User profile not found"));
        UserProfile userProfile =
                userProfiles
                        .findByUserId(userId)
                        .orElseThrow(
                                () ->
                                        new ApiException(
                                                ApiErrorCode.RESOURCE_NOT_FOUND,
                                                "User profile not found"));
        ZoneId timezone = ZoneId.of(userProfile.timezone());
        LocalDate calculationDate = LocalDate.now(clock.withZone(timezone));
        if (request.dateOfBirth().isAfter(calculationDate)) {
            throw new ApiValidationException(
                    java.util.List.of(
                            new FieldViolation(
                                    "dateOfBirth",
                                    "PAST_OR_PRESENT",
                                    "dateOfBirth must not be in the future")));
        }
        OffsetDateTime now = OffsetDateTime.now(clock);
        HealthCalculationResult result =
                calculator.calculate(
                        new HealthCalculationInput(
                                request.dateOfBirth(),
                                request.normalizedCalculationSex(),
                                request.heightCm(),
                                request.currentWeightKg(),
                                request.activityLevel(),
                                request.fitnessGoal()),
                        calculationDate);
        HealthProfile profile =
                healthProfiles.save(
                        new HealthProfile(
                                user,
                                request.dateOfBirth(),
                                request.gender(),
                                request.normalizedCalculationSex(),
                                request.heightCm(),
                                request.currentWeightKg(),
                                request.activityLevel(),
                                request.fitnessGoal(),
                                request.trainingExperience(),
                                result,
                                now));
        if (result.complete()) {
            nutritionTargets.save(
                    new NutritionTarget(user, profile, result.nutritionTarget(), now));
        }
        weightLogs.save(new WeightLog(user, calculationDate, request.currentWeightKg(), now));
        return response(request, result, now);
    }

    @Transactional(readOnly = true)
    public HealthProfileResponse get(Long userId) {
        HealthProfile profile =
                healthProfiles
                        .findByUserId(userId)
                        .orElseThrow(
                                () ->
                                        new ApiException(
                                                ApiErrorCode.RESOURCE_NOT_FOUND,
                                                "Health profile not found"));
        NutritionTarget target = nutritionTargets.findByUserId(userId).orElse(null);
        boolean isComplete = profile.bmrKcal() != null;
        HealthIncompleteReason incompleteReason = null;
        if (!isComplete) {
            if (profile.calculationSex() == CalculationSex.UNSPECIFIED) {
                incompleteReason = HealthIncompleteReason.CALCULATION_SEX_REQUIRED;
            } else {
                incompleteReason = HealthIncompleteReason.UNSUPPORTED_AGE;
            }
        }

        return new HealthProfileResponse(
                new HealthProfileResponse.Profile(
                        profile.dateOfBirth(),
                        profile.gender(),
                        profile.calculationSex(),
                        profile.heightCm(),
                        profile.currentWeightKg(),
                        profile.activityLevel(),
                        profile.fitnessGoal(),
                        profile.trainingExperience(),
                        profile.calculationVersion(),
                        profile.calculatedAt()),
                isComplete ? "COMPLETE" : "INCOMPLETE",
                new HealthProfileResponse.Metrics(
                        profile.bmi(), profile.bmrKcal(), profile.tdeeKcal()),
                target == null
                        ? null
                        : new HealthProfileResponse.NutritionTarget(
                                target.caloriesKcal(),
                                target.proteinG(),
                                target.carbsG(),
                                target.fatG()),
                incompleteReason);
    }

    @Transactional
    public HealthProfileResponse update(
            Long userId, com.viegym.health.api.UpdateHealthProfileRequest request) {
        HealthProfile profile =
                healthProfiles
                        .findByUserId(userId)
                        .orElseThrow(
                                () ->
                                        new ApiException(
                                                ApiErrorCode.RESOURCE_NOT_FOUND,
                                                "Health profile not found"));
        UserProfile userProfile =
                userProfiles
                        .findByUserId(userId)
                        .orElseThrow(
                                () ->
                                        new ApiException(
                                                ApiErrorCode.RESOURCE_NOT_FOUND,
                                                "User profile not found"));
        ZoneId timezone = ZoneId.of(userProfile.timezone());
        LocalDate calculationDate = LocalDate.now(clock.withZone(timezone));
        if (request.dateOfBirth().isAfter(calculationDate)) {
            throw new ApiValidationException(
                    java.util.List.of(
                            new FieldViolation(
                                    "dateOfBirth",
                                    "PAST_OR_PRESENT",
                                    "dateOfBirth must not be in the future")));
        }
        OffsetDateTime now = OffsetDateTime.now(clock);
        HealthCalculationResult result =
                calculator.calculate(
                        new HealthCalculationInput(
                                request.dateOfBirth(),
                                request.normalizedCalculationSex(),
                                request.heightCm(),
                                profile.currentWeightKg(),
                                request.activityLevel(),
                                request.fitnessGoal()),
                        calculationDate);
        profile.update(
                request.dateOfBirth(),
                request.gender(),
                request.normalizedCalculationSex(),
                request.heightCm(),
                request.activityLevel(),
                request.fitnessGoal(),
                request.trainingExperience(),
                result,
                now);
        if (result.complete()) {
            nutritionTargets
                    .findByUserId(userId)
                    .ifPresentOrElse(
                            t -> t.update(result.nutritionTarget(), now),
                            () ->
                                    nutritionTargets.save(
                                            new NutritionTarget(
                                                    profile.user(),
                                                    profile,
                                                    result.nutritionTarget(),
                                                    now)));
        } else {
            nutritionTargets.findByUserId(userId).ifPresent(nutritionTargets::delete);
        }
        NutritionTargetValues target = result.nutritionTarget();
        return new HealthProfileResponse(
                new HealthProfileResponse.Profile(
                        profile.dateOfBirth(),
                        profile.gender(),
                        profile.calculationSex(),
                        profile.heightCm(),
                        profile.currentWeightKg(),
                        profile.activityLevel(),
                        profile.fitnessGoal(),
                        profile.trainingExperience(),
                        HealthCalculator.VERSION,
                        now),
                result.complete() ? "COMPLETE" : "INCOMPLETE",
                new HealthProfileResponse.Metrics(
                        result.bmi(), result.bmrKcal(), result.tdeeKcal()),
                target == null
                        ? null
                        : new HealthProfileResponse.NutritionTarget(
                                target.caloriesKcal(),
                                target.proteinG(),
                                target.carbsG(),
                                target.fatG()),
                result.incompleteReason());
    }

    private HealthProfileResponse response(
            CreateHealthProfileRequest request,
            HealthCalculationResult result,
            OffsetDateTime calculatedAt) {
        NutritionTargetValues target = result.nutritionTarget();
        return new HealthProfileResponse(
                new HealthProfileResponse.Profile(
                        request.dateOfBirth(),
                        request.gender(),
                        request.normalizedCalculationSex(),
                        request.heightCm(),
                        request.currentWeightKg(),
                        request.activityLevel(),
                        request.fitnessGoal(),
                        request.trainingExperience(),
                        HealthCalculator.VERSION,
                        calculatedAt),
                result.complete() ? "COMPLETE" : "INCOMPLETE",
                new HealthProfileResponse.Metrics(
                        result.bmi(), result.bmrKcal(), result.tdeeKcal()),
                target == null
                        ? null
                        : new HealthProfileResponse.NutritionTarget(
                                target.caloriesKcal(),
                                target.proteinG(),
                                target.carbsG(),
                                target.fatG()),
                result.incompleteReason());
    }
}
