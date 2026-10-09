package com.viegym.workout.planning.application;

import com.viegym.common.api.FieldViolation;
import com.viegym.common.error.ApiErrorCode;
import com.viegym.common.error.ApiException;
import com.viegym.common.error.ApiValidationException;
import com.viegym.identity.UserProfile;
import com.viegym.identity.UserProfileRepository;
import com.viegym.workout.planning.api.ApplyScheduleProposalResponse;
import com.viegym.workout.planning.api.CreateScheduleProposalRequest;
import com.viegym.workout.planning.api.ScheduleExercisePlan;
import com.viegym.workout.planning.api.ScheduleProposalItemRequest;
import com.viegym.workout.planning.api.ScheduleProposalItemResponse;
import com.viegym.workout.planning.api.ScheduleProposalResponse;
import com.viegym.workout.schedule.api.WorkoutScheduleResponse;
import com.viegym.workout.schedule.application.WorkoutScheduleService;
import java.sql.Date;
import java.sql.Time;
import java.sql.Timestamp;
import java.time.Clock;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.time.ZoneOffset;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowCallbackHandler;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class WorkoutSchedulePlanningService {

    private static final Set<String> SOURCE_TYPES =
            Set.of("MANUAL", "USER_PROGRAM", "AI", "ADMIN_TEMPLATE");
    private static final Set<String> SCOPES = Set.of("ONE_DAY", "WEEK");
    private static final int MAX_WEEK_ITEMS = 7;

    private final JdbcTemplate jdbc;
    private final WorkoutScheduleService schedules;
    private final UserProfileRepository userProfiles;
    private final Clock clock;

    public WorkoutSchedulePlanningService(
            JdbcTemplate jdbc,
            WorkoutScheduleService schedules,
            UserProfileRepository userProfiles,
            Clock clock) {
        this.jdbc = jdbc;
        this.schedules = schedules;
        this.userProfiles = userProfiles;
        this.clock = clock;
    }

    @Transactional
    public ScheduleProposalResponse createProposal(
            Long userId, CreateScheduleProposalRequest request) {
        RequestContext context = validateBaseRequest(request);
        List<ProposedItem> items =
                switch (context.sourceType()) {
                    case "MANUAL", "AI" -> buildDirectItems(request, context.scope());
                    case "USER_PROGRAM" -> buildProgramItems(userId, request, context.scope());
                    case "ADMIN_TEMPLATE" -> buildTemplateItems(request, context.scope());
                    default -> throw new IllegalStateException("Unsupported source type");
                };
        validateDates(userId, items, context.scope());
        detectExistingConflicts(userId, items);

        SourceMetadata source = sourceMetadata(userId, request, context.sourceType());
        OffsetDateTime expiresAt = OffsetDateTime.now(ZoneOffset.UTC).plusMinutes(30);
        Long proposalId =
                jdbc.queryForObject(
                        "insert into workout_schedule_proposals (user_id, source_type, scope, source_id, source_version, status, expires_at) values (?, ?, ?, ?, ?, 'PENDING', ?) returning id",
                        Long.class,
                        userId,
                        context.sourceType(),
                        context.scope(),
                        source.id(),
                        source.version(),
                        Timestamp.from(expiresAt.toInstant()));

        int sortOrder = 1;
        for (ProposedItem item : items) {
            Long itemId =
                    jdbc.queryForObject(
                            "insert into workout_schedule_proposal_items (proposal_id, sort_order, source_day_id, scheduled_date, scheduled_time, title) values (?, ?, ?, ?, ?, ?) returning id",
                            Long.class,
                            proposalId,
                            sortOrder++,
                            item.sourceDayId(),
                            Date.valueOf(item.date()),
                            item.time() == null ? null : Time.valueOf(item.time()),
                            item.title());
            for (ScheduleExercisePlan exercise : item.exercises()) {
                insertProposalExercise(itemId, exercise);
            }
        }
        return getProposal(userId, proposalId);
    }

    @Transactional(readOnly = true)
    public ScheduleProposalResponse getProposal(Long userId, Long proposalId) {
        List<ProposalRow> proposals =
                jdbc.query(
                        "select id, source_type, scope, source_id, source_version, status, expires_at, applied_at from workout_schedule_proposals where id = ? and user_id = ?",
                        (rs, row) ->
                                new ProposalRow(
                                        rs.getLong("id"),
                                        rs.getString("source_type"),
                                        rs.getString("scope"),
                                        rs.getObject("source_id", Long.class),
                                        rs.getObject("source_version", Integer.class),
                                        rs.getString("status"),
                                        toOffsetDateTime(rs.getTimestamp("expires_at")),
                                        toOffsetDateTime(rs.getTimestamp("applied_at"))),
                        proposalId,
                        userId);
        if (proposals.isEmpty()) {
            throw new ApiException(ApiErrorCode.RESOURCE_NOT_FOUND, "Schedule proposal not found");
        }
        ProposalRow proposal = proposals.get(0);
        return new ScheduleProposalResponse(
                proposal.id(),
                proposal.sourceType(),
                proposal.scope(),
                proposal.sourceId(),
                proposal.sourceVersion(),
                effectiveStatus(proposal),
                proposal.expiresAt(),
                proposal.appliedAt(),
                loadProposalItems(proposal.id()));
    }

    @Transactional
    public ApplyScheduleProposalResponse apply(Long userId, Long proposalId) {
        List<ProposalRow> proposals =
                jdbc.query(
                        "select id, source_type, scope, source_id, source_version, status, expires_at, applied_at from workout_schedule_proposals where id = ? and user_id = ? for update",
                        (rs, row) ->
                                new ProposalRow(
                                        rs.getLong("id"),
                                        rs.getString("source_type"),
                                        rs.getString("scope"),
                                        rs.getObject("source_id", Long.class),
                                        rs.getObject("source_version", Integer.class),
                                        rs.getString("status"),
                                        toOffsetDateTime(rs.getTimestamp("expires_at")),
                                        toOffsetDateTime(rs.getTimestamp("applied_at"))),
                        proposalId,
                        userId);
        if (proposals.isEmpty()) {
            throw new ApiException(ApiErrorCode.RESOURCE_NOT_FOUND, "Schedule proposal not found");
        }
        ProposalRow proposal = proposals.get(0);
        if ("APPLIED".equals(proposal.status())) {
            return new ApplyScheduleProposalResponse(
                    proposalId, "APPLIED", loadAppliedSchedules(userId, proposalId));
        }
        if (proposal.expiresAt().isBefore(OffsetDateTime.now(ZoneOffset.UTC))) {
            jdbc.update(
                    "update workout_schedule_proposals set status = 'EXPIRED' where id = ?",
                    proposalId);
            throw new ApiException(
                    ApiErrorCode.RECOMMENDATION_EXPIRED, "Schedule proposal expired");
        }
        revalidateSource(userId, proposal);

        List<ScheduleProposalItemResponse> items = loadProposalItems(proposalId);
        detectExistingConflicts(
                userId,
                items.stream()
                        .map(
                                item ->
                                        new ProposedItem(
                                                item.sourceDayId(),
                                                item.scheduledDate(),
                                                item.scheduledTime(),
                                                item.title(),
                                                item.exercises()))
                        .toList());

        try {
            for (ScheduleProposalItemResponse item : items) {
                Long programId =
                        "USER_PROGRAM".equals(proposal.sourceType()) ? proposal.sourceId() : null;
                Long workoutDayId =
                        "USER_PROGRAM".equals(proposal.sourceType()) ? item.sourceDayId() : null;
                Long scheduleId =
                        jdbc.queryForObject(
                                "insert into workout_schedules (user_id, workout_program_id, workout_day_id, scheduled_date, scheduled_time, title, status, source_type, source_id, source_version, proposal_id) values (?, ?, ?, ?, ?, ?, 'PLANNED', ?, ?, ?, ?) returning id",
                                Long.class,
                                userId,
                                programId,
                                workoutDayId,
                                Date.valueOf(item.scheduledDate()),
                                item.scheduledTime() == null
                                        ? null
                                        : Time.valueOf(item.scheduledTime()),
                                item.title(),
                                proposal.sourceType(),
                                proposal.sourceId(),
                                proposal.sourceVersion(),
                                proposalId);
                snapshotExercises(scheduleId, item.exercises());
                jdbc.update(
                        "update workout_schedule_proposal_items set applied_schedule_id = ? where id = ?",
                        scheduleId,
                        item.id());
            }
        } catch (DataIntegrityViolationException exception) {
            throw new ApiException(
                    ApiErrorCode.SCHEDULE_SLOT_CONFLICT,
                    "A planned workout already occupies one of the requested time slots");
        }
        jdbc.update(
                "update workout_schedule_proposals set status = 'APPLIED', applied_at = now() where id = ?",
                proposalId);
        return new ApplyScheduleProposalResponse(
                proposalId, "APPLIED", loadAppliedSchedules(userId, proposalId));
    }

    private List<ProposedItem> buildDirectItems(
            CreateScheduleProposalRequest request, String scope) {
        if (request.items() == null || request.items().isEmpty()) {
            throw validation("items", "REQUIRED", "Manual and AI proposals require items");
        }
        if ("ONE_DAY".equals(scope) && request.items().size() != 1) {
            throw validation("items", "INVALID_SIZE", "ONE_DAY requires exactly one item");
        }
        if ("WEEK".equals(scope)
                && (request.items().size() < 1 || request.items().size() > MAX_WEEK_ITEMS)) {
            throw validation("items", "INVALID_SIZE", "WEEK supports between one and seven items");
        }
        List<ProposedItem> result = new ArrayList<>();
        for (int index = 0; index < request.items().size(); index++) {
            ScheduleProposalItemRequest item = request.items().get(index);
            if (item == null || item.scheduledDate() == null) {
                throw validation(
                        "items[" + index + "].scheduledDate",
                        "REQUIRED",
                        "Scheduled date is required");
            }
            String title =
                    item.title() == null || item.title().isBlank()
                            ? "Workout Session"
                            : item.title().trim();
            List<ScheduleExercisePlan> exercises =
                    item.exercises() == null ? List.of() : item.exercises();
            validateExercises(exercises, "items[" + index + "].exercises");
            result.add(
                    new ProposedItem(
                            null, item.scheduledDate(), item.scheduledTime(), title, exercises));
        }
        return result;
    }

    private List<ProposedItem> buildProgramItems(
            Long userId, CreateScheduleProposalRequest request, String scope) {
        if (request.sourceId() == null) {
            throw validation("sourceId", "REQUIRED", "Program id is required");
        }
        Integer count =
                jdbc.queryForObject(
                        "select count(*) from workout_programs where id = ? and user_id = ? and status <> 'ARCHIVED' and deleted_at is null",
                        Integer.class,
                        request.sourceId(),
                        userId);
        if (count == null || count == 0) {
            throw new ApiException(ApiErrorCode.RESOURCE_NOT_FOUND, "Workout program not found");
        }
        List<PlanDay> days = loadProgramDays(request.sourceId());
        return mapSourceDays(days, request, scope);
    }

    private List<ProposedItem> buildTemplateItems(
            CreateScheduleProposalRequest request, String scope) {
        if (request.sourceId() == null) {
            throw validation("sourceId", "REQUIRED", "Template id is required");
        }
        Integer count =
                jdbc.queryForObject(
                        "select count(*) from workout_program_templates where id = ? and status = 'PUBLISHED'",
                        Integer.class,
                        request.sourceId());
        if (count == null || count == 0) {
            throw new ApiException(ApiErrorCode.RESOURCE_NOT_FOUND, "Workout template not found");
        }
        List<PlanDay> days = loadTemplateDays(request.sourceId());
        return mapSourceDays(days, request, scope);
    }

    private List<ProposedItem> mapSourceDays(
            List<PlanDay> days, CreateScheduleProposalRequest request, String scope) {
        if (days.isEmpty()) {
            throw validation("sourceId", "EMPTY", "Source has no workout days");
        }
        if (request.targetDates() == null || request.targetDates().isEmpty()) {
            throw validation("targetDates", "REQUIRED", "Target dates are required");
        }
        if ("ONE_DAY".equals(scope)) {
            if (request.targetDates().size() != 1 || request.sourceDayId() == null) {
                throw validation(
                        "sourceDayId",
                        "REQUIRED",
                        "ONE_DAY requires one target date and one source day");
            }
            PlanDay selected =
                    days.stream()
                            .filter(day -> day.id().equals(request.sourceDayId()))
                            .findFirst()
                            .orElseThrow(
                                    () ->
                                            validation(
                                                    "sourceDayId",
                                                    "INVALID",
                                                    "Source day does not belong to source"));
            validateExercises(selected.exercises(), "sourceDay.exercises");
            return List.of(
                    new ProposedItem(
                            selected.id(),
                            request.targetDates().get(0),
                            request.scheduledTime(),
                            selected.name(),
                            selected.exercises()));
        }
        if (request.targetDates().size() != days.size() || days.size() > MAX_WEEK_ITEMS) {
            throw validation(
                    "targetDates",
                    "INVALID_SIZE",
                    "WEEK requires exactly one target date for each source day, up to seven");
        }
        List<ProposedItem> result = new ArrayList<>();
        for (int index = 0; index < days.size(); index++) {
            PlanDay day = days.get(index);
            validateExercises(day.exercises(), "sourceDays[" + index + "].exercises");
            result.add(
                    new ProposedItem(
                            day.id(),
                            request.targetDates().get(index),
                            request.scheduledTime(),
                            day.name(),
                            day.exercises()));
        }
        return result;
    }

    private List<PlanDay> loadProgramDays(Long programId) {
        return loadSourceDays(
                "select id, day_number, name from workout_days where workout_program_id = ? order by day_number",
                "select we.workout_day_id as day_id, we.exercise_id, e.name as exercise_name, (select mg.name from exercise_muscle_groups emg join muscle_groups mg on mg.id = emg.muscle_group_id where emg.exercise_id = e.id and emg.role = 'PRIMARY' order by mg.name limit 1) as primary_muscle, we.sort_order, we.target_sets, we.target_reps_min, we.target_reps_max, we.target_duration_seconds, we.rest_seconds, we.note from workout_exercises we join exercises e on e.id = we.exercise_id where we.workout_day_id in (%s) order by we.sort_order",
                programId);
    }

    private List<PlanDay> loadTemplateDays(Long templateId) {
        return loadSourceDays(
                "select id, day_number, name from workout_template_days where template_id = ? order by day_number",
                "select wte.template_day_id as day_id, wte.exercise_id, e.name as exercise_name, (select mg.name from exercise_muscle_groups emg join muscle_groups mg on mg.id = emg.muscle_group_id where emg.exercise_id = e.id and emg.role = 'PRIMARY' order by mg.name limit 1) as primary_muscle, wte.sort_order, wte.target_sets, wte.target_reps_min, wte.target_reps_max, wte.target_duration_seconds, wte.rest_seconds, wte.note from workout_template_exercises wte join exercises e on e.id = wte.exercise_id where wte.template_day_id in (%s) order by wte.sort_order",
                templateId);
    }

    private List<PlanDay> loadSourceDays(String daySql, String exerciseSql, Long sourceId) {
        List<PlanDayBase> bases =
                jdbc.query(
                        daySql,
                        (rs, row) ->
                                new PlanDayBase(
                                        rs.getLong("id"),
                                        rs.getInt("day_number"),
                                        rs.getString("name")),
                        sourceId);
        if (bases.isEmpty()) {
            return List.of();
        }
        List<Long> ids = bases.stream().map(PlanDayBase::id).toList();
        String placeholders = String.join(",", Collections.nCopies(ids.size(), "?"));
        Map<Long, List<ScheduleExercisePlan>> exercises = new HashMap<>();
        jdbc.query(
                exerciseSql.formatted(placeholders),
                (RowCallbackHandler)
                        rs ->
                                exercises
                                        .computeIfAbsent(
                                                rs.getLong("day_id"), ignored -> new ArrayList<>())
                                        .add(mapExercise(rs)),
                ids.toArray());
        return bases.stream()
                .map(
                        day ->
                                new PlanDay(
                                        day.id(),
                                        day.dayNumber(),
                                        day.name(),
                                        exercises.getOrDefault(day.id(), List.of())))
                .toList();
    }

    private ScheduleExercisePlan mapExercise(java.sql.ResultSet rs) throws java.sql.SQLException {
        return new ScheduleExercisePlan(
                rs.getLong("exercise_id"),
                rs.getString("exercise_name"),
                rs.getString("primary_muscle"),
                rs.getInt("sort_order"),
                rs.getInt("target_sets"),
                rs.getObject("target_reps_min", Integer.class),
                rs.getObject("target_reps_max", Integer.class),
                rs.getObject("target_duration_seconds", Integer.class),
                rs.getInt("rest_seconds"),
                rs.getString("note"));
    }

    private void validateDates(Long userId, List<ProposedItem> items, String scope) {
        Set<LocalDate> unique = new HashSet<>();
        ZoneId timezone =
                userProfiles
                        .findByUserId(userId)
                        .map(UserProfile::timezone)
                        .map(ZoneId::of)
                        .orElse(ZoneId.of("Asia/Ho_Chi_Minh"));
        LocalDate today = LocalDate.now(clock.withZone(timezone));
        for (ProposedItem item : items) {
            if (item.date().isBefore(today)) {
                throw validation(
                        "scheduledDate", "PAST_DATE", "Scheduled date cannot be in the past");
            }
            if (!unique.add(item.date())) {
                throw validation(
                        "scheduledDate", "DUPLICATE", "Proposal cannot contain duplicate dates");
            }
        }
        if ("WEEK".equals(scope)) {
            LocalDate weekStart =
                    items.get(0).date().with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
            LocalDate weekEnd = weekStart.plusDays(6);
            if (items.stream()
                    .anyMatch(
                            item ->
                                    item.date().isBefore(weekStart)
                                            || item.date().isAfter(weekEnd))) {
                throw validation(
                        "scheduledDate", "OUTSIDE_WEEK", "All WEEK items must be in one week");
            }
        }
    }

    private void detectExistingConflicts(Long userId, List<ProposedItem> items) {
        for (ProposedItem item : items) {
            Integer count;
            if (item.time() == null) {
                count =
                        jdbc.queryForObject(
                                "select count(*) from workout_schedules where user_id = ? and scheduled_date = ? and scheduled_time is null and status = 'PLANNED'",
                                Integer.class,
                                userId,
                                Date.valueOf(item.date()));
            } else {
                count =
                        jdbc.queryForObject(
                                "select count(*) from workout_schedules where user_id = ? and scheduled_date = ? and scheduled_time = ? and status = 'PLANNED'",
                                Integer.class,
                                userId,
                                Date.valueOf(item.date()),
                                Time.valueOf(item.time()));
            }
            if (count != null && count > 0) {
                throw new ApiException(
                        ApiErrorCode.SCHEDULE_SLOT_CONFLICT,
                        "A planned workout already exists at " + item.date() + " " + item.time());
            }
        }
    }

    private SourceMetadata sourceMetadata(
            Long userId, CreateScheduleProposalRequest request, String sourceType) {
        if ("USER_PROGRAM".equals(sourceType)) {
            Integer count =
                    jdbc.queryForObject(
                            "select count(*) from workout_programs where id = ? and user_id = ? and deleted_at is null",
                            Integer.class,
                            request.sourceId(),
                            userId);
            if (count == null || count == 0) {
                throw new ApiException(
                        ApiErrorCode.RESOURCE_NOT_FOUND, "Workout program not found");
            }
            return new SourceMetadata(request.sourceId(), null);
        }
        if ("ADMIN_TEMPLATE".equals(sourceType)) {
            Integer version =
                    jdbc.queryForObject(
                            "select version from workout_program_templates where id = ? and status = 'PUBLISHED'",
                            Integer.class,
                            request.sourceId());
            return new SourceMetadata(request.sourceId(), version);
        }
        return new SourceMetadata(null, null);
    }

    private void revalidateSource(Long userId, ProposalRow proposal) {
        if ("USER_PROGRAM".equals(proposal.sourceType())) {
            Integer count =
                    jdbc.queryForObject(
                            "select count(*) from workout_programs where id = ? and user_id = ? and status <> 'ARCHIVED' and deleted_at is null",
                            Integer.class,
                            proposal.sourceId(),
                            userId);
            if (count == null || count == 0) {
                throw new ApiException(
                        ApiErrorCode.PROPOSAL_TARGET_INVALID,
                        "Workout program is no longer available");
            }
        } else if ("ADMIN_TEMPLATE".equals(proposal.sourceType())) {
            List<Integer> versions =
                    jdbc.queryForList(
                            "select version from workout_program_templates where id = ? and status = 'PUBLISHED'",
                            Integer.class,
                            proposal.sourceId());
            if (versions.isEmpty() || !versions.get(0).equals(proposal.sourceVersion())) {
                throw new ApiException(
                        ApiErrorCode.PROPOSAL_TARGET_INVALID,
                        "Workout template changed; create a new preview");
            }
        }
    }

    private void insertProposalExercise(Long itemId, ScheduleExercisePlan exercise) {
        jdbc.update(
                "insert into workout_schedule_proposal_exercises (proposal_item_id, exercise_id, sort_order, target_sets, target_reps_min, target_reps_max, target_duration_seconds, rest_seconds, note) values (?, ?, ?, ?, ?, ?, ?, ?, ?)",
                itemId,
                exercise.exerciseId(),
                exercise.sortOrder(),
                exercise.targetSets(),
                exercise.targetRepsMin(),
                exercise.targetRepsMax(),
                exercise.targetDurationSeconds(),
                exercise.restSeconds() == null ? 60 : exercise.restSeconds(),
                exercise.note());
    }

    private void snapshotExercises(Long scheduleId, List<ScheduleExercisePlan> exercises) {
        for (ScheduleExercisePlan exercise : exercises) {
            String name =
                    jdbc.queryForObject(
                            "select name from exercises where id = ?",
                            String.class,
                            exercise.exerciseId());
            jdbc.update(
                    "insert into workout_schedule_exercises (workout_schedule_id, exercise_id, exercise_name_snapshot, sort_order, target_sets, target_reps_min, target_reps_max, target_duration_seconds, rest_seconds, note) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                    scheduleId,
                    exercise.exerciseId(),
                    name,
                    exercise.sortOrder(),
                    exercise.targetSets(),
                    exercise.targetRepsMin(),
                    exercise.targetRepsMax(),
                    exercise.targetDurationSeconds(),
                    exercise.restSeconds() == null ? 60 : exercise.restSeconds(),
                    exercise.note());
        }
    }

    private List<ScheduleProposalItemResponse> loadProposalItems(Long proposalId) {
        List<ItemRow> rows =
                jdbc.query(
                        "select id, sort_order, source_day_id, scheduled_date, scheduled_time, title, applied_schedule_id from workout_schedule_proposal_items where proposal_id = ? order by sort_order",
                        (rs, row) ->
                                new ItemRow(
                                        rs.getLong("id"),
                                        rs.getInt("sort_order"),
                                        rs.getObject("source_day_id", Long.class),
                                        rs.getDate("scheduled_date").toLocalDate(),
                                        rs.getTime("scheduled_time") == null
                                                ? null
                                                : rs.getTime("scheduled_time").toLocalTime(),
                                        rs.getString("title"),
                                        rs.getObject("applied_schedule_id", Long.class)),
                        proposalId);
        if (rows.isEmpty()) {
            return List.of();
        }
        List<Long> ids = rows.stream().map(ItemRow::id).toList();
        String placeholders = String.join(",", Collections.nCopies(ids.size(), "?"));
        Map<Long, List<ScheduleExercisePlan>> exercises = new HashMap<>();
        jdbc.query(
                "select wspe.proposal_item_id, wspe.exercise_id, e.name as exercise_name, (select mg.name from exercise_muscle_groups emg join muscle_groups mg on mg.id = emg.muscle_group_id where emg.exercise_id = e.id and emg.role = 'PRIMARY' order by mg.name limit 1) as primary_muscle, wspe.sort_order, wspe.target_sets, wspe.target_reps_min, wspe.target_reps_max, wspe.target_duration_seconds, wspe.rest_seconds, wspe.note from workout_schedule_proposal_exercises wspe join exercises e on e.id = wspe.exercise_id where wspe.proposal_item_id in ("
                        + placeholders
                        + ") order by wspe.sort_order",
                (RowCallbackHandler)
                        rs ->
                                exercises
                                        .computeIfAbsent(
                                                rs.getLong("proposal_item_id"),
                                                ignored -> new ArrayList<>())
                                        .add(mapExercise(rs)),
                ids.toArray());
        return rows.stream()
                .map(
                        row ->
                                new ScheduleProposalItemResponse(
                                        row.id(),
                                        row.sortOrder(),
                                        row.sourceDayId(),
                                        row.date(),
                                        row.time(),
                                        row.title(),
                                        row.appliedScheduleId(),
                                        exercises.getOrDefault(row.id(), List.of())))
                .toList();
    }

    private List<WorkoutScheduleResponse> loadAppliedSchedules(Long userId, Long proposalId) {
        return jdbc
                .queryForList(
                        "select applied_schedule_id from workout_schedule_proposal_items where proposal_id = ? and applied_schedule_id is not null order by sort_order",
                        Long.class,
                        proposalId)
                .stream()
                .map(id -> schedules.getSchedule(userId, id))
                .toList();
    }

    private RequestContext validateBaseRequest(CreateScheduleProposalRequest request) {
        if (request == null) {
            throw validation("proposal", "REQUIRED", "Proposal request is required");
        }
        String sourceType = normalize(request.sourceType());
        String scope = normalize(request.scope());
        if (!SOURCE_TYPES.contains(sourceType)) {
            throw validation("sourceType", "INVALID", "Unsupported schedule source type");
        }
        if (!SCOPES.contains(scope)) {
            throw validation("scope", "INVALID", "Unsupported schedule scope");
        }
        return new RequestContext(sourceType, scope);
    }

    private void validateExercises(List<ScheduleExercisePlan> exercises, String field) {
        Set<Integer> orders = new HashSet<>();
        for (int index = 0; index < exercises.size(); index++) {
            ScheduleExercisePlan exercise = exercises.get(index);
            String prefix = field + "[" + index + "]";
            if (exercise == null
                    || exercise.exerciseId() == null
                    || exercise.sortOrder() == null
                    || exercise.sortOrder() < 1
                    || exercise.targetSets() == null
                    || exercise.targetSets() < 1) {
                throw validation(prefix, "INVALID", "Exercise id, order and sets are required");
            }
            if (!orders.add(exercise.sortOrder())) {
                throw validation(prefix + ".sortOrder", "DUPLICATE", "Sort order must be unique");
            }
            if (exercise.targetRepsMin() != null
                    && exercise.targetRepsMax() != null
                    && exercise.targetRepsMin() > exercise.targetRepsMax()) {
                throw validation(prefix, "INVALID_REPS", "Minimum reps cannot exceed maximum reps");
            }
            Integer count =
                    jdbc.queryForObject(
                            "select count(*) from exercises where id = ? and visibility = 'PUBLIC' and deleted_at is null",
                            Integer.class,
                            exercise.exerciseId());
            if (count == null || count == 0) {
                throw new ApiException(
                        ApiErrorCode.RESOURCE_HIDDEN,
                        "Exercise is not selectable: " + exercise.exerciseId());
            }
        }
    }

    private String effectiveStatus(ProposalRow proposal) {
        if ("PENDING".equals(proposal.status())
                && proposal.expiresAt().isBefore(OffsetDateTime.now(ZoneOffset.UTC))) {
            return "EXPIRED";
        }
        return proposal.status();
    }

    private static ApiValidationException validation(String field, String code, String message) {
        return new ApiValidationException(List.of(new FieldViolation(field, code, message)));
    }

    private static String normalize(String value) {
        return value == null ? "" : value.trim().toUpperCase();
    }

    private static OffsetDateTime toOffsetDateTime(Timestamp timestamp) {
        return timestamp == null ? null : timestamp.toInstant().atOffset(ZoneOffset.UTC);
    }

    private record RequestContext(String sourceType, String scope) {}

    private record SourceMetadata(Long id, Integer version) {}

    private record PlanDayBase(Long id, Integer dayNumber, String name) {}

    private record PlanDay(
            Long id, Integer dayNumber, String name, List<ScheduleExercisePlan> exercises) {}

    private record ProposedItem(
            Long sourceDayId,
            LocalDate date,
            LocalTime time,
            String title,
            List<ScheduleExercisePlan> exercises) {}

    private record ProposalRow(
            Long id,
            String sourceType,
            String scope,
            Long sourceId,
            Integer sourceVersion,
            String status,
            OffsetDateTime expiresAt,
            OffsetDateTime appliedAt) {}

    private record ItemRow(
            Long id,
            Integer sortOrder,
            Long sourceDayId,
            LocalDate date,
            LocalTime time,
            String title,
            Long appliedScheduleId) {}
}
