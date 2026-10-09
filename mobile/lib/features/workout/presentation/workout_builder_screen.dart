import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../application/workout_schedule_controller.dart';
import '../application/workout_session_controller.dart';
import '../data/exercise_catalog.dart';
import '../data/workout_schedule_planning_repository.dart';
import '../domain/workout_models.dart';
import 'exercise_library_screen.dart';
import 'widgets/exercise_thumbnail.dart';
import 'widgets/schedule_proposal_dialog.dart';

class WorkoutBuilderScreen extends ConsumerStatefulWidget {
  const WorkoutBuilderScreen({
    super.key,
    this.initialProgramName,
    this.programType,
    this.initialDate,
  });

  final String? initialProgramName;
  final String? programType;
  final String? initialDate;

  @override
  ConsumerState<WorkoutBuilderScreen> createState() =>
      _WorkoutBuilderScreenState();
}

class _WorkoutBuilderScreenState extends ConsumerState<WorkoutBuilderScreen> {
  static const _validTypes = ['PPL', 'UPPER_LOWER', 'FULL_BODY', 'CUSTOM'];

  late TextEditingController _nameController;
  late String _selectedType;
  final List<_DayBuilderModel> _days = [];
  int _activeDayIndex = 0;
  bool _showTemplatesSection = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialProgramName ?? 'Giáo án cá nhân cho người mới',
    );
    final pType = widget.programType?.toUpperCase();
    _selectedType = _validTypes.contains(pType) ? pType! : 'FULL_BODY';
    _initDefaultDays();
  }

  void _initDefaultDays() {
    final bench = _findEx('Barbell Bench Press', 'Bench');
    final lat = _findEx('Lat Pulldown', 'Pulldown');
    final curl = _findEx('Bicep Barbell Curl', 'Curl');

    _days.add(
      _DayBuilderModel(
        dayNumber: 1,
        name: 'Buổi 1: Thân trên & Ngực (Upper)',
        exercises: [
          _ExerciseBuilderModel(
            exercise: bench,
            targetSets: 3,
            targetRepsMin: 8,
            targetRepsMax: 12,
            restSeconds: 90,
          ),
          _ExerciseBuilderModel(
            exercise: lat,
            targetSets: 3,
            targetRepsMin: 10,
            targetRepsMax: 12,
            restSeconds: 90,
          ),
          _ExerciseBuilderModel(
            exercise: curl,
            targetSets: 3,
            targetRepsMin: 10,
            targetRepsMax: 12,
            restSeconds: 60,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  ExerciseDefinition _findEx(String key, String fallbackName) {
    return exerciseCatalog.firstWhere(
      (e) =>
          e.name.toLowerCase().contains(key.toLowerCase()) ||
          e.nameVi.toLowerCase().contains(key.toLowerCase()),
      orElse: () => exerciseCatalog.firstWhere(
        (e) => e.name.toLowerCase().contains(fallbackName.toLowerCase()),
        orElse: () => exerciseCatalog.first,
      ),
    );
  }

  // ── RESET & START NEW PROGRAM ─────────────────────────────────────────────
  void _startNewProgram({bool skipConfirm = false}) {
    if (skipConfirm ||
        (_days.isEmpty || _days.every((d) => d.exercises.isEmpty))) {
      _resetToNewProgram();
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(
              Icons.restart_alt_rounded,
              color: AppColors.primary,
              size: 22,
            ),
            SizedBox(width: 8),
            Text(
              'Tạo giáo án mới?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ],
        ),
        content: const Text(
          'Dữ liệu hiện tại sẽ được làm mới để bạn bắt đầu thiết kế giáo án mới từ đầu.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13.5,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Hủy',
              style: TextStyle(color: AppColors.textTertiary),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _resetToNewProgram();
            },
            child: const Text(
              'Tạo mới',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _resetToNewProgram() {
    setState(() {
      _nameController.text = 'Giáo án mới';
      _selectedType = 'CUSTOM';
      _days.clear();
      _days.add(
        _DayBuilderModel(
          dayNumber: 1,
          name: 'Buổi 1: Toàn thân (Full Body)',
          exercises: [],
        ),
      );
      _activeDayIndex = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Đã làm mới! Hãy thêm bài tập hoặc áp dụng mẫu gợi ý bên trên.',
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceElevated,
      ),
    );
  }

  // ── PRESET TEMPLATES FOR BEGINNERS ─────────────────────────────────────────
  void _applyPreset(String presetKey) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: AppColors.violet, size: 22),
            SizedBox(width: 8),
            Text(
              'Áp dụng mẫu giáo án?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ],
        ),
        content: const Text(
          'Các buổi tập và bài tập hiện tại sẽ được cập nhật theo mẫu chuẩn khoa học được tối ưu sẵn cho người mới bắt đầu.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13.5,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Hủy',
              style: TextStyle(color: AppColors.textTertiary),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _loadPresetData(presetKey);
            },
            child: const Text(
              'Áp dụng ngay',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _loadPresetData(String presetKey) {
    setState(() {
      _days.clear();
      _activeDayIndex = 0;

      if (presetKey == 'FULL_BODY') {
        _selectedType = 'FULL_BODY';
        _nameController.text = 'Giáo án Toàn thân Cho Người Mới (3 Buổi)';

        // Day 1
        _days.add(
          _DayBuilderModel(
            dayNumber: 1,
            name: 'Buổi 1: Toàn thân A (Full Body A)',
            exercises: [
              _ExerciseBuilderModel(
                exercise: _findEx('Squat', 'Squat'),
                targetSets: 3,
                targetRepsMin: 8,
                targetRepsMax: 10,
                restSeconds: 120,
              ),
              _ExerciseBuilderModel(
                exercise: _findEx('Barbell Bench Press', 'Bench'),
                targetSets: 3,
                targetRepsMin: 8,
                targetRepsMax: 12,
                restSeconds: 90,
              ),
              _ExerciseBuilderModel(
                exercise: _findEx('Lat Pulldown', 'Pulldown'),
                targetSets: 3,
                targetRepsMin: 10,
                targetRepsMax: 12,
                restSeconds: 90,
              ),
              _ExerciseBuilderModel(
                exercise: _findEx('Lateral Raise', 'Vai'),
                targetSets: 3,
                targetRepsMin: 12,
                targetRepsMax: 15,
                restSeconds: 60,
              ),
            ],
          ),
        );

        // Day 2
        _days.add(
          _DayBuilderModel(
            dayNumber: 2,
            name: 'Buổi 2: Toàn thân B (Full Body B)',
            exercises: [
              _ExerciseBuilderModel(
                exercise: _findEx('Romanian Deadlift', 'Deadlift'),
                targetSets: 3,
                targetRepsMin: 8,
                targetRepsMax: 10,
                restSeconds: 90,
              ),
              _ExerciseBuilderModel(
                exercise: _findEx('Overhead Press', 'Press'),
                targetSets: 3,
                targetRepsMin: 8,
                targetRepsMax: 10,
                restSeconds: 90,
              ),
              _ExerciseBuilderModel(
                exercise: _findEx('Seated Cable Row', 'Row'),
                targetSets: 3,
                targetRepsMin: 10,
                targetRepsMax: 12,
                restSeconds: 90,
              ),
              _ExerciseBuilderModel(
                exercise: _findEx('Bicep Barbell Curl', 'Curl'),
                targetSets: 3,
                targetRepsMin: 10,
                targetRepsMax: 12,
                restSeconds: 60,
              ),
            ],
          ),
        );

        // Day 3
        _days.add(
          _DayBuilderModel(
            dayNumber: 3,
            name: 'Buổi 3: Toàn thân C (Full Body C)',
            exercises: [
              _ExerciseBuilderModel(
                exercise: _findEx('Incline Dumbbell Press', 'Incline'),
                targetSets: 3,
                targetRepsMin: 8,
                targetRepsMax: 12,
                restSeconds: 90,
              ),
              _ExerciseBuilderModel(
                exercise: _findEx('Bulgarian Split Squat', 'Squat'),
                targetSets: 3,
                targetRepsMin: 10,
                targetRepsMax: 12,
                restSeconds: 90,
              ),
              _ExerciseBuilderModel(
                exercise: _findEx('Face Pull', 'Face'),
                targetSets: 3,
                targetRepsMin: 12,
                targetRepsMax: 15,
                restSeconds: 60,
              ),
              _ExerciseBuilderModel(
                exercise: _findEx('Hanging Leg Raise', 'Bụng'),
                targetSets: 3,
                targetRepsMin: 12,
                targetRepsMax: 15,
                restSeconds: 60,
              ),
            ],
          ),
        );
      } else if (presetKey == 'UPPER_LOWER') {
        _selectedType = 'UPPER_LOWER';
        _nameController.text = 'Giáo án Thân Trên / Thân Dưới (4 Buổi)';

        // Day 1
        _days.add(
          _DayBuilderModel(
            dayNumber: 1,
            name: 'Buổi 1: Thân trên A (Upper A)',
            exercises: [
              _ExerciseBuilderModel(
                exercise: _findEx('Barbell Bench Press', 'Bench'),
                targetSets: 4,
                targetRepsMin: 8,
                targetRepsMax: 10,
                restSeconds: 90,
              ),
              _ExerciseBuilderModel(
                exercise: _findEx('Lat Pulldown', 'Pulldown'),
                targetSets: 4,
                targetRepsMin: 8,
                targetRepsMax: 12,
                restSeconds: 90,
              ),
              _ExerciseBuilderModel(
                exercise: _findEx('Lateral Raise', 'Vai'),
                targetSets: 3,
                targetRepsMin: 12,
                targetRepsMax: 15,
                restSeconds: 60,
              ),
              _ExerciseBuilderModel(
                exercise: _findEx('Tricep Rope Pushdown', 'Tricep'),
                targetSets: 3,
                targetRepsMin: 12,
                targetRepsMax: 15,
                restSeconds: 60,
              ),
            ],
          ),
        );

        // Day 2
        _days.add(
          _DayBuilderModel(
            dayNumber: 2,
            name: 'Buổi 2: Thân dưới A (Lower A)',
            exercises: [
              _ExerciseBuilderModel(
                exercise: _findEx('Squat', 'Squat'),
                targetSets: 4,
                targetRepsMin: 6,
                targetRepsMax: 10,
                restSeconds: 120,
              ),
              _ExerciseBuilderModel(
                exercise: _findEx('Romanian Deadlift', 'Deadlift'),
                targetSets: 3,
                targetRepsMin: 8,
                targetRepsMax: 12,
                restSeconds: 90,
              ),
              _ExerciseBuilderModel(
                exercise: _findEx('Hanging Leg Raise', 'Bụng'),
                targetSets: 3,
                targetRepsMin: 12,
                targetRepsMax: 15,
                restSeconds: 60,
              ),
            ],
          ),
        );

        // Day 3
        _days.add(
          _DayBuilderModel(
            dayNumber: 3,
            name: 'Buổi 3: Thân trên B (Upper B)',
            exercises: [
              _ExerciseBuilderModel(
                exercise: _findEx('Incline Dumbbell Press', 'Incline'),
                targetSets: 4,
                targetRepsMin: 8,
                targetRepsMax: 12,
                restSeconds: 90,
              ),
              _ExerciseBuilderModel(
                exercise: _findEx('Seated Cable Row', 'Row'),
                targetSets: 4,
                targetRepsMin: 8,
                targetRepsMax: 12,
                restSeconds: 90,
              ),
              _ExerciseBuilderModel(
                exercise: _findEx('Overhead Press', 'Press'),
                targetSets: 3,
                targetRepsMin: 8,
                targetRepsMax: 10,
                restSeconds: 90,
              ),
              _ExerciseBuilderModel(
                exercise: _findEx('Bicep Barbell Curl', 'Curl'),
                targetSets: 3,
                targetRepsMin: 10,
                targetRepsMax: 12,
                restSeconds: 60,
              ),
            ],
          ),
        );

        // Day 4
        _days.add(
          _DayBuilderModel(
            dayNumber: 4,
            name: 'Buổi 4: Thân dưới B (Lower B)',
            exercises: [
              _ExerciseBuilderModel(
                exercise: _findEx('Bulgarian Split Squat', 'Squat'),
                targetSets: 3,
                targetRepsMin: 10,
                targetRepsMax: 12,
                restSeconds: 90,
              ),
              _ExerciseBuilderModel(
                exercise: _findEx('Squat', 'Leg'),
                targetSets: 3,
                targetRepsMin: 10,
                targetRepsMax: 12,
                restSeconds: 90,
              ),
              _ExerciseBuilderModel(
                exercise: _findEx('Plank', 'Core'),
                targetSets: 3,
                targetRepsMin: 30,
                targetRepsMax: 45,
                restSeconds: 60,
              ),
            ],
          ),
        );
      } else {
        // PPL
        _selectedType = 'PPL';
        _nameController.text = 'Giáo án Push - Pull - Legs (3 Buổi)';

        // Day 1: Push
        _days.add(
          _DayBuilderModel(
            dayNumber: 1,
            name: 'Buổi 1: Đẩy (Ngực, Vai, Tay sau)',
            exercises: [
              _ExerciseBuilderModel(
                exercise: _findEx('Barbell Bench Press', 'Bench'),
                targetSets: 4,
                targetRepsMin: 8,
                targetRepsMax: 10,
                restSeconds: 90,
              ),
              _ExerciseBuilderModel(
                exercise: _findEx('Incline Dumbbell Press', 'Incline'),
                targetSets: 3,
                targetRepsMin: 10,
                targetRepsMax: 12,
                restSeconds: 90,
              ),
              _ExerciseBuilderModel(
                exercise: _findEx('Lateral Raise', 'Vai'),
                targetSets: 3,
                targetRepsMin: 12,
                targetRepsMax: 15,
                restSeconds: 60,
              ),
              _ExerciseBuilderModel(
                exercise: _findEx('Tricep Rope Pushdown', 'Tricep'),
                targetSets: 3,
                targetRepsMin: 12,
                targetRepsMax: 15,
                restSeconds: 60,
              ),
            ],
          ),
        );

        // Day 2: Pull
        _days.add(
          _DayBuilderModel(
            dayNumber: 2,
            name: 'Buổi 2: Kéo (Lưng, Tay trước)',
            exercises: [
              _ExerciseBuilderModel(
                exercise: _findEx('Lat Pulldown', 'Pulldown'),
                targetSets: 4,
                targetRepsMin: 8,
                targetRepsMax: 12,
                restSeconds: 90,
              ),
              _ExerciseBuilderModel(
                exercise: _findEx('Seated Cable Row', 'Row'),
                targetSets: 3,
                targetRepsMin: 10,
                targetRepsMax: 12,
                restSeconds: 90,
              ),
              _ExerciseBuilderModel(
                exercise: _findEx('Face Pull', 'Face'),
                targetSets: 3,
                targetRepsMin: 12,
                targetRepsMax: 15,
                restSeconds: 60,
              ),
              _ExerciseBuilderModel(
                exercise: _findEx('Bicep Barbell Curl', 'Curl'),
                targetSets: 3,
                targetRepsMin: 10,
                targetRepsMax: 12,
                restSeconds: 60,
              ),
            ],
          ),
        );

        // Day 3: Legs
        _days.add(
          _DayBuilderModel(
            dayNumber: 3,
            name: 'Buổi 3: Chân & Bụng (Legs & Core)',
            exercises: [
              _ExerciseBuilderModel(
                exercise: _findEx('Squat', 'Squat'),
                targetSets: 4,
                targetRepsMin: 6,
                targetRepsMax: 10,
                restSeconds: 120,
              ),
              _ExerciseBuilderModel(
                exercise: _findEx('Romanian Deadlift', 'Deadlift'),
                targetSets: 3,
                targetRepsMin: 8,
                targetRepsMax: 12,
                restSeconds: 90,
              ),
              _ExerciseBuilderModel(
                exercise: _findEx('Bulgarian Split Squat', 'Leg'),
                targetSets: 3,
                targetRepsMin: 10,
                targetRepsMax: 12,
                restSeconds: 90,
              ),
              _ExerciseBuilderModel(
                exercise: _findEx('Hanging Leg Raise', 'Bụng'),
                targetSets: 3,
                targetRepsMin: 12,
                targetRepsMax: 15,
                restSeconds: 60,
              ),
            ],
          ),
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã áp dụng mẫu giáo án "${_nameController.text}"!'),
        backgroundColor: AppColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _addDay() {
    setState(() {
      final newDayNumber = _days.length + 1;
      _days.add(
        _DayBuilderModel(
          dayNumber: newDayNumber,
          name: 'Buổi $newDayNumber: Tập trung nhóm cơ',
          exercises: [],
        ),
      );
      _activeDayIndex = _days.length - 1;
    });
  }

  void _duplicateDay(int index) {
    if (index < 0 || index >= _days.length) return;
    final source = _days[index];
    setState(() {
      final newDayNumber = _days.length + 1;
      _days.add(
        _DayBuilderModel(
          dayNumber: newDayNumber,
          name: '${source.name} (Bản sao)',
          exercises: source.exercises
              .map(
                (e) => _ExerciseBuilderModel(
                  exercise: e.exercise,
                  targetSets: e.targetSets,
                  targetRepsMin: e.targetRepsMin,
                  targetRepsMax: e.targetRepsMax,
                  restSeconds: e.restSeconds,
                ),
              )
              .toList(),
        ),
      );
      _activeDayIndex = _days.length - 1;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã nhân bản "${source.name}" thành công!'),
        backgroundColor: AppColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _removeDay(int index) {
    if (_days.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Giáo án phải có ít nhất một buổi tập.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Xóa buổi tập này?'),
        content: Text(
          'Bạn có chắc muốn xóa "${_days[index].name}" cùng toàn bộ bài tập trong buổi này?',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Hủy',
              style: TextStyle(color: AppColors.textTertiary),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _days.removeAt(index);
                for (int i = 0; i < _days.length; i++) {
                  _days[i].dayNumber = i + 1;
                }
                if (_activeDayIndex >= _days.length) {
                  _activeDayIndex = _days.length - 1;
                }
              });
            },
            child: const Text('Xóa ngay'),
          ),
        ],
      ),
    );
  }

  void _moveExercise(int dayIndex, int exIndex, int direction) {
    if (dayIndex < 0 || dayIndex >= _days.length) return;
    final day = _days[dayIndex];
    final targetIndex = exIndex + direction;
    if (targetIndex < 0 || targetIndex >= day.exercises.length) return;

    setState(() {
      final item = day.exercises.removeAt(exIndex);
      day.exercises.insert(targetIndex, item);
    });
  }

  Future<void> _addExerciseToCurrentDay() async {
    if (_days.isEmpty || _activeDayIndex >= _days.length) return;
    final currentDayNumber = _days[_activeDayIndex].dayNumber;
    final dynamic result;
    if (GoRouter.maybeOf(context) != null) {
      result = await context.push<dynamic>(
        '/workout/library?select=true&multi=true&title=${Uri.encodeComponent('Chọn bài tập cho Buổi $currentDayNumber')}',
      );
    } else {
      result = await Navigator.of(context).push<dynamic>(
        MaterialPageRoute(
          builder: (context) => ExerciseLibraryScreen(
            isPicker: true,
            isMultiSelect: true,
            title: 'Chọn bài tập cho Buổi $currentDayNumber',
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

    setState(() {
      if (_activeDayIndex < _days.length) {
        final currentDay = _days[_activeDayIndex];
        for (final ex in selectedList) {
          currentDay.exercises.add(
            _ExerciseBuilderModel(
              exercise: ex,
              targetSets: 3,
              targetRepsMin: 8,
              targetRepsMax: 12,
              restSeconds: 90,
            ),
          );
        }
      }
    });
  }

  // --- SMART AI RECOMMENDATION & MUSCLE BALANCE ENGINE ---
  List<ExerciseDefinition> _getSmartSuggestionsForActiveDay() {
    if (_days.isEmpty ||
        _activeDayIndex >= _days.length ||
        _activeDayIndex < 0) {
      return [];
    }
    final currentDay = _days[_activeDayIndex];
    final existingIds = currentDay.exercises.map((e) => e.exercise.id).toSet();

    final presentMuscles = currentDay.exercises
        .map((e) => e.exercise.primaryMuscle)
        .toSet();

    if (presentMuscles.isEmpty) {
      return exerciseCatalog
          .where((e) => !existingIds.contains(e.id))
          .take(3)
          .toList();
    }

    final suggestions = <ExerciseDefinition>[];
    for (final ex in exerciseCatalog) {
      if (existingIds.contains(ex.id)) continue;

      if (presentMuscles.contains(ex.primaryMuscle)) {
        suggestions.add(ex);
      } else if (presentMuscles.contains('Ngực') &&
          (ex.primaryMuscle == 'Vai' || ex.primaryMuscle == 'Tay sau')) {
        suggestions.add(ex);
      } else if (presentMuscles.contains('Lưng') &&
          (ex.primaryMuscle == 'Tay trước' || ex.primaryMuscle == 'Vai sau')) {
        suggestions.add(ex);
      } else if (presentMuscles.contains('Đùi trước') &&
          (ex.primaryMuscle == 'Đùi sau' ||
              ex.primaryMuscle == 'Mông' ||
              ex.primaryMuscle == 'Bụng')) {
        suggestions.add(ex);
      }
    }

    if (suggestions.length < 3) {
      for (final ex in exerciseCatalog) {
        if (!existingIds.contains(ex.id) && !suggestions.contains(ex)) {
          suggestions.add(ex);
          if (suggestions.length >= 3) break;
        }
      }
    }

    return suggestions.take(3).toList();
  }

  void _addQuickSuggestion(ExerciseDefinition ex) {
    if (_days.isEmpty ||
        _activeDayIndex >= _days.length ||
        _activeDayIndex < 0) {
      return;
    }
    setState(() {
      _days[_activeDayIndex].exercises.add(
        _ExerciseBuilderModel(
          exercise: ex,
          targetSets: 3,
          targetRepsMin: 8,
          targetRepsMax: 12,
          restSeconds: 90,
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã thêm "${ex.nameVi.isNotEmpty ? ex.nameVi : ex.name}" vào ${_days[_activeDayIndex].name}',
        ),
        backgroundColor: AppColors.surfaceElevated,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- SAVE & SCHEDULE MODAL ---
  void _saveProgram() {
    if (_days.isEmpty || _days.every((d) => d.exercises.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vui lòng thêm ít nhất 1 bài tập vào giáo án trước khi lưu.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final title = _nameController.text.trim().isEmpty
        ? 'Giáo án cá nhân'
        : _nameController.text.trim();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                  color: AppColors.borderStrong,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.bookmark_add_rounded,
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
                        'Lưu giáo án "$title"',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_days.length} buổi tập • ${_calculateTotalExercises()} bài tập',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Option 1: Apply to schedule (Primary Action)
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.calendar_month_rounded, size: 20),
              label: const Text(
                'Xem trước & Lên lịch tuần đã chọn',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                _applyToSchedule();
              },
            ),
            const SizedBox(height: 10),

            // Option 2: Save as personal template
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                side: const BorderSide(color: AppColors.borderStrong),
                foregroundColor: AppColors.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.bookmark_outline_rounded, size: 20),
              label: const Text(
                'Chỉ lưu vào Giáo án cá nhân',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                _saveAsPersonalProgram();
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _saveAsPersonalProgram() async {
    final title = _nameController.text.trim().isEmpty
        ? 'Giáo án cá nhân'
        : _nameController.text.trim();

    final drafts = _days.asMap().entries.map((entry) {
      final day = entry.value;
      return ScheduleDraftDay(
        date: DateTime.now().add(Duration(days: entry.key)),
        time: '18:00',
        title: day.name.isNotEmpty
            ? day.name
            : '$title — Buổi ${entry.key + 1}',
        exercises: day.exercises
            .map(
              (item) => ScheduleDraftExercise(
                exercise: item.exercise,
                targetSets: item.targetSets,
                targetRepsMin: item.targetRepsMin,
                targetRepsMax: item.targetRepsMax,
                restSeconds: item.restSeconds,
              ),
            )
            .toList(),
      );
    }).toList();

    try {
      final repository = ref.read(workoutSchedulePlanningRepositoryProvider);
      await repository.createPersonalProgram(
        name: title,
        programType: _selectedType,
        description: 'Giáo án tự tạo ${_days.length} buổi',
        days: drafts,
      );
    } catch (_) {
      // Offline / local fallback
    }

    if (!mounted) return;
    _finalizeSave(appliedToSchedule: false);
  }

  Future<void> _applyToSchedule() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final requestedStart =
        DateTime.tryParse(widget.initialDate ?? '') ??
        DateTime.tryParse(ref.read(workoutScheduleProvider).selectedDate) ??
        today;
    final scheduleStart = DateUtils.dateOnly(requestedStart).isBefore(today)
        ? today
        : DateUtils.dateOnly(requestedStart);
    final drafts = _days.asMap().entries.map((entry) {
      final day = entry.value;
      return ScheduleDraftDay(
        date: scheduleStart.add(Duration(days: entry.key)),
        time: '18:00',
        title: '${_nameController.text.trim()} — ${day.name}',
        exercises: day.exercises
            .map(
              (item) => ScheduleDraftExercise(
                exercise: item.exercise,
                targetSets: item.targetSets,
                targetRepsMin: item.targetRepsMin,
                targetRepsMax: item.targetRepsMax,
                restSeconds: item.restSeconds,
              ),
            )
            .toList(),
      );
    }).toList();

    final repository = ref.read(workoutSchedulePlanningRepositoryProvider);
    ScheduleProposalView proposal;
    try {
      proposal = await repository.createDirectProposal(
        sourceType: 'MANUAL',
        days: drafts,
      );
    } catch (_) {
      proposal = ScheduleProposalView(
        id: 0,
        sourceType: 'MANUAL',
        scope: drafts.length == 1 ? 'ONE_DAY' : 'WEEK',
        expiresAt: DateTime.now().add(const Duration(minutes: 30)),
        items: drafts
            .map(
              (d) => ScheduleProposalItemView(
                date: d.date,
                time: d.time,
                title: d.title,
                exerciseCount: d.exercises.length,
              ),
            )
            .toList(),
      );
    }

    if (!mounted) return;
    final result = await showScheduleProposalDialog(context, proposal);
    if (result == null || !result.confirmed || !mounted) return;

    var effectiveDrafts = drafts;
    if (result.items.isNotEmpty) {
      effectiveDrafts = List.generate(drafts.length, (index) {
        final original = drafts[index];
        if (index < result.items.length) {
          final updatedItem = result.items[index];
          return ScheduleDraftDay(
            date: updatedItem.date,
            time: updatedItem.time,
            title: original.title,
            exercises: original.exercises,
          );
        }
        return original;
      });
    }

    if (proposal.id > 0) {
      try {
        final bool changed = List.generate(
          drafts.length,
          (i) =>
              i < effectiveDrafts.length &&
              (drafts[i].date != effectiveDrafts[i].date ||
                  drafts[i].time != effectiveDrafts[i].time),
        ).any((c) => c);

        final proposalToApply = changed
            ? await repository.createDirectProposal(
                sourceType: 'MANUAL',
                days: effectiveDrafts,
              )
            : proposal;

        final applied = await repository.applyProposal(proposalToApply.id);
        if (!mounted) return;
        ref
            .read(workoutScheduleProvider.notifier)
            .mergeAppliedSchedules(
              applied.indexed.map((entry) {
                final item = entry.$2;
                final draft = entry.$1 < effectiveDrafts.length
                    ? effectiveDrafts[entry.$1]
                    : null;
                final plannedExercises = draft != null && draft.exercises.isNotEmpty
                    ? draft.exercises
                          .map(
                            (e) => PlannedExercisePreview(
                              name: e.exercise.name,
                              setsReps:
                                  '${e.targetSets}x${e.targetRepsMin}-${e.targetRepsMax}',
                              primaryMuscle: e.exercise.primaryMuscle,
                            ),
                          )
                          .toList()
                    : item.plannedExercises;
                final targetMuscles = draft != null && draft.exercises.isNotEmpty
                    ? draft.exercises
                          .map((e) => e.exercise.primaryMuscle)
                          .toSet()
                          .join(' • ')
                    : (plannedExercises.isNotEmpty
                          ? plannedExercises
                                .map((e) => e.primaryMuscle)
                                .whereType<String>()
                                .where((m) => m.isNotEmpty)
                                .toSet()
                                .join(' • ')
                          : 'Theo giáo án cá nhân');

                return WorkoutScheduleItem(
                  id: 'server_${item.id}',
                  date:
                      '${item.date.year}-${item.date.month.toString().padLeft(2, '0')}-${item.date.day.toString().padLeft(2, '0')}',
                  time: item.time.substring(0, 5),
                  title: item.title,
                  targetMuscles: targetMuscles,
                  durationMinutes: 45,
                  plannedExercises: plannedExercises,
                );
              }).toList(),
            );
        if (applied.isNotEmpty) {
          ref
              .read(workoutScheduleProvider.notifier)
              .selectDate(_formatDate(applied.first.date));
        }

        final now = DateTime.now();
        final todayStr = _formatDate(now);
        final todayDraft = effectiveDrafts
            .where((d) => _formatDate(d.date) == todayStr)
            .firstOrNull;
        if (todayDraft != null && todayDraft.exercises.isNotEmpty) {
          final todaySchedule = applied.indexed
              .where((entry) =>
                  entry.$1 < effectiveDrafts.length &&
                  _formatDate(effectiveDrafts[entry.$1].date) == todayStr)
              .firstOrNull;
          ref
              .read(workoutSessionProvider.notifier)
              .setSession(
                title: todayDraft.title,
                exercises: todayDraft.exercises
                    .map(
                      (e) => SessionExercise(
                        exerciseId: e.exercise.id,
                        name: e.exercise.nameVi.isNotEmpty
                            ? e.exercise.nameVi
                            : e.exercise.name,
                        primaryMuscle: e.exercise.primaryMuscle,
                        equipment: e.exercise.equipment,
                        targetSets: e.targetSets,
                        targetReps: e.targetRepsMin,
                        weightKg:
                            e.exercise.equipment == EquipmentType.bodyweight
                            ? 0
                            : 20,
                        thumbnailUrl: e.exercise.thumbnailUrl,
                      ),
                    )
                    .toList(),
                id: todaySchedule != null ? 'server_${todaySchedule.$2.id}' : null,
              );
        }

        _finalizeSave(appliedToSchedule: true);
        return;
      } catch (_) {
        // Fall through to local save below
      }
    }

    if (!mounted) return;
    final scheduleNotifier = ref.read(workoutScheduleProvider.notifier);
    for (final draft in effectiveDrafts) {
      final dateStr =
          '${draft.date.year}-${draft.date.month.toString().padLeft(2, '0')}-${draft.date.day.toString().padLeft(2, '0')}';
      scheduleNotifier.addSchedule(
        title: draft.title,
        targetMuscles: draft.exercises
            .map((e) => e.exercise.primaryMuscle)
            .toSet()
            .join(' • '),
        durationMinutes: 45,
        date: dateStr,
        time: draft.time,
        plannedExercises: draft.exercises
            .map(
              (e) => PlannedExercisePreview(
                name: e.exercise.name,
                setsReps:
                    '${e.targetSets}x${e.targetRepsMin}-${e.targetRepsMax}',
                primaryMuscle: e.exercise.primaryMuscle,
              ),
            )
            .toList(),
      );
    }

    final now = DateTime.now();
    final todayStr = _formatDate(now);
    final todayDraft = effectiveDrafts
        .where((d) => _formatDate(d.date) == todayStr)
        .firstOrNull;
    if (todayDraft != null && todayDraft.exercises.isNotEmpty) {
      ref
          .read(workoutSessionProvider.notifier)
          .setSession(
            title: todayDraft.title,
            exercises: todayDraft.exercises
                .map(
                  (e) => SessionExercise(
                    exerciseId: e.exercise.id,
                    name: e.exercise.nameVi.isNotEmpty
                        ? e.exercise.nameVi
                        : e.exercise.name,
                    primaryMuscle: e.exercise.primaryMuscle,
                    equipment: e.exercise.equipment,
                    targetSets: e.targetSets,
                    targetReps: e.targetRepsMin,
                    weightKg: e.exercise.equipment == EquipmentType.bodyweight
                        ? 0
                        : 20,
                    thumbnailUrl: e.exercise.thumbnailUrl,
                  ),
                )
                .toList(),
          );
    }

    _finalizeSave(appliedToSchedule: true);
  }

  void _finalizeSave({required bool appliedToSchedule}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          appliedToSchedule
              ? 'Đã lưu giáo án và lên lịch tập thành công!'
              : 'Đã lưu giáo án "${_nameController.text.trim()}" thành công!',
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).pop(true);
  }

  String _calculateTotalExercises() {
    return '${_days.fold<int>(0, (sum, d) => sum + d.exercises.length)}';
  }

  int _calculateEstimatedMinutes() {
    final activeExercises = _days.isNotEmpty && _activeDayIndex < _days.length
        ? _days[_activeDayIndex].exercises.length
        : 0;
    if (activeExercises == 0) return 0;
    return (activeExercises * 8) + 10;
  }

  static String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  Set<String> _getMusclesForDay(_DayBuilderModel day) {
    return day.exercises.map((e) => e.exercise.primaryMuscle).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final currentDay =
        (_days.isNotEmpty &&
            _activeDayIndex >= 0 &&
            _activeDayIndex < _days.length)
        ? _days[_activeDayIndex]
        : null;
    final smartSuggestions = _getSmartSuggestionsForActiveDay();
    final dayMuscles = currentDay != null ? _getMusclesForDay(currentDay) : <String>{};

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDeep,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Workout Builder',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            onPressed: () => _startNewProgram(),
            icon: const Icon(Icons.restart_alt_rounded, size: 18),
            label: const Text(
              'Tạo mới',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                minimumSize: const Size(64, 36),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _saveProgram,
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text(
                'Lưu',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.backgroundDeep,
          border: const Border(
            top: BorderSide(color: AppColors.borderDefault, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_days.length} Buổi • ${_calculateTotalExercises()} Bài',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      currentDay != null
                          ? '${currentDay.exercises.length} bài (${_calculateEstimatedMinutes()}p) buổi này'
                          : 'Chưa có bài tập',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
                onPressed: _saveProgram,
                icon: const Icon(Icons.check_circle_outline_rounded, size: 19),
                label: const Text(
                  'Lưu & Lên lịch',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 14.0,
          bottom: 24.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. PRESET TEMPLATES FOR BEGINNERS BANNER ──────────────────────
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.surfaceElevated,
                    AppColors.violet.withValues(alpha: 0.16),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.violet.withValues(alpha: 0.35),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppColors.violet.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: AppColors.violet,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Mẫu giáo án chuẩn cho người mới',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13.5,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  _BadgeTag(
                                    text: 'Gợi ý',
                                    color: AppColors.green,
                                  ),
                                ],
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Chọn 1 mẫu để tự động chia buổi và bài tập tối ưu',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            _showTemplatesSection
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: AppColors.textTertiary,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _showTemplatesSection = !_showTemplatesSection;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  if (_showTemplatesSection) ...[
                    const Divider(height: 1, color: AppColors.borderDefault),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _PresetTemplateCard(
                              icon: Icons.accessibility_new_rounded,
                              title: '3 Buổi Toàn thân',
                              badge: 'Khuyên dùng #1',
                              badgeColor: AppColors.green,
                              daysCount: '3 buổi / tuần',
                              targetMuscle: 'Toàn thân • Tăng cơ toàn diện',
                              accentColor: AppColors.green,
                              isSelected: _selectedType == 'FULL_BODY',
                              onTap: () => _applyPreset('FULL_BODY'),
                            ),
                            const SizedBox(width: 10),
                            _PresetTemplateCard(
                              icon: Icons.fitness_center_rounded,
                              title: '4 Buổi Thân trên / dưới',
                              badge: 'Upper - Lower',
                              badgeColor: AppColors.blue,
                              daysCount: '4 buổi / tuần',
                              targetMuscle: 'Cân bằng thân trên & dưới',
                              accentColor: AppColors.blue,
                              isSelected: _selectedType == 'UPPER_LOWER',
                              onTap: () => _applyPreset('UPPER_LOWER'),
                            ),
                            const SizedBox(width: 10),
                            _PresetTemplateCard(
                              icon: Icons.flash_on_rounded,
                              title: '3 Buổi PPL',
                              badge: 'PPL Tăng cơ',
                              badgeColor: AppColors.orange,
                              daysCount: '3 buổi / tuần',
                              targetMuscle: 'Đẩy • Kéo • Chân & Bụng',
                              accentColor: AppColors.orange,
                              isSelected: _selectedType == 'PPL',
                              onTap: () => _applyPreset('PPL'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── 2. PROGRAM BASIC INFO & SUMMARY ──────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderDefault),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Tên giáo án',
                      labelStyle: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      hintText: 'VD: Giáo án tăng cơ 3 buổi...',
                      filled: true,
                      fillColor: AppColors.surfaceStrong,
                      prefixIcon: const Icon(
                        Icons.edit_note_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.borderDefault,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.borderDefault,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    key: ValueKey('program_type_$_selectedType'),
                    initialValue: _validTypes.contains(_selectedType)
                        ? _selectedType
                        : 'CUSTOM',
                    isExpanded: true,
                    dropdownColor: AppColors.surfaceElevated,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Phân loại phương pháp chia lịch',
                      labelStyle: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      filled: true,
                      fillColor: AppColors.surfaceStrong,
                      prefixIcon: const Icon(
                        Icons.splitscreen_rounded,
                        color: AppColors.blue,
                        size: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.borderDefault,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.borderDefault,
                        ),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'FULL_BODY',
                        child: Text(
                          'Full Body (Toàn thân)',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'UPPER_LOWER',
                        child: Text(
                          'Upper / Lower (Thân trên / dưới)',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'PPL',
                        child: Text(
                          'Push / Pull / Legs (PPL)',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'CUSTOM',
                        child: Text(
                          'Tùy chỉnh cá nhân (Custom)',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedType = val);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  // Summary Badges
                  Row(
                    children: [
                      Expanded(
                        child: _StatBadge(
                          icon: Icons.calendar_today_rounded,
                          label: 'Số buổi',
                          value: '${_days.length} ngày',
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatBadge(
                          icon: Icons.fitness_center_rounded,
                          label: 'Tổng bài tập',
                          value: '${_calculateTotalExercises()} bài',
                          color: AppColors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatBadge(
                          icon: Icons.timer_outlined,
                          label: 'Thời lượng/buổi',
                          value: '~45-50p',
                          color: AppColors.cyan,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ── 3. DAYS SELECTOR TABS ─────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'CÁC BUỔI TẬP (${_days.length})',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: _addDay,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                  ),
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 17),
                  label: const Text(
                    'Thêm buổi',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Horizontal Day Pills using ChoiceChip for clean test & visual compatibility
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _days.length,
                separatorBuilder: (c, i) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final day = _days[index];
                  final isSelected = index == _activeDayIndex;
                  return ChoiceChip(
                    label: Text(
                      'Buổi ${day.dayNumber}',
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.borderDefault,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _activeDayIndex = index);
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // ── 4. ACTIVE DAY EDITOR & EXERCISES ──────────────────────────────
            if (currentDay != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.borderDefault),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Day Title Input & Action Tools
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            key: ValueKey('day_name_${currentDay.dayNumber}'),
                            initialValue: currentDay.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14.5,
                              color: AppColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Tên buổi tập #${currentDay.dayNumber}',
                              labelStyle: const TextStyle(
                                fontSize: 12.5,
                                color: AppColors.textSecondary,
                              ),
                              filled: true,
                              fillColor: AppColors.surfaceStrong,
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.borderDefault,
                                ),
                              ),
                            ),
                            onChanged: (val) {
                              currentDay.name = val;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.surfaceStrong,
                            foregroundColor: AppColors.textSecondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(
                            Icons.copy_rounded,
                            size: 18,
                          ),
                          tooltip: 'Nhân bản buổi này',
                          onPressed: () => _duplicateDay(_activeDayIndex),
                        ),
                        const SizedBox(width: 4),
                        IconButton.filledTonal(
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.errorSoft,
                            foregroundColor: AppColors.error,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 19,
                          ),
                          tooltip: 'Xóa buổi này',
                          onPressed: () => _removeDay(_activeDayIndex),
                        ),
                      ],
                    ),

                    // Muscle pills for active day
                    if (dayMuscles.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Icon(
                            Icons.tune_rounded,
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                          const Text(
                            'Nhóm cơ tác động:',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          for (final m in dayMuscles)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.35),
                                ),
                              ),
                              child: Text(
                                m,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.primaryLight,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Exercises section header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Danh sách bài tập (${currentDay.exercises.length})',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: _addExerciseToCurrentDay,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                            minimumSize: const Size(60, 34),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.add_rounded, size: 17),
                          label: const Text(
                            'Thêm bài tập',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Empty state or exercise list
                    if (currentDay.exercises.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceStrong,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderDefault),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: AppColors.surfaceElevated,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.fitness_center_rounded,
                                size: 30,
                                color: AppColors.textTertiary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Chưa có bài tập nào trong buổi này',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Nhấn "Thêm bài tập" hoặc bấm vào các bài gợi ý AI bên dưới để thêm nhanh.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: currentDay.exercises.length,
                        itemBuilder: (context, exIndex) {
                          final exModel = currentDay.exercises[exIndex];
                          final isFirst = exIndex == 0;
                          final isLast = exIndex == currentDay.exercises.length - 1;

                          return Container(
                            key: ValueKey('ex_${exModel.exercise.id}_$exIndex'),
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceStrong,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.borderDefault,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Exercise Header: Order Badge + Thumbnail + Name + Move/Delete
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceElevated,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: AppColors.borderStrong,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${exIndex + 1}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ExerciseThumbnail(
                                      exerciseId: exModel.exercise.id,
                                      name: exModel.exercise.name,
                                      imageUrl: exModel.exercise.thumbnailUrl,
                                      size: 44,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            exModel.exercise.nameVi.isNotEmpty
                                                ? exModel.exercise.nameVi
                                                : exModel.exercise.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 13.5,
                                              color: AppColors.textPrimary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 1.5,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primarySoft,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  exModel.exercise.primaryMuscle,
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    color: AppColors.primaryLight,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  exModel.exercise.name,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: AppColors.textTertiary,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Move Up / Down Buttons
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      icon: const Icon(
                                        Icons.arrow_upward_rounded,
                                        size: 17,
                                        color: AppColors.textTertiary,
                                      ),
                                      onPressed: isFirst
                                          ? null
                                          : () => _moveExercise(
                                                _activeDayIndex,
                                                exIndex,
                                                -1,
                                              ),
                                    ),
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      icon: const Icon(
                                        Icons.arrow_downward_rounded,
                                        size: 17,
                                        color: AppColors.textTertiary,
                                      ),
                                      onPressed: isLast
                                          ? null
                                          : () => _moveExercise(
                                                _activeDayIndex,
                                                exIndex,
                                                1,
                                              ),
                                    ),
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      icon: const Icon(
                                        Icons.close_rounded,
                                        size: 18,
                                        color: AppColors.error,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          currentDay.exercises.removeAt(
                                            exIndex,
                                          );
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // Quick Beginner Goal Pills
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      _GoalPresetChip(
                                        label: '🎯 Tăng cơ (3x10-12)',
                                        accentColor: AppColors.blue,
                                        selected:
                                            exModel.targetSets == 3 &&
                                            exModel.targetRepsMin == 10 &&
                                            exModel.targetRepsMax == 12,
                                        onTap: () {
                                          setState(() {
                                            exModel.targetSets = 3;
                                            exModel.targetRepsMin = 10;
                                            exModel.targetRepsMax = 12;
                                            exModel.restSeconds = 90;
                                          });
                                        },
                                      ),
                                      const SizedBox(width: 6),
                                      _GoalPresetChip(
                                        label: '⚡ Sức mạnh (4x6-8)',
                                        accentColor: AppColors.amber,
                                        selected:
                                            exModel.targetSets == 4 &&
                                            exModel.targetRepsMin == 6 &&
                                            exModel.targetRepsMax == 8,
                                        onTap: () {
                                          setState(() {
                                            exModel.targetSets = 4;
                                            exModel.targetRepsMin = 6;
                                            exModel.targetRepsMax = 8;
                                            exModel.restSeconds = 120;
                                          });
                                        },
                                      ),
                                      const SizedBox(width: 6),
                                      _GoalPresetChip(
                                        label: '🔥 Săn chắc (3x15)',
                                        accentColor: AppColors.orange,
                                        selected:
                                            exModel.targetSets == 3 &&
                                            exModel.targetRepsMin == 12 &&
                                            exModel.targetRepsMax == 15,
                                        onTap: () {
                                          setState(() {
                                            exModel.targetSets = 3;
                                            exModel.targetRepsMin = 12;
                                            exModel.targetRepsMax = 15;
                                            exModel.restSeconds = 60;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // Stepper Boxes for Sets, Reps Min, Reps Max
                                Row(
                                  children: [
                                    Expanded(
                                      child: _ConfigBox(
                                        label: 'Số Sets',
                                        value: '${exModel.targetSets}',
                                        onDecrement: () {
                                          if (exModel.targetSets > 1) {
                                            setState(
                                              () => exModel.targetSets--,
                                            );
                                          }
                                        },
                                        onIncrement: () {
                                          setState(() => exModel.targetSets++);
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _ConfigBox(
                                        label: 'Reps Min',
                                        value: '${exModel.targetRepsMin}',
                                        onDecrement: () {
                                          if (exModel.targetRepsMin > 1) {
                                            setState(
                                              () => exModel.targetRepsMin--,
                                            );
                                          }
                                        },
                                        onIncrement: () {
                                          setState(() {
                                            exModel.targetRepsMin++;
                                            if (exModel.targetRepsMin >
                                                exModel.targetRepsMax) {
                                              exModel.targetRepsMax =
                                                  exModel.targetRepsMin;
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _ConfigBox(
                                        label: 'Reps Max',
                                        value: '${exModel.targetRepsMax}',
                                        onDecrement: () {
                                          if (exModel.targetRepsMax >
                                              exModel.targetRepsMin) {
                                            setState(
                                              () => exModel.targetRepsMax--,
                                            );
                                          }
                                        },
                                        onIncrement: () {
                                          setState(
                                            () => exModel.targetRepsMax++,
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // Rest Timer Quick Selector
                                Container(
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
                                    children: [
                                      const Icon(
                                        Icons.timer_outlined,
                                        size: 15,
                                        color: AppColors.cyan,
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'Nghỉ giữa hiệp:',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Spacer(),
                                      for (final seconds in [45, 60, 90, 120])
                                        Padding(
                                          padding: const EdgeInsets.only(left: 6),
                                          child: InkWell(
                                            onTap: () {
                                              setState(
                                                () =>
                                                    exModel.restSeconds = seconds,
                                              );
                                            },
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 150,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 3.5,
                                              ),
                                              decoration: BoxDecoration(
                                                color: exModel.restSeconds ==
                                                        seconds
                                                    ? AppColors.cyan
                                                    : AppColors.surfaceStrong,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: exModel.restSeconds ==
                                                          seconds
                                                      ? AppColors.cyan
                                                      : AppColors.borderDefault,
                                                ),
                                              ),
                                              child: Text(
                                                '${seconds}s',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight:
                                                      exModel.restSeconds ==
                                                              seconds
                                                          ? FontWeight.w800
                                                          : FontWeight.w500,
                                                  color:
                                                      exModel.restSeconds ==
                                                              seconds
                                                          ? Colors.black
                                                          : AppColors
                                                              .textSecondary,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                    // ── 5. SMART AI SUGGESTION FOR CURRENT DAY ─────────────────
                    if (smartSuggestions.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.violet.withValues(alpha: 0.12),
                              AppColors.surfaceStrong,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.violet.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome_rounded,
                                  color: AppColors.violet,
                                  size: 17,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Gợi ý thêm bài bổ trợ (AI Coach)',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13,
                                          color: AppColors.violet,
                                        ),
                                      ),
                                      Text(
                                        'Tối ưu độ cân bằng nhóm cơ cho buổi tập này',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textTertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            for (final sug in smartSuggestions)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: InkWell(
                                  onTap: () => _addQuickSuggestion(sug),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: AppColors.borderDefault,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        ExerciseThumbnail(
                                          exerciseId: sug.id,
                                          name: sug.name,
                                          imageUrl: sug.thumbnailUrl,
                                          size: 32,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                sug.nameVi.isNotEmpty
                                                    ? sug.nameVi
                                                    : sug.name,
                                                style: const TextStyle(
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.textPrimary,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                '${sug.primaryMuscle} • ${sug.equipment.label}',
                                                style: const TextStyle(
                                                  fontSize: 10.5,
                                                  color: AppColors.textTertiary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3.5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.violetSoft,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border: Border.all(
                                              color: AppColors.violet.withValues(
                                                alpha: 0.4,
                                              ),
                                            ),
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(
                                                Icons.add,
                                                size: 13,
                                                color: AppColors.violet,
                                              ),
                                              SizedBox(width: 2),
                                              Text(
                                                'Thêm',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w800,
                                                  color: AppColors.violet,
                                                ),
                                              ),
                                            ],
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
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PresetTemplateCard extends StatelessWidget {
  const _PresetTemplateCard({
    required this.icon,
    required this.title,
    required this.badge,
    required this.badgeColor,
    required this.daysCount,
    required this.targetMuscle,
    required this.accentColor,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String badge;
  final Color badgeColor;
  final String daysCount;
  final String targetMuscle;
  final Color accentColor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.15)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? accentColor : AppColors.borderDefault,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: accentColor),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _BadgeTag(text: badge, color: badgeColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              daysCount,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              targetMuscle,
              style: const TextStyle(
                fontSize: 10.5,
                color: AppColors.textTertiary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeTag extends StatelessWidget {
  const _BadgeTag({
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _GoalPresetChip extends StatelessWidget {
  const _GoalPresetChip({
    required this.label,
    required this.accentColor,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color accentColor;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: selected
              ? accentColor.withValues(alpha: 0.22)
              : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? accentColor : AppColors.borderDefault,
            width: selected ? 1.2 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
            color: selected ? accentColor : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12.5,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _ConfigBox extends StatelessWidget {
  const _ConfigBox({
    required this.label,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });

  final String label;
  final String value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: onDecrement,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceStrong,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.remove,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13.5,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                ),
              ),
              InkWell(
                onTap: onIncrement,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayBuilderModel {
  _DayBuilderModel({
    required this.dayNumber,
    required this.name,
    required this.exercises,
  });

  int dayNumber;
  String name;
  final List<_ExerciseBuilderModel> exercises;
}

class _ExerciseBuilderModel {
  _ExerciseBuilderModel({
    required this.exercise,
    required this.targetSets,
    required this.targetRepsMin,
    required this.targetRepsMax,
    required this.restSeconds,
  });

  final ExerciseDefinition exercise;
  int targetSets;
  int targetRepsMin;
  int targetRepsMax;
  int restSeconds;
}
