import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../application/exercise_catalog_controller.dart';
import '../application/workout_schedule_controller.dart';
import '../application/workout_session_controller.dart';
import '../data/exercise_catalog.dart';
import '../data/workout_schedule_planning_repository.dart';
import '../domain/workout_models.dart';
import 'widgets/schedule_proposal_dialog.dart';

enum _SourceTab { personal, admin }

class WorkoutScheduleCreateScreen extends ConsumerStatefulWidget {
  const WorkoutScheduleCreateScreen({
    super.key,
    this.initialDate,
    this.initialTab,
  });

  final DateTime? initialDate;
  final String? initialTab;

  @override
  ConsumerState<WorkoutScheduleCreateScreen> createState() =>
      _WorkoutScheduleCreateScreenState();
}

class _WorkoutScheduleCreateScreenState
    extends ConsumerState<WorkoutScheduleCreateScreen> {
  _SourceTab _sourceTab = _SourceTab.personal;
  bool _wholeWeek = false;
  bool _loading = true;
  bool _submitting = false;
  String? _error;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  List<WorkoutPlanSource> _personal = const [];
  List<WorkoutPlanSource> _admin = const [];
  WorkoutPlanSource? _selected;
  WorkoutPlanSource? _originalSelected;
  WorkoutPlanDay? _selectedDay;
  int _selectedDayIndex = 0;
  late DateTime _date;
  TimeOfDay _time = const TimeOfDay(hour: 18, minute: 0);

  @override
  void initState() {
    super.initState();
    if (widget.initialTab == 'admin') {
      _sourceTab = _SourceTab.admin;
    } else {
      _sourceTab = _SourceTab.personal;
    }
    final initial = widget.initialDate ?? DateTime.now();
    final today = DateUtils.dateOnly(DateTime.now());
    _date = DateUtils.dateOnly(initial).isBefore(today) ? today : initial;
    _loadSources();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSources() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repository = ref.read(workoutSchedulePlanningRepositoryProvider);
      final results = await Future.wait([
        repository.loadPersonalPrograms(),
        repository.loadAdminTemplates(),
      ]);
      if (!mounted) return;
      setState(() {
        _personal = results[0];
        _admin = results[1];
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _selectSource(WorkoutPlanSource source) async {
    HapticFeedback.selectionClick();
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final detail = await ref
          .read(workoutSchedulePlanningRepositoryProvider)
          .loadSourceDetail(source);
      if (!mounted) return;

      final updatedDays = detail.days.map((day) {
        if (day.exercises.isEmpty && source.sourceType != 'ADMIN_TEMPLATE') {
          final fallback = resolveDefaultExercisesForDay(day.name, detail.name);
          return day.copyWith(
            exercises: fallback,
            exerciseCount: fallback.length,
          );
        }
        return day;
      }).toList();
      final fullDetail = detail.copyWith(days: updatedDays);

      setState(() {
        _selected = fullDetail;
        _originalSelected = fullDetail;
        _selectedDayIndex = 0;
        _selectedDay = updatedDays.firstOrNull;
        _wholeWeek = updatedDays.length > 1 && _wholeWeek;
        _submitting = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateUtils.dateOnly(DateTime.now()),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (selected != null) {
      setState(
        () => _date = _wholeWeek ? _normalizedWeekStart(selected) : selected,
      );
    }
  }

  Future<void> _pickTime() async {
    final selected = await showTimePicker(context: context, initialTime: _time);
    if (selected != null) setState(() => _time = selected);
  }

  List<DateTime> _targetDates(int count) {
    if (!_wholeWeek || count <= 1) return [_date];
    final monday = _normalizedWeekStart(_date);
    return List.generate(count, (index) {
      final offset = count == 1 ? 0 : (index * 6 / (count - 1)).round();
      return monday.add(Duration(days: offset));
    });
  }

  DateTime _normalizedWeekStart(DateTime date) {
    var monday = DateUtils.dateOnly(
      date.subtract(Duration(days: date.weekday - 1)),
    );
    final today = DateUtils.dateOnly(DateTime.now());
    if (monday.isBefore(today)) monday = monday.add(const Duration(days: 7));
    return monday;
  }

  List<String> _findConflictingDates(List<DateTime> targetDates) {
    final scheduleState = ref.read(workoutScheduleProvider);
    final conflicting = <String>[];
    for (final d in targetDates) {
      final dStr = _formatDate(d);
      final hasPlanned = scheduleState.schedules.any(
        (s) => s.date == dStr && s.status == ScheduleStatus.planned,
      );
      if (hasPlanned) {
        conflicting.add('${d.day}/${d.month}');
      }
    }
    return conflicting;
  }

  Future<void> _removeConflictingSchedules(List<DateTime> targetDates) async {
    final targetDateStrings = targetDates.map(_formatDate).toSet();
    final conflicts = ref
        .read(workoutScheduleProvider)
        .schedules
        .where(
          (schedule) =>
              schedule.status == ScheduleStatus.planned &&
              targetDateStrings.contains(schedule.date),
        )
        .toList();
    final repository = ref.read(workoutSchedulePlanningRepositoryProvider);
    final notifier = ref.read(workoutScheduleProvider.notifier);

    for (final schedule in conflicts) {
      if (schedule.id.startsWith('server_')) {
        final serverId = int.tryParse(schedule.id.substring(7));
        if (serverId != null) await repository.cancelSchedule(serverId);
      }
      notifier.deleteSchedule(schedule.id);
    }
  }

  WorkoutPlanDay? get _activeDay {
    if (_selected == null || _selected!.days.isEmpty) return _selectedDay;
    final idx = _selectedDayIndex.clamp(0, _selected!.days.length - 1);
    return _selected!.days[idx];
  }

  bool get _isDayModified {
    if (_selected == null || _originalSelected == null) return false;
    final currentIdx = _selectedDayIndex.clamp(0, _selected!.days.length - 1);
    if (currentIdx >= _selected!.days.length ||
        currentIdx >= _originalSelected!.days.length) {
      return false;
    }
    final currentExercises = _selected!.days[currentIdx].exercises;
    final originalExercises = _originalSelected!.days[currentIdx].exercises;
    if (currentExercises.length != originalExercises.length) return true;
    for (var i = 0; i < currentExercises.length; i++) {
      if (currentExercises[i].name != originalExercises[i].name ||
          currentExercises[i].setsReps != originalExercises[i].setsReps) {
        return true;
      }
    }
    return false;
  }

  void _updateActiveDayExercises(List<PlannedExercisePreview> newExercises) {
    if (_selected == null || _selected!.days.isEmpty) return;
    final currentIdx = _selectedDayIndex.clamp(0, _selected!.days.length - 1);
    final currentDay = _selected!.days[currentIdx];
    final updatedDay = currentDay.copyWith(
      exercises: newExercises,
      exerciseCount: newExercises.length,
    );
    final newDays = List<WorkoutPlanDay>.from(_selected!.days);
    newDays[currentIdx] = updatedDay;
    setState(() {
      _selected = _selected!.copyWith(days: newDays);
      _selectedDay = updatedDay;
    });
  }

  void _restoreDefaultActiveDay() {
    if (_selected == null || _originalSelected == null) return;
    final currentIdx = _selectedDayIndex.clamp(0, _selected!.days.length - 1);
    if (currentIdx < _originalSelected!.days.length) {
      final origDay = _originalSelected!.days[currentIdx];
      _updateActiveDayExercises(origDay.exercises);
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã khôi phục bài tập gốc cho "${origDay.name}".'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _moveExercise(int fromIndex, int toIndex) {
    final active = _activeDay;
    if (active == null) return;
    final list = List<PlannedExercisePreview>.from(active.exercises);
    if (fromIndex < 0 ||
        fromIndex >= list.length ||
        toIndex < 0 ||
        toIndex >= list.length) {
      return;
    }
    final item = list.removeAt(fromIndex);
    list.insert(toIndex, item);
    HapticFeedback.selectionClick();
    _updateActiveDayExercises(list);
  }

  void _removeExercise(int index) {
    final active = _activeDay;
    if (active == null) return;
    final list = List<PlannedExercisePreview>.from(active.exercises);
    if (list.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Buổi tập cần ít nhất 1 bài tập.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final removed = list.removeAt(index);
    HapticFeedback.mediumImpact();
    _updateActiveDayExercises(list);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã xóa bài "${removed.name}".'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Hoàn tác',
          onPressed: () {
            list.insert(index, removed);
            _updateActiveDayExercises(list);
          },
        ),
      ),
    );
  }

  Future<void> _swapExercise(int index) async {
    final active = _activeDay;
    if (active == null || index < 0 || index >= active.exercises.length) return;
    final current = active.exercises[index];
    final replaced = await _showExercisePickerModal(
      context,
      current.primaryMuscle,
    );
    if (replaced != null) {
      final list = List<PlannedExercisePreview>.from(active.exercises);
      list[index] = PlannedExercisePreview(
        name: replaced.name,
        setsReps: current.setsReps,
        primaryMuscle: replaced.primaryMuscle,
      );
      HapticFeedback.selectionClick();
      _updateActiveDayExercises(list);
    }
  }

  Future<void> _editSetsReps(int index) async {
    final active = _activeDay;
    if (active == null || index < 0 || index >= active.exercises.length) return;
    final current = active.exercises[index];
    final updated = await _showSetsRepsPicker(context, current.setsReps);
    if (updated != null && updated != current.setsReps) {
      final list = List<PlannedExercisePreview>.from(active.exercises);
      list[index] = PlannedExercisePreview(
        name: current.name,
        setsReps: updated,
        primaryMuscle: current.primaryMuscle,
      );
      HapticFeedback.selectionClick();
      _updateActiveDayExercises(list);
    }
  }

  Future<void> _addExercise() async {
    final active = _activeDay;
    if (active == null) return;
    final picked = await _showExercisePickerModal(context, active.name);
    if (picked != null) {
      final list = List<PlannedExercisePreview>.from(active.exercises);
      list.add(
        PlannedExercisePreview(
          name: picked.name,
          setsReps: '3x10-12',
          primaryMuscle: picked.primaryMuscle,
        ),
      );
      HapticFeedback.selectionClick();
      _updateActiveDayExercises(list);
    }
  }

  Future<String?> _showSetsRepsPicker(
    BuildContext context,
    String currentSetsReps,
  ) async {
    int sets = 3;
    String reps = '10';

    final parts = currentSetsReps.toLowerCase().split('x');
    if (parts.isNotEmpty) {
      sets = int.tryParse(parts[0].trim()) ?? 3;
      if (parts.length > 1) {
        reps = parts[1].trim();
      }
    }

    final presets = ['3x8-12', '4x8', '3x10', '4x12', '3x15', '4x10'];

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (pickerContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            final currentStr = '${sets}x$reps';
            return SafeArea(
              child: Container(
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
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.tune_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Số hiệp & Số lần tập',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Điều chỉnh cường độ bài tập cho buổi này',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
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
                    const Text(
                      'Gợi ý phổ biến:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: presets.map((preset) {
                        final isSelected = currentStr == preset;
                        return ChoiceChip(
                          label: Text(
                            preset,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w900
                                  : FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.surfaceElevated,
                          onSelected: (_) {
                            final pParts = preset.split('x');
                            setModalState(() {
                              sets = int.tryParse(pParts[0]) ?? 3;
                              if (pParts.length > 1) reps = pParts[1];
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderDefault),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Số hiệp (Sets):',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: sets > 1
                                        ? () => setModalState(() => sets--)
                                        : null,
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
                                    color: AppColors.primary,
                                  ),
                                  Text(
                                    '$sets',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: sets < 10
                                        ? () => setModalState(() => sets++)
                                        : null,
                                    icon: const Icon(
                                      Icons.add_circle_outline,
                                    ),
                                    color: AppColors.primary,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Divider(
                            height: 16,
                            color: AppColors.borderDefault,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Số lần mỗi hiệp (Reps):',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              Row(
                                children: [
                                  [
                                    '8-10',
                                    '10-12',
                                    '12-15',
                                    '15-20',
                                  ].contains(reps)
                                      ? DropdownButton<String>(
                                          value: reps,
                                          dropdownColor:
                                              AppColors.surfaceElevated,
                                          underline: const SizedBox(),
                                          items: const [
                                            DropdownMenuItem(
                                              value: '8-10',
                                              child: Text('8 - 10 lần'),
                                            ),
                                            DropdownMenuItem(
                                              value: '10-12',
                                              child: Text('10 - 12 lần'),
                                            ),
                                            DropdownMenuItem(
                                              value: '12-15',
                                              child: Text('12 - 15 lần'),
                                            ),
                                            DropdownMenuItem(
                                              value: '15-20',
                                              child: Text('15 - 20 lần'),
                                            ),
                                          ],
                                          onChanged: (val) {
                                            if (val != null) {
                                              setModalState(() => reps = val);
                                            }
                                          },
                                        )
                                      : SizedBox(
                                          width: 80,
                                          child: TextFormField(
                                            initialValue: reps,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 15,
                                            ),
                                            decoration: InputDecoration(
                                              isDense: true,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 8,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            onChanged: (v) => reps = v.trim(),
                                          ),
                                        ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          Navigator.pop(modalContext, '${sets}x$reps');
                        },
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: Text(
                          'Xác nhận: ${sets}x$reps',
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

  Future<ExerciseDefinition?> _showExercisePickerModal(
    BuildContext context,
    String? preferredMuscle,
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

    if (preferredMuscle != null) {
      for (final m in muscleFilters) {
        if (m != 'Tất cả' &&
            preferredMuscle.toLowerCase().contains(m.toLowerCase())) {
          selectedMuscle = m;
          break;
        }
      }
    }

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
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.fitness_center_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Chọn bài tập (${filtered.length}/${allExercises.length})',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const Text(
                                    'Tìm kiếm và chọn bài tập phù hợp cho buổi tập',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
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
                        const SizedBox(height: 12),
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Tìm theo tên bài, nhóm cơ, dụng cụ...',
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              size: 20,
                              color: AppColors.iconSecondary,
                            ),
                            suffixIcon: searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 16),
                                    onPressed: () {
                                      setModalState(() => searchQuery = '');
                                    },
                                  )
                                : null,
                            isDense: true,
                            filled: true,
                            fillColor: AppColors.surfaceElevated,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.borderDefault,
                              ),
                            ),
                          ),
                          onChanged: (val) {
                            setModalState(() => searchQuery = val.trim());
                          },
                        ),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: muscleFilters.map((muscle) {
                              final isSelected = selectedMuscle == muscle;
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: ChoiceChip(
                                  label: Text(
                                    muscle,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: isSelected
                                          ? FontWeight.w900
                                          : FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                  selected: isSelected,
                                  selectedColor: AppColors.primary,
                                  backgroundColor: AppColors.surfaceElevated,
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
                        Flexible(
                          child: filtered.isEmpty
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(24),
                                    child: Text(
                                      'Không tìm thấy bài tập phù hợp.',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: filtered.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(height: 8),
                                  itemBuilder: (context, index) {
                                    final ex = filtered[index];
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceElevated,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: AppColors.borderDefault,
                                        ),
                                      ),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 4,
                                        ),
                                        title: Text(
                                          ex.nameVi.isNotEmpty
                                              ? ex.nameVi
                                              : ex.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13.5,
                                            color: Colors.white,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (ex.nameVi.isNotEmpty &&
                                                ex.name != ex.nameVi)
                                              Text(
                                                ex.name,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: AppColors.textTertiary,
                                                ),
                                              ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primarySoft,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      6,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    ex.primaryMuscle,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      color: AppColors.primary,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  ex.equipment.label,
                                                  style: const TextStyle(
                                                    fontSize: 10.5,
                                                    color:
                                                        AppColors.textSecondary,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        trailing: ElevatedButton(
                                          onPressed: () {
                                            HapticFeedback.selectionClick();
                                            Navigator.pop(modalContext, ex);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            foregroundColor: Colors.white,
                                            minimumSize: const Size(64, 34),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: const Text(
                                            'Chọn',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          HapticFeedback.selectionClick();
                                          Navigator.pop(modalContext, ex);
                                        },
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

  /// Returns the exercises from the source plan for a given item index.
  /// Used as fallback when the API response doesn't include exercise details.
  List<PlannedExercisePreview> _resolveSourceExercises(int index) {
    final source = _selected;
    if (source == null) return const [];
    if (_wholeWeek) {
      if (index < source.days.length) {
        return source.days[index].exercises;
      }
      return const [];
    }
    return _activeDay?.exercises ?? _selectedDay?.exercises ?? const [];
  }

  Future<void> _previewAndApply() async {
    final source = _selected;
    final sourceDay = _activeDay ?? _selectedDay;
    if (source == null || (!_wholeWeek && sourceDay == null)) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final repository = ref.read(workoutSchedulePlanningRepositoryProvider);
      final dates = _targetDates(_wholeWeek ? source.days.length : 1);
      final time =
          '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}';
      ScheduleProposalView proposal;
      try {
        proposal = await repository.createSourceProposal(
          source: source,
          targetDates: dates,
          time: time,
          sourceDayId: _wholeWeek ? null : sourceDay?.id,
        );
      } catch (_) {
        proposal = ScheduleProposalView(
          id: 0,
          sourceType: source.sourceType,
          scope: _wholeWeek ? 'WEEK' : 'ONE_DAY',
          expiresAt: DateTime.now().add(const Duration(minutes: 30)),
          items: dates.asMap().entries.map((entry) {
            final day = _wholeWeek
                ? (entry.key < source.days.length
                      ? source.days[entry.key]
                      : null)
                : sourceDay;
            return ScheduleProposalItemView(
              date: entry.value,
              time: time,
              title: day?.name ?? '${source.name} - Buổi ${entry.key + 1}',
              exerciseCount: day?.exercises.length ?? day?.exerciseCount ?? 4,
              plannedExercises: day?.exercises ?? const [],
            );
          }).toList(),
        );
      }

      if (!mounted) return;
      setState(() => _submitting = false);
      final result = await showScheduleProposalDialog(context, proposal);
      if (result == null || !result.confirmed || !mounted) return;
      setState(() => _submitting = true);

      final updatedDates = result.items.map((e) => e.date).toList();
      final updatedTime = result.items.isNotEmpty
          ? result.items.first.time
          : time;

      await _removeConflictingSchedules(updatedDates);

      try {
        final bool changed =
            updatedDates.length != dates.length ||
            updatedTime != time ||
            List.generate(
              dates.length,
              (i) => i < updatedDates.length && dates[i] != updatedDates[i],
            ).any((c) => c);

        final proposalToApply = proposal.id <= 0 || changed
            ? await repository.createSourceProposal(
                source: source,
                targetDates: updatedDates,
                time: updatedTime,
                sourceDayId: _wholeWeek ? null : sourceDay?.id,
              )
            : proposal;

        final applied = await repository.applyProposal(proposalToApply.id);
        if (!mounted) return;
        final appliedSchedules = applied.indexed.map((entry) {
          final item = entry.$2;
          final idx = entry.$1;
          final proposalItem = idx < proposalToApply.items.length
              ? proposalToApply.items[idx]
              : null;
          // Fallback chain: applied item → proposal item → source day exercises
          final plannedExercises = item.plannedExercises.isNotEmpty
              ? item.plannedExercises
              : (proposalItem?.plannedExercises.isNotEmpty ?? false)
                  ? proposalItem!.plannedExercises
                  : _resolveSourceExercises(idx);
          final targetMuscles = plannedExercises
              .map((exercise) => exercise.primaryMuscle)
              .whereType<String>()
              .where((muscle) => muscle.isNotEmpty)
              .toSet()
              .join(' • ');
          return WorkoutScheduleItem(
            id: 'server_${item.id}',
            date: _formatDate(item.date),
            time: item.time.length >= 5 ? item.time.substring(0, 5) : item.time,
            title: item.title,
            targetMuscles: targetMuscles.isEmpty
                ? 'Theo giáo án'
                : targetMuscles,
            durationMinutes: 45,
            plannedExercises: plannedExercises,
          );
        }).toList();
        ref
            .read(workoutScheduleProvider.notifier)
            .mergeAppliedSchedules(appliedSchedules);
        final now = DateTime.now();
        final todayStr = _formatDate(now);
        final todayItem = appliedSchedules
            .where((item) => item.date == todayStr)
            .firstOrNull;
        if (todayItem != null) {
          ref.read(workoutSessionProvider.notifier).loadFromSchedule(todayItem);
        }

        if (!mounted) return;
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã thêm ${applied.length} buổi tập vào lịch.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.success,
          ),
        );
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop(true);
        }
        return;
      } catch (_) {
        // Keep the app usable offline by falling through to a local schedule.
      }

      // Local merge fallback
      final scheduleNotifier = ref.read(workoutScheduleProvider.notifier);
      final now = DateTime.now();
      final todayStr = _formatDate(now);
      WorkoutScheduleItem? todayScheduleItem;

      for (var i = 0; i < result.items.length; i++) {
        final item = result.items[i];
        final proposalItem = i < proposal.items.length
            ? proposal.items[i]
            : null;
        // Fallback chain: proposal item → source day exercises
        final exercises = (proposalItem?.plannedExercises.isNotEmpty ?? false)
            ? proposalItem!.plannedExercises
            : _resolveSourceExercises(i);
        final targetMuscles = exercises
            .map((exercise) => exercise.primaryMuscle)
            .whereType<String>()
            .where((muscle) => muscle.isNotEmpty)
            .toSet()
            .join(' • ');
        final dateStr =
            '${item.date.year}-${item.date.month.toString().padLeft(2, '0')}-${item.date.day.toString().padLeft(2, '0')}';
        final sch = WorkoutScheduleItem(
          id: 'sch_${DateTime.now().millisecondsSinceEpoch}_$i',
          date: dateStr,
          time: item.time,
          title: item.title,
          targetMuscles: targetMuscles.isEmpty ? 'Theo giáo án' : targetMuscles,
          durationMinutes: 45,
          plannedExercises: exercises,
        );
        if (dateStr == todayStr) {
          todayScheduleItem = sch;
        }
        scheduleNotifier.addSchedule(
          title: item.title,
          targetMuscles: targetMuscles.isEmpty ? 'Theo giáo án' : targetMuscles,
          durationMinutes: 45,
          date: dateStr,
          time: item.time,
          plannedExercises: exercises,
        );
      }

      if (todayScheduleItem != null) {
        ref
            .read(workoutSessionProvider.notifier)
            .loadFromSchedule(todayScheduleItem);
      }

      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã thêm ${result.items.length} buổi tập vào lịch.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
        ),
      );
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final rawSources = _sourceTab == _SourceTab.personal ? _personal : _admin;
    final sources = _searchQuery.trim().isEmpty
        ? rawSources
        : rawSources
              .where(
                (s) =>
                    s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    (s.description?.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ) ??
                        false),
              )
              .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Lên lịch tập luyện',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        centerTitle: false,
        actions: [
          if (_selected != null)
            TextButton.icon(
              onPressed: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selected = null;
                  _selectedDay = null;
                });
              },
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Đổi giáo án'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          // 1. Beginner-friendly Smart Hero Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.surfaceElevated,
                  AppColors.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.borderDefault,
                width: 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.fitness_center_rounded,
                            size: 13,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'KẾ HOẠCH TẬP LUYỆN',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceStrong,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.borderDefault),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            size: 12,
                            color: AppColors.success,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Xem trước an toàn',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Bạn muốn tạo lịch bằng cách nào?',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Dù bạn là người mới hay đã có kinh nghiệm, hãy chọn phương án phù hợp nhất để đạt hiệu quả cao.',
                  style: TextStyle(
                    color: colors.onSurfaceVariant.withValues(alpha: 0.9),
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),

                // Quick Creation Method Cards
                Row(
                  children: [
                    Expanded(
                      child: _QuickSourceCard(
                        icon: Icons.auto_awesome_rounded,
                        badge: 'Gợi ý người mới ⭐',
                        title: 'AI tạo',
                        subtitle: 'Cá nhân hóa theo mục tiêu',
                        color: AppColors.violet,
                        gradientColors: const [
                          AppColors.surfaceElevated,
                          AppColors.surface,
                        ],
                        onTap: () {
                          HapticFeedback.selectionClick();
                          context.push(
                            '/workout/generate?date=${_formatDate(_date)}',
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _QuickSourceCard(
                        icon: Icons.edit_calendar_rounded,
                        badge: 'Tùy chỉnh',
                        title: 'Tự tạo',
                        subtitle: 'Tự chọn bài và số hiệp',
                        color: AppColors.primary,
                        gradientColors: const [
                          AppColors.surfaceElevated,
                          AppColors.surface,
                        ],
                        onTap: () {
                          HapticFeedback.selectionClick();
                          context.push(
                            '/workout/builder?date=${_formatDate(_date)}',
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 2. Ready-Made Program Section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Áp dụng giáo án có sẵn',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Chọn giáo án mẫu chuẩn hoặc giáo án cá nhân đã lưu',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Source Tab Switcher
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderDefault),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _TabButton(
                    icon: Icons.person_rounded,
                    label: 'Của tôi',
                    count: _personal.length,
                    selected: _sourceTab == _SourceTab.personal,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _sourceTab = _SourceTab.personal;
                        _selected = null;
                        _selectedDay = null;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _TabButton(
                    icon: Icons.verified_rounded,
                    label: 'VieGym',
                    count: _admin.length,
                    selected: _sourceTab == _SourceTab.admin,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _sourceTab = _SourceTab.admin;
                        _selected = null;
                        _selectedDay = null;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Search Field for Sources
          if (rawSources.isNotEmpty) ...[
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: _sourceTab == _SourceTab.personal
                    ? 'Tìm giáo án của tôi...'
                    : 'Tìm giáo án mẫu VieGym...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: AppColors.iconSecondary,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                isDense: true,
                filled: true,
                fillColor: AppColors.surfaceElevated,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.borderDefault),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.borderDefault),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.4,
                  ),
                ),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
            ),
            const SizedBox(height: 12),
          ],

          if (_loading)
            Container(
              padding: const EdgeInsets.all(36),
              alignment: Alignment.center,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(strokeWidth: 2.5),
                  SizedBox(height: 12),
                  Text(
                    'Đang tải danh sách giáo án...',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          else if (sources.isEmpty)
            _EmptySources(
              isPersonal: _sourceTab == _SourceTab.personal,
              onCreate: () async {
                await context.push(
                  '/workout/builder?date=${_formatDate(_date)}',
                );
                if (mounted) _loadSources();
              },
            )
          else ...[
            ...sources.map(
              (source) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SourceTile(
                  source: source,
                  selected: _selected?.id == source.id,
                  onTap: () => _selectSource(source),
                ),
              ),
            ),
            if (_sourceTab == _SourceTab.personal) ...[
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.6),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text(
                    'Tạo thêm giáo án mới',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  onPressed: () async {
                    HapticFeedback.selectionClick();
                    await context.push(
                      '/workout/builder?date=${_formatDate(_date)}',
                    );
                    if (mounted) _loadSources();
                  },
                ),
              ),
            ],
          ],

          // 3. Configuration Section when plan is selected
          if (_selected != null) ...[
            const SizedBox(height: 20),
            _buildConfiguration(colors),
          ],

          if (_error != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.errorSoft,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.errorBorder),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: _selected == null
          ? null
          : Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
                border: Border.all(color: AppColors.borderDefault),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Đã chọn: ${_selected!.name} • ${_wholeWeek ? "Cả tuần" : "1 ngày"}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _submitting ? null : _previewAndApply,
                        icon: _submitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.visibility_rounded, size: 20),
                        label: const Text(
                          'Xem trước lịch tập',
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
    );
  }

  Widget _buildConfiguration(ColorScheme colors) {
    final source = _selected!;
    final targetDates = _targetDates(_wholeWeek ? source.days.length : 1);
    final conflictingDates = _findConflictingDates(targetDates);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  source.sourceType == 'ADMIN_TEMPLATE'
                      ? Icons.verified_rounded
                      : Icons.menu_book_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CẤU HÌNH LỊCH TẬP',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        letterSpacing: 0.6,
                      ),
                    ),
                    Text(
                      source.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Scope Switch
          const Text(
            'Phạm vi áp dụng',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
          ),
          const SizedBox(height: 8),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: false,
                icon: Icon(Icons.today_rounded, size: 16),
                label: Text('Một ngày'),
              ),
              ButtonSegment(
                value: true,
                icon: Icon(Icons.date_range_rounded, size: 16),
                label: Text('Cả tuần'),
              ),
            ],
            selected: {_wholeWeek},
            onSelectionChanged: source.days.length < 2
                ? null
                : (selection) => setState(() {
                    HapticFeedback.selectionClick();
                    _wholeWeek = selection.first;
                    if (_wholeWeek) _date = _normalizedWeekStart(_date);
                  }),
          ),

          // Day Selection for Single Day vs Whole Week
          if (!_wholeWeek) ...[
            const SizedBox(height: 14),
            DropdownButtonFormField<WorkoutPlanDay>(
              value: _activeDay,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Chọn buổi tập',
                isDense: true,
                filled: true,
                fillColor: AppColors.surfaceStrong,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.borderDefault),
                ),
              ),
              items: source.days
                  .map(
                    (day) => DropdownMenuItem(
                      value: day,
                      child: Text(
                        '${day.name} • ${day.exercises.length} bài',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (day) {
                if (day != null) {
                  setState(() {
                    _selectedDay = day;
                    _selectedDayIndex = source.days.indexOf(day);
                  });
                }
              },
            ),
          ] else ...[
            const SizedBox(height: 14),
            // Interactive visual weekly distribution
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceStrong,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderDefault),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Phân bổ ${source.days.length} buổi trong tuần:',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successSoft,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Tự động cách ngày',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: source.days.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final day = entry.value;
                      final offset = source.days.length <= 1
                          ? 0
                          : (idx * 6 / (source.days.length - 1)).round();
                      final dayName = _dayOfWeekName(offset + 1);

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.borderDefault,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                dayName,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${day.name} (${day.exercises.length} bài)',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],

          // 4. Detailed and Customizable Exercise List for the active day
          _buildExerciseListSection(source, colors),

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _PickerTile(
                  icon: Icons.calendar_today_rounded,
                  label: _wholeWeek ? 'Tuần bắt đầu' : 'Ngày tập',
                  value: '${_date.day}/${_date.month}/${_date.year}',
                  onTap: _pickDate,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PickerTile(
                  icon: Icons.schedule_rounded,
                  label: 'Giờ tập',
                  value: _time.format(context),
                  onTap: _pickTime,
                ),
              ),
            ],
          ),

          // Quick Time Chips
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text(
                  'Giờ nhanh:',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                _QuickTimeChip(
                  label: '06:00 (Sáng)',
                  selected: _time.hour == 6 && _time.minute == 0,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _time = const TimeOfDay(hour: 6, minute: 0));
                  },
                ),
                const SizedBox(width: 6),
                _QuickTimeChip(
                  label: '17:30 (Chiều)',
                  selected: _time.hour == 17 && _time.minute == 30,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(
                      () => _time = const TimeOfDay(hour: 17, minute: 30),
                    );
                  },
                ),
                const SizedBox(width: 6),
                _QuickTimeChip(
                  label: '19:00 (Tối)',
                  selected: _time.hour == 19 && _time.minute == 0,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(
                      () => _time = const TimeOfDay(hour: 19, minute: 0),
                    );
                  },
                ),
              ],
            ),
          ),

          // Beginner Coach Advice Box
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceStrong,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.borderDefault,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.tips_and_updates_rounded,
                  color: AppColors.amber,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _wholeWeek
                        ? '💡 Mẹo cho người mới: VieGym tự động sắp xếp ngày tập xen kẽ ngày nghỉ để cơ bắp có 48h phục hồi và phát triển tối ưu.'
                        : '💡 Mẹo: Bạn có thể chọn từng buổi để tập bù hoặc thử nghiệm giáo án mới trước khi áp dụng toàn bộ.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: colors.onSurfaceVariant.withValues(alpha: 0.9),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Real-time Conflict Detection Warning Banner
          if (conflictingDates.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warningSoft,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.warningBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.amber,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bạn đã có lịch tập vào ngày ${conflictingDates.join(", ")}. Khi xác nhận áp dụng, giáo án mới sẽ thay thế lịch đang có ở những ngày này.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.amber,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExerciseListSection(
    WorkoutPlanSource source,
    ColorScheme colors,
  ) {
    final activeDay = _activeDay;
    final exercises = activeDay?.exercises ?? const [];

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.fitness_center_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'BÀI TẬP TRONG BUỔI',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${exercises.length} bài',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      activeDay?.name ?? 'Chi tiết bài tập',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isDayModified)
                TextButton.icon(
                  onPressed: _restoreDefaultActiveDay,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: AppColors.amber,
                  ),
                  icon: const Icon(Icons.replay_rounded, size: 14),
                  label: const Text(
                    'Khôi phục',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          if (source.days.length > 1) ...[
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: source.days.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final day = entry.value;
                  final isSelected = _selectedDayIndex == idx;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(
                        '${day.name} (${day.exercises.length} bài)',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight:
                              isSelected ? FontWeight.w900 : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surfaceElevated,
                      onSelected: (_) {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _selectedDayIndex = idx;
                          _selectedDay = day;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (exercises.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 12,
              ),
              alignment: Alignment.center,
              child: const Text(
                'Buổi tập chưa có bài tập nào. Hãy bấm "Thêm bài tập" bên dưới.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.5,
                ),
              ),
            )
          else
            ...exercises.asMap().entries.map((entry) {
              final index = entry.key;
              final ex = entry.value;

              ExerciseDefinition? def;
              final nameLower = ex.name.toLowerCase().trim();
              for (final e in exerciseCatalog) {
                if (e.name.toLowerCase().trim() == nameLower ||
                    e.nameVi.toLowerCase().trim() == nameLower) {
                  def = e;
                  break;
                }
              }

              final titleVi = def?.nameVi ?? ex.name;
              final primaryMuscle =
                  def?.primaryMuscle ?? ex.primaryMuscle ?? 'Toàn thân';

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.borderDefault,
                    width: 0.8,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '#${index + 1}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                titleVi,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13.5,
                                  color: Colors.white,
                                ),
                              ),
                              if (titleVi != ex.name)
                                Text(
                                  ex.name,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textTertiary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primarySoft,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      primaryMuscle,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  if (def?.equipment != null)
                                    Text(
                                      def!.equipment.label,
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  InkWell(
                                    onTap: () => _editSetsReps(index),
                                    borderRadius: BorderRadius.circular(6),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.cyan.withValues(
                                          alpha: 0.12,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: AppColors.cyan.withValues(
                                            alpha: 0.3,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            ex.setsReps,
                                            style: const TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.cyan,
                                            ),
                                          ),
                                          const SizedBox(width: 3),
                                          const Icon(
                                            Icons.edit_rounded,
                                            size: 11,
                                            color: AppColors.cyan,
                                          ),
                                        ],
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
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _swapExercise(index),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 0,
                            ),
                            minimumSize: const Size(0, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            foregroundColor: AppColors.primary,
                            side: BorderSide(
                              color: AppColors.primary.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(
                            Icons.swap_horiz_rounded,
                            size: 14,
                          ),
                          label: const Text(
                            'Đổi bài',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: index > 0
                              ? () => _moveExercise(index, index - 1)
                              : null,
                          icon: const Icon(
                            Icons.arrow_upward_rounded,
                            size: 16,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
                          ),
                          tooltip: 'Di chuyển lên',
                        ),
                        IconButton(
                          onPressed: index < exercises.length - 1
                              ? () => _moveExercise(index, index + 1)
                              : null,
                          icon: const Icon(
                            Icons.arrow_downward_rounded,
                            size: 16,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
                          ),
                          tooltip: 'Di chuyển xuống',
                        ),
                        IconButton(
                          onPressed: () => _removeExercise(index),
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 16,
                            color: AppColors.error,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
                          ),
                          tooltip: 'Xóa bài tập',
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton.icon(
              onPressed: _addExercise,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.6),
                  width: 1.1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text(
                'Thêm bài tập vào buổi này',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 14,
                  color: AppColors.amber,
                ),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Người mới: Bạn có thể bấm "Đổi bài" để chọn máy tập hoặc tạ đơn nhẹ nhàng hơn nếu chưa quen với bài tạ đòn.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _dayOfWeekName(int weekday) {
    switch (weekday) {
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
        return 'T$weekday';
    }
  }

  static String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.icon,
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                  color: selected ? Colors.white : AppColors.textSecondary,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.white.withValues(alpha: 0.25)
                        : AppColors.surfaceStrong,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      color: selected ? Colors.white : AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickTimeChip extends StatelessWidget {
  const _QuickTimeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primarySoft
              : AppColors.surfaceStrong,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderDefault,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _QuickSourceCard extends StatelessWidget {
  const _QuickSourceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.gradientColors,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final List<Color> gradientColors;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  if (badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge!,
                        style: TextStyle(
                          color: color,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    required this.source,
    required this.selected,
    required this.onTap,
  });

  final WorkoutPlanSource source;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isAdmin = source.sourceType == 'ADMIN_TEMPLATE';
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primarySoft
                : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.borderDefault,
              width: selected ? 1.4 : 1.0,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.2)
                          : (isAdmin
                              ? AppColors.primarySoft
                              : AppColors.surfaceStrong),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isAdmin
                          ? Icons.verified_rounded
                          : Icons.menu_book_rounded,
                      color: isAdmin ? AppColors.primary : AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                source.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14.5,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            if (isAdmin)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySoft,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'VieGym Pro',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          source.description?.isNotEmpty == true
                              ? source.description!
                              : 'Giáo án khoa học dành cho người tập',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? AppColors.primary : Colors.transparent,
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.borderStrong,
                        width: 1.5,
                      ),
                    ),
                    child: selected
                        ? const Icon(
                            Icons.check,
                            size: 14,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Feature badges row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceStrong,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_month_rounded,
                          size: 11,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${source.totalDays} buổi / tuần',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceStrong,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 11,
                          color: AppColors.amber,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '~45-60p',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceStrong,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySources extends StatelessWidget {
  const _EmptySources({required this.isPersonal, required this.onCreate});

  final bool isPersonal;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_month_outlined,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isPersonal
                ? 'Bạn chưa có giáo án cá nhân.'
                : 'Chưa có giáo án VieGym được xuất bản.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isPersonal
                ? 'Hãy tự thiết kế giáo án đầu tiên của bạn để lên lịch luyện tập linh hoạt.'
                : 'Các giáo án mẫu chuẩn khoa học đang được cập nhật.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          if (isPersonal) ...[
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Tạo giáo án'),
            ),
          ],
        ],
      ),
    );
  }
}
