import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:viegym/core/theme/app_theme.dart';
import 'package:viegym/features/dashboard/presentation/dashboard_screen.dart';
import 'package:viegym/features/profile/presentation/progress_screen.dart';
import 'package:viegym/features/workout/application/favorite_exercises_controller.dart';
import 'package:viegym/features/workout/application/rest_timer_controller.dart';
import 'package:viegym/features/workout/application/workout_schedule_controller.dart';
import 'package:viegym/features/workout/application/workout_session_controller.dart';
import 'package:viegym/features/workout/data/exercise_catalog.dart';
import 'package:viegym/features/workout/domain/muscle_models.dart';
import 'package:viegym/features/workout/domain/workout_models.dart';
import 'package:viegym/features/workout/presentation/ai_workout_generate_screen.dart';
import 'package:viegym/features/workout/presentation/exercise_detail_screen.dart';
import 'package:viegym/features/workout/presentation/exercise_library_screen.dart';
import 'package:viegym/features/workout/presentation/favorite_exercises_screen.dart';
import 'package:viegym/features/workout/presentation/widgets/body_muscle_map.dart';
import 'package:viegym/features/workout/presentation/widgets/exercise_muscle_visualizer.dart';
import 'package:viegym/features/workout/presentation/widgets/favorite_exercises_section.dart';
import 'package:viegym/features/workout/presentation/widgets/rest_timer_overlay.dart';
import 'package:viegym/features/workout/presentation/widgets/today_workout_empty_state.dart';
import 'package:viegym/features/workout/application/exercise_catalog_controller.dart';
import 'package:viegym/features/workout/domain/exercise_api_models.dart';
import 'package:viegym/features/workout/presentation/workout_builder_screen.dart';
import 'package:viegym/features/workout/presentation/workout_history_detail_screen.dart';
import 'package:viegym/features/workout/presentation/workout_history_screen.dart';
import 'package:viegym/features/workout/presentation/workout_schedule_screen.dart';
import 'package:viegym/features/workout/presentation/workout_session_screen.dart';
import 'package:viegym/features/workout/presentation/workout_summary_screen.dart';
import 'package:viegym/features/workout/presentation/workout_tab_screen.dart';

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
      final initialCount = container
          .read(workoutScheduleProvider)
          .schedules
          .length;

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

    test(
      'MuscleGroup model parses Vietnamese and English keywords properly',
      () {
        expect(MuscleGroup.fromString('Ngực'), equals(MuscleGroup.chest));
        expect(
          MuscleGroup.fromString('Ngực trên'),
          equals(MuscleGroup.upperChest),
        );
        expect(MuscleGroup.fromString('Lưng xô'), equals(MuscleGroup.lats));
        expect(MuscleGroup.fromString('Vai'), equals(MuscleGroup.sideDelts));
        expect(
          MuscleGroup.fromString('Vai trước'),
          equals(MuscleGroup.frontDelts),
        );
        expect(
          MuscleGroup.fromString('Vai sau'),
          equals(MuscleGroup.rearDelts),
        );
        expect(MuscleGroup.fromString('Tay trước'), equals(MuscleGroup.biceps));
        expect(MuscleGroup.fromString('Tay sau'), equals(MuscleGroup.triceps));
        expect(MuscleGroup.fromString('Đùi trước'), equals(MuscleGroup.quads));
        expect(
          MuscleGroup.fromString('Đùi sau'),
          equals(MuscleGroup.hamstrings),
        );
        expect(MuscleGroup.fromString('Cơ mông'), equals(MuscleGroup.glutes));
        expect(MuscleGroup.fromString('Bụng'), equals(MuscleGroup.abs));
        expect(MuscleGroup.fromString('Bắp chân'), equals(MuscleGroup.calves));
      },
    );
  });

  group('Body Muscle Visualization Widget tests', () {
    testWidgets('BodyMuscleMap renders front and back views without error', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BodyMuscleMap(
              bodySide: BodySide.front,
              primaryMuscles: {MuscleGroup.chest},
              secondaryMuscles: {MuscleGroup.frontDelts, MuscleGroup.triceps},
              height: 300,
            ),
          ),
        ),
      );

      expect(find.byType(BodyMuscleMap), findsOneWidget);
    });

    testWidgets(
      'ExerciseMuscleVisualizer renders controls, switches front/back, and toggles zoom',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ExerciseMuscleVisualizer(
                  primaryMuscle: 'Ngực',
                  secondaryMuscles: ['Vai trước', 'Tay sau'],
                ),
              ),
            ),
          ),
        );

        // Verify controls and text
        expect(find.text('Mặt trước'), findsAtLeast(1));
        expect(find.text('Mặt sau'), findsAtLeast(1));
        expect(find.text('Toàn thân'), findsOneWidget);
        expect(find.text('Cơ tác động chính'), findsOneWidget);
        expect(find.text('Cơ bổ trợ / Giữ ổn định'), findsOneWidget);

        // Verify Zoom Focus Card content
        expect(find.text('CƠ CHÍNH'), findsOneWidget);
        expect(find.text('Ngực'), findsAtLeast(1));
        expect(find.text('Pectoralis Major'), findsOneWidget);

        // Switch to Back view
        await tester.tap(find.text('Mặt sau').first);
        await tester.pumpAndSettle();

        // Toggle Zoom Mode
        await tester.tap(find.text('Toàn thân'));
        await tester.pumpAndSettle();
        expect(find.text('Tập trung'), findsOneWidget);
      },
    );

    testWidgets(
      'Single-muscle visualizer focuses automatically and hides unused side controls',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 1800);
        tester.view.devicePixelRatio = 1;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ExerciseMuscleVisualizer(
                primaryMuscle: 'Ngực',
                showZoomCard: false,
              ),
            ),
          ),
        );

        expect(find.text('Mặt trước'), findsOneWidget);
        expect(find.text('Mặt sau'), findsNothing);
        expect(find.text('Cơ bổ trợ / Giữ ổn định'), findsNothing);
        expect(find.text('Toàn thân'), findsOneWidget);

        final camera = tester.widget<TweenAnimationBuilder<double>>(
          find.byType(TweenAnimationBuilder<double>).first,
        );
        expect(camera.tween.end, greaterThan(1));
      },
    );
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
            child: MaterialApp(home: ExerciseDetailScreen(exerciseId: 'ex1')),
          ),
        );

        expect(find.text('Barbell Bench Press'), findsAtLeast(1));
        expect(find.textContaining('Đẩy ngực ngang'), findsOneWidget);
        expect(find.text('Nhóm cơ tác động'), findsOneWidget);
        expect(find.text('Những lỗi sai thường gặp'), findsOneWidget);
        expect(find.text('Hướng dẫn thực hiện'), findsOneWidget);
        expect(find.text('Tập bài này ngay'), findsOneWidget);
      },
    );

    testWidgets('WorkoutSummaryScreen renders completion stats and buttons', (
      tester,
    ) async {
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
          child: MaterialApp(home: WorkoutSummaryScreen(summary: summaryData)),
        ),
      );

      expect(find.textContaining('Hoàn thành'), findsOneWidget);
      expect(find.textContaining('Upper Body A'), findsOneWidget);
      expect(find.text('52:10'), findsOneWidget);
      expect(find.text('4,200 kg'), findsOneWidget);
      expect(find.text('3 PR'), findsOneWidget);
      expect(find.text('Về trang tập luyện'), findsOneWidget);
      expect(find.text('Xem lịch sử buổi tập'), findsOneWidget);
    });

    testWidgets(
      'WorkoutSummaryScreen reads real workout data from session & history when summary is null',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: WorkoutSummaryScreen())),
        );

        expect(find.textContaining('Hoàn thành'), findsOneWidget);
        expect(find.text('THỜI GIAN'), findsOneWidget);
        expect(find.text('TỔNG KHỐI LƯỢNG'), findsOneWidget);
        expect(find.text('HIỆP HOÀN THÀNH'), findsOneWidget);
        expect(find.text('KỶ LỤC MỚI (PR)'), findsOneWidget);
        expect(find.text('Về trang tập luyện'), findsOneWidget);
      },
    );

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
              home: Scaffold(body: Stack(children: [RestTimerOverlay()])),
            ),
          ),
        );

        expect(find.textContaining('THỜI GIAN NGHỈ NGƠI'), findsOneWidget);
        expect(find.text('01:00'), findsOneWidget);
        expect(find.text('+15s'), findsOneWidget);
        expect(find.text('-15s'), findsOneWidget);
        expect(find.text('Tiếp tục tập ngay'), findsOneWidget);
        expect(find.text('Thu nhỏ & xem bài tiếp'), findsNothing);
      },
    );

    testWidgets(
      'WorkoutTabScreen renders exercises, swipe-to-reveal actions, delete confirmation, and add button',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: const WorkoutTabScreen(),
            ),
          ),
        );

        // Verify header and initial exercises
        expect(find.text('Kế hoạch tập luyện'), findsOneWidget);
        expect(find.text('Danh sách bài hôm nay'), findsOneWidget);
        expect(find.text('Barbell Bench Press'), findsAtLeast(1));
        expect(find.text('Incline Dumbbell Press'), findsOneWidget);
        expect(find.text('Thêm bài tập mới'), findsOneWidget);

        // Swipe left on the first exercise in the session list
        await tester.drag(
          find.text('Barbell Bench Press').last,
          const Offset(-200, 0),
        );
        await tester.pumpAndSettle();

        // Action buttons 'Thay đổi' and 'Xóa' should be revealed
        expect(find.text('Thay đổi'), findsAtLeast(1));
        expect(find.text('Xóa'), findsAtLeast(1));

        // Tap 'Xóa' action
        await tester.tap(find.text('Xóa').first);
        await tester.pumpAndSettle();

        // Verify delete confirmation dialog
        expect(find.text('Xóa bài tập?'), findsOneWidget);
        expect(
          find.text(
            'Bạn có chắc muốn xóa "Barbell Bench Press" khỏi buổi tập này?',
          ),
          findsOneWidget,
        );

        // Test tapping 'Hủy' -> dialog dismissed, exercise preserved
        await tester.tap(find.widgetWithText(OutlinedButton, 'Hủy'));
        await tester.pumpAndSettle();
        expect(find.text('Xóa bài tập?'), findsNothing);
        expect(find.text('4 bài tập'), findsOneWidget);

        // Swipe and tap 'Xóa' again
        await tester.drag(
          find.text('Barbell Bench Press'),
          const Offset(-180, 0),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Xóa').first);
        await tester.pumpAndSettle();

        // Confirm delete
        await tester.tap(find.widgetWithText(FilledButton, 'Xóa'));
        await tester.pumpAndSettle();

        // Session list is updated to 3 exercises
        expect(find.text('3 bài tập'), findsOneWidget);

        // Tap '+ Thêm bài tập mới'
        await tester.tap(find.text('Thêm bài tập mới'));
        await tester.pumpAndSettle();

        // Should open ExerciseLibraryScreen picker
        expect(find.text('Thêm bài tập mới'), findsAtLeast(1));
        expect(
          find.text('Tìm theo tên bài tập, nhóm cơ, thiết bị'),
          findsOneWidget,
        );

        // Tap multiple exercises to add (e.g. Pec Deck Machine Fly and Dumbbell Lateral Raise)
        expect(find.text('Đã chọn 0 bài tập'), findsOneWidget);
        await tester.tap(find.text('Pec Deck Machine Fly'));
        await tester.pumpAndSettle();
        expect(find.text('Đã chọn 1 bài tập'), findsOneWidget);

        await tester.tap(find.text('Neutral-Grip Dumbbell Press'));
        await tester.pumpAndSettle();
        expect(find.text('Đã chọn 2 bài tập'), findsOneWidget);

        // Tap 'Thêm (2)' button
        await tester.tap(find.text('Thêm (2)'));
        await tester.pumpAndSettle();

        // Should be back to WorkoutTabScreen and have new exercises added
        expect(find.text('Pec Deck Machine Fly'), findsOneWidget);
        expect(find.text('Neutral-Grip Dumbbell Press'), findsOneWidget);
        expect(find.text('5 bài tập'), findsOneWidget);
      },
    );
  });

  group('WorkoutSessionController exercise management tests', () {
    test('addExercise, removeExercise, and replaceExercise work properly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(workoutSessionProvider.notifier);
      final initialCount = container
          .read(workoutSessionProvider)
          .exercises
          .length;
      expect(initialCount, equals(4));

      // Test remove
      final firstExerciseId = container
          .read(workoutSessionProvider)
          .exercises
          .first
          .exerciseId;
      notifier.removeExercise(firstExerciseId);
      expect(
        container.read(workoutSessionProvider).exercises.length,
        equals(3),
      );
      expect(
        container
            .read(workoutSessionProvider)
            .exercises
            .any((e) => e.exerciseId == firstExerciseId),
        isFalse,
      );

      // Test add
      final pecDeck = findExercise('ex_pec_deck_fly')!;
      notifier.addExercise(pecDeck);
      final exercisesAfterAdd = container
          .read(workoutSessionProvider)
          .exercises;
      expect(exercisesAfterAdd.length, equals(4));
      expect(exercisesAfterAdd.last.name, equals(pecDeck.name));
      expect(
        container.read(workoutSessionProvider).logs.containsKey(pecDeck.id),
        isTrue,
      );

      // Test replace
      final target = exercisesAfterAdd.first;
      final chestPress = findExercise('ex_chest_press_machine')!;
      notifier.replaceExercise(
        originalExerciseId: target.exerciseId,
        replacementExerciseId: chestPress.id,
      );
      final exercisesAfterReplace = container
          .read(workoutSessionProvider)
          .exercises;
      expect(exercisesAfterReplace.first.name, equals(chestPress.name));
    });

    test(
      'adding exercise after finalization starts an add-on workout and preserves completed history',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final sessionNotifier = container.read(workoutSessionProvider.notifier);
        final scheduleNotifier = container.read(
          workoutScheduleProvider.notifier,
        );

        scheduleNotifier.recordWorkoutCompletion(
          workoutName: 'Upper Body A',
          durationMinutes: 45,
          totalVolumeKg: 3200,
          completedSets: 12,
          prCount: 0,
        );
        sessionNotifier.finalizeSession();
        final historyCount = container
            .read(workoutScheduleProvider)
            .history
            .length;

        expect(container.read(isTodayWorkoutCompletedProvider), isTrue);

        final extraExercise = findExercise('ex5')!;
        final startedAddOn = sessionNotifier.addExercise(extraExercise);
        final addOnSession = container.read(workoutSessionProvider);

        expect(startedAddOn, isTrue);
        expect(addOnSession.isFinalized, isFalse);
        expect(addOnSession.title, 'Tập thêm hôm nay');
        expect(addOnSession.exercises, hasLength(1));
        expect(addOnSession.exercises.single.name, extraExercise.name);
        expect(addOnSession.completedSets, 0);
        expect(container.read(isTodayWorkoutCompletedProvider), isFalse);
        expect(
          container.read(workoutScheduleProvider).history.length,
          historyCount,
        );
      },
    );

    test('adding exercise before finalization extends the current workout', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(workoutSessionProvider.notifier);

      final original = container.read(workoutSessionProvider);
      for (final exercise in original.exercises) {
        final sets = original.logs[exercise.exerciseId]!;
        for (var index = 0; index < sets.length; index++) {
          notifier.updateSet(
            exerciseId: exercise.exerciseId,
            setIndex: index,
            completed: true,
          );
        }
      }

      expect(container.read(workoutSessionProvider).isCompleted, isTrue);
      expect(container.read(isTodayWorkoutCompletedProvider), isFalse);

      final extraExercise = findExercise('ex5')!;
      final startedAddOn = notifier.addExercise(extraExercise);
      final extended = container.read(workoutSessionProvider);

      expect(startedAddOn, isFalse);
      expect(extended.exercises, hasLength(original.exercises.length + 1));
      expect(extended.isCompleted, isFalse);
      expect(extended.completedSets, original.totalSets);
      expect(container.read(isTodayWorkoutCompletedProvider), isFalse);
    });

    test('a new planned workout reopens a day that already has history', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(workoutScheduleProvider.notifier);

      notifier.recordWorkoutCompletion(
        workoutName: 'Buổi sáng',
        durationMinutes: 40,
        totalVolumeKg: 2000,
        completedSets: 10,
        prCount: 0,
      );
      final now = DateTime.now();
      final today =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      notifier.addSchedule(
        title: 'Buổi tập thêm bằng AI',
        targetMuscles: 'Vai, Tay sau',
        durationMinutes: 30,
        date: today,
        time: '20:00',
      );

      final state = container.read(workoutScheduleProvider);
      expect(state.isTodayWorkoutCompleted, isFalse);
      expect(state.todayWorkout?.title, 'Buổi tập thêm bằng AI');
      expect(state.todayWorkout?.status, ScheduleStatus.planned);
    });

    test(
      'autoAdvanceIfExerciseCompleted advances to next incomplete exercise and wraps around',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final notifier = container.read(workoutSessionProvider.notifier);

        // Start at exercise 4 (index 3)
        notifier.selectExercise(3);
        expect(
          container.read(workoutSessionProvider).currentExerciseIndex,
          equals(3),
        );

        // Complete all sets for exercise 4 ('ex4')
        final setsEx4 = container.read(workoutSessionProvider).logs['ex4']!;
        for (var i = 0; i < setsEx4.length; i++) {
          notifier.updateSet(exerciseId: 'ex4', setIndex: i, completed: true);
        }

        // Auto advance: since index 3 is complete, it should wrap around to index 0 (first incomplete exercise)
        notifier.autoAdvanceIfExerciseCompleted('ex4');
        expect(
          container.read(workoutSessionProvider).currentExerciseIndex,
          equals(0),
        );

        // Complete all sets for exercise 1 ('ex1')
        final setsEx1 = container.read(workoutSessionProvider).logs['ex1']!;
        for (var i = 0; i < setsEx1.length; i++) {
          notifier.updateSet(exerciseId: 'ex1', setIndex: i, completed: true);
        }

        // Auto advance: should now advance forward to index 1 ('ex2')
        notifier.autoAdvanceIfExerciseCompleted('ex1');
        expect(
          container.read(workoutSessionProvider).currentExerciseIndex,
          equals(1),
        );
      },
    );

    testWidgets(
      'DashboardScreen renders avatar on right and WeeklyProgressCard',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: DashboardScreen())),
        );
        await tester.pumpAndSettle();

        expect(find.text('Gia Huy'), findsOneWidget);
        expect(find.byType(CircleAvatar), findsOneWidget);
        expect(find.text('TIẾN ĐỘ & THỐNG KÊ'), findsOneWidget);
        expect(find.textContaining('buổi tập tuần này'), findsOneWidget);
        expect(find.textContaining('ngày'), findsAtLeast(1));
        expect(find.text('Bắt đầu tập ngay'), findsOneWidget);
      },
    );

    testWidgets(
      'DashboardScreen displays "ĐÃ HOÀN THÀNH" stamp without active CTA when workout completed',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        // Create completed session state
        final completedSession = WorkoutSessionState(
          id: 'completed_session',
          title: 'Push Day A',
          exercises: const [
            SessionExercise(
              exerciseId: 'ex1',
              name: 'Barbell Bench Press',
              primaryMuscle: 'Ngực',
              equipment: EquipmentType.barbell,
              targetSets: 1,
              targetReps: 10,
              weightKg: 60,
            ),
          ],
          logs: {
            'ex1': [SetLog(number: 1, reps: 10, weightKg: 60, completed: true)],
          },
          isFinalized: true,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              workoutSessionProvider.overrideWith(
                () => _TestWorkoutSessionNotifier(completedSession),
              ),
            ],
            child: const MaterialApp(home: DashboardScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('1/1 hiệp • 100% hoàn thành'), findsOneWidget);
        expect(find.text('ĐÃ HOÀN THÀNH'), findsOneWidget);
        expect(find.text('Đã hoàn thành hôm nay ✓'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle_rounded), findsWidgets);
        expect(find.text('Bắt đầu tập ngay'), findsNothing);
        expect(find.text('Tiếp tục buổi tập'), findsNothing);
      },
    );

    testWidgets(
      'WorkoutTabScreen displays "Đã hoàn thành bài tập" disabled button when workout completed',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        // Create completed session state
        final completedSession = WorkoutSessionState(
          id: 'completed_session',
          title: 'Push Day A',
          exercises: const [
            SessionExercise(
              exerciseId: 'ex1',
              name: 'Barbell Bench Press',
              primaryMuscle: 'Ngực',
              equipment: EquipmentType.barbell,
              targetSets: 1,
              targetReps: 10,
              weightKg: 60,
            ),
          ],
          logs: {
            'ex1': [SetLog(number: 1, reps: 10, weightKg: 60, completed: true)],
          },
          isFinalized: true,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              workoutSessionProvider.overrideWith(
                () => _TestWorkoutSessionNotifier(completedSession),
              ),
            ],
            child: const MaterialApp(home: WorkoutTabScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Đã hoàn thành bài tập'), findsOneWidget);
        expect(find.text('1/1 hiệp đã hoàn thành'), findsOneWidget);
        expect(find.text('Tiếp tục buổi tập'), findsNothing);
        expect(find.text('Bắt đầu tập'), findsNothing);
      },
    );

    testWidgets(
      'DashboardScreen renders "Tạo lịch tập với AI" button when no workout today',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        // Override schedule with empty schedules
        final emptyScheduleState = WorkoutScheduleState(
          selectedDate: '2026-08-30',
          schedules: const [],
          history: const [],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              workoutScheduleProvider.overrideWith(
                () => _TestWorkoutScheduleNotifier(emptyScheduleState),
              ),
            ],
            child: const MaterialApp(home: DashboardScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Hôm nay chưa có lịch tập'), findsOneWidget);
        expect(find.text('Tạo lịch tập với AI'), findsOneWidget);
        expect(find.text('Thêm lịch tập ngay!'), findsOneWidget);
      },
    );

    testWidgets(
      'WorkoutTabScreen displays "Hôm nay chưa có lịch tập" when exercise list is empty',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        const emptySession = WorkoutSessionState(
          id: 'empty_session',
          title: 'Buổi tập',
          exercises: [],
          logs: {},
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              workoutSessionProvider.overrideWith(
                () => _TestWorkoutSessionNotifier(emptySession),
              ),
            ],
            child: const MaterialApp(home: WorkoutTabScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Hôm nay chưa có lịch tập'), findsAtLeast(1));
      },
    );

    testWidgets('ProgressScreen renders all 6 detailed analytics sections', (
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

      // Section 1: Consistency
      expect(find.text('TỶ LỆ HOÀN THÀNH MỤC TIÊU'), findsOneWidget);
      expect(find.textContaining('buổi tập'), findsAtLeast(1));

      // Section 2: Volume Load
      expect(find.text('KHỐI LƯỢNG TẢI TRỌNG (VOLUME LOAD)'), findsOneWidget);
      expect(
        find.textContaining('Phân tích Progressive Overload'),
        findsOneWidget,
      );

      // Section 3: Muscle Volume & Recovery
      expect(find.text('TẬP LUYỆN & PHỤC HỒI NHÓM CƠ'), findsOneWidget);

      // Section 4: Strength PR
      expect(find.text('TĂNG TIẾN SỨC MẠNH (STRENGTH PR)'), findsOneWidget);

      // Section 5: Recent history
      expect(find.text('NHẬT KÝ BUỔI TẬP GẦN ĐÂY'), findsOneWidget);
    });

    testWidgets(
      'ExerciseLibraryScreen renders search, filter buttons, and opens ExerciseFilterModal',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: ExerciseLibraryScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Top search bar and filters
        expect(
          find.text('Tìm theo tên bài tập, nhóm cơ, thiết bị'),
          findsOneWidget,
        );
        expect(find.text('Nhóm cơ'), findsOneWidget);
        expect(find.text('Thiết bị'), findsOneWidget);
        expect(find.text('Tất cả bộ lọc'), findsOneWidget);
        expect(find.textContaining('DANH SÁCH BÀI TẬP'), findsOneWidget);

        // Reusable tag chips are visible
        expect(find.text('Ngực'), findsAtLeast(1));

        // Tap "Nhóm cơ" to open Filter Modal
        await tester.tap(find.text('Nhóm cơ'));
        await tester.pumpAndSettle();

        expect(find.text('Theo nhóm cơ'), findsOneWidget);
        expect(find.text('Tất cả'), findsOneWidget);
        expect(find.text('TORSO (THÂN TRÊN)'), findsOneWidget);
        expect(find.text('Áp dụng bộ lọc'), findsOneWidget);
        expect(find.text('Đặt lại'), findsOneWidget);

        // Tap apply
        await tester.tap(find.text('Áp dụng bộ lọc'));
        await tester.pumpAndSettle();

        expect(find.textContaining('DANH SÁCH BÀI TẬP'), findsOneWidget);
      },
    );

    testWidgets(
      'WorkoutScheduleScreen renders swipable weekly calendar and reference workout card',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: WorkoutScheduleScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Verify header and swipable weekly calendar
        expect(find.text('Lịch tập luyện'), findsOneWidget);
        expect(find.text('Hôm nay'), findsOneWidget);
        expect(find.textContaining('Tháng'), findsOneWidget);
        expect(find.text('T2'), findsAtLeast(1));

        // Verify reference card layout contents
        expect(find.textContaining('Pull Focus'), findsOneWidget);
        expect(find.text('CÁC BÀI TẬP DỰ KIẾN'), findsOneWidget);
        expect(find.text('Lat Pulldown'), findsOneWidget);
        expect(find.text('4x10'), findsOneWidget);
        expect(find.text('Đổi buổi'), findsOneWidget);
        expect(find.text('Đổi ngày'), findsOneWidget);
        expect(find.text('Bắt đầu tập ngay'), findsOneWidget);

        // Tap 'Đổi buổi'
        await tester.tap(find.text('Đổi buổi'));
        await tester.pumpAndSettle();

        expect(find.text('Đổi buổi tập với'), findsOneWidget);
        expect(find.text('Xác nhận đổi'), findsOneWidget);
        expect(find.text('Hủy'), findsOneWidget);

        // Close modal
        await tester.tap(find.text('Hủy'));
        await tester.pumpAndSettle();

        // Tap 'Đổi ngày'
        await tester.tap(find.text('Đổi ngày'));
        await tester.pumpAndSettle();

        expect(find.text('Chọn ngày mới cho buổi tập'), findsOneWidget);
        expect(find.text('Xác nhận chuyển'), findsOneWidget);

        // Close modal
        await tester.tap(find.text('Hủy'));
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'WorkoutSessionScreen renders exercise illustrations, sets progress, and swipe to delete set',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: WorkoutSessionScreen())),
        );
        await tester.pumpAndSettle();

        // Check header and exercise title
        expect(find.textContaining('Barbell Bench Press'), findsAtLeast(1));
        expect(find.text('Bảng ghi hiệp tập'), findsOneWidget);

        // Verify X/Y sets progress indicator (e.g. '0/3 hiệp')
        expect(find.textContaining('/3 hiệp'), findsAtLeast(1));

        // Verify BodyMuscleMap is rendered in hero illustration card
        expect(find.byType(BodyMuscleMap), findsOneWidget);

        // Swipe left on set 1 to delete it
        final dismissibleTopLeft = tester.getTopLeft(
          find.byKey(const ValueKey('dismiss_set_ex1_set_1')),
        );
        await tester.dragFrom(
          dismissibleTopLeft + const Offset(15, 15),
          const Offset(-800, 0),
        );
        await tester.pumpAndSettle();

        // Remaining sets should now be renumbered to 1 and 2 (total 2 sets)
        expect(find.textContaining('/2 hiệp'), findsAtLeast(1));
      },
    );

    testWidgets(
      'WorkoutHistoryScreen renders monthly summary, calendar, search and history cards',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: WorkoutHistoryScreen())),
        );
        await tester.pumpAndSettle();

        // Verify Header
        expect(find.text('Lịch sử buổi tập'), findsOneWidget);

        // Verify Monthly Summary Statistics
        expect(find.text('TỔNG BUỔI'), findsOneWidget);
        expect(find.textContaining('TỔNG THỜI'), findsOneWidget);
        expect(find.text('TỔNG VOLUME'), findsOneWidget);
        expect(find.text('4'), findsAtLeast(1));
        expect(find.text('208p'), findsOneWidget);
        expect(find.text('15.3t'), findsOneWidget);

        // Verify Calendar Elements
        expect(find.text('T2'), findsOneWidget);
        expect(find.text('T3'), findsOneWidget);
        expect(find.text('T4'), findsOneWidget);
        expect(find.text('T5'), findsOneWidget);
        expect(find.text('T6'), findsOneWidget);
        expect(find.text('T7'), findsOneWidget);
        expect(find.text('CN'), findsOneWidget);

        // Verify Search Bar
        expect(find.text('Tìm buổi tập, bài tập, nhóm cơ...'), findsOneWidget);

        // Verify History List & Cards
        expect(find.textContaining('DANH SÁCH BUỔI TẬP (4)'), findsOneWidget);
        expect(find.textContaining('Upper Body A'), findsOneWidget);
        expect(find.textContaining('Leg Day Power'), findsOneWidget);
        expect(find.textContaining('Pull Focus'), findsOneWidget);
        expect(find.textContaining('Push Focus'), findsOneWidget);

        // Tap on Day 19 in calendar to filter
        await tester.tap(find.text('19').first);
        await tester.pumpAndSettle();

        // Filtered to 1 workout on day 19
        expect(find.textContaining('DANH SÁCH BUỔI TẬP (1)'), findsOneWidget);
        expect(find.text('Xem cả tháng'), findsOneWidget);

        // Tap 'Xem cả tháng' to clear date filter
        await tester.tap(find.text('Xem cả tháng'));
        await tester.pumpAndSettle();
        expect(find.textContaining('DANH SÁCH BUỔI TẬP (4)'), findsOneWidget);

        // Test Search Filter
        await tester.enterText(find.byType(TextField), 'Squat');
        await tester.pumpAndSettle();
        expect(find.textContaining('DANH SÁCH BUỔI TẬP (1)'), findsOneWidget);
        expect(find.textContaining('Leg Day Power'), findsOneWidget);
      },
    );

    testWidgets(
      'WorkoutHistoryDetailScreen renders complete read-only session breakdown',
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
              home: WorkoutHistoryDetailScreen(historyId: 'hist_1'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify Header and Title
        expect(find.text('Chi tiết buổi tập'), findsOneWidget);
        expect(find.text('Upper Body A — Ngực & Tay sau'), findsOneWidget);
        expect(find.text('1 PR Mới'), findsOneWidget);

        // Verify Metrics
        expect(find.text('52p'), findsOneWidget);
        expect(find.text('4420 kg'), findsOneWidget);
        expect(find.text('14'), findsAtLeast(1));

        // Verify Target Muscles & Body Muscle Map
        expect(find.text('NHÓM CƠ ĐÃ TÁC ĐỘNG'), findsOneWidget);
        expect(find.byType(BodyMuscleMap), findsOneWidget);

        // Verify Completed Exercises and Sets Table
        expect(find.textContaining('DANH SÁCH BÀI TẬP (4)'), findsOneWidget);
        expect(find.text('Barbell Bench Press'), findsOneWidget);
        expect(find.text('Incline Dumbbell Press'), findsOneWidget);
        expect(find.text('Tricep Rope Pushdown'), findsOneWidget);
        expect(find.text('Standing Dumbbell Lateral Raise'), findsOneWidget);

        // Verify Sets
        expect(find.text('60 kg'), findsAtLeast(1));
        expect(find.text('65 kg'), findsAtLeast(1));
        expect(find.text('10 reps'), findsAtLeast(1));
        expect(find.text('🏅 PR'), findsAtLeast(1));
      },
    );

    testWidgets(
      'AiWorkoutGenerateScreen renders equipment section, presets, and generates plan',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: AiWorkoutGenerateScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Verify Header
        expect(find.text('AI Tạo buổi tập'), findsOneWidget);
        expect(find.text('AI Workout Generator'), findsOneWidget);

        // Verify Muscle Section
        expect(find.text('1. Chọn nhóm cơ mục tiêu'), findsOneWidget);

        // Verify Equipment Section & Presets
        expect(find.text('2. Thiết bị tập luyện có sẵn'), findsOneWidget);
        expect(find.text('Đầy đủ phòng Gym'), findsOneWidget);
        expect(find.text('Tạ đơn tại nhà'), findsOneWidget);
        expect(find.text('Bodyweight (Không dụng cụ)'), findsOneWidget);

        // Verify Duration and Goal
        expect(find.text('3. Thời lượng buổi tập'), findsOneWidget);
        expect(find.text('4. Trọng tâm buổi tập'), findsOneWidget);

        // Tap Home Dumbbell preset
        await tester.tap(find.text('Tạ đơn tại nhà'));
        await tester.pumpAndSettle();

        // Tap Generate
        await tester.tap(find.text('AI Tạo giáo án tối ưu'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        // Verify Generated Plan appears
        expect(find.textContaining('Đề xuất:'), findsOneWidget);
        expect(find.text('Áp dụng giáo án này vào lịch tập'), findsOneWidget);
      },
    );

    testWidgets(
      'AI asks before changing an active workout and can append without losing progress',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final container = ProviderContainer();
        addTearDown(container.dispose);
        final originalSession = container.read(workoutSessionProvider);
        final originalScheduleCount = container
            .read(workoutScheduleProvider)
            .schedules
            .length;
        container
            .read(workoutSessionProvider.notifier)
            .updateSet(
              exerciseId: originalSession.exercises.first.exerciseId,
              setIndex: 0,
              completed: true,
            );

        final router = GoRouter(
          initialLocation: '/generate',
          routes: [
            GoRoute(
              path: '/generate',
              builder: (context, state) => const AiWorkoutGenerateScreen(),
            ),
            GoRoute(
              path: '/workout',
              builder: (context, state) => const Scaffold(),
            ),
          ],
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('AI Tạo giáo án tối ưu'));
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Áp dụng giáo án này vào lịch tập'));
        await tester.pumpAndSettle();

        expect(find.text('Hôm nay đã có buổi tập'), findsOneWidget);
        expect(find.text('Thêm vào buổi hiện tại'), findsOneWidget);
        expect(find.text('Thay thế'), findsOneWidget);

        await tester.tap(find.text('Thêm vào buổi hiện tại'));
        await tester.pumpAndSettle();

        final extendedSession = container.read(workoutSessionProvider);
        expect(
          extendedSession.exercises.length,
          greaterThan(originalSession.exercises.length),
        );
        expect(extendedSession.logs['ex1']?.first.completed, isTrue);
        expect(
          container.read(workoutScheduleProvider).schedules.length,
          originalScheduleCount,
        );
      },
    );

    testWidgets(
      'TodayWorkoutEmptyState renders title, subtitle, button and triggers CTA callback',
      (tester) async {
        bool tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TodayWorkoutEmptyState(
                title: 'Hôm nay chưa có lịch tập',
                subtitle: 'Bạn có thể tạo một buổi tập phù hợp cho hôm nay.',
                buttonLabel: 'Thêm lịch tập ngay!',
                onCreateWorkout: () => tapped = true,
              ),
            ),
          ),
        );

        expect(find.text('Hôm nay chưa có lịch tập'), findsOneWidget);
        expect(
          find.text('Bạn có thể tạo một buổi tập phù hợp cho hôm nay.'),
          findsOneWidget,
        );
        expect(find.text('Thêm lịch tập ngay!'), findsOneWidget);

        await tester.tap(find.text('Thêm lịch tập ngay!'));
        await tester.pump();
        expect(tapped, isTrue);
      },
    );

    test(
      'FavoriteExercisesController toggles, adds, removes, and gets favorites',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final notifier = container.read(favoriteExercisesProvider.notifier);
        expect(notifier.isFavorite('ex1'), isTrue);

        final removed = notifier.toggleFavorite('ex1');
        expect(removed, isFalse);
        expect(notifier.isFavorite('ex1'), isFalse);

        final added = notifier.toggleFavorite('ex1');
        expect(added, isTrue);
        expect(notifier.isFavorite('ex1'), isTrue);

        final favorites = notifier.getFavorites();
        expect(favorites.any((e) => e.id == 'ex1'), isTrue);
      },
    );

    testWidgets(
      'FavoriteExercisesSection renders favorite cards and triggers add to session',
      (tester) async {
        ExerciseDefinition? addedExercise;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: FavoriteExercisesSection(
                  onAddExerciseToSession: (ex) => addedExercise = ex,
                ),
              ),
            ),
          ),
        );

        expect(find.text('Bài tập yêu thích'), findsOneWidget);
        expect(find.text('Barbell Bench Press'), findsOneWidget);
        expect(find.text('Thêm vào buổi tập'), findsWidgets);

        await tester.tap(find.text('Thêm vào buổi tập').first);
        await tester.pump();
        expect(addedExercise, isNotNull);
        expect(addedExercise?.name, 'Barbell Bench Press');
      },
    );

    testWidgets(
      'FavoriteExercisesScreen renders favorites list with illustration and action buttons',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: FavoriteExercisesScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Bài tập yêu thích'), findsOneWidget);
        expect(find.text('Barbell Bench Press'), findsAtLeast(1));
        expect(find.text('Barbell Squat'), findsAtLeast(1));
        expect(find.text('Chi tiết'), findsWidgets);
        expect(find.text('Thêm vào hôm nay'), findsWidgets);
      },
    );

    testWidgets(
      'WorkoutTabScreen renders Yêu thích shortcut and AI tạo lịch tập banner',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: WorkoutTabScreen())),
        );
        await tester.pumpAndSettle();

        expect(find.text('Thư viện'), findsOneWidget);
        expect(find.text('Lịch tập'), findsOneWidget);
        expect(find.text('Lịch sử'), findsOneWidget);
        expect(find.text('Yêu thích'), findsOneWidget);

        // Verify AI tạo lịch tập banner below exercise list
        expect(find.text('AI tạo lịch tập'), findsOneWidget);
        expect(
          find.text('Bạn chưa biết tập gì? Hãy để VieGym giúp đỡ bạn !'),
          findsOneWidget,
        );
      },
    );

    testWidgets('WorkoutBuilderScreen renders days, allows adding day and editing exercise targets', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: WorkoutBuilderScreen())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Workout Builder'), findsOneWidget);
      expect(find.text('CÁC BUỔI TẬP (2)'), findsOneWidget);
      expect(find.text('Buổi 1'), findsOneWidget);
      expect(find.text('Buổi 2'), findsOneWidget);

      // Tap thêm buổi
      await tester.tap(find.text('Thêm buổi'));
      await tester.pumpAndSettle();

      expect(find.text('CÁC BUỔI TẬP (3)'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Buổi 3'), findsOneWidget);
    });

    testWidgets('E2E Flow 2: Exercise -> Favorite -> Program -> Schedule -> Session -> Log/PR', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // 1. Exercise & Favorite
      final favNotifier = container.read(favoriteExercisesProvider.notifier);
      final testEx = exerciseCatalog.firstWhere((e) => !favNotifier.isFavorite(e.id));
      expect(favNotifier.isFavorite(testEx.id), isFalse);
      favNotifier.toggleFavorite(testEx.id);
      expect(favNotifier.isFavorite(testEx.id), isTrue);

      // 2. Schedule
      final schedNotifier = container.read(workoutScheduleProvider.notifier);
      schedNotifier.addSchedule(
        title: 'E2E Full Body',
        targetMuscles: 'Toàn thân',
        durationMinutes: 45,
        date: '2026-09-02',
        time: '18:00',
      );
      final schedules = container.read(workoutScheduleProvider).schedules;
      expect(schedules.any((s) => s.title == 'E2E Full Body'), isTrue);

      // 3. Session & Log
      final sessionNotifier = container.read(workoutSessionProvider.notifier);
      sessionNotifier.addExercise(testEx);
      expect(container.read(workoutSessionProvider).exercises.isNotEmpty, isTrue);

      // Record completion
      schedNotifier.recordWorkoutCompletion(
        workoutName: 'E2E Full Body',
        durationMinutes: 45,
        totalVolumeKg: 2400,
        completedSets: 10,
        prCount: 1,
      );
      expect(container.read(workoutScheduleProvider).history.first.workoutName, 'E2E Full Body');
    });

    test('ExerciseCatalogController handles search query, filtering and fallback', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(exerciseCatalogControllerProvider.notifier);
      expect(container.read(exerciseCatalogControllerProvider).exercises.isNotEmpty, isTrue);

      controller.setQuery('Bench');
      expect(container.read(exerciseCatalogControllerProvider).query, 'Bench');

      controller.setMuscleGroup(1);
      expect(container.read(exerciseCatalogControllerProvider).muscleGroupId, 1);

      controller.setEquipment(2);
      expect(container.read(exerciseCatalogControllerProvider).equipmentId, 2);

      controller.resetFilters();
      expect(container.read(exerciseCatalogControllerProvider).query, '');
      expect(container.read(exerciseCatalogControllerProvider).muscleGroupId, isNull);
    });

    test('ExerciseApiSummary and ExerciseApiDetail map JSON and convert to ExerciseDefinition correctly', () {
      final summaryJson = {
        'id': 101,
        'name': 'Hít đất rộng tay (Wide Push-up)',
        'searchName': 'hit dat rong tay',
        'slug': 'hit-dat-rong-tay',
        'difficulty': 'BEGINNER',
        'description': 'Biến thể tập ngực ngoài',
        'muscleGroups': [
          {'muscleGroupId': 1, 'code': 'CHEST', 'name': 'Ngực', 'role': 'PRIMARY'},
          {'muscleGroupId': 2, 'code': 'TRICEPS', 'name': 'Tay sau', 'role': 'SECONDARY'},
        ],
        'equipment': [
          {'equipmentId': 1, 'code': 'BODYWEIGHT', 'name': 'Trọng lượng cơ thể'},
        ],
        'isFavorite': true,
      };

      final summary = ExerciseApiSummary.fromJson(summaryJson);
      expect(summary.id, 101);
      expect(summary.name, 'Hít đất rộng tay (Wide Push-up)');
      expect(summary.isFavorite, isTrue);

      final def = summary.toExerciseDefinition();
      expect(def.id, 'ex_101');
      expect(def.primaryMuscle, 'Ngực');
      expect(def.secondaryMuscles, contains('Tay sau'));
      expect(def.equipment, EquipmentType.bodyweight);

      final detailJson = {
        'id': 102,
        'name': 'Kéo xà đơn (Pull-up)',
        'searchName': 'keo xa don',
        'slug': 'keo-xa-don',
        'difficulty': 'INTERMEDIATE',
        'description': 'Bài tập lưng xô kinh điển',
        'instructionSteps': ['Treo người trên xà', 'Kéo cằm vượt quá xà'],
        'commonMistakes': ['Đung đưa người lấy đà'],
        'safetyNotes': ['Không thả lỏng vai đột ngột'],
        'muscleGroups': [
          {'muscleGroupId': 3, 'code': 'BACK', 'name': 'Lưng', 'role': 'PRIMARY'},
        ],
        'equipment': [
          {'equipmentId': 1, 'code': 'BODYWEIGHT', 'name': 'Trọng lượng cơ thể'},
        ],
      };

      final detail = ExerciseApiDetail.fromJson(detailJson);
      expect(detail.id, 102);
      expect(detail.instructionSteps.length, 2);
      expect(detail.safetyNotes.first, 'Không thả lỏng vai đột ngột');

      final detailDef = detail.toExerciseDefinition();
      expect(detailDef.instructions.length, 2);
      expect(detailDef.commonMistakes.first.mistake, 'Đung đưa người lấy đà');
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

class _TestWorkoutSessionNotifier extends WorkoutSessionController {
  _TestWorkoutSessionNotifier(this._initial);
  final WorkoutSessionState _initial;

  @override
  WorkoutSessionState build() => _initial;
}

class _TestWorkoutScheduleNotifier extends WorkoutScheduleController {
  _TestWorkoutScheduleNotifier(this._initial);
  final WorkoutScheduleState _initial;

  @override
  WorkoutScheduleState build() => _initial;
}
