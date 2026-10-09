package com.viegym.notification.application;

import com.viegym.common.api.PageResponse;
import com.viegym.common.error.ApiErrorCode;
import com.viegym.common.error.ApiException;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.Clock;
import java.time.LocalTime;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

@Service
public class NotificationService {
    private final JdbcTemplate jdbc;
    private final Clock clock;

    public NotificationService(JdbcTemplate jdbc, Clock clock) {
        this.jdbc = jdbc;
        this.clock = clock;
    }

    @Transactional(readOnly = true)
    public PageResponse<NotificationItem> list(
            long userId, String status, String type, Pageable page) {
        StringBuilder where = new StringBuilder("where user_id=? and deleted_at is null ");
        List<Object> params = new ArrayList<>();
        params.add(userId);
        if (status != null && !status.isBlank()) {
            where.append("and status=? ");
            params.add(status.toUpperCase(Locale.ROOT));
        }
        if (type != null && !type.isBlank()) {
            where.append("and type=? ");
            params.add(type.toUpperCase(Locale.ROOT));
        }
        long total =
                jdbc.queryForObject(
                        "select count(*) from notifications " + where,
                        Long.class,
                        params.toArray());
        params.add(page.getPageSize());
        params.add(page.getOffset());
        List<NotificationItem> rows =
                jdbc.query(
                        "select * from notifications "
                                + where
                                + "order by coalesce(sent_at, scheduled_at) desc, id desc limit ? offset ?",
                        this::map,
                        params.toArray());
        return PageResponse.from(new PageImpl<>(rows, page, total));
    }

    @Transactional(readOnly = true)
    public long unreadCount(long userId) {
        return jdbc.queryForObject(
                "select count(*) from notifications where user_id=? and status='SENT' and deleted_at is null",
                Long.class,
                userId);
    }

    @Transactional
    public NotificationItem read(long userId, long id) {
        int found =
                jdbc.update(
                        "update notifications set status=case when status='SENT' then 'READ' else status end, read_at=case when status='SENT' then current_timestamp else read_at end, updated_at=current_timestamp where id=? and user_id=? and deleted_at is null",
                        id,
                        userId);
        if (found == 0)
            throw new ApiException(ApiErrorCode.RESOURCE_NOT_FOUND, "Notification not found");
        return get(userId, id);
    }

    @Transactional
    public ReadAllResult readAll(long userId) {
        int count =
                jdbc.update(
                        "update notifications set status='READ', read_at=current_timestamp, updated_at=current_timestamp where user_id=? and status='SENT' and deleted_at is null",
                        userId);
        return new ReadAllResult(count, unreadCount(userId));
    }

    @Transactional
    public void delete(long userId, long id) {
        // Idempotent for owned rows, while never revealing rows owned by somebody else.
        Integer owned =
                jdbc.queryForObject(
                        "select count(*) from notifications where id=? and user_id=?",
                        Integer.class,
                        id,
                        userId);
        if (owned == null || owned == 0)
            throw new ApiException(ApiErrorCode.RESOURCE_NOT_FOUND, "Notification not found");
        jdbc.update(
                "update notifications set deleted_at=coalesce(deleted_at,current_timestamp), updated_at=current_timestamp where id=? and user_id=?",
                id,
                userId);
    }

    @Transactional(readOnly = true)
    public Preference preference(long userId) {
        ensureUser(userId);
        List<Preference> rows =
                jdbc.query(
                        "select * from notification_preferences where user_id=?",
                        this::mapPreference,
                        userId);
        return rows.isEmpty() ? Preference.defaults(userId) : rows.getFirst();
    }

    @Transactional
    public Preference updatePreference(long userId, PreferenceRequest request) {
        ensureUser(userId);
        validate(request);
        jdbc.update(
                "insert into notification_preferences (user_id, workout_enabled, meal_enabled, weight_enabled, recommendation_enabled, weekly_review_enabled, quiet_hours_start, quiet_hours_end, timezone) values (?,?,?,?,?,?,?,?,?) on conflict (user_id) do update set workout_enabled=excluded.workout_enabled, meal_enabled=excluded.meal_enabled, weight_enabled=excluded.weight_enabled, recommendation_enabled=excluded.recommendation_enabled, weekly_review_enabled=excluded.weekly_review_enabled, quiet_hours_start=excluded.quiet_hours_start, quiet_hours_end=excluded.quiet_hours_end, timezone=excluded.timezone, updated_at=current_timestamp",
                userId,
                request.workoutEnabled(),
                request.mealEnabled(),
                request.weightEnabled(),
                request.recommendationEnabled(),
                request.weeklyReviewEnabled(),
                request.quietHoursStart(),
                request.quietHoursEnd(),
                request.timezone());
        return preference(userId);
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public boolean schedule(
            long userId,
            String type,
            String title,
            String content,
            OffsetDateTime when,
            String sourceType,
            String sourceId,
            String deepLink,
            String idempotencyKey) {
        try {
            Preference p = preference(userId);
            String normalized = type.toUpperCase(Locale.ROOT);
            if (!enabled(p, normalized)) return false;
            if (normalized.equals("AI_RECOMMENDATION") || normalized.equals("WEEKLY_REVIEW"))
                requireAiConsent(userId);
            OffsetDateTime adjusted =
                    outsideQuietHours(when == null ? OffsetDateTime.now(clock) : when, p);
            jdbc.update(
                    "insert into notifications (user_id, type, title, content, status, scheduled_at, source_type, source_id, deep_link, idempotency_key) values (?,?,?,?, 'SCHEDULED',?,?,?,?,?) on conflict (user_id,idempotency_key) do nothing",
                    userId,
                    normalized,
                    trim(title, 180),
                    trim(content, 1000),
                    adjusted,
                    sourceType,
                    sourceId,
                    deepLink,
                    trim(idempotencyKey, 150));
            return true;
        } catch (ApiException | DuplicateKeyException ignored) {
            return false;
        }
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public int dispatchDue() {
        return jdbc.update(
                "update notifications set status='SENT', sent_at=current_timestamp, updated_at=current_timestamp where status='SCHEDULED' and scheduled_at<=current_timestamp and deleted_at is null");
    }

    private NotificationItem get(long userId, long id) {
        List<NotificationItem> rows =
                jdbc.query(
                        "select * from notifications where id=? and user_id=? and deleted_at is null",
                        this::map,
                        id,
                        userId);
        if (rows.isEmpty())
            throw new ApiException(ApiErrorCode.RESOURCE_NOT_FOUND, "Notification not found");
        return rows.getFirst();
    }

    private NotificationItem map(ResultSet rs, int row) throws SQLException {
        return new NotificationItem(
                rs.getLong("id"),
                rs.getString("type"),
                rs.getString("title"),
                rs.getString("content"),
                rs.getString("status"),
                rs.getObject("scheduled_at", OffsetDateTime.class),
                rs.getObject("sent_at", OffsetDateTime.class),
                rs.getObject("read_at", OffsetDateTime.class),
                rs.getString("source_type"),
                rs.getString("source_id"),
                rs.getString("deep_link"));
    }

    private Preference mapPreference(ResultSet rs, int row) throws SQLException {
        return new Preference(
                rs.getLong("user_id"),
                rs.getBoolean("workout_enabled"),
                rs.getBoolean("meal_enabled"),
                rs.getBoolean("weight_enabled"),
                rs.getBoolean("recommendation_enabled"),
                rs.getBoolean("weekly_review_enabled"),
                rs.getObject("quiet_hours_start", LocalTime.class),
                rs.getObject("quiet_hours_end", LocalTime.class),
                rs.getString("timezone"));
    }

    private void ensureUser(long id) {
        Integer count =
                jdbc.queryForObject(
                        "select count(*) from users where id=? and deleted_at is null",
                        Integer.class,
                        id);
        if (count == null || count == 0)
            throw new ApiException(ApiErrorCode.RESOURCE_NOT_FOUND, "User not found");
    }

    private void requireAiConsent(long id) {
        Integer count =
                jdbc.queryForObject(
                        "select count(*) from ai_consents where user_id=? and mode='ENABLED'",
                        Integer.class,
                        id);
        if (count == null || count == 0)
            throw new ApiException(ApiErrorCode.AI_CONSENT_REQUIRED, "AI consent is required");
    }

    private static boolean enabled(Preference p, String type) {
        return switch (type) {
            case "WORKOUT_REMINDER" -> p.workoutEnabled();
            case "MEAL_REMINDER" -> p.mealEnabled();
            case "WEIGHT_REMINDER" -> p.weightEnabled();
            case "AI_RECOMMENDATION" -> p.recommendationEnabled();
            case "WEEKLY_REVIEW" -> p.weeklyReviewEnabled();
            case "SYSTEM" -> true;
            default -> false;
        };
    }

    private static void validate(PreferenceRequest r) {
        if (r == null)
            throw new ApiException(ApiErrorCode.VALIDATION_ERROR, "Preference is required");
        try {
            ZoneId.of(r.timezone());
        } catch (Exception e) {
            throw new ApiException(ApiErrorCode.VALIDATION_ERROR, "Timezone is invalid");
        }
        if ((r.quietHoursStart() == null) != (r.quietHoursEnd() == null))
            throw new ApiException(
                    ApiErrorCode.VALIDATION_ERROR, "Both quiet hour boundaries are required");
    }

    private static OffsetDateTime outsideQuietHours(OffsetDateTime instant, Preference p) {
        if (p.quietHoursStart() == null) return instant;
        ZoneId zone = ZoneId.of(p.timezone());
        ZonedDateTime local = instant.atZoneSameInstant(zone);
        LocalTime t = local.toLocalTime();
        boolean overnight = p.quietHoursStart().isAfter(p.quietHoursEnd());
        boolean quiet =
                overnight
                        ? (t.compareTo(p.quietHoursStart()) >= 0 || t.isBefore(p.quietHoursEnd()))
                        : (t.compareTo(p.quietHoursStart()) >= 0 && t.isBefore(p.quietHoursEnd()));
        if (!quiet) return instant;
        ZonedDateTime end = local.with(p.quietHoursEnd());
        if (overnight && t.compareTo(p.quietHoursStart()) >= 0) end = end.plusDays(1);
        return end.toOffsetDateTime();
    }

    private static String trim(String s, int max) {
        if (s == null || s.isBlank())
            throw new ApiException(ApiErrorCode.VALIDATION_ERROR, "Notification text is required");
        return s.length() > max ? s.substring(0, max) : s;
    }

    public record NotificationItem(
            long id,
            String type,
            String title,
            String content,
            String status,
            OffsetDateTime scheduledAt,
            OffsetDateTime sentAt,
            OffsetDateTime readAt,
            String sourceType,
            String sourceId,
            String deepLink) {}

    public record ReadAllResult(int updatedCount, long unreadCount) {}

    public record Preference(
            long userId,
            boolean workoutEnabled,
            boolean mealEnabled,
            boolean weightEnabled,
            boolean recommendationEnabled,
            boolean weeklyReviewEnabled,
            LocalTime quietHoursStart,
            LocalTime quietHoursEnd,
            String timezone) {
        static Preference defaults(long id) {
            return new Preference(
                    id, true, true, true, false, false, null, null, "Asia/Ho_Chi_Minh");
        }
    }

    public record PreferenceRequest(
            boolean workoutEnabled,
            boolean mealEnabled,
            boolean weightEnabled,
            boolean recommendationEnabled,
            boolean weeklyReviewEnabled,
            LocalTime quietHoursStart,
            LocalTime quietHoursEnd,
            String timezone) {}
}
