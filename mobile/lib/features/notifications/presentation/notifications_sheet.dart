import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/notifications_controller.dart';
import '../domain/notification_models.dart';

class NotificationsSheet extends ConsumerStatefulWidget {
  const NotificationsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationsSheet(),
    );
  }

  @override
  ConsumerState<NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends ConsumerState<NotificationsSheet> {
  int _selectedTabIndex = 0; // 0: All, 1: Unread only

  String _formatRelativeTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays == 1) return 'Hôm qua';
    return '${diff.inDays} ngày trước';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsProvider);
    final notifier = ref.read(notificationsProvider.notifier);
    final colors = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    final displayedList = _selectedTabIndex == 0
        ? state.notifications
        : state.notifications.where((n) => !n.isRead).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: BoxDecoration(
        color: const Color(0xFF10131E),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Column(
          children: [
            // Drag Handle
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF2E54).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      color: Color(0xFFFF2E54),
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Thông báo & Gợi ý AI',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          state.hasUnread
                              ? '${state.unreadCount} thông báo chưa đọc'
                              : 'Đã cập nhật mới nhất',
                          style: TextStyle(
                            fontSize: 12,
                            color: state.hasUnread
                                ? const Color(0xFFFF2E54)
                                : colors.onSurfaceVariant,
                            fontWeight: state.hasUnread
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (state.hasUnread)
                    TextButton.icon(
                      onPressed: notifier.markAllAsRead,
                      icon: const Icon(Icons.done_all_rounded, size: 16),
                      label: const Text('Đọc tất cả'),
                      style: TextButton.styleFrom(
                        foregroundColor: colors.primary,
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Filter Segment Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _TabButton(
                    label: 'Tất cả (${state.notifications.length})',
                    isSelected: _selectedTabIndex == 0,
                    onTap: () => setState(() => _selectedTabIndex = 0),
                  ),
                  const SizedBox(width: 8),
                  _TabButton(
                    label: 'Chưa đọc (${state.unreadCount})',
                    isSelected: _selectedTabIndex == 1,
                    badgeColor: const Color(0xFFFF2E54),
                    showBadge: state.hasUnread,
                    onTap: () => setState(() => _selectedTabIndex = 1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Colors.white12),

            // Notifications List
            Expanded(
              child: displayedList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerHighest.withValues(
                                alpha: 0.4,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.notifications_off_outlined,
                              size: 30,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _selectedTabIndex == 1
                                ? 'Không có thông báo chưa đọc'
                                : 'Chưa có thông báo nào',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Các gợi ý luyện tập & dinh dưỡng từ AI sẽ hiển thị tại đây.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        12,
                        16,
                        bottomInset + 20,
                      ),
                      itemCount: displayedList.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = displayedList[index];
                        return _NotificationCard(
                          notification: item,
                          timeFormatted: _formatRelativeTime(item.timestamp),
                          onTap: () {
                            if (!item.isRead) {
                              notifier.markAsRead(item.id);
                            }
                            if (item.actionRoute != null) {
                              Navigator.of(context, rootNavigator: true).pop();
                              context.push(item.actionRoute!);
                            }
                          },
                          onDelete: () => notifier.deleteNotification(item.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.showBadge = false,
    this.badgeColor,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showBadge;
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withValues(alpha: 0.16)
              : const Color(0xFF181C28),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colors.primary.withValues(alpha: 0.6)
                : colors.outlineVariant.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? colors.primary : colors.onSurfaceVariant,
              ),
            ),
            if (showBadge) ...[
              const SizedBox(width: 6),
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: badgeColor ?? colors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.timeFormatted,
    required this.onTap,
    required this.onDelete,
  });

  final AppNotification notification;
  final String timeFormatted;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isUnread = !notification.isRead;
    final type = notification.type;

    return Dismissible(
      key: ValueKey('notif_${notification.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: colors.error.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete_outline_rounded, color: colors.error),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isUnread ? const Color(0xFF1B2030) : const Color(0xFF141722),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUnread
                  ? type.color.withValues(alpha: 0.45)
                  : colors.outlineVariant.withValues(alpha: 0.25),
              width: isUnread ? 1.2 : 0.8,
            ),
            boxShadow: isUnread
                ? [
                    BoxShadow(
                      color: type.color.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Type Badge + Time + Unread Dot
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: type.color.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: type.color.withValues(alpha: 0.35),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(type.icon, size: 12, color: type.color),
                        const SizedBox(width: 4),
                        Text(
                          type.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: type.color,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    timeFormatted,
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (isUnread) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF2E54),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),

              // Title
              Text(
                notification.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isUnread ? FontWeight.w800 : FontWeight.w700,
                  color: isUnread ? Colors.white : colors.onSurface,
                ),
              ),
              const SizedBox(height: 4),

              // Message
              Text(
                notification.message,
                style: TextStyle(
                  fontSize: 12.5,
                  color: colors.onSurfaceVariant,
                  height: 1.35,
                ),
              ),

              // Action button if available
              if (notification.actionLabel != null) ...[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: type.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            notification.actionLabel!,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: type.color,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 10,
                            color: type.color,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
