package com.viegym.workout.template.application;

import com.viegym.common.api.FieldViolation;
import com.viegym.common.error.ApiErrorCode;
import com.viegym.common.error.ApiException;
import com.viegym.common.error.ApiValidationException;
import com.viegym.workout.planning.api.ScheduleExercisePlan;
import com.viegym.workout.template.api.WorkoutTemplateDayRequest;
import com.viegym.workout.template.api.WorkoutTemplateDayResponse;
import com.viegym.workout.template.api.WorkoutTemplateRequest;
import com.viegym.workout.template.api.WorkoutTemplateResponse;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowCallbackHandler;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class WorkoutTemplateService {

    private static final Set<String> PROGRAM_TYPES =
            Set.of("PPL", "UPPER_LOWER", "FULL_BODY", "CUSTOM");
    private static final Set<String> STATUSES = Set.of("DRAFT", "PUBLISHED", "ARCHIVED");

    private final JdbcTemplate jdbc;

    public WorkoutTemplateService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    @Transactional(readOnly = true)
    public List<WorkoutTemplateResponse> listPublished() {
        return jdbc
                .queryForList(
                        "select id from workout_program_templates where status = 'PUBLISHED' order by updated_at desc",
                        Long.class)
                .stream()
                .map(id -> get(id, false))
                .toList();
    }

    @Transactional(readOnly = true)
    public List<WorkoutTemplateResponse> listForAdmin() {
        return jdbc
                .queryForList(
                        "select id from workout_program_templates order by updated_at desc",
                        Long.class)
                .stream()
                .map(id -> get(id, true))
                .toList();
    }

    @Transactional(readOnly = true)
    public WorkoutTemplateResponse getPublished(Long id) {
        return get(id, false);
    }

    @Transactional
    public WorkoutTemplateResponse create(Long adminId, WorkoutTemplateRequest request) {
        validate(request);
        String status = normalizeStatus(request.status());
        Long id =
                jdbc.queryForObject(
                        "insert into workout_program_templates (created_by_admin_id, name, program_type, description, difficulty, goal, status) values (?, ?, ?, ?, ?, ?, ?) returning id",
                        Long.class,
                        adminId,
                        request.name().trim(),
                        request.programType().trim().toUpperCase(),
                        request.description(),
                        normalizeNullable(request.difficulty()),
                        normalizeNullable(request.goal()),
                        status);
        replaceDays(id, request.days());
        return get(id, true);
    }

    @Transactional
    public WorkoutTemplateResponse update(Long id, WorkoutTemplateRequest request) {
        validate(request);
        Integer updated =
                jdbc.update(
                        "update workout_program_templates set name = ?, program_type = ?, description = ?, difficulty = ?, goal = ?, status = ?, version = version + 1, updated_at = now() where id = ?",
                        request.name().trim(),
                        request.programType().trim().toUpperCase(),
                        request.description(),
                        normalizeNullable(request.difficulty()),
                        normalizeNullable(request.goal()),
                        normalizeStatus(request.status()),
                        id);
        if (updated == 0) {
            throw new ApiException(ApiErrorCode.RESOURCE_NOT_FOUND, "Workout template not found");
        }
        jdbc.update("delete from workout_template_days where template_id = ?", id);
        replaceDays(id, request.days());
        return get(id, true);
    }

    @Transactional
    public void archive(Long id) {
        Integer updated =
                jdbc.update(
                        "update workout_program_templates set status = 'ARCHIVED', version = version + 1, updated_at = now() where id = ?",
                        id);
        if (updated == 0) {
            throw new ApiException(ApiErrorCode.RESOURCE_NOT_FOUND, "Workout template not found");
        }
    }

    private WorkoutTemplateResponse get(Long id, boolean includeNonPublished) {
        String sql =
                "select id, name, program_type, description, difficulty, goal, status, version from workout_program_templates where id = ?"
                        + (includeNonPublished ? "" : " and status = 'PUBLISHED'");
        List<WorkoutTemplateResponse> rows =
                jdbc.query(
                        sql,
                        (rs, row) ->
                                new WorkoutTemplateResponse(
                                        rs.getLong("id"),
                                        rs.getString("name"),
                                        rs.getString("program_type"),
                                        rs.getString("description"),
                                        rs.getString("difficulty"),
                                        rs.getString("goal"),
                                        rs.getString("status"),
                                        rs.getInt("version"),
                                        List.of()),
                        id);
        if (rows.isEmpty()) {
            throw new ApiException(ApiErrorCode.RESOURCE_NOT_FOUND, "Workout template not found");
        }
        WorkoutTemplateResponse base = rows.get(0);
        return new WorkoutTemplateResponse(
                base.id(),
                base.name(),
                base.programType(),
                base.description(),
                base.difficulty(),
                base.goal(),
                base.status(),
                base.version(),
                loadDays(id));
    }

    private List<WorkoutTemplateDayResponse> loadDays(Long templateId) {
        List<DayRow> days =
                jdbc.query(
                        "select id, day_number, name, note from workout_template_days where template_id = ? order by day_number",
                        (rs, row) ->
                                new DayRow(
                                        rs.getLong("id"),
                                        rs.getInt("day_number"),
                                        rs.getString("name"),
                                        rs.getString("note")),
                        templateId);
        if (days.isEmpty()) {
            return List.of();
        }
        List<Long> ids = days.stream().map(DayRow::id).toList();
        String placeholders = String.join(",", Collections.nCopies(ids.size(), "?"));
        Map<Long, List<ScheduleExercisePlan>> exercises = new HashMap<>();
        jdbc.query(
                "select wte.template_day_id, wte.exercise_id, e.name as exercise_name, (select mg.name from exercise_muscle_groups emg join muscle_groups mg on mg.id = emg.muscle_group_id where emg.exercise_id = e.id and emg.role = 'PRIMARY' order by mg.name limit 1) as primary_muscle, wte.sort_order, wte.target_sets, wte.target_reps_min, wte.target_reps_max, wte.target_duration_seconds, wte.rest_seconds, wte.note from workout_template_exercises wte join exercises e on e.id = wte.exercise_id where wte.template_day_id in ("
                        + placeholders
                        + ") order by wte.sort_order",
                (RowCallbackHandler)
                        rs ->
                                exercises
                                        .computeIfAbsent(
                                                rs.getLong("template_day_id"),
                                                ignored -> new ArrayList<>())
                                        .add(
                                                new ScheduleExercisePlan(
                                                        rs.getLong("exercise_id"),
                                                        rs.getString("exercise_name"),
                                                        rs.getString("primary_muscle"),
                                                        rs.getInt("sort_order"),
                                                        rs.getInt("target_sets"),
                                                        rs.getObject(
                                                                "target_reps_min", Integer.class),
                                                        rs.getObject(
                                                                "target_reps_max", Integer.class),
                                                        rs.getObject(
                                                                "target_duration_seconds",
                                                                Integer.class),
                                                        rs.getInt("rest_seconds"),
                                                        rs.getString("note"))),
                ids.toArray());
        return days.stream()
                .map(
                        day ->
                                new WorkoutTemplateDayResponse(
                                        day.id(),
                                        day.dayNumber(),
                                        day.name(),
                                        day.note(),
                                        exercises.getOrDefault(day.id(), List.of())))
                .toList();
    }

    private void replaceDays(Long templateId, List<WorkoutTemplateDayRequest> days) {
        if (days == null) {
            return;
        }
        for (WorkoutTemplateDayRequest day : days) {
            Long dayId =
                    jdbc.queryForObject(
                            "insert into workout_template_days (template_id, day_number, name, note) values (?, ?, ?, ?) returning id",
                            Long.class,
                            templateId,
                            day.dayNumber(),
                            day.name().trim(),
                            day.note());
            if (day.exercises() != null) {
                for (ScheduleExercisePlan exercise : day.exercises()) {
                    insertExercise(dayId, exercise);
                }
            }
        }
    }

    private void insertExercise(Long dayId, ScheduleExercisePlan exercise) {
        validateExerciseSelectable(exercise.exerciseId());
        jdbc.update(
                "insert into workout_template_exercises (template_day_id, exercise_id, sort_order, target_sets, target_reps_min, target_reps_max, target_duration_seconds, rest_seconds, note) values (?, ?, ?, ?, ?, ?, ?, ?, ?)",
                dayId,
                exercise.exerciseId(),
                exercise.sortOrder(),
                exercise.targetSets(),
                exercise.targetRepsMin(),
                exercise.targetRepsMax(),
                exercise.targetDurationSeconds(),
                exercise.restSeconds() == null ? 60 : Math.max(0, exercise.restSeconds()),
                exercise.note());
    }

    private void validate(WorkoutTemplateRequest request) {
        List<FieldViolation> violations = new ArrayList<>();
        if (request == null) {
            throw new ApiValidationException(
                    List.of(new FieldViolation("template", "REQUIRED", "Template is required")));
        }
        if (request.name() == null || request.name().isBlank()) {
            violations.add(new FieldViolation("name", "REQUIRED", "Name is required"));
        }
        String programType = normalizeNullable(request.programType());
        if (programType == null || !PROGRAM_TYPES.contains(programType)) {
            violations.add(
                    new FieldViolation(
                            "programType", "INVALID", "Unsupported workout program type"));
        }
        String status = normalizeStatus(request.status());
        if (!STATUSES.contains(status)) {
            violations.add(new FieldViolation("status", "INVALID", "Unsupported template status"));
        }
        if (request.days() == null || request.days().isEmpty()) {
            violations.add(new FieldViolation("days", "REQUIRED", "At least one day is required"));
        } else {
            Set<Integer> dayNumbers = new HashSet<>();
            for (int index = 0; index < request.days().size(); index++) {
                WorkoutTemplateDayRequest day = request.days().get(index);
                if (day == null || day.dayNumber() == null || day.dayNumber() < 1) {
                    violations.add(
                            new FieldViolation(
                                    "days[" + index + "].dayNumber",
                                    "INVALID",
                                    "Day number must be positive"));
                } else if (!dayNumbers.add(day.dayNumber())) {
                    violations.add(
                            new FieldViolation(
                                    "days[" + index + "].dayNumber",
                                    "DUPLICATE",
                                    "Day number must be unique"));
                }
                if (day == null || day.name() == null || day.name().isBlank()) {
                    violations.add(
                            new FieldViolation(
                                    "days[" + index + "].name",
                                    "REQUIRED",
                                    "Day name is required"));
                }
                if (day != null && day.exercises() != null) {
                    validateExercises(day.exercises(), index, violations);
                }
            }
        }
        if (!violations.isEmpty()) {
            throw new ApiValidationException(violations);
        }
    }

    private void validateExercises(
            List<ScheduleExercisePlan> exercises, int dayIndex, List<FieldViolation> violations) {
        Set<Integer> sortOrders = new HashSet<>();
        for (int index = 0; index < exercises.size(); index++) {
            ScheduleExercisePlan exercise = exercises.get(index);
            String field = "days[" + dayIndex + "].exercises[" + index + "]";
            if (exercise == null) {
                violations.add(new FieldViolation(field, "REQUIRED", "Exercise is required"));
                continue;
            }
            if (exercise.exerciseId() == null) {
                violations.add(
                        new FieldViolation(
                                field + ".exerciseId", "REQUIRED", "Exercise id is required"));
            }
            if (exercise.sortOrder() == null || exercise.sortOrder() < 1) {
                violations.add(
                        new FieldViolation(
                                field + ".sortOrder", "INVALID", "Sort order must be positive"));
            } else if (!sortOrders.add(exercise.sortOrder())) {
                violations.add(
                        new FieldViolation(
                                field + ".sortOrder",
                                "DUPLICATE",
                                "Sort order must be unique within a day"));
            }
            if (exercise.targetSets() == null || exercise.targetSets() < 1) {
                violations.add(
                        new FieldViolation(
                                field + ".targetSets", "INVALID", "Target sets must be positive"));
            }
            if (exercise.targetRepsMin() != null && exercise.targetRepsMin() < 1) {
                violations.add(
                        new FieldViolation(
                                field + ".targetRepsMin",
                                "INVALID",
                                "Minimum reps must be positive"));
            }
            if (exercise.targetRepsMax() != null && exercise.targetRepsMax() < 1) {
                violations.add(
                        new FieldViolation(
                                field + ".targetRepsMax",
                                "INVALID",
                                "Maximum reps must be positive"));
            }
            if (exercise.targetRepsMin() != null
                    && exercise.targetRepsMax() != null
                    && exercise.targetRepsMin() > exercise.targetRepsMax()) {
                violations.add(
                        new FieldViolation(
                                field, "INVALID_REPS", "Minimum reps cannot exceed maximum reps"));
            }
            if (exercise.targetDurationSeconds() != null && exercise.targetDurationSeconds() < 1) {
                violations.add(
                        new FieldViolation(
                                field + ".targetDurationSeconds",
                                "INVALID",
                                "Target duration must be positive"));
            }
            if (exercise.restSeconds() != null && exercise.restSeconds() < 0) {
                violations.add(
                        new FieldViolation(
                                field + ".restSeconds",
                                "INVALID",
                                "Rest seconds cannot be negative"));
            }
        }
    }

    private void validateExerciseSelectable(Long exerciseId) {
        Integer count =
                jdbc.queryForObject(
                        "select count(*) from exercises where id = ? and visibility = 'PUBLIC' and deleted_at is null",
                        Integer.class,
                        exerciseId);
        if (count == null || count == 0) {
            throw new ApiException(
                    ApiErrorCode.RESOURCE_HIDDEN, "Exercise is not selectable: " + exerciseId);
        }
    }

    private static String normalizeStatus(String status) {
        return status == null || status.isBlank() ? "DRAFT" : status.trim().toUpperCase();
    }

    private static String normalizeNullable(String value) {
        return value == null || value.isBlank() ? null : value.trim().toUpperCase();
    }

    private record DayRow(Long id, Integer dayNumber, String name, String note) {}
}
