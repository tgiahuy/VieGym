import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/exercise_tag_chip.dart';
import '../application/favorite_exercises_controller.dart';
import '../application/workout_session_controller.dart';
import '../data/exercise_catalog.dart';

class FavoriteExercisesScreen extends ConsumerWidget {
  const FavoriteExercisesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final favoriteIds = ref.watch(favoriteExercisesProvider);
    final favoriteExercises = exerciseCatalog
        .where((e) => favoriteIds.contains(e.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Row(
          children: [
            const Text(
              'Bài tập yêu thích',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${favoriteExercises.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: colors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
      body: favoriteExercises.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.primary.withValues(alpha: 0.12),
                      ),
                      child: Icon(
                        Icons.favorite_border_rounded,
                        size: 40,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Chưa có bài tập yêu thích nào',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hãy khám phá thư viện và bấm biểu tượng ❤️ để lưu các bài tập bạn yêu thích vào đây.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => context.push('/workout/library'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.search_rounded, size: 18),
                      label: const Text(
                        'Khám phá thư viện bài tập',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: favoriteExercises.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final exercise = favoriteExercises[index];

                return Container(
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
                      // Card Top: Illustration Image + Heart Toggle Overlay
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(19),
                        ),
                        child: Stack(
                          children: [
                            Container(
                              height: 140,
                              width: double.infinity,
                              color: const Color(0xFF1B1E2E),
                              child: Image.network(
                                exercise.thumbnailUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.fitness_center_rounded,
                                            color: colors.primary,
                                            size: 36,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            exercise.name,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: colors.onSurfaceVariant,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Material(
                                color: Colors.black.withValues(alpha: 0.55),
                                shape: const CircleBorder(),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(99),
                                  onTap: () {
                                    ref
                                        .read(
                                          favoriteExercisesProvider.notifier,
                                        )
                                        .toggleFavorite(exercise.id);
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Icon(
                                      Icons.favorite_rounded,
                                      color: Color(0xFFFF2E54),
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ExerciseTagChip.muscle(
                                  label: exercise.primaryMuscle,
                                  fontSize: 11,
                                ),
                                const SizedBox(width: 6),
                                ExerciseTagChip.equipment(
                                  label: exercise.equipment.label,
                                  fontSize: 11,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              exercise.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (exercise.nameVi.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                exercise.nameVi,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      context.push('/exercise/${exercise.id}');
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      side: BorderSide(
                                        color: colors.outlineVariant.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                    ),
                                    child: const Text(
                                      'Chi tiết',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 2,
                                  child: FilledButton.icon(
                                    onPressed: () {
                                      final startedAddOn = ref
                                          .read(workoutSessionProvider.notifier)
                                          .addExercise(exercise);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            startedAddOn
                                                ? 'Đã tạo buổi tập thêm với ${exercise.name}.'
                                                : 'Đã thêm ${exercise.name} vào hôm nay.',
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    },
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.add_rounded,
                                      size: 16,
                                    ),
                                    label: const Text(
                                      'Thêm vào hôm nay',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
