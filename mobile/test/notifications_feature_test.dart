import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viegym/core/network/token_storage.dart';
import 'package:viegym/core/router/app_router.dart';
import 'package:viegym/features/notifications/application/notifications_controller.dart';
import 'package:viegym/features/notifications/presentation/notifications_sheet.dart';
import 'package:viegym/features/notifications/presentation/widgets/notification_bell_button.dart';
import 'package:viegym/features/shell/presentation/not_found_screen.dart';
import 'package:viegym/main.dart';

void main() {
  group('Notifications Controller Tests', () {
    test('Initial state has default notifications and unread count', () {
      final container = ProviderContainer();
      final state = container.read(notificationsProvider);

      expect(state.notifications.isNotEmpty, isTrue);
      expect(state.hasUnread, isTrue);
      expect(state.unreadCount, greaterThan(0));
    });

    test('markAsRead updates isRead and unread count', () {
      final container = ProviderContainer();
      final notifier = container.read(notificationsProvider.notifier);
      final unreadItem = container
          .read(notificationsProvider)
          .notifications
          .firstWhere((n) => !n.isRead);
      final initialUnread = container.read(notificationsProvider).unreadCount;

      notifier.markAsRead(unreadItem.id);

      final updatedItem = container
          .read(notificationsProvider)
          .notifications
          .firstWhere((n) => n.id == unreadItem.id);
      expect(updatedItem.isRead, isTrue);
      expect(
        container.read(notificationsProvider).unreadCount,
        equals(initialUnread - 1),
      );
    });

    test(
      'markAllAsRead marks all notifications as read and clears unread count',
      () {
        final container = ProviderContainer();
        final notifier = container.read(notificationsProvider.notifier);
        expect(container.read(notificationsProvider).hasUnread, isTrue);

        notifier.markAllAsRead();

        expect(container.read(notificationsProvider).hasUnread, isFalse);
        expect(container.read(notificationsProvider).unreadCount, equals(0));
        expect(
          container
              .read(notificationsProvider)
              .notifications
              .every((n) => n.isRead),
          isTrue,
        );
      },
    );

    test('deleteNotification removes notification from list', () {
      final container = ProviderContainer();
      final notifier = container.read(notificationsProvider.notifier);
      final target = container.read(notificationsProvider).notifications.first;
      final initialCount = container
          .read(notificationsProvider)
          .notifications
          .length;

      notifier.deleteNotification(target.id);

      expect(
        container.read(notificationsProvider).notifications.length,
        equals(initialCount - 1),
      );
      expect(
        container
            .read(notificationsProvider)
            .notifications
            .any((n) => n.id == target.id),
        isFalse,
      );
    });

    testWidgets('Every default notification opens a registered route', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          tokenStorageProvider.overrideWithValue(DefaultTokenStorage()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const VieGymApp(),
        ),
      );
      await tester.pumpAndSettle();

      final routes = container
          .read(notificationsProvider)
          .notifications
          .map((item) => item.actionRoute)
          .whereType<String>();
      final router = container.read(routerProvider);

      for (final route in routes) {
        router.go(route);
        await tester.pumpAndSettle();
        expect(
          find.byType(NotFoundScreen),
          findsNothing,
          reason: 'Route thông báo không tồn tại: $route',
        );
      }
    });
  });

  group('Notifications UI Widget Tests', () {
    testWidgets(
      'NotificationBellButton renders and shows red badge when unread',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: Center(child: NotificationBellButton())),
            ),
          ),
        );

        // Verify bell icon is present
        expect(find.byType(NotificationBellButton), findsOneWidget);
        expect(
          find.byIcon(Icons.notifications_active_outlined),
          findsOneWidget,
        );

        // Tap bell button to open bottom sheet
        await tester.tap(find.byType(NotificationBellButton));
        await tester.pumpAndSettle();

        // Verify NotificationsSheet is opened
        expect(find.text('Thông báo & Gợi ý AI'), findsOneWidget);
        expect(find.text('Đọc tất cả'), findsOneWidget);
        expect(find.textContaining('Gợi ý tăng tạ'), findsOneWidget);

        // Tap "Đọc tất cả"
        await tester.tap(find.text('Đọc tất cả'));
        await tester.pumpAndSettle();

        // Verify unread count is updated
        expect(find.text('Đã cập nhật mới nhất'), findsOneWidget);
      },
    );

    testWidgets('NotificationsSheet switches between All and Unread tabs', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: NotificationsSheet())),
        ),
      );

      expect(find.textContaining('Tất cả'), findsOneWidget);
      expect(find.textContaining('Chưa đọc'), findsOneWidget);

      // Switch to Unread tab
      await tester.tap(find.textContaining('Chưa đọc'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Gợi ý tăng tạ'), findsOneWidget);
    });
  });
}
