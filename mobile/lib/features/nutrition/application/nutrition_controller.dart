import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/food_models.dart';

String _formatDate(DateTime d) {
  final year = d.year;
  final month = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

String _formatCurrentTime() {
  final now = DateTime.now();
  final h = now.hour.toString().padLeft(2, '0');
  final m = now.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

class NutritionState {
  const NutritionState({
    required this.selectedDate,
    required this.entries,
    this.targetCalories = 2500,
    this.targetProtein = 160,
    this.targetCarbs = 250,
    this.targetFat = 70,
    this.waterIntakeByDate = const {},
    this.targetWaterMl = 2000,
  });

  final String selectedDate;
  final List<FoodEntry> entries;
  final int targetCalories;
  final double targetProtein;
  final double targetCarbs;
  final double targetFat;
  final Map<String, int> waterIntakeByDate;
  final int targetWaterMl;

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

  double get consumedFat => currentDayEntries.fold(0, (sum, e) => sum + e.fat);

  int get remainingCalories =>
      (targetCalories - consumedCalories).clamp(0, 99999);

  int get waterIntakeMl => waterIntakeByDate[selectedDate] ?? 0;

  int get remainingWaterMl => (targetWaterMl - waterIntakeMl).clamp(0, 99999);

  double get caloriePercentage => targetCalories > 0
      ? (consumedCalories / targetCalories).clamp(0.0, 1.0)
      : 0.0;

  double get proteinPercentage => targetProtein > 0
      ? (consumedProtein / targetProtein).clamp(0.0, 1.0)
      : 0.0;

  double get carbsPercentage =>
      targetCarbs > 0 ? (consumedCarbs / targetCarbs).clamp(0.0, 1.0) : 0.0;

  double get fatPercentage =>
      targetFat > 0 ? (consumedFat / targetFat).clamp(0.0, 1.0) : 0.0;

  double get waterPercentage =>
      targetWaterMl > 0 ? (waterIntakeMl / targetWaterMl).clamp(0.0, 1.0) : 0.0;

  NutritionState copyWith({
    String? selectedDate,
    List<FoodEntry>? entries,
    int? targetCalories,
    double? targetProtein,
    double? targetCarbs,
    double? targetFat,
    Map<String, int>? waterIntakeByDate,
    int? targetWaterMl,
  }) {
    return NutritionState(
      selectedDate: selectedDate ?? this.selectedDate,
      entries: entries ?? this.entries,
      targetCalories: targetCalories ?? this.targetCalories,
      targetProtein: targetProtein ?? this.targetProtein,
      targetCarbs: targetCarbs ?? this.targetCarbs,
      targetFat: targetFat ?? this.targetFat,
      waterIntakeByDate: waterIntakeByDate ?? this.waterIntakeByDate,
      targetWaterMl: targetWaterMl ?? this.targetWaterMl,
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
        foodId: 'food_pho_bo',
        name: 'Phở bò tái nạm',
        mealType: MealType.breakfast,
        calories: 420,
        protein: 28,
        carbs: 55,
        fat: 9,
        servingAmount: 1,
        servingUnit: 'tô vừa',
        imageUrl:
            'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=500&auto=format&fit=crop&q=80',
        date: today,
        loggedTime: '07:30',
      ),
      FoodEntry(
        id: 'entry_2',
        foodId: 'food_ca_phe',
        name: 'Cà phê sữa đá ít đường',
        mealType: MealType.breakfast,
        calories: 85,
        protein: 2,
        carbs: 12,
        fat: 3,
        servingAmount: 1,
        servingUnit: 'ly',
        imageUrl:
            'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=500&auto=format&fit=crop&q=80',
        date: today,
        loggedTime: '08:00',
      ),
      FoodEntry(
        id: 'entry_3',
        foodId: 'food_com_tam_suon',
        name: 'Cơm tấm sườn bì chả',
        mealType: MealType.lunch,
        calories: 685,
        protein: 42,
        carbs: 72,
        fat: 25,
        servingAmount: 1,
        servingUnit: 'dĩa tiêu chuẩn',
        imageUrl:
            'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&auto=format&fit=crop&q=80',
        date: today,
        loggedTime: '12:15',
      ),
      FoodEntry(
        id: 'entry_4',
        foodId: 'food_uc_ga',
        name: 'Ức gà áp chảo sốt tiêu',
        mealType: MealType.dinner,
        calories: 230,
        protein: 31,
        carbs: 2,
        fat: 11,
        servingAmount: 150,
        servingUnit: 'g',
        imageUrl:
            'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=500&auto=format&fit=crop&q=80',
        date: today,
        loggedTime: '19:00',
      ),
      FoodEntry(
        id: 'entry_5',
        foodId: 'food_whey',
        name: 'Whey Protein Isolate',
        mealType: MealType.snack,
        calories: 220,
        protein: 27,
        carbs: 24,
        fat: 2,
        servingAmount: 1,
        servingUnit: 'khẩu phần',
        imageUrl:
            'https://images.unsplash.com/photo-1579722821273-0f6c7d44362f?w=500&auto=format&fit=crop&q=80',
        date: today,
        loggedTime: '16:30',
      ),
    ];

    return NutritionState(
      selectedDate: today,
      entries: initialEntries,
      targetCalories: 2500,
      targetProtein: 160,
      targetCarbs: 250,
      targetFat: 70,
      waterIntakeByDate: {today: 1500},
      targetWaterMl: 2000,
    );
  }

  void selectDate(String date) {
    state = state.copyWith(selectedDate: date);
  }

  void addWater(int amountMl) {
    final current = state.waterIntakeMl;
    final updated = (current + amountMl).clamp(0, 10000);
    final newMap = Map<String, int>.from(state.waterIntakeByDate);
    newMap[state.selectedDate] = updated;
    state = state.copyWith(waterIntakeByDate: newMap);
  }

  void removeWater(int amountMl) {
    final current = state.waterIntakeMl;
    final updated = (current - amountMl).clamp(0, 10000);
    final newMap = Map<String, int>.from(state.waterIntakeByDate);
    newMap[state.selectedDate] = updated;
    state = state.copyWith(waterIntakeByDate: newMap);
  }

  void updateGoals({
    int? targetCalories,
    double? targetProtein,
    double? targetCarbs,
    double? targetFat,
    int? targetWaterMl,
  }) {
    state = state.copyWith(
      targetCalories: targetCalories,
      targetProtein: targetProtein,
      targetCarbs: targetCarbs,
      targetFat: targetFat,
      targetWaterMl: targetWaterMl,
    );
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
    String? loggedTime,
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
      loggedTime: loggedTime ?? _formatCurrentTime(),
    );

    state = state.copyWith(entries: [...state.entries, entry]);
  }

  void addQuickCalories({
    required MealType mealType,
    required int calories,
    String? name,
    double? protein,
    double? carbs,
    double? fat,
  }) {
    final entry = FoodEntry(
      id: 'quick_${DateTime.now().millisecondsSinceEpoch}',
      foodId: 'food_quick_log',
      name: (name != null && name.trim().isNotEmpty)
          ? name.trim()
          : 'Ghi nhanh calo (${mealType.label})',
      mealType: mealType,
      calories: calories,
      protein: protein ?? 0.0,
      carbs: carbs ?? 0.0,
      fat: fat ?? 0.0,
      servingAmount: 1,
      servingUnit: 'khẩu phần',
      imageUrl:
          'https://images.unsplash.com/photo-1498837167922-ddd27525d352?w=500&auto=format&fit=crop&q=80',
      date: state.selectedDate,
      loggedTime: _formatCurrentTime(),
    );

    state = state.copyWith(entries: [...state.entries, entry]);
  }

  void updateFoodEntry({
    required String id,
    required String name,
    required int calories,
    required double protein,
    required double carbs,
    required double fat,
    required double servingAmount,
    required String servingUnit,
  }) {
    state = state.copyWith(
      entries: state.entries.map((e) {
        if (e.id == id) {
          return FoodEntry(
            id: e.id,
            foodId: e.foodId,
            name: name,
            mealType: e.mealType,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            servingAmount: servingAmount,
            servingUnit: servingUnit,
            imageUrl: e.imageUrl,
            date: e.date,
            loggedTime: e.loggedTime,
          );
        }
        return e;
      }).toList(),
    );
  }

  void removeFoodEntry(String id) {
    state = state.copyWith(
      entries: state.entries.where((e) => e.id != id).toList(),
    );
  }
}

final nutritionProvider = NotifierProvider<NutritionController, NutritionState>(
  NutritionController.new,
);
