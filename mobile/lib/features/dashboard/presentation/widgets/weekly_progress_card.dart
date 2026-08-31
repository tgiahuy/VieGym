import 'package:flutter/material.dart';

class WeeklyProgressCard extends StatelessWidget {
  const WeeklyProgressCard({
    super.key,
    required this.completedWorkouts,
    required this.targetWorkouts,
    required this.streakDays,
    required this.onTap,
  });

  final int completedWorkouts;
  final int targetWorkouts;
  final int streakDays;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final now = DateTime.now();
    // Monday is weekday 1 -> index 0; Sunday is weekday 7 -> index 6
    final todayWeekdayIndex = (now.weekday - 1) % 7;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colors.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Section title, main summary & streak badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TIẾN ĐỘ & THỐNG KÊ',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$completedWorkouts/$targetWorkouts buổi tập tuần này',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Streak badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF332014),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          size: 15,
                          color: Colors.orangeAccent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$streakDays ngày',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.orangeAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 7 Days of the Week Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  final dayLabel = days[index];
                  final isToday = index == todayWeekdayIndex;
                  final isCompleted =
                      index == 0 || index == 2; // e.g. T2, T4 completed

                  return Column(
                    children: [
                      Text(
                        dayLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isToday
                              ? FontWeight.w900
                              : FontWeight.w600,
                          color: isToday
                              ? colors.primary
                              : colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _DayIndicator(
                        isCompleted: isCompleted,
                        isToday: isToday,
                        primaryColor: colors.primary,
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayIndicator extends StatelessWidget {
  const _DayIndicator({
    required this.isCompleted,
    required this.isToday,
    required this.primaryColor,
  });

  final bool isCompleted, isToday;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    if (isCompleted) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: primaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.35),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
      );
    }

    if (isToday) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFF1E212E),
          shape: BoxShape.circle,
          border: Border.all(color: primaryColor, width: 1.5),
        ),
        child: Center(
          child: Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }

    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: Color(0xFF1B1E29),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          '•',
          style: TextStyle(
            color: Color(0xFF43495D),
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
