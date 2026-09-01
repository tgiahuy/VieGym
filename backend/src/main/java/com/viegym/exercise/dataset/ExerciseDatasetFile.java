package com.viegym.exercise.dataset;

import java.util.List;

public record ExerciseDatasetFile(int schemaVersion, String datasetVersion, List<Record> records) {

    public record Record(
            String importKey,
            String source,
            String sourceExternalId,
            String sourceVersion,
            String recordChecksum,
            String name,
            String searchName,
            String slug,
            String difficulty,
            String description,
            List<String> instructionSteps,
            List<String> commonMistakes,
            List<String> safetyNotes,
            String visibility,
            boolean verified,
            List<MuscleGroup> muscleGroups,
            List<Equipment> equipment,
            List<Object> media) {}

    public record MuscleGroup(String code, String role) {}

    public record Equipment(String code, boolean required) {}
}
