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
        id: '${exercise.exerciseId}_set_${index + 1}',
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

  int? findNextIncompleteExerciseIndex([int? fromIndex]) {
    final start = fromIndex ?? state.currentExerciseIndex;
    final total = state.exercises.length;
    if (total == 0) return null;

    // Check forward: from start + 1 to end
    for (var i = start + 1; i < total; i++) {
      final ex = state.exercises[i];
      final sets = state.logs[ex.exerciseId] ?? const <SetLog>[];
      final isDone = sets.isNotEmpty && sets.every((s) => s.completed);
      if (!isDone) return i;
    }

    // Wrap around: check from 0 up to start
    for (var i = 0; i < start; i++) {
      final ex = state.exercises[i];
      final sets = state.logs[ex.exerciseId] ?? const <SetLog>[];
      final isDone = sets.isNotEmpty && sets.every((s) => s.completed);
      if (!isDone) return i;
    }

    return null;
  }

  void autoAdvanceIfExerciseCompleted(String exerciseId) {
    final currentSets = state.logs[exerciseId];
    if (currentSets == null || currentSets.isEmpty) return;

    final isCurrentExerciseDone = currentSets.every((s) => s.completed);
    if (isCurrentExerciseDone) {
      final nextIndex = findNextIncompleteExerciseIndex();
      if (nextIndex != null && nextIndex != state.currentExerciseIndex) {
        selectExercise(nextIndex);
      }
    }
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
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    if (currentSets == null || currentSets.isEmpty) {
      // If all sets were removed, create set 1 with default values
      state = state.copyWith(
        logs: {
          ...state.logs,
          exerciseId: [
            SetLog(
              id: '${exerciseId}_set_$timestamp',
              number: 1,
              weightKg: 20,
              reps: 10,
            ),
          ],
        },
      );
      return;
    }
    final previous = currentSets.last;
    state = state.copyWith(
      logs: {
        ...state.logs,
        exerciseId: [
          ...currentSets,
          SetLog(
            id: '${exerciseId}_set_$timestamp',
            number: currentSets.length + 1,
            weightKg: previous.weightKg,
            reps: previous.reps,
          ),
        ],
      },
    );
  }

  void removeSet({required String exerciseId, required int setIndex}) {
    final currentSets = state.logs[exerciseId];
    if (currentSets == null || setIndex < 0 || setIndex >= currentSets.length) {
      return;
    }

    final updatedSets = [...currentSets]..removeAt(setIndex);
    // Renumber remaining sets
    for (var i = 0; i < updatedSets.length; i++) {
      updatedSets[i] = updatedSets[i].copyWith(number: i + 1);
    }

    state = state.copyWith(logs: {...state.logs, exerciseId: updatedSets});
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

  /// Returns true when adding the exercise starts a separate add-on workout
  /// after a previously finalized session.
  bool addExercise(
    ExerciseDefinition definition, {
    int targetSets = 3,
    int targetReps = 10,
    double weightKg = 20.0,
  }) {
    if (state.isFinalized) {
      final newExercise = SessionExercise(
        exerciseId: definition.id,
        name: definition.name,
        primaryMuscle: definition.primaryMuscle,
        equipment: definition.equipment,
        targetSets: targetSets,
        targetReps: targetReps,
        weightKg: definition.equipment == EquipmentType.bodyweight
            ? 0
            : weightKg,
      );
      state = WorkoutSessionState(
        id: 'session_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Tập thêm hôm nay',
        exercises: [newExercise],
        logs: {newExercise.exerciseId: _createSetLogs(newExercise)},
      );
      return true;
    }

    final exerciseId = state.exercises.any((e) => e.exerciseId == definition.id)
        ? '${definition.id}_${DateTime.now().millisecondsSinceEpoch}'
        : definition.id;

    final newExercise = SessionExercise(
      exerciseId: exerciseId,
      name: definition.name,
      primaryMuscle: definition.primaryMuscle,
      equipment: definition.equipment,
      targetSets: targetSets,
      targetReps: targetReps,
      weightKg: definition.equipment == EquipmentType.bodyweight ? 0 : weightKg,
    );

    final updatedExercises = [...state.exercises, newExercise];
    final updatedLogs = {
      ...state.logs,
      newExercise.exerciseId: _createSetLogs(newExercise),
    };

    state = state.copyWith(exercises: updatedExercises, logs: updatedLogs);
    return false;
  }

  void removeExercise(String exerciseId) {
    final index = state.exercises.indexWhere((e) => e.exerciseId == exerciseId);
    if (index == -1) return;

    final updatedExercises = [...state.exercises]..removeAt(index);
    final updatedLogs = {...state.logs}..remove(exerciseId);

    var newIndex = state.currentExerciseIndex;
    if (updatedExercises.isEmpty) {
      newIndex = 0;
    } else if (newIndex >= updatedExercises.length) {
      newIndex = updatedExercises.length - 1;
    }

    state = state.copyWith(
      exercises: updatedExercises,
      logs: updatedLogs,
      currentExerciseIndex: newIndex,
    );
  }

  void setSession({
    required String title,
    required List<SessionExercise> exercises,
  }) {
    state = WorkoutSessionState(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      exercises: exercises,
      logs: {for (final ex in exercises) ex.exerciseId: _createSetLogs(ex)},
    );
  }

  void finalizeSession() {
    if (state.exercises.isEmpty) return;
    state = state.copyWith(isFinalized: true, isPaused: false);
  }

  void clearSession() {
    state = WorkoutSessionState(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      title: '',
      exercises: const [],
      logs: const {},
    );
  }
}
