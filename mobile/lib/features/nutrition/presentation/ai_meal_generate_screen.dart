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

  void _selectNextRecommendedMeal() {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedMealTypes.clear();
      _selectedMealTypes.add(_detectDefaultMealType());
      _generatedMeals.clear();
      _addedMealTypes.clear();
    });
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

    final recommendedMeal = _detectDefaultMealType();

    // Calculate smart estimated allocation for selected meals
    final targetKcal = nutritionState.targetCalories;
    final mealWeight = {
      MealType.breakfast: 0.25,
      MealType.lunch: 0.35,
      MealType.dinner: 0.30,
      MealType.snack: 0.10,
    };
    final totalSelectedWeight = _selectedMealTypes.fold<double>(
      0.0,
      (sum, m) => sum + (mealWeight[m] ?? 0.25),
    );
    final estimatedSelectedKcal = (totalSelectedWeight * targetKcal).round();

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
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.aiViolet,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'AI Tạo Bữa Ăn Thông Minh',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── AI Hero Intelligence Banner ──────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.aiViolet.withValues(alpha: 0.18),
                    colors.surfaceContainer,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.aiVioletBorder, width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.aiViolet,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.psychology_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'AI NUTRITION ENGINE',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: colors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          healthProfile.goal.label.split('(').first.trim(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: colors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'AI tự động phân tích calo còn lại trong ngày và thiết kế thực đơn chuẩn macro cá nhân hóa.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: colors.onSurface.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 4 Nutrition Badges (Orange, Cyan, Green, Blue)
                  Row(
                    children: [
                      Expanded(
                        child: _MacroBadge(
                          label: 'Calo thiếu',
                          value: '$remainingKcal',
                          unit: 'kcal',
                          color: AppColors.nutritionCalories,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _MacroBadge(
                          label: 'Protein thiếu',
                          value: remainingProtein.toStringAsFixed(0),
                          unit: 'g',
                          color: AppColors.nutritionProtein,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _MacroBadge(
                          label: 'Carb thiếu',
                          value: remainingCarbs.toStringAsFixed(0),
                          unit: 'g',
                          color: AppColors.nutritionCarbs,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _MacroBadge(
                          label: 'Fat thiếu',
                          value: remainingFat.toStringAsFixed(0),
                          unit: 'g',
                          color: AppColors.nutritionFat,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── 1. Smart Meal Selector Section ───────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'BỮA ĂN CẦN GỢI Ý',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.aiVioletSoft,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${_selectedMealTypes.length} đã chọn',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.aiViolet,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _QuickSelectBtn(
                        label: '⚡ Hiện tại',
                        isSelected:
                            _selectedMealTypes.length == 1 &&
                            _selectedMealTypes.contains(recommendedMeal),
                        onTap: _selectNextRecommendedMeal,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _QuickSelectBtn(
                        label: '🍽️ 3 chính',
                        isSelected:
                            _selectedMealTypes.length == 3 &&
                            _selectedMealTypes.contains(MealType.breakfast) &&
                            _selectedMealTypes.contains(MealType.lunch) &&
                            _selectedMealTypes.contains(MealType.dinner),
                        onTap: _selectMainMeals,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _QuickSelectBtn(
                        label: '✨ Tất cả',
                        isSelected:
                            _selectedMealTypes.length == MealType.values.length,
                        onTap: _selectAllMeals,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Smart Bento Grid for Meal Selection (2x2)
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _SmartMealCard(
                        mealType: MealType.breakfast,
                        title: 'Bữa sáng',
                        timeRange: '06:00 – 09:00',
                        emoji: '🌅',
                        suggestedKcal: (targetKcal * 0.25).round(),
                        loggedEntries: nutritionState.getEntriesByMeal(
                          MealType.breakfast,
                        ),
                        isRecommendedNow: recommendedMeal == MealType.breakfast,
                        isSelected: _selectedMealTypes.contains(
                          MealType.breakfast,
                        ),
                        onToggle: () => _toggleMealType(MealType.breakfast),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SmartMealCard(
                        mealType: MealType.lunch,
                        title: 'Bữa trưa',
                        timeRange: '11:30 – 13:30',
                        emoji: '☀️',
                        suggestedKcal: (targetKcal * 0.35).round(),
                        loggedEntries: nutritionState.getEntriesByMeal(
                          MealType.lunch,
                        ),
                        isRecommendedNow: recommendedMeal == MealType.lunch,
                        isSelected: _selectedMealTypes.contains(MealType.lunch),
                        onToggle: () => _toggleMealType(MealType.lunch),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _SmartMealCard(
                        mealType: MealType.dinner,
                        title: 'Bữa tối',
                        timeRange: '18:00 – 20:30',
                        emoji: '🌙',
                        suggestedKcal: (targetKcal * 0.30).round(),
                        loggedEntries: nutritionState.getEntriesByMeal(
                          MealType.dinner,
                        ),
                        isRecommendedNow: recommendedMeal == MealType.dinner,
                        isSelected: _selectedMealTypes.contains(
                          MealType.dinner,
                        ),
                        onToggle: () => _toggleMealType(MealType.dinner),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SmartMealCard(
                        mealType: MealType.snack,
                        title: 'Bữa phụ',
                        timeRange: '15:00 – 16:30',
                        emoji: '🍎',
                        suggestedKcal: (targetKcal * 0.10).round(),
                        loggedEntries: nutritionState.getEntriesByMeal(
                          MealType.snack,
                        ),
                        isRecommendedNow: recommendedMeal == MealType.snack,
                        isSelected: _selectedMealTypes.contains(MealType.snack),
                        onToggle: () => _toggleMealType(MealType.snack),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // AI Target Allocation Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.pie_chart_outline_rounded,
                    color: AppColors.aiViolet,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Dự kiến phân bổ cho ${_selectedMealTypes.length} bữa đã chọn: ~${remainingKcal > 0 ? (remainingKcal * (totalSelectedWeight / 1.0)).round() : estimatedSelectedKcal} kcal',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── 2. Smart Quick Moods & Dietary Tags ───────────────────────────
            const Text(
              'GỢI Ý KHẨU VỊ & CHẾ ĐỘ ĂN (1 CHẠM)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  _DietaryChip(
                    emoji: '🇻🇳',
                    label: 'Ưu tiên món Việt',
                    isActive: _preferVietnamese,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _preferVietnamese = !_preferVietnamese);
                    },
                  ),
                  const SizedBox(width: 8),
                  _DietaryChip(
                    emoji: '🥩',
                    label: 'Giàu đạm (High-Protein)',
                    isActive: _promptController.text.contains('protein'),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        if (_promptController.text.contains('protein')) {
                          _promptController.clear();
                        } else {
                          _promptController.text =
                              'giàu protein, ít dầu mỡ, tăng cơ';
                        }
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _DietaryChip(
                    emoji: '🥗',
                    label: 'Ít tinh bột (Low-Carb)',
                    isActive: _promptController.text.contains('low carb'),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        if (_promptController.text.contains('low carb')) {
                          _promptController.clear();
                        } else {
                          _promptController.text =
                              'low carb, nhiều rau xanh, hạn chế tinh bột';
                        }
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _DietaryChip(
                    emoji: '🥑',
                    label: 'Eat Clean thanh đạm',
                    isActive: _promptController.text.contains('eat clean'),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        if (_promptController.text.contains('eat clean')) {
                          _promptController.clear();
                        } else {
                          _promptController.text =
                              'eat clean, hấp luộc, thanh nhẹ';
                        }
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _DietaryChip(
                    emoji: '🍲',
                    label: 'Món nước ấm bụng',
                    isActive: _promptController.text.contains('món nước'),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        if (_promptController.text.contains('món nước')) {
                          _promptController.clear();
                        } else {
                          _promptController.text = 'món nước, canh súp ấm nóng';
                        }
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _DietaryChip(
                    emoji: '⏱️',
                    label: '<15 phút',
                    isActive: _prepTimePreference == 'quick',
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(
                        () => _prepTimePreference =
                            _prepTimePreference == 'quick' ? 'any' : 'quick',
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── 3. Custom Free-text Prompt ────────────────────────────────────
            const Text(
              'BẠN ĐANG THÈM GÌ HOẶC CÓ NGUYÊN LIỆU NÀO? (TÙY CHỌN)',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: AppColors.textTertiary,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _promptController,
              decoration: InputDecoration(
                hintText: 'VD: cơm gà, bò xào bông cải, trứng, ức gà...',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                ),
                prefixIcon: const Icon(
                  Icons.restaurant_rounded,
                  size: 20,
                  color: AppColors.aiViolet,
                ),
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
                fillColor: AppColors.surfaceInput,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: colors.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),

            // ── 4. Main Generate Button ──────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.aiViolet.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FilledButton.icon(
                onPressed: _isGenerating ? null : _generateAllSelectedMeals,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.aiViolet,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 0,
                ),
                icon: _isGenerating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.auto_awesome_rounded, size: 22),
                label: Text(
                  _isGenerating
                      ? 'AI đang tính toán ${_selectedMealTypes.length} bữa ăn...'
                      : '✨ Tạo ${_selectedMealTypes.length} bữa ăn với AI',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 26),

            // ── 5. Loading State or Generated Result List ────────────────────
            if (_isGenerating)
              Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.surfaceContainer,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.aiVioletBorder,
                    width: 1.2,
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(
                        color: AppColors.aiViolet,
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'VieGym AI đang thiết kế thực đơn...',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tối ưu hóa ${_selectedMealTypes.length} bữa ăn dựa trên mục tiêu ${healthProfile.goal.label.split("(").first.trim()}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
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
                    color: AppColors.amberSoft,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.amberBorder),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.amber,
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
                                color: AppColors.amber,
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
                    color: colors.surfaceContainer,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.aiVioletBorder,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.aiVioletSoft,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.dashboard_customize_rounded,
                              color: AppColors.aiViolet,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'TỔNG THỰC ĐƠN (${_generatedMeals.length} BỮA)',
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
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: AppColors.nutritionCalories,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Tổng protein: ${totalGeneratedProtein.toStringAsFixed(1)}g',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: colors.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Flexible(
                            child: FilledButton.icon(
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
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
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

class _QuickSelectBtn extends StatelessWidget {
  const _QuickSelectBtn({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withValues(alpha: 0.16)
              : colors.surfaceContainer,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? colors.primary
                : colors.outlineVariant.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? colors.primary : colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _SmartMealCard extends StatelessWidget {
  const _SmartMealCard({
    required this.mealType,
    required this.title,
    required this.timeRange,
    required this.emoji,
    required this.suggestedKcal,
    required this.loggedEntries,
    required this.isRecommendedNow,
    required this.isSelected,
    required this.onToggle,
  });

  final MealType mealType;
  final String title;
  final String timeRange;
  final String emoji;
  final int suggestedKcal;
  final List<FoodEntry> loggedEntries;
  final bool isRecommendedNow;
  final bool isSelected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasLogged = loggedEntries.isNotEmpty;
    final totalLoggedKcal = loggedEntries.fold<int>(
      0,
      (sum, e) => sum + e.calories,
    );

    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withValues(alpha: 0.08)
              : colors.surfaceContainer,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? colors.primary
                : isRecommendedNow
                ? AppColors.aiVioletBorder
                : colors.outlineVariant.withValues(alpha: 0.4),
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Emoji + Title + Selection Indicator
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? colors.primary : colors.onSurface,
                    ),
                  ),
                ),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isSelected ? colors.primary : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? colors.primary
                          : AppColors.textTertiary,
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 13)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Time & Target budget
            Text(
              timeRange,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),

            // Dynamic Status Badge
            if (isRecommendedNow) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.aiVioletSoft,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.alarm_on_rounded,
                      size: 11,
                      color: AppColors.aiViolet,
                    ),
                    SizedBox(width: 3),
                    Text(
                      'Khuyên dùng lúc này',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.aiViolet,
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (hasLogged) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accentEmerald.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Đã nạp $totalLoggedKcal kcal',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accentEmerald,
                  ),
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Gợi ý ~$suggestedKcal kcal',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.nutritionCalories,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DietaryChip extends StatelessWidget {
  const _DietaryChip({
    required this.emoji,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.aiViolet.withValues(alpha: 0.16)
              : colors.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? AppColors.aiViolet
                : colors.outlineVariant.withValues(alpha: 0.4),
            width: isActive ? 1.4 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive ? AppColors.aiViolet : colors.onSurface,
              ),
            ),
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
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
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
        border: Border.all(color: AppColors.aiVioletBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.aiViolet,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'GỢI Ý ${meal.mealType.label.toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: AppColors.aiViolet,
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
                    color: AppColors.surfaceElevated,
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
                          color: AppColors.nutritionCalories,
                        ),
                      ),
                      Text(
                        'P: ${meal.totalProtein}g',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.nutritionProtein,
                        ),
                      ),
                      Text(
                        'C: ${meal.totalCarbs}g',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.nutritionCarbs,
                        ),
                      ),
                      Text(
                        'F: ${meal.totalFat}g',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.nutritionFat,
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
                    color: AppColors.textTertiary,
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
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.nutritionCalories,
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
                    color: AppColors.aiVioletSoft,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.aiVioletBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.psychology_alt_rounded,
                            size: 16,
                            color: AppColors.aiViolet,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Vì sao AI gợi ý?',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.aiViolet,
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
