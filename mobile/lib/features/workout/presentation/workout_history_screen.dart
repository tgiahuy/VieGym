import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/exercise_tag_chip.dart';
import '../application/workout_schedule_controller.dart';
import '../domain/workout_models.dart';

class WorkoutHistoryScreen extends ConsumerStatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  ConsumerState<WorkoutHistoryScreen> createState() =>
      _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends ConsumerState<WorkoutHistoryScreen> {
  late DateTime _selectedMonth;
  String? _selectedDateStr;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month, 1);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _previousMonth() {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month - 1,
        1,
      );
      _selectedDateStr = null;
    });
  }

  void _nextMonth() {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
        1,
      );
      _selectedDateStr = null;
    });
  }

  void _onDateTap(String dateStr) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedDateStr == dateStr) {
        _selectedDateStr = null; // Unselect to view all for the month
      } else {
        _selectedDateStr = dateStr;
      }
    });
  }

  String _formatVolumeSummary(double volumeKg) {
    if (volumeKg >= 1000) {
      final tons = volumeKg / 1000;
      if (tons == tons.roundToDouble()) {
        return '${tons.toInt()}t';
      }
      return '${tons.toStringAsFixed(1)}t';
    }
    return '${volumeKg.toInt()} kg';
  }

  String _formatVolumeCard(double volumeKg) {
    final intVal = volumeKg.toInt();
    final buffer = StringBuffer();
    final str = intVal.toString();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return '${buffer.toString()} kg';
  }

  String _formatVietnameseDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        final date = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
        const weekdays = [
          'Thứ 2',
          'Thứ 3',
          'Thứ 4',
          'Thứ 5',
          'Thứ 6',
          'Thứ 7',
          'Chủ nhật',
        ];
        final weekday = weekdays[date.weekday - 1];
        final day = parts[2];
        final month = parts[1];
        final year = parts[0];
        return '$weekday, $day/$month/$year';
      }
    } catch (_) {}
    return dateStr;
  }

  @override
  Widget build(BuildContext context) {
    final scheduleState = ref.watch(workoutScheduleProvider);
    final allHistory = scheduleState.history;
    final colors = Theme.of(context).colorScheme;

    // Filter by selected month: YYYY-MM
    final monthPrefix =
        '${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}';
    final monthHistory = allHistory
        .where((item) => item.date.startsWith(monthPrefix))
        .toList();

    // Compute monthly statistics
    final totalWorkouts = monthHistory.length;
    final totalDurationMinutes = monthHistory.fold<int>(
      0,
      (sum, item) => sum + item.durationMinutes,
    );
    final totalVolumeKg = monthHistory.fold<double>(
      0.0,
      (sum, item) => sum + item.totalVolumeKg,
    );

    // Set of dates in selected month with completed workouts
    final completedDatesSet = monthHistory.map((item) => item.date).toSet();

    // Filter by selected date and search query
    var filteredList = monthHistory;
    if (_selectedDateStr != null) {
      filteredList = filteredList
          .where((item) => item.date == _selectedDateStr)
          .toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      filteredList = filteredList.where((item) {
        final matchWorkoutName = item.workoutName.toLowerCase().contains(query);
        final matchMuscles = item.targetMuscles.any(
          (m) => m.toLowerCase().contains(query),
        );
        final matchExercises = item.exercises.any(
          (e) =>
              e.exerciseName.toLowerCase().contains(query) ||
              e.primaryMuscle.toLowerCase().contains(query),
        );
        return matchWorkoutName || matchMuscles || matchExercises;
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Lịch sử buổi tập'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Monthly Summary Card (TỔNG BUỔI, TỔNG THỜI GIAN, TỔNG VOLUME)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: BoxDecoration(
                color: const Color(0xFF141724),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF282E44), width: 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _MonthlyMetricColumn(
                      label: 'TỔNG BUỔI',
                      value: '$totalWorkouts',
                    ),
                  ),
                  Expanded(
                    child: _MonthlyMetricColumn(
                      label: 'TỔNG THỜI\nGIAN',
                      value: '${totalDurationMinutes}p',
                    ),
                  ),
                  Expanded(
                    child: _MonthlyMetricColumn(
                      label: 'TỔNG VOLUME',
                      value: _formatVolumeSummary(totalVolumeKg),
                      valueColor: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Monthly Calendar Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF141724),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF282E44), width: 1),
              ),
              child: Column(
                children: [
                  // Month Header with arrows
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 18,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tháng ${_selectedMonth.month}, ${_selectedMonth.year}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            onPressed: _previousMonth,
                            icon: const Icon(
                              Icons.chevron_left_rounded,
                              color: Colors.white70,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            onPressed: _nextMonth,
                            icon: const Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.white70,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Weekday Header
                  const Row(
                    children: [
                      _WeekdayLabel('T2'),
                      _WeekdayLabel('T3'),
                      _WeekdayLabel('T4'),
                      _WeekdayLabel('T5'),
                      _WeekdayLabel('T6'),
                      _WeekdayLabel('T7'),
                      _WeekdayLabel('CN'),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Calendar Grid
                  _buildCalendarGrid(completedDatesSet),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Search Bar
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F121E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _searchQuery.isNotEmpty
                      ? colors.primary.withValues(alpha: 0.6)
                      : const Color(0xFF282E44),
                  width: 1.2,
                ),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 14, color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Tìm buổi tập, bài tập, nhóm cơ...',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: colors.onSurfaceVariant,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                onChanged: (val) {
                  setState(() => _searchQuery = val);
                },
              ),
            ),
            const SizedBox(height: 20),

            // 4. Workout History List Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'DANH SÁCH BUỔI TẬP (${filteredList.length})',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: colors.onSurfaceVariant,
                    letterSpacing: 0.8,
                  ),
                ),
                if (_selectedDateStr != null)
                  InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedDateStr = null);
                    },
                    child: Text(
                      'Xem cả tháng',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colors.primary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // 5. Workout History Cards / Empty State
            if (filteredList.isEmpty)
              _buildEmptyState(
                monthHistoryIsEmpty: monthHistory.isEmpty,
                hasDateFilter: _selectedDateStr != null,
                hasSearchQuery: _searchQuery.isNotEmpty,
                colors: colors,
              )
            else
              ...filteredList.map(
                (item) => _WorkoutHistoryCard(
                  item: item,
                  formattedVolume: _formatVolumeCard(item.totalVolumeKg),
                  formattedDate: _formatVietnameseDate(item.date),
                  onTap: () {
                    context.push('/workout/history/detail?id=${item.id}');
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(Set<String> completedDatesSet) {
    final year = _selectedMonth.year;
    final month = _selectedMonth.month;

    // Number of days in month
    final daysInMonth = DateUtils.getDaysInMonth(year, month);

    // Day of week for first day (Monday is 1, Sunday is 7)
    final firstDayWeekday = DateTime(year, month, 1).weekday;

    // Empty lead cells before the 1st
    final leadEmptyCells = firstDayWeekday - 1;

    // Total cells in grid
    final totalCells = leadEmptyCells + daysInMonth;
    final rowCount = (totalCells / 7).ceil();

    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    return Column(
      children: List.generate(rowCount, (rowIndex) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: List.generate(7, (colIndex) {
              final cellIndex = rowIndex * 7 + colIndex;
              final dayNumber = cellIndex - leadEmptyCells + 1;

              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const Expanded(child: SizedBox(height: 38));
              }

              final dateStr =
                  '$year-${month.toString().padLeft(2, '0')}-${dayNumber.toString().padLeft(2, '0')}';
              final hasWorkout = completedDatesSet.contains(dateStr);
              final isSelected = _selectedDateStr == dateStr;
              final isToday = dateStr == todayStr;

              return Expanded(
                child: GestureDetector(
                  onTap: () => _onDateTap(dateStr),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF252A40)
                          : isToday
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: isToday && !isSelected
                          ? Border.all(color: const Color(0xFF333A52), width: 1)
                          : isSelected
                          ? Border.all(color: const Color(0xFF434C6D), width: 1)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$dayNumber',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected || isToday
                                ? FontWeight.w900
                                : FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : hasWorkout
                                ? Colors.white
                                : Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Workout dot indicator
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: hasWorkout
                                ? const Color(0xFFFF2E54)
                                : Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState({
    required bool monthHistoryIsEmpty,
    required bool hasDateFilter,
    required bool hasSearchQuery,
    required ColorScheme colors,
  }) {
    String message = 'Chưa có buổi tập nào trong tháng này.';
    if (hasSearchQuery) {
      message = 'Không tìm thấy buổi tập phù hợp.';
    } else if (hasDateFilter) {
      message = 'Bạn chưa tập luyện vào ngày này.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF141724),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF282E44)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.fitness_center_rounded,
            size: 40,
            color: colors.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white70,
            ),
          ),
          if (hasDateFilter || hasSearchQuery) ...[
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _selectedDateStr = null;
                });
              },
              style: OutlinedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                side: const BorderSide(color: Color(0xFF333A52)),
              ),
              child: const Text('Xóa bộ lọc', style: TextStyle(fontSize: 12)),
            ),
          ],
        ],
      ),
    );
  }
}

class _MonthlyMetricColumn extends StatelessWidget {
  const _MonthlyMetricColumn({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Colors.white60,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: valueColor ?? Colors.white,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  const _WeekdayLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white54,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _WorkoutHistoryCard extends StatelessWidget {
  const _WorkoutHistoryCard({
    required this.item,
    required this.formattedVolume,
    required this.formattedDate,
    required this.onTap,
  });

  final WorkoutHistoryItem item;
  final String formattedVolume;
  final String formattedDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF141724),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF282E44), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Title + PR Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.workoutName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (item.prCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3.5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.4),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.emoji_events_rounded,
                              size: 13,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${item.prCount} PR',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),

                // Date row
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurfaceVariant,
                  ),
                ),

                // Target muscle tags
                if (item.targetMuscles.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: item.targetMuscles
                        .map((muscle) => ExerciseTagChip.muscle(label: muscle))
                        .toList(),
                  ),
                ],

                const SizedBox(height: 12),
                const Divider(color: Color(0xFF222638), height: 1),
                const SizedBox(height: 10),

                // Bottom Metrics Row: 55 phút • 4.420 kg • 12 sets • 1 PR
                Row(
                  children: [
                    _CardMetricText('${item.durationMinutes} phút'),
                    _CardMetricDot(),
                    _CardMetricText(formattedVolume),
                    _CardMetricDot(),
                    _CardMetricText('${item.completedSetsCount} sets'),
                    if (item.prCount > 0) ...[
                      _CardMetricDot(),
                      _CardMetricText(
                        '${item.prCount} PR',
                        color: Colors.amber,
                      ),
                    ],
                    const Spacer(),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: Colors.white38,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardMetricText extends StatelessWidget {
  const _CardMetricText(this.text, {this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: color ?? Colors.white70,
      ),
    );
  }
}

class _CardMetricDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        '•',
        style: TextStyle(
          fontSize: 12,
          color: Colors.white38,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
