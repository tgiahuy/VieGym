import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viegym/features/profile/application/progress_controller.dart';
import 'package:viegym/features/profile/presentation/equipment_preference_screen.dart';
import 'package:viegym/features/profile/presentation/health_profile_edit_screen.dart';
import 'package:viegym/features/profile/presentation/personal_records_screen.dart';
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
    testWidgets('ProgressScreen renders all 6 detailed progress sections', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: ProgressScreen())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tiến độ & Phân tích'), findsOneWidget);
      expect(find.text('TỶ LỆ HOÀN THÀNH MỤC TIÊU'), findsOneWidget);
      expect(find.text('KHỐI LƯỢNG TẢI TRỌNG (VOLUME LOAD)'), findsOneWidget);
      expect(find.text('TẬP LUYỆN & PHỤC HỒI NHÓM CƠ'), findsOneWidget);
      expect(find.text('TĂNG TIẾN SỨC MẠNH (STRENGTH PR)'), findsOneWidget);
      expect(find.text('NHẬT KÝ BUỔI TẬP GẦN ĐÂY'), findsOneWidget);
    });

    testWidgets(
      'HealthProfileEditScreen renders live calculated metrics and sliders',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: HealthProfileEditScreen()),
          ),
        );

        expect(find.text('Chỉ số thể chất & Mục tiêu'), findsOneWidget);
        expect(find.text('BMI'), findsOneWidget);
        expect(find.text('BMR'), findsOneWidget);
        expect(find.text('TDEE (Mục tiêu)'), findsOneWidget);
        expect(find.text('Chiều cao:'), findsOneWidget);
        expect(find.text('Cân nặng:'), findsOneWidget);
        expect(find.text('Cập nhật chỉ số'), findsOneWidget);
      },
    );

    testWidgets(
      'SettingsScreen renders equipment, preferences, security, AI consent and logout button',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: SettingsScreen())),
        );
        await tester.pumpAndSettle();

        expect(find.text('Cài đặt'), findsOneWidget);
        expect(find.text('Kỷ lục cá nhân (PR)'), findsOneWidget);
        expect(find.text('Thiết bị tập luyện'), findsOneWidget);
        expect(find.text('Tùy chọn & Ràng buộc cá nhân'), findsOneWidget);
        expect(find.text('Bảo mật tài khoản'), findsOneWidget);
        expect(find.text('Cá nhân hóa AI theo hồ sơ'), findsOneWidget);
        expect(find.text('Âm thanh đếm ngược nghỉ'), findsOneWidget);
        expect(find.text('Đăng xuất tài khoản'), findsOneWidget);
      },
    );

    testWidgets('PersonalRecordsScreen renders PR list and add record button', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: PersonalRecordsScreen())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Kỷ lục cá nhân (PR)'), findsOneWidget);
      expect(find.text('BẢNG KỶ LỤC CÁ NHÂN'), findsOneWidget);
      expect(find.text('AI AUTO-DETECT'), findsOneWidget);
      expect(find.text('Barbell Bench Press'), findsOneWidget);
      expect(find.text('Barbell Squat'), findsOneWidget);
    });

    testWidgets(
      'EquipmentPreferenceScreen renders illustrated equipment cards',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: EquipmentPreferenceScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Thiết bị tập luyện'), findsOneWidget);
        expect(find.text('Cấu hình nhanh theo không gian'), findsOneWidget);
        expect(find.text('Full Gym'), findsOneWidget);
        expect(find.text('Tạ đơn & Dây'), findsOneWidget);
        expect(find.text('Tạ đơn (Dumbbell)'), findsOneWidget);
      },
    );

    testWidgets('ProfileScreen renders personal fitness dashboard (Cá nhân)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: ProfileScreen())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cá nhân'), findsOneWidget);
      expect(find.text('CHỈ SỐ THỂ CHẤT'), findsOneWidget);
      expect(find.text('CÂN NẶNG'), findsOneWidget);
      expect(find.text('CHIỀU CAO'), findsOneWidget);
      expect(find.text('THỐNG KÊ TUẦN NÀY'), findsOneWidget);
      expect(find.textContaining('THỜI LƯỢNG TẬP'), findsOneWidget);
      expect(find.text('Mặt trước'), findsOneWidget);
      expect(find.text('Mặt sau'), findsOneWidget);
      expect(find.text('NHÓM CƠ TRỌNG TÂM:'), findsOneWidget);
      expect(find.textContaining('THEO NGÀY'), findsOneWidget);
      expect(find.text('Tổng cả tuần'), findsOneWidget);
      expect(find.textContaining('XU HƯỚNG CÂN NẶNG'), findsOneWidget);
    });
  });
}
