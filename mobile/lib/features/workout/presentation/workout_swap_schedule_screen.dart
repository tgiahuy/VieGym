import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/workout_schedule_controller.dart';
import '../domain/workout_models.dart';

class WorkoutSwapScheduleScreen extends ConsumerStatefulWidget {
  const WorkoutSwapScheduleScreen({super.key, this.sourceScheduleId});

  final String? sourceScheduleId;

  @override
  ConsumerState<WorkoutSwapScheduleScreen> createState() =>
      _WorkoutSwapScheduleScreenState();
}

class _WorkoutSwapScheduleScreenState
    extends ConsumerState<WorkoutSwapScheduleScreen> {
  String? _selectedTargetId;

  String _formatDisplayDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        final d = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
        const dayNames = [
          'Thứ Hai',
          'Thứ Ba',
          'Thứ Tư',
          'Thứ Năm',
          'Thứ Sáu',
          'Thứ Bảy',
          'Chủ Nhật'
        ];
        final dayName = dayNames[d.weekday - 1];
        final day = d.day.toString().padLeft(2, '0');
        final month = d.month.toString().padLeft(2, '0');
        return '$dayName, $day/$month/${d.year}';
      }
    } catch (_) {}
    return dateStr;
  }

  void _confirmSwap(
    BuildContext context,
    WorkoutScheduleItem source,
    WorkoutScheduleItem target,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.swap_horiz_rounded, color: Colors.blueAccent),
              SizedBox(width: 8),
              Text('Đổi lịch hai buổi tập?'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bạn có chắc chắn muốn hoán đổi lịch ngày tập giữa hai buổi này không?',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      source.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${_formatDisplayDate(source.date)} ➔ ${_formatDisplayDate(target.date)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      target.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${_formatDisplayDate(target.date)} ➔ ${_formatDisplayDate(source.date)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
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
                Navigator.pop(dialogContext);
                final success = ref
                    .read(workoutScheduleProvider.notifier)
                    .swapWorkouts(source.id, target.id);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Đã đổi lịch giữa "${source.title}" và "${target.title}"!',
                      ),
                    ),
                  );
                  context.pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Không thể hoán đổi buổi tập đã hoàn thành.'),
                    ),
                  );
                }
              },
              child: const Text('Đổi lịch'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheduleState = ref.watch(workoutScheduleProvider);
    final schedules = scheduleState.schedules;
    final colors = Theme.of(context).colorScheme;

    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    WorkoutScheduleItem? sourceItem;
    if (widget.sourceScheduleId != null) {
      sourceItem = schedules.cast<WorkoutScheduleItem?>().firstWhere(
            (s) => s?.id == widget.sourceScheduleId,
            orElse: () => null,
          );
    }
    sourceItem ??= schedules.cast<WorkoutScheduleItem?>().firstWhere(
          (s) => s?.date == todayStr && s?.status != ScheduleStatus.rest,
          orElse: () => null,
        );
    sourceItem ??= schedules.cast<WorkoutScheduleItem?>().firstWhere(
          (s) => s?.status == ScheduleStatus.planned,
          orElse: () => schedules.isNotEmpty ? schedules.first : null,
        );

    final availableTargets = sourceItem == null
        ? <WorkoutScheduleItem>[]
        : schedules.where((s) {
            return s.id != sourceItem!.id &&
                s.status == ScheduleStatus.planned &&
                s.date.compareTo(todayStr) >= 0;
          }).toList();

    final targetItem = _selectedTargetId == null
        ? null
        : availableTargets.cast<WorkoutScheduleItem?>().firstWhere(
              (t) => t?.id == _selectedTargetId,
              orElse: () => null,
            );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Đổi buổi tập'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          // Helper Banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.repeat_rounded,
                    size: 18,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hoán đổi lịch tập trong tuần',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Chuyển ngày giữa buổi tập hiện tại và một buổi tập sắp tới. Toàn bộ danh sách bài tập sẽ được bảo toàn.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Section 1: Source Workout
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '1. BUỔI TẬP HIỆN TẠI',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: Colors.grey,
                ),
              ),
              if (sourceItem?.date == todayStr)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Hôm nay',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: colors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          if (sourceItem != null)
            Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: colors.primary.withValues(alpha: 0.4),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 14,
                              color: colors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatDisplayDate(sourceItem.date),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: colors.primary,
                              ),
                            ),
                          ],
                        ),
                        if (sourceItem.time.isNotEmpty)
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                sourceItem.time,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sourceItem.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sourceItem.targetMuscles,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${sourceItem.durationMinutes} phút',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              child: const Text('Chưa có buổi tập nào để hoán đổi.'),
            ),

          const SizedBox(height: 20),

          // Section 2: Target Selection
          const Text(
            '2. CHỌN BUỔI TẬP MUỐN ĐỔI SANG',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),

          if (availableTargets.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.event_busy_rounded, size: 36, color: Colors.grey),
                  const SizedBox(height: 8),
                  const Text(
                    'Không tìm thấy buổi tập sắp tới nào khả dụng để hoán đổi.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => context.push('/workout/schedule'),
                    child: const Text('Mở Lịch tập tuần'),
                  ),
                ],
              ),
            )
          else
            ...availableTargets.map((target) {
              final isSelected = target.id == _selectedTargetId;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  margin: EdgeInsets.zero,
                  color: isSelected
                      ? colors.primary.withValues(alpha: 0.12)
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isSelected
                          ? colors.primary
                          : Theme.of(context).colorScheme.outlineVariant,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      setState(() {
                        _selectedTargetId = target.id;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDisplayDate(target.date),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? colors.primary : Colors.grey,
                                ),
                              ),
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? colors.primary
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected
                                        ? colors.primary
                                        : Colors.grey,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check_rounded,
                                        size: 14,
                                        color: Colors.black,
                                      )
                                    : null,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            target.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            target.targetMuscles,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),

          if (sourceItem != null && targetItem != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: colors.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TÓM TẮT SAU KHI ĐỔI LỊCH',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: colors.primary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          sourceItem.title,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${sourceItem.date.substring(5)} ➔ ${targetItem.date.substring(5)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          targetItem.title,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${targetItem.date.substring(5)} ➔ ${sourceItem.date.substring(5)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
        child: FilledButton.icon(
          onPressed: (sourceItem != null && targetItem != null)
              ? () => _confirmSwap(context, sourceItem!, targetItem)
              : null,
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.repeat_rounded),
          label: const Text(
            'Xác nhận đổi lịch',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
        ),
      ),
    );
  }
}
