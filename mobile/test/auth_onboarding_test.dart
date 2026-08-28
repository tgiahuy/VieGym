import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viegym/features/auth/application/auth_controller.dart';
import 'package:viegym/features/auth/domain/auth_state.dart';
import 'package:viegym/features/auth/presentation/welcome_screen.dart';
import 'package:viegym/features/dashboard/presentation/dashboard_screen.dart';
import 'package:viegym/features/onboarding/application/health_profile_controller.dart';
import 'package:viegym/features/onboarding/data/equipment_catalog.dart';
import 'package:viegym/features/onboarding/domain/user_profile_models.dart';
import 'package:viegym/features/onboarding/presentation/health_profile_onboarding_screen.dart';
import 'package:viegym/shared/widgets/ruler_picker.dart';

void main() {
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

      final success = await container.read(authProvider.notifier).login(
            email: 'test@viegym.vn',
            password: 'password123',
          );

      expect(success, isTrue);
      final state = container.read(authProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.user?.email, 'test@viegym.vn');
      expect(state.isAuthenticated, isTrue);
    });

    test('Register stores pending email and verifyOtp completes authentication',
        () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final registerSuccess =
          await container.read(authProvider.notifier).register(
                email: 'newuser@viegym.vn',
                password: 'password123',
                confirmPassword: 'password123',
              );

      expect(registerSuccess, isTrue);
      expect(container.read(authProvider).pendingEmail, 'newuser@viegym.vn');

      final otpSuccess =
          await container.read(authProvider.notifier).verifyOtp('123456');
      expect(otpSuccess, isTrue);
      final state = container.read(authProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.user?.email, 'newuser@viegym.vn');
    });

    test('Register fails when passwords do not match', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final success = await container.read(authProvider.notifier).register(
            email: 'newuser@viegym.vn',
            password: 'password123',
            confirmPassword: 'wrongpassword',
          );

      expect(success, isFalse);
      final state = container.read(authProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, contains('không khớp'));
    });
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

    test('TDEE adjusts correctly for cutting / fat loss goal', () {
      const profile = HealthProfile(
        gender: BiologicalGender.female,
        heightCm: 160,
        weightKg: 55,
        goal: FitnessGoal.loseFat,
        activityLevel: ActivityLevel.light,
      );

      final expectedBase = (profile.bmr * 1.375).round();
      expect(profile.tdee, equals(expectedBase - 400));
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
    testWidgets('WelcomeScreen renders brand logo, title, and action buttons',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: WelcomeScreen(),
          ),
        ),
      );

      expect(find.text('VIEGYM'), findsOneWidget);
      expect(find.textContaining('Tập thông minh.'), findsOneWidget);
      expect(find.text('Bắt đầu ngay'), findsOneWidget);
      expect(find.text('Bạn đã có tài khoản?'), findsOneWidget);
    });

    testWidgets('RulerPicker renders label, value, unit, and adjust buttons',
        (tester) async {
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

    testWidgets('RulerPicker renders properly across screen widths (320px to 430px) without overflow',
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
    });

    testWidgets('HealthProfileOnboardingScreen renders 8-step flow including Nickname and Target Weight',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HealthProfileOnboardingScreen(),
          ),
        ),
      );

      // Step 1: Nickname
      expect(find.text('Bước 1 / 8'), findsOneWidget);
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
      expect(find.text('Bước 2 / 8'), findsOneWidget);
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
      expect(find.text('Bước 3 / 8'), findsOneWidget);
      expect(
        find.text(
          'Tuyệt vời! Chúng tôi sẽ tạo lịch tập tốt nhất dựa trên chỉ số cơ thể của bạn.',
        ),
        findsOneWidget,
      );
      expect(find.text('2001'), findsAtLeast(1));

      // Tap Next (Tiếp tục) to advance to Step 4
      await tester.tap(find.text('Tiếp tục'));
      await tester.pumpAndSettle();

      // Step 4: Height & Current Weight
      expect(find.text('Bước 4 / 8'), findsOneWidget);
      expect(find.text('Chiều cao & Cân nặng'), findsOneWidget);
      expect(find.text('170'), findsAtLeast(1));
      expect(find.text('cm'), findsOneWidget);
      expect(find.text('65'), findsAtLeast(1));
      expect(find.text('kg'), findsAtLeast(1));

      // Tap Next to advance to Step 5 (Target Weight)
      await tester.tap(find.text('Tiếp tục'));
      await tester.pumpAndSettle();

      // Step 5: Target Weight
      expect(find.text('Bước 5 / 8'), findsOneWidget);
      expect(find.text('Cân nặng mục tiêu'), findsOneWidget);
      expect(find.text('Bạn muốn hướng tới cân nặng bao nhiêu?'), findsOneWidget);
      expect(find.text('Duy trì cân nặng'), findsOneWidget);
    });

    testWidgets('Nickname screen renders properly across screen widths (320px to 430px)',
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
            child: MaterialApp(
              home: HealthProfileOnboardingScreen(),
            ),
          ),
        );

        expect(find.text('Bạn muốn được gọi là gì?'), findsOneWidget);
        expect(find.text('Biệt danh'), findsOneWidget);
        expect(find.text('Tiếp tục'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('DashboardScreen displays personalized greeting with nickname',
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
          child: const MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );

      expect(find.text('Chào buổi sáng,'), findsOneWidget);
      expect(find.text('Huy'), findsOneWidget);
    });
  });
}

class _TestHealthProfileNotifier extends HealthProfileController {
  _TestHealthProfileNotifier(this._initial);
  final HealthProfile _initial;

  @override
  HealthProfile build() => _initial;
}

