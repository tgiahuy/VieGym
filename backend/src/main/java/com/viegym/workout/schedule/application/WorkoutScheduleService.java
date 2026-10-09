package com.viegym.workout.schedule.application;

import com.viegym.common.api.FieldViolation;
import com.viegym.common.api.PageResponse;
import com.viegym.common.error.ApiErrorCode;
import com.viegym.common.error.ApiException;
import com.viegym.common.error.ApiValidationException;
import com.viegym.workout.schedule.api.WorkoutScheduleExerciseResponse;
import com.viegym.workout.schedule.api.WorkoutScheduleRequest;
import com.viegym.workout.schedule.api.WorkoutScheduleResponse;
import java.sql.Date;
import java.sql.Time;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class WorkoutScheduleService {

    private final JdbcTemplate jdbc;

    public WorkoutScheduleService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    @Transactional(readOnly = true)
    public PageResponse<WorkoutScheduleResponse> listSchedules(
            Long userId, LocalDate from, LocalDate to, String status, Pageable pageable) {
        StringBuilder where = new StringBuilder("where s.user_id = ? ");
        List<Object> params = new ArrayList<>();
        params.add(userId);

        if (from != null) {
            where.append("and s.scheduled_date >= ? ");
            params.add(Date.valueOf(from));
        }
        if (to != null) {
            where.append("and s.scheduled_date <= ? ");
            params.add(Date.valueOf(to));
        }
        if (status != null && !status.isBlank()) {
            where.append("and s.status = ? ");
            params.add(status.trim().toUpperCase());
        }

        Long total =
                jdbc.queryForObject(
                        "select count(*) from workout_schedules s " + where,
                        Long.class,
                        params.toArray());
        long totalElements = total != null ? total : 0L;

        if (totalElements == 0) {
            return PageResponse.from(new PageImpl<>(Collections.emptyList(), pageable, 0));
        }

        String sql =
                "select s.id, s.workout_program_id, s.workout_day_id, s.scheduled_date,"
                        + " s.scheduled_time, s.title, s.status, s.cancel_reason, s.completed_at,"
                        + " (select ws.id from workout_sessions ws where ws.workout_schedule_id = s.id"
                        + " and ws.status in ('IN_PROGRESS', 'PAUSED') limit 1) as active_session_id"
                        + " from workout_schedules s "
                        + where
                        + " order by s.scheduled_date asc, s.scheduled_time asc nulls last limit ?"
                        + " offset ?";

        List<Object> dataParams = new ArrayList<>(params);
        dataParams.add(pageable.getPageSize());
        dataParams.add(pageable.getOffset());

        List<WorkoutScheduleResponse> list =
                jdbc.query(sql, (rs, row) -> mapScheduleResponse(rs), dataParams.toArray());

        return PageResponse.from(new PageImpl<>(list, pageable, totalElements));
    }

    @Transactional
    public WorkoutScheduleResponse createSchedule(Long userId, WorkoutScheduleRequest request) {
        validateScheduleRequest(request);
        validateProgramReferences(userId, request.workoutProgramId(), request.workoutDayId());

        String title = request.title();
        if ((title == null || title.isBlank()) && request.workoutDayId() != null) {
            title =
                    jdbc
                            .query(
                                    "select name from workout_days where id = ?",
                                    (rs, row) -> rs.getString("name"),
                                    request.workoutDayId())
                            .stream()
                            .findFirst()
                            .orElse("Workout Session");
        } else if (title == null || title.isBlank()) {
            title = "Workout Session";
        }

        Long scheduleId =
                jdbc.queryForObject(
                        "insert into workout_schedules (user_id, workout_program_id,"
                                + " workout_day_id, scheduled_date, scheduled_time, title, status, source_type, source_id)"
                                + " values (?, ?, ?, ?, ?, ?, 'PLANNED', ?, ?) returning id",
                        Long.class,
                        userId,
                        request.workoutProgramId(),
                        request.workoutDayId(),
                        Date.valueOf(request.scheduledDate()),
                        request.scheduledTime() != null
                                ? Time.valueOf(request.scheduledTime())
                                : null,
                        title,
                        request.workoutProgramId() == null ? "MANUAL" : "USER_PROGRAM",
                        request.workoutProgramId());

        snapshotWorkoutDay(scheduleId, request.workoutDayId());

        return getSchedule(userId, scheduleId);
    }

    @Transactional(readOnly = true)
    public WorkoutScheduleResponse getSchedule(Long userId, Long scheduleId) {
        String sql =
                "select s.id, s.workout_program_id, s.workout_day_id, s.scheduled_date,"
                        + " s.scheduled_time, s.title, s.status, s.cancel_reason, s.completed_at,"
                        + " (select ws.id from workout_sessions ws where ws.workout_schedule_id = s.id"
                        + " and ws.status in ('IN_PROGRESS', 'PAUSED') limit 1) as active_session_id"
                        + " from workout_schedules s where s.id = ? and s.user_id = ?";

        List<WorkoutScheduleResponse> list =
                jdbc.query(sql, (rs, row) -> mapScheduleResponse(rs), scheduleId, userId);

        if (list.isEmpty()) {
            throw new ApiException(ApiErrorCode.RESOURCE_NOT_FOUND, "Workout schedule not found");
        }
        return list.get(0);
    }

    private WorkoutScheduleResponse mapScheduleResponse(java.sql.ResultSet rs)
            throws java.sql.SQLException {
        Long scheduleId = rs.getLong("id");
        return new WorkoutScheduleResponse(
                scheduleId,
                rs.getObject("workout_program_id", Long.class),
                rs.getObject("workout_day_id", Long.class),
                rs.getDate("scheduled_date").toLocalDate(),
                rs.getTime("scheduled_time") != null
                        ? rs.getTime("scheduled_time").toLocalTime()
                        : null,
                rs.getString("title"),
                rs.getString("status"),
                rs.getString("cancel_reason"),
                toOffsetDateTime(rs.getTimestamp("completed_at")),
                rs.getObject("active_session_id", Long.class),
                loadScheduleExercises(scheduleId));
    }

    private List<WorkoutScheduleExerciseResponse> loadScheduleExercises(Long scheduleId) {
        return jdbc.query(
                "select wse.exercise_id, wse.exercise_name_snapshot,"
                        + " (select mg.name from exercise_muscle_groups emg join muscle_groups mg"
                        + " on mg.id = emg.muscle_group_id where emg.exercise_id = wse.exercise_id"
                        + " and emg.role = 'PRIMARY' order by mg.name limit 1) as primary_muscle,"
                        + " wse.target_sets, wse.target_reps_min, wse.target_reps_max,"
                        + " wse.target_duration_seconds, wse.rest_seconds, wse.note"
                        + " from workout_schedule_exercises wse where wse.workout_schedule_id = ?"
                        + " order by wse.sort_order",
                (rs, row) ->
                        new WorkoutScheduleExerciseResponse(
                                rs.getLong("exercise_id"),
                                rs.getString("exercise_name_snapshot"),
                                rs.getString("primary_muscle"),
                                rs.getObject("target_sets", Integer.class),
                                rs.getObject("target_reps_min", Integer.class),
                                rs.getObject("target_reps_max", Integer.class),
                                rs.getObject("target_duration_seconds", Integer.class),
                                rs.getObject("rest_seconds", Integer.class),
                                rs.getString("note")),
                scheduleId);
    }

    @Transactional
    public WorkoutScheduleResponse updateSchedule(
            Long userId, Long scheduleId, WorkoutScheduleRequest request) {
        validateScheduleRequest(request);
        validateProgramReferences(userId, request.workoutProgramId(), request.workoutDayId());

        WorkoutScheduleResponse current = getSchedule(userId, scheduleId);
        if (!"PLANNED".equals(current.status())) {
            throw new ApiException(
                    ApiErrorCode.SCHEDULE_NO_LONGER_PLANNED,
                    "Only planned workout schedules can be updated");
        }

        String title =
                request.title() != null && !request.title().isBlank()
                        ? request.title().trim()
                        : current.title();

        jdbc.update(
                "update workout_schedules set workout_program_id = ?, workout_day_id = ?,"
                        + " scheduled_date = ?, scheduled_time = ?, title = ?, source_type = ?,"
                        + " source_id = ?, source_version = null, proposal_id = null, updated_at = now()"
                        + " where id = ? and user_id = ?",
                request.workoutProgramId(),
                request.workoutDayId(),
                Date.valueOf(request.scheduledDate()),
                request.scheduledTime() != null ? Time.valueOf(request.scheduledTime()) : null,
                title,
                request.workoutProgramId() == null ? "MANUAL" : "USER_PROGRAM",
                request.workoutProgramId(),
                scheduleId,
                userId);

        jdbc.update(
                "delete from workout_schedule_exercises where workout_schedule_id = ?", scheduleId);
        snapshotWorkoutDay(scheduleId, request.workoutDayId());

        return getSchedule(userId, scheduleId);
    }

    @Transactional
    public void cancelSchedule(Long userId, Long scheduleId, String cancelReason) {
        WorkoutScheduleResponse current = getSchedule(userId, scheduleId);
        if (!"PLANNED".equals(current.status())) {
            throw new ApiException(
                    ApiErrorCode.INVALID_STATE_TRANSITION,
                    "Only planned workout schedules can be cancelled");
        }

        jdbc.update(
                "update workout_schedules set status = 'CANCELLED', cancel_reason = ?, updated_at ="
                        + " now() where id = ? and user_id = ?",
                cancelReason,
                scheduleId,
                userId);
    }

    private void validateScheduleRequest(WorkoutScheduleRequest request) {
        if (request == null) {
            throw new ApiValidationException(
                    List.of(
                            new FieldViolation(
                                    "schedule", "REQUIRED", "Schedule request is required")));
        }
        if (request.scheduledDate() == null) {
            throw new ApiValidationException(
                    List.of(
                            new FieldViolation(
                                    "scheduledDate", "REQUIRED", "Scheduled date is required")));
        }
    }

    private void validateProgramReferences(Long userId, Long programId, Long workoutDayId) {
        if ((programId == null) != (workoutDayId == null)) {
            throw new ApiValidationException(
                    List.of(
                            new FieldViolation(
                                    "workoutDayId",
                                    "INVALID_REFERENCE",
                                    "Program and workout day must be provided together")));
        }
        if (programId == null) {
            return;
        }
        Integer count =
                jdbc.queryForObject(
                        "select count(*) from workout_days d join workout_programs p on d.workout_program_id = p.id where p.id = ? and d.id = ? and p.user_id = ? and p.status <> 'ARCHIVED' and p.deleted_at is null",
                        Integer.class,
                        programId,
                        workoutDayId,
                        userId);
        if (count == null || count == 0) {
            throw new ApiException(
                    ApiErrorCode.RESOURCE_NOT_FOUND, "Workout program or workout day not found");
        }
    }

    private void snapshotWorkoutDay(Long scheduleId, Long workoutDayId) {
        if (workoutDayId == null) {
            return;
        }
        jdbc.update(
                "insert into workout_schedule_exercises (workout_schedule_id, exercise_id, exercise_name_snapshot, sort_order, target_sets, target_reps_min, target_reps_max, target_duration_seconds, rest_seconds, note)"
                        + " select ?, we.exercise_id, e.name, we.sort_order, we.target_sets, we.target_reps_min, we.target_reps_max, we.target_duration_seconds, we.rest_seconds, we.note"
                        + " from workout_exercises we join exercises e on we.exercise_id = e.id where we.workout_day_id = ? order by we.sort_order",
                scheduleId,
                workoutDayId);
    }

    private OffsetDateTime toOffsetDateTime(Timestamp timestamp) {
        if (timestamp == null) {
            return null;
        }
        return timestamp.toInstant().atOffset(ZoneOffset.UTC);
    }
}
