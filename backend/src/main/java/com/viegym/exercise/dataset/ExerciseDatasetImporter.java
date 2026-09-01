package com.viegym.exercise.dataset;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.regex.Pattern;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;

@Service
public class ExerciseDatasetImporter {

    private static final Pattern CHECKSUM_PATTERN = Pattern.compile("[a-f0-9]{64}");
    private static final Set<String> DIFFICULTIES = Set.of("BEGINNER", "INTERMEDIATE", "ADVANCED");
    private static final Set<String> VISIBILITIES = Set.of("PUBLIC", "HIDDEN");
    private static final Set<String> MUSCLE_ROLES = Set.of("PRIMARY", "SECONDARY");

    private final JdbcTemplate jdbcTemplate;
    private final ObjectMapper objectMapper;
    private final TransactionTemplate transactionTemplate;

    public ExerciseDatasetImporter(
            JdbcTemplate jdbcTemplate,
            ObjectMapper objectMapper,
            PlatformTransactionManager transactionManager) {
        this.jdbcTemplate = jdbcTemplate;
        this.objectMapper = objectMapper;
        this.transactionTemplate = new TransactionTemplate(transactionManager);
    }

    public ExerciseDatasetImportResult importFile(Path path) throws IOException {
        byte[] content = Files.readAllBytes(path);
        ExerciseDatasetFile dataset = objectMapper.readValue(content, ExerciseDatasetFile.class);
        validateDataset(dataset);
        String sourceChecksum = sha256(content);
        Long batchId =
                jdbcTemplate.queryForObject(
                        "insert into dataset_import_batches "
                                + "(dataset_type, dataset_version, source_checksum, status, total_records) "
                                + "values ('EXERCISE', ?, ?, 'RUNNING', ?) returning id",
                        Long.class,
                        dataset.datasetVersion(),
                        sourceChecksum,
                        dataset.records().size());

        try {
            ImportCounts counts =
                    transactionTemplate.execute(
                            transactionStatus -> importRecords(batchId, dataset.records()));
            if (counts == null) {
                throw new IllegalStateException("Exercise import transaction returned no result");
            }
            return new ExerciseDatasetImportResult(
                    batchId,
                    dataset.datasetVersion(),
                    dataset.records().size(),
                    counts.inserted(),
                    counts.skipped());
        } catch (RuntimeException exception) {
            markBatchFailed(batchId, exception);
            throw exception;
        }
    }

    private ImportCounts importRecords(Long batchId, List<ExerciseDatasetFile.Record> records) {
        for (ExerciseDatasetFile.Record record : records) {
            validateRecord(record);
        }
        int inserted = 0;
        int skipped = 0;
        for (ExerciseDatasetFile.Record record : records) {
            if (registryEntryExists(record.source(), record.sourceExternalId())) {
                // Existing imported master data is deliberately not overwritten. This preserves
                // later admin curation until an explicit reviewed update workflow exists.
                skipped++;
                continue;
            }
            Long exerciseId = insertExercise(record);
            insertMuscleMappings(exerciseId, record.muscleGroups());
            insertEquipmentMappings(exerciseId, record.equipment());
            jdbcTemplate.update(
                    "insert into exercise_import_registry "
                            + "(source, source_external_id, exercise_id, source_version, "
                            + "record_checksum, last_import_batch_id) values (?, ?, ?, ?, ?, ?)",
                    record.source(),
                    record.sourceExternalId(),
                    exerciseId,
                    record.sourceVersion(),
                    record.recordChecksum(),
                    batchId);
            inserted++;
        }
        jdbcTemplate.update(
                "update dataset_import_batches set status = 'SUCCEEDED', inserted_records = ?, "
                        + "skipped_records = ?, completed_at = CURRENT_TIMESTAMP where id = ?",
                inserted,
                skipped,
                batchId);
        return new ImportCounts(inserted, skipped);
    }

    private void markBatchFailed(Long batchId, RuntimeException exception) {
        String message = exception.getMessage();
        String summary =
                message == null || message.isBlank()
                        ? exception.getClass().getSimpleName()
                        : message.substring(0, Math.min(message.length(), 1000));
        jdbcTemplate.update(
                "update dataset_import_batches set status = 'FAILED', error_summary = ?, "
                        + "completed_at = CURRENT_TIMESTAMP where id = ?",
                summary,
                batchId);
    }

    private void validateDataset(ExerciseDatasetFile dataset) {
        if (dataset.schemaVersion() != 1) {
            throw new IllegalArgumentException("Unsupported Exercise dataset schemaVersion");
        }
        if (isBlank(dataset.datasetVersion())
                || dataset.records() == null
                || dataset.records().isEmpty()) {
            throw new IllegalArgumentException("Exercise dataset version and records are required");
        }
        Set<String> importKeys = new HashSet<>();
        Set<String> slugs = new HashSet<>();
        for (ExerciseDatasetFile.Record record : dataset.records()) {
            if (!importKeys.add(record.importKey())) {
                throw new IllegalArgumentException("Duplicate importKey: " + record.importKey());
            }
            if (!slugs.add(record.slug())) {
                throw new IllegalArgumentException("Duplicate slug: " + record.slug());
            }
        }
    }

    private void validateRecord(ExerciseDatasetFile.Record record) {
        if (isBlank(record.importKey())
                || isBlank(record.source())
                || isBlank(record.sourceExternalId())
                || isBlank(record.sourceVersion())
                || isBlank(record.name())
                || isBlank(record.searchName())
                || isBlank(record.slug())
                || isBlank(record.description())) {
            throw new IllegalArgumentException(
                    "Missing required Exercise field: " + record.importKey());
        }
        if (!record.importKey().equals(record.source() + ":" + record.sourceExternalId())) {
            throw new IllegalArgumentException("Invalid importKey: " + record.importKey());
        }
        if (record.recordChecksum() == null
                || !CHECKSUM_PATTERN.matcher(record.recordChecksum()).matches()) {
            throw new IllegalArgumentException("Invalid record checksum: " + record.importKey());
        }
        if (!DIFFICULTIES.contains(record.difficulty())
                || !VISIBILITIES.contains(record.visibility())) {
            throw new IllegalArgumentException("Invalid Exercise enum: " + record.importKey());
        }
        if (record.media() != null && !record.media().isEmpty()) {
            throw new IllegalArgumentException(
                    "Exercise media import is disabled: " + record.importKey());
        }
        if (record.visibility().equals("PUBLIC") && !record.verified()) {
            throw new IllegalArgumentException(
                    "PUBLIC Exercise must be verified: " + record.importKey());
        }
        if (record.muscleGroups() == null
                || record.muscleGroups().stream()
                        .noneMatch(item -> "PRIMARY".equals(item.role()))) {
            throw new IllegalArgumentException(
                    "Exercise requires a PRIMARY muscle: " + record.importKey());
        }
        if (record.muscleGroups().stream().anyMatch(item -> !MUSCLE_ROLES.contains(item.role()))) {
            throw new IllegalArgumentException("Invalid muscle role: " + record.importKey());
        }
        if (record.equipment() == null || record.equipment().isEmpty()) {
            throw new IllegalArgumentException(
                    "Exercise requires equipment mapping: " + record.importKey());
        }
    }

    private boolean registryEntryExists(String source, String externalId) {
        Integer count =
                jdbcTemplate.queryForObject(
                        "select count(*) from exercise_import_registry "
                                + "where source = ? and source_external_id = ?",
                        Integer.class,
                        source,
                        externalId);
        return count != null && count > 0;
    }

    private Long insertExercise(ExerciseDatasetFile.Record record) {
        return jdbcTemplate.queryForObject(
                "insert into exercises (name, search_name, slug, difficulty, description, "
                        + "instruction_steps, common_mistakes, safety_notes, visibility) "
                        + "values (?, ?, ?, ?, ?, ?::jsonb, ?::jsonb, ?::jsonb, ?) returning id",
                Long.class,
                record.name(),
                record.searchName(),
                record.slug(),
                record.difficulty(),
                record.description(),
                toJson(record.instructionSteps()),
                toJson(record.commonMistakes()),
                toJson(record.safetyNotes()),
                record.visibility());
    }

    private void insertMuscleMappings(
            Long exerciseId, List<ExerciseDatasetFile.MuscleGroup> muscleGroups) {
        for (ExerciseDatasetFile.MuscleGroup muscle : muscleGroups) {
            Long muscleId =
                    jdbcTemplate.queryForObject(
                            "select id from muscle_groups where code = ? and is_active = true",
                            Long.class,
                            muscle.code());
            jdbcTemplate.update(
                    "insert into exercise_muscle_groups (exercise_id, muscle_group_id, role) "
                            + "values (?, ?, ?)",
                    exerciseId,
                    muscleId,
                    muscle.role());
        }
    }

    private void insertEquipmentMappings(
            Long exerciseId, List<ExerciseDatasetFile.Equipment> equipmentItems) {
        for (ExerciseDatasetFile.Equipment equipment : equipmentItems) {
            Long equipmentId =
                    jdbcTemplate.queryForObject(
                            "select id from equipment where code = ? and is_active = true",
                            Long.class,
                            equipment.code());
            jdbcTemplate.update(
                    "insert into exercise_equipment (exercise_id, equipment_id, is_required) "
                            + "values (?, ?, ?)",
                    exerciseId,
                    equipmentId,
                    equipment.required());
        }
    }

    private String toJson(List<String> values) {
        try {
            return objectMapper.writeValueAsString(values == null ? List.of() : values);
        } catch (JsonProcessingException exception) {
            throw new IllegalArgumentException("Cannot serialize Exercise JSON fields", exception);
        }
    }

    private static boolean isBlank(String value) {
        return value == null || value.isBlank();
    }

    private static String sha256(byte[] value) {
        try {
            return java.util.HexFormat.of()
                    .formatHex(MessageDigest.getInstance("SHA-256").digest(value));
        } catch (NoSuchAlgorithmException exception) {
            throw new IllegalStateException("SHA-256 is unavailable", exception);
        }
    }

    private record ImportCounts(int inserted, int skipped) {}
}
