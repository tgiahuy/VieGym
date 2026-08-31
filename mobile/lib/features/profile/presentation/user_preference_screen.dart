import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/user_preference_controller.dart';

class UserPreferenceScreen extends ConsumerStatefulWidget {
  const UserPreferenceScreen({super.key});

  @override
  ConsumerState<UserPreferenceScreen> createState() =>
      _UserPreferenceScreenState();
}

class _UserPreferenceScreenState extends ConsumerState<UserPreferenceScreen> {
  final _dislikedFoodController = TextEditingController();
  final _allergyController = TextEditingController();

  static const _allMuscles = [
    'Ngực',
    'Lưng',
    'Chân',
    'Vai',
    'Tay trước',
    'Tay sau',
    'Bụng/Core',
  ];
  static const _durationOptions = [30, 45, 60, 75, 90];
  static const _mealOptions = [3, 4, 5, 6];

  @override
  void dispose() {
    _dislikedFoodController.dispose();
    _allergyController.dispose();
    super.dispose();
  }

  void _handleAddDislikedFood() {
    final text = _dislikedFoodController.text.trim();
    if (text.isNotEmpty) {
      ref.read(userPreferencesProvider.notifier).addDislikedFood(text);
      _dislikedFoodController.clear();
    }
  }

  void _handleAddAllergy() {
    final text = _allergyController.text.trim();
    if (text.isNotEmpty) {
      ref.read(userPreferencesProvider.notifier).addAllergy(text);
      _allergyController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(userPreferencesProvider);
    final notifier = ref.read(userPreferencesProvider.notifier);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Tùy chọn & Ràng buộc'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          // Section 1: Workout Preferences
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.fitness_center_rounded,
                        size: 20,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'TÙY CHỌN TẬP LUYỆN',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Preferred Time
                  const Text(
                    'Khung giờ tập yêu thích',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: WorkoutTimePreference.values.map((time) {
                      final isSelected = prefs.preferredWorkoutTime == time;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => notifier.setPreferredTime(time),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colors.primary.withValues(alpha: 0.15)
                                    : Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainer,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? colors.primary
                                      : Colors.transparent,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                time.label.split(' ')[0],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  color: isSelected ? colors.primary : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Duration Options
                  const Text(
                    'Thời lượng buổi tập mong muốn',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: _durationOptions.map((mins) {
                      final isSelected = prefs.defaultDurationMinutes == mins;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => notifier.setDefaultDuration(mins),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colors.primary.withValues(alpha: 0.15)
                                    : Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainer,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? colors.primary
                                      : Colors.transparent,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$mins\'',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  color: isSelected ? colors.primary : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Target Muscles Priority
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Nhóm cơ ưu tiên phát triển',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Đã chọn: ${prefs.targetMusclesPriority.length}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _allMuscles.map((muscle) {
                      final isSelected = prefs.targetMusclesPriority.contains(
                        muscle,
                      );
                      return FilterChip(
                        selected: isSelected,
                        label: Text(muscle),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w500,
                          color: isSelected ? colors.primary : null,
                        ),
                        selectedColor: colors.primary.withValues(alpha: 0.15),
                        checkmarkColor: colors.primary,
                        onSelected: (_) =>
                            notifier.toggleMusclePriority(muscle),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Section 2: Nutrition Preferences
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.restaurant_rounded,
                        size: 20,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'TÙY CHỌN DINH DƯỠNG',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Meals Per Day
                  const Text(
                    'Số bữa ăn tiêu chuẩn trong ngày',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: _mealOptions.map((count) {
                      final isSelected = prefs.mealsPerDay == count;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => notifier.setMealsPerDay(count),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colors.primary.withValues(alpha: 0.15)
                                    : Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainer,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? colors.primary
                                      : Colors.transparent,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$count bữa',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  color: isSelected ? colors.primary : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Disliked Foods
                  const Text(
                    'Món ăn / Nguyên liệu không thích',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _dislikedFoodController,
                          decoration: InputDecoration(
                            hintText: 'Ví dụ: Khổ qua, rau mùi...',
                            hintStyle: const TextStyle(fontSize: 12),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onSubmitted: (_) => _handleAddDislikedFood(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.tonal(
                        onPressed: _handleAddDislikedFood,
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Thêm'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: prefs.dislikedFoods.map((food) {
                      return Chip(
                        label: Text(food, style: const TextStyle(fontSize: 12)),
                        deleteIcon: const Icon(Icons.close_rounded, size: 16),
                        onDeleted: () => notifier.removeDislikedFood(food),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Allergies
                  Row(
                    children: [
                      const Icon(
                        Icons.no_food_rounded,
                        size: 18,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Dị ứng & Ràng buộc bắt buộc (Allergies)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'AI Meal Planner sẽ loại bỏ tuyệt đối các nguyên liệu này.',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _allergyController,
                          decoration: InputDecoration(
                            hintText: 'Ví dụ: Đậu phộng, Hải sản...',
                            hintStyle: const TextStyle(fontSize: 12),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onSubmitted: (_) => _handleAddAllergy(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: _handleAddAllergy,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Thêm'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: prefs.allergies.map((allergy) {
                      return Chip(
                        label: Text(
                          allergy,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        backgroundColor: Colors.redAccent.withValues(
                          alpha: 0.1,
                        ),
                        side: const BorderSide(color: Colors.redAccent),
                        deleteIcon: const Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: Colors.redAccent,
                        ),
                        onDeleted: () => notifier.removeAllergy(allergy),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
        child: FilledButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã lưu tùy chọn & ràng buộc!')),
            );
            context.pop();
          },
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.check_rounded),
          label: const Text(
            'Lưu tùy chọn',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
        ),
      ),
    );
  }
}
