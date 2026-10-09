import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viegym/features/workout/application/workout_schedule_controller.dart';
import 'package:viegym/features/workout/application/workout_session_controller.dart';
import 'package:viegym/features/workout/presentation/widgets/body_muscle_map.dart';
import 'package:viegym/features/workout/presentation/widgets/flippable_muscle_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FlippableMuscleCard widget tests', () {
    testWidgets(
      'Card with only front target muscles can flip to back side on tap',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: FlippableMuscleCard(
                  targetMuscles: ['Ngực', 'Vai', 'Bụng'],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Initial side should be front
        expect(find.text('Mặt trước'), findsOneWidget);
        expect(find.byType(BodyMuscleMap), findsOneWidget);

        // Tap the card to flip to back
        await tester.tap(find.byType(FlippableMuscleCard));
        await tester.pumpAndSettle();

        // Should now show back side
        expect(find.text('Mặt sau'), findsOneWidget);

        // Tap again to flip back to front
        await tester.tap(find.byType(FlippableMuscleCard));
        await tester.pumpAndSettle();

        // Should be front again
        expect(find.text('Mặt trước'), findsOneWidget);
      },
    );

    testWidgets(
      'Card with only back target muscles initially shows back and can flip to front',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: FlippableMuscleCard(
                  targetMuscles: ['Lưng xô', 'Cầu vai'],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Preferred side for only back targets is back side
        expect(find.text('Mặt sau'), findsOneWidget);

        // Tap to flip to front
        await tester.tap(find.byType(FlippableMuscleCard));
        await tester.pumpAndSettle();

        expect(find.text('Mặt trước'), findsOneWidget);
      },
    );

    testWidgets(
      'Card with compound muscles and delimiters (e.g. "Đùi sau & Mông") correctly parses and flips',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: FlippableMuscleCard(
                  targetMuscles: ['Đùi sau & Mông', 'Ngực • Tay trước'],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Both front and back have targets, defaults to front
        expect(find.text('Mặt trước'), findsOneWidget);

        // Tap to flip to back
        await tester.tap(find.byType(FlippableMuscleCard));
        await tester.pumpAndSettle();

        expect(find.text('Mặt sau'), findsOneWidget);
      },
    );

    testWidgets(
      'Long press opens detail modal with flip button that flips the map',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: FlippableMuscleCard(
                  targetMuscles: ['Ngực', 'Tay trước'],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Long press to show modal
        await tester.longPress(find.byType(FlippableMuscleCard));
        await tester.pumpAndSettle();

        expect(find.text('Nhóm cơ buổi tập hôm nay'), findsOneWidget);
        expect(find.text('Xem mặt sau'), findsOneWidget);

        // Tap flip button inside modal
        await tester.tap(find.text('Xem mặt sau'));
        await tester.pumpAndSettle();

        expect(find.text('Xem mặt trước'), findsOneWidget);
      },
    );

    testWidgets(
      'Card updates correctly when a new back exercise is added dynamically',
      (tester) async {
        var targetMuscles = <String>['Ngực', 'Tay trước'];

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return MaterialApp(
                home: Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FlippableMuscleCard(targetMuscles: targetMuscles),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              targetMuscles = [
                                ...targetMuscles,
                                'Lưng xô',
                              ];
                            });
                          },
                          child: const Text('Add Back Exercise'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        // Initial state is front
        expect(find.text('Mặt trước'), findsOneWidget);

        // Add back exercise
        await tester.tap(find.text('Add Back Exercise'));
        await tester.pumpAndSettle();

        // Flip to back side
        await tester.tap(find.byType(FlippableMuscleCard));
        await tester.pumpAndSettle();

        // Should now show back side with back muscles recognized
        expect(find.text('Mặt sau'), findsOneWidget);
      },
    );

    testWidgets(
      'Deleting today workout clears active session and shows empty state',
      (tester) async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final scheduleNotifier =
            container.read(workoutScheduleProvider.notifier);

        // Delete all existing today schedules
        final todayItem =
            container.read(workoutScheduleProvider).todayWorkout;
        if (todayItem != null) {
          scheduleNotifier.deleteSchedule(todayItem.id);
        }
        container.read(workoutSessionProvider.notifier).clearSession();

        expect(
          container.read(workoutScheduleProvider).hasTodayWorkout,
          isFalse,
        );
        expect(
          container.read(workoutSessionProvider).exercises,
          isEmpty,
        );
      },
    );
  });
}
