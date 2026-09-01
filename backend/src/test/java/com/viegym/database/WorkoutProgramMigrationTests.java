package com.viegym.database;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.sql.Date;
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
class WorkoutProgramMigrationTests {

    @Container
    static final PostgreSQLContainer<?> POSTGRES =
            new PostgreSQLContainer<>("postgres:16.14-bookworm")
                    .withDatabaseName("viegym_program_test")
                    .withUsername("viegym_program_test")
                    .withPassword("test_password");

    @DynamicPropertySource
    static void datasourceProperties(DynamicPropertyRegistry registry) {
        registry.add("SPRING_DATASOURCE_URL", POSTGRES::getJdbcUrl);
        registry.add("SPRING_DATASOURCE_USERNAME", POSTGRES::getUsername);
        registry.add("SPRING_DATASOURCE_PASSWORD", POSTGRES::getPassword);
    }

    @Autowired JdbcTemplate jdbcTemplate;

    @Test
    void appliesWorkoutProgramAndScheduleMigrationOnCleanPostgreSql() {
        Integer applied =
                jdbcTemplate.queryForObject(
                        "select count(*) from flyway_schema_history "
                                + "where version = '9' and success = true",
                        Integer.class);
        List<String> tables =
                jdbcTemplate.queryForList(
                        "select table_name from information_schema.tables "
                                + "where table_schema = 'public'",
                        String.class);
        List<String> constraints =
                jdbcTemplate.queryForList(
                        "select conname from pg_constraint where conname in "
                                + "('pk_workout_programs', "
                                + "'fk_workout_programs_user', "
                                + "'chk_workout_programs_type', "
                                + "'chk_workout_programs_status', "
                                + "'pk_workout_days', "
                                + "'fk_workout_days_program', "
                                + "'chk_workout_days_number', "
                                + "'uq_workout_days_program_day', "
                                + "'pk_workout_exercises', "
                                + "'fk_workout_exercises_day', "
                                + "'fk_workout_exercises_exercise', "
                                + "'chk_workout_exercises_sort_order', "
                                + "'chk_workout_exercises_target_sets', "
                                + "'uq_workout_exercises_day_sort', "
                                + "'chk_workout_exercises_reps', "
                                + "'pk_workout_schedules', "
                                + "'fk_workout_schedules_user', "
                                + "'fk_workout_schedules_program', "
                                + "'fk_workout_schedules_day', "
                                + "'chk_workout_schedules_status')",
                        String.class);

        assertThat(applied).isEqualTo(1);
        assertThat(tables)
                .contains(
                        "workout_programs",
                        "workout_days",
                        "workout_exercises",
                        "workout_schedules");
        assertThat(constraints)
                .contains(
                        "pk_workout_programs",
                        "fk_workout_programs_user",
                        "chk_workout_programs_type",
                        "chk_workout_programs_status",
                        "pk_workout_days",
                        "fk_workout_days_program",
                        "chk_workout_days_number",
                        "uq_workout_days_program_day",
                        "pk_workout_exercises",
                        "fk_workout_exercises_day",
                        "fk_workout_exercises_exercise",
                        "chk_workout_exercises_sort_order",
                        "chk_workout_exercises_target_sets",
                        "uq_workout_exercises_day_sort",
                        "chk_workout_exercises_reps",
                        "pk_workout_schedules",
                        "fk_workout_schedules_user",
                        "fk_workout_schedules_program",
                        "fk_workout_schedules_day",
                        "chk_workout_schedules_status");
    }

    @Test
    void allowsOnlyOneActiveProgramPerUser() {
        Long userId =
                jdbcTemplate.queryForObject(
                        "insert into users (email, password_hash, auth_provider, role, status,"
                                + " email_verified_at) values ('prog-user@example.com', 'hash',"
                                + " 'LOCAL', 'USER', 'ACTIVE', now()) returning id",
                        Long.class);

        jdbcTemplate.update(
                "insert into workout_programs (user_id, name, program_type, status) values (?, 'PPL"
                        + " 1', 'PPL', 'ACTIVE')",
                userId);

        // Second active program for same user should fail due to unique partial index
        assertThatThrownBy(
                        () ->
                                jdbcTemplate.update(
                                        "insert into workout_programs (user_id, name, program_type,"
                                                + " status) values (?, 'PPL 2', 'PPL', 'ACTIVE')",
                                        userId))
                .isInstanceOf(DataIntegrityViolationException.class);

        // But an INACTIVE or ARCHIVED program is allowed
        jdbcTemplate.update(
                "insert into workout_programs (user_id, name, program_type, status) values (?, 'PPL"
                        + " 2', 'PPL', 'INACTIVE')",
                userId);
        jdbcTemplate.update(
                "insert into workout_programs (user_id, name, program_type, status) values (?, 'PPL"
                        + " 3', 'PPL', 'ARCHIVED')",
                userId);
    }

    @Test
    void createsProgramDayExerciseAndScheduleWithConstraints() {
        Long userId =
                jdbcTemplate.queryForObject(
                        "insert into users (email, password_hash, auth_provider, role, status,"
                                + " email_verified_at) values ('schedule-user@example.com', 'hash',"
                                + " 'LOCAL', 'USER', 'ACTIVE', now()) returning id",
                        Long.class);

        Long progId =
                jdbcTemplate.queryForObject(
                        "insert into workout_programs (user_id, name, program_type, status) values"
                                + " (?, 'Upper Lower', 'UPPER_LOWER', 'ACTIVE') returning id",
                        Long.class,
                        userId);

        Long dayId =
                jdbcTemplate.queryForObject(
                        "insert into workout_days (workout_program_id, day_number, name) values (?,"
                                + " 1, 'Upper Body A') returning id",
                        Long.class,
                        progId);

        Long exId =
                jdbcTemplate.queryForObject(
                        "insert into exercises (name, search_name, slug, difficulty, description)"
                                + " values ('Incline Press', 'incline press', 'incline-press',"
                                + " 'INTERMEDIATE', 'Đẩy ngực dốc') returning id",
                        Long.class);

        jdbcTemplate.update(
                "insert into workout_exercises (workout_day_id, exercise_id, sort_order,"
                        + " target_sets, target_reps_min, target_reps_max, rest_seconds) values (?, ?,"
                        + " 1, 4, 8, 12, 90)",
                dayId,
                exId);

        Long schedId =
                jdbcTemplate.queryForObject(
                        "insert into workout_schedules (user_id, workout_program_id,"
                                + " workout_day_id, scheduled_date, title, status) values (?, ?, ?, ?,"
                                + " 'Upper Body A', 'PLANNED') returning id",
                        Long.class,
                        userId,
                        progId,
                        dayId,
                        Date.valueOf(LocalDate.parse("2026-09-02")));

        assertThat(schedId).isNotNull();
    }
}
