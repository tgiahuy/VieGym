package com.viegym.database;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.sql.Timestamp;
import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

@Testcontainers
@SpringBootTest
class HealthBodyMigrationTests {

    @Container
    static final PostgreSQLContainer<?> POSTGRES =
            new PostgreSQLContainer<>("postgres:16.14-bookworm")
                    .withDatabaseName("viegym_health_test")
                    .withUsername("viegym_health_test")
                    .withPassword("test_password");

    @DynamicPropertySource
    static void datasourceProperties(DynamicPropertyRegistry registry) {
        registry.add("SPRING_DATASOURCE_URL", POSTGRES::getJdbcUrl);
        registry.add("SPRING_DATASOURCE_USERNAME", POSTGRES::getUsername);
        registry.add("SPRING_DATASOURCE_PASSWORD", POSTGRES::getPassword);
    }

    @Autowired JdbcTemplate jdbcTemplate;

    @Test
    void appliesHealthBodyMigrationOnCleanPostgreSql() {
        Integer applied =
                jdbcTemplate.queryForObject(
                        "select count(*) from flyway_schema_history "
                                + "where version = '4' and success = true",
                        Integer.class);
        List<String> tables =
                jdbcTemplate.queryForList(
                        "select table_name from information_schema.tables "
                                + "where table_schema = 'public'",
                        String.class);
        List<String> constraints =
                jdbcTemplate.queryForList(
                        "select conname from pg_constraint where conname in "
                                + "('pk_health_profiles', "
                                + "'fk_health_profiles_user', "
                                + "'uq_health_profiles_user', "
                                + "'chk_health_profiles_gender', "
                                + "'chk_health_profiles_calculation_sex', "
                                + "'chk_health_profiles_height_cm', "
                                + "'chk_health_profiles_current_weight_kg', "
                                + "'chk_health_profiles_activity_level', "
                                + "'chk_health_profiles_fitness_goal', "
                                + "'chk_health_profiles_training_experience', "
                                + "'chk_health_profiles_bmi', "
                                + "'chk_health_profiles_bmr_kcal', "
                                + "'chk_health_profiles_tdee_kcal', "
                                + "'pk_nutrition_targets', "
                                + "'fk_nutrition_targets_user', "
                                + "'fk_nutrition_targets_health_profile', "
                                + "'uq_nutrition_targets_user', "
                                + "'chk_nutrition_targets_calories_kcal', "
                                + "'chk_nutrition_targets_protein_g', "
                                + "'chk_nutrition_targets_carbs_g', "
                                + "'chk_nutrition_targets_fat_g', "
                                + "'pk_weight_logs', "
                                + "'fk_weight_logs_user', "
                                + "'uq_weight_logs_user_logged_date', "
                                + "'chk_weight_logs_weight_kg')",
                        String.class);
        List<String> indexes =
                jdbcTemplate.queryForList(
                        "select indexname from pg_indexes where schemaname = 'public'",
                        String.class);

        assertThat(applied).isEqualTo(1);
        assertThat(tables).contains("health_profiles", "nutrition_targets", "weight_logs");
        assertThat(constraints)
                .contains(
                        "pk_health_profiles",
                        "fk_health_profiles_user",
                        "uq_health_profiles_user",
                        "chk_health_profiles_gender",
                        "chk_health_profiles_calculation_sex",
                        "chk_health_profiles_height_cm",
                        "chk_health_profiles_current_weight_kg",
                        "chk_health_profiles_activity_level",
                        "chk_health_profiles_fitness_goal",
                        "chk_health_profiles_training_experience",
                        "chk_health_profiles_bmi",
                        "chk_health_profiles_bmr_kcal",
                        "chk_health_profiles_tdee_kcal",
                        "pk_nutrition_targets",
                        "fk_nutrition_targets_user",
                        "fk_nutrition_targets_health_profile",
                        "uq_nutrition_targets_user",
                        "chk_nutrition_targets_calories_kcal",
                        "chk_nutrition_targets_protein_g",
                        "chk_nutrition_targets_carbs_g",
                        "chk_nutrition_targets_fat_g",
                        "pk_weight_logs",
                        "fk_weight_logs_user",
                        "uq_weight_logs_user_logged_date",
                        "chk_weight_logs_weight_kg");
        assertThat(indexes).contains("idx_weight_logs_user_logged_date");
    }

    @Test
    void acceptsValidHealthProfileTargetAndWeightLog() {
        long userId = createUser("health-valid@example.com");
        long healthProfileId = createHealthProfile(userId);

        jdbcTemplate.update(
                "insert into nutrition_targets "
                        + "(user_id, health_profile_id, calories_kcal, protein_g, carbs_g, fat_g, "
                        + "calculation_version, effective_from) "
                        + "values (?, ?, 2200.00, 140.00, 260.00, 70.00, 'health-v1', ?)",
                userId,
                healthProfileId,
                Timestamp.from(Instant.parse("2026-08-26T00:00:00Z")));
        jdbcTemplate.update(
                "insert into weight_logs (user_id, logged_date, weight_kg, note) "
                        + "values (?, ?, 70.50, 'initial')",
                userId,
                LocalDate.parse("2026-08-26"));

        Integer targets =
                jdbcTemplate.queryForObject(
                        "select count(*) from nutrition_targets where user_id = ?",
                        Integer.class,
                        userId);
        Integer weightLogs =
                jdbcTemplate.queryForObject(
                        "select count(*) from weight_logs where user_id = ?",
                        Integer.class,
                        userId);

        assertThat(targets).isEqualTo(1);
        assertThat(weightLogs).isEqualTo(1);
    }

    @Test
    void rejectsDuplicateOnePerUserHealthProfileAndNutritionTarget() {
        long userId = createUser("health-unique@example.com");
        long healthProfileId = createHealthProfile(userId);
        createNutritionTarget(userId, healthProfileId);

        assertThatThrownBy(() -> createHealthProfile(userId))
                .isInstanceOf(DataIntegrityViolationException.class);
        assertThatThrownBy(() -> createNutritionTarget(userId, healthProfileId))
                .isInstanceOf(DataIntegrityViolationException.class);
    }

    @Test
    void rejectsDuplicateWeightLogDatePerUser() {
        long userId = createUser("weight-unique@example.com");
        createHealthProfile(userId);
        createWeightLog(userId, LocalDate.parse("2026-08-26"));

        assertThatThrownBy(() -> createWeightLog(userId, LocalDate.parse("2026-08-26")))
                .isInstanceOf(DataIntegrityViolationException.class);
    }

    @Test
    void rejectsInvalidHealthEnumValues() {
        long userId = createUser("health-enum@example.com");

        assertThatThrownBy(
                        () ->
                                jdbcTemplate.update(
                                        "insert into health_profiles "
                                                + "(user_id, date_of_birth, gender, calculation_sex, height_cm, "
                                                + "current_weight_kg, activity_level, fitness_goal, "
                                                + "training_experience, bmi, calculation_version, calculated_at) "
                                                + "values (?, ?, 'UNKNOWN', 'MALE', 170.00, 70.00, 'MODERATE', "
                                                + "'MAINTAIN_WEIGHT', 'INTERMEDIATE', 24.22, 'health-v1', ?)",
                                        userId,
                                        LocalDate.parse("1995-01-01"),
                                        Timestamp.from(Instant.parse("2026-08-26T00:00:00Z"))))
                .isInstanceOf(DataIntegrityViolationException.class);
    }

    @Test
    void rejectsNonpositiveHealthAndWeightMeasurements() {
        long userId = createUser("health-positive@example.com");
        long healthProfileId = createHealthProfile(userId);

        assertHealthProfileOverrideFails(userId, "height_cm", "0.00");
        assertHealthProfileOverrideFails(userId, "current_weight_kg", "0.00");
        assertHealthProfileOverrideFails(userId, "bmi", "0.00");
        assertHealthProfileOverrideFails(userId, "bmr_kcal", "0.00");
        assertHealthProfileOverrideFails(userId, "tdee_kcal", "0.00");
        assertThatThrownBy(
                        () ->
                                jdbcTemplate.update(
                                        "insert into nutrition_targets "
                                                + "(user_id, health_profile_id, calories_kcal, protein_g, carbs_g, "
                                                + "fat_g, calculation_version, effective_from) "
                                                + "values (?, ?, 0.00, 140.00, 260.00, 70.00, 'health-v1', ?)",
                                        userId,
                                        healthProfileId,
                                        Timestamp.from(Instant.parse("2026-08-26T00:00:00Z"))))
                .isInstanceOf(DataIntegrityViolationException.class);
        assertThatThrownBy(() -> createWeightLog(userId, LocalDate.parse("2026-08-26"), "0.00"))
                .isInstanceOf(DataIntegrityViolationException.class);
    }

    @Test
    void rejectsNegativeMacroTargets() {
        long userId = createUser("macro-negative@example.com");
        long healthProfileId = createHealthProfile(userId);

        assertNutritionTargetOverrideFails(userId, healthProfileId, "protein_g", "-0.01");
        assertNutritionTargetOverrideFails(userId, healthProfileId, "carbs_g", "-0.01");
        assertNutritionTargetOverrideFails(userId, healthProfileId, "fat_g", "-0.01");
    }

    @Test
    void allowsIncompleteHealthCalculationWithoutBmrOrTdee() {
        long userId = createUser("health-incomplete@example.com");

        jdbcTemplate.update(
                "insert into health_profiles "
                        + "(user_id, date_of_birth, gender, calculation_sex, height_cm, current_weight_kg, "
                        + "activity_level, fitness_goal, training_experience, bmi, bmr_kcal, tdee_kcal, "
                        + "calculation_version, calculated_at) "
                        + "values (?, ?, 'UNSPECIFIED', 'UNSPECIFIED', 170.00, 70.00, 'MODERATE', "
                        + "'MAINTAIN_WEIGHT', 'BEGINNER', 24.22, null, null, 'health-v1', ?)",
                userId,
                LocalDate.parse("1995-01-01"),
                Timestamp.from(Instant.parse("2026-08-26T00:00:00Z")));

        Integer count =
                jdbcTemplate.queryForObject(
                        "select count(*) from health_profiles where user_id = ? and bmr_kcal is null "
                                + "and tdee_kcal is null",
                        Integer.class,
                        userId);

        assertThat(count).isEqualTo(1);
    }

    private long createUser(String email) {
        return jdbcTemplate.queryForObject(
                "insert into users (email, password_hash, auth_provider, role, status, email_verified_at) "
                        + "values (?, 'bcrypt-hash', 'LOCAL', 'USER', 'ACTIVE', ?) returning id",
                Long.class,
                email,
                Timestamp.from(Instant.parse("2026-08-26T00:00:00Z")));
    }

    private long createHealthProfile(long userId) {
        return jdbcTemplate.queryForObject(
                "insert into health_profiles "
                        + "(user_id, date_of_birth, gender, calculation_sex, height_cm, current_weight_kg, "
                        + "activity_level, fitness_goal, training_experience, bmi, bmr_kcal, tdee_kcal, "
                        + "calculation_version, calculated_at) "
                        + "values (?, ?, 'MALE', 'MALE', 170.00, 70.00, 'MODERATE', 'MAINTAIN_WEIGHT', "
                        + "'INTERMEDIATE', 24.22, 1600.00, 2480.00, 'health-v1', ?) returning id",
                Long.class,
                userId,
                LocalDate.parse("1995-01-01"),
                Timestamp.from(Instant.parse("2026-08-26T00:00:00Z")));
    }

    private void createNutritionTarget(long userId, long healthProfileId) {
        jdbcTemplate.update(
                "insert into nutrition_targets "
                        + "(user_id, health_profile_id, calories_kcal, protein_g, carbs_g, fat_g, "
                        + "calculation_version, effective_from) "
                        + "values (?, ?, 2200.00, 140.00, 260.00, 70.00, 'health-v1', ?)",
                userId,
                healthProfileId,
                Timestamp.from(Instant.parse("2026-08-26T00:00:00Z")));
    }

    private void createWeightLog(long userId, LocalDate loggedDate) {
        createWeightLog(userId, loggedDate, "70.50");
    }

    private void createWeightLog(long userId, LocalDate loggedDate, String weightKg) {
        jdbcTemplate.update(
                "insert into weight_logs (user_id, logged_date, weight_kg) values (?, ?, ?::numeric)",
                userId,
                loggedDate,
                weightKg);
    }

    private void assertHealthProfileOverrideFails(
            long existingUserId, String column, String value) {
        long userId = createUser("health-check-" + column + "@example.com");

        assertThatThrownBy(
                        () ->
                                jdbcTemplate.update(
                                        "insert into health_profiles "
                                                + "(user_id, date_of_birth, gender, calculation_sex, height_cm, "
                                                + "current_weight_kg, activity_level, fitness_goal, "
                                                + "training_experience, bmi, bmr_kcal, tdee_kcal, "
                                                + "calculation_version, calculated_at) "
                                                + "values (?, ?, 'MALE', 'MALE', "
                                                + healthValue(column, "height_cm", value, "170.00")
                                                + ", "
                                                + healthValue(
                                                        column, "current_weight_kg", value, "70.00")
                                                + ", 'MODERATE', 'MAINTAIN_WEIGHT', 'INTERMEDIATE', "
                                                + healthValue(column, "bmi", value, "24.22")
                                                + ", "
                                                + healthValue(column, "bmr_kcal", value, "1600.00")
                                                + ", "
                                                + healthValue(column, "tdee_kcal", value, "2480.00")
                                                + ", 'health-v1', ?)",
                                        userId,
                                        LocalDate.parse("1995-01-01"),
                                        Timestamp.from(Instant.parse("2026-08-26T00:00:00Z"))))
                .isInstanceOf(DataIntegrityViolationException.class);
        assertThat(existingUserId).isPositive();
    }

    private String healthValue(
            String requestedColumn, String currentColumn, String value, String fallback) {
        return requestedColumn.equals(currentColumn) ? value : fallback;
    }

    private void assertNutritionTargetOverrideFails(
            long userId, long healthProfileId, String column, String value) {
        long nextUserId = createUser("nutrition-check-" + column + "@example.com");
        long nextHealthProfileId = createHealthProfile(nextUserId);

        assertThatThrownBy(
                        () ->
                                jdbcTemplate.update(
                                        "insert into nutrition_targets "
                                                + "(user_id, health_profile_id, calories_kcal, protein_g, "
                                                + "carbs_g, fat_g, calculation_version, effective_from) "
                                                + "values (?, ?, 2200.00, "
                                                + nutritionValue(
                                                        column, "protein_g", value, "140.00")
                                                + ", "
                                                + nutritionValue(column, "carbs_g", value, "260.00")
                                                + ", "
                                                + nutritionValue(column, "fat_g", value, "70.00")
                                                + ", 'health-v1', ?)",
                                        nextUserId,
                                        nextHealthProfileId,
                                        Timestamp.from(Instant.parse("2026-08-26T00:00:00Z"))))
                .isInstanceOf(DataIntegrityViolationException.class);
        assertThat(userId).isPositive();
        assertThat(healthProfileId).isPositive();
    }

    private String nutritionValue(
            String requestedColumn, String currentColumn, String value, String fallback) {
        return requestedColumn.equals(currentColumn) ? value : fallback;
    }
}
