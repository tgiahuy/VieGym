import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/nutrition_controller.dart';
import '../data/food_catalog.dart';
import '../domain/food_models.dart';

class MealBuilderScreen extends ConsumerStatefulWidget {
  const MealBuilderScreen({
    super.key,
    this.initialMealType = MealType.lunch,
  });

  final MealType initialMealType;

  @override
  ConsumerState<MealBuilderScreen> createState() => _MealBuilderScreenState();
}

class _MealBuilderScreenState extends ConsumerState<MealBuilderScreen> {
  late MealType _mealType;
  final List<FoodItem> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    _mealType = widget.initialMealType;
    // Default initial items
    final item1 = findFoodById('food_uc_ga');
    final item2 = findFoodById('food_gao_lut');
    if (item1 != null) _selectedItems.add(item1);
    if (item2 != null) _selectedItems.add(item2);
  }

  int get _totalCalories =>
      _selectedItems.fold(0, (sum, item) => sum + item.baseCalories);
  double get _totalProtein =>
      _selectedItems.fold(0, (sum, item) => sum + item.baseProtein);
  double get _totalCarbs =>
      _selectedItems.fold(0, (sum, item) => sum + item.baseCarbs);
  double get _totalFat =>
      _selectedItems.fold(0, (sum, item) => sum + item.baseFat);

  void _saveMeal() {
    final notifier = ref.read(nutritionProvider.notifier);
    for (final item in _selectedItems) {
      notifier.addFoodEntry(
        foodId: item.id,
        name: item.name,
        mealType: _mealType,
        calories: item.baseCalories,
        protein: item.baseProtein,
        carbs: item.baseCarbs,
        fat: item.baseFat,
        servingAmount: 1,
        servingUnit: item.baseServingUnit,
        imageUrl: item.imageUrl,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã lưu bữa ăn (${_totalCalories} kcal) vào ${_mealType.label}!',
        ),
      ),
    );
    context.go('/meal');
  }

  void _showAddFoodModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            height: MediaQuery.of(sheetContext).size.height * 0.7,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chọn món thêm vào bữa ăn',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: masterFoodCatalog.length,
                    itemBuilder: (context, index) {
                      final food = masterFoodCatalog[index];
                      final isAdded = _selectedItems.any((i) => i.id == food.id);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(food.imageUrl),
                          ),
                          title: Text(
                            food.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            '${food.baseServingUnit} • ${food.baseCalories} kcal • P: ${food.baseProtein}g',
                          ),
                          trailing: isAdded
                              ? const Icon(Icons.check_circle_rounded, color: Colors.greenAccent)
                              : const Icon(Icons.add_circle_outline_rounded),
                          onTap: () {
                            setState(() {
                              if (!isAdded) {
                                _selectedItems.add(food);
                              } else {
                                _selectedItems.removeWhere((i) => i.id == food.id);
                              }
                            });
                            Navigator.pop(sheetContext);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

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
          // Meal Type Selector
          Row(
            children: MealType.values.map((m) {
              final isSelected = _mealType == m;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: ChoiceChip(
                    label: Text(
                      m.label.replaceAll('Bữa ', ''),
                      style: const TextStyle(fontSize: 12),
                    ),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _mealType = m),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Total Live Summary Card
          Card(
            margin: EdgeInsets.zero,
            color: colors.primary.withValues(alpha: 0.12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: colors.primary.withValues(alpha: 0.5)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TỔNG DINH DƯỠNG BỮA ĂN',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: colors.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        '$_totalCalories kcal',
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
                      _SmallMacro(label: 'Protein', value: '${_totalProtein.toStringAsFixed(1)}g', color: Colors.blueAccent),
                      _SmallMacro(label: 'Carbs', value: '${_totalCarbs.toStringAsFixed(1)}g', color: Colors.amber),
                      _SmallMacro(label: 'Fat', value: '${_totalFat.toStringAsFixed(1)}g', color: Colors.pinkAccent),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Items Header & Add Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Danh sách món ăn (${_selectedItems.length})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              TextButton.icon(
                onPressed: () => _showAddFoodModal(context),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Thêm món'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (_selectedItems.isEmpty)
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 36),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.add_shopping_cart_rounded, size: 44, color: Colors.grey),
                      const SizedBox(height: 8),
                      const Text('Chưa có món ăn nào trong bữa này'),
                      const SizedBox(height: 10),
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
            ..._selectedItems.map((item) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(item.imageUrl),
                  ),
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                    '1 ${item.baseServingUnit} • ${item.baseCalories} kcal • P: ${item.baseProtein}g',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                    onPressed: () => setState(() => _selectedItems.remove(item)),
                  ),
                ),
              );
            }),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: _selectedItems.isEmpty ? null : _saveMeal,
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.save_rounded),
          label: Text(
            'Lưu vào ${_mealType.label} ($_totalCalories kcal)',
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
