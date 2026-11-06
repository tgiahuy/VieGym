import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../domain/ai_models.dart';
import '../domain/ai_plan_models.dart';

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepository(ref.watch(dioProvider));
});

class AiRepository {
  const AiRepository(this._dio);
  final Dio _dio;

  Future<bool> getConsent() async {
    final response = await _dio.get<Map<String, dynamic>>('/api/v1/ai/consent');
    return _data(response.data)['mode'] == 'ENABLED';
  }

  Future<bool> updateConsent(bool enabled) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/api/v1/ai/consent',
      data: {
        'mode': enabled ? 'ENABLED' : 'DISABLED',
        'consentVersion': 'v1.0',
        'source': 'SETTINGS',
      },
    );
    return _data(response.data)['mode'] == 'ENABLED';
  }

  Future<AiConversationSummary> createConversation({
    required String title,
    required bool personalized,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/ai/conversations',
      data: {
        'title': title,
        'requestedMode': personalized ? 'PERSONALIZED' : 'GENERAL_KNOWLEDGE',
      },
    );
    return AiConversationSummary.fromJson(_data(response.data));
  }

  Future<List<AiConversationSummary>> getConversations() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/ai/conversations',
    );
    return _list(
      response.data?['data'],
    ).map(AiConversationSummary.fromJson).toList();
  }

  Future<AiMessageExchange> sendMessage(
    int conversationId,
    String content,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/ai/conversations/$conversationId/messages',
      data: {'content': content},
    );
    final json = _data(response.data);
    return AiMessageExchange(
      mode: '${json['mode'] ?? 'GENERAL_KNOWLEDGE'}',
      user: _message(_map(json['userMessage'])),
      assistant: _message(_map(json['assistantMessage'])),
    );
  }

  Future<List<AiRecommendation>> getDailyRecommendations() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/ai/recommendations/daily',
    );
    final data = _data(response.data);
    return _list(data['recommendations']).map(_recommendation).toList();
  }

  Future<List<AiRecommendation>> generateDailyRecommendations() async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/ai/recommendations/daily/generations',
      data: <String, dynamic>{},
      options: Options(
        headers: {
          'Idempotency-Key':
              'daily-${DateTime.now().toUtc().toIso8601String().substring(0, 10)}',
        },
      ),
    );
    final data = _data(response.data);
    return _list(data['recommendations']).map(_recommendation).toList();
  }

  Future<void> apply(AiRecommendation recommendation) async {
    await _dio.post<void>(
      '/api/v1/ai/recommendations/${recommendation.id}/apply',
      data: {'expectedVersion': recommendation.version},
      options: Options(
        headers: {'Idempotency-Key': 'apply-${recommendation.id}'},
      ),
    );
  }

  Future<void> dismiss(AiRecommendation recommendation) async {
    await _dio.post<void>(
      '/api/v1/ai/recommendations/${recommendation.id}/dismiss',
      data: {'expectedVersion': recommendation.version},
      options: Options(
        headers: {'Idempotency-Key': 'dismiss-${recommendation.id}'},
      ),
    );
  }

  /// Generates one workout. [muscleCodes] and [equipmentCodes] use backend
  /// codes (`CHEST`, `DUMBBELL`…); empty equipment = the user's saved set.
  Future<AiWorkoutPlan> generateWorkout({
    DateTime? targetDate,
    required List<String> muscleCodes,
    required List<String> equipmentCodes,
    required int durationMinutes,
    required String intensity,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/ai/workouts/generate',
      data: {
        if (targetDate != null) 'targetDate': _date(targetDate),
        'targetMuscles': muscleCodes,
        'equipmentCodes': equipmentCodes,
        'durationMinutes': durationMinutes,
        'intensity': intensity,
      },
      options: Options(headers: {'Idempotency-Key': _newKey('workout')}),
    );
    return AiWorkoutPlan.fromJson(_data(response.data));
  }

  /// Generates one meal per [mealTypes] entry (BREAKFAST, LUNCH, DINNER, SNACK).
  Future<AiMealPlan> generateMeals({
    DateTime? targetDate,
    required List<String> mealTypes,
    int? maxPrepTimeMinutes,
    String? customPrompt,
  }) async {
    final prompt = customPrompt?.trim() ?? '';
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/ai/meals/generate',
      data: {
        if (targetDate != null) 'targetDate': _date(targetDate),
        'mealTypes': mealTypes,
        'maxPrepTimeMinutes': ?maxPrepTimeMinutes,
        if (prompt.isNotEmpty)
          'customPrompt': prompt.length > 300
              ? prompt.substring(0, 300)
              : prompt,
      },
      options: Options(headers: {'Idempotency-Key': _newKey('meals')}),
    );
    return AiMealPlan.fromJson(_data(response.data));
  }

  /// Applies a generated plan (or one of its meals) through the backend, which
  /// writes it to the workout schedule or the meal diary.
  Future<Map<String, dynamic>> applyPlan({
    required int recommendationId,
    required int version,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/ai/recommendations/$recommendationId/apply',
      data: {'expectedVersion': version},
      options: Options(
        headers: {'Idempotency-Key': 'apply-$recommendationId-v$version'},
      ),
    );
    return _map(_data(response.data)['mutationResult']);
  }

  static final Random _random = Random();

  /// A fresh key per generate call; the backend replays results for a reused key.
  static String _newKey(String prefix) =>
      '$prefix-${DateTime.now().microsecondsSinceEpoch}-${_random.nextInt(1 << 32)}';

  static String _date(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static AiChatMessage _message(Map<String, dynamic> json) {
    return AiChatMessage(
      id: '${json['id']}',
      sender: json['role'] == 'USER'
          ? AiMessageSender.user
          : AiMessageSender.assistant,
      text: '${json['content'] ?? ''}',
    );
  }

  static AiRecommendation _recommendation(Map<String, dynamic> json) {
    final action = '${json['allowedAction'] ?? 'NONE'}';
    return AiRecommendation(
      id: '${json['id']}',
      type: switch ('${json['type']}') {
        'NUTRITION' => RecommendationType.nutrition,
        'HEALTH' => RecommendationType.recovery,
        'WORKOUT' => RecommendationType.workout,
        _ => RecommendationType.trainingBalance,
      },
      title: '${json['title'] ?? ''}',
      description: '${json['content'] ?? ''}',
      reason: '${json['reason'] ?? ''}',
      actionType: switch (action) {
        'ADD_MEAL_ENTRY_PROPOSAL' => RecommendationActionType.adjustNutrition,
        'CREATE_WORKOUT_SCHEDULE_PROPOSAL' =>
          RecommendationActionType.applySchedule,
        _ => RecommendationActionType.viewRecovery,
      },
      status: switch ('${json['status']}') {
        'APPLIED' => ProposalStatus.applied,
        'DISMISSED' || 'EXPIRED' => ProposalStatus.dismissed,
        _ => ProposalStatus.pending,
      },
      version: (json['version'] as num?)?.toInt() ?? 0,
      metadata: _map(json['actionPreview']),
    );
  }
}

Map<String, dynamic> _data(Map<String, dynamic>? envelope) =>
    _map(envelope?['data']);
Map<String, dynamic> _map(Object? value) =>
    value is Map<String, dynamic> ? value : <String, dynamic>{};
List<Map<String, dynamic>> _list(Object? value) => value is List
    ? value.whereType<Map<String, dynamic>>().toList()
    : <Map<String, dynamic>>[];
