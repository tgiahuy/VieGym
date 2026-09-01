package com.viegym.workout.log.application;

import com.viegym.common.api.PageResponse;
import com.viegym.common.error.ApiErrorCode;
import com.viegym.common.error.ApiException;
import com.viegym.workout.log.api.PersonalRecordDto;
import com.viegym.workout.log.api.WorkoutExerciseLogDto;
import com.viegym.workout.log.api.WorkoutLogDetailDto;
import com.viegym.workout.log.api.WorkoutLogSummaryDto;
import com.viegym.workout.log.api.WorkoutSetLogDto;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class WorkoutHistoryService {

    private final JdbcTemplate jdbc;

    public WorkoutHistoryService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    @Transactional(readOnly = true)
    public PageResponse<WorkoutLogSummaryDto> listWorkoutLogs(
            Long userId, LocalDate from, LocalDate to, Long exerciseId, Pageable pageable) {
        StringBuilder where = new StringBuilder("where wl.user_id = ? ");
        List<Object> params = new ArrayList<>();
        params.add(userId);

        if (from != null) {
            where.append("and wl.completed_at >= ? ");
            params.add(Timestamp.valueOf(from.atStartOfDay()));
        }
        if (to != null) {
            where.append("and wl.completed_at <= ? ");
            params.add(Timestamp.valueOf(to.plusDays(1).atStartOfDay()));
        }
        if (exerciseId != null) {
            where.append(
                    "and exists (select 1 from workout_exercise_logs wel where"
                            + " wel.workout_log_id = wl.id and wel.exercise_id = ?) ");
            params.add(exerciseId);
        }

        Long total =
                jdbc.queryForObject(
                        "select count(*) from workout_logs wl " + where,
                        Long.class,
                        params.toArray());
        long totalElements = total != null ? total : 0L;

        if (totalElements == 0) {
            return PageResponse.from(new PageImpl<>(Collections.emptyList(), pageable, 0));
        }

        String sql =
                "select wl.id, wl.workout_session_id, wl.workout_schedule_id, wl.title_snapshot,"
                        + " wl.started_at, wl.completed_at, wl.duration_seconds, wl.total_volume_kg,"
                        + " (select count(*) from workout_exercise_logs wel where wel.workout_log_id ="
                        + " wl.id) as total_exercises, (select count(*) from personal_records pr where"
                        + " pr.workout_log_id = wl.id) as pr_count from workout_logs wl "
                        + where
                        + " order by wl.completed_at desc limit ? offset ?";

        List<Object> dataParams = new ArrayList<>(params);
        dataParams.add(pageable.getPageSize());
        dataParams.add(pageable.getOffset());

        List<WorkoutLogSummaryDto> list =
                jdbc.query(
                        sql,
                        (rs, row) ->
                                new WorkoutLogSummaryDto(
                                        rs.getLong("id"),
                                        rs.getLong("workout_session_id"),
                                        rs.getLong("workout_schedule_id"),
                                        rs.getString("title_snapshot"),
                                        toOffsetDateTime(rs.getTimestamp("started_at")),
                                        toOffsetDateTime(rs.getTimestamp("completed_at")),
                                        rs.getInt("duration_seconds"),
                                        rs.getDouble("total_volume_kg"),
                                        rs.getInt("total_exercises"),
                                        rs.getInt("pr_count")),
                        dataParams.toArray());

        return PageResponse.from(new PageImpl<>(list, pageable, totalElements));
    }

    @Transactional(readOnly = true)
    public WorkoutLogDetailDto getWorkoutLogDetail(Long userId, Long workoutLogId) {
        String sql =
                "select id, workout_session_id, workout_schedule_id, title_snapshot, started_at,"
                        + " completed_at, duration_seconds, total_volume_kg, note from workout_logs"
                        + " where id = ? and user_id = ?";

        List<WorkoutLogBaseRow> list =
                jdbc.query(
                        sql,
                        (rs, row) ->
                                new WorkoutLogBaseRow(
                                        rs.getLong("id"),
                                        rs.getLong("workout_session_id"),
                                        rs.getLong("workout_schedule_id"),
                                        rs.getString("title_snapshot"),
                                        toOffsetDateTime(rs.getTimestamp("started_at")),
                                        toOffsetDateTime(rs.getTimestamp("completed_at")),
                                        rs.getInt("duration_seconds"),
                                        rs.getDouble("total_volume_kg"),
                                        rs.getString("note")),
                        workoutLogId,
                        userId);

        if (list.isEmpty()) {
            throw new ApiException(ApiErrorCode.RESOURCE_NOT_FOUND, "Workout log not found");
        }

        WorkoutLogBaseRow base = list.get(0);
        List<WorkoutExerciseLogDto> exercises = loadExerciseLogs(workoutLogId);
        List<PersonalRecordDto> prs = loadLogPrs(workoutLogId);

        return new WorkoutLogDetailDto(
                base.id(),
                base.sessionId(),
                base.scheduleId(),
                base.title(),
                base.startedAt(),
                base.completedAt(),
                base.durationSeconds(),
                base.totalVolumeKg(),
                base.note(),
                exercises,
                prs);
    }

    @Transactional(readOnly = true)
    public PageResponse<PersonalRecordDto> listPersonalRecords(
            Long userId, Long exerciseId, String type, Pageable pageable) {
        StringBuilder where = new StringBuilder("where pr.user_id = ? ");
        List<Object> params = new ArrayList<>();
        params.add(userId);

        if (exerciseId != null) {
            where.append("and pr.exercise_id = ? ");
            params.add(exerciseId);
        }
        if (type != null && !type.isBlank()) {
            where.append("and pr.record_type = ? ");
            params.add(type.trim().toUpperCase());
        }

        Long total =
                jdbc.queryForObject(
                        "select count(*) from personal_records pr " + where,
                        Long.class,
                        params.toArray());
        long totalElements = total != null ? total : 0L;

        if (totalElements == 0) {
            return PageResponse.from(new PageImpl<>(Collections.emptyList(), pageable, 0));
        }

        String sql =
                "select pr.id, pr.exercise_id, e.name as exercise_name, pr.record_type, pr.value,"
                        + " pr.achieved_at, pr.workout_log_id from personal_records pr join exercises e"
                        + " on pr.exercise_id = e.id "
                        + where
                        + " order by pr.achieved_at desc limit ? offset ?";

        List<Object> dataParams = new ArrayList<>(params);
        dataParams.add(pageable.getPageSize());
        dataParams.add(pageable.getOffset());

        List<PersonalRecordDto> list =
                jdbc.query(
                        sql,
                        (rs, row) ->
                                new PersonalRecordDto(
                                        rs.getLong("id"),
                                        rs.getLong("exercise_id"),
                                        rs.getString("exercise_name"),
                                        rs.getString("record_type"),
                                        rs.getDouble("value"),
                                        toOffsetDateTime(rs.getTimestamp("achieved_at")),
                                        rs.getLong("workout_log_id"),
                                        null),
                        dataParams.toArray());

        return PageResponse.from(new PageImpl<>(list, pageable, totalElements));
    }

    private List<WorkoutExerciseLogDto> loadExerciseLogs(Long workoutLogId) {
        String sql =
                "select id, exercise_id, exercise_name_snapshot, sort_order, duration_seconds,"
                        + " exercise_volume_kg, completed from workout_exercise_logs where"
                        + " workout_log_id = ? order by sort_order asc";

        List<ExerciseLogRow> rows =
                jdbc.query(
                        sql,
                        (rs, row) ->
                                new ExerciseLogRow(
                                        rs.getLong("id"),
                                        rs.getLong("exercise_id"),
                                        rs.getString("exercise_name_snapshot"),
                                        rs.getInt("sort_order"),
                                        rs.getObject("duration_seconds", Integer.class),
                                        rs.getDouble("exercise_volume_kg"),
                                        rs.getBoolean("completed")),
                        workoutLogId);

        if (rows.isEmpty()) {
            return Collections.emptyList();
        }

        List<Long> exLogIds = rows.stream().map(ExerciseLogRow::id).toList();
        String placeholders = String.join(",", Collections.nCopies(exLogIds.size(), "?"));

        String setSql =
                "select workout_exercise_log_id, set_number, reps, weight_kg, duration_seconds,"
                        + " rpe, completed from workout_set_logs where workout_exercise_log_id in ("
                        + placeholders
                        + ") order by set_number asc";

        Map<Long, List<WorkoutSetLogDto>> setMap = new HashMap<>();
        jdbc.query(
                setSql,
                rs -> {
                    long parentId = rs.getLong("workout_exercise_log_id");
                    setMap.computeIfAbsent(parentId, k -> new ArrayList<>())
                            .add(
                                    new WorkoutSetLogDto(
                                            rs.getInt("set_number"),
                                            rs.getObject("reps", Integer.class),
                                            rs.getBigDecimal("weight_kg") != null
                                                    ? rs.getBigDecimal("weight_kg").doubleValue()
                                                    : null,
                                            rs.getObject("duration_seconds", Integer.class),
                                            rs.getBigDecimal("rpe") != null
                                                    ? rs.getBigDecimal("rpe").doubleValue()
                                                    : null,
                                            rs.getBoolean("completed")));
                },
                exLogIds.toArray());

        return rows.stream()
                .map(
                        r ->
                                new WorkoutExerciseLogDto(
                                        r.id(),
                                        r.exerciseId(),
                                        r.exerciseName(),
                                        r.sortOrder(),
                                        r.durationSeconds(),
                                        r.exerciseVolumeKg(),
                                        r.completed(),
                                        setMap.getOrDefault(r.id(), Collections.emptyList())))
                .toList();
    }

    private List<PersonalRecordDto> loadLogPrs(Long workoutLogId) {
        String sql =
                "select pr.id, pr.exercise_id, e.name as exercise_name, pr.record_type, pr.value,"
                        + " pr.achieved_at, pr.workout_log_id from personal_records pr join exercises e"
                        + " on pr.exercise_id = e.id where pr.workout_log_id = ? order by pr.id asc";

        return jdbc.query(
                sql,
                (rs, row) ->
                        new PersonalRecordDto(
                                rs.getLong("id"),
                                rs.getLong("exercise_id"),
                                rs.getString("exercise_name"),
                                rs.getString("record_type"),
                                rs.getDouble("value"),
                                toOffsetDateTime(rs.getTimestamp("achieved_at")),
                                rs.getLong("workout_log_id"),
                                null),
                workoutLogId);
    }

    private OffsetDateTime toOffsetDateTime(Timestamp timestamp) {
        if (timestamp == null) {
            return null;
        }
        return timestamp.toInstant().atOffset(ZoneOffset.UTC);
    }

    private record WorkoutLogBaseRow(
            Long id,
            Long sessionId,
            Long scheduleId,
            String title,
            OffsetDateTime startedAt,
            OffsetDateTime completedAt,
            int durationSeconds,
            Double totalVolumeKg,
            String note) {}

    private record ExerciseLogRow(
            Long id,
            Long exerciseId,
            String exerciseName,
            int sortOrder,
            Integer durationSeconds,
            Double exerciseVolumeKg,
            boolean completed) {}
}
