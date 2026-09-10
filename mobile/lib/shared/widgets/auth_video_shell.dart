import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../core/theme/app_theme.dart';

/// Keeps one muted, looping video alive across the authentication and
/// onboarding route group.
class AuthVideoShell extends StatefulWidget {
  const AuthVideoShell({required this.child, super.key});

  final Widget child;

  @override
  State<AuthVideoShell> createState() => _AuthVideoShellState();
}

class _AuthVideoShellState extends State<AuthVideoShell>
    with WidgetsBindingObserver {
  late final VideoPlayerController _controller;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = VideoPlayerController.asset(
      'assets/videos/auth_background.mp4',
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    unawaited(_initializeVideo());
  }

  Future<void> _initializeVideo() async {
    try {
      await _controller.initialize();
      await _controller.setLooping(true);
      await _controller.setVolume(0);
      await _controller.play();
      if (mounted) {
        setState(() => _isReady = true);
      }
    } catch (_) {
      // The gradient fallback remains visible when the asset cannot be played.
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isReady) return;

    if (state == AppLifecycleState.resumed) {
      unawaited(_controller.play());
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      unawaited(_controller.pause());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.surfaceElevated, AppColors.background],
              ),
            ),
          ),
          if (_isReady)
            IgnorePointer(
              child: FittedBox(
                fit: BoxFit.cover,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            ),
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.background.withValues(alpha: 0.6),
                    AppColors.background.withValues(alpha: 0.4),
                    AppColors.background.withValues(alpha: 0.9),
                  ],
                  stops: const [0, 0.48, 1],
                ),
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}
