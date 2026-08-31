import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/exercise_tag_chip.dart';
import '../application/workout_schedule_controller.dart';
import '../domain/muscle_models.dart';
import '../domain/workout_models.dart';
import 'widgets/body_muscle_map.dart';

class WorkoutHistoryDetailScreen extends ConsumerWidget {
  const WorkoutHistoryDetailScreen({super.key, required this.historyId});

  final String historyId;

  String _formatVietnameseDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        final date = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
        const weekdays = [
          'Thứ Hai',
          'Thứ Ba',
          'Thứ Tư',
          'Thứ Năm',
          'Thứ Sáu',
          'Thứ Bảy',
          'Chủ Nhật',
        ];
        final weekday = weekdays[date.weekday - 1];
        final day = parts[2];
        final month = parts[1];
        final year = parts[0];
        return '$weekday, ngày $day/$month/$year';
      }
    } catch (_) {}
    return dateStr;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleState = ref.watch(workoutScheduleProvider);
    final colors = Theme.of(context).colorScheme;

    final historyItem = scheduleState.history.firstWhere(
      (h) => h.id == historyId,
      orElse: () => WorkoutHistoryItem(
        id: historyId,
        date: '',
        workoutName: 'Buổi tập',
        durationMinutes: 0,
        totalVolumeKg: 0,
        completedSetsCount: 0,
        prCount: 0,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Chi tiết buổi tập'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Card Summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF141724),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF282E44), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              historyItem.workoutName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 14,
                                  color: colors.onSurfaceVariant,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _formatVietnameseDate(historyItem.date),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (historyItem.prCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.amber.withValues(alpha: 0.4),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.emoji_events_rounded,
                                size: 14,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${historyItem.prCount} PR Mới',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  if (historyItem.targetMuscles.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: historyItem.targetMuscles
                          .map((m) => ExerciseTagChip.muscle(label: m))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 18),
                  const Divider(color: Color(0xFF282E44), height: 1),
                  const SizedBox(height: 16),

                  // 4 Core Metrics
                  Row(
                    children: [
                      Expanded(
                        child: _DetailMetricItem(
                          icon: Icons.timer_outlined,
                          iconColor: colors.primary,
                          label: 'Thời gian',
                          value: '${historyItem.durationMinutes}p',
                        ),
                      ),
                      Expanded(
                        child: _DetailMetricItem(
                          icon: Icons.fitness_center_rounded,
                          iconColor: const Color(0xFF10B981),
                          label: 'Tổng Volume',
                          value:
                              '${historyItem.totalVolumeKg.toStringAsFixed(0)} kg',
                          valueColor: const Color(0xFF10B981),
                        ),
                      ),
                      Expanded(
                        child: _DetailMetricItem(
                          icon: Icons.repeat_rounded,
                          iconColor: const Color(0xFF3B82F6),
                          label: 'Tổng số hiệp',
                          value: '${historyItem.completedSetsCount}',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Target Muscles Visual Card (If primary muscles available)
            if (historyItem.targetMuscles.isNotEmpty) ...[
              Builder(
                builder: (context) {
                  final primaryGroup = MuscleGroup.fromString(
                    historyItem.targetMuscles.first,
                  );
                  final secondaryGroups = historyItem.targetMuscles
                      .skip(1)
                      .map(MuscleGroup.fromString)
                      .whereType<MuscleGroup>()
                      .toSet();

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141724),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFF282E44),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 68,
                          height: 84,
                          child: BodyMuscleMap(
                            bodySide:
                                primaryGroup?.primarySide ??
                                secondaryGroups.firstOrNull?.primarySide ??
                                BodySide.front,
                            primaryMuscles: primaryGroup != null
                                ? {primaryGroup}
                                : const {},
                            secondaryMuscles: secondaryGroups,
                            autoZoom: true,
                            interactive: false,
                            height: 84,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'NHÓM CƠ ĐÃ TÁC ĐỘNG',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: colors.onSurfaceVariant,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                historyItem.targetMuscles.join(' • '),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Buổi tập đã kích hoạt hiệu quả các nhóm cơ mục tiêu.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],

            // Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'DANH SÁCH BÀI TẬP (${historyItem.exercises.isNotEmpty
                      ? historyItem.exercises.length
                      : historyItem.completedSetsCount > 0
                      ? 1
                      : 0})',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: colors.onSurfaceVariant,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  'Chế độ xem lịch sử',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Exercise Cards List
            if (historyItem.exercises.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF141724),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF282E44)),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.checklist_rounded,
                      size: 36,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      historyItem.workoutName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Đã hoàn thành ${historyItem.completedSetsCount} hiệp trong ${historyItem.durationMinutes} phút.',
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...historyItem.exercises.asMap().entries.map((entry) {
                final exIndex = entry.key;
                final ex = entry.value;

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141724),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFF282E44),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Exercise Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                        child: Row(
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${exIndex + 1}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: colors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ex.exerciseName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${ex.totalSets} hiệp • ${ex.volumeKg.toStringAsFixed(0)} kg volume',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ExerciseTagChip.muscle(label: ex.primaryMuscle),
                          ],
                        ),
                      ),
                      const Divider(color: Color(0xFF282E44), height: 1),

                      // Table Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        color: const Color(0xFF1B1F30).withValues(alpha: 0.5),
                        child: const Row(
                          children: [
                            SizedBox(
                              width: 44,
                              child: Text(
                                'HIỆP',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white54,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'MỨC TẠ',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white54,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'SỐ REPS',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white54,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Text(
                              'TRẠNG THÁI',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.white54,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Set Rows
                      ...ex.sets.map((setLog) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color(0xFF1F2436),
                                width: 0.6,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 44,
                                child: Text(
                                  '${setLog.setNumber}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '${setLog.weightKg.toStringAsFixed(setLog.weightKg % 1 == 0 ? 0 : 1)} kg',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '${setLog.reps} reps',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              if (setLog.isPr)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    '🏅 PR',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.amber,
                                    ),
                                  ),
                                )
                              else
                                const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle_rounded,
                                      size: 15,
                                      color: Color(0xFF10B981),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Đạt',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF10B981),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _DetailMetricItem extends StatelessWidget {
  const _DetailMetricItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: valueColor ?? Colors.white,
          ),
        ),
      ],
    );
  }
}
