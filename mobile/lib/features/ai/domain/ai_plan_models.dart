/// Plans returned by `POST /api/v1/ai/workouts/generate` and
/// `POST /api/v1/ai/meals/generate`.
///
/// `generatedBy` is the provider name (e.g. `gemini`) when the AI produced the
/// plan, `heuristic` when the backend fell back to its rule-based planner and,
/// for meal plans only, `mixed` when some meals came from each.
library;

const String heuristicSource = 'heuristic';

class AiWorkoutPlan {
  const AiWorkoutPlan({
    required this.recommendationId,
    required this.version,
    required this.planTitle,
    required this.rationale,
    required this.estimatedDurationMinutes,
    required this.exercises,
    required this.generatedBy,
    required this.personalized,
  });

  factory AiWorkoutPlan.fromJson(Map<String, dynamic> json) {
    return AiWorkoutPlan(
      recommendationId: _int(json['recommendationId']),
      version: _int(json['version']),
      planTitle: '${json['planTitle'] ?? ''}',
      rationale: '${json['rationale'] ?? ''}',
      estimatedDurationMinutes: _int(json['estimatedDurationMinutes']),
      exercises: _maps(
        json['exercises'],
      ).map(AiWorkoutPlanExercise.fromJson).toList(),
      generatedBy: '${json['generatedBy'] ?? heuristicSource}',
      personalized: json['personalized'] == true,
    );
  }

  final int recommendationId;
  final int version;
  final String planTitle;
  final String rationale;
  final int estimatedDurationMinutes;
  final List<AiWorkoutPlanExercise> exercises;
  final String generatedBy;
  final bool personalized;

  bool get isAiGenerated => generatedBy != heuristicSource;
}

class AiWorkoutPlanExercise {
  const AiWorkoutPlanExercise({
    required this.exerciseId,
    required this.name,
    required this.primaryMuscleCode,
    required this.equipmentCodes,
    required this.targetSets,
    required this.targetRepsMin,
    required this.targetRepsMax,
    required this.restSeconds,
    this.targetWeightKg,
    this.coachingTip,
  });

  factory AiWorkoutPlanExercise.fromJson(Map<String, dynamic> json) {
    return AiWorkoutPlanExercise(
      exerciseId: _int(json['exerciseId']),
      name: '${json['name'] ?? ''}',
      primaryMuscleCode: '${json['primaryMuscle'] ?? 'GENERAL'}',
      equipmentCodes: json['equipmentCodes'] is List
          ? (json['equipmentCodes'] as List).map((e) => '$e').toList()
          : const [],
      targetSets: _int(json['targetSets'], 3),
      targetRepsMin: _int(json['targetRepsMin'], 8),
      targetRepsMax: _int(json['targetRepsMax'], 12),
      restSeconds: _int(json['restSeconds'], 90),
      targetWeightKg: (json['targetWeightKg'] as num?)?.toDouble(),
      coachingTip: (json['coachingTip'] as String?)?.trim().isEmpty ?? true
          ? null
          : (json['coachingTip'] as String).trim(),
    );
  }

  final int exerciseId;
  final String name;
  final String primaryMuscleCode;
  final List<String> equipmentCodes;
  final int targetSets;
  final int targetRepsMin;
  final int targetRepsMax;
  final int restSeconds;
  final double? targetWeightKg;
  final String? coachingTip;

  /// e.g. `4 hiệp × 8-12 reps • nghỉ 90s • 22.5 kg`.
  String get prescription {
    final reps = targetRepsMin == targetRepsMax
        ? '$targetRepsMin'
        : '$targetRepsMin-$targetRepsMax';
    final weight = targetWeightKg == null
        ? ''
        : ' • ${_trimZero(targetWeightKg!)} kg';
    return '$targetSets hiệp × $reps reps • nghỉ ${restSeconds}s$weight';
  }
}

class AiMealPlan {
  const AiMealPlan({
    required this.generatedBy,
    required this.personalized,
    required this.rationale,
    required this.targetCalories,
    required this.generatedCalories,
    required this.meals,
  });

  factory AiMealPlan.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] is Map<String, dynamic>
        ? json['summary'] as Map<String, dynamic>
        : const <String, dynamic>{};
    return AiMealPlan(
      generatedBy: '${json['generatedBy'] ?? heuristicSource}',
      personalized: json['personalized'] == true,
      rationale: '${json['rationale'] ?? ''}',
      targetCalories: _int(summary['targetCalories']),
      generatedCalories: _double(summary['generatedCalories']),
      meals: _maps(json['meals']).map(AiPlannedMeal.fromJson).toList(),
    );
  }

  final String generatedBy;
  final bool personalized;
  final String rationale;
  final int targetCalories;
  final double generatedCalories;
  final List<AiPlannedMeal> meals;
}

class AiPlannedMeal {
  const AiPlannedMeal({
    required this.recommendationId,
    required this.version,
    required this.mealType,
    required this.dishName,
    required this.coachingReason,
    required this.targetCalories,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.items,
    required this.generatedBy,
  });

  factory AiPlannedMeal.fromJson(Map<String, dynamic> json) {
    return AiPlannedMeal(
      recommendationId: _int(json['recommendationId']),
      version: _int(json['version']),
      mealType: '${json['mealType'] ?? 'SNACK'}',
      dishName: '${json['dishName'] ?? ''}',
      coachingReason: '${json['coachingReason'] ?? ''}',
      targetCalories: _int(json['targetCalories']),
      calories: _double(json['calories']),
      protein: _double(json['protein']),
      carbs: _double(json['carbs']),
      fat: _double(json['fat']),
      items: _maps(json['items']).map(AiPlannedMealItem.fromJson).toList(),
      generatedBy: '${json['generatedBy'] ?? heuristicSource}',
    );
  }

  final int recommendationId;
  final int version;

  /// Backend meal type code: BREAKFAST, LUNCH, DINNER or SNACK.
  final String mealType;
  final String dishName;
  final String coachingReason;
  final int targetCalories;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final List<AiPlannedMealItem> items;
  final String generatedBy;

  bool get isAiGenerated => generatedBy != heuristicSource;
}

class AiPlannedMealItem {
  const AiPlannedMealItem({
    required this.foodId,
    required this.name,
    required this.servingUnit,
    required this.servingMultiplier,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory AiPlannedMealItem.fromJson(Map<String, dynamic> json) {
    return AiPlannedMealItem(
      foodId: _int(json['foodId']),
      name: '${json['name'] ?? ''}',
      servingUnit: '${json['servingUnit'] ?? 'phần'}',
      servingMultiplier: _double(json['servingMultiplier'], 1),
      calories: _double(json['calories']),
      protein: _double(json['protein']),
      carbs: _double(json['carbs']),
      fat: _double(json['fat']),
    );
  }

  final int foodId;
  final String name;
  final String servingUnit;
  final double servingMultiplier;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  /// e.g. `1.5 tô`.
  String get portion => '${_trimZero(servingMultiplier)} $servingUnit';
}

int _int(Object? value, [int fallback = 0]) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? fallback;

double _double(Object? value, [double fallback = 0]) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? fallback;

List<Map<String, dynamic>> _maps(Object? value) => value is List
    ? value.whereType<Map<String, dynamic>>().toList()
    : const <Map<String, dynamic>>[];

String _trimZero(double value) => value == value.roundToDouble()
    ? value.toStringAsFixed(0)
    : value
          .toStringAsFixed(2)
          .replaceFirst(RegExp(r'0+$'), '')
          .replaceFirst(RegExp(r'\.$'), '');
