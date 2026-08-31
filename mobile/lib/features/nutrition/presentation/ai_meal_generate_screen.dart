import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../onboarding/application/health_profile_controller.dart';
import '../application/nutrition_controller.dart';
import '../domain/food_models.dart';

class GeneratedMealIngredient {
  const GeneratedMealIngredient({
    required this.name,
    required this.portion,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.foodId,
    this.imageUrl,
  });

  final String name;
  final String portion;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final String? foodId;
  final String? imageUrl;
}

class GeneratedMealResult {
  const GeneratedMealResult({
    required this.mealName,
    required this.mealType,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.ingredients,
    required this.reason,
    required this.prepTimeMinutes,
    required this.isVietnamese,
  });

  final String mealName;
  final MealType mealType;
  final int totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final List<GeneratedMealIngredient> ingredients;
  final String reason;
  final int prepTimeMinutes;
  final bool isVietnamese;
}

class AiMealGenerateScreen extends ConsumerStatefulWidget {
  const AiMealGenerateScreen({super.key, this.initialMealType});

  final MealType? initialMealType;

  @override
  ConsumerState<AiMealGenerateScreen> createState() =>
      _AiMealGenerateScreenState();
}

class _AiMealGenerateScreenState extends ConsumerState<AiMealGenerateScreen> {
  final Set<MealType> _selectedMealTypes = {};
  String _prepTimePreference = 'any';
  bool _preferVietnamese = true;
  final TextEditingController _promptController = TextEditingController();

  bool _isGenerating = false;
  Map<MealType, GeneratedMealResult> _generatedMeals = {};
  final Set<MealType> _addedMealTypes = {};
  final Map<MealType, int> _variationSeeds = {};

  @override
  void initState() {
    super.initState();
    final defaultType = widget.initialMealType ?? _detectDefaultMealType();
    _selectedMealTypes.add(defaultType);
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  MealType _detectDefaultMealType() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 10) return MealType.breakfast;
    if (hour >= 10 && hour < 14) return MealType.lunch;
    if (hour >= 14 && hour < 17) return MealType.snack;
    return MealType.dinner;
  }

  void _toggleMealType(MealType mealType) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedMealTypes.contains(mealType)) {
        if (_selectedMealTypes.length > 1) {
          _selectedMealTypes.remove(mealType);
          _generatedMeals.remove(mealType);
          _addedMealTypes.remove(mealType);
        }
      } else {
        _selectedMealTypes.add(mealType);
      }
    });
  }

  void _selectAllMeals() {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedMealTypes.addAll(MealType.values);
    });
  }

  void _selectMainMeals() {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedMealTypes.clear();
      _selectedMealTypes.addAll([
        MealType.breakfast,
        MealType.lunch,
        MealType.dinner,
      ]);
      _generatedMeals.clear();
      _addedMealTypes.clear();
    });
  }

  Future<void> _generateAllSelectedMeals() async {
    if (_selectedMealTypes.isEmpty) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _isGenerating = true;
      _addedMealTypes.clear();
    });

    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    final nutritionState = ref.read(nutritionProvider);
    final healthProfile = ref.read(healthProfileProvider);

    final remainingKcal = nutritionState.remainingCalories;
    final targetKcal = nutritionState.targetCalories;
    final remainingP =
        (nutritionState.targetProtein - nutritionState.consumedProtein).clamp(
          0.0,
          300.0,
        );
    final fitnessGoal = healthProfile.goal;
    final customQuery = _promptController.text.trim().toLowerCase();

    final newResults = <MealType, GeneratedMealResult>{};

    for (final mealType in _selectedMealTypes) {
      final seed = _variationSeeds[mealType] ?? 0;
      final meal = _computeSmartMeal(
        mealType: mealType,
        remainingCalories: remainingKcal > 0
            ? remainingKcal
            : (targetKcal / 3).round(),
        remainingProtein: remainingP,
        goalLabel: fitnessGoal.label,
        preferVietnamese: _preferVietnamese,
        prepTime: _prepTimePreference,
        customQuery: customQuery,
        variation: seed,
      );
      newResults[mealType] = meal;
    }

    setState(() {
      _isGenerating = false;
      _generatedMeals = newResults;
    });
  }

  void _regenerateSingleMeal(MealType mealType) {
    HapticFeedback.selectionClick();
    final currentSeed = _variationSeeds[mealType] ?? 0;
    _variationSeeds[mealType] = currentSeed + 1;

    final nutritionState = ref.read(nutritionProvider);
    final healthProfile = ref.read(healthProfileProvider);

    final remainingKcal = nutritionState.remainingCalories;
    final targetKcal = nutritionState.targetCalories;
    final remainingP =
        (nutritionState.targetProtein - nutritionState.consumedProtein).clamp(
          0.0,
          300.0,
        );
    final fitnessGoal = healthProfile.goal;
    final customQuery = _promptController.text.trim().toLowerCase();

    final newMeal = _computeSmartMeal(
      mealType: mealType,
      remainingCalories: remainingKcal > 0
          ? remainingKcal
          : (targetKcal / 3).round(),
      remainingProtein: remainingP,
      goalLabel: fitnessGoal.label,
      preferVietnamese: _preferVietnamese,
      prepTime: _prepTimePreference,
      customQuery: customQuery,
      variation: _variationSeeds[mealType]!,
    );

    setState(() {
      _generatedMeals[mealType] = newMeal;
      _addedMealTypes.remove(mealType);
    });
  }

  Future<bool> _showCalorieLimitDialog({
    required BuildContext context,
    required int remainingKcal,
    required int itemCalories,
    required String itemName,
    required int excessKcal,
  }) async {
    final colors = Theme.of(context).colorScheme;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          icon: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.accentAmber.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.accentAmber,
              size: 28,
            ),
          ),
          title: const Text(
            'Lượng calo sắp đạt chỉ tiêu',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Lượng calo còn lại hôm nay chỉ còn $remainingKcal kcal. Thêm $itemName (+$itemCalories kcal) sẽ khiến bạn ${excessKcal > 0 ? "vượt chỉ tiêu $excessKcal kcal" : "đạt ngưỡng tối đa"} trong ngày.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.45,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accentAmber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.accentAmber.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.accentAmber,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Không khuyến khích thêm món ăn nếu bạn đang muốn duy trì hoặc giảm mỡ.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentAmber,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: BorderSide(
                        color: colors.outlineVariant.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Text(
                      'Hủy',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accentAmber,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Vẫn thêm',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<void> _handleAddSingleMeal(GeneratedMealResult meal) async {
    final nutritionState = ref.read(nutritionProvider);
    final remainingKcal = nutritionState.remainingCalories;
    final willExceed =
        (nutritionState.consumedCalories + meal.totalCalories) >
        nutritionState.targetCalories;
    final isVeryLowRemaining =
        remainingKcal <= 100 || meal.totalCalories > remainingKcal;

    if (willExceed || isVeryLowRemaining) {
      final excessKcal =
          (nutritionState.consumedCalories + meal.totalCalories) -
          nutritionState.targetCalories;

      final proceed = await _showCalorieLimitDialog(
        context: context,
        remainingKcal: remainingKcal,
        itemCalories: meal.totalCalories,
        itemName: 'món "${meal.mealName}"',
        excessKcal: excessKcal,
      );

      if (!proceed) return;
    }

    final notifier = ref.read(nutritionProvider.notifier);

    for (final item in meal.ingredients) {
      notifier.addFoodEntry(
        foodId:
            item.foodId ?? 'food_ai_${DateTime.now().millisecondsSinceEpoch}',
        name: item.name,
        mealType: meal.mealType,
        calories: item.calories,
        protein: item.protein,
        carbs: item.carbs,
        fat: item.fat,
        servingAmount: 1,
        servingUnit: item.portion,
        imageUrl:
            item.imageUrl ??
            'https://images.unsplash.com/photo-1498837167922-ddd27525d352?w=500&auto=format&fit=crop&q=80',
      );
    }

    HapticFeedback.heavyImpact();
    setState(() => _addedMealTypes.add(meal.mealType));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã thêm "${meal.mealName}" (${meal.totalCalories} kcal) vào ${meal.mealType.label}!',
        ),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Xem nhật ký',
          onPressed: () {
            if (GoRouter.maybeOf(context) != null && context.canPop()) {
              context.pop();
            } else if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/meal');
            }
          },
        ),
      ),
    );
  }

  Future<void> _handleAddAllMeals() async {
    final nutritionState = ref.read(nutritionProvider);
    final remainingKcal = nutritionState.remainingCalories;

    final unaddedMeals = _generatedMeals.values
        .where((m) => !_addedMealTypes.contains(m.mealType))
        .toList();
    if (unaddedMeals.isEmpty) return;

    final totalAddKcal = unaddedMeals.fold(
      0,
      (sum, meal) => sum + meal.totalCalories,
    );
    final willExceed =
        (nutritionState.consumedCalories + totalAddKcal) >
        nutritionState.targetCalories;
    final isVeryLowRemaining =
        remainingKcal <= 100 || totalAddKcal > remainingKcal;

    if (willExceed || isVeryLowRemaining) {
      final excessKcal =
          (nutritionState.consumedCalories + totalAddKcal) -
          nutritionState.targetCalories;

      final proceed = await _showCalorieLimitDialog(
        context: context,
        remainingKcal: remainingKcal,
        itemCalories: totalAddKcal,
        itemName: 'kế hoạch ${unaddedMeals.length} bữa ăn',
        excessKcal: excessKcal,
      );

      if (!proceed) return;
    }

    final notifier = ref.read(nutritionProvider.notifier);
    int totalCount = 0;
    int totalKcal = 0;

    for (final meal in unaddedMeals) {
      for (final item in meal.ingredients) {
        notifier.addFoodEntry(
          foodId:
              item.foodId ?? 'food_ai_${DateTime.now().millisecondsSinceEpoch}',
          name: item.name,
          mealType: meal.mealType,
          calories: item.calories,
          protein: item.protein,
          carbs: item.carbs,
          fat: item.fat,
          servingAmount: 1,
          servingUnit: item.portion,
          imageUrl:
              item.imageUrl ??
              'https://images.unsplash.com/photo-1498837167922-ddd27525d352?w=500&auto=format&fit=crop&q=80',
        );
      }
      totalCount++;
      totalKcal += meal.totalCalories;
      _addedMealTypes.add(meal.mealType);
    }

    HapticFeedback.heavyImpact();
    setState(() {});

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã thêm $totalCount bữa ăn ($totalKcal kcal) vào thực đơn hôm nay!',
        ),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Xem nhật ký',
          onPressed: () {
            if (GoRouter.maybeOf(context) != null && context.canPop()) {
              context.pop();
            } else if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/meal');
            }
          },
        ),
      ),
    );
  }

  GeneratedMealResult _computeSmartMeal({
    required MealType mealType,
    required int remainingCalories,
    required double remainingProtein,
    required String goalLabel,
    required bool preferVietnamese,
    required String prepTime,
    required String customQuery,
    required int variation,
  }) {
    if (mealType == MealType.breakfast) {
      final options = [
        GeneratedMealResult(
          mealName: 'Phở bò tái nạm & Trứng chần',
          mealType: MealType.breakfast,
          totalCalories: 510,
          totalProtein: 36.0,
          totalCarbs: 58.0,
          totalFat: 14.0,
          prepTimeMinutes: 15,
          isVietnamese: true,
          ingredients: const [
            GeneratedMealIngredient(
              name: 'Phở bò tái nạm (bánh phở tươi & bò mềm)',
              portion: '1 tô vừa',
              calories: 430,
              protein: 29.0,
              carbs: 56.0,
              fat: 10.0,
              foodId: 'food_pho_bo',
              imageUrl:
                  'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=500&auto=format&fit=crop&q=80',
            ),
            GeneratedMealIngredient(
              name: 'Trứng gà chần nước dùng',
              portion: '1 quả',
              calories: 80,
              protein: 7.0,
              carbs: 2.0,
              fat: 4.0,
              foodId: 'food_trung_luoc',
            ),
          ],
          reason:
              'Phở bò cung cấp carb chuyển hóa nhanh và protein dồi dào, giúp nạp đầy glycogen cơ bắp ngay đầu ngày cho mục tiêu $goalLabel.',
        ),
        GeneratedMealResult(
          mealName: 'Bánh mì ức gà xé & Trứng ốp la',
          mealType: MealType.breakfast,
          totalCalories: 480,
          totalProtein: 38.0,
          totalCarbs: 50.0,
          totalFat: 13.0,
          prepTimeMinutes: 10,
          isVietnamese: true,
          ingredients: const [
            GeneratedMealIngredient(
              name: 'Bánh mì nguyên cám',
              portion: '1 ổ vừa',
              calories: 210,
              protein: 6.0,
              carbs: 42.0,
              fat: 2.0,
              foodId: 'food_banh_mi_thit',
              imageUrl:
                  'https://images.unsplash.com/photo-1626804475297-41608ea09aeb?w=500&auto=format&fit=crop&q=80',
            ),
            GeneratedMealIngredient(
              name: 'Ức gà xé áp chảo sốt tiêu',
              portion: '100g',
              calories: 165,
              protein: 30.0,
              carbs: 0.0,
              fat: 3.5,
              foodId: 'food_uc_ga',
            ),
            GeneratedMealIngredient(
              name: 'Trứng gà ốp la ít dầu + Dưa leo & Ngò',
              portion: '1 quả',
              calories: 105,
              protein: 2.0,
              carbs: 8.0,
              fat: 7.5,
              foodId: 'food_trung_luoc',
            ),
          ],
          reason:
              'Chuẩn bị siêu nhanh dưới 10 phút, giàu protein nạc và carb sạch, rất phù hợp khi bạn cần ăn sáng nhanh trước giờ làm việc/tập luyện.',
        ),
        GeneratedMealResult(
          mealName: 'Yến mạch ngâm sữa chua & Chuối già',
          mealType: MealType.breakfast,
          totalCalories: 395,
          totalProtein: 24.0,
          totalCarbs: 62.0,
          totalFat: 6.5,
          prepTimeMinutes: 5,
          isVietnamese: false,
          ingredients: const [
            GeneratedMealIngredient(
              name: 'Yến mạch cán dẹt',
              portion: '50g',
              calories: 190,
              protein: 6.5,
              carbs: 34.0,
              fat: 3.0,
            ),
            GeneratedMealIngredient(
              name: 'Sữa chua Hy Lạp không đường',
              portion: '1 hũ (150g)',
              calories: 100,
              protein: 16.0,
              carbs: 4.0,
              fat: 0.5,
            ),
            GeneratedMealIngredient(
              name: 'Chuối chín cắt lát',
              portion: '1 trái vừa',
              calories: 105,
              protein: 1.5,
              carbs: 24.0,
              fat: 3.0,
              foodId: 'food_chuoi',
              imageUrl:
                  'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=500&auto=format&fit=crop&q=80',
            ),
          ],
          reason:
              'Bữa sáng nhẹ bụng, dồi dào chất xơ beta-glucan và probiotic hỗ trợ tiêu hóa êm ái, cung cấp năng lượng giải phóng chậm.',
        ),
      ];
      return options[variation % options.length];
    }

    if (mealType == MealType.snack) {
      final options = [
        GeneratedMealResult(
          mealName: 'Whey Protein Shake & Chuối già',
          mealType: MealType.snack,
          totalCalories: 225,
          totalProtein: 28.3,
          totalCarbs: 28.5,
          totalFat: 0.8,
          prepTimeMinutes: 3,
          isVietnamese: false,
          ingredients: const [
            GeneratedMealIngredient(
              name: 'Whey Protein Isolate',
              portion: '1 muỗng (30g)',
              calories: 120,
              protein: 27.0,
              carbs: 1.5,
              fat: 0.5,
              foodId: 'food_whey',
              imageUrl:
                  'https://images.unsplash.com/photo-1579722821273-0f6c7d44362f?w=500&auto=format&fit=crop&q=80',
            ),
            GeneratedMealIngredient(
              name: 'Chuối già Nam Mỹ',
              portion: '1 trái (120g)',
              calories: 105,
              protein: 1.3,
              carbs: 27.0,
              fat: 0.3,
              foodId: 'food_chuoi',
            ),
          ],
          reason:
              'Nạp đạm siêu nhanh chống dị hóa cơ và bù đắp khoáng Kali chống chuột rút, lý tưởng dùng trước hoặc sau buổi tập.',
        ),
        GeneratedMealResult(
          mealName: 'Trứng gà luộc & Khoai lang hấp',
          mealType: MealType.snack,
          totalCalories: 286,
          totalProtein: 15.2,
          totalCarbs: 31.1,
          totalFat: 11.2,
          prepTimeMinutes: 12,
          isVietnamese: true,
          ingredients: const [
            GeneratedMealIngredient(
              name: 'Trứng gà luộc',
              portion: '2 quả',
              calories: 156,
              protein: 13.0,
              carbs: 1.1,
              fat: 11.0,
              foodId: 'food_trung_luoc',
              imageUrl:
                  'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=500&auto=format&fit=crop&q=80',
            ),
            GeneratedMealIngredient(
              name: 'Khoai lang luộc',
              portion: '1 củ vừa (150g)',
              calories: 130,
              protein: 2.2,
              carbs: 30.0,
              fat: 0.2,
              foodId: 'food_khoai_lang',
            ),
          ],
          reason:
              'Món ăn nhẹ truyền thống quen thuộc, nguồn carb chậm GI thấp giúp bạn không bị tụt đường huyết giữa giờ làm việc.',
        ),
      ];
      return options[variation % options.length];
    }

    if (mealType == MealType.dinner) {
      final options = [
        GeneratedMealResult(
          mealName: 'Cá hồi áp chảo, Khoai lang & Salad dầu ô liu',
          mealType: MealType.dinner,
          totalCalories: 515,
          totalProtein: 37.5,
          totalCarbs: 34.0,
          totalFat: 20.2,
          prepTimeMinutes: 20,
          isVietnamese: false,
          ingredients: const [
            GeneratedMealIngredient(
              name: 'Phi lê cá hồi áp chảo',
              portion: '150g',
              calories: 310,
              protein: 34.0,
              carbs: 0.0,
              fat: 18.0,
              foodId: 'food_ca_hoi',
              imageUrl:
                  'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=500&auto=format&fit=crop&q=80',
            ),
            GeneratedMealIngredient(
              name: 'Khoai lang luộc / nướng',
              portion: '1 củ (150g)',
              calories: 130,
              protein: 2.2,
              carbs: 30.0,
              fat: 0.2,
              foodId: 'food_khoai_lang',
            ),
            GeneratedMealIngredient(
              name: 'Xà lách cà chua bi sốt dầu ô liu',
              portion: '1 dĩa lớn',
              calories: 75,
              protein: 1.3,
              carbs: 4.0,
              fat: 2.0,
            ),
          ],
          reason:
              'Giàu axit béo Omega-3 chống viêm cơ bắp, lượng tinh bột vừa phải giúp giấc ngủ sâu hơn và tối ưu hóa tổng hợp protein ban đêm.',
        ),
        GeneratedMealResult(
          mealName: 'Ức gà áp chảo sốt tiêu đen & Canh rau củ',
          mealType: MealType.dinner,
          totalCalories: 462,
          totalProtein: 51.0,
          totalCarbs: 48.0,
          totalFat: 6.8,
          prepTimeMinutes: 18,
          isVietnamese: true,
          ingredients: const [
            GeneratedMealIngredient(
              name: 'Ức gà áp chảo',
              portion: '150g',
              calories: 247,
              protein: 46.0,
              carbs: 0.0,
              fat: 5.0,
              foodId: 'food_uc_ga',
              imageUrl:
                  'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=500&auto=format&fit=crop&q=80',
            ),
            GeneratedMealIngredient(
              name: 'Cơm gạo lứt',
              portion: '1 chén vừa (150g)',
              calories: 215,
              protein: 5.0,
              carbs: 45.0,
              fat: 1.8,
              foodId: 'food_gao_lut',
            ),
          ],
          reason:
              'Bữa tối thanh đạm giàu đạm nạc, hỗ trợ bù đắp protein còn thiếu trong ngày mà không gây tích mỡ thừa.',
        ),
      ];
      return options[variation % options.length];
    }

    final lunchOptions = [
      GeneratedMealResult(
        mealName: 'Cơm gạo lứt ức gà áp chảo & Rau củ luộc',
        mealType: MealType.lunch,
        totalCalories: 512,
        totalProtein: 52.5,
        totalCarbs: 48.0,
        totalFat: 7.2,
        prepTimeMinutes: 18,
        isVietnamese: true,
        ingredients: const [
          GeneratedMealIngredient(
            name: 'Ức gà phi lê áp chảo',
            portion: '150g',
            calories: 247,
            protein: 46.0,
            carbs: 0.0,
            fat: 5.0,
            foodId: 'food_uc_ga',
            imageUrl:
                'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=500&auto=format&fit=crop&q=80',
          ),
          GeneratedMealIngredient(
            name: 'Cơm gạo lứt huyết rồng',
            portion: '1 chén (150g)',
            calories: 215,
            protein: 5.0,
            carbs: 45.0,
            fat: 1.8,
            foodId: 'food_gao_lut',
            imageUrl:
                'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=500&auto=format&fit=crop&q=80',
          ),
          GeneratedMealIngredient(
            name: 'Bông cải xanh & Cà rốt luộc',
            portion: '150g',
            calories: 50,
            protein: 1.5,
            carbs: 3.0,
            fat: 0.4,
          ),
        ],
        reason:
            'Cung cấp hơn 50g protein tinh khiết và carb phức giải phóng chậm, vừa vặn bù đắp năng lượng tiêu hao mà vẫn nằm trong ngưỡng mục tiêu $goalLabel.',
      ),
      GeneratedMealResult(
        mealName: 'Bún bò bắp hoa & Rau sống tươi',
        mealType: MealType.lunch,
        totalCalories: 520,
        totalProtein: 33.0,
        totalCarbs: 58.0,
        totalFat: 17.0,
        prepTimeMinutes: 15,
        isVietnamese: true,
        ingredients: const [
          GeneratedMealIngredient(
            name: 'Bún bò Huế bắp hoa tươi',
            portion: '1 tô vừa',
            calories: 520,
            protein: 33.0,
            carbs: 58.0,
            fat: 17.0,
            foodId: 'food_bun_bo_hue',
            imageUrl:
                'https://images.unsplash.com/photo-1569058242253-92a9c755a0ec?w=500&auto=format&fit=crop&q=80',
          ),
        ],
        reason:
            'Món ăn truyền thống đậm đà, cung cấp đầy đủ đạm từ thịt bò nạc và năng lượng dồi dào cho buổi chiều năng động.',
      ),
      GeneratedMealResult(
        mealName: 'Cơm tấm sườn nướng ít mỡ & Trứng hấp',
        mealType: MealType.lunch,
        totalCalories: 640,
        totalProtein: 39.0,
        totalCarbs: 70.0,
        totalFat: 23.0,
        prepTimeMinutes: 15,
        isVietnamese: true,
        ingredients: const [
          GeneratedMealIngredient(
            name: 'Cơm tấm sườn nướng mỡ hành vừa',
            portion: '1 dĩa tiêu chuẩn',
            calories: 640,
            protein: 39.0,
            carbs: 70.0,
            fat: 23.0,
            foodId: 'food_com_tam_suon',
            imageUrl:
                'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&auto=format&fit=crop&q=80',
          ),
        ],
        reason:
            'Bữa ăn giàu calo và dinh dưỡng, rất thích hợp cho những ngày tập nặng cần nạp nhiều carbohydrate và protein.',
      ),
    ];

    return lunchOptions[variation % lunchOptions.length];
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final nutritionState = ref.watch(nutritionProvider);
    final healthProfile = ref.watch(healthProfileProvider);

    final remainingKcal = nutritionState.remainingCalories;
    final remainingProtein =
        (nutritionState.targetProtein - nutritionState.consumedProtein).clamp(
          0.0,
          300.0,
        );
    final remainingCarbs =
        (nutritionState.targetCarbs - nutritionState.consumedCarbs).clamp(
          0.0,
          500.0,
        );
    final remainingFat = (nutritionState.targetFat - nutritionState.consumedFat)
        .clamp(0.0, 200.0);

    final totalGeneratedCalories = _generatedMeals.values.fold(
      0,
      (sum, meal) => sum + meal.totalCalories,
    );
    final totalGeneratedProtein = _generatedMeals.values.fold(
      0.0,
      (sum, meal) => sum + meal.totalProtein,
    );

    final allAdded =
        _generatedMeals.isNotEmpty &&
        _generatedMeals.keys.every(_addedMealTypes.contains);

    final willExceedPlan =
        (nutritionState.consumedCalories + totalGeneratedCalories) >
        nutritionState.targetCalories;
    final isVeryLowRemaining =
        remainingKcal <= 100 || totalGeneratedCalories > remainingKcal;
    final excessKcal =
        (nutritionState.consumedCalories + totalGeneratedCalories) -
        nutritionState.targetCalories;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (GoRouter.maybeOf(context) != null && context.canPop()) {
              context.pop();
            } else if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/meal');
            }
          },
        ),
        title: const Text(
          'AI tạo bữa ăn',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header description
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.accentAmber.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.accentAmber,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Chọn một hoặc nhiều bữa trong ngày. VieGym AI sẽ tính toán và phân bổ thực đơn cân bằng cho bạn.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 1. Multi-Select Meal Type Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'CHỌN CÁC BỮA CẦN GỢI Ý',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF7E849E),
                    letterSpacing: 0.8,
                  ),
                ),
                Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: _selectMainMeals,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        child: Text(
                          '3 bữa chính',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: colors.primary,
                          ),
                        ),
                      ),
                    ),
                    const Text(' • ', style: TextStyle(color: Colors.grey)),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: _selectAllMeals,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        child: Text(
                          'Tất cả',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: colors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MealType.values.map((m) {
                final isSelected = _selectedMealTypes.contains(m);
                return FilterChip(
                  label: Text(m.label),
                  selected: isSelected,
                  selectedColor: colors.primary,
                  showCheckmark: true,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : colors.onSurface,
                  ),
                  backgroundColor: colors.surfaceContainer,
                  side: BorderSide(
                    color: isSelected
                        ? colors.primary
                        : colors.outlineVariant.withValues(alpha: 0.4),
                  ),
                  onSelected: (_) => _toggleMealType(m),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // 2. Nutrition Target Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'DINH DƯỠNG CÒN LẠI HÔM NAY',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF7E849E),
                          letterSpacing: 0.6,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          healthProfile.goal.label.split('(').first.trim(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: colors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _MacroBadge(
                          label: 'Calo còn lại',
                          value: '$remainingKcal',
                          unit: 'kcal',
                          color: AppColors.accentAmber,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MacroBadge(
                          label: 'Protein thiếu',
                          value: remainingProtein.toStringAsFixed(0),
                          unit: 'g',
                          color: AppColors.accentBlue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MacroBadge(
                          label: 'Carb thiếu',
                          value: remainingCarbs.toStringAsFixed(0),
                          unit: 'g',
                          color: AppColors.accentEmerald,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MacroBadge(
                          label: 'Fat thiếu',
                          value: remainingFat.toStringAsFixed(0),
                          unit: 'g',
                          color: const Color(0xFFF97316),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Optional Preferences
            const Text(
              'TÙY CHỌN & ƯU TIÊN',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF7E849E),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [Text('🇻🇳 '), Text('Ưu tiên món Việt')],
                  ),
                  selected: _preferVietnamese,
                  selectedColor: colors.primary.withValues(alpha: 0.16),
                  checkmarkColor: colors.primary,
                  labelStyle: TextStyle(
                    fontSize: 12.5,
                    fontWeight: _preferVietnamese
                        ? FontWeight.w800
                        : FontWeight.w600,
                    color: _preferVietnamese
                        ? colors.primary
                        : colors.onSurface,
                  ),
                  side: BorderSide(
                    color: _preferVietnamese
                        ? colors.primary
                        : colors.outlineVariant.withValues(alpha: 0.4),
                  ),
                  onSelected: (val) {
                    HapticFeedback.selectionClick();
                    setState(() => _preferVietnamese = val);
                  },
                ),
                ChoiceChip(
                  label: const Text('⏱️ < 15 phút'),
                  selected: _prepTimePreference == 'quick',
                  selectedColor: colors.primary.withValues(alpha: 0.16),
                  labelStyle: TextStyle(
                    fontSize: 12.5,
                    fontWeight: _prepTimePreference == 'quick'
                        ? FontWeight.w800
                        : FontWeight.w600,
                    color: _prepTimePreference == 'quick'
                        ? colors.primary
                        : colors.onSurface,
                  ),
                  side: BorderSide(
                    color: _prepTimePreference == 'quick'
                        ? colors.primary
                        : colors.outlineVariant.withValues(alpha: 0.4),
                  ),
                  onSelected: (val) {
                    HapticFeedback.selectionClick();
                    setState(() => _prepTimePreference = val ? 'quick' : 'any');
                  },
                ),
                ChoiceChip(
                  label: const Text('⏱️ 15–30 phút'),
                  selected: _prepTimePreference == 'medium',
                  selectedColor: colors.primary.withValues(alpha: 0.16),
                  labelStyle: TextStyle(
                    fontSize: 12.5,
                    fontWeight: _prepTimePreference == 'medium'
                        ? FontWeight.w800
                        : FontWeight.w600,
                    color: _prepTimePreference == 'medium'
                        ? colors.primary
                        : colors.onSurface,
                  ),
                  side: BorderSide(
                    color: _prepTimePreference == 'medium'
                        ? colors.primary
                        : colors.outlineVariant.withValues(alpha: 0.4),
                  ),
                  onSelected: (val) {
                    HapticFeedback.selectionClick();
                    setState(
                      () => _prepTimePreference = val ? 'medium' : 'any',
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 4. Optional Free-Text Input
            const Text(
              'BẠN MUỐN ĂN GÌ? (TÙY CHỌN)',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF7E849E),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _promptController,
              decoration: InputDecoration(
                hintText: 'VD: cơm gà, món nước, ít dầu mỡ, dễ nấu...',
                prefixIcon: const Icon(Icons.restaurant_menu_rounded, size: 20),
                suffixIcon: _promptController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _promptController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                isDense: true,
                filled: true,
                fillColor: const Color(0xFF141724),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: colors.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),

            // 5. Generate Button
            FilledButton.icon(
              onPressed: _isGenerating ? null : _generateAllSelectedMeals,
              style: FilledButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: _isGenerating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.auto_awesome_rounded, size: 20),
              label: Text(
                _isGenerating
                    ? 'AI đang tạo ${_selectedMealTypes.length} bữa ăn...'
                    : '✨ Tạo ${_selectedMealTypes.length} bữa ăn với AI',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 6. Loading State or Generated Result List
            if (_isGenerating)
              Container(
                padding: const EdgeInsets.all(28),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'VieGym AI đang tính toán và phân bổ dinh dưỡng cho ${_selectedMealTypes.length} bữa ăn...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            else if (_generatedMeals.isNotEmpty) ...[
              // Calorie limit warning banner if total exceeds or remaining <= 100
              if (willExceedPlan || isVeryLowRemaining) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.accentAmber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.accentAmber.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.accentAmber,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Lượng calo sắp đạt chỉ tiêu trong ngày',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.accentAmber,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Calo còn lại: $remainingKcal kcal. Thêm thực đơn này (+$totalGeneratedCalories kcal) sẽ khiến bạn ${excessKcal > 0 ? "vượt chỉ tiêu $excessKcal kcal" : "chạm mức tối đa"}. Không khuyến khích thêm món ăn nếu bạn đang muốn duy trì hoặc giảm mỡ.',
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.4,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Combined Plan Summary Card if > 1 meal
              if (_generatedMeals.length > 1) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colors.primary.withValues(alpha: 0.15),
                        colors.surfaceContainer,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.dashboard_customize_rounded,
                            color: AppColors.accentAmber,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'TỔNG KẾ HOẠCH (${_generatedMeals.length} BỮA ĂN)',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '🔥 $totalGeneratedCalories kcal',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: AppColors.accentAmber,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Tổng protein: ${totalGeneratedProtein.toStringAsFixed(1)}g',
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          FilledButton.icon(
                            onPressed: allAdded ? null : _handleAddAllMeals,
                            style: FilledButton.styleFrom(
                              backgroundColor: allAdded
                                  ? AppColors.accentEmerald
                                  : colors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: Icon(
                              allAdded
                                  ? Icons.check_circle_rounded
                                  : Icons.playlist_add_check_rounded,
                              size: 16,
                            ),
                            label: Text(
                              allAdded
                                  ? 'Đã thêm tất cả ✓'
                                  : 'Thêm tất cả (${_generatedMeals.length})',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Render each meal card
              ...MealType.values
                  .where((m) => _generatedMeals.containsKey(m))
                  .map((mealType) {
                    final meal = _generatedMeals[mealType]!;
                    final isAdded = _addedMealTypes.contains(mealType);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _GeneratedMealCard(
                        meal: meal,
                        isAdded: isAdded,
                        onAddMeal: () => _handleAddSingleMeal(meal),
                        onRegenerate: () => _regenerateSingleMeal(mealType),
                      ),
                    );
                  }),
            ],
          ],
        ),
      ),
    );
  }
}

class _MacroBadge extends StatelessWidget {
  const _MacroBadge({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  final String label;
  final String value;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: Color(0xFF9E9E9E)),
          ),
          const SizedBox(height: 3),
          Text(
            '$value $unit',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _GeneratedMealCard extends StatelessWidget {
  const _GeneratedMealCard({
    required this.meal,
    required this.isAdded,
    required this.onAddMeal,
    required this.onRegenerate,
  });

  final GeneratedMealResult meal;
  final bool isAdded;
  final VoidCallback onAddMeal;
  final VoidCallback onRegenerate;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.accentAmber,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'GỢI Ý ${meal.mealType.label.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: colors.primary,
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                Text(
                  '⏱️ ~${meal.prepTimeMinutes} phút',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Meal Title
                Text(
                  meal.mealName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 10),

                // Total Nutrition Pills
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141724),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colors.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        '🔥 ${meal.totalCalories} kcal',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.accentAmber,
                        ),
                      ),
                      Text(
                        'P: ${meal.totalProtein}g',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.accentBlue,
                        ),
                      ),
                      Text(
                        'C: ${meal.totalCarbs}g',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.accentEmerald,
                        ),
                      ),
                      Text(
                        'F: ${meal.totalFat}g',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFF97316),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Ingredients / Components
                const Text(
                  'KHẨU PHẦN & NGUYÊN LIỆU:',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF7E849E),
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 8),
                ...meal.ingredients.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${item.name} (${item.portion})',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          '${item.calories} kcal',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 14),

                // AI Reason
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.psychology_alt_rounded,
                            size: 16,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Vì sao AI gợi ý?',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: colors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        meal.reason,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.4,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Action Buttons: [ Tạo gợi ý khác ] & [ + Thêm vào bữa ăn ]
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onRegenerate,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          side: BorderSide(
                            color: colors.outlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text(
                          'Gợi ý khác',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: FilledButton.icon(
                        onPressed: isAdded ? null : onAddMeal,
                        style: FilledButton.styleFrom(
                          backgroundColor: isAdded
                              ? AppColors.accentEmerald
                              : colors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: Icon(
                          isAdded
                              ? Icons.check_circle_rounded
                              : Icons.add_circle_outline_rounded,
                          size: 18,
                        ),
                        label: Text(
                          isAdded
                              ? 'Đã thêm vào ${meal.mealType.label} ✓'
                              : 'Thêm vào ${meal.mealType.label}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
