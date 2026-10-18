import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viegym/features/workout/application/workout_schedule_controller.dart';
import 'package:viegym/features/workout/application/workout_session_controller.dart';
import 'package:viegym/features/workout/data/exercise_catalog.dart';
import 'package:viegym/features/workout/data/workout_schedule_planning_repository.dart';
import 'package:viegym/features/workout/domain/workout_models.dart';
import 'package:viegym/features/workout/presentation/ai_workout_generate_screen.dart';
import 'package:viegym/features/workout/presentation/widgets/schedule_proposal_dialog.dart';
import 'package:viegym/features/workout/presentation/workout_builder_screen.dart';
import 'package:viegym/features/workout/presentation/workout_schedule_create_screen.dart';
import 'package:viegym/features/workout/presentation/workout_schedule_screen.dart';
import 'package:viegym/features/workout/presentation/workout_tab_screen.dart';

class _FakePlanningRepository extends WorkoutSchedulePlanningRepository {
  _FakePlanningRepository() : super(Dio());

  List<ScheduleDraftDay>? submittedDirectDays;
  List<DateTime>? submittedSourceDates;
  List<PlannedExercisePreview> appliedSourceExercises = const [];
  final List<int> cancelledScheduleIds = [];
  bool personalProgramCreated = false;
  String? lastCreatedProgramName;
  List<AppliedWorkoutSchedule> schedules = const [];

  static const personal = WorkoutPlanSource(
    id: 10,
    name: 'Upper Lower cá nhân',
    totalDays: 2,
    sourceType: 'USER_PROGRAM',
  );

  @override
  Future<List<WorkoutPlanSource>> loadPersonalPrograms() async => [personal];

  @override
  Future<WorkoutPlanSource> createPersonalProgram({
    required String name,
    required String programType,
    String? description,
    required List<ScheduleDraftDay> days,
  }) async {
    personalProgramCreated = true;
    lastCreatedProgramName = name;
    return WorkoutPlanSource(
      id: 999,
      name: name,
      totalDays: days.length,
      sourceType: 'USER_PROGRAM',
    );
  }

  @override
  Future<List<WorkoutPlanSource>> loadAdminTemplates() async => const [
    WorkoutPlanSource(
      id: 20,
      name: 'Full Body VieGym',
      totalDays: 3,
      sourceType: 'ADMIN_TEMPLATE',
    ),
  ];

  @override
  Future<List<AppliedWorkoutSchedule>> loadSchedules({
    required DateTime from,
    required DateTime to,
  }) async => schedules;

  @override
  Future<WorkoutPlanSource> loadSourceDetail(WorkoutPlanSource source) async {
    return source.copyWith(
      days: const [
        WorkoutPlanDay(
          id: 101,
          dayNumber: 1,
          name: 'Upper A',
          exerciseCount: 4,
        ),
        WorkoutPlanDay(
          id: 102,
          dayNumber: 2,
          name: 'Lower A',
          exerciseCount: 5,
        ),
      ],
      totalDays: 2,
    );
  }

  @override
  Future<ScheduleProposalView> createSourceProposal({
    required WorkoutPlanSource source,
    required List<DateTime> targetDates,
    required String time,
    int? sourceDayId,
  }) async {
    submittedSourceDates = targetDates;
    return ScheduleProposalView(
      id: 99,
      sourceType: source.sourceType,
      scope: 'ONE_DAY',
      expiresAt: DateTime.now().add(const Duration(minutes: 30)),
      items: [
        ScheduleProposalItemView(
          date: targetDates.first,
          time: time,
          title: 'Upper A',
          exerciseCount: 4,
          plannedExercises: const [
            PlannedExercisePreview(
              name: 'Goblet Squat',
              setsReps: '3x8-12',
              primaryMuscle: 'Đùi trước',
            ),
          ],
        ),
      ],
    );
  }

  @override
  Future<void> cancelSchedule(int scheduleId) async {
    cancelledScheduleIds.add(scheduleId);
  }

  @override
  Future<ScheduleProposalView> createDirectProposal({
    required String sourceType,
    required List<ScheduleDraftDay> days,
  }) async {
    submittedDirectDays = days;
    return ScheduleProposalView(
      id: 100,
      sourceType: sourceType,
      scope: days.length == 1 ? 'ONE_DAY' : 'WEEK',
      expiresAt: DateTime.now().add(const Duration(minutes: 30)),
      items: days
          .map(
            (day) => ScheduleProposalItemView(
              date: day.date,
              time: day.time,
              title: day.title,
              exerciseCount: day.exercises.length,
            ),
          )
          .toList(),
    );
  }

  @override
  Future<List<AppliedWorkoutSchedule>> applyProposal(int proposalId) async {
    final directDays = submittedDirectDays;
    if (directDays != null) {
      return directDays.indexed
          .map(
            (entry) => AppliedWorkoutSchedule(
              id: 600 + entry.$1,
              date: entry.$2.date,
              time: entry.$2.time,
              title: entry.$2.title,
              status: 'PLANNED',
            ),
          )
          .toList();
    }
    return [
      AppliedWorkoutSchedule(
        id: 501,
        date:
            submittedSourceDates?.first ??
            DateTime.now().add(const Duration(days: 1)),
        time: '18:00',
        title: 'Upper A',
        status: 'PLANNED',
        plannedExercises: appliedSourceExercises,
      ),
    ];
  }
}

void main() {
  test('schedule proposal retains exercise names and targets', () {
    final proposal = ScheduleProposalView.fromJson({
      'id': 55,
      'sourceType': 'USER_PROGRAM',
      'scope': 'ONE_DAY',
      'expiresAt': '2099-03-01T12:00:00Z',
      'items': [
        {
          'scheduledDate': '2099-03-02',
          'scheduledTime': '18:00',
          'title': 'Lower A',
          'exercises': [
            {
              'exerciseId': 12,
              'exerciseName': 'Goblet Squat',
              'primaryMuscle': 'Đùi trước',
              'targetSets': 4,
              'targetRepsMin': 8,
              'targetRepsMax': 12,
            },
          ],
        },
      ],
    });

    expect(proposal.items.single.plannedExercises, hasLength(1));
    expect(proposal.items.single.plannedExercises.single.name, 'Goblet Squat');
    expect(proposal.items.single.plannedExercises.single.setsReps, '4x8-12');
    expect(
      proposal.items.single.plannedExercises.single.primaryMuscle,
      'Đùi trước',
    );
  });

  test('static exercise keys are resolved to real backend IDs', () async {
    final adapter = _PlanningApiAdapter();
    final dio = Dio()..httpClientAdapter = adapter;
    final repository = WorkoutSchedulePlanningRepository(dio);

    await repository.createDirectProposal(
      sourceType: 'AI',
      days: [
        ScheduleDraftDay(
          date: DateTime(2099, 3, 1),
          time: '17:30',
          title: 'AI workout',
          exercises: [
            ScheduleDraftExercise(
              exercise: exerciseCatalog.first,
              targetSets: 3,
              targetRepsMin: 8,
              targetRepsMax: 12,
              restSeconds: 90,
            ),
          ],
        ),
      ],
    );

    expect(adapter.searchQuery, exerciseCatalog.first.name);
    final items = adapter.proposalBody!['items'] as List<dynamic>;
    final exercises =
        (items.first as Map<String, dynamic>)['exercises'] as List<dynamic>;
    expect((exercises.first as Map<String, dynamic>)['exerciseId'], 321);
  });

  testWidgets('schedule creator exposes all sources and configures a program', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          workoutSchedulePlanningRepositoryProvider.overrideWithValue(
            _FakePlanningRepository(),
          ),
        ],
        child: const MaterialApp(home: WorkoutScheduleCreateScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tự tạo'), findsOneWidget);
    expect(find.text('AI tạo'), findsOneWidget);
    expect(find.text('Upper Lower cá nhân'), findsOneWidget);

    await tester.tap(find.text('Upper Lower cá nhân'));
    await tester.pumpAndSettle();

    expect(find.text('Phạm vi áp dụng'), findsNothing);
    expect(find.text('Một ngày'), findsNothing);
    expect(find.text('Cả tuần'), findsNothing);
    expect(find.text('CẤU HÌNH LỊCH TẬP'), findsOneWidget);
    expect(find.textContaining('Upper A'), findsWidgets);
    expect(find.text('Xem trước lịch tập'), findsOneWidget);
  });

  testWidgets('schedule creator previews and applies a selected program', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          workoutSchedulePlanningRepositoryProvider.overrideWithValue(
            _FakePlanningRepository(),
          ),
        ],
        child: const MaterialApp(home: WorkoutScheduleCreateScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upper Lower cá nhân'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xem trước lịch tập'));
    await tester.pumpAndSettle();

    expect(
      find.text('Kiểm tra ngày, giờ và nội dung trước khi thêm vào lịch.'),
      findsOneWidget,
    );
    expect(find.text('Upper A'), findsWidgets);

    await tester.tap(find.text('Áp dụng lịch'));
    await tester.pumpAndSettle();

    expect(find.text('Đã thêm 1 buổi tập vào lịch.'), findsOneWidget);
  });

  testWidgets(
    'applying a ready-made program replaces an existing server schedule',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repository = _FakePlanningRepository();
      repository.appliedSourceExercises = const [
        PlannedExercisePreview(
          name: 'Hip Thrust',
          setsReps: '4x8-12',
          primaryMuscle: 'Cơ mông',
        ),
      ];
      final container = ProviderContainer(
        overrides: [
          workoutSchedulePlanningRepositoryProvider.overrideWithValue(
            repository,
          ),
        ],
      );
      addTearDown(container.dispose);
      final today = DateTime.now();
      final todayString =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      container.read(workoutScheduleProvider.notifier).mergeAppliedSchedules([
        WorkoutScheduleItem(
          id: 'server_77',
          date: todayString,
          time: '18:00',
          title: 'Lịch cũ',
          targetMuscles: 'Ngực',
          durationMinutes: 40,
        ),
      ]);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: WorkoutScheduleCreateScreen(initialDate: today),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Upper Lower cá nhân'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xem trước lịch tập'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Áp dụng lịch'));
      await tester.pumpAndSettle();

      expect(repository.cancelledScheduleIds, [77]);
      final todaySchedules = container
          .read(workoutScheduleProvider)
          .schedules
          .where((schedule) => schedule.date == todayString)
          .toList();
      expect(todaySchedules, hasLength(1));
      expect(todaySchedules.single.id, 'server_501');
      expect(todaySchedules.single.title, 'Upper A');
      expect(todaySchedules.single.targetMuscles, 'Cơ mông');
      expect(todaySchedules.single.plannedExercises.single.name, 'Hip Thrust');
      expect(
        container.read(workoutSessionProvider).exercises.single.name,
        'Hip Thrust',
      );
      expect(
        container.read(workoutSessionProvider).exercises.single.primaryMuscle,
        'Cơ mông',
      );
    },
  );

  testWidgets('manual builder applies sessions from the selected date', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final repository = _FakePlanningRepository();
    final selectedDate = DateTime(2099, 1, 12);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          workoutSchedulePlanningRepositoryProvider.overrideWithValue(
            repository,
          ),
        ],
        child: MaterialApp(
          home: WorkoutBuilderScreen(initialDate: '2099-01-12'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xem trước & Lên lịch tuần đã chọn'));
    await tester.pumpAndSettle();

    expect(repository.submittedDirectDays, isNotNull);
    expect(repository.submittedDirectDays!.first.date, selectedDate);
  });

  testWidgets(
    'manual builder keeps the selected exercises after the server applies the schedule',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repository = _FakePlanningRepository();
      final container = ProviderContainer(
        overrides: [
          workoutSchedulePlanningRepositoryProvider.overrideWithValue(
            repository,
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: WorkoutBuilderScreen(initialDate: '2099-01-12'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lưu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xem trước & Lên lịch tuần đã chọn'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Áp dụng lịch'));
      await tester.pumpAndSettle();

      final draft = repository.submittedDirectDays!.first;
      final saved = container
          .read(workoutScheduleProvider)
          .schedules
          .singleWhere((item) => item.date == '2099-01-12');

      expect(
        saved.plannedExercises.map((exercise) => exercise.name),
        draft.exercises.map((exercise) => exercise.exercise.name),
      );
      expect(saved.plannedExercises, isNotEmpty);
    },
  );

  testWidgets('AI applies a one-day plan to its requested date', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final repository = _FakePlanningRepository();
    final selectedDate = DateTime(2099, 2, 10);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          workoutSchedulePlanningRepositoryProvider.overrideWithValue(
            repository,
          ),
        ],
        child: MaterialApp(
          home: AiWorkoutGenerateScreen(initialDate: selectedDate),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('AI Tạo giáo án tối ưu'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Áp dụng giáo án này vào lịch tập'));
    await tester.pumpAndSettle();

    expect(repository.submittedDirectDays, isNotNull);
    expect(repository.submittedDirectDays!.single.date, selectedDate);
  });

  testWidgets('proposal preview dialog allows user to interact with date box', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final proposal = ScheduleProposalView(
      id: 99,
      sourceType: 'USER_PROGRAM',
      scope: 'ONE_DAY',
      expiresAt: DateTime(2099, 1, 1),
      items: [
        ScheduleProposalItemView(
          date: DateTime(2099, 5, 20),
          time: '18:00',
          title: 'Buổi Tập Thử Nghiệm',
          exerciseCount: 4,
        ),
      ],
    );

    ScheduleProposalDialogResult? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await showScheduleProposalDialog(context, proposal);
            },
            child: const Text('Mở preview'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mở preview'));
    await tester.pumpAndSettle();

    expect(find.text('Xem trước lịch tập'), findsOneWidget);
    expect(find.text('20/05'), findsOneWidget);
    expect(find.text('18:00'), findsOneWidget);
    expect(
      find.text('Chạm vào ô ngày hoặc giờ để chỉnh sửa trước khi áp dụng.'),
      findsOneWidget,
    );

    // Tap on the date box to trigger picker
    await tester.tap(find.text('20/05'));
    await tester.pumpAndSettle();

    // The DatePickerDialog is displayed
    expect(find.byType(DatePickerDialog), findsOneWidget);

    // Cancel date picker
    await tester.tap(find.text('HỦY'));
    await tester.pumpAndSettle();

    // Confirm proposal
    await tester.tap(find.text('Áp dụng lịch'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.confirmed, isTrue);
    expect(result!.items.single.date, DateTime(2099, 5, 20));
  });

  testWidgets(
    'workout schedule screen allows deleting schedule with modern bottom sheet and undo',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: WorkoutScheduleScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Find the delete button tooltip
      final deleteButtons = find.byTooltip('Xóa buổi tập');
      expect(deleteButtons, findsWidgets);

      // Tap delete button on the card
      await tester.tap(deleteButtons.first);
      await tester.pumpAndSettle();

      // Modern Bottom Sheet confirmation appears
      expect(find.text('Xóa buổi tập khỏi lịch?'), findsOneWidget);
      expect(find.text('Xác nhận xóa'), findsOneWidget);
      expect(find.text('Giữ lại'), findsOneWidget);

      // Confirm delete
      await tester.tap(find.text('Xác nhận xóa'));
      await tester.pumpAndSettle();

      // Smart Undo SnackBar appears
      expect(find.text('HOÀN TÁC'), findsOneWidget);

      // Tap HOÀN TÁC
      await tester.tap(find.text('HOÀN TÁC'));
      await tester.pumpAndSettle();

      // Card is restored
      expect(find.byTooltip('Xóa buổi tập'), findsWidgets);
    },
  );

  testWidgets(
    'applying new AI schedule replaces old schedule on the same date and does not duplicate',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(workoutScheduleProvider.notifier);
      final todayStr = '2099-06-15';

      // 1. Initial schedule exists
      notifier.addSchedule(
        title: 'Lịch Cũ Sắp Xóa',
        targetMuscles: 'Ngực',
        durationMinutes: 40,
        date: todayStr,
        time: '17:00',
      );

      expect(
        container
            .read(workoutScheduleProvider)
            .schedules
            .where((s) => s.date == todayStr)
            .length,
        1,
      );

      // 2. Delete the old schedule
      final oldId = container
          .read(workoutScheduleProvider)
          .schedules
          .firstWhere((s) => s.date == todayStr)
          .id;
      notifier.deleteSchedule(oldId);

      expect(
        container
            .read(workoutScheduleProvider)
            .schedules
            .where((s) => s.date == todayStr),
        isEmpty,
      );

      // 3. AI applies a new schedule for todayStr
      notifier.mergeAppliedSchedules([
        WorkoutScheduleItem(
          id: 'server_999',
          date: todayStr,
          time: '18:00',
          title: 'Lịch AI Mới',
          targetMuscles: 'Lưng',
          durationMinutes: 45,
        ),
      ]);

      final updated = container
          .read(workoutScheduleProvider)
          .schedules
          .where((s) => s.date == todayStr)
          .toList();

      // Only the new AI schedule should be present on that date
      expect(updated.length, 1);
      expect(updated.single.title, 'Lịch AI Mới');
      expect(updated.single.id, 'server_999');
    },
  );

  test(
    'server refresh preserves exercises added from the workout tab',
    () async {
      final repository = _FakePlanningRepository();
      final container = ProviderContainer(
        overrides: [
          workoutSchedulePlanningRepositoryProvider.overrideWithValue(
            repository,
          ),
        ],
      );
      addTearDown(container.dispose);

      final initial = container.read(workoutScheduleProvider).todayWorkout!;
      final extraExercise = findExercise('ex_pec_deck_fly')!;
      container
          .read(workoutSessionProvider.notifier)
          .addExercise(extraExercise);

      repository.schedules = [
        AppliedWorkoutSchedule(
          id: 808,
          date: DateTime.now(),
          time: initial.time,
          title: initial.title,
        ),
      ];
      await container
          .read(workoutScheduleProvider.notifier)
          .syncFromServer(
            from: DateTime.now().subtract(const Duration(days: 1)),
            to: DateTime.now().add(const Duration(days: 1)),
          );

      final refreshed = container.read(workoutScheduleProvider).todayWorkout!;
      expect(refreshed.id, 'server_808');
      expect(
        refreshed.plannedExercises.map((exercise) => exercise.name),
        contains(extraExercise.name),
      );
    },
  );

  test(
    'server schedule refresh retains exercise names and primary muscles',
    () async {
      final repository = _FakePlanningRepository();
      final container = ProviderContainer(
        overrides: [
          workoutSchedulePlanningRepositoryProvider.overrideWithValue(
            repository,
          ),
        ],
      );
      addTearDown(container.dispose);

      final tomorrow = DateTime.now().add(const Duration(days: 1));
      repository.schedules = [
        AppliedWorkoutSchedule(
          id: 809,
          date: tomorrow,
          time: '18:00',
          title: 'Lower A',
          plannedExercises: const [
            PlannedExercisePreview(
              name: 'Goblet Squat',
              setsReps: '4x8-12',
              primaryMuscle: 'Đùi trước',
            ),
          ],
        ),
      ];

      await container
          .read(workoutScheduleProvider.notifier)
          .syncFromServer(
            from: DateTime.now(),
            to: tomorrow.add(const Duration(days: 1)),
          );

      final schedule = container
          .read(workoutScheduleProvider)
          .schedules
          .singleWhere((item) => item.id == 'server_809');
      expect(schedule.plannedExercises.single.name, 'Goblet Squat');
      expect(schedule.targetMuscles, 'Đùi trước');
    },
  );

  test(
    'syncFromServer purges mock planned schedules and clears session when server has no workout today',
    () async {
      final repository = _FakePlanningRepository();
      final container = ProviderContainer(
        overrides: [
          workoutSchedulePlanningRepositoryProvider.overrideWithValue(
            repository,
          ),
        ],
      );
      addTearDown(container.dispose);

      // Server returns empty schedule list (no workout today or any day)
      repository.schedules = [];

      await container
          .read(workoutScheduleProvider.notifier)
          .syncFromServer(
            from: DateTime.now().subtract(const Duration(days: 7)),
            to: DateTime.now().add(const Duration(days: 7)),
          );

      final scheduleState = container.read(workoutScheduleProvider);
      expect(scheduleState.hasTodayWorkout, isFalse);
      expect(scheduleState.todayWorkout, isNull);

      final sessionState = container.read(workoutSessionProvider);
      expect(sessionState.exercises, isEmpty);
    },
  );

  test(
    'syncFromServer loads today workout into active session when server has a planned workout today',
    () async {
      final repository = _FakePlanningRepository();
      final container = ProviderContainer(
        overrides: [
          workoutSchedulePlanningRepositoryProvider.overrideWithValue(
            repository,
          ),
        ],
      );
      addTearDown(container.dispose);

      final today = DateTime.now();
      repository.schedules = [
        AppliedWorkoutSchedule(
          id: 990,
          date: today,
          time: '08:00',
          title: 'Morning Upper Body',
          plannedExercises: const [
            PlannedExercisePreview(
              name: 'Barbell Bench Press',
              setsReps: '4x10',
              primaryMuscle: 'Ngực',
            ),
          ],
        ),
      ];

      await container
          .read(workoutScheduleProvider.notifier)
          .syncFromServer(
            from: today.subtract(const Duration(days: 1)),
            to: today.add(const Duration(days: 1)),
          );

      final scheduleState = container.read(workoutScheduleProvider);
      expect(scheduleState.hasTodayWorkout, isTrue);
      expect(scheduleState.todayWorkout?.title, 'Morning Upper Body');

      final sessionState = container.read(workoutSessionProvider);
      expect(sessionState.title, 'Morning Upper Body');
      expect(sessionState.exercises.isNotEmpty, isTrue);
      expect(sessionState.exercises.first.name, 'Barbell Bench Press');
    },
  );

  testWidgets(
    'workout schedule screen on past days displays manual log CTA and hides creation options',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final pastDate = DateTime.now().subtract(const Duration(days: 2));
      final pastDateStr =
          '${pastDate.year.toString().padLeft(4, '0')}-${pastDate.month.toString().padLeft(2, '0')}-${pastDate.day.toString().padLeft(2, '0')}';

      // Ensure no schedules on this past date
      container.read(workoutScheduleProvider.notifier).selectDate(pastDateStr);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: WorkoutScheduleScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Empty state text for past days
      expect(find.text('Chưa có lịch tập ngày này'), findsOneWidget);
      expect(find.text('Ghi lại lịch đã tập bằng tay'), findsOneWidget);

      // Creation options MUST NOT be shown for past days
      expect(find.text('AI tạo lịch tập'), findsNothing);
      expect(find.text('Tự tạo lịch tập'), findsNothing);
      expect(find.text('Áp dụng giáo án có sẵn'), findsNothing);

      // Tap manual log button
      await tester.tap(find.text('Ghi lại lịch đã tập bằng tay'));
      await tester.pumpAndSettle();

      // Modal sheet should appear with date indicator and submit button
      expect(find.text('Lưu vào nhật ký'), findsOneWidget);
      expect(find.textContaining('Buổi tập tự do'), findsWidgets);

      // Tap submit
      await tester.tap(find.text('Lưu vào nhật ký'));
      await tester.pumpAndSettle();

      // Should have recorded workout completion into history
      final history = container.read(workoutScheduleProvider).history;
      expect(history.any((h) => h.date == pastDateStr), isTrue);
    },
  );

  testWidgets(
    'manual log on past day allows configuring exercises and sets/reps',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final pastDate = DateTime.now().subtract(const Duration(days: 2));
      final pastDateStr =
          '${pastDate.year.toString().padLeft(4, '0')}-${pastDate.month.toString().padLeft(2, '0')}-${pastDate.day.toString().padLeft(2, '0')}';

      // Insert an uncompleted schedule for this past date with planned exercises
      container.read(workoutScheduleProvider.notifier).mergeAppliedSchedules([
        WorkoutScheduleItem(
          id: 'past_manual_1',
          date: pastDateStr,
          time: '07:30',
          title: 'Buổi Tập Ngực Quá Khứ',
          targetMuscles: 'Ngực',
          durationMinutes: 45,
          plannedExercises: const [
            PlannedExercisePreview(
              name: 'Barbell Bench Press',
              setsReps: '3x10',
              primaryMuscle: 'Ngực',
            ),
          ],
        ),
      ]);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: WorkoutScheduleScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Select past date
      container.read(workoutScheduleProvider.notifier).selectDate(pastDateStr);
      await tester.pumpAndSettle();

      // Tap manual log button in AppBar
      await tester.tap(find.byIcon(Icons.edit_note_rounded));
      await tester.pumpAndSettle();

      // Verify preloaded exercise and initial sets/reps
      expect(find.text('Barbell Bench Press'), findsWidgets);
      expect(find.text('3 Sets'), findsOneWidget);
      expect(find.text('10 Reps'), findsOneWidget);

      // Increase sets
      final addIcons = find.byIcon(Icons.add);
      await tester.tap(addIcons.at(0));
      await tester.pumpAndSettle();
      expect(find.text('4 Sets'), findsOneWidget);

      // Increase reps
      await tester.tap(addIcons.at(1));
      await tester.pumpAndSettle();
      expect(find.text('11 Reps'), findsOneWidget);

      // Save to history
      await tester.tap(find.text('Lưu vào nhật ký'));
      await tester.pumpAndSettle();

      // Check recorded workout history
      final history = container.read(workoutScheduleProvider).history;
      final loggedHistory = history.firstWhere((h) => h.date == pastDateStr);
      expect(loggedHistory.workoutName, 'Buổi Tập Ngực Quá Khứ');
      expect(loggedHistory.exercises, isNotEmpty);
      expect(
        loggedHistory.exercises.first.exerciseName,
        anyOf('Barbell Bench Press', 'Đẩy ngực ngang với tạ đòn'),
      );
      expect(loggedHistory.exercises.first.sets.length, 4);
      expect(loggedHistory.exercises.first.sets.first.reps, 11);

      // Check updated schedule item
      final updatedSchedule = container
          .read(workoutScheduleProvider)
          .schedules
          .firstWhere((s) => s.date == pastDateStr);
      expect(updatedSchedule.status, ScheduleStatus.completed);
      expect(updatedSchedule.plannedExercises.first.setsReps, '4x11');
    },
  );

  testWidgets(
    'workout schedule screen on past day with schedule shows completed badge and hides swap/move buttons',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final pastDate = DateTime.now().subtract(const Duration(days: 1));
      final pastDateStr =
          '${pastDate.year.toString().padLeft(4, '0')}-${pastDate.month.toString().padLeft(2, '0')}-${pastDate.day.toString().padLeft(2, '0')}';

      // Insert a schedule for this past date
      container.read(workoutScheduleProvider.notifier).mergeAppliedSchedules([
        WorkoutScheduleItem(
          id: 'past_item_1',
          date: pastDateStr,
          time: '08:00',
          title: 'Push Day Quá Khứ',
          targetMuscles: 'Ngực, Vai, Tay sau',
          durationMinutes: 50,
          status: ScheduleStatus.completed,
        ),
      ]);
      container.read(workoutScheduleProvider.notifier).selectDate(pastDateStr);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: WorkoutScheduleScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Workout title should be visible
      expect(find.text('Push Day Quá Khứ'), findsOneWidget);

      // "Đã hoàn thành" status should be visible
      expect(find.text('Đã hoàn thành'), findsWidgets);
      expect(find.text('ĐÃ HOÀN THÀNH'), findsWidgets);

      // "Đổi buổi" and "Đổi ngày" and "Bắt đầu tập ngay" MUST NOT be shown for past days
      expect(find.text('Đổi buổi'), findsNothing);
      expect(find.text('Đổi ngày'), findsNothing);
      expect(find.text('Bắt đầu tập ngay'), findsNothing);
    },
  );

  testWidgets(
    'workout schedule screen allows editing exercises inside an existing schedule',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final todayStr =
          '${DateTime.now().year.toString().padLeft(4, '0')}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';
      container.read(workoutScheduleProvider.notifier).selectDate(todayStr);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: WorkoutScheduleScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Check that "Sửa bài tập" button exists
      expect(find.text('Sửa bài tập'), findsOneWidget);

      // Tap "Sửa bài tập"
      await tester.tap(find.text('Sửa bài tập'));
      await tester.pumpAndSettle();

      // Modal should be open
      expect(find.text('Sửa bài tập trong lịch'), findsOneWidget);
      expect(find.text('Thêm bài tập mới'), findsOneWidget);

      // Tap "Thêm bài tập mới"
      await tester.tap(find.text('Thêm bài tập mới'));
      await tester.pumpAndSettle();

      // Exercise picker should appear
      expect(find.textContaining('Chọn bài tập'), findsWidgets);

      // Pick an exercise from the list
      await tester.tap(find.text('Barbell Bench Press').last);
      await tester.pumpAndSettle();

      // Tap "Lưu thay đổi"
      final saveButtonFinder = find.textContaining('Lưu thay đổi');
      expect(saveButtonFinder, findsOneWidget);
      await tester.tap(saveButtonFinder);
      await tester.pumpAndSettle();

      // Verify schedule updated in provider
      final todaySchedule = container
          .read(workoutScheduleProvider)
          .schedules
          .firstWhere((s) => s.date == todayStr);
      expect(todaySchedule.plannedExercises.length, greaterThan(4));
    },
  );

  testWidgets(
    'workout tab screen displays exercises when today has a scheduled workout',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final now = DateTime.now();
      final todayStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Start with a cleared session
      container.read(workoutSessionProvider.notifier).clearSession();

      // Add a schedule for today
      container
          .read(workoutScheduleProvider.notifier)
          .addSchedule(
            title: 'Buổi tập ngực hôm nay',
            targetMuscles: 'Ngực • Tay sau',
            durationMinutes: 45,
            date: todayStr,
            time: '18:00',
            plannedExercises: const [
              PlannedExercisePreview(
                name: 'Barbell Bench Press',
                setsReps: '4x10',
              ),
              PlannedExercisePreview(
                name: 'Incline Dumbbell Press',
                setsReps: '3x12',
              ),
            ],
          );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: WorkoutTabScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Should display today's workout title and exercise count
      expect(find.text('Buổi tập ngực hôm nay'), findsOneWidget);
      expect(find.textContaining('2 bài'), findsWidgets);
      expect(find.text('Barbell Bench Press'), findsOneWidget);
      expect(find.text('Incline Dumbbell Press'), findsOneWidget);
      expect(find.text('Hôm nay chưa có lịch tập'), findsNothing);
    },
  );

  test(
    'createPersonalProgram posts program data correctly to backend',
    () async {
      final adapter = _PlanningApiAdapter();
      final dio = Dio()..httpClientAdapter = adapter;
      final repository = WorkoutSchedulePlanningRepository(dio);

      final result = await repository.createPersonalProgram(
        name: 'Giáo án ngực tay sau của tôi',
        programType: 'HYPERTROPHY',
        description: 'Chuyên biệt ngực',
        days: [
          ScheduleDraftDay(
            date: DateTime(2026, 3, 2),
            time: '17:30',
            title: 'Ngực + Tay sau',
            exercises: [
              ScheduleDraftExercise(
                exercise: exerciseCatalog.first,
                targetSets: 4,
                targetRepsMin: 8,
                targetRepsMax: 12,
                restSeconds: 90,
              ),
            ],
          ),
        ],
      );

      expect(adapter.programBody, isNotNull);
      expect(adapter.programBody!['name'], 'Giáo án ngực tay sau của tôi');
      expect(adapter.programBody!['programType'], 'HYPERTROPHY');
      expect(result.name, 'Giáo án ngực tay sau của tôi');
    },
  );

  testWidgets(
    'WorkoutBuilderScreen can save custom program as personal template',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fakeRepo = _FakePlanningRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workoutSchedulePlanningRepositoryProvider.overrideWithValue(
              fakeRepo,
            ),
          ],
          child: const MaterialApp(
            home: WorkoutBuilderScreen(initialDate: '2026-03-02'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Ensure save button is visible and tap it
      final saveBtn = find.text('Lưu');
      expect(saveBtn, findsOneWidget);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      // Dialog options appear
      expect(find.textContaining('Lưu giáo án'), findsOneWidget);
      expect(find.text('Chỉ lưu vào Giáo án cá nhân'), findsOneWidget);

      await tester.tap(find.text('Chỉ lưu vào Giáo án cá nhân'));
      await tester.pumpAndSettle();

      expect(fakeRepo.personalProgramCreated, isTrue);
    },
  );

  testWidgets(
    'WorkoutBuilderScreen removes quick goal presets/rest timer and allows swiping exercise left for actions',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fakeRepo = _FakePlanningRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workoutSchedulePlanningRepositoryProvider.overrideWithValue(
              fakeRepo,
            ),
          ],
          child: const MaterialApp(
            home: WorkoutBuilderScreen(initialDate: '2026-03-02'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Quick goal chips like 'Tăng cơ (3x10-12)' and rest timers should NOT be present
      expect(find.textContaining('Tăng cơ (3x10-12)'), findsNothing);
      expect(find.textContaining('Nghỉ giữa hiệp'), findsNothing);

      // ReorderableListView should be present for exercises
      expect(find.byType(ReorderableListView), findsWidgets);

      // Drag indicator handle should be present
      expect(find.byIcon(Icons.drag_indicator_rounded), findsWidgets);

      // Swipe first exercise to the left
      await tester.drag(find.byIcon(Icons.drag_indicator_rounded).first, const Offset(-300, 0));
      await tester.pumpAndSettle();

      // 'Thay bài' and 'Xóa bài' action buttons are revealed
      expect(find.text('Thay bài'), findsWidgets);
      expect(find.text('Xóa bài'), findsWidgets);
    },
  );

  testWidgets(
    'WorkoutScheduleCreateScreen shows "Tạo thêm giáo án mới" button under personal programs',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fakeRepo = _FakePlanningRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workoutSchedulePlanningRepositoryProvider.overrideWithValue(
              fakeRepo,
            ),
          ],
          child: MaterialApp(
            home: WorkoutScheduleCreateScreen(
              initialDate: DateTime(2026, 3, 2),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Upper Lower cá nhân'), findsOneWidget);
      expect(find.text('Tạo thêm giáo án mới'), findsOneWidget);
    },
  );

  testWidgets(
    'WorkoutBuilderScreen has "Tạo mới" action to create another workout plan',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fakeRepo = _FakePlanningRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workoutSchedulePlanningRepositoryProvider.overrideWithValue(
              fakeRepo,
            ),
          ],
          child: const MaterialApp(
            home: WorkoutBuilderScreen(initialDate: '2026-03-02'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final newBtn = find.text('Tạo mới');
      expect(newBtn, findsOneWidget);

      await tester.tap(newBtn);
      await tester.pumpAndSettle();

      // Confirmation dialog pops up
      expect(find.text('Tạo giáo án mới?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Tạo mới'));
      await tester.pumpAndSettle();

      expect(find.text('Giáo án mới'), findsOneWidget);
    },
  );

  testWidgets(
    'WorkoutScheduleCreateScreen displays exercises and technical guide for selected plan',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workoutSchedulePlanningRepositoryProvider.overrideWithValue(
              _FakePlanningRepository(),
            ),
          ],
          child: const MaterialApp(home: WorkoutScheduleCreateScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on program
      await tester.tap(find.text('Upper Lower cá nhân'));
      await tester.pumpAndSettle();

      // Should display exercise list section
      expect(find.text('BÀI TẬP TRONG BUỔI'), findsOneWidget);
      expect(find.text('Đổi bài'), findsWidgets);
      expect(find.text('Thêm bài tập vào buổi này'), findsOneWidget);
    },
  );

  testWidgets(
    'WorkoutScheduleCreateScreen allows modifying sets/reps and swapping exercise',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workoutSchedulePlanningRepositoryProvider.overrideWithValue(
              _FakePlanningRepository(),
            ),
          ],
          child: const MaterialApp(home: WorkoutScheduleCreateScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Upper Lower cá nhân'));
      await tester.pumpAndSettle();

      // Tap sets/reps badge to open picker
      final setsRepsChips = find.byWidgetPredicate(
        (widget) => widget is Text && widget.data != null && widget.data!.contains('x'),
      );
      expect(setsRepsChips, findsWidgets);
      await tester.tap(setsRepsChips.first);
      await tester.pumpAndSettle();

      // Sets/Reps modal should open
      expect(find.text('Số hiệp & Số lần tập'), findsOneWidget);
      expect(find.text('3x15'), findsOneWidget);

      // Select preset 3x15
      await tester.tap(find.text('3x15'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Xác nhận: 3x15'));
      await tester.pumpAndSettle();

      // Expect 'Khôi phục' button to appear since day was modified
      expect(find.text('Khôi phục'), findsOneWidget);

      // Tap "Khôi phục" to restore default
      await tester.tap(find.text('Khôi phục'));
      await tester.pumpAndSettle();

      expect(find.text('Khôi phục'), findsNothing);
    },
  );

  testWidgets(
    'WorkoutScheduleCreateScreen allows swiping personal plan left to reveal and delete program',
    (tester) async {
      final fakeRepo = _FakePlanningRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workoutSchedulePlanningRepositoryProvider.overrideWithValue(
              fakeRepo,
            ),
          ],
          child: const MaterialApp(home: WorkoutScheduleCreateScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Upper Lower cá nhân'), findsOneWidget);

      await tester.drag(find.text('Upper Lower cá nhân'), const Offset(-200, 0));
      await tester.pumpAndSettle();

      expect(find.text('Xoá giáo án'), findsWidgets);

      await tester.tap(find.text('Xoá giáo án').first);
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Bạn có chắc chắn muốn xoá giáo án "Upper Lower cá nhân" không? Thao tác này không thể hoàn tác.',
        ),
        findsOneWidget,
      );
    },
  );
}

class _PlanningApiAdapter implements HttpClientAdapter {
  String? searchQuery;
  Map<String, dynamic>? proposalBody;
  Map<String, dynamic>? programBody;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.method == 'GET' && options.path == '/api/v1/exercises') {
      searchQuery = options.queryParameters['q'] as String?;
      return _jsonResponse(200, {
        'data': {
          'content': [
            {'id': 321, 'name': exerciseCatalog.first.name},
          ],
        },
      });
    }
    if (options.method == 'POST' &&
        options.path == '/api/v1/workout-schedule-proposals') {
      proposalBody = options.data as Map<String, dynamic>;
      return _jsonResponse(200, {
        'data': {
          'id': 900,
          'sourceType': 'AI',
          'scope': 'ONE_DAY',
          'expiresAt': '2099-03-01T12:00:00Z',
          'items': <dynamic>[],
        },
      });
    }
    if (options.method == 'POST' &&
        options.path == '/api/v1/workout-programs') {
      programBody = options.data as Map<String, dynamic>;
      return _jsonResponse(201, {
        'data': {
          'id': 777,
          'name': programBody?['name'] ?? 'Custom Program',
          'programType': programBody?['programType'] ?? 'CUSTOM',
          'totalDays': (programBody?['days'] as List?)?.length ?? 1,
          'sourceType': 'USER_PROGRAM',
        },
      });
    }
    if (options.method == 'DELETE' &&
        options.path.startsWith('/api/v1/workout-programs/')) {
      return _jsonResponse(200, {'data': null});
    }
    return _jsonResponse(404, {'message': 'Not found'});
  }

  ResponseBody _jsonResponse(int statusCode, Map<String, dynamic> body) {
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
