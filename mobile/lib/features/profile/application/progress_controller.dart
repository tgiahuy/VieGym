import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../onboarding/application/health_profile_controller.dart';
import '../../workout/application/workout_schedule_controller.dart';
import '../../workout/domain/workout_models.dart';
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

class DailyVolumeItem {
  const DailyVolumeItem({
    required this.weekday, // 1=Mon, ..., 7=Sun
    required this.label, // 'T2', ..., 'CN'
    required this.volumeKg,
    required this.isToday,
  });

  final int weekday;
  final String label;
  final double volumeKg;
  final bool isToday;
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
    this.dailyVolumes = const [],
    this.lastWeekTotalVolumeKg = 0.0,
    this.growthRatePercentage = 0.0,
    this.weeklyCaloriesBurned = 0,
    this.weightTrend,
  });

  final int completedWorkoutsThisWeek;
  final int targetWorkoutsPerWeek;
  final int currentStreakDays;
  final double totalVolumeKg;
  final int totalWorkoutMinutes;
  final List<WeightLogItem> weightLogs;
  final List<PersonalRecordItem> personalRecords;
  final List<DailyVolumeItem> dailyVolumes;
  final double lastWeekTotalVolumeKg;
  final double growthRatePercentage;
  final int weeklyCaloriesBurned;
  final WeightTrendResult? weightTrend;

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
    List<DailyVolumeItem>? dailyVolumes,
    double? lastWeekTotalVolumeKg,
    double? growthRatePercentage,
    int? weeklyCaloriesBurned,
    WeightTrendResult? weightTrend,
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
      dailyVolumes: dailyVolumes ?? this.dailyVolumes,
      lastWeekTotalVolumeKg:
          lastWeekTotalVolumeKg ?? this.lastWeekTotalVolumeKg,
      growthRatePercentage:
          growthRatePercentage ?? this.growthRatePercentage,
      weeklyCaloriesBurned:
          weeklyCaloriesBurned ?? this.weeklyCaloriesBurned,
      weightTrend: weightTrend ?? this.weightTrend,
    );
  }
}

class ProgressController extends Notifier<ProgressState> {
  List<WeightLogItem>? _cachedWeightLogs;
  WeightTrendResult? _cachedWeightTrend;
  List<PersonalRecordItem>? _cachedPersonalRecords;

  static const _defaultPRs = [
    PersonalRecordItem(
      id: 'pr_1',
      exerciseName: 'Barbell Bench Press',
      weightKg: 85.0,
      reps: 5,
      date: '25/08',
    ),
    PersonalRecordItem(
      id: 'pr_2',
      exerciseName: 'Barbell Squat',
      weightKg: 110.0,
      reps: 6,
      date: '22/08',
    ),
    PersonalRecordItem(
      id: 'pr_3',
      exerciseName: 'Deadlift',
      weightKg: 135.0,
      reps: 3,
      date: '18/08',
    ),
    PersonalRecordItem(
      id: 'pr_4',
      exerciseName: 'Overhead Press (OHP)',
      weightKg: 55.0,
      reps: 5,
      date: '20/08',
    ),
  ];

  @override
  ProgressState build() {
    final scheduleState = ref.watch(workoutScheduleProvider);
    final healthProfile = ref.watch(healthProfileProvider);

    final stats = _computeWorkoutStats(
      schedules: scheduleState.schedules,
      history: scheduleState.history,
      currentWeightKg: healthProfile.weightKg.toDouble(),
    );

    final targetWorkouts = healthProfile.workoutDaysPerWeek > 0
        ? healthProfile.workoutDaysPerWeek
        : 4;

    final realPRs = <String, PersonalRecordItem>{};
    for (final h in scheduleState.history) {
      for (final ex in h.exercises) {
        for (final s in ex.sets) {
          if (s.weightKg > 0) {
            final existing = realPRs[ex.exerciseName];
            if (existing == null ||
                s.weightKg > existing.weightKg ||
                (s.weightKg == existing.weightKg && s.reps > existing.reps)) {
              realPRs[ex.exerciseName] = PersonalRecordItem(
                id: 'pr_${ex.exerciseId}_${s.weightKg.toInt()}',
                exerciseName: ex.exerciseName,
                weightKg: s.weightKg,
                reps: s.reps,
                date: h.date,
              );
            }
          }
        }
      }
    }

    final effectivePRs = (_cachedPersonalRecords != null &&
            _cachedPersonalRecords!.isNotEmpty)
        ? _cachedPersonalRecords!
        : (realPRs.isNotEmpty
            ? [
                ...realPRs.values,
                ..._defaultPRs
                    .where((d) => !realPRs.containsKey(d.exerciseName)),
              ]
            : _defaultPRs);

    return ProgressState(
      completedWorkoutsThisWeek: stats['completedWorkoutsThisWeek'] as int,
      targetWorkoutsPerWeek: targetWorkouts,
      currentStreakDays: stats['currentStreakDays'] as int,
      totalVolumeKg: stats['totalVolumeKg'] as double,
      totalWorkoutMinutes: stats['totalWorkoutMinutes'] as int,
      weightLogs: _cachedWeightLogs ?? const [],
      personalRecords: effectivePRs,
      dailyVolumes: stats['dailyVolumes'] as List<DailyVolumeItem>,
      lastWeekTotalVolumeKg: stats['lastWeekTotalVolumeKg'] as double,
      growthRatePercentage: stats['growthRatePercentage'] as double,
      weeklyCaloriesBurned: stats['weeklyCaloriesBurned'] as int,
      weightTrend: _cachedWeightTrend,
    );
  }

  WeightLogRepository get _weightLogRepo =>
      ref.read(weightLogRepositoryProvider);

  Future<void> fetchWeightLogs() async {
    try {
      final logs = await _weightLogRepo.getWeightLogs();
      _cachedWeightLogs = logs;
      state = state.copyWith(weightLogs: logs);
    } catch (_) {
      // Keep local state on error / offline
    }

    try {
      final trend = await _weightLogRepo.getWeightTrend(days: 30);
      _cachedWeightTrend = trend;
      state = state.copyWith(weightTrend: trend);
    } catch (_) {}
  }

  Future<void> fetchPersonalRecords() async {
    try {
      final prs = await _weightLogRepo.getPersonalRecords();
      if (prs.isNotEmpty) {
        _cachedPersonalRecords = prs;
        state = state.copyWith(personalRecords: prs);
      }
    } catch (_) {}
  }

  Future<void> fetchAllProgressData() async {
    await Future.wait([
      fetchWeightLogs(),
      fetchPersonalRecords(),
    ]);
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
    final currentLogs = state.weightLogs;
    final existingIndex = currentLogs.indexWhere((w) => w.date == dateStr);
    List<WeightLogItem> updatedLogs;
    if (existingIndex >= 0) {
      updatedLogs = [...currentLogs];
      updatedLogs[existingIndex] = newItem;
    } else {
      updatedLogs = [newItem, ...currentLogs];
    }
    _cachedWeightLogs = updatedLogs;
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

      // 5. Refresh trend
      try {
        final trend = await _weightLogRepo.getWeightTrend(days: 30);
        _cachedWeightTrend = trend;
        state = state.copyWith(weightTrend: trend);
      } catch (_) {}

      return result;
    } catch (_) {
      return null;
    }
  }

  void clearAllLogs() {
    _cachedWeightLogs = [];
    _cachedWeightTrend = null;
    state = state.copyWith(weightLogs: [], weightTrend: null);
  }

  void setWeightLogs(List<WeightLogItem> logs) {
    _cachedWeightLogs = logs;
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

    final updated = [newItem, ...state.personalRecords];
    _cachedPersonalRecords = updated;
    state = state.copyWith(personalRecords: updated);
  }

  void deletePersonalRecord(String id) {
    final updated =
        state.personalRecords.where((pr) => pr.id != id).toList();
    _cachedPersonalRecords = updated;
    state = state.copyWith(personalRecords: updated);
  }

  static double calculate1Rm(double weightKg, int reps) {
    if (reps <= 1) return weightKg;
    return weightKg * (1.0 + reps / 30.0);
  }

  static DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

  static Map<String, dynamic> _computeWorkoutStats({
    required List<WorkoutScheduleItem> schedules,
    required List<WorkoutHistoryItem> history,
    required double currentWeightKg,
  }) {
    final now = DateTime.now();
    final today = _startOfDay(now);

    final currentMonday = today.subtract(Duration(days: now.weekday - 1));
    final currentSunday = currentMonday.add(const Duration(days: 6));
    final lastMonday = currentMonday.subtract(const Duration(days: 7));
    final lastSunday = currentMonday.subtract(const Duration(days: 1));

    final records = <_WorkoutRecord>[];

    for (final h in history) {
      final d = DateTime.tryParse(h.date);
      if (d != null) {
        records.add(_WorkoutRecord(
          date: _startOfDay(d),
          durationMinutes: h.durationMinutes,
          volumeKg: h.totalVolumeKg,
        ));
      }
    }

    for (final s in schedules) {
      if (s.status == ScheduleStatus.completed) {
        final d = DateTime.tryParse(s.date);
        if (d != null) {
          final day = _startOfDay(d);
          final alreadyLogged = records.any((r) => r.date == day);
          if (!alreadyLogged) {
            records.add(_WorkoutRecord(
              date: day,
              durationMinutes: s.durationMinutes,
              volumeKg: 0.0,
            ));
          }
        }
      }
    }

    final thisWeekRecords = records.where((r) {
      return !r.date.isBefore(currentMonday) && !r.date.isAfter(currentSunday);
    }).toList();

    final completedWorkoutsThisWeek = thisWeekRecords.length;
    final totalWorkoutMinutes = thisWeekRecords.fold<int>(
      0,
      (sum, r) => sum + r.durationMinutes,
    );

    final dayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final dailyVolumes = <DailyVolumeItem>[];
    double totalVolumeThisWeek = 0.0;

    for (int i = 0; i < 7; i++) {
      final dayDate = currentMonday.add(Duration(days: i));
      final isToday = (i + 1 == now.weekday);
      final dayVolume = thisWeekRecords
          .where((r) => r.date == dayDate)
          .fold<double>(0.0, (sum, r) => sum + r.volumeKg);
      totalVolumeThisWeek += dayVolume;

      dailyVolumes.add(DailyVolumeItem(
        weekday: i + 1,
        label: dayLabels[i],
        volumeKg: dayVolume,
        isToday: isToday,
      ));
    }

    final lastWeekVolume = records.where((r) {
      return !r.date.isBefore(lastMonday) && !r.date.isAfter(lastSunday);
    }).fold<double>(0.0, (sum, r) => sum + r.volumeKg);

    double growthRate = 0.0;
    if (lastWeekVolume > 0) {
      growthRate =
          ((totalVolumeThisWeek - lastWeekVolume) / lastWeekVolume) * 100.0;
    } else if (totalVolumeThisWeek > 0) {
      growthRate = 100.0;
    }

    final uniqueDates = records.map((r) => r.date).toSet();
    int streak = 0;
    if (uniqueDates.isNotEmpty) {
      final yesterday = today.subtract(const Duration(days: 1));
      DateTime? checkDate;
      if (uniqueDates.contains(today)) {
        checkDate = today;
      } else if (uniqueDates.contains(yesterday)) {
        checkDate = yesterday;
      }
      if (checkDate != null) {
        while (uniqueDates.contains(checkDate)) {
          streak++;
          checkDate = checkDate!.subtract(const Duration(days: 1));
        }
      }
    }

    final effectiveWeight = currentWeightKg > 0 ? currentWeightKg : 68.0;
    final caloriesBurned =
        (5.5 * effectiveWeight * (totalWorkoutMinutes / 60.0)).round();

    return {
      'completedWorkoutsThisWeek': completedWorkoutsThisWeek,
      'totalWorkoutMinutes': totalWorkoutMinutes,
      'totalVolumeKg': totalVolumeThisWeek,
      'currentStreakDays': streak,
      'dailyVolumes': dailyVolumes,
      'lastWeekTotalVolumeKg': lastWeekVolume,
      'growthRatePercentage': growthRate,
      'weeklyCaloriesBurned': caloriesBurned,
    };
  }
}

class _WorkoutRecord {
  const _WorkoutRecord({
    required this.date,
    required this.durationMinutes,
    required this.volumeKg,
  });

  final DateTime date;
  final int durationMinutes;
  final double volumeKg;
}

final progressProvider = NotifierProvider<ProgressController, ProgressState>(
  ProgressController.new,
);
