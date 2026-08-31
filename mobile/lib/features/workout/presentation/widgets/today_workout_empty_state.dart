import 'package:flutter/material.dart';

class TodayWorkoutEmptyState extends StatelessWidget {
  const TodayWorkoutEmptyState({
    super.key,
    this.title = 'Hôm nay chưa có lịch tập',
    this.subtitle = 'Bạn có thể tạo một buổi tập phù hợp cho hôm nay.',
    required this.buttonLabel,
    required this.onCreateWorkout,
    this.aiButtonLabel = 'Tạo lịch tập với AI',
    this.onAiCreateWorkout,
    this.icon = Icons.calendar_today_rounded,
  });

  final String title;
  final String? subtitle;
  final String buttonLabel;
  final VoidCallback onCreateWorkout;
  final String aiButtonLabel;
  final VoidCallback? onAiCreateWorkout;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: colors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BUỔI TẬP HÔM NAY',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 12),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12.5,
                color: colors.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (onAiCreateWorkout != null) ...[
            SizedBox(
              width: double.infinity,
              height: 46,
              child: FilledButton.icon(
                onPressed: onAiCreateWorkout,
                style: FilledButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                label: Text(
                  aiButtonLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: onCreateWorkout,
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.onSurface,
                  side: BorderSide(
                    color: colors.outlineVariant.withValues(alpha: 0.6),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(
                  buttonLabel,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              height: 46,
              child: FilledButton.icon(
                onPressed: onCreateWorkout,
                style: FilledButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text(
                  buttonLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
