import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/nutrition_controller.dart';
import '../data/food_catalog.dart';
import '../domain/food_models.dart';

class FoodDetailScreen extends ConsumerStatefulWidget {
  const FoodDetailScreen({
    super.key,
    required this.foodId,
    this.initialMealType = MealType.lunch,
  });

  final String foodId;
  final MealType initialMealType;

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
    if (food != null && food.servingOptions.isNotEmpty) {
      _selectedServingId = food.servingOptions.first.id;
    } else {
      _selectedServingId = '';
    }
  }

  void _addFood(FoodItem food, CalculatedNutrition calculated) {
    ref.read(nutritionProvider.notifier).addFoodEntry(
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã thêm ${food.name} (${calculated.calories} kcal) vào ${_selectedMeal.label}!',
        ),
      ),
    );
    context.pop();
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

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(food.name, style: const TextStyle(fontSize: 16)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          // Food Image Banner
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: NetworkImage(food.imageUrl),
                fit: BoxFit.cover,
              ),
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
              child: Column(
                children: food.servingOptions.map((opt) {
                  return RadioListTile<String>(
                    title: Text(opt.name, style: const TextStyle(fontSize: 14)),
                    subtitle: Text('${opt.grams}g'),
                    value: opt.id,
                    groupValue: _selectedServingId,
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedServingId = val);
                    },
                  );
                }).toList(),
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

          // 3. Target Meal Selector
          const Text(
            '3. Thêm vào bữa ăn nào?',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Row(
            children: MealType.values.map((meal) {
              final isSelected = _selectedMeal == meal;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: ChoiceChip(
                    label: Text(
                      meal.label.replaceAll('Bữa ', ''),
                      style: const TextStyle(fontSize: 12),
                    ),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedMeal = meal),
                  ),
                ),
              );
            }).toList(),
          ),
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
          icon: const Icon(Icons.add_circle_rounded),
          label: Text(
            'Thêm vào ${_selectedMeal.label} (+${calculated.calories} kcal)',
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
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.4),
        ),
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
            style: TextStyle(
              fontSize: 9,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
