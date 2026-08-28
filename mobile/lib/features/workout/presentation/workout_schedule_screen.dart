import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/workout_schedule_controller.dart';
import '../domain/workout_models.dart';

class WorkoutScheduleScreen extends ConsumerStatefulWidget {
  const WorkoutScheduleScreen({super.key});

  @override
  ConsumerState<WorkoutScheduleScreen> createState() =>
      _WorkoutScheduleScreenState();
}

class _WorkoutScheduleScreenState extends ConsumerState<WorkoutScheduleScreen> {
  DateTime _currentWeekStart = _getMonday(DateTime.now());

  static DateTime _getMonday(DateTime d) {
    return d.subtract(Duration(days: d.weekday - 1));
  }

  String _formatDate(DateTime d) {
    final year = d.year;
    final month = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  void _showAddScheduleDialog(BuildContext context) {
    final titleController = TextEditingController(text: 'Upper Body B');
    final musclesController =
        TextEditingController(text: 'Ngực trên, Vai, Tay trước');
    int duration = 45;
    final state = ref.read(workoutScheduleProvider);

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Thêm buổi tập vào lịch'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Tên buổi tập'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: musclesController,
                decoration: const InputDecoration(labelText: 'Nhóm cơ tác động'),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Thời lượng:'),
                  DropdownButton<int>(
                    value: duration,
                    items: const [
                      DropdownMenuItem(value: 30, child: Text('30 phút')),
                      DropdownMenuItem(value: 45, child: Text('45 phút')),
                      DropdownMenuItem(value: 60, child: Text('60 phút')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => duration = val);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () {
                ref.read(workoutScheduleProvider.notifier).addSchedule(
                      title: titleController.text,
                      targetMuscles: musclesController.text,
                      durationMinutes: duration,
                      date: state.selectedDate,
                      time: '18:00',
                    );
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã thêm buổi tập vào lịch!')),
                );
              },
              child: const Text('Thêm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheduleState = ref.watch(workoutScheduleProvider);
    final notifier = ref.read(workoutScheduleProvider.notifier);
    final colors = Theme.of(context).colorScheme;

    final weekDays = List.generate(7, (i) {
      return _currentWeekStart.add(Duration(days: i));
    });

    final dayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final selectedDaySchedules = scheduleState.selectedDaySchedules;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Lịch tập luyện'),
        actions: [
          IconButton(
            onPressed: () => context.push('/workout/schedule/swap'),
            icon: const Icon(Icons.swap_horiz_rounded),
            tooltip: 'Đổi buổi tập',
          ),
          IconButton(
            onPressed: () => _showAddScheduleDialog(context),
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Thêm buổi tập',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          // Week Header Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _currentWeekStart =
                        _currentWeekStart.subtract(const Duration(days: 7));
                  });
                },
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Text(
                'Tháng ${_currentWeekStart.month}, ${_currentWeekStart.year}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _currentWeekStart =
                        _currentWeekStart.add(const Duration(days: 7));
                  });
                },
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 7-day Horizontal Week Strip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weekDays.asMap().entries.map((entry) {
              final idx = entry.key;
              final date = entry.value;
              final dateStr = _formatDate(date);
              final isSelected = dateStr == scheduleState.selectedDate;
              final hasSchedule = scheduleState.schedules.any(
                (s) => s.date == dateStr,
              );

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => notifier.selectDate(dateStr),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.primary
                            : colors.surfaceContainer,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? colors.primary
                              : colors.outlineVariant.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            dayLabels[idx],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? colors.onPrimary
                                  : colors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: isSelected
                                  ? colors.onPrimary
                                  : colors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: hasSchedule
                                  ? (isSelected
                                      ? colors.onPrimary
                                      : colors.primary)
                                  : Colors.transparent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Selected Day Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lịch tập ngày ${scheduleState.selectedDate}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showAddScheduleDialog(context),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Thêm'),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Scheduled items list
          if (selectedDaySchedules.isEmpty)
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
                child: Column(
                  children: [
                    Icon(
                      Icons.bedtime_outlined,
                      size: 44,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Ngày nghỉ ngơi (Rest Day)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Chưa có buổi tập nào được lên lịch cho ngày này.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...selectedDaySchedules.map((item) {
              final isRest = item.status == ScheduleStatus.rest;
              final isCompleted = item.status == ScheduleStatus.completed;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(
                    color: isCompleted
                        ? Colors.greenAccent.withValues(alpha: 0.5)
                        : colors.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isRest
                                    ? Icons.bedtime_outlined
                                    : Icons.timer_outlined,
                                size: 16,
                                color: colors.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${item.time} • ${item.durationMinutes} phút',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: colors.primary,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? Colors.greenAccent.withValues(alpha: 0.15)
                                  : colors.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.status.label,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: isCompleted
                                    ? Colors.greenAccent
                                    : colors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Nhóm cơ: ${item.targetMuscles}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                      ),
                      if (!isRest) ...[
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () => context.push('/workout/session'),
                                icon: const Icon(Icons.play_arrow_rounded),
                                label: const Text('Bắt đầu tập'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () {
                                notifier.markCompleted(item.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Đã đánh dấu hoàn thành!'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.check_rounded),
                              style: IconButton.styleFrom(
                                backgroundColor: colors.surfaceContainer,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
