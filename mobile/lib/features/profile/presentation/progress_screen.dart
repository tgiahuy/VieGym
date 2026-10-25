import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../workout/application/workout_schedule_controller.dart';
import '../../workout/domain/workout_models.dart';
import '../application/progress_controller.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  int _selectedTimeframe = 0; // 0 = Tuần này, 1 = Tháng này, 2 = 3 tháng qua

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(progressProvider.notifier).fetchAllProgressData();
      ref.read(workoutScheduleProvider.notifier).syncCurrentPeriod();
    });
  }

  static DateTime? _parseWorkoutDate(String dateStr) {
    final direct = DateTime.tryParse(dateStr);
    if (direct != null) return DateTime(direct.year, direct.month, direct.day);
    final parts = dateStr.split('/');
    if (parts.length == 3) {
      final d = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final y = int.tryParse(parts[2]);
      if (d != null && m != null && y != null) {
        return DateTime(y, m, d);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(progressProvider);
    final scheduleState = ref.watch(workoutScheduleProvider);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Compute dynamic timeframe bounds
    DateTime timeframeStart;
    DateTime timeframeEnd = today.add(const Duration(days: 1));
    DateTime prevTimeframeStart;
    DateTime prevTimeframeEnd;

    final currentMonday = today.subtract(Duration(days: now.weekday - 1));
    if (_selectedTimeframe == 0) {
      // Tuần này (Thứ 2 đến Chủ nhật)
      timeframeStart = currentMonday;
      timeframeEnd = currentMonday.add(const Duration(days: 7));
      prevTimeframeStart = currentMonday.subtract(const Duration(days: 7));
      prevTimeframeEnd = currentMonday;
    } else if (_selectedTimeframe == 1) {
      // Tháng này
      timeframeStart = DateTime(now.year, now.month, 1);
      timeframeEnd = DateTime(now.year, now.month + 1, 1);
      prevTimeframeStart = DateTime(now.year, now.month - 1, 1);
      prevTimeframeEnd = timeframeStart;
    } else {
      // 3 tháng qua (90 ngày)
      timeframeStart = today.subtract(const Duration(days: 90));
      timeframeEnd = today.add(const Duration(days: 1));
      prevTimeframeStart = today.subtract(const Duration(days: 180));
      prevTimeframeEnd = timeframeStart;
    }

    final allHistory = scheduleState.history;

    // Filter workouts in timeframe
    final timeframeHistory = allHistory.where((h) {
      final d = _parseWorkoutDate(h.date);
      if (d == null) return false;
      return !d.isBefore(timeframeStart) && d.isBefore(timeframeEnd);
    }).toList();

    final prevTimeframeHistory = allHistory.where((h) {
      final d = _parseWorkoutDate(h.date);
      if (d == null) return false;
      return !d.isBefore(prevTimeframeStart) && d.isBefore(prevTimeframeEnd);
    }).toList();

    final tfVolume = timeframeHistory.fold<double>(
      0.0,
      (sum, h) => sum + h.totalVolumeKg,
    );
    final prevVolume = prevTimeframeHistory.fold<double>(
      0.0,
      (sum, h) => sum + h.totalVolumeKg,
    );

    final effectiveTotalVolume = (_selectedTimeframe == 0 && tfVolume == 0)
        ? state.totalVolumeKg
        : tfVolume;

    double dynamicGrowth = 0.0;
    if (prevVolume > 0) {
      dynamicGrowth = ((effectiveTotalVolume - prevVolume) / prevVolume) * 100.0;
    } else if (effectiveTotalVolume > 0) {
      dynamicGrowth = 100.0;
    } else if (_selectedTimeframe == 0) {
      dynamicGrowth = state.growthRatePercentage;
    }

    final completedWorkoutsCount = timeframeHistory.isNotEmpty
        ? timeframeHistory.length
        : (_selectedTimeframe == 0 ? state.completedWorkoutsThisWeek : 0);

    // Compute Push / Pull / Legs Volume dynamically
    double pushVolume = 0.0;
    double pullVolume = 0.0;
    double legsVolume = 0.0;

    for (final h in timeframeHistory) {
      if (h.exercises.isNotEmpty) {
        for (final ex in h.exercises) {
          final t = '${ex.exerciseName} ${ex.primaryMuscle} ${ex.secondaryMuscles.join(' ')}'.toLowerCase();
          final v = ex.volumeKg > 0
              ? ex.volumeKg
              : ex.sets.fold<double>(0.0, (s, st) => s + (st.weightKg * st.reps));

          if (t.contains('ngực') || t.contains('chest') || t.contains('vai') ||
              t.contains('shoulder') || t.contains('tricep') || t.contains('tay sau') ||
              t.contains('bench') || t.contains('press') || t.contains('dip')) {
            pushVolume += v;
          } else if (t.contains('lưng') || t.contains('back') || t.contains('lat') ||
                     t.contains('xô') || t.contains('bicep') || t.contains('tay trước') ||
                     t.contains('pull') || t.contains('row') || t.contains('curl')) {
            pullVolume += v;
          } else {
            legsVolume += v;
          }
        }
      } else {
        final t = '${h.workoutName} ${h.targetMuscles.join(' ')}'.toLowerCase();
        if (t.contains('push') || t.contains('đẩy') || t.contains('ngực') || t.contains('vai')) {
          pushVolume += h.totalVolumeKg;
        } else if (t.contains('pull') || t.contains('kéo') || t.contains('lưng') || t.contains('tay')) {
          pullVolume += h.totalVolumeKg;
        } else {
          legsVolume += h.totalVolumeKg;
        }
      }
    }

    // 7-day Completed Check-in
    final completedDays = List.generate(7, (i) {
      final day = currentMonday.add(Duration(days: i));
      final hasHistory = allHistory.any((h) {
        final d = _parseWorkoutDate(h.date);
        return d != null && d.year == day.year && d.month == day.month && d.day == day.day;
      });
      final hasDailyVolume = state.dailyVolumes.any(
        (v) => v.weekday == (i + 1) && v.volumeKg > 0,
      );
      final hasSchedule = scheduleState.schedules.any((s) {
        final d = _parseWorkoutDate(s.date);
        return d != null &&
            d.year == day.year &&
            d.month == day.month &&
            d.day == day.day &&
            s.status == ScheduleStatus.completed;
      });
      return hasHistory || hasDailyVolume || hasSchedule;
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text(
          'Tiến độ & Phân tích',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: 'Kỷ lục cá nhân (PR)',
            onPressed: () => context.push('/profile/records'),
            icon: const Icon(Icons.emoji_events_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ref.read(progressProvider.notifier).fetchAllProgressData(),
            ref.read(workoutScheduleProvider.notifier).syncCurrentPeriod(),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          children: [
            // 1. Timeframe Filter Selector
            _TimeframeSelector(
              selectedIndex: _selectedTimeframe,
              onChanged: (index) => setState(() => _selectedTimeframe = index),
            ),
            const SizedBox(height: 16),

            // 2. Training Consistency & Adherence Hero Card
            _ConsistencyHeroCard(
              completedWorkouts: state.completedWorkoutsThisWeek,
              targetWorkouts: state.targetWorkoutsPerWeek,
              streakDays: state.currentStreakDays,
              totalMinutes: state.totalWorkoutMinutes,
              completedDays: completedDays,
            ),
            const SizedBox(height: 18),

            // 3. Progressive Overload & Volume Analysis
            _VolumeProgressionCard(
              totalVolumeKg: effectiveTotalVolume,
              timeframeIndex: _selectedTimeframe,
              growthRate: dynamicGrowth,
              completedWorkouts: completedWorkoutsCount,
              pushVolume: pushVolume,
              pullVolume: pullVolume,
              legsVolume: legsVolume,
            ),
            const SizedBox(height: 18),

            // 4. Muscle Recovery & Sets Volume Matrix
            _MuscleRecoveryMatrixCard(
              history: allHistory,
              now: now,
            ),
            const SizedBox(height: 18),

            // 5. Strength Progression & PR Highlights
            _StrengthProgressionCard(
              personalRecords: state.personalRecords,
              onViewAllPRs: () => context.push('/profile/records'),
            ),
            const SizedBox(height: 18),

            // 6. Recent Workout Activity Log
            _WorkoutActivitySection(
              history: scheduleState.history,
              onViewAllHistory: () => context.push('/workout/history'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. Timeframe Selector
// ─────────────────────────────────────────────────────────────────────────────
class _TimeframeSelector extends StatelessWidget {
  const _TimeframeSelector({
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final options = ['Tuần này', 'Tháng này', '3 tháng qua'];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: List.generate(options.length, (i) {
          final isSelected = selectedIndex == i;
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? colors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  options[i],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : colors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. Training Consistency & Adherence Hero Card
// ─────────────────────────────────────────────────────────────────────────────
class _ConsistencyHeroCard extends StatelessWidget {
  const _ConsistencyHeroCard({
    required this.completedWorkouts,
    required this.targetWorkouts,
    required this.streakDays,
    required this.totalMinutes,
    required this.completedDays,
  });

  final int completedWorkouts;
  final int targetWorkouts;
  final int streakDays;
  final int totalMinutes;
  final List<bool> completedDays;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final ratio = targetWorkouts == 0
        ? 0.0
        : (completedWorkouts / targetWorkouts).clamp(0.0, 1.0);
    final percent = (ratio * 100).round();

    final days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final effectiveCompletedDays = completedDays.length == 7
        ? completedDays
        : [false, false, false, false, false, false, false];

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
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.track_changes_rounded,
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
                      'TỶ LỆ HOÀN THÀNH MỤC TIÊU',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: AppColors.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 1),
                    Text(
                      'Kỷ luật & Tính kiên trì',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 11)),
                    const SizedBox(width: 3),
                    Text(
                      '$streakDays ngày',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Main Stats Row with clean, beautifully rendered Gauge
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // Clean Circular Progress Gauge (72x72)
                SizedBox(
                  width: 72,
                  height: 72,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: ratio,
                        strokeWidth: 6.5,
                        backgroundColor: colors.outlineVariant.withValues(
                          alpha: 0.25,
                        ),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colors.primary,
                        ),
                        strokeCap: StrokeCap.round,
                      ),
                      Text(
                        '$percent%',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                // Breakdown Summary Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Đã hoàn thành $completedWorkouts/$targetWorkouts buổi tập',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tổng thời lượng: $totalMinutes phút tập luyện chất lượng cao.',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: colors.onSurfaceVariant,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 7-day Check-in Dots
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (i) {
                final isDone = effectiveCompletedDays[i];
                final isToday = (i + 1 == DateTime.now().weekday);
                return Column(
                  children: [
                    Text(
                      days[i],
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: isToday
                            ? colors.primary
                            : AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone
                            ? colors.primary
                            : (isToday
                                  ? colors.primary.withValues(alpha: 0.2)
                                  : colors.surfaceContainer),
                        border: isToday
                            ? Border.all(color: colors.primary, width: 1.2)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: isDone
                          ? const Icon(
                              Icons.check_rounded,
                              size: 15,
                              color: Colors.white,
                            )
                          : (isToday
                                ? Text(
                                    '•',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: colors.primary,
                                    ),
                                  )
                                : null),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. Progressive Overload & Volume Analysis
// ─────────────────────────────────────────────────────────────────────────────
class _VolumeProgressionCard extends StatelessWidget {
  const _VolumeProgressionCard({
    required this.totalVolumeKg,
    required this.timeframeIndex,
    required this.growthRate,
    required this.completedWorkouts,
    required this.pushVolume,
    required this.pullVolume,
    required this.legsVolume,
  });

  final double totalVolumeKg;
  final int timeframeIndex;
  final double growthRate;
  final int completedWorkouts;
  final double pushVolume;
  final double pullVolume;
  final double legsVolume;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final totalCategorized = pushVolume + pullVolume + legsVolume;
    final double displayPush = totalCategorized > 0
        ? pushVolume
        : (totalVolumeKg > 0 ? totalVolumeKg * 0.35 : 0.0);
    final double displayPull = totalCategorized > 0
        ? pullVolume
        : (totalVolumeKg > 0 ? totalVolumeKg * 0.35 : 0.0);
    final double displayLegs = totalCategorized > 0
        ? legsVolume
        : (totalVolumeKg > 0 ? totalVolumeKg * 0.30 : 0.0);

    final volumeBreakdown = [
      ('Đẩy (Push: Ngực, Vai, Tay sau)', displayPush.round(), AppColors.chartPrimary),
      ('Kéo (Pull: Lưng xô, Tay trước)', displayPull.round(), AppColors.chartBlue),
      ('Chân & Mông (Legs & Glutes)', displayLegs.round(), AppColors.chartCyan),
    ];

    final displayTotal = totalVolumeKg.toInt();
    final avgPerWorkout =
        completedWorkouts > 0 ? (totalVolumeKg / completedWorkouts).round() : 0;

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  size: 18,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KHỐI LƯỢNG TẢI TRỌNG (VOLUME LOAD)',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: AppColors.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 1),
                    Text(
                      'Phân tích Progressive Overload',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: growthRate >= 0
                      ? Colors.green.withValues(alpha: 0.15)
                      : Colors.red.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  growthRate > 0
                      ? '+${growthRate.toStringAsFixed(1)}% TĂNG'
                      : (growthRate < 0
                          ? '${growthRate.toStringAsFixed(1)}% GIẢM'
                          : '0.0% DUY TRÌ'),
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: growthRate >= 0
                        ? Colors.greenAccent
                        : Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Total Volume Highlight Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TỔNG KHỐI LƯỢNG NÂNG',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${(totalVolumeKg / 1000).toStringAsFixed(1)} tấn (${displayTotal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} kg)',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'TRUNG BÌNH BUỔI',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${avgPerWorkout.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} kg/buổi',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Category Volume Breakdown Progress Bars
          const Text(
            'PHÂN BỔ TẢI THEO NHÓM BÀI CHÍNH:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 10),

          ...volumeBreakdown.map((item) {
            final (name, vol, barColor) = item;
            final pct = totalVolumeKg > 0
                ? (vol / totalVolumeKg).clamp(0.0, 1.0)
                : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(pct * 100).round()}% (${vol.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} kg)',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: barColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 6,
                      backgroundColor: colors.outlineVariant.withValues(
                        alpha: 0.25,
                      ),
                      valueColor: AlwaysStoppedAnimation<Color>(barColor),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. Muscle Recovery & Sets Volume Matrix
// ─────────────────────────────────────────────────────────────────────────────
class _MuscleRecoveryMatrixCard extends StatelessWidget {
  const _MuscleRecoveryMatrixCard({
    required this.history,
    required this.now,
  });

  final List<WorkoutHistoryItem> history;
  final DateTime now;

  static DateTime? _parseDate(String s) {
    final d = DateTime.tryParse(s);
    if (d != null) return DateTime(d.year, d.month, d.day);
    final parts = s.split('/');
    if (parts.length == 3) {
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final definitions = [
      (
        'Chân & Mông (Quads, Glutes)',
        [
          'chân',
          'leg',
          'mông',
          'glute',
          'quad',
          'hamstring',
          'calf',
          'squat',
          'deadlift',
          'lunge',
          'bắp chân',
          'đùi',
        ],
        Icons.directions_walk_rounded,
      ),
      (
        'Ngực & Tay trước (Chest & Biceps)',
        ['ngực', 'chest', 'tay trước', 'bicep', 'bench', 'curl'],
        Icons.fitness_center_rounded,
      ),
      (
        'Lưng xô (Lats & Back)',
        ['lưng', 'back', 'lat', 'xô', 'row', 'pullup', 'pulldown'],
        Icons.accessibility_new_rounded,
      ),
      (
        'Vai & Cầu vai (Shoulders & Traps)',
        ['vai', 'shoulder', 'deltoid', 'cầu vai', 'trap', 'ohp'],
        Icons.bolt_rounded,
      ),
      (
        'Core & Bụng (Abs & Obliques)',
        ['bụng', 'core', 'abs', 'oblique', 'plank', 'crunch'],
        Icons.local_fire_department_rounded,
      ),
    ];

    final matrixData = definitions.map((def) {
      final (groupName, keywords, icon) = def;
      int setsCount = 0;
      double volumeKg = 0.0;
      DateTime? latestDate;

      for (final h in history) {
        final workoutDate = _parseDate(h.date);
        bool workoutMatched = false;

        if (h.exercises.isNotEmpty) {
          for (final ex in h.exercises) {
            final t =
                '${ex.exerciseName} ${ex.primaryMuscle} ${ex.secondaryMuscles.join(' ')}'
                    .toLowerCase();
            final matches = keywords.any((k) => t.contains(k));
            if (matches) {
              workoutMatched = true;
              setsCount += ex.sets.length;
              final exVol = ex.volumeKg > 0
                  ? ex.volumeKg
                  : ex.sets.fold<double>(
                      0.0,
                      (s, st) => s + (st.weightKg * st.reps),
                    );
              volumeKg += exVol;
            }
          }
        } else {
          final t =
              '${h.workoutName} ${h.targetMuscles.join(' ')}'.toLowerCase();
          if (keywords.any((k) => t.contains(k))) {
            workoutMatched = true;
            setsCount += h.completedSetsCount > 0 ? h.completedSetsCount : 4;
            volumeKg += h.totalVolumeKg;
          }
        }

        if (workoutMatched && workoutDate != null) {
          if (latestDate == null || workoutDate.isAfter(latestDate)) {
            latestDate = workoutDate;
          }
        }
      }

      String recoveryText = 'Sẵn sàng (100%)';
      Color statusColor = Colors.greenAccent;

      if (latestDate != null) {
        final hoursElapsed = now.difference(latestDate).inHours;
        if (hoursElapsed < 24) {
          final pct = (40 + (hoursElapsed / 24.0) * 30).clamp(40, 70).round();
          recoveryText = 'Hồi phục $pct%';
          statusColor = Colors.orangeAccent;
        } else if (hoursElapsed < 48) {
          final pct = (70 + ((hoursElapsed - 24) / 24.0) * 25)
              .clamp(70, 95)
              .round();
          recoveryText = 'Hồi phục tốt ($pct%)';
          statusColor = Colors.lightGreenAccent;
        } else {
          recoveryText = 'Sẵn sàng (100%)';
          statusColor = Colors.greenAccent;
        }
      }

      String volumeDisplay;
      if (volumeKg > 0) {
        volumeDisplay =
            '${volumeKg.toInt().toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]}.")} kg';
      } else if (setsCount > 0) {
        volumeDisplay = 'Tập tự do';
      } else {
        volumeDisplay = '0 kg';
      }

      return (
        groupName,
        setsCount,
        volumeDisplay,
        recoveryText,
        statusColor,
        icon,
      );
    }).toList();

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.tealAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.monitor_heart_outlined,
                  size: 18,
                  color: Colors.tealAccent,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TẬP LUYỆN & PHỤC HỒI NHÓM CƠ',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: AppColors.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 1),
                    Text(
                      'Khối lượng hiệp tập & Trạng thái',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          ...matrixData.map((item) {
            final (name, sets, volume, recovery, statusColor, icon) = item;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 18, color: colors.onSurfaceVariant),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$sets sets hoàn thành • $volume',
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      recovery,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. Strength Progression & PR Highlights
// ─────────────────────────────────────────────────────────────────────────────
class _StrengthProgressionCard extends StatelessWidget {
  const _StrengthProgressionCard({
    required this.personalRecords,
    required this.onViewAllPRs,
  });

  final List<PersonalRecordItem> personalRecords;
  final VoidCallback onViewAllPRs;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  size: 18,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TĂNG TIẾN SỨC MẠNH (STRENGTH PR)',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: AppColors.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 1),
                    Text(
                      'Kỷ lục nâng tạ nổi bật',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onViewAllPRs,
                child: const Text('Xem tất cả', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (personalRecords.isEmpty)
            const Text(
              'Chưa có kỷ lục nào được ghi nhận.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            )
          else
            ...personalRecords.take(3).map((pr) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.fitness_center_rounded,
                        size: 18,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pr.exerciseName,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${pr.weightKg} kg × ${pr.reps} reps (1RM: ~${pr.calculated1Rm.toStringAsFixed(1)} kg)',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'PR',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 6. Recent Workout Activity Log
// ─────────────────────────────────────────────────────────────────────────────
class _WorkoutActivitySection extends StatelessWidget {
  const _WorkoutActivitySection({
    required this.history,
    required this.onViewAllHistory,
  });

  final List<WorkoutHistoryItem> history;
  final VoidCallback onViewAllHistory;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'NHẬT KÝ BUỔI TẬP GẦN ĐÂY',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                color: AppColors.textTertiary,
              ),
            ),
            TextButton(
              onPressed: onViewAllHistory,
              child: const Text('Xem lịch sử', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 6),

        if (history.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: Text(
                'Chưa có buổi tập nào hoàn thành trong tuần này.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
          )
        else
          ...history.take(3).map((item) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: colors.outlineVariant.withValues(alpha: 0.35),
                ),
              ),
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.check_circle_outline_rounded,
                    color: colors.primary,
                    size: 20,
                  ),
                ),
                title: Text(
                  item.workoutName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  '${item.date} • ${item.durationMinutes} phút • ${item.exercises.length} bài tập',
                  style: const TextStyle(fontSize: 11.5),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                onTap: onViewAllHistory,
              ),
            );
          }),
      ],
    );
  }
}
