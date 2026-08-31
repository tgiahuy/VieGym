import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/workout_schedule_controller.dart';
import '../domain/muscle_models.dart';
import '../domain/workout_models.dart';
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

  Set<MuscleGroup> _getFrontMuscles(String target) {
    final t = target.toLowerCase();
    final Set<MuscleGroup> muscles = {};
    if (t.contains('ngực') || t.contains('chest') || t.contains('push')) {
      muscles.add(MuscleGroup.chest);
    }
    if (t.contains('vai') || t.contains('shoulder') || t.contains('push')) {
      muscles.add(MuscleGroup.frontDelts);
      muscles.add(MuscleGroup.sideDelts);
    }
    if (t.contains('tay trước') ||
        t.contains('biceps') ||
        t.contains('pull') ||
        t.contains('tay')) {
      muscles.add(MuscleGroup.biceps);
    }
    if (t.contains('tay sau') || t.contains('triceps') || t.contains('push')) {
      muscles.add(MuscleGroup.triceps);
    }
    if (t.contains('chân') ||
        t.contains('đùi') ||
        t.contains('legs') ||
        t.contains('leg') ||
        t.contains('quads')) {
      muscles.add(MuscleGroup.quads);
    }
    if (t.contains('bụng') || t.contains('core') || t.contains('abs')) {
      muscles.add(MuscleGroup.abs);
    }
    if (muscles.isEmpty) {
      muscles.addAll([MuscleGroup.chest, MuscleGroup.frontDelts]);
    }
    return muscles;
  }

  Set<MuscleGroup> _getBackMuscles(String target) {
    final t = target.toLowerCase();
    final Set<MuscleGroup> muscles = {};
    if (t.contains('lưng') ||
        t.contains('back') ||
        t.contains('pull') ||
        t.contains('xô')) {
      muscles.addAll([MuscleGroup.upperBack, MuscleGroup.lats]);
    }
    if (t.contains('vai') || t.contains('shoulder') || t.contains('pull')) {
      muscles.add(MuscleGroup.rearDelts);
    }
    if (t.contains('tay sau') || t.contains('triceps') || t.contains('push')) {
      muscles.add(MuscleGroup.triceps);
    }
    if (t.contains('mông') ||
        t.contains('glutes') ||
        t.contains('legs') ||
        t.contains('leg')) {
      muscles.add(MuscleGroup.glutes);
    }
    if (t.contains('đùi sau') ||
        t.contains('hamstrings') ||
        t.contains('chân') ||
        t.contains('legs') ||
        t.contains('leg')) {
      muscles.addAll([MuscleGroup.hamstrings, MuscleGroup.calves]);
    }
    if (muscles.isEmpty) {
      muscles.addAll([MuscleGroup.upperBack, MuscleGroup.rearDelts]);
    }
    return muscles;
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
                color: const Color(0xFF10131E),
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
                            color: colors.primary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.sync_alt_rounded,
                            color: colors.primary,
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
                                  color: Color(0xFF7E849E),
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
                              : const Color(0xFF171A28),
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
                                              : const Color(0xFF8E95AF),
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
                              backgroundColor: const Color(0xFF1B1E2E),
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

    // Generate days in current 2-week span that have no scheduled workouts
    final List<DateTime> emptyDays = [];
    for (int i = 0; i < 14; i++) {
      final d = _currentWeekMonday.add(Duration(days: i));
      final dStr = _formatDate(d);
      final hasWorkout = scheduleState.schedules.any((s) => s.date == dStr);
      if (!hasWorkout) {
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
                color: const Color(0xFF10131E),
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
                            color: colors.primary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.calendar_month_rounded,
                            color: colors.primary,
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
                                  color: Color(0xFF7E849E),
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
                              : const Color(0xFF171A28),
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
                              backgroundColor: const Color(0xFF1B1E2E),
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
    final colors = Theme.of(context).colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa lịch tập?'),
        content: Text(
          'Bạn có chắc muốn xóa buổi "${item.title}" khỏi lịch tập?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: colors.onError,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;
    HapticFeedback.mediumImpact();
    ref.read(workoutScheduleProvider.notifier).deleteSchedule(item.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã xóa buổi tập khỏi lịch.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheduleState = ref.watch(workoutScheduleProvider);
    final notifier = ref.read(workoutScheduleProvider.notifier);
    final colors = Theme.of(context).colorScheme;
    final selectedDaySchedules = scheduleState.selectedDaySchedules;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Lịch tập luyện'),
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
                        color: colors.primary,
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
                        color: colors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: colors.primary.withValues(alpha: 0.4),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.today_rounded,
                            size: 13,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Hôm nay',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: colors.primary,
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
                                    ? colors.primary
                                    : const Color(0xFF141724),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? colors.primary
                                      : colors.outlineVariant.withValues(
                                          alpha: 0.35,
                                        ),
                                  width: 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: colors.primary.withValues(
                                            alpha: 0.35,
                                          ),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : null,
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
                                          ? colors.onPrimary
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
                                          ? colors.onPrimary
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
                                                ? colors.onPrimary
                                                : colors.primary)
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
              Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 40,
                    horizontal: 16,
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B1E2E),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.bedtime_outlined,
                          size: 36,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Ngày nghỉ ngơi (Rest Day)',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Chưa có buổi tập nào được lên lịch cho ngày này.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...selectedDaySchedules.map((item) {
                final isSwiped = _swipedScheduleId == item.id;

                final plannedList = item.plannedExercises.isNotEmpty
                    ? item.plannedExercises
                    : const [
                        PlannedExercisePreview(
                          name: 'Lat Pulldown',
                          setsReps: '4x10',
                        ),
                        PlannedExercisePreview(
                          name: 'Seated Cable Row',
                          setsReps: '3x12',
                        ),
                        PlannedExercisePreview(
                          name: 'Face Pull',
                          setsReps: '3x15',
                        ),
                        PlannedExercisePreview(
                          name: 'Bicep Barbell Curl',
                          setsReps: '3x10',
                        ),
                      ];

                return Stack(
                  children: [
                    // Revealed Delete Background
                    Positioned.fill(
                      child: Container(
                        alignment: Alignment.centerRight,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE53935),
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
                          color: const Color(0xFF141724),
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
                                          color: Color(0xFF9096B0),
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
                                            color: colors.primary,
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
                                              color: Color(0xFF636A84),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Icon(
                                            Icons.access_time_filled_rounded,
                                            size: 16,
                                            color: colors.primary,
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
                                  frontPrimaryMuscles: _getFrontMuscles(
                                    item.targetMuscles,
                                  ),
                                  backPrimaryMuscles: _getBackMuscles(
                                    item.targetMuscles,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // 4. Section Label: CÁC BÀI TẬP DỰ KIẾN
                            const Text(
                              'CÁC BÀI TẬP DỰ KIẾN',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF7E849E),
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // 5. Planned Exercise Rows
                            ...plannedList.map((exercise) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 11,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1B1F2E),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFF262C40),
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
                                    Text(
                                      exercise.setsReps,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF8E95AF),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const SizedBox(height: 14),

                            // 6. Secondary Actions: [ Đổi buổi ] [ Đổi ngày ]
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _handleSwapWorkout(item),
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(0, 44),
                                      backgroundColor: const Color(0xFF181C2B),
                                      side: BorderSide(
                                        color: colors.outlineVariant.withValues(
                                          alpha: 0.4,
                                        ),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    icon: Icon(
                                      Icons.sync_alt_rounded,
                                      size: 16,
                                      color: colors.primary,
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
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _handleMoveDate(item),
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(0, 44),
                                      backgroundColor: const Color(0xFF181C2B),
                                      side: BorderSide(
                                        color: colors.outlineVariant.withValues(
                                          alpha: 0.4,
                                        ),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    icon: Icon(
                                      Icons.calendar_month_outlined,
                                      size: 16,
                                      color: colors.primary,
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
                              ],
                            ),
                            const SizedBox(height: 12),

                            // 7. Primary CTA: [ ▶ Bắt đầu tập ngay ]
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
