import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Interactive exercise illustration and 2-phase motion player banner.
///
/// Seamlessly showcases starting position (Phase 1) and peak contraction
/// position (Phase 2) from verified Free Exercise DB photography with
/// interactive switching and motion loop playback.
class ExerciseMotionPlayerBanner extends StatefulWidget {
  const ExerciseMotionPlayerBanner({
    super.key,
    required this.startImageUrl,
    this.peakImageUrl,
    required this.exerciseName,
  });

  final String startImageUrl;
  final String? peakImageUrl;
  final String exerciseName;

  @override
  State<ExerciseMotionPlayerBanner> createState() =>
      _ExerciseMotionPlayerBannerState();
}

class _ExerciseMotionPlayerBannerState
    extends State<ExerciseMotionPlayerBanner> {
  int _activePhase = 0; // 0 = Start, 1 = Peak
  bool _isPlaying = false;
  Timer? _animationTimer;

  bool get _hasTwoPhases =>
      widget.peakImageUrl != null &&
      widget.peakImageUrl!.trim().isNotEmpty &&
      widget.peakImageUrl != widget.startImageUrl;

  String get _currentImageUrl =>
      (_activePhase == 1 && _hasTwoPhases)
          ? widget.peakImageUrl!
          : widget.startImageUrl;

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  void _togglePlayback() {
    if (!_hasTwoPhases) return;

    if (_isPlaying) {
      _stopPlayback();
    } else {
      _startPlayback();
    }
  }

  void _startPlayback() {
    setState(() {
      _isPlaying = true;
    });
    _animationTimer?.cancel();
    _animationTimer = Timer.periodic(const Duration(milliseconds: 1200), (_) {
      if (mounted) {
        setState(() {
          _activePhase = _activePhase == 0 ? 1 : 0;
        });
      }
    });
  }

  void _stopPlayback() {
    _animationTimer?.cancel();
    _animationTimer = null;
    if (mounted) {
      setState(() {
        _isPlaying = false;
      });
    }
  }

  void _selectPhase(int phase) {
    if (_isPlaying) {
      _stopPlayback();
    }
    setState(() {
      _activePhase = phase;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Center Image with AnimatedSwitcher for smooth 2-phase crossfade
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Image.network(
                _currentImageUrl,
                key: ValueKey('phase_${_activePhase}_$_currentImageUrl'),
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: colors.surfaceContainerHighest,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.fitness_center_rounded,
                          size: 48,
                          color: colors.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.exerciseName,
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: colors.primary,
                    ),
                  );
                },
              ),
            ),

            // Top gradient overlay for text readability
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 50,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.65),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Bottom gradient overlay for controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 60,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.75),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Top Badges
            Positioned(
              top: 10,
              left: 12,
              right: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Phase indicator badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _activePhase == 0
                              ? Icons.play_circle_outline_rounded
                              : Icons.check_circle_outline_rounded,
                          size: 14,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _activePhase == 0
                              ? 'Tư thế 1: Bắt đầu'
                              : 'Tư thế 2: Đỉnh điểm',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Source badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          size: 12,
                          color: Colors.greenAccent,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Free Exercise DB',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Controls (Phase Switcher & Animation Toggle)
            if (_hasTwoPhases)
              Positioned(
                bottom: 10,
                left: 12,
                right: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Segmented Phase Buttons
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildPhaseChip(
                            index: 0,
                            label: '1. Chuẩn bị',
                            isSelected: _activePhase == 0,
                            colors: colors,
                          ),
                          const SizedBox(width: 4),
                          _buildPhaseChip(
                            index: 1,
                            label: '2. Động tác',
                            isSelected: _activePhase == 1,
                            colors: colors,
                          ),
                        ],
                      ),
                    ),

                    // Motion Loop Playback Button
                    InkWell(
                      onTap: _togglePlayback,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _isPlaying
                              ? colors.primary
                              : Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _isPlaying
                                ? colors.primary
                                : colors.primary.withValues(alpha: 0.7),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.repeat_rounded,
                              size: 16,
                              color: _isPlaying ? Colors.white : colors.primary,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              _isPlaying ? 'Tạm dừng' : 'Xem chuyển động',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _isPlaying
                                    ? Colors.white
                                    : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseChip({
    required int index,
    required String label,
    required bool isSelected,
    required ColorScheme colors,
  }) {
    return InkWell(
      onTap: () => _selectPhase(index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }
}
