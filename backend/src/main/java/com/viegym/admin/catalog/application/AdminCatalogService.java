package com.viegym.admin.catalog.application;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.viegym.admin.audit.application.AdminAuditService;
import com.viegym.admin.catalog.api.AdminCatalogDtos.EquipmentInput;
import com.viegym.admin.catalog.api.AdminCatalogDtos.Exercise;
import com.viegym.admin.catalog.api.AdminCatalogDtos.ExerciseRequest;
import com.viegym.admin.catalog.api.AdminCatalogDtos.Food;
import com.viegym.admin.catalog.api.AdminCatalogDtos.FoodRequest;
import com.viegym.admin.catalog.api.AdminCatalogDtos.MuscleInput;
import com.viegym.common.api.PageResponse;
import com.viegym.common.error.ApiErrorCode;
import com.viegym.common.error.ApiException;
import java.math.BigDecimal;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AdminCatalogService {
    private static final TypeReference<List<String>> STRING_LIST = new TypeReference<>() {};
    private static final Set<String> DIFFICULTIES = Set.of("BEGINNER", "INTERMEDIATE", "ADVANCED");
    private static final Set<String> VISIBILITIES = Set.of("PUBLIC", "HIDDEN");

    private final JdbcTemplate jdbc;
    private final ObjectMapper mapper;
    private final AdminAuditService audit;

    public AdminCatalogService(JdbcTemplate jdbc, ObjectMapper mapper, AdminAuditService audit) {
        this.jdbc = jdbc;
        this.mapper = mapper;
        this.audit = audit;
    }

    @Transactional(readOnly = true)
    public PageResponse<Exercise> listExercises(
            String q, String difficulty, String visibility, Pageable page) {
        StringBuilder where = new StringBuilder("where deleted_at is null ");
        List<Object> params = new ArrayList<>();
        if (q != null && !q.isBlank()) {
            where.append("and (lower(name) like ? or lower(slug) like ?) ");
            params.add("%" + q.trim().toLowerCase(Locale.ROOT) + "%");
            params.add("%" + q.trim().toLowerCase(Locale.ROOT) + "%");
        }
        if (difficulty != null && !difficulty.isBlank()) {
            where.append("and difficulty = ? ");
            params.add(difficulty.toUpperCase(Locale.ROOT));
        }
        if (visibility != null && !visibility.isBlank()) {
            where.append("and visibility = ? ");
            params.add(visibility.toUpperCase(Locale.ROOT));
        }
        long total =
                jdbc.queryForObject(
                        "select count(*) from exercises " + where, Long.class, params.toArray());
        params.add(page.getPageSize());
        params.add(page.getOffset());
        List<Exercise> rows =
                jdbc.query(
                        "select * from exercises "
                                + where
                                + "order by updated_at desc, id desc limit ? offset ?",
                        this::mapExercise,
                        params.toArray());
        return PageResponse.from(new PageImpl<>(rows, page, total));
    }

    @Transactional(readOnly = true)
    public Exercise getExercise(long id) {
        List<Exercise> rows =
                jdbc.query(
                        "select * from exercises where id = ? and deleted_at is null",
                        this::mapExercise,
                        id);
        if (rows.isEmpty())
            throw new ApiException(ApiErrorCode.EXERCISE_NOT_FOUND, "Exercise not found");
        return rows.getFirst();
    }

    @Transactional
    public Exercise createExercise(long adminId, ExerciseRequest request) {
        validate(request);
        KeyHolder key = new GeneratedKeyHolder();
        try {
            jdbc.update(
                    connection -> {
                        var statement =
                                connection.prepareStatement(
                                        "insert into exercises (name, search_name, slug, difficulty, description, instruction_steps, common_mistakes, safety_notes, visibility, created_by) values (?, ?, ?, ?, ?, ?::jsonb, ?::jsonb, ?::jsonb, ?, ?)",
                                        new String[] {"id"});
                        statement.setString(1, request.name().trim());
                        statement.setString(2, normalizeSearch(request.name()));
                        statement.setString(3, request.slug().trim().toLowerCase(Locale.ROOT));
                        statement.setString(4, upper(request.difficulty()));
                        statement.setString(5, request.description().trim());
                        statement.setString(6, json(list(request.instructionSteps())));
                        statement.setString(7, json(list(request.commonMistakes())));
                        statement.setString(8, json(list(request.safetyNotes())));
                        statement.setString(9, visibility(request.visibility()));
                        statement.setLong(10, adminId);
                        return statement;
                    },
                    key);
        } catch (DuplicateKeyException e) {
            throw new ApiException(
                    ApiErrorCode.INVALID_STATE_TRANSITION, "Exercise slug already exists");
        }
        long id = key.getKey().longValue();
        replaceExerciseRelations(id, request);
        audit.record(
                adminId,
                "ADMIN",
                "CREATE",
                "EXERCISE",
                id,
                "SUCCESS",
                Map.of("name", request.name(), "visibility", visibility(request.visibility())));
        return getExercise(id);
    }

    @Transactional
    public Exercise updateExercise(long adminId, long id, ExerciseRequest request) {
        validate(request);
        long expected = request.version() == null ? -1 : request.version();
        int updated =
                jdbc.update(
                        "update exercises set name=?, search_name=?, slug=?, difficulty=?, description=?, instruction_steps=?::jsonb, common_mistakes=?::jsonb, safety_notes=?::jsonb, visibility=?, version=version+1, updated_at=current_timestamp where id=? and deleted_at is null and (? < 0 or version=?)",
                        request.name().trim(),
                        normalizeSearch(request.name()),
                        request.slug().trim().toLowerCase(Locale.ROOT),
                        upper(request.difficulty()),
                        request.description().trim(),
                        json(list(request.instructionSteps())),
                        json(list(request.commonMistakes())),
                        json(list(request.safetyNotes())),
                        visibility(request.visibility()),
                        id,
                        expected,
                        expected);
        if (updated == 0) conflictOrMissing("Exercise", id);
        replaceExerciseRelations(id, request);
        audit.record(
                adminId, "ADMIN", "UPDATE", "EXERCISE", id, "SUCCESS", Map.of("version", expected));
        return getExercise(id);
    }

    @Transactional
    public Exercise setExerciseVisibility(long adminId, long id, String value, Long version) {
        String next = visibility(value);
        long expected = version == null ? -1 : version;
        int updated =
                jdbc.update(
                        "update exercises set visibility=?, version=version+1, updated_at=current_timestamp where id=? and deleted_at is null and (? < 0 or version=?)",
                        next,
                        id,
                        expected,
                        expected);
        if (updated == 0) conflictOrMissing("Exercise", id);
        audit.record(
                adminId,
                "ADMIN",
                next.equals("HIDDEN") ? "HIDE" : "SHOW",
                "EXERCISE",
                id,
                "SUCCESS",
                Map.of("visibility", next));
        return getExercise(id);
    }

    @Transactional
    public void deleteExercise(long adminId, long id) {
        int updated =
                jdbc.update(
                        "update exercises set visibility='HIDDEN', deleted_at=current_timestamp, version=version+1, updated_at=current_timestamp where id=? and deleted_at is null",
                        id);
        if (updated == 0)
            throw new ApiException(ApiErrorCode.EXERCISE_NOT_FOUND, "Exercise not found");
        audit.record(
                adminId,
                "ADMIN",
                "DELETE",
                "EXERCISE",
                id,
                "SUCCESS",
                Map.of("mode", "SOFT_DELETE"));
    }

    @Transactional(readOnly = true)
    public PageResponse<Food> listFoods(
            String q, String category, String visibility, Pageable page) {
        StringBuilder where = new StringBuilder("where deleted_at is null ");
        List<Object> params = new ArrayList<>();
        if (q != null && !q.isBlank()) {
            where.append("and (lower(name) like ? or lower(slug) like ?) ");
            params.add("%" + q.trim().toLowerCase(Locale.ROOT) + "%");
            params.add("%" + q.trim().toLowerCase(Locale.ROOT) + "%");
        }
        if (category != null && !category.isBlank()) {
            where.append("and lower(category)=? ");
            params.add(category.toLowerCase(Locale.ROOT));
        }
        if (visibility != null && !visibility.isBlank()) {
            where.append("and visibility=? ");
            params.add(visibility.toUpperCase(Locale.ROOT));
        }
        long total =
                jdbc.queryForObject(
                        "select count(*) from foods " + where, Long.class, params.toArray());
        params.add(page.getPageSize());
        params.add(page.getOffset());
        List<Food> rows =
                jdbc.query(
                        "select * from foods "
                                + where
                                + "order by updated_at desc, id desc limit ? offset ?",
                        this::mapFood,
                        params.toArray());
        return PageResponse.from(new PageImpl<>(rows, page, total));
    }

    @Transactional(readOnly = true)
    public Food getFood(long id) {
        List<Food> rows =
                jdbc.query(
                        "select * from foods where id=? and deleted_at is null", this::mapFood, id);
        if (rows.isEmpty()) throw new ApiException(ApiErrorCode.FOOD_NOT_FOUND, "Food not found");
        return rows.getFirst();
    }

    @Transactional
    public Food createFood(long adminId, FoodRequest request) {
        validate(request);
        KeyHolder key = new GeneratedKeyHolder();
        try {
            jdbc.update(
                    connection -> {
                        var ps =
                                connection.prepareStatement(
                                        "insert into foods (name, search_name, slug, category, serving_amount, serving_unit, grams_per_serving, calories_per_serving, protein_g_per_serving, carbs_g_per_serving, fat_g_per_serving, data_source, source_note, is_estimated, visibility) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
                                        new String[] {"id"});
                        bindFood(ps, request, false, 0);
                        return ps;
                    },
                    key);
        } catch (DuplicateKeyException e) {
            throw new ApiException(
                    ApiErrorCode.INVALID_STATE_TRANSITION, "Food slug already exists");
        }
        long id = key.getKey().longValue();
        audit.record(
                adminId,
                "ADMIN",
                "CREATE",
                "FOOD",
                id,
                "SUCCESS",
                Map.of("name", request.name(), "visibility", visibility(request.visibility())));
        return getFood(id);
    }

    @Transactional
    public Food updateFood(long adminId, long id, FoodRequest request) {
        validate(request);
        long expected = request.version() == null ? -1 : request.version();
        int updated;
        try {
            updated =
                    jdbc.update(
                            connection -> {
                                var ps =
                                        connection.prepareStatement(
                                                "update foods set name=?, search_name=?, slug=?, category=?, serving_amount=?, serving_unit=?, grams_per_serving=?, calories_per_serving=?, protein_g_per_serving=?, carbs_g_per_serving=?, fat_g_per_serving=?, data_source=?, source_note=?, is_estimated=?, visibility=?, version=version+1, updated_at=current_timestamp where id=? and deleted_at is null and (? < 0 or version=?)");
                                bindFood(ps, request, true, id);
                                ps.setLong(17, expected);
                                ps.setLong(18, expected);
                                return ps;
                            });
        } catch (DuplicateKeyException e) {
            throw new ApiException(
                    ApiErrorCode.INVALID_STATE_TRANSITION, "Food slug already exists");
        }
        if (updated == 0) conflictOrMissing("Food", id);
        audit.record(
                adminId, "ADMIN", "UPDATE", "FOOD", id, "SUCCESS", Map.of("version", expected));
        return getFood(id);
    }

    @Transactional
    public Food setFoodVisibility(long adminId, long id, String value, Long version) {
        String next = visibility(value);
        long expected = version == null ? -1 : version;
        int updated =
                jdbc.update(
                        "update foods set visibility=?, version=version+1, updated_at=current_timestamp where id=? and deleted_at is null and (? < 0 or version=?)",
                        next,
                        id,
                        expected,
                        expected);
        if (updated == 0) conflictOrMissing("Food", id);
        audit.record(
                adminId,
                "ADMIN",
                next.equals("HIDDEN") ? "HIDE" : "SHOW",
                "FOOD",
                id,
                "SUCCESS",
                Map.of("visibility", next));
        return getFood(id);
    }

    @Transactional
    public void deleteFood(long adminId, long id) {
        int updated =
                jdbc.update(
                        "update foods set visibility='HIDDEN', deleted_at=current_timestamp, version=version+1, updated_at=current_timestamp where id=? and deleted_at is null",
                        id);
        if (updated == 0) throw new ApiException(ApiErrorCode.FOOD_NOT_FOUND, "Food not found");
        audit.record(
                adminId, "ADMIN", "DELETE", "FOOD", id, "SUCCESS", Map.of("mode", "SOFT_DELETE"));
    }

    private Exercise mapExercise(ResultSet rs, int row) throws SQLException {
        long id = rs.getLong("id");
        return new Exercise(
                id,
                rs.getString("name"),
                rs.getString("slug"),
                rs.getString("difficulty"),
                rs.getString("description"),
                readList(rs.getString("instruction_steps")),
                readList(rs.getString("common_mistakes")),
                readList(rs.getString("safety_notes")),
                rs.getString("visibility"),
                loadMuscles(id),
                loadEquipment(id),
                rs.getLong("version"),
                rs.getObject("updated_at", OffsetDateTime.class));
    }

    private Food mapFood(ResultSet rs, int row) throws SQLException {
        return new Food(
                rs.getLong("id"),
                rs.getString("name"),
                rs.getString("slug"),
                rs.getString("category"),
                rs.getBigDecimal("serving_amount"),
                rs.getString("serving_unit"),
                rs.getBigDecimal("grams_per_serving"),
                rs.getBigDecimal("calories_per_serving"),
                rs.getBigDecimal("protein_g_per_serving"),
                rs.getBigDecimal("carbs_g_per_serving"),
                rs.getBigDecimal("fat_g_per_serving"),
                rs.getString("data_source"),
                rs.getString("source_note"),
                rs.getBoolean("is_estimated"),
                rs.getString("visibility"),
                rs.getLong("version"),
                rs.getObject("updated_at", OffsetDateTime.class));
    }

    private List<MuscleInput> loadMuscles(long id) {
        return jdbc.query(
                "select muscle_group_id, role from exercise_muscle_groups where exercise_id=? order by role, muscle_group_id",
                (rs, row) -> new MuscleInput(rs.getLong(1), rs.getString(2)),
                id);
    }

    private List<EquipmentInput> loadEquipment(long id) {
        return jdbc.query(
                "select equipment_id, is_required from exercise_equipment where exercise_id=? order by equipment_id",
                (rs, row) -> new EquipmentInput(rs.getLong(1), rs.getBoolean(2)),
                id);
    }

    private void replaceExerciseRelations(long id, ExerciseRequest request) {
        jdbc.update("delete from exercise_muscle_groups where exercise_id=?", id);
        for (MuscleInput item : list(request.muscleGroups()))
            jdbc.update(
                    "insert into exercise_muscle_groups (exercise_id, muscle_group_id, role) values (?,?,?)",
                    id,
                    item.muscleGroupId(),
                    upper(item.role()));
        jdbc.update("delete from exercise_equipment where exercise_id=?", id);
        for (EquipmentInput item : list(request.equipment()))
            jdbc.update(
                    "insert into exercise_equipment (exercise_id, equipment_id, is_required) values (?,?,?)",
                    id,
                    item.equipmentId(),
                    item.required());
    }

    private void validate(ExerciseRequest r) {
        if (r == null
                || blank(r.name())
                || blank(r.slug())
                || blank(r.description())
                || !DIFFICULTIES.contains(upper(r.difficulty()))
                || !VISIBILITIES.contains(visibility(r.visibility())))
            throw new ApiException(ApiErrorCode.VALIDATION_ERROR, "Exercise fields are invalid");
        if (r.name().length() > 180 || r.slug().length() > 200)
            throw new ApiException(
                    ApiErrorCode.VALIDATION_ERROR, "Exercise name or slug is too long");
    }

    private void validate(FoodRequest r) {
        if (r == null
                || blank(r.name())
                || blank(r.slug())
                || blank(r.category())
                || blank(r.servingUnit())
                || nonPositive(r.servingAmount())
                || negative(r.caloriesPerServing())
                || negative(r.proteinGPerServing())
                || negative(r.carbsGPerServing())
                || negative(r.fatGPerServing())
                || (r.gramsPerServing() != null && nonPositive(r.gramsPerServing())))
            throw new ApiException(ApiErrorCode.VALIDATION_ERROR, "Food fields are invalid");
        visibility(r.visibility());
    }

    private void bindFood(java.sql.PreparedStatement ps, FoodRequest r, boolean update, long id)
            throws SQLException {
        ps.setString(1, r.name().trim());
        ps.setString(2, normalizeSearch(r.name()));
        ps.setString(3, r.slug().trim().toLowerCase(Locale.ROOT));
        ps.setString(4, r.category().trim());
        ps.setBigDecimal(5, r.servingAmount());
        ps.setString(6, r.servingUnit().trim());
        ps.setBigDecimal(7, r.gramsPerServing());
        ps.setBigDecimal(8, r.caloriesPerServing());
        ps.setBigDecimal(9, r.proteinGPerServing());
        ps.setBigDecimal(10, r.carbsGPerServing());
        ps.setBigDecimal(11, r.fatGPerServing());
        ps.setString(12, r.dataSource());
        ps.setString(13, r.sourceNote());
        ps.setBoolean(14, r.estimated());
        ps.setString(15, visibility(r.visibility()));
        if (update) ps.setLong(16, id);
    }

    private void conflictOrMissing(String kind, long id) {
        Integer count =
                jdbc.queryForObject(
                        "select count(*) from "
                                + (kind.equals("Food") ? "foods" : "exercises")
                                + " where id=? and deleted_at is null",
                        Integer.class,
                        id);
        if (count == null || count == 0)
            throw new ApiException(
                    kind.equals("Food")
                            ? ApiErrorCode.FOOD_NOT_FOUND
                            : ApiErrorCode.EXERCISE_NOT_FOUND,
                    kind + " not found");
        throw new ApiException(
                ApiErrorCode.INVALID_STATE_TRANSITION,
                kind + " was changed by another administrator");
    }

    private String json(Object value) {
        try {
            return mapper.writeValueAsString(value);
        } catch (JsonProcessingException e) {
            throw new IllegalArgumentException(e);
        }
    }

    private List<String> readList(String value) {
        try {
            return mapper.readValue(value, STRING_LIST);
        } catch (JsonProcessingException e) {
            return List.of();
        }
    }

    private static String normalizeSearch(String s) {
        return java.text.Normalizer.normalize(s, java.text.Normalizer.Form.NFD)
                .replaceAll("\\p{M}+", "")
                .toLowerCase(Locale.ROOT);
    }

    private static String upper(String s) {
        return s == null ? "" : s.trim().toUpperCase(Locale.ROOT);
    }

    private static String visibility(String s) {
        String value = blank(s) ? "PUBLIC" : upper(s);
        if (!VISIBILITIES.contains(value))
            throw new ApiException(ApiErrorCode.VALIDATION_ERROR, "Visibility is invalid");
        return value;
    }

    private static boolean blank(String s) {
        return s == null || s.isBlank();
    }

    private static boolean nonPositive(BigDecimal n) {
        return n == null || n.signum() <= 0;
    }

    private static boolean negative(BigDecimal n) {
        return n == null || n.signum() < 0;
    }

    private static <T> List<T> list(List<T> value) {
        return value == null ? List.of() : value;
    }
}
