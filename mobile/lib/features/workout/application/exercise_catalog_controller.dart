import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/exercise_catalog.dart';
import '../data/exercise_catalog_repository.dart';
import '../domain/exercise_api_models.dart';
import '../domain/workout_models.dart';

final muscleGroupsProvider = FutureProvider<List<MuscleGroupItem>>((ref) async {
  final repo = ref.watch(exerciseCatalogRepositoryProvider);
  try {
    return await repo.getMuscleGroups();
  } catch (_) {
    return const [];
  }
});

final equipmentListProvider = FutureProvider<List<EquipmentItem>>((ref) async {
  final repo = ref.watch(exerciseCatalogRepositoryProvider);
  return repo.getEquipment();
});

final exerciseDetailProvider =
    FutureProvider.family<ExerciseDefinition, String>((ref, id) async {
      final repo = ref.watch(exerciseCatalogRepositoryProvider);

      // Parse numeric ID if formatted as "ex_123" or "123"
      final numId = int.tryParse(id.replaceFirst('ex_', ''));
      if (numId != null && numId > 0) {
        try {
          final detail = await repo.getExerciseDetail(numId);
          return detail.toExerciseDefinition();
        } catch (_) {
          // Fallback to local catalog
        }
      }

      // Fallback to local catalog
      return exerciseCatalog.firstWhere(
        (e) => e.id == id,
        orElse: () => exerciseCatalog.first,
      );
    });

final exerciseCatalogControllerProvider =
    NotifierProvider<ExerciseCatalogController, ExerciseCatalogState>(
      ExerciseCatalogController.new,
    );

class ExerciseCatalogState {
  const ExerciseCatalogState({
    this.query = '',
    this.muscleGroupId,
    this.equipmentId,
    this.difficulty,
    this.compatibleWithMyEquipment,
    this.page = 0,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.exercises = const [],
    this.rawSummaries = const [],
  });

  final String query;
  final int? muscleGroupId;
  final int? equipmentId;
  final String? difficulty;
  final bool? compatibleWithMyEquipment;
  final int page;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final List<ExerciseDefinition> exercises;
  final List<ExerciseApiSummary> rawSummaries;

  ExerciseCatalogState copyWith({
    String? query,
    int? muscleGroupId,
    int? equipmentId,
    String? difficulty,
    bool? compatibleWithMyEquipment,
    int? page,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    List<ExerciseDefinition>? exercises,
    List<ExerciseApiSummary>? rawSummaries,
    bool clearMuscleGroup = false,
    bool clearEquipment = false,
    bool clearDifficulty = false,
  }) {
    return ExerciseCatalogState(
      query: query ?? this.query,
      muscleGroupId: clearMuscleGroup
          ? null
          : (muscleGroupId ?? this.muscleGroupId),
      equipmentId: clearEquipment ? null : (equipmentId ?? this.equipmentId),
      difficulty: clearDifficulty ? null : (difficulty ?? this.difficulty),
      compatibleWithMyEquipment:
          compatibleWithMyEquipment ?? this.compatibleWithMyEquipment,
      page: page ?? this.page,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      exercises: exercises ?? this.exercises,
      rawSummaries: rawSummaries ?? this.rawSummaries,
    );
  }
}

class ExerciseCatalogController extends Notifier<ExerciseCatalogState> {
  @override
  ExerciseCatalogState build() {
    return const ExerciseCatalogState();
  }

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, page: 0, error: null);
    final repo = ref.read(exerciseCatalogRepositoryProvider);

    try {
      final res = await repo.getExercises(
        q: state.query.isNotEmpty ? state.query : null,
        muscleGroupId: state.muscleGroupId,
        equipmentId: state.equipmentId,
        difficulty: state.difficulty,
        compatibleWithMyEquipment: state.compatibleWithMyEquipment,
        page: 0,
        size: 150,
      );

      final mapped = res.items.map((e) => e.toExerciseDefinition()).toList();
      state = state.copyWith(
        isLoading: false,
        exercises: mapped,
        rawSummaries: res.items,
        page: 0,
        hasMore: !res.isLastPage,
      );
    } catch (err) {
      state = state.copyWith(isLoading: false, error: err.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;
    state = state.copyWith(isLoadingMore: true);

    final nextPage = state.page + 1;
    final repo = ref.read(exerciseCatalogRepositoryProvider);

    try {
      final res = await repo.getExercises(
        q: state.query.isNotEmpty ? state.query : null,
        muscleGroupId: state.muscleGroupId,
        equipmentId: state.equipmentId,
        difficulty: state.difficulty,
        compatibleWithMyEquipment: state.compatibleWithMyEquipment,
        page: nextPage,
        size: 50,
      );

      final newItems = res.items.map((e) => e.toExerciseDefinition()).toList();
      state = state.copyWith(
        isLoadingMore: false,
        page: nextPage,
        exercises: [...state.exercises, ...newItems],
        rawSummaries: [...state.rawSummaries, ...res.items],
        hasMore: !res.isLastPage,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void setQuery(String q) {
    if (state.query == q) return;
    state = state.copyWith(query: q);
    loadInitial();
  }

  void setMuscleGroup(int? id) {
    state = state.copyWith(muscleGroupId: id, clearMuscleGroup: id == null);
    loadInitial();
  }

  void setEquipment(int? id) {
    state = state.copyWith(equipmentId: id, clearEquipment: id == null);
    loadInitial();
  }

  void setDifficulty(String? diff) {
    state = state.copyWith(difficulty: diff, clearDifficulty: diff == null);
    loadInitial();
  }

  void resetFilters() {
    state = state.copyWith(
      query: '',
      clearMuscleGroup: true,
      clearEquipment: true,
      clearDifficulty: true,
    );
    loadInitial();
  }
}
