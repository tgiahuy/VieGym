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
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.Date;
import java.sql.Timestamp;
import java.time.Clock;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.HexFormat;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;

/**
 * AI workout and meal plan generation.
 *
 * <p>The backend builds a filtered shortlist, Gemini picks and orders items from it, and the
 * backend validates and clamps the result. Calories are always recomputed from the food catalog.
 * When the provider is unavailable or its output is unusable, a deterministic heuristic planner
 * produces the plan instead ({@code generatedBy = "heuristic"}). Plans are stored as pending
 * recommendations, so the existing apply/dismiss endpoints act on them.
 */
@Service
public class AiPlanService {
    static final String WORKOUT_PURPOSE = "WORKOUT_PLAN";
    static final String MEAL_PURPOSE = "MEAL_PLAN";
    static final String WORKOUT_ACTION = "CREATE_WORKOUT_SCHEDULE_PROPOSAL";
    static final String HEURISTIC = "heuristic";
    private static final int PLAN_GENERATIONS_PER_DAY = 10;
    private static final int MAX_DAYS_AHEAD = 14;

    private static final List<String> MEAL_ORDER = List.of("BREAKFAST", "LUNCH", "DINNER", "SNACK");
    private static final Map<String, Double> MEAL_SHARE =
            Map.of("BREAKFAST", 0.25, "LUNCH", 0.35, "DINNER", 0.30, "SNACK", 0.10);
    private static final Map<String, String> MEAL_LABEL =
            Map.of(
                    "BREAKFAST", "bữa sáng",
                    "LUNCH", "bữa trưa",
                    "DINNER", "bữa tối",
                    "SNACK", "bữa phụ");
    private static final List<String> MAIN_MEAL_CATEGORIES =
            List.of("COM", "DAM", "CANH_RAU", "MON_NUOC", "TINH_BOT");
    private static final Map<String, List<String>> MEAL_CATEGORIES =
            Map.of(
                    "BREAKFAST",
                    List.of("MON_NUOC", "BANH", "TINH_BOT", "DAM", "DO_UONG", "TRAI_CAY"),
                    "LUNCH",
                    MAIN_MEAL_CATEGORIES,
                    "DINNER",
                    MAIN_MEAL_CATEGORIES,
                    "SNACK",
                    List.of("DAM", "AN_VAT", "TRAI_CAY", "DO_UONG"));

    /** Heuristic meal = one food from each group, in order. */
    private static final Map<String, List<List<String>>> HEURISTIC_MEAL_GROUPS =
            Map.of(
                    "BREAKFAST",
                            List.of(
                                    List.of("MON_NUOC", "BANH", "TINH_BOT"),
                                    List.of("DO_UONG", "TRAI_CAY")),
                    "LUNCH",
                            List.of(
                                    List.of("COM", "MON_NUOC", "TINH_BOT"),
                                    List.of("DAM"),
                                    List.of("CANH_RAU")),
                    "DINNER",
                            List.of(
                                    List.of("COM", "MON_NUOC", "TINH_BOT"),
                                    List.of("DAM"),
                                    List.of("CANH_RAU")),
                    "SNACK", List.of(List.of("DAM", "AN_VAT", "DO_UONG", "TRAI_CAY")));

    private static final BigDecimal MIN_SERVING = new BigDecimal("0.25");
    private static final BigDecimal MAX_SERVING = new BigDecimal("2.5");

    private static final Set<String> INTENSITIES = Set.of("LIGHT", "MODERATE", "HARD");

    private final JdbcTemplate jdbc;
    private final ObjectMapper objectMapper;
    private final Clock clock;
    private final AiContextBuilder contextBuilder;
    private final AiProviderClient provider;
    private final AiPromptConfigurationService promptConfiguration;
    private final TransactionTemplate transactions;

    public AiPlanService(
            JdbcTemplate jdbc,
            ObjectMapper objectMapper,
            Clock clock,
            AiContextBuilder contextBuilder,
            AiProviderClient provider,
            AiPromptConfigurationService promptConfiguration,
            PlatformTransactionManager transactionManager) {
        this.jdbc = jdbc;
        this.objectMapper = objectMapper;
        this.clock = clock;
        this.contextBuilder = contextBuilder;
        this.provider = provider;
        this.promptConfiguration = promptConfiguration;
        this.transactions = new TransactionTemplate(transactionManager);
    }

    // ---------------------------------------------------------------------------------------
    // Workout
    // ---------------------------------------------------------------------------------------

    public AiDtos.WorkoutPlan generateWorkout(
            Long userId, AiDtos.GenerateWorkout request, String idempotencyKey) {
        validateIdempotencyKey(idempotencyKey);
        requireUser(userId);
        AiDtos.GenerateWorkout input =
                request == null
                        ? new AiDtos.GenerateWorkout(null, null, null, null, null, null, null)
                        : request;
        LocalDate date = targetDate(userId, input.targetDate());
        int duration = input.durationMinutes() == null ? 45 : input.durationMinutes();
        if (duration < 15 || duration > 120)
            invalid("durationMinutes", "must be between 15 and 120");
        String intensity =
                input.intensity() == null
                        ? "MODERATE"
                        : input.intensity().trim().toUpperCase(Locale.ROOT);
        if (!INTENSITIES.contains(intensity))
            invalid("intensity", "must be LIGHT, MODERATE or HARD");
        Set<String> muscles = muscleCodes(input.targetMuscles());
        Set<Long> equipment =
                new LinkedHashSet<>(positiveIds(input.equipmentIds(), "equipmentIds"));
        equipment.addAll(equipmentIdsForCodes(input.equipmentCodes()));
        Set<Long> excluded = positiveIds(input.excludedExerciseIds(), "excludedExerciseIds");

        Map<String, Object> normalized = new LinkedHashMap<>();
        normalized.put("date", date.toString());
        normalized.put("muscles", muscles);
        normalized.put("equipment", equipment);
        normalized.put("excluded", excluded);
        normalized.put("duration", duration);
        normalized.put("intensity", intensity);
        Batch batch =
                beginBatch(userId, WORKOUT_PURPOSE, date, idempotencyKey, sha256(json(normalized)));
        if (!batch.created()) return workoutReplay(userId, batch);

        try {
            boolean personalized = consentEnabled(userId);
            AiContextBuilder.ContextBundle bundle =
                    contextBuilder.build(
                            userId,
                            WORKOUT_PURPOSE,
                            new AiContextBuilder.CandidateQuery(
                                    date,
                                    muscles,
                                    equipment.isEmpty() ? null : equipment,
                                    excluded,
                                    List.of(),
                                    30,
                                    0,
                                    true),
                            personalized);
            List<Map<String, Object>> candidates = list(bundle.candidates().get("exercises"));
            if (candidates.isEmpty()) {
                throw new ApiException(
                        ApiErrorCode.VALIDATION_ERROR,
                        "Không có bài tập phù hợp với thiết bị và nhóm cơ đã chọn");
            }
            if (personalized) persistSnapshot(userId, WORKOUT_PURPOSE, bundle);
            int minExercises = clamp(duration / 10, 3, 8);
            int maxExercises = clamp(duration / 8, 3, 10);

            AiPromptConfigurationService.ResolvedPrompt prompt =
                    promptConfiguration.resolve(
                            "WORKOUT_ENGINE",
                            "workout-plan-v1",
                            "Create safe Vietnamese workout plans using only candidate exercise IDs.");
            String rendered =
                    prompt.content()
                            + "\n\nNHIỆM VỤ: Thiết kế một buổi tập cho ngày "
                            + date
                            + ". Thời lượng: "
                            + duration
                            + " phút. Cường độ: "
                            + intensity
                            + ". Nhóm cơ mục tiêu: "
                            + (muscles.isEmpty()
                                    ? "toàn thân/tuỳ chọn"
                                    : String.join(", ", muscles))
                            + ". Số bài: "
                            + minExercises
                            + "-"
                            + maxExercises
                            + ". Tránh ưu tiên nhóm cơ có status RECOVERING trong CONTEXT.recovery.";
            startRequest(userId, WORKOUT_PURPOSE, batch.correlationId(), prompt.version());

            WorkoutDraft draft = null;
            String failure = null;
            String generatedBy = HEURISTIC;
            String safety = "NORMAL";
            try {
                ProviderResponse response =
                        provider.generate(
                                new ProviderRequest(
                                        batch.correlationId(),
                                        WORKOUT_PURPOSE,
                                        prompt.version(),
                                        rendered,
                                        bundle.context(),
                                        bundle.candidates(),
                                        List.of(),
                                        List.of()));
                if ("BLOCKED".equalsIgnoreCase(response.safetyLevel())) {
                    failure = "AI_OUTPUT_BLOCKED";
                } else {
                    draft = validateWorkout(response.plan(), candidates, maxExercises);
                    if (draft == null) {
                        failure = "AI_OUTPUT_INVALID";
                    } else {
                        generatedBy = providerName(response);
                        safety =
                                "CAUTION".equalsIgnoreCase(response.safetyLevel())
                                        ? "CAUTION"
                                        : "NORMAL";
                    }
                }
            } catch (ApiException exception) {
                failure = exception.code().name();
            }
            if (draft == null) {
                draft = heuristicWorkout(candidates, muscles, duration, intensity, minExercises);
            } else if (draft.exercises().size() < minExercises) {
                draft = padWorkout(draft, candidates, intensity, minExercises);
            }
            WorkoutDraft finalDraft = draft;
            String finalGeneratedBy = generatedBy;
            String finalSafety = safety;
            transactions.executeWithoutResult(
                    status -> {
                        insertWorkoutRecommendation(
                                userId,
                                batch,
                                date,
                                finalDraft,
                                finalGeneratedBy,
                                finalSafety,
                                personalized,
                                intensity,
                                duration);
                        completeBatch(batch.id(), "SUCCEEDED");
                    });
            finishRequest(batch.correlationId(), failure == null ? "SUCCEEDED" : "FAILED", failure);
            return workoutReplay(userId, batch);
        } catch (ApiException exception) {
            completeBatch(batch.id(), "FAILED");
            finishRequestIfStarted(batch.correlationId(), exception.code().name());
            throw exception;
        }
    }

    private WorkoutDraft validateWorkout(
            Map<String, Object> plan, List<Map<String, Object>> candidates, int maxExercises) {
        if (plan == null) return null;
        Map<Long, Map<String, Object>> byId = byId(candidates);
        List<Map<String, Object>> exercises = new ArrayList<>();
        Set<Long> seen = new HashSet<>();
        for (Map<String, Object> raw : list(plan.get("exercises"))) {
            Long id = longValue(raw.get("exerciseId"));
            if (id == null || !byId.containsKey(id) || !seen.add(id)) continue;
            Map<String, Object> candidate = byId.get(id);
            int sets = clamp(intValue(raw.get("targetSets"), 3), 1, 6);
            int repsMin = clamp(intValue(raw.get("targetRepsMin"), 8), 1, 30);
            int repsMax = clamp(intValue(raw.get("targetRepsMax"), repsMin), repsMin, 30);
            int rest = clamp(intValue(raw.get("restSeconds"), 90), 30, 300);
            exercises.add(
                    exercise(
                            candidate,
                            sets,
                            repsMin,
                            repsMax,
                            rest,
                            safeWeight(raw.get("targetWeightKg"), candidate.get("lastWeightKg")),
                            optionalText(raw.get("coachingTip"), 300)));
            if (exercises.size() == maxExercises) break;
        }
        if (exercises.isEmpty()) return null;
        return new WorkoutDraft(
                textOr(plan.get("planTitle"), 120, "Buổi tập AI"),
                textOr(
                        plan.get("rationale"),
                        1000,
                        "Giáo án được thiết kế theo thiết bị và mục tiêu của bạn."),
                exercises);
    }

    /** Tops up a too-short AI plan with unused shortlisted exercises. */
    private static WorkoutDraft padWorkout(
            WorkoutDraft draft,
            List<Map<String, Object>> candidates,
            String intensity,
            int minExercises) {
        Set<Long> used =
                draft.exercises().stream()
                        .map(ex -> longValue(ex.get("exerciseId")))
                        .collect(Collectors.toSet());
        int[] scheme = scheme(intensity);
        List<Map<String, Object>> exercises = new ArrayList<>(draft.exercises());
        for (Map<String, Object> candidate : candidates) {
            if (exercises.size() >= minExercises) break;
            if (used.contains(longValue(candidate.get("id")))) continue;
            Object last = candidate.get("lastWeightKg");
            exercises.add(
                    exercise(
                            candidate,
                            scheme[0],
                            scheme[1],
                            scheme[2],
                            scheme[3],
                            last == null ? null : decimal(last),
                            null));
        }
        return new WorkoutDraft(draft.title(), draft.rationale(), exercises);
    }

    /** {sets, repsMin, repsMax, restSeconds} for an intensity. */
    private static int[] scheme(String intensity) {
        return switch (intensity) {
            case "LIGHT" -> new int[] {3, 12, 15, 60};
            case "HARD" -> new int[] {4, 6, 10, 120};
            default -> new int[] {3, 8, 12, 90};
        };
    }

    private WorkoutDraft heuristicWorkout(
            List<Map<String, Object>> candidates,
            Set<String> muscles,
            int duration,
            String intensity,
            int minExercises) {
        int[] scheme = scheme(intensity);
        int sets = scheme[0];
        int repsMin = scheme[1];
        int repsMax = scheme[2];
        int rest = scheme[3];
        int count = Math.min(candidates.size(), Math.max(minExercises, clamp(duration / 10, 3, 8)));
        // Candidates are already ordered round-robin across muscles, recovered muscles first.
        List<Map<String, Object>> exercises = new ArrayList<>();
        for (Map<String, Object> candidate : candidates.subList(0, count)) {
            Object last = candidate.get("lastWeightKg");
            exercises.add(
                    exercise(
                            candidate,
                            sets,
                            repsMin,
                            repsMax,
                            rest,
                            last == null ? null : decimal(last),
                            null));
        }
        String focus = muscles.isEmpty() ? "toàn thân" : muscleNames(muscles);
        return new WorkoutDraft(
                "Buổi tập " + focus,
                "Gợi ý cơ bản: AI Coach tạm thời chưa phản hồi nên hệ thống chọn bài phù hợp thiết bị, "
                        + "nhóm cơ và trạng thái phục hồi của bạn.",
                exercises);
    }

    private static Map<String, Object> exercise(
            Map<String, Object> candidate,
            int sets,
            int repsMin,
            int repsMax,
            int rest,
            BigDecimal weight,
            String tip) {
        Map<String, Object> exercise = new LinkedHashMap<>();
        exercise.put("exerciseId", longValue(candidate.get("id")));
        exercise.put("name", candidate.get("name"));
        exercise.put("primaryMuscle", candidate.get("primaryMuscle"));
        exercise.put("equipment", candidate.get("equipment"));
        exercise.put("targetSets", sets);
        exercise.put("targetRepsMin", repsMin);
        exercise.put("targetRepsMax", repsMax);
        exercise.put("restSeconds", rest);
        exercise.put("targetWeightKg", weight);
        exercise.put("coachingTip", tip);
        return exercise;
    }

    /**
     * A target weight is only kept when the user has logged this exercise; it may progress at most
     * 5% above the heaviest recent set.
     */
    private static BigDecimal safeWeight(Object proposed, Object lastWeight) {
        if (lastWeight == null) return null;
        BigDecimal last = decimal(lastWeight);
        BigDecimal cap = roundToHalf(last.multiply(new BigDecimal("1.05")));
        if (proposed == null) return last;
        BigDecimal value = decimal(proposed);
        if (value.signum() <= 0) return last;
        return roundToHalf(value.min(cap));
    }

    private void insertWorkoutRecommendation(
            Long userId,
            Batch batch,
            LocalDate date,
            WorkoutDraft draft,
            String generatedBy,
            String safety,
            boolean personalized,
            String intensity,
            int duration) {
        int estimated = estimatedMinutes(draft.exercises());
        Map<String, Object> preview = new LinkedHashMap<>();
        preview.put("allowedAction", WORKOUT_ACTION);
        preview.put("targetDate", date.toString());
        preview.put("title", draft.title());
        preview.put("rationale", draft.rationale());
        preview.put("estimatedDurationMinutes", estimated);
        preview.put("exercises", draft.exercises());
        Map<String, Object> metrics = new LinkedHashMap<>();
        metrics.put("generatedBy", generatedBy);
        metrics.put("personalized", personalized);
        metrics.put("intensity", intensity);
        metrics.put("durationMinutes", duration);
        insertRecommendation(
                userId,
                batch,
                date,
                "WORKOUT",
                draft.title(),
                draft.rationale(),
                draft.exercises().size()
                        + " bài tập, khoảng "
                        + estimated
                        + " phút, cường độ "
                        + intensity
                        + ".",
                safety,
                WORKOUT_ACTION,
                preview,
                metrics);
    }

    private AiDtos.WorkoutPlan workoutReplay(Long userId, Batch batch) {
        StoredRecommendation row = storedRecommendations(userId, batch).getFirst();
        Map<String, Object> preview = row.preview();
        List<AiDtos.WorkoutPlanExercise> exercises =
                list(preview.get("exercises")).stream()
                        .map(
                                raw ->
                                        new AiDtos.WorkoutPlanExercise(
                                                longValue(raw.get("exerciseId")),
                                                (String) raw.get("name"),
                                                (String) raw.get("primaryMuscle"),
                                                raw.get("equipment") == null
                                                        ? List.of()
                                                        : List.of(
                                                                String.valueOf(raw.get("equipment"))
                                                                        .split(",")),
                                                intValue(raw.get("targetSets"), 3),
                                                intValue(raw.get("targetRepsMin"), 8),
                                                intValue(raw.get("targetRepsMax"), 12),
                                                intValue(raw.get("restSeconds"), 90),
                                                raw.get("targetWeightKg") == null
                                                        ? null
                                                        : decimal(raw.get("targetWeightKg")),
                                                (String) raw.get("coachingTip")))
                        .toList();
        return new AiDtos.WorkoutPlan(
                row.id(),
                row.version(),
                row.status(),
                LocalDate.parse(String.valueOf(preview.get("targetDate"))),
                String.valueOf(preview.get("title")),
                String.valueOf(preview.get("rationale")),
                intValue(preview.get("estimatedDurationMinutes"), 0),
                exercises,
                WORKOUT_ACTION,
                String.valueOf(row.metrics().get("generatedBy")),
                Boolean.TRUE.equals(row.metrics().get("personalized")),
                row.safety(),
                row.expiresAt());
    }

    // ---------------------------------------------------------------------------------------
    // Meals
    // ---------------------------------------------------------------------------------------

    public AiDtos.MealPlan generateMeals(
            Long userId, AiDtos.GenerateMeals request, String idempotencyKey) {
        validateIdempotencyKey(idempotencyKey);
        requireUser(userId);
        AiDtos.GenerateMeals input =
                request == null ? new AiDtos.GenerateMeals(null, null, null, null) : request;
        LocalDate date = targetDate(userId, input.targetDate());
        List<String> mealTypes = mealTypes(userId, date, input.mealTypes());
        Integer maxPrep = input.maxPrepTimeMinutes();
        if (maxPrep != null && (maxPrep < 5 || maxPrep > 180)) {
            invalid("maxPrepTimeMinutes", "must be between 5 and 180");
        }
        String customPrompt = input.customPrompt() == null ? "" : input.customPrompt().trim();
        if (AiPromptSafety.looksLikePromptInjection(customPrompt)) customPrompt = "";

        Map<String, Object> normalized = new LinkedHashMap<>();
        normalized.put("date", date.toString());
        normalized.put("mealTypes", mealTypes);
        normalized.put("maxPrep", maxPrep);
        normalized.put("prompt", customPrompt);
        Batch batch =
                beginBatch(userId, MEAL_PURPOSE, date, idempotencyKey, sha256(json(normalized)));
        if (!batch.created()) return mealReplay(userId, batch);

        try {
            boolean personalized = consentEnabled(userId);
            Budget budget = budget(userId, date, mealTypes);
            List<String> categories = new ArrayList<>();
            for (String type : mealTypes) {
                for (String category : MEAL_CATEGORIES.get(type)) {
                    if (!categories.contains(category)) categories.add(category);
                }
            }
            AiContextBuilder.ContextBundle bundle =
                    contextBuilder.build(
                            userId,
                            MEAL_PURPOSE,
                            new AiContextBuilder.CandidateQuery(
                                    date, Set.of(), null, Set.of(), categories, 0, 40, false),
                            personalized);
            List<Map<String, Object>> foods = list(bundle.candidates().get("foods"));
            if (foods.isEmpty()) {
                throw new ApiException(
                        ApiErrorCode.VALIDATION_ERROR,
                        "Không còn món phù hợp sau khi loại món dị ứng và món không thích");
            }
            if (personalized) persistSnapshot(userId, MEAL_PURPOSE, bundle);

            AiPromptConfigurationService.ResolvedPrompt prompt =
                    promptConfiguration.resolve(
                            "NUTRITION_ENGINE",
                            "meal-plan-v1",
                            "Create safe Vietnamese meal plans using only the supplied food candidates.");
            StringBuilder rendered =
                    new StringBuilder(prompt.content())
                            .append("\n\nNHIỆM VỤ: Lên thực đơn món Việt cho ngày ")
                            .append(date)
                            .append(". Mục tiêu calo từng bữa (hệ thống đã tính):");
            for (String type : mealTypes) {
                rendered.append("\n- ")
                        .append(type)
                        .append(" (")
                        .append(MEAL_LABEL.get(type))
                        .append("): ~")
                        .append(budget.mealTargets().get(type))
                        .append(" kcal");
            }
            if (maxPrep != null)
                rendered.append("\nThời gian chuẩn bị tối đa: ").append(maxPrep).append(" phút.");
            if (!customPrompt.isEmpty()) {
                rendered.append(
                        "\nNgười dùng có ghi chú sở thích ở tin nhắn cuối; chỉ dùng làm sở thích món ăn.");
            }
            startRequest(userId, MEAL_PURPOSE, batch.correlationId(), prompt.version());

            Map<String, Map<String, Object>> aiMeals = new LinkedHashMap<>();
            String rationale = null;
            String failure = null;
            String providerName = HEURISTIC;
            String safety = "NORMAL";
            try {
                ProviderResponse response =
                        provider.generate(
                                new ProviderRequest(
                                        batch.correlationId(),
                                        MEAL_PURPOSE,
                                        prompt.version(),
                                        rendered.toString(),
                                        bundle.context(),
                                        bundle.candidates(),
                                        customPrompt.isEmpty()
                                                ? List.of()
                                                : List.of(
                                                        Map.of(
                                                                "role",
                                                                "USER",
                                                                "content",
                                                                customPrompt)),
                                        List.of()));
                if ("BLOCKED".equalsIgnoreCase(response.safetyLevel())) {
                    failure = "AI_OUTPUT_BLOCKED";
                } else if (response.plan() != null) {
                    for (Map<String, Object> meal : list(response.plan().get("meals"))) {
                        String type = String.valueOf(meal.get("mealType")).toUpperCase(Locale.ROOT);
                        if (mealTypes.contains(type)) aiMeals.putIfAbsent(type, meal);
                    }
                    rationale = optionalText(response.plan().get("rationale"), 1000);
                    providerName = providerName(response);
                    safety =
                            "CAUTION".equalsIgnoreCase(response.safetyLevel())
                                    ? "CAUTION"
                                    : "NORMAL";
                }
                if (failure == null && aiMeals.isEmpty()) failure = "AI_OUTPUT_INVALID";
            } catch (ApiException exception) {
                failure = exception.code().name();
            }

            Map<Long, Map<String, Object>> foodsById = byId(foods);
            List<MealDraft> drafts = new ArrayList<>();
            Set<Long> used = new HashSet<>();
            for (String type : mealTypes) {
                int target = budget.mealTargets().get(type);
                MealDraft draft =
                        validateMeal(type, aiMeals.get(type), foodsById, target, providerName);
                if (draft == null) draft = heuristicMeal(type, foods, target, used, userId, date);
                if (draft != null) {
                    draft.items().forEach(item -> used.add(longValue(item.get("foodId"))));
                    drafts.add(draft);
                }
            }
            if (drafts.isEmpty()) {
                throw new ApiException(
                        ApiErrorCode.VALIDATION_ERROR, "Không đủ món phù hợp để lên thực đơn");
            }
            String finalRationale =
                    rationale != null
                            ? rationale
                            : "Thực đơn được cân theo lượng calo còn lại trong ngày của bạn.";
            String finalSafety = safety;
            transactions.executeWithoutResult(
                    status -> {
                        for (MealDraft draft : drafts) {
                            insertMealRecommendation(
                                    userId,
                                    batch,
                                    date,
                                    draft,
                                    finalSafety,
                                    personalized,
                                    finalRationale,
                                    budget.remainingBefore());
                        }
                        completeBatch(batch.id(), "SUCCEEDED");
                    });
            finishRequest(batch.correlationId(), failure == null ? "SUCCEEDED" : "FAILED", failure);
            return mealReplay(userId, batch);
        } catch (ApiException exception) {
            completeBatch(batch.id(), "FAILED");
            finishRequestIfStarted(batch.correlationId(), exception.code().name());
            throw exception;
        }
    }

    private MealDraft validateMeal(
            String type,
            Map<String, Object> meal,
            Map<Long, Map<String, Object>> foodsById,
            int target,
            String generatedBy) {
        if (meal == null) return null;
        List<Map<String, Object>> items = new ArrayList<>();
        Set<Long> seen = new HashSet<>();
        for (Map<String, Object> raw : list(meal.get("items"))) {
            Long id = longValue(raw.get("foodId"));
            if (id == null || !foodsById.containsKey(id) || !seen.add(id)) continue;
            BigDecimal multiplier =
                    clampServing(
                            raw.get("servingMultiplier") == null
                                    ? BigDecimal.ONE
                                    : decimal(raw.get("servingMultiplier")));
            items.add(item(foodsById.get(id), multiplier));
            if (items.size() == 4) break;
        }
        if (items.isEmpty()) return null;
        // The dish name is built from the chosen foods: the model's own name may mention
        // foods it did not actually pick.
        return new MealDraft(
                type,
                bounded(
                        items.stream()
                                .map(i -> String.valueOf(i.get("name")))
                                .collect(Collectors.joining(" + ")),
                        200),
                textOr(
                        meal.get("coachingReason"),
                        1000,
                        "Phù hợp mục tiêu " + MEAL_LABEL.get(type) + "."),
                target,
                scaleToTarget(items, target),
                generatedBy);
    }

    private MealDraft heuristicMeal(
            String type,
            List<Map<String, Object>> foods,
            int target,
            Set<Long> used,
            Long userId,
            LocalDate date) {
        List<Map<String, Object>> items = new ArrayList<>();
        int variety = Math.floorMod(Objects.hash(userId, date, type), 3);
        for (List<String> group : HEURISTIC_MEAL_GROUPS.get(type)) {
            List<Map<String, Object>> options =
                    foods.stream()
                            .filter(food -> group.contains(String.valueOf(food.get("category"))))
                            .filter(food -> !used.contains(longValue(food.get("id"))))
                            .filter(
                                    food ->
                                            items.stream()
                                                    .noneMatch(
                                                            i ->
                                                                    i.get("foodId")
                                                                            .equals(
                                                                                    longValue(
                                                                                            food
                                                                                                    .get(
                                                                                                            "id")))))
                            .sorted((a, b) -> Double.compare(proteinDensity(b), proteinDensity(a)))
                            .limit(3)
                            .toList();
            if (options.isEmpty()) continue;
            items.add(item(options.get(Math.min(variety, options.size() - 1)), BigDecimal.ONE));
        }
        if (items.isEmpty()) return null;
        return new MealDraft(
                type,
                bounded(
                        items.stream()
                                .map(i -> String.valueOf(i.get("name")))
                                .collect(Collectors.joining(" + ")),
                        200),
                "Gợi ý cơ bản cho "
                        + MEAL_LABEL.get(type)
                        + " khoảng "
                        + target
                        + " kcal, ưu tiên món giàu đạm.",
                target,
                scaleToTarget(items, target),
                HEURISTIC);
    }

    /**
     * Scales serving multipliers proportionally (step 0.25, between 0.25 and 2.5) when the meal
     * misses its calorie target by more than 10%; macros are then recomputed from the catalog.
     */
    private static List<Map<String, Object>> scaleToTarget(
            List<Map<String, Object>> items, int target) {
        BigDecimal total = sum(items, "calories");
        if (total.signum() <= 0 || target <= 0) return items;
        BigDecimal deviation =
                total.subtract(BigDecimal.valueOf(target))
                        .abs()
                        .divide(BigDecimal.valueOf(target), 4, RoundingMode.HALF_UP);
        if (deviation.compareTo(new BigDecimal("0.10")) <= 0) return items;
        BigDecimal factor = BigDecimal.valueOf(target).divide(total, 6, RoundingMode.HALF_UP);
        List<Map<String, Object>> scaled = new ArrayList<>();
        for (Map<String, Object> item : items) {
            BigDecimal multiplier =
                    clampServing(
                            roundToQuarter(
                                    decimal(item.get("servingMultiplier")).multiply(factor)));
            @SuppressWarnings("unchecked")
            Map<String, Object> food = (Map<String, Object>) item.get("_food");
            scaled.add(item(food, multiplier));
        }
        return scaled;
    }

    private static Map<String, Object> item(Map<String, Object> food, BigDecimal multiplier) {
        Map<String, Object> item = new LinkedHashMap<>();
        item.put("foodId", longValue(food.get("id")));
        item.put("name", food.get("name"));
        item.put("servingUnit", food.get("servingUnit"));
        item.put("servingMultiplier", multiplier);
        item.put("calories", scaled(food.get("caloriesKcal"), multiplier));
        item.put("protein", scaled(food.get("proteinG"), multiplier));
        item.put("carbs", scaled(food.get("carbsG"), multiplier));
        item.put("fat", scaled(food.get("fatG"), multiplier));
        item.put("_food", food);
        return item;
    }

    private void insertMealRecommendation(
            Long userId,
            Batch batch,
            LocalDate date,
            MealDraft draft,
            String safety,
            boolean personalized,
            String rationale,
            BigDecimal remainingBefore) {
        List<Map<String, Object>> entries = new ArrayList<>();
        for (Map<String, Object> item : draft.items()) {
            Map<String, Object> entry = new LinkedHashMap<>(item);
            entry.remove("_food");
            entries.add(entry);
        }
        Map<String, Object> preview = new LinkedHashMap<>();
        preview.put("allowedAction", AiCoachService.MEAL_PLAN_ACTION);
        preview.put("targetDate", date.toString());
        preview.put("mealType", draft.mealType());
        preview.put("dishName", draft.dishName());
        preview.put("entries", entries);
        Map<String, Object> metrics = new LinkedHashMap<>();
        metrics.put("generatedBy", draft.generatedBy());
        metrics.put("personalized", personalized);
        metrics.put("mealTargetCalories", draft.targetCalories());
        metrics.put("remainingCaloriesBeforePlan", remainingBefore);
        metrics.put("planRationale", rationale);
        insertRecommendation(
                userId,
                batch,
                date,
                "NUTRITION",
                draft.dishName(),
                draft.coachingReason(),
                "Mục tiêu "
                        + MEAL_LABEL.get(draft.mealType())
                        + " khoảng "
                        + draft.targetCalories()
                        + " kcal.",
                safety,
                AiCoachService.MEAL_PLAN_ACTION,
                preview,
                metrics);
    }

    private AiDtos.MealPlan mealReplay(Long userId, Batch batch) {
        List<StoredRecommendation> rows = storedRecommendations(userId, batch);
        List<AiDtos.MealPlanMeal> meals = new ArrayList<>();
        Set<String> sources = new LinkedHashSet<>();
        int target = 0;
        BigDecimal calories = BigDecimal.ZERO;
        BigDecimal protein = BigDecimal.ZERO;
        BigDecimal carbs = BigDecimal.ZERO;
        BigDecimal fat = BigDecimal.ZERO;
        for (StoredRecommendation row : rows) {
            List<Map<String, Object>> entries = list(row.preview().get("entries"));
            List<AiDtos.MealPlanItem> items =
                    entries.stream()
                            .map(
                                    raw ->
                                            new AiDtos.MealPlanItem(
                                                    longValue(raw.get("foodId")),
                                                    (String) raw.get("name"),
                                                    (String) raw.get("servingUnit"),
                                                    decimal(raw.get("servingMultiplier")),
                                                    decimal(raw.get("calories")),
                                                    decimal(raw.get("protein")),
                                                    decimal(raw.get("carbs")),
                                                    decimal(raw.get("fat"))))
                            .toList();
            BigDecimal mealCalories = sum(entries, "calories");
            BigDecimal mealProtein = sum(entries, "protein");
            BigDecimal mealCarbs = sum(entries, "carbs");
            BigDecimal mealFat = sum(entries, "fat");
            int mealTarget = intValue(row.metrics().get("mealTargetCalories"), 0);
            String generatedBy = String.valueOf(row.metrics().get("generatedBy"));
            sources.add(generatedBy);
            meals.add(
                    new AiDtos.MealPlanMeal(
                            row.id(),
                            row.version(),
                            row.status(),
                            String.valueOf(row.preview().get("mealType")),
                            String.valueOf(row.preview().get("dishName")),
                            row.content(),
                            mealTarget,
                            mealCalories,
                            mealProtein,
                            mealCarbs,
                            mealFat,
                            items,
                            generatedBy));
            target += mealTarget;
            calories = calories.add(mealCalories);
            protein = protein.add(mealProtein);
            carbs = carbs.add(mealCarbs);
            fat = fat.add(mealFat);
        }
        Map<String, Object> first = rows.getFirst().metrics();
        return new AiDtos.MealPlan(
                LocalDate.parse(String.valueOf(rows.getFirst().preview().get("targetDate"))),
                Boolean.TRUE.equals(first.get("personalized")),
                sources.size() == 1 ? sources.iterator().next() : "mixed",
                String.valueOf(first.get("planRationale")),
                new AiDtos.MealPlanSummary(
                        target,
                        calories,
                        protein,
                        carbs,
                        fat,
                        decimal(first.get("remainingCaloriesBeforePlan"))),
                meals,
                AiCoachService.MEAL_PLAN_ACTION,
                rows.getFirst().expiresAt());
    }

    private Budget budget(Long userId, LocalDate date, List<String> mealTypes) {
        Map<String, Object> target = contextBuilder.nutritionTarget(userId);
        BigDecimal daily =
                target.isEmpty() ? new BigDecimal("2000") : decimal(target.get("calories_kcal"));
        BigDecimal remaining =
                daily.subtract(contextBuilder.consumed(userId, date).get("calories"))
                        .max(BigDecimal.ZERO);
        double shareSum = mealTypes.stream().mapToDouble(MEAL_SHARE::get).sum();
        Map<String, Integer> targets = new LinkedHashMap<>();
        for (String type : mealTypes) {
            double share = MEAL_SHARE.get(type);
            double byShare = daily.doubleValue() * share;
            double byRemaining = remaining.doubleValue() * share / shareSum;
            targets.put(type, (int) Math.max(150, Math.round(Math.min(byShare, byRemaining))));
        }
        return new Budget(targets, remaining);
    }

    private List<String> mealTypes(Long userId, LocalDate date, List<String> requested) {
        if (requested != null && !requested.isEmpty()) {
            Set<String> types = new HashSet<>();
            for (String raw : requested) {
                String type = raw == null ? "" : raw.trim().toUpperCase(Locale.ROOT);
                if (!MEAL_ORDER.contains(type))
                    invalid("mealTypes", "must be BREAKFAST, LUNCH, DINNER or SNACK");
                types.add(type);
            }
            return MEAL_ORDER.stream().filter(types::contains).toList();
        }
        List<String> logged =
                jdbc.queryForList(
                        "select distinct m.meal_type from meals m join meal_plans p on p.id = m.meal_plan_id "
                                + "join meal_entries me on me.meal_id = m.id where p.user_id = ? and p.plan_date = ?",
                        String.class,
                        userId,
                        Date.valueOf(date));
        List<String> remaining =
                MEAL_ORDER.stream().filter(type -> !logged.contains(type)).toList();
        return remaining.isEmpty() ? MEAL_ORDER : remaining;
    }

    // ---------------------------------------------------------------------------------------
    // Shared persistence helpers
    // ---------------------------------------------------------------------------------------

    private Batch beginBatch(
            Long userId,
            String purpose,
            LocalDate date,
            String idempotencyKey,
            String requestHash) {
        Batch batch =
                transactions.execute(
                        status -> {
                            List<Batch> existing =
                                    jdbc.query(
                                            "select id, correlation_id, request_hash, status from ai_generation_batches "
                                                    + "where user_id = ? and idempotency_key = ?",
                                            (rs, row) ->
                                                    new Batch(
                                                            rs.getLong("id"),
                                                            rs.getString("correlation_id"),
                                                            false,
                                                            rs.getString("request_hash"),
                                                            rs.getString("status")),
                                            userId,
                                            idempotencyKey);
                            if (!existing.isEmpty()) return existing.getFirst();
                            Integer count =
                                    jdbc.queryForObject(
                                            "select count(*) from ai_generation_batches where user_id = ? "
                                                    + "and target_date = ? and purpose = ?",
                                            Integer.class,
                                            userId,
                                            Date.valueOf(date),
                                            purpose);
                            int generationNo = (count == null ? 0 : count) + 1;
                            if (generationNo > PLAN_GENERATIONS_PER_DAY) {
                                throw new ApiException(
                                        ApiErrorCode.DAILY_GENERATION_LIMIT_REACHED,
                                        "Đã đạt giới hạn "
                                                + PLAN_GENERATIONS_PER_DAY
                                                + " lần tạo kế hoạch cho ngày này");
                            }
                            String correlationId = UUID.randomUUID().toString();
                            Long id =
                                    jdbc.queryForObject(
                                            "insert into ai_generation_batches (user_id, purpose, target_date, generation_no, "
                                                    + "idempotency_key, request_hash, correlation_id) values (?, ?, ?, ?, ?, ?, ?) returning id",
                                            Long.class,
                                            userId,
                                            purpose,
                                            Date.valueOf(date),
                                            generationNo,
                                            idempotencyKey,
                                            requestHash,
                                            correlationId);
                            return new Batch(id, correlationId, true, requestHash, "STARTED");
                        });
        if (!batch.created()) {
            if (!batch.requestHash().equals(requestHash)) {
                throw new ApiException(
                        ApiErrorCode.IDEMPOTENCY_CONFLICT,
                        "Idempotency key was already used with another request");
            }
            if (!"SUCCEEDED".equals(batch.status())) {
                throw new ApiException(
                        ApiErrorCode.IDEMPOTENCY_CONFLICT,
                        "The previous request with this Idempotency-Key did not complete; use a new key");
            }
        }
        return batch;
    }

    private void insertRecommendation(
            Long userId,
            Batch batch,
            LocalDate date,
            String type,
            String title,
            String content,
            String reason,
            String safety,
            String action,
            Map<String, Object> preview,
            Map<String, Object> metrics) {
        OffsetDateTime expiresAt =
                date.plusDays(1).atStartOfDay(contextBuilder.zone(userId)).toOffsetDateTime();
        jdbc.update(
                "insert into ai_recommendations (generation_batch_id, user_id, recommendation_date, type, title, "
                        + "content, reason, priority, safety_level, allowed_action, action_preview, source_metrics, expires_at) "
                        + "values (?, ?, ?, ?, ?, ?, ?, 'MEDIUM', ?, ?, ?::jsonb, ?::jsonb, ?)",
                batch.id(),
                userId,
                Date.valueOf(date),
                type,
                bounded(title, 200),
                bounded(content, 4000),
                bounded(reason, 1000),
                safety,
                action,
                json(preview),
                json(metrics),
                Timestamp.from(expiresAt.toInstant()));
    }

    private List<StoredRecommendation> storedRecommendations(Long userId, Batch batch) {
        List<StoredRecommendation> rows =
                jdbc.query(
                        "select id, version, status, content, safety_level, action_preview::text preview, "
                                + "source_metrics::text metrics, expires_at from ai_recommendations "
                                + "where generation_batch_id = ? and user_id = ? order by id",
                        (rs, row) ->
                                new StoredRecommendation(
                                        rs.getLong("id"),
                                        rs.getInt("version"),
                                        rs.getString("status"),
                                        rs.getString("content"),
                                        rs.getString("safety_level"),
                                        parseMap(rs.getString("preview")),
                                        parseMap(rs.getString("metrics")),
                                        rs.getTimestamp("expires_at")
                                                .toInstant()
                                                .atOffset(ZoneOffset.UTC)),
                        batch.id(),
                        userId);
        if (rows.isEmpty()) {
            throw new ApiException(ApiErrorCode.RESOURCE_NOT_FOUND, "Generated plan not found");
        }
        return rows;
    }

    private void completeBatch(Long batchId, String status) {
        jdbc.update(
                "update ai_generation_batches set status = ?, completed_at = current_timestamp where id = ?",
                status,
                batchId);
    }

    private void persistSnapshot(
            Long userId, String purpose, AiContextBuilder.ContextBundle bundle) {
        jdbc.update(
                "insert into ai_context_snapshots (user_id, purpose, context_version, snapshot, expires_at) "
                        + "values (?, ?, 'context-v1', ?::jsonb, ?)",
                userId,
                purpose,
                json(bundle.context()),
                Timestamp.from(bundle.expiresAt().toInstant()));
    }

    private void startRequest(
            Long userId, String type, String correlationId, String promptVersion) {
        jdbc.update(
                "insert into ai_requests (user_id, request_type, correlation_id, prompt_version, status) "
                        + "values (?, ?, ?, ?, 'STARTED')",
                userId,
                type,
                correlationId,
                promptVersion);
    }

    private void finishRequest(String correlationId, String status, String failureCode) {
        jdbc.update(
                "update ai_requests set status = ?, failure_code = ?, completed_at = current_timestamp "
                        + "where correlation_id = ?",
                status,
                failureCode,
                correlationId);
    }

    private void finishRequestIfStarted(String correlationId, String failureCode) {
        finishRequest(correlationId, "FAILED", failureCode);
    }

    private boolean consentEnabled(Long userId) {
        List<String> rows =
                jdbc.queryForList(
                        "select mode from ai_consents where user_id = ?", String.class, userId);
        return !rows.isEmpty() && "ENABLED".equals(rows.getFirst());
    }

    private void requireUser(Long userId) {
        Integer count =
                jdbc.queryForObject(
                        "select count(*) from users where id = ? and deleted_at is null",
                        Integer.class,
                        userId);
        if (count == null || count == 0) {
            throw new ApiException(ApiErrorCode.RESOURCE_NOT_FOUND, "User not found");
        }
    }

    private LocalDate targetDate(Long userId, LocalDate requested) {
        LocalDate today = contextBuilder.today(userId);
        LocalDate date = requested == null ? today : requested;
        if (date.isBefore(today) || date.isAfter(today.plusDays(MAX_DAYS_AHEAD))) {
            invalid("targetDate", "must be between today and " + MAX_DAYS_AHEAD + " days ahead");
        }
        return date;
    }

    private Set<String> muscleCodes(List<String> requested) {
        if (requested == null || requested.isEmpty()) return Set.of();
        Set<String> codes = new LinkedHashSet<>();
        for (String raw : requested) {
            if (raw != null && !raw.isBlank()) codes.add(raw.trim().toUpperCase(Locale.ROOT));
        }
        Set<String> known =
                new HashSet<>(
                        jdbc.queryForList(
                                "select code from muscle_groups where is_active", String.class));
        if (!known.containsAll(codes))
            invalid("targetMuscles", "contains an unknown muscle group code");
        return codes;
    }

    private String muscleNames(Set<String> codes) {
        Map<String, String> names = new LinkedHashMap<>();
        for (Map<String, Object> row : jdbc.queryForList("select code, name from muscle_groups")) {
            names.put(String.valueOf(row.get("code")), String.valueOf(row.get("name")));
        }
        return codes.stream()
                .map(code -> names.getOrDefault(code, code))
                .collect(Collectors.joining(", "));
    }

    private Set<Long> equipmentIdsForCodes(List<String> codes) {
        if (codes == null || codes.isEmpty()) return Set.of();
        Set<String> wanted = new LinkedHashSet<>();
        for (String raw : codes) {
            if (raw != null && !raw.isBlank()) wanted.add(raw.trim().toUpperCase(Locale.ROOT));
        }
        Map<String, Long> known = new LinkedHashMap<>();
        for (Map<String, Object> row :
                jdbc.queryForList("select id, code from equipment where is_active")) {
            known.put(String.valueOf(row.get("code")), ((Number) row.get("id")).longValue());
        }
        if (!known.keySet().containsAll(wanted)) {
            invalid("equipmentCodes", "contains an unknown equipment code");
        }
        return wanted.stream().map(known::get).collect(Collectors.toCollection(LinkedHashSet::new));
    }

    private static Set<Long> positiveIds(List<Long> ids, String field) {
        if (ids == null) return Set.of();
        Set<Long> result = new LinkedHashSet<>();
        for (Long id : ids) {
            if (id == null || id <= 0) invalid(field, "must contain positive IDs");
            result.add(id);
        }
        return result;
    }

    private static String providerName(ProviderResponse response) {
        Object name =
                response.providerMetadata() == null
                        ? null
                        : response.providerMetadata().get("provider");
        return name == null ? "ai" : String.valueOf(name);
    }

    private static int estimatedMinutes(List<Map<String, Object>> exercises) {
        int seconds = 0;
        for (Map<String, Object> exercise : exercises) {
            int sets = intValue(exercise.get("targetSets"), 3);
            seconds += sets * (40 + intValue(exercise.get("restSeconds"), 90));
        }
        return Math.round(seconds / 60f) + 5;
    }

    private static Map<Long, Map<String, Object>> byId(List<Map<String, Object>> candidates) {
        Map<Long, Map<String, Object>> byId = new LinkedHashMap<>();
        for (Map<String, Object> candidate : candidates)
            byId.put(longValue(candidate.get("id")), candidate);
        return byId;
    }

    @SuppressWarnings("unchecked")
    private static List<Map<String, Object>> list(Object value) {
        if (!(value instanceof List<?> raw)) return List.of();
        List<Map<String, Object>> result = new ArrayList<>();
        for (Object item : raw) {
            if (item instanceof Map<?, ?> map) result.add((Map<String, Object>) map);
        }
        return result;
    }

    private static double proteinDensity(Map<String, Object> food) {
        double calories = Math.max(1, decimal(food.get("caloriesKcal")).doubleValue());
        return decimal(food.get("proteinG")).doubleValue() / calories;
    }

    private static BigDecimal sum(List<Map<String, Object>> items, String key) {
        return items.stream()
                .map(item -> decimal(item.get(key)))
                .reduce(BigDecimal.ZERO, BigDecimal::add)
                .setScale(1, RoundingMode.HALF_UP);
    }

    private static BigDecimal scaled(Object value, BigDecimal multiplier) {
        return decimal(value).multiply(multiplier).setScale(1, RoundingMode.HALF_UP);
    }

    private static BigDecimal clampServing(BigDecimal value) {
        return value.max(MIN_SERVING).min(MAX_SERVING).setScale(2, RoundingMode.HALF_UP);
    }

    private static BigDecimal roundToQuarter(BigDecimal value) {
        return value.multiply(BigDecimal.valueOf(4))
                .setScale(0, RoundingMode.HALF_UP)
                .divide(BigDecimal.valueOf(4));
    }

    private static BigDecimal roundToHalf(BigDecimal value) {
        return value.multiply(BigDecimal.valueOf(2))
                .setScale(0, RoundingMode.HALF_DOWN)
                .divide(BigDecimal.valueOf(2))
                .setScale(1, RoundingMode.HALF_UP);
    }

    private static BigDecimal decimal(Object value) {
        return AiContextBuilder.decimal(value);
    }

    private static Long longValue(Object value) {
        if (value instanceof Number number) return number.longValue();
        try {
            return value == null ? null : Long.parseLong(String.valueOf(value));
        } catch (NumberFormatException exception) {
            return null;
        }
    }

    private static int intValue(Object value, int fallback) {
        if (value instanceof Number number) return number.intValue();
        try {
            return value == null
                    ? fallback
                    : (int) Math.round(Double.parseDouble(String.valueOf(value)));
        } catch (NumberFormatException exception) {
            return fallback;
        }
    }

    private static int clamp(int value, int min, int max) {
        return Math.max(min, Math.min(max, value));
    }

    private static String optionalText(Object value, int max) {
        if (value == null) return null;
        String text = String.valueOf(value).trim();
        if (text.isEmpty()) return null;
        return text.length() > max ? text.substring(0, max) : text;
    }

    private static String textOr(Object value, int max, String fallback) {
        String text = optionalText(value, max);
        return text == null ? fallback : text;
    }

    private static String bounded(String value, int max) {
        String text = value == null ? "" : value.trim();
        return text.length() > max ? text.substring(0, max) : text;
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

    private static void validateIdempotencyKey(String key) {
        if (key == null || key.isBlank() || key.length() > 100) {
            throw new ApiException(
                    ApiErrorCode.VALIDATION_ERROR,
                    "Idempotency-Key is required and must not exceed 100 characters");
        }
    }

    private static void invalid(String field, String message) {
        throw new ApiException(ApiErrorCode.VALIDATION_ERROR, field + ": " + message);
    }

    private record Batch(
            Long id, String correlationId, boolean created, String requestHash, String status) {}

    private record WorkoutDraft(
            String title, String rationale, List<Map<String, Object>> exercises) {}

    private record MealDraft(
            String mealType,
            String dishName,
            String coachingReason,
            int targetCalories,
            List<Map<String, Object>> items,
            String generatedBy) {}

    private record Budget(Map<String, Integer> mealTargets, BigDecimal remainingBefore) {}

    private record StoredRecommendation(
            Long id,
            int version,
            String status,
            String content,
            String safety,
            Map<String, Object> preview,
            Map<String, Object> metrics,
            OffsetDateTime expiresAt) {}
}
