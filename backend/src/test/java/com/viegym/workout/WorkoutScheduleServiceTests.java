package com.viegym.workout;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.viegym.common.error.ApiException;
import com.viegym.workout.schedule.api.WorkoutScheduleRequest;
import com.viegym.workout.schedule.application.WorkoutScheduleService;
import java.time.LocalDate;
import java.time.LocalTime;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
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
class WorkoutScheduleServiceTests {

    @Container
    static final PostgreSQLContainer<?> POSTGRES =
            new PostgreSQLContainer<>("postgres:16.14-bookworm")
                    .withDatabaseName("viegym_sched_svc_test")
                    .withUsername("viegym_sched_svc_test")
                    .withPassword("test_password");

    @DynamicPropertySource
    static void datasourceProperties(DynamicPropertyRegistry registry) {
        registry.add("SPRING_DATASOURCE_URL", POSTGRES::getJdbcUrl);
        registry.add("SPRING_DATASOURCE_USERNAME", POSTGRES::getUsername);
        registry.add("SPRING_DATASOURCE_PASSWORD", POSTGRES::getPassword);
    }

    @Autowired JdbcTemplate jdbcTemplate;

    private WorkoutScheduleService service;
    private Long userId;

    @BeforeEach
    void setUp() {
        service = new WorkoutScheduleService(jdbcTemplate);
        jdbcTemplate.update("delete from workout_schedules");
        jdbcTemplate.update("delete from users");

        userId =
                jdbcTemplate.queryForObject(
                        "insert into users (email, password_hash, auth_provider, role, status,"
                                + " email_verified_at) values ('sched-svc-user@example.com', 'hash',"
                                + " 'LOCAL', 'USER', 'ACTIVE', now()) returning id",
                        Long.class);
    }

    @Test
    @DisplayName("createSchedule creates planned schedule and lists by date range")
    void createAndListSchedules() {
        var req =
                new WorkoutScheduleRequest(
                        null,
                        null,
                        LocalDate.parse("2026-09-02"),
                        LocalTime.parse("18:30:00"),
                        "Chest Day");
        var created = service.createSchedule(userId, req);
        assertThat(created.id()).isNotNull();
        assertThat(created.status()).isEqualTo("PLANNED");

        var list =
                service.listSchedules(
                        userId,
                        LocalDate.parse("2026-09-01"),
                        LocalDate.parse("2026-09-03"),
                        null,
                        PageRequest.of(0, 10));
        assertThat(list.totalElements()).isEqualTo(1);
        assertThat(list.content().get(0).title()).isEqualTo("Chest Day");
    }

    @Test
    @DisplayName("cancelSchedule transitions status to CANCELLED with reason")
    void cancelScheduleTransitionsStatus() {
        var req =
                new WorkoutScheduleRequest(
                        null, null, LocalDate.parse("2026-09-02"), null, "Leg Day");
        var created = service.createSchedule(userId, req);

        service.cancelSchedule(userId, created.id(), "Sick today");

        var cancelled = service.getSchedule(userId, created.id());
        assertThat(cancelled.status()).isEqualTo("CANCELLED");
        assertThat(cancelled.cancelReason()).isEqualTo("Sick today");

        // Cancelling again fails
        assertThatThrownBy(() -> service.cancelSchedule(userId, created.id(), "Retry"))
                .isInstanceOf(ApiException.class);
    }
}
