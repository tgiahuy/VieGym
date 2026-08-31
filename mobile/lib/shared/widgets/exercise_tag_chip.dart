import 'package:flutter/material.dart';

enum ExerciseTagType { muscle, equipment, neutral, difficulty }

/// A global reusable metadata tag/chip component for exercises across VieGym.
class ExerciseTagChip extends StatelessWidget {
  const ExerciseTagChip({
    super.key,
    required this.label,
    this.type = ExerciseTagType.muscle,
    this.isSelected = false,
    this.onTap,
    this.fontSize = 11,
    this.icon,
  });

  const ExerciseTagChip.muscle({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.fontSize = 11,
    this.icon,
  }) : type = ExerciseTagType.muscle;

  const ExerciseTagChip.equipment({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.fontSize = 11,
    this.icon,
  }) : type = ExerciseTagType.equipment;

  const ExerciseTagChip.neutral({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.fontSize = 11,
    this.icon,
  }) : type = ExerciseTagType.neutral;

  final String label;
  final ExerciseTagType type;
  final bool isSelected;
  final VoidCallback? onTap;
  final double fontSize;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    Color bgColor;
    Color textColor;
    Border? border;

    switch (type) {
      case ExerciseTagType.muscle:
        bgColor = const Color(0xFF222636);
        textColor = const Color(0xFFE4E7F2);
        border = Border.all(color: const Color(0xFF333A52), width: 0.8);
        break;
      case ExerciseTagType.equipment:
        bgColor = colors.primary.withValues(alpha: 0.14);
        textColor = colors.primary;
        border = Border.all(
          color: colors.primary.withValues(alpha: 0.35),
          width: 0.8,
        );
        break;
      case ExerciseTagType.difficulty:
        bgColor = const Color(0xFF2A2218);
        textColor = const Color(0xFFF59E0B);
        border = Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
          width: 0.8,
        );
        break;
      case ExerciseTagType.neutral:
        bgColor = colors.surfaceContainerHighest.withValues(alpha: 0.4);
        textColor = colors.onSurfaceVariant;
        border = Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.4),
          width: 0.8,
        );
        break;
    }

    if (isSelected) {
      bgColor = colors.primary.withValues(alpha: 0.25);
      border = Border.all(color: colors.primary, width: 1.2);
      textColor = Colors.white;
    }

    final Widget content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: border,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon!, const SizedBox(width: 4)],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}
