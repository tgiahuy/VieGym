package com.viegym.dashboard.application;

import com.viegym.dashboard.api.BodySection;
import com.viegym.dashboard.api.DashboardResponse;
import com.viegym.dashboard.api.NutritionMacroSummary;
import com.viegym.dashboard.api.NutritionSection;
import com.viegym.dashboard.api.WorkoutCompletion;
import com.viegym.dashboard.api.WorkoutSection;
import com.viegym.health.api.WeightTrendResponse;
import com.viegym.health.application.WeightLogService;
import com.viegym.health.domain.HealthProfile;
import com.viegym.health.domain.HealthProfileRepository;
import com.viegym.identity.UserProfile;
import com.viegym.identity.UserProfileRepository;
import com.viegym.nutrition.api.NutritionDtos;
import com.viegym.nutrition.application.NutritionService;
import java.time.Clock;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Optional;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class DashboardService {

    private final UserProfileRepository userProfiles;
    private final HealthProfileRepository healthProfiles;
    private final WeightLogService weightLogs;
    private final NutritionService mealNutrition;
    private final Clock clock;

    public DashboardService(
            UserProfileRepository userProfiles,
            HealthProfileRepository healthProfiles,
            WeightLogService weightLogs,
            NutritionService mealNutrition,
            Clock clock) {
        this.userProfiles = userProfiles;
        this.healthProfiles = healthProfiles;
        this.weightLogs = weightLogs;
        this.mealNutrition = mealNutrition;
        this.clock = clock;
    }

    @Transactional(readOnly = true)
    public DashboardResponse getDashboard(Long userId, LocalDate requestedDate) {
        Optional<UserProfile> userProfileOpt = userProfiles.findByUserId(userId);
        ZoneId timezone =
                userProfileOpt
                        .map(UserProfile::timezone)
                        .map(ZoneId::of)
                        .orElse(ZoneId.of("Asia/Ho_Chi_Minh"));

        LocalDate date =
                requestedDate != null ? requestedDate : LocalDate.now(clock.withZone(timezone));

        List<String> missingData = new ArrayList<>();

        // 1. Health & Body Section
        Optional<HealthProfile> healthProfileOpt = healthProfiles.findByUserId(userId);
        BodySection body;
        if (healthProfileOpt.isPresent()) {
            HealthProfile hp = healthProfileOpt.get();
            WeightTrendResponse trend = weightLogs.getTrend(userId, 30);
            String trendDirection =
                    trend.sufficientData() && trend.direction() != null
                            ? trend.direction().name()
                            : null;
            body = new BodySection(hp.currentWeightKg(), hp.bmi(), trendDirection);
        } else {
            missingData.add("HEALTH_PROFILE");
            body = new BodySection(null, null, null);
        }

        // 2. Nutrition Section
        NutritionSection nutrition;
        NutritionDtos.MealPlan mealPlan = mealNutrition.getMealPlan(userId, date);
        if (mealPlan.target() != null) {
            NutritionMacroSummary targetSummary = summary(mealPlan.target());
            NutritionMacroSummary consumedSummary = summary(mealPlan.consumed());
            NutritionMacroSummary remainingSummary = summary(mealPlan.remaining());
            boolean hasMealPlan = mealPlan.id() != null;
            nutrition =
                    new NutritionSection(
                            targetSummary, consumedSummary, remainingSummary, hasMealPlan);
            if (!hasMealPlan) missingData.add("MEAL_PLAN");
        } else {
            missingData.add("MEAL_PLAN");
            nutrition = new NutritionSection(null, null, null, false);
        }

        // 3. Workout Section
        missingData.add("WORKOUT_SCHEDULE");
        WorkoutCompletion completion = new WorkoutCompletion(date.minusDays(2), date, 0, 0, null);
        WorkoutSection workout = new WorkoutSection(Collections.emptyList(), null, completion);

        OffsetDateTime generatedAt = OffsetDateTime.now(clock);

        return new DashboardResponse(
                date, nutrition, workout, body, Collections.emptyList(), missingData, generatedAt);
    }

    private static NutritionMacroSummary summary(NutritionDtos.Nutrition value) {
        return new NutritionMacroSummary(
                value.caloriesKcal(), value.proteinG(), value.carbsG(), value.fatG());
    }
}
