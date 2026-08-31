import '../domain/food_models.dart';

const masterFoodCatalog = <FoodItem>[
  // Vietnamese Meals
  FoodItem(
    id: 'food_pho_bo',
    name: 'Phở bò tái nạm',
    category: FoodCategory.vietnamese,
    baseServingUnit: 'tô vừa',
    baseCalories: 430,
    baseProtein: 29,
    baseCarbs: 56,
    baseFat: 10,
    imageUrl:
        'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=500&auto=format&fit=crop&q=80',
    description:
        'Phở bò truyền thống với bánh phở tươi, thịt bò tái nạm và nước dùng thanh ngọt đậm đà.',
    servingOptions: [
      ServingOption(
        id: 'opt_pho_standard',
        name: '1 tô vừa (tiêu chuẩn)',
        multiplier: 1.0,
        grams: 550,
        isDefault: true,
      ),
      ServingOption(
        id: 'opt_pho_large',
        name: '1 tô lớn (nhiều thịt)',
        multiplier: 1.35,
        grams: 750,
      ),
      ServingOption(
        id: 'opt_pho_small',
        name: '1 tô nhỏ',
        multiplier: 0.75,
        grams: 400,
      ),
    ],
  ),
  FoodItem(
    id: 'food_bun_bo_hue',
    name: 'Bún bò Huế',
    category: FoodCategory.vietnamese,
    baseServingUnit: 'tô vừa',
    baseCalories: 520,
    baseProtein: 33,
    baseCarbs: 58,
    baseFat: 17,
    imageUrl:
        'https://images.unsplash.com/photo-1569058242253-92a9c755a0ec?w=500&auto=format&fit=crop&q=80',
    description:
        'Bún bò Huế cay nồng thơm mùi sả mắm ruốc, ăn kèm thịt bò bắp, chả cua và rau sống.',
    servingOptions: [
      ServingOption(
        id: 'opt_bun_bo_std',
        name: '1 tô vừa',
        multiplier: 1.0,
        grams: 600,
        isDefault: true,
      ),
      ServingOption(
        id: 'opt_bun_bo_large',
        name: '1 tô đặc biệt (giò, chả)',
        multiplier: 1.4,
        grams: 850,
      ),
    ],
  ),
  FoodItem(
    id: 'food_com_tam_suon',
    name: 'Cơm tấm sườn bì chả',
    category: FoodCategory.vietnamese,
    baseServingUnit: 'dĩa',
    baseCalories: 640,
    baseProtein: 39,
    baseCarbs: 70,
    baseFat: 23,
    imageUrl:
        'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&auto=format&fit=crop&q=80',
    description:
        'Cơm tấm Sài Gòn ăn kèm sườn nướng mỡ hành, bì heo sợi, chả trứng hấp và đồ chua.',
    servingOptions: [
      ServingOption(
        id: 'opt_com_tam_std',
        name: '1 dĩa tiêu chuẩn',
        multiplier: 1.0,
        grams: 450,
        isDefault: true,
      ),
      ServingOption(
        id: 'opt_com_tam_heavy',
        name: '1 dĩa đầy đủ + ốp la',
        multiplier: 1.25,
        grams: 550,
      ),
    ],
  ),
  FoodItem(
    id: 'food_banh_mi_thit',
    name: 'Bánh mì thịt',
    category: FoodCategory.vietnamese,
    baseServingUnit: 'ổ',
    baseCalories: 420,
    baseProtein: 19,
    baseCarbs: 48,
    baseFat: 16,
    imageUrl:
        'https://images.unsplash.com/photo-1626804475297-41608ea09aeb?w=500&auto=format&fit=crop&q=80',
    description:
        'Bánh mì giòn rụm kẹp thịt chả lụa, pate gan, dưa leo và ngò rí tươi.',
    servingOptions: [
      ServingOption(
        id: 'opt_bm_std',
        name: '1 ổ tiêu chuẩn',
        multiplier: 1.0,
        grams: 200,
        isDefault: true,
      ),
      ServingOption(
        id: 'opt_bm_extra',
        name: '1 ổ thêm thịt & trứng',
        multiplier: 1.3,
        grams: 260,
      ),
    ],
  ),

  // Protein / Fitness Foods
  FoodItem(
    id: 'food_uc_ga',
    name: 'Ức gà áp chảo',
    category: FoodCategory.protein,
    baseServingUnit: '150g',
    baseCalories: 247,
    baseProtein: 46,
    baseCarbs: 0,
    baseFat: 5,
    imageUrl:
        'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=500&auto=format&fit=crop&q=80',
    description:
        'Ức gà lọc da áp chảo ít dầu, giàu đạm tinh khiết cho người tập gym.',
    servingOptions: [
      ServingOption(
        id: 'opt_uc_ga_150',
        name: '1 phần 150g (tiêu chuẩn)',
        multiplier: 1.0,
        grams: 150,
        isDefault: true,
      ),
      ServingOption(
        id: 'opt_uc_ga_200',
        name: '1 phần 200g (nhiều đạm)',
        multiplier: 1.33,
        grams: 200,
      ),
      ServingOption(
        id: 'opt_uc_ga_100',
        name: '100g khẩu phần',
        multiplier: 0.67,
        grams: 100,
      ),
    ],
  ),
  FoodItem(
    id: 'food_trung_luoc',
    name: 'Trứng gà luộc',
    category: FoodCategory.protein,
    baseServingUnit: '2 quả',
    baseCalories: 156,
    baseProtein: 13,
    baseCarbs: 1.1,
    baseFat: 11,
    imageUrl:
        'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=500&auto=format&fit=crop&q=80',
    description:
        'Trứng gà luộc nguyên quả giàu amino acids và choline cần thiết.',
    servingOptions: [
      ServingOption(
        id: 'opt_trung_2',
        name: '2 quả vừa',
        multiplier: 1.0,
        grams: 110,
        isDefault: true,
      ),
      ServingOption(
        id: 'opt_trung_1',
        name: '1 quả',
        multiplier: 0.5,
        grams: 55,
      ),
      ServingOption(
        id: 'opt_trung_3',
        name: '3 quả',
        multiplier: 1.5,
        grams: 165,
      ),
    ],
  ),
  FoodItem(
    id: 'food_ca_hoi',
    name: 'Cá hồi áp chảo',
    category: FoodCategory.protein,
    baseServingUnit: '150g',
    baseCalories: 310,
    baseProtein: 34,
    baseCarbs: 0,
    baseFat: 18,
    imageUrl:
        'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=500&auto=format&fit=crop&q=80',
    description:
        'Phi lê cá hồi áp chảo giàu Omega-3, EPA và DHA tốt cho tim mạch và phục hồi cơ.',
    servingOptions: [
      ServingOption(
        id: 'opt_ca_hoi_150',
        name: '1 miếng 150g',
        multiplier: 1.0,
        grams: 150,
        isDefault: true,
      ),
      ServingOption(
        id: 'opt_ca_hoi_200',
        name: '1 miếng lớn 200g',
        multiplier: 1.33,
        grams: 200,
      ),
    ],
  ),

  // Staples / Carbs
  FoodItem(
    id: 'food_gao_lut',
    name: 'Cơm gạo lứt',
    category: FoodCategory.staple,
    baseServingUnit: 'chén vừa',
    baseCalories: 215,
    baseProtein: 5,
    baseCarbs: 45,
    baseFat: 1.8,
    imageUrl:
        'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=500&auto=format&fit=crop&q=80',
    description:
        'Gạo lứt giàu chất xơ, chỉ số đường huyết GI thấp giúp no lâu và duy trì năng lượng bền bỉ.',
    servingOptions: [
      ServingOption(
        id: 'opt_lut_std',
        name: '1 chén vừa (150g)',
        multiplier: 1.0,
        grams: 150,
        isDefault: true,
      ),
      ServingOption(
        id: 'opt_lut_large',
        name: '1 chén đầy (200g)',
        multiplier: 1.33,
        grams: 200,
      ),
    ],
  ),
  FoodItem(
    id: 'food_khoai_lang',
    name: 'Khoai lang luộc',
    category: FoodCategory.staple,
    baseServingUnit: 'củ vừa',
    baseCalories: 130,
    baseProtein: 2.2,
    baseCarbs: 30,
    baseFat: 0.2,
    imageUrl:
        'https://images.unsplash.com/photo-1596097635121-14b63b7a0c19?w=500&auto=format&fit=crop&q=80',
    description:
        'Khoai lang mật/khoai lang vàng ngọt bùi, nguồn carb chậm tuyệt vời trước buổi tập.',
    servingOptions: [
      ServingOption(
        id: 'opt_khoai_1',
        name: '1 củ vừa (150g)',
        multiplier: 1.0,
        grams: 150,
        isDefault: true,
      ),
      ServingOption(
        id: 'opt_khoai_2',
        name: '2 củ nhỏ (250g)',
        multiplier: 1.67,
        grams: 250,
      ),
    ],
  ),

  // Snacks & Beverage
  FoodItem(
    id: 'food_whey',
    name: 'Whey Protein Isolate Shake',
    category: FoodCategory.beverage,
    baseServingUnit: 'muỗng (scoop)',
    baseCalories: 120,
    baseProtein: 27,
    baseCarbs: 1.5,
    baseFat: 0.5,
    imageUrl:
        'https://images.unsplash.com/photo-1579722821273-0f6c7d44362f?w=500&auto=format&fit=crop&q=80',
    description:
        'Bột đạm whey tinh khiết hấp thu siêu nhanh sau khi tập luyện để chống dị hóa cơ bắp.',
    servingOptions: [
      ServingOption(
        id: 'opt_whey_1',
        name: '1 muỗng (30g bột)',
        multiplier: 1.0,
        grams: 30,
        isDefault: true,
      ),
      ServingOption(
        id: 'opt_whey_2',
        name: '2 muỗng (60g bột)',
        multiplier: 2.0,
        grams: 60,
      ),
    ],
  ),
  FoodItem(
    id: 'food_chuoi',
    name: 'Chuối già Nam Mỹ',
    category: FoodCategory.snack,
    baseServingUnit: 'trái',
    baseCalories: 105,
    baseProtein: 1.3,
    baseCarbs: 27,
    baseFat: 0.3,
    imageUrl:
        'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=500&auto=format&fit=crop&q=80',
    description:
        'Chuối chín tự nhiên giàu kali giúp chống chuột rút cơ và bổ sung glycogen nhanh chóng.',
    servingOptions: [
      ServingOption(
        id: 'opt_chuoi_1',
        name: '1 trái vừa (120g)',
        multiplier: 1.0,
        grams: 120,
        isDefault: true,
      ),
      ServingOption(
        id: 'opt_chuoi_2',
        name: '2 trái (240g)',
        multiplier: 2.0,
        grams: 240,
      ),
    ],
  ),
];

FoodItem? findFoodById(String id) {
  for (final item in masterFoodCatalog) {
    if (item.id == id) return item;
  }
  return null;
}

CalculatedNutrition calculateFoodNutrition({
  required FoodItem food,
  required String servingOptionId,
  required double quantity,
}) {
  final option = food.servingOptions.firstWhere(
    (o) => o.id == servingOptionId,
    orElse: () => food.servingOptions.isNotEmpty
        ? food.servingOptions.first
        : ServingOption(
            id: 'opt_default',
            name: food.baseServingUnit,
            multiplier: 1.0,
            grams: 100,
          ),
  );

  final totalMultiplier = option.multiplier * quantity;

  return CalculatedNutrition(
    calories: (food.baseCalories * totalMultiplier).round(),
    protein: double.parse(
      (food.baseProtein * totalMultiplier).toStringAsFixed(1),
    ),
    carbs: double.parse((food.baseCarbs * totalMultiplier).toStringAsFixed(1)),
    fat: double.parse((food.baseFat * totalMultiplier).toStringAsFixed(1)),
    servingName: option.name,
    quantity: quantity,
  );
}
