import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viegym/features/workout/application/rest_timer_controller.dart';
import 'package:viegym/features/workout/application/workout_schedule_controller.dart';
import 'package:viegym/features/workout/data/exercise_catalog.dart';
import 'package:viegym/features/workout/domain/workout_models.dart';
import 'package:viegym/features/workout/presentation/exercise_detail_screen.dart';
import 'package:viegym/features/workout/presentation/widgets/rest_timer_overlay.dart';
import 'package:viegym/features/workout/presentation/workout_summary_screen.dart';

void main() {
  group('RestTimerController tests', () {
    test('Starts and adjusts rest countdown correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(restTimerProvider.notifier);
      expect(container.read(restTimerProvider).isResting, isFalse);

      notifier.startRest(seconds: 90);
      final state = container.read(restTimerProvider);
      expect(state.isResting, isTrue);
      expect(state.timeLeftSeconds, 90);
      expect(state.formattedTime, '01:30');

      notifier.adjustTime(15);
      expect(container.read(restTimerProvider).timeLeftSeconds, 105);

      notifier.adjustTime(-30);
      expect(container.read(restTimerProvider).timeLeftSeconds, 75);

      notifier.toggleMinimized();
      expect(container.read(restTimerProvider).isMinimized, isTrue);

      notifier.stopRest();
      expect(container.read(restTimerProvider).isResting, isFalse);
    });
  });

  group('WorkoutScheduleController tests', () {
    test('Adds schedule, reschedules, and marks completed', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(workoutScheduleProvider.notifier);
      final initialCount =
          container.read(workoutScheduleProvider).schedules.length;

      notifier.addSchedule(
        title: 'Full Body Test',
        targetMuscles: 'Toàn thân',
        durationMinutes: 45,
        date: '2026-08-30',
        time: '19:00',
      );

      final schedules = container.read(workoutScheduleProvider).schedules;
      expect(schedules.length, equals(initialCount + 1));
      final added = schedules.last;
      expect(added.title, 'Full Body Test');
      expect(added.status, ScheduleStatus.planned);

      notifier.markCompleted(added.id);
      final completed = container
          .read(workoutScheduleProvider)
          .schedules
          .firstWhere((s) => s.id == added.id);
      expect(completed.status, ScheduleStatus.completed);

      notifier.recordWorkoutCompletion(
        workoutName: 'Full Body Test',
        durationMinutes: 42,
        totalVolumeKg: 3600,
        completedSets: 12,
        prCount: 1,
      );

      final history = container.read(workoutScheduleProvider).history;
      expect(history.first.workoutName, 'Full Body Test');
      expect(history.first.totalVolumeKg, 3600);
    });
  });

  group('Exercise Catalog tests', () {
    test('Exercise catalog contains rich descriptions and mistakes', () {
      final benchPress = findExercise('ex1');
      expect(benchPress, isNotNull);
      expect(benchPress!.name, 'Barbell Bench Press');
      expect(benchPress.nameVi, contains('Đẩy ngực'));
      expect(benchPress.primaryMuscle, 'Ngực');
      expect(benchPress.instructions, isNotEmpty);
      expect(benchPress.commonMistakes, isNotEmpty);
    });
  });

  group('Workout UI Widget tests', () {
    testWidgets(
        'ExerciseDetailScreen renders exercise details, target and mistake cards',
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
            home: ExerciseDetailScreen(exerciseId: 'ex1'),
          ),
        ),
      );

      expect(find.text('Barbell Bench Press'), findsAtLeast(1));
      expect(find.textContaining('Đẩy ngực ngang'), findsOneWidget);
      expect(find.text('Nhóm cơ tác động'), findsOneWidget);
      expect(find.text('Những lỗi sai thường gặp'), findsOneWidget);
      expect(find.text('Hướng dẫn thực hiện'), findsOneWidget);
      expect(find.text('Tập bài này ngay'), findsOneWidget);
    });

    testWidgets('WorkoutSummaryScreen renders completion stats and buttons',
        (tester) async {
      const summaryData = WorkoutSummaryData(
        workoutId: 'w_1',
        title: 'Upper Body A',
        durationFormatted: '52:10',
        totalVolumeKg: 4200,
        completedSets: 14,
        totalSets: 14,
        prCount: 3,
      );

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: WorkoutSummaryScreen(summary: summaryData),
          ),
        ),
      );

      expect(find.textContaining('Hoàn thành'), findsOneWidget);
      expect(find.textContaining('Upper Body A'), findsOneWidget);
      expect(find.text('52:10'), findsOneWidget);
      expect(find.text('4200 kg'), findsOneWidget);
      expect(find.text('3 PR'), findsOneWidget);
      expect(find.text('Về trang tập luyện'), findsOneWidget);
      expect(find.text('Xem lịch sử buổi tập'), findsOneWidget);
    });

    testWidgets(
        'RestTimerOverlay renders countdown and action buttons when resting',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            restTimerProvider.overrideWith(() {
              return _MockRestTimerController();
            }),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  RestTimerOverlay(),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.textContaining('THỜI GIAN NGHỈ NGƠI'), findsOneWidget);
      expect(find.text('01:00'), findsOneWidget);
      expect(find.text('+15s'), findsOneWidget);
      expect(find.text('-15s'), findsOneWidget);
      expect(find.text('Tiếp tục tập ngay'), findsOneWidget);
    });
  });
}

class _MockRestTimerController extends RestTimerController {
  @override
  RestTimerState build() {
    return const RestTimerState(
      isResting: true,
      timeLeftSeconds: 60,
      totalSeconds: 60,
      isMinimized: false,
    );
  }
}
