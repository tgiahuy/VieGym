import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/application/auth_controller.dart';
import '../data/food_catalog.dart';
import '../data/nutrition_repository.dart';
import '../domain/food_models.dart';

final favoriteFoodsProvider =
    NotifierProvider<FavoriteFoodsController, Set<String>>(
      FavoriteFoodsController.new,
    );

class FavoriteFoodsController extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    if (ref.read(authProvider).isAuthenticated) {
      Future.microtask(syncRemoteFavorites);
    }
    // Initial favorite staples
    return {
      'food_pho_bo', // Phở bò tái nạm
      'food_uc_ga', // Ức gà áp chảo
      'food_salmon', // Cá hồi áp chảo măng tây
    };
  }

  Future<void> syncRemoteFavorites() async {
    try {
      final foods = await ref.read(nutritionRepositoryProvider).getFavorites();
      if (!ref.mounted) return;
      state = foods.map((food) => food.id).toSet();
    } catch (_) {
      // Offline fallback remains available for the existing demo catalog.
    }
  }

  bool isFavorite(String foodId) => state.contains(foodId);

  bool toggleFavorite(String foodId) {
    final updated = Set<String>.from(state);
    final isFav = updated.contains(foodId);
    if (isFav) {
      updated.remove(foodId);
    } else {
      updated.add(foodId);
    }
    state = updated;
    return !isFav;
  }

  Future<bool> toggleFavoriteWithSync(String foodId) async {
    final isNowFavorite = toggleFavorite(foodId);
    final numericId = int.tryParse(foodId);
    if (numericId == null) return isNowFavorite;
    try {
      final repository = ref.read(nutritionRepositoryProvider);
      if (isNowFavorite) {
        await repository.addFavorite(foodId);
      } else {
        await repository.removeFavorite(foodId);
      }
      return isNowFavorite;
    } catch (_) {
      toggleFavorite(foodId);
      rethrow;
    }
  }

  void addFavorite(String foodId) {
    if (!state.contains(foodId)) {
      state = {...state, foodId};
    }
  }

  void removeFavorite(String foodId) {
    if (state.contains(foodId)) {
      state = state.where((id) => id != foodId).toSet();
    }
  }

  List<FoodItem> getFavorites() {
    return masterFoodCatalog.where((food) => state.contains(food.id)).toList();
  }
}
