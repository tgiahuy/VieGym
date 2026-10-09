package com.viegym.workout;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.viegym.common.error.ApiException;
import com.viegym.identity.UserProfileRepository;
import com.viegym.workout.planning.api.CreateScheduleProposalRequest;
import com.viegym.workout.planning.api.ScheduleExercisePlan;
import com.viegym.workout.planning.api.ScheduleProposalItemRequest;
import com.viegym.workout.planning.application.WorkoutSchedulePlanningService;
import com.viegym.workout.schedule.application.WorkoutScheduleService;
import com.viegym.workout.template.api.WorkoutTemplateDayRequest;
import com.viegym.workout.template.api.WorkoutTemplateRequest;
import com.viegym.workout.template.application.WorkoutTemplateService;
import java.time.Clock;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.temporal.TemporalAdjusters;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

@Testcontainers
@SpringBootTest
class WorkoutSchedulePlanningServiceTests {

    @Container
    static final PostgreSQLContainer<?> POSTGRES =
            new PostgreSQLContainer<>("postgres:16.14-bookworm")
                    .withDatabaseName("viegym_planning_test")
                    .withUsername("viegym_planning_test")
                    .withPassword("test_password");

    @DynamicPropertySource
    static void datasourceProperties(DynamicPropertyRegistry registry) {
        registry.add("SPRING_DATASOURCE_URL", POSTGRES::getJdbcUrl);
        registry.add("SPRING_DATASOURCE_USERNAME", POSTGRES::getUsername);
        registry.add("SPRING_DATASOURCE_PASSWORD", POSTGRES::getPassword);
    }

    @Autowired JdbcTemplate jdbc;
    @Autowired UserProfileRepository userProfiles;
    @Autowired Clock clock;

    private WorkoutSchedulePlanningService planning;
    private WorkoutTemplateService templates;
    private Long userId;
    private Long adminId;
    private Long exerciseId;
    private LocalDate monday;

    @BeforeEach
    void setUp() {
        WorkoutScheduleService scheduleService = new WorkoutScheduleService(jdbc);
        planning = new WorkoutSchedulePlanningService(jdbc, scheduleService, userProfiles, clock);
        templates = new WorkoutTemplateService(jdbc);

        jdbc.update("delete from workout_schedule_exercises");
        jdbc.update("delete from workout_schedule_proposal_exercises");
        jdbc.update("update workout_schedule_proposal_items set applied_schedule_id = null");
        jdbc.update("delete from workout_schedules");
        jdbc.update("delete from workout_schedule_proposal_items");
        jdbc.update("delete from workout_schedule_proposals");
        jdbc.update("delete from workout_template_exercises");
        jdbc.update("delete from workout_template_days");
        jdbc.update("delete from workout_program_templates");
        jdbc.update("delete from exercise_muscle_groups");
        jdbc.update("delete from workout_exercises");
        jdbc.update("delete from workout_days");
        jdbc.update("delete from workout_programs");
        jdbc.update("delete from exercise_import_registry");
        jdbc.update("delete from dataset_import_batches");
        jdbc.update("delete from exercises");
        jdbc.update("delete from muscle_groups");
        jdbc.update("delete from users");

        userId = insertUser("planning-user@example.com", "USER");
        adminId = insertUser("planning-admin@example.com", "ADMIN");
        exerciseId =
                jdbc.queryForObject(
                        "insert into exercises (name, search_name, slug, difficulty, description, visibility) values ('Goblet Squat', 'goblet squat', 'goblet-squat-planning', 'BEGINNER', 'Squat', 'PUBLIC') returning id",
                        Long.class);
        Long muscleId =
                jdbc.queryForObject(
                        "insert into muscle_groups (code, name, is_active) values ('QUADS_TEST', 'Đùi trước', true) returning id",
                        Long.class);
        jdbc.update(
                "insert into exercise_muscle_groups (exercise_id, muscle_group_id, role) values (?, ?, 'PRIMARY')",
                exerciseId,
                muscleId);
        monday = LocalDate.now().plusDays(1).with(TemporalAdjusters.nextOrSame(DayOfWeek.MONDAY));
    }

    @Test
    @DisplayName("manual week preview applies atomically and preserves an exercise snapshot")
    void manualWeekPreviewAndApply() {
        ScheduleExercisePlan exercise = exercise(1);
        var request =
                new CreateScheduleProposalRequest(
                        "MANUAL",
                        "WEEK",
                        null,
                        null,
                        null,
                        null,
                        List.of(
                                new ScheduleProposalItemRequest(
                                        monday,
                                        LocalTime.of(18, 30),
                                        "Full Body A",
                                        List.of(exercise)),
                                new ScheduleProposalItemRequest(
                                        monday.plusDays(2),
                                        LocalTime.of(18, 30),
                                        "Full Body B",
                                        List.of(exercise))));

        var proposal = planning.createProposal(userId, request);
        assertThat(proposal.status()).isEqualTo("PENDING");
        assertThat(proposal.items()).hasSize(2);
        assertThat(proposal.items().get(0).exercises().get(0).exerciseName())
                .isEqualTo("Goblet Squat");
        assertThat(proposal.items().get(0).exercises().get(0).primaryMuscle())
                .isEqualTo("Đùi trước");

        var applied = planning.apply(userId, proposal.id());
        assertThat(applied.status()).isEqualTo("APPLIED");
        assertThat(applied.schedules()).hasSize(2);
        assertThat(applied.schedules().get(0).exercises())
                .extracting(scheduleExercise -> scheduleExercise.exerciseName())
                .containsExactly("Goblet Squat");
        assertThat(applied.schedules().get(0).exercises())
                .extracting(scheduleExercise -> scheduleExercise.primaryMuscle())
                .containsExactly("Đùi trước");
        assertThat(
                        jdbc.queryForObject(
                                "select count(*) from workout_schedule_exercises", Integer.class))
                .isEqualTo(2);

        var retry = planning.apply(userId, proposal.id());
        assertThat(retry.schedules()).hasSize(2);
        assertThat(jdbc.queryForObject("select count(*) from workout_schedules", Integer.class))
                .isEqualTo(2);
    }

    @Test
    @DisplayName("user program week maps each owned workout day to one requested date")
    void userProgramWeekMapsDays() {
        Long programId =
                jdbc.queryForObject(
                        "insert into workout_programs (user_id, name, program_type, status) values (?, 'Upper Lower', 'UPPER_LOWER', 'ACTIVE') returning id",
                        Long.class,
                        userId);
        Long upperId = insertProgramDay(programId, 1, "Upper A");
        Long lowerId = insertProgramDay(programId, 2, "Lower A");
        insertProgramExercise(upperId, 1);
        insertProgramExercise(lowerId, 1);

        var proposal =
                planning.createProposal(
                        userId,
                        new CreateScheduleProposalRequest(
                                "USER_PROGRAM",
                                "WEEK",
                                programId,
                                null,
                                List.of(monday, monday.plusDays(3)),
                                LocalTime.of(19, 0),
                                null));

        assertThat(proposal.items())
                .extracting(item -> item.title())
                .containsExactly("Upper A", "Lower A");
        var applied = planning.apply(userId, proposal.id());
        assertThat(applied.schedules())
                .extracting(schedule -> schedule.workoutDayId())
                .containsExactly(upperId, lowerId);
    }

    @Test
    @DisplayName(
            "published admin template can create a one-day proposal and version changes invalidate it")
    void adminTemplateVersionProtectsProposal() {
        WorkoutTemplateRequest templateRequest =
                new WorkoutTemplateRequest(
                        "Beginner Full Body",
                        "FULL_BODY",
                        "Admin curated",
                        "BEGINNER",
                        "GAIN_MUSCLE",
                        "PUBLISHED",
                        List.of(
                                new WorkoutTemplateDayRequest(
                                        1, "Full Body A", null, List.of(exercise(1)))));
        var template = templates.create(adminId, templateRequest);
        Long templateDayId = template.days().get(0).id();

        var proposal =
                planning.createProposal(
                        userId,
                        new CreateScheduleProposalRequest(
                                "ADMIN_TEMPLATE",
                                "ONE_DAY",
                                template.id(),
                                templateDayId,
                                List.of(monday),
                                LocalTime.of(7, 0),
                                null));
        assertThat(proposal.sourceVersion()).isEqualTo(1);

        templates.update(template.id(), templateRequest);

        assertThatThrownBy(() -> planning.apply(userId, proposal.id()))
                .isInstanceOf(ApiException.class)
                .hasMessage("Workout template changed; create a new preview");
    }

    private Long insertUser(String email, String role) {
        return jdbc.queryForObject(
                "insert into users (email, password_hash, auth_provider, role, status, email_verified_at) values (?, 'hash', 'LOCAL', ?, 'ACTIVE', now()) returning id",
                Long.class,
                email,
                role);
    }

    private Long insertProgramDay(Long programId, int dayNumber, String name) {
        return jdbc.queryForObject(
                "insert into workout_days (workout_program_id, day_number, name) values (?, ?, ?) returning id",
                Long.class,
                programId,
                dayNumber,
                name);
    }

    private void insertProgramExercise(Long dayId, int sortOrder) {
        jdbc.update(
                "insert into workout_exercises (workout_day_id, exercise_id, sort_order, target_sets, target_reps_min, target_reps_max, rest_seconds) values (?, ?, ?, 3, 8, 12, 90)",
                dayId,
                exerciseId,
                sortOrder);
    }

    private ScheduleExercisePlan exercise(int sortOrder) {
        return new ScheduleExercisePlan(
                exerciseId, "Goblet Squat", "Đùi trước", sortOrder, 3, 8, 12, null, 90, null);
    }
}
