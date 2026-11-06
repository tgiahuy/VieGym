import 'package:dio/dio.dart';
import 'package:viegym/features/ai/data/ai_repository.dart';
import 'package:viegym/features/ai/domain/ai_models.dart';
import 'package:viegym/features/ai/domain/ai_plan_models.dart';

/// Answers the AI plan endpoints instantly so widget tests never hit the
/// network (real HTTP never completes inside `testWidgets`' fake async zone).
class FakeAiPlanRepository extends AiRepository {
  FakeAiPlanRepository() : super(Dio());

  int workoutRequests = 0;

  @override
  Future<List<AiRecommendation>> getDailyRecommendations() async => const [];

  @override
  Future<AiWorkoutPlan> generateWorkout({
    DateTime? targetDate,
    required List<String> muscleCodes,
    required List<String> equipmentCodes,
    required int durationMinutes,
    required String intensity,
  }) async {
    workoutRequests++;
    return AiWorkoutPlan.fromJson({
      'recommendationId': 1,
      'version': 0,
      'planTitle': 'Buổi tập Ngực AI',
      'rationale': 'Compound trước, isolation sau.',
      'estimatedDurationMinutes': 40,
      'generatedBy': 'gemini',
      'personalized': true,
      'exercises': [
        {
          'exerciseId': 101,
          'name': 'Barbell Bench Press',
          'primaryMuscle': 'CHEST',
          'equipmentCodes': ['BARBELL', 'BENCH'],
          'targetSets': 4,
          'targetRepsMin': 6,
          'targetRepsMax': 10,
          'restSeconds': 120,
          'coachingTip': 'Giữ bả vai ép chặt.',
        },
        {
          'exerciseId': 102,
          'name': 'Push Up',
          'primaryMuscle': 'CHEST',
          'equipmentCodes': ['BODYWEIGHT'],
          'targetSets': 3,
          'targetRepsMin': 12,
          'targetRepsMax': 15,
          'restSeconds': 60,
        },
      ],
    });
  }
}
