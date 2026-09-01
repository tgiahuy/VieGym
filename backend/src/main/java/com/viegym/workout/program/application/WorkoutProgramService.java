package com.viegym.workout.program.application;

import com.viegym.common.api.FieldViolation;
import com.viegym.common.api.PageResponse;
import com.viegym.common.error.ApiErrorCode;
import com.viegym.common.error.ApiException;
import com.viegym.common.error.ApiValidationException;
import com.viegym.workout.program.api.WorkoutDayRequest;
import com.viegym.workout.program.api.WorkoutDayResponse;
import com.viegym.workout.program.api.WorkoutExerciseRequest;
import com.viegym.workout.program.api.WorkoutExerciseResponse;
import com.viegym.workout.program.api.WorkoutProgramRequest;
import com.viegym.workout.program.api.WorkoutProgramResponse;
import com.viegym.workout.program.api.WorkoutProgramSummaryResponse;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class WorkoutProgramService {

    private final JdbcTemplate jdbc;

    public WorkoutProgramService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    @Transactional(readOnly = true)
    public PageResponse<WorkoutProgramSummaryResponse> listPrograms(
            Long userId, String status, Pageable pageable) {
        StringBuilder where = new StringBuilder("where user_id = ? and deleted_at is null ");
        List<Object> params = new ArrayList<>();
        params.add(userId);

        if (status != null && !status.isBlank()) {
            where.append("and status = ? ");
            params.add(status.trim().toUpperCase());
        }

        Long total =
                jdbc.queryForObject(
                        "select count(*) from workout_programs " + where,
                        Long.class,
                        params.toArray());
        long totalElements = total != null ? total : 0L;

        if (totalElements == 0) {
            return PageResponse.from(new PageImpl<>(Collections.emptyList(), pageable, 0));
        }

        String sql =
                "select p.id, p.name, p.program_type, p.description, p.status,"
                        + " (select count(*) from workout_days d where d.workout_program_id = p.id) as"
                        + " total_days from workout_programs p "
                        + where
                        + " order by case when p.status = 'ACTIVE' then 0 else 1 end, p.updated_at"
                        + " desc limit ? offset ?";

        List<Object> dataParams = new ArrayList<>(params);
        dataParams.add(pageable.getPageSize());
        dataParams.add(pageable.getOffset());

        List<WorkoutProgramSummaryResponse> list =
                jdbc.query(
                        sql,
                        (rs, row) ->
                                new WorkoutProgramSummaryResponse(
                                        rs.getLong("id"),
                                        rs.getString("name"),
                                        rs.getString("program_type"),
                                        rs.getString("description"),
                                        rs.getString("status"),
                                        rs.getInt("total_days")),
                        dataParams.toArray());

        return PageResponse.from(new PageImpl<>(list, pageable, totalElements));
    }

    @Transactional
    public WorkoutProgramResponse createProgram(Long userId, WorkoutProgramRequest request) {
        validateProgramRequest(request, true);

        String status =
                request.status() != null && !request.status().isBlank()
                        ? request.status().trim().toUpperCase()
                        : "ACTIVE";

        if ("ACTIVE".equals(status)) {
            jdbc.update(
                    "update workout_programs set status = 'INACTIVE', updated_at = now() where"
                            + " user_id = ? and status = 'ACTIVE' and deleted_at is null",
                    userId);
        }

        Long programId =
                jdbc.queryForObject(
                        "insert into workout_programs (user_id, name, program_type, description,"
                                + " status) values (?, ?, ?, ?, ?) returning id",
                        Long.class,
                        userId,
                        request.name().trim(),
                        request.programType().trim().toUpperCase(),
                        request.description(),
                        status);

        if (request.days() != null) {
            for (WorkoutDayRequest dayReq : request.days()) {
                Long dayId =
                        jdbc.queryForObject(
                                "insert into workout_days (workout_program_id, day_number, name,"
                                        + " note) values (?, ?, ?, ?) returning id",
                                Long.class,
                                programId,
                                dayReq.dayNumber(),
                                dayReq.name().trim(),
                                dayReq.note());

                if (dayReq.exercises() != null) {
                    for (WorkoutExerciseRequest exReq : dayReq.exercises()) {
                        jdbc.update(
                                "insert into workout_exercises (workout_day_id, exercise_id,"
                                        + " sort_order, target_sets, target_reps_min, target_reps_max,"
                                        + " target_duration_seconds, rest_seconds, note) values (?, ?,"
                                        + " ?, ?, ?, ?, ?, ?, ?)",
                                dayId,
                                exReq.exerciseId(),
                                exReq.sortOrder(),
                                exReq.targetSets(),
                                exReq.targetRepsMin(),
                                exReq.targetRepsMax(),
                                exReq.targetDurationSeconds(),
                                Math.max(0, exReq.restSeconds()),
                                exReq.note());
                    }
                }
            }
        }

        return getProgram(userId, programId);
    }

    @Transactional(readOnly = true)
    public WorkoutProgramResponse getProgram(Long userId, Long programId) {
        List<WorkoutProgramResponse> list =
                jdbc.query(
                        "select id, name, program_type, description, status from workout_programs"
                                + " where id = ? and user_id = ? and deleted_at is null",
                        (rs, row) ->
                                new WorkoutProgramResponse(
                                        rs.getLong("id"),
                                        rs.getString("name"),
                                        rs.getString("program_type"),
                                        rs.getString("description"),
                                        rs.getString("status"),
                                        Collections.emptyList()),
                        programId,
                        userId);

        if (list.isEmpty()) {
            throw new ApiException(ApiErrorCode.RESOURCE_NOT_FOUND, "Workout program not found");
        }

        WorkoutProgramResponse base = list.get(0);
        List<WorkoutDayResponse> days = loadProgramDays(programId);
        return new WorkoutProgramResponse(
                base.id(),
                base.name(),
                base.programType(),
                base.description(),
                base.status(),
                days);
    }

    @Transactional
    public WorkoutProgramResponse updateProgram(
            Long userId, Long programId, WorkoutProgramRequest request) {
        validateProgramRequest(request, false);

        Integer exists =
                jdbc.queryForObject(
                        "select count(*) from workout_programs where id = ? and user_id = ? and"
                                + " deleted_at is null",
                        Integer.class,
                        programId,
                        userId);
        if (exists == null || exists == 0) {
            throw new ApiException(ApiErrorCode.RESOURCE_NOT_FOUND, "Workout program not found");
        }

        String status =
                request.status() != null && !request.status().isBlank()
                        ? request.status().trim().toUpperCase()
                        : "ACTIVE";

        if ("ACTIVE".equals(status)) {
            jdbc.update(
                    "update workout_programs set status = 'INACTIVE', updated_at = now() where"
                            + " user_id = ? and id <> ? and status = 'ACTIVE' and deleted_at is null",
                    userId,
                    programId);
        }

        jdbc.update(
                "update workout_programs set name = ?, program_type = ?, description = ?, status ="
                        + " ?, updated_at = now() where id = ? and user_id = ?",
                request.name().trim(),
                request.programType().trim().toUpperCase(),
                request.description(),
                status,
                programId,
                userId);

        // Check days diff
        List<Long> currentDayIds =
                jdbc.queryForList(
                        "select id from workout_days where workout_program_id = ?",
                        Long.class,
                        programId);

        Set<Long> requestDayIds = new HashSet<>();
        if (request.days() != null) {
            for (WorkoutDayRequest d : request.days()) {
                if (d.id() != null) {
                    requestDayIds.add(d.id());
                }
            }
        }

        for (Long currentDayId : currentDayIds) {
            if (!requestDayIds.contains(currentDayId)) {
                // Check if referenced by planned schedule
                Integer plannedSchedules =
                        jdbc.queryForObject(
                                "select count(*) from workout_schedules where workout_day_id = ?"
                                        + " and status = 'PLANNED'",
                                Integer.class,
                                currentDayId);
                if (plannedSchedules != null && plannedSchedules > 0) {
                    throw new ApiException(
                            ApiErrorCode.DAY_HAS_PLANNED_SCHEDULES,
                            "Cannot delete workout day referenced by planned schedule");
                }
                jdbc.update("delete from workout_days where id = ?", currentDayId);
            }
        }

        if (request.days() != null) {
            for (WorkoutDayRequest dayReq : request.days()) {
                Long dayId = dayReq.id();
                if (dayId != null && currentDayIds.contains(dayId)) {
                    jdbc.update(
                            "update workout_days set day_number = ?, name = ?, note = ?,"
                                    + " updated_at = now() where id = ?",
                            dayReq.dayNumber(),
                            dayReq.name().trim(),
                            dayReq.note(),
                            dayId);
                    jdbc.update("delete from workout_exercises where workout_day_id = ?", dayId);
                } else {
                    dayId =
                            jdbc.queryForObject(
                                    "insert into workout_days (workout_program_id, day_number,"
                                            + " name, note) values (?, ?, ?, ?) returning id",
                                    Long.class,
                                    programId,
                                    dayReq.dayNumber(),
                                    dayReq.name().trim(),
                                    dayReq.note());
                }

                if (dayReq.exercises() != null) {
                    for (WorkoutExerciseRequest exReq : dayReq.exercises()) {
                        validateExerciseSelectable(exReq.exerciseId());
                        jdbc.update(
                                "insert into workout_exercises (workout_day_id, exercise_id,"
                                        + " sort_order, target_sets, target_reps_min, target_reps_max,"
                                        + " target_duration_seconds, rest_seconds, note) values (?, ?,"
                                        + " ?, ?, ?, ?, ?, ?, ?)",
                                dayId,
                                exReq.exerciseId(),
                                exReq.sortOrder(),
                                exReq.targetSets(),
                                exReq.targetRepsMin(),
                                exReq.targetRepsMax(),
                                exReq.targetDurationSeconds(),
                                Math.max(0, exReq.restSeconds()),
                                exReq.note());
                    }
                }
            }
        }

        return getProgram(userId, programId);
    }

    @Transactional
    public void archiveProgram(Long userId, Long programId) {
        Integer updated =
                jdbc.update(
                        "update workout_programs set status = 'ARCHIVED', deleted_at = now(),"
                                + " updated_at = now() where id = ? and user_id = ? and deleted_at"
                                + " is null",
                        programId,
                        userId);
        if (updated == 0) {
            throw new ApiException(ApiErrorCode.RESOURCE_NOT_FOUND, "Workout program not found");
        }
    }

    private List<WorkoutDayResponse> loadProgramDays(Long programId) {
        List<WorkoutDayRow> dayRows =
                jdbc.query(
                        "select id, day_number, name, note from workout_days where"
                                + " workout_program_id = ? order by day_number asc",
                        (rs, row) ->
                                new WorkoutDayRow(
                                        rs.getLong("id"),
                                        rs.getInt("day_number"),
                                        rs.getString("name"),
                                        rs.getString("note")),
                        programId);

        if (dayRows.isEmpty()) {
            return Collections.emptyList();
        }

        List<Long> dayIds = dayRows.stream().map(WorkoutDayRow::id).toList();
        String placeholders = String.join(",", Collections.nCopies(dayIds.size(), "?"));

        String exSql =
                "select we.id, we.workout_day_id, we.exercise_id, e.name as exercise_name, e.slug"
                        + " as exercise_slug, (case when e.visibility = 'HIDDEN' or e.deleted_at is not"
                        + " null then true else false end) as is_hidden, we.sort_order, we.target_sets,"
                        + " we.target_reps_min, we.target_reps_max, we.target_duration_seconds,"
                        + " we.rest_seconds, we.note from workout_exercises we join exercises e on"
                        + " we.exercise_id = e.id where we.workout_day_id in ("
                        + placeholders
                        + ") order by we.sort_order asc";

        Map<Long, List<WorkoutExerciseResponse>> exMap = new HashMap<>();
        jdbc.query(
                exSql,
                rs -> {
                    long dayId = rs.getLong("workout_day_id");
                    exMap.computeIfAbsent(dayId, k -> new ArrayList<>())
                            .add(
                                    new WorkoutExerciseResponse(
                                            rs.getLong("id"),
                                            rs.getLong("exercise_id"),
                                            rs.getString("exercise_name"),
                                            rs.getString("exercise_slug"),
                                            rs.getBoolean("is_hidden"),
                                            rs.getInt("sort_order"),
                                            rs.getInt("target_sets"),
                                            rs.getObject("target_reps_min", Integer.class),
                                            rs.getObject("target_reps_max", Integer.class),
                                            rs.getObject("target_duration_seconds", Integer.class),
                                            rs.getInt("rest_seconds"),
                                            rs.getString("note")));
                },
                dayIds.toArray());

        return dayRows.stream()
                .map(
                        d ->
                                new WorkoutDayResponse(
                                        d.id(),
                                        d.dayNumber(),
                                        d.name(),
                                        d.note(),
                                        exMap.getOrDefault(d.id(), Collections.emptyList())))
                .toList();
    }

    private void validateProgramRequest(WorkoutProgramRequest request, boolean isCreate) {
        List<FieldViolation> violations = new ArrayList<>();
        if (request == null) {
            throw new ApiValidationException(
                    List.of(
                            new FieldViolation(
                                    "program", "REQUIRED", "Program request is required")));
        }
        if (request.name() == null || request.name().isBlank()) {
            violations.add(new FieldViolation("name", "REQUIRED", "Program name is required"));
        }
        if (request.programType() == null || request.programType().isBlank()) {
            violations.add(
                    new FieldViolation("programType", "REQUIRED", "Program type is required"));
        }

        if (request.days() != null) {
            for (int i = 0; i < request.days().size(); i++) {
                WorkoutDayRequest day = request.days().get(i);
                if (day.dayNumber() <= 0) {
                    violations.add(
                            new FieldViolation(
                                    "days[" + i + "].dayNumber",
                                    "INVALID_VALUE",
                                    "Day number must be positive"));
                }
                if (day.name() == null || day.name().isBlank()) {
                    violations.add(
                            new FieldViolation(
                                    "days[" + i + "].name", "REQUIRED", "Day name is required"));
                }
                if (day.exercises() != null) {
                    for (int j = 0; j < day.exercises().size(); j++) {
                        WorkoutExerciseRequest ex = day.exercises().get(j);
                        if (ex.targetSets() <= 0) {
                            violations.add(
                                    new FieldViolation(
                                            "days[" + i + "].exercises[" + j + "].targetSets",
                                            "INVALID_VALUE",
                                            "Target sets must be positive"));
                        }
                        if (ex.targetRepsMin() != null
                                && ex.targetRepsMax() != null
                                && ex.targetRepsMin() > ex.targetRepsMax()) {
                            violations.add(
                                    new FieldViolation(
                                            "days[" + i + "].exercises[" + j + "].targetRepsMin",
                                            "INVALID_RANGE",
                                            "targetRepsMin must be <= targetRepsMax"));
                        }
                        if (isCreate) {
                            validateExerciseSelectable(ex.exerciseId());
                        }
                    }
                }
            }
        }

        if (!violations.isEmpty()) {
            throw new ApiValidationException(violations);
        }
    }

    private void validateExerciseSelectable(Long exerciseId) {
        if (exerciseId == null) {
            throw new ApiValidationException(
                    List.of(
                            new FieldViolation(
                                    "exerciseId", "REQUIRED", "Exercise ID is required")));
        }
        Integer exists =
                jdbc.queryForObject(
                        "select count(*) from exercises where id = ? and visibility = 'PUBLIC' and"
                                + " deleted_at is null",
                        Integer.class,
                        exerciseId);
        if (exists == null || exists == 0) {
            throw new ApiException(
                    ApiErrorCode.EXERCISE_NOT_FOUND,
                    "Exercise ID " + exerciseId + " is not found or not selectable");
        }
    }

    private record WorkoutDayRow(Long id, int dayNumber, String name, String note) {}
}
