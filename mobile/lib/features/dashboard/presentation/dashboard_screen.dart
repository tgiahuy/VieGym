import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/utils/greeting_utils.dart';
import '../../ai/application/ai_coach_controller.dart';
import '../../auth/application/auth_controller.dart';
import '../../notifications/presentation/widgets/notification_bell_button.dart';
import '../../nutrition/application/nutrition_controller.dart';
import '../../onboarding/application/health_profile_controller.dart';
import '../../profile/application/progress_controller.dart';
import '../../workout/application/workout_schedule_controller.dart';
import '../../workout/application/workout_session_controller.dart';
import '../../workout/presentation/widgets/flippable_muscle_card.dart';
import '../../workout/presentation/widgets/today_workout_empty_state.dart';
import 'widgets/weekly_progress_card.dart';

String _formatDate(DateTime d) {
  final year = d.year;
  final month = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(workoutSessionProvider);
    final schedule = ref.watch(workoutScheduleProvider);
    final nutrition = ref.watch(nutritionProvider);
    final auth = ref.watch(authProvider);
    final healthProfile = ref.watch(healthProfileProvider);
    final progress = ref.watch(progressProvider);
    final aiCalories = ref.watch(mealCaloriesAddedProvider);
    final colors = Theme.of(context).colorScheme;

    final userName = healthProfile.nickname.isNotEmpty
        ? healthProfile.nickname
        : (auth.user?.displayName ?? 'Gia Huy');
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'G';
    final totalConsumedCalories = nutrition.consumedCalories + aiCalories;
    final greeting = getTimeBasedGreeting();
    final hasTodayWorkout = schedule.hasTodayWorkout;
    final todayWorkoutTitle = schedule.todayWorkout?.title;
    final displayTitle = session.title.isNotEmpty
        ? session.title
        : (todayWorkoutTitle ?? 'Upper Body A');

    final isTodayCompleted = ref.watch(isTodayWorkoutCompletedProvider);
    final todayScheduleItem = schedule.todayWorkout;
    final todayHistoryItem = schedule.history
        .where((h) => h.date == _formatDate(DateTime.now()))
        .firstOrNull;
    final completedMetadata = todayHistoryItem != null
        ? '${todayHistoryItem.durationMinutes} phút • ${todayHistoryItem.totalVolumeKg.toStringAsFixed(0)} kg • ${todayHistoryItem.completedSetsCount} hiệp'
        : (isTodayCompleted
              ? '${session.totalSets}/${session.totalSets} hiệp • 100% hoàn thành'
              : null);
    final activeSessionMuscles = session.exercises
        .map((exercise) => exercise.primaryMuscle)
        .where((muscle) => muscle.isNotEmpty)
        .toSet()
        .toList();
    final targetMusclesList =
        !session.isFinalized && activeSessionMuscles.isNotEmpty
        ? activeSessionMuscles
        : todayScheduleItem != null &&
              todayScheduleItem.targetMuscles.isNotEmpty
        ? todayScheduleItem.targetMuscles
              .split(RegExp(r'[•,]'))
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList()
        : const ['Ngực', 'Vai', 'Tay sau'];

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            // User Header: Greeting & Name on left, Avatar on right
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$greeting,',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const NotificationBellButton(),
                const SizedBox(width: 10),
                InkWell(
                  borderRadius: BorderRadius.circular(99),
                  onTap: () => context.push('/profile'),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: colors.primary.withValues(alpha: 0.2),
                    child: Text(
                      userInitial,
                      style: TextStyle(
                        color: colors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Weekly Progress Card (Tiến độ trong tuần)
            WeeklyProgressCard(
              completedWorkouts: progress.completedWorkoutsThisWeek,
              targetWorkouts: progress.targetWorkoutsPerWeek,
              streakDays: progress.currentStreakDays,
              onTap: () => context.push('/progress'),
            ),
            const SizedBox(height: 16),

            // Hero Workout Card or Empty State
            if (hasTodayWorkout && session.exercises.isNotEmpty)
              _HeroWorkoutCard(
                title: displayTitle,
                completedSets: session.completedSets,
                totalSets: session.totalSets,
                isCompleted: isTodayCompleted,
                completedMetadata: completedMetadata,
                targetMuscles: targetMusclesList,
                onStart: () => context.push('/workout/session'),
              )
            else
              TodayWorkoutEmptyState(
                title: 'Hôm nay chưa có lịch tập',
                subtitle:
                    'Bạn có thể tự tạo hoặc để VieGym AI thiết kế buổi tập chuẩn cho bạn.',
                aiButtonLabel: 'Tạo lịch tập với AI',
                onAiCreateWorkout: () {
                  final now = DateTime.now();
                  final todayStr =
                      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
                  ref
                      .read(workoutScheduleProvider.notifier)
                      .selectDate(todayStr);
                  context.push('/workout/generate');
                },
                buttonLabel: 'Thêm lịch tập ngay!',
                onCreateWorkout: () {
                  final now = DateTime.now();
                  final todayStr =
                      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
                  ref
                      .read(workoutScheduleProvider.notifier)
                      .selectDate(todayStr);
                  context.push('/workout/schedule');
                },
              ),
            const SizedBox(height: 20),

            // Today's Metrics Overview (Hiển thị thông tin, không phải button)
            const Text(
              'Chỉ số dinh dưỡng & Phục hồi',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    icon: Icons.local_fire_department_rounded,
                    label: 'Năng lượng',
                    value: '$totalConsumedCalories',
                    unit: '/ ${nutrition.targetCalories} kcal',
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: const _MetricCard(
                    icon: Icons.monitor_heart_outlined,
                    label: 'Phục hồi',
                    value: '88%',
                    unit: 'Sẵn sàng tập luyện',
                    color: Colors.tealAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // AI Coach Banner
            Card(
              margin: EdgeInsets.zero,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => context.push('/ai/chat'),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.primary.withValues(alpha: 0.18),
                        ),
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Coach Thông Minh',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Hỏi AI về kỹ thuật, đau nhức hoặc đổi bài tập linh hoạt.',
                              style: TextStyle(fontSize: 12, height: 1.35),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroWorkoutCard extends StatelessWidget {
  const _HeroWorkoutCard({
    required this.title,
    required this.completedSets,
    required this.totalSets,
    required this.onStart,
    this.isCompleted = false,
    this.completedMetadata,
    this.targetMuscles = const ['Ngực', 'Vai', 'Tay sau'],
  });

  final String title;
  final int completedSets;
  final int totalSets;
  final VoidCallback onStart;
  final bool isCompleted;
  final String? completedMetadata;
  final List<String> targetMuscles;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (isCompleted) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.35),
            width: 1.2,
          ),
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
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.accentEmerald,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'BUỔI TẬP HÔM NAY',
                            style: TextStyle(
                              color: colors.onSurfaceVariant.withValues(
                                alpha: 0.8,
                              ),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        title,
                        style: TextStyle(
                          color: colors.onSurface.withValues(alpha: 0.88),
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        completedMetadata ??
                            '$totalSets/$totalSets hiệp đã hoàn thành',
                        style: TextStyle(
                          color: colors.onSurfaceVariant.withValues(
                            alpha: 0.75,
                          ),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: targetMuscles
                            .map((m) => _MuscleBadge(label: m, isMuted: true))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Opacity(
                  opacity: 0.65,
                  child: FlippableMuscleCard(targetMuscles: targetMuscles),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Đã hoàn thành hôm nay ✓',
                  style: TextStyle(
                    color: AppColors.accentEmerald,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Transform.rotate(
                  angle: -0.08,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentEmerald.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.accentEmerald,
                        width: 1.8,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.accentEmerald,
                          size: 15,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'ĐÃ HOÀN THÀNH',
                          style: TextStyle(
                            color: AppColors.accentEmerald,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Active pending/in-progress card
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [colors.primary, colors.primary.withValues(alpha: 0.76)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
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
                    const Text(
                      'BUỔI TẬP HÔM NAY',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completedSets/$totalSets hiệp đã hoàn thành',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Target muscle badges
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: targetMuscles
                          .map((m) => _MuscleBadge(label: m))
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // 3D Flippable Body Muscle Map Illustration
              FlippableMuscleCard(targetMuscles: targetMuscles),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onStart,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: colors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(
              completedSets > 0 ? 'Tiếp tục buổi tập' : 'Bắt đầu tập ngay',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _MuscleBadge extends StatelessWidget {
  const _MuscleBadge({required this.label, this.isMuted = false});
  final String label;
  final bool isMuted;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isMuted
            ? colors.surfaceContainerHighest.withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isMuted
              ? colors.outlineVariant.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.28),
          width: 0.8,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isMuted ? colors.onSurfaceVariant : Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cardContent = Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          Text(unit, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );

    return Card(margin: EdgeInsets.zero, child: cardContent);
  }
}
