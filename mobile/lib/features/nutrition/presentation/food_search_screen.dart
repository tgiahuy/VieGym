import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/resilient_network_image.dart';
import '../application/favorite_foods_controller.dart';
import '../application/food_catalog_controller.dart';
import '../domain/food_models.dart';

class FoodSearchScreen extends ConsumerStatefulWidget {
  const FoodSearchScreen({super.key, this.initialMealType = MealType.lunch});

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
    final favoriteIds = ref.watch(favoriteFoodsProvider);
    final catalog = ref.watch(foodCatalogProvider);

    final filteredFoods = catalog.foods.where((food) {
      final q = _query.toLowerCase().trim();
      final matchesQuery =
          q.isEmpty ||
          food.name.toLowerCase().contains(q) ||
          food.description.toLowerCase().contains(q);

      final matchesCategory =
          _selectedCategory == FoodCategory.all ||
          food.category == _selectedCategory;

      return matchesQuery && matchesCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text(
          'Thư viện món ăn',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
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

          if (catalog.error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Material(
                color: colors.errorContainer,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.cloud_off_rounded,
                        color: colors.onErrorContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Không tải được dữ liệu từ máy chủ. Đang hiển thị dữ liệu mẫu.',
                          style: TextStyle(
                            color: colors.onErrorContainer,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: catalog.isLoading
                            ? null
                            : () => ref
                                  .read(foodCatalogProvider.notifier)
                                  .refresh(),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                catalog.isLoading
                    ? 'Đang tải danh sách món ăn…'
                    : '${filteredFoods.length} món ăn',
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

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
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
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
                                SizedBox(
                                  width: 64,
                                  height: 64,
                                  child: ResilientNetworkImage(
                                    url: item.imageUrl,
                                    semanticLabel: 'Ảnh món ${item.name}',
                                    borderRadius: BorderRadius.circular(12),
                                    placeholderIcon: Icons.restaurant_rounded,
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
                                          color: AppColors.nutritionCalories,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      if (item.estimated)
                                        const Text(
                                          'Giá trị tham khảo',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'P: ${item.baseProtein}g',
                                              style: const TextStyle(
                                                color:
                                                    AppColors.nutritionProtein,
                                              ),
                                            ),
                                            TextSpan(
                                              text: '  ',
                                              style: const TextStyle(
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                            TextSpan(
                                              text: 'C: ${item.baseCarbs}g',
                                              style: const TextStyle(
                                                color: AppColors.nutritionCarbs,
                                              ),
                                            ),
                                            TextSpan(
                                              text: '  ',
                                              style: const TextStyle(
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                            TextSpan(
                                              text: 'F: ${item.baseFat}g',
                                              style: const TextStyle(
                                                color: AppColors.nutritionFat,
                                              ),
                                            ),
                                          ],
                                        ),
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

                                const SizedBox(width: 8),

                                // Favorite Toggle Button
                                IconButton(
                                  tooltip: favoriteIds.contains(item.id)
                                      ? 'Bỏ yêu thích'
                                      : 'Thêm vào yêu thích',
                                  icon: Icon(
                                    favoriteIds.contains(item.id)
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    color: favoriteIds.contains(item.id)
                                        ? colors.primary
                                        : colors.onSurfaceVariant.withValues(
                                            alpha: 0.6,
                                          ),
                                    size: 22,
                                  ),
                                  onPressed: () {
                                    ref
                                        .read(favoriteFoodsProvider.notifier)
                                        .toggleFavoriteWithSync(item.id);
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
