import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/workout_schedule_controller.dart';

class WorkoutHistoryScreen extends ConsumerWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleState = ref.watch(workoutScheduleProvider);
    final history = scheduleState.history;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Lịch sử buổi tập'),
      ),
      body: history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 56,
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Chưa có buổi tập nào hoàn thành',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: colors.outlineVariant.withValues(alpha: 0.5),
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
                            Text(
                              item.date,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: colors.primary,
                              ),
                            ),
                            if (item.prCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.emoji_events_rounded,
                                      size: 13,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${item.prCount} PR Mới',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.amber,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.workoutName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _HistoryStat(
                                label: 'Thời gian',
                                value: '${item.durationMinutes} phút',
                              ),
                            ),
                            Expanded(
                              child: _HistoryStat(
                                label: 'Tổng volume',
                                value: '${item.totalVolumeKg.toStringAsFixed(0)} kg',
                                valueColor: Colors.greenAccent,
                              ),
                            ),
                            Expanded(
                              child: _HistoryStat(
                                label: 'Số hiệp',
                                value: '${item.completedSetsCount} hiệp',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _HistoryStat extends StatelessWidget {
  const _HistoryStat({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: valueColor ?? colors.onSurface,
          ),
        ),
      ],
    );
  }
}
