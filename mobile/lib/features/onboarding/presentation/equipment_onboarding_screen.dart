import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../application/health_profile_controller.dart';
import '../data/equipment_catalog.dart';

class EquipmentOnboardingScreen extends ConsumerStatefulWidget {
  const EquipmentOnboardingScreen({super.key});

  @override
  ConsumerState<EquipmentOnboardingScreen> createState() =>
      _EquipmentOnboardingScreenState();
}

class _EquipmentOnboardingScreenState
    extends ConsumerState<EquipmentOnboardingScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'Tất cả';
  final _searchController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      final selected = ref.read(userEquipmentProvider);
      await ref
          .read(equipmentOnboardingCompletedProvider.notifier)
          .saveAndComplete(selected);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thiết lập hoàn tất! Chào mừng bạn đến với VieGym'),
        ),
      );
      context.go('/home');
    } catch (_) {
      if (!mounted) return;
      ref.read(equipmentOnboardingCompletedProvider.notifier).complete();
      context.go('/home');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _skip() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(equipmentOnboardingCompletedProvider.notifier)
          .saveAndComplete({});
    } catch (_) {
      ref.read(equipmentOnboardingCompletedProvider.notifier).complete();
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIds = ref.watch(userEquipmentProvider);
    final notifier = ref.read(userEquipmentProvider.notifier);
    final colors = Theme.of(context).colorScheme;

    final allCategories = masterEquipmentCatalogue
        .map((e) => e.category)
        .toSet()
        .toList();

    final categoryTabs = ['Tất cả', ...allCategories];

    final filteredCatalogue = masterEquipmentCatalogue.where((e) {
      if (_selectedCategory != 'Tất cả' && e.category != _selectedCategory) {
        return false;
      }
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return e.name.toLowerCase().contains(q) ||
          e.description.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
        title: const Text(
          'Thiết bị của bạn',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        actions: const [
          SizedBox(width: 48),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
        children: [
          // AI Assistant Smart Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.aiVioletSoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    size: 15,
                    color: AppColors.aiViolet,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'VieGym AI sẽ tự động tùy biến các bài tập phù hợp chính xác với những dụng cụ bạn tích chọn.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colors.onSurface.withValues(alpha: 0.88),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quick presets header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.tune_rounded,
                      size: 15,
                      color: AppColors.iconSecondary,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'MẪU THIẾT LẬP NHANH',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (selectedIds.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    notifier.clearAll();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã bỏ chọn tất cả thiết bị'),
                      ),
                    );
                  },
                  child: Text(
                    'Bỏ chọn tất cả',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Preset cards row
          Row(
            children: [
              Expanded(
                child: _PresetButton(
                  label: '🏋️ Full Gym',
                  sublabel: 'Đầy đủ phòng tập',
                  accentColor: AppColors.primary,
                  isSelected: EquipmentPresets.fullGym.every(
                    selectedIds.contains,
                  ),
                  onTap: () {
                    notifier.applyPreset(EquipmentPresets.fullGym);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã chọn mẫu: Full Gym')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PresetButton(
                  label: '🏠 Tạ đơn & Dây',
                  sublabel: 'Tập tại nhà',
                  accentColor: AppColors.blue,
                  isSelected:
                      EquipmentPresets.homeDumbbell.every(
                        selectedIds.contains,
                      ) &&
                      selectedIds.length ==
                          EquipmentPresets.homeDumbbell.length,
                  onTap: () {
                    notifier.applyPreset(EquipmentPresets.homeDumbbell);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã chọn mẫu: Tạ đơn & Dây'),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PresetButton(
                  label: '🤸 Bodyweight',
                  sublabel: 'Không cần tạ',
                  accentColor: AppColors.cyan,
                  isSelected:
                      EquipmentPresets.bodyweightOnly.every(
                        selectedIds.contains,
                      ) &&
                      selectedIds.length ==
                          EquipmentPresets.bodyweightOnly.length,
                  onTap: () {
                    notifier.applyPreset(EquipmentPresets.bodyweightOnly);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã chọn mẫu: Bodyweight')),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search input
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm thiết bị (vd: tạ đơn, ghế, xô...)...',
              hintStyle: TextStyle(
                fontSize: 13.5,
                color: colors.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                size: 20,
                color: AppColors.iconSecondary,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.surfaceInput,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: colors.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: 12),

          // Category filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categoryTabs.map((cat) {
                final isCatSelected = _selectedCategory == cat;
                final catAccent = cat == 'Tất cả' ? AppColors.primary : _getCategoryAccent(cat);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isCatSelected
                            ? catAccent
                            : colors.onSurfaceVariant,
                      ),
                    ),
                    selected: isCatSelected,
                    selectedColor: catAccent.withValues(alpha: 0.12),
                    backgroundColor: colors.surfaceContainer,
                    showCheckmark: false,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCategory = cat);
                      }
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isCatSelected
                            ? catAccent.withValues(alpha: 0.28)
                            : colors.outlineVariant.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          // Grouped Equipment list
          ...allCategories.map((cat) {
            final items = filteredCatalogue
                .where((e) => e.category == cat)
                .toList();
            if (items.isEmpty) return const SizedBox.shrink();

            final selectedInCat = items
                .where((e) => selectedIds.contains(e.id))
                .length;

                final catAccent = _getCategoryAccent(cat);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: selectedInCat > 0
                                      ? catAccent
                                      : AppColors.borderDefault,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                cat.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: colors.onSurfaceVariant,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: selectedInCat > 0
                                  ? catAccent.withValues(alpha: 0.12)
                                  : colors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$selectedInCat/${items.length}',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: selectedInCat > 0
                                    ? catAccent
                                    : colors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ...items.map((item) {
                      final isSelected = selectedIds.contains(item.id);
                      return _EquipmentItemCard(
                        item: item,
                        isSelected: isSelected,
                        accentColor: catAccent,
                        onTap: () => notifier.toggleEquipment(item.id),
                      );
                    }),                const SizedBox(height: 8),
              ],
            );
          }),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: _isSubmitting ? null : _skip,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 52),
                  foregroundColor: colors.onSurfaceVariant,
                  side: BorderSide(
                    color: colors.outlineVariant.withValues(alpha: 0.6),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Bỏ qua',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: _isSubmitting ? null : _finish,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 52),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_rounded, size: 20),
                label: Text(
                  _isSubmitting ? 'Đang lưu...' : 'Hoàn tất & Bắt đầu',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


Color _getCategoryAccent(String category) {
  return switch (category) {
    'Tạ tự do (Free Weights)' => AppColors.primary,
    'Ghế & Khung tập' => AppColors.amber,
    'Máy & Dây cáp' => AppColors.blue,
    'Phụ kiện & Thể trọng' => AppColors.cyan,
    _ => AppColors.primary,
  };
}

class _PresetButton extends StatefulWidget {
  const _PresetButton({
    required this.label,
    required this.sublabel,
    required this.isSelected,
    required this.onTap,
    this.accentColor,
  });

  final String label;
  final String sublabel;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? accentColor;

  @override
  State<_PresetButton> createState() => _PresetButtonState();
}

class _PresetButtonState extends State<_PresetButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = widget.accentColor ?? AppColors.primary;
    final accentSoft = accent.withValues(alpha: 0.12);
    final accentBorder = accent.withValues(alpha: 0.28);

    return AnimatedScale(
      scale: _isPressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: widget.isSelected ? accentSoft : colors.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isSelected
                ? accentBorder
                : colors.outlineVariant.withValues(alpha: 0.4),
            width: widget.isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            splashColor: accent.withValues(alpha: 0.14),
            highlightColor: accent.withValues(alpha: 0.07),
            onHighlightChanged: (v) => setState(() => _isPressed = v),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Column(
                children: [
                  Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: widget.isSelected ? accent : colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.sublabel,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: widget.isSelected
                          ? accent.withValues(alpha: 0.85)
                          : colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EquipmentItemCard extends StatefulWidget {
  const _EquipmentItemCard({
    required this.item,
    required this.isSelected,
    required this.accentColor,
    required this.onTap,
  });

  final EquipmentItem item;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  State<_EquipmentItemCard> createState() => _EquipmentItemCardState();
}

class _EquipmentItemCardState extends State<_EquipmentItemCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = widget.accentColor;
    final accentSoft = accent.withValues(alpha: 0.12);
    final accentBorder = accent.withValues(alpha: 0.28);
    final accentIconBg = accent.withValues(alpha: 0.16);
    final iconUnselected = accent.withValues(alpha: 0.55);

    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: widget.isSelected ? accentSoft : colors.surfaceContainer,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: widget.isSelected
                ? accentBorder
                : colors.outlineVariant.withValues(alpha: 0.35),
            width: widget.isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            splashColor: accent.withValues(alpha: 0.14),
            highlightColor: accent.withValues(alpha: 0.07),
            onHighlightChanged: (v) => setState(() => _isPressed = v),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? accentIconBg
                          : AppColors.surfaceNested,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: widget.isSelected
                            ? accentBorder
                            : Colors.transparent,
                      ),
                    ),
                    child: Icon(
                      widget.item.icon,
                      color: widget.isSelected
                          ? accent
                          : iconUnselected,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.item.description,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: colors.onSurfaceVariant,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: widget.isSelected ? accent : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.isSelected
                            ? accent
                            : colors.outlineVariant.withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                    ),
                    child: widget.isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
