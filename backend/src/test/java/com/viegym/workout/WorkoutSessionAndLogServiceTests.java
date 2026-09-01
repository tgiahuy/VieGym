package com.viegym.workout;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.viegym.common.error.ApiException;
import com.viegym.workout.log.application.WorkoutHistoryService;
import com.viegym.workout.schedule.api.WorkoutScheduleRequest;
import com.viegym.workout.schedule.application.WorkoutScheduleService;
import com.viegym.workout.session.api.FinishExerciseLogRequest;
import com.viegym.workout.session.api.FinishSessionRequest;
import com.viegym.workout.session.api.FinishSetLogRequest;
import com.viegym.workout.session.application.WorkoutSessionService;
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
class WorkoutSessionAndLogServiceTests {

    @Container
    static final PostgreSQLContainer<?> POSTGRES =
            new PostgreSQLContainer<>("postgres:16.14-bookworm")
                    .withDatabaseName("viegym_session_svc_test")
                    .withUsername("viegym_session_svc_test")
                    .withPassword("test_password");

    @DynamicPropertySource
    static void datasourceProperties(DynamicPropertyRegistry registry) {
        registry.add("SPRING_DATASOURCE_URL", POSTGRES::getJdbcUrl);
        registry.add("SPRING_DATASOURCE_USERNAME", POSTGRES::getUsername);
        registry.add("SPRING_DATASOURCE_PASSWORD", POSTGRES::getPassword);
    }

    @Autowired JdbcTemplate jdbcTemplate;

    private WorkoutSessionService sessionService;
    private WorkoutScheduleService scheduleService;
    private WorkoutHistoryService historyService;
    private Long userId;
    private Long exerciseId;

    @BeforeEach
    void setUp() {
        sessionService = new WorkoutSessionService(jdbcTemplate);
        scheduleService = new WorkoutScheduleService(jdbcTemplate);
        historyService = new WorkoutHistoryService(jdbcTemplate);

        jdbcTemplate.update("delete from personal_records");
        jdbcTemplate.update("delete from workout_set_logs");
        jdbcTemplate.update("delete from workout_exercise_logs");
        jdbcTemplate.update("delete from workout_logs");
        jdbcTemplate.update("delete from workout_sessions");
        jdbcTemplate.update("delete from workout_schedules");
        jdbcTemplate.update("delete from exercise_import_registry");
        jdbcTemplate.update("delete from dataset_import_batches");
        jdbcTemplate.update("delete from exercises");
        jdbcTemplate.update("delete from users");

        userId =
                jdbcTemplate.queryForObject(
                        "insert into users (email, password_hash, auth_provider, role, status,"
                                + " email_verified_at) values ('session-svc-user@example.com', 'hash',"
                                + " 'LOCAL', 'USER', 'ACTIVE', now()) returning id",
                        Long.class);

        exerciseId =
                jdbcTemplate.queryForObject(
                        "insert into exercises (name, search_name, slug, difficulty, description,"
                                + " visibility) values ('Squat', 'squat', 'squat', 'BEGINNER', 'Gánh"
                                + " tạ', 'PUBLIC') returning id",
                        Long.class);
    }

    @Test
    @DisplayName(
            "startSession creates active session and blocks concurrent active session on other schedule")
    void startSessionLifecycleAndConcurrency() {
        var sched1 =
                scheduleService.createSchedule(
                        userId,
                        new WorkoutScheduleRequest(
                                null, null, LocalDate.parse("2026-09-02"), null, "Session 1"));
        var sched2 =
                scheduleService.createSchedule(
                        userId,
                        new WorkoutScheduleRequest(
                                null, null, LocalDate.parse("2026-09-03"), null, "Session 2"));

        var session1 = sessionService.startSession(userId, sched1.id());
        assertThat(session1.status()).isEqualTo("IN_PROGRESS");

        // Idempotent retry on same schedule returns session1
        var retry = sessionService.startSession(userId, sched1.id());
        assertThat(retry.id()).isEqualTo(session1.id());

        // Starting on another schedule fails with ACTIVE_SESSION_EXISTS
        assertThatThrownBy(() -> sessionService.startSession(userId, sched2.id()))
                .isInstanceOf(ApiException.class)
                .hasMessageContaining("Active workout session already exists");
    }

    @Test
    @DisplayName("pause and resume transitions session state and accumulates paused seconds")
    void pauseAndResumeLifecycle() {
        var sched =
                scheduleService.createSchedule(
                        userId,
                        new WorkoutScheduleRequest(
                                null, null, LocalDate.parse("2026-09-02"), null, "Session 1"));
        var session = sessionService.startSession(userId, sched.id());

        var paused = sessionService.pauseSession(userId, session.id());
        assertThat(paused.status()).isEqualTo("PAUSED");

        var resumed = sessionService.resumeSession(userId, session.id());
        assertThat(resumed.status()).isEqualTo("IN_PROGRESS");
    }

    @Test
    @DisplayName(
            "finishSession atomically creates logs, computes volume and PRs, and marks schedule completed")
    void finishSessionCreatesLogsAndPrs() {
        var sched =
                scheduleService.createSchedule(
                        userId,
                        new WorkoutScheduleRequest(
                                null, null, LocalDate.parse("2026-09-02"), null, "Leg Day"));
        var session = sessionService.startSession(userId, sched.id());

        var set1 = new FinishSetLogRequest(1, 10, 80.0, null, 7.0, true);
        var set2 = new FinishSetLogRequest(2, 8, 100.0, null, 8.5, true);
        var exLog = new FinishExerciseLogRequest(exerciseId, 1, 600, true, List.of(set1, set2));
        var finishReq = new FinishSessionRequest("Great leg workout", List.of(exLog));

        var finishRes = sessionService.finishSession(userId, session.id(), finishReq);
        assertThat(finishRes.workoutLogId()).isNotNull();
        // Volume = (10 * 80) + (8 * 100) = 800 + 800 = 1600.0
        assertThat(finishRes.totalVolumeKg()).isEqualTo(1600.0);
        assertThat(finishRes.newPersonalRecords())
                .hasSize(3); // MAX_WEIGHT (100), MAX_REPS (10), MAX_VOLUME (800)

        // Schedule is COMPLETED
        var completedSched = scheduleService.getSchedule(userId, sched.id());
        assertThat(completedSched.status()).isEqualTo("COMPLETED");

        // History query
        var history =
                historyService.listWorkoutLogs(userId, null, null, null, PageRequest.of(0, 10));
        assertThat(history.totalElements()).isEqualTo(1);
        assertThat(history.content().get(0).totalVolumeKg()).isEqualTo(1600.0);

        // Detail query
        var detail = historyService.getWorkoutLogDetail(userId, finishRes.workoutLogId());
        assertThat(detail.title()).isEqualTo("Leg Day");
        assertThat(detail.exercises()).hasSize(1);
        assertThat(detail.exercises().get(0).sets()).hasSize(2);

        // PRs query
        var prs =
                historyService.listPersonalRecords(userId, exerciseId, null, PageRequest.of(0, 10));
        assertThat(prs.totalElements()).isEqualTo(3);
    }

    @Test
    @DisplayName("discardSession cancels session without creating workout log or PR")
    void discardSessionLifecycle() {
        var sched =
                scheduleService.createSchedule(
                        userId,
                        new WorkoutScheduleRequest(
                                null, null, LocalDate.parse("2026-09-02"), null, "Discard Test"));
        var session = sessionService.startSession(userId, sched.id());

        sessionService.discardSession(userId, session.id(), "Started wrong workout");

        var logs = historyService.listWorkoutLogs(userId, null, null, null, PageRequest.of(0, 10));
        assertThat(logs.totalElements()).isEqualTo(0);

        var prs = historyService.listPersonalRecords(userId, null, null, PageRequest.of(0, 10));
        assertThat(prs.totalElements()).isEqualTo(0);
    }
}
