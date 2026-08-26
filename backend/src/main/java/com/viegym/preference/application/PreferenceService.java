package com.viegym.preference.application;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.viegym.common.api.FieldViolation;
import com.viegym.common.error.ApiValidationException;
import com.viegym.preference.api.EquipmentPreferenceRequest;
import com.viegym.preference.api.EquipmentPreferenceResponse;
import com.viegym.preference.api.PreferenceRequest;
import com.viegym.preference.api.PreferenceResponse;
import java.sql.Time;
import java.time.LocalTime;
import java.time.OffsetDateTime;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class PreferenceService {

    private static final TypeReference<List<String>> STRING_LIST = new TypeReference<>() {};
    private static final TypeReference<Map<String, Object>> OBJECT_MAP = new TypeReference<>() {};
    private static final int MAX_LIST_ITEMS = 100;
    private static final int MAX_ITEM_LENGTH = 120;

    private final JdbcTemplate jdbc;
    private final ObjectMapper objectMapper;

    public PreferenceService(JdbcTemplate jdbc, ObjectMapper objectMapper) {
        this.jdbc = jdbc;
        this.objectMapper = objectMapper;
    }

    @Transactional(readOnly = true)
    public PreferenceResponse get(Long userId) {
        return jdbc
                .query(
                        """
                        select disliked_foods::text, allergies::text, dietary_constraints::text,
                               meal_preferences::text, training_preferences::text,
                               preferred_training_time
                        from user_preferences where user_id = ?
                        """,
                        (rs, row) ->
                                new PreferenceResponse(
                                        readList(rs.getString(1)),
                                        readList(rs.getString(2)),
                                        readList(rs.getString(3)),
                                        readMap(rs.getString(4)),
                                        readMap(rs.getString(5)),
                                        rs.getObject(6, LocalTime.class)),
                        userId)
                .stream()
                .findFirst()
                .orElseGet(PreferenceService::emptyPreference);
    }

    @Transactional
    public PreferenceResponse replace(Long userId, PreferenceRequest request) {
        PreferenceResponse normalized = validate(request);
        jdbc.update(
                """
                insert into user_preferences(
                  user_id, disliked_foods, allergies, dietary_constraints, meal_preferences,
                  training_preferences, preferred_training_time)
                values (?, ?::jsonb, ?::jsonb, ?::jsonb, ?::jsonb, ?::jsonb, ?)
                on conflict (user_id) do update set
                  disliked_foods = excluded.disliked_foods,
                  allergies = excluded.allergies,
                  dietary_constraints = excluded.dietary_constraints,
                  meal_preferences = excluded.meal_preferences,
                  training_preferences = excluded.training_preferences,
                  preferred_training_time = excluded.preferred_training_time,
                  updated_at = now()
                """,
                userId,
                write(normalized.dislikedFoods()),
                write(normalized.allergies()),
                write(normalized.dietaryConstraints()),
                write(normalized.mealPreferences()),
                write(normalized.trainingPreferences()),
                normalized.preferredTrainingTime() == null
                        ? null
                        : Time.valueOf(normalized.preferredTrainingTime()));
        return normalized;
    }

    @Transactional(readOnly = true)
    public EquipmentPreferenceResponse getEquipment(Long userId) {
        List<Long> selected =
                jdbc.queryForList(
                        "select equipment_id from user_equipment_preferences where user_id = ? order by equipment_id",
                        Long.class,
                        userId);
        Set<Long> selectedSet = Set.copyOf(selected);
        List<EquipmentPreferenceResponse.EquipmentItem> catalog =
                jdbc.query(
                        "select id, code, name from equipment where is_active = true order by id",
                        (rs, row) ->
                                new EquipmentPreferenceResponse.EquipmentItem(
                                        rs.getLong("id"),
                                        rs.getString("code"),
                                        rs.getString("name"),
                                        selectedSet.contains(rs.getLong("id"))));
        OffsetDateTime completed =
                jdbc
                        .query(
                                "select equipment_onboarding_completed_at from user_preferences where user_id = ?",
                                (rs, row) ->
                                        rs.getObject(
                                                "equipment_onboarding_completed_at",
                                                OffsetDateTime.class),
                                userId)
                        .stream()
                        .findFirst()
                        .orElse(null);
        return new EquipmentPreferenceResponse(selected, catalog, completed);
    }

    @Transactional
    public EquipmentPreferenceResponse replaceEquipment(
            Long userId, EquipmentPreferenceRequest request) {
        List<Long> ids = validateEquipment(request);
        if (!ids.isEmpty()) {
            String placeholders = String.join(",", java.util.Collections.nCopies(ids.size(), "?"));
            Integer activeCount =
                    jdbc.queryForObject(
                            "select count(*) from equipment where is_active = true and id in ("
                                    + placeholders
                                    + ")",
                            Integer.class,
                            ids.toArray());
            if (activeCount == null || activeCount != ids.size()) {
                throw new ApiValidationException(
                        List.of(
                                new FieldViolation(
                                        "equipmentIds",
                                        "UNKNOWN_EQUIPMENT",
                                        "equipmentIds must reference active equipment")));
            }
        }
        jdbc.update("delete from user_equipment_preferences where user_id = ?", userId);
        for (Long id : ids) {
            jdbc.update(
                    "insert into user_equipment_preferences(user_id, equipment_id) values (?, ?)",
                    userId,
                    id);
        }
        jdbc.update(
                """
                insert into user_preferences(user_id, equipment_onboarding_completed_at)
                values (?, now())
                on conflict (user_id) do update set
                  equipment_onboarding_completed_at = excluded.equipment_onboarding_completed_at,
                  updated_at = now()
                """,
                userId);
        return getEquipment(userId);
    }

    private PreferenceResponse validate(PreferenceRequest request) {
        if (request == null) {
            throw validation("preferences", "REQUIRED", "Preference document is required");
        }
        return new PreferenceResponse(
                validateList(request.dislikedFoods(), "dislikedFoods"),
                validateList(request.allergies(), "allergies"),
                validateList(request.dietaryConstraints(), "dietaryConstraints"),
                request.mealPreferences() == null
                        ? Map.of()
                        : java.util.Collections.unmodifiableMap(
                                new LinkedHashMap<>(request.mealPreferences())),
                request.trainingPreferences() == null
                        ? Map.of()
                        : java.util.Collections.unmodifiableMap(
                                new LinkedHashMap<>(request.trainingPreferences())),
                request.preferredTrainingTime());
    }

    private List<Long> validateEquipment(EquipmentPreferenceRequest request) {
        if (request == null || request.equipmentIds() == null) {
            throw validation("equipmentIds", "REQUIRED", "equipmentIds is required");
        }
        LinkedHashSet<Long> unique = new LinkedHashSet<>();
        for (Long id : request.equipmentIds()) {
            if (id == null || id <= 0 || !unique.add(id)) {
                throw validation(
                        "equipmentIds", "INVALID", "equipmentIds must contain unique positive IDs");
            }
        }
        return List.copyOf(unique);
    }

    private List<String> validateList(List<String> values, String field) {
        if (values == null) {
            return List.of();
        }
        if (values.size() > MAX_LIST_ITEMS) {
            throw validation(field, "SIZE", field + " must contain at most 100 items");
        }
        LinkedHashSet<String> normalized = new LinkedHashSet<>();
        for (String value : values) {
            if (value == null || value.isBlank() || value.trim().length() > MAX_ITEM_LENGTH) {
                throw validation(field, "INVALID", field + " contains an invalid value");
            }
            normalized.add(value.trim());
        }
        return List.copyOf(normalized);
    }

    private ApiValidationException validation(String field, String code, String message) {
        return new ApiValidationException(List.of(new FieldViolation(field, code, message)));
    }

    private String write(Object value) {
        try {
            return objectMapper.writeValueAsString(value);
        } catch (JsonProcessingException exception) {
            throw new IllegalStateException("Unable to serialize validated preference", exception);
        }
    }

    private List<String> readList(String json) {
        try {
            return objectMapper.readValue(json, STRING_LIST);
        } catch (JsonProcessingException exception) {
            throw new IllegalStateException("Invalid stored preference list", exception);
        }
    }

    private Map<String, Object> readMap(String json) {
        try {
            return new LinkedHashMap<>(objectMapper.readValue(json, OBJECT_MAP));
        } catch (JsonProcessingException exception) {
            throw new IllegalStateException("Invalid stored preference object", exception);
        }
    }

    private static PreferenceResponse emptyPreference() {
        return new PreferenceResponse(List.of(), List.of(), List.of(), Map.of(), Map.of(), null);
    }
}
