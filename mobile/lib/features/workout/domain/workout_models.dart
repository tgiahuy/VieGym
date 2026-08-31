enum EquipmentType {
  bodyweight('BODYWEIGHT', 'Trọng lượng cơ thể'),
  dumbbell('DUMBBELL', 'Tạ đơn'),
  barbell('BARBELL', 'Tạ đòn'),
  bench('BENCH', 'Ghế tập'),
  cable('CABLE_MACHINE', 'Máy kéo cáp'),
  machine('MACHINE', 'Máy tập');

  const EquipmentType(this.code, this.label);

  final String code;
  final String label;
}

class ExerciseMistake {
  const ExerciseMistake({
    required this.mistake,
    required this.fix,
    this.injuryRisk,
  });

  final String mistake;
  final String fix;
  final String? injuryRisk;
}

class ExerciseDefinition {
  const ExerciseDefinition({
    required this.id,
    required this.name,
    required this.nameVi,
    required this.primaryMuscle,
    required this.secondaryMuscles,
    required this.equipment,
    required this.description,
    this.primaryMuscleKey = 'chest',
    this.thumbnailUrl =
        'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=400&auto=format&fit=crop&q=80',
    this.videoUrl,
    this.instructions = const [],
    this.commonMistakes = const [],
  });

  final String id;
  final String name;
  final String nameVi;
  final String primaryMuscle;
  final String primaryMuscleKey;
  final List<String> secondaryMuscles;
  final EquipmentType equipment;
  final String description;
  final String thumbnailUrl;
  final String? videoUrl;
  final List<String> instructions;
  final List<ExerciseMistake> commonMistakes;
}

class SessionExercise {
  const SessionExercise({
    required this.exerciseId,
    required this.name,
    required this.primaryMuscle,
    required this.equipment,
    required this.targetSets,
    required this.targetReps,
    required this.weightKg,
  });

  final String exerciseId;
  final String name;
  final String primaryMuscle;
  final EquipmentType equipment;
  final int targetSets;
  final int targetReps;
  final double weightKg;

  SessionExercise copyWith({
    String? exerciseId,
    String? name,
    String? primaryMuscle,
    EquipmentType? equipment,
    int? targetSets,
    int? targetReps,
    double? weightKg,
  }) {
    return SessionExercise(
      exerciseId: exerciseId ?? this.exerciseId,
      name: name ?? this.name,
      primaryMuscle: primaryMuscle ?? this.primaryMuscle,
      equipment: equipment ?? this.equipment,
      targetSets: targetSets ?? this.targetSets,
      targetReps: targetReps ?? this.targetReps,
      weightKg: weightKg ?? this.weightKg,
    );
  }
}

class SetLog {
  const SetLog({
    this._id,
    required this.number,
    required this.weightKg,
    required this.reps,
    this.completed = false,
  });

  final String? _id;
  String get id => _id ?? 'set_$number';
  final int number;
  final double weightKg;
  final int reps;
  final bool completed;

  SetLog copyWith({
    String? id,
    int? number,
    double? weightKg,
    int? reps,
    bool? completed,
  }) {
    return SetLog(
      id: id ?? this.id,
      number: number ?? this.number,
      weightKg: weightKg ?? this.weightKg,
      reps: reps ?? this.reps,
      completed: completed ?? this.completed,
    );
  }
}

class WorkoutSessionState {
  const WorkoutSessionState({
    required this.id,
    required this.title,
    required this.exercises,
    required this.logs,
    this.currentExerciseIndex = 0,
    this.isPaused = false,
    this.isFinalized = false,
  });

  final String id;
  final String title;
  final List<SessionExercise> exercises;
  final Map<String, List<SetLog>> logs;
  final int currentExerciseIndex;
  final bool isPaused;
  final bool isFinalized;

  SessionExercise get currentExercise {
    if (exercises.isEmpty) {
      return const SessionExercise(
        exerciseId: '',
        name: '',
        primaryMuscle: '',
        equipment: EquipmentType.bodyweight,
        targetSets: 0,
        targetReps: 0,
        weightKg: 0,
      );
    }
    final validIndex = currentExerciseIndex.clamp(0, exercises.length - 1);
    return exercises[validIndex];
  }

  int get totalSets => exercises.fold(0, (sum, item) => sum + item.targetSets);

  int get completedSets =>
      logs.values.expand((sets) => sets).where((set) => set.completed).length;

  double get totalVolumeKg {
    double total = 0;
    for (final sets in logs.values) {
      for (final s in sets) {
        if (s.completed) {
          total += s.weightKg * s.reps;
        }
      }
    }
    return total;
  }

  bool get isCompleted =>
      exercises.isNotEmpty && totalSets > 0 && completedSets >= totalSets;

  WorkoutSessionState copyWith({
    List<SessionExercise>? exercises,
    Map<String, List<SetLog>>? logs,
    int? currentExerciseIndex,
    bool? isPaused,
    bool? isFinalized,
  }) {
    return WorkoutSessionState(
      id: id,
      title: title,
      exercises: exercises ?? this.exercises,
      logs: logs ?? this.logs,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      isPaused: isPaused ?? this.isPaused,
      isFinalized: isFinalized ?? this.isFinalized,
    );
  }
}

class WorkoutSummaryData {
  const WorkoutSummaryData({
    required this.workoutId,
    required this.title,
    required this.durationFormatted,
    required this.totalVolumeKg,
    required this.completedSets,
    required this.totalSets,
    required this.prCount,
  });

  final String workoutId;
  final String title;
  final String durationFormatted;
  final double totalVolumeKg;
  final int completedSets;
  final int totalSets;
  final int prCount;
}

enum ScheduleStatus {
  planned('Chưa tập'),
  completed('Đã hoàn thành'),
  rest('Nghỉ ngơi');

  const ScheduleStatus(this.label);
  final String label;
}

class PlannedExercisePreview {
  const PlannedExercisePreview({required this.name, required this.setsReps});

  final String name;
  final String setsReps;
}

class WorkoutScheduleItem {
  const WorkoutScheduleItem({
    required this.id,
    required this.date,
    required this.time,
    required this.title,
    required this.targetMuscles,
    required this.durationMinutes,
    this.status = ScheduleStatus.planned,
    this.plannedExercises = const [],
  });

  final String id;
  final String date;
  final String time;
  final String title;
  final String targetMuscles;
  final int durationMinutes;
  final ScheduleStatus status;
  final List<PlannedExercisePreview> plannedExercises;

  WorkoutScheduleItem copyWith({
    String? id,
    String? date,
    String? time,
    String? title,
    String? targetMuscles,
    int? durationMinutes,
    ScheduleStatus? status,
    List<PlannedExercisePreview>? plannedExercises,
  }) {
    return WorkoutScheduleItem(
      id: id ?? this.id,
      date: date ?? this.date,
      time: time ?? this.time,
      title: title ?? this.title,
      targetMuscles: targetMuscles ?? this.targetMuscles,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      plannedExercises: plannedExercises ?? this.plannedExercises,
    );
  }
}

class HistorySetLog {
  const HistorySetLog({
    required this.setNumber,
    required this.weightKg,
    required this.reps,
    this.isPr = false,
    this.rpe,
  });

  final int setNumber;
  final double weightKg;
  final int reps;
  final bool isPr;
  final double? rpe;
}

class HistoryExerciseLog {
  const HistoryExerciseLog({
    required this.exerciseId,
    required this.exerciseName,
    required this.primaryMuscle,
    this.secondaryMuscles = const [],
    required this.sets,
  });

  final String exerciseId;
  final String exerciseName;
  final String primaryMuscle;
  final List<String> secondaryMuscles;
  final List<HistorySetLog> sets;

  int get totalSets => sets.length;
  double get volumeKg =>
      sets.fold(0.0, (sum, s) => sum + (s.weightKg * s.reps));
}

class WorkoutHistoryItem {
  const WorkoutHistoryItem({
    required this.id,
    required this.date,
    required this.workoutName,
    required this.durationMinutes,
    required this.totalVolumeKg,
    required this.completedSetsCount,
    required this.prCount,
    this.targetMuscles = const [],
    this.exercises = const [],
  });

  final String id;
  final String date;
  final String workoutName;
  final int durationMinutes;
  final double totalVolumeKg;
  final int completedSetsCount;
  final int prCount;
  final List<String> targetMuscles;
  final List<HistoryExerciseLog> exercises;

  WorkoutHistoryItem copyWith({
    String? id,
    String? date,
    String? workoutName,
    int? durationMinutes,
    double? totalVolumeKg,
    int? completedSetsCount,
    int? prCount,
    List<String>? targetMuscles,
    List<HistoryExerciseLog>? exercises,
  }) {
    return WorkoutHistoryItem(
      id: id ?? this.id,
      date: date ?? this.date,
      workoutName: workoutName ?? this.workoutName,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      totalVolumeKg: totalVolumeKg ?? this.totalVolumeKg,
      completedSetsCount: completedSetsCount ?? this.completedSetsCount,
      prCount: prCount ?? this.prCount,
      targetMuscles: targetMuscles ?? this.targetMuscles,
      exercises: exercises ?? this.exercises,
    );
  }
}
