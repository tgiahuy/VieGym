import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../onboarding/application/health_profile_controller.dart';
import '../data/weight_log_repository.dart';

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

  double get weeklyCompletionRatio => targetWorkoutsPerWeek == 0
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

  WeightLogRepository get _weightLogRepo =>
      ref.read(weightLogRepositoryProvider);

  Future<void> fetchWeightLogs() async {
    try {
      final logs = await _weightLogRepo.getWeightLogs();
      if (logs.isNotEmpty) {
        state = state.copyWith(weightLogs: logs);
      }
    } catch (_) {
      // Keep local state on error / offline
    }
  }

  Future<UpsertWeightLogResult?> logWeight(
    double weightKg, {
    DateTime? date,
    String? note,
  }) async {
    final effectiveDate = date ?? DateTime.now();
    final dateStr =
        '${effectiveDate.day.toString().padLeft(2, '0')}/${effectiveDate.month.toString().padLeft(2, '0')}';

    final newItem = WeightLogItem(
      id: 'w_${DateTime.now().millisecondsSinceEpoch}',
      date: dateStr,
      weightKg: weightKg,
    );

    // 1. Optimistic update in UI
    final existingIndex = state.weightLogs.indexWhere((w) => w.date == dateStr);
    List<WeightLogItem> updatedLogs;
    if (existingIndex >= 0) {
      updatedLogs = [...state.weightLogs];
      updatedLogs[existingIndex] = newItem;
    } else {
      updatedLogs = [newItem, ...state.weightLogs];
    }
    state = state.copyWith(weightLogs: updatedLogs);

    // 2. Synchronize weight and recalculate BMI in health profile immediately
    ref.read(healthProfileProvider.notifier).updateWeight(weightKg);

    // 3. Persist to backend API (PUT /api/v1/weight-logs/{date})
    try {
      final result = await _weightLogRepo.upsertWeightLog(
        effectiveDate,
        weightKg,
        note: note,
      );

      // 4. Update health profile with authoritative server-computed metrics
      if (result.metricsUpdated) {
        ref.read(healthProfileProvider.notifier).updateWeight(
              weightKg,
              serverBmi: result.bmi,
              serverBmr: result.bmrKcal,
              serverTdee: result.tdeeKcal,
            );
      }

      return result;
    } catch (_) {
      return null;
    }
  }

  void clearAllLogs() {
    state = state.copyWith(weightLogs: []);
  }

  void setWeightLogs(List<WeightLogItem> logs) {
    state = state.copyWith(weightLogs: logs);
  }

  void addPersonalRecord({
    required String exerciseName,
    required double weightKg,
    required int reps,
  }) {
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}';

    final newItem = PersonalRecordItem(
      id: 'pr_${DateTime.now().millisecondsSinceEpoch}',
      exerciseName: exerciseName.trim(),
      weightKg: weightKg,
      reps: reps,
      date: dateStr,
    );

    state = state.copyWith(
      personalRecords: [newItem, ...state.personalRecords],
    );
  }

  void deletePersonalRecord(String id) {
    state = state.copyWith(
      personalRecords: state.personalRecords
          .where((pr) => pr.id != id)
          .toList(),
    );
  }

  static double calculate1Rm(double weightKg, int reps) {
    if (reps <= 1) return weightKg;
    return weightKg * (1.0 + reps / 30.0);
  }
}

final progressProvider = NotifierProvider<ProgressController, ProgressState>(
  ProgressController.new,
);
