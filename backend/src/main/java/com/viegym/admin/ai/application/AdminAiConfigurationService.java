package com.viegym.admin.ai.application;

import com.viegym.admin.ai.api.AdminAiDtos.AiMetrics;
import com.viegym.admin.ai.api.AdminAiDtos.CreatePromptRequest;
import com.viegym.admin.ai.api.AdminAiDtos.PromptTemplate;
import com.viegym.admin.ai.api.AdminAiDtos.SafetyRule;
import com.viegym.admin.audit.application.AdminAuditService;
import com.viegym.ai.infrastructure.AiProviderClient;
import com.viegym.ai.infrastructure.AiProviderClient.ProviderStatus;
import com.viegym.common.error.ApiErrorCode;
import com.viegym.common.error.ApiException;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AdminAiConfigurationService {
    private static final Set<String> USE_CASES =
            Set.of("WORKOUT_ENGINE", "NUTRITION_ENGINE", "CHAT_COACH", "SAFETY_FILTER");

    private final JdbcTemplate jdbc;
    private final AdminAuditService audit;
    private final AiProviderClient provider;

    public AdminAiConfigurationService(
            JdbcTemplate jdbc, AdminAuditService audit, AiProviderClient provider) {
        this.jdbc = jdbc;
        this.audit = audit;
        this.provider = provider;
    }

    @Transactional(readOnly = true)
    public List<PromptTemplate> prompts() {
        return jdbc.query(
                "select t.*, v.version_label, u.email author_email from ai_prompt_templates t "
                        + "left join ai_prompt_versions v on v.id=t.active_version_id "
                        + "left join users u on u.id=t.updated_by order by t.id",
                this::mapPrompt);
    }

    @Transactional(readOnly = true)
    public PromptTemplate prompt(long id) {
        List<PromptTemplate> rows =
                jdbc.query(
                        "select t.*, v.version_label, u.email author_email from ai_prompt_templates t "
                                + "left join ai_prompt_versions v on v.id=t.active_version_id "
                                + "left join users u on u.id=t.updated_by where t.id=?",
                        this::mapPrompt,
                        id);
        if (rows.isEmpty())
            throw new ApiException(ApiErrorCode.RESOURCE_NOT_FOUND, "Prompt template not found");
        return rows.getFirst();
    }

    @Transactional
    public PromptTemplate create(long adminId, CreatePromptRequest request) {
        String useCase = upper(request.useCase());
        if (!USE_CASES.contains(useCase)) invalid("Unsupported AI use case");
        String content = required(request.content(), "Prompt content");
        KeyHolder key = new GeneratedKeyHolder();
        try {
            jdbc.update(
                    connection -> {
                        var statement =
                                connection.prepareStatement(
                                        "insert into ai_prompt_templates (code,use_case,title,description,model_name,fallback_model_name,draft_content,created_by,updated_by) values (?,?,?,?,?,?,?,?,?)",
                                        Statement.RETURN_GENERATED_KEYS);
                        statement.setString(1, required(request.code(), "Prompt code"));
                        statement.setString(2, useCase);
                        statement.setString(3, required(request.title(), "Prompt title"));
                        statement.setString(4, required(request.description(), "Description"));
                        statement.setString(5, required(request.model(), "Model"));
                        statement.setString(6, trimToNull(request.fallbackModel()));
                        statement.setString(7, content);
                        statement.setLong(8, adminId);
                        statement.setLong(9, adminId);
                        return statement;
                    },
                    key);
        } catch (DuplicateKeyException exception) {
            throw new ApiException(
                    ApiErrorCode.INVALID_STATE_TRANSITION,
                    "Prompt code or use case already exists");
        }
        long id = key.getKey().longValue();
        audit.record(
                adminId,
                "ADMIN",
                "AI_PROMPT_CREATE",
                "AI_PROMPT_TEMPLATE",
                id,
                "SUCCESS",
                Map.of("useCase", useCase));
        return prompt(id);
    }

    @Transactional
    public PromptTemplate saveDraft(long adminId, long id, String content, Long expectedRevision) {
        String value = required(content, "Prompt content");
        long expected = expectedRevision == null ? -1 : expectedRevision;
        int updated =
                jdbc.update(
                        "update ai_prompt_templates set draft_content=?, draft_revision=draft_revision+1, updated_by=?, updated_at=current_timestamp where id=? and (? < 0 or draft_revision=?)",
                        value,
                        adminId,
                        id,
                        expected,
                        expected);
        if (updated == 0) conflictOrMissing(id);
        audit.record(
                adminId,
                "ADMIN",
                "AI_PROMPT_DRAFT_SAVE",
                "AI_PROMPT_TEMPLATE",
                id,
                "SUCCESS",
                Map.of("previousRevision", expected));
        return prompt(id);
    }

    @Transactional
    public PromptTemplate publish(long adminId, long id, Long expectedRevision) {
        PromptTemplate current = prompt(id);
        if (expectedRevision != null && current.draftRevision() != expectedRevision) {
            throw new ApiException(
                    ApiErrorCode.INVALID_STATE_TRANSITION,
                    "Prompt draft changed; reload before publishing");
        }
        Integer next =
                jdbc.queryForObject(
                        "select coalesce(max(version_no),0)+1 from ai_prompt_versions where template_id=?",
                        Integer.class,
                        id);
        String label = "v1.0." + Math.max(0, next - 1);
        KeyHolder key = new GeneratedKeyHolder();
        jdbc.update(
                connection -> {
                    var statement =
                            connection.prepareStatement(
                                    "insert into ai_prompt_versions (template_id,version_no,version_label,content,model_name,published_by) select id,?,?,?,?,? from ai_prompt_templates where id=?",
                                    Statement.RETURN_GENERATED_KEYS);
                    statement.setInt(1, next);
                    statement.setString(2, label);
                    statement.setString(3, current.content());
                    statement.setString(4, current.model());
                    statement.setLong(5, adminId);
                    statement.setLong(6, id);
                    return statement;
                },
                key);
        long versionId = key.getKey().longValue();
        jdbc.update(
                "update ai_prompt_templates set active_version_id=?, published_revision=draft_revision, updated_by=?, updated_at=current_timestamp where id=?",
                versionId,
                adminId,
                id);
        audit.record(
                adminId,
                "ADMIN",
                "AI_PROMPT_PUBLISH",
                "AI_PROMPT_TEMPLATE",
                id,
                "SUCCESS",
                Map.of("version", label, "versionId", versionId));
        return prompt(id);
    }

    @Transactional(readOnly = true)
    public List<SafetyRule> safetyRules() {
        return jdbc.query("select * from ai_safety_rules order by code", this::safetyRule);
    }

    @Transactional
    public SafetyRule updateSafetyRule(
            long adminId, long id, Boolean active, Long expectedVersion) {
        if (active == null) invalid("Safety rule active state is required");
        long expected = expectedVersion == null ? -1 : expectedVersion;
        int updated =
                jdbc.update(
                        "update ai_safety_rules set is_active=?, version=version+1, updated_by=?, updated_at=current_timestamp where id=? and (? < 0 or version=?)",
                        active,
                        adminId,
                        id,
                        expected,
                        expected);
        if (updated == 0) {
            throw new ApiException(
                    ApiErrorCode.INVALID_STATE_TRANSITION,
                    "Safety rule changed or no longer exists");
        }
        audit.record(
                adminId,
                "ADMIN",
                "AI_SAFETY_RULE_UPDATE",
                "AI_SAFETY_RULE",
                id,
                "SUCCESS",
                Map.of("active", active, "previousVersion", expected));
        return jdbc.query("select * from ai_safety_rules where id=?", this::safetyRule, id)
                .getFirst();
    }

    @Transactional(readOnly = true)
    public AiMetrics metrics() {
        Map<String, Object> totals =
                jdbc.queryForMap(
                        "select count(*) total, count(*) filter (where status='SUCCEEDED') succeeded, "
                                + "count(*) filter (where status='FAILED') failed, count(*) filter (where status='BLOCKED') blocked, "
                                + "avg(extract(epoch from (completed_at-created_at))*1000) filter (where completed_at is not null) latency "
                                + "from ai_requests where created_at >= current_timestamp - interval '24 hours'");
        ProviderStatus status;
        try {
            status = provider.status();
        } catch (RuntimeException exception) {
            status = new ProviderStatus("unavailable", "unavailable", false);
        }
        long total = ((Number) totals.get("total")).longValue();
        long succeeded = ((Number) totals.get("succeeded")).longValue();
        long failed = ((Number) totals.get("failed")).longValue();
        long blocked = ((Number) totals.get("blocked")).longValue();
        Number latency = (Number) totals.get("latency");
        List<String> warnings =
                "mock".equalsIgnoreCase(status.provider())
                        ? List.of("AI service is using the mock provider")
                        : List.of();
        return new AiMetrics(
                status.provider(),
                status.model(),
                status.reachable(),
                total,
                succeeded,
                failed,
                blocked,
                latency == null ? null : Math.round(latency.doubleValue() * 10.0) / 10.0,
                warnings);
    }

    private PromptTemplate mapPrompt(ResultSet rs, int row) throws SQLException {
        boolean hasActive = rs.getObject("active_version_id") != null;
        return new PromptTemplate(
                rs.getLong("id"),
                rs.getString("code"),
                rs.getString("use_case"),
                rs.getString("title"),
                rs.getString("description"),
                hasActive ? rs.getString("version_label") : "Chưa phát hành",
                hasActive && rs.getLong("draft_revision") == rs.getLong("published_revision")
                        ? "production"
                        : "draft",
                rs.getString("model_name"),
                rs.getString("fallback_model_name"),
                rs.getString("draft_content"),
                rs.getLong("draft_revision"),
                rs.getObject("updated_at", java.time.OffsetDateTime.class),
                rs.getString("author_email") == null ? "System" : rs.getString("author_email"));
    }

    private SafetyRule safetyRule(ResultSet rs, int row) throws SQLException {
        return new SafetyRule(
                rs.getLong("id"),
                rs.getString("code"),
                rs.getString("name"),
                rs.getString("category").toLowerCase(Locale.ROOT),
                rs.getString("severity").toLowerCase(Locale.ROOT),
                rs.getString("description"),
                rs.getString("action"),
                rs.getBoolean("is_active"),
                rs.getLong("version"),
                rs.getObject("updated_at", java.time.OffsetDateTime.class));
    }

    private void conflictOrMissing(long id) {
        if (jdbc.queryForObject(
                        "select count(*) from ai_prompt_templates where id=?", Integer.class, id)
                == 0) {
            throw new ApiException(ApiErrorCode.RESOURCE_NOT_FOUND, "Prompt template not found");
        }
        throw new ApiException(
                ApiErrorCode.INVALID_STATE_TRANSITION,
                "Prompt draft changed; reload before saving");
    }

    private static String required(String value, String field) {
        if (value == null || value.isBlank()) invalid(field + " is required");
        String result = value.trim();
        if (result.length() > 16000) invalid(field + " is too long");
        return result;
    }

    private static String trimToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }

    private static String upper(String value) {
        return value == null ? "" : value.trim().toUpperCase(Locale.ROOT);
    }

    private static void invalid(String message) {
        throw new ApiException(ApiErrorCode.VALIDATION_ERROR, message);
    }
}
