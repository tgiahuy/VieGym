package com.viegym.nutrition.application;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.viegym.common.api.PageResponse;
import com.viegym.common.error.ApiErrorCode;
import com.viegym.common.error.ApiException;
import com.viegym.nutrition.api.ApplyMealTemplateRequest;
import com.viegym.nutrition.api.CreateMealTemplateRequest;
import com.viegym.nutrition.api.MealEntryRequest;
import com.viegym.nutrition.api.NutritionDtos;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.text.Normalizer;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.regex.Pattern;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.annotation.Transactional;

@Service
public class NutritionService {
    private static final Set<String> MEAL_TYPES = Set.of("BREAKFAST", "LUNCH", "DINNER", "SNACK");
    private static final Pattern DIACRITICS = Pattern.compile("\\p{M}+");
    private static final List<String> MEAL_ORDER = List.of("BREAKFAST", "LUNCH", "DINNER", "SNACK");

    private final JdbcTemplate jdbc;
    private final ObjectMapper objectMapper;

    public NutritionService(JdbcTemplate jdbc, ObjectMapper objectMapper) {
        this.jdbc = jdbc;
        this.objectMapper = objectMapper;
    }

    @Transactional(readOnly = true)
    public PageResponse<NutritionDtos.Food> searchFoods(
            String q, String category, Pageable pageable) {
        StringBuilder where =
                new StringBuilder("where visibility = 'PUBLIC' and deleted_at is null ");
        List<Object> params = new ArrayList<>();
        if (q != null && !q.isBlank()) {
            where.append("and search_name like ? ");
            params.add("%" + normalize(q) + "%");
        }
        if (category != null && !category.isBlank() && !"ALL".equalsIgnoreCase(category)) {
            where.append("and upper(category) = ? ");
            params.add(category.trim().toUpperCase(Locale.ROOT));
        }
        long total =
                jdbc.queryForObject(
                        "select count(*) from foods " + where, Long.class, params.toArray());
        String sort = "name asc, id asc";
        if (pageable.getSort().isSorted()) {
            var order = pageable.getSort().iterator().next();
            String field =
                    switch (order.getProperty()) {
                        case "calories", "caloriesKcal" -> "calories_per_serving";
                        case "category" -> "category";
                        default -> "name";
                    };
            sort = field + (order.isDescending() ? " desc" : " asc") + ", id asc";
        }
        List<Object> dataParams = new ArrayList<>(params);
        dataParams.add(pageable.getPageSize());
        dataParams.add(pageable.getOffset());
        List<NutritionDtos.Food> content =
                jdbc.query(
                        "select * from foods " + where + "order by " + sort + " limit ? offset ?",
                        (rs, row) -> mapFood(rs, true),
                        dataParams.toArray());
        return PageResponse.from(new PageImpl<>(content, pageable, total));
    }

    @Transactional(readOnly = true)
    public NutritionDtos.Food getFood(Long id) {
        loadSelectableFood(id);
        return jdbc.query(
                        "select * from foods where id=? and visibility='PUBLIC' and deleted_at is null",
                        (rs, row) -> mapFood(rs, true),
                        id)
                .getFirst();
    }

    @Transactional(readOnly = true)
    public PageResponse<NutritionDtos.Food> listFavorites(
            Long userId, String q, Pageable pageable) {
        requireUser(userId);
        String search = q == null || q.isBlank() ? null : "%" + normalize(q) + "%";
        String searchClause = search == null ? "" : "and f.search_name like ? ";
        List<Object> params = new ArrayList<>(List.of(userId));
        if (search != null) params.add(search);
        long total =
                jdbc.queryForObject(
                        "select count(*) from favorite_foods ff join foods f on f.id = ff.food_id "
                                + "where ff.user_id = ? and f.visibility = 'PUBLIC' "
                                + "and f.deleted_at is null "
                                + searchClause,
                        Long.class,
                        params.toArray());
        params.add(pageable.getPageSize());
        params.add(pageable.getOffset());
        List<NutritionDtos.Food> content =
                jdbc.query(
                        "select f.* from favorite_foods ff join foods f on f.id = ff.food_id "
                                + "where ff.user_id = ? and f.visibility = 'PUBLIC' "
                                + "and f.deleted_at is null "
                                + searchClause
                                + "order by ff.created_at desc, f.id desc limit ? offset ?",
                        (rs, row) -> mapFood(rs, true),
                        params.toArray());
        return PageResponse.from(new PageImpl<>(content, pageable, total));
    }

    @Transactional
    public void addFavorite(Long userId, Long foodId) {
        requireUser(userId);
        loadSelectableFood(foodId);
        jdbc.update(
                "insert into favorite_foods (user_id, food_id) values (?, ?) on conflict do nothing",
                userId,
                foodId);
    }

    @Transactional
    public void removeFavorite(Long userId, Long foodId) {
        requireUser(userId);
        jdbc.update("delete from favorite_foods where user_id = ? and food_id = ?", userId, foodId);
    }

    @Transactional(readOnly = true)
    public NutritionDtos.MealPlan getMealPlan(Long userId, LocalDate date) {
        requireUser(userId);
        Long planId = findPlanId(userId, date);
        if (planId == null) {
            NutritionDtos.Nutrition target = loadCurrentTarget(userId, false);
            return emptyPlan(date, target);
        }
        return loadPlan(userId, date, planId);
    }

    @Transactional(readOnly = true)
    public PageResponse<NutritionDtos.MealPlan> listMealHistory(Long userId, Pageable pageable) {
        requireUser(userId);
        long total =
                jdbc.queryForObject(
                        "select count(*) from meal_plans where user_id = ?", Long.class, userId);
        List<PlanDateRow> rows =
                jdbc.query(
                        "select id, plan_date from meal_plans where user_id = ? "
                                + "order by plan_date desc limit ? offset ?",
                        (rs, row) ->
                                new PlanDateRow(
                                        rs.getLong("id"),
                                        rs.getObject("plan_date", LocalDate.class)),
                        userId,
                        pageable.getPageSize(),
                        pageable.getOffset());
        List<NutritionDtos.MealPlan> content =
                rows.stream().map(row -> loadPlan(userId, row.date(), row.id())).toList();
        return PageResponse.from(new PageImpl<>(content, pageable, total));
    }

    @Transactional(isolation = Isolation.READ_COMMITTED)
    public NutritionDtos.MealPlan addEntry(Long userId, LocalDate date, MealEntryRequest request) {
        requireUser(userId);
        validateMealRequest(request, true);
        FoodRow food = loadSelectableFood(request.foodId());
        ServingInput serving = servingInput(request, food);
        Long planId = ensurePlan(userId, date);
        Long mealId = ensureMeal(planId, request.mealType(), request.mealSortOrder());
        jdbc.update(
                "insert into meal_entries (meal_id, food_id, serving_multiplier, input_amount, "
                        + "input_unit, food_name_snapshot, serving_amount_snapshot, "
                        + "serving_unit_snapshot, calories_snapshot, protein_g_snapshot, "
                        + "carbs_g_snapshot, fat_g_snapshot, estimated_snapshot, note) "
                        + "values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                mealId,
                food.id(),
                serving.multiplier(),
                serving.inputAmount(),
                serving.inputUnit(),
                food.name(),
                food.servingAmount(),
                food.servingUnit(),
                scaled(food.calories(), serving.multiplier()),
                scaled(food.protein(), serving.multiplier()),
                scaled(food.carbs(), serving.multiplier()),
                scaled(food.fat(), serving.multiplier()),
                food.estimated(),
                cleanNote(request.note()));
        return loadPlan(userId, date, planId);
    }

    @Transactional(isolation = Isolation.READ_COMMITTED)
    public NutritionDtos.MealPlan updateEntry(
            Long userId, LocalDate date, Long entryId, MealEntryRequest request) {
        requireUser(userId);
        validateMealRequest(request, false);
        EntryOwnerRow owned = loadOwnedEntry(userId, date, entryId);
        FoodRow food = loadSelectableFood(owned.foodId());
        ServingInput serving = servingInput(request, food);
        Long mealId = ensureMeal(owned.planId(), request.mealType(), request.mealSortOrder());
        int updated =
                jdbc.update(
                        "update meal_entries set meal_id = ?, serving_multiplier = ?, input_amount = ?, "
                                + "input_unit = ?, food_name_snapshot = ?, serving_amount_snapshot = ?, "
                                + "serving_unit_snapshot = ?, calories_snapshot = ?, "
                                + "protein_g_snapshot = ?, carbs_g_snapshot = ?, fat_g_snapshot = ?, "
                                + "estimated_snapshot = ?, note = ?, updated_at = current_timestamp "
                                + "where id = ?",
                        mealId,
                        serving.multiplier(),
                        serving.inputAmount(),
                        serving.inputUnit(),
                        food.name(),
                        food.servingAmount(),
                        food.servingUnit(),
                        scaled(food.calories(), serving.multiplier()),
                        scaled(food.protein(), serving.multiplier()),
                        scaled(food.carbs(), serving.multiplier()),
                        scaled(food.fat(), serving.multiplier()),
                        food.estimated(),
                        cleanNote(request.note()),
                        entryId);
        if (updated != 1) throw notFound("Meal entry not found");
        return loadPlan(userId, date, owned.planId());
    }

    @Transactional(isolation = Isolation.READ_COMMITTED)
    public void deleteEntry(Long userId, LocalDate date, Long entryId) {
        requireUser(userId);
        loadOwnedEntry(userId, date, entryId);
        jdbc.update("delete from meal_entries where id = ?", entryId);
    }

    @Transactional(readOnly = true)
    public List<NutritionDtos.MealTemplate> listTemplates(Long userId) {
        requireUser(userId);
        return jdbc.query(
                "select id, name, description, source_meal_plan_id from meal_templates "
                        + "where user_id = ? order by updated_at desc, id desc",
                (rs, row) ->
                        new NutritionDtos.MealTemplate(
                                rs.getLong("id"),
                                rs.getString("name"),
                                rs.getString("description"),
                                nullableLong(rs, "source_meal_plan_id"),
                                loadTemplateItems(rs.getLong("id"))),
                userId);
    }

    @Transactional(readOnly = true)
    public NutritionDtos.MealTemplate getTemplate(Long userId, Long templateId) {
        requireUser(userId);
        List<NutritionDtos.MealTemplate> rows =
                jdbc.query(
                        "select id, name, description, source_meal_plan_id from meal_templates "
                                + "where id = ? and user_id = ?",
                        (rs, row) ->
                                new NutritionDtos.MealTemplate(
                                        rs.getLong("id"),
                                        rs.getString("name"),
                                        rs.getString("description"),
                                        nullableLong(rs, "source_meal_plan_id"),
                                        loadTemplateItems(rs.getLong("id"))),
                        templateId,
                        userId);
        if (rows.isEmpty()) throw notFound("Meal template not found");
        return rows.getFirst();
    }

    @Transactional
    public NutritionDtos.MealTemplate createTemplate(
            Long userId, CreateMealTemplateRequest request) {
        requireUser(userId);
        Long sourcePlanId = request.sourceMealPlanId();
        if (sourcePlanId != null) assertPlanOwner(userId, sourcePlanId);
        Long id =
                jdbc.queryForObject(
                        "insert into meal_templates (user_id, name, description, source_meal_plan_id) "
                                + "values (?, ?, ?, ?) returning id",
                        Long.class,
                        userId,
                        request.name().trim(),
                        cleanText(request.description()),
                        sourcePlanId);
        if (sourcePlanId != null) {
            jdbc.update(
                    "insert into meal_template_items (meal_template_id, food_id, meal_type, "
                            + "serving_multiplier, food_name_snapshot, serving_amount_snapshot, "
                            + "serving_unit_snapshot, sort_order) "
                            + "select ?, e.food_id, m.meal_type, e.serving_multiplier, "
                            + "e.food_name_snapshot, e.serving_amount_snapshot, "
                            + "e.serving_unit_snapshot, m.sort_order from meal_entries e "
                            + "join meals m on m.id = e.meal_id where m.meal_plan_id = ?",
                    id,
                    sourcePlanId);
        } else {
            insertTemplateItems(id, request.items());
        }
        return getTemplate(userId, id);
    }

    @Transactional
    public NutritionDtos.MealTemplate updateTemplate(
            Long userId, Long templateId, CreateMealTemplateRequest request) {
        getTemplate(userId, templateId);
        Long sourcePlanId = request.sourceMealPlanId();
        if (sourcePlanId != null) assertPlanOwner(userId, sourcePlanId);
        jdbc.update(
                "update meal_templates set name = ?, description = ?, source_meal_plan_id = ?, "
                        + "updated_at = current_timestamp where id = ? and user_id = ?",
                request.name().trim(),
                cleanText(request.description()),
                sourcePlanId,
                templateId,
                userId);
        jdbc.update("delete from meal_template_items where meal_template_id = ?", templateId);
        if (sourcePlanId != null) {
            jdbc.update(
                    "insert into meal_template_items (meal_template_id, food_id, meal_type, "
                            + "serving_multiplier, food_name_snapshot, serving_amount_snapshot, "
                            + "serving_unit_snapshot, sort_order) select ?, e.food_id, m.meal_type, "
                            + "e.serving_multiplier, e.food_name_snapshot, e.serving_amount_snapshot, "
                            + "e.serving_unit_snapshot, m.sort_order from meal_entries e join meals m "
                            + "on m.id = e.meal_id where m.meal_plan_id = ?",
                    templateId,
                    sourcePlanId);
        } else {
            insertTemplateItems(templateId, request.items());
        }
        return getTemplate(userId, templateId);
    }

    @Transactional
    public void deleteTemplate(Long userId, Long templateId) {
        requireUser(userId);
        jdbc.update("delete from meal_templates where id = ? and user_id = ?", templateId, userId);
    }

    @Transactional(isolation = Isolation.READ_COMMITTED)
    public NutritionDtos.ApplyTemplateResult applyTemplate(
            Long userId, Long templateId, ApplyMealTemplateRequest request) {
        if (!"MERGE".equalsIgnoreCase(request.mode())) {
            throw validation("Only MERGE template mode is supported");
        }
        NutritionDtos.MealTemplate template = getTemplate(userId, templateId);
        List<NutritionDtos.TemplateItem> blocked =
                template.items().stream().filter(item -> !item.available()).toList();
        if (!blocked.isEmpty()) {
            return new NutritionDtos.ApplyTemplateResult(
                    false,
                    request.targetDate(),
                    0,
                    blocked,
                    getMealPlan(userId, request.targetDate()));
        }
        Long planId = ensurePlan(userId, request.targetDate());
        for (NutritionDtos.TemplateItem item : template.items()) {
            FoodRow food = loadSelectableFood(item.foodId());
            Long mealId = ensureMeal(planId, item.mealType(), item.sortOrder());
            BigDecimal multiplier = item.servingMultiplier();
            jdbc.update(
                    "insert into meal_entries (meal_id, food_id, serving_multiplier, "
                            + "food_name_snapshot, serving_amount_snapshot, serving_unit_snapshot, "
                            + "calories_snapshot, protein_g_snapshot, carbs_g_snapshot, "
                            + "fat_g_snapshot, estimated_snapshot) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                    mealId,
                    food.id(),
                    multiplier,
                    food.name(),
                    food.servingAmount(),
                    food.servingUnit(),
                    scaled(food.calories(), multiplier),
                    scaled(food.protein(), multiplier),
                    scaled(food.carbs(), multiplier),
                    scaled(food.fat(), multiplier),
                    food.estimated());
        }
        NutritionDtos.MealPlan plan = loadPlan(userId, request.targetDate(), planId);
        return new NutritionDtos.ApplyTemplateResult(
                true, request.targetDate(), template.items().size(), List.of(), plan);
    }

    private NutritionDtos.MealPlan loadPlan(Long userId, LocalDate date, Long planId) {
        PlanRow plan =
                jdbc.queryForObject(
                        "select id, nutrition_target_snapshot::text from meal_plans "
                                + "where id = ? and user_id = ? and plan_date = ?",
                        (rs, row) ->
                                new PlanRow(
                                        rs.getLong("id"),
                                        nutritionFromJson(
                                                rs.getString("nutrition_target_snapshot"))),
                        planId,
                        userId,
                        date);
        if (plan == null) throw notFound("Meal plan not found");

        Map<String, NutritionDtos.Meal> byKey = new LinkedHashMap<>();
        for (String type : MEAL_ORDER) {
            byKey.put(
                    type + ":1",
                    new NutritionDtos.Meal(
                            null, type, null, 1, NutritionDtos.Nutrition.zero(), List.of()));
        }
        List<MealRow> meals =
                jdbc.query(
                        "select id, meal_type, name, sort_order from meals where meal_plan_id = ? "
                                + "order by case meal_type when 'BREAKFAST' then 1 when 'LUNCH' then 2 "
                                + "when 'DINNER' then 3 else 4 end, sort_order, id",
                        (rs, row) ->
                                new MealRow(
                                        rs.getLong("id"),
                                        rs.getString("meal_type"),
                                        rs.getString("name"),
                                        rs.getInt("sort_order")),
                        planId);
        for (MealRow meal : meals) {
            List<NutritionDtos.MealEntry> entries = loadEntries(meal);
            NutritionDtos.Nutrition subtotal = sumEntries(entries);
            byKey.put(
                    meal.type() + ":" + meal.sortOrder(),
                    new NutritionDtos.Meal(
                            meal.id(),
                            meal.type(),
                            meal.name(),
                            meal.sortOrder(),
                            subtotal,
                            entries));
        }
        List<NutritionDtos.Meal> responseMeals = new ArrayList<>(byKey.values());
        NutritionDtos.Nutrition consumed = sumMeals(responseMeals);
        NutritionDtos.Nutrition remaining = subtract(plan.target(), consumed);
        return new NutritionDtos.MealPlan(
                plan.id(),
                date,
                "SNAPSHOT",
                plan.target(),
                consumed,
                remaining,
                responseMeals,
                warnings(remaining));
    }

    private List<NutritionDtos.MealEntry> loadEntries(MealRow meal) {
        return jdbc.query(
                "select id, food_id, food_name_snapshot, serving_multiplier, input_amount, "
                        + "input_unit, serving_amount_snapshot, serving_unit_snapshot, "
                        + "calories_snapshot, protein_g_snapshot, carbs_g_snapshot, "
                        + "fat_g_snapshot, estimated_snapshot, note from meal_entries "
                        + "where meal_id = ? order by created_at, id",
                (rs, row) ->
                        new NutritionDtos.MealEntry(
                                rs.getLong("id"),
                                rs.getLong("food_id"),
                                rs.getString("food_name_snapshot"),
                                meal.type(),
                                meal.sortOrder(),
                                rs.getBigDecimal("serving_multiplier"),
                                rs.getBigDecimal("input_amount"),
                                rs.getString("input_unit"),
                                rs.getBigDecimal("serving_amount_snapshot"),
                                rs.getString("serving_unit_snapshot"),
                                new NutritionDtos.Nutrition(
                                        rs.getBigDecimal("calories_snapshot"),
                                        rs.getBigDecimal("protein_g_snapshot"),
                                        rs.getBigDecimal("carbs_g_snapshot"),
                                        rs.getBigDecimal("fat_g_snapshot")),
                                rs.getBoolean("estimated_snapshot"),
                                rs.getString("note")),
                meal.id());
    }

    private Long ensurePlan(Long userId, LocalDate date) {
        Long existing = findPlanId(userId, date);
        if (existing != null) return existing;
        NutritionDtos.Nutrition target = loadCurrentTarget(userId, true);
        try {
            jdbc.update(
                    "insert into meal_plans (user_id, plan_date, nutrition_target_snapshot) "
                            + "values (?, ?, ?::jsonb) on conflict (user_id, plan_date) do nothing",
                    userId,
                    date,
                    nutritionToJson(target));
        } catch (DuplicateKeyException ignored) {
            // A concurrent first mutation won the natural-key insert.
        }
        Long planId = findPlanId(userId, date);
        if (planId == null) throw new IllegalStateException("Could not create meal plan");
        return planId;
    }

    private Long ensureMeal(Long planId, String mealType, int sortOrder) {
        jdbc.update(
                "insert into meals (meal_plan_id, meal_type, sort_order) values (?, ?, ?) "
                        + "on conflict (meal_plan_id, meal_type, sort_order) do nothing",
                planId,
                mealType,
                sortOrder);
        return jdbc.queryForObject(
                "select id from meals where meal_plan_id = ? and meal_type = ? and sort_order = ?",
                Long.class,
                planId,
                mealType,
                sortOrder);
    }

    private Long findPlanId(Long userId, LocalDate date) {
        List<Long> rows =
                jdbc.queryForList(
                        "select id from meal_plans where user_id = ? and plan_date = ?",
                        Long.class,
                        userId,
                        date);
        return rows.isEmpty() ? null : rows.getFirst();
    }

    private NutritionDtos.Nutrition loadCurrentTarget(Long userId, boolean required) {
        List<NutritionDtos.Nutrition> rows =
                jdbc.query(
                        "select calories_kcal, protein_g, carbs_g, fat_g from nutrition_targets "
                                + "where user_id = ?",
                        (rs, row) ->
                                new NutritionDtos.Nutrition(
                                        rs.getBigDecimal("calories_kcal"),
                                        rs.getBigDecimal("protein_g"),
                                        rs.getBigDecimal("carbs_g"),
                                        rs.getBigDecimal("fat_g")),
                        userId);
        if (rows.isEmpty()) {
            if (required) {
                throw new ApiException(
                        ApiErrorCode.HEALTH_PROFILE_REQUIRED,
                        "Nutrition target is required before adding a meal entry");
            }
            return null;
        }
        return rows.getFirst();
    }

    private NutritionDtos.MealPlan emptyPlan(LocalDate date, NutritionDtos.Nutrition target) {
        List<NutritionDtos.Meal> meals =
                MEAL_ORDER.stream()
                        .map(
                                type ->
                                        new NutritionDtos.Meal(
                                                null,
                                                type,
                                                null,
                                                1,
                                                NutritionDtos.Nutrition.zero(),
                                                List.of()))
                        .toList();
        NutritionDtos.Nutrition zero = NutritionDtos.Nutrition.zero();
        return new NutritionDtos.MealPlan(
                null, date, "CURRENT", target, zero, target, meals, List.of());
    }

    private FoodRow loadSelectableFood(Long foodId) {
        if (foodId == null) throw validation("foodId is required");
        List<FoodRow> rows =
                jdbc.query(
                        "select * from foods where id = ? and visibility = 'PUBLIC' "
                                + "and deleted_at is null",
                        (rs, row) ->
                                new FoodRow(
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
                                        rs.getBoolean("is_estimated")),
                        foodId);
        if (rows.isEmpty()) {
            throw new ApiException(ApiErrorCode.FOOD_NOT_FOUND, "Food not found or not selectable");
        }
        return rows.getFirst();
    }

    private NutritionDtos.Food mapFood(java.sql.ResultSet rs, boolean selectable)
            throws java.sql.SQLException {
        return new NutritionDtos.Food(
                rs.getLong("id"),
                rs.getString("name"),
                rs.getString("slug"),
                rs.getString("category"),
                new NutritionDtos.Serving(
                        rs.getBigDecimal("serving_amount"),
                        rs.getString("serving_unit"),
                        rs.getBigDecimal("grams_per_serving")),
                new NutritionDtos.Nutrition(
                        rs.getBigDecimal("calories_per_serving"),
                        rs.getBigDecimal("protein_g_per_serving"),
                        rs.getBigDecimal("carbs_g_per_serving"),
                        rs.getBigDecimal("fat_g_per_serving")),
                rs.getString("data_source"),
                rs.getString("source_note"),
                rs.getBoolean("is_estimated"),
                selectable,
                loadFoodMedia(rs.getLong("id")));
    }

    private List<Object> loadFoodMedia(Long foodId) {
        return jdbc.query(
                "select id, role, mime_type from media_objects where owner_type='FOOD' and owner_id=? and status='READY' and visibility='PUBLIC' and deleted_at is null order by sort_order, id",
                (rs, row) ->
                        Map.of(
                                "id", rs.getLong("id"),
                                "role", rs.getString("role"),
                                "mimeType", rs.getString("mime_type"),
                                "url", "/api/v1/media-content/" + rs.getLong("id") + "/public"),
                foodId);
    }

    private ServingInput servingInput(MealEntryRequest request, FoodRow food) {
        boolean hasAmount = request.inputAmount() != null;
        boolean hasUnit = request.inputUnit() != null && !request.inputUnit().isBlank();
        if (hasAmount != hasUnit) {
            throw validation("inputAmount and inputUnit must be supplied together");
        }
        if (hasAmount) {
            if (!"GRAM".equalsIgnoreCase(request.inputUnit())) {
                throw validation("Only GRAM inputUnit is supported");
            }
            if (food.gramsPerServing() == null) {
                throw new ApiException(
                        ApiErrorCode.FOOD_NOT_SELECTABLE,
                        "This food has no verified grams-per-serving conversion");
            }
            BigDecimal multiplier =
                    request.inputAmount().divide(food.gramsPerServing(), 3, RoundingMode.HALF_UP);
            if (multiplier.signum() <= 0) throw validation("Serving amount must be positive");
            return new ServingInput(multiplier, request.inputAmount(), "GRAM");
        }
        if (request.servingMultiplier() == null || request.servingMultiplier().signum() <= 0) {
            throw validation("servingMultiplier must be positive when gram input is not used");
        }
        return new ServingInput(request.servingMultiplier(), null, null);
    }

    private void validateMealRequest(MealEntryRequest request, boolean requireFood) {
        String mealType = request.mealType().toUpperCase(Locale.ROOT);
        if (!MEAL_TYPES.contains(mealType) || !mealType.equals(request.mealType())) {
            throw validation("Invalid mealType");
        }
        if (request.mealSortOrder() == null || request.mealSortOrder() <= 0) {
            throw validation("mealSortOrder must be positive");
        }
        if (requireFood && request.foodId() == null) throw validation("foodId is required");
    }

    private EntryOwnerRow loadOwnedEntry(Long userId, LocalDate date, Long entryId) {
        List<EntryOwnerRow> rows =
                jdbc.query(
                        "select p.id as plan_id, e.food_id from meal_entries e join meals m on "
                                + "m.id = e.meal_id join meal_plans p on p.id = m.meal_plan_id "
                                + "where e.id = ? and p.user_id = ? and p.plan_date = ?",
                        (rs, row) ->
                                new EntryOwnerRow(rs.getLong("plan_id"), rs.getLong("food_id")),
                        entryId,
                        userId,
                        date);
        if (rows.isEmpty()) throw notFound("Meal entry not found");
        return rows.getFirst();
    }

    private List<NutritionDtos.TemplateItem> loadTemplateItems(Long templateId) {
        return jdbc.query(
                "select i.id, i.food_id, i.food_name_snapshot, i.meal_type, i.sort_order, "
                        + "i.serving_multiplier, i.serving_amount_snapshot, i.serving_unit_snapshot, "
                        + "(f.visibility = 'PUBLIC' and f.deleted_at is null) available "
                        + "from meal_template_items i join foods f on f.id = i.food_id "
                        + "where i.meal_template_id = ? order by case i.meal_type "
                        + "when 'BREAKFAST' then 1 when 'LUNCH' then 2 when 'DINNER' then 3 else 4 end, "
                        + "i.sort_order, i.id",
                (rs, row) ->
                        new NutritionDtos.TemplateItem(
                                rs.getLong("id"),
                                rs.getLong("food_id"),
                                rs.getString("food_name_snapshot"),
                                rs.getString("meal_type"),
                                rs.getInt("sort_order"),
                                rs.getBigDecimal("serving_multiplier"),
                                rs.getBigDecimal("serving_amount_snapshot"),
                                rs.getString("serving_unit_snapshot"),
                                rs.getBoolean("available")),
                templateId);
    }

    private void insertTemplateItems(Long templateId, List<CreateMealTemplateRequest.Item> items) {
        if (items == null || items.isEmpty()) return;
        for (CreateMealTemplateRequest.Item item : items) {
            if (item.foodId() == null
                    || item.mealType() == null
                    || !MEAL_TYPES.contains(item.mealType())
                    || item.servingMultiplier() == null
                    || item.servingMultiplier().signum() <= 0) {
                throw validation("Invalid meal template item");
            }
            FoodRow food = loadSelectableFood(item.foodId());
            jdbc.update(
                    "insert into meal_template_items (meal_template_id, food_id, meal_type, "
                            + "serving_multiplier, food_name_snapshot, serving_amount_snapshot, "
                            + "serving_unit_snapshot, sort_order) values (?, ?, ?, ?, ?, ?, ?, ?)",
                    templateId,
                    food.id(),
                    item.mealType(),
                    item.servingMultiplier(),
                    food.name(),
                    food.servingAmount(),
                    food.servingUnit(),
                    item.sortOrder() == null ? 1 : item.sortOrder());
        }
    }

    private void assertPlanOwner(Long userId, Long planId) {
        Integer count =
                jdbc.queryForObject(
                        "select count(*) from meal_plans where id = ? and user_id = ?",
                        Integer.class,
                        planId,
                        userId);
        if (count == null || count == 0) throw notFound("Source meal plan not found");
    }

    private void requireUser(Long userId) {
        if (userId == null) {
            throw new ApiException(ApiErrorCode.UNAUTHENTICATED, "Authentication is required");
        }
    }

    private NutritionDtos.Nutrition nutritionFromJson(String json) {
        try {
            JsonNode node = objectMapper.readTree(json);
            return new NutritionDtos.Nutrition(
                    decimal(node, "caloriesKcal"),
                    decimal(node, "proteinG"),
                    decimal(node, "carbsG"),
                    decimal(node, "fatG"));
        } catch (JsonProcessingException exception) {
            throw new IllegalStateException("Invalid nutrition target snapshot", exception);
        }
    }

    private String nutritionToJson(NutritionDtos.Nutrition value) {
        try {
            return objectMapper.writeValueAsString(value);
        } catch (JsonProcessingException exception) {
            throw new IllegalStateException("Cannot serialize nutrition target", exception);
        }
    }

    private static BigDecimal decimal(JsonNode node, String field) {
        return node.path(field).decimalValue();
    }

    private static NutritionDtos.Nutrition sumEntries(List<NutritionDtos.MealEntry> entries) {
        return entries.stream()
                .map(NutritionDtos.MealEntry::nutrition)
                .reduce(NutritionDtos.Nutrition.zero(), NutritionService::add);
    }

    private static NutritionDtos.Nutrition sumMeals(List<NutritionDtos.Meal> meals) {
        return meals.stream()
                .map(NutritionDtos.Meal::subtotal)
                .reduce(NutritionDtos.Nutrition.zero(), NutritionService::add);
    }

    private static NutritionDtos.Nutrition add(
            NutritionDtos.Nutrition a, NutritionDtos.Nutrition b) {
        return new NutritionDtos.Nutrition(
                a.caloriesKcal().add(b.caloriesKcal()),
                a.proteinG().add(b.proteinG()),
                a.carbsG().add(b.carbsG()),
                a.fatG().add(b.fatG()));
    }

    private static NutritionDtos.Nutrition subtract(
            NutritionDtos.Nutrition a, NutritionDtos.Nutrition b) {
        if (a == null) return null;
        return new NutritionDtos.Nutrition(
                a.caloriesKcal().subtract(b.caloriesKcal()),
                a.proteinG().subtract(b.proteinG()),
                a.carbsG().subtract(b.carbsG()),
                a.fatG().subtract(b.fatG()));
    }

    private static List<String> warnings(NutritionDtos.Nutrition remaining) {
        if (remaining == null) return List.of();
        List<String> warnings = new ArrayList<>();
        if (remaining.caloriesKcal().signum() < 0) warnings.add("CALORIES_TARGET_EXCEEDED");
        if (remaining.proteinG().signum() < 0) warnings.add("PROTEIN_TARGET_EXCEEDED");
        if (remaining.carbsG().signum() < 0) warnings.add("CARBS_TARGET_EXCEEDED");
        if (remaining.fatG().signum() < 0) warnings.add("FAT_TARGET_EXCEEDED");
        return List.copyOf(warnings);
    }

    private static BigDecimal scaled(BigDecimal value, BigDecimal multiplier) {
        return value.multiply(multiplier).setScale(2, RoundingMode.HALF_UP);
    }

    private static String normalize(String value) {
        String normalized = Normalizer.normalize(value.trim(), Normalizer.Form.NFD);
        return DIACRITICS
                .matcher(normalized)
                .replaceAll("")
                .replace('đ', 'd')
                .replace('Đ', 'D')
                .toLowerCase(Locale.ROOT)
                .replaceAll("[^a-z0-9]+", " ")
                .trim();
    }

    private static String cleanNote(String value) {
        return cleanText(value);
    }

    private static String cleanText(String value) {
        if (value == null || value.isBlank()) return null;
        return value.trim();
    }

    private static Long nullableLong(java.sql.ResultSet rs, String column)
            throws java.sql.SQLException {
        long value = rs.getLong(column);
        return rs.wasNull() ? null : value;
    }

    private static ApiException validation(String message) {
        return new ApiException(ApiErrorCode.VALIDATION_ERROR, message);
    }

    private static ApiException notFound(String message) {
        return new ApiException(ApiErrorCode.RESOURCE_NOT_FOUND, message);
    }

    private record ServingInput(BigDecimal multiplier, BigDecimal inputAmount, String inputUnit) {}

    private record EntryOwnerRow(Long planId, Long foodId) {}

    private record MealRow(Long id, String type, String name, int sortOrder) {}

    private record PlanRow(Long id, NutritionDtos.Nutrition target) {}

    private record PlanDateRow(Long id, LocalDate date) {}

    private record FoodRow(
            Long id,
            String name,
            String slug,
            String category,
            BigDecimal servingAmount,
            String servingUnit,
            BigDecimal gramsPerServing,
            BigDecimal calories,
            BigDecimal protein,
            BigDecimal carbs,
            BigDecimal fat,
            String dataSource,
            String sourceNote,
            boolean estimated) {
        NutritionDtos.Food toDto() {
            return new NutritionDtos.Food(
                    id,
                    name,
                    slug,
                    category,
                    new NutritionDtos.Serving(servingAmount, servingUnit, gramsPerServing),
                    new NutritionDtos.Nutrition(calories, protein, carbs, fat),
                    dataSource,
                    sourceNote,
                    estimated,
                    true,
                    List.of());
        }
    }
}
