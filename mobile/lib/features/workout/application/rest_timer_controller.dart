import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RestTimerState {
  const RestTimerState({
    this.isResting = false,
    this.timeLeftSeconds = 60,
    this.totalSeconds = 60,
    this.isMinimized = false,
  });

  final bool isResting;
  final int timeLeftSeconds;
  final int totalSeconds;
  final bool isMinimized;

  String get formattedTime {
    final minutes = timeLeftSeconds ~/ 60;
    final seconds = timeLeftSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  RestTimerState copyWith({
    bool? isResting,
    int? timeLeftSeconds,
    int? totalSeconds,
    bool? isMinimized,
  }) {
    return RestTimerState(
      isResting: isResting ?? this.isResting,
      timeLeftSeconds: timeLeftSeconds ?? this.timeLeftSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      isMinimized: isMinimized ?? this.isMinimized,
    );
  }
}

class RestTimerController extends Notifier<RestTimerState> {
  Timer? _timer;

  @override
  RestTimerState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return const RestTimerState();
  }

  void startRest({int seconds = 60}) {
    _timer?.cancel();
    state = RestTimerState(
      isResting: true,
      timeLeftSeconds: seconds,
      totalSeconds: seconds,
      isMinimized: false,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeLeftSeconds > 1) {
        state = state.copyWith(timeLeftSeconds: state.timeLeftSeconds - 1);
      } else {
        stopRest();
      }
    });
  }

  void stopRest() {
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(isResting: false);
  }

  void adjustTime(int deltaSeconds) {
    final newTime = (state.timeLeftSeconds + deltaSeconds).clamp(5, 600);
    state = state.copyWith(
      timeLeftSeconds: newTime,
      totalSeconds: state.totalSeconds < newTime ? newTime : state.totalSeconds,
    );
  }

  void toggleMinimized() {
    state = state.copyWith(isMinimized: !state.isMinimized);
  }

  void setMinimized(bool minimized) {
    state = state.copyWith(isMinimized: minimized);
  }
}

final restTimerProvider = NotifierProvider<RestTimerController, RestTimerState>(
  RestTimerController.new,
);
