package com.viegym.exercise.dataset;

public record ExerciseDatasetImportResult(
        long batchId,
        String datasetVersion,
        int totalRecords,
        int insertedRecords,
        int skippedRecords) {}
