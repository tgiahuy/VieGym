import 'package:flutter/material.dart';

enum NotificationType {
  aiRecommendation(
    label: 'GỢI Ý AI',
    icon: Icons.auto_awesome_rounded,
    color: Color(0xFFFF2E54),
  ),
  workoutReminder(
    label: 'LUYỆN TẬP',
    icon: Icons.fitness_center_rounded,
    color: Color(0xFF00E5FF),
  ),
  recoveryAlert(
    label: 'PHỤC HỒI',
    icon: Icons.battery_charging_full_rounded,
    color: Color(0xFF00E676),
  ),
  nutritionSuggestion(
    label: 'DINH DƯỠNG',
    icon: Icons.restaurant_menu_rounded,
    color: Color(0xFFFFB300),
  ),
  system(
    label: 'HỆ THỐNG',
    icon: Icons.notifications_rounded,
    color: Color(0xFF8C9EFF),
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
