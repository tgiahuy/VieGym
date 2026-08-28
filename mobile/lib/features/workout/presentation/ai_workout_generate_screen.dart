import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/workout_schedule_controller.dart';

class AiWorkoutGenerateScreen extends ConsumerStatefulWidget {
  const AiWorkoutGenerateScreen({super.key});

  @override
  ConsumerState<AiWorkoutGenerateScreen> createState() =>
      _AiWorkoutGenerateScreenState();
}

class _AiWorkoutGenerateScreenState
    extends ConsumerState<AiWorkoutGenerateScreen> {
  final Set<String> _selectedMuscles = {'Ngực', 'Vai'};
  double _durationMinutes = 45;
  String _goal = 'Tăng cơ nạc (Hypertrophy)';
  bool _isGenerating = false;
  bool _generated = false;

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

  Future<void> _generatePlan() async {
    setState(() => _isGenerating = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (mounted) {
      setState(() {
        _isGenerating = false;
        _generated = true;
      });
    }
  }

  void _applyPlan() {
    ref.read(workoutScheduleProvider.notifier).addSchedule(
          title: 'AI Cung Cấp: ${_selectedMuscles.join(' - ')} Hypertrophy',
          targetMuscles: _selectedMuscles.join(', '),
          durationMinutes: _durationMinutes.round(),
          date: ref.read(workoutScheduleProvider).selectedDate,
          time: '17:30',
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã áp dụng giáo án AI vào lịch tập thành công!'),
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
                  colors.primary.withValues(alpha: 0.7),
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
                        'Tạo buổi tập chuẩn khoa học theo cơ địa & mục tiêu',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Target Muscles
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
          const SizedBox(height: 20),

          // Duration Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '2. Thời lượng buổi tập',
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
          const SizedBox(height: 16),

          // Goal Selector
          const Text(
            '3. Trọng tâm buổi tập',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          ..._goals.map((g) {
            final isSelected = _goal == g;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: isSelected
                  ? colors.primary.withValues(alpha: 0.12)
                  : colors.surfaceContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: isSelected
                      ? colors.primary
                      : colors.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: ListTile(
                title: Text(
                  g,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
                trailing: Radio<String>(
                  value: g,
                  groupValue: _goal,
                  onChanged: (val) {
                    if (val != null) setState(() => _goal = val);
                  },
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
            label: Text(_isGenerating ? 'AI Đang phân tích...' : 'AI Tạo giáo án tối ưu'),
          ),

          // Generated Plan Preview
          if (_generated) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.greenAccent),
                const SizedBox(width: 8),
                Text(
                  'Đề xuất: ${_selectedMuscles.join(' + ')}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _ExercisePreviewRow(
                      number: 1,
                      name: 'Barbell Bench Press',
                      sets: '4 hiệp × 8-10 reps',
                      muscle: 'Ngực',
                    ),
                    const Divider(),
                    _ExercisePreviewRow(
                      number: 2,
                      name: 'Incline Dumbbell Press',
                      sets: '3 hiệp × 10-12 reps',
                      muscle: 'Ngực trên',
                    ),
                    const Divider(),
                    _ExercisePreviewRow(
                      number: 3,
                      name: 'Overhead Press (OHP)',
                      sets: '3 hiệp × 8-10 reps',
                      muscle: 'Vai',
                    ),
                    const Divider(),
                    _ExercisePreviewRow(
                      number: 4,
                      name: 'Tricep Rope Pushdown',
                      sets: '3 hiệp × 12-15 reps',
                      muscle: 'Tay sau',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _applyPlan,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.greenAccent.shade700,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.add_task_rounded),
              label: const Text(
                'Áp dụng giáo án này vào lịch tập',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ],
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
  });

  final int number;
  final String name;
  final String sets;
  final String muscle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            child: Text('$number', style: const TextStyle(fontSize: 11)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                Text(
                  '$muscle • $sets',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
