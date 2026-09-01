package com.viegym.exercise.dataset;

import java.nio.file.Path;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;

@Component
@ConditionalOnProperty(name = "viegym.dataset.exercise.enabled", havingValue = "true")
public class ExerciseDatasetImportRunner implements ApplicationRunner {

    private static final Logger LOGGER = LoggerFactory.getLogger(ExerciseDatasetImportRunner.class);

    private final ExerciseDatasetImporter importer;
    private final Path datasetPath;

    public ExerciseDatasetImportRunner(
            ExerciseDatasetImporter importer,
            @Value("${viegym.dataset.exercise.path:../datasets/exports/viegym_exercises_v1.json}")
                    String datasetPath) {
        this.importer = importer;
        this.datasetPath = Path.of(datasetPath).toAbsolutePath().normalize();
    }

    @Override
    public void run(ApplicationArguments args) throws Exception {
        Path resolvedPath = datasetPath;
        if (!java.nio.file.Files.exists(resolvedPath)) {
            Path fallback1 = Path.of("datasets/exports/viegym_exercises_v1.json").toAbsolutePath().normalize();
            Path fallback2 = Path.of("../datasets/exports/viegym_exercises_v1.json").toAbsolutePath().normalize();
            if (java.nio.file.Files.exists(fallback1)) {
                resolvedPath = fallback1;
            } else if (java.nio.file.Files.exists(fallback2)) {
                resolvedPath = fallback2;
            }
        }

        if (java.nio.file.Files.exists(resolvedPath)) {
            ExerciseDatasetImportResult result = importer.importFile(resolvedPath);
            LOGGER.info(
                    "Exercise dataset import completed: batchId={}, version={}, total={}, inserted={}, skipped={}",
                    result.batchId(),
                    result.datasetVersion(),
                    result.totalRecords(),
                    result.insertedRecords(),
                    result.skippedRecords());
        } else {
            LOGGER.warn("Exercise dataset file not found at: {}. Skipping auto-import.", datasetPath);
        }
    }
}
