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
class WorkoutExecutionMigrationTests {

    @Container
    static final PostgreSQLContainer<?> POSTGRES =
            new PostgreSQLContainer<>("postgres:16.14-bookworm")
                    .withDatabaseName("viegym_session_test")
                    .withUsername("viegym_session_test")
                    .withPassword("test_password");

    @DynamicPropertySource
    static void datasourceProperties(DynamicPropertyRegistry registry) {
        registry.add("SPRING_DATASOURCE_URL", POSTGRES::getJdbcUrl);
        registry.add("SPRING_DATASOURCE_USERNAME", POSTGRES::getUsername);
        registry.add("SPRING_DATASOURCE_PASSWORD", POSTGRES::getPassword);
    }

    @Autowired JdbcTemplate jdbcTemplate;

    @Test
    void appliesWorkoutExecutionMigrationOnCleanPostgreSql() {
        Integer applied =
                jdbcTemplate.queryForObject(
                        "select count(*) from flyway_schema_history "
                                + "where version = '10' and success = true",
                        Integer.class);
        List<String> tables =
                jdbcTemplate.queryForList(
                        "select table_name from information_schema.tables "
                                + "where table_schema = 'public'",
                        String.class);

        assertThat(applied).isEqualTo(1);
        assertThat(tables)
                .contains(
                        "workout_sessions",
                        "workout_logs",
                        "workout_exercise_logs",
                        "workout_set_logs",
                        "personal_records");
    }

    @Test
    void allowsOnlyOneActiveSessionPerUser() {
        Long userId =
                jdbcTemplate.queryForObject(
                        "insert into users (email, password_hash, auth_provider, role, status,"
                                + " email_verified_at) values ('session-user@example.com', 'hash',"
                                + " 'LOCAL', 'USER', 'ACTIVE', now()) returning id",
                        Long.class);

        Long sched1 =
                jdbcTemplate.queryForObject(
                        "insert into workout_schedules (user_id, scheduled_date, title, status)"
                                + " values (?, ?, 'S1', 'PLANNED') returning id",
                        Long.class,
                        userId,
                        Date.valueOf(LocalDate.parse("2026-09-02")));

        Long sched2 =
                jdbcTemplate.queryForObject(
                        "insert into workout_schedules (user_id, scheduled_date, title, status)"
                                + " values (?, ?, 'S2', 'PLANNED') returning id",
                        Long.class,
                        userId,
                        Date.valueOf(LocalDate.parse("2026-09-03")));

        jdbcTemplate.update(
                "insert into workout_sessions (user_id, workout_schedule_id, status) values (?,"
                        + " ?, 'IN_PROGRESS')",
                userId,
                sched1);

        // Second in-progress session for same user fails due to unique partial index
        assertThatThrownBy(
                        () ->
                                jdbcTemplate.update(
                                        "insert into workout_sessions (user_id,"
                                                + " workout_schedule_id, status) values (?, ?,"
                                                + " 'IN_PROGRESS')",
                                        userId,
                                        sched2))
                .isInstanceOf(DataIntegrityViolationException.class);
    }
}
