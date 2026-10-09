import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../data/food_catalog.dart';
import '../data/nutrition_repository.dart';
import '../domain/food_models.dart';

class FoodCatalogState {
  const FoodCatalogState({
    required this.foods,
    this.isLoading = false,
    this.error,
  });
  final List<FoodItem> foods;
  final bool isLoading;
  final String? error;
}

class FoodCatalogController extends Notifier<FoodCatalogState> {
  @override
  FoodCatalogState build() {
    final isAuthenticated = ref.watch(
      authProvider.select((state) => state.isAuthenticated),
    );
    if (isAuthenticated) Future.microtask(refresh);
    return const FoodCatalogState(foods: masterFoodCatalog);
  }

  Future<void> refresh({String? query, String? category}) async {
    state = FoodCatalogState(foods: state.foods, isLoading: true);
    try {
      final foods = await ref
          .read(nutritionRepositoryProvider)
          .getFoods(query: query, category: category);
      if (!ref.mounted) return;
      state = FoodCatalogState(foods: foods);
    } catch (error) {
      if (!ref.mounted) return;
      state = FoodCatalogState(foods: state.foods, error: '$error');
    }
  }

  FoodItem? findById(String id) {
    for (final food in state.foods) {
      if (food.id == id) return food;
    }
    return findFoodById(id);
  }
}

final foodCatalogProvider =
    NotifierProvider<FoodCatalogController, FoodCatalogState>(
      FoodCatalogController.new,
    );
