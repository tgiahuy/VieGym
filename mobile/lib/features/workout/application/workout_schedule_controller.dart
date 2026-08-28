import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/workout_models.dart';

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
        title: 'Upper Body A (Ngực, Vai, Tay sau)',
        targetMuscles: 'Ngực, Vai, Tay sau',
        durationMinutes: 45,
        status: ScheduleStatus.planned,
      ),
      WorkoutScheduleItem(
        id: 'sch_2',
        date: _formatDate(now.add(const Duration(days: 1))),
        time: '18:00',
        title: 'Lower Body & Core (Đùi, Mông, Bụng)',
        targetMuscles: 'Đùi trước, Mông, Cơ bụng',
        durationMinutes: 50,
        status: ScheduleStatus.planned,
      ),
      WorkoutScheduleItem(
        id: 'sch_3',
        date: _formatDate(now.add(const Duration(days: 2))),
        time: '17:30',
        title: 'Nghỉ ngơi phục hồi chủ động (Active Recovery)',
        targetMuscles: 'Toàn thân',
        durationMinutes: 30,
        status: ScheduleStatus.rest,
      ),
      WorkoutScheduleItem(
        id: 'sch_4',
        date: _formatDate(now.add(const Duration(days: 3))),
        time: '18:00',
        title: 'Pull & Lưng xô (Back & Biceps)',
        targetMuscles: 'Lưng xô, Tay trước',
        durationMinutes: 45,
        status: ScheduleStatus.planned,
      ),
    ];

    final defaultHistory = [
      WorkoutHistoryItem(
        id: 'hist_1',
        date: _formatDate(now.subtract(const Duration(days: 1))),
        workoutName: 'Upper Body A',
        durationMinutes: 48,
        totalVolumeKg: 3450,
        completedSetsCount: 14,
        prCount: 2,
      ),
      WorkoutHistoryItem(
        id: 'hist_2',
        date: _formatDate(now.subtract(const Duration(days: 3))),
        workoutName: 'Leg Day Power',
        durationMinutes: 55,
        totalVolumeKg: 4800,
        completedSetsCount: 16,
        prCount: 1,
      ),
      WorkoutHistoryItem(
        id: 'hist_3',
        date: _formatDate(now.subtract(const Duration(days: 5))),
        workoutName: 'Back & Core Hypertrophy',
        durationMinutes: 42,
        totalVolumeKg: 2900,
        completedSetsCount: 12,
        prCount: 0,
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
  }) {
    final newItem = WorkoutScheduleItem(
      id: 'sch_${DateTime.now().millisecondsSinceEpoch}',
      date: date,
      time: time,
      title: title,
      targetMuscles: targetMuscles,
      durationMinutes: durationMinutes,
      status: ScheduleStatus.planned,
    );

    state = state.copyWith(
      schedules: [...state.schedules, newItem],
    );
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

    if (source.status == ScheduleStatus.completed || target.status == ScheduleStatus.completed) {
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

  void recordWorkoutCompletion({
    required String workoutName,
    required int durationMinutes,
    required double totalVolumeKg,
    required int completedSets,
    required int prCount,
  }) {
    final newHistoryItem = WorkoutHistoryItem(
      id: 'hist_${DateTime.now().millisecondsSinceEpoch}',
      date: _formatDate(DateTime.now()),
      workoutName: workoutName,
      durationMinutes: durationMinutes,
      totalVolumeKg: totalVolumeKg,
      completedSetsCount: completedSets,
      prCount: prCount,
    );

    state = state.copyWith(
      history: [newHistoryItem, ...state.history],
    );
  }
}

final workoutScheduleProvider =
    NotifierProvider<WorkoutScheduleController, WorkoutScheduleState>(
  WorkoutScheduleController.new,
);
