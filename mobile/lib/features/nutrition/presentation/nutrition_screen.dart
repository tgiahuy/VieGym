import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../ai/application/ai_coach_controller.dart';
import '../application/nutrition_controller.dart';
import '../domain/food_models.dart';

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(nutritionProvider);
    final aiCalories = ref.watch(mealCaloriesAddedProvider);
    final colors = Theme.of(context).colorScheme;

    final consumed = state.consumedCalories + aiCalories;
    final target = state.targetCalories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dinh dưỡng & Bữa ăn'),
        actions: [
          IconButton(
            onPressed: () => context.push('/meal/search'),
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
        children: [
          // Calorie & Macro Target Progress Card
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Năng lượng hôm nay',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '$consumed / $target kcal',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  LinearProgressIndicator(
                    value: (consumed / target).clamp(0.0, 1.0),
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _Macro(
                          label: 'Protein',
                          value:
                              '${state.consumedProtein.toStringAsFixed(0)} / ${state.targetProtein.toStringAsFixed(0)}g',
                          color: Colors.blueAccent,
                        ),
                      ),
                      Expanded(
                        child: _Macro(
                          label: 'Carb',
                          value:
                              '${state.consumedCarbs.toStringAsFixed(0)} / ${state.targetCarbs.toStringAsFixed(0)}g',
                          color: Colors.amber,
                        ),
                      ),
                      Expanded(
                        child: _Macro(
                          label: 'Fat',
                          value:
                              '${state.consumedFat.toStringAsFixed(0)} / ${state.targetFat.toStringAsFixed(0)}g',
                          color: Colors.pinkAccent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 4 Shortcut Buttons
          Row(
            children: [
              Expanded(
                child: _Shortcut(
                  icon: Icons.search_rounded,
                  label: 'Tìm món',
                  onTap: () => context.push('/meal/search'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Shortcut(
                  icon: Icons.soup_kitchen_rounded,
                  label: 'Tạo bữa',
                  onTap: () => context.push('/meal/builder'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Shortcut(
                  icon: Icons.menu_book_rounded,
                  label: 'Kế hoạch',
                  onTap: () => context.push('/meal/plan'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Shortcut(
                  icon: Icons.history_rounded,
                  label: 'Lịch sử',
                  onTap: () => context.push('/meal/history'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Meals Sections Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Nhật ký bữa ăn hôm nay',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              TextButton.icon(
                onPressed: () => context.push('/meal/plan'),
                icon: const Icon(Icons.tune_rounded, size: 16),
                label: const Text('Xem chi tiết'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 4 Meals Cards
          ...MealType.values.map((meal) {
            final mealEntries = state.getEntriesByMeal(meal);
            final mealCalories =
                mealEntries.fold(0, (sum, e) => sum + e.calories);
            final foodsSummary = mealEntries.isEmpty
                ? 'Chưa thêm món'
                : mealEntries.map((e) => e.name).join(', ');

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: colors.primary.withValues(alpha: 0.15),
                  child: Icon(
                    Icons.restaurant_rounded,
                    color: colors.primary,
                    size: 20,
                  ),
                ),
                title: Text(
                  meal.label,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  foodsSummary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$mealCalories\nkcal',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline_rounded),
                      onPressed: () =>
                          context.push('/meal/search?mealType=${meal.code}'),
                    ),
                  ],
                ),
                onTap: () => context.push('/meal/search?mealType=${meal.code}'),
              ),
            );
          }),

          if (aiCalories > 0)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: Colors.greenAccent.withValues(alpha: 0.1),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.greenAccent,
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
                title: const Text(
                  'Đề xuất từ AI Coach',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: const Text('Đã thêm từ structured meal proposal'),
                trailing: Text(
                  '$aiCalories\nkcal',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.greenAccent,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => context.push('/ai/chat'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.auto_awesome_rounded),
            label: const Text('Nhờ AI Coach phân tích thực đơn'),
          ),
        ],
      ),
    );
  }
}

class _Macro extends StatelessWidget {
  const _Macro({
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 12,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
          child: Column(
            children: [
              Icon(icon, color: colors.primary, size: 22),
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
