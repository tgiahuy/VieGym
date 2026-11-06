import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/preference_repository.dart';

enum WorkoutTimePreference {
  morning('Sáng (5h-10h)'),
  afternoon('Chiều (14h-18h)'),
  evening('Tối (18h-22h)');

  const WorkoutTimePreference(this.label);
  final String label;
}

/// Injury flags understood by the backend AI exercise filter.
enum InjuryArea {
  lowerBack('LOWER_BACK', 'Lưng dưới'),
  knee('KNEE', 'Đầu gối'),
  shoulder('SHOULDER', 'Vai'),
  wrist('WRIST', 'Cổ tay'),
  elbow('ELBOW', 'Khuỷu tay'),
  neck('NECK', 'Cổ'),
  ankle('ANKLE', 'Cổ chân'),
  hip('HIP', 'Hông');

  const InjuryArea(this.code, this.label);
  final String code;
  final String label;
}

class UserPreferences {
  const UserPreferences({
    this.preferredWorkoutTime = WorkoutTimePreference.afternoon,
    this.defaultDurationMinutes = 45,
    this.targetMusclesPriority = const ['Ngực', 'Tay trước', 'Bụng/Core'],
    this.mealsPerDay = 4,
    this.dislikedFoods = const [],
    this.allergies = const [],
    this.injuries = const {},
  });

  final WorkoutTimePreference preferredWorkoutTime;
  final int defaultDurationMinutes;
  final List<String> targetMusclesPriority;
  final int mealsPerDay;
  final List<String> dislikedFoods;
  final List<String> allergies;
  final Set<InjuryArea> injuries;

  UserPreferences copyWith({
    WorkoutTimePreference? preferredWorkoutTime,
    int? defaultDurationMinutes,
    List<String>? targetMusclesPriority,
    int? mealsPerDay,
    List<String>? dislikedFoods,
    List<String>? allergies,
    Set<InjuryArea>? injuries,
  }) {
    return UserPreferences(
      preferredWorkoutTime: preferredWorkoutTime ?? this.preferredWorkoutTime,
      defaultDurationMinutes:
          defaultDurationMinutes ?? this.defaultDurationMinutes,
      targetMusclesPriority:
          targetMusclesPriority ?? this.targetMusclesPriority,
      mealsPerDay: mealsPerDay ?? this.mealsPerDay,
      dislikedFoods: dislikedFoods ?? this.dislikedFoods,
      allergies: allergies ?? this.allergies,
      injuries: injuries ?? this.injuries,
    );
  }
}

/// Edits happen locally; [save] writes the whole document to the backend,
/// whose allergy/disliked-food/injury lists drive the AI planners' hard filters.
class UserPreferencesController extends Notifier<UserPreferences> {
  /// Last server document, so fields this screen does not edit
  /// (dietaryConstraints, preferredTrainingTime, other map keys) survive a PUT.
  Map<String, dynamic> _server = const {};

  @override
  UserPreferences build() {
    Future<void>.microtask(load);
    return const UserPreferences();
  }

  Future<void> load() async {
    try {
      final document = await ref.read(preferenceRepositoryProvider).get();
      if (!ref.mounted) return;
      _server = document;
      state = _fromDocument(document);
    } catch (_) {
      // Keep the current (local) values when the backend is unreachable.
    }
  }

  Future<void> save() async {
    final saved = await ref
        .read(preferenceRepositoryProvider)
        .replace(_toDocument(state));
    if (!ref.mounted) return;
    _server = saved;
    state = _fromDocument(saved);
  }

  void updatePreferences(UserPreferences newPrefs) {
    state = newPrefs;
  }

  void setPreferredTime(WorkoutTimePreference time) {
    state = state.copyWith(preferredWorkoutTime: time);
  }

  void setDefaultDuration(int minutes) {
    state = state.copyWith(defaultDurationMinutes: minutes);
  }

  void toggleMusclePriority(String muscle) {
    final list = [...state.targetMusclesPriority];
    if (list.contains(muscle)) {
      list.remove(muscle);
    } else {
      list.add(muscle);
    }
    state = state.copyWith(targetMusclesPriority: list);
  }

  void setMealsPerDay(int meals) {
    state = state.copyWith(mealsPerDay: meals);
  }

  void addDislikedFood(String food) {
    if (food.trim().isEmpty || state.dislikedFoods.contains(food.trim())) {
      return;
    }
    state = state.copyWith(
      dislikedFoods: [...state.dislikedFoods, food.trim()],
    );
  }

  void removeDislikedFood(String food) {
    state = state.copyWith(
      dislikedFoods: state.dislikedFoods.where((f) => f != food).toList(),
    );
  }

  void addAllergy(String allergy) {
    if (allergy.trim().isEmpty || state.allergies.contains(allergy.trim())) {
      return;
    }
    state = state.copyWith(allergies: [...state.allergies, allergy.trim()]);
  }

  void removeAllergy(String allergy) {
    state = state.copyWith(
      allergies: state.allergies.where((a) => a != allergy).toList(),
    );
  }

  void toggleInjury(InjuryArea area) {
    final injuries = {...state.injuries};
    if (!injuries.remove(area)) injuries.add(area);
    state = state.copyWith(injuries: injuries);
  }

  Map<String, dynamic> _toDocument(UserPreferences prefs) {
    return {
      ..._server,
      'dislikedFoods': prefs.dislikedFoods,
      'allergies': prefs.allergies,
      'dietaryConstraints': _strings(_server['dietaryConstraints']),
      'injuries': InjuryArea.values
          .where(prefs.injuries.contains)
          .map((area) => area.code)
          .toList(),
      'trainingPreferences': {
        ..._map(_server['trainingPreferences']),
        'preferredWorkoutTime': prefs.preferredWorkoutTime.name,
        'defaultDurationMinutes': prefs.defaultDurationMinutes,
        'targetMusclesPriority': prefs.targetMusclesPriority,
      },
      'mealPreferences': {
        ..._map(_server['mealPreferences']),
        'mealsPerDay': prefs.mealsPerDay,
      },
    };
  }

  static UserPreferences _fromDocument(Map<String, dynamic> document) {
    const defaults = UserPreferences();
    final training = _map(document['trainingPreferences']);
    final meals = _map(document['mealPreferences']);
    final injuryCodes = _strings(document['injuries']).toSet();
    final muscles = _strings(training['targetMusclesPriority']);
    return UserPreferences(
      preferredWorkoutTime:
          WorkoutTimePreference.values
              .where((value) => value.name == training['preferredWorkoutTime'])
              .firstOrNull ??
          defaults.preferredWorkoutTime,
      defaultDurationMinutes:
          (training['defaultDurationMinutes'] as num?)?.toInt() ??
          defaults.defaultDurationMinutes,
      targetMusclesPriority: training.containsKey('targetMusclesPriority')
          ? muscles
          : defaults.targetMusclesPriority,
      mealsPerDay:
          (meals['mealsPerDay'] as num?)?.toInt() ?? defaults.mealsPerDay,
      dislikedFoods: _strings(document['dislikedFoods']),
      allergies: _strings(document['allergies']),
      injuries: InjuryArea.values
          .where((area) => injuryCodes.contains(area.code))
          .toSet(),
    );
  }

  static Map<String, dynamic> _map(Object? value) =>
      value is Map<String, dynamic> ? value : <String, dynamic>{};

  static List<String> _strings(Object? value) =>
      value is List ? value.map((item) => '$item').toList() : <String>[];
}

final userPreferencesProvider =
    NotifierProvider<UserPreferencesController, UserPreferences>(
      UserPreferencesController.new,
    );
