import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/application/auth_controller.dart';
import '../application/meal_templates_controller.dart';
import '../application/nutrition_controller.dart';
import '../domain/food_models.dart';

class MealHistoryScreen extends ConsumerStatefulWidget {
  const MealHistoryScreen({super.key});

  @override
  ConsumerState<MealHistoryScreen> createState() => _MealHistoryScreenState();
}

class _MealHistoryScreenState extends ConsumerState<MealHistoryScreen> {
  @override
  void initState() {
    super.initState();
    if (ref.read(authProvider).isAuthenticated) {
      Future.microtask(
        () => ref.read(nutritionProvider.notifier).refreshHistory(),
      );
    }
  }

  static String _formatDateLabel(String dateStr) {
    try {
      final parts = dateStr.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      final date = DateTime(year, month, day);
      final now = DateTime.now();

      final isToday =
          date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
      final isYesterday =
          date.year == now.year &&
          date.month == now.month &&
          date.day == now.day - 1;

      if (isToday) {
        return 'Hôm nay ($day/${month.toString().padLeft(2, '0')})';
      }
      if (isYesterday) {
        return 'Hôm qua ($day/${month.toString().padLeft(2, '0')})';
      }

      const dayNames = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
      final dayName = dayNames[date.weekday - 1];
      return '$dayName, $day Tháng $month';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(nutritionProvider);
    final templateState = ref.watch(mealTemplatesProvider);
    final colors = Theme.of(context).colorScheme;

    // Group actual entries by date
    final Map<String, List<FoodEntry>> entriesByDate = {};
    for (final entry in state.entries) {
      entriesByDate.putIfAbsent(entry.date, () => []).add(entry);
    }

    final sortedDates = entriesByDate.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    // Calculate weekly average
    final totalCaloriesAll = state.entries.fold(
      0,
      (sum, e) => sum + e.calories,
    );
    final daysCount = sortedDates.isEmpty ? 1 : sortedDates.length;
    final avgDailyCal = (totalCaloriesAll / daysCount).round();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Lịch sử dinh dưỡng'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          // Weekly Average Summary Card
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
                Text(
                  'Trung bình dinh dưỡng đã ghi',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$avgDailyCal kcal / ngày',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentEmerald.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${sortedDates.length} ngày đã ghi',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppColors.accentEmerald,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Mẫu bữa ăn',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                ),
              ),
              if (state.planId != null)
                TextButton.icon(
                  onPressed: () => _saveTemplate(state.planId!),
                  icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                  label: const Text('Lưu ngày này'),
                ),
            ],
          ),
          if (templateState.isLoading && templateState.templates.isEmpty)
            const LinearProgressIndicator()
          else if (templateState.templates.isEmpty)
            Text(
              'Chưa có mẫu. Mở một ngày đã ghi và chọn “Lưu ngày này”.',
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
            )
          else
            ...templateState.templates.map(
              (template) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.restaurant_menu_rounded),
                title: Text(
                  template.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text('${template.items.length} món'),
                trailing: FilledButton.tonal(
                  onPressed: () => _applyTemplate(
                    template.id,
                    template.name,
                    template.items.length,
                    state.selectedDate,
                  ),
                  child: const Text('Dùng mẫu'),
                ),
              ),
            ),
          const SizedBox(height: 18),

          // Section Title
          Text(
            'Chi tiết theo ngày',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              color: colors.onSurface.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 10),

          if (sortedDates.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(
                    Icons.no_meals_rounded,
                    size: 48,
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Chưa có dữ liệu bữa ăn.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          else
            ...sortedDates.map((dateStr) {
              final dayEntries = entriesByDate[dateStr] ?? [];
              final dayCalories = dayEntries.fold(
                0,
                (sum, e) => sum + e.calories,
              );
              final dayProtein = dayEntries.fold(
                0.0,
                (sum, e) => sum + e.protein,
              );
              final dayCarbs = dayEntries.fold(0.0, (sum, e) => sum + e.carbs);
              final dayFat = dayEntries.fold(0.0, (sum, e) => sum + e.fat);

              final targetCal = state.targetCalories;
              final ratio = targetCal > 0
                  ? (dayCalories / targetCal).clamp(0.0, 1.0)
                  : 0.0;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
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
                    // Date Header & Calories
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDateLabel(dateStr),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '$dayCalories / $targetCal kcal',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color: AppColors.nutritionCalories,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Macro Summary Row
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'P: ${dayProtein.toStringAsFixed(0)}g',
                            style: const TextStyle(
                              color: AppColors.nutritionProtein,
                            ),
                          ),
                          TextSpan(
                            text: ' • ',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          TextSpan(
                            text: 'C: ${dayCarbs.toStringAsFixed(0)}g',
                            style: const TextStyle(
                              color: AppColors.nutritionCarbs,
                            ),
                          ),
                          TextSpan(
                            text: ' • ',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          TextSpan(
                            text: 'F: ${dayFat.toStringAsFixed(0)}g',
                            style: const TextStyle(
                              color: AppColors.nutritionFat,
                            ),
                          ),
                        ],
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 5,
                        backgroundColor: colors.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation(
                          AppColors.nutritionCalories,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Food Items List
                    ...dayEntries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.nutritionCalories,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                entry.name,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
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
                      );
                    }),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Future<void> _saveTemplate(int planId) async {
    final controller = TextEditingController(text: 'Thực đơn của tôi');
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Lưu mẫu bữa ăn'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 160,
          decoration: const InputDecoration(labelText: 'Tên mẫu'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.trim().isEmpty) return;
    try {
      await ref
          .read(mealTemplatesProvider.notifier)
          .saveCurrentPlan(name.trim(), planId);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể lưu mẫu bữa ăn.')),
      );
    }
  }

  Future<void> _applyTemplate(
    int id,
    String name,
    int itemCount,
    String targetDate,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Áp dụng “$name”?'),
        content: Text(
          'Xem trước: thêm $itemCount món vào ngày $targetDate. Dữ liệu ngày nguồn không thay đổi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final result = await ref
          .read(mealTemplatesProvider.notifier)
          .apply(id, targetDate);
      if (!mounted) return;
      if (!result.applied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${result.blockedItems.length} món không còn khả dụng; chưa có dữ liệu nào được sao chép.',
            ),
          ),
        );
        return;
      }
      await ref.read(nutritionProvider.notifier).refreshSelectedDate();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã áp dụng mẫu bữa ăn.')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể áp dụng mẫu bữa ăn.')),
      );
    }
  }
}
