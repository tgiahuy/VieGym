import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/workout_session_controller.dart';

class WorkoutTabScreen extends ConsumerWidget {
  const WorkoutTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(workoutSessionProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Kế hoạch tập luyện')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          // Hero Workout Card
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.bolt_rounded, color: Colors.amber),
                      SizedBox(width: 8),
                      Text(
                        'HÔM NAY',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    session.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${session.exercises.length} bài • ${session.totalSets} hiệp • khoảng 45 phút',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: session.totalSets == 0
                        ? 0
                        : session.completedSets / session.totalSets,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${session.completedSets}/${session.totalSets} hiệp hoàn thành',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => context.push('/workout/session'),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(
                      session.completedSets > 0
                          ? 'Tiếp tục buổi tập'
                          : 'Bắt đầu tập',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 4 Shortcut Grid
          Row(
            children: [
              Expanded(
                child: _Shortcut(
                  icon: Icons.search_rounded,
                  label: 'Thư viện',
                  onTap: () => context.push('/workout/library'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Shortcut(
                  icon: Icons.calendar_month_rounded,
                  label: 'Lịch tập',
                  onTap: () => context.push('/workout/schedule'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Shortcut(
                  icon: Icons.history_rounded,
                  label: 'Lịch sử',
                  onTap: () => context.push('/workout/history'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Shortcut(
                  icon: Icons.auto_awesome_rounded,
                  label: 'AI Tạo bài',
                  onTap: () => context.push('/workout/generate'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Exercise List Header
          const Text(
            'Danh sách bài hôm nay',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),

          // Exercises List
          ...session.exercises.asMap().entries.map((entry) {
            final exercise = entry.value;
            final completed = session.logs[exercise.exerciseId]
                    ?.where((set) => set.completed)
                    .length ??
                0;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: colors.primary.withValues(alpha: 0.15),
                  child: Text(
                    '${entry.key + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: colors.primary,
                    ),
                  ),
                ),
                title: Text(
                  exercise.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  '${exercise.primaryMuscle} • ${exercise.equipment.label}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$completed/${exercise.targetSets}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.info_outline_rounded, size: 20),
                      onPressed: () =>
                          context.push('/exercise/${exercise.exerciseId}'),
                    ),
                  ],
                ),
                onTap: () {
                  ref
                      .read(workoutSessionProvider.notifier)
                      .selectExercise(entry.key);
                  context.push('/workout/session');
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
          child: Column(
            children: [
              Icon(icon, color: colors.primary, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
