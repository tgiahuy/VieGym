import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/resilient_network_image.dart';
import '../application/nutrition_controller.dart';
import '../data/food_catalog.dart';
import '../domain/food_models.dart';
import 'food_detail_screen.dart';

class MealBuilderScreen extends ConsumerStatefulWidget {
  const MealBuilderScreen({super.key, this.initialMealType = MealType.lunch});

  final MealType initialMealType;

  @override
  ConsumerState<MealBuilderScreen> createState() => _MealBuilderScreenState();
}

class _MealBuilderScreenState extends ConsumerState<MealBuilderScreen> {
  late MealType _mealType;

  @override
  void initState() {
    super.initState();
    _mealType = widget.initialMealType;
  }

  Future<void> _editFoodEntry(FoodEntry entry) async {
    final food = findFoodById(entry.foodId);
    if (food == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không tìm thấy thông tin gốc của "${entry.name}"'),
        ),
      );
      return;
    }

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => FoodDetailScreen(
          foodId: food.id,
          initialQuantity: entry.servingAmount,
          initialMealType: _mealType,
          isMealBuilderMode: true,
        ),
      ),
    );

    if (result != null && mounted) {
      final servingId = result['servingId'] as String;
      final quantity = (result['quantity'] as num).toDouble();
      final calculated = calculateFoodNutrition(
        food: food,
        servingOptionId: servingId,
        quantity: quantity,
      );

      ref
          .read(nutritionProvider.notifier)
          .updateFoodEntry(
            id: entry.id,
            name: '${food.name} (${calculated.servingName})',
            calories: calculated.calories,
            protein: calculated.protein,
            carbs: calculated.carbs,
            fat: calculated.fat,
            servingAmount: quantity,
            servingUnit: calculated.servingName,
          );
    }
  }

  void _showAddFoodModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return Container(
          height: MediaQuery.of(sheetContext).size.height * 0.75,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Thêm món vào ${_mealType.label}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      context.push('/meal/search?mealType=${_mealType.code}');
                    },
                    icon: const Icon(Icons.search_rounded, size: 16),
                    label: const Text('Tìm kiếm chi tiết'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: masterFoodCatalog.length,
                  itemBuilder: (context, index) {
                    final food = masterFoodCatalog[index];
                    final currentEntries = ref
                        .watch(nutritionProvider)
                        .getEntriesByMeal(_mealType);
                    final isAdded = currentEntries.any(
                      (e) => e.foodId == food.id,
                    );

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: SizedBox.square(
                          dimension: 40,
                          child: ResilientNetworkImage(
                            url: food.imageUrl,
                            semanticLabel: 'Ảnh món ${food.name}',
                            borderRadius: BorderRadius.circular(99),
                            placeholderIcon: Icons.restaurant_rounded,
                          ),
                        ),
                        title: Text(
                          food.name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          '${food.baseServingUnit} • ${food.baseCalories} kcal • P: ${food.baseProtein}g',
                        ),
                        trailing: isAdded
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: Colors.greenAccent,
                              )
                            : const Icon(Icons.add_circle_outline_rounded),
                        onTap: () {
                          if (!isAdded) {
                            ref
                                .read(nutritionProvider.notifier)
                                .addFoodEntry(
                                  foodId: food.id,
                                  name: food.name,
                                  mealType: _mealType,
                                  calories: food.baseCalories,
                                  protein: food.baseProtein,
                                  carbs: food.baseCarbs,
                                  fat: food.baseFat,
                                  servingAmount: 1,
                                  servingUnit: food.baseServingUnit,
                                  imageUrl: food.imageUrl,
                                );
                          }
                          Navigator.pop(sheetContext);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(nutritionProvider);
    final notifier = ref.read(nutritionProvider.notifier);
    final colors = Theme.of(context).colorScheme;

    // Get real food entries for currently selected meal type
    final currentMealEntries = state.getEntriesByMeal(_mealType);
    final totalCalories = currentMealEntries.fold(
      0,
      (sum, e) => sum + e.calories,
    );
    final totalProtein = currentMealEntries.fold(
      0.0,
      (sum, e) => sum + e.protein,
    );
    final totalCarbs = currentMealEntries.fold(0.0, (sum, e) => sum + e.carbs);
    final totalFat = currentMealEntries.fold(0.0, (sum, e) => sum + e.fat);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Xây dựng bữa ăn'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          // Meal Type Selector with Icons
          Row(
            children:
                const [
                  _MealTypeTab(
                    type: MealType.breakfast,
                    label: 'Sáng',
                    icon: Icons.wb_twilight_rounded,
                  ),
                  _MealTypeTab(
                    type: MealType.lunch,
                    label: 'Trưa',
                    icon: Icons.wb_sunny_rounded,
                  ),
                  _MealTypeTab(
                    type: MealType.dinner,
                    label: 'Tối',
                    icon: Icons.nights_stay_rounded,
                  ),
                  _MealTypeTab(
                    type: MealType.snack,
                    label: 'Phụ',
                    icon: Icons.local_cafe_rounded,
                  ),
                ].map((tab) {
                  final isSelected = _mealType == tab.type;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => setState(() => _mealType = tab.type),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colors.primary
                                : colors.surfaceContainerHigh.withValues(
                                    alpha: 0.6,
                                  ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? colors.primary
                                  : colors.outlineVariant.withValues(
                                      alpha: 0.4,
                                    ),
                              width: 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: colors.primary.withValues(
                                        alpha: 0.35,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                tab.icon,
                                size: 18,
                                color: isSelected
                                    ? Colors.white
                                    : colors.onSurfaceVariant,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                tab.label,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected
                                      ? Colors.white
                                      : colors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 16),

          // Total Live Summary Card for Selected Meal
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: colors.primary.withValues(alpha: 0.5),
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
                      'TỔNG DINH DƯỠNG ${_mealType.label.toUpperCase()}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: colors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      '$totalCalories kcal',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _SmallMacro(
                      label: 'Protein',
                      value: '${totalProtein.toStringAsFixed(1)}g',
                      color: Colors.blueAccent,
                    ),
                    _SmallMacro(
                      label: 'Carbs',
                      value: '${totalCarbs.toStringAsFixed(1)}g',
                      color: Colors.amber,
                    ),
                    _SmallMacro(
                      label: 'Fat',
                      value: '${totalFat.toStringAsFixed(1)}g',
                      color: Colors.pinkAccent,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Items Header & Add Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Món ăn trong ${_mealType.label.toLowerCase()} (${currentMealEntries.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showAddFoodModal(context),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Thêm món'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (currentMealEntries.isEmpty)
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 36),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.add_shopping_cart_rounded,
                        size: 44,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Chưa có món ăn nào trong ${_mealType.label.toLowerCase()}',
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => _showAddFoodModal(context),
                        child: const Text('Chọn món ngay'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ...currentMealEntries.map((entry) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => _editFoodEntry(entry),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 46,
                            height: 46,
                            color: colors.surfaceContainerHighest,
                            child: Image.network(
                              entry.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    Icons.restaurant_rounded,
                                    color: colors.onSurfaceVariant,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${entry.servingUnit} • ${entry.calories} kcal',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'P: ${entry.protein.toStringAsFixed(1)}g • C: ${entry.carbs.toStringAsFixed(1)}g • F: ${entry.fat.toStringAsFixed(1)}g',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          tooltip: 'Chỉnh sửa khẩu phần',
                          onPressed: () => _editFoodEntry(entry),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.redAccent,
                            size: 18,
                          ),
                          tooltip: 'Xóa món',
                          onPressed: () => notifier.removeFoodEntry(entry.id),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: () => context.pop(),
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.check_circle_rounded),
          label: Text(
            'Hoàn tất — ${_mealType.label} ($totalCalories kcal)',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}

class _SmallMacro extends StatelessWidget {
  const _SmallMacro({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _MealTypeTab {
  const _MealTypeTab({
    required this.type,
    required this.label,
    required this.icon,
  });

  final MealType type;
  final String label;
  final IconData icon;
}
