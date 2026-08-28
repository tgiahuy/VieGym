import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viegym/features/profile/application/progress_controller.dart';
import 'package:viegym/features/profile/presentation/health_profile_edit_screen.dart';
import 'package:viegym/features/profile/presentation/profile_screen.dart';
import 'package:viegym/features/profile/presentation/progress_screen.dart';
import 'package:viegym/features/profile/presentation/settings_screen.dart';

void main() {
  group('ProgressController tests', () {
    test('Calculates 1RM accurately according to Epley formula', () {
      expect(ProgressController.calculate1Rm(100.0, 1), 100.0);
      expect(ProgressController.calculate1Rm(100.0, 6), 120.0);
      expect(ProgressController.calculate1Rm(80.0, 10), closeTo(106.67, 0.01));
    });

    test('ProgressController logs weight properly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(progressProvider.notifier);
      final initialCount = container.read(progressProvider).weightLogs.length;

      notifier.logWeight(66.5);
      final updated = container.read(progressProvider).weightLogs;
      expect(updated.length, equals(initialCount + 1));
      expect(updated.first.weightKg, 66.5);
    });
  });

  group('Profile & Progress UI Widget tests', () {
    testWidgets('ProgressScreen renders overview stats, tabs, and 1RM',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProgressScreen(),
          ),
        ),
      );

      expect(find.text('Tiến độ & Thống kê'), findsOneWidget);
      expect(find.text('Tổng quan'), findsOneWidget);
      expect(find.text('Cân nặng'), findsOneWidget);
      expect(find.text('Kỷ lục & 1RM'), findsOneWidget);
      expect(find.text('Mục tiêu tuần này'), findsOneWidget);
      expect(find.textContaining('CHUỖI TẬP'), findsOneWidget);
    });

    testWidgets('HealthProfileEditScreen renders live calculated metrics and sliders',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HealthProfileEditScreen(),
          ),
        ),
      );

      expect(find.text('Chỉ số thể chất & Mục tiêu'), findsOneWidget);
      expect(find.text('BMI'), findsOneWidget);
      expect(find.text('BMR'), findsOneWidget);
      expect(find.text('TDEE (Mục tiêu)'), findsOneWidget);
      expect(find.text('Chiều cao:'), findsOneWidget);
      expect(find.text('Cân nặng:'), findsOneWidget);
      expect(find.text('Cập nhật chỉ số'), findsOneWidget);
    });

    testWidgets('SettingsScreen renders AI consent and logout button',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );

      expect(find.text('Cài đặt ứng dụng'), findsOneWidget);
      expect(find.text('Cá nhân hóa AI theo hồ sơ'), findsOneWidget);
      expect(find.text('Âm thanh đếm ngược nghỉ'), findsOneWidget);
      expect(find.text('Đăng xuất tài khoản'), findsOneWidget);
    });

    testWidgets('ProfileScreen renders user profile and menu items',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      expect(find.text('Hồ sơ cá nhân'), findsOneWidget);
      expect(find.text('Chỉ số thể chất & Thể trạng'), findsOneWidget);
      expect(find.text('Tiến độ & Thống kê tập luyện'), findsOneWidget);
      expect(find.text('Thiết bị tập luyện'), findsOneWidget);
      expect(find.text('Cài đặt ứng dụng'), findsOneWidget);
    });
  });
}
