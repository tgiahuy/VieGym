import 'package:flutter/material.dart';

import '../../domain/muscle_models.dart';
import 'body_muscle_map.dart';

class MuscleZoomFocusCard extends StatelessWidget {
  const MuscleZoomFocusCard({
    super.key,
    required this.muscle,
    this.isPrimary = true,
    this.customExplanation,
    this.onTap,
  });

  final MuscleGroup muscle;
  final bool isPrimary;
  final String? customExplanation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final badgeColor = isPrimary ? colors.primary : const Color(0xFFFF6B8B);

    return Card(
      margin: EdgeInsets.zero,
      color: colors.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isPrimary
              ? colors.primary.withValues(alpha: 0.35)
              : colors.outlineVariant.withValues(alpha: 0.4),
          width: isPrimary ? 1.2 : 1.0,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mini Zoomed Anatomical Map Viewport
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 90,
                  height: 110,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      BodyMuscleMap(
                        bodySide: muscle.primarySide,
                        primaryMuscles: isPrimary ? {muscle} : const {},
                        secondaryMuscles: isPrimary ? const {} : {muscle},
                        focusedMuscle: muscle,
                        isZoomed: true,
                        interactive: false,
                        height: 110,
                      ),
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.zoom_in_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Info column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: badgeColor.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            isPrimary ? 'CƠ CHÍNH' : 'CƠ BỔ TRỢ',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: badgeColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          muscle.primarySide == BodySide.front
                              ? 'Mặt trước'
                              : 'Mặt sau',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Vietnamese & Anatomical names
                    Text(
                      muscle.nameVi,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      muscle.nameAnatomy,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Function / description
                    Text(
                      customExplanation ?? muscle.anatomicalFunction,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.35,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
