import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../onboarding/application/health_profile_controller.dart';
import '../../onboarding/data/health_profile_repository.dart';
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
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(healthProfileProvider);
    _age = profile.age;
    _heightCm = profile.heightCm.toDouble();
    _weightKg = profile.weightKg.roundToDouble();
    _targetWeightKg = profile.targetWeightKg.roundToDouble();
    _gender = profile.gender;
    _goal = profile.goal;
    _activityLevel = profile.activityLevel;
    _experience = profile.experience;
  }

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    ref
        .read(healthProfileProvider.notifier)
        .updateProfile(
          gender: _gender,
          age: _age,
          heightCm: _heightCm.round(),
          weightKg: _weightKg.round(),
          targetWeightKg: _targetWeightKg.round(),
          goal: _goal,
          activityLevel: _activityLevel,
          experience: _experience,
        );

    try {
      await ref.read(healthProfileProvider.notifier).saveEditedProfile();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã cập nhật chỉ số thể chất & mục tiêu!'),
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e is HealthProfileApiException
                ? e.message
                : 'Không thể cập nhật hồ sơ. Vui lòng thử lại.',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
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

          // Height & Weight Controls (Số tròn nguyên bản)
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
                      const Text(
                        'Chiều cao:',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${_heightCm.round()} cm',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _heightCm,
                    min: 130,
                    max: 210,
                    divisions: 80,
                    onChanged: (val) =>
                        setState(() => _heightCm = val.roundToDouble()),
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Cân nặng:',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${_weightKg.round()} kg',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _weightKg,
                    min: 35,
                    max: 150,
                    divisions: 115,
                    onChanged: (val) =>
                        setState(() => _weightKg = val.roundToDouble()),
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Cân nặng mục tiêu:',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${_targetWeightKg.round()} kg',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _targetWeightKg,
                    min: 35,
                    max: 150,
                    divisions: 115,
                    onChanged: (val) =>
                        setState(() => _targetWeightKg = val.roundToDouble()),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Fitness Goal Selector with Rich Visual Illustration Cards
          const Text(
            'Mục tiêu thể hình',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),

          ...FitnessGoal.values.map((goal) {
            final isSelected = _goal == goal;
            return _GoalIllustrationCard(
              goal: goal,
              isSelected: isSelected,
              onTap: () => setState(() => _goal = goal),
            );
          }),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: _isSaving ? null : _save,
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Cập nhật chỉ số',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
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
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        Text(
          subLabel,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10),
        ),
      ],
    );
  }
}

class _GoalIllustrationCard extends StatelessWidget {
  const _GoalIllustrationCard({
    required this.goal,
    required this.isSelected,
    required this.onTap,
  });

  final FitnessGoal goal;
  final bool isSelected;
  final VoidCallback onTap;

  (IconData, Color, List<Color>) _getGoalVisuals() {
    switch (goal) {
      case FitnessGoal.gainMuscle:
        return (
          Icons.fitness_center_rounded,
          const Color(0xFFFF2E54),
          [const Color(0xFFFF2E54), const Color(0xFFFF5277)],
        );
      case FitnessGoal.loseFat:
        return (
          Icons.local_fire_department_rounded,
          Colors.orangeAccent,
          [Colors.deepOrange, Colors.orangeAccent],
        );
      case FitnessGoal.buildStrength:
        return (
          Icons.bolt_rounded,
          Colors.purpleAccent,
          [Colors.deepPurple, Colors.purpleAccent],
        );
      case FitnessGoal.maintain:
        return (
          Icons.favorite_rounded,
          Colors.greenAccent,
          [Colors.teal, Colors.greenAccent],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (icon, accentColor, gradientColors) = _getGoalVisuals();

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: isSelected
          ? colors.primary.withValues(alpha: 0.12)
          : colors.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected
              ? colors.primary
              : colors.outlineVariant.withValues(alpha: 0.35),
          width: isSelected ? 1.6 : 1.0,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Visual Icon Illustration Container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    colors: gradientColors
                        .map(
                          (c) => c.withValues(alpha: isSelected ? 0.35 : 0.15),
                        )
                        .toList(),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: accentColor.withValues(
                      alpha: isSelected ? 0.6 : 0.25,
                    ),
                  ),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: isSelected ? colors.primary : accentColor,
                ),
              ),
              const SizedBox(width: 12),

              // Title & Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            goal.label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isSelected
                                  ? colors.primary
                                  : colors.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            goal.badge,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      goal.description,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: colors.onSurfaceVariant,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Radio Check Circle
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? colors.primary : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? colors.primary : colors.outlineVariant,
                    width: 1.5,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
