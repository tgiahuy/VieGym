import 'package:flutter/material.dart';
import '../../domain/ai_models.dart';

class AIRecommendationCard extends StatelessWidget {
  const AIRecommendationCard({
    super.key,
    required this.recommendation,
    required this.onApply,
    required this.onDismiss,
  });

  final AiRecommendation recommendation;
  final VoidCallback onApply;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final (badgeIcon, badgeLabel, badgeColor) = switch (recommendation.type) {
      RecommendationType.workout => (
        Icons.fitness_center_rounded,
        'ĐỀ XUẤT BUỔI TẬP',
        colors.primary,
      ),
      RecommendationType.recovery => (
        Icons.monitor_heart_outlined,
        'PHỤC HỒI NHÓM CƠ',
        Colors.tealAccent,
      ),
      RecommendationType.fatigueDeload => (
        Icons.battery_charging_full_rounded,
        'GIẢM TẢI / NGHỈ NGƠI',
        Colors.amber,
      ),
      RecommendationType.trainingBalance => (
        Icons.balance_rounded,
        'CÂN BẰNG TẬP LUYỆN',
        Colors.blueAccent,
      ),
      RecommendationType.schedule => (
        Icons.calendar_month_rounded,
        'ĐIỀU CHỈNH LỊCH',
        Colors.purpleAccent,
      ),
      RecommendationType.nutrition => (
        Icons.restaurant_rounded,
        'DINH DƯỠNG',
        Colors.orangeAccent,
      ),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Category Pill & Dismiss X Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(badgeIcon, size: 13, color: badgeColor),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          badgeLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                            color: badgeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onDismiss,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 1. Recommendation Title
          Text(
            recommendation.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),

          // 2. Short Explanation / Description
          Text(
            recommendation.description,
            style: TextStyle(
              fontSize: 13,
              color: colors.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),

          // 3. AI Reason Section (Visually separated inset container)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF161922),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 15,
                  color: colors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Lý do: ',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                            color: colors.primary,
                          ),
                        ),
                        TextSpan(
                          text: recommendation.reason,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurface.withValues(alpha: 0.9),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 4. Primary Action Button (✓ Áp dụng)
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onApply,
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.check_rounded, size: 17),
                  label: const Text(
                    'Áp dụng',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
