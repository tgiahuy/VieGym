import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../auth/application/auth_controller.dart';
import '../application/exercise_catalog_controller.dart';
import '../application/workout_schedule_controller.dart';
import '../application/workout_session_controller.dart';
import '../data/exercise_catalog.dart';
import '../data/workout_schedule_planning_repository.dart';
import '../domain/muscle_models.dart';
import '../domain/workout_models.dart';
import 'exercise_library_screen.dart';
import 'widgets/flippable_muscle_card.dart';

class WorkoutScheduleScreen extends ConsumerStatefulWidget {
  const WorkoutScheduleScreen({super.key});

  @override
  ConsumerState<WorkoutScheduleScreen> createState() =>
      _WorkoutScheduleScreenState();
}

class _WorkoutScheduleScreenState extends ConsumerState<WorkoutScheduleScreen> {
  static DateTime _getMonday(DateTime d) {
    return DateTime(
      d.year,
      d.month,
      d.day,
    ).subtract(Duration(days: d.weekday - 1));
  }

  static const int _initialPageIndex = 500;
  final PageController _weekPageController = PageController(
    initialPage: _initialPageIndex,
  );
  DateTime _baseMonday = _getMonday(DateTime.now());
  DateTime _currentWeekMonday = _getMonday(DateTime.now());
  String? _swipedScheduleId;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _baseMonday = _getMonday(now);
    _currentWeekMonday = _baseMonday;
    Future<void>.microtask(() {
      if (!mounted) return;
      ref.read(exerciseCatalogControllerProvider.notifier).loadInitial();
      if (ref.read(authProvider).isAuthenticated) {
        ref
            .read(workoutScheduleProvider.notifier)
            .syncFromServer(
              from: _baseMonday.subtract(const Duration(days: 28)),
              to: _baseMonday.add(const Duration(days: 62)),
            );
      }
    });
  }

  @override
  void dispose() {
    _weekPageController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) {
    final year = d.year;
    final month = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String _getDayNameVi(DateTime d) {
    switch (d.weekday) {
      case 1:
        return 'Thứ 2';
      case 2:
        return 'Thứ 3';
      case 3:
        return 'Thứ 4';
      case 4:
        return 'Thứ 5';
      case 5:
        return 'Thứ 6';
      case 6:
        return 'Thứ 7';
      case 7:
        return 'Chủ nhật';
      default:
        return '';
    }
  }

  void _onWeekPageChanged(int index) {
    final weekOffset = index - _initialPageIndex;
    setState(() {
      _currentWeekMonday = _baseMonday.add(Duration(days: weekOffset * 7));
    });
  }

  void _jumpToToday() {
    HapticFeedback.lightImpact();
    final now = DateTime.now();
    final todayStr = _formatDate(now);
    final nowMonday = _getMonday(now);
    final weekOffset = (nowMonday.difference(_baseMonday).inDays / 7).round();
    final targetPage = _initialPageIndex + weekOffset;

    if (_weekPageController.hasClients) {
      _weekPageController.animateToPage(
        targetPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    ref.read(workoutScheduleProvider.notifier).selectDate(todayStr);
  }

  // ==========================================
  // SWAP WORKOUT ("Đổi buổi") MODAL
  // ==========================================
  Future<void> _handleSwapWorkout(WorkoutScheduleItem current) async {
    setState(() => _swipedScheduleId = null);
    final scheduleState = ref.read(workoutScheduleProvider);
    final otherWorkouts = scheduleState.schedules
        .where(
          (s) => s.id != current.id && s.status != ScheduleStatus.completed,
        )
        .toList();

    if (otherWorkouts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không có buổi tập khác để đổi.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    String? selectedTargetId = otherWorkouts.first.id;

    final targetId = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        final colors = Theme.of(sheetContext).colorScheme;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceNested,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.sync_alt_rounded,
                            color: AppColors.iconSecondary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Đổi buổi tập với',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Hoán đổi lịch giữa hai buổi tập đã lên lịch',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...otherWorkouts.map((other) {
                      final isSelected = selectedTargetId == other.id;
                      final otherDate = DateTime.tryParse(other.date);
                      final dayLabel = otherDate != null
                          ? '${_getDayNameVi(otherDate)} (${other.date})'
                          : other.date;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colors.primary.withValues(alpha: 0.12)
                              : AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? colors.primary
                                : colors.outlineVariant.withValues(alpha: 0.3),
                            width: isSelected ? 1.2 : 0.8,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            setModalState(() => selectedTargetId = other.id);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? colors.primary
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected
                                          ? colors.primary
                                          : colors.onSurfaceVariant.withValues(
                                              alpha: 0.5,
                                            ),
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Center(
                                          child: Icon(
                                            Icons.check_rounded,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        dayLabel,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected
                                              ? colors.primary
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        other.title,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 48),
                              backgroundColor: AppColors.surfaceElevated,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text('Hủy'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: FilledButton(
                            onPressed: selectedTargetId == null
                                ? null
                                : () =>
                                      Navigator.pop(context, selectedTargetId),
                            style: FilledButton.styleFrom(
                              backgroundColor: colors.primary,
                              minimumSize: const Size(0, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Xác nhận đổi',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (!mounted || targetId == null) return;
    final success = ref
        .read(workoutScheduleProvider.notifier)
        .swapWorkouts(current.id, targetId);
    if (success) {
      HapticFeedback.mediumImpact();
    }
  }

  // ==========================================
  // MOVE WORKOUT TO EMPTY DAY ("Đổi ngày") MODAL
  // ==========================================
  Future<void> _handleMoveDate(WorkoutScheduleItem current) async {
    setState(() => _swipedScheduleId = null);
    final scheduleState = ref.read(workoutScheduleProvider);

    final todayStr = _formatDate(DateTime.now());
    // Generate days in current 2-week span that have no scheduled workouts and are not in the past
    final List<DateTime> emptyDays = [];
    for (int i = 0; i < 14; i++) {
      final d = _currentWeekMonday.add(Duration(days: i));
      final dStr = _formatDate(d);
      final hasWorkout = scheduleState.schedules.any((s) => s.date == dStr);
      if (!hasWorkout && dStr.compareTo(todayStr) >= 0) {
        emptyDays.add(d);
      }
    }

    if (emptyDays.isEmpty) {
      return;
    }

    String? selectedNewDate = _formatDate(emptyDays.first);

    final newDateStr = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        final colors = Theme.of(sheetContext).colorScheme;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceNested,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.calendar_month_rounded,
                            color: AppColors.iconSecondary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Chọn ngày mới cho buổi tập',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Chuyển buổi tập sang ngày trống',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...emptyDays.take(6).map((d) {
                      final dStr = _formatDate(d);
                      final isSelected = selectedNewDate == dStr;
                      final dayLabel = '${_getDayNameVi(d)} ($dStr)';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colors.primary.withValues(alpha: 0.12)
                              : AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? colors.primary
                                : colors.outlineVariant.withValues(alpha: 0.3),
                            width: isSelected ? 1.2 : 0.8,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            setModalState(() => selectedNewDate = dStr);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? colors.primary
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected
                                          ? colors.primary
                                          : colors.onSurfaceVariant.withValues(
                                              alpha: 0.5,
                                            ),
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Center(
                                          child: Icon(
                                            Icons.check_rounded,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  dayLabel,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: isSelected
                                        ? colors.primary
                                        : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 48),
                              backgroundColor: AppColors.surfaceElevated,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text('Hủy'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: FilledButton(
                            onPressed: selectedNewDate == null
                                ? null
                                : () => Navigator.pop(context, selectedNewDate),
                            style: FilledButton.styleFrom(
                              backgroundColor: colors.primary,
                              minimumSize: const Size(0, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Xác nhận chuyển',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (!mounted || newDateStr == null) return;
    final success = ref
        .read(workoutScheduleProvider.notifier)
        .moveWorkoutDate(current.id, newDateStr);
    if (success) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã chuyển buổi tập sang ngày $newDateStr!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ==========================================
  // DELETE SCHEDULE WORKOUT
  // ==========================================
  Future<void> _handleDeleteSchedule(WorkoutScheduleItem item) async {
    setState(() => _swipedScheduleId = null);
    HapticFeedback.selectionClick();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        final dateParts = item.date.split('-');
        final displayDate = dateParts.length == 3
            ? '${dateParts[2]}/${dateParts[1]}/${dateParts[0]}'
            : item.date;

        return SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              border: Border.all(color: AppColors.borderDefault),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderDefault,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.error,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Xóa buổi tập khỏi lịch?',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ngày $displayDate • ${item.time}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderDefault),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.fitness_center_rounded,
                        color: AppColors.cyan,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.targetMuscles,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Buổi tập này sẽ được gỡ khỏi lịch tập. Bạn vẫn có thể hoàn tác ngay sau khi xóa.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textTertiary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(modalContext, false),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Giữ lại'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton.icon(
                        onPressed: () => Navigator.pop(modalContext, true),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(
                          Icons.delete_forever_rounded,
                          size: 18,
                        ),
                        label: const Text(
                          'Xác nhận xóa',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || confirmed != true) return;
    HapticFeedback.heavyImpact();

    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final isToday = item.date == todayStr;
    final previousSession = ref.read(workoutSessionProvider);

    // 1. Delete from Riverpod state
    ref.read(workoutScheduleProvider.notifier).deleteSchedule(item.id);

    // 2. If today's workout was deleted, clear active session
    if (isToday) {
      ref.read(workoutSessionProvider.notifier).clearSession();
    }

    // 3. Call backend if it's a server-backed schedule
    if (item.id.startsWith('server_')) {
      final serverId = int.tryParse(item.id.substring(7));
      if (serverId != null) {
        try {
          await ref
              .read(workoutSchedulePlanningRepositoryProvider)
              .cancelSchedule(serverId);
        } catch (_) {}
      }
    }

    // 4. Show Smart Undo SnackBar
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.cyan,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Đã xóa "${item.title}" khỏi lịch tập.',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'HOÀN TÁC',
          textColor: AppColors.cyan,
          onPressed: () {
            ref.read(workoutScheduleProvider.notifier).restoreSchedule(item);
            if (isToday && previousSession.exercises.isNotEmpty) {
              ref
                  .read(workoutSessionProvider.notifier)
                  .setSession(
                    title: previousSession.title.isNotEmpty
                        ? previousSession.title
                        : item.title,
                    exercises: previousSession.exercises,
                  );
            }
            HapticFeedback.mediumImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đã khôi phục "${item.title}" vào lịch tập.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ),
    );
  }

  // ==========================================
  // EDIT SCHEDULE EXERCISES MODAL
  // ==========================================
  Future<void> _showEditExercisesSheet(
    BuildContext context,
    WorkoutScheduleItem item, {
    int? initialFocusedIndex,
  }) async {
    final scheduleNotifier = ref.read(workoutScheduleProvider.notifier);
    final plannedList = item.plannedExercises;

    final exercises = List<PlannedExercisePreview>.from(plannedList);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return SafeArea(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(modalContext).height * 0.90,
                ),
                padding: EdgeInsets.fromLTRB(
                  20,
                  14,
                  20,
                  MediaQuery.viewInsetsOf(modalContext).bottom + 20,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  border: Border.all(color: AppColors.borderDefault),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.borderDefault,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.cyan.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.fitness_center_rounded,
                            color: AppColors.cyan,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Sửa bài tập trong lịch',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${item.title} • ${item.date}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(modalContext),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Exercise list
                    Flexible(
                      child: exercises.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: Text(
                                  'Chưa có bài tập nào. Hãy bấm nút thêm bài bên dưới.',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: exercises.length,
                              separatorBuilder: (context, _) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final ex = exercises[index];
                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceElevated,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: initialFocusedIndex == index
                                          ? AppColors.cyan.withValues(
                                              alpha: 0.5,
                                            )
                                          : AppColors.borderDefault,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: AppColors.cyan.withValues(
                                                alpha: 0.15,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              '${index + 1}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w900,
                                                color: AppColors.cyan,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              ex.name,
                                              style: const TextStyle(
                                                fontSize: 14.5,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () async {
                                              final updated =
                                                  await _showSetsRepsPicker(
                                                    modalContext,
                                                    ex.setsReps,
                                                  );
                                              if (updated != null) {
                                                setModalState(() {
                                                  exercises[index] =
                                                      PlannedExercisePreview(
                                                        name: ex.name,
                                                        setsReps: updated,
                                                        primaryMuscle:
                                                            ex.primaryMuscle,
                                                      );
                                                });
                                              }
                                            },
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColors.surface,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color:
                                                      AppColors.borderDefault,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    ex.setsReps,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: AppColors.cyan,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  const Icon(
                                                    Icons.edit_rounded,
                                                    size: 12,
                                                    color: AppColors.cyan,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: () async {
                                                final replaced =
                                                    await _showExercisePickerModal(
                                                      modalContext,
                                                      item.targetMuscles,
                                                    );
                                                if (replaced != null) {
                                                  setModalState(() {
                                                    exercises[index] =
                                                        PlannedExercisePreview(
                                                          name: replaced.name,
                                                          setsReps: ex.setsReps,
                                                          primaryMuscle:
                                                              replaced
                                                                  .primaryMuscle,
                                                        );
                                                  });
                                                }
                                              },
                                              style: OutlinedButton.styleFrom(
                                                minimumSize: const Size(0, 36),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                side: const BorderSide(
                                                  color:
                                                      AppColors.borderDefault,
                                                ),
                                              ),
                                              icon: const Icon(
                                                Icons.swap_horiz_rounded,
                                                size: 15,
                                                color: Colors.white,
                                              ),
                                              label: const Text(
                                                'Đổi bài khác',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            onPressed: () {
                                              if (exercises.length <= 1) {
                                                ScaffoldMessenger.of(
                                                  modalContext,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Buổi tập cần ít nhất 1 bài tập.',
                                                    ),
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                  ),
                                                );
                                                return;
                                              }
                                              setModalState(() {
                                                exercises.removeAt(index);
                                              });
                                            },
                                            tooltip: 'Xóa bài này',
                                            icon: const Icon(
                                              Icons.delete_outline_rounded,
                                              size: 18,
                                              color: AppColors.error,
                                            ),
                                            style: IconButton.styleFrom(
                                              minimumSize: const Size(36, 36),
                                              padding: EdgeInsets.zero,
                                              backgroundColor: AppColors.error
                                                  .withValues(alpha: 0.1),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 12),

                    // Add Exercise button
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final added = await _showExercisePickerModal(
                            modalContext,
                            item.targetMuscles,
                          );
                          if (added != null) {
                            setModalState(() {
                              exercises.add(
                                PlannedExercisePreview(
                                  name: added.name,
                                  setsReps: '3x10',
                                  primaryMuscle: added.primaryMuscle,
                                ),
                              );
                            });
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.cyan,
                          side: BorderSide(
                            color: AppColors.cyan.withValues(alpha: 0.6),
                            style: BorderStyle.solid,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text(
                          'Thêm bài tập mới',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: exercises.isEmpty
                            ? null
                            : () {
                                final calculatedMuscles = exercises
                                    .map((e) => e.primaryMuscle)
                                    .where(
                                      (m) => m != null && m.trim().isNotEmpty,
                                    )
                                    .cast<String>()
                                    .toSet()
                                    .join(' • ');
                                final newTargetMuscles =
                                    calculatedMuscles.isNotEmpty
                                        ? calculatedMuscles
                                        : item.targetMuscles;

                                scheduleNotifier.updateScheduleExercises(
                                  scheduleId: item.id,
                                  exercises: exercises,
                                  targetMuscles: newTargetMuscles,
                                );
                                final now = DateTime.now();
                                final todayStr = _formatDate(now);
                                if (item.date == todayStr) {
                                  ref
                                      .read(workoutSessionProvider.notifier)
                                      .loadFromSchedule(
                                        item.copyWith(
                                          plannedExercises: exercises,
                                          targetMuscles: newTargetMuscles,
                                        ),
                                      );
                                }
                                HapticFeedback.heavyImpact();
                                Navigator.pop(modalContext);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Đã cập nhật bài tập cho buổi "${item.title}"!',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.cyan,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.check_circle_rounded, size: 20),
                        label: Text(
                          'Lưu thay đổi (${exercises.length} bài tập)',
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // EXERCISE PICKER MODAL (Search & Muscle filter)
  // ==========================================
  Future<ExerciseDefinition?> _showExercisePickerModal(
    BuildContext context,
    String? targetMuscles,
  ) async {
    final currentCatalog = ref.read(exerciseCatalogControllerProvider);
    if (currentCatalog.exercises.isEmpty && !currentCatalog.isLoading) {
      ref.read(exerciseCatalogControllerProvider.notifier).loadInitial();
    }

    String searchQuery = '';
    String selectedMuscle = 'Tất cả';

    final muscleFilters = [
      'Tất cả',
      'Ngực',
      'Lưng',
      'Vai',
      'Tay trước',
      'Tay sau',
      'Đùi',
      'Mông',
      'Bụng',
      'Cardio',
    ];

    return showModalBottomSheet<ExerciseDefinition>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (pickerContext) {
        return Consumer(
          builder: (consumerContext, consumerRef, _) {
            final catalogState = consumerRef.watch(
              exerciseCatalogControllerProvider,
            );

            final Map<String, ExerciseDefinition> allExercisesMap = {};
            for (final e in exerciseCatalog) {
              allExercisesMap[e.name.toLowerCase().trim()] = e;
            }
            for (final e in catalogState.exercises) {
              allExercisesMap[e.name.toLowerCase().trim()] = e;
            }
            final allExercises = allExercisesMap.values.toList();

            return StatefulBuilder(
              builder: (modalContext, setModalState) {
                final filtered = allExercises.where((ex) {
                  final matchesQuery =
                      searchQuery.isEmpty ||
                      ex.name.toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      ) ||
                      ex.nameVi.toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      ) ||
                      ex.primaryMuscle.toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      ) ||
                      ex.equipment.label.toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      );

                  final matchesMuscle =
                      selectedMuscle == 'Tất cả' ||
                      ex.primaryMuscle.toLowerCase().contains(
                        selectedMuscle.toLowerCase(),
                      ) ||
                      ex.secondaryMuscles.any(
                        (m) => m.toLowerCase().contains(
                          selectedMuscle.toLowerCase(),
                        ),
                      );

                  return matchesQuery && matchesMuscle;
                }).toList();

                return SafeArea(
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.sizeOf(modalContext).height * 0.88,
                    ),
                    padding: EdgeInsets.fromLTRB(
                      20,
                      14,
                      20,
                      MediaQuery.viewInsetsOf(modalContext).bottom + 20,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                      border: Border.all(color: AppColors.borderDefault),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.borderDefault,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Chọn bài tập (${allExercises.length} bài)',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () async {
                                final ExerciseDefinition? picked;
                                if (GoRouter.maybeOf(context) != null) {
                                  picked = await context.push<ExerciseDefinition>(
                                    '/workout/library?select=true&title=${Uri.encodeComponent('Chọn bài tập')}',
                                  );
                                } else {
                                  picked =
                                      await Navigator.of(
                                        context,
                                        rootNavigator: true,
                                      ).push<ExerciseDefinition>(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ExerciseLibraryScreen(
                                                isPicker: true,
                                                title: 'Chọn bài tập',
                                              ),
                                        ),
                                      );
                                }
                                if (picked != null && modalContext.mounted) {
                                  Navigator.pop(modalContext, picked);
                                }
                              },
                              icon: const Icon(
                                Icons.menu_book_rounded,
                                size: 16,
                                color: AppColors.cyan,
                              ),
                              label: const Text(
                                'Mở thư viện',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.cyan,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Search field
                        TextField(
                          onChanged: (val) =>
                              setModalState(() => searchQuery = val.trim()),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                'Tìm trong ${allExercises.length} bài tập...',
                            hintStyle: const TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 13.5,
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: AppColors.iconSecondary,
                              size: 20,
                            ),
                            filled: true,
                            fillColor: AppColors.surfaceElevated,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Muscle Filter Chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: muscleFilters.map((muscle) {
                              final isSelected = selectedMuscle == muscle;
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: FilterChip(
                                  label: Text(
                                    muscle,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: isSelected
                                          ? FontWeight.w900
                                          : FontWeight.w600,
                                      color: isSelected
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                  ),
                                  selected: isSelected,
                                  selectedColor: AppColors.cyan,
                                  backgroundColor: AppColors.surfaceElevated,
                                  side: BorderSide(
                                    color: isSelected
                                        ? AppColors.cyan
                                        : AppColors.borderDefault,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  showCheckmark: false,
                                  onSelected: (_) {
                                    setModalState(
                                      () => selectedMuscle = muscle,
                                    );
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Results list
                        Flexible(
                          child: filtered.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 24,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          'Không tìm thấy bài tập tương ứng',
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 13.5,
                                          ),
                                        ),
                                        if (searchQuery.isNotEmpty) ...[
                                          const SizedBox(height: 10),
                                          OutlinedButton.icon(
                                            onPressed: () {
                                              final inferredMuscle =
                                                  selectedMuscle != 'Tất cả'
                                                      ? selectedMuscle
                                                      : (MuscleGroup.fromString(
                                                            searchQuery,
                                                          )?.nameVi ??
                                                          'Toàn thân');
                                              Navigator.pop(
                                                modalContext,
                                                ExerciseDefinition(
                                                  id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                                                  name: searchQuery,
                                                  nameVi: searchQuery,
                                                  primaryMuscle:
                                                      inferredMuscle,
                                                  primaryMuscleKey: 'other',
                                                  equipment:
                                                      EquipmentType.bodyweight,
                                                  instructions: const [],
                                                  commonMistakes: const [],
                                                  description: '',
                                                  secondaryMuscles: const [],
                                                ),
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.add,
                                              size: 16,
                                            ),
                                            label: Text(
                                              'Dùng tên "$searchQuery"',
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: filtered.length,
                                  separatorBuilder: (context, _) =>
                                      const SizedBox(height: 8),
                                  itemBuilder: (context, idx) {
                                    final ex = filtered[idx];
                                    return InkWell(
                                      onTap: () =>
                                          Navigator.pop(modalContext, ex),
                                      borderRadius: BorderRadius.circular(14),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceElevated,
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          border: Border.all(
                                            color: AppColors.borderDefault,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    ex.name,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    '${ex.nameVi.isNotEmpty ? '${ex.nameVi} • ' : ''}${ex.primaryMuscle} (${ex.equipment.label})',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: AppColors
                                                          .textSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Icon(
                                              Icons.add_circle_outline_rounded,
                                              color: AppColors.cyan,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // ==========================================
  // SETS & REPS PICKER DIALOG
  // ==========================================
  Future<String?> _showSetsRepsPicker(
    BuildContext context,
    String currentSetsReps,
  ) async {
    final presets = [
      '3x8',
      '3x10',
      '3x12',
      '3x15',
      '4x8',
      '4x10',
      '4x12',
      '5x5',
      '10p',
      '15p',
      '20p',
      '30p',
    ];

    String selected = currentSetsReps;

    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (pickerContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return SafeArea(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  border: Border.all(color: AppColors.borderDefault),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.borderDefault,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Điều chỉnh số hiệp & số rep / thời gian',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: presets.map((preset) {
                        final isSelected = selected == preset;
                        return ChoiceChip(
                          label: Text(
                            preset,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w900
                                  : FontWeight.w700,
                              color: isSelected ? Colors.black : Colors.white,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.cyan,
                          backgroundColor: AppColors.surfaceElevated,
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.cyan
                                : AppColors.borderDefault,
                          ),
                          onSelected: (_) {
                            setModalState(() => selected = preset);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: FilledButton(
                        onPressed: () => Navigator.pop(modalContext, selected),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.cyan,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Xác nhận',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showManualLogSheet(
    BuildContext context,
    String targetDate,
  ) async {
    final dateParts = targetDate.split('-');
    final displayDate = dateParts.length == 3
        ? '${dateParts[2]}/${dateParts[1]}/${dateParts[0]}'
        : targetDate;

    final nameController = TextEditingController(text: 'Buổi tập tự do');
    final selectedMuscles = <String>{'Ngực', 'Tay sau'};
    var duration = 45;
    var setsCount = 12;
    const volumeKg = 2000.0;

    final availableMuscles = [
      'Ngực',
      'Lưng',
      'Vai',
      'Tay trước',
      'Tay sau',
      'Đùi trước',
      'Đùi sau',
      'Mông',
      'Bụng',
      'Cardio',
    ];

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return SafeArea(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(modalContext).height * 0.88,
                ),
                padding: EdgeInsets.fromLTRB(
                  20,
                  14,
                  20,
                  MediaQuery.viewInsetsOf(modalContext).bottom + 20,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  border: Border.all(color: AppColors.borderDefault),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.borderDefault,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.cyan.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.edit_note_rounded,
                              color: AppColors.cyan,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Ghi lại lịch đã tập bằng tay',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Ngày $displayDate',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.cyan,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Workout Name
                      const Text(
                        'TÊN BUỔI TẬP',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textTertiary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: nameController,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Nhập tên buổi tập...',
                          filled: true,
                          fillColor: AppColors.surfaceElevated,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: AppColors.borderDefault,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Target Muscles
                      const Text(
                        'NHÓM CƠ ĐÃ TẬP',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textTertiary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: availableMuscles.map((muscle) {
                          final isSelected = selectedMuscles.contains(muscle);
                          return FilterChip(
                            label: Text(muscle),
                            selected: isSelected,
                            onSelected: (val) {
                              setModalState(() {
                                if (val) {
                                  selectedMuscles.add(muscle);
                                } else {
                                  selectedMuscles.remove(muscle);
                                }
                              });
                            },
                            selectedColor: AppColors.cyan.withValues(
                              alpha: 0.2,
                            ),
                            checkmarkColor: AppColors.cyan,
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? AppColors.cyan
                                  : Colors.white70,
                            ),
                            backgroundColor: AppColors.surfaceElevated,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.cyan
                                    : AppColors.borderDefault,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),

                      // Stats Row: Duration & Sets
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.borderDefault,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'THỜI GIAN',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () {
                                          if (duration > 15) {
                                            setModalState(() => duration -= 15);
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                          size: 20,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      Text(
                                        '$duration phút',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      ),
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () {
                                          if (duration < 180) {
                                            setModalState(() => duration += 15);
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                          size: 20,
                                          color: AppColors.cyan,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.borderDefault,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'SỐ HIỆP',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () {
                                          if (setsCount > 1) {
                                            setModalState(() => setsCount -= 1);
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                          size: 20,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      Text(
                                        '$setsCount hiệp',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      ),
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () {
                                          if (setsCount < 50) {
                                            setModalState(() => setsCount += 1);
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                          size: 20,
                                          color: AppColors.cyan,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton.icon(
                          onPressed: () {
                            final title = nameController.text.trim().isEmpty
                                ? 'Buổi tập tự do'
                                : nameController.text.trim();
                            ref
                                .read(workoutScheduleProvider.notifier)
                                .recordWorkoutCompletion(
                                  workoutName: title,
                                  durationMinutes: duration,
                                  totalVolumeKg: volumeKg,
                                  completedSets: setsCount,
                                  prCount: 0,
                                  date: targetDate,
                                  targetMuscles: selectedMuscles.toList(),
                                );
                            HapticFeedback.heavyImpact();
                            Navigator.pop(modalContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Đã ghi nhận buổi tập "$title" vào ngày $displayDate!',
                                ),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: AppColors.success,
                              ),
                            );
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.cyan,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(Icons.check_circle_rounded),
                          label: const Text(
                            'Lưu vào nhật ký',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheduleState = ref.watch(workoutScheduleProvider);
    final notifier = ref.read(workoutScheduleProvider.notifier);
    final colors = Theme.of(context).colorScheme;
    final selectedDaySchedules = scheduleState.selectedDaySchedules;
    final todayStr = _formatDate(DateTime.now());
    final isSelectedToday = scheduleState.selectedDate == todayStr;
    final isPastDay = scheduleState.selectedDate.compareTo(todayStr) < 0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Lịch tập luyện'),
        actions: [
          if (!isPastDay)
            IconButton(
              tooltip: 'Tạo lịch tập',
              onPressed: () => context.push(
                '/workout/schedule/create?date=${scheduleState.selectedDate}',
              ),
              icon: const Icon(Icons.add_circle_outline_rounded),
            )
          else
            IconButton(
              tooltip: 'Ghi lại lịch đã tập',
              onPressed: () =>
                  _showManualLogSheet(context, scheduleState.selectedDate),
              icon: const Icon(Icons.edit_note_rounded),
            ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          if (_swipedScheduleId != null) {
            setState(() => _swipedScheduleId = null);
          }
        },
        behavior: HitTestBehavior.opaque,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          children: [
            // Calendar Month Header with "Hôm nay" button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        size: 18,
                        color: AppColors.iconSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tháng ${_currentWeekMonday.month}, ${_currentWeekMonday.year}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: _jumpToToday,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.borderDefault,
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.today_rounded,
                            size: 13,
                            color: AppColors.iconSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Hôm nay',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Horizontal Swipable Weekly Calendar Carousel (PageView)
            SizedBox(
              height: 72,
              child: PageView.builder(
                controller: _weekPageController,
                onPageChanged: _onWeekPageChanged,
                itemBuilder: (context, pageIndex) {
                  final offset = pageIndex - _initialPageIndex;
                  final weekStart = _baseMonday.add(Duration(days: offset * 7));
                  final days = List.generate(
                    7,
                    (i) => weekStart.add(Duration(days: i)),
                  );
                  final dayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: days.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final date = entry.value;
                      final dateStr = _formatDate(date);
                      final isSelected = dateStr == scheduleState.selectedDate;
                      final hasSchedule = scheduleState.schedules.any(
                        (s) => s.date == dateStr,
                      );

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.5),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              HapticFeedback.selectionClick();
                              notifier.selectDate(dateStr);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primarySoft
                                    : AppColors.surfaceInput,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primaryBorder
                                      : colors.outlineVariant.withValues(
                                          alpha: 0.35,
                                        ),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    dayLabels[idx],
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected
                                          ? colors.primary
                                          : colors.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${date.day}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: isSelected
                                          ? Colors.white
                                          : colors.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: hasSchedule
                                          ? (isSelected
                                                ? colors.primary
                                                : colors.onSurfaceVariant)
                                          : Colors.transparent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Scheduled Workout Card Section
            if (selectedDaySchedules.isEmpty)
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: colors.surfaceContainer,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Icon(
                        isPastDay
                            ? Icons.history_toggle_off_rounded
                            : Icons.fitness_center_rounded,
                        size: 26,
                        color: isPastDay ? AppColors.cyan : colors.primary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Chưa có lịch tập ngày này',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isPastDay
                          ? 'Ngày này đã qua. Bạn không thể tạo lịch tập mới cho ngày trong quá khứ, nhưng có thể ghi lại kết quả buổi tập bạn đã hoàn thành.'
                          : 'Bạn có thể tự thiết kế buổi tập hoặc để VieGym AI lên giáo án cá nhân hóa.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.4,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (isPastDay) ...[
                      // Past Day Action: ONLY manual workout recording
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton.icon(
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            _showManualLogSheet(
                              context,
                              scheduleState.selectedDate,
                            );
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.cyan,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.edit_note_rounded, size: 20),
                          label: const Text(
                            'Ghi lại lịch đã tập bằng tay',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      // Future / Today Actions:
                      // 1. AI tạo lịch tập Button
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: FilledButton.icon(
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            ref
                                .read(workoutScheduleProvider.notifier)
                                .selectDate(scheduleState.selectedDate);
                            context.push('/workout/generate');
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(
                            Icons.auto_awesome_rounded,
                            size: 18,
                          ),
                          label: const Text(
                            'AI tạo lịch tập',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 2. Tự tạo lịch tập Button
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            context.push(
                              '/workout/builder?date=${scheduleState.selectedDate}',
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colors.onSurface,
                            side: BorderSide(
                              color: colors.outlineVariant.withValues(
                                alpha: 0.6,
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text(
                            'Tự tạo lịch tập',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: TextButton.icon(
                          onPressed: () => context.push(
                            '/workout/schedule/create?date=${scheduleState.selectedDate}',
                          ),
                          icon: const Icon(Icons.menu_book_rounded, size: 18),
                          label: const Text(
                            'Áp dụng giáo án có sẵn',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              )
            else
              ...selectedDaySchedules.map((item) {
                final isSwiped = _swipedScheduleId == item.id;

                final plannedList = item.plannedExercises;

                return Stack(
                  children: [
                    // Revealed Delete Background
                    Positioned.fill(
                      child: Container(
                        alignment: Alignment.centerRight,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: InkWell(
                          onTap: () => _handleDeleteSchedule(item),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Xóa',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Swipeable Foreground Card
                    GestureDetector(
                      onHorizontalDragEnd: (details) {
                        if (details.primaryVelocity != null) {
                          if (details.primaryVelocity! < -150) {
                            setState(() => _swipedScheduleId = item.id);
                          } else if (details.primaryVelocity! > 150) {
                            setState(() => _swipedScheduleId = null);
                          }
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        transform: Matrix4.translationValues(
                          isSwiped ? -80.0 : 0.0,
                          0.0,
                          0.0,
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: colors.outlineVariant.withValues(alpha: 0.4),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row: Info on left, Flippable Muscle Map on right
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (isPastDay ||
                                          item.status ==
                                              ScheduleStatus.completed) ...[
                                        Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 6,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.success.withValues(
                                              alpha: 0.15,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: AppColors.success
                                                  .withValues(alpha: 0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: const [
                                              Icon(
                                                Icons.check_circle_rounded,
                                                size: 13,
                                                color: AppColors.success,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'ĐÃ HOÀN THÀNH',
                                                style: TextStyle(
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w900,
                                                  color: AppColors.success,
                                                  letterSpacing: 0.4,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],

                                      // 1. Workout Name
                                      Text(
                                        item.title,
                                        style: const TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 4),

                                      // 2. Target Muscles
                                      Text(
                                        item.targetMuscles,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      // 3. Exercise Count & Duration Row
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.layers_rounded,
                                            size: 17,
                                            color: AppColors.iconSecondary,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${plannedList.length} bài tập',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          const Text(
                                            '•',
                                            style: TextStyle(
                                              color: AppColors.textTertiary,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Icon(
                                            Icons.access_time_filled_rounded,
                                            size: 16,
                                            color: AppColors.iconSecondary,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${item.durationMinutes}p',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // 3D Flippable Muscle Visualizer (Mặt trước / Mặt sau)
                                FlippableMuscleCard(
                                  width: 82,
                                  height: 114,
                                  targetMuscles: {
                                    ...item.targetMuscles
                                        .split(
                                          RegExp(
                                            r'[,•&+/]|\bvà\b',
                                            caseSensitive: false,
                                          ),
                                        )
                                        .map((s) => s.trim())
                                        .where((s) => s.isNotEmpty),
                                    ...item.plannedExercises
                                        .map((e) => e.primaryMuscle)
                                        .where(
                                          (s) => s != null && s.trim().isNotEmpty,
                                        )
                                        .cast<String>(),
                                  }.toList(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // 4. Section Label: CÁC BÀI TẬP DỰ KIẾN + Sửa bài tập
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'CÁC BÀI TẬP DỰ KIẾN',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textTertiary,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                if (!isPastDay)
                                  InkWell(
                                    onTap: () =>
                                        _showEditExercisesSheet(context, item),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(
                                            Icons.edit_note_rounded,
                                            size: 16,
                                            color: AppColors.cyan,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Sửa bài tập',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.cyan,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // 5. Planned Exercise Rows
                            ...plannedList.asMap().entries.map((entry) {
                              final index = entry.key;
                              final exercise = entry.value;
                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: !isPastDay
                                      ? () => _showEditExercisesSheet(
                                          context,
                                          item,
                                          initialFocusedIndex: index,
                                        )
                                      : null,
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 11,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceElevated,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: AppColors.borderDefault,
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            exercise.name,
                                            style: const TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              exercise.setsReps,
                                              style: const TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                            if (!isPastDay) ...[
                                              const SizedBox(width: 6),
                                              const Icon(
                                                Icons.tune_rounded,
                                                size: 14,
                                                color: AppColors.iconSecondary,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 14),

                            // 6. Actions: For past days show [Đã hoàn thành] + [🗑️ Xóa], for today/future show [Đổi buổi] [Đổi ngày] [🗑️ Xóa]
                            if (isPastDay) ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 44,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.success.withValues(
                                          alpha: 0.12,
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: AppColors.success.withValues(
                                            alpha: 0.35,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Icon(
                                            Icons.check_circle_rounded,
                                            size: 18,
                                            color: AppColors.success,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Đã hoàn thành',
                                            style: TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.success,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: AppColors.error.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ),
                                    child: IconButton(
                                      onPressed: () =>
                                          _handleDeleteSchedule(item),
                                      tooltip: 'Xóa buổi tập',
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: AppColors.error,
                                        size: 20,
                                      ),
                                      style: IconButton.styleFrom(
                                        minimumSize: const Size(44, 44),
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _handleSwapWorkout(item),
                                      style: OutlinedButton.styleFrom(
                                        minimumSize: const Size(0, 44),
                                        backgroundColor:
                                            AppColors.surfaceElevated,
                                        side: BorderSide(
                                          color: colors.outlineVariant
                                              .withValues(alpha: 0.4),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.sync_alt_rounded,
                                        size: 16,
                                        color: AppColors.iconSecondary,
                                      ),
                                      label: const Text(
                                        'Đổi buổi',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _handleMoveDate(item),
                                      style: OutlinedButton.styleFrom(
                                        minimumSize: const Size(0, 44),
                                        backgroundColor:
                                            AppColors.surfaceElevated,
                                        side: BorderSide(
                                          color: colors.outlineVariant
                                              .withValues(alpha: 0.4),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.calendar_month_outlined,
                                        size: 16,
                                        color: AppColors.iconSecondary,
                                      ),
                                      label: const Text(
                                        'Đổi ngày',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: AppColors.error.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ),
                                    child: IconButton(
                                      onPressed: () =>
                                          _handleDeleteSchedule(item),
                                      tooltip: 'Xóa buổi tập',
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: AppColors.error,
                                        size: 20,
                                      ),
                                      style: IconButton.styleFrom(
                                        minimumSize: const Size(44, 44),
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (isSelectedToday) ...[
                              const SizedBox(height: 12),

                              // 7. Primary CTA: [ ▶ Bắt đầu tập ngay ] (Chỉ hiển thị cho ngày hôm nay)
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: () =>
                                      context.push('/workout/session'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: colors.primary,
                                    minimumSize: const Size(0, 48),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.play_arrow_rounded,
                                    size: 20,
                                  ),
                                  label: const Text(
                                    'Bắt đầu tập ngay',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
          ],
        ),
      ),
    );
  }
}
