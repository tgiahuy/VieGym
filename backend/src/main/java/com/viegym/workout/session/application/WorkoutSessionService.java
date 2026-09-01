package com.viegym.workout.session.application;

import com.viegym.common.error.ApiErrorCode;
import com.viegym.common.error.ApiException;
import com.viegym.workout.log.api.PersonalRecordDto;
import com.viegym.workout.program.api.WorkoutExerciseResponse;
import com.viegym.workout.session.api.FinishExerciseLogRequest;
import com.viegym.workout.session.api.FinishSessionRequest;
import com.viegym.workout.session.api.FinishSessionResponse;
import com.viegym.workout.session.api.FinishSetLogRequest;
import com.viegym.workout.session.api.PauseSessionResponse;
import com.viegym.workout.session.api.ResumeSessionResponse;
import com.viegym.workout.session.api.StartSessionResponse;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Timestamp;
import java.time.Duration;
import java.time.Instant;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class WorkoutSessionService {

    private final JdbcTemplate jdbc;

    public WorkoutSessionService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    @Transactional
    public StartSessionResponse startSession(Long userId, Long scheduleId) {
        // Verify schedule
        List<ScheduleInfo> schedules =
                jdbc.query(
                        "select id, workout_day_id, title, status from workout_schedules where id"
                                + " = ? and user_id = ?",
                        (rs, row) ->
                                new ScheduleInfo(
                                        rs.getLong("id"),
                                        rs.getObject("workout_day_id", Long.class),
                                        rs.getString("title"),
                                        rs.getString("status")),
                        scheduleId,
                        userId);

        if (schedules.isEmpty()) {
            throw new ApiException(ApiErrorCode.RESOURCE_NOT_FOUND, "Workout schedule not found");
        }

        ScheduleInfo schedule = schedules.get(0);
        if (!"PLANNED".equals(schedule.status())) {
            throw new ApiException(
                    ApiErrorCode.INVALID_STATE_TRANSITION,
                    "Only planned workout schedules can be started");
        }

        // Check if an active session exists for user
        List<ActiveSessionRow> activeSessions =
                jdbc.query(
                        "select id, workout_schedule_id, status, started_at, total_paused_seconds"
                                + " from workout_sessions where user_id = ? and status in"
                                + " ('IN_PROGRESS', 'PAUSED')",
                        (rs, row) ->
                                new ActiveSessionRow(
                                        rs.getLong("id"),
                                        rs.getLong("workout_schedule_id"),
                                        rs.getString("status"),
                                        rs.getTimestamp("started_at"),
                                        rs.getInt("total_paused_seconds")),
                        userId);

        if (!activeSessions.isEmpty()) {
            ActiveSessionRow active = activeSessions.get(0);
            if (active.scheduleId().equals(scheduleId)) {
                // Idempotent retry for same schedule
                List<WorkoutExerciseResponse> exercises =
                        loadPlannedExercises(schedule.workoutDayId());
                return new StartSessionResponse(
                        active.id(),
                        active.scheduleId(),
                        active.status(),
                        toOffsetDateTime(active.startedAt()),
                        active.totalPausedSeconds(),
                        exercises);
            } else {
                throw new ApiException(
                        ApiErrorCode.ACTIVE_SESSION_EXISTS,
                        "Active workout session already exists for schedule "
                                + active.scheduleId());
            }
        }

        Long sessionId =
                jdbc.queryForObject(
                        "insert into workout_sessions (user_id, workout_schedule_id, status,"
                                + " started_at) values (?, ?, 'IN_PROGRESS', now()) returning id",
                        Long.class,
                        userId,
                        scheduleId);

        Timestamp startedAt =
                jdbc.queryForObject(
                        "select started_at from workout_sessions where id = ?",
                        Timestamp.class,
                        sessionId);

        List<WorkoutExerciseResponse> exercises = loadPlannedExercises(schedule.workoutDayId());

        return new StartSessionResponse(
                sessionId, scheduleId, "IN_PROGRESS", toOffsetDateTime(startedAt), 0, exercises);
    }

    @Transactional
    public PauseSessionResponse pauseSession(Long userId, Long sessionId) {
        List<SessionRow> sessions =
                jdbc.query(
                        "select id, status, started_at, paused_at, total_paused_seconds from"
                                + " workout_sessions where id = ? and user_id = ?",
                        (rs, row) ->
                                new SessionRow(
                                        rs.getLong("id"),
                                        rs.getString("status"),
                                        rs.getTimestamp("started_at"),
                                        rs.getTimestamp("paused_at"),
                                        rs.getInt("total_paused_seconds")),
                        sessionId,
                        userId);

        if (sessions.isEmpty()) {
            throw new ApiException(ApiErrorCode.RESOURCE_NOT_FOUND, "Workout session not found");
        }

        SessionRow session = sessions.get(0);
        if (!"IN_PROGRESS".equals(session.status())) {
            throw new ApiException(
                    ApiErrorCode.INVALID_STATE_TRANSITION,
                    "Only in-progress workout sessions can be paused");
        }

        jdbc.update(
                "update workout_sessions set status = 'PAUSED', paused_at = now(), updated_at ="
                        + " now() where id = ?",
                sessionId);

        Timestamp now =
                jdbc.queryForObject(
                        "select paused_at from workout_sessions where id = ?",
                        Timestamp.class,
                        sessionId);

        return new PauseSessionResponse(
                sessionId, "PAUSED", toOffsetDateTime(now), session.totalPausedSeconds());
    }

    @Transactional
    public ResumeSessionResponse resumeSession(Long userId, Long sessionId) {
        List<SessionRow> sessions =
                jdbc.query(
                        "select id, status, started_at, paused_at, total_paused_seconds from"
                                + " workout_sessions where id = ? and user_id = ?",
                        (rs, row) ->
                                new SessionRow(
                                        rs.getLong("id"),
                                        rs.getString("status"),
                                        rs.getTimestamp("started_at"),
                                        rs.getTimestamp("paused_at"),
                                        rs.getInt("total_paused_seconds")),
                        sessionId,
                        userId);

        if (sessions.isEmpty()) {
            throw new ApiException(ApiErrorCode.RESOURCE_NOT_FOUND, "Workout session not found");
        }

        SessionRow session = sessions.get(0);
        if (!"PAUSED".equals(session.status())) {
            throw new ApiException(
                    ApiErrorCode.INVALID_STATE_TRANSITION,
                    "Only paused workout sessions can be resumed");
        }

        Instant now = Instant.now();
        long addedPause = 0;
        if (session.pausedAt() != null) {
            addedPause =
                    Math.max(0, Duration.between(session.pausedAt().toInstant(), now).toSeconds());
        }
        int totalPause = session.totalPausedSeconds() + (int) addedPause;

        jdbc.update(
                "update workout_sessions set status = 'IN_PROGRESS', paused_at = null,"
                        + " total_paused_seconds = ?, updated_at = now() where id = ?",
                totalPause,
                sessionId);

        return new ResumeSessionResponse(sessionId, "IN_PROGRESS", totalPause);
    }

    @Transactional
    public FinishSessionResponse finishSession(
            Long userId, Long sessionId, FinishSessionRequest request) {
        List<SessionFullRow> sessions =
                jdbc.query(
                        "select ws.id, ws.workout_schedule_id, ws.status, ws.started_at,"
                                + " ws.paused_at, ws.total_paused_seconds, s.title from"
                                + " workout_sessions ws join workout_schedules s on"
                                + " ws.workout_schedule_id = s.id where ws.id = ? and ws.user_id = ?",
                        (rs, row) ->
                                new SessionFullRow(
                                        rs.getLong("id"),
                                        rs.getLong("workout_schedule_id"),
                                        rs.getString("status"),
                                        rs.getTimestamp("started_at"),
                                        rs.getTimestamp("paused_at"),
                                        rs.getInt("total_paused_seconds"),
                                        rs.getString("title")),
                        sessionId,
                        userId);

        if (sessions.isEmpty()) {
            throw new ApiException(ApiErrorCode.RESOURCE_NOT_FOUND, "Workout session not found");
        }

        SessionFullRow session = sessions.get(0);
        if (!"IN_PROGRESS".equals(session.status()) && !"PAUSED".equals(session.status())) {
            throw new ApiException(
                    ApiErrorCode.INVALID_STATE_TRANSITION,
                    "Only in-progress or paused workout sessions can be finished");
        }

        Instant now = Instant.now();
        int totalPause = session.totalPausedSeconds();
        if ("PAUSED".equals(session.status()) && session.pausedAt() != null) {
            long added =
                    Math.max(0, Duration.between(session.pausedAt().toInstant(), now).toSeconds());
            totalPause += (int) added;
        }

        long rawDuration =
                Math.max(0, Duration.between(session.startedAt().toInstant(), now).toSeconds());
        int actualDurationSeconds = Math.max(0, (int) rawDuration - totalPause);

        // Compute set & exercise volumes
        BigDecimal totalVolume = BigDecimal.ZERO;
        List<PersonalRecordDto> newPrs = new ArrayList<>();

        // Create workout_log
        Long workoutLogId =
                jdbc.queryForObject(
                        "insert into workout_logs (user_id, workout_session_id,"
                                + " workout_schedule_id, title_snapshot, started_at, completed_at,"
                                + " duration_seconds, total_volume_kg, note) values (?, ?, ?, ?, ?, ?,"
                                + " ?, 0, ?) returning id",
                        Long.class,
                        userId,
                        sessionId,
                        session.scheduleId(),
                        session.scheduleTitle(),
                        session.startedAt(),
                        Timestamp.from(now),
                        actualDurationSeconds,
                        request != null ? request.note() : null);

        if (request != null && request.exercises() != null) {
            for (FinishExerciseLogRequest exReq : request.exercises()) {
                String exName =
                        jdbc
                                .query(
                                        "select name from exercises where id = ?",
                                        (rs, row) -> rs.getString("name"),
                                        exReq.exerciseId())
                                .stream()
                                .findFirst()
                                .orElse("Exercise " + exReq.exerciseId());

                BigDecimal exerciseVolume = BigDecimal.ZERO;
                Double maxWeight = null;
                Integer maxReps = null;
                Double maxSetVolume = null;

                Long exLogId =
                        jdbc.queryForObject(
                                "insert into workout_exercise_logs (workout_log_id, exercise_id,"
                                        + " exercise_name_snapshot, sort_order, duration_seconds,"
                                        + " exercise_volume_kg, completed) values (?, ?, ?, ?, ?, 0, ?)"
                                        + " returning id",
                                Long.class,
                                workoutLogId,
                                exReq.exerciseId(),
                                exName,
                                exReq.sortOrder(),
                                exReq.durationSeconds(),
                                exReq.completed());

                if (exReq.sets() != null) {
                    for (FinishSetLogRequest setReq : exReq.sets()) {
                        jdbc.update(
                                "insert into workout_set_logs (workout_exercise_log_id, set_number,"
                                        + " reps, weight_kg, duration_seconds, rpe, completed) values"
                                        + " (?, ?, ?, ?, ?, ?, ?)",
                                exLogId,
                                setReq.setNumber(),
                                setReq.reps(),
                                setReq.weightKg(),
                                setReq.durationSeconds(),
                                setReq.rpe(),
                                setReq.completed());

                        if (setReq.completed()) {
                            if (setReq.weightKg() != null && setReq.weightKg() > 0) {
                                if (maxWeight == null || setReq.weightKg() > maxWeight) {
                                    maxWeight = setReq.weightKg();
                                }
                            }
                            if (setReq.reps() != null && setReq.reps() > 0) {
                                if (maxReps == null || setReq.reps() > maxReps) {
                                    maxReps = setReq.reps();
                                }
                            }
                            if (setReq.weightKg() != null
                                    && setReq.weightKg() > 0
                                    && setReq.reps() != null
                                    && setReq.reps() > 0) {
                                double setVol = setReq.weightKg() * setReq.reps();
                                exerciseVolume = exerciseVolume.add(BigDecimal.valueOf(setVol));
                                if (maxSetVolume == null || setVol > maxSetVolume) {
                                    maxSetVolume = setVol;
                                }
                            }
                        }
                    }
                }

                totalVolume = totalVolume.add(exerciseVolume);
                jdbc.update(
                        "update workout_exercise_logs set exercise_volume_kg = ? where id = ?",
                        exerciseVolume.setScale(2, RoundingMode.HALF_UP),
                        exLogId);

                // PR evaluation
                evaluatePr(
                        userId,
                        exReq.exerciseId(),
                        exName,
                        "MAX_WEIGHT",
                        maxWeight,
                        now,
                        workoutLogId,
                        newPrs);
                evaluatePr(
                        userId,
                        exReq.exerciseId(),
                        exName,
                        "MAX_REPS",
                        maxReps != null ? maxReps.doubleValue() : null,
                        now,
                        workoutLogId,
                        newPrs);
                evaluatePr(
                        userId,
                        exReq.exerciseId(),
                        exName,
                        "MAX_VOLUME",
                        maxSetVolume,
                        now,
                        workoutLogId,
                        newPrs);
            }
        }

        // Update workout_log total volume
        BigDecimal finalVolume = totalVolume.setScale(2, RoundingMode.HALF_UP);
        jdbc.update(
                "update workout_logs set total_volume_kg = ? where id = ?",
                finalVolume,
                workoutLogId);

        // Finish session & schedule
        jdbc.update(
                "update workout_sessions set status = 'COMPLETED', finished_at = ?, total_paused_seconds = ?, updated_at = now() where id = ?",
                Timestamp.from(now),
                totalPause,
                sessionId);

        jdbc.update(
                "update workout_schedules set status = 'COMPLETED', completed_at = ?, updated_at = now() where id = ?",
                Timestamp.from(now),
                session.scheduleId());

        return new FinishSessionResponse(
                workoutLogId, sessionId, actualDurationSeconds, finalVolume.doubleValue(), newPrs);
    }

    @Transactional
    public void discardSession(Long userId, Long sessionId, String reason) {
        List<SessionRow> sessions =
                jdbc.query(
                        "select id, status, started_at, paused_at, total_paused_seconds from"
                                + " workout_sessions where id = ? and user_id = ?",
                        (rs, row) ->
                                new SessionRow(
                                        rs.getLong("id"),
                                        rs.getString("status"),
                                        rs.getTimestamp("started_at"),
                                        rs.getTimestamp("paused_at"),
                                        rs.getInt("total_paused_seconds")),
                        sessionId,
                        userId);

        if (sessions.isEmpty()) {
            throw new ApiException(ApiErrorCode.RESOURCE_NOT_FOUND, "Workout session not found");
        }

        SessionRow session = sessions.get(0);
        if (!"IN_PROGRESS".equals(session.status()) && !"PAUSED".equals(session.status())) {
            throw new ApiException(
                    ApiErrorCode.INVALID_STATE_TRANSITION,
                    "Only in-progress or paused workout sessions can be discarded");
        }

        jdbc.update(
                "update workout_sessions set status = 'DISCARDED', discarded_at = now(),"
                        + " updated_at = now() where id = ?",
                sessionId);
    }

    private void evaluatePr(
            Long userId,
            Long exerciseId,
            String exerciseName,
            String recordType,
            Double candidateValue,
            Instant achievedAt,
            Long workoutLogId,
            List<PersonalRecordDto> prList) {
        if (candidateValue == null || candidateValue <= 0) {
            return;
        }

        List<PersonalRecordRow> current =
                jdbc.query(
                        "select id, value from personal_records where user_id = ? and exercise_id ="
                                + " ? and record_type = ?",
                        (rs, row) -> new PersonalRecordRow(rs.getLong("id"), rs.getDouble("value")),
                        userId,
                        exerciseId,
                        recordType);

        if (current.isEmpty()) {
            Long prId =
                    jdbc.queryForObject(
                            "insert into personal_records (user_id, exercise_id, record_type,"
                                    + " value, achieved_at, workout_log_id) values (?, ?, ?, ?, ?, ?)"
                                    + " returning id",
                            Long.class,
                            userId,
                            exerciseId,
                            recordType,
                            candidateValue,
                            Timestamp.from(achievedAt),
                            workoutLogId);
            prList.add(
                    new PersonalRecordDto(
                            prId,
                            exerciseId,
                            exerciseName,
                            recordType,
                            candidateValue,
                            achievedAt.atOffset(ZoneOffset.UTC),
                            workoutLogId,
                            null));
        } else {
            PersonalRecordRow row = current.get(0);
            if (candidateValue > row.value()) {
                jdbc.update(
                        "update personal_records set value = ?, achieved_at = ?, workout_log_id = ?,"
                                + " updated_at = now() where id = ?",
                        candidateValue,
                        Timestamp.from(achievedAt),
                        workoutLogId,
                        row.id());
                prList.add(
                        new PersonalRecordDto(
                                row.id(),
                                exerciseId,
                                exerciseName,
                                recordType,
                                candidateValue,
                                achievedAt.atOffset(ZoneOffset.UTC),
                                workoutLogId,
                                row.value()));
            }
        }
    }

    private List<WorkoutExerciseResponse> loadPlannedExercises(Long workoutDayId) {
        if (workoutDayId == null) {
            return Collections.emptyList();
        }
        String sql =
                "select we.id, we.exercise_id, e.name as exercise_name, e.slug as exercise_slug,"
                        + " (case when e.visibility = 'HIDDEN' or e.deleted_at is not null then true"
                        + " else false end) as is_hidden, we.sort_order, we.target_sets,"
                        + " we.target_reps_min, we.target_reps_max, we.target_duration_seconds,"
                        + " we.rest_seconds, we.note from workout_exercises we join exercises e on"
                        + " we.exercise_id = e.id where we.workout_day_id = ? order by we.sort_order"
                        + " asc";

        return jdbc.query(
                sql,
                (rs, row) ->
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
                                rs.getString("note")),
                workoutDayId);
    }

    private OffsetDateTime toOffsetDateTime(Timestamp timestamp) {
        if (timestamp == null) {
            return null;
        }
        return timestamp.toInstant().atOffset(ZoneOffset.UTC);
    }

    private record ScheduleInfo(Long id, Long workoutDayId, String title, String status) {}

    private record ActiveSessionRow(
            Long id, Long scheduleId, String status, Timestamp startedAt, int totalPausedSeconds) {}

    private record SessionRow(
            Long id,
            String status,
            Timestamp startedAt,
            Timestamp pausedAt,
            int totalPausedSeconds) {}

    private record SessionFullRow(
            Long id,
            Long scheduleId,
            String status,
            Timestamp startedAt,
            Timestamp pausedAt,
            int totalPausedSeconds,
            String scheduleTitle) {}

    private record PersonalRecordRow(Long id, double value) {}
}
