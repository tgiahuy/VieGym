import 'package:flutter/material.dart';
import '../../domain/workout_models.dart';

class CommonMistakesCard extends StatelessWidget {
  const CommonMistakesCard({
    super.key,
    required this.exerciseName,
    required this.mistakes,
  });

  final String exerciseName;
  final List<ExerciseMistake> mistakes;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (mistakes.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.amber.withValues(alpha: 0.35),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.amber,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Những lỗi sai thường gặp',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Tránh sai tư thế & chấn thương khi tập',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...mistakes.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mistake line
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.cancel_rounded,
                          color: Colors.redAccent,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              text: 'Lỗi sai: ',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Colors.redAccent,
                              ),
                              children: [
                                TextSpan(
                                  text: item.mistake,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
                                    color: colors.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Fix line
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.greenAccent,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              text: 'Khắc phục: ',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Colors.greenAccent,
                              ),
                              children: [
                                TextSpan(
                                  text: item.fix,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Injury risk warning if available
                    if (item.injuryRisk != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.shield_outlined,
                              size: 13,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Rủi ro: ${item.injuryRisk}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.amber,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
