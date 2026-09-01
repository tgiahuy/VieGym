package com.viegym.exercise;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.viegym.exercise.dataset.ExerciseDatasetImportResult;
import com.viegym.exercise.dataset.ExerciseDatasetImporter;
import java.nio.file.Files;
import java.nio.file.Path;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
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
class ExerciseDatasetImporterTests {

    @Container
    static final PostgreSQLContainer<?> POSTGRES =
            new PostgreSQLContainer<>("postgres:16.14-bookworm")
                    .withDatabaseName("viegym_dataset_test")
                    .withUsername("viegym_dataset_test")
                    .withPassword("test_password");

    @DynamicPropertySource
    static void datasourceProperties(DynamicPropertyRegistry registry) {
        registry.add("SPRING_DATASOURCE_URL", POSTGRES::getJdbcUrl);
        registry.add("SPRING_DATASOURCE_USERNAME", POSTGRES::getUsername);
        registry.add("SPRING_DATASOURCE_PASSWORD", POSTGRES::getPassword);
    }

    @Autowired ExerciseDatasetImporter importer;
    @Autowired JdbcTemplate jdbcTemplate;

    @TempDir Path tempDirectory;

    @BeforeEach
    void resetImportedExerciseData() {
        jdbcTemplate.execute(
                "TRUNCATE TABLE exercise_import_registry, exercise_muscle_groups, "
                        + "exercise_equipment, favorite_exercises, exercises, "
                        + "dataset_import_batches RESTART IDENTITY CASCADE");
    }

    @Test
    void importsOnceAndSkipsExistingImportKeysOnRerun() throws Exception {
        Path fixture =
                Path.of(getClass().getResource("/datasets/exercise_import_fixture.json").toURI())
                        .toAbsolutePath();

        ExerciseDatasetImportResult first = importer.importFile(fixture);
        ExerciseDatasetImportResult second = importer.importFile(fixture);

        assertThat(first.insertedRecords()).isEqualTo(2);
        assertThat(first.skippedRecords()).isZero();
        assertThat(second.insertedRecords()).isZero();
        assertThat(second.skippedRecords()).isEqualTo(2);
        assertThat(
                        jdbcTemplate.queryForObject(
                                "select count(*) from exercise_import_registry where source = 'TEST'",
                                Integer.class))
                .isEqualTo(2);
        assertThat(
                        jdbcTemplate.queryForObject(
                                "select count(*) from dataset_import_batches "
                                        + "where dataset_type = 'EXERCISE' and status = 'SUCCEEDED'",
                                Integer.class))
                .isEqualTo(2);
        assertThat(
                        jdbcTemplate.queryForObject(
                                "select count(*) from exercise_equipment ee "
                                        + "join exercises e on e.id = ee.exercise_id "
                                        + "where e.slug = 'test-bench-press'",
                                Integer.class))
                .isEqualTo(2);
    }

    @Test
    void rollsBackMasterDataAndRecordsFailedBatch() throws Exception {
        Path fixture =
                Path.of(getClass().getResource("/datasets/exercise_import_fixture.json").toURI())
                        .toAbsolutePath();
        String invalidContent =
                Files.readString(fixture)
                        .replaceFirst("\\\"verified\\\": true", "\\\"verified\\\": false");
        Path invalidFixture = tempDirectory.resolve("invalid_exercise_import.json");
        Files.writeString(invalidFixture, invalidContent);

        assertThatThrownBy(() -> importer.importFile(invalidFixture))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("PUBLIC Exercise must be verified");
        assertThat(
                        jdbcTemplate.queryForObject(
                                "select count(*) from exercise_import_registry where source = 'TEST'",
                                Integer.class))
                .isZero();
        assertThat(
                        jdbcTemplate.queryForObject(
                                "select count(*) from dataset_import_batches "
                                        + "where dataset_type = 'EXERCISE' and status = 'FAILED'",
                                Integer.class))
                .isEqualTo(1);
    }
}
