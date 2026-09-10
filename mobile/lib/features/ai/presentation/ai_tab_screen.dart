import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
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
    bool autoNavigate = true;

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: AppColors.borderDefault, width: 1),
      ),
      builder: (sheetContext) {
        final colors = Theme.of(sheetContext).colorScheme;

        final (
          badgeIcon,
          badgeLabel,
          badgeColor,
        ) = switch (recommendation.type) {
          RecommendationType.workout => (
            Icons.fitness_center_rounded,
            'ĐỀ XUẤT BUỔI TẬP',
            colors.primary,
          ),
          RecommendationType.recovery => (
            Icons.monitor_heart_outlined,
            'PHỤC HỒI NHÓM CƠ',
            AppColors.cyan,
          ),
          RecommendationType.fatigueDeload => (
            Icons.battery_charging_full_rounded,
            'GIẢM TẢI / NGHỈ NGƠI',
            AppColors.amber,
          ),
          RecommendationType.trainingBalance => (
            Icons.balance_rounded,
            'CÂN BẰNG TẬP LUYỆN',
            AppColors.blue,
          ),
          RecommendationType.schedule => (
            Icons.calendar_month_rounded,
            'ĐIỀU CHỈNH LỊCH',
            AppColors.violet,
          ),
          RecommendationType.nutrition => (
            Icons.restaurant_rounded,
            'DINH DƯỠNG',
            AppColors.orange,
          ),
        };

        final (
          actionIcon,
          actionLabel,
          actionDest,
        ) = switch (recommendation.actionType) {
          RecommendationActionType.startWorkout => (
            Icons.fitness_center_rounded,
            'Bắt đầu buổi tập tối ưu',
            'Chuyển đến màn hình Buổi tập',
          ),
          RecommendationActionType.applySchedule => (
            Icons.calendar_month_rounded,
            'Cập nhật kế hoạch tuần',
            'Chuyển đến màn hình Lịch tập',
          ),
          RecommendationActionType.adjustNutrition => (
            Icons.restaurant_rounded,
            'Điều chỉnh mục tiêu dinh dưỡng',
            'Chuyển đến màn hình Bữa ăn',
          ),
          RecommendationActionType.viewRecovery => (
            Icons.favorite_rounded,
            'Theo dõi phục hồi cơ bắp',
            'Chuyển đến màn hình Tiến độ',
          ),
        };

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 12,
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag Handle Bar
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colors.outlineVariant.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Top Bar: AI Category Badge & Close Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: badgeColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(badgeIcon, size: 14, color: badgeColor),
                              const SizedBox(width: 6),
                              Text(
                                badgeLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.4,
                                  color: badgeColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          color: colors.onSurfaceVariant,
                          onPressed: () => Navigator.pop(sheetContext, false),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Recommendation Title
                    Text(
                      recommendation.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Smart Impact Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceInput,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: colors.outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.aiVioletSoft,
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            child: Icon(
                              actionIcon,
                              color: AppColors.aiViolet,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  actionLabel,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  actionDest,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // AI Reasoning Box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: colors.outlineVariant.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.auto_awesome_rounded,
                                size: 14,
                                color: AppColors.aiViolet,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Lý do từ AI Coach',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            recommendation.description,
                            style: const TextStyle(
                              fontSize: 12.5,
                              height: 1.35,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (recommendation.reason.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              recommendation.reason,
                              style: TextStyle(
                                fontSize: 11.5,
                                height: 1.35,
                                fontStyle: FontStyle.italic,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Smart Auto-Navigate Switch
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        setSheetState(() => autoNavigate = !autoNavigate);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: autoNavigate,
                                onChanged: (val) {
                                  setSheetState(
                                    () => autoNavigate = val ?? true,
                                  );
                                },
                                activeColor: colors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Tự động mở màn hình tương ứng sau khi áp dụng',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: colors.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Smart Actions: Áp dụng ngay & Hủy (Non-overflowing & High-contrast)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final cancelButton = OutlinedButton(
                          onPressed: () => Navigator.pop(sheetContext, false),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            side: BorderSide(
                              color: colors.outlineVariant.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Hủy',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        );

                        final applyButton = FilledButton.icon(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            Navigator.pop(sheetContext, true);
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 2,
                          ),
                          icon: const Icon(Icons.bolt_rounded, size: 20),
                          label: const Text(
                            'Áp dụng ngay',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        );

                        if (constraints.maxWidth < 340) {
                          return Column(
                            children: [
                              applyButton,
                              const SizedBox(height: 8),
                              cancelButton,
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(child: cancelButton),
                            const SizedBox(width: 12),
                            Expanded(flex: 2, child: applyButton),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (confirmed == true && context.mounted) {
      ref.read(aiCoachProvider.notifier).applyRecommendation(recommendation.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Đã áp dụng thành công: ${recommendation.title}'),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      if (autoNavigate && context.mounted) {
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
              gradient: const LinearGradient(
                colors: [AppColors.violetSoft, AppColors.surface],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: AppColors.violetBorder, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.violetSoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.violet,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'AI Coach Chat',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Hỏi về dinh dưỡng, buổi tập hoặc nhận gợi ý thay bài khi đang khó chịu.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () => context.push('/ai/chat'),
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: AppColors.onPrimary,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                  label: const Text(
                    'Mở cuộc trò chuyện',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
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
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceNested,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.iconSecondary,
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
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                          ),
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
