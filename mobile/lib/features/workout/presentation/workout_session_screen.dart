import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/rest_timer_controller.dart';
import '../application/workout_schedule_controller.dart';
import '../application/workout_session_controller.dart';
import '../data/exercise_catalog.dart';
import '../domain/workout_models.dart';
import 'widgets/rest_timer_overlay.dart';

class WorkoutSessionScreen extends ConsumerStatefulWidget {
  const WorkoutSessionScreen({super.key});

  @override
  ConsumerState<WorkoutSessionScreen> createState() =>
      _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends ConsumerState<WorkoutSessionScreen> {
  Timer? _timer;
  var _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!ref.read(workoutSessionProvider).isPaused && mounted) {
        setState(() => _elapsedSeconds++);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = _elapsedSeconds ~/ 60;
    final seconds = _elapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(workoutSessionProvider);
    final controller = ref.read(workoutSessionProvider.notifier);
    final exercise = session.currentExercise;
    final sets = session.logs[exercise.exerciseId] ?? const <SetLog>[];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => _confirmExit(context),
          icon: const Icon(Icons.close_rounded),
        ),
        title: Column(
          children: [
            Text(
              'Bài ${session.currentExerciseIndex + 1}/${session.exercises.length}',
            ),
            Text(
              '${session.completedSets}/${session.totalSets} hiệp hoàn thành',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: controller.togglePause,
            icon: Icon(
              session.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
            ),
            label: Text(_formattedTime),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
            children: [
              InkWell(
                onTap: () => context.push('/exercise/${exercise.exerciseId}'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        exercise.name,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const Icon(Icons.info_outline_rounded),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  Chip(label: Text(exercise.primaryMuscle)),
                  Chip(label: Text(exercise.equipment.label)),
                ],
              ),
              const SizedBox(height: 12),
              InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () => context.push('/exercise/${exercise.exerciseId}'),
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primaryContainer,
                        Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_circle_fill_rounded, size: 52),
                        SizedBox(height: 8),
                        Text(
                          'Xem kỹ thuật chuẩn form & giải phẫu cơ',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 54,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: session.exercises.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final item = session.exercises[index];
                    return ChoiceChip(
                      selected: index == session.currentExerciseIndex,
                      label: Text('${index + 1}. ${item.name}'),
                      onSelected: (_) => controller.selectExercise(index),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Bảng ghi hiệp tập',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ),
                  Text(
                    '${exercise.weightKg.toStringAsFixed(0)}kg × ${exercise.targetReps} reps',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...sets.asMap().entries.map(
                (entry) => _SetRow(
                  key: ValueKey('${exercise.exerciseId}_${entry.key}'),
                  set: entry.value,
                  onWeightChanged: (value) => controller.updateSet(
                    exerciseId: exercise.exerciseId,
                    setIndex: entry.key,
                    weightKg: double.tryParse(value),
                  ),
                  onRepsChanged: (value) => controller.updateSet(
                    exerciseId: exercise.exerciseId,
                    setIndex: entry.key,
                    reps: int.tryParse(value),
                  ),
                  onCompletedChanged: (value) {
                    controller.updateSet(
                      exerciseId: exercise.exerciseId,
                      setIndex: entry.key,
                      completed: value,
                    );
                    if (value) {
                      ref.read(restTimerProvider.notifier).startRest(seconds: 60);
                    }
                  },
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => controller.addSet(exercise.exerciseId),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Thêm hiệp cho bài này'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: session.currentExerciseIndex == 0
                          ? null
                          : controller.previousExercise,
                      icon: const Icon(Icons.chevron_left_rounded),
                      label: const Text('Bài trước'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showReplacements(context, session),
                      icon: const Icon(Icons.swap_horiz_rounded),
                      label: const Text('Thay bài'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          session.currentExerciseIndex ==
                              session.exercises.length - 1
                          ? null
                          : controller.nextExercise,
                      icon: const Icon(Icons.chevron_right_rounded),
                      label: const Text('Bài sau'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: () => context.push('/ai/chat'),
                icon: const Icon(Icons.auto_awesome_rounded),
                label: const Text('Đang đau hoặc khó chịu? Hỏi AI Coach'),
              ),
            ],
          ),

          // Rest Timer Overlay (Minimized or Fullscreen)
          const RestTimerOverlay(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: () => _finishWorkout(context, session),
          child: const Text('Hoàn thành buổi tập'),
        ),
      ),
    );
  }

  Future<void> _showReplacements(
    BuildContext context,
    WorkoutSessionState session,
  ) async {
    final equipment = ref.read(equipmentPreferencesProvider);
    final candidates = replacementCandidates(
      originalExerciseId: session.currentExercise.exerciseId,
      availableEquipment: equipment,
    );
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thay ${session.currentExercise.name}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Chọn bài cùng nhóm cơ và phù hợp thiết bị hiện có.',
                ),
                const SizedBox(height: 12),
                if (candidates.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 28),
                    child: Text('Không tìm thấy bài thay thế phù hợp.'),
                  )
                else
                  ...candidates.map(
                    (candidate) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(candidate.name),
                        subtitle: Text(
                          '${candidate.primaryMuscle} • ${candidate.equipment.label}',
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () async {
                          final confirmed = await showDialog<bool>(
                            context: sheetContext,
                            builder: (dialogContext) => AlertDialog(
                              title: const Text('Xác nhận thay bài?'),
                              content: Text(
                                'Chỉ thay ${session.currentExercise.name} bằng ${candidate.name}. Tiến độ các bài khác được giữ nguyên.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(dialogContext, false),
                                  child: const Text('Quay lại'),
                                ),
                                FilledButton(
                                  onPressed: () =>
                                      Navigator.pop(dialogContext, true),
                                  child: const Text('Xác nhận'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true && sheetContext.mounted) {
                            ref
                                .read(workoutSessionProvider.notifier)
                                .replaceExercise(
                                  originalExerciseId:
                                      session.currentExercise.exerciseId,
                                  replacementExerciseId: candidate.id,
                                );
                            Navigator.pop(sheetContext);
                          }
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmExit(BuildContext context) async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rời buổi tập?'),
        content: const Text(
          'Tiến độ hiện tại vẫn được giữ trong phiên ứng dụng.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Tiếp tục tập'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Rời buổi tập'),
          ),
        ],
      ),
    );
    if (shouldLeave == true && context.mounted) context.pop();
  }

  Future<void> _finishWorkout(
    BuildContext context,
    WorkoutSessionState session,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hoàn thành buổi tập?'),
        content: Text(
          'Bạn đã hoàn thành ${session.completedSets}/${session.totalSets} hiệp.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Tiếp tục tập'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Kết thúc'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      ref.read(workoutScheduleProvider.notifier).recordWorkoutCompletion(
            workoutName: session.title,
            durationMinutes: (_elapsedSeconds / 60).ceil(),
            totalVolumeKg: session.totalVolumeKg,
            completedSets: session.completedSets,
            prCount: 2,
          );

      context.push('/workout/summary');
    }
  }
}

class _SetRow extends StatelessWidget {
  const _SetRow({
    super.key,
    required this.set,
    required this.onWeightChanged,
    required this.onRepsChanged,
    required this.onCompletedChanged,
  });

  final SetLog set;
  final ValueChanged<String> onWeightChanged;
  final ValueChanged<String> onRepsChanged;
  final ValueChanged<bool> onCompletedChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 7),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 38,
              child: Text(
                '${set.number}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            Expanded(
              child: TextFormField(
                initialValue: set.weightKg.toStringAsFixed(0),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  labelText: 'KG',
                  isDense: true,
                ),
                onChanged: onWeightChanged,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                initialValue: '${set.reps}',
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  labelText: 'Reps',
                  isDense: true,
                ),
                onChanged: onRepsChanged,
              ),
            ),
            const SizedBox(width: 8),
            Checkbox(
              value: set.completed,
              onChanged: (value) => onCompletedChanged(value ?? false),
            ),
          ],
        ),
      ),
    );
  }
}
