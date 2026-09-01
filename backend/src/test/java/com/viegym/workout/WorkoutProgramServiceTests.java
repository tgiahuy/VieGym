package com.viegym.workout;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.viegym.common.error.ApiException;
import com.viegym.workout.program.api.WorkoutDayRequest;
import com.viegym.workout.program.api.WorkoutExerciseRequest;
import com.viegym.workout.program.api.WorkoutProgramRequest;
import com.viegym.workout.program.api.WorkoutProgramResponse;
import com.viegym.workout.program.application.WorkoutProgramService;
import java.sql.Date;
import java.time.LocalDate;
import java.util.List;
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
class WorkoutProgramServiceTests {

    @Container
    static final PostgreSQLContainer<?> POSTGRES =
            new PostgreSQLContainer<>("postgres:16.14-bookworm")
                    .withDatabaseName("viegym_prog_svc_test")
                    .withUsername("viegym_prog_svc_test")
                    .withPassword("test_password");

    @DynamicPropertySource
    static void datasourceProperties(DynamicPropertyRegistry registry) {
        registry.add("SPRING_DATASOURCE_URL", POSTGRES::getJdbcUrl);
        registry.add("SPRING_DATASOURCE_USERNAME", POSTGRES::getUsername);
        registry.add("SPRING_DATASOURCE_PASSWORD", POSTGRES::getPassword);
    }

    @Autowired JdbcTemplate jdbcTemplate;

    private WorkoutProgramService service;
    private Long userId;
    private Long exerciseId;

    @BeforeEach
    void setUp() {
        service = new WorkoutProgramService(jdbcTemplate);
        jdbcTemplate.update("delete from workout_schedules");
        jdbcTemplate.update("delete from workout_exercises");
        jdbcTemplate.update("delete from workout_days");
        jdbcTemplate.update("delete from workout_programs");
        jdbcTemplate.update("delete from exercise_import_registry");
        jdbcTemplate.update("delete from dataset_import_batches");
        jdbcTemplate.update("delete from exercises");
        jdbcTemplate.update("delete from users");

        userId =
                jdbcTemplate.queryForObject(
                        "insert into users (email, password_hash, auth_provider, role, status,"
                                + " email_verified_at) values ('prog-svc-user@example.com', 'hash',"
                                + " 'LOCAL', 'USER', 'ACTIVE', now()) returning id",
                        Long.class);

        exerciseId =
                jdbcTemplate.queryForObject(
                        "insert into exercises (name, search_name, slug, difficulty, description,"
                                + " visibility) values ('Bench Press', 'bench press', 'bench-press',"
                                + " 'BEGINNER', 'Đẩy ngực', 'PUBLIC') returning id",
                        Long.class);
    }

    @Test
    @DisplayName(
            "createProgram creates program with days and exercises and auto deactivates previous active")
    void createProgramDeactivatesPreviousActive() {
        var exReq =
                new WorkoutExerciseRequest(null, exerciseId, 1, 3, 8, 12, null, 90, "Warmup first");
        var dayReq = new WorkoutDayRequest(null, 1, "Day 1 Full Body", null, List.of(exReq));
        var req1 =
                new WorkoutProgramRequest(
                        "PPL 1", "PPL", "First program", "ACTIVE", List.of(dayReq));

        WorkoutProgramResponse res1 = service.createProgram(userId, req1);
        assertThat(res1.status()).isEqualTo("ACTIVE");
        assertThat(res1.days()).hasSize(1);
        assertThat(res1.days().get(0).exercises()).hasSize(1);

        var req2 =
                new WorkoutProgramRequest(
                        "PPL 2", "PPL", "Second program", "ACTIVE", List.of(dayReq));
        WorkoutProgramResponse res2 = service.createProgram(userId, req2);
        assertThat(res2.status()).isEqualTo("ACTIVE");

        // First program should now be INACTIVE
        var updatedProg1 = service.getProgram(userId, res1.id());
        assertThat(updatedProg1.status()).isEqualTo("INACTIVE");
    }

    @Test
    @DisplayName("updateProgram blocks deleting a day if referenced by a planned schedule")
    void updateProgramBlocksDeletingDayWithPlannedSchedule() {
        var dayReq = new WorkoutDayRequest(null, 1, "Day 1", null, List.of());
        var createReq =
                new WorkoutProgramRequest("Program A", "CUSTOM", null, "ACTIVE", List.of(dayReq));
        var created = service.createProgram(userId, createReq);
        Long dayId = created.days().get(0).id();

        // Create planned schedule referencing this day
        jdbcTemplate.update(
                "insert into workout_schedules (user_id, workout_program_id, workout_day_id,"
                        + " scheduled_date, title, status) values (?, ?, ?, ?, 'Day 1', 'PLANNED')",
                userId,
                created.id(),
                dayId,
                Date.valueOf(LocalDate.parse("2026-09-05")));

        // Try to update program without day 1 (attempting to delete day 1)
        var updateReq = new WorkoutProgramRequest("Program A", "CUSTOM", null, "ACTIVE", List.of());

        assertThatThrownBy(() -> service.updateProgram(userId, created.id(), updateReq))
                .isInstanceOf(ApiException.class)
                .hasMessage("Cannot delete workout day referenced by planned schedule");
    }

    @Test
    @DisplayName("archiveProgram sets status ARCHIVED")
    void archiveProgramSetsStatusArchived() {
        var createReq = new WorkoutProgramRequest("Program A", "CUSTOM", null, "ACTIVE", List.of());
        var created = service.createProgram(userId, createReq);

        service.archiveProgram(userId, created.id());

        var list = service.listPrograms(userId, "ACTIVE", PageRequest.of(0, 10));
        assertThat(list.totalElements()).isEqualTo(0);
    }
}
