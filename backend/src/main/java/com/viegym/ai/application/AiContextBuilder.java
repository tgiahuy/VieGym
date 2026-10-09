package com.viegym.ai.application;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.viegym.common.error.ApiErrorCode;
import com.viegym.common.error.ApiException;
import java.time.Clock;
import java.time.OffsetDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

@Component
public class AiContextBuilder {
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
        Map<String, Object> data = new LinkedHashMap<>();
        addHealth(userId, data);
        addNutrition(userId, data);
        addWorkout(userId, data);
        addPreferences(userId, data);
        Map<String, Object> candidates = candidates();
        enforceBudget(data, candidates);
        return new ContextBundle(
                Map.of(
                        "contextVersion", "context-v1",
                        "consentMode", "ENABLED",
                        "data", data),
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

    private void addHealth(Long userId, Map<String, Object> data) {
        List<Map<String, Object>> rows =
                jdbc.queryForList(
                        "select bmi, bmr_kcal, tdee_kcal, fitness_goal, training_experience "
                                + "from health_profiles where user_id = ?",
                        userId);
        if (!rows.isEmpty()) data.put("health", rows.getFirst());
    }

    private void addNutrition(Long userId, Map<String, Object> data) {
        List<Map<String, Object>> rows =
                jdbc.queryForList(
                        "select calories_kcal, protein_g, carbs_g, fat_g "
                                + "from nutrition_targets where user_id = ?",
                        userId);
        if (!rows.isEmpty()) data.put("nutritionTarget", rows.getFirst());
    }

    private void addWorkout(Long userId, Map<String, Object> data) {
        Integer sessions =
                jdbc.queryForObject(
                        "select count(*) from workout_logs where user_id = ? "
                                + "and completed_at >= current_timestamp - interval '7 days'",
                        Integer.class,
                        userId);
        List<Long> equipment =
                jdbc.queryForList(
                        "select equipment_id from user_equipment_preferences where user_id = ? "
                                + "order by equipment_id limit 30",
                        Long.class,
                        userId);
        data.put(
                "workout",
                Map.of(
                        "recentSessions7d",
                        sessions == null ? 0 : sessions,
                        "equipmentIds",
                        equipment));
    }

    private void addPreferences(Long userId, Map<String, Object> data) {
        List<Map<String, Object>> rows =
                jdbc.queryForList(
                        "select disliked_foods, meal_preferences, training_preferences, "
                                + "preferred_training_time from user_preferences where user_id = ?",
                        userId);
        if (!rows.isEmpty()) data.put("preferences", rows.getFirst());
    }

    private Map<String, Object> candidates() {
        List<Map<String, Object>> foods =
                jdbc.queryForList(
                        "select id, name, serving_unit, calories_per_serving as calories_kcal, "
                                + "protein_g_per_serving as protein_g from foods "
                                + "where visibility = 'PUBLIC' and deleted_at is null order by id limit 12");
        List<Map<String, Object>> exercises =
                jdbc.queryForList(
                        "select id, name, difficulty from exercises "
                                + "where visibility = 'PUBLIC' and deleted_at is null order by id limit 12");
        return Map.of("foods", foods, "exercises", exercises);
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

    public record ContextBundle(
            Map<String, Object> context,
            Map<String, Object> candidates,
            OffsetDateTime expiresAt) {}
}
