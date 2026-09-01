package com.viegym.database;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

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
class ExerciseCatalogMigrationTests {

    @Container
    static final PostgreSQLContainer<?> POSTGRES =
            new PostgreSQLContainer<>("postgres:16.14-bookworm")
                    .withDatabaseName("viegym_exercise_test")
                    .withUsername("viegym_exercise_test")
                    .withPassword("test_password");

    @DynamicPropertySource
    static void datasourceProperties(DynamicPropertyRegistry registry) {
        registry.add("SPRING_DATASOURCE_URL", POSTGRES::getJdbcUrl);
        registry.add("SPRING_DATASOURCE_USERNAME", POSTGRES::getUsername);
        registry.add("SPRING_DATASOURCE_PASSWORD", POSTGRES::getPassword);
    }

    @Autowired JdbcTemplate jdbcTemplate;

    @Test
    void appliesExerciseCatalogMigrationOnCleanPostgreSql() {
        Integer applied =
                jdbcTemplate.queryForObject(
                        "select count(*) from flyway_schema_history "
                                + "where version = '7' and success = true",
                        Integer.class);
        List<String> tables =
                jdbcTemplate.queryForList(
                        "select table_name from information_schema.tables "
                                + "where table_schema = 'public'",
                        String.class);
        List<String> constraints =
                jdbcTemplate.queryForList(
                        "select conname from pg_constraint where conname in "
                                + "('pk_muscle_groups', "
                                + "'uq_muscle_groups_code', "
                                + "'pk_exercises', "
                                + "'uq_exercises_slug', "
                                + "'fk_exercises_created_by', "
                                + "'chk_exercises_difficulty', "
                                + "'chk_exercises_visibility', "
                                + "'pk_exercise_muscle_groups', "
                                + "'fk_exercise_muscle_groups_exercise', "
                                + "'fk_exercise_muscle_groups_muscle_group', "
                                + "'chk_exercise_muscle_groups_role', "
                                + "'pk_exercise_equipment', "
                                + "'fk_exercise_equipment_exercise', "
                                + "'fk_exercise_equipment_equipment', "
                                + "'pk_favorite_exercises', "
                                + "'fk_favorite_exercises_user', "
                                + "'fk_favorite_exercises_exercise')",
                        String.class);
        List<String> indexes =
                jdbcTemplate.queryForList(
                        "select indexname from pg_indexes where schemaname = 'public'",
                        String.class);

        assertThat(applied).isEqualTo(1);
        assertThat(tables)
                .contains(
                        "muscle_groups",
                        "exercises",
                        "exercise_muscle_groups",
                        "exercise_equipment",
                        "favorite_exercises");
        assertThat(constraints)
                .contains(
                        "pk_muscle_groups",
                        "uq_muscle_groups_code",
                        "pk_exercises",
                        "uq_exercises_slug",
                        "chk_exercises_difficulty",
                        "chk_exercises_visibility",
                        "pk_exercise_muscle_groups",
                        "fk_exercise_muscle_groups_exercise",
                        "fk_exercise_muscle_groups_muscle_group",
                        "chk_exercise_muscle_groups_role",
                        "pk_exercise_equipment",
                        "fk_exercise_equipment_exercise",
                        "fk_exercise_equipment_equipment",
                        "pk_favorite_exercises",
                        "fk_favorite_exercises_user",
                        "fk_favorite_exercises_exercise");
        assertThat(indexes)
                .contains(
                        "idx_exercises_search_name",
                        "idx_exercises_visibility_deleted_at",
                        "idx_exercise_muscle_groups_muscle_exercise",
                        "idx_exercise_equipment_equipment_exercise",
                        "idx_favorite_exercises_user_created");
    }

    @Test
    void acceptsValidExerciseMuscleGroupAndEquipmentMappings() {
        Long mgId =
                jdbcTemplate.queryForObject(
                        "insert into muscle_groups (code, name, description) "
                                + "values ('TEST_CHEST', 'Ngực kiểm thử', 'Nhóm cơ ngực') returning id",
                        Long.class);

        Long exId =
                jdbcTemplate.queryForObject(
                        "insert into exercises (name, search_name, slug, difficulty, description, visibility) "
                                + "values ('Bench Press', 'bench press', 'bench-press', 'INTERMEDIATE', "
                                + "'Đẩy ngực ngang với đòn tạ', 'PUBLIC') returning id",
                        Long.class);

        Long eqId =
                jdbcTemplate.queryForObject(
                        "select id from equipment where code = 'BARBELL'", Long.class);

        jdbcTemplate.update(
                "insert into exercise_muscle_groups (exercise_id, muscle_group_id, role) "
                        + "values (?, ?, 'PRIMARY')",
                exId,
                mgId);

        jdbcTemplate.update(
                "insert into exercise_equipment (exercise_id, equipment_id, is_required) "
                        + "values (?, ?, true)",
                exId,
                eqId);

        Integer mgMappings =
                jdbcTemplate.queryForObject(
                        "select count(*) from exercise_muscle_groups where exercise_id = ?",
                        Integer.class,
                        exId);
        Integer eqMappings =
                jdbcTemplate.queryForObject(
                        "select count(*) from exercise_equipment where exercise_id = ?",
                        Integer.class,
                        exId);

        assertThat(mgMappings).isEqualTo(1);
        assertThat(eqMappings).isEqualTo(1);
    }

    @Test
    void rejectsDuplicateSlugAndCodes() {
        jdbcTemplate.update("insert into muscle_groups (code, name) values ('TEST_BACK', 'Lưng')");
        assertThatThrownBy(
                        () ->
                                jdbcTemplate.update(
                                        "insert into muscle_groups (code, name) values ('TEST_BACK', 'Lưng xô')"))
                .isInstanceOf(DataIntegrityViolationException.class);

        jdbcTemplate.update(
                "insert into exercises (name, search_name, slug, difficulty, description) "
                        + "values ('Squat', 'squat', 'squat', 'BEGINNER', 'Gánh đùi')");
        assertThatThrownBy(
                        () ->
                                jdbcTemplate.update(
                                        "insert into exercises (name, search_name, slug, difficulty, description) "
                                                + "values ('Back Squat', 'back squat', 'squat', 'INTERMEDIATE', 'Squat với đòn')"))
                .isInstanceOf(DataIntegrityViolationException.class);
    }

    @Test
    void rejectsInvalidRoleAndDifficultyEnums() {
        Long exId =
                jdbcTemplate.queryForObject(
                        "insert into exercises (name, search_name, slug, difficulty, description) "
                                + "values ('Deadlift', 'deadlift', 'deadlift', 'ADVANCED', 'Kéo tạ') returning id",
                        Long.class);

        Long mgId =
                jdbcTemplate.queryForObject(
                        "insert into muscle_groups (code, name) values ('TEST_LEGS', 'Chân') returning id",
                        Long.class);

        assertThatThrownBy(
                        () ->
                                jdbcTemplate.update(
                                        "insert into exercise_muscle_groups (exercise_id, muscle_group_id, role) "
                                                + "values (?, ?, 'TERTIARY')",
                                        exId,
                                        mgId))
                .isInstanceOf(DataIntegrityViolationException.class);

        assertThatThrownBy(
                        () ->
                                jdbcTemplate.update(
                                        "insert into exercises (name, search_name, slug, difficulty, description) "
                                                + "values ('Bad Ex', 'bad ex', 'bad-ex', 'EXPERT', 'Invalid diff')"))
                .isInstanceOf(DataIntegrityViolationException.class);
    }
}
