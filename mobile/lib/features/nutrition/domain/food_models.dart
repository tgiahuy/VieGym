enum FoodCategory {
  all('ALL', 'Tất cả'),
  vietnamese('VIETNAMESE', 'Món Việt'),
  protein('PROTEIN', 'Đạm / Thịt'),
  staple('STAPLE', 'Tinh bột'),
  snack('SNACK', 'Ăn vặt & Trái cây'),
  vegetable('VEGETABLE', 'Rau củ / Canh'),
  beverage('BEVERAGE', 'Đồ uống');

  const FoodCategory(this.code, this.label);
  final String code;
  final String label;
}

enum MealType {
  breakfast('BREAKFAST', 'Bữa sáng', '06:00 - 09:00'),
  lunch('LUNCH', 'Bữa trưa', '11:30 - 13:30'),
  dinner('DINNER', 'Bữa tối', '18:00 - 20:30'),
  snack('SNACK', 'Bữa phụ', 'Bất cứ lúc nào');

  const MealType(this.code, this.label, this.timeRange);
  final String code;
  final String label;
  final String timeRange;
}

class ServingOption {
  const ServingOption({
    required this.id,
    required this.name,
    required this.multiplier,
    required this.grams,
    this.isDefault = false,
  });

  final String id;
  final String name;
  final double multiplier;
  final int grams;
  final bool isDefault;
}

class FoodItem {
  const FoodItem({
    required this.id,
    required this.name,
    required this.category,
    required this.baseServingUnit,
    required this.baseCalories,
    required this.baseProtein,
    required this.baseCarbs,
    required this.baseFat,
    required this.imageUrl,
    required this.description,
    this.servingOptions = const [],
  });

  final String id;
  final String name;
  final FoodCategory category;
  final String baseServingUnit;
  final int baseCalories;
  final double baseProtein;
  final double baseCarbs;
  final double baseFat;
  final String imageUrl;
  final String description;
  final List<ServingOption> servingOptions;
}

class FoodEntry {
  const FoodEntry({
    required this.id,
    required this.foodId,
    required this.name,
    required this.mealType,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.servingAmount,
    required this.servingUnit,
    required this.imageUrl,
    required this.date,
  });

  final String id;
  final String foodId;
  final String name;
  final MealType mealType;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final double servingAmount;
  final String servingUnit;
  final String imageUrl;
  final String date;
}

class CalculatedNutrition {
  const CalculatedNutrition({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.servingName,
    required this.quantity,
  });

  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final String servingName;
  final double quantity;
}
