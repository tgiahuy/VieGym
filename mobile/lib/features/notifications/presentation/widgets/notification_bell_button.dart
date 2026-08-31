import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/notifications_controller.dart';
import '../notifications_sheet.dart';

class NotificationBellButton extends ConsumerWidget {
  const NotificationBellButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsProvider);
    final colors = Theme.of(context).colorScheme;
    final hasUnread = state.hasUnread;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(99),
        onTap: () => NotificationsSheet.show(context),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
            shape: BoxShape.circle,
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.3),
              width: 0.9,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                hasUnread
                    ? Icons.notifications_active_outlined
                    : Icons.notifications_none_rounded,
                size: 22,
                color: hasUnread ? colors.onSurface : colors.onSurfaceVariant,
              ),

              // Red unread badge dot
              if (hasUnread)
                Positioned(
                  top: 9,
                  right: 9,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF2E54),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF0F1117),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF2E54).withValues(alpha: 0.6),
                          blurRadius: 4,
                          spreadRadius: 0.5,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
