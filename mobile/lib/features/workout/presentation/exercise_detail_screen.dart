import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/workout_session_controller.dart';
import '../data/exercise_catalog.dart';
import 'widgets/common_mistakes_card.dart';
import 'widgets/muscle_target_card.dart';

class ExerciseDetailScreen extends ConsumerWidget {
  const ExerciseDetailScreen({
    super.key,
    required this.exerciseId,
  });

  final String exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercise = findExercise(exerciseId);
    final colors = Theme.of(context).colorScheme;

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
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã lưu bài tập vào danh sách yêu thích!')),
              );
            },
            icon: const Icon(Icons.bookmark_border_rounded),
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
              Chip(
                label: Text(exercise.primaryMuscle),
                backgroundColor: colors.primary.withValues(alpha: 0.15),
                labelStyle: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              Chip(
                label: Text(exercise.equipment.label),
                backgroundColor: colors.surfaceContainer,
                labelStyle: const TextStyle(fontSize: 12),
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
            ref.read(workoutSessionProvider.notifier).replaceExercise(
                  originalExerciseId: ref
                      .read(workoutSessionProvider)
                      .currentExercise
                      .exerciseId,
                  replacementExerciseId: exercise.id,
                );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Đã chọn ${exercise.name} cho buổi tập!')),
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
