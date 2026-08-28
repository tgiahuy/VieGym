import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AiTabScreen extends StatelessWidget {
  const AiTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VieGym AI Coach'),
        actions: [
          IconButton(
            onPressed: () => context.push('/ai/consent'),
            icon: const Icon(Icons.shield_outlined),
            tooltip: 'Quyền riêng tư AI',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.tertiary,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 34,
                ),
                const SizedBox(height: 22),
                const Text(
                  'AI Coach Chat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Hỏi về dinh dưỡng, buổi tập hoặc nhận gợi ý thay bài khi đang khó chịu.',
                  style: TextStyle(color: Colors.white70, height: 1.4),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () => context.push('/ai/chat'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                  label: const Text('Mở cuộc trò chuyện'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Gợi ý hôm nay',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          const _RecommendationCard(
            icon: Icons.fitness_center_rounded,
            title: 'Upper Body tối ưu',
            content:
                'Nhóm cơ ngực và vai đã phục hồi tốt cho buổi tập hôm nay.',
            priority: 'Ưu tiên cao',
          ),
          const _RecommendationCard(
            icon: Icons.bedtime_outlined,
            title: 'Phục hồi cơ chân',
            content: 'Cơ chân đã có đủ thời gian nghỉ sau buổi tập gần nhất.',
            priority: 'Thông tin',
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.icon,
    required this.title,
    required this.content,
    required this.priority,
  });

  final IconData icon;
  final String title;
  final String content;
  final String priority;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(child: Icon(icon)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: const TextStyle(fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    priority,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
