import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/progress_controller.dart';

class PersonalRecordsScreen extends ConsumerWidget {
  const PersonalRecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(progressProvider);
    final records = state.personalRecords;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Kỷ lục cá nhân (PR)'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          // Banner Overview Card (Tự động ghi nhận bởi AI)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors.primary.withValues(alpha: 0.18),
                  Colors.amber.withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.primary.withValues(alpha: 0.35)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: Colors.amber,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'BẢNG KỶ LỤC CÁ NHÂN',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: Colors.amber,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.auto_awesome_rounded,
                                  size: 10,
                                  color: colors.primary,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  'AI AUTO-DETECT',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w900,
                                    color: colors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${records.length} Kỷ lục đã xác lập',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'AI VieGym sẽ tự động phân tích và ghi nhận khi bạn vượt qua mức tạ hoặc số reps cao nhất trong các buổi tập.',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // PR Records List Header
          Text(
            'DANH SÁCH KỶ LỤC CỦA BẠN',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              color: colors.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 10),

          if (records.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.emoji_events_outlined,
                      size: 40,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Chưa có kỷ lục nào được ghi nhận',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hãy hoàn thành các buổi tập, AI sẽ tự động ghi nhận những mốc PR ấn tượng của bạn!',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ...records.map((pr) {
              final calculated1Rm = pr.calculated1Rm;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.surfaceContainer,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    // Trophy / Dumbbell Icon
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.fitness_center_rounded,
                        color: colors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // PR Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pr.exerciseName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Text(
                                '${pr.weightKg.toStringAsFixed(1)} kg × ${pr.reps} reps',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: colors.onSurface,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '1RM: ~${calculated1Rm.toStringAsFixed(1)} kg',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.greenAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Tự động ghi nhận ngày: ${pr.date}',
                            style: TextStyle(
                              fontSize: 11,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Delete PR Action
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      color: colors.onSurfaceVariant,
                      onPressed: () {
                        ref
                            .read(progressProvider.notifier)
                            .deletePersonalRecord(pr.id);
                      },
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
