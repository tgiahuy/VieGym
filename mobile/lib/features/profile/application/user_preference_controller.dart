import 'package:flutter_riverpod/flutter_riverpod.dart';

enum WorkoutTimePreference {
  morning('Sáng (5h-10h)'),
  afternoon('Chiều (14h-18h)'),
  evening('Tối (18h-22h)');

  const WorkoutTimePreference(this.label);
  final String label;
}

class UserPreferences {
  const UserPreferences({
    this.preferredWorkoutTime = WorkoutTimePreference.afternoon,
    this.defaultDurationMinutes = 45,
    this.targetMusclesPriority = const ['Ngực', 'Tay trước', 'Bụng/Core'],
    this.mealsPerDay = 4,
    this.dislikedFoods = const ['Khổ qua'],
    this.allergies = const ['Đậu phộng'],
  });

  final WorkoutTimePreference preferredWorkoutTime;
  final int defaultDurationMinutes;
  final List<String> targetMusclesPriority;
  final int mealsPerDay;
  final List<String> dislikedFoods;
  final List<String> allergies;

  UserPreferences copyWith({
    WorkoutTimePreference? preferredWorkoutTime,
    int? defaultDurationMinutes,
    List<String>? targetMusclesPriority,
    int? mealsPerDay,
    List<String>? dislikedFoods,
    List<String>? allergies,
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
    );
  }
}

class UserPreferencesController extends Notifier<UserPreferences> {
  @override
  UserPreferences build() => const UserPreferences();

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
    if (food.trim().isEmpty || state.dislikedFoods.contains(food.trim())) return;
    state = state.copyWith(dislikedFoods: [...state.dislikedFoods, food.trim()]);
  }

  void removeDislikedFood(String food) {
    state = state.copyWith(
      dislikedFoods: state.dislikedFoods.where((f) => f != food).toList(),
    );
  }

  void addAllergy(String allergy) {
    if (allergy.trim().isEmpty || state.allergies.contains(allergy.trim())) return;
    state = state.copyWith(allergies: [...state.allergies, allergy.trim()]);
  }

  void removeAllergy(String allergy) {
    state = state.copyWith(
      allergies: state.allergies.where((a) => a != allergy).toList(),
    );
  }
}

final userPreferencesProvider =
    NotifierProvider<UserPreferencesController, UserPreferences>(
  UserPreferencesController.new,
);
