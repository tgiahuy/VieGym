import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/muscle_models.dart';
import 'body_muscle_map.dart';

class FlippableMuscleCard extends StatefulWidget {
  const FlippableMuscleCard({
    super.key,
    this.targetMuscles = const [],
    this.frontPrimaryMuscles,
    this.frontSecondaryMuscles,
    this.backPrimaryMuscles,
    this.backSecondaryMuscles,
    this.width = 96,
    this.height = 132,
  });

  final List<String> targetMuscles;
  final Set<MuscleGroup>? frontPrimaryMuscles;
  final Set<MuscleGroup>? frontSecondaryMuscles;
  final Set<MuscleGroup>? backPrimaryMuscles;
  final Set<MuscleGroup>? backSecondaryMuscles;
  final double width;
  final double height;

  @override
  State<FlippableMuscleCard> createState() => _FlippableMuscleCardState();
}

class _FlippableMuscleCardState extends State<FlippableMuscleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isBack = false;

  late Set<MuscleGroup> _frontPrimary;
  late Set<MuscleGroup> _frontSecondary;
  late Set<MuscleGroup> _backPrimary;
  late Set<MuscleGroup> _backSecondary;

  @override
  void initState() {
    super.initState();
    _initMuscles();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation =
        Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
        )..addListener(() {
          if (_animation.value >= 0.5 && !_isBack) {
            setState(() => _isBack = true);
          } else if (_animation.value < 0.5 && _isBack) {
            setState(() => _isBack = false);
          }
        });

    _syncPreferredSide();
  }

  @override
  void didUpdateWidget(covariant FlippableMuscleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.targetMuscles != oldWidget.targetMuscles ||
        widget.frontPrimaryMuscles != oldWidget.frontPrimaryMuscles ||
        widget.backPrimaryMuscles != oldWidget.backPrimaryMuscles) {
      _initMuscles();
      _syncPreferredSide();
    }
  }

  void _syncPreferredSide() {
    if (!_hasFrontTargets && _hasBackTargets) {
      _controller.value = 1;
      _isBack = true;
    } else if (_hasFrontTargets && !_hasBackTargets) {
      _controller.value = 0;
      _isBack = false;
    }
  }

  void _initMuscles() {
    if (widget.frontPrimaryMuscles != null ||
        widget.backPrimaryMuscles != null) {
      _frontPrimary = widget.frontPrimaryMuscles ?? {};
      _frontSecondary = widget.frontSecondaryMuscles ?? {};
      _backPrimary = widget.backPrimaryMuscles ?? {};
      _backSecondary = widget.backSecondaryMuscles ?? {};
      return;
    }

    final parsed = widget.targetMuscles
        .map(MuscleGroup.fromString)
        .whereType<MuscleGroup>()
        .toSet();

    if (parsed.isEmpty) {
      _frontPrimary = {};
      _frontSecondary = {};
      _backPrimary = {};
      _backSecondary = {};
      return;
    }

    _frontPrimary = parsed
        .where((m) => m.primarySide == BodySide.front)
        .toSet();
    _backPrimary = parsed.where((m) => m.primarySide == BodySide.back).toSet();
    _frontSecondary = {};
    _backSecondary = {};
  }

  bool get _hasFrontTargets =>
      _frontPrimary.isNotEmpty || _frontSecondary.isNotEmpty;

  bool get _hasBackTargets =>
      _backPrimary.isNotEmpty || _backSecondary.isNotEmpty;

  bool get _canFlip => _hasFrontTargets && _hasBackTargets;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    HapticFeedback.lightImpact();
    if (_controller.isCompleted ||
        _controller.status == AnimationStatus.forward) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  void _showMuscleDetailModal() {
    HapticFeedback.mediumImpact();
    final colors = Theme.of(context).colorScheme;

    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final activePrimary = _isBack ? _backPrimary : _frontPrimary;
            final activeSecondary = _isBack ? _backSecondary : _frontSecondary;
            final primaryNames = activePrimary.map((m) => m.nameVi).join(', ');
            final secondaryNames = activeSecondary
                .map((m) => m.nameVi)
                .join(', ');

            return Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              decoration: BoxDecoration(
                color: const Color(0xFF10131E),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.accessibility_new_rounded,
                                color: colors.primary,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Nhóm cơ buổi tập hôm nay',
                              style: TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        if (_canFlip)
                          InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              _flipCard();
                              setModalState(() {});
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: colors.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.sync_rounded,
                                    size: 14,
                                    color: colors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _isBack ? 'Xem mặt trước' : 'Xem mặt sau',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: colors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Centered Large Body Muscle Map
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 160,
                          height: 240,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF161925),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colors.primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: BodyMuscleMap(
                            bodySide: _isBack ? BodySide.back : BodySide.front,
                            primaryMuscles: _isBack
                                ? _backPrimary
                                : _frontPrimary,
                            secondaryMuscles: _isBack
                                ? _backSecondary
                                : _frontSecondary,
                            autoZoom: true,
                            interactive: false,
                            height: 228,
                            width: 148,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Beginner-friendly description cards
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161924),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: colors.outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF2E54),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Cơ tác động chính: ${primaryNames.isNotEmpty ? primaryNames : "Toàn thân"}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          if (secondaryNames.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFF6B8B),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Cơ bổ trợ: $secondaryNames',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            '💡 Mẹo cho người mới: Hãy tập trung cảm nhận nhóm cơ phát sáng đỏ co thắt khi nâng và giãn ra khi hạ tạ.',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: colors.onSurfaceVariant.withValues(
                                alpha: 0.85,
                              ),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final currentPrimary = _isBack ? _backPrimary : _frontPrimary;
    final currentSecondary = _isBack ? _backSecondary : _frontSecondary;
    final targetLabel = currentPrimary.isNotEmpty
        ? currentPrimary.first.nameVi
        : (_isBack ? 'Mặt sau' : 'Mặt trước');

    return GestureDetector(
      onTap: _canFlip ? _flipCard : _showMuscleDetailModal,
      onLongPress: _showMuscleDetailModal,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * math.pi;
          // Rotate around Y axis with 3D perspective
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.002)
            ..rotateY(angle);

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: Container(
              width: widget.width,
              height: widget.height,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color: colors.surfaceContainer.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.38),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Clean Body Muscle Canvas without any text overlays
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Transform(
                        transform: _isBack
                            ? Matrix4.rotationY(math.pi)
                            : Matrix4.identity(),
                        alignment: Alignment.center,
                        child: BodyMuscleMap(
                          bodySide: _isBack ? BodySide.back : BodySide.front,
                          primaryMuscles: currentPrimary,
                          secondaryMuscles: currentSecondary,
                          interactive: false,
                          autoZoom: true,
                          showContainerFrame: false,
                          height: widget.height - 24,
                          width: widget.width - 8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),

                  // Bottom Flip Indicator Row
                  Transform(
                    transform: _isBack
                        ? Matrix4.rotationY(math.pi)
                        : Matrix4.identity(),
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _canFlip
                                ? Icons.sync_rounded
                                : Icons.center_focus_strong_rounded,
                            size: 11,
                            color: colors.primary.withValues(alpha: 0.9),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            _canFlip
                                ? (_isBack ? 'Mặt sau' : 'Mặt trước')
                                : targetLabel,
                            style: TextStyle(
                              fontSize: 9.5,
                              color: colors.onSurface.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
