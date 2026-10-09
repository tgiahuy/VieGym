import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../data/ai_repository.dart';
import '../domain/ai_models.dart';

class AiConversationHistoryScreen extends ConsumerStatefulWidget {
  const AiConversationHistoryScreen({super.key});

  @override
  ConsumerState<AiConversationHistoryScreen> createState() =>
      _AiConversationHistoryScreenState();
}

class _AiConversationHistoryScreenState
    extends ConsumerState<AiConversationHistoryScreen> {
  late Future<List<AiConversationSummary>> _future;

  @override
  void initState() {
    super.initState();
    _future = ref.read(aiRepositoryProvider).getConversations();
  }

  void _reload() {
    setState(() {
      _future = ref.read(aiRepositoryProvider).getConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử AI Coach')),
      body: FutureBuilder<List<AiConversationSummary>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off_rounded, size: 36),
                    const SizedBox(height: 12),
                    const Text('Không thể tải lịch sử trò chuyện.'),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _reload,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }
          final conversations = snapshot.data ?? const [];
          if (conversations.isEmpty) {
            return const Center(
              child: Text(
                'Chưa có cuộc trò chuyện nào.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: conversations.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = conversations[index];
                final personalized = item.requestedMode == 'PERSONALIZED';
                return Card(
                  child: ListTile(
                    leading: Icon(
                      personalized
                          ? Icons.auto_awesome_rounded
                          : Icons.public_rounded,
                      color: personalized ? AppColors.aiViolet : AppColors.info,
                    ),
                    title: Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      item.preview?.isNotEmpty == true
                          ? item.preview!
                          : personalized
                          ? 'Cá nhân hóa'
                          : 'Kiến thức chung',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
