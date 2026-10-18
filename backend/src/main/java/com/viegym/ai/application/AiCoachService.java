package com.viegym.ai.application;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.viegym.ai.api.AiDtos;
import com.viegym.ai.infrastructure.AiProviderClient;
import com.viegym.ai.infrastructure.AiProviderClient.ProviderRequest;
import com.viegym.ai.infrastructure.AiProviderClient.ProviderResponse;
import com.viegym.common.error.ApiErrorCode;
import com.viegym.common.error.ApiException;
import com.viegym.nutrition.api.MealEntryRequest;
import com.viegym.nutrition.api.NutritionDtos;
import com.viegym.nutrition.application.NutritionService;
import com.viegym.workout.planning.api.ApplyScheduleProposalResponse;
import com.viegym.workout.planning.api.CreateScheduleProposalRequest;
import com.viegym.workout.planning.api.ScheduleExercisePlan;
import com.viegym.workout.planning.api.ScheduleProposalItemRequest;
import com.viegym.workout.planning.api.ScheduleProposalResponse;
import com.viegym.workout.planning.application.WorkoutSchedulePlanningService;
import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.Date;
import java.sql.Timestamp;
import java.time.Clock;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.HexFormat;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionTemplate;

@Service
public class AiCoachService {
    private static final String CONSENT_VERSION = "v1.0";
    private static final Set<String> MODES = Set.of("ENABLED", "DISABLED");
    private static final Set<String> CONVERSATION_MODES =
            Set.of("GENERAL_KNOWLEDGE", "PERSONALIZED");
    private static final Set<String> TYPES =
            Set.of("WORKOUT", "NUTRITION", "HEALTH", "GENERAL_ADVICE");
    private static final Set<String> PRIORITIES = Set.of("LOW", "MEDIUM", "HIGH");
    private static final Set<String> ACTIONS =
            Set.of("NONE", "ADD_MEAL_ENTRY_PROPOSAL", "CREATE_WORKOUT_SCHEDULE_PROPOSAL");

    private final JdbcTemplate jdbc;
    private final ObjectMapper objectMapper;
    private final Clock clock;
    private final AiContextBuilder contextBuilder;
    private final AiProviderClient provider;
    private final AiPromptConfigurationService promptConfiguration;
    private final NutritionService nutrition;
    private final WorkoutSchedulePlanningService workoutPlanning;
    private final TransactionTemplate transactions;

    public AiCoachService(
            JdbcTemplate jdbc,
            ObjectMapper objectMapper,
            Clock clock,
            AiContextBuilder contextBuilder,
            AiProviderClient provider,
            AiPromptConfigurationService promptConfiguration,
            NutritionService nutrition,
            WorkoutSchedulePlanningService workoutPlanning,
            PlatformTransactionManager transactionManager) {
        this.jdbc = jdbc;
        this.objectMapper = objectMapper;
        this.clock = clock;
        this.contextBuilder = contextBuilder;
        this.provider = provider;
        this.promptConfiguration = promptConfiguration;
        this.nutrition = nutrition;
        this.workoutPlanning = workoutPlanning;
        this.transactions = new TransactionTemplate(transactionManager);
    }

    @Transactional(readOnly = true)
    public AiDtos.Consent getConsent(Long userId) {
        requireUser(userId);
        List<AiDtos.Consent> rows =
                jdbc.query(
                        "select mode, consent_version, accepted_at, updated_at from ai_consents where user_id = ?",
                        (rs, row) ->
                                new AiDtos.Consent(
                                        rs.getString("mode"),
                                        rs.getString("consent_version"),
                                        time(rs.getTimestamp("accepted_at")),
                                        time(rs.getTimestamp("updated_at"))),
                        userId);
        return rows.isEmpty()
                ? new AiDtos.Consent("DISABLED", CONSENT_VERSION, null, OffsetDateTime.now(clock))
                : rows.getFirst();
    }

    @Transactional
    public AiDtos.Consent updateConsent(Long userId, AiDtos.UpdateConsent request) {
        requireUser(userId);
        String mode = request.mode().trim().toUpperCase();
        if (!MODES.contains(mode)) invalid("mode", "Consent mode is invalid");
        if (!CONSENT_VERSION.equals(request.consentVersion())) {
            invalid("consentVersion", "The current consent version is required");
        }
        String source = request.source().trim().toUpperCase();
        if (!Set.of("SETTINGS", "ONBOARDING", "AI_TAB").contains(source)) {
            invalid("source", "Consent source is invalid");
        }
        AiDtos.Consent previous = getConsent(userId);
        OffsetDateTime now = OffsetDateTime.now(clock);
        jdbc.update(
                "insert into ai_consents (user_id, mode, consent_version, accepted_at, updated_at) "
                        + "values (?, ?, ?, ?, ?) on conflict (user_id) do update set mode = excluded.mode, "
                        + "consent_version = excluded.consent_version, accepted_at = excluded.accepted_at, "
                        + "updated_at = excluded.updated_at",
                userId,
                mode,
                CONSENT_VERSION,
                "ENABLED".equals(mode) ? Timestamp.from(now.toInstant()) : null,
                Timestamp.from(now.toInstant()));
        jdbc.update(
                "insert into ai_consent_history (user_id, previous_mode, new_mode, consent_version, source, changed_at) values (?, ?, ?, ?, ?, ?)",
                userId,
                previous.mode(),
                mode,
                CONSENT_VERSION,
                source,
                Timestamp.from(now.toInstant()));
        audit(
                userId,
                "AI_CONSENT_CHANGED",
                "AI_CONSENT",
                String.valueOf(userId),
                Map.of("mode", mode));
        return getConsent(userId);
    }

    @Transactional
    public AiDtos.Conversation createConversation(Long userId, AiDtos.CreateConversation request) {
        requireUser(userId);
        String requested = request.requestedMode().trim().toUpperCase();
        if (!CONVERSATION_MODES.contains(requested)) {
            invalid("requestedMode", "Conversation mode is invalid");
        }
        Long id =
                jdbc.queryForObject(
                        "insert into ai_conversations (user_id, title, requested_mode) values (?, ?, ?) returning id",
                        Long.class,
                        userId,
                        request.title().trim(),
                        requested);
        return getConversation(userId, id);
    }

    @Transactional(readOnly = true)
    public List<AiDtos.Conversation> listConversations(Long userId) {
        requireUser(userId);
        return jdbc.query(
                "select c.id, c.title, c.requested_mode, c.status, c.last_message_at, "
                        + "(select m.content from ai_messages m where m.conversation_id = c.id "
                        + "order by m.created_at desc, m.id desc limit 1) preview "
                        + "from ai_conversations c where c.user_id = ? and c.status = 'ACTIVE' "
                        + "order by c.last_message_at desc nulls last, c.id desc limit 50",
                (rs, row) ->
                        new AiDtos.Conversation(
                                rs.getLong("id"),
                                rs.getString("title"),
                                rs.getString("requested_mode"),
                                rs.getString("status"),
                                time(rs.getTimestamp("last_message_at")),
                                rs.getString("preview"),
                                List.of()),
                userId);
    }

    @Transactional(readOnly = true)
    public AiDtos.Conversation getConversation(Long userId, Long conversationId) {
        List<AiDtos.Conversation> rows =
                jdbc.query(
                        "select id, title, requested_mode, status, last_message_at from ai_conversations where id = ? and user_id = ?",
                        (rs, row) ->
                                new AiDtos.Conversation(
                                        rs.getLong("id"),
                                        rs.getString("title"),
                                        rs.getString("requested_mode"),
                                        rs.getString("status"),
                                        time(rs.getTimestamp("last_message_at")),
                                        null,
                                        messages(rs.getLong("id"))),
                        conversationId,
                        userId);
        if (rows.isEmpty()) notFound("Conversation not found");
        return rows.getFirst();
    }

    public AiDtos.MessageExchange sendMessage(
            Long userId, Long conversationId, AiDtos.SendMessage request) {
        AiDtos.Conversation conversation = getConversation(userId, conversationId);
        String content = request.content().trim();
        if (content.isEmpty()) invalid("content", "Message is required");
        String effectiveMode =
                "PERSONALIZED".equals(conversation.requestedMode()) && consentEnabled(userId)
                        ? "PERSONALIZED"
                        : "GENERAL_KNOWLEDGE";
        String correlationId = UUID.randomUUID().toString();
        AiDtos.Message userMessage =
                transactions.execute(
                        status ->
                                insertMessage(
                                        conversationId,
                                        "USER",
                                        content,
                                        effectiveMode,
                                        "NORMAL",
                                        null,
                                        correlationId));

        AiContextBuilder.ContextBundle bundle =
                "PERSONALIZED".equals(effectiveMode)
                        ? contextBuilder.build(userId, "CHAT")
                        : contextBuilder.general();
        if ("PERSONALIZED".equals(effectiveMode)) persistSnapshot(userId, "CHAT", bundle);

        AiPromptConfigurationService.ResolvedPrompt promptConfig =
                promptConfiguration.resolve(
                        "CHAT_COACH",
                        "chat-v1",
                        "Provide concise Vietnamese fitness guidance. Never diagnose illness.");
        String prompt = renderChatPrompt(promptConfig.content(), content, effectiveMode);
        startRequest(userId, "CHAT", correlationId, promptConfig.version());
        String answer;
        String safety = "NORMAL";
        String disclaimer = null;
        try {
            if (looksLikePromptInjection(content)) {
                answer =
                        "Mình không thể làm theo yêu cầu thay đổi quy tắc hệ thống. Mình vẫn có thể hỗ trợ kiến thức tập luyện và dinh dưỡng an toàn.";
                safety = "CAUTION";
                disclaimer = "Nội dung đã được giới hạn vì lý do an toàn.";
                finishRequest(correlationId, "BLOCKED", "PROMPT_INJECTION");
            } else {
                ProviderResponse response =
                        provider.generate(
                                new ProviderRequest(
                                        correlationId,
                                        "CHAT",
                                        promptConfig.version(),
                                        prompt,
                                        bundle.context(),
                                        bundle.candidates(),
                                        List.of(Map.of("role", "USER", "content", content)),
                                        List.of("NONE")));
                answer = validateChatResponse(response);
                safety = normalizeSafety(response.safetyLevel());
                if ("BLOCKED".equals(safety)) {
                    throw new ApiException(
                            ApiErrorCode.AI_OUTPUT_INVALID, "Blocked AI output cannot be returned");
                }
                finishRequest(correlationId, "SUCCEEDED", null);
            }
        } catch (ApiException exception) {
            answer =
                    "AI Coach đang tạm thời không phản hồi. Bạn hãy nghỉ nếu đang đau và thử lại sau; dữ liệu của bạn chưa bị thay đổi.";
            safety = "CAUTION";
            disclaimer = "Phản hồi dự phòng, không phải chẩn đoán y khoa.";
            finishRequest(correlationId, "FAILED", exception.code().name());
        }
        String finalSafety = safety;
        String finalDisclaimer = disclaimer;
        String finalAnswer = answer;
        AiDtos.Message assistant =
                transactions.execute(
                        status ->
                                insertMessage(
                                        conversationId,
                                        "ASSISTANT",
                                        finalAnswer,
                                        effectiveMode,
                                        finalSafety,
                                        finalDisclaimer,
                                        correlationId));
        return new AiDtos.MessageExchange(userMessage, assistant, effectiveMode, correlationId);
    }

    @Transactional
    public AiDtos.DailyRecommendations getDaily(Long userId, LocalDate requestedDate) {
        requireUser(userId);
        LocalDate date = requestedDate == null ? businessDate(userId) : requestedDate;
        boolean enabled = consentEnabled(userId);
        if (!enabled) {
            return new AiDtos.DailyRecommendations(date, false, "DISABLED", List.of());
        }
        expirePending(userId, date);
        List<AiDtos.Recommendation> items =
                jdbc.query(
                        "select r.* from ai_recommendations r join ai_generation_batches b "
                                + "on b.id = r.generation_batch_id where r.user_id = ? "
                                + "and r.recommendation_date = ? and b.generation_no = "
                                + "(select max(generation_no) from ai_generation_batches where user_id = ? and target_date = ?) "
                                + "order by r.id",
                        (rs, row) -> recommendation(rs),
                        userId,
                        Date.valueOf(date),
                        userId,
                        Date.valueOf(date));
        return new AiDtos.DailyRecommendations(date, true, "SUCCEEDED", items);
    }

    public AiDtos.DailyRecommendations generateDaily(
            Long userId, AiDtos.GenerateDaily request, String idempotencyKey) {
        validateIdempotencyKey(idempotencyKey);
        requireUser(userId);
        if (!consentEnabled(userId)) {
            throw new ApiException(
                    ApiErrorCode.AI_CONSENT_REQUIRED,
                    "Personalization consent is required for daily recommendations");
        }
        LocalDate targetDate =
                request == null || request.targetDate() == null
                        ? businessDate(userId)
                        : request.targetDate();
        String requestHash = sha256(targetDate.toString());
        Batch batch =
                transactions.execute(
                        status -> beginGeneration(userId, targetDate, idempotencyKey, requestHash));
        if (!batch.created()) return getDaily(userId, targetDate);

        AiContextBuilder.ContextBundle bundle =
                contextBuilder.build(userId, "DAILY_RECOMMENDATION");
        persistSnapshot(userId, "DAILY_RECOMMENDATION", bundle);
        AiPromptConfigurationService.ResolvedPrompt promptConfig =
                promptConfiguration.resolve(
                        "WORKOUT_ENGINE",
                        "daily-v1",
                        "Create 1-3 safe Vietnamese recommendations. Use only candidate IDs and allowed actions.");
        startRequest(
                userId, "DAILY_RECOMMENDATION", batch.correlationId(), promptConfig.version());
        try {
            ProviderResponse response =
                    provider.generate(
                            new ProviderRequest(
                                    batch.correlationId(),
                                    "DAILY_RECOMMENDATION",
                                    promptConfig.version(),
                                    renderDailyPrompt(promptConfig.content(), targetDate),
                                    bundle.context(),
                                    bundle.candidates(),
                                    List.of(),
                                    List.copyOf(ACTIONS)));
            List<ValidatedItem> items = validateItems(response, targetDate, bundle.candidates());
            transactions.executeWithoutResult(
                    status -> completeGeneration(userId, batch, targetDate, items));
            finishRequest(batch.correlationId(), "SUCCEEDED", null);
        } catch (ApiException exception) {
            transactions.executeWithoutResult(
                    status ->
                            jdbc.update(
                                    "update ai_generation_batches set status = 'FAILED', completed_at = current_timestamp where id = ?",
                                    batch.id()));
            finishRequest(batch.correlationId(), "FAILED", exception.code().name());
            throw exception;
        }
        return getDaily(userId, targetDate);
    }

    @Transactional
    public AiDtos.RecommendationAction apply(
            Long userId,
            Long recommendationId,
            AiDtos.ApplyRecommendation request,
            String idempotencyKey) {
        validateIdempotencyKey(idempotencyKey);
        String requestHash = sha256(recommendationId + ":APPLY:" + request.expectedVersion());
        AiDtos.RecommendationAction replay = replayAction(userId, idempotencyKey, requestHash);
        if (replay != null) return replay;
        RecommendationRow row = lockRecommendation(userId, recommendationId);
        ensurePending(row, request.expectedVersion());
        Map<String, Object> mutation = applyDomainAction(userId, row);
        OffsetDateTime now = OffsetDateTime.now(clock);
        jdbc.update(
                "update ai_recommendations set status = 'APPLIED', applied_at = ?, version = version + 1, updated_at = ? where id = ?",
                Timestamp.from(now.toInstant()),
                Timestamp.from(now.toInstant()),
                recommendationId);
        AiDtos.RecommendationAction result =
                new AiDtos.RecommendationAction(
                        recommendationId, "APPLIED", row.allowedAction(), mutation, now);
        persistAction(userId, recommendationId, "APPLY", idempotencyKey, requestHash, result);
        audit(
                userId,
                "AI_RECOMMENDATION_APPLIED",
                "AI_RECOMMENDATION",
                recommendationId.toString(),
                mutation);
        return result;
    }

    @Transactional
    public AiDtos.RecommendationAction dismiss(
            Long userId,
            Long recommendationId,
            AiDtos.DismissRecommendation request,
            String idempotencyKey) {
        validateIdempotencyKey(idempotencyKey);
        String feedback = request.feedback() == null ? "" : request.feedback().trim();
        String requestHash =
                sha256(recommendationId + ":DISMISS:" + request.expectedVersion() + ":" + feedback);
        AiDtos.RecommendationAction replay = replayAction(userId, idempotencyKey, requestHash);
        if (replay != null) return replay;
        RecommendationRow row = lockRecommendation(userId, recommendationId);
        ensurePending(row, request.expectedVersion());
        OffsetDateTime now = OffsetDateTime.now(clock);
        jdbc.update(
                "update ai_recommendations set status = 'DISMISSED', feedback = ?, dismissed_at = ?, "
                        + "version = version + 1, updated_at = ? where id = ?",
                feedback.isBlank() ? null : feedback,
                Timestamp.from(now.toInstant()),
                Timestamp.from(now.toInstant()),
                recommendationId);
        AiDtos.RecommendationAction result =
                new AiDtos.RecommendationAction(
                        recommendationId, "DISMISSED", row.allowedAction(), Map.of(), now);
        persistAction(userId, recommendationId, "DISMISS", idempotencyKey, requestHash, result);
        return result;
    }

    private Batch beginGeneration(
            Long userId, LocalDate date, String idempotencyKey, String requestHash) {
        List<Batch> existing =
                jdbc.query(
                        "select id, correlation_id, request_hash from ai_generation_batches where user_id = ? and idempotency_key = ?",
                        (rs, row) ->
                                new Batch(
                                        rs.getLong("id"),
                                        rs.getString("correlation_id"),
                                        false,
                                        rs.getString("request_hash")),
                        userId,
                        idempotencyKey);
        if (!existing.isEmpty()) {
            if (!existing.getFirst().requestHash().equals(requestHash)) {
                throw new ApiException(
                        ApiErrorCode.IDEMPOTENCY_CONFLICT,
                        "Idempotency key was already used with another request");
            }
            return existing.getFirst();
        }
        Integer count =
                jdbc.queryForObject(
                        "select count(*) from ai_generation_batches where user_id = ? and target_date = ?",
                        Integer.class,
                        userId,
                        Date.valueOf(date));
        int generationNo = (count == null ? 0 : count) + 1;
        if (generationNo > 3) {
            throw new ApiException(
                    ApiErrorCode.DAILY_GENERATION_LIMIT_REACHED,
                    "Daily recommendation generation limit reached");
        }
        String correlationId = UUID.randomUUID().toString();
        Long id =
                jdbc.queryForObject(
                        "insert into ai_generation_batches (user_id, target_date, generation_no, idempotency_key, request_hash, correlation_id) values (?, ?, ?, ?, ?, ?) returning id",
                        Long.class,
                        userId,
                        Date.valueOf(date),
                        generationNo,
                        idempotencyKey,
                        requestHash,
                        correlationId);
        return new Batch(id, correlationId, true, requestHash);
    }

    private void completeGeneration(
            Long userId, Batch batch, LocalDate date, List<ValidatedItem> items) {
        jdbc.update(
                "update ai_recommendations set status = 'EXPIRED', updated_at = current_timestamp "
                        + "where user_id = ? and recommendation_date = ? and status = 'PENDING'",
                userId,
                Date.valueOf(date));
        OffsetDateTime expiresAt = date.plusDays(1).atStartOfDay(zone(userId)).toOffsetDateTime();
        for (ValidatedItem item : items) {
            jdbc.update(
                    "insert into ai_recommendations (generation_batch_id, user_id, recommendation_date, type, title, content, reason, priority, safety_level, allowed_action, action_preview, source_metrics, expires_at) "
                            + "values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?::jsonb, ?::jsonb, ?)",
                    batch.id(),
                    userId,
                    Date.valueOf(date),
                    item.type(),
                    item.title(),
                    item.content(),
                    item.reason(),
                    item.priority(),
                    item.safety(),
                    item.action(),
                    json(item.preview()),
                    json(item.metrics()),
                    Timestamp.from(expiresAt.toInstant()));
        }
        jdbc.update(
                "update ai_generation_batches set status = 'SUCCEEDED', completed_at = current_timestamp where id = ?",
                batch.id());
    }

    private List<ValidatedItem> validateItems(
            ProviderResponse response, LocalDate date, Map<String, Object> candidates) {
        if (response.items() == null || response.items().isEmpty() || response.items().size() > 3) {
            throw new ApiException(
                    ApiErrorCode.AI_OUTPUT_INVALID,
                    "AI output must contain between one and three items");
        }
        Set<Long> foodIds = candidateIds(candidates.get("foods"));
        Set<Long> exerciseIds = candidateIds(candidates.get("exercises"));
        List<ValidatedItem> validated = new ArrayList<>();
        for (Map<String, Object> raw : response.items()) {
            String safety = normalizeSafety(text(raw, "safetyLevel", "NORMAL"));
            if ("BLOCKED".equalsIgnoreCase(text(raw, "safetyLevel", ""))) {
                throw new ApiException(
                        ApiErrorCode.AI_OUTPUT_INVALID, "Blocked AI output is not persisted");
            }
            String type = text(raw, "type", "").toUpperCase();
            String priority = text(raw, "priority", "MEDIUM").toUpperCase();
            Map<String, Object> proposal = map(raw.get("proposal"));
            String action = text(proposal, "allowedAction", "NONE").toUpperCase();
            if (!TYPES.contains(type)
                    || !PRIORITIES.contains(priority)
                    || !ACTIONS.contains(action)) {
                throw new ApiException(
                        ApiErrorCode.AI_OUTPUT_INVALID, "AI output contains an invalid enum");
            }
            if ("ADD_MEAL_ENTRY_PROPOSAL".equals(action)) {
                long foodId = number(proposal.get("foodId"));
                if (!foodIds.contains(foodId)) {
                    throw new ApiException(
                            ApiErrorCode.AI_OUTPUT_INVALID,
                            "AI output referenced a food outside the candidate shortlist");
                }
                String target = text(proposal, "targetDate", "");
                if (!date.toString().equals(target)) {
                    throw new ApiException(
                            ApiErrorCode.AI_OUTPUT_INVALID, "Meal proposal targetDate is invalid");
                }
            }
            if ("CREATE_WORKOUT_SCHEDULE_PROPOSAL".equals(action)) {
                String target = text(proposal, "targetDate", "");
                if (!date.toString().equals(target)) {
                    throw new ApiException(
                            ApiErrorCode.AI_OUTPUT_INVALID,
                            "Workout proposal targetDate is invalid");
                }
                Object rawExercises = proposal.get("exercises");
                if (!(rawExercises instanceof List<?> exercises)
                        || exercises.isEmpty()
                        || exercises.size() > 12) {
                    throw new ApiException(
                            ApiErrorCode.AI_OUTPUT_INVALID,
                            "Workout proposal must contain between one and twelve exercises");
                }
                for (Object rawExercise : exercises) {
                    long exerciseId = number(map(rawExercise).get("exerciseId"));
                    if (!exerciseIds.contains(exerciseId)) {
                        throw new ApiException(
                                ApiErrorCode.AI_OUTPUT_INVALID,
                                "AI output referenced an exercise outside the candidate shortlist");
                    }
                }
            }
            validated.add(
                    new ValidatedItem(
                            type,
                            bounded(text(raw, "title", ""), 200),
                            bounded(text(raw, "content", ""), 2000),
                            bounded(text(raw, "reason", ""), 1000),
                            priority,
                            safety,
                            action,
                            proposal,
                            map(raw.get("sourceMetrics"))));
        }
        return validated;
    }

    private Map<String, Object> applyDomainAction(Long userId, RecommendationRow row) {
        if ("ADD_MEAL_ENTRY_PROPOSAL".equals(row.allowedAction())) {
            long foodId = number(row.preview().get("foodId"));
            LocalDate targetDate = LocalDate.parse(text(row.preview(), "targetDate", ""));
            String mealType = text(row.preview(), "mealType", "SNACK").toUpperCase();
            BigDecimal multiplier =
                    new BigDecimal(
                            String.valueOf(row.preview().getOrDefault("servingMultiplier", 1)));
            NutritionDtos.MealPlan plan =
                    nutrition.addEntry(
                            userId,
                            targetDate,
                            new MealEntryRequest(
                                    mealType,
                                    1,
                                    foodId,
                                    multiplier,
                                    null,
                                    null,
                                    "Applied from AI recommendation " + row.id()));
            Long entryId =
                    plan.meals().stream()
                            .flatMap(meal -> meal.entries().stream())
                            .filter(entry -> entry.foodId().equals(foodId))
                            .map(NutritionDtos.MealEntry::id)
                            .reduce((first, second) -> second)
                            .orElse(null);
            return Map.of(
                    "targetType",
                    "MEAL_ENTRY",
                    "targetId",
                    entryId == null ? 0 : entryId,
                    "targetDate",
                    targetDate.toString());
        }
        if ("CREATE_WORKOUT_SCHEDULE_PROPOSAL".equals(row.allowedAction())) {
            LocalDate targetDate = LocalDate.parse(text(row.preview(), "targetDate", ""));
            Object rawExercises = row.preview().get("exercises");
            if (!(rawExercises instanceof List<?> exercises) || exercises.isEmpty()) {
                throw new ApiException(
                        ApiErrorCode.PROPOSAL_TARGET_INVALID,
                        "Workout recommendation has no exercises");
            }
            List<ScheduleExercisePlan> plans = new ArrayList<>();
            for (int index = 0; index < exercises.size(); index++) {
                Map<String, Object> raw = map(exercises.get(index));
                long exerciseId = number(raw.get("exerciseId"));
                List<Map<String, Object>> catalogRows =
                        jdbc.queryForList(
                                "select e.name, coalesce((select mg.name from exercise_muscle_groups emg join muscle_groups mg on mg.id = emg.muscle_group_id where emg.exercise_id = e.id and emg.role = 'PRIMARY' order by mg.name limit 1), 'GENERAL') as primary_muscle from exercises e where e.id = ? and e.visibility = 'PUBLIC' and e.deleted_at is null",
                                exerciseId);
                if (catalogRows.isEmpty()) {
                    throw new ApiException(
                            ApiErrorCode.RESOURCE_HIDDEN,
                            "Exercise is no longer selectable: " + exerciseId);
                }
                Map<String, Object> catalog = catalogRows.getFirst();
                plans.add(
                        new ScheduleExercisePlan(
                                exerciseId,
                                String.valueOf(catalog.get("name")),
                                String.valueOf(catalog.get("primary_muscle")),
                                index + 1,
                                integer(raw.get("targetSets"), 3),
                                integer(raw.get("targetRepsMin"), 8),
                                integer(raw.get("targetRepsMax"), 12),
                                null,
                                integer(raw.get("restSeconds"), 60),
                                "Applied from AI recommendation " + row.id()));
            }
            ScheduleProposalResponse proposal =
                    workoutPlanning.createProposal(
                            userId,
                            new CreateScheduleProposalRequest(
                                    "AI",
                                    "ONE_DAY",
                                    null,
                                    null,
                                    List.of(targetDate),
                                    null,
                                    List.of(
                                            new ScheduleProposalItemRequest(
                                                    targetDate,
                                                    null,
                                                    text(row.preview(), "title", "AI Workout"),
                                                    plans))));
            ApplyScheduleProposalResponse applied = workoutPlanning.apply(userId, proposal.id());
            Long scheduleId =
                    applied.schedules().isEmpty() ? null : applied.schedules().getFirst().id();
            return Map.of(
                    "targetType",
                    "WORKOUT_SCHEDULE",
                    "targetId",
                    scheduleId == null ? 0 : scheduleId,
                    "proposalId",
                    proposal.id(),
                    "targetDate",
                    targetDate.toString());
        }
        if ("NONE".equals(row.allowedAction())) {
            return Map.of("targetType", "NONE");
        }
        throw new ApiException(
                ApiErrorCode.PROPOSAL_TARGET_INVALID,
                "This recommendation action is not supported by the current domain owner");
    }

    private RecommendationRow lockRecommendation(Long userId, Long recommendationId) {
        List<RecommendationRow> rows =
                jdbc.query(
                        "select id, status, version, safety_level, allowed_action, action_preview::text, expires_at "
                                + "from ai_recommendations where id = ? and user_id = ? for update",
                        (rs, row) ->
                                new RecommendationRow(
                                        rs.getLong("id"),
                                        rs.getString("status"),
                                        rs.getInt("version"),
                                        rs.getString("safety_level"),
                                        rs.getString("allowed_action"),
                                        parseMap(rs.getString("action_preview")),
                                        time(rs.getTimestamp("expires_at"))),
                        recommendationId,
                        userId);
        if (rows.isEmpty()) notFound("Recommendation not found");
        return rows.getFirst();
    }

    private void ensurePending(RecommendationRow row, int expectedVersion) {
        if (row.expiresAt().isBefore(OffsetDateTime.now(clock))) {
            jdbc.update(
                    "update ai_recommendations set status = 'EXPIRED', updated_at = current_timestamp where id = ?",
                    row.id());
            throw new ApiException(ApiErrorCode.RECOMMENDATION_EXPIRED, "Recommendation expired");
        }
        if (!"PENDING".equals(row.status()) || row.version() != expectedVersion) {
            throw new ApiException(
                    ApiErrorCode.RECOMMENDATION_NOT_PENDING,
                    "Recommendation is no longer pending or its version changed");
        }
    }

    private AiDtos.RecommendationAction replayAction(
            Long userId, String idempotencyKey, String requestHash) {
        List<Map<String, Object>> rows =
                jdbc.queryForList(
                        "select request_hash, result::text result from ai_recommendation_actions where user_id = ? and idempotency_key = ?",
                        userId,
                        idempotencyKey);
        if (rows.isEmpty()) return null;
        if (!requestHash.equals(rows.getFirst().get("request_hash"))) {
            throw new ApiException(
                    ApiErrorCode.IDEMPOTENCY_CONFLICT,
                    "Idempotency key was already used with another request");
        }
        try {
            return objectMapper.readValue(
                    String.valueOf(rows.getFirst().get("result")),
                    AiDtos.RecommendationAction.class);
        } catch (JsonProcessingException exception) {
            throw new ApiException(ApiErrorCode.INTERNAL_ERROR, "Stored action result is invalid");
        }
    }

    private void persistAction(
            Long userId,
            Long recommendationId,
            String action,
            String idempotencyKey,
            String requestHash,
            AiDtos.RecommendationAction result) {
        try {
            jdbc.update(
                    "insert into ai_recommendation_actions (recommendation_id, user_id, action_type, idempotency_key, request_hash, result) values (?, ?, ?, ?, ?, ?::jsonb)",
                    recommendationId,
                    userId,
                    action,
                    idempotencyKey,
                    requestHash,
                    json(result));
        } catch (DuplicateKeyException exception) {
            throw new ApiException(ApiErrorCode.IDEMPOTENCY_CONFLICT, "Action already processed");
        }
    }

    private AiDtos.Recommendation recommendation(java.sql.ResultSet rs)
            throws java.sql.SQLException {
        return new AiDtos.Recommendation(
                rs.getLong("id"),
                rs.getString("type"),
                rs.getString("title"),
                rs.getString("content"),
                rs.getString("reason"),
                rs.getString("priority"),
                rs.getString("status"),
                parseMap(rs.getString("source_metrics")),
                rs.getString("safety_level"),
                rs.getString("allowed_action"),
                parseMap(rs.getString("action_preview")),
                rs.getInt("version"),
                time(rs.getTimestamp("expires_at")));
    }

    private List<AiDtos.Message> messages(Long conversationId) {
        return jdbc.query(
                "select id, role, content, effective_mode, safety_level, disclaimer, created_at from ai_messages where conversation_id = ? order by created_at, id",
                (rs, row) ->
                        new AiDtos.Message(
                                rs.getLong("id"),
                                rs.getString("role"),
                                rs.getString("content"),
                                rs.getString("effective_mode"),
                                rs.getString("safety_level"),
                                rs.getString("disclaimer"),
                                time(rs.getTimestamp("created_at"))),
                conversationId);
    }

    private AiDtos.Message insertMessage(
            Long conversationId,
            String role,
            String content,
            String mode,
            String safety,
            String disclaimer,
            String correlationId) {
        Long id =
                jdbc.queryForObject(
                        "insert into ai_messages (conversation_id, role, content, effective_mode, safety_level, disclaimer, correlation_id) values (?, ?, ?, ?, ?, ?, ?) returning id",
                        Long.class,
                        conversationId,
                        role,
                        bounded(content, 4000),
                        mode,
                        safety,
                        disclaimer,
                        correlationId);
        jdbc.update(
                "update ai_conversations set last_message_at = current_timestamp, updated_at = current_timestamp where id = ?",
                conversationId);
        return jdbc.queryForObject(
                "select id, role, content, effective_mode, safety_level, disclaimer, created_at from ai_messages where id = ?",
                (rs, row) ->
                        new AiDtos.Message(
                                rs.getLong("id"),
                                rs.getString("role"),
                                rs.getString("content"),
                                rs.getString("effective_mode"),
                                rs.getString("safety_level"),
                                rs.getString("disclaimer"),
                                time(rs.getTimestamp("created_at"))),
                id);
    }

    private void persistSnapshot(
            Long userId, String purpose, AiContextBuilder.ContextBundle bundle) {
        transactions.executeWithoutResult(
                status ->
                        jdbc.update(
                                "insert into ai_context_snapshots (user_id, purpose, context_version, snapshot, expires_at) values (?, ?, 'context-v1', ?::jsonb, ?)",
                                userId,
                                purpose,
                                json(bundle.context()),
                                Timestamp.from(bundle.expiresAt().toInstant())));
    }

    private void startRequest(
            Long userId, String type, String correlationId, String promptVersion) {
        transactions.executeWithoutResult(
                status ->
                        jdbc.update(
                                "insert into ai_requests (user_id, request_type, correlation_id, prompt_version, status) values (?, ?, ?, ?, 'STARTED')",
                                userId,
                                type,
                                correlationId,
                                promptVersion));
    }

    private void finishRequest(String correlationId, String status, String failureCode) {
        transactions.executeWithoutResult(
                tx ->
                        jdbc.update(
                                "update ai_requests set status = ?, failure_code = ?, completed_at = current_timestamp where correlation_id = ?",
                                status,
                                failureCode,
                                correlationId));
    }

    private void audit(
            Long userId,
            String action,
            String targetType,
            String targetId,
            Map<String, Object> metadata) {
        jdbc.update(
                "insert into audit_logs (actor_user_id, action, target_type, target_id, result, metadata) values (?, ?, ?, ?, 'SUCCESS', ?::jsonb)",
                userId,
                action,
                targetType,
                targetId,
                json(metadata));
    }

    private boolean consentEnabled(Long userId) {
        List<String> rows =
                jdbc.queryForList(
                        "select mode from ai_consents where user_id = ?", String.class, userId);
        return !rows.isEmpty() && "ENABLED".equals(rows.getFirst());
    }

    private LocalDate businessDate(Long userId) {
        return LocalDate.now(clock.withZone(zone(userId)));
    }

    private ZoneId zone(Long userId) {
        List<String> zones =
                jdbc.queryForList(
                        "select timezone from user_profiles where user_id = ?",
                        String.class,
                        userId);
        return ZoneId.of(zones.isEmpty() ? "Asia/Ho_Chi_Minh" : zones.getFirst());
    }

    private void expirePending(Long userId, LocalDate date) {
        jdbc.update(
                "update ai_recommendations set status = 'EXPIRED', updated_at = current_timestamp "
                        + "where user_id = ? and recommendation_date = ? and status = 'PENDING' and expires_at <= current_timestamp",
                userId,
                Date.valueOf(date));
    }

    private void requireUser(Long userId) {
        Integer count =
                jdbc.queryForObject(
                        "select count(*) from users where id = ? and deleted_at is null",
                        Integer.class,
                        userId);
        if (count == null || count == 0) notFound("User not found");
    }

    private static String validateChatResponse(ProviderResponse response) {
        if (response.content() == null || response.content().isBlank()) {
            throw new ApiException(ApiErrorCode.AI_OUTPUT_INVALID, "AI chat response is empty");
        }
        if (response.content().length() > 4000) {
            throw new ApiException(ApiErrorCode.AI_OUTPUT_INVALID, "AI chat response is too long");
        }
        return response.content().trim();
    }

    private static String normalizeSafety(String safety) {
        if ("CAUTION".equalsIgnoreCase(safety)) return "CAUTION";
        if ("NORMAL".equalsIgnoreCase(safety)) return "NORMAL";
        if ("BLOCKED".equalsIgnoreCase(safety)) return "BLOCKED";
        throw new ApiException(ApiErrorCode.AI_OUTPUT_INVALID, "AI safety level is invalid");
    }

    private static boolean looksLikePromptInjection(String content) {
        String normalized = content.toLowerCase();
        return normalized.contains("ignore previous")
                || normalized.contains("system prompt")
                || normalized.contains("bỏ qua hướng dẫn")
                || normalized.contains("tiết lộ prompt");
    }

    private static String renderChatPrompt(String configuredPrompt, String message, String mode) {
        return configuredPrompt
                + "\nMode: "
                + mode
                + "\nUser: "
                + message;
    }

    private static String renderDailyPrompt(String configuredPrompt, LocalDate date) {
        return configuredPrompt
                + "\nTarget date: "
                + date
                + ".";
    }

    private static void validateIdempotencyKey(String key) {
        if (key == null || key.isBlank() || key.length() > 100) {
            throw new ApiException(
                    ApiErrorCode.VALIDATION_ERROR,
                    "Idempotency-Key is required and must not exceed 100 characters");
        }
    }

    private String json(Object value) {
        try {
            return objectMapper.writeValueAsString(value);
        } catch (JsonProcessingException exception) {
            throw new ApiException(ApiErrorCode.INTERNAL_ERROR, "Could not serialize data");
        }
    }

    private Map<String, Object> parseMap(String value) {
        try {
            return objectMapper.readValue(value, new TypeReference<>() {});
        } catch (JsonProcessingException exception) {
            throw new ApiException(ApiErrorCode.INTERNAL_ERROR, "Stored JSON is invalid");
        }
    }

    @SuppressWarnings("unchecked")
    private static Map<String, Object> map(Object value) {
        return value instanceof Map<?, ?> raw ? (Map<String, Object>) raw : new LinkedHashMap<>();
    }

    private static Set<Long> candidateIds(Object value) {
        if (!(value instanceof List<?> list)) return Set.of();
        java.util.HashSet<Long> ids = new java.util.HashSet<>();
        for (Object item : list) {
            Object id = map(item).get("id");
            if (id instanceof Number number) ids.add(number.longValue());
        }
        return ids;
    }

    private static long number(Object value) {
        if (value instanceof Number number) return number.longValue();
        try {
            return Long.parseLong(String.valueOf(value));
        } catch (NumberFormatException exception) {
            throw new ApiException(ApiErrorCode.AI_OUTPUT_INVALID, "AI proposal ID is invalid");
        }
    }

    private static int integer(Object value, int fallback) {
        if (value == null) return fallback;
        long number = number(value);
        if (number < 1 || number > Integer.MAX_VALUE) {
            throw new ApiException(ApiErrorCode.AI_OUTPUT_INVALID, "AI numeric field is invalid");
        }
        return (int) number;
    }

    private static String text(Map<String, Object> map, String key, String fallback) {
        Object value = map.get(key);
        return value == null ? fallback : String.valueOf(value);
    }

    private static String bounded(String value, int max) {
        String clean = value == null ? "" : value.trim();
        if (clean.isEmpty() || clean.length() > max) {
            throw new ApiException(ApiErrorCode.AI_OUTPUT_INVALID, "AI text field is invalid");
        }
        return clean;
    }

    private static String sha256(String value) {
        try {
            byte[] digest =
                    MessageDigest.getInstance("SHA-256")
                            .digest(value.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(digest);
        } catch (NoSuchAlgorithmException exception) {
            throw new IllegalStateException(exception);
        }
    }

    private static OffsetDateTime time(Timestamp timestamp) {
        return timestamp == null ? null : timestamp.toInstant().atOffset(ZoneOffset.UTC);
    }

    private static void invalid(String field, String message) {
        throw new ApiException(ApiErrorCode.VALIDATION_ERROR, field + ": " + message);
    }

    private static void notFound(String message) {
        throw new ApiException(ApiErrorCode.RESOURCE_NOT_FOUND, message);
    }

    private record Batch(Long id, String correlationId, boolean created, String requestHash) {}

    private record ValidatedItem(
            String type,
            String title,
            String content,
            String reason,
            String priority,
            String safety,
            String action,
            Map<String, Object> preview,
            Map<String, Object> metrics) {}

    private record RecommendationRow(
            Long id,
            String status,
            int version,
            String safety,
            String allowedAction,
            Map<String, Object> preview,
            OffsetDateTime expiresAt) {}
}
