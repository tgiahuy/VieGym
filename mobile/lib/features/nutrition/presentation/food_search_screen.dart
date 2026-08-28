import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/nutrition_controller.dart';
import '../data/food_catalog.dart';
import '../domain/food_models.dart';

class FoodSearchScreen extends ConsumerStatefulWidget {
  const FoodSearchScreen({
    super.key,
    this.initialMealType = MealType.lunch,
  });

  final MealType initialMealType;

  @override
  ConsumerState<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends ConsumerState<FoodSearchScreen> {
  String _query = '';
  FoodCategory _selectedCategory = FoodCategory.all;
  late MealType _activeMealType;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _activeMealType = widget.initialMealType;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final filteredFoods = masterFoodCatalog.where((food) {
      final q = _query.toLowerCase().trim();
      final matchesQuery = q.isEmpty ||
          food.name.toLowerCase().contains(q) ||
          food.description.toLowerCase().contains(q);

      final matchesCategory = _selectedCategory == FoodCategory.all ||
          food.category == _selectedCategory;

      return matchesQuery && matchesCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Column(
          children: [
            const Text(
              'Thư viện món ăn',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            Text(
              'Thêm vào: ${_activeMealType.label}',
              style: TextStyle(
                fontSize: 11,
                color: colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<MealType>(
            icon: const Icon(Icons.tune_rounded),
            initialValue: _activeMealType,
            onSelected: (val) => setState(() => _activeMealType = val),
            itemBuilder: (context) => MealType.values.map((m) {
              return PopupMenuItem(
                value: m,
                child: Text('Đổi sang: ${m.label}'),
              );
            }).toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Input
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm món ăn, thực phẩm (vd: phở, ức gà...)',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: colors.surfaceContainer,
              ),
              onChanged: (val) => setState(() => _query = val),
            ),
          ),

          // Categories Horizontal List
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: FoodCategory.values.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat.label),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),

          // Food List
          Expanded(
            child: filteredFoods.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant_rounded,
                          size: 48,
                          color: colors.onSurfaceVariant,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Không tìm thấy món ăn phù hợp',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: filteredFoods.length,
                    itemBuilder: (context, index) {
                      final item = filteredFoods[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: colors.outlineVariant.withValues(alpha: 0.4),
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => context.push(
                            '/meal/food/${item.id}?mealType=${_activeMealType.code}',
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // Thumbnail
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: colors.surfaceContainerHighest,
                                    image: DecorationImage(
                                      image: NetworkImage(item.imageUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '1 ${item.baseServingUnit} • ${item.baseCalories} kcal',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: colors.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'P: ${item.baseProtein}g  C: ${item.baseCarbs}g  F: ${item.baseFat}g',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: colors.onSurfaceVariant,
                                              fontSize: 11,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Quick Add Button
                                IconButton.filledTonal(
                                  icon: const Icon(Icons.add_rounded),
                                  onPressed: () {
                                    ref
                                        .read(nutritionProvider.notifier)
                                        .addFoodEntry(
                                          foodId: item.id,
                                          name: item.name,
                                          mealType: _activeMealType,
                                          calories: item.baseCalories,
                                          protein: item.baseProtein,
                                          carbs: item.baseCarbs,
                                          fat: item.baseFat,
                                          servingAmount: 1,
                                          servingUnit: item.baseServingUnit,
                                          imageUrl: item.imageUrl,
                                        );

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Đã thêm ${item.name} vào ${_activeMealType.label}!',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
