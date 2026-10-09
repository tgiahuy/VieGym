package com.viegym.admin.audit.application;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.viegym.common.api.PageResponse;
import com.viegym.common.error.ApiErrorCode;
import com.viegym.common.error.ApiException;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.OffsetDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AdminAuditService {
    private static final Set<String> SECRET_WORDS =
            Set.of(
                    "password",
                    "token",
                    "otp",
                    "apikey",
                    "api_key",
                    "secret",
                    "presignedurl",
                    "rawcontext");

    private final JdbcTemplate jdbc;
    private final ObjectMapper mapper;

    public AdminAuditService(JdbcTemplate jdbc, ObjectMapper mapper) {
        this.jdbc = jdbc;
        this.mapper = mapper;
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void record(
            Long actorId,
            String actorRole,
            String action,
            String targetType,
            Object targetId,
            String result,
            Map<String, ?> metadata) {
        jdbc.update(
                "insert into audit_logs (actor_user_id, actor_role, action, target_type, target_id, result, correlation_id, metadata) values (?, ?, ?, ?, ?, ?, ?, ?::jsonb)",
                actorId,
                actorRole,
                action,
                targetType,
                targetId == null ? null : targetId.toString(),
                result,
                com.viegym.observability.CorrelationId.currentOrCreate(),
                json(redact(metadata)));
    }

    @Transactional(readOnly = true)
    public PageResponse<AuditEvent> list(
            Long actorId,
            String action,
            String targetType,
            String targetId,
            String result,
            String correlationId,
            OffsetDateTime from,
            OffsetDateTime to,
            Pageable pageable) {
        StringBuilder where = new StringBuilder("where 1=1 ");
        var params = new java.util.ArrayList<>();
        add(where, params, actorId, "and a.actor_user_id = ? ");
        add(where, params, normalized(action), "and a.action = ? ");
        add(where, params, normalized(targetType), "and a.target_type = ? ");
        add(where, params, targetId, "and a.target_id = ? ");
        add(where, params, normalized(result), "and a.result = ? ");
        add(where, params, correlationId, "and a.correlation_id = ? ");
        add(where, params, from, "and a.created_at >= ? ");
        add(where, params, to, "and a.created_at <= ? ");
        long total =
                jdbc.queryForObject(
                        "select count(*) from audit_logs a " + where, Long.class, params.toArray());
        params.add(pageable.getPageSize());
        params.add(pageable.getOffset());
        List<AuditEvent> events =
                jdbc.query(
                        "select a.*, u.email actor_email from audit_logs a left join users u on u.id = a.actor_user_id "
                                + where
                                + "order by a.created_at desc, a.id desc limit ? offset ?",
                        this::map,
                        params.toArray());
        return PageResponse.from(new PageImpl<>(events, pageable, total));
    }

    @Transactional(readOnly = true)
    public AuditEvent get(long id) {
        List<AuditEvent> rows =
                jdbc.query(
                        "select a.*, u.email actor_email from audit_logs a left join users u on u.id = a.actor_user_id where a.id = ?",
                        this::map,
                        id);
        if (rows.isEmpty())
            throw new ApiException(ApiErrorCode.RESOURCE_NOT_FOUND, "Audit event not found");
        return rows.getFirst();
    }

    private AuditEvent map(ResultSet rs, int row) throws SQLException {
        return new AuditEvent(
                rs.getLong("id"),
                (Long) rs.getObject("actor_user_id"),
                rs.getString("actor_email"),
                rs.getString("actor_role"),
                rs.getString("action"),
                rs.getString("target_type"),
                rs.getString("target_id"),
                rs.getString("result"),
                rs.getString("correlation_id"),
                readMap(rs.getString("metadata")),
                rs.getObject("created_at", OffsetDateTime.class));
    }

    private Map<String, Object> redact(Map<String, ?> input) {
        Map<String, Object> safe = new LinkedHashMap<>();
        if (input == null) return safe;
        input.forEach(
                (key, value) -> safe.put(key, isSecret(key) ? "[REDACTED]" : sanitize(value)));
        return safe;
    }

    private Object sanitize(Object value) {
        if (!(value instanceof Map<?, ?> nested)) return value;
        Map<String, Object> safe = new LinkedHashMap<>();
        nested.forEach(
                (key, item) -> {
                    String name = String.valueOf(key);
                    safe.put(name, isSecret(name) ? "[REDACTED]" : sanitize(item));
                });
        return safe;
    }

    private boolean isSecret(String key) {
        String compact = key.toLowerCase(Locale.ROOT).replaceAll("[^a-z0-9_]", "");
        return SECRET_WORDS.stream().anyMatch(compact::contains);
    }

    private String json(Object value) {
        try {
            return mapper.writeValueAsString(value);
        } catch (JsonProcessingException e) {
            throw new IllegalArgumentException("Cannot serialize audit metadata", e);
        }
    }

    @SuppressWarnings("unchecked")
    private Map<String, Object> readMap(String json) {
        try {
            return mapper.readValue(json, Map.class);
        } catch (JsonProcessingException e) {
            return Map.of("unavailable", true);
        }
    }

    private static String normalized(String value) {
        return value == null || value.isBlank() ? null : value.trim().toUpperCase(Locale.ROOT);
    }

    private static void add(StringBuilder sql, List<Object> params, Object value, String clause) {
        if (value != null) {
            sql.append(clause);
            params.add(value);
        }
    }

    public record AuditEvent(
            long id,
            Long actorId,
            String actorEmail,
            String actorRole,
            String action,
            String targetType,
            String targetId,
            String result,
            String correlationId,
            Map<String, Object> metadata,
            OffsetDateTime createdAt) {}
}
