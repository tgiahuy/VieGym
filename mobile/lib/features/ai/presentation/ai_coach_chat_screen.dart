import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/ai_coach_controller.dart';
import '../domain/ai_models.dart';

class AiCoachChatScreen extends ConsumerStatefulWidget {
  const AiCoachChatScreen({super.key});

  @override
  ConsumerState<AiCoachChatScreen> createState() => _AiCoachChatScreenState();
}

class _AiCoachChatScreenState extends ConsumerState<AiCoachChatScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send([String? suggestedText]) async {
    final text = suggestedText ?? _inputController.text;
    if (text.trim().isEmpty) return;
    _inputController.clear();
    await ref.read(aiCoachProvider.notifier).send(text);
    if (mounted) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiCoachProvider);
    final colors = Theme.of(context).colorScheme;

    final quickSuggestions = [
      // Bữa ăn
      (
        '🥗 Gợi ý thực đơn tăng cơ',
        'Gợi ý cho tôi thực đơn tăng cơ giàu protein tối ưu',
      ),
      ('🍳 Bữa sáng nhanh gọn', 'Gợi ý bữa sáng lành mạnh chuẩn bị nhanh gọn'),
      (
        '🍱 Bữa trưa 500 kcal',
        'Hãy lên thực đơn bữa trưa khoảng 500 kcal giàu đạm',
      ),
      ('🥑 Bữa tối nhẹ bụng', 'Gợi ý bữa tối nhẹ bụng dễ tiêu hóa phục hồi cơ'),
      (
        '⚡ Bữa phụ giàu protein',
        'Gợi ý bữa phụ nạp năng lượng trước hoặc sau khi tập',
      ),
      // Buổi tập
      (
        '🏋️ Gợi ý buổi tập Ngực & Tay',
        'Gợi ý cho tôi buổi tập Ngực & Tay sau hiệu quả',
      ),
      (
        '🦅 Gợi ý buổi tập Lưng xô',
        'Gợi ý cho tôi buổi tập Lưng xô & Tay trước Pull Day',
      ),
      (
        '🦵 Gợi ý buổi tập Chân mông',
        'Gợi ý cho tôi buổi tập Chân & Mông toàn diện',
      ),
      (
        '⏱️ Buổi tập Full Body 45\'',
        'Gợi ý buổi tập toàn thân Full Body 45 phút',
      ),
      (
        '⚠️ Đau cổ tay khi Bench Press',
        'Hôm nay tôi bị đau cổ tay, có bài nào thay Bench Press không?',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          children: [
            Text(
              'AI Coach Chat',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            Text(
              'Hỏi đáp & Hỗ trợ thông minh',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Chat Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
              itemCount: state.messages.length + (state.isGenerating ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == state.messages.length) {
                  return const _GeneratingBubble();
                }
                return _MessageBubble(message: state.messages[index]);
              },
            ),
          ),

          // Horizontal Quick Suggestion Chips (Gợi ý bữa ăn & buổi tập)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: colors.surfaceContainer.withValues(alpha: 0.5),
              border: Border(
                top: BorderSide(
                  color: colors.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: quickSuggestions.map((item) {
                  final (label, prompt) = item;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      backgroundColor: colors.surfaceContainerHighest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      onPressed: () => _send(prompt),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Bottom Input Bar
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      enabled: !state.isGenerating,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Hỏi AI về món ăn, buổi tập, bài tập...',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: colors.onSurfaceVariant,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        filled: true,
                        fillColor: colors.surfaceContainer,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: state.isGenerating ? null : _send,
                    icon: const Icon(Icons.send_rounded, size: 20),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends ConsumerWidget {
  const _MessageBubble({required this.message});

  final AiChatMessage message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUser = message.sender == AiMessageSender.user;
    final colors = Theme.of(context).colorScheme;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * .88,
        ),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 7),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? colors.primary : colors.surfaceContainerHigh,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isUser ? colors.onPrimary : colors.onSurface,
                  fontSize: 13.5,
                  height: 1.35,
                ),
              ),
            ),
            if (message.proposal
                case final AlternativeExerciseProposal proposal)
              _ReplacementProposalCard(proposal: proposal),
            if (message.proposal case final MealProposal proposal)
              _MealProposalCard(proposal: proposal),
            if (message.proposal case final WorkoutProposal proposal)
              _WorkoutProposalCard(proposal: proposal),
            const SizedBox(height: 9),
          ],
        ),
      ),
    );
  }
}

class _ReplacementProposalCard extends ConsumerWidget {
  const _ReplacementProposalCard({required this.proposal});

  final AlternativeExerciseProposal proposal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPending = proposal.status == ProposalStatus.pending;
    final selected = proposal.alternatives
        .where((item) => item.exerciseId == proposal.selectedExerciseId)
        .firstOrNull;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.swap_horiz_rounded),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'GỢI Ý THAY BÀI AI',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        proposal.originalExerciseName,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                _StatusChip(status: proposal.status),
              ],
            ),
            const Divider(height: 22),
            ...proposal.alternatives.map((item) {
              final isApplied = item.exerciseId == proposal.selectedExerciseId;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isApplied
                      ? Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.12)
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isApplied
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Thiết bị: ${item.equipment} • Nhóm cơ: ${item.targetMuscles.join(', ')}',
                            style: const TextStyle(fontSize: 11),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.reason,
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isPending)
                      FilledButton.tonal(
                        onPressed: () =>
                            _confirmReplacement(context, ref, item),
                        child: const Text(
                          'Chọn bài này',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                  ],
                ),
              );
            }),
            Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.amber,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      proposal.warning,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
            if (isPending)
              TextButton(
                onPressed: () => ref
                    .read(aiCoachProvider.notifier)
                    .dismissProposal(proposal.id),
                child: const Text('Bỏ qua'),
              ),
            if (selected != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Đã thay bằng ${selected.name}',
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmReplacement(
    BuildContext context,
    WidgetRef ref,
    AlternativeExerciseItem alternative,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận thay bài tập?'),
        content: Text(
          'Chỉ thay ${proposal.originalExerciseName} bằng ${alternative.name}. Các bài khác và tiến độ của chúng sẽ được giữ nguyên.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Quay lại'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Xác nhận thay bài'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref
          .read(aiCoachProvider.notifier)
          .applyReplacement(proposal.id, alternative.exerciseId);
    }
  }
}

class _MealProposalCard extends ConsumerWidget {
  const _MealProposalCard({required this.proposal});

  final MealProposal proposal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.restaurant_rounded,
                    size: 16,
                    color: Colors.greenAccent,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    proposal.mealName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),
                _StatusChip(status: proposal.status),
              ],
            ),
            const Divider(height: 18),
            ...proposal.items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '• ${item.name} (${item.serving})',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '${item.calories} kcal • ${item.protein}g đạm',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tổng dinh dưỡng:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '${proposal.totalCalories} kcal • ${proposal.totalProtein.toStringAsFixed(1)}g Protein',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              proposal.reason,
              style: TextStyle(
                fontSize: 11.5,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.25,
              ),
            ),
            if (proposal.status == ProposalStatus.pending) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () => ref
                          .read(aiCoachProvider.notifier)
                          .applyMeal(proposal.id),
                      child: const Text(
                        'Thêm vào thực đơn',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => ref
                        .read(aiCoachProvider.notifier)
                        .dismissProposal(proposal.id),
                    child: const Text('Bỏ qua'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WorkoutProposalCard extends ConsumerWidget {
  const _WorkoutProposalCard({required this.proposal});

  final WorkoutProposal proposal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.primary.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.fitness_center_rounded,
                    size: 16,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        proposal.workoutTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${proposal.focusArea} • ~${proposal.durationMinutes} phút',
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusChip(status: proposal.status),
              ],
            ),
            const Divider(height: 18),
            ...proposal.items.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Tác động: ${item.targetMuscle} • Nghỉ: ${item.restSeconds}s',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.setsReps,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 6),
            Text(
              proposal.reason,
              style: TextStyle(
                fontSize: 11.5,
                color: colors.onSurfaceVariant,
                height: 1.25,
              ),
            ),
            if (proposal.status == ProposalStatus.pending) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        ref
                            .read(aiCoachProvider.notifier)
                            .applyWorkout(proposal.id);
                        context.push('/workout/session');
                      },
                      icon: const Icon(Icons.play_arrow_rounded, size: 18),
                      label: const Text(
                        'Bắt đầu tập ngay',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => ref
                        .read(aiCoachProvider.notifier)
                        .dismissProposal(proposal.id),
                    child: const Text('Bỏ qua'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final ProposalStatus status;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      ProposalStatus.pending => 'Chờ xác nhận',
      ProposalStatus.applied => 'Đã áp dụng',
      ProposalStatus.dismissed => 'Đã bỏ qua',
    };
    return Chip(
      visualDensity: VisualDensity.compact,
      label: Text(label, style: const TextStyle(fontSize: 9)),
    );
  }
}

class _GeneratingBubble extends StatelessWidget {
  const _GeneratingBubble();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 9),
            Text('AI Coach đang phân tích yêu cầu...'),
          ],
        ),
      ),
    );
  }
}
