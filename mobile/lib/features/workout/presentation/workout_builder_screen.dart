import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../data/exercise_catalog.dart';
import '../domain/workout_models.dart';
import 'exercise_library_screen.dart';

class WorkoutBuilderScreen extends ConsumerStatefulWidget {
  const WorkoutBuilderScreen({
    super.key,
    this.initialProgramName,
    this.programType,
  });

  final String? initialProgramName;
  final String? programType;

  @override
  ConsumerState<WorkoutBuilderScreen> createState() =>
      _WorkoutBuilderScreenState();
}

class _WorkoutBuilderScreenState extends ConsumerState<WorkoutBuilderScreen> {
  late TextEditingController _nameController;
  late String _selectedType;
  final List<_DayBuilderModel> _days = [];
  int _activeDayIndex = 0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialProgramName ?? 'Giáo án cá nhân',
    );
    _selectedType = widget.programType ?? 'CUSTOM';
    _initDefaultDays();
  }

  void _initDefaultDays() {
    _days.add(
      _DayBuilderModel(
        dayNumber: 1,
        name: 'Buổi 1: Thân trên',
        exercises: [
          _ExerciseBuilderModel(
            exercise: exerciseCatalog.firstWhere(
              (e) => e.name.contains('Bench') || e.nameVi.contains('Ngực'),
              orElse: () => exerciseCatalog.first,
            ),
            targetSets: 3,
            targetRepsMin: 8,
            targetRepsMax: 12,
            restSeconds: 90,
          ),
        ],
      ),
    );
    _days.add(
      _DayBuilderModel(
        dayNumber: 2,
        name: 'Buổi 2: Thân dưới',
        exercises: [
          _ExerciseBuilderModel(
            exercise: exerciseCatalog.firstWhere(
              (e) => e.name.contains('Squat') || e.nameVi.contains('Chân'),
              orElse: () => exerciseCatalog.last,
            ),
            targetSets: 4,
            targetRepsMin: 6,
            targetRepsMax: 10,
            restSeconds: 120,
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

  void _addDay() {
    setState(() {
      final newDayNumber = _days.length + 1;
      _days.add(
        _DayBuilderModel(
          dayNumber: newDayNumber,
          name: 'Buổi $newDayNumber',
          exercises: [],
        ),
      );
      _activeDayIndex = _days.length - 1;
    });
  }

  void _removeDay(int index) {
    if (_days.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Giáo án phải có ít nhất một ngày tập.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() {
      _days.removeAt(index);
      for (int i = 0; i < _days.length; i++) {
        _days[i].dayNumber = i + 1;
      }
      if (_activeDayIndex >= _days.length) {
        _activeDayIndex = _days.length - 1;
      }
    });
  }

  Future<void> _addExerciseToCurrentDay() async {
    final dynamic result;
    if (GoRouter.maybeOf(context) != null) {
      result = await context.push<dynamic>(
        '/workout/library?select=true&multi=true&title=${Uri.encodeComponent('Chọn bài tập cho Buổi ${_days[_activeDayIndex].dayNumber}')}',
      );
    } else {
      result = await Navigator.of(context).push<dynamic>(
        MaterialPageRoute(
          builder: (context) => ExerciseLibraryScreen(
            isPicker: true,
            isMultiSelect: true,
            title: 'Chọn bài tập cho Buổi ${_days[_activeDayIndex].dayNumber}',
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
    });
  }

  void _saveProgram() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tên giáo án.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    for (final day in _days) {
      if (day.exercises.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${day.name} chưa có bài tập nào.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã lưu giáo án "${_nameController.text.trim()}" thành công!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final currentDay = _days.isNotEmpty ? _days[_activeDayIndex] : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Builder'),
        actions: [
          TextButton(
            onPressed: _saveProgram,
            child: const Text(
              'Lưu',
              style: TextStyle(
                color: AppColors.accentEmerald,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Program info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1F30),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF282E44)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Tên giáo án',
                      hintText: 'Nhập tên giáo án...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Phân loại',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'PPL',
                        child: Text('Push / Pull / Legs (PPL)'),
                      ),
                      DropdownMenuItem(
                        value: 'UPPER_LOWER',
                        child: Text('Upper / Lower'),
                      ),
                      DropdownMenuItem(
                        value: 'FULL_BODY',
                        child: Text('Full Body'),
                      ),
                      DropdownMenuItem(
                        value: 'CUSTOM',
                        child: Text('Tùy chỉnh (Custom)'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedType = val);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Days Tabs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CÁC BUỔI TẬP (${_days.length})',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: Colors.white70,
                  ),
                ),
                TextButton.icon(
                  onPressed: _addDay,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Thêm buổi'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _days.length,
                separatorBuilder: (c, i) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final day = _days[index];
                  final isSelected = index == _activeDayIndex;
                  return ChoiceChip(
                    label: Text('Buổi ${day.dayNumber}'),
                    selected: isSelected,
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

            // Active Day Editor
            if (currentDay != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1F30),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF282E44)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            key: ValueKey('day_name_${currentDay.dayNumber}'),
                            initialValue: currentDay.name,
                            decoration: const InputDecoration(
                              labelText: 'Tên buổi tập',
                              isDense: true,
                            ),
                            onChanged: (val) {
                              currentDay.name = val;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          tooltip: 'Xóa buổi này',
                          onPressed: () => _removeDay(_activeDayIndex),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Danh sách bài tập (${currentDay.exercises.length})',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _addExerciseToCurrentDay,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Thêm bài'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (currentDay.exercises.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            'Chưa có bài tập nào trong buổi này.\nNhấn "Thêm bài" để chọn từ thư viện.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      )
                    else
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: currentDay.exercises.length,
                        onReorderItem: (oldIndex, newIndex) {
                          setState(() {
                            final item = currentDay.exercises.removeAt(oldIndex);
                            currentDay.exercises.insert(newIndex, item);
                          });
                        },
                        itemBuilder: (context, exIndex) {
                          final exModel = currentDay.exercises[exIndex];
                          return Card(
                            key: ValueKey('ex_${exModel.exercise.id}_$exIndex'),
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${exIndex + 1}. ${exModel.exercise.name}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close, size: 18),
                                        onPressed: () {
                                          setState(() {
                                            currentDay.exercises.removeAt(exIndex);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _ConfigBox(
                                          label: 'Số Sets',
                                          value: '${exModel.targetSets}',
                                          onDecrement: () {
                                            if (exModel.targetSets > 1) {
                                              setState(() => exModel.targetSets--);
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
                                              setState(() => exModel.targetRepsMin--);
                                            }
                                          },
                                          onIncrement: () {
                                            setState(() {
                                              exModel.targetRepsMin++;
                                              if (exModel.targetRepsMin > exModel.targetRepsMax) {
                                                exModel.targetRepsMax = exModel.targetRepsMin;
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
                                            if (exModel.targetRepsMax > exModel.targetRepsMin) {
                                              setState(() => exModel.targetRepsMax--);
                                            }
                                          },
                                          onIncrement: () {
                                            setState(() => exModel.targetRepsMax++);
                                          },
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
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.white70),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: onDecrement,
                child: const Icon(Icons.remove, size: 16),
              ),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              InkWell(
                onTap: onIncrement,
                child: const Icon(Icons.add, size: 16),
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
