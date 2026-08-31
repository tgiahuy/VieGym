import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/workout_models.dart';
import 'workout_session_controller.dart';

String _formatDate(DateTime d) {
  final year = d.year;
  final month = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

class WorkoutScheduleState {
  const WorkoutScheduleState({
    required this.selectedDate,
    required this.schedules,
    required this.history,
  });

  final String selectedDate;
  final List<WorkoutScheduleItem> schedules;
  final List<WorkoutHistoryItem> history;

  List<WorkoutScheduleItem> get selectedDaySchedules =>
      schedules.where((s) => s.date == selectedDate).toList();

  bool get hasTodayWorkout {
    final todayStr = _formatDate(DateTime.now());
    return schedules.any(
      (s) => s.date == todayStr && s.status != ScheduleStatus.rest,
    );
  }

  WorkoutScheduleItem? get todayWorkout {
    final todayStr = _formatDate(DateTime.now());
    final todayItems = schedules.where(
      (s) => s.date == todayStr && s.status != ScheduleStatus.rest,
    );
    return todayItems
            .where((s) => s.status == ScheduleStatus.planned)
            .lastOrNull ??
        todayItems.lastOrNull;
  }

  bool get isTodayWorkoutCompleted {
    final todayStr = _formatDate(DateTime.now());
    final todayItems = schedules
        .where((s) => s.date == todayStr && s.status != ScheduleStatus.rest)
        .toList();
    if (todayItems.any((s) => s.status == ScheduleStatus.planned)) {
      return false;
    }
    if (todayItems.any((s) => s.status == ScheduleStatus.completed)) {
      return true;
    }
    return history.any((h) => h.date == todayStr);
  }

  WorkoutScheduleState copyWith({
    String? selectedDate,
    List<WorkoutScheduleItem>? schedules,
    List<WorkoutHistoryItem>? history,
  }) {
    return WorkoutScheduleState(
      selectedDate: selectedDate ?? this.selectedDate,
      schedules: schedules ?? this.schedules,
      history: history ?? this.history,
    );
  }
}

class WorkoutScheduleController extends Notifier<WorkoutScheduleState> {
  @override
  WorkoutScheduleState build() {
    final now = DateTime.now();
    final todayStr = _formatDate(now);

    final defaultSchedules = [
      WorkoutScheduleItem(
        id: 'sch_1',
        date: todayStr,
        time: '17:30',
        title: 'Pull Focus — Lưng & Tay trước',
        targetMuscles: 'Lưng • Xô • Tay trước',
        durationMinutes: 45,
        status: ScheduleStatus.planned,
        plannedExercises: const [
          PlannedExercisePreview(name: 'Lat Pulldown', setsReps: '4x10'),
          PlannedExercisePreview(name: 'Seated Cable Row', setsReps: '3x12'),
          PlannedExercisePreview(name: 'Face Pull', setsReps: '3x15'),
          PlannedExercisePreview(name: 'Bicep Barbell Curl', setsReps: '3x10'),
        ],
      ),
      WorkoutScheduleItem(
        id: 'sch_2',
        date: _formatDate(now.add(const Duration(days: 1))),
        time: '18:00',
        title: 'Lower Body & Core (Đùi, Mông, Bụng)',
        targetMuscles: 'Đùi trước • Mông • Bụng',
        durationMinutes: 50,
        status: ScheduleStatus.planned,
        plannedExercises: const [
          PlannedExercisePreview(name: 'Barbell Back Squat', setsReps: '4x8'),
          PlannedExercisePreview(name: 'Romanian Deadlift', setsReps: '3x10'),
          PlannedExercisePreview(
            name: 'Bulgarian Split Squat',
            setsReps: '3x12',
          ),
          PlannedExercisePreview(name: 'Hanging Leg Raise', setsReps: '3x15'),
        ],
      ),
      WorkoutScheduleItem(
        id: 'sch_3',
        date: _formatDate(now.add(const Duration(days: 2))),
        time: '17:30',
        title: 'Nghỉ ngơi phục hồi chủ động (Active Recovery)',
        targetMuscles: 'Toàn thân',
        durationMinutes: 30,
        status: ScheduleStatus.rest,
        plannedExercises: const [
          PlannedExercisePreview(
            name: 'Đi bộ nhẹ nhàng trên máy',
            setsReps: '20p',
          ),
          PlannedExercisePreview(
            name: 'Giãn cơ toàn thân & Foam Roll',
            setsReps: '10p',
          ),
        ],
      ),
      WorkoutScheduleItem(
        id: 'sch_4',
        date: _formatDate(now.add(const Duration(days: 3))),
        time: '18:00',
        title: 'Push Focus — Ngực, Vai & Tay sau',
        targetMuscles: 'Ngực • Vai • Tay sau',
        durationMinutes: 45,
        status: ScheduleStatus.planned,
        plannedExercises: const [
          PlannedExercisePreview(name: 'Barbell Bench Press', setsReps: '4x10'),
          PlannedExercisePreview(
            name: 'Incline Dumbbell Press',
            setsReps: '3x12',
          ),
          PlannedExercisePreview(
            name: 'Standing Dumbbell Lateral Raise',
            setsReps: '3x15',
          ),
          PlannedExercisePreview(
            name: 'Tricep Rope Pushdown',
            setsReps: '3x12',
          ),
        ],
      ),
    ];

    final currentYear = now.year;
    final currentMonth = now.month.toString().padLeft(2, '0');

    final defaultHistory = [
      WorkoutHistoryItem(
        id: 'hist_1',
        date: '$currentYear-$currentMonth-19',
        workoutName: 'Upper Body A — Ngực & Tay sau',
        durationMinutes: 52,
        totalVolumeKg: 4420,
        completedSetsCount: 14,
        prCount: 1,
        targetMuscles: const ['Ngực', 'Vai', 'Tay sau'],
        exercises: const [
          HistoryExerciseLog(
            exerciseId: 'ex_bench_press',
            exerciseName: 'Barbell Bench Press',
            primaryMuscle: 'Ngực',
            secondaryMuscles: ['Vai trước', 'Tay sau'],
            sets: [
              HistorySetLog(setNumber: 1, weightKg: 60, reps: 10),
              HistorySetLog(setNumber: 2, weightKg: 65, reps: 10, isPr: true),
              HistorySetLog(setNumber: 3, weightKg: 65, reps: 8),
              HistorySetLog(setNumber: 4, weightKg: 60, reps: 10),
            ],
          ),
          HistoryExerciseLog(
            exerciseId: 'ex_incline_db_press',
            exerciseName: 'Incline Dumbbell Press',
            primaryMuscle: 'Ngực',
            secondaryMuscles: ['Vai trước', 'Tay sau'],
            sets: [
              HistorySetLog(setNumber: 1, weightKg: 22, reps: 10),
              HistorySetLog(setNumber: 2, weightKg: 24, reps: 10),
              HistorySetLog(setNumber: 3, weightKg: 24, reps: 8),
            ],
          ),
          HistoryExerciseLog(
            exerciseId: 'ex_tricep_pushdown',
            exerciseName: 'Tricep Rope Pushdown',
            primaryMuscle: 'Tay sau',
            sets: [
              HistorySetLog(setNumber: 1, weightKg: 25, reps: 12),
              HistorySetLog(setNumber: 2, weightKg: 30, reps: 12),
              HistorySetLog(setNumber: 3, weightKg: 30, reps: 10),
              HistorySetLog(setNumber: 4, weightKg: 25, reps: 12),
            ],
          ),
          HistoryExerciseLog(
            exerciseId: 'ex_lat_raise',
            exerciseName: 'Standing Dumbbell Lateral Raise',
            primaryMuscle: 'Vai',
            sets: [
              HistorySetLog(setNumber: 1, weightKg: 10, reps: 15),
              HistorySetLog(setNumber: 2, weightKg: 10, reps: 15),
              HistorySetLog(setNumber: 3, weightKg: 12, reps: 12),
            ],
          ),
        ],
      ),
      WorkoutHistoryItem(
        id: 'hist_2',
        date: '$currentYear-$currentMonth-22',
        workoutName: 'Leg Day Power — Đùi & Mông',
        durationMinutes: 58,
        totalVolumeKg: 5120,
        completedSetsCount: 16,
        prCount: 2,
        targetMuscles: const ['Đùi trước', 'Mông', 'Bắp chân'],
        exercises: const [
          HistoryExerciseLog(
            exerciseId: 'ex_squat',
            exerciseName: 'Barbell Back Squat',
            primaryMuscle: 'Đùi trước',
            secondaryMuscles: ['Mông', 'Đùi sau'],
            sets: [
              HistorySetLog(setNumber: 1, weightKg: 80, reps: 8),
              HistorySetLog(setNumber: 2, weightKg: 90, reps: 8),
              HistorySetLog(setNumber: 3, weightKg: 100, reps: 6, isPr: true),
              HistorySetLog(setNumber: 4, weightKg: 90, reps: 8),
            ],
          ),
          HistoryExerciseLog(
            exerciseId: 'ex_rdl',
            exerciseName: 'Romanian Deadlift',
            primaryMuscle: 'Đùi sau',
            secondaryMuscles: ['Mông', 'Lưng dưới'],
            sets: [
              HistorySetLog(setNumber: 1, weightKg: 70, reps: 10),
              HistorySetLog(setNumber: 2, weightKg: 80, reps: 10),
              HistorySetLog(setNumber: 3, weightKg: 80, reps: 8, isPr: true),
              HistorySetLog(setNumber: 4, weightKg: 70, reps: 10),
            ],
          ),
          HistoryExerciseLog(
            exerciseId: 'ex_leg_ext',
            exerciseName: 'Leg Extension Machine',
            primaryMuscle: 'Đùi trước',
            sets: [
              HistorySetLog(setNumber: 1, weightKg: 45, reps: 12),
              HistorySetLog(setNumber: 2, weightKg: 50, reps: 12),
              HistorySetLog(setNumber: 3, weightKg: 55, reps: 10),
              HistorySetLog(setNumber: 4, weightKg: 50, reps: 12),
            ],
          ),
          HistoryExerciseLog(
            exerciseId: 'ex_calf_raise',
            exerciseName: 'Standing Calf Raise',
            primaryMuscle: 'Bắp chân',
            sets: [
              HistorySetLog(setNumber: 1, weightKg: 60, reps: 15),
              HistorySetLog(setNumber: 2, weightKg: 60, reps: 15),
              HistorySetLog(setNumber: 3, weightKg: 60, reps: 15),
              HistorySetLog(setNumber: 4, weightKg: 60, reps: 15),
            ],
          ),
        ],
      ),
      WorkoutHistoryItem(
        id: 'hist_3',
        date: '$currentYear-$currentMonth-24',
        workoutName: 'Pull Focus — Lưng Xô & Tay trước',
        durationMinutes: 46,
        totalVolumeKg: 3200,
        completedSetsCount: 12,
        prCount: 0,
        targetMuscles: const ['Lưng', 'Xô', 'Tay trước'],
        exercises: const [
          HistoryExerciseLog(
            exerciseId: 'ex_lat_pulldown',
            exerciseName: 'Lat Pulldown Wide Grip',
            primaryMuscle: 'Xô',
            secondaryMuscles: ['Tay trước', 'Lưng giữa'],
            sets: [
              HistorySetLog(setNumber: 1, weightKg: 50, reps: 10),
              HistorySetLog(setNumber: 2, weightKg: 55, reps: 10),
              HistorySetLog(setNumber: 3, weightKg: 60, reps: 8),
              HistorySetLog(setNumber: 4, weightKg: 55, reps: 10),
            ],
          ),
          HistoryExerciseLog(
            exerciseId: 'ex_cable_row',
            exerciseName: 'Seated Cable Row',
            primaryMuscle: 'Lưng',
            secondaryMuscles: ['Tay trước'],
            sets: [
              HistorySetLog(setNumber: 1, weightKg: 45, reps: 10),
              HistorySetLog(setNumber: 2, weightKg: 50, reps: 10),
              HistorySetLog(setNumber: 3, weightKg: 50, reps: 8),
              HistorySetLog(setNumber: 4, weightKg: 45, reps: 10),
            ],
          ),
          HistoryExerciseLog(
            exerciseId: 'ex_bicep_curl',
            exerciseName: 'Barbell Bicep Curl',
            primaryMuscle: 'Tay trước',
            sets: [
              HistorySetLog(setNumber: 1, weightKg: 25, reps: 10),
              HistorySetLog(setNumber: 2, weightKg: 30, reps: 10),
              HistorySetLog(setNumber: 3, weightKg: 30, reps: 8),
              HistorySetLog(setNumber: 4, weightKg: 25, reps: 10),
            ],
          ),
        ],
      ),
      WorkoutHistoryItem(
        id: 'hist_4',
        date: '$currentYear-$currentMonth-26',
        workoutName: 'Push Focus — Vai & Ngực trên',
        durationMinutes: 52,
        totalVolumeKg: 2560,
        completedSetsCount: 12,
        prCount: 1,
        targetMuscles: const ['Vai', 'Ngực', 'Tay sau'],
        exercises: const [
          HistoryExerciseLog(
            exerciseId: 'ex_overhead_press',
            exerciseName: 'Standing Overhead Barbell Press',
            primaryMuscle: 'Vai',
            secondaryMuscles: ['Tay sau', 'Ngực trên'],
            sets: [
              HistorySetLog(setNumber: 1, weightKg: 40, reps: 8),
              HistorySetLog(setNumber: 2, weightKg: 45, reps: 8),
              HistorySetLog(setNumber: 3, weightKg: 50, reps: 6, isPr: true),
              HistorySetLog(setNumber: 4, weightKg: 45, reps: 8),
            ],
          ),
          HistoryExerciseLog(
            exerciseId: 'ex_incline_fly',
            exerciseName: 'Incline Dumbbell Fly',
            primaryMuscle: 'Ngực',
            sets: [
              HistorySetLog(setNumber: 1, weightKg: 14, reps: 12),
              HistorySetLog(setNumber: 2, weightKg: 16, reps: 12),
              HistorySetLog(setNumber: 3, weightKg: 16, reps: 10),
              HistorySetLog(setNumber: 4, weightKg: 14, reps: 12),
            ],
          ),
          HistoryExerciseLog(
            exerciseId: 'ex_skull_crusher',
            exerciseName: 'EZ-Bar Skull Crusher',
            primaryMuscle: 'Tay sau',
            sets: [
              HistorySetLog(setNumber: 1, weightKg: 25, reps: 10),
              HistorySetLog(setNumber: 2, weightKg: 30, reps: 10),
              HistorySetLog(setNumber: 3, weightKg: 30, reps: 8),
              HistorySetLog(setNumber: 4, weightKg: 25, reps: 10),
            ],
          ),
        ],
      ),
    ];

    return WorkoutScheduleState(
      selectedDate: todayStr,
      schedules: defaultSchedules,
      history: defaultHistory,
    );
  }

  void selectDate(String date) {
    state = state.copyWith(selectedDate: date);
  }

  void addSchedule({
    required String title,
    required String targetMuscles,
    required int durationMinutes,
    required String date,
    required String time,
    List<PlannedExercisePreview> plannedExercises = const [],
  }) {
    final newItem = WorkoutScheduleItem(
      id: 'sch_${DateTime.now().millisecondsSinceEpoch}',
      date: date,
      time: time,
      title: title,
      targetMuscles: targetMuscles,
      durationMinutes: durationMinutes,
      status: ScheduleStatus.planned,
      plannedExercises: plannedExercises,
    );

    state = state.copyWith(schedules: [...state.schedules, newItem]);
  }

  bool extendLatestPlannedSchedule({
    required String date,
    required String targetMuscles,
    required int addedDurationMinutes,
    required List<PlannedExercisePreview> plannedExercises,
  }) {
    final index = state.schedules.lastIndexWhere(
      (item) => item.date == date && item.status == ScheduleStatus.planned,
    );
    if (index == -1) {
      return false;
    }

    final current = state.schedules[index];
    final mergedMuscles = {
      ...current.targetMuscles
          .split(RegExp(r'[•,]'))
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty),
      ...targetMuscles
          .split(RegExp(r'[•,]'))
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty),
    };
    final updated = [...state.schedules];
    updated[index] = current.copyWith(
      targetMuscles: mergedMuscles.join(' • '),
      durationMinutes: current.durationMinutes + addedDurationMinutes,
      plannedExercises: [...current.plannedExercises, ...plannedExercises],
    );
    state = state.copyWith(schedules: updated);
    return true;
  }

  bool replaceLatestPlannedSchedule({
    required String date,
    required String title,
    required String targetMuscles,
    required int durationMinutes,
    required String time,
    required List<PlannedExercisePreview> plannedExercises,
  }) {
    final index = state.schedules.lastIndexWhere(
      (item) => item.date == date && item.status == ScheduleStatus.planned,
    );
    if (index == -1) {
      return false;
    }

    final current = state.schedules[index];
    final updated = [...state.schedules];
    updated[index] = current.copyWith(
      title: title,
      targetMuscles: targetMuscles,
      durationMinutes: durationMinutes,
      time: time,
      status: ScheduleStatus.planned,
      plannedExercises: plannedExercises,
    );
    state = state.copyWith(schedules: updated);
    return true;
  }

  void reschedule(String scheduleId, String newDate, String newTime) {
    final updated = state.schedules.map((item) {
      if (item.id == scheduleId) {
        return item.copyWith(date: newDate, time: newTime);
      }
      return item;
    }).toList();

    state = state.copyWith(schedules: updated);
  }

  void markCompleted(String scheduleId) {
    final updated = state.schedules.map((item) {
      if (item.id == scheduleId) {
        return item.copyWith(status: ScheduleStatus.completed);
      }
      return item;
    }).toList();

    state = state.copyWith(schedules: updated);
  }

  bool swapWorkouts(String sourceId, String targetId) {
    final sourceIndex = state.schedules.indexWhere((s) => s.id == sourceId);
    final targetIndex = state.schedules.indexWhere((s) => s.id == targetId);

    if (sourceIndex == -1 || targetIndex == -1) return false;

    final source = state.schedules[sourceIndex];
    final target = state.schedules[targetIndex];

    if (source.status == ScheduleStatus.completed ||
        target.status == ScheduleStatus.completed) {
      return false;
    }

    final newSource = source.copyWith(date: target.date, time: target.time);
    final newTarget = target.copyWith(date: source.date, time: source.time);

    final updated = [...state.schedules];
    updated[sourceIndex] = newSource;
    updated[targetIndex] = newTarget;

    state = state.copyWith(schedules: updated);
    return true;
  }

  void deleteSchedule(String scheduleId) {
    state = state.copyWith(
      schedules: state.schedules.where((s) => s.id != scheduleId).toList(),
    );
  }

  bool moveWorkoutDate(String scheduleId, String newDate) {
    final existingOnTarget = state.schedules
        .where((s) => s.date == newDate)
        .toList();
    if (existingOnTarget.isNotEmpty) return false;

    final updated = state.schedules.map((item) {
      if (item.id == scheduleId) {
        return item.copyWith(date: newDate);
      }
      return item;
    }).toList();

    state = state.copyWith(schedules: updated, selectedDate: newDate);
    return true;
  }

  void recordWorkoutCompletion({
    required String workoutName,
    required int durationMinutes,
    required double totalVolumeKg,
    required int completedSets,
    required int prCount,
    List<String> targetMuscles = const [],
    List<HistoryExerciseLog> exercises = const [],
  }) {
    final todayStr = _formatDate(DateTime.now());
    final newHistoryItem = WorkoutHistoryItem(
      id: 'hist_${DateTime.now().millisecondsSinceEpoch}',
      date: todayStr,
      workoutName: workoutName,
      durationMinutes: durationMinutes,
      totalVolumeKg: totalVolumeKg,
      completedSetsCount: completedSets,
      prCount: prCount,
      targetMuscles: targetMuscles,
      exercises: exercises,
    );

    final activeScheduleId = state.schedules
        .where(
          (item) =>
              item.date == todayStr && item.status == ScheduleStatus.planned,
        )
        .lastOrNull
        ?.id;
    final updatedSchedules = state.schedules.map((item) {
      if (item.id == activeScheduleId) {
        return item.copyWith(status: ScheduleStatus.completed);
      }
      return item;
    }).toList();

    state = state.copyWith(
      schedules: updatedSchedules,
      history: [newHistoryItem, ...state.history],
    );
  }
}

final workoutScheduleProvider =
    NotifierProvider<WorkoutScheduleController, WorkoutScheduleState>(
      WorkoutScheduleController.new,
    );

final isTodayWorkoutCompletedProvider = Provider<bool>((ref) {
  final session = ref.watch(workoutSessionProvider);
  final schedule = ref.watch(workoutScheduleProvider);
  if (session.exercises.isNotEmpty) {
    return session.isFinalized;
  }
  return schedule.isTodayWorkoutCompleted;
});
