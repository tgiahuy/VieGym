import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/notifications_repository.dart';
import '../domain/notification_models.dart';

class NotificationsState {
  const NotificationsState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.preference = const NotificationPreference(),
    this.isLoading = false,
    this.error,
  });

  final List<AppNotification> notifications;
  final int unreadCount;
  final NotificationPreference preference;
  final bool isLoading;
  final String? error;

  bool get hasUnread => unreadCount > 0;

  NotificationsState copyWith({
    List<AppNotification>? notifications,
    int? unreadCount,
    NotificationPreference? preference,
    bool? isLoading,
    String? error,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      preference: preference ?? this.preference,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class NotificationsController extends Notifier<NotificationsState> {
  @override
  NotificationsState build() {
    return _buildInitialState();
  }

  Future<void> refresh() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true);
    try {
      final repository = ref.read(notificationsRepositoryProvider);
      final results = await Future.wait([
        repository.list(),
        repository.unreadCount(),
        repository.preference(),
      ]);
      if (!ref.mounted) return;
      state = NotificationsState(
        notifications: results[0] as List<AppNotification>,
        unreadCount: results[1] as int,
        preference: results[2] as NotificationPreference,
      );
    } catch (error) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, error: '$error');
    }
  }

  NotificationsState _buildInitialState() {
    final now = DateTime.now();
    final defaultList = [
      AppNotification(
        id: 'notif_ai_1',
        title: 'Gợi ý tăng tạ Bench Press (+2.5kg)',
        message:
            'AI Coach nhận thấy bạn đã hoàn thành 4 hiệp 10 reps dễ dàng trong 2 buổi gần nhất. Đề xuất tăng mức tạ lên 62.5kg hôm nay!',
        timestamp: now.subtract(const Duration(minutes: 15)),
        type: NotificationType.aiRecommendation,
        isRead: false,
        actionRoute: '/exercise/ex1',
        actionLabel: 'Xem bài tập',
      ),
      AppNotification(
        id: 'notif_ai_2',
        title: 'Cơ lưng đã hồi phục 94%',
        message:
            'Nhóm cơ Lưng & Tay trước đã sẵn sàng cho buổi tập cường độ cao hôm nay. Hãy bắt đầu buổi tập Upper Body nhé!',
        timestamp: now.subtract(const Duration(hours: 2)),
        type: NotificationType.recoveryAlert,
        isRead: false,
        actionRoute: '/workout',
        actionLabel: 'Tập ngay',
      ),
      AppNotification(
        id: 'notif_ai_3',
        title: 'Nhắc nhở nạp 35g Protein sau tập',
        message:
            'Bữa ăn sau buổi tập rất quan trọng cho việc tổng hợp cơ bắp. Bạn có thể thêm 1 cốc Whey hoặc 150g ức gà.',
        timestamp: now.subtract(const Duration(hours: 5)),
        type: NotificationType.nutritionSuggestion,
        isRead: true,
        actionRoute: '/meal',
        actionLabel: 'Xem thực đơn',
      ),
      AppNotification(
        id: 'notif_sys_4',
        title: 'Chúc mừng chuỗi tập luyện 3 ngày liên tiếp! 🔥',
        message:
            'Bạn đang duy trì phong độ rất tốt trong tuần này. Tiếp tục giữ vững phong độ nhé!',
        timestamp: now.subtract(const Duration(days: 1)),
        type: NotificationType.workoutReminder,
        isRead: true,
        actionRoute: '/progress',
        actionLabel: 'Xem tiến độ',
      ),
    ];

    final unread = defaultList.where((n) => !n.isRead).length;
    return NotificationsState(notifications: defaultList, unreadCount: unread);
  }

  void markAsRead(String id) {
    final updated = state.notifications.map((n) {
      if (n.id == id && !n.isRead) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    final unread = updated.where((n) => !n.isRead).length;
    state = state.copyWith(notifications: updated, unreadCount: unread);
    unawaited(_ignore(ref.read(notificationsRepositoryProvider).read(id)));
  }

  void markAllAsRead() {
    final updated = state.notifications.map((n) {
      return n.copyWith(isRead: true);
    }).toList();

    state = state.copyWith(notifications: updated, unreadCount: 0);
    unawaited(_ignore(ref.read(notificationsRepositoryProvider).readAll()));
  }

  void deleteNotification(String id) {
    final updated = state.notifications.where((n) => n.id != id).toList();
    final unread = updated.where((n) => !n.isRead).length;
    state = state.copyWith(notifications: updated, unreadCount: unread);
    unawaited(_ignore(ref.read(notificationsRepositoryProvider).delete(id)));
  }

  void clearAll() {
    state = const NotificationsState(notifications: [], unreadCount: 0);
  }

  void addNotification(AppNotification notification) {
    final updated = [notification, ...state.notifications];
    final unread = updated.where((n) => !n.isRead).length;
    state = state.copyWith(notifications: updated, unreadCount: unread);
  }

  Future<void> updatePreference(NotificationPreference value) async {
    final previous = state.preference;
    state = state.copyWith(preference: value);
    try {
      final saved = await ref
          .read(notificationsRepositoryProvider)
          .savePreference(value);
      if (ref.mounted) state = state.copyWith(preference: saved);
    } catch (error) {
      if (ref.mounted) {
        state = state.copyWith(preference: previous, error: '$error');
      }
    }
  }

  Future<void> _ignore(Future<void> request) async {
    try {
      await request;
    } catch (_) {
      // Optimistic UI remains usable while offline; refresh reconciles later.
    }
  }
}

final notificationsProvider =
    NotifierProvider<NotificationsController, NotificationsState>(() {
      return NotificationsController();
    });
