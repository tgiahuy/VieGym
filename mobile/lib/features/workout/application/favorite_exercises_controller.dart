import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/exercise_catalog.dart';
import '../data/exercise_catalog_repository.dart';
import '../domain/workout_models.dart';
import 'exercise_catalog_controller.dart';

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

  Future<void> syncRemoteFavorites() async {
    try {
      final repo = ref.read(exerciseCatalogRepositoryProvider);
      final res = await repo.getFavorites(size: 100);
      if (res.items.isNotEmpty) {
        final remoteIds = res.items.map((e) => 'ex_${e.id}').toSet();
        state = {...state, ...remoteIds};
      }
    } catch (_) {
      // Keep local state on error / offline
    }
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

  Future<bool> toggleFavoriteWithSync(String exerciseId) async {
    final willBeFavorite = toggleFavorite(exerciseId);
    final numId = int.tryParse(exerciseId.replaceFirst('ex_', ''));
    if (numId != null && numId > 0) {
      try {
        final repo = ref.read(exerciseCatalogRepositoryProvider);
        if (willBeFavorite) {
          await repo.addFavorite(numId);
        } else {
          await repo.removeFavorite(numId);
        }
      } catch (_) {}
    }
    return willBeFavorite;
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
    final catalogState = ref.watch(exerciseCatalogControllerProvider);
    final seen = <String>{};
    final all = <ExerciseDefinition>[];
    for (final e in catalogState.exercises) {
      if (seen.add(e.id) && state.contains(e.id)) {
        all.add(e);
      }
    }
    for (final e in exerciseCatalog) {
      if (seen.add(e.id) && state.contains(e.id)) {
        all.add(e);
      }
    }
    return all;
  }
}
