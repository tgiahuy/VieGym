import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/food_catalog.dart';
import '../domain/food_models.dart';

final favoriteFoodsProvider =
    NotifierProvider<FavoriteFoodsController, Set<String>>(
      FavoriteFoodsController.new,
    );

class FavoriteFoodsController extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    // Initial favorite staples
    return {
      'food_pho_bo', // Phở bò tái nạm
      'food_uc_ga', // Ức gà áp chảo
      'food_salmon', // Cá hồi áp chảo măng tây
    };
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
