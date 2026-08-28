import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../onboarding/application/health_profile_controller.dart';
import '../../onboarding/domain/user_profile_models.dart';

class HealthProfileEditScreen extends ConsumerStatefulWidget {
  const HealthProfileEditScreen({super.key});

  @override
  ConsumerState<HealthProfileEditScreen> createState() =>
      _HealthProfileEditScreenState();
}

class _HealthProfileEditScreenState
    extends ConsumerState<HealthProfileEditScreen> {
  late int _age;
  late double _heightCm;
  late double _weightKg;
  late double _targetWeightKg;
  late BiologicalGender _gender;
  late FitnessGoal _goal;
  late ActivityLevel _activityLevel;
  late TrainingExperience _experience;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(healthProfileProvider);
    _age = profile.age;
    _heightCm = profile.heightCm.toDouble();
    _weightKg = profile.weightKg.toDouble();
    _targetWeightKg = profile.targetWeightKg.toDouble();
    _gender = profile.gender;
    _goal = profile.goal;
    _activityLevel = profile.activityLevel;
    _experience = profile.experience;
  }

  void _save() {
    ref.read(healthProfileProvider.notifier).updateProfile(
          gender: _gender,
          age: _age,
          heightCm: _heightCm.round(),
          weightKg: _weightKg.round(),
          targetWeightKg: _targetWeightKg.round(),
          goal: _goal,
          activityLevel: _activityLevel,
          experience: _experience,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã cập nhật chỉ số thể chất & mục tiêu!')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final tempProfile = HealthProfile(
      gender: _gender,
      age: _age,
      heightCm: _heightCm.round(),
      weightKg: _weightKg.round(),
      targetWeightKg: _targetWeightKg.round(),
      goal: _goal,
      activityLevel: _activityLevel,
      experience: _experience,
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Chỉ số thể chất & Mục tiêu'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          // Live Calculated Metrics Card
          Card(
            margin: EdgeInsets.zero,
            color: colors.primary.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: colors.primary.withValues(alpha: 0.4)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.bolt_rounded, color: colors.primary),
                      const SizedBox(width: 8),
                      const Text(
                        'Chỉ số tính toán tự động',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _MetricBox(
                        label: 'BMI',
                        value: tempProfile.bmi.toStringAsFixed(1),
                        subLabel: tempProfile.bmiCategory,
                        color: Colors.greenAccent,
                      ),
                      _MetricBox(
                        label: 'BMR',
                        value: '${tempProfile.bmr}',
                        subLabel: 'kcal/ngày',
                        color: Colors.blueAccent,
                      ),
                      _MetricBox(
                        label: 'TDEE (Mục tiêu)',
                        value: '${tempProfile.tdee}',
                        subLabel: 'kcal/ngày',
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Height & Weight Controls
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Chiều cao:', style: TextStyle(fontWeight: FontWeight.w700)),
                      Text('${_heightCm.round()} cm', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: colors.primary)),
                    ],
                  ),
                  Slider(
                    value: _heightCm,
                    min: 130,
                    max: 210,
                    onChanged: (val) => setState(() => _heightCm = val),
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Cân nặng:', style: TextStyle(fontWeight: FontWeight.w700)),
                      Text('${_weightKg.toStringAsFixed(1)} kg', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: colors.primary)),
                    ],
                  ),
                  Slider(
                    value: _weightKg,
                    min: 35,
                    max: 150,
                    onChanged: (val) => setState(() => _weightKg = val),
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Cân nặng mục tiêu:', style: TextStyle(fontWeight: FontWeight.w700)),
                      Text('${_targetWeightKg.toStringAsFixed(1)} kg', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: colors.primary)),
                    ],
                  ),
                  Slider(
                    value: _targetWeightKg,
                    min: 35,
                    max: 150,
                    onChanged: (val) => setState(() => _targetWeightKg = val),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Fitness Goal Selector
          const Text('Mục tiêu thể hình', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ...FitnessGoal.values.map((g) {
            final isSelected = _goal == g;
            return Card(
              margin: const EdgeInsets.only(bottom: 6),
              color: isSelected ? colors.primary.withValues(alpha: 0.12) : null,
              child: ListTile(
                title: Text(g.label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                trailing: Radio<FitnessGoal>(
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
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: _save,
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text('Cập nhật chỉ số', style: TextStyle(fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  const _MetricBox({
    required this.label,
    required this.value,
    required this.subLabel,
    required this.color,
  });

  final String label;
  final String value;
  final String subLabel;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
        Text(subLabel, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10)),
      ],
    );
  }
}
