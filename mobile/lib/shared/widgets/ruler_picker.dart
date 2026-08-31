import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RulerPicker extends StatefulWidget {
  const RulerPicker({
    super.key,
    required this.label,
    required this.min,
    required this.max,
    required this.unit,
    required this.value,
    required this.onChanged,
    this.step = 1,
    this.majorTickInterval = 10,
    this.mediumTickInterval = 5,
    this.itemWidth = 14.0,
    this.showLabelAndControls = true,
  });

  final String label;
  final int min;
  final int max;
  final String unit;
  final int value;
  final ValueChanged<int> onChanged;
  final int step;
  final int majorTickInterval;
  final int mediumTickInterval;
  final double itemWidth;
  final bool showLabelAndControls;

  @override
  State<RulerPicker> createState() => _RulerPickerState();
}

class _RulerPickerState extends State<RulerPicker> {
  late final ScrollController _scrollController;
  bool _isUserScrolling = false;
  int _lastReportedValue = 0;

  @override
  void initState() {
    super.initState();
    _lastReportedValue = widget.value;
    final initialOffset =
        ((widget.value - widget.min) / widget.step) * widget.itemWidth;
    _scrollController = ScrollController(initialScrollOffset: initialOffset);
  }

  @override
  void didUpdateWidget(covariant RulerPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isUserScrolling && oldWidget.value != widget.value) {
      _lastReportedValue = widget.value;
      final targetOffset =
          ((widget.value - widget.min) / widget.step) * widget.itemWidth;
      if (_scrollController.hasClients &&
          (_scrollController.offset - targetOffset).abs() >
              widget.itemWidth / 2) {
        _scrollController.jumpTo(targetOffset);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final offset = _scrollController.offset;
    final stepIndex = (offset / widget.itemWidth).round();
    final rawValue = widget.min + stepIndex * widget.step;
    final clampedValue = rawValue.clamp(widget.min, widget.max);
    if (clampedValue != _lastReportedValue) {
      _lastReportedValue = clampedValue;
      HapticFeedback.selectionClick();
      widget.onChanged(clampedValue);
    }
  }

  void _snapToValue() {
    if (!_scrollController.hasClients) return;
    final targetOffset =
        ((widget.value - widget.min) / widget.step) * widget.itemWidth;
    if ((_scrollController.offset - targetOffset).abs() > 0.5) {
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _adjustValue(int delta) {
    final target = (widget.value + delta * widget.step).clamp(
      widget.min,
      widget.max,
    );
    if (target == widget.value) return;
    _lastReportedValue = target;
    HapticFeedback.selectionClick();
    widget.onChanged(target);
    final targetOffset =
        ((target - widget.min) / widget.step) * widget.itemWidth;
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final totalSteps = ((widget.max - widget.min) / widget.step).round() + 1;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: colors.outlineVariant.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      color: colors.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.showLabelAndControls) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      widget.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        onPressed: widget.value > widget.min
                            ? () => _adjustValue(-1)
                            : null,
                        icon: const Icon(
                          Icons.remove_circle_outline_rounded,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${widget.value}',
                              maxLines: 1,
                              softWrap: false,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: colors.primary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.unit,
                              maxLines: 1,
                              softWrap: false,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        onPressed: widget.value < widget.max
                            ? () => _adjustValue(1)
                            : null,
                        icon: const Icon(
                          Icons.add_circle_outline_rounded,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            SizedBox(
              height: 82,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final sidePadding = constraints.maxWidth / 2;
                  return Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification is ScrollStartNotification) {
                            _isUserScrolling = true;
                          } else if (notification is ScrollUpdateNotification) {
                            _onScroll();
                          } else if (notification is ScrollEndNotification) {
                            _isUserScrolling = false;
                            _onScroll();
                            _snapToValue();
                          }
                          return false;
                        },
                        child: ListView.builder(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                            horizontal: sidePadding,
                          ),
                          itemCount: totalSteps,
                          itemBuilder: (context, index) {
                            final val = widget.min + index * widget.step;
                            final isMajor = val % widget.majorTickInterval == 0;
                            final isMedium =
                                !isMajor &&
                                (val % widget.mediumTickInterval == 0);
                            final tickHeight = isMajor
                                ? 30.0
                                : (isMedium ? 18.0 : 10.0);
                            final tickWidth = isMajor
                                ? 2.5
                                : (isMedium ? 1.8 : 1.2);
                            final tickColor = isMajor
                                ? colors.onSurface
                                : (isMedium
                                      ? colors.outlineVariant.withValues(
                                          alpha: 0.9,
                                        )
                                      : colors.outlineVariant.withValues(
                                          alpha: 0.45,
                                        ));

                            return SizedBox(
                              width: widget.itemWidth,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    width: tickWidth,
                                    height: tickHeight,
                                    decoration: BoxDecoration(
                                      color: tickColor,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  if (isMajor)
                                    SizedBox(
                                      height: 16,
                                      child: OverflowBox(
                                        maxWidth: widget.itemWidth * 3.5,
                                        child: Text(
                                          '$val',
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          softWrap: false,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: colors.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    const SizedBox(height: 16),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      // Center pointer & indicator
                      IgnorePointer(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.arrow_drop_down_rounded,
                              size: 16,
                              color: colors.primary,
                            ),
                            Container(
                              width: 3.5,
                              height: 38,
                              decoration: BoxDecoration(
                                color: colors.primary,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: colors.primary.withValues(
                                      alpha: 0.45,
                                    ),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 22),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
