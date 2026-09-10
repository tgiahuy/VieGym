import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Generic selection card used in onboarding and other choice screens.
///
/// When [accentColor] is provided, it drives ALL color states automatically:
/// - Unselected icon: `accentColor` at 60% opacity (subtle hint).
/// - Selected background: `accentColor` at 12% opacity (accentSoft).
/// - Selected border: `accentColor` at 28% opacity.
/// - Selected icon container bg: `accentColor` at 16% opacity.
/// - Selected icon: full `accentColor`.
/// - Selected badge/check: full `accentColor`.
///
/// When [accentColor] is not provided, falls back to VieGym Brand Red.
class SelectableCard extends StatefulWidget {
  const SelectableCard({
    super.key,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
    this.badge,
    this.icon,
    this.accentColor,
    // Legacy params kept for backwards compat; accentColor takes precedence.
    this.iconColor,
    this.selectedColor,
    this.selectedBorderColor,
  });

  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;
  final String? badge;
  final IconData? icon;

  /// Primary accent color. Drives all selected-state visuals automatically.
  final Color? accentColor;

  // Legacy overrides (ignored when accentColor is set).
  final Color? iconColor;
  final Color? selectedColor;
  final Color? selectedBorderColor;

  @override
  State<SelectableCard> createState() => _SelectableCardState();
}

class _SelectableCardState extends State<SelectableCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor ?? AppColors.primary;

    // All color states derived from a single accentColor token.
    final accentSoft = accent.withValues(alpha: 0.12);
    final accentBorder = accent.withValues(alpha: 0.28);
    final accentIconBg = accent.withValues(alpha: 0.16);
    final iconColorUnselected = accent.withValues(alpha: 0.60);

    return AnimatedScale(
      scale: _isPressed ? 0.975 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        margin: const EdgeInsets.only(bottom: 10),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: widget.isSelected ? accentSoft : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: widget.isSelected ? accentBorder : AppColors.borderDefault,
            width: widget.isSelected ? 1.5 : 1.0,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          splashColor: accent.withValues(alpha: 0.14),
          highlightColor: accent.withValues(alpha: 0.07),
          onHighlightChanged: (v) => setState(() => _isPressed = v),
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.icon != null) ...[
                  AnimatedContainer(
                    width: 44,
                    height: 44,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? accentIconBg
                          : AppColors.surfaceNested,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: widget.isSelected
                            ? accentBorder
                            : AppColors.borderDefault,
                      ),
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.isSelected ? accent : iconColorUnselected,
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
                              widget.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (widget.badge != null) ...[
                            const SizedBox(width: 8),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutCubic,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: widget.isSelected
                                    ? accentIconBg
                                    : AppColors.surfaceNested,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: widget.isSelected
                                      ? accentBorder
                                      : AppColors.borderDefault,
                                ),
                              ),
                              child: Text(
                                widget.badge!,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: widget.isSelected
                                      ? accent
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Check indicator — animated via AnimatedContainer.
                AnimatedContainer(
                  width: 22,
                  height: 22,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isSelected ? accent : Colors.transparent,
                    border: Border.all(
                      color:
                          widget.isSelected ? accent : AppColors.iconTertiary,
                      width: 1.5,
                    ),
                  ),
                  child: widget.isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          size: 13,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
