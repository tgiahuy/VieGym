import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Interactive bouncing wrapper that provides a spring micro-animation and haptic
/// feedback whenever tapped.
class BouncingEffect extends StatefulWidget {
  const BouncingEffect({
    super.key,
    required this.child,
    this.onTap,
    this.scaleDown = 0.86,
    this.duration = const Duration(milliseconds: 120),
    this.enableHaptic = true,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scaleDown;
  final Duration duration;
  final bool enableHaptic;
  final BorderRadius? borderRadius;

  @override
  State<BouncingEffect> createState() => _BouncingEffectState();
}

class _BouncingEffectState extends State<BouncingEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: const Duration(milliseconds: 180),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleDown).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInQuad,
        reverseCurve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap == null) return;
    _controller.forward();
    if (widget.enableHaptic) {
      HapticFeedback.lightImpact();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap == null) return;
    _controller.reverse();
  }

  void _onTapCancel() {
    if (widget.onTap == null) return;
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null) return widget.child;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: widget.child,
      ),
    );
  }
}

/// Reusable VieGym animated icon button with bounce, ripple, and glow effects.
class BouncingIconButton extends StatelessWidget {
  const BouncingIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.iconSize = 22,
    this.color,
    this.backgroundColor,
    this.borderRadius = 14,
    this.padding = const EdgeInsets.all(10),
    this.enableGlow = false,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double iconSize;
  final Color? color;
  final Color? backgroundColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool enableGlow;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final effectiveBg =
        backgroundColor ??
        colors.surfaceContainerHighest.withValues(alpha: 0.5);
    final effectiveColor = color ?? colors.onSurface;

    Widget button = BouncingEffect(
      onTap: onPressed,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: effectiveBg,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: enableGlow
              ? [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.35),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: IconTheme(
          data: IconThemeData(color: effectiveColor, size: iconSize),
          child: icon,
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}
