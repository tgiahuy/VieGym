package com.viegym.ai.application;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.viegym.common.error.ApiErrorCode;
import com.viegym.common.error.ApiException;
import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;
import java.time.Clock;
import java.time.Duration;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Random;
import java.util.Set;
import java.util.TreeMap;
import java.util.stream.Collectors;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

/**
 * Builds the minimal personal context and the candidate shortlist sent to the AI service.
 *
 * <p>Allergies and disliked foods are applied here as a hard filter on the food shortlist and are
 * never sent to the provider. Muscles trained less than {@value #RECOVERY_HOURS} hours ago are
 * reported as RECOVERING and their exercises are ranked last.
 */
@Component
public class AiContextBuilder {
    static final int RECOVERY_HOURS = 48;

    private final JdbcTemplate jdbc;
    private final ObjectMapper objectMapper;
    private final Clock clock;
    private final int maxBytes;

    public AiContextBuilder(
            JdbcTemplate jdbc,
            ObjectMapper objectMapper,
            Clock clock,
            @Value("${AI_MAX_CONTEXT_BYTES:16384}") int maxBytes) {
        this.jdbc = jdbc;
        this.objectMapper = objectMapper;
        this.clock = clock;
        this.maxBytes = maxBytes;
    }

    public ContextBundle build(Long userId, String purpose) {
        return build(userId, purpose, CandidateQuery.defaults(today(userId)), true);
    }

    public ContextBundle build(
            Long userId, String purpose, CandidateQuery query, boolean personalized) {
        Map<String, Object> data = new LinkedHashMap<>();
        List<Map<String, Object>> recovery = recovery(userId);
        List<String> injuries = injuries(userId);
        if (personalized) {
            addHealth(userId, data);
            Map<String, Object> target = addNutrition(userId, data);
            addToday(userId, query.date(), target, data);
            addWorkout(userId, data);
            if (!recovery.isEmpty()) data.put("recovery", recovery);
            if (!injuries.isEmpty()) data.put("injuries", injuries);
            addPreferences(userId, data);
        }
        Set<String> recovering =
                recovery.stream()
                        .filter(row -> "RECOVERING".equals(row.get("status")))
                        .map(row -> String.valueOf(row.get("muscle")))
                        .collect(Collectors.toSet());
        Map<String, Object> candidates = new LinkedHashMap<>();
        candidates.put("foods", foods(userId, query));
        candidates.put("exercises", exercises(userId, query, recovering, injuries, personalized));
        enforceBudget(data, candidates);
        return new ContextBundle(
                Map.of(
                        "contextVersion",
                        "context-v1",
                        "consentMode",
                        personalized ? "ENABLED" : "DISABLED",
                        "data",
                        data),
                candidates,
                OffsetDateTime.now(clock).plusDays(7));
    }

    public ContextBundle general() {
        return new ContextBundle(
                Map.of(
                        "contextVersion", "context-v1",
                        "consentMode", "DISABLED",
                        "data", Map.of()),
                Map.of("foods", List.of(), "exercises", List.of()),
                null);
    }

    /** Calories and macros already logged on {@code date}. */
    public Map<String, BigDecimal> consumed(Long userId, LocalDate date) {
        Map<String, Object> row =
                jdbc.queryForMap(
                        "select coalesce(sum(me.calories_snapshot), 0) calories, "
                                + "coalesce(sum(me.protein_g_snapshot), 0) protein, "
                                + "coalesce(sum(me.carbs_g_snapshot), 0) carbs, "
                                + "coalesce(sum(me.fat_g_snapshot), 0) fat "
                                + "from meal_entries me join meals m on m.id = me.meal_id "
                                + "join meal_plans p on p.id = m.meal_plan_id "
                                + "where p.user_id = ? and p.plan_date = ?",
                        userId,
                        Date.valueOf(date));
        Map<String, BigDecimal> result = new LinkedHashMap<>();
        row.forEach((key, value) -> result.put(key, decimal(value)));
        return result;
    }

    /** The user's nutrition target, or empty when the health profile is not set up yet. */
    public Map<String, Object> nutritionTarget(Long userId) {
        List<Map<String, Object>> rows =
                jdbc.queryForList(
                        "select calories_kcal, protein_g, carbs_g, fat_g "
                                + "from nutrition_targets where user_id = ?",
                        userId);
        return rows.isEmpty() ? Map.of() : rows.getFirst();
    }

    public LocalDate today(Long userId) {
        return LocalDate.now(clock.withZone(zone(userId)));
    }

    public ZoneId zone(Long userId) {
        List<String> zones =
                jdbc.queryForList(
                        "select timezone from user_profiles where user_id = ?",
                        String.class,
                        userId);
        return ZoneId.of(zones.isEmpty() ? "Asia/Ho_Chi_Minh" : zones.getFirst());
    }

    private void addHealth(Long userId, Map<String, Object> data) {
        List<Map<String, Object>> rows =
                jdbc.queryForList(
                        "select bmi, bmr_kcal, tdee_kcal, fitness_goal, training_experience "
                                + "from health_profiles where user_id = ?",
                        userId);
        if (!rows.isEmpty()) data.put("health", rows.getFirst());
    }

    private Map<String, Object> addNutrition(Long userId, Map<String, Object> data) {
        Map<String, Object> target = nutritionTarget(userId);
        if (!target.isEmpty()) data.put("nutritionTarget", target);
        return target;
    }

    private void addToday(
            Long userId, LocalDate date, Map<String, Object> target, Map<String, Object> data) {
        Map<String, BigDecimal> consumed = consumed(userId, date);
        Map<String, Object> today = new LinkedHashMap<>();
        today.put("date", date.toString());
        today.put("consumed", consumed);
        if (!target.isEmpty()) {
            Map<String, Object> remaining = new LinkedHashMap<>();
            remaining.put(
                    "calories",
                    decimal(target.get("calories_kcal")).subtract(consumed.get("calories")));
            remaining.put(
                    "protein", decimal(target.get("protein_g")).subtract(consumed.get("protein")));
            remaining.put("carbs", decimal(target.get("carbs_g")).subtract(consumed.get("carbs")));
            remaining.put("fat", decimal(target.get("fat_g")).subtract(consumed.get("fat")));
            today.put("remaining", remaining);
        }
        today.put(
                "loggedMealTypes",
                jdbc.queryForList(
                        "select distinct m.meal_type from meals m "
                                + "join meal_plans p on p.id = m.meal_plan_id "
                                + "join meal_entries me on me.meal_id = m.id "
                                + "where p.user_id = ? and p.plan_date = ? order by m.meal_type",
                        String.class,
                        userId,
                        Date.valueOf(date)));
        data.put("today", today);
    }

    private void addWorkout(Long userId, Map<String, Object> data) {
        Integer sessions =
                jdbc.queryForObject(
                        "select count(*) from workout_logs where user_id = ? "
                                + "and completed_at >= current_timestamp - interval '7 days'",
                        Integer.class,
                        userId);
        List<String> equipment =
                jdbc.queryForList(
                        "select e.code from user_equipment_preferences p "
                                + "join equipment e on e.id = p.equipment_id "
                                + "where p.user_id = ? order by e.code limit 30",
                        String.class,
                        userId);
        data.put(
                "workout",
                Map.of(
                        "recentSessions7d",
                        sessions == null ? 0 : sessions,
                        "equipment",
                        equipment));
    }

    private void addPreferences(Long userId, Map<String, Object> data) {
        List<Map<String, Object>> rows =
                jdbc.queryForList(
                        "select disliked_foods::text disliked_foods, meal_preferences::text meal_preferences, "
                                + "training_preferences::text training_preferences, preferred_training_time "
                                + "from user_preferences where user_id = ?",
                        userId);
        if (rows.isEmpty()) return;
        Map<String, Object> preferences = new LinkedHashMap<>();
        rows.getFirst()
                .forEach(
                        (key, value) ->
                                preferences.put(
                                        key,
                                        key.equals("preferred_training_time") || value == null
                                                ? value == null ? null : String.valueOf(value)
                                                : parseJson(String.valueOf(value))));
        data.put("preferences", preferences);
    }

    private Object parseJson(String json) {
        try {
            return objectMapper.readValue(json, Object.class);
        } catch (JsonProcessingException exception) {
            return null;
        }
    }

    private List<Map<String, Object>> recovery(Long userId) {
        OffsetDateTime now = OffsetDateTime.now(clock);
        return jdbc.query(
                "select mg.code, max(wl.completed_at) last_trained from workout_logs wl "
                        + "join workout_exercise_logs wel on wel.workout_log_id = wl.id "
                        + "join exercise_muscle_groups emg on emg.exercise_id = wel.exercise_id "
                        + "and emg.role = 'PRIMARY' "
                        + "join muscle_groups mg on mg.id = emg.muscle_group_id "
                        + "where wl.user_id = ? and wl.completed_at >= ? "
                        + "group by mg.code order by mg.code",
                (rs, row) -> {
                    Timestamp last = rs.getTimestamp("last_trained");
                    long hours =
                            Math.max(
                                    0,
                                    Duration.between(last.toInstant(), now.toInstant()).toHours());
                    Map<String, Object> item = new LinkedHashMap<>();
                    item.put("muscle", rs.getString("code"));
                    item.put("hoursSinceLastTrained", hours);
                    item.put("status", hours < RECOVERY_HOURS ? "RECOVERING" : "READY");
                    return item;
                },
                userId,
                Timestamp.from(now.minusDays(7).toInstant()));
    }

    /** Declared injury codes; applied as a hard exercise filter even without consent. */
    private List<String> injuries(Long userId) {
        List<String> rows =
                jdbc.queryForList(
                        "select injuries::text from user_preferences where user_id = ?",
                        String.class,
                        userId);
        return rows.isEmpty() ? List.of() : stringList(rows.getFirst());
    }

    private List<Map<String, Object>> exercises(
            Long userId,
            CandidateQuery query,
            Set<String> recovering,
            List<String> injuries,
            boolean personalized) {
        if (query.exerciseLimit() <= 0) return List.of();
        List<Object> args = new ArrayList<>();
        StringBuilder where = new StringBuilder("e.visibility = 'PUBLIC' and e.deleted_at is null");
        List<String> difficulties = difficulties(userId);
        where.append(" and e.difficulty in (")
                .append(placeholders(difficulties.size()))
                .append(')');
        args.addAll(difficulties);

        List<Long> equipment = availableEquipment(userId, query.equipmentIds());
        if (!equipment.isEmpty()) {
            where.append(
                            " and not exists (select 1 from exercise_equipment xe where xe.exercise_id = e.id "
                                    + "and xe.is_required and xe.equipment_id not in (")
                    .append(placeholders(equipment.size()))
                    .append("))");
            args.addAll(equipment);
        }
        if (!query.muscleCodes().isEmpty()) {
            where.append(
                            " and exists (select 1 from exercise_muscle_groups emg "
                                    + "join muscle_groups mg on mg.id = emg.muscle_group_id "
                                    + "where emg.exercise_id = e.id and emg.role = 'PRIMARY' and mg.code in (")
                    .append(placeholders(query.muscleCodes().size()))
                    .append("))");
            args.addAll(query.muscleCodes());
        }
        Set<String> injuredMuscles = InjuryExerciseRules.excludedMuscles(injuries);
        if (!injuredMuscles.isEmpty()) {
            where.append(
                            " and not exists (select 1 from exercise_muscle_groups emg "
                                    + "join muscle_groups mg on mg.id = emg.muscle_group_id "
                                    + "where emg.exercise_id = e.id and emg.role = 'PRIMARY' and mg.code in (")
                    .append(placeholders(injuredMuscles.size()))
                    .append("))");
            args.addAll(injuredMuscles);
        }
        for (String fragment : InjuryExerciseRules.excludedNameFragments(injuries)) {
            where.append(" and lower(e.name) not like ?");
            args.add("%" + fragment + "%");
        }
        if (!query.excludedExerciseIds().isEmpty()) {
            where.append(" and e.id not in (")
                    .append(placeholders(query.excludedExerciseIds().size()))
                    .append(')');
            args.addAll(query.excludedExerciseIds());
        }

        List<String> deprioritized =
                query.preferRecoveredMuscles() ? List.copyOf(recovering) : List.of();
        String recoveringCase =
                deprioritized.isEmpty()
                        ? "0"
                        : "case when b.primary_muscle in ("
                                + placeholders(deprioritized.size())
                                + ") then 1 else 0 end";
        String seed = userId + ":" + query.date();
        List<Object> rankArgs = new ArrayList<>(deprioritized);
        rankArgs.add(seed);

        // Round-robin across primary muscles (rn) so one muscle cannot crowd out the others;
        // md5(id || seed) gives a stable, per-user-per-day variety.
        String ranked =
                "select b.*, "
                        + recoveringCase
                        + " as recovering, row_number() over (partition by b.primary_muscle "
                        + "order by md5(b.id::text || ?)) as rn from ("
                        + "select e.id, e.name, e.difficulty, "
                        + "coalesce((select mg.code from exercise_muscle_groups emg "
                        + "join muscle_groups mg on mg.id = emg.muscle_group_id "
                        + "where emg.exercise_id = e.id and emg.role = 'PRIMARY' "
                        + "order by mg.code limit 1), 'GENERAL') as primary_muscle, "
                        + "(select string_agg(eq.code, ',' order by eq.code) from exercise_equipment xe "
                        + "join equipment eq on eq.id = xe.equipment_id "
                        + "where xe.exercise_id = e.id and xe.is_required) as equipment "
                        + "from exercises e where "
                        + where
                        + ") b";
        String lastWeight =
                personalized
                        ? "(select max(s.weight_kg) from workout_set_logs s "
                                + "join workout_exercise_logs wel on wel.id = s.workout_exercise_log_id "
                                + "join workout_logs wl on wl.id = wel.workout_log_id "
                                + "where wl.user_id = ? and wel.exercise_id = x.id and s.completed "
                                + "and s.weight_kg > 0 and wl.completed_at >= current_timestamp - interval '90 days')"
                        : "null";
        String sql =
                "select x.id, x.name, x.difficulty, x.primary_muscle, x.equipment, "
                        + lastWeight
                        + " as last_weight_kg from (select * from ("
                        + ranked
                        + ") r order by r.recovering, r.rn, r.id limit ?) x "
                        + "order by x.recovering, x.rn, x.id";

        List<Object> all = new ArrayList<>();
        if (personalized) all.add(userId);
        all.addAll(rankArgs);
        all.addAll(args);
        all.add(query.exerciseLimit());
        return jdbc.query(
                sql,
                (rs, row) -> {
                    Map<String, Object> item = new LinkedHashMap<>();
                    item.put("id", rs.getLong("id"));
                    item.put("name", rs.getString("name"));
                    item.put("difficulty", rs.getString("difficulty"));
                    item.put("primaryMuscle", rs.getString("primary_muscle"));
                    String equipmentCodes = rs.getString("equipment");
                    item.put("equipment", equipmentCodes == null ? "BODYWEIGHT" : equipmentCodes);
                    BigDecimal weight = rs.getBigDecimal("last_weight_kg");
                    if (weight != null) item.put("lastWeightKg", weight);
                    return item;
                },
                all.toArray());
    }

    private List<Map<String, Object>> foods(Long userId, CandidateQuery query) {
        if (query.foodLimit() <= 0) return List.of();
        FoodExclusionMatcher exclusions = exclusions(userId);
        List<Map<String, Object>> rows =
                jdbc.queryForList(
                        "select id, name, search_name, category, serving_unit, calories_per_serving, "
                                + "protein_g_per_serving, carbs_g_per_serving, fat_g_per_serving "
                                + "from foods where visibility = 'PUBLIC' and deleted_at is null order by id");
        Random random = new Random(Objects.hash(userId, query.date()));
        Map<String, List<Map<String, Object>>> byCategory = new TreeMap<>();
        Map<Object, Double> score = new LinkedHashMap<>();
        for (Map<String, Object> row : rows) {
            String category = String.valueOf(row.get("category"));
            if (!query.foodCategories().isEmpty() && !query.foodCategories().contains(category)) {
                continue;
            }
            if (exclusions.excludes(
                    String.valueOf(row.get("name")), (String) row.get("search_name"))) {
                continue;
            }
            double calories = Math.max(1, decimal(row.get("calories_per_serving")).doubleValue());
            double protein = decimal(row.get("protein_g_per_serving")).doubleValue();
            // Protein density with a little per-day jitter so the shortlist varies.
            score.put(row.get("id"), protein / calories * (0.6 + 0.8 * random.nextDouble()));
            byCategory.computeIfAbsent(category, key -> new ArrayList<>()).add(row);
        }
        List<List<Map<String, Object>>> buckets = new ArrayList<>();
        List<String> order =
                query.foodCategories().isEmpty()
                        ? List.copyOf(byCategory.keySet())
                        : query.foodCategories();
        for (String category : order) {
            List<Map<String, Object>> bucket = byCategory.getOrDefault(category, List.of());
            List<Map<String, Object>> sorted = new ArrayList<>(bucket);
            sorted.sort(
                    Comparator.comparingDouble(
                                    (Map<String, Object> row) -> score.get(row.get("id")))
                            .reversed());
            buckets.add(sorted);
        }
        List<Map<String, Object>> result = new ArrayList<>();
        for (int index = 0; result.size() < query.foodLimit(); index++) {
            boolean added = false;
            for (List<Map<String, Object>> bucket : buckets) {
                if (index < bucket.size() && result.size() < query.foodLimit()) {
                    result.add(food(bucket.get(index)));
                    added = true;
                }
            }
            if (!added) break;
        }
        return result;
    }

    private static Map<String, Object> food(Map<String, Object> row) {
        Map<String, Object> item = new LinkedHashMap<>();
        item.put("id", ((Number) row.get("id")).longValue());
        item.put("name", row.get("name"));
        item.put("category", row.get("category"));
        item.put("servingUnit", row.get("serving_unit"));
        item.put("caloriesKcal", row.get("calories_per_serving"));
        item.put("proteinG", row.get("protein_g_per_serving"));
        item.put("carbsG", row.get("carbs_g_per_serving"));
        item.put("fatG", row.get("fat_g_per_serving"));
        return item;
    }

    private FoodExclusionMatcher exclusions(Long userId) {
        List<Map<String, Object>> rows =
                jdbc.queryForList(
                        "select allergies::text allergies, disliked_foods::text disliked "
                                + "from user_preferences where user_id = ?",
                        userId);
        if (rows.isEmpty()) return new FoodExclusionMatcher(List.of(), List.of());
        return new FoodExclusionMatcher(
                stringList(rows.getFirst().get("allergies")),
                stringList(rows.getFirst().get("disliked")));
    }

    private List<String> difficulties(Long userId) {
        List<String> rows =
                jdbc.queryForList(
                        "select training_experience from health_profiles where user_id = ?",
                        String.class,
                        userId);
        String experience = rows.isEmpty() ? "ADVANCED" : rows.getFirst();
        return switch (experience) {
            case "BEGINNER" -> List.of("BEGINNER");
            case "INTERMEDIATE" -> List.of("BEGINNER", "INTERMEDIATE");
            default -> List.of("BEGINNER", "INTERMEDIATE", "ADVANCED");
        };
    }

    /** Empty list = no equipment filter (user never configured equipment). */
    private List<Long> availableEquipment(Long userId, Set<Long> requested) {
        List<Long> equipment =
                requested != null
                        ? new ArrayList<>(requested)
                        : jdbc.queryForList(
                                "select equipment_id from user_equipment_preferences where user_id = ?",
                                Long.class,
                                userId);
        if (equipment.isEmpty()) return List.of();
        equipment.addAll(
                jdbc.queryForList(
                        "select id from equipment where code = 'BODYWEIGHT'", Long.class));
        return equipment.stream().distinct().toList();
    }

    private List<String> stringList(Object json) {
        if (json == null) return List.of();
        try {
            List<Object> values =
                    objectMapper.readValue(String.valueOf(json), new TypeReference<>() {});
            return values.stream().filter(Objects::nonNull).map(String::valueOf).toList();
        } catch (JsonProcessingException exception) {
            return List.of();
        }
    }

    private void enforceBudget(Map<String, Object> data, Map<String, Object> candidates) {
        try {
            int bytes =
                    objectMapper.writeValueAsBytes(Map.of("data", data, "candidates", candidates))
                            .length;
            if (bytes > maxBytes) {
                throw new ApiException(
                        ApiErrorCode.AI_OUTPUT_INVALID, "AI context exceeds the configured budget");
            }
        } catch (JsonProcessingException exception) {
            throw new ApiException(ApiErrorCode.INTERNAL_ERROR, "Could not serialize AI context");
        }
    }

    private static String placeholders(int count) {
        return String.join(", ", Collections.nCopies(count, "?"));
    }

    static BigDecimal decimal(Object value) {
        if (value == null) return BigDecimal.ZERO;
        if (value instanceof BigDecimal decimal) return decimal;
        return new BigDecimal(String.valueOf(value));
    }

    /**
     * What to shortlist. {@code equipmentIds == null} means "use the user's saved equipment"; empty
     * muscle/category sets mean "no filter".
     */
    public record CandidateQuery(
            LocalDate date,
            Set<String> muscleCodes,
            Set<Long> equipmentIds,
            Set<Long> excludedExerciseIds,
            List<String> foodCategories,
            int exerciseLimit,
            int foodLimit,
            boolean preferRecoveredMuscles) {
        public static CandidateQuery defaults(LocalDate date) {
            return new CandidateQuery(date, Set.of(), null, Set.of(), List.of(), 15, 20, true);
        }
    }

    public record ContextBundle(
            Map<String, Object> context,
            Map<String, Object> candidates,
            OffsetDateTime expiresAt) {}
}
