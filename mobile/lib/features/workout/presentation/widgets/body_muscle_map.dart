import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/muscle_models.dart';
import 'body_muscle_regions_generated.dart';

const _frontBodyAsset = 'assets/images/body/body_muscles_front_v2.jpg';
const _backBodyAsset = 'assets/images/body/body_muscles_back_v2.jpg';

class BodyMuscleMap extends StatelessWidget {
  const BodyMuscleMap({
    super.key,
    required this.bodySide,
    this.primaryMuscles = const {},
    this.secondaryMuscles = const {},
    this.focusedMuscle,
    this.isZoomed = false,
    this.autoZoom = true,
    this.interactive = true,
    this.showLabels = false,
    this.showContainerFrame = false,
    this.backgroundColor,
    this.borderRadius,
    this.onMuscleTap,
    this.height = 360,
    this.width,
  });

  final BodySide bodySide;
  final Set<MuscleGroup> primaryMuscles;
  final Set<MuscleGroup> secondaryMuscles;
  final MuscleGroup? focusedMuscle;
  final bool isZoomed;
  final bool autoZoom;
  final bool interactive;
  final bool showLabels;
  final bool showContainerFrame;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final ValueChanged<MuscleGroup>? onMuscleTap;
  final double height;
  final double? width;

  MuscleHighlightLevel _highlightLevel(MuscleGroup muscle) {
    if (primaryMuscles.contains(muscle)) {
      return MuscleHighlightLevel.primary;
    }
    if (secondaryMuscles.contains(muscle)) {
      return MuscleHighlightLevel.secondary;
    }
    if (focusedMuscle == muscle) return MuscleHighlightLevel.primary;
    return MuscleHighlightLevel.none;
  }

  _MuscleCamera _calculateCamera({
    required Size referenceSize,
    required Size viewportSize,
    required Size canvasSize,
  }) {
    if (!isZoomed && !autoZoom) return const _MuscleCamera.fullBody();

    final availableRegions = _MuscleRegions.forSide(bodySide);
    final activeMuscles = <MuscleGroup>{
      ...primaryMuscles,
      ...secondaryMuscles,
    }.where(availableRegions.containsKey).toSet();

    Set<MuscleGroup> cameraTargets;
    if (focusedMuscle != null && availableRegions.containsKey(focusedMuscle)) {
      cameraTargets = {focusedMuscle!};
    } else if (isZoomed) {
      final preferred =
          primaryMuscles.where(availableRegions.containsKey).firstOrNull ??
          activeMuscles.firstOrNull;
      cameraTargets = preferred == null ? const {} : {preferred};
    } else {
      cameraTargets = activeMuscles;
    }

    if (cameraTargets.isEmpty) return const _MuscleCamera.fullBody();

    Rect? targetBounds;
    for (final muscle in cameraTargets) {
      for (final path in availableRegions[muscle] ?? const <Path>[]) {
        final bounds = path.getBounds();
        targetBounds = targetBounds == null
            ? bounds
            : targetBounds.expandToInclude(bounds);
      }
    }
    if (targetBounds == null || targetBounds.isEmpty) {
      return const _MuscleCamera.fullBody();
    }

    final renderedTargetWidth =
        targetBounds.width * canvasSize.width / referenceSize.width;
    final renderedTargetHeight =
        targetBounds.height * canvasSize.height / referenceSize.height;
    final isSingleTarget = cameraTargets.length == 1;
    final horizontalFill = isSingleTarget ? 0.74 : 0.82;
    final verticalFill = isSingleTarget ? 0.58 : 0.72;
    final widthScale = renderedTargetWidth <= 0
        ? 1.0
        : viewportSize.width * horizontalFill / renderedTargetWidth;
    final heightScale = renderedTargetHeight <= 0
        ? 1.0
        : viewportSize.height * verticalFill / renderedTargetHeight;
    final maxScale = isSingleTarget ? 3.15 : 2.05;
    final scale = math.min(widthScale, heightScale).clamp(1.0, maxScale);

    if (scale <= 1.06) return const _MuscleCamera.fullBody();
    return _MuscleCamera(
      scale: scale,
      center: Offset(
        targetBounds.center.dx / referenceSize.width,
        targetBounds.center.dy / referenceSize.height,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final referenceSize = generatedMuscleReferenceSize(bodySide);

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportHeight = height;
        final targetAspectWidth = viewportHeight * referenceSize.aspectRatio;
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : targetAspectWidth;
        final viewportWidth =
            width ??
            ((autoZoom || isZoomed)
                ? availableWidth
                : math.min(availableWidth, targetAspectWidth));

        // Canvas base size strictly preserves exact anatomical aspect ratio (839 / 1555)
        final canvasHeight = viewportHeight;
        final canvasWidth = canvasHeight * referenceSize.aspectRatio;
        final containerRadius = borderRadius ?? BorderRadius.circular(16);
        final camera = _calculateCamera(
          referenceSize: referenceSize,
          viewportSize: Size(viewportWidth, viewportHeight),
          canvasSize: Size(canvasWidth, canvasHeight),
        );

        final imageAndHighlights = GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: interactive && onMuscleTap != null
              ? (details) {
                  final point = Offset(
                    details.localPosition.dx *
                        referenceSize.width /
                        canvasWidth,
                    details.localPosition.dy *
                        referenceSize.height /
                        canvasHeight,
                  );
                  final muscle = _MuscleRegions.hitTest(bodySide, point);
                  if (muscle != null) onMuscleTap!(muscle);
                }
              : null,
          child: CustomPaint(
            foregroundPainter: BodyMuscleHighlightPainter(
              bodySide: bodySide,
              primaryColor: colors.primary,
              secondaryColor: const Color(0xFFFF6B8B),
              highlightLevelResolver: _highlightLevel,
            ),
            child: Image.asset(
              bodySide == BodySide.front ? _frontBodyAsset : _backBodyAsset,
              key: ValueKey('body-muscle-${bodySide.name}-asset'),
              width: canvasWidth,
              height: canvasHeight,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              semanticLabel: bodySide.label,
            ),
          ),
        );

        final canvasContent = Center(
          child: ClipRRect(
            borderRadius: containerRadius,
            child: Container(
              width: viewportWidth,
              height: viewportHeight,
              decoration: BoxDecoration(
                color: showContainerFrame
                    ? (backgroundColor ?? const Color(0xFF171720))
                    : (backgroundColor ?? Colors.transparent),
                borderRadius: containerRadius,
                border: showContainerFrame
                    ? Border.all(
                        color: colors.outlineVariant.withValues(alpha: 0.3),
                      )
                    : null,
              ),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 1, end: camera.scale),
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeOutCubic,
                    builder: (context, scale, child) {
                      final isFullBody = scale <= 1.05;
                      final effectiveCenter = isFullBody
                          ? const Offset(0.5, 0.5)
                          : camera.center;
                      final offsetX =
                          -(effectiveCenter.dx - 0.5) * canvasWidth * scale;
                      final offsetY =
                          -(effectiveCenter.dy - 0.5) * canvasHeight * scale;
                      return Transform.translate(
                        offset: Offset(offsetX, offsetY),
                        child: Transform.scale(scale: scale, child: child),
                      );
                    },
                    child: SizedBox(
                      width: canvasWidth,
                      height: canvasHeight,
                      child: imageAndHighlights,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        if (showLabels) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              canvasContent,
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  bodySide.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
              ),
            ],
          );
        }

        return canvasContent;
      },
    );
  }
}

class _MuscleCamera {
  const _MuscleCamera({required this.scale, required this.center});

  const _MuscleCamera.fullBody() : scale = 1, center = const Offset(0.5, 0.5);

  final double scale;
  final Offset center;
}

class BodyMuscleHighlightPainter extends CustomPainter {
  BodyMuscleHighlightPainter({
    required this.bodySide,
    required this.primaryColor,
    required this.secondaryColor,
    required this.highlightLevelResolver,
  });

  final BodySide bodySide;
  final Color primaryColor;
  final Color secondaryColor;
  final MuscleHighlightLevel Function(MuscleGroup) highlightLevelResolver;

  @override
  void paint(Canvas canvas, Size size) {
    final referenceSize = generatedMuscleReferenceSize(bodySide);
    canvas.save();
    canvas.scale(
      size.width / referenceSize.width,
      size.height / referenceSize.height,
    );

    final pathLevels = Map<Path, MuscleHighlightLevel>.identity();
    for (final entry in _MuscleRegions.forSide(bodySide).entries) {
      final level = highlightLevelResolver(entry.key);
      if (level == MuscleHighlightLevel.none) continue;
      for (final path in entry.value) {
        final previous = pathLevels[path] ?? MuscleHighlightLevel.none;
        if (level.index > previous.index) pathLevels[path] = level;
      }
    }

    for (final entry in pathLevels.entries) {
      final path = entry.key;
      final level = entry.value;
      final isPrimary = level == MuscleHighlightLevel.primary;
      final color = isPrimary ? primaryColor : secondaryColor;

      final bounds = path.getBounds();

      // 1. Ambient Bloom / Outer Glow
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: isPrimary ? 0.40 : 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );

      // 2. Focused Core Glow
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: isPrimary ? 0.55 : 0.38)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );

      // 3. Depth-preserving 3D Muscle Fiber Fill
      final center = bounds.center;
      final radius = math.max(bounds.width, bounds.height) * 0.75;
      final fillShader = RadialGradient(
        center: Alignment.center,
        radius: 0.9,
        colors: [
          color.withValues(alpha: isPrimary ? 0.82 : 0.60),
          color.withValues(alpha: isPrimary ? 0.65 : 0.42),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawPath(
        path,
        Paint()
          ..shader = fillShader
          ..style = PaintingStyle.fill,
      );

      // 4. Inner Rim Highlight / Edge Glow Stroke
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: isPrimary ? 0.95 : 0.85)
          ..strokeWidth = isPrimary ? 2.2 : 1.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );

      // 5. Crisp White/Specular Accent on Primary Muscles
      if (isPrimary) {
        canvas.drawPath(
          path,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.65)
            ..strokeWidth = 0.9
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant BodyMuscleHighlightPainter oldDelegate) =>
      oldDelegate.bodySide != bodySide ||
      oldDelegate.primaryColor != primaryColor ||
      oldDelegate.secondaryColor != secondaryColor ||
      oldDelegate.highlightLevelResolver != highlightLevelResolver;
}

class _MuscleRegions {
  static Map<MuscleGroup, List<Path>> forSide(BodySide side) =>
      generatedMuscleRegions(side);

  static MuscleGroup? hitTest(BodySide side, Offset point) {
    for (final entry in forSide(side).entries.toList().reversed) {
      if (entry.value.any((path) => path.contains(point))) return entry.key;
    }
    return null;
  }
}
