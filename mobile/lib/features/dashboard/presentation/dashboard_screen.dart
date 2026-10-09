import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/utils/greeting_utils.dart';
import '../../ai/application/ai_coach_controller.dart';
import '../../auth/application/auth_controller.dart';
import '../../notifications/presentation/widgets/notification_bell_button.dart';
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
    final colors = Theme.of(context).colorScheme;
    final session = ref.watch(workoutSessionProvider);
    final schedule = ref.watch(workoutScheduleProvider);
    final auth = ref.watch(authProvider);
    final healthProfile = ref.watch(healthProfileProvider);
    final progress = ref.watch(progressProvider);

    final userName = healthProfile.nickname.isNotEmpty
        ? healthProfile.nickname
        : (auth.user?.displayName ?? 'Gia Huy');
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'G';
    final greeting = getTimeBasedGreeting();
    final isTodayCompleted = ref.watch(isTodayWorkoutCompletedProvider);
    final hasTodayWorkout =
        schedule.hasTodayWorkout || isTodayCompleted;
    final todayWorkoutTitle = schedule.todayWorkout?.title;
    final displayTitle = session.title.isNotEmpty
        ? session.title
        : (todayWorkoutTitle ?? 'Upper Body A');
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

    final goalLabel = healthProfile.goal.label.split('(').first.trim();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            // ─────────────────────────────────────────────────────────────────
            // 1. User Hero Header: Greeting, Goal Badge, Notifications & Avatar
            // ─────────────────────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            '$greeting 👋',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (goalLabel.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: colors.primary.withValues(alpha: 0.25),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                goalLabel,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: colors.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
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
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colors.outlineVariant.withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 21,
                      backgroundColor: AppColors.surfaceNested,
                      child: Text(
                        userInitial,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // ─────────────────────────────────────────────────────────────────
            // 2. Weekly Progress Card (Tiến độ & Chuỗi ngày trong tuần)
            // ─────────────────────────────────────────────────────────────────
            WeeklyProgressCard(
              completedWorkouts: progress.completedWorkoutsThisWeek,
              targetWorkouts: progress.targetWorkoutsPerWeek,
              streakDays: progress.currentStreakDays,
              onTap: () => context.push('/progress'),
            ),
            const SizedBox(height: 16),

            // ─────────────────────────────────────────────────────────────────
            // 3. Hero Workout Card or Empty State
            // ─────────────────────────────────────────────────────────────────
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
                customBuildButtonLabel: 'Áp dụng giáo án có sẵn',
                onCustomBuildWorkout: () {
                  final now = DateTime.now();
                  final todayStr =
                      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
                  ref
                      .read(workoutScheduleProvider.notifier)
                      .selectDate(todayStr);
                  context.push(
                    '/workout/schedule/create?date=$todayStr&tab=personal',
                  );
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
            const SizedBox(height: 18),

            // ─────────────────────────────────────────────────────────────────
            // 4. Weight Trend Card (Xu hướng cân nặng 30 ngày & Cập nhật)
            // ─────────────────────────────────────────────────────────────────
            _DashboardWeightTrendCard(
              currentWeightKg: currentWeight,
              targetWeightKg: targetWeight,
              bmi: bmi,
              weightLogs: progress.weightLogs,
              onLogWeight: () => _showLogWeightDialog(context, ref),
            ),
            const SizedBox(height: 18),

            // ─────────────────────────────────────────────────────────────────
            // 5. AI Coach Assistant Card with Starter Prompt Chips
            // ─────────────────────────────────────────────────────────────────
            _DashboardAiCoachCard(
              onChat: () => context.push('/ai/chat'),
              onSelectPrompt: (prompt) {
                ref.read(aiCoachProvider.notifier).send(prompt);
                context.push('/ai/chat');
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. Dashboard Weight Trend Card (30-Day Trend + Quick Log Action)
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
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.45),
          width: 1.1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icon, Title, Metric, and Quick Action Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'XU HƯỚNG CÂN NẶNG (30 NGÀY)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: colors.onSurfaceVariant,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Wrap(
                      spacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          '${currentWeightKg.toStringAsFixed(1)} kg',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                        ),
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
              ),
              const SizedBox(width: 8),
              // Action Button "Cập nhật cân nặng"
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: onLogWeight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
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
                          fontSize: 11,
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
              Expanded(
                child: Text(
                  'So với 30 ngày trước',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: colors.onSurfaceVariant,
                  ),
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
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      'Mục tiêu: ${targetWeightKg.toStringAsFixed(0)} kg',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.cyan,
                      ),
                    ),
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
// 3. Hero Workout Card
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
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onStart,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(
                    completedSets > 0 ? 'Tiếp tục buổi tập' : 'Bắt đầu tập ngay',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
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

// ─────────────────────────────────────────────────────────────────────────────
// 6. AI Coach Assistant Card with Starter Prompt Chips
// ─────────────────────────────────────────────────────────────────────────────
class _DashboardAiCoachCard extends StatelessWidget {
  const _DashboardAiCoachCard({
    required this.onChat,
    required this.onSelectPrompt,
  });

  final VoidCallback onChat;
  final ValueChanged<String> onSelectPrompt;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.aiVioletBorder.withValues(alpha: 0.6),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.aiVioletSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.aiViolet,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trợ lý AI Thể hình & Dinh dưỡng',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Hỏi AI về kỹ thuật, đổi bài hoặc dinh dưỡng chuẩn gym',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
                color: AppColors.aiViolet,
                onPressed: onChat,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Starter Prompt Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PromptChip(
                label: '💡 Hướng dẫn cho người mới',
                onTap: () => onSelectPrompt('Tôi là người mới bắt đầu tập gym, hãy hướng dẫn tôi lộ trình 4 tuần đầu tiên'),
              ),
              _PromptChip(
                label: '💪 Gợi ý tăng cơ nạc',
                onTap: () => onSelectPrompt('Làm thế nào để tối ưu tăng cơ nạc mà không tích mỡ thừa?'),
              ),
              _PromptChip(
                label: '🥗 Bữa ăn sau tập',
                onTap: () => onSelectPrompt('Nên ăn gì ngay sau buổi tập gym để phục hồi cơ tốt nhất?'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PromptChip extends StatelessWidget {
  const _PromptChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.4),
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
