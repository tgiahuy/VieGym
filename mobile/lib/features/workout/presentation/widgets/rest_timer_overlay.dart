import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/rest_timer_controller.dart';

class RestTimerOverlay extends ConsumerWidget {
  const RestTimerOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(restTimerProvider);
    final notifier = ref.read(restTimerProvider.notifier);
    final colors = Theme.of(context).colorScheme;

    if (!timerState.isResting) return const SizedBox.shrink();

    // Minimized Floating Banner Mode
    if (timerState.isMinimized) {
      return Positioned(
        bottom: 84,
        left: 16,
        right: 16,
        child: Material(
          elevation: 10,
          borderRadius: BorderRadius.circular(16),
          color: colors.surfaceContainerHighest,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colors.primary.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: notifier.toggleMinimized,
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.timer_outlined,
                          color: colors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'THỜI GIAN NGHỈ',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: colors.onSurfaceVariant,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            timerState.formattedTime,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: () => notifier.adjustTime(15),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 32),
                  ),
                  child: const Text('+15s', style: TextStyle(fontSize: 11)),
                ),
                const SizedBox(width: 6),
                TextButton(
                  onPressed: notifier.stopRest,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 32),
                  ),
                  child: const Text('Bỏ qua', style: TextStyle(fontSize: 11)),
                ),
                IconButton(
                  onPressed: notifier.toggleMinimized,
                  icon: const Icon(Icons.fullscreen_rounded, size: 20),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Fullscreen Overlay Mode
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.88),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Action Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => notifier.setMinimized(true),
                    icon: const Icon(Icons.fullscreen_exit_rounded, size: 16),
                    label: const Text(
                      'Thu nhỏ & xem bài tiếp',
                      style: TextStyle(fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                    ),
                  ),
                  IconButton(
                    onPressed: notifier.stopRest,
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  ),
                ],
              ),

              // Center Countdown
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.timer_rounded, size: 16, color: colors.primary),
                        const SizedBox(width: 6),
                        Text(
                          'THỜI GIAN NGHỈ NGƠI',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    timerState.formattedTime,
                    style: const TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Hãy hít thở đều, uống nước và sẵn sàng cho hiệp tiếp theo.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: () => notifier.adjustTime(-15),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white24),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        child: const Text('-15s', style: TextStyle(fontSize: 13)),
                      ),
                      const SizedBox(width: 14),
                      OutlinedButton(
                        onPressed: () => notifier.adjustTime(15),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white24),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        child: const Text('+15s', style: TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                ],
              ),

              // Bottom Actions
              Column(
                children: [
                  FilledButton(
                    onPressed: notifier.stopRest,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Tiếp tục tập ngay',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => notifier.setMinimized(true),
                    child: const Text(
                      'Xem chi tiết bài tập trong lúc nghỉ',
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
