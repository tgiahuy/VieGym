import 'dart:math' as math;
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
import '../../profile/presentation/widgets/log_weight_dialog.dart';
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

  void _showLogWeightDialog(BuildContext context, WidgetRef ref) {
    showLogWeightModal(context, ref);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(workoutSessionProvider);
    final schedule = ref.watch(workoutScheduleProvider);
    final nutrition = ref.watch(nutritionProvider);
    final auth = ref.watch(authProvider);
    final healthProfile = ref.watch(healthProfileProvider);
    final progress = ref.watch(progressProvider);
    final aiCalories = ref.watch(mealCaloriesAddedProvider);

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

    final double currentWeight = progress.weightLogs.isNotEmpty
        ? progress.weightLogs.first.weightKg
        : (healthProfile.weightKg > 0 ? healthProfile.weightKg : 67.2)
              .toDouble();
    final double targetWeight =
        (healthProfile.targetWeightKg > 0 ? healthProfile.targetWeightKg : 68.0)
            .toDouble();
    final double bmi = (healthProfile.bmi > 0 ? healthProfile.bmi : 23.73)
        .toDouble();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            // 1. User Header: Greeting & Name on left, Bell & Avatar on right
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
                          color: AppColors.textSecondary,
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
                    backgroundColor: AppColors.surfaceNested,
                    child: Text(
                      userInitial,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 2. Weekly Progress Card (Tiến độ trong tuần)
            WeeklyProgressCard(
              completedWorkouts: progress.completedWorkoutsThisWeek,
              targetWorkouts: progress.targetWorkoutsPerWeek,
              streakDays: progress.currentStreakDays,
              onTap: () => context.push('/progress'),
            ),
            const SizedBox(height: 16),

            // 3. Hero Workout Card or Empty State
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

            // 4. Weight Trend (Xu hướng cân nặng 30 ngày & Cập nhật cân nặng)
            _DashboardWeightTrendCard(
              currentWeightKg: currentWeight,
              targetWeightKg: targetWeight,
              bmi: bmi,
              weightLogs: progress.weightLogs,
              onLogWeight: () => _showLogWeightDialog(context, ref),
            ),
            const SizedBox(height: 20),

            // 5. Today's Nutrition & Recovery Metrics Overview
            const Text(
              'Chỉ số dinh dưỡng & Phục hồi',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
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
                    color: AppColors.nutritionCalories,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: _MetricCard(
                    icon: Icons.monitor_heart_outlined,
                    label: 'Phục hồi',
                    value: '88%',
                    unit: 'Sẵn sàng tập luyện',
                    color: AppColors.cyan,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 6. AI Coach Banner
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
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.aiVioletSoft,
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: AppColors.aiViolet,
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

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard Weight Trend Card (30-Day Trend + Quick Log Action)
// ─────────────────────────────────────────────────────────────────────────────
class _DashboardWeightTrendCard extends StatelessWidget {
  const _DashboardWeightTrendCard({
    required this.currentWeightKg,
    required this.targetWeightKg,
    required this.bmi,
    required this.weightLogs,
    required this.onLogWeight,
  });

  final double currentWeightKg;
  final double targetWeightKg;
  final double bmi;
  final List<WeightLogItem> weightLogs;
  final VoidCallback onLogWeight;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    String changeText = '0.0 kg';
    if (weightLogs.length >= 2) {
      final diff = currentWeightKg - weightLogs.last.weightKg;
      if (diff < 0) {
        changeText = '↓ ${(-diff).toStringAsFixed(1)} kg';
      } else if (diff > 0) {
        changeText = '↑ ${diff.toStringAsFixed(1)} kg';
      }
    } else {
      changeText = '↓ 1.3 kg';
    }

    final dateStart = weightLogs.isNotEmpty ? weightLogs.last.date : '01/08';
    final dateEnd = weightLogs.isNotEmpty ? weightLogs.first.date : 'Hôm nay';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icon, Title, Metric, and Quick Action Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.cyan.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.trending_down_rounded,
                      size: 17,
                      color: AppColors.cyan,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'XU HƯỚNG CÂN NẶNG (30 NGÀY)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: colors.onSurfaceVariant,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            '${currentWeightKg.toStringAsFixed(1)} kg',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'BMI: ${bmi.toStringAsFixed(1)}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              // Action Button "Cập nhật cân nặng"
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: onLogWeight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.cyan.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, size: 14, color: AppColors.cyan),
                      SizedBox(width: 3),
                      Text(
                        'Cập nhật',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.cyan,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Difference Badge & Subtitle
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 3.5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  changeText,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: AppColors.success,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'So với 30 ngày trước',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Line Chart with custom painter
          if (weightLogs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      'Chưa có dữ liệu cân nặng.',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    FilledButton.tonal(
                      onPressed: onLogWeight,
                      child: const Text('Cập nhật cân nặng hôm nay'),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            SizedBox(
              height: 120,
              width: double.infinity,
              child: CustomPaint(
                painter: _DashboardWeightLineChartPainter(
                  logs: weightLogs,
                  targetWeight: targetWeightKg,
                  lineColor: AppColors.cyan,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Date Range & Target Label
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateStart,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                Text(
                  'Mục tiêu: ${targetWeightKg.toStringAsFixed(0)} kg',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.cyan,
                  ),
                ),
                Text(
                  dateEnd,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DashboardWeightLineChartPainter extends CustomPainter {
  _DashboardWeightLineChartPainter({
    required this.logs,
    required this.targetWeight,
    required this.lineColor,
  });

  final List<WeightLogItem> logs;
  final double targetWeight;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (logs.isEmpty) return;

    final chronologicalLogs = logs.reversed.toList();
    final weights = chronologicalLogs.map((l) => l.weightKg).toList();

    double minW = targetWeight > 0
        ? math.min(targetWeight - 1.0, weights.reduce(math.min) - 1.0)
        : weights.reduce(math.min) - 1.0;
    double maxW = weights.reduce(math.max) + 1.0;
    if (targetWeight > maxW) maxW = targetWeight + 1.0;
    if (minW >= maxW) {
      minW -= 2.0;
      maxW += 2.0;
    }
    final range = maxW - minW;

    final points = <Offset>[];
    final stepX = weights.length > 1
        ? size.width / (weights.length - 1)
        : size.width / 2;

    for (int i = 0; i < weights.length; i++) {
      final x = weights.length > 1 ? i * stepX : size.width / 2;
      final yRatio = 1.0 - ((weights[i] - minW) / range).clamp(0.0, 1.0);
      final y = yRatio * (size.height - 24) + 12;
      points.add(Offset(x, y));
    }

    // Draw Target Dashed Line
    final targetYRatio = 1.0 - ((targetWeight - minW) / range).clamp(0.0, 1.0);
    final targetY = targetYRatio * (size.height - 24) + 12;

    final targetPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.35)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, targetY),
        Offset(math.min(startX + 6, size.width), targetY),
        targetPaint,
      );
      startX += 10;
    }

    // Draw Gradient Area under Line
    final fillPath = Path()..moveTo(points.first.dx, size.height);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          lineColor.withValues(alpha: 0.22),
          lineColor.withValues(alpha: 0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // Draw Line Chart
    if (points.length > 1) {
      final linePath = Path()..moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        final p0 = points[i - 1];
        final p1 = points[i];
        final cx = (p0.dx + p1.dx) / 2;
        linePath.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
      }

      final linePaint = Paint()
        ..color = lineColor
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(linePath, linePaint);
    }

    // Draw Dots on points
    final dotPaint = Paint()..color = Colors.white;
    final dotRingPaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (final p in points) {
      canvas.drawCircle(p, 3.5, dotPaint);
      canvas.drawCircle(p, 3.5, dotRingPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero Workout Card
// ─────────────────────────────────────────────────────────────────────────────
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 340;
        final cardWidth = isNarrow ? 90.0 : 110.0;
        final cardHeight = isNarrow ? 126.0 : 154.0;

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
                              Flexible(
                                child: Text(
                                  'BUỔI TẬP HÔM NAY',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: colors.onSurfaceVariant.withValues(
                                      alpha: 0.8,
                                    ),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                  ),
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
                                .map(
                                  (m) => _MuscleBadge(label: m, isMuted: true),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Opacity(
                      opacity: 0.65,
                      child: FlippableMuscleCard(
                        targetMuscles: targetMuscles,
                        width: cardWidth,
                        height: cardHeight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Text(
                        'Đã hoàn thành hôm nay ✓',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.accentEmerald,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
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
                          color: AppColors.accentEmerald.withValues(
                            alpha: 0.12,
                          ),
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
            gradient: const LinearGradient(
              colors: [AppColors.primarySurface, AppColors.surface],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: AppColors.primaryBorder, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
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
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Flexible(
                              child: Text(
                                'BUỔI TẬP HÔM NAY',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$completedSets/$totalSets hiệp đã hoàn thành',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
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
                  FlippableMuscleCard(
                    targetMuscles: targetMuscles,
                    width: cardWidth,
                    height: cardHeight,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onStart,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
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
      },
    );
  }
}

class _MuscleBadge extends StatelessWidget {
  const _MuscleBadge({required this.label, this.isMuted = false});
  final String label;
  final bool isMuted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceNested,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderDefault, width: 0.8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w700,
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
          Text(
            unit,
            style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
          ),
        ],
      ),
    );

    return Card(margin: EdgeInsets.zero, child: cardContent);
  }
}
