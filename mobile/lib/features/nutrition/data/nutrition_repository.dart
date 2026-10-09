import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../domain/food_models.dart';

final nutritionRepositoryProvider = Provider<NutritionRepository>((ref) {
  return NutritionRepository(ref.watch(dioProvider));
});

class NutritionRepository {
  const NutritionRepository(this._dio);
  final Dio _dio;

  Future<List<FoodItem>> getFoods({String? query, String? category}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/foods',
      queryParameters: {
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        if (category != null && category != 'ALL') 'category': category,
        'page': 0,
        'size': 100,
        'sort': 'name,asc',
      },
    );
    final data = _map(response.data?['data']);
    return _list(data['content']).map(FoodApiMapper.food).toList();
  }

  Future<FoodItem> getFood(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/api/v1/foods/$id');
    return FoodApiMapper.food(_map(response.data?['data']));
  }

  Future<List<FoodItem>> getFavorites() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/favorite-foods',
      queryParameters: {'page': 0, 'size': 100},
    );
    final data = _map(response.data?['data']);
    return _list(data['content']).map(FoodApiMapper.food).toList();
  }

  Future<void> addFavorite(String foodId) =>
      _dio.put<void>('/api/v1/favorite-foods/$foodId');

  Future<void> removeFavorite(String foodId) =>
      _dio.delete<void>('/api/v1/favorite-foods/$foodId');

  Future<MealPlanApi> getMealPlan(String date) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/meal-plans',
      queryParameters: {'date': date},
    );
    return MealPlanApi.fromJson(_map(response.data?['data']));
  }

  Future<List<MealPlanApi>> getMealHistory() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/meal-plans/history',
      queryParameters: {'page': 0, 'size': 30},
    );
    final data = _map(response.data?['data']);
    return _list(data['content']).map(MealPlanApi.fromJson).toList();
  }

  Future<MealPlanApi> addEntry({
    required String date,
    required String foodId,
    required MealType mealType,
    required double servingMultiplier,
    double? inputAmount,
    String? inputUnit,
    String? note,
  }) async {
    final payload = <String, dynamic>{
      'mealType': mealType.code,
      'mealSortOrder': 1,
      'foodId': int.parse(foodId),
      'servingMultiplier': servingMultiplier,
    };
    if (inputAmount != null) payload['inputAmount'] = inputAmount;
    if (inputUnit != null) payload['inputUnit'] = inputUnit;
    if (note != null) payload['note'] = note;
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/meal-plans/$date/entries',
      data: payload,
    );
    return MealPlanApi.fromJson(_map(response.data?['data']));
  }

  Future<MealPlanApi> updateEntry({
    required String date,
    required String entryId,
    required MealType mealType,
    required double servingMultiplier,
    double? inputAmount,
    String? inputUnit,
    String? note,
  }) async {
    final payload = <String, dynamic>{
      'mealType': mealType.code,
      'mealSortOrder': 1,
      'servingMultiplier': servingMultiplier,
    };
    if (inputAmount != null) payload['inputAmount'] = inputAmount;
    if (inputUnit != null) payload['inputUnit'] = inputUnit;
    if (note != null) payload['note'] = note;
    final response = await _dio.put<Map<String, dynamic>>(
      '/api/v1/meal-plans/$date/entries/$entryId',
      data: payload,
    );
    return MealPlanApi.fromJson(_map(response.data?['data']));
  }

  Future<void> deleteEntry(String date, String entryId) =>
      _dio.delete<void>('/api/v1/meal-plans/$date/entries/$entryId');

  Future<List<MealTemplateApi>> getTemplates() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/meal-templates',
    );
    return _list(response.data?['data']).map(MealTemplateApi.fromJson).toList();
  }

  Future<MealTemplateApi> saveCurrentPlanAsTemplate({
    required String name,
    required int sourceMealPlanId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/meal-templates',
      data: {'name': name, 'sourceMealPlanId': sourceMealPlanId},
    );
    return MealTemplateApi.fromJson(_map(response.data?['data']));
  }

  Future<TemplateApplyApi> applyTemplate(int id, String targetDate) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/meal-templates/$id/apply',
      data: {'targetDate': targetDate, 'mode': 'MERGE'},
    );
    return TemplateApplyApi.fromJson(_map(response.data?['data']));
  }
}

class FoodApiMapper {
  static FoodItem food(Map<String, dynamic> json) {
    final serving = _map(json['serving']);
    final nutrition = _map(json['nutritionPerServing']);
    final grams = _doubleOrNull(serving['gramsPerServing']);
    final unit = '${serving['amount'] ?? 1} ${serving['unit'] ?? 'phần'}';
    return FoodItem(
      id: '${json['id']}',
      name: '${json['name'] ?? ''}',
      category: _category('${json['category'] ?? ''}'),
      baseServingUnit: unit,
      baseCalories: _number(nutrition['caloriesKcal']).round(),
      baseProtein: _number(nutrition['proteinG']),
      baseCarbs: _number(nutrition['carbsG']),
      baseFat: _number(nutrition['fatG']),
      imageUrl: '',
      description: '${json['sourceNote'] ?? ''}',
      gramsPerServing: grams,
      estimated: json['estimated'] as bool? ?? true,
      dataSource: json['dataSource'] as String?,
      sourceNote: json['sourceNote'] as String?,
      selectable: json['selectable'] as bool? ?? true,
      servingOptions: [
        ServingOption(
          id: 'serving_${json['id']}',
          name: unit,
          multiplier: 1,
          grams: grams?.round() ?? 0,
          isDefault: true,
        ),
      ],
    );
  }

  static FoodCategory _category(String value) {
    if (value == 'DAM') return FoodCategory.protein;
    if (value == 'TINH_BOT' || value == 'COM') return FoodCategory.staple;
    if (value == 'TRAI_CAY' || value == 'AN_VAT') return FoodCategory.snack;
    if (value == 'CANH_RAU') return FoodCategory.vegetable;
    if (value == 'DO_UONG') return FoodCategory.beverage;
    return FoodCategory.vietnamese;
  }
}

class MealPlanApi {
  const MealPlanApi({
    required this.id,
    required this.date,
    required this.targetSource,
    required this.target,
    required this.consumed,
    required this.remaining,
    required this.entries,
    required this.warnings,
  });

  factory MealPlanApi.fromJson(Map<String, dynamic> json) {
    final entries = <FoodEntry>[];
    for (final meal in _list(json['meals'])) {
      final type = MealType.values.firstWhere(
        (item) => item.code == meal['mealType'],
        orElse: () => MealType.snack,
      );
      for (final raw in _list(meal['entries'])) {
        final nutrition = NutritionApi.fromJson(_map(raw['nutrition']));
        entries.add(
          FoodEntry(
            id: '${raw['id']}',
            foodId: '${raw['foodId']}',
            name: '${raw['foodName'] ?? ''}',
            mealType: type,
            calories: nutrition.calories.round(),
            protein: nutrition.protein,
            carbs: nutrition.carbs,
            fat: nutrition.fat,
            servingAmount: _number(raw['servingMultiplier']),
            servingUnit: '${raw['servingAmount']} ${raw['servingUnit']}',
            servingMultiplier: _number(raw['servingMultiplier']),
            inputAmount: _doubleOrNull(raw['inputAmount']),
            inputUnit: raw['inputUnit'] as String?,
            imageUrl: '',
            date: '${json['planDate']}',
            estimated: raw['estimated'] as bool? ?? true,
          ),
        );
      }
    }
    return MealPlanApi(
      id: (json['id'] as num?)?.toInt(),
      date: '${json['planDate']}',
      targetSource: '${json['targetSource'] ?? 'CURRENT'}',
      target: json['target'] == null
          ? null
          : NutritionApi.fromJson(_map(json['target'])),
      consumed: NutritionApi.fromJson(_map(json['consumed'])),
      remaining: json['remaining'] == null
          ? null
          : NutritionApi.fromJson(_map(json['remaining'])),
      entries: entries,
      warnings: _list(json['warnings']).map((e) => '$e').toList(),
    );
  }

  final int? id;
  final String date;
  final String targetSource;
  final NutritionApi? target;
  final NutritionApi consumed;
  final NutritionApi? remaining;
  final List<FoodEntry> entries;
  final List<String> warnings;
}

class NutritionApi {
  const NutritionApi(this.calories, this.protein, this.carbs, this.fat);
  factory NutritionApi.fromJson(Map<String, dynamic> json) => NutritionApi(
    _number(json['caloriesKcal']),
    _number(json['proteinG']),
    _number(json['carbsG']),
    _number(json['fatG']),
  );
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
}

class MealTemplateApi {
  const MealTemplateApi({
    required this.id,
    required this.name,
    required this.items,
  });
  factory MealTemplateApi.fromJson(Map<String, dynamic> json) =>
      MealTemplateApi(
        id: (json['id'] as num).toInt(),
        name: '${json['name']}',
        items: _list(json['items']),
      );
  final int id;
  final String name;
  final List<Map<String, dynamic>> items;
}

class TemplateApplyApi {
  const TemplateApplyApi({required this.applied, required this.blockedItems});
  factory TemplateApplyApi.fromJson(Map<String, dynamic> json) =>
      TemplateApplyApi(
        applied: json['applied'] as bool? ?? false,
        blockedItems: _list(json['blockedItems']),
      );
  final bool applied;
  final List<Map<String, dynamic>> blockedItems;
}

Map<String, dynamic> _map(dynamic value) =>
    value is Map<String, dynamic> ? value : <String, dynamic>{};
List<Map<String, dynamic>> _list(dynamic value) => value is List
    ? value.whereType<Map<String, dynamic>>().toList()
    : <Map<String, dynamic>>[];
double _number(dynamic value) => (value as num?)?.toDouble() ?? 0;
double? _doubleOrNull(dynamic value) => (value as num?)?.toDouble();
