import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/ai_coach_controller.dart';
import '../domain/ai_models.dart';
import 'widgets/ai_recommendation_card.dart';

class AiTabScreen extends ConsumerWidget {
  const AiTabScreen({super.key});

  Future<void> _handleApplyRecommendation(
    BuildContext context,
    WidgetRef ref,
    AiRecommendation recommendation,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Áp dụng: ${recommendation.title}?'),
        content: Text(
          '${recommendation.description}\n\n${recommendation.reason}',
          style: const TextStyle(fontSize: 13, height: 1.35),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Xác nhận áp dụng'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      ref.read(aiCoachProvider.notifier).applyRecommendation(recommendation.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã áp dụng: ${recommendation.title}'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      switch (recommendation.actionType) {
        case RecommendationActionType.startWorkout:
          context.push('/workout/session');
        case RecommendationActionType.applySchedule:
          context.push('/workout/schedule');
        case RecommendationActionType.adjustNutrition:
          context.push('/meal');
        case RecommendationActionType.viewRecovery:
          context.push('/progress');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(aiCoachProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'VieGym AI Coach',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/ai/consent'),
            icon: const Icon(Icons.shield_outlined),
            tooltip: 'Quyền riêng tư AI',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          // 1. Hero AI Coach Chat Banner Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [colors.primary, const Color(0xFFFF9052)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.28),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(height: 18),
                const Text(
                  'AI Coach Chat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Hỏi về dinh dưỡng, buổi tập hoặc nhận gợi ý thay bài khi đang khó chịu.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () => context.push('/ai/chat'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: colors.primary,
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: colors.primary,
                    size: 18,
                  ),
                  label: Text(
                    'Mở cuộc trò chuyện',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: colors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // 2. SECTION HEADER: ĐỀ XUẤT HÔM NAY
          LayoutBuilder(
            builder: (context, constraints) {
              final title = const Text(
                'ĐỀ XUẤT HÔM NAY',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                ),
              );
              final badge = state.newRecommendationsCount > 0
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${state.newRecommendationsCount} đề xuất mới',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: colors.primary,
                        ),
                      ),
                    )
                  : null;

              if (constraints.maxWidth < 360 && badge != null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [title, const SizedBox(height: 6), badge],
                );
              }

              return Row(
                children: [
                  Expanded(child: title),
                  if (badge != null) ...[const SizedBox(width: 12), badge],
                ],
              );
            },
          ),
          const SizedBox(height: 12),

          // 3. RECOMMENDATIONS LIST / EMPTY STATE
          if (state.activeRecommendations.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: colors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chưa có đề xuất mới',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'VieGym AI đang liên tục phân tích dữ liệu tập luyện để đưa ra gợi ý khi cần.',
                          style: TextStyle(fontSize: 11.5, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            ...state.activeRecommendations.map((rec) {
              return AIRecommendationCard(
                recommendation: rec,
                onApply: () => _handleApplyRecommendation(context, ref, rec),
                onDismiss: () {
                  ref
                      .read(aiCoachProvider.notifier)
                      .dismissRecommendation(rec.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã bỏ qua đề xuất'),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              );
            }),
        ],
      ),
    );
  }
}
