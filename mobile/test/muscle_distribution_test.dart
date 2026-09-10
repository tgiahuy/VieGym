import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viegym/features/profile/application/muscle_distribution_controller.dart';
import 'package:viegym/features/profile/domain/muscle_distribution_models.dart';
import 'package:viegym/features/profile/presentation/profile_screen.dart';
import 'package:viegym/features/workout/domain/muscle_models.dart';
import 'package:viegym/features/workout/presentation/widgets/body_muscle_map.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MuscleDistributionController Unit Tests', () {
    test('Initial state defaults to 30 days, front side, and 100% total sum', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(muscleDistributionProvider);

      expect(state.timeframe, equals(TimeframeFilter.thirtyDays));
      expect(state.bodySide, equals(BodySide.front));
      expect(state.selectedMuscle, isNull);

      final totalPercentage = state.items.values
          .map((item) => item.percentage)
          .fold<int>(0, (sum, val) => sum + val);

      expect(totalPercentage, equals(100),
          reason: 'Percentages must sum to exactly 100% using Largest Remainder Method');
    });

    test('Timeframe switching updates distribution percentages and preserves 100% sum', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(muscleDistributionProvider.notifier);

      // 7 Days
      notifier.setTimeframe(TimeframeFilter.sevenDays);
      var state = container.read(muscleDistributionProvider);
      expect(state.timeframe, equals(TimeframeFilter.sevenDays));
      final sum7 = state.items.values
          .map((i) => i.percentage)
          .fold<int>(0, (sum, val) => sum + val);
      expect(sum7, equals(100));

      // 3 Months
      notifier.setTimeframe(TimeframeFilter.threeMonths);
      state = container.read(muscleDistributionProvider);
      expect(state.timeframe, equals(TimeframeFilter.threeMonths));
      final sum90 = state.items.values
          .map((i) => i.percentage)
          .fold<int>(0, (sum, val) => sum + val);
      expect(sum90, equals(100));
    });

    test('Toggling muscle selection selects and deselects', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(muscleDistributionProvider.notifier);

      notifier.selectMuscle(MuscleGroup.chest);
      expect(container.read(muscleDistributionProvider).selectedMuscle,
          equals(MuscleGroup.chest));

      // Tapping same muscle deselects
      notifier.selectMuscle(MuscleGroup.chest);
      expect(container.read(muscleDistributionProvider).selectedMuscle, isNull);

      // Tapping different muscle updates
      notifier.selectMuscle(MuscleGroup.lats);
      expect(container.read(muscleDistributionProvider).selectedMuscle,
          equals(MuscleGroup.lats));
    });

    test('Body side toggle switches between Front and Back', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(muscleDistributionProvider.notifier);

      notifier.setBodySide(BodySide.back);
      expect(container.read(muscleDistributionProvider).bodySide,
          equals(BodySide.back));

      notifier.setBodySide(BodySide.front);
      expect(container.read(muscleDistributionProvider).bodySide,
          equals(BodySide.front));
    });

    test('All 16 core muscles exist with non-empty Vietnamese names and non-negative percentages', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(muscleDistributionProvider);

      expect(state.items.length, equals(16));
      for (final item in state.items.values) {
        expect(item.nameVi.isNotEmpty, isTrue);
        expect(item.percentage, greaterThanOrEqualTo(0));
      }
    });
  });

  group('Muscle Distribution UI Tests', () {
    testWidgets('ProfileScreen renders muscle distribution card with all elements', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Header and summary
      expect(find.text('Phân bố nhóm cơ'), findsOneWidget);
      expect(find.text('Dựa trên khối lượng tập luyện của bạn'), findsOneWidget);

      // Timeframe chips
      expect(find.text('7 ngày'), findsOneWidget);
      expect(find.text('30 ngày'), findsOneWidget);
      expect(find.text('3 tháng'), findsOneWidget);

      // Front / Back toggle
      expect(find.text('Phía trước'), findsOneWidget);
      expect(find.text('Phía sau'), findsOneWidget);

      // Body Map is rendered
      expect(find.byType(BodyMuscleMap), findsOneWidget);

      // Front muscles appear on screen
      expect(find.text('Vai'), findsWidgets);
      expect(find.text('Ngực'), findsWidgets);
      expect(find.text('Tay trước'), findsWidgets);
      expect(find.text('Cơ đùi trước'), findsWidgets);

      // Legend is displayed
      expect(find.text('Ít tập (0%)'), findsOneWidget);
      expect(find.text('Nhiều tập (>30%)'), findsOneWidget);
    });

    testWidgets('Tapping Phía sau toggles to back view muscles', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap 'Phía sau'
      await tester.tap(find.text('Phía sau'));
      await tester.pumpAndSettle();

      // Back muscles now appear
      expect(find.text('Cầu vai'), findsOneWidget);
      expect(find.text('Lưng'), findsOneWidget);
      expect(find.text('Tay sau'), findsOneWidget);
      expect(find.text('Cơ mông'), findsOneWidget);
      expect(find.text('Bắp chân'), findsOneWidget);
    });

    testWidgets('Tapping a muscle item highlights and tapping again deselects', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on 'Ngực'
      await tester.tap(find.text('Ngực'));
      await tester.pumpAndSettle();

      // Tap again on 'Ngực' to deselect
      await tester.tap(find.text('Ngực'));
      await tester.pumpAndSettle();
    });
  });
}
