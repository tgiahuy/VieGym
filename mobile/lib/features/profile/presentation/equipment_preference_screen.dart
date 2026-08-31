import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../onboarding/application/health_profile_controller.dart';
import '../../onboarding/data/equipment_catalog.dart';

class EquipmentPreferenceScreen extends ConsumerStatefulWidget {
  const EquipmentPreferenceScreen({super.key});

  @override
  ConsumerState<EquipmentPreferenceScreen> createState() =>
      _EquipmentPreferenceScreenState();
}

class _EquipmentPreferenceScreenState
    extends ConsumerState<EquipmentPreferenceScreen> {
  String _selectedCategory = 'Tất cả';

  (Color, List<Color>) _getCategoryVisuals(String category) {
    if (category.contains('Tạ tự do')) {
      return (
        const Color(0xFFFF2E54),
        [const Color(0xFFFF2E54), const Color(0xFFFF5277)],
      );
    } else if (category.contains('Ghế') || category.contains('Khung')) {
      return (Colors.purpleAccent, [Colors.deepPurple, Colors.purpleAccent]);
    } else if (category.contains('Máy') || category.contains('cáp')) {
      return (Colors.cyanAccent, [Colors.blue, Colors.cyanAccent]);
    } else {
      return (Colors.greenAccent, [Colors.teal, Colors.greenAccent]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userEquipment = ref.watch(userEquipmentProvider);
    final notifier = ref.read(userEquipmentProvider.notifier);
    final colors = Theme.of(context).colorScheme;

    final categories = [
      'Tất cả',
      ...masterEquipmentCatalogue.map((e) => e.category).toSet(),
    ];

    final filteredItems = _selectedCategory == 'Tất cả'
        ? masterEquipmentCatalogue
        : masterEquipmentCatalogue
              .where((e) => e.category == _selectedCategory)
              .toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Thiết bị tập luyện'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          // Quick Presets Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.flash_on_rounded,
                        size: 16,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Cấu hình nhanh theo không gian',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            notifier.applyPreset(EquipmentPresets.fullGym),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Full Gym',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            notifier.applyPreset(EquipmentPresets.homeDumbbell),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Tạ đơn & Dây',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => notifier.applyPreset(
                          EquipmentPresets.bodyweightOnly,
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Bodyweight',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Categories Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((cat) {
                final isCatSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isCatSelected ? Colors.white : colors.onSurface,
                      ),
                    ),
                    selected: isCatSelected,
                    selectedColor: colors.primary,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCategory = cat);
                      }
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          // Header summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DANH SÁCH THIẾT BỊ',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: colors.onSurface.withValues(alpha: 0.75),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'ĐÃ CHỌN ${userEquipment.length}/${masterEquipmentCatalogue.length}',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Illustrated Equipment Cards
          ...filteredItems.map((item) {
            final isSelected = userEquipment.contains(item.id);
            final (accentColor, gradientColors) = _getCategoryVisuals(
              item.category,
            );

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.primary.withValues(alpha: 0.1)
                    : colors.surfaceContainer,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected
                      ? colors.primary
                      : colors.outlineVariant.withValues(alpha: 0.35),
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => notifier.toggleEquipment(item.id),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      // Equipment Visual Illustration Box
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: LinearGradient(
                            colors: gradientColors
                                .map(
                                  (c) => c.withValues(
                                    alpha: isSelected ? 0.35 : 0.15,
                                  ),
                                )
                                .toList(),
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: accentColor.withValues(
                              alpha: isSelected ? 0.6 : 0.25,
                            ),
                          ),
                        ),
                        child: Icon(
                          item.icon,
                          size: 26,
                          color: isSelected ? colors.primary : accentColor,
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Equipment Text Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    item.name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: isSelected
                                          ? colors.primary
                                          : colors.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.description,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: colors.onSurfaceVariant,
                                height: 1.25,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colors.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.category,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Toggle Check Icon
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? colors.primary
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? colors.primary
                                : colors.outlineVariant,
                            width: 1.5,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
