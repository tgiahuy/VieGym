import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../ai/application/ai_coach_controller.dart';
import '../application/nutrition_controller.dart';
import '../domain/food_models.dart';

class NutritionScreen extends ConsumerStatefulWidget {
  const NutritionScreen({super.key});

  @override
  ConsumerState<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends ConsumerState<NutritionScreen> {
  static const int _initialPageIndex = 1000;
  late final PageController _pageController;
  late final DateTime _baseMonday;
  late int _currentPage;

  static DateTime _getMondayOfCurrentWeek(DateTime date) {
    final daysToSubtract = date.weekday - 1;
    final monday = date.subtract(Duration(days: daysToSubtract));
    return DateTime(monday.year, monday.month, monday.day);
  }

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
    final aiCalories = ref.watch(mealCaloriesAddedProvider);
    final colors = Theme.of(context).colorScheme;

    final consumed = state.consumedCalories + aiCalories;
    final target = state.targetCalories;
    final remaining = target - consumed;
    final caloriePercent = target > 0
        ? (consumed / target).clamp(0.0, 1.0)
        : 0.0;
    final caloriePercentInt = (caloriePercent * 100).toInt();

    // Total logged items for selected day
    final totalLoggedCount = state.currentDayEntries.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dinh dưỡng & Bữa ăn'),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              key: const Key('beginner_nutrition_tips_button'),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.surfaceNested,
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(
                    color: AppColors.borderDefault,
                    width: 0.8,
                  ),
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: const Icon(Icons.lightbulb_outline_rounded, size: 16),
              label: const Text(
                'Mẹo cho người mới',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              onPressed: () => _BeginnerNutritionTipsDialog.show(context),
            ),
          ),
        ],
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
            selectedDateStr: state.selectedDate,
            allEntries: state.entries,
            onTapToday: _onTapToday,
            onPageChanged: (page) => setState(() => _currentPage = page),
            onSelectDate: (dateStr) {
              ref.read(nutritionProvider.notifier).selectDate(dateStr);
            },
          ),
          const SizedBox(height: 14),

          // 2. Daily Energy & Nutrition Summary Card
          _DailyEnergySummaryCard(
            consumed: consumed,
            target: target,
            remaining: remaining,
            caloriePercentInt: caloriePercentInt,
            calorieRatio: caloriePercent,
            state: state,
            onAdjustGoals: () => _showGoalAdjustmentSheet(context, ref, state),
          ),
          if (state.currentDayEntries.any((entry) => entry.estimated)) ...[
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 15),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Tổng ngày có sử dụng giá trị dinh dưỡng tham khảo.',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),

          // 3. Nutrition Action Cards: Tìm kiếm, AI Thực đơn, Kế hoạch, Lịch sử
          _NutritionActionCards(
            onSearch: () => context.push('/meal/search'),
            onAiGenerate: () => context.push('/meal/generate'),
            onPlan: () => context.push('/meal/plan'),
            onHistory: () => context.push('/meal/history'),
          ),
          const SizedBox(height: 14),

          // 4. VieGym AI Nutrition Assistant Card
          const _AiNutritionAssistantCard(),
          const SizedBox(height: 20),

          // 6. Meals Section Header
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.restaurant_menu_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'CÁC BỮA ĂN TRONG NGÀY',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$totalLoggedCount món đã ghi',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 7. Meal Cards (Breakfast, Lunch, Dinner, Snack)
          ...MealType.values.map((meal) {
            final mealEntries = state.getEntriesByMeal(meal);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _MealSectionCard(
                mealType: meal,
                entries: mealEntries,
                onAddFood: () =>
                    context.push('/meal/search?mealType=${meal.code}'),
                onAiGenerate: () =>
                    context.push('/meal/generate?mealType=${meal.code}'),
                onQuickLog: () => _showQuickCalorieDialog(context, ref, meal),
                onDeleteEntry: (entry) =>
                    _confirmDeleteEntry(context, ref, entry, meal),
              ),
            );
          }),

          if (aiCalories > 0)
            Card(
              margin: const EdgeInsets.only(top: 4, bottom: 8),
              color: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppColors.aiVioletBorder),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.aiVioletSoft,
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.aiViolet,
                    size: 20,
                  ),
                ),
                title: const Text(
                  'Đề xuất từ AI Coach',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                subtitle: const Text('Đã thêm từ structured meal proposal'),
                trailing: Text(
                  '+$aiCalories kcal',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.nutritionCalories,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showQuickCalorieDialog(
    BuildContext context,
    WidgetRef ref,
    MealType meal,
  ) {
    final caloriesController = TextEditingController();
    final nameController = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        final bottomInset = MediaQuery.of(modalContext).viewInsets.bottom;
        final bottomPadding = MediaQuery.of(modalContext).padding.bottom;
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 10,
            bottom: bottomInset + bottomPadding + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.nutritionCaloriesSoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bolt_rounded,
                      color: AppColors.nutritionCalories,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Ghi nhanh calo — ${meal.label}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: caloriesController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Lượng calo (kcal) *',
                  hintText: 'Ví dụ: 350',
                  suffixText: 'kcal',
                  prefixIcon: Icon(Icons.local_fire_department_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên món hoặc ghi chú (không bắt buộc)',
                  hintText: 'Ví dụ: Cơm trưa ngoài hàng, Bánh tráng...',
                  prefixIcon: Icon(Icons.edit_note_rounded),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(modalContext),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        final cal = int.tryParse(
                          caloriesController.text.trim(),
                        );
                        if (cal == null || cal <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Vui lòng nhập lượng calo hợp lệ'),
                            ),
                          );
                          return;
                        }
                        ref
                            .read(nutritionProvider.notifier)
                            .addQuickCalories(
                              mealType: meal,
                              calories: cal,
                              name: nameController.text.trim(),
                            );
                        Navigator.pop(modalContext);
                      },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Lưu'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteEntry(
    BuildContext context,
    WidgetRef ref,
    FoodEntry entry,
    MealType meal,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final colors = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          icon: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors.error.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.delete_outline_rounded,
              color: colors.error,
              size: 24,
            ),
          ),
          title: const Text(
            'Xóa món ăn?',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
          content: Text(
            'Bạn có chắc muốn xóa "${entry.name}" (${entry.calories} kcal) khỏi ${meal.label.toLowerCase()} không?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5, color: colors.onSurfaceVariant),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: BorderSide(
                        color: colors.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      'Hủy',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.error,
                      foregroundColor: colors.onError,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      ref
                          .read(nutritionProvider.notifier)
                          .removeFoodEntry(entry.id);
                    },
                    child: const Text(
                      'Xóa',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showGoalAdjustmentSheet(
    BuildContext context,
    WidgetRef ref,
    NutritionState state,
  ) {
    final calController = TextEditingController(
      text: state.targetCalories.toString(),
    );
    final proteinController = TextEditingController(
      text: state.targetProtein.toStringAsFixed(0),
    );
    final carbsController = TextEditingController(
      text: state.targetCarbs.toStringAsFixed(0),
    );
    final fatController = TextEditingController(
      text: state.targetFat.toStringAsFixed(0),
    );

    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        final bottomInset = MediaQuery.of(modalContext).viewInsets.bottom;
        final bottomPadding = MediaQuery.of(modalContext).padding.bottom;
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 10,
            bottom: bottomInset + bottomPadding + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chỉnh mục tiêu dinh dưỡng',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  'Đặt mục tiêu năng lượng và dinh dưỡng phù hợp thể trạng của bạn',
                  style: Theme.of(modalContext).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: calController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Mục tiêu Calo hàng ngày (kcal)',
                    suffixText: 'kcal',
                    prefixIcon: Icon(Icons.local_fire_department_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: proteinController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Protein (g)',
                          suffixText: 'g',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: carbsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Carb (g)',
                          suffixText: 'g',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: fatController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Fat (g)',
                          suffixText: 'g',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(modalContext),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Hủy'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          final cal = int.tryParse(calController.text.trim());
                          final p = double.tryParse(
                            proteinController.text.trim(),
                          );
                          final c = double.tryParse(
                            carbsController.text.trim(),
                          );
                          final f = double.tryParse(fatController.text.trim());

                          ref
                              .read(nutritionProvider.notifier)
                              .updateGoals(
                                targetCalories: cal,
                                targetProtein: p,
                                targetCarbs: c,
                                targetFat: f,
                              );
                          Navigator.pop(modalContext);
                        },
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Lưu thay đổi'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. Weekly Date Selector Card with Horizontal Swipe & "Hôm nay" Button
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
          LayoutBuilder(
            builder: (context, constraints) {
              final dateChip = Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: AppColors.iconSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        headerLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              );
              final todayButton = InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: onTapToday,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelectedToday
                        ? AppColors.primarySoft
                        : AppColors.surfaceNested,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelectedToday
                          ? AppColors.primaryBorder
                          : AppColors.borderDefault,
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
                            ? AppColors.primary
                            : AppColors.textSecondary,
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
              );

              if (constraints.maxWidth < 300) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    dateChip,
                    const SizedBox(height: 8),
                    Align(alignment: Alignment.centerRight, child: todayButton),
                  ],
                );
              }

              return Row(
                children: [
                  Flexible(child: dateChip),
                  const SizedBox(width: 10),
                  todayButton,
                ],
              );
            },
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
                                  : colors.surfaceContainerHigh.withValues(
                                      alpha: 0.5,
                                    ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: colors.primary.withValues(
                                          alpha: 0.35,
                                        ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
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
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: isSelected
                                        ? Colors.white
                                        : colors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Small indicator dot
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? Colors.white
                                        : (hasLogs
                                              ? colors.primary
                                              : Colors.transparent),
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

// ─────────────────────────────────────────────────────────────────────────────
// 2. Daily Energy & Nutrition Summary Card (Modern Bento Hub)
// ─────────────────────────────────────────────────────────────────────────────
class _DailyEnergySummaryCard extends StatelessWidget {
  const _DailyEnergySummaryCard({
    required this.consumed,
    required this.target,
    required this.remaining,
    required this.caloriePercentInt,
    required this.calorieRatio,
    required this.state,
    required this.onAdjustGoals,
  });

  final int consumed;
  final int target;
  final int remaining;
  final int caloriePercentInt;
  final double calorieRatio;
  final NutritionState state;
  final VoidCallback onAdjustGoals;

  static String _formatNumber(int n) {
    return n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isOverTarget = remaining < 0;

    // Remaining macros
    final proteinRemaining = (state.targetProtein - state.consumedProtein)
        .clamp(0.0, 500.0);
    final carbsRemaining = (state.targetCarbs - state.consumedCarbs).clamp(
      0.0,
      800.0,
    );
    final fatRemaining = (state.targetFat - state.consumedFat).clamp(
      0.0,
      300.0,
    );

    // Dynamic smart tip for beginners
    String smartCoachTip;
    if (consumed == 0) {
      smartCoachTip =
          '👋 Chào ngày mới! Bấm "✨ AI Thực đơn" để gợi ý bữa ăn chuẩn macro đầu ngày.';
    } else if (isOverTarget) {
      smartCoachTip =
          '⚠️ Bạn đã nạp vượt chỉ tiêu ${remaining.abs()} kcal. Hãy duy trì vận động nhẹ & uống nhiều nước.';
    } else if (proteinRemaining > 35) {
      smartCoachTip =
          '💪 Bạn còn thiếu ${proteinRemaining.toStringAsFixed(0)}g Protein. Hãy ưu tiên bổ sung ức gà, trứng hoặc cá.';
    } else if (caloriePercentInt >= 85) {
      smartCoachTip =
          '🎯 Tuyệt vời! Bạn sắp hoàn thành mục tiêu calo hôm nay ($caloriePercentInt%).';
    } else {
      smartCoachTip =
          '🔥 Đang nạp $caloriePercentInt% năng lượng. Hãy cân đối protein & carb cho các bữa tiếp theo!';
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.6),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Row: Title & Adjust Goal ────────────────────────────────
          Row(
            children: [
              const Icon(
                Icons.bolt_rounded,
                color: AppColors.nutritionCalories,
                size: 20,
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'NĂNG LƯỢNG HÔM NAY',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: onAdjustGoals,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceNested,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.borderDefault,
                      width: 0.8,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.tune_rounded,
                        size: 13,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Chỉnh mục tiêu',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Hero Calorie Display ───────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.nutritionCalories.withValues(alpha: 0.12),
                  colors.surfaceContainerHigh,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.nutritionCaloriesBorder,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isOverTarget ? 'VƯỢT CHỈ TIÊU' : 'CALO CÒN LẠI',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: isOverTarget
                                ? colors.error
                                : AppColors.nutritionCalories,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              _formatNumber(remaining.abs()),
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: isOverTarget
                                    ? colors.error
                                    : AppColors.nutritionCalories,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'kcal',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: isOverTarget
                                    ? colors.error
                                    : AppColors.nutritionCalories,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Đã nạp / Mục tiêu',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatNumber(consumed)} / ${_formatNumber(target)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Main Calorie Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: calorieRatio,
                    minHeight: 8,
                    backgroundColor: colors.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isOverTarget ? colors.error : AppColors.nutritionCalories,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── 3 Macro Cards (Protein, Carb, Fat) ─────────────────────────────
          Row(
            children: [
              Expanded(
                child: _MacroProgressCard(
                  name: 'Protein',
                  consumed: state.consumedProtein,
                  target: state.targetProtein,
                  remaining: proteinRemaining,
                  color: AppColors.nutritionProtein,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MacroProgressCard(
                  name: 'Carb',
                  consumed: state.consumedCarbs,
                  target: state.targetCarbs,
                  remaining: carbsRemaining,
                  color: AppColors.nutritionCarbs,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MacroProgressCard(
                  name: 'Fat',
                  consumed: state.consumedFat,
                  target: state.targetFat,
                  remaining: fatRemaining,
                  color: AppColors.nutritionFat,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Smart AI Status Callout (Beginner Friendly) ────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.aiVioletSoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.aiVioletBorder, width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.aiViolet,
                  size: 17,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    smartCoachTip,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroProgressCard extends StatelessWidget {
  const _MacroProgressCard({
    required this.name,
    required this.consumed,
    required this.target,
    required this.remaining,
    required this.color,
  });

  final String name;
  final double consumed;
  final double target;
  final double remaining;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final ratio = target > 0 ? (consumed / target).clamp(0.0, 1.0) : 0.0;
    final percent = (ratio * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Dot + Name + Percent
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '$percent%',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Consumed / Target
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${consumed.toStringAsFixed(0)}g',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: colors.onSurface,
                  ),
                ),
                TextSpan(
                  text: ' / ${target.toStringAsFixed(0)}g',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Mini progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 5,
              backgroundColor: colors.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 6),

          // Remaining hint
          Text(
            remaining > 0
                ? 'Còn thiếu ${remaining.toStringAsFixed(0)}g'
                : 'Đã đủ ✓',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: remaining > 0
                  ? colors.onSurfaceVariant
                  : AppColors.accentEmerald,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. Nutrition Action Cards: Tìm kiếm, AI Thực đơn, Kế hoạch, Lịch sử
// ─────────────────────────────────────────────────────────────────────────────
class _NutritionActionCards extends StatelessWidget {
  const _NutritionActionCards({
    required this.onSearch,
    required this.onAiGenerate,
    required this.onPlan,
    required this.onHistory,
  });

  final VoidCallback onSearch;
  final VoidCallback onAiGenerate;
  final VoidCallback onPlan;
  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionCardItem(
            icon: Icons.search_rounded,
            label: 'Tìm món',
            onTap: onSearch,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionCardItem(
            icon: Icons.auto_awesome_rounded,
            label: '✨ AI Thực đơn',
            isAiHighlighted: true,
            onTap: onAiGenerate,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionCardItem(
            icon: Icons.calendar_month_rounded,
            label: 'Kế hoạch',
            onTap: onPlan,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionCardItem(
            icon: Icons.history_rounded,
            label: 'Lịch sử',
            onTap: onHistory,
          ),
        ),
      ],
    );
  }
}

class _ActionCardItem extends StatelessWidget {
  const _ActionCardItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isAiHighlighted = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isAiHighlighted;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: isAiHighlighted
              ? AppColors.aiViolet.withValues(alpha: 0.12)
              : colors.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isAiHighlighted
                ? AppColors.aiVioletBorder
                : colors.outlineVariant.withValues(alpha: 0.5),
            width: isAiHighlighted ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isAiHighlighted
                  ? AppColors.aiViolet
                  : AppColors.iconPrimary,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: isAiHighlighted ? AppColors.aiViolet : colors.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. Beginner Nutrition Tips Dialog Pop-up
// ─────────────────────────────────────────────────────────────────────────────
class _BeginnerNutritionTipsDialog extends StatelessWidget {
  const _BeginnerNutritionTipsDialog();

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => const _BeginnerNutritionTipsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: colors.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: colors.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: [Icon] Title & Subtitle + Close Icon
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lightbulb_outline_rounded,
                    color: AppColors.warning,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mẹo cho người mới',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Cách theo dõi bữa ăn chuẩn gymmer',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 14),

            _tipRow(
              '1',
              'Ưu tiên nạp đủ Protein',
              'Duy trì 1.6g - 2.2g đạm trên mỗi kg thể trọng giúp tối ưu quá trình phục hồi & xây dựng cơ bắp.',
              colors,
            ),
            const SizedBox(height: 12),
            _tipRow(
              '2',
              'Ghi nhận món ăn dễ dàng',
              'Dùng thư viện món ăn Việt Nam có sẵn hoặc "Ghi nhanh calo" khi ăn ngoài hàng quán.',
              colors,
            ),
            const SizedBox(height: 12),
            _tipRow(
              '3',
              'Tận dụng AI Coach',
              'Hỏi nhanh thực đơn phù hợp mục tiêu tăng cơ, giảm mỡ hoặc thực đơn lành mạnh 500 kcal.',
              colors,
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Đã hiểu',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _tipRow(
    String number,
    String title,
    String description,
    ColorScheme colors,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. VieGym AI Nutrition Assistant Card
// ─────────────────────────────────────────────────────────────────────────────
class _AiNutritionAssistantCard extends ConsumerWidget {
  const _AiNutritionAssistantCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;

    return Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Trợ lý AI Dinh dưỡng VieGym',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Hỏi nhanh thực đơn phù hợp mục tiêu của bạn',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Action Buttons: [ Chat ngay ] & [ ✨ AI tạo món ăn ]
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/ai/chat'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(
                      color: colors.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 15),
                  label: const Text(
                    'Chat ngay',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => context.push('/meal/generate'),
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.auto_awesome_rounded, size: 15),
                  label: const Text(
                    'AI tạo món ăn',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Suggested Prompt Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PromptChip(
                icon: '💪',
                label: 'Gợi ý thực đơn tăng cơ',
                onTap: () {
                  ref
                      .read(aiCoachProvider.notifier)
                      .send('Gợi ý thực đơn tăng cơ giàu protein');
                  context.push('/ai/chat');
                },
              ),
              _PromptChip(
                icon: '🥗',
                label: 'Bữa trưa lành mạnh 500 kcal',
                onTap: () {
                  ref
                      .read(aiCoachProvider.notifier)
                      .send(
                        'Hãy gợi ý cho tôi bữa trưa lành mạnh khoảng 500 kcal',
                      );
                  context.push('/ai/chat');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PromptChip extends StatelessWidget {
  const _PromptChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.4),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
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
// 7. Meal Section Card (Smart Bento Card with Harmonious Action Buttons)
// ─────────────────────────────────────────────────────────────────────────────
class _MealSectionCard extends StatelessWidget {
  const _MealSectionCard({
    required this.mealType,
    required this.entries,
    required this.onAddFood,
    this.onAiGenerate,
    required this.onQuickLog,
    required this.onDeleteEntry,
  });

  final MealType mealType;
  final List<FoodEntry> entries;
  final VoidCallback onAddFood;
  final VoidCallback? onAiGenerate;
  final VoidCallback onQuickLog;
  final ValueChanged<FoodEntry> onDeleteEntry;

  String _getMealEmoji() {
    switch (mealType) {
      case MealType.breakfast:
        return '🌅';
      case MealType.lunch:
        return '☀️';
      case MealType.dinner:
        return '🌙';
      case MealType.snack:
        return '🍎';
    }
  }

  Color _getMealAccentColor() {
    switch (mealType) {
      case MealType.breakfast:
        return AppColors.nutritionCalories;
      case MealType.lunch:
        return AppColors.nutritionProtein;
      case MealType.dinner:
        return AppColors.aiViolet;
      case MealType.snack:
        return AppColors.nutritionCarbs;
    }
  }

  String _getMealSubtitle() {
    switch (mealType) {
      case MealType.breakfast:
        return 'Nạp năng lượng đầu ngày';
      case MealType.lunch:
        return 'Bữa chính cân bằng dưỡng chất';
      case MealType.dinner:
        return 'Phục hồi cơ bắp & nghỉ ngơi';
      case MealType.snack:
        return 'Bổ sung trước/sau tập';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final totalCalories = entries.fold(0, (sum, e) => sum + e.calories);
    final totalProtein = entries.fold(0.0, (sum, e) => sum + e.protein);
    final totalCarbs = entries.fold(0.0, (sum, e) => sum + e.carbs);
    final totalFat = entries.fold(0.0, (sum, e) => sum + e.fat);

    final accentColor = _getMealAccentColor();
    final hasItems = entries.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasItems
              ? colors.outlineVariant.withValues(alpha: 0.7)
              : colors.outlineVariant.withValues(alpha: 0.45),
          width: 1.1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Meal Header ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                // Meal Emoji Container matching AI Meal Generator style
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.28),
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _getMealEmoji(),
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            mealType.label,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              mealType.timeRange,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getMealSubtitle(),
                        style: TextStyle(
                          fontSize: 11.5,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Calorie pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: hasItems
                        ? AppColors.nutritionCalories.withValues(alpha: 0.14)
                        : colors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: hasItems
                          ? AppColors.nutritionCaloriesBorder
                          : colors.outlineVariant.withValues(alpha: 0.4),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$totalCalories',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: hasItems
                              ? AppColors.nutritionCalories
                              : colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'kcal',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: hasItems
                              ? AppColors.nutritionCalories
                              : colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Macro Summary Strip (if has items) ──────────────────────────
          if (hasItems) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tổng macro bữa:',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    Row(
                      children: [
                        _macroPill(
                          'P',
                          '${totalProtein.toStringAsFixed(0)}g',
                          AppColors.nutritionProtein,
                        ),
                        const SizedBox(width: 8),
                        _macroPill(
                          'C',
                          '${totalCarbs.toStringAsFixed(0)}g',
                          AppColors.nutritionCarbs,
                        ),
                        const SizedBox(width: 8),
                        _macroPill(
                          'F',
                          '${totalFat.toStringAsFixed(0)}g',
                          AppColors.nutritionFat,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],

          // ── Food Items List or Beginner Empty State ───────────────────────
          if (!hasItems)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHigh.withValues(
                        alpha: 0.45,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.restaurant_outlined,
                          size: 13,
                          color: colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Chưa có món nào trong ${mealType.label.toLowerCase()}',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildActionRow(colors),
                ],
              ),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _FoodItemRow(
                      entry: entry,
                      onDelete: () => onDeleteEntry(entry),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 4),

            // Populated bottom actions row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: _buildActionRow(colors),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionRow(ColorScheme colors) {
    return Row(
      children: [
        // 1. Thêm món
        Expanded(
          child: _MealActionButton(
            icon: Icons.add_circle_outline_rounded,
            label: 'Thêm món',
            color: colors.primary,
            backgroundColor: colors.primary.withValues(alpha: 0.12),
            borderColor: colors.primary.withValues(alpha: 0.35),
            onTap: onAddFood,
          ),
        ),
        const SizedBox(width: 8),

        // 2. AI gợi ý
        if (onAiGenerate != null) ...[
          Expanded(
            child: _MealActionButton(
              icon: Icons.auto_awesome_rounded,
              label: 'AI gợi ý',
              color: AppColors.aiViolet,
              backgroundColor: AppColors.aiVioletSoft,
              borderColor: AppColors.aiVioletBorder,
              onTap: onAiGenerate!,
            ),
          ),
          const SizedBox(width: 8),
        ],

        // 3. Ghi nhanh
        Expanded(
          child: _MealActionButton(
            icon: Icons.bolt_rounded,
            label: 'Ghi nhanh',
            color: AppColors.accentAmber,
            backgroundColor: AppColors.accentAmber.withValues(alpha: 0.12),
            borderColor: AppColors.accentAmber.withValues(alpha: 0.35),
            onTap: onQuickLog,
          ),
        ),
      ],
    );
  }

  Widget _macroPill(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 7.1. Harmonious Meal Action Button Component
// ─────────────────────────────────────────────────────────────────────────────
class _MealActionButton extends StatelessWidget {
  const _MealActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.backgroundColor,
    required this.borderColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 8. Food Item Row Inside Meal Card
// ─────────────────────────────────────────────────────────────────────────────
class _FoodItemRow extends StatelessWidget {
  const _FoodItemRow({required this.entry, required this.onDelete});

  final FoodEntry entry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Food Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 52,
              height: 52,
              color: colors.surfaceContainerHighest,
              child: Image.network(
                entry.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.restaurant_rounded,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Food Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        entry.name,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (entry.loggedTime != null)
                      Text(
                        entry.loggedTime!,
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '${entry.servingAmount.toStringAsFixed(0)} ${entry.servingUnit}',
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${entry.calories} kcal',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.nutritionCalories,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'P:${entry.protein.toStringAsFixed(0)}g',
                        style: const TextStyle(
                          color: AppColors.nutritionProtein,
                        ),
                      ),
                      TextSpan(
                        text: '  ',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      TextSpan(
                        text: 'C:${entry.carbs.toStringAsFixed(0)}g',
                        style: const TextStyle(color: AppColors.nutritionCarbs),
                      ),
                      TextSpan(
                        text: '  ',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      TextSpan(
                        text: 'F:${entry.fat.toStringAsFixed(0)}g',
                        style: const TextStyle(color: AppColors.nutritionFat),
                      ),
                    ],
                  ),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),

          // Delete Button
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(
              Icons.delete_outline_rounded,
              size: 18,
              color: colors.onSurfaceVariant,
            ),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
