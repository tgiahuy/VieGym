import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/exercise_catalog.dart';
import '../domain/workout_models.dart';

final equipmentPreferencesProvider =
    NotifierProvider<EquipmentPreferencesController, Set<EquipmentType>>(
      EquipmentPreferencesController.new,
    );

class EquipmentPreferencesController extends Notifier<Set<EquipmentType>> {
  @override
  Set<EquipmentType> build() => {
    EquipmentType.bodyweight,
    EquipmentType.dumbbell,
    EquipmentType.barbell,
    EquipmentType.bench,
    EquipmentType.cable,
    EquipmentType.machine,
  };

  void toggle(EquipmentType equipment) {
    final updated = {...state};
    if (!updated.remove(equipment)) updated.add(equipment);
    state = updated.isEmpty ? {EquipmentType.bodyweight} : updated;
  }

  void replaceAll(Set<EquipmentType> equipment) {
    state = equipment.isEmpty ? {EquipmentType.bodyweight} : {...equipment};
  }
}

final workoutSessionProvider =
    NotifierProvider<WorkoutSessionController, WorkoutSessionState>(
      WorkoutSessionController.new,
    );

class WorkoutSessionController extends Notifier<WorkoutSessionState> {
  @override
  WorkoutSessionState build() {
    const exercises = [
      SessionExercise(
        exerciseId: 'ex1',
        name: 'Barbell Bench Press',
        primaryMuscle: 'Ngực',
        equipment: EquipmentType.barbell,
        targetSets: 3,
        targetReps: 10,
        weightKg: 40,
      ),
      SessionExercise(
        exerciseId: 'ex2',
        name: 'Incline Dumbbell Press',
        primaryMuscle: 'Ngực',
        equipment: EquipmentType.dumbbell,
        targetSets: 3,
        targetReps: 12,
        weightKg: 15,
      ),
      SessionExercise(
        exerciseId: 'ex3',
        name: 'Overhead Press',
        primaryMuscle: 'Vai',
        equipment: EquipmentType.barbell,
        targetSets: 3,
        targetReps: 10,
        weightKg: 25,
      ),
      SessionExercise(
        exerciseId: 'ex4',
        name: 'Tricep Pushdown',
        primaryMuscle: 'Tay sau',
        equipment: EquipmentType.cable,
        targetSets: 3,
        targetReps: 15,
        weightKg: 20,
      ),
    ];

    return WorkoutSessionState(
      id: 'plan123',
      title: 'Upper Body A',
      exercises: exercises,
      logs: {
        for (final exercise in exercises)
          exercise.exerciseId: _createSetLogs(exercise),
      },
    );
  }

  static List<SetLog> _createSetLogs(SessionExercise exercise) {
    return List.generate(
      exercise.targetSets,
      (index) => SetLog(
        number: index + 1,
        weightKg: exercise.weightKg,
        reps: exercise.targetReps,
      ),
    );
  }

  void selectExercise(int index) {
    if (index < 0 || index >= state.exercises.length) return;
    state = state.copyWith(currentExerciseIndex: index);
  }

  void nextExercise() {
    selectExercise(
      (state.currentExerciseIndex + 1).clamp(0, state.exercises.length - 1),
    );
  }

  void previousExercise() {
    selectExercise(
      (state.currentExerciseIndex - 1).clamp(0, state.exercises.length - 1),
    );
  }

  void togglePause() {
    state = state.copyWith(isPaused: !state.isPaused);
  }

  void updateSet({
    required String exerciseId,
    required int setIndex,
    double? weightKg,
    int? reps,
    bool? completed,
  }) {
    final currentSets = state.logs[exerciseId];
    if (currentSets == null || setIndex < 0 || setIndex >= currentSets.length) {
      return;
    }

    final updatedSets = [...currentSets];
    updatedSets[setIndex] = updatedSets[setIndex].copyWith(
      weightKg: weightKg,
      reps: reps,
      completed: completed,
    );
    state = state.copyWith(logs: {...state.logs, exerciseId: updatedSets});
  }

  void addSet(String exerciseId) {
    final currentSets = state.logs[exerciseId];
    if (currentSets == null || currentSets.isEmpty) return;
    final previous = currentSets.last;
    state = state.copyWith(
      logs: {
        ...state.logs,
        exerciseId: [
          ...currentSets,
          SetLog(
            number: currentSets.length + 1,
            weightKg: previous.weightKg,
            reps: previous.reps,
          ),
        ],
      },
    );
  }

  void replaceExercise({
    required String originalExerciseId,
    required String replacementExerciseId,
  }) {
    final index = state.exercises.indexWhere(
      (item) => item.exerciseId == originalExerciseId,
    );
    final definition = findExercise(replacementExerciseId);
    if (index == -1 || definition == null) return;

    final original = state.exercises[index];
    final replacement = original.copyWith(
      exerciseId: definition.id,
      name: definition.name,
      primaryMuscle: definition.primaryMuscle,
      equipment: definition.equipment,
      weightKg: definition.equipment == EquipmentType.bodyweight
          ? 0
          : original.weightKg,
    );
    final updatedExercises = [...state.exercises]..[index] = replacement;

    // Business rule: progress của bài khác được giữ nguyên. Log của bài cũ
    // vẫn còn trong session snapshot; bài mới có bảng hiệp riêng.
    final updatedLogs = {...state.logs};
    updatedLogs.putIfAbsent(
      replacement.exerciseId,
      () => _createSetLogs(replacement),
    );

    state = state.copyWith(exercises: updatedExercises, logs: updatedLogs);
  }
}
