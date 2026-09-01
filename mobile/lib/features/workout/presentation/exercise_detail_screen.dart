import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/exercise_tag_chip.dart';
import '../application/exercise_catalog_controller.dart';
import '../application/favorite_exercises_controller.dart';
import '../application/workout_session_controller.dart';
import '../data/exercise_catalog.dart';
import 'widgets/common_mistakes_card.dart';
import 'widgets/muscle_target_card.dart';

class ExerciseDetailScreen extends ConsumerWidget {
  const ExerciseDetailScreen({super.key, required this.exerciseId});

  final String exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncEx = ref.watch(exerciseDetailProvider(exerciseId));
    final exercise = asyncEx.value ?? findExercise(exerciseId);
    final colors = Theme.of(context).colorScheme;
    final isFav = ref.watch(favoriteExercisesProvider).contains(exerciseId);

    if (exercise == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Không tìm thấy bài tập')),
        body: const Center(
          child: Text('Không tìm thấy thông tin cho bài tập này.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(
          exercise.name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: isFav ? 'Bỏ yêu thích' : 'Thêm vào yêu thích',
            onPressed: () {
              final added = ref
                  .read(favoriteExercisesProvider.notifier)
                  .toggleFavorite(exerciseId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    added
                        ? 'Đã thêm "${exercise.name}" vào danh sách yêu thích! ❤️'
                        : 'Đã bỏ "${exercise.name}" khỏi danh sách yêu thích.',
                  ),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: Icon(
              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFav ? colors.primary : colors.onSurface,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          // Media / Video Simulation Banner
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  colors.primaryContainer,
                  colors.surfaceContainerHighest,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.primary.withValues(alpha: 0.85),
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Video kỹ thuật chuẩn form',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Exercise Title & Vi Name
          Text(
            exercise.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          if (exercise.nameVi.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              exercise.nameVi,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: colors.primary,
              ),
            ),
          ],
          const SizedBox(height: 10),

          // Muscle & Equipment Badges
          Row(
            children: [
              ExerciseTagChip.muscle(
                label: exercise.primaryMuscle,
                fontSize: 12,
              ),
              const SizedBox(width: 8),
              ExerciseTagChip.equipment(
                label: exercise.equipment.label,
                fontSize: 12,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 1. Muscle Target Illustration Card
          MuscleTargetCard(
            primaryMuscle: exercise.primaryMuscle,
            secondaryMuscles: exercise.secondaryMuscles,
          ),
          const SizedBox(height: 16),

          // 2. Common Mistakes & Fixes Card
          CommonMistakesCard(
            exerciseName: exercise.name,
            mistakes: exercise.commonMistakes,
          ),
          const SizedBox(height: 16),

          // 3. Step-by-step Instructions
          if (exercise.instructions.isNotEmpty) ...[
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: Colors.blue,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hướng dẫn thực hiện',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Các bước chuẩn form kỹ thuật',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                children: exercise.instructions.asMap().entries.map((entry) {
                  final index = entry.key + 1;
                  final step = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.primary.withValues(alpha: 0.2),
                          ),
                          child: Center(
                            child: Text(
                              '$index',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: colors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            step,
                            style: const TextStyle(fontSize: 13, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: () {
            final session = ref.read(workoutSessionProvider);
            final startsAddOn = session.isFinalized;
            if (!session.isFinalized &&
                session.exercises.isNotEmpty &&
                session.currentExercise.exerciseId.isNotEmpty) {
              ref
                  .read(workoutSessionProvider.notifier)
                  .replaceExercise(
                    originalExerciseId: session.currentExercise.exerciseId,
                    replacementExerciseId: exercise.id,
                  );
            } else {
              ref.read(workoutSessionProvider.notifier).addExercise(exercise);
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  startsAddOn
                      ? 'Đã tạo buổi tập thêm với ${exercise.name}.'
                      : 'Đã chọn ${exercise.name} cho buổi tập!',
                ),
              ),
            );
            context.push('/workout/session');
          },
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text(
            'Tập bài này ngay',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}
