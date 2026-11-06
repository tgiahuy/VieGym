package com.viegym.ai;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.reset;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.viegym.ai.api.AiDtos;
import com.viegym.ai.application.AiCoachService;
import com.viegym.ai.application.AiPlanService;
import com.viegym.ai.infrastructure.AiProviderClient;
import com.viegym.common.error.ApiErrorCode;
import com.viegym.common.error.ApiException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

@Testcontainers
@SpringBootTest
class AiPlanServiceTests {
    @Container
    static final PostgreSQLContainer<?> POSTGRES =
            new PostgreSQLContainer<>("postgres:16.14-bookworm")
                    .withDatabaseName("viegym_ai_plan")
                    .withUsername("viegym_ai")
                    .withPassword("test_password");

    @DynamicPropertySource
    static void datasourceProperties(DynamicPropertyRegistry registry) {
        registry.add("SPRING_DATASOURCE_URL", POSTGRES::getJdbcUrl);
        registry.add("SPRING_DATASOURCE_USERNAME", POSTGRES::getUsername);
        registry.add("SPRING_DATASOURCE_PASSWORD", POSTGRES::getPassword);
    }

    @Autowired JdbcTemplate jdbc;
    @Autowired AiPlanService plans;
    @Autowired AiCoachService coach;
    @MockitoBean AiProviderClient provider;

    @BeforeEach
    void resetProvider() {
        reset(provider);
    }

    @Test
    void workoutPlanFromAiIsRestrictedToShortlistAndClamped() {
        Long userId = createUser("workout-ai");
        Long chest = exercise("Bench Press", "CHEST", "BARBELL");
        Long triceps = exercise("Rope Pushdown", "TRICEPS", "CABLE_MACHINE");
        Long legs = exercise("Back Squat", "QUADRICEPS", "BARBELL");
        when(provider.generate(any()))
                .thenReturn(
                        planResponse(
                                Map.of(
                                        "planTitle",
                                        "Ngực & Tay sau",
                                        "rationale",
                                        "Compound trước.",
                                        "exercises",
                                        List.of(
                                                planExercise(chest, 12, 8, 12, 5),
                                                planExercise(legs, 3, 8, 12, 90),
                                                planExercise(triceps, 3, 15, 10, 60)))));

        AiDtos.WorkoutPlan plan =
                plans.generateWorkout(
                        userId,
                        new AiDtos.GenerateWorkout(
                                null,
                                List.of("CHEST", "TRICEPS"),
                                null,
                                null,
                                45,
                                "MODERATE",
                                null),
                        "workout-ai-key");

        assertThat(plan.generatedBy()).isEqualTo("gemini");
        // 45 minutes needs at least 4 exercises: the two valid AI picks come first, then the
        // plan is topped up from the shortlist (never with the off-target squat).
        assertThat(plan.exercises())
                .extracting(AiDtos.WorkoutPlanExercise::exerciseId)
                .startsWith(chest, triceps)
                .doesNotContain(legs);
        AiDtos.WorkoutPlanExercise first = plan.exercises().getFirst();
        assertThat(first.targetSets()).isEqualTo(6);
        assertThat(first.restSeconds()).isEqualTo(30);
        assertThat(first.targetWeightKg()).isNull();
        AiDtos.WorkoutPlanExercise second = plan.exercises().get(1);
        assertThat(second.targetRepsMin()).isEqualTo(15);
        assertThat(second.targetRepsMax()).isEqualTo(15);

        ArgumentCaptor<AiProviderClient.ProviderRequest> captor =
                ArgumentCaptor.forClass(AiProviderClient.ProviderRequest.class);
        verify(provider).generate(captor.capture());
        assertThat(captor.getValue().requestType()).isEqualTo("WORKOUT_PLAN");
        List<Object> candidateIds =
                ((List<?>) captor.getValue().candidates().get("exercises"))
                        .stream()
                                .map(item -> ((Map<?, ?>) item).get("id"))
                                .map(Object.class::cast)
                                .toList();
        assertThat(candidateIds).contains(chest, triceps).doesNotContain(legs);
    }

    @Test
    void workoutFallsBackToHeuristicAndCanBeAppliedAndReplayed() {
        Long userId = createUser("workout-fallback");
        exercise("Push Up", "CHEST", null);
        exercise("Dumbbell Fly", "CHEST", "DUMBBELL");
        exercise("Machine Press", "CHEST", "MACHINE");
        when(provider.generate(any()))
                .thenThrow(new ApiException(ApiErrorCode.AI_PROVIDER_UNAVAILABLE, "provider down"));

        AiDtos.GenerateWorkout request =
                new AiDtos.GenerateWorkout(
                        null, List.of("CHEST"), null, List.of("DUMBBELL"), 30, "LIGHT", null);
        AiDtos.WorkoutPlan plan = plans.generateWorkout(userId, request, "fallback-key");
        AiDtos.WorkoutPlan replay = plans.generateWorkout(userId, request, "fallback-key");

        assertThat(plan.generatedBy()).isEqualTo("heuristic");
        assertThat(plan.exercises())
                .extracting(AiDtos.WorkoutPlanExercise::name)
                .containsExactlyInAnyOrder("Push Up", "Dumbbell Fly");
        assertThat(plan.exercises()).allMatch(ex -> ex.targetRepsMin() == 12);
        assertThat(plan.exercises())
                .flatExtracting(AiDtos.WorkoutPlanExercise::equipmentCodes)
                .containsOnly("BODYWEIGHT", "DUMBBELL");
        assertThat(replay.recommendationId()).isEqualTo(plan.recommendationId());

        AiDtos.RecommendationAction applied =
                coach.apply(
                        userId,
                        plan.recommendationId(),
                        new AiDtos.ApplyRecommendation(plan.version()),
                        "fallback-apply");
        assertThat(applied.mutationResult()).containsEntry("targetType", "WORKOUT_SCHEDULE");
        assertThat(
                        jdbc.queryForObject(
                                "select count(*) from workout_schedules where user_id = ? and source_type = 'AI'",
                                Integer.class,
                                userId))
                .isOne();
    }

    @Test
    void mealPlanRecomputesCaloriesFiltersAllergiesAndAppliesPerMeal() {
        Long userId = createUser("meal-ai");
        jdbc.update(
                "update user_preferences set allergies = '[\"Hải sản\"]' where user_id = ?",
                userId);
        coach.updateConsent(userId, new AiDtos.UpdateConsent("ENABLED", "v1.0", "AI_TAB"));
        when(provider.generate(any()))
                .thenAnswer(
                        invocation -> {
                            AiProviderClient.ProviderRequest request = invocation.getArgument(0);
                            Long foodId = AiCoachServiceTests.firstCandidateFoodId(request);
                            return planResponse(
                                    Map.of(
                                            "rationale",
                                            "Đủ đạm.",
                                            "meals",
                                            List.of(
                                                    Map.of(
                                                            "mealType",
                                                            "LUNCH",
                                                            "dishName",
                                                            "Bữa trưa AI",
                                                            "coachingReason",
                                                            "Nhiều đạm.",
                                                            "items",
                                                            List.of(
                                                                    Map.of(
                                                                            "foodId",
                                                                            foodId,
                                                                            "servingMultiplier",
                                                                            1)),
                                                            "calories",
                                                            99999))));
                        });

        AiDtos.MealPlan plan =
                plans.generateMeals(
                        userId,
                        new AiDtos.GenerateMeals(
                                null, List.of("LUNCH", "DINNER"), 30, "Muốn ăn món nước"),
                        "meal-key");

        assertThat(plan.personalized()).isTrue();
        assertThat(plan.generatedBy()).isEqualTo("mixed");
        assertThat(plan.meals())
                .extracting(AiDtos.MealPlanMeal::mealType)
                .containsExactly("LUNCH", "DINNER");
        AiDtos.MealPlanMeal lunch = plan.meals().getFirst();
        assertThat(lunch.generatedBy()).isEqualTo("gemini");
        // 2400 kcal target × 35% lunch share; the backend scales servings to within ±10%.
        assertThat(lunch.targetCalories()).isEqualTo(840);
        BigDecimal recomputed =
                lunch.items().stream()
                        .map(AiDtos.MealPlanItem::calories)
                        .reduce(BigDecimal.ZERO, BigDecimal::add);
        assertThat(lunch.calories()).isEqualByComparingTo(recomputed);
        assertThat(plan.meals().get(1).generatedBy()).isEqualTo("heuristic");
        assertThat(plan.meals())
                .flatExtracting(AiDtos.MealPlanMeal::items)
                .extracting(item -> item.name().toLowerCase())
                .noneMatch(name -> name.matches("(?U).*\\b(tôm|cá|mực|cua|hải sản)\\b.*"));

        ArgumentCaptor<AiProviderClient.ProviderRequest> captor =
                ArgumentCaptor.forClass(AiProviderClient.ProviderRequest.class);
        verify(provider).generate(captor.capture());
        assertThat(captor.getValue().messages())
                .containsExactly(Map.of("role", "USER", "content", "Muốn ăn món nước"));
        assertThat(captor.getValue().renderedPrompt()).doesNotContain("Muốn ăn món nước");

        AiDtos.RecommendationAction applied =
                coach.apply(
                        userId,
                        lunch.recommendationId(),
                        new AiDtos.ApplyRecommendation(lunch.version()),
                        "meal-apply");
        assertThat(applied.mutationResult()).containsEntry("targetType", "MEAL_PLAN");
        assertThat(
                        jdbc.queryForObject(
                                "select count(*) from meal_entries me join meals m on m.id = me.meal_id "
                                        + "join meal_plans p on p.id = m.meal_plan_id where p.user_id = ? and m.meal_type = 'LUNCH'",
                                Integer.class,
                                userId))
                .isEqualTo(lunch.items().size());
    }

    @Test
    void declaredInjuriesRemoveRiskyExercisesAndReachTheAiContext() {
        Long userId = createUser("injury");
        jdbc.update(
                "update user_preferences set injuries = '[\"LOWER_BACK\", \"SHOULDER\"]' where user_id = ?",
                userId);
        coach.updateConsent(userId, new AiDtos.UpdateConsent("ENABLED", "v1.0", "AI_TAB"));
        Long deadlift = exercise("Romanian Deadlift", "HAMSTRINGS", null);
        Long legCurl = exercise("Lying Leg Curl", "HAMSTRINGS", null);
        Long press = exercise("Seated Overhead Press", "SHOULDERS", null);
        Long lateral = exercise("Lateral Raise", "SHOULDERS", null);
        Long lowerBack = exercise("Bird Dog", "LOWER_BACK", null);
        when(provider.generate(any())).thenReturn(planResponse(null));

        plans.generateWorkout(
                userId,
                new AiDtos.GenerateWorkout(
                        null,
                        List.of("HAMSTRINGS", "SHOULDERS", "LOWER_BACK"),
                        null,
                        null,
                        45,
                        "MODERATE",
                        null),
                "injury-key");

        ArgumentCaptor<AiProviderClient.ProviderRequest> captor =
                ArgumentCaptor.forClass(AiProviderClient.ProviderRequest.class);
        verify(provider).generate(captor.capture());
        List<Object> candidateIds =
                ((List<?>) captor.getValue().candidates().get("exercises"))
                        .stream()
                                .map(item -> ((Map<?, ?>) item).get("id"))
                                .map(Object.class::cast)
                                .toList();
        assertThat(candidateIds)
                .contains(legCurl, lateral)
                .doesNotContain(deadlift, press, lowerBack);
        Map<?, ?> data = (Map<?, ?>) captor.getValue().context().get("data");
        assertThat(data.get("injuries")).isEqualTo(List.of("LOWER_BACK", "SHOULDER"));
    }

    @Test
    void planGenerationDoesNotConsumeDailyRecommendationQuota() {
        Long userId = createUser("quota");
        coach.updateConsent(userId, new AiDtos.UpdateConsent("ENABLED", "v1.0", "AI_TAB"));
        when(provider.generate(any())).thenReturn(planResponse(null));
        for (int index = 0; index < 4; index++) {
            plans.generateMeals(
                    userId,
                    new AiDtos.GenerateMeals(null, List.of("SNACK"), null, null),
                    "quota-meal-" + index);
        }

        assertThat(coach.getDaily(userId, LocalDate.now()).recommendations()).isEmpty();
        assertThat(
                        jdbc.queryForObject(
                                "select count(*) from ai_generation_batches where user_id = ? and purpose = 'MEAL_PLAN'",
                                Integer.class,
                                userId))
                .isEqualTo(4);
    }

    @Test
    void reusingAnIdempotencyKeyForADifferentRequestIsRejected() {
        Long userId = createUser("conflict");
        when(provider.generate(any())).thenReturn(planResponse(null));
        plans.generateMeals(
                userId, new AiDtos.GenerateMeals(null, List.of("SNACK"), null, null), "same-key");

        assertThatThrownBy(
                        () ->
                                plans.generateMeals(
                                        userId,
                                        new AiDtos.GenerateMeals(
                                                null, List.of("LUNCH"), null, null),
                                        "same-key"))
                .isInstanceOf(ApiException.class)
                .extracting(error -> ((ApiException) error).code())
                .isEqualTo(ApiErrorCode.IDEMPOTENCY_CONFLICT);
    }

    private static AiProviderClient.ProviderResponse planResponse(Map<String, Object> plan) {
        return new AiProviderClient.ProviderResponse(
                "corr", null, "NORMAL", List.of(), plan, Map.of("provider", "gemini"));
    }

    private static Map<String, Object> planExercise(
            Long id, int sets, int repsMin, int repsMax, int rest) {
        return Map.of(
                "exerciseId",
                id,
                "targetSets",
                sets,
                "targetRepsMin",
                repsMin,
                "targetRepsMax",
                repsMax,
                "restSeconds",
                rest,
                "targetWeightKg",
                80);
    }

    private Long exercise(String name, String muscle, String equipmentCode) {
        Long id =
                jdbc.queryForObject(
                        "insert into exercises (name, search_name, slug, difficulty, description) "
                                + "values (?, lower(?), ?, 'BEGINNER', 'Test exercise') returning id",
                        Long.class,
                        name,
                        name,
                        "ai-plan-" + UUID.randomUUID());
        jdbc.update(
                "insert into exercise_muscle_groups (exercise_id, muscle_group_id, role) "
                        + "select ?, id, 'PRIMARY' from muscle_groups where code = ?",
                id,
                muscle);
        if (equipmentCode != null) {
            jdbc.update(
                    "insert into exercise_equipment (exercise_id, equipment_id, is_required) "
                            + "values (?, ?, true)",
                    id,
                    equipmentId(equipmentCode));
        }
        return id;
    }

    private Long equipmentId(String code) {
        return jdbc.queryForObject("select id from equipment where code = ?", Long.class, code);
    }

    private Long createUser(String prefix) {
        String unique = prefix + "-" + UUID.randomUUID();
        Long userId =
                jdbc.queryForObject(
                        "insert into users (email, password_hash, auth_provider, role, status, email_verified_at) "
                                + "values (?, 'hash', 'LOCAL', 'USER', 'ACTIVE', now()) returning id",
                        Long.class,
                        unique + "@viegym.test");
        jdbc.update(
                "insert into user_profiles (user_id, display_name, timezone, locale) values (?, 'AI Plan', 'Asia/Ho_Chi_Minh', 'vi-VN')",
                userId);
        Long profileId =
                jdbc.queryForObject(
                        "insert into health_profiles (user_id, date_of_birth, gender, calculation_sex, height_cm, current_weight_kg, activity_level, fitness_goal, training_experience, bmi, bmr_kcal, tdee_kcal, calculation_version, calculated_at) "
                                + "values (?, '1995-01-01', 'MALE', 'MALE', 175, 70, 'MODERATE', 'GAIN_MUSCLE', 'INTERMEDIATE', 22.86, 1600, 2400, 'test-v1', now()) returning id",
                        Long.class,
                        userId);
        jdbc.update(
                "insert into nutrition_targets (user_id, health_profile_id, calories_kcal, protein_g, carbs_g, fat_g, calculation_version, effective_from) values (?, ?, 2400, 150, 300, 70, 'test-v1', now())",
                userId,
                profileId);
        jdbc.update(
                "insert into user_preferences (user_id, disliked_foods, allergies, dietary_constraints, meal_preferences, training_preferences) values (?, '[]', '[]', '[]', '{}', '{}')",
                userId);
        return userId;
    }
}
