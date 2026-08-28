import 'package:flutter/material.dart';

class MuscleTargetCard extends StatelessWidget {
  const MuscleTargetCard({
    super.key,
    required this.primaryMuscle,
    required this.secondaryMuscles,
  });

  final String primaryMuscle;
  final List<String> secondaryMuscles;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colors.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.local_fire_department_rounded,
                    color: Colors.amber,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nhóm cơ tác động',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Bản đồ chuyển động sinh học',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Primary Target
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'CƠ TÁC ĐỘNG CHÍNH:',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: colors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      primaryMuscle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: colors.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (secondaryMuscles.isNotEmpty) ...[
              const SizedBox(height: 10),
              // Secondary targets
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          size: 14,
                          color: colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Cơ bổ trợ / Giữ ổn định:',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: secondaryMuscles.map((muscle) {
                        return Chip(
                          label: Text(muscle),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          labelStyle: const TextStyle(fontSize: 11),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
