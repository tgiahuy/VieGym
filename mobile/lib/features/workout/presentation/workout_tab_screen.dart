import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../application/workout_schedule_controller.dart';
import '../application/workout_session_controller.dart';
import '../data/exercise_catalog.dart';
import '../domain/workout_models.dart';
import 'exercise_library_screen.dart';
import 'widgets/flippable_muscle_card.dart';
import 'widgets/today_workout_empty_state.dart';

class WorkoutTabScreen extends ConsumerStatefulWidget {
  const WorkoutTabScreen({super.key});

  @override
  ConsumerState<WorkoutTabScreen> createState() => _WorkoutTabScreenState();
}

class _WorkoutTabScreenState extends ConsumerState<WorkoutTabScreen> {
  String? _openedExerciseId;

  void _closeOpenedItem() {
    if (_openedExerciseId != null) {
      setState(() => _openedExerciseId = null);
    }
  }

  Future<void> _handleAddExercise() async {
    _closeOpenedItem();
    final dynamic result;
    if (GoRouter.maybeOf(context) != null) {
      result = await context.push<dynamic>(
        '/workout/library?select=true&multi=true&title=${Uri.encodeComponent('Thêm bài tập mới')}',
      );
    } else {
      result = await Navigator.of(context, rootNavigator: true).push<dynamic>(
        MaterialPageRoute(
          builder: (context) => const ExerciseLibraryScreen(
            isPicker: true,
            isMultiSelect: true,
            title: 'Thêm bài tập mới',
          ),
        ),
      );
    }

    if (!mounted || result == null) return;
    final List<ExerciseDefinition> selectedList;
    if (result is List<ExerciseDefinition>) {
      selectedList = result;
    } else if (result is ExerciseDefinition) {
      selectedList = [result];
    } else if (result is List) {
      selectedList = result.whereType<ExerciseDefinition>().toList();
    } else {
      return;
    }

    if (selectedList.isEmpty) return;
    var startedAddOnWorkout = false;
    for (final exercise in selectedList) {
      startedAddOnWorkout =
          ref.read(workoutSessionProvider.notifier).addExercise(exercise) ||
          startedAddOnWorkout;
    }
    if (startedAddOnWorkout && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Đã tạo một buổi tập thêm. Kết quả buổi trước vẫn được giữ nguyên.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleChangeExercise(SessionExercise exercise) async {
    _closeOpenedItem();
    final equipment = ref.read(equipmentPreferencesProvider);
    final candidates = replacementCandidates(
      originalExerciseId: exercise.exerciseId,
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
                const Row(
                  children: [
                    Icon(Icons.swap_horiz_rounded, size: 22),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Thay đổi bài tập',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Bài hiện tại: ${exercise.name}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(sheetContext).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                if (candidates.isNotEmpty) ...[
                  Text(
                    'Gợi ý cùng nhóm cơ (${exercise.primaryMuscle}):',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...candidates.map((candidate) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.15),
                        child: Icon(
                          Icons.fitness_center_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: 18,
                        ),
                      ),
                      title: Text(
                        candidate.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        'Thiết bị: ${candidate.equipment.label} • ${candidate.instructions.take(1).join()}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11),
                      ),
                      trailing: FilledButton.tonal(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          _confirmAndReplace(exercise, candidate);
                        },
                        child: const Text(
                          'Chọn',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    );
                  }),
                ] else
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Không tìm thấy bài tập thay thế phù hợp với thiết bị hiện có.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                Card(
                  elevation: 0,
                  color: Theme.of(
                    sheetContext,
                  ).colorScheme.surfaceContainerHigh,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(
                        sheetContext,
                      ).colorScheme.primary.withValues(alpha: 0.15),
                      child: Icon(
                        Icons.search_rounded,
                        color: Theme.of(sheetContext).colorScheme.primary,
                        size: 18,
                      ),
                    ),
                    title: const Text(
                      'Tìm bài tập khác trong thư viện',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: const Text('Chọn từ toàn bộ danh mục bài tập'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () async {
                      Navigator.pop(sheetContext);
                      final ExerciseDefinition? selected;
                      if (GoRouter.maybeOf(context) != null) {
                        selected = await context.push<ExerciseDefinition>(
                          '/workout/library?select=true&title=${Uri.encodeComponent('Chọn bài thay thế')}',
                        );
                      } else {
                        selected =
                            await Navigator.of(
                              context,
                              rootNavigator: true,
                            ).push<ExerciseDefinition>(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ExerciseLibraryScreen(
                                      isPicker: true,
                                      title: 'Chọn bài thay thế',
                                    ),
                              ),
                            );
                      }

                      if (!mounted || selected == null) return;
                      await _confirmAndReplace(exercise, selected);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmAndReplace(
    SessionExercise exercise,
    ExerciseDefinition replacement,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận thay bài?'),
        content: Text(
          'Thay "${exercise.name}" bằng "${replacement.name}". Các bài khác trong buổi tập sẽ được giữ nguyên.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Quay lại'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;
    ref
        .read(workoutSessionProvider.notifier)
        .replaceExercise(
          originalExerciseId: exercise.exerciseId,
          replacementExerciseId: replacement.id,
        );
  }

  Future<void> _handleDeleteExercise(SessionExercise exercise) async {
    _closeOpenedItem();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final colors = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          icon: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors.error.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.delete_outline_rounded,
              color: colors.error,
              size: 24,
            ),
          ),
          title: const Text(
            'Xóa bài tập?',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
          content: Text(
            'Bạn có chắc muốn xóa "${exercise.name}" khỏi buổi tập này?',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13.5, color: Colors.grey),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: BorderSide(
                        color: colors.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      'Hủy',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.error,
                      foregroundColor: colors.onError,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Xóa',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) return;
    ref
        .read(workoutSessionProvider.notifier)
        .removeExercise(exercise.exerciseId);
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(workoutSessionProvider);
    final schedule = ref.watch(workoutScheduleProvider);
    final colors = Theme.of(context).colorScheme;
    final hasTodayWorkout = schedule.hasTodayWorkout;
    final todayWorkoutTitle = schedule.todayWorkout?.title;
    final displayTitle = session.title.isNotEmpty
        ? session.title
        : (todayWorkoutTitle ?? 'Upper Body A');

    final isTodayWorkoutCompleted = ref.watch(isTodayWorkoutCompletedProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Kế hoạch tập luyện')),
      body: GestureDetector(
        onTap: _closeOpenedItem,
        behavior: HitTestBehavior.opaque,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          children: [
            // Hero Workout Card with 3D Flippable Muscle Body Map or Empty State
            if (hasTodayWorkout && session.exercises.isNotEmpty)
              Card(
                margin: EdgeInsets.zero,
                color: isTodayWorkoutCompleted ? colors.surfaceContainer : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: isTodayWorkoutCompleted
                      ? BorderSide(
                          color: colors.outlineVariant.withValues(alpha: 0.35),
                          width: 1.2,
                        )
                      : BorderSide.none,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isTodayWorkoutCompleted
                                      ? Icons.check_circle_rounded
                                      : Icons.bolt_rounded,
                                  color: isTodayWorkoutCompleted
                                      ? AppColors.accentEmerald
                                      : Colors.amber,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isTodayWorkoutCompleted
                                      ? 'ĐÃ HOÀN THÀNH'
                                      : 'HÔM NAY',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                    color: isTodayWorkoutCompleted
                                        ? AppColors.accentEmerald
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              displayTitle,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.3,
                                color: isTodayWorkoutCompleted
                                    ? colors.onSurface.withValues(alpha: 0.88)
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${session.exercises.length} bài • ${session.totalSets} hiệp • ~45p',
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            LinearProgressIndicator(
                              value: isTodayWorkoutCompleted
                                  ? 1.0
                                  : (session.totalSets == 0
                                        ? 0
                                        : session.completedSets /
                                              session.totalSets),
                              color: isTodayWorkoutCompleted
                                  ? AppColors.accentEmerald
                                  : null,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isTodayWorkoutCompleted
                                  ? '${session.totalSets}/${session.totalSets} hiệp đã hoàn thành'
                                  : '${session.completedSets}/${session.totalSets} hiệp hoàn thành',
                              style: TextStyle(
                                fontSize: 11,
                                color: colors.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (isTodayWorkoutCompleted)
                              Container(
                                height: 42,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.surfaceContainerHighest
                                      .withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: colors.outlineVariant.withValues(
                                      alpha: 0.35,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle_rounded,
                                      size: 18,
                                      color: AppColors.accentEmerald,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Đã hoàn thành bài tập',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              FilledButton.icon(
                                onPressed: session.exercises.isEmpty
                                    ? null
                                    : () => context.push('/workout/session'),
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size(0, 42),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.play_arrow_rounded,
                                  size: 20,
                                ),
                                label: Text(
                                  session.completedSets > 0
                                      ? 'Tiếp tục buổi tập'
                                      : 'Bắt đầu tập',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Opacity(
                        opacity: isTodayWorkoutCompleted ? 0.65 : 1.0,
                        child: FlippableMuscleCard(
                          targetMuscles:
                              !session.isFinalized &&
                                  session.exercises.isNotEmpty
                              ? session.exercises
                                    .map((exercise) => exercise.primaryMuscle)
                                    .where((muscle) => muscle.isNotEmpty)
                                    .toSet()
                                    .toList()
                              : schedule.todayWorkout != null
                              ? schedule.todayWorkout!.targetMuscles
                                    .split(RegExp(r'[•,]'))
                                    .map((s) => s.trim())
                                    .where((s) => s.isNotEmpty)
                                    .toList()
                              : const ['Ngực', 'Tay sau', 'Vai'],
                          width: 90,
                          height: 126,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              TodayWorkoutEmptyState(
                title: 'Hôm nay chưa có lịch tập',
                subtitle:
                    'Bạn có thể tự tạo hoặc để VieGym AI thiết kế buổi tập chuẩn cho bạn.',
                aiButtonLabel: 'Tạo lịch tập với AI',
                onAiCreateWorkout: () {
                  final now = DateTime.now();
                  final todayStr =
                      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
                  ref
                      .read(workoutScheduleProvider.notifier)
                      .selectDate(todayStr);
                  context.push('/workout/generate');
                },
                buttonLabel: 'Thêm lịch tập hôm nay',
                onCreateWorkout: () {
                  final now = DateTime.now();
                  final todayStr =
                      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
                  ref
                      .read(workoutScheduleProvider.notifier)
                      .selectDate(todayStr);
                  context.push('/workout/schedule');
                },
              ),
            const SizedBox(height: 16),

            // 4 Shortcut Grid
            Row(
              children: [
                Expanded(
                  child: _Shortcut(
                    icon: Icons.search_rounded,
                    label: 'Thư viện',
                    onTap: () => context.push('/workout/library'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Shortcut(
                    icon: Icons.calendar_month_rounded,
                    label: 'Lịch tập',
                    onTap: () => context.push('/workout/schedule'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Shortcut(
                    icon: Icons.history_rounded,
                    label: 'Lịch sử',
                    onTap: () => context.push('/workout/history'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Shortcut(
                    icon: Icons.favorite_rounded,
                    label: 'Yêu thích',
                    onTap: () => context.push('/workout/favorites'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // Exercise List Header
            LayoutBuilder(
              builder: (context, constraints) {
                final title = Text(
                  'Danh sách bài hôm nay',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                );
                final count = Text(
                  '${session.exercises.length} bài tập',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurfaceVariant,
                  ),
                );

                if (constraints.maxWidth < 360) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [title, const SizedBox(height: 4), count],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: title),
                    const SizedBox(width: 12),
                    count,
                  ],
                );
              },
            ),
            const SizedBox(height: 10),

            // Exercises List with Swipeable Cards
            if (session.exercises.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'Hôm nay chưa có lịch tập',
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            else
              ...session.exercises.asMap().entries.map((entry) {
                final index = entry.key;
                final exercise = entry.value;
                final completed =
                    session.logs[exercise.exerciseId]
                        ?.where((set) => set.completed)
                        .length ??
                    0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _SwipeableExerciseItem(
                    key: ValueKey(exercise.exerciseId),
                    exercise: exercise,
                    index: index,
                    completedSets: completed,
                    isOpen: _openedExerciseId == exercise.exerciseId,
                    onOpen: () {
                      setState(() => _openedExerciseId = exercise.exerciseId);
                    },
                    onClose: () {
                      if (_openedExerciseId == exercise.exerciseId) {
                        setState(() => _openedExerciseId = null);
                      }
                    },
                    onChange: () => _handleChangeExercise(exercise),
                    onDelete: () => _handleDeleteExercise(exercise),
                    onTap: () {
                      _closeOpenedItem();
                      ref
                          .read(workoutSessionProvider.notifier)
                          .selectExercise(index);
                      context.push('/workout/session');
                    },
                    onInfoTap: () {
                      _closeOpenedItem();
                      context.push('/exercise/${exercise.exerciseId}');
                    },
                  ),
                );
              }),

            // Dedicated "+ Thêm bài tập mới" action after final exercise
            Card(
              elevation: 0,
              margin: const EdgeInsets.only(top: 4, bottom: 8),
              color: colors.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: colors.primary.withValues(alpha: 0.35),
                  width: 1.2,
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _handleAddExercise,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_rounded, color: colors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Thêm bài tập mới',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // AI Tạo bài - Full-Width Horizontal Banner
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    colors.primary.withValues(alpha: 0.14),
                    colors.surfaceContainer,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.35),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => context.push('/workout/generate'),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.primary.withValues(alpha: 0.2),
                          ),
                          child: Icon(
                            Icons.auto_awesome_rounded,
                            color: colors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'AI tạo lịch tập',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Bạn chưa biết tập gì? Hãy để VieGym giúp đỡ bạn !',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: colors.onSurfaceVariant,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: colors.primary,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwipeableExerciseItem extends StatefulWidget {
  const _SwipeableExerciseItem({
    super.key,
    required this.exercise,
    required this.index,
    required this.completedSets,
    required this.isOpen,
    required this.onOpen,
    required this.onClose,
    required this.onChange,
    required this.onDelete,
    required this.onTap,
    required this.onInfoTap,
  });

  final SessionExercise exercise;
  final int index;
  final int completedSets;
  final bool isOpen;
  final VoidCallback onOpen;
  final VoidCallback onClose;
  final VoidCallback onChange;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final VoidCallback onInfoTap;

  @override
  State<_SwipeableExerciseItem> createState() => _SwipeableExerciseItemState();
}

class _SwipeableExerciseItemState extends State<_SwipeableExerciseItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  static const double _actionsWidth = 152.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: widget.isOpen ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(covariant _SwipeableExerciseItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen != oldWidget.isOpen) {
      if (widget.isOpen) {
        _controller.animateTo(1.0, curve: Curves.easeOutCubic);
      } else {
        _controller.animateTo(0.0, curve: Curves.easeOutCubic);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final delta = details.primaryDelta ?? 0;
    _controller.value = (_controller.value - delta / _actionsWidth).clamp(
      0.0,
      1.0,
    );
  }

  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -300 || _controller.value > 0.4) {
      _controller.animateTo(1.0, curve: Curves.easeOutCubic);
      widget.onOpen();
    } else {
      _controller.animateTo(0.0, curve: Curves.easeOutCubic);
      widget.onClose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          // Background Action Buttons Area
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Thay đổi action
                Material(
                  color: colors.surfaceContainerHighest,
                  child: InkWell(
                    onTap: () {
                      _controller.animateTo(0.0);
                      widget.onChange();
                    },
                    child: SizedBox(
                      width: 76,
                      height: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.swap_horiz_rounded,
                            color: colors.onSurface,
                            size: 22,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Thay đổi',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: colors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Xóa action
                Material(
                  color: colors.error,
                  child: InkWell(
                    onTap: () {
                      _controller.animateTo(0.0);
                      widget.onDelete();
                    },
                    child: SizedBox(
                      width: 76,
                      height: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            color: colors.onError,
                            size: 22,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Xóa',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: colors.onError,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Foreground Exercise Card
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(-_controller.value * _actionsWidth, 0),
                child: child,
              );
            },
            child: GestureDetector(
              onHorizontalDragUpdate: _handleDragUpdate,
              onHorizontalDragEnd: _handleDragEnd,
              child: Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: colors.primary.withValues(alpha: 0.15),
                    child: Text(
                      '${widget.index + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: colors.primary,
                      ),
                    ),
                  ),
                  title: Text(
                    widget.exercise.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '${widget.exercise.primaryMuscle} • ${widget.exercise.equipment.label}\n${widget.exercise.targetSets} hiệp × ${widget.exercise.targetReps} reps',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${widget.completedSets}/${widget.exercise.targetSets}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.info_outline_rounded, size: 20),
                        onPressed: widget.onInfoTap,
                      ),
                    ],
                  ),
                  onTap: () {
                    if (_controller.value > 0.05) {
                      _controller.animateTo(0.0, curve: Curves.easeOutCubic);
                      widget.onClose();
                    } else {
                      widget.onTap();
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
          child: Column(
            children: [
              Icon(icon, color: colors.primary, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
