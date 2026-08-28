import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../onboarding/application/health_profile_controller.dart';
import '../../onboarding/data/equipment_catalog.dart';

class EquipmentPreferenceScreen extends ConsumerWidget {
  const EquipmentPreferenceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userEquipment = ref.watch(userEquipmentProvider);
    final notifier = ref.read(userEquipmentProvider.notifier);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Thiết bị tập luyện'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          // Presets Card
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cấu hình nhanh thiết bị',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              notifier.applyPreset(EquipmentPresets.fullGym),
                          child: const Text('Full Gym', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => notifier
                              .applyPreset(EquipmentPresets.homeDumbbell),
                          child: const Text('Tạ đơn & Dây', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => notifier
                              .applyPreset(EquipmentPresets.bodyweightOnly),
                          child: const Text('Bodyweight', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Danh sách thiết bị (${userEquipment.length} đã chọn)',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),

          ...masterEquipmentCatalogue.map((item) {
            final isSelected = userEquipment.contains(item.id);
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: isSelected
                  ? colors.primary.withValues(alpha: 0.1)
                  : colors.surfaceContainer,
              child: CheckboxListTile(
                title: Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                subtitle: Text(item.category),
                value: isSelected,
                onChanged: (_) {
                  notifier.toggleEquipment(item.id);
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
