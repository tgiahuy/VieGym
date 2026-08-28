import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.fitness_center_rounded,
    this.onBack,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (onBack != null)
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: colors.surfaceContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              )
            else
              const SizedBox(width: 48),
            const SizedBox(width: 48),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colors.primary.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.primary.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              icon,
              size: 34,
              color: colors.primary,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontSize: 13,
              ),
        ),
      ],
    );
  }
}
