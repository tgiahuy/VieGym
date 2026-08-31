import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/workout_schedule_controller.dart';
import '../application/workout_session_controller.dart';
import '../domain/workout_models.dart';

class WorkoutSummaryScreen extends ConsumerWidget {
  const WorkoutSummaryScreen({super.key, this.summary});

  final WorkoutSummaryData? summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;

    final latestHistory = ref
        .watch(workoutScheduleProvider)
        .history
        .firstOrNull;
    final session = ref.watch(workoutSessionProvider);

    final title = summary?.title ?? latestHistory?.workoutName ?? session.title;
    final duration =
        summary?.durationFormatted ??
        (latestHistory != null
            ? '${latestHistory.durationMinutes.toString().padLeft(2, '0')}:00'
            : '00:00');

    final volumeNum =
        summary?.totalVolumeKg ??
        latestHistory?.totalVolumeKg ??
        session.totalVolumeKg;
    final volume =
        '${volumeNum.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} kg';

    final completedSets =
        summary?.completedSets ??
        latestHistory?.completedSetsCount ??
        session.completedSets;
    final totalSets = summary?.totalSets ?? session.totalSets;
    final sets = '$completedSets/$totalSets';

    final prs = summary?.prCount ?? latestHistory?.prCount ?? 0;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Trophy / Check Circle
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.greenAccent.withValues(alpha: 0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.greenAccent.withValues(alpha: 0.3),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.greenAccent,
                    size: 52,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Hoàn thành xuất sắc!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Bạn đã hoàn thành buổi tập $title',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 28),

              // Summary Metric Cards (2x2 Grid)
              Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: colors.outlineVariant.withValues(alpha: 0.6),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _MetricTile(
                              label: 'THỜI GIAN',
                              value: duration,
                              icon: Icons.timer_outlined,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _MetricTile(
                              label: 'TỔNG KHỐI LƯỢNG',
                              value: volume,
                              icon: Icons.fitness_center_rounded,
                              valueColor: Colors.greenAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _MetricTile(
                              label: 'HIỆP HOÀN THÀNH',
                              value: sets,
                              icon: Icons.checklist_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _MetricTile(
                              label: 'KỶ LỤC MỚI (PR)',
                              value: '$prs PR',
                              icon: Icons.emoji_events_rounded,
                              valueColor: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),

              // Actions
              FilledButton(
                onPressed: () => context.go('/workout'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Về trang tập luyện',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.push('/workout/history'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  side: BorderSide(color: colors.outlineVariant),
                ),
                child: Text(
                  'Xem lịch sử buổi tập',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: colors.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: colors.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: valueColor ?? colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
