package com.viegym.exercise;

import static org.assertj.core.api.Assertions.assertThat;

import com.viegym.common.api.PageResponse;
import com.viegym.exercise.api.EquipmentDto;
import com.viegym.exercise.api.ExerciseSummaryDto;
import com.viegym.exercise.api.MuscleGroupDto;
import com.viegym.exercise.application.ExerciseCatalogService;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

@Testcontainers
@SpringBootTest
class ExerciseCatalogServiceTests {

    @Container
    static final PostgreSQLContainer<?> POSTGRES =
            new PostgreSQLContainer<>("postgres:16.14-bookworm")
                    .withDatabaseName("viegym_exercise_svc_test")
                    .withUsername("viegym_exercise_svc_test")
                    .withPassword("test_password");

    @DynamicPropertySource
    static void datasourceProperties(DynamicPropertyRegistry registry) {
        registry.add("SPRING_DATASOURCE_URL", POSTGRES::getJdbcUrl);
        registry.add("SPRING_DATASOURCE_USERNAME", POSTGRES::getUsername);
        registry.add("SPRING_DATASOURCE_PASSWORD", POSTGRES::getPassword);
    }

    @Autowired JdbcTemplate jdbcTemplate;

    private ExerciseCatalogService service;
    private Long chestMgId;
    private Long tricepsMgId;
    private Long barbellEqId;
    private Long dumbbellEqId;
    private Long bodyweightEqId;
    private Long benchPressId;
    private Long dumbbellPressId;
    private Long pushUpId;
    private Long hiddenExId;

    @BeforeEach
    void setUp() {
        service =
                new ExerciseCatalogService(
                        jdbcTemplate, new com.fasterxml.jackson.databind.ObjectMapper());
        jdbcTemplate.update("delete from favorite_exercises");
        jdbcTemplate.update("delete from exercise_equipment");
        jdbcTemplate.update("delete from exercise_muscle_groups");
        jdbcTemplate.update("delete from exercise_import_registry");
        jdbcTemplate.update("delete from dataset_import_batches");
        jdbcTemplate.update("delete from exercises");
        jdbcTemplate.update("delete from user_equipment_preferences");
        jdbcTemplate.update("delete from muscle_groups");

        chestMgId =
                jdbcTemplate.queryForObject(
                        "insert into muscle_groups (code, name, description) values ('CHEST', 'Ngực',"
                                + " 'Cơ ngực') returning id",
                        Long.class);
        tricepsMgId =
                jdbcTemplate.queryForObject(
                        "insert into muscle_groups (code, name, description) values ('TRICEPS', 'Tay"
                                + " sau', 'Cơ tay sau') returning id",
                        Long.class);

        barbellEqId =
                jdbcTemplate.queryForObject(
                        "select id from equipment where code = 'BARBELL'", Long.class);
        dumbbellEqId =
                jdbcTemplate.queryForObject(
                        "select id from equipment where code = 'DUMBBELL'", Long.class);
        bodyweightEqId =
                jdbcTemplate.queryForObject(
                        "select id from equipment where code = 'BODYWEIGHT'", Long.class);

        // 1. Bench Press (Barbell, Chest Primary, Triceps Secondary, Intermediate, Public)
        benchPressId =
                jdbcTemplate.queryForObject(
                        "insert into exercises (name, search_name, slug, difficulty, description,"
                                + " visibility) values ('Barbell Bench Press', 'barbell bench press',"
                                + " 'barbell-bench-press', 'INTERMEDIATE', 'Đẩy ngực với đòn', 'PUBLIC')"
                                + " returning id",
                        Long.class);
        jdbcTemplate.update(
                "insert into exercise_muscle_groups (exercise_id, muscle_group_id, role) values (?,"
                        + " ?, 'PRIMARY')",
                benchPressId,
                chestMgId);
        jdbcTemplate.update(
                "insert into exercise_muscle_groups (exercise_id, muscle_group_id, role) values (?,"
                        + " ?, 'SECONDARY')",
                benchPressId,
                tricepsMgId);
        jdbcTemplate.update(
                "insert into exercise_equipment (exercise_id, equipment_id, is_required) values (?,"
                        + " ?, true)",
                benchPressId,
                barbellEqId);

        // 2. Dumbbell Press (Dumbbell, Chest Primary, Beginner, Public)
        dumbbellPressId =
                jdbcTemplate.queryForObject(
                        "insert into exercises (name, search_name, slug, difficulty, description,"
                                + " visibility) values ('Dumbbell Press', 'dumbbell press',"
                                + " 'dumbbell-press', 'BEGINNER', 'Đẩy ngực với tạ đơn', 'PUBLIC')"
                                + " returning id",
                        Long.class);
        jdbcTemplate.update(
                "insert into exercise_muscle_groups (exercise_id, muscle_group_id, role) values (?,"
                        + " ?, 'PRIMARY')",
                dumbbellPressId,
                chestMgId);
        jdbcTemplate.update(
                "insert into exercise_equipment (exercise_id, equipment_id, is_required) values (?,"
                        + " ?, true)",
                dumbbellPressId,
                dumbbellEqId);

        // 3. Push Up (Bodyweight, Chest Primary, Triceps Secondary, Beginner, Public)
        pushUpId =
                jdbcTemplate.queryForObject(
                        "insert into exercises (name, search_name, slug, difficulty, description,"
                                + " visibility) values ('Push Up', 'push up', 'push-up', 'BEGINNER',"
                                + " 'Hít đất', 'PUBLIC') returning id",
                        Long.class);
        jdbcTemplate.update(
                "insert into exercise_muscle_groups (exercise_id, muscle_group_id, role) values (?,"
                        + " ?, 'PRIMARY')",
                pushUpId,
                chestMgId);
        jdbcTemplate.update(
                "insert into exercise_muscle_groups (exercise_id, muscle_group_id, role) values (?,"
                        + " ?, 'SECONDARY')",
                pushUpId,
                tricepsMgId);
        jdbcTemplate.update(
                "insert into exercise_equipment (exercise_id, equipment_id, is_required) values (?,"
                        + " ?, true)",
                pushUpId,
                bodyweightEqId);

        // 4. Hidden Exercise
        hiddenExId =
                jdbcTemplate.queryForObject(
                        "insert into exercises (name, search_name, slug, difficulty, description,"
                                + " visibility) values ('Secret Lift', 'secret lift', 'secret-lift',"
                                + " 'ADVANCED', 'Bài tập ẩn', 'HIDDEN') returning id",
                        Long.class);
    }

    @Test
    @DisplayName("listMuscleGroups returns active muscle groups sorted by name")
    void listMuscleGroupsReturnsActiveGroups() {
        List<MuscleGroupDto> groups = service.listMuscleGroups();
        assertThat(groups).hasSize(2);
        assertThat(groups.get(0).name()).isEqualTo("Ngực");
        assertThat(groups.get(1).name()).isEqualTo("Tay sau");
    }

    @Test
    @DisplayName("listEquipment returns active equipment catalog")
    void listEquipmentReturnsActiveEquipment() {
        List<EquipmentDto> equipment = service.listEquipment();
        assertThat(equipment).isNotEmpty();
        assertThat(equipment).anyMatch(e -> e.code().equals("BARBELL"));
        assertThat(equipment).anyMatch(e -> e.code().equals("DUMBBELL"));
    }

    @Test
    @DisplayName("searchExercises returns public exercises with muscle and equipment mappings")
    void searchExercisesReturnsPublicExercises() {
        PageResponse<ExerciseSummaryDto> response =
                service.searchExercises(null, null, null, null, null, false, PageRequest.of(0, 10));

        assertThat(response.totalElements()).isEqualTo(3);
        assertThat(response.content())
                .extracting(ExerciseSummaryDto::name)
                .containsExactlyInAnyOrder("Barbell Bench Press", "Dumbbell Press", "Push Up");

        ExerciseSummaryDto bench =
                response.content().stream()
                        .filter(e -> e.id().equals(benchPressId))
                        .findFirst()
                        .orElseThrow();
        assertThat(bench.muscleGroups()).hasSize(2);
        assertThat(bench.muscleGroups().get(0).code()).isEqualTo("CHEST");
        assertThat(bench.muscleGroups().get(0).role()).isEqualTo("PRIMARY");
        assertThat(bench.equipment()).hasSize(1);
        assertThat(bench.equipment().get(0).code()).isEqualTo("BARBELL");
    }

    @Test
    @DisplayName("searchExercises filters by search keyword q case-insensitively")
    void searchExercisesFiltersByKeyword() {
        PageResponse<ExerciseSummaryDto> response =
                service.searchExercises(
                        null, "DUMBBELL", null, null, null, false, PageRequest.of(0, 10));

        assertThat(response.totalElements()).isEqualTo(1);
        assertThat(response.content().get(0).name()).isEqualTo("Dumbbell Press");
    }

    @Test
    @DisplayName("searchExercises filters by muscleGroupId")
    void searchExercisesFiltersByMuscleGroup() {
        PageResponse<ExerciseSummaryDto> response =
                service.searchExercises(
                        null, null, tricepsMgId, null, null, false, PageRequest.of(0, 10));

        assertThat(response.totalElements()).isEqualTo(2);
        assertThat(response.content())
                .extracting(ExerciseSummaryDto::name)
                .containsExactlyInAnyOrder("Barbell Bench Press", "Push Up");
    }

    @Test
    @DisplayName("searchExercises filters by equipmentId")
    void searchExercisesFiltersByEquipment() {
        PageResponse<ExerciseSummaryDto> response =
                service.searchExercises(
                        null, null, null, barbellEqId, null, false, PageRequest.of(0, 10));

        assertThat(response.totalElements()).isEqualTo(1);
        assertThat(response.content().get(0).name()).isEqualTo("Barbell Bench Press");
    }

    @Test
    @DisplayName("searchExercises filters by difficulty")
    void searchExercisesFiltersByDifficulty() {
        PageResponse<ExerciseSummaryDto> response =
                service.searchExercises(
                        null, null, null, null, "INTERMEDIATE", false, PageRequest.of(0, 10));

        assertThat(response.totalElements()).isEqualTo(1);
        assertThat(response.content().get(0).name()).isEqualTo("Barbell Bench Press");
    }

    @Test
    @DisplayName("searchExercises filters by compatibleWithMyEquipment")
    void searchExercisesFiltersByCompatibleEquipment() {
        Long userId =
                jdbcTemplate.queryForObject(
                        "insert into users (email, password_hash, auth_provider, role, status,"
                                + " email_verified_at) values ('exercise-user@example.com',"
                                + " 'hash', 'LOCAL', 'USER', 'ACTIVE', now()) returning id",
                        Long.class);
        // User has only Dumbbell and Bodyweight selected
        jdbcTemplate.update(
                "insert into user_equipment_preferences (user_id, equipment_id) values (?, ?)",
                userId,
                dumbbellEqId);
        jdbcTemplate.update(
                "insert into user_equipment_preferences (user_id, equipment_id) values (?, ?)",
                userId,
                bodyweightEqId);

        PageResponse<ExerciseSummaryDto> response =
                service.searchExercises(
                        userId, null, null, null, null, true, PageRequest.of(0, 10));

        assertThat(response.totalElements()).isEqualTo(2);
        assertThat(response.content())
                .extracting(ExerciseSummaryDto::name)
                .containsExactlyInAnyOrder("Dumbbell Press", "Push Up");
    }

    @Test
    @DisplayName("searchExercises supports pagination and sorting")
    void searchExercisesSupportsPaginationAndSorting() {
        PageResponse<ExerciseSummaryDto> page1 =
                service.searchExercises(
                        null,
                        null,
                        null,
                        null,
                        null,
                        false,
                        PageRequest.of(0, 2, Sort.by(Sort.Direction.DESC, "name")));

        assertThat(page1.totalElements()).isEqualTo(3);
        assertThat(page1.content()).hasSize(2);
        assertThat(page1.content().get(0).name()).isEqualTo("Push Up");
        assertThat(page1.content().get(1).name()).isEqualTo("Dumbbell Press");
        assertThat(page1.hasNext()).isTrue();
    }

    @Test
    @DisplayName("getExerciseDetail returns complete detail including JSON instructions and notes")
    void getExerciseDetailReturnsCompleteDetail() {
        jdbcTemplate.update(
                "update exercises set instruction_steps = '[\"Step 1\", \"Step 2\"]'::jsonb,"
                        + " common_mistakes = '[\"Mistake 1\"]'::jsonb, safety_notes = '[\"Safety"
                        + " 1\"]'::jsonb where id = ?",
                benchPressId);

        var detail = service.getExerciseDetail(benchPressId);
        assertThat(detail.id()).isEqualTo(benchPressId);
        assertThat(detail.name()).isEqualTo("Barbell Bench Press");
        assertThat(detail.instructionSteps()).containsExactly("Step 1", "Step 2");
        assertThat(detail.commonMistakes()).containsExactly("Mistake 1");
        assertThat(detail.safetyNotes()).containsExactly("Safety 1");
        assertThat(detail.muscleGroups()).hasSize(2);
        assertThat(detail.equipment()).hasSize(1);
    }

    @Test
    @DisplayName("getExerciseDetail throws EXERCISE_NOT_FOUND for hidden or non-existent exercise")
    void getExerciseDetailThrowsForHiddenOrNotFound() {
        org.assertj.core.api.Assertions.assertThatThrownBy(
                        () -> service.getExerciseDetail(hiddenExId))
                .isInstanceOf(com.viegym.common.error.ApiException.class)
                .hasMessage("Exercise not found");

        org.assertj.core.api.Assertions.assertThatThrownBy(() -> service.getExerciseDetail(99999L))
                .isInstanceOf(com.viegym.common.error.ApiException.class)
                .hasMessage("Exercise not found");
    }

    @Test
    @DisplayName(
            "getExerciseAlternatives returns exercises sharing primary muscle group ranked by user equipment")
    void getExerciseAlternativesReturnsRankedAlternatives() {
        Long userId =
                jdbcTemplate.queryForObject(
                        "insert into users (email, password_hash, auth_provider, role, status,"
                                + " email_verified_at) values ('alt-user@example.com', 'hash',"
                                + " 'LOCAL', 'USER', 'ACTIVE', now()) returning id",
                        Long.class);
        // User has only dumbbell
        jdbcTemplate.update(
                "insert into user_equipment_preferences (user_id, equipment_id) values (?, ?)",
                userId,
                dumbbellEqId);

        // Alternatives for Bench Press (Chest Primary): Dumbbell Press and Push Up
        var alternatives = service.getExerciseAlternatives(userId, benchPressId, 5);

        assertThat(alternatives).hasSize(2);
        // Dumbbell Press should be ranked first (compatible equipment), then Push Up
        assertThat(alternatives.get(0).name()).isEqualTo("Dumbbell Press");
        assertThat(alternatives.get(1).name()).isEqualTo("Push Up");
    }

    @Test
    @DisplayName("favorite exercises support add, list with search, and remove")
    void favoriteExercisesFlow() {
        Long userId =
                jdbcTemplate.queryForObject(
                        "insert into users (email, password_hash, auth_provider, role, status,"
                                + " email_verified_at) values ('fav-user@example.com', 'hash',"
                                + " 'LOCAL', 'USER', 'ACTIVE', now()) returning id",
                        Long.class);

        service.addFavorite(userId, benchPressId);
        service.addFavorite(userId, pushUpId);
        // Idempotent duplicate add
        service.addFavorite(userId, benchPressId);

        var favorites = service.listFavorites(userId, null, PageRequest.of(0, 10));
        assertThat(favorites.totalElements()).isEqualTo(2);

        var filteredFavorites = service.listFavorites(userId, "bench", PageRequest.of(0, 10));
        assertThat(filteredFavorites.totalElements()).isEqualTo(1);
        assertThat(filteredFavorites.content().get(0).name()).isEqualTo("Barbell Bench Press");

        service.removeFavorite(userId, benchPressId);
        var afterRemove = service.listFavorites(userId, null, PageRequest.of(0, 10));
        assertThat(afterRemove.totalElements()).isEqualTo(1);
        assertThat(afterRemove.content().get(0).name()).isEqualTo("Push Up");
    }

    @Test
    @DisplayName("addFavorite throws EXERCISE_NOT_FOUND when adding hidden exercise")
    void addFavoriteThrowsForHidden() {
        Long userId =
                jdbcTemplate.queryForObject(
                        "insert into users (email, password_hash, auth_provider, role, status,"
                                + " email_verified_at) values ('fav-hidden-user@example.com', 'hash',"
                                + " 'LOCAL', 'USER', 'ACTIVE', now()) returning id",
                        Long.class);

        org.assertj.core.api.Assertions.assertThatThrownBy(
                        () -> service.addFavorite(userId, hiddenExId))
                .isInstanceOf(com.viegym.common.error.ApiException.class)
                .hasMessage("Exercise not found");
    }
}
