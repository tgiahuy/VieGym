import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/selectable_card.dart';
import '../../auth/application/auth_controller.dart';
import '../application/health_profile_controller.dart';
import '../data/health_profile_repository.dart';
import '../domain/user_profile_models.dart';

class HealthProfileOnboardingScreen extends ConsumerStatefulWidget {
  const HealthProfileOnboardingScreen({super.key});

  @override
  ConsumerState<HealthProfileOnboardingScreen> createState() =>
      _HealthProfileOnboardingScreenState();
}

class _HealthProfileOnboardingScreenState
    extends ConsumerState<HealthProfileOnboardingScreen> {
  int _currentStep = 1;
  static const int _totalSteps = 11;
  static const int _currentYear = 2026;
  bool _isSubmitting = false;

  late final TextEditingController _nicknameController;
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;
  late final TextEditingController _targetWeightController;
  late final FocusNode _heightFocusNode;
  late final FocusNode _weightFocusNode;
  late final FocusNode _targetWeightFocusNode;
  String? _nicknameError;

  // Track explicit user selection per step (default null so nothing is highlighted initially)
  BiologicalGender? _selectedGender;
  FitnessGoal? _selectedGoal;
  ActivityLevel? _selectedActivityLevel;
  TrainingExperience? _selectedExperience;
  int? _selectedDaysPerWeek;
  int? _selectedDurationMinutes;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(healthProfileProvider);
    final auth = ref.read(authProvider);
    final initialName = profile.nickname.isNotEmpty
        ? profile.nickname
        : (auth.user?.displayName ?? '');
    _nicknameController = TextEditingController(text: initialName);
    _heightController = TextEditingController(text: '${profile.heightCm}');
    _weightController = TextEditingController(text: '${profile.weightKg}');
    _targetWeightController = TextEditingController(
      text: '${profile.targetWeightKg}',
    );
    _heightFocusNode = FocusNode();
    _weightFocusNode = FocusNode();
    _targetWeightFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    _heightFocusNode.dispose();
    _weightFocusNode.dispose();
    _targetWeightFocusNode.dispose();
    super.dispose();
  }

  void _setHeight(int val) {
    final clamped = val.clamp(100, 250);
    ref.read(healthProfileProvider.notifier).updateHeight(clamped);
  }

  void _setWeight(int val) {
    final clamped = val.clamp(30, 250);
    ref.read(healthProfileProvider.notifier).updateWeight(clamped);
  }

  void _setTargetWeight(int val) {
    final clamped = val.clamp(30, 250);
    ref.read(healthProfileProvider.notifier).updateTargetWeight(clamped);
  }

  void _nextStep() {
    if (_currentStep == 4) {
      final h =
          int.tryParse(_heightController.text) ??
          ref.read(healthProfileProvider).heightCm;
      final clampedH = h.clamp(100, 250);
      _heightController.text = '$clampedH';
      ref.read(healthProfileProvider.notifier).updateHeight(clampedH);

      final w =
          int.tryParse(_weightController.text) ??
          ref.read(healthProfileProvider).weightKg;
      final clampedW = w.clamp(30, 250);
      _weightController.text = '$clampedW';
      ref.read(healthProfileProvider.notifier).updateWeight(clampedW);
    } else if (_currentStep == 5) {
      final tw =
          int.tryParse(_targetWeightController.text) ??
          ref.read(healthProfileProvider).targetWeightKg;
      final clampedTw = tw.clamp(30, 250);
      _targetWeightController.text = '$clampedTw';
      ref.read(healthProfileProvider.notifier).updateTargetWeight(clampedTw);
    }

    if (_currentStep < _totalSteps) {
      setState(() => _currentStep++);
    } else {
      _finishHealthProfile();
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    } else {
      if (context.canPop()) {
        context.pop();
      }
    }
  }

  void _validateAndNextNickname() {
    final text = _nicknameController.text.trim();
    if (text.isEmpty) {
      setState(() => _nicknameError = 'Vui lòng nhập biệt danh của bạn');
      return;
    }
    if (text.length < 2) {
      setState(() => _nicknameError = 'Biệt danh cần tối thiểu 2 ký tự');
      return;
    }
    if (text.length > 10) {
      setState(() => _nicknameError = 'Biệt danh tối đa 10 ký tự');
      return;
    }
    _nicknameController.text = text;
    setState(() => _nicknameError = null);
    ref.read(healthProfileProvider.notifier).updateNickname(text);
    ref.read(authProvider.notifier).updateDisplayName(text);
    _nextStep();
  }

  Future<void> _finishHealthProfile() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      await ref.read(healthProfileProvider.notifier).submitInitialProfile();
      if (!mounted) return;
      final profile = ref.read(healthProfileProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Hồ sơ sức khỏe đã lưu! TDEE: ${profile.tdee} kcal/ngày',
          ),
        ),
      );
      context.push('/onboarding/equipment');
    } catch (e) {
      if (!mounted) return;
      final isBypass = ref.read(devBypassAuthProvider);
      if (isBypass) {
        ref.read(healthProfileProvider.notifier).completeProfile();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hồ sơ sức khỏe đã lưu cục bộ (Dev Mode)'),
          ),
        );
        context.push('/onboarding/equipment');
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e is HealthProfileApiException
                ? e.message
                : 'Không thể lưu hồ sơ sức khỏe. Vui lòng thử lại.',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _autoSelect(VoidCallback updateAction) {
    updateAction();
    Future.delayed(const Duration(milliseconds: 180), () {
      if (mounted) {
        _nextStep();
      }
    });
  }

  Widget _buildBottomStepProgress(ColorScheme colors, HealthProfile profile) {
    final progress = _currentStep / _totalSteps;
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Bước $_currentStep / $_totalSteps',
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: AppColors.surfaceNested,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(healthProfileProvider);
    final notifier = ref.read(healthProfileProvider.notifier);
    final colors = Theme.of(context).colorScheme;

    final birthYear = _currentYear - profile.age;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header: Back Arrow (visible if _currentStep > 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 1)
                    IconButton(
                      onPressed: _previousStep,
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: colors.surfaceContainer,
                        foregroundColor: colors.onSurface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: colors.outlineVariant.withValues(alpha: 0.6),
                          ),
                        ),
                        minimumSize: const Size(40, 40),
                        padding: EdgeInsets.zero,
                      ),
                    )
                  else
                    const SizedBox(width: 40, height: 40),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 16),

              // Title and Subtitle Area for Steps 2..8
              if (_currentStep == 2) ...[
                Text(
                  'Giới tính sinh học?',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: colors.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Chọn một mục để tự động tính toán chỉ số BMR & TDEE',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
              ] else if (_currentStep == 3) ...[
                Text(
                  'Tuyệt vời! Chúng tôi sẽ tạo lịch tập tốt nhất dựa trên thông tin của bạn.',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                    height: 1.35,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 20),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                    ),
                    children: [
                      const TextSpan(text: 'Bạn sinh '),
                      TextSpan(
                        text: 'năm bao nhiêu',
                        style: TextStyle(color: colors.onSurface),
                      ),
                      const TextSpan(text: '?'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ] else if (_currentStep == 4) ...[
                Text(
                  'Chiều cao & Cân nặng',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: colors.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Nhập trực tiếp thông số cơ thể để AI tính toán chỉ số BMI & BMR chính xác',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
              ] else if (_currentStep == 5) ...[
                Text(
                  'Cân nặng mục tiêu',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: colors.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Bạn muốn hướng tới cân nặng bao nhiêu?',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
              ] else if (_currentStep == 6) ...[
                Text(
                  'Mục tiêu chính của bạn?',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: colors.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Chọn mục tiêu để AI cá nhân hóa bài tập và dinh dưỡng',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
              ] else if (_currentStep == 7) ...[
                Text(
                  'Mức độ vận động mỗi ngày?',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: colors.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Không tính buổi tập gym - giúp tính calo tiêu thụ tự nhiên',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
              ] else if (_currentStep == 8) ...[
                Text(
                  'Kinh nghiệm tập luyện?',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: colors.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Chọn cấp độ của bạn để hoàn tất hồ sơ thể lực',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
              ] else if (_currentStep == 9) ...[
                Text(
                  'Bạn sẽ tập bao nhiêu buổi 1 tuần?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: colors.onSurface,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'VieGym sẽ cân bằng khối lượng và thời gian phục hồi cơ bắp tối ưu',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
              ] else if (_currentStep == 10) ...[
                Text(
                  '1 buổi tập của bạn kéo dài bao lâu?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: colors.onSurface,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Để thiết kế số lượng bài tập và thời gian nghỉ giữa hiệp chính xác nhất',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
              ] else if (_currentStep == 11) ...[
                Text(
                  'Chúng tôi sẽ tối ưu lịch tập và thực đơn của bạn!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: colors.onSurface,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'VieGym AI đã sẵn sàng cá nhân hóa toàn bộ lộ trình cho ${profile.nickname.isEmpty ? 'bạn' : profile.nickname}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Step Body
              Expanded(
                child: _currentStep == 1
                    ? LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: IntrinsicHeight(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 24),
                                      Text(
                                        'Hello!',
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w700,
                                          color: colors.onSurface,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Bạn muốn được gọi là gì?',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w900,
                                          color: colors.onSurface,
                                          letterSpacing: -0.5,
                                          height: 1.25,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'VieGym sẽ dùng tên này để gọi bạn trong ứng dụng.',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: colors.onSurfaceVariant,
                                        ),
                                      ),

                                      const Spacer(flex: 2),

                                      // Minimal Centered Nickname Input Area
                                      Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextField(
                                              autofocus: true,
                                              controller: _nicknameController,
                                              textAlign: TextAlign.center,
                                              textCapitalization:
                                                  TextCapitalization.words,
                                              maxLength: 10,
                                              maxLines: 1,
                                              cursorColor: colors.primary,
                                              cursorWidth: 2.5,
                                              buildCounter:
                                                  (
                                                    context, {
                                                    required currentLength,
                                                    required isFocused,
                                                    maxLength,
                                                  }) => null,
                                              style: TextStyle(
                                                fontSize: 34,
                                                fontWeight: FontWeight.w800,
                                                color: colors.onSurface,
                                                letterSpacing: -0.5,
                                              ),
                                              decoration: InputDecoration(
                                                isDense: true,
                                                filled: false,
                                                border: InputBorder.none,
                                                enabledBorder: InputBorder.none,
                                                focusedBorder: InputBorder.none,
                                                errorBorder: InputBorder.none,
                                                focusedErrorBorder:
                                                    InputBorder.none,
                                                contentPadding: EdgeInsets.zero,
                                                hintText: 'Biệt danh',
                                                hintStyle: TextStyle(
                                                  fontSize: 34,
                                                  fontWeight: FontWeight.w700,
                                                  color: colors.onSurfaceVariant
                                                      .withValues(alpha: 0.35),
                                                  letterSpacing: -0.5,
                                                ),
                                              ),
                                              onChanged: (val) {
                                                if (_nicknameError != null &&
                                                    val.trim().isNotEmpty) {
                                                  setState(
                                                    () => _nicknameError = null,
                                                  );
                                                }
                                              },
                                              onSubmitted: (_) =>
                                                  _validateAndNextNickname(),
                                            ),
                                            const SizedBox(height: 12),
                                            if (_nicknameError != null)
                                              Text(
                                                _nicknameError!,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: colors.error,
                                                ),
                                              )
                                            else
                                              Text(
                                                '2–10 ký tự, chỉ gồm chữ cái và số',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: colors.onSurfaceVariant
                                                      .withValues(alpha: 0.65),
                                                ),
                                              ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Bạn có thể thay đổi biệt danh sau trong Hồ sơ.',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: colors.onSurfaceVariant
                                                    .withValues(alpha: 0.4),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const Spacer(flex: 3),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : (_currentStep == 3
                          ? Center(
                              child: _BirthYearWheelPicker(
                                selectedYear: birthYear,
                                minYear: 1940,
                                maxYear: _currentYear - 14,
                                onYearChanged: (year) {
                                  final age = _currentYear - year;
                                  notifier.updateAge(age);
                                },
                              ),
                            )
                          : SingleChildScrollView(
                              child: Column(
                                children: [
                                  if (_currentStep == 2) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.violetSoft,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: AppColors.violetBorder
                                              .withValues(alpha: 0.7),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: const BoxDecoration(
                                              color: AppColors.violetSoft,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.auto_awesome_rounded,
                                              size: 14,
                                              color: AppColors.violet,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              'Giới tính sinh học giúp AI áp dụng chính xác công thức Mifflin-St Jeor để tính tốc độ chuyển hóa (BMR) và lượng calo tiêu thụ chuẩn.',
                                              style: TextStyle(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w500,
                                                color: colors.onSurface
                                                    .withValues(alpha: 0.85),
                                                height: 1.35,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    IntrinsicHeight(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Expanded(
                                            child: _GenderCard(
                                              label: 'Nam',
                                              sublabel: 'Thể hình & Thể lực',
                                              tag: 'BMR (+5 kcal)',
                                              icon: Icons.male_rounded,
                                              accentColor: AppColors.blue,
                                              isSelected:
                                                  _selectedGender ==
                                                  BiologicalGender.male,
                                              onTap: () {
                                                setState(() {
                                                  _selectedGender =
                                                      BiologicalGender.male;
                                                });
                                                _autoSelect(
                                                  () => notifier.updateGender(
                                                    BiologicalGender.male,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: _GenderCard(
                                              label: 'Nữ',
                                              sublabel: 'Săn chắc & Vóc dáng',
                                              tag: 'BMR (-161 kcal)',
                                              icon: Icons.female_rounded,
                                              accentColor: AppColors.cyan,
                                              isSelected:
                                                  _selectedGender ==
                                                  BiologicalGender.female,
                                              onTap: () {
                                                setState(() {
                                                  _selectedGender =
                                                      BiologicalGender.female;
                                                });
                                                _autoSelect(
                                                  () => notifier.updateGender(
                                                    BiologicalGender.female,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    SelectableCard(
                                      title: BiologicalGender.other.label,
                                      description:
                                          'Áp dụng hệ số chuyển hóa trung hòa (-78 kcal)',
                                      icon: Icons.transgender_rounded,
                                      accentColor: AppColors.violet,
                                      isSelected:
                                          _selectedGender ==
                                          BiologicalGender.other,
                                      onTap: () {
                                        setState(() {
                                          _selectedGender =
                                              BiologicalGender.other;
                                        });
                                        _autoSelect(
                                          () => notifier.updateGender(
                                            BiologicalGender.other,
                                          ),
                                        );
                                      },
                                    ),
                                    SelectableCard(
                                      title:
                                          BiologicalGender.preferNotToSay.label,
                                      description:
                                          'Bảo mật thông tin • Mặc định công thức chuẩn an toàn',
                                      icon: Icons.security_rounded,
                                      accentColor: AppColors.primary,
                                      isSelected:
                                          _selectedGender ==
                                          BiologicalGender.preferNotToSay,
                                      onTap: () {
                                        setState(() {
                                          _selectedGender =
                                              BiologicalGender.preferNotToSay;
                                        });
                                        _autoSelect(
                                          () => notifier.updateGender(
                                            BiologicalGender.preferNotToSay,
                                          ),
                                        );
                                      },
                                    ),
                                  ] else if (_currentStep == 4) ...[
                                    _DirectNumericInputCard(
                                      label: 'Chiều cao',
                                      unit: 'cm',
                                      icon: Icons.height_rounded,
                                      controller: _heightController,
                                      focusNode: _heightFocusNode,
                                      textInputAction: TextInputAction.next,
                                      onEditingComplete: () =>
                                          _weightFocusNode.requestFocus(),
                                      value: profile.heightCm,
                                      min: 100,
                                      max: 250,
                                      onChanged: _setHeight,
                                    ),
                                    const SizedBox(height: 12),
                                    _DirectNumericInputCard(
                                      label: 'Cân nặng hiện tại',
                                      unit: 'kg',
                                      icon: Icons.monitor_weight_outlined,
                                      controller: _weightController,
                                      focusNode: _weightFocusNode,
                                      textInputAction: TextInputAction.done,
                                      value: profile.weightKg,
                                      min: 30,
                                      max: 200,
                                      onChanged: _setWeight,
                                    ),
                                    const SizedBox(height: 14),
                                    _BmiSpectrumBar(bmi: profile.bmi),
                                    const SizedBox(height: 10),
                                    Builder(
                                      builder: (context) {
                                        final heightM =
                                            profile.heightCm / 100.0;
                                        final idealMinW =
                                            (18.5 * heightM * heightM).round();
                                        final idealMaxW =
                                            (24.9 * heightM * heightM).round();

                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.accentEmerald
                                                .withValues(alpha: 0.08),
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            border: Border.all(
                                              color: AppColors.accentEmerald
                                                  .withValues(alpha: 0.25),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.verified_rounded,
                                                size: 16,
                                                color: AppColors.accentEmerald,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'Cân nặng lý tưởng theo WHO cho ${profile.heightCm} cm: $idealMinW – $idealMaxW kg',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: colors.onSurface,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colors.surfaceContainer,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: colors.outlineVariant
                                              .withValues(alpha: 0.5),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: AppColors.accentAmber
                                                  .withValues(alpha: 0.15),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const Icon(
                                              Icons
                                                  .local_fire_department_rounded,
                                              size: 18,
                                              color: AppColors.accentAmber,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Tốc độ trao đổi chất cơ bản (BMR)',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        colors.onSurfaceVariant,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '${profile.bmr} kcal / ngày',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w900,
                                                    color: colors.onSurface,
                                                  ),
                                                ),
                                                Text(
                                                  'Năng lượng cơ thể tự tiêu thụ khi nghỉ ngơi hoàn toàn',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: colors
                                                        .onSurfaceVariant
                                                        .withValues(alpha: 0.7),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ] else if (_currentStep == 5) ...[
                                    // Target Weight Step
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: colors.surfaceContainer,
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: colors.outlineVariant
                                              .withValues(alpha: 0.6),
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Hiện tại: ${profile.weightKg} kg',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: colors
                                                          .onSurfaceVariant,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      profile.weightDifference ==
                                                          0
                                                      ? AppColors.info
                                                            .withValues(
                                                              alpha: 0.15,
                                                            )
                                                      : (profile.weightDifference <
                                                                0
                                                            ? AppColors.warning
                                                                  .withValues(
                                                                    alpha: 0.15,
                                                                  )
                                                            : AppColors.success
                                                                  .withValues(
                                                                    alpha: 0.15,
                                                                  )),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  profile.weightDifference == 0
                                                      ? 'Duy trì cân nặng'
                                                      : (profile.weightDifference <
                                                                0
                                                            ? 'Giảm ${profile.weightDifference.abs()} kg'
                                                            : 'Tăng ${profile.weightDifference} kg'),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w800,
                                                    color:
                                                        profile.weightDifference ==
                                                            0
                                                        ? AppColors.info
                                                        : (profile.weightDifference <
                                                                  0
                                                              ? AppColors
                                                                    .warning
                                                              : AppColors
                                                                    .success),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          _DirectNumericInputCard(
                                            label: 'Chọn cân nặng mục tiêu',
                                            unit: 'kg',
                                            icon: Icons.track_changes_rounded,
                                            controller: _targetWeightController,
                                            focusNode: _targetWeightFocusNode,
                                            textInputAction:
                                                TextInputAction.done,
                                            value: profile.targetWeightKg,
                                            min: 30,
                                            max: 200,
                                            onChanged: _setTargetWeight,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    // Smart AI Target Analytics Card
                                    Builder(
                                      builder: (context) {
                                        final targetHeightM =
                                            profile.heightCm / 100.0;
                                        final targetBmi =
                                            profile.targetWeightKg /
                                            (targetHeightM * targetHeightM);
                                        final (
                                          targetBmiLabel,
                                          targetBmiColor,
                                        ) = targetBmi < 18.5
                                            ? ('Thiếu cân', AppColors.warning)
                                            : (targetBmi < 24.9
                                                  ? (
                                                      'Chuẩn cân đối',
                                                      AppColors.success,
                                                    )
                                                  : (targetBmi < 29.9
                                                        ? (
                                                            'Thừa cân nhẹ',
                                                            AppColors.warning,
                                                          )
                                                        : (
                                                            'Cần giảm cân',
                                                            AppColors.error,
                                                          )));
                                        final diff = profile.weightDifference;
                                        final weeks = (diff.abs() / 0.5).ceil();

                                        return Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: colors.surfaceContainer,
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                            border: Border.all(
                                              color: colors.outlineVariant
                                                  .withValues(alpha: 0.5),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(6),
                                                    decoration: const BoxDecoration(
                                                      color: AppColors.violetSoft,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                            Radius.circular(8),
                                                          ),
                                                    ),
                                                    child: const Icon(
                                                      Icons
                                                          .auto_awesome_rounded,
                                                      size: 15,
                                                      color: AppColors.violet,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Phân tích mục tiêu AI',
                                                    style: TextStyle(
                                                      fontSize: 13.5,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: colors.onSurface,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              // Timeline
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.schedule_rounded,
                                                    size: 15,
                                                    color:
                                                        AppColors.iconSecondary,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      diff == 0
                                                          ? 'Duy trì vóc dáng: Tối ưu săn chắc cơ bắp & tỷ lệ chuyển hóa'
                                                          : 'Lộ trình dự kiến: ~$weeks tuần theo mức an toàn 0.5 kg/tuần',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: colors.onSurface,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              // Projected BMI
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.speed_rounded,
                                                    size: 15,
                                                    color:
                                                        AppColors.iconSecondary,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    'BMI mục tiêu: ',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: colors
                                                          .onSurfaceVariant,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${targetBmi.toStringAsFixed(1)} • $targetBmiLabel',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: targetBmiColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: targetBmiColor
                                                      .withValues(alpha: 0.10),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      targetBmi >= 18.5 &&
                                                              targetBmi <= 24.9
                                                          ? Icons
                                                                .check_circle_rounded
                                                          : Icons
                                                                .info_outline_rounded,
                                                      size: 14,
                                                      color: targetBmiColor,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Expanded(
                                                      child: Text(
                                                        targetBmi >= 18.5 &&
                                                                targetBmi <=
                                                                    24.9
                                                            ? 'Mục tiêu khoa học, lành mạnh và rất khả thi.'
                                                            : (targetBmi < 18.5
                                                                  ? 'Mục tiêu hơi nhẹ so với chiều cao, AI sẽ chú trọng bảo tồn cơ.'
                                                                  : 'AI sẽ tùy chỉnh giáo án và calo để bạn giảm mỡ bền vững.'),
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: targetBmiColor,
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
                                  ] else if (_currentStep == 6) ...[
                                    ...FitnessGoal.values.map((goal) {
                                      final (
                                        badge,
                                        smartTag,
                                        accent,
                                      ) = switch (goal) {
                                        FitnessGoal.gainMuscle => (
                                          'Phổ biến nhất',
                                          'Đồng hóa cơ • Thặng dư calo +300 kcal',
                                          AppColors.primary,
                                        ),
                                        FitnessGoal.loseFat => (
                                          'Khuyên dùng',
                                          'Thâm hụt calo -400 kcal • Giữ cơ tối đa',
                                          AppColors.orange,
                                        ),
                                        FitnessGoal.buildStrength => (
                                          null,
                                          'Tải trọng 80-90% 1RM • Tối ưu hệ thần kinh',
                                          AppColors.amber,
                                        ),
                                        FitnessGoal.maintain => (
                                          null,
                                          'Cân bằng năng lượng • Giữ vững phong độ',
                                          AppColors.cyan,
                                        ),
                                      };
                                      return _ModernSelectionCard(
                                        title: goal.label,
                                        description: goal.description,
                                        badge: badge ?? goal.badge,
                                        smartTag: smartTag,
                                        accentColor: accent,
                                        icon: goal == FitnessGoal.loseFat
                                            ? Icons
                                                  .local_fire_department_rounded
                                            : (goal == FitnessGoal.buildStrength
                                                  ? Icons.bolt_rounded
                                                  : (goal ==
                                                            FitnessGoal.maintain
                                                        ? Icons.balance_rounded
                                                        : Icons
                                                              .fitness_center_rounded)),
                                        isSelected: _selectedGoal == goal,
                                        onTap: () {
                                          setState(() => _selectedGoal = goal);
                                          _autoSelect(
                                            () => notifier.updateGoal(goal),
                                          );
                                        },
                                      );
                                    }),
                                  ] else if (_currentStep == 7) ...[
                                    ...ActivityLevel.values.map((level) {
                                      final (
                                        badge,
                                        smartTag,
                                        accent,
                                        icon,
                                      ) = switch (level) {
                                        ActivityLevel.sedentary => (
                                          null,
                                          'BMR x 1.2 • Dành cho công việc văn phòng ít di chuyển',
                                          AppColors.blue,
                                          Icons.chair_rounded,
                                        ),
                                        ActivityLevel.light => (
                                          null,
                                          'BMR x 1.375 • Đi bộ nhẹ, vận động 1-3 ngày/tuần',
                                          AppColors.cyan,
                                          Icons.directions_walk_rounded,
                                        ),
                                        ActivityLevel.active => (
                                          'Khuyên dùng',
                                          'BMR x 1.55 • Vận động tích cực 3-5 ngày/tuần',
                                          AppColors.green,
                                          Icons.directions_run_rounded,
                                        ),
                                        ActivityLevel.veryActive => (
                                          'Cường độ cao',
                                          'BMR x 1.725 • Vận động viên & tập nặng 6-7 ngày/tuần',
                                          AppColors.orange,
                                          Icons.sports_gymnastics_rounded,
                                        ),
                                      };
                                      return _ModernSelectionCard(
                                        title: level.label,
                                        description: level.description,
                                        badge: badge,
                                        smartTag: smartTag,
                                        accentColor: accent,
                                        icon: icon,
                                        isSelected:
                                            _selectedActivityLevel == level,
                                        onTap: () {
                                          setState(
                                            () =>
                                                _selectedActivityLevel = level,
                                          );
                                          _autoSelect(
                                            () => notifier.updateActivityLevel(
                                              level,
                                            ),
                                          );
                                        },
                                      );
                                    }),
                                  ] else if (_currentStep == 8) ...[
                                    ...TrainingExperience.values.map((exp) {
                                      final (
                                        badge,
                                        smartTag,
                                        accent,
                                        icon,
                                      ) = switch (exp) {
                                        TrainingExperience.beginner => (
                                          'Dễ tiếp cận',
                                          'Học kỹ thuật chuẩn & kích thích thích nghi thần kinh',
                                          AppColors.accentEmerald,
                                          Icons.spa_rounded,
                                        ),
                                        TrainingExperience.intermediate => (
                                          'Phổ biến',
                                          'Áp dụng Progressive Overload & phân chia nhóm cơ',
                                          AppColors.accentBlue,
                                          Icons.fitness_center_rounded,
                                        ),
                                        TrainingExperience.advanced => (
                                          'Chuyên sâu',
                                          'Phân kỳ tập luyện (Periodization) & bứt phá tạ',
                                          AppColors.accentAmber,
                                          Icons.military_tech_rounded,
                                        ),
                                      };
                                      return _ModernSelectionCard(
                                        title: exp.label,
                                        description: exp.description,
                                        badge: badge,
                                        smartTag: smartTag,
                                        accentColor: accent,
                                        icon: icon,
                                        isSelected: _selectedExperience == exp,
                                        onTap: () {
                                          setState(
                                            () => _selectedExperience = exp,
                                          );
                                          _autoSelect(
                                            () =>
                                                notifier.updateExperience(exp),
                                          );
                                        },
                                      );
                                    }),
                                  ] else if (_currentStep == 9) ...[
                                    _ModernSelectionCard(
                                      title: '2 - 3 buổi / tuần',
                                      description:
                                          'Thong thả, phục hồi tối đa, phù hợp người bận rộn',
                                      smartTag:
                                          'Giáo án Full-Body mỗi buổi • 48h phục hồi',
                                      accentColor: AppColors.cyan,
                                      icon: Icons.calendar_today_rounded,
                                      isSelected: _selectedDaysPerWeek == 3,
                                      onTap: () {
                                        setState(
                                          () => _selectedDaysPerWeek = 3,
                                        );
                                        _autoSelect(
                                          () => notifier
                                              .updateWorkoutDaysPerWeek(3),
                                        );
                                      },
                                    ),
                                    _ModernSelectionCard(
                                      title: '4 - 5 buổi / tuần',
                                      description:
                                          'Tối ưu phát triển cơ bắp & thể lực toàn diện',
                                      badge: 'Khuyên dùng',
                                      smartTag:
                                          'Upper/Lower hoặc PPL • Tần suất vàng khoa học',
                                      accentColor: AppColors.accentBlue,
                                      icon: Icons.calendar_month_rounded,
                                      isSelected:
                                          _selectedDaysPerWeek == 4 ||
                                          _selectedDaysPerWeek == 5,
                                      onTap: () {
                                        setState(
                                          () => _selectedDaysPerWeek = 4,
                                        );
                                        _autoSelect(
                                          () => notifier
                                              .updateWorkoutDaysPerWeek(4),
                                        );
                                      },
                                    ),
                                    _ModernSelectionCard(
                                      title: '6 buổi / tuần',
                                      description:
                                          'Cường độ cao, phân chia chuyên sâu (Push / Pull / Legs)',
                                      badge: 'Chuyên sâu',
                                      smartTag:
                                          'Push/Pull/Legs x 2 • Kích thích mỗi nhóm cơ 2 lần/tuần',
                                      accentColor: AppColors.accentAmber,
                                      icon: Icons.fitness_center_rounded,
                                      isSelected: _selectedDaysPerWeek == 6,
                                      onTap: () {
                                        setState(
                                          () => _selectedDaysPerWeek = 6,
                                        );
                                        _autoSelect(
                                          () => notifier
                                              .updateWorkoutDaysPerWeek(6),
                                        );
                                      },
                                    ),
                                    _ModernSelectionCard(
                                      title: 'Hàng ngày (7 buổi)',
                                      description:
                                          'Luyện tập kết hợp cardio & giãn cơ mỗi ngày',
                                      smartTag:
                                          'Kháng lực xen kẽ Active Recovery & giãn cơ sâu',
                                      accentColor: AppColors.accentEmerald,
                                      icon: Icons.all_inclusive_rounded,
                                      isSelected: _selectedDaysPerWeek == 7,
                                      onTap: () {
                                        setState(
                                          () => _selectedDaysPerWeek = 7,
                                        );
                                        _autoSelect(
                                          () => notifier
                                              .updateWorkoutDaysPerWeek(7),
                                        );
                                      },
                                    ),
                                  ] else if (_currentStep == 10) ...[
                                    _ModernSelectionCard(
                                      title: '30 - 45 phút',
                                      description:
                                          'Nhanh gọn, tập trung cao độ, tiết kiệm thời gian',
                                      smartTag:
                                          'Superset & nghỉ ngắn • Đốt calo & kích thích cơ nhanh',
                                      accentColor: AppColors.cyan,
                                      icon: Icons.timer_outlined,
                                      isSelected:
                                          _selectedDurationMinutes == 30 ||
                                          _selectedDurationMinutes == 45,
                                      onTap: () {
                                        setState(
                                          () => _selectedDurationMinutes = 45,
                                        );
                                        _autoSelect(
                                          () => notifier
                                              .updateSessionDurationMinutes(45),
                                        );
                                      },
                                    ),
                                    _ModernSelectionCard(
                                      title: '45 - 60 phút',
                                      description:
                                          'Thời lượng vàng chuẩn khoa học phát triển cơ bắp',
                                      badge: 'Khuyên dùng',
                                      smartTag:
                                          '4-6 bài tập chính • Không cạn kiệt Glycogen & Cortisol',
                                      accentColor: AppColors.accentBlue,
                                      icon: Icons.timer_rounded,
                                      isSelected:
                                          _selectedDurationMinutes == 60,
                                      onTap: () {
                                        setState(
                                          () => _selectedDurationMinutes = 60,
                                        );
                                        _autoSelect(
                                          () => notifier
                                              .updateSessionDurationMinutes(60),
                                        );
                                      },
                                    ),
                                    _ModernSelectionCard(
                                      title: '60 - 90 phút',
                                      description:
                                          'Tập luyện chuyên sâu với đầy đủ bài phụ & giãn cơ',
                                      smartTag:
                                          'Khối lượng tạ lớn • Nghỉ giữa hiệp 2-3 phút chuẩn sức mạnh',
                                      accentColor: AppColors.accentAmber,
                                      icon: Icons.hourglass_bottom_rounded,
                                      isSelected:
                                          _selectedDurationMinutes == 75 ||
                                          _selectedDurationMinutes == 90,
                                      onTap: () {
                                        setState(
                                          () => _selectedDurationMinutes = 75,
                                        );
                                        _autoSelect(
                                          () => notifier
                                              .updateSessionDurationMinutes(75),
                                        );
                                      },
                                    ),
                                    _ModernSelectionCard(
                                      title: 'Trên 90 phút',
                                      description:
                                          'Khối lượng tạ lớn & thời gian nghỉ dài giữa các hiệp',
                                      smartTag:
                                          'Powerlifting / Vận động viên • Khối lượng Volume tối đa',
                                      accentColor: AppColors.accentEmerald,
                                      icon: Icons.schedule_rounded,
                                      isSelected:
                                          _selectedDurationMinutes != null &&
                                          _selectedDurationMinutes! > 90,
                                      onTap: () {
                                        setState(
                                          () => _selectedDurationMinutes = 100,
                                        );
                                        _autoSelect(
                                          () => notifier
                                              .updateSessionDurationMinutes(
                                                100,
                                              ),
                                        );
                                      },
                                    ),
                                  ] else if (_currentStep == 11) ...[
                                    _AiPlanOptimizationSummary(
                                      profile: profile,
                                    ),
                                  ],
                                ],
                              ),
                            )),
              ),

              // Bottom Button for non-auto-advancing steps
              if (_currentStep == 1) ...[
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _validateAndNextNickname,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.surfaceNested,
                    disabledForegroundColor: AppColors.textDisabled,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Tiếp tục',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ] else if (_currentStep == 3 ||
                  _currentStep == 4 ||
                  _currentStep == 5) ...[
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _nextStep,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.surfaceNested,
                    disabledForegroundColor: AppColors.textDisabled,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Tiếp tục',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ] else if (_currentStep == 11) ...[
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _isSubmitting ? null : _finishHealthProfile,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.surfaceNested,
                    disabledForegroundColor: AppColors.textDisabled,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.arrow_forward_rounded, size: 20),
                  label: Text(
                    _isSubmitting
                        ? 'Đang lưu hồ sơ...'
                        : 'Tiếp tục: Chọn thiết bị tập',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],

              // Step Progress at the very bottom in pure white
              _buildBottomStepProgress(colors, profile),
            ],
          ),
        ),
      ),
    );
  }
}

class _BirthYearWheelPicker extends StatefulWidget {
  const _BirthYearWheelPicker({
    required this.selectedYear,
    required this.minYear,
    required this.maxYear,
    required this.onYearChanged,
  });

  final int selectedYear;
  final int minYear;
  final int maxYear;
  final ValueChanged<int> onYearChanged;

  @override
  State<_BirthYearWheelPicker> createState() => _BirthYearWheelPickerState();
}

class _BirthYearWheelPickerState extends State<_BirthYearWheelPicker> {
  late FixedExtentScrollController _controller;

  @override
  void initState() {
    super.initState();
    final initialIndex = (widget.selectedYear - widget.minYear).clamp(
      0,
      widget.maxYear - widget.minYear,
    );
    _controller = FixedExtentScrollController(initialItem: initialIndex);
  }

  @override
  void didUpdateWidget(covariant _BirthYearWheelPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedYear != widget.selectedYear) {
      final targetIndex = (widget.selectedYear - widget.minYear).clamp(
        0,
        widget.maxYear - widget.minYear,
      );
      if (_controller.hasClients && _controller.selectedItem != targetIndex) {
        _controller.jumpToItem(targetIndex);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalCount = widget.maxYear - widget.minYear + 1;

    return SizedBox(
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Center highlight capsule pill matching VieGym Design System
          Container(
            height: 48,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primaryBorder, width: 1.5),
            ),
          ),
          ListWheelScrollView.useDelegate(
            controller: _controller,
            itemExtent: 44,
            perspective: 0.0025,
            diameterRatio: 2.0,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) {
              final year = widget.minYear + index;
              HapticFeedback.selectionClick();
              widget.onYearChanged(year);
            },
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: totalCount,
              builder: (context, index) {
                final year = widget.minYear + index;
                final isSelected = year == widget.selectedYear;
                return Center(
                  child: Text(
                    '$year',
                    style: TextStyle(
                      fontSize: isSelected ? 24 : 16,
                      fontWeight: isSelected
                          ? FontWeight.w900
                          : FontWeight.w500,
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                      letterSpacing: isSelected ? 0.5 : 0.0,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Gender card — tall vertical card, used 2-per-row in step 2.
/// [accentColor] drives the selected-state highlight and ripple.
class _GenderCard extends StatefulWidget {
  const _GenderCard({
    required this.label,
    required this.sublabel,
    this.tag,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.accentColor, // NEW — accent per gender option
  });

  final String label;
  final String sublabel;
  final String? tag;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? accentColor;

  @override
  State<_GenderCard> createState() => _GenderCardState();
}

class _GenderCardState extends State<_GenderCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor ?? AppColors.primary;
    final accentSoft = accent.withValues(alpha: 0.12);
    final accentBorder = accent.withValues(alpha: 0.28);
    final accentIconBg = accent.withValues(alpha: 0.16);
    final iconColorUnselected = accent.withValues(alpha: 0.55);

    return AnimatedScale(
      scale: _isPressed ? 0.975 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: widget.isSelected ? accentSoft : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color:
                widget.isSelected ? accentBorder : AppColors.borderDefault,
            width: widget.isSelected ? 1.5 : 1.0,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          splashColor: accent.withValues(alpha: 0.14),
          highlightColor: accent.withValues(alpha: 0.07),
          onHighlightChanged: (v) => setState(() => _isPressed = v),
          onTap: widget.onTap,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 12,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        width: 52,
                        height: 52,
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        decoration: BoxDecoration(
                          color: widget.isSelected
                              ? accentIconBg
                              : AppColors.surfaceNested,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: widget.isSelected
                                ? accentBorder
                                : AppColors.borderDefault,
                          ),
                        ),
                        child: Icon(
                          widget.icon,
                          size: 28,
                          color: widget.isSelected
                              ? accent
                              : iconColorUnselected,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.sublabel,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (widget.tag != null) ...[
                        const SizedBox(height: 8),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: widget.isSelected
                                ? accentIconBg
                                : AppColors.surfaceNested,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: widget.isSelected
                                  ? accentBorder
                                  : AppColors.borderDefault,
                            ),
                          ),
                          child: Text(
                            widget.tag!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: widget.isSelected
                                  ? accent
                                  : AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // Selected check dot — animated, uses accent color
              AnimatedPositioned(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                top: 10,
                right: 10,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: widget.isSelected ? 1.0 : 0.0,
                  child: AnimatedScale(
                    scale: widget.isSelected ? 1.0 : 0.6,
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutBack,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
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
}

class _DirectNumericInputCard extends StatefulWidget {
  const _DirectNumericInputCard({
    required this.label,
    required this.unit,
    required this.icon,
    required this.controller,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.focusNode,
    this.textInputAction,
    this.onEditingComplete,
  });

  final String label;
  final String unit;
  final IconData icon;
  final TextEditingController controller;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final VoidCallback? onEditingComplete;

  @override
  State<_DirectNumericInputCard> createState() =>
      _DirectNumericInputCardState();
}

class _DirectNumericInputCardState extends State<_DirectNumericInputCard> {
  FocusNode? _internalFocusNode;
  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _effectiveFocusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {});
    if (_effectiveFocusNode.hasFocus) {
      widget.controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: widget.controller.text.length,
      );
    } else {
      final parsed = int.tryParse(widget.controller.text);
      if (parsed == null || parsed < widget.min || parsed > widget.max) {
        final clamped = (parsed ?? widget.value).clamp(widget.min, widget.max);
        widget.controller.text = '$clamped';
        widget.onChanged(clamped);
      }
    }
  }

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_handleFocusChange);
    _internalFocusNode?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _DirectNumericInputCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value &&
        widget.controller.text != '${widget.value}' &&
        !_effectiveFocusNode.hasFocus) {
      widget.controller.text = '${widget.value}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = _effectiveFocusNode.hasFocus;

    return GestureDetector(
      onTap: () => _effectiveFocusNode.requestFocus(),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isFocused
                ? AppColors.borderStrong
                : AppColors.borderDefault,
            width: 1.0,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceNested,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        widget.icon,
                        size: 18,
                        color: isFocused
                            ? AppColors.textPrimary
                            : AppColors.iconSecondary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceNested,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderDefault),
                  ),
                  child: Text(
                    '${widget.min} – ${widget.max} ${widget.unit}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surfaceInput,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isFocused
                      ? AppColors.borderStrong
                      : AppColors.borderDefault,
                  width: 1.0,
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IntrinsicWidth(
                      child: TextField(
                        focusNode: _effectiveFocusNode,
                        controller: widget.controller,
                        keyboardType: TextInputType.number,
                        cursorColor: AppColors.textPrimary,
                        textInputAction:
                            widget.textInputAction ?? TextInputAction.done,
                        onEditingComplete: widget.onEditingComplete,
                        textAlign: TextAlign.center,
                        onTap: () {
                          widget.controller.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: widget.controller.text.length,
                          );
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: -1.0,
                          height: 1.1,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          hintText: '${widget.value}',
                          hintStyle: const TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        onChanged: (text) {
                          final parsed = int.tryParse(text);
                          if (parsed != null &&
                              parsed >= widget.min &&
                              parsed <= widget.max) {
                            widget.onChanged(parsed);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceNested,
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: AppColors.borderDefault,
                        ),
                      ),
                      child: Text(
                        widget.unit,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isFocused
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                isFocused ? 'Đang chỉnh sửa...' : 'Chạm để thay đổi',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: isFocused
                      ? AppColors.textSecondary
                      : AppColors.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BmiSpectrumBar extends StatelessWidget {
  const _BmiSpectrumBar({required this.bmi});

  final double bmi;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final (label, color) = bmi < 18.5
        ? ('Thiếu cân', AppColors.warning)
        : (bmi < 24.9
              ? ('Chuẩn cân đối', AppColors.success)
              : (bmi < 29.9
                    ? ('Thừa cân nhẹ', AppColors.warning)
                    : ('Cần giảm cân', AppColors.error)));

    final normalized = ((bmi - 15.0) / (35.0 - 15.0)).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.speed_rounded, size: 16, color: color),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Chỉ số BMI & Thể trạng',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      bmi.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 35,
                          child: Container(
                            height: 8,
                            color: AppColors.warning.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          flex: 64,
                          child: Container(height: 8, color: AppColors.success),
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          flex: 49,
                          child: Container(height: 8, color: AppColors.warning),
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          flex: 51,
                          child: Container(height: 8, color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: (totalWidth * normalized - 7).clamp(
                      0.0,
                      totalWidth - 14,
                    ),
                    top: -4,
                    child: Container(
                      width: 14,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '< 18.5',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
              Text(
                '18.5 – 24.9 Chuẩn',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accentEmerald,
                ),
              ),
              Text(
                '25.0 – 29.9',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
              Text(
                '≥ 30.0',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Versatile selection card for onboarding steps 6–10.
/// Each card can have a unique [accentColor] that drives ALL visual states:
/// - Unselected: neutral surface, dim accent icon hint.
/// - Selected: accentSoft background, accentBorder border, accent icon/badge/check.
/// - Press: 0.975 scale, accent ripple.
class _ModernSelectionCard extends StatefulWidget {
  const _ModernSelectionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.badge,
    this.smartTag,
    this.accentColor,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final String? badge;
  final String? smartTag;

  /// Per-option accent color from AppColors tokens.
  /// If null, falls back to AppColors.primary (VieGym Brand Red).
  final Color? accentColor;

  @override
  State<_ModernSelectionCard> createState() => _ModernSelectionCardState();
}

class _ModernSelectionCardState extends State<_ModernSelectionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor ?? AppColors.primary;

    // All derived from a single accentColor token — no hard-coded colors.
    final accentSoft = accent.withValues(alpha: 0.12);
    final accentBorder = accent.withValues(alpha: 0.28);
    final accentIconBg = accent.withValues(alpha: 0.16);
    final iconColorUnselected = accent.withValues(alpha: 0.60);

    return AnimatedScale(
      scale: _isPressed ? 0.975 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        margin: const EdgeInsets.only(bottom: 10),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: widget.isSelected ? accentSoft : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: widget.isSelected ? accentBorder : AppColors.borderDefault,
            width: widget.isSelected ? 1.5 : 1.0,
          ),
        ),
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (v) => setState(() => _isPressed = v),
          borderRadius: BorderRadius.circular(18),
          splashColor: accent.withValues(alpha: 0.14),
          highlightColor: accent.withValues(alpha: 0.07),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon container
                AnimatedContainer(
                  width: 44,
                  height: 44,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    color: widget.isSelected
                        ? accentIconBg
                        : AppColors.surfaceNested,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.isSelected
                          ? accentBorder
                          : AppColors.borderDefault,
                    ),
                  ),
                  child: Icon(
                    widget.icon,
                    size: 22,
                    color:
                        widget.isSelected ? accent : iconColorUnselected,
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
                              widget.title,
                              style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (widget.badge != null) ...[
                            const SizedBox(width: 6),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutCubic,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: widget.isSelected
                                    ? accentIconBg
                                    : AppColors.surfaceNested,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: widget.isSelected
                                      ? accentBorder
                                      : AppColors.borderDefault,
                                ),
                              ),
                              child: Text(
                                widget.badge!,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: widget.isSelected
                                      ? accent
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                      if (widget.smartTag != null) ...[
                        const SizedBox(height: 6),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: widget.isSelected
                                ? accentIconBg
                                : AppColors.surfaceNested,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: widget.isSelected
                                  ? accentBorder
                                  : AppColors.borderDefault,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome_rounded,
                                size: 11,
                                color: widget.isSelected
                                    ? accent
                                    : AppColors.iconTertiary,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  widget.smartTag!,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: widget.isSelected
                                        ? accent
                                        : AppColors.textMuted,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Check indicator — animated color transition
                AnimatedContainer(
                  width: 22,
                  height: 22,
                  margin: const EdgeInsets.only(top: 2),
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isSelected ? accent : Colors.transparent,
                    border: Border.all(
                      color: widget.isSelected
                          ? accent
                          : AppColors.borderDefault,
                      width: 1.5,
                    ),
                  ),
                  child: widget.isSelected
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
      ),
    );
  }
}

class _AiPlanOptimizationSummary extends StatelessWidget {
  const _AiPlanOptimizationSummary({required this.profile});

  final HealthProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderDefault),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Badge — AI identity uses Violet, not Brand Red
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.violetSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.violet,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'AI TỐI ƯU HÓA LỘ TRÌNH',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppColors.violet,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 4 Metric Badges
          Row(
            children: [
              Expanded(
                child: _SummaryMetricItem(
                  icon: Icons.calendar_month_rounded,
                  label: 'Tần suất',
                  value: '${profile.workoutDaysPerWeek} buổi/tuần',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryMetricItem(
                  icon: Icons.timer_rounded,
                  label: 'Thời lượng',
                  value: '${profile.sessionDurationMinutes} phút/buổi',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _SummaryMetricItem(
                  icon: Icons.local_fire_department_rounded,
                  label: 'Năng lượng TDEE',
                  value: '${profile.tdee} kcal/ngày',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryMetricItem(
                  icon: Icons.track_changes_rounded,
                  label: 'Mục tiêu',
                  value: '${profile.weightKg} ➔ ${profile.targetWeightKg} kg',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Highlight Points
          const _SummaryBulletPoint(
            icon: Icons.fitness_center_rounded,
            title: 'Lịch tập tối ưu theo tuần',
            description:
                'Tự động phân chia nhóm cơ và thời gian nghỉ phục hồi hợp lý.',
          ),
          const SizedBox(height: 12),
          _SummaryBulletPoint(
            icon: Icons.restaurant_rounded,
            title: 'Thực đơn chuẩn Macro & Calo',
            description:
                'Khẩu phần dinh dưỡng được tính toán theo mục tiêu ${profile.goal.label}.',
          ),
          const SizedBox(height: 12),
          const _SummaryBulletPoint(
            icon: Icons.auto_awesome_rounded,
            title: 'Huấn luyện viên AI 24/7',
            description:
                'Theo dõi tiến độ, thay thế bài tập và giải đáp mọi thắc mắc của bạn.',
            iconColor: AppColors.violet,
            iconBgColor: AppColors.violetSoft,
          ),
        ],
      ),
    );
  }
}

class _SummaryMetricItem extends StatelessWidget {
  const _SummaryMetricItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceNested,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: AppColors.iconSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryBulletPoint extends StatelessWidget {
  const _SummaryBulletPoint({
    required this.icon,
    required this.title,
    required this.description,
    this.iconColor,
    this.iconBgColor,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color? iconColor;
  final Color? iconBgColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconBgColor ?? AppColors.surfaceNested,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: iconColor ?? AppColors.iconSecondary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
