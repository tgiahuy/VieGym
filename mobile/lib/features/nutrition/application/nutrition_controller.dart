import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/food_models.dart';

String _formatDate(DateTime d) {
  final year = d.year;
  final month = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

class NutritionState {
  const NutritionState({
    required this.selectedDate,
    required this.entries,
    this.targetCalories = 2450,
    this.targetProtein = 150,
    this.targetCarbs = 280,
    this.targetFat = 75,
  });

  final String selectedDate;
  final List<FoodEntry> entries;
  final int targetCalories;
  final double targetProtein;
  final double targetCarbs;
  final double targetFat;

  List<FoodEntry> get currentDayEntries =>
      entries.where((e) => e.date == selectedDate).toList();

  List<FoodEntry> getEntriesByMeal(MealType type) =>
      currentDayEntries.where((e) => e.mealType == type).toList();

  int get consumedCalories =>
      currentDayEntries.fold(0, (sum, e) => sum + e.calories);

  double get consumedProtein =>
      currentDayEntries.fold(0, (sum, e) => sum + e.protein);

  double get consumedCarbs =>
      currentDayEntries.fold(0, (sum, e) => sum + e.carbs);

  double get consumedFat =>
      currentDayEntries.fold(0, (sum, e) => sum + e.fat);

  int get remainingCalories => (targetCalories - consumedCalories).clamp(0, 9999);

  NutritionState copyWith({
    String? selectedDate,
    List<FoodEntry>? entries,
    int? targetCalories,
    double? targetProtein,
    double? targetCarbs,
    double? targetFat,
  }) {
    return NutritionState(
      selectedDate: selectedDate ?? this.selectedDate,
      entries: entries ?? this.entries,
      targetCalories: targetCalories ?? this.targetCalories,
      targetProtein: targetProtein ?? this.targetProtein,
      targetCarbs: targetCarbs ?? this.targetCarbs,
      targetFat: targetFat ?? this.targetFat,
    );
  }
}

class NutritionController extends Notifier<NutritionState> {
  @override
  NutritionState build() {
    final today = _formatDate(DateTime.now());

    final initialEntries = [
      FoodEntry(
        id: 'entry_1',
        foodId: 'food_trung_luoc',
        name: 'Trứng gà luộc (2 quả) & Chuối',
        mealType: MealType.breakfast,
        calories: 260,
        protein: 14.3,
        carbs: 28.1,
        fat: 11.3,
        servingAmount: 1,
        servingUnit: 'phần',
        imageUrl:
            'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=500&auto=format&fit=crop&q=80',
        date: today,
      ),
      FoodEntry(
        id: 'entry_2',
        foodId: 'food_com_tam_suon',
        name: 'Cơm tấm sườn bì chả',
        mealType: MealType.lunch,
        calories: 640,
        protein: 39,
        carbs: 70,
        fat: 23,
        servingAmount: 1,
        servingUnit: 'dĩa tiêu chuẩn',
        imageUrl:
            'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&auto=format&fit=crop&q=80',
        date: today,
      ),
      FoodEntry(
        id: 'entry_3',
        foodId: 'food_uc_ga',
        name: 'Ức gà áp chảo (200g) + Gạo lứt',
        mealType: MealType.dinner,
        calories: 540,
        protein: 56,
        carbs: 45,
        fat: 8.5,
        servingAmount: 1,
        servingUnit: 'phần',
        imageUrl:
            'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=500&auto=format&fit=crop&q=80',
        date: today,
      ),
    ];

    return NutritionState(
      selectedDate: today,
      entries: initialEntries,
    );
  }

  void selectDate(String date) {
    state = state.copyWith(selectedDate: date);
  }

  void addFoodEntry({
    required String foodId,
    required String name,
    required MealType mealType,
    required int calories,
    required double protein,
    required double carbs,
    required double fat,
    required double servingAmount,
    required String servingUnit,
    required String imageUrl,
  }) {
    final entry = FoodEntry(
      id: 'entry_${DateTime.now().millisecondsSinceEpoch}',
      foodId: foodId,
      name: name,
      mealType: mealType,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      servingAmount: servingAmount,
      servingUnit: servingUnit,
      imageUrl: imageUrl,
      date: state.selectedDate,
    );

    state = state.copyWith(
      entries: [...state.entries, entry],
    );
  }

  void removeFoodEntry(String id) {
    state = state.copyWith(
      entries: state.entries.where((e) => e.id != id).toList(),
    );
  }
}

final nutritionProvider =
    NotifierProvider<NutritionController, NutritionState>(
  NutritionController.new,
);
