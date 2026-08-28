import 'package:flutter/material.dart';

class SelectableCard extends StatelessWidget {
  const SelectableCard({
    super.key,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
    this.badge,
    this.icon,
    this.iconColor,
  });

  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;
  final String? badge;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected
              ? colors.primary
              : colors.outlineVariant.withValues(alpha: 0.6),
          width: isSelected ? 2.0 : 1.0,
        ),
      ),
      color: isSelected
          ? colors.primary.withValues(alpha: 0.12)
          : colors.surfaceContainer,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (iconColor ?? colors.primary).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (iconColor ?? colors.primary).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? colors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? colors.primary : colors.onSurface,
                            ),
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: colors.primary.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Text(
                              badge!,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: colors.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            height: 1.35,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: isSelected ? colors.primary : colors.outlineVariant,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
