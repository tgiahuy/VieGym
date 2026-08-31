import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
  Widget build(BuildContext context) {
    final state = ref.watch(progressProvider);
    final scheduleState = ref.watch(workoutScheduleProvider);
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
      body: ListView(
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
          ),
          const SizedBox(height: 18),

          // 3. Progressive Overload & Volume Analysis
          _VolumeProgressionCard(
            totalVolumeKg: state.totalVolumeKg,
            timeframeIndex: _selectedTimeframe,
          ),
          const SizedBox(height: 18),

          // 4. Muscle Recovery & Sets Volume Matrix (Khác biệt hoàn toàn với trang Cá nhân)
          const _MuscleRecoveryMatrixCard(),
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
  });

  final int completedWorkouts;
  final int targetWorkouts;
  final int streakDays;
  final int totalMinutes;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final ratio = targetWorkouts == 0
        ? 0.0
        : (completedWorkouts / targetWorkouts).clamp(0.0, 1.0);
    final percent = (ratio * 100).round();

    final days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final completedDays = [true, false, true, false, true, false, false];

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
                        color: Colors.grey,
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
              color: const Color(0xFF161922),
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
              color: const Color(0xFF161922),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (i) {
                final isDone = completedDays[i];
                final isToday = i == 4; // T6
                return Column(
                  children: [
                    Text(
                      days[i],
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: isToday ? colors.primary : Colors.grey,
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
  });

  final double totalVolumeKg;
  final int timeframeIndex;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final volumeBreakdown = [
      ('Đẩy (Push: Ngực, Vai, Tay sau)', 8500, const Color(0xFFFF2E54)),
      ('Kéo (Pull: Lưng xô, Tay trước)', 9200, const Color(0xFFFF5277)),
      ('Chân & Mông (Legs & Glutes)', 10800, const Color(0xFFFF7A00)),
    ];

    final displayTotal = totalVolumeKg.toInt();

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
                        color: Colors.grey,
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
                  color: Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '+12.4% TĂNG',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.greenAccent,
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
              color: const Color(0xFF161922),
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
                        style: TextStyle(fontSize: 10, color: Colors.grey),
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
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '7.125 kg/buổi',
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
              color: Colors.grey,
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
  const _MuscleRecoveryMatrixCard();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final matrixData = [
      (
        'Chân & Mông (Quads, Glutes)',
        22,
        '10.800 kg',
        'Hồi phục 70%',
        Colors.orangeAccent,
        Icons.directions_walk_rounded,
      ),
      (
        'Ngực & Tay trước (Chest & Biceps)',
        16,
        '8.500 kg',
        'Sẵn sàng (100%)',
        Colors.greenAccent,
        Icons.fitness_center_rounded,
      ),
      (
        'Lưng xô (Lats & Back)',
        18,
        '9.200 kg',
        'Sẵn sàng (95%)',
        Colors.greenAccent,
        Icons.accessibility_new_rounded,
      ),
      (
        'Vai & Cầu vai (Shoulders & Traps)',
        12,
        '4.200 kg',
        'Sẵn sàng (100%)',
        Colors.greenAccent,
        Icons.bolt_rounded,
      ),
      (
        'Core & Bụng (Abs & Obliques)',
        8,
        'Tập tự do',
        'Sẵn sàng (100%)',
        Colors.greenAccent,
        Icons.local_fire_department_rounded,
      ),
    ];

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
                        color: Colors.grey,
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
                color: const Color(0xFF161922),
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
                        color: Colors.grey,
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
              style: TextStyle(fontSize: 12, color: Colors.grey),
            )
          else
            ...personalRecords.take(3).map((pr) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF161922),
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
                color: Colors.grey,
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
                style: TextStyle(fontSize: 12, color: Colors.grey),
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
