package com.viegym.workout.schedule.application;

import com.viegym.common.api.FieldViolation;
import com.viegym.common.api.PageResponse;
import com.viegym.common.error.ApiErrorCode;
import com.viegym.common.error.ApiException;
import com.viegym.common.error.ApiValidationException;
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
                jdbc.query(
                        sql,
                        (rs, row) ->
                                new WorkoutScheduleResponse(
                                        rs.getLong("id"),
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
                                        rs.getObject("active_session_id", Long.class)),
                        dataParams.toArray());

        return PageResponse.from(new PageImpl<>(list, pageable, totalElements));
    }

    @Transactional
    public WorkoutScheduleResponse createSchedule(Long userId, WorkoutScheduleRequest request) {
        validateScheduleRequest(request);

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
                                + " workout_day_id, scheduled_date, scheduled_time, title, status)"
                                + " values (?, ?, ?, ?, ?, ?, 'PLANNED') returning id",
                        Long.class,
                        userId,
                        request.workoutProgramId(),
                        request.workoutDayId(),
                        Date.valueOf(request.scheduledDate()),
                        request.scheduledTime() != null
                                ? Time.valueOf(request.scheduledTime())
                                : null,
                        title);

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
                jdbc.query(
                        sql,
                        (rs, row) ->
                                new WorkoutScheduleResponse(
                                        rs.getLong("id"),
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
                                        rs.getObject("active_session_id", Long.class)),
                        scheduleId,
                        userId);

        if (list.isEmpty()) {
            throw new ApiException(ApiErrorCode.RESOURCE_NOT_FOUND, "Workout schedule not found");
        }
        return list.get(0);
    }

    @Transactional
    public WorkoutScheduleResponse updateSchedule(
            Long userId, Long scheduleId, WorkoutScheduleRequest request) {
        validateScheduleRequest(request);

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
                        + " scheduled_date = ?, scheduled_time = ?, title = ?, updated_at = now()"
                        + " where id = ? and user_id = ?",
                request.workoutProgramId(),
                request.workoutDayId(),
                Date.valueOf(request.scheduledDate()),
                request.scheduledTime() != null ? Time.valueOf(request.scheduledTime()) : null,
                title,
                scheduleId,
                userId);

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

    private OffsetDateTime toOffsetDateTime(Timestamp timestamp) {
        if (timestamp == null) {
            return null;
        }
        return timestamp.toInstant().atOffset(ZoneOffset.UTC);
    }
}
