import 'package:flutter_riverpod/flutter_riverpod.dart';

class PersonalRecordItem {
  const PersonalRecordItem({
    required this.id,
    required this.exerciseName,
    required this.weightKg,
    required this.reps,
    required this.date,
  });

  final String id;
  final String exerciseName;
  final double weightKg;
  final int reps;
  final String date;

  double get calculated1Rm => weightKg * (1 + reps / 30.0);
}

class WeightLogItem {
  const WeightLogItem({
    required this.id,
    required this.date,
    required this.weightKg,
  });

  final String id;
  final String date;
  final double weightKg;
}

class ProgressState {
  const ProgressState({
    required this.completedWorkoutsThisWeek,
    required this.targetWorkoutsPerWeek,
    required this.currentStreakDays,
    required this.totalVolumeKg,
    required this.totalWorkoutMinutes,
    required this.weightLogs,
    required this.personalRecords,
  });

  final int completedWorkoutsThisWeek;
  final int targetWorkoutsPerWeek;
  final int currentStreakDays;
  final double totalVolumeKg;
  final int totalWorkoutMinutes;
  final List<WeightLogItem> weightLogs;
  final List<PersonalRecordItem> personalRecords;

  double get weeklyCompletionRatio =>
      targetWorkoutsPerWeek == 0
          ? 0.0
          : (completedWorkoutsThisWeek / targetWorkoutsPerWeek).clamp(0.0, 1.0);

  ProgressState copyWith({
    int? completedWorkoutsThisWeek,
    int? targetWorkoutsPerWeek,
    int? currentStreakDays,
    double? totalVolumeKg,
    int? totalWorkoutMinutes,
    List<WeightLogItem>? weightLogs,
    List<PersonalRecordItem>? personalRecords,
  }) {
    return ProgressState(
      completedWorkoutsThisWeek:
          completedWorkoutsThisWeek ?? this.completedWorkoutsThisWeek,
      targetWorkoutsPerWeek:
          targetWorkoutsPerWeek ?? this.targetWorkoutsPerWeek,
      currentStreakDays: currentStreakDays ?? this.currentStreakDays,
      totalVolumeKg: totalVolumeKg ?? this.totalVolumeKg,
      totalWorkoutMinutes: totalWorkoutMinutes ?? this.totalWorkoutMinutes,
      weightLogs: weightLogs ?? this.weightLogs,
      personalRecords: personalRecords ?? this.personalRecords,
    );
  }
}

class ProgressController extends Notifier<ProgressState> {
  @override
  ProgressState build() {
    final defaultWeightLogs = [
      const WeightLogItem(id: 'w_1', date: '28/08', weightKg: 67.2),
      const WeightLogItem(id: 'w_2', date: '21/08', weightKg: 67.8),
      const WeightLogItem(id: 'w_3', date: '14/08', weightKg: 68.3),
      const WeightLogItem(id: 'w_4', date: '07/08', weightKg: 68.9),
      const WeightLogItem(id: 'w_5', date: '01/08', weightKg: 69.5),
    ];

    final defaultPRs = [
      const PersonalRecordItem(
        id: 'pr_1',
        exerciseName: 'Barbell Bench Press',
        weightKg: 85.0,
        reps: 5,
        date: '25/08',
      ),
      const PersonalRecordItem(
        id: 'pr_2',
        exerciseName: 'Barbell Squat',
        weightKg: 110.0,
        reps: 6,
        date: '22/08',
      ),
      const PersonalRecordItem(
        id: 'pr_3',
        exerciseName: 'Deadlift',
        weightKg: 135.0,
        reps: 3,
        date: '18/08',
      ),
      const PersonalRecordItem(
        id: 'pr_4',
        exerciseName: 'Overhead Press (OHP)',
        weightKg: 55.0,
        reps: 5,
        date: '20/08',
      ),
    ];

    return ProgressState(
      completedWorkoutsThisWeek: 4,
      targetWorkoutsPerWeek: 5,
      currentStreakDays: 12,
      totalVolumeKg: 28500,
      totalWorkoutMinutes: 480,
      weightLogs: defaultWeightLogs,
      personalRecords: defaultPRs,
    );
  }

  void logWeight(double weightKg) {
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}';

    final newItem = WeightLogItem(
      id: 'w_${DateTime.now().millisecondsSinceEpoch}',
      date: dateStr,
      weightKg: weightKg,
    );

    state = state.copyWith(
      weightLogs: [newItem, ...state.weightLogs],
    );
  }

  static double calculate1Rm(double weightKg, int reps) {
    if (reps <= 1) return weightKg;
    return weightKg * (1.0 + reps / 30.0);
  }
}

final progressProvider =
    NotifierProvider<ProgressController, ProgressState>(
  ProgressController.new,
);
