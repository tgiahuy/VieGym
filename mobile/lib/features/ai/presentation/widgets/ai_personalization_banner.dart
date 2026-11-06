import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../profile/presentation/settings_screen.dart';

/// Invites the user to turn on AI personalization.
///
/// Shown only once the server-side consent state is known to be disabled, so it
/// never flashes for users who already opted in or while the app is offline.
/// The button opens the consent screen, which explains what data is used.
class AiPersonalizationBanner extends ConsumerWidget {
  const AiPersonalizationBanner({
    super.key,
    required this.message,
    this.margin = const EdgeInsets.only(bottom: 12),
  });

  final String message;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final known = ref.watch(aiConsentKnownProvider);
    final enabled = ref.watch(aiConsentProvider);
    if (!known || enabled) return const SizedBox.shrink();

    return Container(
      margin: margin,
      padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
      decoration: BoxDecoration(
        color: AppColors.aiVioletSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.aiViolet.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            size: 18,
            color: AppColors.aiViolet,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => context.push('/ai/consent'),
            child: const Text(
              'Bật',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: AppColors.aiViolet,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
