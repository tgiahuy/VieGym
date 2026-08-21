import 'package:flutter/material.dart';

/// Displayed when the device has no network connectivity.
///
/// Wraps [connectivity_plus] detection — the parent widget is responsible for
/// listening to [ConnectivityResult] and showing this widget when offline.
/// See [AsyncValueWidget] for the integrated offline + error + loading pattern.
class OfflineView extends StatelessWidget {
  const OfflineView({super.key, this.onRetry});

  /// Callback invoked when the user taps the retry button.
  /// Typically triggers a connectivity re-check and data reload.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 72,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 20),
            Text(
              'Không có kết nối mạng',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Kiểm tra kết nối Wi-Fi hoặc dữ liệu di động của bạn.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Thử lại'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
