import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/resilient_network_image.dart';
import '../application/favorite_foods_controller.dart';
import '../application/nutrition_controller.dart';
import '../data/food_catalog.dart';
import '../domain/food_models.dart';

class FoodDetailScreen extends ConsumerStatefulWidget {
  const FoodDetailScreen({
    super.key,
    required this.foodId,
    this.initialMealType = MealType.lunch,
    this.initialServingId,
    this.initialQuantity,
    this.isMealBuilderMode = false,
  });

  final String foodId;
  final MealType initialMealType;
  final String? initialServingId;
  final double? initialQuantity;
  final bool isMealBuilderMode;

  @override
  ConsumerState<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends ConsumerState<FoodDetailScreen> {
  late String _selectedServingId;
  double _quantity = 1.0;
  late MealType _selectedMeal;

  @override
  void initState() {
    super.initState();
    _selectedMeal = widget.initialMealType;
    final food = findFoodById(widget.foodId);
    if (widget.initialServingId != null &&
        widget.initialServingId!.isNotEmpty) {
      _selectedServingId = widget.initialServingId!;
    } else if (food != null && food.servingOptions.isNotEmpty) {
      _selectedServingId = food.servingOptions.first.id;
    } else {
      _selectedServingId = '';
    }

    if (widget.initialQuantity != null && widget.initialQuantity! > 0) {
      _quantity = widget.initialQuantity!;
    }
  }

  Future<void> _addFood(FoodItem food, CalculatedNutrition calculated) async {
    if (widget.isMealBuilderMode) {
      Navigator.pop(context, {
        'servingId': _selectedServingId,
        'quantity': _quantity,
      });
      return;
    }

    final nutritionState = ref.read(nutritionProvider);
    final remainingKcal = nutritionState.remainingCalories;
    final willExceed =
        (nutritionState.consumedCalories + calculated.calories) >
        nutritionState.targetCalories;
    final isVeryLowRemaining =
        remainingKcal <= 100 || calculated.calories > remainingKcal;

    if (willExceed || isVeryLowRemaining) {
      final excessKcal =
          (nutritionState.consumedCalories + calculated.calories) -
          nutritionState.targetCalories;

      final proceed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          final colors = Theme.of(dialogContext).colorScheme;
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            icon: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.accentAmber.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.accentAmber,
                size: 28,
              ),
            ),
            title: const Text(
              'Lượng calo sắp đạt chỉ tiêu',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Lượng calo còn lại hôm nay chỉ còn $remainingKcal kcal. Thêm "${food.name}" (+${calculated.calories} kcal) sẽ khiến bạn ${excessKcal > 0 ? "vượt chỉ tiêu $excessKcal kcal" : "đạt ngưỡng tối đa"} trong ngày.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.45,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accentAmber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.accentAmber.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.accentAmber,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Không khuyến khích thêm món ăn nếu bạn đang muốn duy trì hoặc giảm mỡ.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentAmber,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.center,
            actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: BorderSide(
                          color: colors.outlineVariant.withValues(alpha: 0.6),
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
                      onPressed: () => Navigator.pop(dialogContext, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accentAmber,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Vẫn thêm',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );

      if (proceed != true) return;
    }

    ref
        .read(nutritionProvider.notifier)
        .addFoodEntry(
          foodId: food.id,
          name: '${food.name} (${calculated.servingName})',
          mealType: _selectedMeal,
          calories: calculated.calories,
          protein: calculated.protein,
          carbs: calculated.carbs,
          fat: calculated.fat,
          servingAmount: _quantity,
          servingUnit: calculated.servingName,
          imageUrl: food.imageUrl,
        );

    if (!mounted) return;
    if (GoRouter.maybeOf(context) != null && context.canPop()) {
      context.pop();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  IconData _getMealIcon(MealType meal) {
    switch (meal) {
      case MealType.breakfast:
        return Icons.wb_twilight_rounded;
      case MealType.lunch:
        return Icons.wb_sunny_rounded;
      case MealType.dinner:
        return Icons.nights_stay_rounded;
      case MealType.snack:
        return Icons.cookie_outlined;
    }
  }

  String _getMealLabel(MealType meal) {
    switch (meal) {
      case MealType.breakfast:
        return 'Sáng';
      case MealType.lunch:
        return 'Trưa';
      case MealType.dinner:
        return 'Tối';
      case MealType.snack:
        return 'Phụ';
    }
  }

  @override
  Widget build(BuildContext context) {
    final food = findFoodById(widget.foodId);
    final colors = Theme.of(context).colorScheme;

    if (food == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Không tìm thấy')),
        body: const Center(child: Text('Không tìm thấy thông tin món ăn.')),
      );
    }

    final calculated = calculateFoodNutrition(
      food: food,
      servingOptionId: _selectedServingId,
      quantity: _quantity,
    );
    final isFav = ref.watch(favoriteFoodsProvider).contains(food.id);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(food.name, style: const TextStyle(fontSize: 16)),
        actions: [
          IconButton(
            tooltip: isFav ? 'Bỏ yêu thích' : 'Thêm vào yêu thích',
            icon: Icon(
              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFav ? colors.primary : colors.onSurface,
            ),
            onPressed: () {
              ref.read(favoriteFoodsProvider.notifier).toggleFavorite(food.id);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          // Food Image Banner
          SizedBox(
            height: 200,
            child: ResilientNetworkImage(
              url: food.imageUrl,
              semanticLabel: 'Ảnh món ${food.name}',
              borderRadius: BorderRadius.circular(20),
              placeholderIcon: Icons.restaurant_rounded,
            ),
          ),
          const SizedBox(height: 16),

          // Food Title & Description
          Text(
            food.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            food.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),

          // Live Macro Cards (4 Columns)
          Row(
            children: [
              Expanded(
                child: _MacroBox(
                  label: 'Năng lượng',
                  value: '${calculated.calories}',
                  unit: 'kcal',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MacroBox(
                  label: 'Protein',
                  value: '${calculated.protein}',
                  unit: 'g',
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MacroBox(
                  label: 'Carbs',
                  value: '${calculated.carbs}',
                  unit: 'g',
                  color: Colors.amber,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MacroBox(
                  label: 'Fat',
                  value: '${calculated.fat}',
                  unit: 'g',
                  color: Colors.pinkAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 1. Serving Options Selector
          if (food.servingOptions.isNotEmpty) ...[
            const Text(
              '1. Chọn khẩu phần',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Card(
              margin: EdgeInsets.zero,
              child: RadioGroup<String>(
                groupValue: _selectedServingId,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedServingId = value);
                  }
                },
                child: Column(
                  children: food.servingOptions.map((opt) {
                    return RadioListTile<String>(
                      title: Text(
                        opt.name,
                        style: const TextStyle(fontSize: 14),
                      ),
                      subtitle: Text('${opt.grams}g'),
                      value: opt.id,
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // 2. Quantity Stepper & Shortcuts
          const Text(
            '2. Số lượng phần ăn',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filledTonal(
                        onPressed: _quantity > 0.5
                            ? () => setState(() => _quantity -= 0.5)
                            : null,
                        icon: const Icon(Icons.remove_rounded),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          _quantity.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton.filledTonal(
                        onPressed: () => setState(() => _quantity += 0.5),
                        icon: const Icon(Icons.add_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [0.5, 1.0, 1.5, 2.0, 3.0].map((q) {
                      final isSelected = (_quantity - q).abs() < 0.01;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text('${q}x'),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _quantity = q),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 3. Target Meal Selector (Hidden in meal builder edit mode)
          if (!widget.isMealBuilderMode) ...[
            const Text(
              '3. Thêm vào bữa ăn nào?',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Row(
              children: MealType.values.map((meal) {
                final isSelected = _selectedMeal == meal;
                final icon = _getMealIcon(meal);
                final shortLabel = _getMealLabel(meal);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => setState(() => _selectedMeal = meal),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colors.primary.withValues(alpha: 0.16)
                              : colors.surfaceContainer,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? colors.primary
                                : colors.outlineVariant.withValues(alpha: 0.35),
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              icon,
                              size: 22,
                              color: isSelected
                                  ? colors.primary
                                  : colors.onSurfaceVariant,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              shortLabel,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: isSelected
                                    ? FontWeight.w900
                                    : FontWeight.w600,
                                color: isSelected
                                    ? colors.primary
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
            if (!widget.isMealBuilderMode) ...[
              Consumer(
                builder: (context, ref, _) {
                  final nutritionState = ref.watch(nutritionProvider);
                  final remainingKcal = nutritionState.remainingCalories;
                  final willExceed =
                      (nutritionState.consumedCalories + calculated.calories) >
                      nutritionState.targetCalories;
                  final isVeryLowRemaining =
                      remainingKcal <= 100 ||
                      calculated.calories > remainingKcal;

                  if (!willExceed && !isVeryLowRemaining) {
                    return const SizedBox.shrink();
                  }

                  final excessKcal =
                      (nutritionState.consumedCalories + calculated.calories) -
                      nutritionState.targetCalories;

                  return Container(
                    margin: const EdgeInsets.only(top: 18),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.accentAmber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.accentAmber.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.accentAmber,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Lượng calo sắp đạt chỉ tiêu trong ngày',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.accentAmber,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Calo còn lại: $remainingKcal kcal. Thêm món này (+${calculated.calories} kcal) sẽ khiến bạn ${excessKcal > 0 ? "vượt chỉ tiêu $excessKcal kcal" : "chạm mức tối đa"}. Không khuyến khích thêm món ăn nếu bạn đang muốn duy trì hoặc giảm mỡ.',
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 1.4,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: () => _addFood(food, calculated),
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: Icon(
            widget.isMealBuilderMode
                ? Icons.check_circle_rounded
                : Icons.add_circle_rounded,
          ),
          label: Text(
            widget.isMealBuilderMode
                ? 'Cập nhật khẩu phần (${calculated.calories} kcal)'
                : 'Thêm vào ${_selectedMeal.label} (+${calculated.calories} kcal)',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}

class _MacroBox extends StatelessWidget {
  const _MacroBox({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  final String label;
  final String value;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            unit,
            style: TextStyle(fontSize: 9, color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
