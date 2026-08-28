import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          children: [
            Text('AI Coach Chat'),
            Text('Chế độ cá nhân hóa', style: TextStyle(fontSize: 10)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
              itemCount: state.messages.length + (state.isGenerating ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == state.messages.length) {
                  return const _GeneratingBubble();
                }
                return _MessageBubble(message: state.messages[index]);
              },
            ),
          ),
          if (state.messages.length == 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
              child: Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  ActionChip(
                    label: const Text('Đau cổ tay khi Bench Press'),
                    onPressed: () => _send(
                      'Hôm nay tôi bị đau cổ tay, có bài nào thay Bench Press không?',
                    ),
                  ),
                  ActionChip(
                    label: const Text('Gợi ý bữa trưa'),
                    onPressed: () =>
                        _send('Hãy lên thực đơn bữa trưa giúp tôi'),
                  ),
                ],
              ),
            ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
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
                      decoration: const InputDecoration(
                        hintText: 'Nhập yêu cầu món ăn hoặc bài tập...',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: state.isGenerating ? null : _send,
                    icon: const Icon(Icons.send_rounded),
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
                ),
              ),
            ),
            if (message.proposal
                case final AlternativeExerciseProposal proposal)
              _ReplacementProposalCard(proposal: proposal),
            if (message.proposal case final MealProposal proposal)
              _MealProposalCard(proposal: proposal),
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
            const Divider(height: 24),
            ...proposal.alternatives.map(
              (alternative) => Container(
                margin: const EdgeInsets.only(bottom: 9),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Theme.of(context).colorScheme.surfaceContainer,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alternative.name,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${alternative.targetMuscles.join(', ')} • ${alternative.equipment}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 7),
                    Text(
                      alternative.reason,
                      style: const TextStyle(fontSize: 12, height: 1.4),
                    ),
                    if (isPending) ...[
                      const SizedBox(height: 9),
                      OutlinedButton(
                        onPressed: () =>
                            _confirmReplacement(context, ref, alternative),
                        child: const Text('Chọn bài này'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 18,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 7),
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
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.restaurant_rounded),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Đề xuất ${proposal.mealName}',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                _StatusChip(status: proposal.status),
              ],
            ),
            const Divider(height: 22),
            ...proposal.items.map(
              (item) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(item.name),
                subtitle: Text(item.serving),
                trailing: Text('${item.calories} kcal'),
              ),
            ),
            Text(
              '${proposal.totalCalories} kcal • ${proposal.totalProtein.toStringAsFixed(1)}g protein',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(proposal.reason, style: const TextStyle(fontSize: 12)),
            if (proposal.status == ProposalStatus.pending) ...[
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () =>
                    ref.read(aiCoachProvider.notifier).applyMeal(proposal.id),
                child: const Text('Áp dụng / Thêm vào thực đơn'),
              ),
              TextButton(
                onPressed: () => ref
                    .read(aiCoachProvider.notifier)
                    .dismissProposal(proposal.id),
                child: const Text('Bỏ qua'),
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
