package com.viegym.database;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

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
class NutritionMigrationTests {
    @Container
    static final PostgreSQLContainer<?> POSTGRES =
            new PostgreSQLContainer<>("postgres:16.14-bookworm")
                    .withDatabaseName("viegym_nutrition_migration")
                    .withUsername("viegym_nutrition")
                    .withPassword("test_password");

    @DynamicPropertySource
    static void datasourceProperties(DynamicPropertyRegistry registry) {
        registry.add("SPRING_DATASOURCE_URL", POSTGRES::getJdbcUrl);
        registry.add("SPRING_DATASOURCE_USERNAME", POSTGRES::getUsername);
        registry.add("SPRING_DATASOURCE_PASSWORD", POSTGRES::getPassword);
    }

    @Autowired JdbcTemplate jdbc;

    @Test
    void createsNutritionSchemaAndSeedsEightyVietnameseFoods() {
        List<String> tables =
                jdbc.queryForList(
                        "select table_name from information_schema.tables where table_schema = 'public'",
                        String.class);
        assertThat(tables)
                .contains(
                        "foods",
                        "favorite_foods",
                        "meal_plans",
                        "meals",
                        "meal_entries",
                        "meal_templates",
                        "meal_template_items");
        assertThat(jdbc.queryForObject("select count(*) from foods", Integer.class)).isEqualTo(80);
        assertThat(
                        jdbc.queryForObject(
                                "select count(*) from foods where search_name is not null "
                                        + "and grams_per_serving > 0 and calories_per_serving >= 0 "
                                        + "and visibility = 'PUBLIC'",
                                Integer.class))
                .isEqualTo(80);
    }

    @Test
    void mealPlanNaturalKeyPreventsDuplicates() {
        Long userId = createUser("nutrition-natural-key@viegym.test");
        String target = "{\"caloriesKcal\":2200,\"proteinG\":130,\"carbsG\":270,\"fatG\":65}";
        jdbc.update(
                "insert into meal_plans (user_id, plan_date, nutrition_target_snapshot) values (?, ?, ?::jsonb)",
                userId,
                LocalDate.of(2026, 9, 17),
                target);
        assertThatThrownBy(
                        () ->
                                jdbc.update(
                                        "insert into meal_plans (user_id, plan_date, nutrition_target_snapshot) values (?, ?, ?::jsonb)",
                                        userId,
                                        LocalDate.of(2026, 9, 17),
                                        target))
                .isInstanceOf(DataIntegrityViolationException.class);
    }

    private Long createUser(String email) {
        return jdbc.queryForObject(
                "insert into users (email, password_hash, auth_provider, role, status, email_verified_at) "
                        + "values (?, 'hash', 'LOCAL', 'USER', 'ACTIVE', now()) returning id",
                Long.class,
                email);
    }
}
