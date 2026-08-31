import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/exercise_catalog.dart';
import '../domain/workout_models.dart';

final favoriteExercisesProvider =
    NotifierProvider<FavoriteExercisesController, Set<String>>(
      FavoriteExercisesController.new,
    );

class FavoriteExercisesController extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    // Initial favorite staples
    return {
      'ex1', // Barbell Bench Press
      'ex5', // Lat Pulldown
      'ex6', // Barbell Squat
    };
  }

  bool isFavorite(String exerciseId) => state.contains(exerciseId);

  bool toggleFavorite(String exerciseId) {
    final updated = Set<String>.from(state);
    final isFav = updated.contains(exerciseId);
    if (isFav) {
      updated.remove(exerciseId);
    } else {
      updated.add(exerciseId);
    }
    state = updated;
    return !isFav;
  }

  void addFavorite(String exerciseId) {
    if (!state.contains(exerciseId)) {
      state = {...state, exerciseId};
    }
  }

  void removeFavorite(String exerciseId) {
    if (state.contains(exerciseId)) {
      state = state.where((id) => id != exerciseId).toSet();
    }
  }

  List<ExerciseDefinition> getFavorites() {
    return exerciseCatalog.where((ex) => state.contains(ex.id)).toList();
  }
}
