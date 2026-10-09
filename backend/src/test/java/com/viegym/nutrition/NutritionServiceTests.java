package com.viegym.nutrition;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.viegym.common.error.ApiException;
import com.viegym.dashboard.api.DashboardResponse;
import com.viegym.dashboard.application.DashboardService;
import com.viegym.nutrition.api.ApplyMealTemplateRequest;
import com.viegym.nutrition.api.CreateMealTemplateRequest;
import com.viegym.nutrition.api.MealEntryRequest;
import com.viegym.nutrition.api.NutritionDtos;
import com.viegym.nutrition.application.NutritionService;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.data.domain.PageRequest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

@Testcontainers
@SpringBootTest
class NutritionServiceTests {
    @Container
    static final PostgreSQLContainer<?> POSTGRES =
            new PostgreSQLContainer<>("postgres:16.14-bookworm")
                    .withDatabaseName("viegym_nutrition_service")
                    .withUsername("viegym_nutrition")
                    .withPassword("test_password");

    @DynamicPropertySource
    static void datasourceProperties(DynamicPropertyRegistry registry) {
        registry.add("SPRING_DATASOURCE_URL", POSTGRES::getJdbcUrl);
        registry.add("SPRING_DATASOURCE_USERNAME", POSTGRES::getUsername);
        registry.add("SPRING_DATASOURCE_PASSWORD", POSTGRES::getPassword);
    }

    @Autowired JdbcTemplate jdbc;
    @Autowired NutritionService service;
    @Autowired DashboardService dashboardService;

    @Test
    void emptyGetIsReadOnlyAndMutationCreatesImmutableTargetSnapshot() {
        Long userId = createUserWithTarget("snapshot", "2200");
        Long foodId = createFood("snapshot-food", "PUBLIC", "200", "400");
        LocalDate date = LocalDate.of(2026, 9, 17);

        NutritionDtos.MealPlan empty = service.getMealPlan(userId, date);
        assertThat(empty.id()).isNull();
        assertThat(empty.targetSource()).isEqualTo("CURRENT");
        assertThat(
                        jdbc.queryForObject(
                                "select count(*) from meal_plans where user_id = ?",
                                Integer.class,
                                userId))
                .isZero();

        NutritionDtos.MealPlan created =
                service.addEntry(
                        userId,
                        date,
                        new MealEntryRequest(
                                "BREAKFAST", 1, foodId, null, new BigDecimal("100"), "GRAM", null));
        assertThat(created.id()).isNotNull();
        assertThat(created.targetSource()).isEqualTo("SNAPSHOT");
        assertThat(created.consumed().caloriesKcal()).isEqualByComparingTo("200.00");
        assertThat(created.meals().getFirst().entries().getFirst().servingMultiplier())
                .isEqualByComparingTo("0.500");

        jdbc.update("update nutrition_targets set calories_kcal = 1800 where user_id = ?", userId);
        jdbc.update(
                "update foods set name = 'Tên đã sửa', calories_per_serving = 999 where id = ?",
                foodId);
        NutritionDtos.MealPlan history = service.getMealPlan(userId, date);
        assertThat(history.target().caloriesKcal()).isEqualByComparingTo("2200");
        assertThat(history.consumed().caloriesKcal()).isEqualByComparingTo("200.00");
        assertThat(history.meals().getFirst().entries().getFirst().foodName())
                .isEqualTo("snapshot-food");
    }

    @Test
    void hiddenFoodIsExcludedFromCatalogFavoritesAndNewEntries() {
        Long userId = createUserWithTarget("hidden", "2200");
        Long hiddenId = createFood("hidden-food", "HIDDEN", "100", "100");

        assertThat(service.searchFoods("hidden-food", null, PageRequest.of(0, 20)).content())
                .isEmpty();
        assertThatThrownBy(() -> service.getFood(hiddenId)).isInstanceOf(ApiException.class);
        assertThatThrownBy(() -> service.addFavorite(userId, hiddenId))
                .isInstanceOf(ApiException.class);
        assertThatThrownBy(
                        () ->
                                service.addEntry(
                                        userId, LocalDate.of(2026, 9, 18), standardEntry(hiddenId)))
                .isInstanceOf(ApiException.class);
    }

    @Test
    void favoritesAreIdempotentAndScopedByOwner() {
        Long first = createUserWithTarget("favorite-a", "2200");
        Long second = createUserWithTarget("favorite-b", "2200");
        Long foodId = createFood("favorite-food", "PUBLIC", "100", "100");

        service.addFavorite(first, foodId);
        service.addFavorite(first, foodId);
        assertThat(service.listFavorites(first, null, PageRequest.of(0, 20)).totalElements())
                .isOne();
        assertThat(service.listFavorites(second, null, PageRequest.of(0, 20)).totalElements())
                .isZero();

        service.removeFavorite(first, foodId);
        service.removeFavorite(first, foodId);
        assertThat(service.listFavorites(first, null, PageRequest.of(0, 20)).totalElements())
                .isZero();
    }

    @Test
    void updateAndDeleteEnforceOwnershipAndSummaryCanGoNegative() {
        Long owner = createUserWithTarget("owner", "100");
        Long attacker = createUserWithTarget("attacker", "100");
        Long foodId = createFood("warning-food", "PUBLIC", "100", "160");
        LocalDate date = LocalDate.of(2026, 9, 19);
        NutritionDtos.MealPlan plan = service.addEntry(owner, date, standardEntry(foodId));
        Long entryId = plan.meals().getFirst().entries().getFirst().id();

        assertThat(plan.remaining().caloriesKcal()).isEqualByComparingTo("-60.00");
        assertThat(plan.warnings()).contains("CALORIES_TARGET_EXCEEDED");
        assertThatThrownBy(() -> service.deleteEntry(attacker, date, entryId))
                .isInstanceOf(ApiException.class);
        service.deleteEntry(owner, date, entryId);
        assertThat(service.getMealPlan(owner, date).consumed().caloriesKcal())
                .isEqualByComparingTo("0");
    }

    @Test
    void concurrentFirstEntriesShareOnePlanWithoutLostEntries() throws Exception {
        Long userId = createUserWithTarget("concurrent", "2200");
        Long foodId = createFood("concurrent-food", "PUBLIC", "100", "100");
        LocalDate date = LocalDate.of(2026, 9, 20);
        CountDownLatch start = new CountDownLatch(1);

        try (var executor = Executors.newFixedThreadPool(2)) {
            Future<?> first =
                    executor.submit(
                            () -> {
                                await(start);
                                service.addEntry(userId, date, standardEntry(foodId));
                            });
            Future<?> second =
                    executor.submit(
                            () -> {
                                await(start);
                                service.addEntry(userId, date, standardEntry(foodId));
                            });
            start.countDown();
            first.get();
            second.get();
        }

        assertThat(
                        jdbc.queryForObject(
                                "select count(*) from meal_plans where user_id = ? and plan_date = ?",
                                Integer.class,
                                userId,
                                date))
                .isOne();
        NutritionDtos.MealPlan plan = service.getMealPlan(userId, date);
        assertThat(plan.meals().stream().flatMap(meal -> meal.entries().stream())).hasSize(2);
        assertThat(plan.consumed().caloriesKcal()).isEqualByComparingTo("200.00");
    }

    @Test
    void templateApplyReportsHiddenItemsWithoutMutatingTargetDay() {
        Long userId = createUserWithTarget("template", "2200");
        Long foodId = createFood("template-food", "PUBLIC", "100", "100");
        NutritionDtos.MealTemplate template =
                service.createTemplate(
                        userId,
                        new CreateMealTemplateRequest(
                                "Ngày tập",
                                "Template test",
                                null,
                                List.of(
                                        new CreateMealTemplateRequest.Item(
                                                foodId, "LUNCH", 1, BigDecimal.ONE))));
        jdbc.update("update foods set visibility = 'HIDDEN' where id = ?", foodId);

        NutritionDtos.ApplyTemplateResult result =
                service.applyTemplate(
                        userId,
                        template.id(),
                        new ApplyMealTemplateRequest(LocalDate.of(2026, 9, 21), "MERGE"));
        assertThat(result.applied()).isFalse();
        assertThat(result.blockedItems()).hasSize(1);
        assertThat(result.mealPlan().id()).isNull();
    }

    @Test
    void e2eFoodFavoriteEntrySummaryAndDashboardUseTheSameAuthoritativeData() {
        Long userId = createUserWithTarget("e2e", "2200");
        Long foodId = createFood("e2e-pho", "PUBLIC", "500", "450");
        LocalDate date = LocalDate.of(2026, 9, 22);

        service.addFavorite(userId, foodId);
        assertThat(service.listFavorites(userId, null, PageRequest.of(0, 20)).totalElements())
                .isOne();

        NutritionDtos.MealPlan plan = service.addEntry(userId, date, standardEntry(foodId));
        assertThat(plan.consumed().caloriesKcal()).isEqualByComparingTo("450.00");
        assertThat(plan.remaining().caloriesKcal()).isEqualByComparingTo("1750.00");

        DashboardResponse dashboard = dashboardService.getDashboard(userId, date);
        assertThat(dashboard.nutrition().hasMealPlan()).isTrue();
        assertThat(dashboard.nutrition().consumed().caloriesKcal()).isEqualByComparingTo("450.00");
        assertThat(dashboard.nutrition().remaining().caloriesKcal())
                .isEqualByComparingTo("1750.00");
    }

    private MealEntryRequest standardEntry(Long foodId) {
        return new MealEntryRequest("BREAKFAST", 1, foodId, BigDecimal.ONE, null, null, null);
    }

    private Long createUserWithTarget(String prefix, String calories) {
        String unique = prefix + "-" + UUID.randomUUID();
        Long userId =
                jdbc.queryForObject(
                        "insert into users (email, password_hash, auth_provider, role, status, email_verified_at) "
                                + "values (?, 'hash', 'LOCAL', 'USER', 'ACTIVE', now()) returning id",
                        Long.class,
                        unique + "@viegym.test");
        Long profileId =
                jdbc.queryForObject(
                        "insert into health_profiles (user_id, date_of_birth, gender, calculation_sex, "
                                + "height_cm, current_weight_kg, activity_level, fitness_goal, "
                                + "training_experience, bmi, bmr_kcal, tdee_kcal, calculation_version, "
                                + "calculated_at) values (?, '1995-01-01', 'MALE', 'MALE', 175, 70, "
                                + "'MODERATE', 'MAINTAIN_WEIGHT', 'INTERMEDIATE', 22.86, 1600, 2200, "
                                + "'test-v1', now()) returning id",
                        Long.class,
                        userId);
        jdbc.update(
                "insert into user_profiles (user_id, display_name, timezone, locale) "
                        + "values (?, 'Nutrition Test', 'Asia/Ho_Chi_Minh', 'vi-VN')",
                userId);
        jdbc.update(
                "insert into nutrition_targets (user_id, health_profile_id, calories_kcal, protein_g, "
                        + "carbs_g, fat_g, calculation_version, effective_from) "
                        + "values (?, ?, ?, 130, 270, 65, 'test-v1', now())",
                userId,
                profileId,
                new BigDecimal(calories));
        return userId;
    }

    private Long createFood(String name, String visibility, String grams, String calories) {
        String slug = name + "-" + UUID.randomUUID();
        return jdbc.queryForObject(
                "insert into foods (name, search_name, slug, category, serving_amount, serving_unit, "
                        + "grams_per_serving, calories_per_serving, protein_g_per_serving, "
                        + "carbs_g_per_serving, fat_g_per_serving, data_source, is_estimated, visibility) "
                        + "values (?, ?, ?, 'TEST', 1, 'phần', ?, ?, 10, 10, 2, 'test', true, ?) returning id",
                Long.class,
                name,
                name,
                slug,
                new BigDecimal(grams),
                new BigDecimal(calories),
                visibility);
    }

    private static void await(CountDownLatch latch) {
        try {
            latch.await();
        } catch (InterruptedException exception) {
            Thread.currentThread().interrupt();
            throw new IllegalStateException(exception);
        }
    }
}
