package com.viegym.exercise.application;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.viegym.common.api.PageResponse;
import com.viegym.common.error.ApiErrorCode;
import com.viegym.common.error.ApiException;
import com.viegym.exercise.api.EquipmentDto;
import com.viegym.exercise.api.ExerciseDetailDto;
import com.viegym.exercise.api.ExerciseEquipmentDto;
import com.viegym.exercise.api.ExerciseMuscleGroupDto;
import com.viegym.exercise.api.ExerciseSummaryDto;
import com.viegym.exercise.api.MuscleGroupDto;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ExerciseCatalogService {

    private static final TypeReference<List<String>> STRING_LIST = new TypeReference<>() {};

    private final JdbcTemplate jdbc;
    private final ObjectMapper objectMapper;

    public ExerciseCatalogService(JdbcTemplate jdbc, ObjectMapper objectMapper) {
        this.jdbc = jdbc;
        this.objectMapper = objectMapper;
    }

    @Transactional(readOnly = true)
    public List<MuscleGroupDto> listMuscleGroups() {
        return jdbc.query(
                "select id, code, name, description from muscle_groups where is_active = true order"
                        + " by name asc",
                (rs, row) ->
                        new MuscleGroupDto(
                                rs.getLong("id"),
                                rs.getString("code"),
                                rs.getString("name"),
                                rs.getString("description")));
    }

    @Transactional(readOnly = true)
    public List<EquipmentDto> listEquipment() {
        return jdbc.query(
                "select id, code, name, description from equipment where is_active = true order by"
                        + " name asc",
                (rs, row) ->
                        new EquipmentDto(
                                rs.getLong("id"),
                                rs.getString("code"),
                                rs.getString("name"),
                                rs.getString("description")));
    }

    @Transactional(readOnly = true)
    public PageResponse<ExerciseSummaryDto> searchExercises(
            Long userId,
            String q,
            Long muscleGroupId,
            Long equipmentId,
            String difficulty,
            Boolean compatibleWithMyEquipment,
            Pageable pageable) {

        StringBuilder whereClause =
                new StringBuilder("where e.visibility = 'PUBLIC' and e.deleted_at is null ");
        List<Object> params = new ArrayList<>();

        if (q != null && !q.trim().isEmpty()) {
            String term = "%" + q.trim().toLowerCase() + "%";
            whereClause.append("and (lower(e.search_name) like ? or lower(e.name) like ?) ");
            params.add(term);
            params.add(term);
        }

        if (muscleGroupId != null) {
            whereClause.append(
                    "and exists (select 1 from exercise_muscle_groups emg where emg.exercise_id ="
                            + " e.id and emg.muscle_group_id = ?) ");
            params.add(muscleGroupId);
        }

        if (equipmentId != null) {
            whereClause.append(
                    "and exists (select 1 from exercise_equipment ee where ee.exercise_id = e.id"
                            + " and ee.equipment_id = ?) ");
            params.add(equipmentId);
        }

        if (difficulty != null && !difficulty.trim().isEmpty()) {
            whereClause.append("and e.difficulty = ? ");
            params.add(difficulty.trim().toUpperCase());
        }

        if (Boolean.TRUE.equals(compatibleWithMyEquipment) && userId != null) {
            List<Long> userEquipmentIds =
                    jdbc.queryForList(
                            "select equipment_id from user_equipment_preferences where user_id ="
                                    + " ?",
                            Long.class,
                            userId);
            if (userEquipmentIds.isEmpty()) {
                whereClause.append(
                        "and not exists (select 1 from exercise_equipment ee join equipment eq on"
                                + " ee.equipment_id = eq.id where ee.exercise_id = e.id and"
                                + " ee.is_required = true and eq.code <> 'BODYWEIGHT') ");
            } else {
                String placeholders =
                        String.join(",", Collections.nCopies(userEquipmentIds.size(), "?"));
                whereClause.append(
                        "and not exists (select 1 from exercise_equipment ee join equipment eq on"
                                + " ee.equipment_id = eq.id where ee.exercise_id = e.id and"
                                + " ee.is_required = true and eq.code <> 'BODYWEIGHT' and"
                                + " ee.equipment_id not in ("
                                + placeholders
                                + ")) ");
                params.addAll(userEquipmentIds);
            }
        }

        String countSql = "select count(*) from exercises e " + whereClause;
        Long total = jdbc.queryForObject(countSql, Long.class, params.toArray());
        long totalElements = total != null ? total : 0L;

        if (totalElements == 0) {
            return PageResponse.from(new PageImpl<>(Collections.emptyList(), pageable, 0));
        }

        String sortOrder = "e.name asc";
        if (pageable.getSort().isSorted()) {
            var order = pageable.getSort().iterator().next();
            String property =
                    order.getProperty().equalsIgnoreCase("difficulty") ? "e.difficulty" : "e.name";
            String direction = order.isDescending() ? "desc" : "asc";
            sortOrder = property + " " + direction;
        }

        String dataSql =
                "select e.id, e.name, e.slug, e.difficulty, e.description from exercises e "
                        + whereClause
                        + " order by "
                        + sortOrder
                        + " limit ? offset ?";

        List<Object> dataParams = new ArrayList<>(params);
        dataParams.add(pageable.getPageSize());
        dataParams.add(pageable.getOffset());

        List<ExerciseRow> rows =
                jdbc.query(
                        dataSql,
                        (rs, row) ->
                                new ExerciseRow(
                                        rs.getLong("id"),
                                        rs.getString("name"),
                                        rs.getString("slug"),
                                        rs.getString("difficulty"),
                                        rs.getString("description")),
                        dataParams.toArray());

        if (rows.isEmpty()) {
            return PageResponse.from(
                    new PageImpl<>(Collections.emptyList(), pageable, totalElements));
        }

        List<Long> exerciseIds = rows.stream().map(ExerciseRow::id).toList();
        Map<Long, List<ExerciseMuscleGroupDto>> muscleGroupMap = loadMuscleGroups(exerciseIds);
        Map<Long, List<ExerciseEquipmentDto>> equipmentMap = loadEquipment(exerciseIds);

        List<ExerciseSummaryDto> content =
                rows.stream()
                        .map(
                                r ->
                                        new ExerciseSummaryDto(
                                                r.id(),
                                                r.name(),
                                                r.slug(),
                                                r.difficulty(),
                                                r.description(),
                                                muscleGroupMap.getOrDefault(
                                                        r.id(), Collections.emptyList()),
                                                equipmentMap.getOrDefault(
                                                        r.id(), Collections.emptyList()),
                                                Collections.emptyList()))
                        .toList();

        return PageResponse.from(new PageImpl<>(content, pageable, totalElements));
    }

    @Transactional(readOnly = true)
    public ExerciseDetailDto getExerciseDetail(Long id) {
        String sql =
                "select id, name, slug, difficulty, description, instruction_steps::text,"
                        + " common_mistakes::text, safety_notes::text from exercises where id = ? and"
                        + " visibility = 'PUBLIC' and deleted_at is null";

        List<ExerciseDetailRow> list =
                jdbc.query(
                        sql,
                        (rs, row) ->
                                new ExerciseDetailRow(
                                        rs.getLong("id"),
                                        rs.getString("name"),
                                        rs.getString("slug"),
                                        rs.getString("difficulty"),
                                        rs.getString("description"),
                                        rs.getString("instruction_steps"),
                                        rs.getString("common_mistakes"),
                                        rs.getString("safety_notes")),
                        id);

        if (list.isEmpty()) {
            throw new ApiException(ApiErrorCode.EXERCISE_NOT_FOUND, "Exercise not found");
        }

        ExerciseDetailRow row = list.get(0);
        Map<Long, List<ExerciseMuscleGroupDto>> muscleGroups = loadMuscleGroups(List.of(row.id()));
        Map<Long, List<ExerciseEquipmentDto>> equipment = loadEquipment(List.of(row.id()));

        return new ExerciseDetailDto(
                row.id(),
                row.name(),
                row.slug(),
                row.difficulty(),
                row.description(),
                readJsonStringList(row.instructionStepsJson()),
                readJsonStringList(row.commonMistakesJson()),
                readJsonStringList(row.safetyNotesJson()),
                muscleGroups.getOrDefault(row.id(), Collections.emptyList()),
                equipment.getOrDefault(row.id(), Collections.emptyList()),
                Collections.emptyList());
    }

    @Transactional(readOnly = true)
    public List<ExerciseSummaryDto> getExerciseAlternatives(
            Long userId, Long exerciseId, int limit) {
        int safeLimit = Math.min(Math.max(1, limit), 20);

        // Ensure source exercise exists and is PUBLIC/active
        Integer exists =
                jdbc.queryForObject(
                        "select count(*) from exercises where id = ? and visibility = 'PUBLIC' and"
                                + " deleted_at is null",
                        Integer.class,
                        exerciseId);
        if (exists == null || exists == 0) {
            throw new ApiException(ApiErrorCode.EXERCISE_NOT_FOUND, "Exercise not found");
        }

        List<Long> primaryMuscleGroupIds =
                jdbc.queryForList(
                        "select muscle_group_id from exercise_muscle_groups where exercise_id = ?"
                                + " and role = 'PRIMARY'",
                        Long.class,
                        exerciseId);

        if (primaryMuscleGroupIds.isEmpty()) {
            return Collections.emptyList();
        }

        String placeholders =
                String.join(",", Collections.nCopies(primaryMuscleGroupIds.size(), "?"));
        List<Object> params = new ArrayList<>();
        params.add(exerciseId);
        params.addAll(primaryMuscleGroupIds);

        StringBuilder sql =
                new StringBuilder(
                        "select e.id, e.name, e.slug, e.difficulty, e.description from exercises e"
                                + " where e.id <> ? and e.visibility = 'PUBLIC' and e.deleted_at is"
                                + " null and exists (select 1 from exercise_muscle_groups emg where"
                                + " emg.exercise_id = e.id and emg.role = 'PRIMARY' and"
                                + " emg.muscle_group_id in ("
                                + placeholders
                                + ")) ");

        // Priority ranking: compatible equipment first
        if (userId != null) {
            List<Long> userEquipmentIds =
                    jdbc.queryForList(
                            "select equipment_id from user_equipment_preferences where user_id ="
                                    + " ?",
                            Long.class,
                            userId);
            if (userEquipmentIds.isEmpty()) {
                sql.append(
                        "order by case when not exists (select 1 from exercise_equipment ee join"
                                + " equipment eq on ee.equipment_id = eq.id where ee.exercise_id = e.id"
                                + " and ee.is_required = true and eq.code <> 'BODYWEIGHT') then 0 else"
                                + " 1 end, e.name asc ");
            } else {
                String eqPlaceholders =
                        String.join(",", Collections.nCopies(userEquipmentIds.size(), "?"));
                sql.append(
                        "order by case when not exists (select 1 from exercise_equipment ee join"
                                + " equipment eq on ee.equipment_id = eq.id where ee.exercise_id = e.id"
                                + " and ee.is_required = true and eq.code <> 'BODYWEIGHT' and"
                                + " ee.equipment_id not in ("
                                + eqPlaceholders
                                + ")) then 0 else 1 end, e.name asc ");
                params.addAll(userEquipmentIds);
            }
        } else {
            sql.append("order by e.name asc ");
        }

        sql.append("limit ?");
        params.add(safeLimit);

        List<ExerciseRow> rows =
                jdbc.query(
                        sql.toString(),
                        (rs, row) ->
                                new ExerciseRow(
                                        rs.getLong("id"),
                                        rs.getString("name"),
                                        rs.getString("slug"),
                                        rs.getString("difficulty"),
                                        rs.getString("description")),
                        params.toArray());

        if (rows.isEmpty()) {
            return Collections.emptyList();
        }

        List<Long> exerciseIds = rows.stream().map(ExerciseRow::id).toList();
        Map<Long, List<ExerciseMuscleGroupDto>> muscleGroupMap = loadMuscleGroups(exerciseIds);
        Map<Long, List<ExerciseEquipmentDto>> equipmentMap = loadEquipment(exerciseIds);

        return rows.stream()
                .map(
                        r ->
                                new ExerciseSummaryDto(
                                        r.id(),
                                        r.name(),
                                        r.slug(),
                                        r.difficulty(),
                                        r.description(),
                                        muscleGroupMap.getOrDefault(
                                                r.id(), Collections.emptyList()),
                                        equipmentMap.getOrDefault(r.id(), Collections.emptyList()),
                                        Collections.emptyList()))
                .toList();
    }

    @Transactional(readOnly = true)
    public PageResponse<ExerciseSummaryDto> listFavorites(
            Long userId, String q, Pageable pageable) {
        StringBuilder whereClause =
                new StringBuilder(
                        "from favorite_exercises fe join exercises e on fe.exercise_id = e.id where"
                                + " fe.user_id = ? and e.visibility = 'PUBLIC' and e.deleted_at is"
                                + " null ");
        List<Object> params = new ArrayList<>();
        params.add(userId);

        if (q != null && !q.trim().isEmpty()) {
            String term = "%" + q.trim().toLowerCase() + "%";
            whereClause.append("and (lower(e.search_name) like ? or lower(e.name) like ?) ");
            params.add(term);
            params.add(term);
        }

        String countSql = "select count(*) " + whereClause;
        Long total = jdbc.queryForObject(countSql, Long.class, params.toArray());
        long totalElements = total != null ? total : 0L;

        if (totalElements == 0) {
            return PageResponse.from(new PageImpl<>(Collections.emptyList(), pageable, 0));
        }

        String dataSql =
                "select e.id, e.name, e.slug, e.difficulty, e.description "
                        + whereClause
                        + " order by fe.created_at desc limit ? offset ?";

        List<Object> dataParams = new ArrayList<>(params);
        dataParams.add(pageable.getPageSize());
        dataParams.add(pageable.getOffset());

        List<ExerciseRow> rows =
                jdbc.query(
                        dataSql,
                        (rs, row) ->
                                new ExerciseRow(
                                        rs.getLong("id"),
                                        rs.getString("name"),
                                        rs.getString("slug"),
                                        rs.getString("difficulty"),
                                        rs.getString("description")),
                        dataParams.toArray());

        List<Long> exerciseIds = rows.stream().map(ExerciseRow::id).toList();
        Map<Long, List<ExerciseMuscleGroupDto>> muscleGroupMap = loadMuscleGroups(exerciseIds);
        Map<Long, List<ExerciseEquipmentDto>> equipmentMap = loadEquipment(exerciseIds);

        List<ExerciseSummaryDto> content =
                rows.stream()
                        .map(
                                r ->
                                        new ExerciseSummaryDto(
                                                r.id(),
                                                r.name(),
                                                r.slug(),
                                                r.difficulty(),
                                                r.description(),
                                                muscleGroupMap.getOrDefault(
                                                        r.id(), Collections.emptyList()),
                                                equipmentMap.getOrDefault(
                                                        r.id(), Collections.emptyList()),
                                                Collections.emptyList()))
                        .toList();

        return PageResponse.from(new PageImpl<>(content, pageable, totalElements));
    }

    @Transactional
    public void addFavorite(Long userId, Long exerciseId) {
        Integer exists =
                jdbc.queryForObject(
                        "select count(*) from exercises where id = ? and visibility = 'PUBLIC' and"
                                + " deleted_at is null",
                        Integer.class,
                        exerciseId);
        if (exists == null || exists == 0) {
            throw new ApiException(ApiErrorCode.EXERCISE_NOT_FOUND, "Exercise not found");
        }

        jdbc.update(
                "insert into favorite_exercises (user_id, exercise_id) values (?, ?) on conflict"
                        + " do nothing",
                userId,
                exerciseId);
    }

    @Transactional
    public void removeFavorite(Long userId, Long exerciseId) {
        jdbc.update(
                "delete from favorite_exercises where user_id = ? and exercise_id = ?",
                userId,
                exerciseId);
    }

    private Map<Long, List<ExerciseMuscleGroupDto>> loadMuscleGroups(List<Long> exerciseIds) {
        if (exerciseIds.isEmpty()) {
            return Collections.emptyMap();
        }
        String placeholders = String.join(",", Collections.nCopies(exerciseIds.size(), "?"));
        String sql =
                "select emg.exercise_id, mg.id, mg.code, mg.name, emg.role from"
                        + " exercise_muscle_groups emg join muscle_groups mg on emg.muscle_group_id ="
                        + " mg.id where emg.exercise_id in ("
                        + placeholders
                        + ") order by case when emg.role = 'PRIMARY' then 0 else 1 end, mg.name"
                        + " asc";

        Map<Long, List<ExerciseMuscleGroupDto>> map = new HashMap<>();
        jdbc.query(
                sql,
                rs -> {
                    long exerciseId = rs.getLong("exercise_id");
                    map.computeIfAbsent(exerciseId, k -> new ArrayList<>())
                            .add(
                                    new ExerciseMuscleGroupDto(
                                            rs.getLong("id"),
                                            rs.getString("code"),
                                            rs.getString("name"),
                                            rs.getString("role")));
                },
                exerciseIds.toArray());
        return map;
    }

    private Map<Long, List<ExerciseEquipmentDto>> loadEquipment(List<Long> exerciseIds) {
        if (exerciseIds.isEmpty()) {
            return Collections.emptyMap();
        }
        String placeholders = String.join(",", Collections.nCopies(exerciseIds.size(), "?"));
        String sql =
                "select ee.exercise_id, eq.id, eq.code, eq.name, ee.is_required from"
                        + " exercise_equipment ee join equipment eq on ee.equipment_id = eq.id where"
                        + " ee.exercise_id in ("
                        + placeholders
                        + ") order by eq.name asc";

        Map<Long, List<ExerciseEquipmentDto>> map = new HashMap<>();
        jdbc.query(
                sql,
                rs -> {
                    long exerciseId = rs.getLong("exercise_id");
                    map.computeIfAbsent(exerciseId, k -> new ArrayList<>())
                            .add(
                                    new ExerciseEquipmentDto(
                                            rs.getLong("id"),
                                            rs.getString("code"),
                                            rs.getString("name"),
                                            rs.getBoolean("is_required")));
                },
                exerciseIds.toArray());
        return map;
    }

    private List<String> readJsonStringList(String json) {
        if (json == null || json.isBlank()) {
            return Collections.emptyList();
        }
        try {
            return objectMapper.readValue(json, STRING_LIST);
        } catch (Exception e) {
            return Collections.emptyList();
        }
    }

    private record ExerciseRow(
            Long id, String name, String slug, String difficulty, String description) {}

    private record ExerciseDetailRow(
            Long id,
            String name,
            String slug,
            String difficulty,
            String description,
            String instructionStepsJson,
            String commonMistakesJson,
            String safetyNotesJson) {}
}
