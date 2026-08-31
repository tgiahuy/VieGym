import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../profile/application/progress_controller.dart';
import '../application/rest_timer_controller.dart';
import '../application/workout_schedule_controller.dart';
import '../application/workout_session_controller.dart';
import '../data/exercise_catalog.dart';
import '../domain/muscle_models.dart';
import '../domain/workout_models.dart';
import 'widgets/body_muscle_map.dart';
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
    if (session.exercises.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.close_rounded),
          ),
          title: const Text('Buổi tập trống'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.fitness_center_rounded,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'Chưa có bài tập nào trong buổi tập',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.pop(),
                child: const Text('Quay lại'),
              ),
            ],
          ),
        ),
      );
    }
    final controller = ref.read(workoutSessionProvider.notifier);
    final exercise = session.currentExercise;
    final sets = session.logs[exercise.exerciseId] ?? const <SetLog>[];
    final completedSetsCount = sets.where((s) => s.completed).length;
    final totalSetsCount = sets.length;
    final colors = Theme.of(context).colorScheme;

    final primaryMuscle = MuscleGroup.fromString(exercise.primaryMuscle);
    final isResting = ref.watch(restTimerProvider).isResting;

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
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            Text(
              '${session.completedSets}/${session.totalSets} hiệp hoàn thành',
              style: TextStyle(
                fontSize: 12,
                color: colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: controller.togglePause,
              style: TextButton.styleFrom(
                backgroundColor: colors.surfaceContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: Icon(
                session.isPaused
                    ? Icons.play_arrow_rounded
                    : Icons.pause_rounded,
                size: 18,
                color: colors.primary,
              ),
              label: Text(
                _formattedTime,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
            children: [
              // Exercise Title & Info Icon
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => context.push('/exercise/${exercise.exerciseId}'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${exercise.primaryMuscle} • ${exercise.equipment.label}',
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.info_outline_rounded,
                        color: colors.primary,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Hero Exercise Illustration Card
              InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () => context.push('/exercise/${exercise.exerciseId}'),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141724),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: colors.outlineVariant.withValues(alpha: 0.4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Muscle Illustration Visual
                      Container(
                        width: 100,
                        height: 120,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F121C),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colors.outlineVariant.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Center(
                          child: primaryMuscle != null
                              ? BodyMuscleMap(
                                  bodySide: primaryMuscle.primarySide,
                                  primaryMuscles: {primaryMuscle},
                                  autoZoom: true,
                                  height: 110,
                                  interactive: false,
                                )
                              : Icon(
                                  Icons.fitness_center_rounded,
                                  size: 40,
                                  color: colors.primary,
                                ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Details & Progress Badge
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    completedSetsCount == totalSetsCount &&
                                        totalSetsCount > 0
                                    ? Colors.greenAccent.withValues(alpha: 0.15)
                                    : colors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    completedSetsCount == totalSetsCount &&
                                            totalSetsCount > 0
                                        ? Icons.check_circle_rounded
                                        : Icons.fitness_center_rounded,
                                    size: 13,
                                    color:
                                        completedSetsCount == totalSetsCount &&
                                            totalSetsCount > 0
                                        ? Colors.greenAccent
                                        : colors.primary,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '$completedSetsCount/$totalSetsCount hiệp',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color:
                                          completedSetsCount ==
                                                  totalSetsCount &&
                                              totalSetsCount > 0
                                          ? Colors.greenAccent
                                          : colors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              primaryMuscle?.nameAnatomy ??
                                  exercise.primaryMuscle,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Mục tiêu: ${exercise.weightKg.toStringAsFixed(0)}kg × ${exercise.targetReps} reps',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF8E95AF),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.play_circle_outline_rounded,
                                  size: 14,
                                  color: colors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Xem video chuẩn form',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: colors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Horizontal Exercise Navigation Selector with Thumbnail & Progress
              SizedBox(
                height: 64,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: session.exercises.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final item = session.exercises[index];
                    final isSelected = index == session.currentExerciseIndex;
                    final itemSets =
                        session.logs[item.exerciseId] ?? const <SetLog>[];
                    final itemCompleted = itemSets
                        .where((s) => s.completed)
                        .length;
                    final itemTotal = itemSets.length;
                    final isItemAllDone =
                        itemCompleted == itemTotal && itemTotal > 0;

                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        controller.selectExercise(index);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colors.primary.withValues(alpha: 0.15)
                              : const Color(0xFF141724),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? colors.primary
                                : colors.outlineVariant.withValues(alpha: 0.3),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colors.primary
                                    : (isItemAllDone
                                          ? Colors.greenAccent.withValues(
                                              alpha: 0.2,
                                            )
                                          : const Color(0xFF1B1E2E)),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: isItemAllDone
                                    ? const Icon(
                                        Icons.check_rounded,
                                        size: 16,
                                        color: Colors.greenAccent,
                                      )
                                    : Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 12,
                                          color: isSelected
                                              ? colors.onPrimary
                                              : Colors.white70,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: isSelected
                                        ? colors.primary
                                        : Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$itemCompleted/$itemTotal hiệp',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isItemAllDone
                                        ? Colors.greenAccent
                                        : (isSelected
                                              ? colors.primary
                                              : const Color(0xFF8E95AF)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),

              // Section Header: Bảng ghi hiệp tập & Swipe-to-delete Hint
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Bảng ghi hiệp tập',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$completedSetsCount/$totalSetsCount hiệp',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: colors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Gạt trái để xóa hiệp',
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Swipeable Set Rows with Dismissible
              if (sets.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'Chưa có hiệp nào. Nhấn "+ Thêm hiệp" bên dưới để thêm.',
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    ),
                  ),
                )
              else
                ...sets.asMap().entries.map((entry) {
                  final setIndex = entry.key;
                  final setItem = entry.value;

                  return Dismissible(
                    key: ValueKey('dismiss_set_${setItem.id}'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.only(right: 20),
                      alignment: Alignment.centerRight,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Xóa hiệp',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onDismissed: (_) {
                      HapticFeedback.mediumImpact();
                      controller.removeSet(
                        exerciseId: exercise.exerciseId,
                        setIndex: setIndex,
                      );
                    },
                    child: _SetRow(
                      key: ValueKey('row_set_${setItem.id}'),
                      set: setItem,
                      onWeightChanged: (value) => controller.updateSet(
                        exerciseId: exercise.exerciseId,
                        setIndex: setIndex,
                        weightKg: double.tryParse(value),
                      ),
                      onRepsChanged: (value) => controller.updateSet(
                        exerciseId: exercise.exerciseId,
                        setIndex: setIndex,
                        reps: int.tryParse(value),
                      ),
                      onCompletedChanged: (value) {
                        controller.updateSet(
                          exerciseId: exercise.exerciseId,
                          setIndex: setIndex,
                          completed: value,
                        );
                        if (value) {
                          HapticFeedback.lightImpact();
                          ref
                              .read(restTimerProvider.notifier)
                              .startRest(seconds: 60);
                          controller.autoAdvanceIfExerciseCompleted(
                            exercise.exerciseId,
                          );
                        }
                      },
                    ),
                  );
                }),
              const SizedBox(height: 6),

              OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  controller.addSet(exercise.exerciseId);
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.add_rounded),
                label: const Text(
                  'Thêm hiệp cho bài này',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: session.currentExerciseIndex == 0
                          ? null
                          : controller.previousExercise,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.chevron_left_rounded),
                      label: const Text('Bài trước'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showReplacements(context, session),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
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
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
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
      bottomNavigationBar: isResting
          ? null
          : SafeArea(
              minimum: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: () => _finishWorkout(context, session),
                style: FilledButton.styleFrom(
                  backgroundColor: colors.primary,
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Hoàn thành buổi tập',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
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
      builder: (dialogContext) {
        final colors = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Rời buổi tập?',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: const Text(
            'Tiến độ hiện tại vẫn được giữ trong phiên ứng dụng.',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          actions: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.primary,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text(
                    'Tiếp tục tập',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: Text(
                    'Rời buổi tập',
                    style: TextStyle(
                      color: colors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
    if (shouldLeave == true && context.mounted) context.pop();
  }

  Future<void> _finishWorkout(
    BuildContext context,
    WorkoutSessionState session,
  ) async {
    final allCompleted =
        session.totalSets > 0 && session.completedSets == session.totalSets;

    // If there are still incomplete sets, ask for confirmation
    if (!allCompleted) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          final colors = Theme.of(dialogContext).colorScheme;
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Chưa hoàn thành hết các hiệp?',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            content: Text(
              'Bạn đã hoàn thành ${session.completedSets}/${session.totalSets} hiệp. Bạn có muốn kết thúc buổi tập sớm không?',
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.center,
            actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            actions: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.primary,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text(
                      'Tiếp tục tập luyện',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: Text(
                      'Kết thúc sớm',
                      style: TextStyle(
                        color: colors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );

      if (confirmed != true || !context.mounted) return;
    }

    final completedExercises = <HistoryExerciseLog>[];
    final allMuscles = <String>{};

    for (final ex in session.exercises) {
      final sets = session.logs[ex.exerciseId] ?? const <SetLog>[];
      final completedSets = sets
          .where((s) => s.completed)
          .map(
            (s) => HistorySetLog(
              setNumber: s.number,
              weightKg: s.weightKg,
              reps: s.reps,
            ),
          )
          .toList();

      if (completedSets.isNotEmpty) {
        allMuscles.add(ex.primaryMuscle);
        completedExercises.add(
          HistoryExerciseLog(
            exerciseId: ex.exerciseId,
            exerciseName: ex.name,
            primaryMuscle: ex.primaryMuscle,
            sets: completedSets,
          ),
        );
      }
    }

    final minutes = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    final durationFormatted = '$minutes:$seconds';

    final prRecords = ref.read(progressProvider).personalRecords;
    int calculatedPrs = 0;
    for (final ex in session.exercises) {
      final sets = session.logs[ex.exerciseId] ?? const <SetLog>[];
      for (final s in sets.where((s) => s.completed)) {
        final existing = prRecords
            .where(
              (pr) => pr.exerciseName.toLowerCase() == ex.name.toLowerCase(),
            )
            .firstOrNull;
        if (existing != null && s.weightKg > existing.weightKg) {
          calculatedPrs++;
        }
      }
    }
    if (calculatedPrs == 0 && session.completedSets > 0) {
      calculatedPrs = 1;
    }

    final summaryData = WorkoutSummaryData(
      workoutId: session.id,
      title: session.title,
      durationFormatted: durationFormatted,
      totalVolumeKg: session.totalVolumeKg,
      completedSets: session.completedSets,
      totalSets: session.totalSets,
      prCount: calculatedPrs,
    );

    ref
        .read(workoutScheduleProvider.notifier)
        .recordWorkoutCompletion(
          workoutName: session.title,
          durationMinutes: (_elapsedSeconds / 60).ceil(),
          totalVolumeKg: session.totalVolumeKg,
          completedSets: session.completedSets,
          prCount: calculatedPrs,
          targetMuscles: allMuscles.toList(),
          exercises: completedExercises,
        );
    ref.read(workoutSessionProvider.notifier).finalizeSession();

    context.push('/workout/summary', extra: summaryData);
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
    final isDone = set.completed;
    final colors = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDone
            ? colors.primary.withValues(alpha: 0.08)
            : const Color(0xFF141724),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone
              ? colors.primary.withValues(alpha: 0.4)
              : colors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isDone ? colors.primary : const Color(0xFF1B1E2E),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${set.number}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  color: isDone ? colors.onPrimary : Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              initialValue: set.weightKg.toStringAsFixed(0),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800),
              decoration: InputDecoration(
                labelText: 'KG',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
              style: const TextStyle(fontWeight: FontWeight.w800),
              decoration: InputDecoration(
                labelText: 'Reps',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: onRepsChanged,
            ),
          ),
          const SizedBox(width: 8),
          Transform.scale(
            scale: 1.15,
            child: Checkbox(
              value: set.completed,
              activeColor: colors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              onChanged: (value) => onCompletedChanged(value ?? false),
            ),
          ),
        ],
      ),
    );
  }
}
