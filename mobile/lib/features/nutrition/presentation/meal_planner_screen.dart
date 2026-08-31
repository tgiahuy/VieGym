import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../application/nutrition_controller.dart';
import '../domain/food_models.dart';

class MealPlannerScreen extends ConsumerStatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  ConsumerState<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends ConsumerState<MealPlannerScreen> {
  static DateTime _getMondayOfCurrentWeek(DateTime d) {
    return DateTime(
      d.year,
      d.month,
      d.day,
    ).subtract(Duration(days: d.weekday - 1));
  }

  static const int _initialPageIndex = 500;
  late final DateTime _baseMonday;
  late int _currentPage;
  late final PageController _pageController;

  static String _formatDate(DateTime d) {
    final year = d.year;
    final month = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  @override
  void initState() {
    super.initState();
    _baseMonday = _getMondayOfCurrentWeek(DateTime.now());
    _currentPage = _initialPageIndex;
    _pageController = PageController(initialPage: _initialPageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTapToday() {
    HapticFeedback.lightImpact();
    final now = DateTime.now();
    final todayStr = _formatDate(now);
    ref.read(nutritionProvider.notifier).selectDate(todayStr);

    final nowMonday = _getMondayOfCurrentWeek(now);
    final weekOffset = (nowMonday.difference(_baseMonday).inDays / 7).round();
    final targetPage = _initialPageIndex + weekOffset;

    if (_pageController.hasClients) {
      _pageController.animateToPage(
        targetPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(nutritionProvider);
    final notifier = ref.read(nutritionProvider.notifier);
    final colors = Theme.of(context).colorScheme;

    final selectedDateStr = state.selectedDate;
    final dateEntries = state.currentDayEntries;

    final plannedCalories = dateEntries.fold(0, (sum, e) => sum + e.calories);
    final plannedProtein = dateEntries.fold(0.0, (sum, e) => sum + e.protein);
    final plannedCarbs = dateEntries.fold(0.0, (sum, e) => sum + e.carbs);
    final plannedFat = dateEntries.fold(0.0, (sum, e) => sum + e.fat);

    final targetCal = state.targetCalories;
    final ratio = targetCal > 0
        ? (plannedCalories / targetCal).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Kế hoạch bữa ăn'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          // 1. Weekly Date Selector Card with horizontal swipe & "Hôm nay" button
          _WeeklyDateSelector(
            baseMonday: _baseMonday,
            pageController: _pageController,
            currentPage: _currentPage,
            initialPageIndex: _initialPageIndex,
            selectedDateStr: selectedDateStr,
            allEntries: state.entries,
            onTapToday: _onTapToday,
            onPageChanged: (page) => setState(() => _currentPage = page),
            onSelectDate: (dateStr) {
              ref.read(nutritionProvider.notifier).selectDate(dateStr);
            },
          ),
          const SizedBox(height: 14),

          // 2. Plan Nutrition Summary Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TỔNG KẾ HOẠCH NGÀY',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: colors.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      '$plannedCalories / $targetCal kcal',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 6,
                    backgroundColor: colors.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(colors.primary),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _macroTag(
                      'Protein',
                      plannedProtein,
                      state.targetProtein,
                      AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    _macroTag(
                      'Carb',
                      plannedCarbs,
                      state.targetCarbs,
                      const Color(0xFF38BDF8),
                    ),
                    const SizedBox(width: 8),
                    _macroTag(
                      'Fat',
                      plannedFat,
                      state.targetFat,
                      const Color(0xFFFBBF24),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 3. 4 Meal Sections (Sáng, Trưa, Tối, Phụ)
          ...MealType.values.map((meal) {
            final mealEntries = dateEntries
                .where((e) => e.mealType == meal)
                .toList();
            final mealCalories = mealEntries.fold(
              0,
              (sum, e) => sum + e.calories,
            );

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.6),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            meal.label,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            meal.timeRange,
                            style: TextStyle(
                              fontSize: 11,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '$mealCalories kcal',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: mealCalories > 0
                              ? colors.primary
                              : colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (mealEntries.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        'Chưa có món nào trong kế hoạch.',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    )
                  else
                    ...mealEntries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colors.outlineVariant.withValues(
                                alpha: 0.3,
                              ),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Food Thumbnail Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  color: colors.surfaceContainerHighest,
                                  child: Image.network(
                                    entry.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                          Icons.restaurant_rounded,
                                          size: 20,
                                          color: colors.onSurfaceVariant,
                                        ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Food Information
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${entry.calories} kcal • P: ${entry.protein.toStringAsFixed(0)}g • C: ${entry.carbs.toStringAsFixed(0)}g • F: ${entry.fat.toStringAsFixed(0)}g',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                icon: Icon(
                                  Icons.close_rounded,
                                  size: 16,
                                  color: colors.onSurfaceVariant,
                                ),
                                onPressed: () =>
                                    notifier.removeFoodEntry(entry.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      ref
                          .read(nutritionProvider.notifier)
                          .selectDate(selectedDateStr);
                      context.push('/meal/search?mealType=${meal.code}');
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 38),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: Text('Thêm món vào ${meal.label}'),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _macroTag(String name, double val, double target, Color col) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: col.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: col.withValues(alpha: 0.3), width: 0.8),
        ),
        child: Column(
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: col,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${val.toStringAsFixed(0)}/${target.toStringAsFixed(0)}g',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Weekly Date Selector with Horizontal Swipe & "Hôm nay" Button
// ─────────────────────────────────────────────────────────────────────────────
class _WeeklyDateSelector extends StatelessWidget {
  const _WeeklyDateSelector({
    required this.baseMonday,
    required this.pageController,
    required this.currentPage,
    required this.initialPageIndex,
    required this.selectedDateStr,
    required this.allEntries,
    required this.onTapToday,
    required this.onPageChanged,
    required this.onSelectDate,
  });

  final DateTime baseMonday;
  final PageController pageController;
  final int currentPage;
  final int initialPageIndex;
  final String selectedDateStr;
  final List<FoodEntry> allEntries;
  final VoidCallback onTapToday;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<String> onSelectDate;

  static String _formatDate(DateTime d) {
    final year = d.year;
    final month = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static String _formatDateLabel(DateTime date) {
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    if (isToday) {
      return 'Hôm nay, ${date.day} Tháng ${date.month}';
    }
    const dayNames = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final name = dayNames[date.weekday - 1];
    return '$name, ${date.day} Tháng ${date.month}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    DateTime selectedDateTime;
    try {
      final parts = selectedDateStr.split('-');
      selectedDateTime = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    } catch (_) {
      selectedDateTime = DateTime.now();
    }

    final headerLabel = _formatDateLabel(selectedDateTime);

    final now = DateTime.now();
    final todayStr = _formatDate(now);
    final isSelectedToday = selectedDateStr == todayStr;

    const dayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Top Row: [calendar icon] Date label            [ Hôm nay ]
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      headerLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // "Hôm nay" secondary compact button
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: onTapToday,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelectedToday
                        ? colors.surfaceContainerHigh
                        : colors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelectedToday
                          ? colors.outlineVariant.withValues(alpha: 0.5)
                          : colors.primary.withValues(alpha: 0.4),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.today_rounded,
                        size: 13,
                        color: isSelectedToday
                            ? colors.onSurfaceVariant
                            : colors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Hôm nay',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: isSelectedToday
                              ? colors.onSurfaceVariant
                              : colors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Horizontal Swipe PageView for 7-day strip
          SizedBox(
            height: 70,
            child: PageView.builder(
              controller: pageController,
              onPageChanged: onPageChanged,
              itemBuilder: (context, pageIndex) {
                final weekOffset = pageIndex - initialPageIndex;
                final weekStart = baseMonday.add(
                  Duration(days: weekOffset * 7),
                );
                final weekDays = List.generate(7, (i) {
                  return weekStart.add(Duration(days: i));
                });

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (index) {
                    final dayDate = weekDays[index];
                    final dateStr = _formatDate(dayDate);
                    final isSelected = dateStr == selectedDateStr;
                    final hasLogs = allEntries.any((e) => e.date == dateStr);

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => onSelectDate(dateStr),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colors.primary
                                  : (hasLogs
                                        ? colors.surfaceContainerHigh
                                        : Colors.transparent),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? colors.primary
                                    : (hasLogs
                                          ? colors.primary.withValues(
                                              alpha: 0.3,
                                            )
                                          : Colors.transparent),
                                width: 1.2,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  dayLabels[index],
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? Colors.white
                                        : colors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${dayDate.day}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: isSelected
                                        ? Colors.white
                                        : colors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: hasLogs
                                        ? (isSelected
                                              ? Colors.white
                                              : colors.primary)
                                        : Colors.transparent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
