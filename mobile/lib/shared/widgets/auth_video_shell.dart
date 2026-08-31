import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

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
      color: const Color(0xFF070910),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF171B2B), Color(0xFF070910)],
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
          const IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x99070A12),
                    Color(0x66070A12),
                    Color(0xE6070A12),
                  ],
                  stops: [0, 0.48, 1],
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
