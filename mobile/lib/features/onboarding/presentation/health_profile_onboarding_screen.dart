import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/ruler_picker.dart';
import '../../../shared/widgets/selectable_card.dart';
import '../../auth/application/auth_controller.dart';
import '../application/health_profile_controller.dart';
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

  late final TextEditingController _nicknameController;
  String? _nicknameError;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(healthProfileProvider);
    final auth = ref.read(authProvider);
    final initialName = profile.nickname.isNotEmpty
        ? profile.nickname
        : (auth.user?.displayName ?? '');
    _nicknameController = TextEditingController(text: initialName);
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  void _nextStep() {
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

  void _finishHealthProfile() {
    final profile = ref.read(healthProfileProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Hồ sơ sức khỏe đã lưu! TDEE: ${profile.tdee} kcal/ngày'),
      ),
    );
    context.push('/onboarding/equipment');
  }

  void _autoSelect(VoidCallback updateAction) {
    updateAction();
    Future.delayed(const Duration(milliseconds: 180), () {
      if (mounted) {
        _nextStep();
      }
    });
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
              // Header: Back Arrow, Step Progress, and Context Badge
              Row(
                children: [
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
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Bước $_currentStep / $_totalSteps',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: colors.primary,
                              ),
                            ),
                            if (_currentStep > 1)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(99),
                                  border: Border.all(
                                    color: colors.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  _currentStep == 2
                                      ? 'Giới tính'
                                      : profile.gender.label.split(' ').first,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: colors.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: _currentStep / _totalSteps,
                          minHeight: 4,
                          borderRadius: BorderRadius.circular(99),
                          backgroundColor: colors.surfaceContainer,
                          valueColor: AlwaysStoppedAnimation(colors.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

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
                        style: TextStyle(color: colors.primary),
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
                  'Kéo thước sang 2 bên hoặc dùng nút +/- để chỉnh chính xác',
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
                                          color: colors.primary,
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
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _GenderCard(
                                            label: 'Nam',
                                            sublabel: 'Thể hình & Thể lực',
                                            icon: Icons.male_rounded,
                                            iconColor: AppColors.accentBlue,
                                            isSelected:
                                                profile.gender ==
                                                BiologicalGender.male,
                                            onTap: () => _autoSelect(
                                              () => notifier.updateGender(
                                                BiologicalGender.male,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: _GenderCard(
                                            label: 'Nữ',
                                            sublabel: 'Săn chắc & Vóc dáng',
                                            icon: Icons.female_rounded,
                                            iconColor: AppColors.primary,
                                            isSelected:
                                                profile.gender ==
                                                BiologicalGender.female,
                                            onTap: () => _autoSelect(
                                              () => notifier.updateGender(
                                                BiologicalGender.female,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    SelectableCard(
                                      title: BiologicalGender.other.label,
                                      description:
                                          BiologicalGender.other.description,
                                      icon: Icons.transgender_rounded,
                                      iconColor: AppColors.accentEmerald,
                                      isSelected:
                                          profile.gender ==
                                          BiologicalGender.other,
                                      onTap: () => _autoSelect(
                                        () => notifier.updateGender(
                                          BiologicalGender.other,
                                        ),
                                      ),
                                    ),
                                    SelectableCard(
                                      title:
                                          BiologicalGender.preferNotToSay.label,
                                      description: BiologicalGender
                                          .preferNotToSay
                                          .description,
                                      icon: Icons.security_rounded,
                                      isSelected:
                                          profile.gender ==
                                          BiologicalGender.preferNotToSay,
                                      onTap: () => _autoSelect(
                                        () => notifier.updateGender(
                                          BiologicalGender.preferNotToSay,
                                        ),
                                      ),
                                    ),
                                  ] else if (_currentStep == 4) ...[
                                    RulerPicker(
                                      label: 'Chiều cao',
                                      min: 130,
                                      max: 220,
                                      unit: 'cm',
                                      value: profile.heightCm,
                                      majorTickInterval: 10,
                                      mediumTickInterval: 5,
                                      onChanged: notifier.updateHeight,
                                    ),
                                    const SizedBox(height: 16),
                                    RulerPicker(
                                      label: 'Cân nặng hiện tại',
                                      min: 35,
                                      max: 160,
                                      unit: 'kg',
                                      value: profile.weightKg,
                                      majorTickInterval: 10,
                                      mediumTickInterval: 5,
                                      onChanged: (w) {
                                        notifier.updateWeight(w);
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: colors.surfaceContainer,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: colors.outlineVariant
                                              .withValues(alpha: 0.5),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Column(
                                            children: [
                                              Text(
                                                'Chỉ số BMI',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color:
                                                      colors.onSurfaceVariant,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                profile.bmi.toStringAsFixed(1),
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w900,
                                                  color: colors.onSurface,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            width: 1,
                                            height: 30,
                                            color: colors.outlineVariant,
                                          ),
                                          Column(
                                            children: [
                                              Text(
                                                'BMR cơ bản',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color:
                                                      colors.onSurfaceVariant,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '${profile.bmr} kcal',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w900,
                                                  color: colors.onSurface,
                                                ),
                                              ),
                                            ],
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
                                              Text(
                                                'Hiện tại: ${profile.weightKg} kg',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      colors.onSurfaceVariant,
                                                ),
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
                                                      ? AppColors.accentBlue
                                                            .withValues(
                                                              alpha: 0.15,
                                                            )
                                                      : (profile.weightDifference <
                                                                0
                                                            ? AppColors
                                                                  .accentAmber
                                                                  .withValues(
                                                                    alpha: 0.15,
                                                                  )
                                                            : AppColors
                                                                  .accentEmerald
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
                                                        ? AppColors.accentBlue
                                                        : (profile.weightDifference <
                                                                  0
                                                              ? AppColors
                                                                    .accentAmber
                                                              : AppColors
                                                                    .accentEmerald),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            '${profile.targetWeightKg} kg',
                                            style: TextStyle(
                                              fontSize: 44,
                                              fontWeight: FontWeight.w900,
                                              color: colors.primary,
                                              letterSpacing: -1.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    RulerPicker(
                                      label: 'Chọn cân nặng mục tiêu',
                                      min: 35,
                                      max: 160,
                                      unit: 'kg',
                                      value: profile.targetWeightKg,
                                      majorTickInterval: 10,
                                      mediumTickInterval: 5,
                                      onChanged: notifier.updateTargetWeight,
                                    ),
                                  ] else if (_currentStep == 6) ...[
                                    ...FitnessGoal.values.map(
                                      (goal) => SelectableCard(
                                        title: goal.label,
                                        description: goal.description,
                                        badge: goal.badge,
                                        icon: Icons.bolt_rounded,
                                        isSelected: profile.goal == goal,
                                        onTap: () => _autoSelect(
                                          () => notifier.updateGoal(goal),
                                        ),
                                      ),
                                    ),
                                  ] else if (_currentStep == 7) ...[
                                    ...ActivityLevel.values.map(
                                      (level) => SelectableCard(
                                        title: level.label,
                                        description: level.description,
                                        badge: level == ActivityLevel.active
                                            ? 'Khuyên dùng'
                                            : null,
                                        icon: Icons.directions_run_rounded,
                                        isSelected:
                                            profile.activityLevel == level,
                                        onTap: () => _autoSelect(
                                          () => notifier.updateActivityLevel(
                                            level,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ] else if (_currentStep == 8) ...[
                                    ...TrainingExperience.values.map(
                                      (exp) => SelectableCard(
                                        title: exp.label,
                                        description: exp.description,
                                        badge: exp.badge,
                                        icon: Icons.fitness_center_rounded,
                                        isSelected: profile.experience == exp,
                                        onTap: () => _autoSelect(
                                          () => notifier.updateExperience(exp),
                                        ),
                                      ),
                                    ),
                                  ] else if (_currentStep == 9) ...[
                                    SelectableCard(
                                      title: '2 - 3 buổi / tuần',
                                      description:
                                          'Thong thả, phục hồi tối đa, phù hợp người bận rộn',
                                      icon: Icons.calendar_today_rounded,
                                      isSelected:
                                          profile.workoutDaysPerWeek == 3,
                                      onTap: () => _autoSelect(
                                        () => notifier.updateWorkoutDaysPerWeek(
                                          3,
                                        ),
                                      ),
                                    ),
                                    SelectableCard(
                                      title: '4 - 5 buổi / tuần',
                                      description:
                                          'Tối ưu phát triển cơ bắp & thể lực toàn diện',
                                      badge: 'Khuyên dùng',
                                      icon: Icons.calendar_month_rounded,
                                      isSelected:
                                          profile.workoutDaysPerWeek == 4 ||
                                          profile.workoutDaysPerWeek == 5,
                                      onTap: () => _autoSelect(
                                        () => notifier.updateWorkoutDaysPerWeek(
                                          4,
                                        ),
                                      ),
                                    ),
                                    SelectableCard(
                                      title: '6 buổi / tuần',
                                      description:
                                          'Cường độ cao, phân chia chuyên sâu (Push / Pull / Legs)',
                                      badge: 'Chuyên sâu',
                                      icon: Icons.fitness_center_rounded,
                                      isSelected:
                                          profile.workoutDaysPerWeek == 6,
                                      onTap: () => _autoSelect(
                                        () => notifier.updateWorkoutDaysPerWeek(
                                          6,
                                        ),
                                      ),
                                    ),
                                    SelectableCard(
                                      title: 'Hàng ngày (7 buổi)',
                                      description:
                                          'Luyện tập kết hợp cardio & giãn cơ mỗi ngày',
                                      icon: Icons.all_inclusive_rounded,
                                      isSelected:
                                          profile.workoutDaysPerWeek == 7,
                                      onTap: () => _autoSelect(
                                        () => notifier.updateWorkoutDaysPerWeek(
                                          7,
                                        ),
                                      ),
                                    ),
                                  ] else if (_currentStep == 10) ...[
                                    SelectableCard(
                                      title: '30 - 45 phút',
                                      description:
                                          'Nhanh gọn, tập trung cao độ, tiết kiệm thời gian',
                                      icon: Icons.timer_outlined,
                                      isSelected:
                                          profile.sessionDurationMinutes ==
                                              30 ||
                                          profile.sessionDurationMinutes == 45,
                                      onTap: () => _autoSelect(
                                        () => notifier
                                            .updateSessionDurationMinutes(45),
                                      ),
                                    ),
                                    SelectableCard(
                                      title: '45 - 60 phút',
                                      description:
                                          'Thời lượng vàng chuẩn khoa học phát triển cơ bắp',
                                      badge: 'Khuyên dùng',
                                      icon: Icons.timer_rounded,
                                      isSelected:
                                          profile.sessionDurationMinutes == 60,
                                      onTap: () => _autoSelect(
                                        () => notifier
                                            .updateSessionDurationMinutes(60),
                                      ),
                                    ),
                                    SelectableCard(
                                      title: '60 - 90 phút',
                                      description:
                                          'Tập luyện chuyên sâu với đầy đủ bài phụ & giãn cơ',
                                      icon: Icons.hourglass_bottom_rounded,
                                      isSelected:
                                          profile.sessionDurationMinutes ==
                                              75 ||
                                          profile.sessionDurationMinutes == 90,
                                      onTap: () => _autoSelect(
                                        () => notifier
                                            .updateSessionDurationMinutes(75),
                                      ),
                                    ),
                                    SelectableCard(
                                      title: 'Trên 90 phút',
                                      description:
                                          'Khối lượng tạ lớn & thời gian nghỉ dài giữa các hiệp',
                                      icon: Icons.schedule_rounded,
                                      isSelected:
                                          profile.sessionDurationMinutes > 90,
                                      onTap: () => _autoSelect(
                                        () => notifier
                                            .updateSessionDurationMinutes(100),
                                      ),
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
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99),
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
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99),
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
                  onPressed: _finishHealthProfile,
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                  label: const Text(
                    'Tiếp tục: Chọn thiết bị tập',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
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
    final colors = Theme.of(context).colorScheme;
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
              color: colors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colors.primary.withValues(alpha: 0.35),
                width: 1.5,
              ),
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
                          ? colors.primary
                          : colors.onSurfaceVariant.withValues(alpha: 0.35),
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

class _GenderCard extends StatelessWidget {
  const _GenderCard({
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.iconColor,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String sublabel;
  final IconData icon;
  final Color iconColor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? iconColor
              : colors.outlineVariant.withValues(alpha: 0.6),
          width: isSelected ? 2.0 : 1.0,
        ),
      ),
      color: isSelected
          ? iconColor.withValues(alpha: 0.12)
          : colors.surfaceContainer,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
          child: Column(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: iconColor.withValues(alpha: 0.35)),
                ),
                child: Icon(icon, size: 30, color: iconColor),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sublabel,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ],
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
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: colors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'AI TỐI ƯU HÓA LỘ TRÌNH',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: colors.primary,
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
            icon: Icons.psychology_rounded,
            title: 'Huấn luyện viên AI 24/7',
            description:
                'Theo dõi tiến độ, thay thế bài tập và giải đáp mọi thắc mắc của bạn.',
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
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: colors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.onSurfaceVariant,
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
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900),
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
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: colors.primary),
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
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: colors.onSurfaceVariant,
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
