import 'package:flutter/material.dart';

import '../../domain/muscle_models.dart';
import 'body_muscle_map.dart';
import 'muscle_zoom_focus_card.dart';

class ExerciseMuscleVisualizer extends StatefulWidget {
  const ExerciseMuscleVisualizer({
    super.key,
    required this.primaryMuscle,
    this.secondaryMuscles = const [],
    this.initialBodySide,
    this.showZoomCard = true,
    this.interactive = true,
    this.mapHeight = 320,
  });

  final String primaryMuscle;
  final List<String> secondaryMuscles;
  final BodySide? initialBodySide;
  final bool showZoomCard;
  final bool interactive;
  final double mapHeight;

  @override
  State<ExerciseMuscleVisualizer> createState() =>
      _ExerciseMuscleVisualizerState();
}

class _ExerciseMuscleVisualizerState extends State<ExerciseMuscleVisualizer> {
  late BodySide _currentSide;
  late Set<MuscleGroup> _primaryMuscles;
  late Set<MuscleGroup> _secondaryMuscles;
  MuscleGroup? _focusedMuscle;
  bool _showFullBody = false;

  @override
  void initState() {
    super.initState();
    _initMuscles();
  }

  @override
  void didUpdateWidget(covariant ExerciseMuscleVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.primaryMuscle != oldWidget.primaryMuscle ||
        widget.secondaryMuscles != oldWidget.secondaryMuscles) {
      _initMuscles();
    }
  }

  void _initMuscles() {
    final primary = MuscleGroup.fromString(widget.primaryMuscle);
    _primaryMuscles = primary != null ? {primary} : {};

    _secondaryMuscles = widget.secondaryMuscles
        .map(MuscleGroup.fromString)
        .whereType<MuscleGroup>()
        .toSet();

    final allTargets = {..._primaryMuscles, ..._secondaryMuscles};
    _focusedMuscle = allTargets.length == 1 ? allTargets.first : null;
    _showFullBody = false;

    if (widget.initialBodySide != null) {
      _currentSide = widget.initialBodySide!;
    } else if (primary != null) {
      _currentSide = primary.primarySide;
    } else {
      _currentSide = BodySide.front;
    }
  }

  void _toggleSide(BodySide side) {
    setState(() {
      _currentSide = side;
    });
  }

  void _toggleFraming() {
    setState(() {
      _showFullBody = !_showFullBody;
    });
  }

  void _selectFocusedMuscle(MuscleGroup muscle) {
    setState(() {
      _focusedMuscle = muscle;
      _currentSide = muscle.primarySide;
      _showFullBody = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final allTargetMuscles = [..._primaryMuscles, ..._secondaryMuscles];
    final targetSides = allTargetMuscles
        .map((muscle) => muscle.primarySide)
        .toSet();
    final needsSideSwitch = targetSides.length > 1;
    final displayMuscle =
        _focusedMuscle ??
        _primaryMuscles.firstOrNull ??
        _secondaryMuscles.firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Toolbar: Front/Back Segmented Switch & Zoom Mode Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (needsSideSwitch)
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SegmentButton(
                      label: 'Mặt trước',
                      isSelected: _currentSide == BodySide.front,
                      onTap: () => _toggleSide(BodySide.front),
                    ),
                    _SegmentButton(
                      label: 'Mặt sau',
                      isSelected: _currentSide == BodySide.back,
                      onTap: () => _toggleSide(BodySide.back),
                    ),
                  ],
                ),
              )
            else
              _BodySideBadge(bodySide: _currentSide),

            // Zoom Toggle Button
            OutlinedButton.icon(
              onPressed: allTargetMuscles.isEmpty ? null : _toggleFraming,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                visualDensity: VisualDensity.compact,
                side: BorderSide(
                  color: !_showFullBody
                      ? colors.primary
                      : colors.outlineVariant.withValues(alpha: 0.6),
                ),
                backgroundColor: !_showFullBody
                    ? colors.primary.withValues(alpha: 0.12)
                    : Colors.transparent,
              ),
              icon: Icon(
                _showFullBody
                    ? Icons.center_focus_strong_rounded
                    : Icons.zoom_out_map_rounded,
                size: 16,
                color: !_showFullBody ? colors.primary : colors.onSurface,
              ),
              label: Text(
                _showFullBody ? 'Tập trung' : 'Toàn thân',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: !_showFullBody ? colors.primary : colors.onSurface,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Main Body Muscle Map Canvas
        BodyMuscleMap(
          bodySide: _currentSide,
          primaryMuscles: _primaryMuscles,
          secondaryMuscles: _secondaryMuscles,
          focusedMuscle: _showFullBody ? null : _focusedMuscle,
          isZoomed: false,
          autoZoom: !_showFullBody,
          interactive: widget.interactive,
          showLabels: false,
          height: widget.mapHeight,
        ),
        const SizedBox(height: 12),

        // Quick Muscle Selector Chips
        if (allTargetMuscles.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: allTargetMuscles.map((muscle) {
              final isPrimary = _primaryMuscles.contains(muscle);
              final isSelected = _focusedMuscle == muscle;
              final chipColor = isPrimary
                  ? colors.primary
                  : const Color(0xFFFF6B8B);

              return ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: chipColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(muscle.nameVi),
                  ],
                ),
                selected: isSelected,
                selectedColor: chipColor.withValues(alpha: 0.2),
                side: BorderSide(
                  color: isSelected
                      ? chipColor
                      : colors.outlineVariant.withValues(alpha: 0.4),
                  width: isSelected ? 1.5 : 1.0,
                ),
                onSelected: (_) => _selectFocusedMuscle(muscle),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],

        // Legend: Primary vs Secondary
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            runSpacing: 6,
            children: [
              _LegendItem(color: colors.primary, label: 'Cơ tác động chính'),
              if (_secondaryMuscles.isNotEmpty)
                const _LegendItem(
                  color: Color(0xFFFF6B8B),
                  label: 'Cơ bổ trợ / Giữ ổn định',
                ),
            ],
          ),
        ),

        // Zoom Focus Inset Card
        if (widget.showZoomCard && displayMuscle != null) ...[
          const SizedBox(height: 14),
          MuscleZoomFocusCard(
            muscle: displayMuscle,
            isPrimary: _primaryMuscles.contains(displayMuscle),
          ),
        ],
      ],
    );
  }
}

class _BodySideBadge extends StatelessWidget {
  const _BodySideBadge({required this.bodySide});

  final BodySide bodySide;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.accessibility_new_rounded,
            size: 15,
            color: colors.primary,
          ),
          const SizedBox(width: 6),
          Text(
            bodySide.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(9),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? colors.onPrimary : colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 4),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
