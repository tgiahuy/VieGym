import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../ai/application/ai_coach_controller.dart';
import '../../auth/application/auth_controller.dart';
import '../../nutrition/application/nutrition_controller.dart';
import '../../onboarding/application/health_profile_controller.dart';
import '../../workout/application/workout_session_controller.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(workoutSessionProvider);
    final nutrition = ref.watch(nutritionProvider);
    final auth = ref.watch(authProvider);
    final healthProfile = ref.watch(healthProfileProvider);
    final aiCalories = ref.watch(mealCaloriesAddedProvider);
    final colors = Theme.of(context).colorScheme;

    final userName = healthProfile.nickname.isNotEmpty
        ? healthProfile.nickname
        : (auth.user?.displayName ?? 'Gia Huy');
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'G';
    final totalConsumedCalories = nutrition.consumedCalories + aiCalories;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
          children: [
            // User Header
            Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(99),
                  onTap: () => context.push('/profile'),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: colors.primary.withValues(alpha: 0.2),
                    child: Text(
                      userInitial,
                      style: TextStyle(
                        color: colors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Chào buổi sáng,',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () => context.push('/profile/settings'),
                  icon: const Icon(Icons.settings_outlined),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Hero Workout Card
            _HeroWorkoutCard(
              title: session.title,
              completedSets: session.completedSets,
              totalSets: session.totalSets,
              onStart: () => context.push('/workout/session'),
            ),
            const SizedBox(height: 16),

            // 4 Shortcuts Row
            Row(
              children: [
                Expanded(
                  child: _DashboardShortcut(
                    icon: Icons.calendar_month_rounded,
                    label: 'Lịch tập',
                    color: Colors.blueAccent,
                    onTap: () => context.push('/workout/schedule'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _DashboardShortcut(
                    icon: Icons.search_rounded,
                    label: 'Thư viện',
                    color: Colors.amber,
                    onTap: () => context.push('/workout/library'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _DashboardShortcut(
                    icon: Icons.restaurant_rounded,
                    label: 'Thực đơn',
                    color: Colors.greenAccent,
                    onTap: () => context.push('/meal/plan'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _DashboardShortcut(
                    icon: Icons.trending_up_rounded,
                    label: 'Tiến độ',
                    color: Colors.purpleAccent,
                    onTap: () => context.push('/progress'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Today's Metrics Overview
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
                    onTap: () => context.push('/meal'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricCard(
                    icon: Icons.monitor_heart_outlined,
                    label: 'Phục hồi',
                    value: '88%',
                    unit: 'Sẵn sàng tập luyện',
                    color: Colors.tealAccent,
                    onTap: () => context.push('/progress'),
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
                        child: Icon(Icons.auto_awesome_rounded, color: colors.primary),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Coach Thông Minh',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
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
  });

  final String title;
  final int completedSets;
  final int totalSets;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            colors.primary,
            colors.primary.withValues(alpha: 0.72),
          ],
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
          const Text(
            'BUỔI TẬP HÔM NAY',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$completedSets/$totalSets hiệp • Ngực, Vai, Tay sau',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 18),
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

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
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
        ),
      ),
    );
  }
}

class _DashboardShortcut extends StatelessWidget {
  const _DashboardShortcut({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
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
