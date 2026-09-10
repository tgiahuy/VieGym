import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

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
    Color bgColor;
    Color textColor;
    Border? border;

    switch (type) {
      case ExerciseTagType.muscle:
        bgColor = AppColors.surfaceElevated;
        textColor = AppColors.textPrimary;
        border = Border.all(color: AppColors.borderDefault, width: 0.8);
        break;
      case ExerciseTagType.equipment:
        bgColor = AppColors.surfaceNested;
        textColor = AppColors.textSecondary;
        border = Border.all(color: AppColors.borderDefault, width: 0.8);
        break;
      case ExerciseTagType.difficulty:
        bgColor = AppColors.warning.withValues(alpha: 0.12);
        textColor = AppColors.warning;
        border = Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
          width: 0.8,
        );
        break;
      case ExerciseTagType.neutral:
        bgColor = AppColors.surfaceNested;
        textColor = AppColors.textSecondary;
        border = Border.all(color: AppColors.borderDefault, width: 0.8);
        break;
    }

    if (isSelected) {
      bgColor = AppColors.primarySoft;
      border = Border.all(color: AppColors.primaryBorder, width: 1.0);
      textColor = AppColors.textPrimary;
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
