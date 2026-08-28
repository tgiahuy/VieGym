import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/nutrition_controller.dart';
import '../domain/food_models.dart';

class MealPlannerScreen extends ConsumerWidget {
  const MealPlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(nutritionProvider);
    final notifier = ref.read(nutritionProvider.notifier);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Kế hoạch dinh dưỡng'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
        children: [
          // Target Overview Card
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Mục tiêu calo hàng ngày',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${state.targetCalories} kcal',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: (state.consumedCalories / state.targetCalories)
                        .clamp(0.0, 1.0),
                    borderRadius: BorderRadius.circular(99),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Đã nạp ${state.consumedCalories} kcal • Còn lại ${state.remainingCalories} kcal',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 4 Meal Sections
          ...MealType.values.map((meal) {
            final mealEntries = state.getEntriesByMeal(meal);
            final mealCalories =
                mealEntries.fold(0, (sum, e) => sum + e.calories);

            return Card(
              margin: const EdgeInsets.only(bottom: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(
                  color: colors.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              meal.label,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              meal.timeRange,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: colors.onSurfaceVariant),
                            ),
                          ],
                        ),
                        Text(
                          '$mealCalories kcal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (mealEntries.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Chưa thêm món nào cho ${meal.label.toLowerCase()}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      )
                    else
                      ...mealEntries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(entry.imageUrl),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      '${entry.calories} kcal • P: ${entry.protein}g C: ${entry.carbs}g F: ${entry.fat}g',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                                onPressed: () =>
                                    notifier.removeFoodEntry(entry.id),
                              ),
                            ],
                          ),
                        );
                      }),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => context
                          .push('/meal/search?mealType=${meal.code}'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: Text('Thêm món vào ${meal.label}'),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
