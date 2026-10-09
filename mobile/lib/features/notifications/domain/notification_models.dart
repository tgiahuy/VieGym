import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

enum NotificationType {
  aiRecommendation(
    label: 'GỢI Ý AI',
    icon: Icons.auto_awesome_rounded,
    color: AppColors.aiViolet,
  ),
  workoutReminder(
    label: 'LUYỆN TẬP',
    icon: Icons.fitness_center_rounded,
    color: AppColors.primary,
  ),
  recoveryAlert(
    label: 'PHỤC HỒI',
    icon: Icons.battery_charging_full_rounded,
    color: AppColors.cyan,
  ),
  nutritionSuggestion(
    label: 'DINH DƯỠNG',
    icon: Icons.restaurant_menu_rounded,
    color: AppColors.amber,
  ),
  system(
    label: 'HỆ THỐNG',
    icon: Icons.notifications_rounded,
    color: AppColors.info,
  );

  const NotificationType({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.type = NotificationType.aiRecommendation,
    this.isRead = false,
    this.actionRoute,
    this.actionLabel,
    this.aiRecommendationId,
  });

  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;
  final String? actionRoute;
  final String? actionLabel;
  final String? aiRecommendationId;

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    NotificationType? type,
    bool? isRead,
    String? actionRoute,
    String? actionLabel,
    String? aiRecommendationId,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      actionRoute: actionRoute ?? this.actionRoute,
      actionLabel: actionLabel ?? this.actionLabel,
      aiRecommendationId: aiRecommendationId ?? this.aiRecommendationId,
    );
  }
}

class NotificationPreference {
  const NotificationPreference({
    this.workoutEnabled = true,
    this.mealEnabled = true,
    this.weightEnabled = true,
    this.recommendationEnabled = false,
    this.weeklyReviewEnabled = false,
    this.quietHoursStart,
    this.quietHoursEnd,
    this.timezone = 'Asia/Ho_Chi_Minh',
  });

  factory NotificationPreference.fromJson(Map<String, dynamic> json) {
    return NotificationPreference(
      workoutEnabled: json['workoutEnabled'] as bool? ?? true,
      mealEnabled: json['mealEnabled'] as bool? ?? true,
      weightEnabled: json['weightEnabled'] as bool? ?? true,
      recommendationEnabled: json['recommendationEnabled'] as bool? ?? false,
      weeklyReviewEnabled: json['weeklyReviewEnabled'] as bool? ?? false,
      quietHoursStart: json['quietHoursStart'] as String?,
      quietHoursEnd: json['quietHoursEnd'] as String?,
      timezone: json['timezone'] as String? ?? 'Asia/Ho_Chi_Minh',
    );
  }

  final bool workoutEnabled;
  final bool mealEnabled;
  final bool weightEnabled;
  final bool recommendationEnabled;
  final bool weeklyReviewEnabled;
  final String? quietHoursStart;
  final String? quietHoursEnd;
  final String timezone;

  NotificationPreference copyWith({
    bool? workoutEnabled,
    bool? mealEnabled,
    bool? weightEnabled,
    bool? recommendationEnabled,
    bool? weeklyReviewEnabled,
  }) => NotificationPreference(
    workoutEnabled: workoutEnabled ?? this.workoutEnabled,
    mealEnabled: mealEnabled ?? this.mealEnabled,
    weightEnabled: weightEnabled ?? this.weightEnabled,
    recommendationEnabled: recommendationEnabled ?? this.recommendationEnabled,
    weeklyReviewEnabled: weeklyReviewEnabled ?? this.weeklyReviewEnabled,
    quietHoursStart: quietHoursStart,
    quietHoursEnd: quietHoursEnd,
    timezone: timezone,
  );

  Map<String, dynamic> toJson() => {
    'workoutEnabled': workoutEnabled,
    'mealEnabled': mealEnabled,
    'weightEnabled': weightEnabled,
    'recommendationEnabled': recommendationEnabled,
    'weeklyReviewEnabled': weeklyReviewEnabled,
    'quietHoursStart': quietHoursStart,
    'quietHoursEnd': quietHoursEnd,
    'timezone': timezone,
  };
}
