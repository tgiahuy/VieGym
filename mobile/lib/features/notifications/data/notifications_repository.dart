import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../domain/notification_models.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((
  ref,
) {
  return NotificationsRepository(ref.watch(dioProvider));
});

class NotificationsRepository {
  const NotificationsRepository(this._dio);
  final Dio _dio;

  Future<List<AppNotification>> list({bool unreadOnly = false}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/notifications',
      queryParameters: {if (unreadOnly) 'status': 'SENT', 'size': 50},
    );
    final data = _map(response.data?['data']);
    return _list(data['content']).map(_notification).toList();
  }

  Future<int> unreadCount() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/notifications/unread-count',
    );
    return (response.data?['data'] as num?)?.toInt() ?? 0;
  }

  Future<void> read(String id) =>
      _dio.post<void>('/api/v1/notifications/$id/read');
  Future<void> readAll() => _dio.post<void>('/api/v1/notifications/read-all');
  Future<void> delete(String id) =>
      _dio.delete<void>('/api/v1/notifications/$id');

  Future<NotificationPreference> preference() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/notifications/preferences',
    );
    return NotificationPreference.fromJson(_map(response.data?['data']));
  }

  Future<NotificationPreference> savePreference(
    NotificationPreference value,
  ) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/api/v1/notifications/preferences',
      data: value.toJson(),
    );
    return NotificationPreference.fromJson(_map(response.data?['data']));
  }

  static AppNotification _notification(Map<String, dynamic> json) {
    final type = switch (json['type']) {
      'WORKOUT_REMINDER' => NotificationType.workoutReminder,
      'MEAL_REMINDER' ||
      'WEIGHT_REMINDER' => NotificationType.nutritionSuggestion,
      'AI_RECOMMENDATION' => NotificationType.aiRecommendation,
      'WEEKLY_REVIEW' => NotificationType.recoveryAlert,
      _ => NotificationType.system,
    };
    return AppNotification(
      id: '${json['id']}',
      title: '${json['title'] ?? ''}',
      message: '${json['content'] ?? ''}',
      timestamp:
          DateTime.tryParse('${json['sentAt'] ?? json['scheduledAt'] ?? ''}') ??
          DateTime.now(),
      type: type,
      isRead: json['status'] == 'READ',
      actionRoute: json['deepLink'] as String?,
    );
  }
}

Map<String, dynamic> _map(dynamic value) =>
    value is Map<String, dynamic> ? value : <String, dynamic>{};
List<Map<String, dynamic>> _list(dynamic value) => value is List
    ? value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList()
    : const [];
