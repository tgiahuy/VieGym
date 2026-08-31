import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/resilient_network_image.dart';
import '../application/favorite_foods_controller.dart';
import '../data/food_catalog.dart';

class FavoriteFoodsScreen extends ConsumerWidget {
  const FavoriteFoodsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final favoriteIds = ref.watch(favoriteFoodsProvider);
    final favoriteFoods = masterFoodCatalog
        .where((f) => favoriteIds.contains(f.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Row(
          children: [
            const Text(
              'Món ăn yêu thích',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${favoriteFoods.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: colors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
      body: favoriteFoods.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.primary.withValues(alpha: 0.12),
                      ),
                      child: Icon(
                        Icons.favorite_border_rounded,
                        size: 40,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Chưa có món ăn yêu thích nào',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hãy tìm kiếm món ăn và bấm biểu tượng ❤️ để lưu các món bạn yêu thích vào đây.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => context.push('/meal/search'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.search_rounded, size: 18),
                      label: const Text(
                        'Tìm kiếm món ăn',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: favoriteFoods.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final food = favoriteFoods[index];

                return Container(
                  decoration: BoxDecoration(
                    color: colors.surfaceContainer,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: colors.outlineVariant.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => context.push('/meal/food/${food.id}'),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Thumbnail
                            SizedBox(
                              width: 72,
                              height: 72,
                              child: ResilientNetworkImage(
                                url: food.imageUrl,
                                semanticLabel: 'Ảnh món ${food.name}',
                                borderRadius: BorderRadius.circular(14),
                                placeholderIcon: Icons.restaurant_rounded,
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    food.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '1 ${food.baseServingUnit} • ${food.baseCalories} kcal',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: colors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'P: ${food.baseProtein}g  C: ${food.baseCarbs}g  F: ${food.baseFat}g',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Favorite Toggle Heart Button
                            IconButton(
                              tooltip: 'Bỏ yêu thích',
                              icon: const Icon(
                                Icons.favorite_rounded,
                                color: Color(0xFFFF2E54),
                                size: 22,
                              ),
                              onPressed: () {
                                ref
                                    .read(favoriteFoodsProvider.notifier)
                                    .toggleFavorite(food.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
