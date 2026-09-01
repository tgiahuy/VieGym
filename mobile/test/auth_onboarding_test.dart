import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:viegym/core/network/token_storage.dart';
import 'package:viegym/features/auth/application/auth_controller.dart';
import 'package:viegym/features/auth/domain/auth_state.dart';
import 'package:viegym/features/auth/presentation/forgot_password_screen.dart';
import 'package:viegym/features/auth/presentation/login_screen.dart';
import 'package:viegym/features/auth/presentation/otp_screen.dart';
import 'package:viegym/features/auth/presentation/register_screen.dart';
import 'package:viegym/features/auth/presentation/reset_password_screen.dart';
import 'package:viegym/features/auth/presentation/splash_screen.dart';
import 'package:viegym/features/auth/presentation/welcome_screen.dart';
import 'package:viegym/features/dashboard/presentation/dashboard_screen.dart';
import 'package:viegym/features/onboarding/application/health_profile_controller.dart';
import 'package:viegym/features/onboarding/data/equipment_catalog.dart';
import 'package:viegym/features/onboarding/domain/user_profile_models.dart';
import 'package:viegym/features/onboarding/presentation/equipment_onboarding_screen.dart';
import 'package:viegym/features/onboarding/presentation/health_profile_onboarding_screen.dart';
import 'package:viegym/features/profile/presentation/account_security_screen.dart';
import 'package:viegym/shared/utils/greeting_utils.dart';
import 'package:viegym/shared/widgets/brand_icons.dart';
import 'package:viegym/shared/widgets/ruler_picker.dart';

void main() {
  group('Time-based greeting tests', () {
    test('Correctly calculates greetings according to time of day', () {
      // 04:30 -> Chào buổi tối
      expect(
        getTimeBasedGreeting(DateTime(2026, 8, 29, 4, 30)),
        'Chào buổi tối',
      );
      // 04:31 -> Chào buổi sáng
      expect(
        getTimeBasedGreeting(DateTime(2026, 8, 29, 4, 31)),
        'Chào buổi sáng',
      );
      // 08:00 -> Chào buổi sáng
      expect(
        getTimeBasedGreeting(DateTime(2026, 8, 29, 8, 0)),
        'Chào buổi sáng',
      );
      // 10:30 -> Chào buổi sáng
      expect(
        getTimeBasedGreeting(DateTime(2026, 8, 29, 10, 30)),
        'Chào buổi sáng',
      );
      // 10:31 -> Chào buổi chiều
      expect(
        getTimeBasedGreeting(DateTime(2026, 8, 29, 10, 31)),
        'Chào buổi chiều',
      );
      // 14:00 -> Chào buổi chiều
      expect(
        getTimeBasedGreeting(DateTime(2026, 8, 29, 14, 0)),
        'Chào buổi chiều',
      );
      // 18:00 -> Chào buổi chiều
      expect(
        getTimeBasedGreeting(DateTime(2026, 8, 29, 18, 0)),
        'Chào buổi chiều',
      );
      // 18:01 -> Chào buổi tối
      expect(
        getTimeBasedGreeting(DateTime(2026, 8, 29, 18, 1)),
        'Chào buổi tối',
      );
      // 22:00 -> Chào buổi tối
      expect(
        getTimeBasedGreeting(DateTime(2026, 8, 29, 22, 0)),
        'Chào buổi tối',
      );
      // 00:00 -> Chào buổi tối
      expect(
        getTimeBasedGreeting(DateTime(2026, 8, 29, 0, 0)),
        'Chào buổi tối',
      );
    });
  });
  group('AuthController tests', () {
    test('Initial state is unauthenticated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(authProvider);
      expect(state.status, AuthStatus.unauthenticated);
      expect(state.isAuthenticated, isFalse);
    });

    test('Login success updates user and authenticated status', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final success = await container
          .read(authProvider.notifier)
          .login(email: 'test@viegym.vn', password: 'password123');

      expect(success, isTrue);
      final state = container.read(authProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.user?.email, 'test@viegym.vn');
      expect(state.isAuthenticated, isTrue);
    });

    test('loginWithGoogle completes authentication and saves tokens', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final success = await container
          .read(authProvider.notifier)
          .loginWithGoogle();
      expect(success, isTrue);

      final state = container.read(authProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.user?.displayName, 'Google Athlete');
      expect(
        await container.read(tokenStorageProvider).hasRefreshToken(),
        isTrue,
      );
    });

    test(
      'loginWithFacebook completes authentication and saves tokens',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final success = await container
            .read(authProvider.notifier)
            .loginWithFacebook();
        expect(success, isTrue);

        final state = container.read(authProvider);
        expect(state.status, AuthStatus.authenticated);
        expect(state.user?.displayName, 'Facebook Athlete');
        expect(
          await container.read(tokenStorageProvider).hasRefreshToken(),
          isTrue,
        );
      },
    );

    test(
      'Register stores pending email and verifyOtp completes authentication',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final registerSuccess = await container
            .read(authProvider.notifier)
            .register(
              email: 'newuser@viegym.vn',
              password: 'password123',
              confirmPassword: 'password123',
            );

        expect(registerSuccess, isTrue);
        expect(container.read(authProvider).pendingEmail, 'newuser@viegym.vn');

        final otpSuccess = await container
            .read(authProvider.notifier)
            .verifyOtp('123456');
        expect(otpSuccess, isTrue);
        final state = container.read(authProvider);
        expect(state.status, AuthStatus.authenticated);
        expect(state.user?.email, 'newuser@viegym.vn');
      },
    );

    test('Register fails when passwords do not match', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final success = await container
          .read(authProvider.notifier)
          .register(
            email: 'newuser@viegym.vn',
            password: 'password123',
            confirmPassword: 'wrongpassword',
          );

      expect(success, isFalse);
      final state = container.read(authProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, contains('không khớp'));
    });

    test('maskEmail correctly masks username while keeping domain', () {
      expect(AuthState.maskEmail('nguyen@viegym.vn'), 'n***n@viegym.vn');
      expect(AuthState.maskEmail('ab@viegym.vn'), 'a***@viegym.vn');
      expect(AuthState.maskEmail('user@gmail.com'), 'u***r@gmail.com');
      expect(AuthState.maskEmail('invalid-email'), 'invalid-email');
    });

    test('resendOtp updates cooldown seconds and pending parameters', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final success = await container
          .read(authProvider.notifier)
          .resendOtp(email: 'test@viegym.vn', purpose: OtpPurpose.register);

      expect(success, isTrue);
      final state = container.read(authProvider);
      expect(state.pendingEmail, 'test@viegym.vn');
      expect(state.pendingPurpose, OtpPurpose.register);
      expect(state.resendCooldownSeconds, 60);
    });

    test(
      'forgotPassword sets pending verification with passwordReset purpose',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final success = await container
            .read(authProvider.notifier)
            .forgotPassword('reset@viegym.vn');

        expect(success, isTrue);
        final state = container.read(authProvider);
        expect(state.pendingEmail, 'reset@viegym.vn');
        expect(state.pendingPurpose, OtpPurpose.passwordReset);
        expect(state.isPendingVerification, isTrue);
      },
    );

    test('resetPassword validates matching and min length', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Mismatched
      final failMismatch = await container
          .read(authProvider.notifier)
          .resetPassword(
            email: 'user@viegym.vn',
            newPassword: 'password123',
            confirmPassword: 'wrongpassword',
          );
      expect(failMismatch, isFalse);
      expect(container.read(authProvider).errorMessage, contains('không khớp'));

      // Short password
      final failShort = await container
          .read(authProvider.notifier)
          .resetPassword(
            email: 'user@viegym.vn',
            newPassword: '123',
            confirmPassword: '123',
          );
      expect(failShort, isFalse);
      expect(
        container.read(authProvider).errorMessage,
        contains('ít nhất 6 ký tự'),
      );

      // Success
      final success = await container
          .read(authProvider.notifier)
          .resetPassword(
            email: 'user@viegym.vn',
            newPassword: 'newpassword123',
            confirmPassword: 'newpassword123',
          );
      expect(success, isTrue);
      expect(container.read(authProvider).status, AuthStatus.unauthenticated);
    });

    test(
      'changePassword validates fields and updates authenticated state',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final failEmpty = await container
            .read(authProvider.notifier)
            .changePassword(
              currentPassword: '',
              newPassword: 'password123',
              confirmPassword: 'password123',
            );
        expect(failEmpty, isFalse);

        final success = await container
            .read(authProvider.notifier)
            .changePassword(
              currentPassword: 'oldPassword123',
              newPassword: 'newPassword123',
              confirmPassword: 'newPassword123',
            );
        expect(success, isTrue);
        expect(container.read(authProvider).status, AuthStatus.authenticated);
      },
    );
  });

  group('HealthProfile calculation tests', () {
    test('Calculates BMI, BMR, and TDEE correctly for standard profile', () {
      const profile = HealthProfile(
        gender: BiologicalGender.male,
        heightCm: 175,
        weightKg: 70,
        goal: FitnessGoal.gainMuscle,
        activityLevel: ActivityLevel.active,
        experience: TrainingExperience.intermediate,
      );

      // BMI = 70 / (1.75 * 1.75) = 22.857
      expect(profile.bmi, closeTo(22.86, 0.05));

      // BMR (Mifflin) = 10 * 70 + 6.25 * 175 - 5 * 25 + 5 = 700 + 1093.75 - 125 + 5 = 1673.75 -> 1674
      expect(profile.bmr, equals(1674));

      // TDEE = round(1674 * 1.55) + 300 = 2595 + 300 = 2895
      expect(profile.tdee, equals((1674 * 1.55).round() + 300));
    });

    test(
      'BMI Category correctly classifies underweight, normal, pre-obese, and obese',
      () {
        // Underweight (< 18.5)
        const underweight = HealthProfile(heightCm: 175, weightKg: 50);
        expect(underweight.bmiCategory, 'Nhẹ cân');

        // Normal (18.5 - 24.9)
        const normal = HealthProfile(heightCm: 175, weightKg: 68);
        expect(normal.bmiCategory, 'Bình thường');

        // Pre-obese (25.0 - 29.9)
        const preObese = HealthProfile(heightCm: 175, weightKg: 80);
        expect(preObese.bmiCategory, 'Tiền béo phì');

        // Obese (>= 30.0)
        const obese = HealthProfile(heightCm: 175, weightKg: 100);
        expect(obese.bmiCategory, 'Béo phì');
      },
    );

    test('BMR calculations for Female and Non-binary / Other offsets', () {
      // Base: 10 * 60 + 6.25 * 165 - 5 * 25 = 600 + 1031.25 - 125 = 1506.25
      // Female offset: base - 161 = 1345.25 -> 1345
      const female = HealthProfile(
        gender: BiologicalGender.female,
        heightCm: 165,
        weightKg: 60,
        age: 25,
      );
      expect(female.bmr, 1345);

      // Other / Non-binary offset: base - 78 = 1428.25 -> 1428
      const nonBinary = HealthProfile(
        gender: BiologicalGender.other,
        heightCm: 165,
        weightKg: 60,
        age: 25,
      );
      expect(nonBinary.bmr, 1428);
    });

    test('TDEE adjusts correctly for all fitness goals', () {
      const baseProfile = HealthProfile(
        gender: BiologicalGender.male,
        heightCm: 170,
        weightKg: 70,
        age: 25,
        activityLevel: ActivityLevel.active, // 1.55 multiplier
      );
      final baseTdee = (baseProfile.bmr * 1.55).round();

      // Gain muscle (+300)
      expect(
        baseProfile.copyWith(goal: FitnessGoal.gainMuscle).tdee,
        baseTdee + 300,
      );

      // Lose fat (-400)
      expect(
        baseProfile.copyWith(goal: FitnessGoal.loseFat).tdee,
        baseTdee - 400,
      );

      // Build strength (+150)
      expect(
        baseProfile.copyWith(goal: FitnessGoal.buildStrength).tdee,
        baseTdee + 150,
      );

      // Maintain (0)
      expect(baseProfile.copyWith(goal: FitnessGoal.maintain).tdee, baseTdee);
    });

    test('weightDifference calculates correct target offset', () {
      const cuttingProfile = HealthProfile(weightKg: 80, targetWeightKg: 72);
      expect(cuttingProfile.weightDifference, -8);

      const bulkingProfile = HealthProfile(weightKg: 65, targetWeightKg: 70);
      expect(bulkingProfile.weightDifference, 5);
    });

    test('BMR adjusts correctly when age changes', () {
      const profile20 = HealthProfile(
        gender: BiologicalGender.male,
        age: 20,
        heightCm: 175,
        weightKg: 70,
      );
      const profile30 = HealthProfile(
        gender: BiologicalGender.male,
        age: 30,
        heightCm: 175,
        weightKg: 70,
      );

      // Difference should be 5 * (30 - 20) = 50 kcal
      expect(profile20.bmr - profile30.bmr, equals(50));
    });
  });

  group('UserEquipmentController tests', () {
    test('Applies presets and toggles individual equipment correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(userEquipmentProvider.notifier);
      notifier.applyPreset(EquipmentPresets.homeDumbbell);

      expect(
        container.read(userEquipmentProvider),
        containsAll(['db', 'bench', 'bw', 'band']),
      );
      expect(container.read(userEquipmentProvider).contains('bb'), isFalse);

      notifier.toggleEquipment('bb');
      expect(container.read(userEquipmentProvider).contains('bb'), isTrue);

      notifier.toggleEquipment('bb');
      expect(container.read(userEquipmentProvider).contains('bb'), isFalse);
    });
  });

  group('Auth & Onboarding UI Widget tests', () {
    testWidgets('WelcomeScreen renders brand logo, title, and action buttons', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: WelcomeScreen())),
      );

      expect(find.byType(VieGymLogo), findsOneWidget);
      expect(find.text('VIEGYM'), findsOneWidget);
      expect(find.textContaining('Tập thông minh.'), findsOneWidget);
      expect(find.text('Bắt đầu ngay'), findsOneWidget);
      expect(find.text('Bạn đã có tài khoản?'), findsOneWidget);
    });

    testWidgets('RulerPicker renders label, value, unit, and adjust buttons', (
      tester,
    ) async {
      var currentValue = 170;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return RulerPicker(
                  label: 'Chiều cao',
                  min: 130,
                  max: 220,
                  unit: 'cm',
                  value: currentValue,
                  onChanged: (val) {
                    setState(() => currentValue = val);
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Chiều cao'), findsOneWidget);
      expect(find.text('170'), findsAtLeast(1));
      expect(find.text('cm'), findsOneWidget);

      // Tap the add button
      await tester.tap(find.byIcon(Icons.add_circle_outline_rounded));
      await tester.pumpAndSettle();

      expect(currentValue, equals(171));
    });

    testWidgets(
      'RulerPicker renders properly across screen widths (320px to 430px) without overflow',
      (tester) async {
        for (final width in [320.0, 375.0, 390.0, 430.0]) {
          tester.view.physicalSize = Size(width, 800);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() => tester.view.resetPhysicalSize());

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      RulerPicker(
                        label: 'Chiều cao',
                        min: 130,
                        max: 220,
                        unit: 'cm',
                        value: 200,
                        onChanged: (_) {},
                      ),
                      const SizedBox(height: 16),
                      RulerPicker(
                        label: 'Cân nặng',
                        min: 35,
                        max: 160,
                        unit: 'kg',
                        value: 99,
                        onChanged: (_) {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );

          expect(find.text('200'), findsAtLeast(1));
          expect(find.text('cm'), findsOneWidget);
          expect(find.text('99'), findsAtLeast(1));
          expect(find.text('kg'), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
      },
    );

    testWidgets(
      'HealthProfileOnboardingScreen renders 11-step flow including frequency and plan optimization',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: HealthProfileOnboardingScreen()),
          ),
        );

        // Step 1: Nickname
        expect(find.text('Bước 1 / 11'), findsOneWidget);
        expect(find.text('Bạn muốn được gọi là gì?'), findsOneWidget);

        // Try empty submission -> validation error
        await tester.tap(find.text('Tiếp tục'));
        await tester.pumpAndSettle();
        expect(find.text('Vui lòng nhập biệt danh của bạn'), findsOneWidget);

        // Enter Nickname 'Huy'
        await tester.enterText(find.byType(TextField), '  Huy  ');
        await tester.tap(find.text('Tiếp tục'));
        await tester.pumpAndSettle();

        // Step 2: Gender
        expect(find.text('Bước 2 / 11'), findsOneWidget);
        expect(find.text('Giới tính sinh học?'), findsOneWidget);

        // Test Back button -> preserves 'Huy' in Step 1
        await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
        await tester.pumpAndSettle();
        expect(find.text('Bạn muốn được gọi là gì?'), findsOneWidget);
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller?.text,
          equals('Huy'),
        );

        // Advance to Step 2 again
        await tester.tap(find.text('Tiếp tục'));
        await tester.pumpAndSettle();

        // Tap Male to auto advance to Step 3
        await tester.tap(find.text('Nam'));
        await tester.pump(const Duration(milliseconds: 250));
        await tester.pumpAndSettle();

        // Step 3: Birth Year / Age
        expect(find.text('Bước 3 / 11'), findsOneWidget);
        expect(
          find.text(
            'Tuyệt vời! Chúng tôi sẽ tạo lịch tập tốt nhất dựa trên thông tin của bạn.',
          ),
          findsOneWidget,
        );
        expect(find.text('2001'), findsAtLeast(1));

        // Tap Next (Tiếp tục) to advance to Step 4
        await tester.tap(find.text('Tiếp tục'));
        await tester.pumpAndSettle();

        // Step 4: Height & Current Weight
        expect(find.text('Bước 4 / 11'), findsOneWidget);
        expect(find.text('Chiều cao & Cân nặng'), findsOneWidget);
        expect(find.text('170'), findsAtLeast(1));
        expect(find.text('cm'), findsOneWidget);
        expect(find.text('65'), findsAtLeast(1));
        expect(find.text('kg'), findsAtLeast(1));

        // Tap Next to advance to Step 5 (Target Weight)
        await tester.tap(find.text('Tiếp tục'));
        await tester.pumpAndSettle();

        // Step 5: Target Weight
        expect(find.text('Bước 5 / 11'), findsOneWidget);
        expect(find.text('Cân nặng mục tiêu'), findsOneWidget);
        expect(
          find.text('Bạn muốn hướng tới cân nặng bao nhiêu?'),
          findsOneWidget,
        );
        expect(find.text('Duy trì cân nặng'), findsOneWidget);

        // Tap Next to advance to Step 6 (Fitness Goal)
        await tester.tap(find.text('Tiếp tục'));
        await tester.pumpAndSettle();

        // Step 6: Fitness Goal
        expect(find.text('Bước 6 / 11'), findsOneWidget);
        expect(find.text('Mục tiêu chính của bạn?'), findsOneWidget);
        await tester.tap(find.text('Tăng cơ nạc (Hypertrophy)'));
        await tester.pump(const Duration(milliseconds: 250));
        await tester.pumpAndSettle();

        // Step 7: Activity Level
        expect(find.text('Bước 7 / 11'), findsOneWidget);
        expect(find.text('Mức độ vận động mỗi ngày?'), findsOneWidget);
        await tester.tap(find.text('Năng động (Active)'));
        await tester.pump(const Duration(milliseconds: 250));
        await tester.pumpAndSettle();

        // Step 8: Training Experience
        expect(find.text('Bước 8 / 11'), findsOneWidget);
        expect(find.text('Kinh nghiệm tập luyện?'), findsOneWidget);
        await tester.tap(find.text('Trung bình (Intermediate)'));
        await tester.pump(const Duration(milliseconds: 250));
        await tester.pumpAndSettle();

        // Step 9: Workout Frequency (Buổi tập 1 tuần)
        expect(find.text('Bước 9 / 11'), findsOneWidget);
        expect(find.text('Bạn sẽ tập bao nhiêu buổi 1 tuần?'), findsOneWidget);
        await tester.tap(find.text('4 - 5 buổi / tuần'));
        await tester.pump(const Duration(milliseconds: 250));
        await tester.pumpAndSettle();

        // Step 10: Session Duration (Thời lượng 1 buổi)
        expect(find.text('Bước 10 / 11'), findsOneWidget);
        expect(
          find.text('1 buổi tập của bạn kéo dài bao lâu?'),
          findsOneWidget,
        );
        await tester.tap(find.text('45 - 60 phút'));
        await tester.pump(const Duration(milliseconds: 250));
        await tester.pumpAndSettle();

        // Step 11: Plan Optimization Summary
        expect(find.text('Bước 11 / 11'), findsOneWidget);
        expect(
          find.text('Chúng tôi sẽ tối ưu lịch tập và thực đơn của bạn!'),
          findsOneWidget,
        );
        expect(find.text('AI TỐI ƯU HÓA LỘ TRÌNH'), findsOneWidget);
        expect(find.text('Tiếp tục: Chọn thiết bị tập'), findsOneWidget);
      },
    );

    testWidgets(
      'Nickname screen renders properly across screen widths (320px to 430px)',
      (tester) async {
        final screenSizes = [
          const Size(320, 640),
          const Size(375, 812),
          const Size(390, 844),
          const Size(430, 932),
        ];

        for (final size in screenSizes) {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          await tester.pumpWidget(
            const ProviderScope(
              child: MaterialApp(home: HealthProfileOnboardingScreen()),
            ),
          );

          expect(find.text('Bạn muốn được gọi là gì?'), findsOneWidget);
          expect(find.text('Biệt danh'), findsOneWidget);
          expect(find.text('Tiếp tục'), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
      },
    );

    testWidgets(
      'DashboardScreen displays personalized greeting with nickname',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              healthProfileProvider.overrideWith(
                () => _TestHealthProfileNotifier(
                  const HealthProfile(nickname: 'Huy'),
                ),
              ),
            ],
            child: const MaterialApp(home: DashboardScreen()),
          ),
        );

        final expectedGreeting = getTimeBasedGreeting();
        expect(find.text('$expectedGreeting,'), findsOneWidget);
        expect(find.text('Huy'), findsOneWidget);
        expect(find.text('Mặt trước'), findsOneWidget);

        // Tap muscle card to flip
        await tester.tap(find.text('Mặt trước'));
        await tester.pumpAndSettle();

        expect(find.text('Mặt sau'), findsOneWidget);
      },
    );

    testWidgets(
      'LoginScreen renders Biometrics (Face ID/Fingerprint), Google and Facebook buttons',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: LoginScreen())),
        );
        await tester.pumpAndSettle();

        expect(find.byType(VieGymLogo), findsOneWidget);
        expect(find.text('Đăng nhập'), findsAtLeast(1));
        expect(find.byIcon(Icons.fingerprint_rounded), findsOneWidget);
        expect(find.text('Google'), findsOneWidget);
        expect(find.text('Facebook'), findsOneWidget);
        expect(find.byType(GoogleLogo), findsOneWidget);
        expect(find.byType(FacebookLogo), findsOneWidget);

        // Tap Biometric button
        await tester.tap(find.byIcon(Icons.fingerprint_rounded));
        await tester.pumpAndSettle();

        expect(find.text('Xác thực Sinh trắc học'), findsOneWidget);
        expect(find.text('Xác thực ngay'), findsOneWidget);
      },
    );

    testWidgets(
      'RegisterScreen renders Google and Facebook social auth buttons with brand logos',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: RegisterScreen())),
        );
        await tester.pumpAndSettle();

        expect(find.byType(VieGymLogo), findsOneWidget);
        expect(find.text('Đăng ký tài khoản'), findsOneWidget);
        expect(find.text('Google'), findsOneWidget);
        expect(find.text('Facebook'), findsOneWidget);
        expect(find.byType(GoogleLogo), findsOneWidget);
        expect(find.byType(FacebookLogo), findsOneWidget);
      },
    );

    testWidgets(
      'SplashScreen renders brand logo, motto, and loading indicator',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: SplashScreen())),
        );
        // pump frames for animation
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(VieGymLogo), findsOneWidget);
        expect(find.text('VIEGYM'), findsOneWidget);
        expect(find.text('Luyện tập & Dinh dưỡng thông minh'), findsOneWidget);
        expect(find.text('Đang khởi tạo phiên làm việc...'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // advance timer without pumpAndSettle due to repeating pulse animation
        await tester.pump(const Duration(milliseconds: 650));
      },
    );

    testWidgets(
      'OtpScreen renders 6 digits input, masked email, and cooldown button',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: OtpScreen(
                email: 'nguyenvana@gmail.com',
                purpose: OtpPurpose.register,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Xác thực đăng ký'), findsOneWidget);
        expect(find.textContaining('n***a@gmail.com'), findsOneWidget);
        expect(find.byType(TextField), findsNWidgets(6));
        expect(find.text('Xác nhận mã OTP'), findsOneWidget);
        expect(find.textContaining('Gửi lại mã sau'), findsOneWidget);

        // Enter OTP digit
        await tester.enterText(find.byType(TextField).first, '1');
        await tester.pump();
      },
    );

    testWidgets('OtpScreen supports passwordReset purpose variant', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OtpScreen(
              email: 'user@viegym.vn',
              purpose: OtpPurpose.passwordReset,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Xác thực đặt lại mật khẩu'), findsOneWidget);
      expect(find.textContaining('đặt lại mật khẩu mới'), findsOneWidget);
    });

    testWidgets(
      'ForgotPasswordScreen renders email field and submits OTP request',
      (tester) async {
        tester.view.physicalSize = const Size(400, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final router = GoRouter(
          initialLocation: '/forgot',
          routes: [
            GoRoute(
              path: '/forgot',
              builder: (_, _) => const ForgotPasswordScreen(),
            ),
            GoRoute(
              path: '/otp',
              builder: (_, _) =>
                  const Scaffold(body: Text('OTP Screen Target')),
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(child: MaterialApp.router(routerConfig: router)),
        );
        await tester.pumpAndSettle();

        expect(find.text('Quên mật khẩu'), findsOneWidget);
        expect(find.text('Email đã đăng ký'), findsOneWidget);
        expect(find.text('Gửi mã xác thực OTP'), findsOneWidget);
        expect(find.text('Đăng nhập'), findsOneWidget);

        // Enter valid email and submit
        await tester.enterText(find.byType(TextFormField), 'test@viegym.vn');
        await tester.tap(find.text('Gửi mã xác thực OTP'));
        await tester.pumpAndSettle();

        expect(find.text('OTP Screen Target'), findsOneWidget);
      },
    );

    testWidgets(
      'ResetPasswordScreen renders checklist, fields, and handles password reset',
      (tester) async {
        tester.view.physicalSize = const Size(400, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final router = GoRouter(
          initialLocation: '/reset',
          routes: [
            GoRoute(
              path: '/reset',
              builder: (_, _) =>
                  const ResetPasswordScreen(email: 'user@viegym.vn'),
            ),
            GoRoute(
              path: '/login',
              builder: (_, _) =>
                  const Scaffold(body: Text('Login Screen Target')),
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(child: MaterialApp.router(routerConfig: router)),
        );
        await tester.pumpAndSettle();

        expect(find.text('Đặt lại mật khẩu'), findsAtLeast(1));
        expect(find.text('Mật khẩu mới'), findsOneWidget);
        expect(find.text('Xác nhận mật khẩu mới'), findsOneWidget);
        expect(find.text('Yêu cầu mật khẩu:'), findsOneWidget);
        expect(find.text('Tối thiểu 6 ký tự'), findsOneWidget);

        // Enter new password & confirm
        final textFields = find.byType(TextFormField);
        await tester.enterText(textFields.first, 'Secret123');
        await tester.enterText(textFields.last, 'Secret123');
        await tester.pumpAndSettle();

        await tester.tap(find.text('Đặt lại mật khẩu').last);
        await tester.pumpAndSettle();

        expect(find.text('Login Screen Target'), findsOneWidget);
      },
    );

    testWidgets(
      'AccountSecurityScreen renders Change Password, Biometric and 2FA toggles',
      (tester) async {
        tester.view.physicalSize = const Size(400, 1100);
        tester.view.devicePixelRatio = 1;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: AccountSecurityScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Bảo mật tài khoản'), findsOneWidget);
        expect(find.text('Đổi mật khẩu'), findsOneWidget);
        expect(find.text('Mật khẩu hiện tại'), findsOneWidget);
        expect(find.text('Xác thực Sinh trắc học'), findsOneWidget);
        expect(find.text('Mở khóa nhanh Face ID / Vân tay'), findsOneWidget);
        expect(find.text('Bảo vệ 2 lớp (2FA)'), findsOneWidget);
        expect(find.text('iPhone 17 Pro Max (Thiết bị này)'), findsOneWidget);

        // Toggle Biometric switch
        final switches = find.byType(Switch);
        expect(switches, findsNWidgets(2));
        await tester.tap(switches.first);
        await tester.pumpAndSettle();

        expect(
          find.textContaining('Đã tắt xác thực sinh trắc học'),
          findsOneWidget,
        );
      },
    );

    test(
      'resolveOnboardingRoute directs users according to authoritative session & onboarding status',
      () {
        expect(
          resolveOnboardingRoute(
            isAuthenticated: false,
            isHealthProfileCompleted: false,
            isEquipmentOnboardingCompleted: false,
          ),
          '/welcome',
        );

        expect(
          resolveOnboardingRoute(
            isAuthenticated: true,
            isHealthProfileCompleted: false,
            isEquipmentOnboardingCompleted: false,
          ),
          '/onboarding/health',
        );

        expect(
          resolveOnboardingRoute(
            isAuthenticated: true,
            isHealthProfileCompleted: true,
            isEquipmentOnboardingCompleted: false,
          ),
          '/onboarding/equipment',
        );

        expect(
          resolveOnboardingRoute(
            isAuthenticated: true,
            isHealthProfileCompleted: true,
            isEquipmentOnboardingCompleted: true,
          ),
          '/home',
        );
      },
    );

    testWidgets(
      'EquipmentOnboardingScreen renders presets, clear all, and completes onboarding',
      (tester) async {
        tester.view.physicalSize = const Size(400, 1100);
        tester.view.devicePixelRatio = 1;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final router = GoRouter(
          initialLocation: '/equipment',
          routes: [
            GoRoute(
              path: '/equipment',
              builder: (_, _) => const EquipmentOnboardingScreen(),
            ),
            GoRoute(
              path: '/home',
              builder: (_, _) =>
                  const Scaffold(body: Text('Home Target Screen')),
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(child: MaterialApp.router(routerConfig: router)),
        );
        await tester.pumpAndSettle();

        expect(find.text('Thiết bị của bạn'), findsOneWidget);
        expect(find.text('MẪU THIẾT LẬP NHANH'), findsOneWidget);
        expect(find.text('🏋️ Full Gym'), findsOneWidget);
        expect(find.text('🏠 Tạ đơn & Dây'), findsOneWidget);
        expect(find.text('🤸 Bodyweight'), findsOneWidget);
        expect(find.text('Bỏ chọn tất cả'), findsOneWidget);
        expect(find.text('Bỏ qua'), findsOneWidget);
        expect(find.text('Hoàn tất & Bắt đầu'), findsOneWidget);

        // Tap 'Bỏ chọn tất cả'
        await tester.tap(find.text('Bỏ chọn tất cả'));
        await tester.pumpAndSettle();
        expect(
          find.textContaining('Đã bỏ chọn tất cả thiết bị'),
          findsOneWidget,
        );

        // Tap 'Hoàn tất & Bắt đầu'
        await tester.tap(find.text('Hoàn tất & Bắt đầu'));
        await tester.pumpAndSettle();

        expect(find.text('Home Target Screen'), findsOneWidget);
      },
    );

    testWidgets('OtpScreen handles invalid OTP error gracefully', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: OtpScreen(email: 'user@viegym.vn')),
        ),
      );
      await tester.pumpAndSettle();

      // Incomplete code -> tap 'Xác nhận mã OTP'
      await tester.tap(find.text('Xác nhận mã OTP'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Vui lòng nhập đủ 6 chữ số'), findsOneWidget);
    });

    testWidgets('E2E Flow 1: Register -> OTP -> Health Profile transition', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final router = GoRouter(
        initialLocation: '/register',
        routes: [
          GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
          GoRoute(
            path: '/otp',
            builder: (_, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return OtpScreen(
                email: extra?['email'] as String? ?? 'athlete@viegym.vn',
                purpose:
                    extra?['purpose'] as OtpPurpose? ?? OtpPurpose.register,
              );
            },
          ),
          GoRoute(
            path: '/onboarding/health',
            builder: (_, _) => const HealthProfileOnboardingScreen(),
          ),
          GoRoute(
            path: '/onboarding/equipment',
            builder: (_, _) => const EquipmentOnboardingScreen(),
          ),
          GoRoute(
            path: '/home',
            builder: (_, _) =>
                const Scaffold(body: Text('Initial Dashboard Target')),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(child: MaterialApp.router(routerConfig: router)),
      );
      await tester.pumpAndSettle();

      // 1. Register step
      expect(find.text('Đăng ký tài khoản'), findsAtLeast(1));
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'athlete@viegym.vn');
      await tester.enterText(fields.at(1), 'Password123');
      await tester.enterText(fields.at(2), 'Password123');
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      // 2. OTP step
      expect(find.text('Xác thực đăng ký'), findsOneWidget);
      final pinFields = find.byType(TextField);
      for (int i = 0; i < 6; i++) {
        await tester.enterText(pinFields.at(i), '${i + 1}');
      }
      await tester.pumpAndSettle();

      // 3. Auto-verified on 6th digit -> Reached Health Profile Onboarding wizard
      expect(find.text('Bước 1 / 11'), findsOneWidget);
    });
  });
}

class _TestHealthProfileNotifier extends HealthProfileController {
  _TestHealthProfileNotifier(this._initial);
  final HealthProfile _initial;

  @override
  HealthProfile build() => _initial;
}
