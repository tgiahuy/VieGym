import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/exercise_tag_chip.dart';
import '../application/workout_schedule_controller.dart';
import '../application/workout_session_controller.dart';
import '../data/exercise_catalog.dart';
import '../domain/workout_models.dart';

enum _PlanApplyMode { append, replace }

class AiWorkoutGenerateScreen extends ConsumerStatefulWidget {
  const AiWorkoutGenerateScreen({super.key});

  @override
  ConsumerState<AiWorkoutGenerateScreen> createState() =>
      _AiWorkoutGenerateScreenState();
}

class _AiWorkoutGenerateScreenState
    extends ConsumerState<AiWorkoutGenerateScreen> {
  final Set<String> _selectedMuscles = {'Ngực', 'Vai'};
  final Set<EquipmentType> _selectedEquipment = {
    EquipmentType.barbell,
    EquipmentType.dumbbell,
    EquipmentType.bench,
    EquipmentType.cable,
    EquipmentType.machine,
    EquipmentType.bodyweight,
  };
  double _durationMinutes = 45;
  String _goal = 'Tăng cơ nạc (Hypertrophy)';
  bool _isGenerating = false;
  bool _generated = false;
  List<ExerciseDefinition> _generatedExercises = [];

  final _allMuscles = [
    'Ngực',
    'Lưng xô',
    'Vai',
    'Tay trước',
    'Tay sau',
    'Đùi trước',
    'Đùi sau & Mông',
    'Cơ bụng (Core)',
  ];

  final _goals = [
    'Tăng cơ nạc (Hypertrophy)',
    'Tăng sức mạnh (Strength)',
    'Giảm mỡ & Săn chắc (Fat Burn)',
    'Phục hồi chức năng (Mobility)',
  ];

  final _equipmentOptions = [
    (EquipmentType.barbell, 'Tạ đòn (Barbell)', Icons.fitness_center_rounded),
    (
      EquipmentType.dumbbell,
      'Tạ đơn (Dumbbell)',
      Icons.fitness_center_outlined,
    ),
    (EquipmentType.cable, 'Máy kéo cáp (Cable)', Icons.cable_rounded),
    (
      EquipmentType.machine,
      'Máy khối chuyên dụng',
      Icons.precision_manufacturing_rounded,
    ),
    (EquipmentType.bench, 'Ghế tập (Bench)', Icons.chair_alt_rounded),
    (
      EquipmentType.bodyweight,
      'Trọng lượng cơ thể (Calisthenics)',
      Icons.accessibility_new_rounded,
    ),
  ];

  void _applyEquipmentPreset(String preset) {
    HapticFeedback.selectionClick();
    setState(() {
      if (preset == 'full_gym') {
        _selectedEquipment.addAll(EquipmentType.values);
      } else if (preset == 'home_dumbbell') {
        _selectedEquipment.clear();
        _selectedEquipment.addAll([
          EquipmentType.dumbbell,
          EquipmentType.bodyweight,
          EquipmentType.bench,
        ]);
      } else if (preset == 'bodyweight') {
        _selectedEquipment.clear();
        _selectedEquipment.add(EquipmentType.bodyweight);
      }
    });
  }

  String _getSetsRepsRecommendation() {
    if (_goal.contains('Strength')) {
      return '4 hiệp × 5-6 reps';
    } else if (_goal.contains('Fat Burn')) {
      return '3 hiệp × 12-15 reps';
    } else if (_goal.contains('Mobility')) {
      return '3 hiệp × 15-20 reps';
    }
    return '4 hiệp × 8-12 reps';
  }

  Future<void> _generatePlan() async {
    HapticFeedback.mediumImpact();
    setState(() => _isGenerating = true);
    await Future<void>.delayed(const Duration(milliseconds: 800));

    // Dynamic exercise selection based on muscles & available equipment
    final targetMusclesLower = _selectedMuscles
        .map((m) => m.toLowerCase())
        .toList();

    final matchingExercises = exerciseCatalog.where((ex) {
      final matchesEquipment = _selectedEquipment.contains(ex.equipment);
      final primaryLower = ex.primaryMuscle.toLowerCase();
      final secondaryLower = ex.secondaryMuscles
          .map((m) => m.toLowerCase())
          .toList();

      final matchesMuscle = targetMusclesLower.any((m) {
        if (m.contains('ngực') && primaryLower.contains('ngực')) {
          return true;
        }
        if (m.contains('vai') &&
            (primaryLower.contains('vai') ||
                secondaryLower.any((s) => s.contains('vai')))) {
          return true;
        }
        if (m.contains('lưng') &&
            (primaryLower.contains('lưng') || primaryLower.contains('xô'))) {
          return true;
        }
        if (m.contains('tay trước') && primaryLower.contains('tay trước')) {
          return true;
        }
        if (m.contains('tay sau') && primaryLower.contains('tay sau')) {
          return true;
        }
        if (m.contains('đùi trước') && primaryLower.contains('đùi trước')) {
          return true;
        }
        if (m.contains('đùi sau') &&
            (primaryLower.contains('đùi sau') ||
                primaryLower.contains('mông'))) {
          return true;
        }
        if (m.contains('bụng') && primaryLower.contains('bụng')) {
          return true;
        }
        return primaryLower.contains(m);
      });

      return matchesEquipment && matchesMuscle;
    }).toList();

    // Determine target count based on duration
    int targetCount = 4;
    if (_durationMinutes <= 30) {
      targetCount = 3;
    } else if (_durationMinutes >= 60) {
      targetCount = 5;
    }

    final selectedList = <ExerciseDefinition>[];
    if (matchingExercises.isNotEmpty) {
      final pool = [...matchingExercises];
      pool.shuffle();
      selectedList.addAll(pool.take(targetCount));
    }

    // Fallback if not enough matching exercises
    if (selectedList.length < targetCount) {
      final fallbackPool = exerciseCatalog
          .where((ex) => _selectedEquipment.contains(ex.equipment))
          .toList();
      fallbackPool.shuffle();
      for (final ex in fallbackPool) {
        if (!selectedList.any((s) => s.id == ex.id)) {
          selectedList.add(ex);
          if (selectedList.length >= targetCount) break;
        }
      }
    }

    if (mounted) {
      setState(() {
        _isGenerating = false;
        _generated = true;
        _generatedExercises = selectedList.isNotEmpty
            ? selectedList
            : exerciseCatalog.take(4).toList();
      });
    }
  }

  Future<_PlanApplyMode?> _chooseApplyMode(WorkoutSessionState session) {
    return showDialog<_PlanApplyMode>(
      context: context,
      builder: (dialogContext) {
        final colors = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          title: const Text(
            'Hôm nay đã có buổi tập',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(
            session.isCompleted
                ? 'Bạn đã hoàn thành toàn bộ hiệp nhưng chưa kết thúc buổi tập. Hãy thêm các bài AI vào buổi hiện tại để giữ nguyên kết quả vừa tập.'
                : 'Bạn muốn bổ sung các bài AI vào buổi hiện tại hay thay thế toàn bộ kế hoạch chưa hoàn thành?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            OutlinedButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, _PlanApplyMode.replace),
              style: OutlinedButton.styleFrom(foregroundColor: colors.error),
              child: const Text('Thay thế'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, _PlanApplyMode.append),
              child: const Text('Thêm vào buổi hiện tại'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _applyPlan() async {
    HapticFeedback.lightImpact();
    final scheduleState = ref.read(workoutScheduleProvider);
    final sessionState = ref.read(workoutSessionProvider);
    final selectedDate = scheduleState.selectedDate;
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final newTitle = 'AI Giáo án: ${_selectedMuscles.join(' - ')}';
    final isAdditionalWorkout =
        selectedDate == todayStr &&
        (scheduleState.isTodayWorkoutCompleted || sessionState.isFinalized);
    final hasActiveWorkoutToday =
        selectedDate == todayStr &&
        sessionState.exercises.isNotEmpty &&
        !sessionState.isFinalized;
    var applyMode = _PlanApplyMode.replace;
    if (hasActiveWorkoutToday) {
      final selectedMode = await _chooseApplyMode(sessionState);
      if (selectedMode == null || !mounted) return;
      applyMode = selectedMode;
    }

    final plannedExercises = _generatedExercises
        .map(
          (exercise) =>
              PlannedExercisePreview(name: exercise.name, setsReps: '3x10'),
        )
        .toList();
    final scheduleNotifier = ref.read(workoutScheduleProvider.notifier);

    if (hasActiveWorkoutToday && applyMode == _PlanApplyMode.append) {
      final extended = scheduleNotifier.extendLatestPlannedSchedule(
        date: selectedDate,
        targetMuscles: _selectedMuscles.join(', '),
        addedDurationMinutes: _durationMinutes.round(),
        plannedExercises: plannedExercises,
      );
      if (!extended) {
        scheduleNotifier.addSchedule(
          title: sessionState.title,
          targetMuscles: {
            ...sessionState.exercises.map((item) => item.primaryMuscle),
            ..._selectedMuscles,
          }.join(' • '),
          durationMinutes: _durationMinutes.round(),
          date: selectedDate,
          time: '17:30',
          plannedExercises: plannedExercises,
        );
      }
      final sessionNotifier = ref.read(workoutSessionProvider.notifier);
      for (final exercise in _generatedExercises) {
        sessionNotifier.addExercise(exercise);
      }
    } else {
      final replaced =
          hasActiveWorkoutToday &&
          scheduleNotifier.replaceLatestPlannedSchedule(
            date: selectedDate,
            title: newTitle,
            targetMuscles: _selectedMuscles.join(', '),
            durationMinutes: _durationMinutes.round(),
            time: '17:30',
            plannedExercises: plannedExercises,
          );
      if (!replaced) {
        scheduleNotifier.addSchedule(
          title: newTitle,
          targetMuscles: _selectedMuscles.join(', '),
          durationMinutes: _durationMinutes.round(),
          date: selectedDate,
          time: '17:30',
          plannedExercises: plannedExercises,
        );
      }

      if (selectedDate == todayStr && _generatedExercises.isNotEmpty) {
        ref
            .read(workoutSessionProvider.notifier)
            .setSession(
              title: newTitle,
              exercises: _generatedExercises
                  .map(
                    (ex) => SessionExercise(
                      exerciseId: ex.id,
                      name: ex.name,
                      primaryMuscle: ex.primaryMuscle,
                      equipment: ex.equipment,
                      targetSets: 3,
                      targetReps: 10,
                      weightKg: ex.equipment == EquipmentType.bodyweight
                          ? 0
                          : 30,
                    ),
                  )
                  .toList(),
            );
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          hasActiveWorkoutToday && applyMode == _PlanApplyMode.append
              ? 'Đã bổ sung các bài AI và giữ nguyên tiến độ buổi hiện tại.'
              : isAdditionalWorkout
              ? 'Đã tạo buổi tập thêm bằng AI. Buổi đã hoàn thành vẫn được giữ trong lịch sử.'
              : 'Đã áp dụng giáo án AI vào lịch tập thành công!',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.go('/workout');
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('AI Tạo buổi tập'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          // Header Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                colors: [
                  colors.primary,
                  colors.primary.withValues(alpha: 0.75),
                ],
              ),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white24,
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Workout Generator',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Tạo buổi tập chuẩn khoa học theo cơ địa, mục tiêu & thiết bị sẵn có',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // 1. Target Muscles
          const Text(
            '1. Chọn nhóm cơ mục tiêu',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _allMuscles.map((muscle) {
              final isSelected = _selectedMuscles.contains(muscle);
              return FilterChip(
                label: Text(muscle),
                selected: isSelected,
                selectedColor: colors.primary.withValues(alpha: 0.22),
                checkmarkColor: colors.primary,
                side: BorderSide(
                  color: isSelected ? colors.primary : const Color(0xFF282E44),
                ),
                onSelected: (val) {
                  setState(() {
                    if (val) {
                      _selectedMuscles.add(muscle);
                    } else if (_selectedMuscles.length > 1) {
                      _selectedMuscles.remove(muscle);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 22),

          // 2. Equipment Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '2. Thiết bị tập luyện có sẵn',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              Text(
                '${_selectedEquipment.length}/${_equipmentOptions.length} thiết bị',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Equipment Presets
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _PresetChip(
                  label: 'Đầy đủ phòng Gym',
                  isSelected:
                      _selectedEquipment.length == EquipmentType.values.length,
                  onTap: () => _applyEquipmentPreset('full_gym'),
                ),
                const SizedBox(width: 8),
                _PresetChip(
                  label: 'Tạ đơn tại nhà',
                  isSelected:
                      _selectedEquipment.contains(EquipmentType.dumbbell) &&
                      !_selectedEquipment.contains(EquipmentType.machine) &&
                      !_selectedEquipment.contains(EquipmentType.cable),
                  onTap: () => _applyEquipmentPreset('home_dumbbell'),
                ),
                const SizedBox(width: 8),
                _PresetChip(
                  label: 'Bodyweight (Không dụng cụ)',
                  isSelected:
                      _selectedEquipment.length == 1 &&
                      _selectedEquipment.contains(EquipmentType.bodyweight),
                  onTap: () => _applyEquipmentPreset('bodyweight'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Equipment Multi-Selection
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _equipmentOptions.map((item) {
              final type = item.$1;
              final label = item.$2;
              final icon = item.$3;
              final isSelected = _selectedEquipment.contains(type);

              return FilterChip(
                avatar: Icon(
                  icon,
                  size: 16,
                  color: isSelected ? colors.primary : Colors.white60,
                ),
                label: Text(label),
                selected: isSelected,
                selectedColor: colors.primary.withValues(alpha: 0.22),
                checkmarkColor: colors.primary,
                side: BorderSide(
                  color: isSelected ? colors.primary : const Color(0xFF282E44),
                ),
                onSelected: (val) {
                  setState(() {
                    if (val) {
                      _selectedEquipment.add(type);
                    } else if (_selectedEquipment.length > 1) {
                      _selectedEquipment.remove(type);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 22),

          // 3. Duration Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '3. Thời lượng buổi tập',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              Text(
                '${_durationMinutes.round()} phút',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          Slider(
            value: _durationMinutes,
            min: 30,
            max: 90,
            divisions: 4,
            label: '${_durationMinutes.round()} phút',
            onChanged: (val) => setState(() => _durationMinutes = val),
          ),
          const SizedBox(height: 18),

          // 4. Goal Selector
          const Text(
            '4. Trọng tâm buổi tập',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          ..._goals.map((g) {
            final isSelected = _goal == g;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: isSelected
                  ? colors.primary.withValues(alpha: 0.12)
                  : const Color(0xFF141724),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: isSelected ? colors.primary : const Color(0xFF282E44),
                ),
              ),
              child: ListTile(
                title: Text(
                  g,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.white70,
                  ),
                ),
                trailing: Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isSelected ? colors.primary : colors.onSurfaceVariant,
                ),
                onTap: () => setState(() => _goal = g),
              ),
            );
          }),

          const SizedBox(height: 20),

          // Generate CTA Button
          FilledButton.icon(
            onPressed: _isGenerating ? null : _generatePlan,
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: _isGenerating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome_rounded),
            label: Text(
              _isGenerating ? 'AI Đang phân tích...' : 'AI Tạo giáo án tối ưu',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
          ),

          // Generated Plan Preview
          if (_generated) ...[
            const SizedBox(height: 24),
            const Divider(color: Color(0xFF282E44)),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Đề xuất: ${_selectedMuscles.join(' + ')} (${_generatedExercises.length} bài)',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF141724),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF282E44)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: _generatedExercises.asMap().entries.map((entry) {
                  final index = entry.key;
                  final ex = entry.value;
                  final isLast = index == _generatedExercises.length - 1;

                  return Column(
                    children: [
                      _ExercisePreviewRow(
                        number: index + 1,
                        name: ex.name,
                        sets: _getSetsRepsRecommendation(),
                        muscle: ex.primaryMuscle,
                        equipmentLabel: ex.equipment.label,
                      ),
                      if (!isLast)
                        const Divider(color: Color(0xFF222638), height: 16),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _applyPlan,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.add_task_rounded),
              label: const Text(
                'Áp dụng giáo án này vào lịch tập',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withValues(alpha: 0.18)
              : const Color(0xFF141724),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? colors.primary : const Color(0xFF282E44),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? colors.primary : Colors.white70,
          ),
        ),
      ),
    );
  }
}

class _ExercisePreviewRow extends StatelessWidget {
  const _ExercisePreviewRow({
    required this.number,
    required this.name,
    required this.sets,
    required this.muscle,
    required this.equipmentLabel,
  });

  final int number;
  final String name;
  final String sets;
  final String muscle;
  final String equipmentLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(7),
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: colors.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sets,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ExerciseTagChip.muscle(label: muscle),
              const SizedBox(height: 4),
              ExerciseTagChip.equipment(label: equipmentLabel),
            ],
          ),
        ],
      ),
    );
  }
}
