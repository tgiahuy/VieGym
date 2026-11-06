import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viegym/features/ai/application/ai_coach_controller.dart';
import 'package:viegym/features/ai/data/ai_repository.dart';
import 'package:viegym/features/ai/domain/ai_models.dart';
import 'package:viegym/features/ai/domain/ai_plan_models.dart';

void main() {
  group('AI plan models', () {
    test('workout plan parses backend response and formats prescriptions', () {
      final plan = AiWorkoutPlan.fromJson({
        'recommendationId': 16,
        'version': 0,
        'planTitle': 'Buổi tập Ngực và Tay sau',
        'rationale': 'Compound trước.',
        'estimatedDurationMinutes': 28,
        'generatedBy': 'gemini',
        'personalized': true,
        'exercises': [
          {
            'exerciseId': 118,
            'name': 'Incline Dumbbell Press',
            'primaryMuscle': 'CHEST',
            'equipmentCodes': ['BENCH', 'DUMBBELL'],
            'targetSets': 4,
            'targetRepsMin': 8,
            'targetRepsMax': 12,
            'restSeconds': 90,
            'targetWeightKg': 22.5,
            'coachingTip': 'Hạ tạ chậm.',
          },
          {
            'exerciseId': 7,
            'name': 'Push Up',
            'primaryMuscle': 'CHEST',
            'targetSets': 3,
            'targetRepsMin': 12,
            'targetRepsMax': 12,
            'restSeconds': 60,
            'targetWeightKg': null,
            'coachingTip': '  ',
          },
        ],
      });

      expect(plan.isAiGenerated, isTrue);
      expect(plan.exercises.first.equipmentCodes, ['BENCH', 'DUMBBELL']);
      expect(
        plan.exercises.first.prescription,
        '4 hiệp × 8-12 reps • nghỉ 90s • 22.5 kg',
      );
      expect(plan.exercises.last.prescription, '3 hiệp × 12 reps • nghỉ 60s');
      expect(plan.exercises.last.coachingTip, isNull);
    });

    test('heuristic plans are labelled as not AI generated', () {
      final plan = AiWorkoutPlan.fromJson({
        'generatedBy': 'heuristic',
        'exercises': <Object>[],
      });
      expect(plan.isAiGenerated, isFalse);
    });

    test('meal plan keeps backend-computed calories per item', () {
      final plan = AiMealPlan.fromJson({
        'generatedBy': 'mixed',
        'personalized': true,
        'rationale': 'Đủ đạm.',
        'summary': {'targetCalories': 1787, 'generatedCalories': 1799.7},
        'meals': [
          {
            'recommendationId': 20,
            'version': 0,
            'mealType': 'LUNCH',
            'dishName': 'Bún bò Huế + Rau muống luộc',
            'coachingReason': 'Món nước.',
            'targetCalories': 962,
            'calories': 841.5,
            'protein': 40,
            'carbs': 100,
            'fat': 20,
            'generatedBy': 'gemini',
            'items': [
              {
                'foodId': 3,
                'name': 'Bún bò Huế',
                'servingUnit': 'tô',
                'servingMultiplier': 1.5,
                'calories': 744.0,
                'protein': 30,
                'carbs': 90,
                'fat': 18,
              },
            ],
          },
        ],
      });

      final lunch = plan.meals.single;
      expect(plan.targetCalories, 1787);
      expect(lunch.isAiGenerated, isTrue);
      expect(lunch.items.single.portion, '1.5 tô');
      expect(lunch.items.single.calories, 744.0);
    });
  });

  group('AI Coach chat offline handling', () {
    test(
      'a general question offline shows an honest error and can be retried',
      () async {
        final repository = _FlakyAiRepository();
        final container = ProviderContainer(
          overrides: [aiRepositoryProvider.overrideWithValue(repository)],
        );
        addTearDown(container.dispose);
        final coach = container.read(aiCoachProvider.notifier);

        await coach.send('Hôm nay tôi nên ăn gì để tăng cơ?');
        var state = container.read(aiCoachProvider);
        expect(state.retryText, 'Hôm nay tôi nên ăn gì để tăng cơ?');
        expect(state.messages.last.text, contains('chưa kết nối được'));
        expect(state.messages.last.proposal, isNull);

        repository.online = true;
        await coach.retry();
        state = container.read(aiCoachProvider);
        expect(state.retryText, isNull);
        expect(state.messages.last.text, 'Bạn nên ăn thêm ức gà.');
        expect(
          state.messages.where((m) => m.id.startsWith('assistant_offline_')),
          isEmpty,
        );
        expect(
          state.messages.where(
            (m) => m.text == 'Hôm nay tôi nên ăn gì để tăng cơ?',
          ),
          hasLength(1),
        );
      },
    );
  });
}

class _FlakyAiRepository extends AiRepository {
  _FlakyAiRepository() : super(Dio());

  bool online = false;

  @override
  Future<List<AiRecommendation>> getDailyRecommendations() async => const [];

  @override
  Future<AiConversationSummary> createConversation({
    required String title,
    required bool personalized,
  }) async {
    if (!online) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/ai/conversations'),
        type: DioExceptionType.connectionError,
      );
    }
    return AiConversationSummary.fromJson({
      'id': 1,
      'title': title,
      'requestedMode': 'PERSONALIZED',
    });
  }

  @override
  Future<AiMessageExchange> sendMessage(
    int conversationId,
    String content,
  ) async {
    return AiMessageExchange(
      mode: 'PERSONALIZED',
      user: AiChatMessage(
        id: 'u1',
        sender: AiMessageSender.user,
        text: content,
      ),
      assistant: const AiChatMessage(
        id: 'a1',
        sender: AiMessageSender.assistant,
        text: 'Bạn nên ăn thêm ức gà.',
      ),
    );
  }
}
