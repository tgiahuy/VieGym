import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viegym/features/ai/application/ai_coach_controller.dart';
import 'package:viegym/features/ai/domain/ai_models.dart';
import 'package:viegym/features/workout/application/workout_session_controller.dart';
import 'package:viegym/features/workout/domain/workout_models.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  test(
    'Case A: pain request creates pending proposal without changing workout',
    () async {
      final originalId = container
          .read(workoutSessionProvider)
          .exercises
          .first
          .exerciseId;

      await container
          .read(aiCoachProvider.notifier)
          .send(
            'Hôm nay tôi bị đau cổ tay, có bài nào thay Bench Press không?',
          );

      final proposal = container
          .read(aiCoachProvider)
          .messages
          .map((message) => message.proposal)
          .whereType<AlternativeExerciseProposal>()
          .single;
      expect(proposal.status, ProposalStatus.pending);
      expect(
        container.read(workoutSessionProvider).exercises.first.exerciseId,
        originalId,
      );
    },
  );

  test(
    'Case B: apply replaces one exercise and preserves other progress',
    () async {
      container
          .read(workoutSessionProvider.notifier)
          .updateSet(exerciseId: 'ex2', setIndex: 0, completed: true);
      await container
          .read(aiCoachProvider.notifier)
          .send('Tôi đau cổ tay và muốn thay Bench Press bằng bài khác');
      final proposal = container
          .read(aiCoachProvider)
          .messages
          .map((message) => message.proposal)
          .whereType<AlternativeExerciseProposal>()
          .single;
      final selected = proposal.alternatives.first;

      container
          .read(aiCoachProvider.notifier)
          .applyReplacement(proposal.id, selected.exerciseId);

      final session = container.read(workoutSessionProvider);
      expect(session.exercises.first.exerciseId, selected.exerciseId);
      expect(session.exercises[1].exerciseId, 'ex2');
      expect(session.logs['ex2']!.first.completed, isTrue);
    },
  );

  test(
    'Case C: dumbbell-only preference filters incompatible alternatives',
    () async {
      container.read(equipmentPreferencesProvider.notifier).replaceAll({
        EquipmentType.dumbbell,
      });
      await container
          .read(aiCoachProvider.notifier)
          .send('Tôi đau cổ tay và muốn thay Bench Press bằng bài khác');
      final proposal = container
          .read(aiCoachProvider)
          .messages
          .map((message) => message.proposal)
          .whereType<AlternativeExerciseProposal>()
          .single;

      expect(proposal.alternatives, isNotEmpty);
      expect(
        proposal.alternatives.every((item) => item.equipment == 'Tạ đơn'),
        isTrue,
      );
    },
  );

  test(
    'Case D: severe symptoms return safety guidance without proposal',
    () async {
      await container
          .read(aiCoachProvider.notifier)
          .send(
            'Cổ tay đau dữ dội, bị sưng và tê, có bài nào thay Bench Press không?',
          );
      final response = container.read(aiCoachProvider).messages.last;

      expect(response.proposal, isNull);
      expect(response.text, contains('dừng'));
      expect(response.text, contains('chuyên gia y tế'));
    },
  );
}
