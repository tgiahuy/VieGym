import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/exercise_tag_chip.dart';
import '../../application/exercise_catalog_controller.dart';
import '../../application/favorite_exercises_controller.dart';
import '../../data/exercise_catalog.dart';
import '../../domain/workout_models.dart';

class FavoriteExercisesSection extends ConsumerWidget {
  const FavoriteExercisesSection({
    super.key,
    required this.onAddExerciseToSession,
  });

  final ValueChanged<ExerciseDefinition> onAddExerciseToSession;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final favoriteIds = ref.watch(favoriteExercisesProvider);
    final catalogState = ref.watch(exerciseCatalogControllerProvider);
    final allKnown = {
      for (final e in catalogState.exercises) e.id: e,
      for (final e in exerciseCatalog) e.id: e,
    };
    final favoriteExercises = favoriteIds
        .map((id) => allKnown[id])
        .whereType<ExerciseDefinition>()
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.favorite_rounded, color: colors.primary, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Bài tập yêu thích',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${favoriteExercises.length}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: colors.primary,
                    ),
                  ),
                ),
              ],
            ),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => context.push('/workout/library'),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  children: [
                    Text(
                      'Thư viện',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: colors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Carousel / Empty State
        if (favoriteExercises.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.favorite_border_rounded,
                  size: 36,
                  color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Chưa có bài tập yêu thích nào',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  'Nhấn biểu tượng ❤️ khi xem bài tập để lưu vào đây.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 172,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: favoriteExercises.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final exercise = favoriteExercises[index];

                return Container(
                  width: 240,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainer,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: colors.outlineVariant.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Row: Muscle badge & Heart icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ExerciseTagChip.muscle(label: exercise.primaryMuscle),
                          InkWell(
                            borderRadius: BorderRadius.circular(99),
                            onTap: () {
                              HapticFeedback.selectionClick();
                              ref
                                  .read(favoriteExercisesProvider.notifier)
                                  .toggleFavorite(exercise.id);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.favorite_rounded,
                                color: colors.primary,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Exercise Name & Subtitle
                      InkWell(
                        onTap: () => context.push('/exercise/${exercise.id}'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exercise.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${exercise.nameVi} • ${exercise.equipment.label}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Action Button: Thêm vào buổi tập
                      SizedBox(
                        width: double.infinity,
                        height: 34,
                        child: FilledButton.tonalIcon(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            onAddExerciseToSession(exercise);
                          },
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.add_rounded, size: 16),
                          label: const Text(
                            'Thêm vào buổi tập',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
