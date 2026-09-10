import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/exercise_catalog.dart';

/// A reusable exercise illustration thumbnail that replaces numeric badges
/// in exercise lists and workout sessions, conforming to the VieGym Design System.
class ExerciseThumbnail extends StatelessWidget {
  const ExerciseThumbnail({
    super.key,
    required this.exerciseId,
    this.name,
    this.imageUrl,
    this.size = 48.0,
    this.borderRadius = 12.0,
    this.isSelected = false,
    this.isCompleted = false,
  });

  final String exerciseId;
  final String? name;
  final String? imageUrl;
  final double size;
  final double borderRadius;
  final bool isSelected;
  final bool isCompleted;

  String _resolveThumbnailUrl() {
    if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      return imageUrl!.trim();
    }
    final def = findExercise(exerciseId);
    if (def != null && def.thumbnailUrl.isNotEmpty) {
      return def.thumbnailUrl;
    }
    return 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=400&auto=format&fit=crop&q=80';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final resolvedUrl = _resolveThumbnailUrl();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isSelected
              ? colors.primary
              : (isCompleted
                    ? AppColors.success.withValues(alpha: 0.6)
                    : colors.outlineVariant.withValues(alpha: 0.35)),
          width: isSelected ? 1.8 : 1.0,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - 1),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Exercise illustration image
            Image.network(
              resolvedUrl,
              fit: BoxFit.cover,
              semanticLabel: name ?? 'Minh họa bài tập',
              errorBuilder: (context, error, stackTrace) => Center(
                child: Icon(
                  Icons.fitness_center_rounded,
                  size: size * 0.46,
                  color: isSelected ? colors.primary : colors.onSurfaceVariant,
                ),
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: SizedBox(
                    width: size * 0.35,
                    height: size * 0.35,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.primary,
                    ),
                  ),
                );
              },
            ),

            // Completion check overlay
            if (isCompleted)
              Container(
                color: Colors.black.withValues(alpha: 0.4),
                alignment: Alignment.center,
                child: Container(
                  padding: EdgeInsets.all(size * 0.06),
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: size * 0.4,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
