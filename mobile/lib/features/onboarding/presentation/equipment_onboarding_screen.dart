import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _finish() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thiết lập hoàn tất! Chào mừng bạn đến với VieGym'),
      ),
    );
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final selectedIds = ref.watch(userEquipmentProvider);
    final notifier = ref.read(userEquipmentProvider.notifier);
    final colors = Theme.of(context).colorScheme;

    final categories = masterEquipmentCatalogue
        .map((e) => e.category)
        .toSet()
        .toList();

    final filteredCatalogue = masterEquipmentCatalogue.where((e) {
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return e.name.toLowerCase().contains(q) ||
          e.description.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Column(
          children: [
            const Text(
              'Thiết bị của bạn',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            Text(
              'Đã chọn ${selectedIds.length}/${masterEquipmentCatalogue.length} dụng cụ',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
            ),
            child: Text(
              'Bước 2/2',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: colors.primary,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          // Quick presets
          Row(
            children: [
              Icon(Icons.tune_rounded, size: 16, color: colors.primary),
              const SizedBox(width: 6),
              Text(
                'MẪU THIẾT LẬP NHANH',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _PresetButton(
                  label: '🏋️ Full Gym',
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
              hintText: 'Tìm kiếm thiết bị (vd: tạ đơn, ghế...)...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
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
              fillColor: colors.surfaceContainer,
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: 16),

          // Grouped Equipment list
          ...categories.map((cat) {
            final items = filteredCatalogue
                .where((e) => e.category == cat)
                .toList();
            if (items.isEmpty) return const SizedBox.shrink();

            final selectedInCat = items
                .where((e) => selectedIds.contains(e.id))
                .length;

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
                      Text(
                        cat.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: colors.onSurfaceVariant,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        '$selectedInCat/${items.length}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                ...items.map((item) {
                  final isSelected = selectedIds.contains(item.id);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: isSelected
                        ? colors.primary.withValues(alpha: 0.1)
                        : colors.surfaceContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isSelected
                            ? colors.primary.withValues(alpha: 0.8)
                            : colors.outlineVariant.withValues(alpha: 0.4),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      leading: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(item.icon, color: colors.primary, size: 22),
                      ),
                      title: Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        item.description,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(fontSize: 12),
                      ),
                      trailing: Checkbox(
                        value: isSelected,
                        onChanged: (_) => notifier.toggleEquipment(item.id),
                      ),
                      onTap: () => notifier.toggleEquipment(item.id),
                    ),
                  );
                }),
                const SizedBox(height: 8),
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
                onPressed: () => context.go('/home'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Bỏ qua'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: _finish,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.check_circle_rounded, size: 20),
                label: const Text(
                  'Hoàn tất & Bắt đầu',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PresetButton extends StatelessWidget {
  const _PresetButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainer,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
