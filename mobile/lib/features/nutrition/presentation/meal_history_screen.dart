import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MealHistoryScreen extends ConsumerWidget {
  const MealHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;

    final historyDays = [
      {'day': 'Hôm nay', 'date': '28/08', 'calories': 2140, 'target': 2450, 'status': 'Đạt chuẩn'},
      {'day': 'Hôm qua', 'date': '27/08', 'calories': 2380, 'target': 2450, 'status': 'Đạt chuẩn'},
      {'day': 'Thứ 3', 'date': '26/08', 'calories': 2510, 'target': 2450, 'status': 'Đạt chuẩn'},
      {'day': 'Thứ 2', 'date': '25/08', 'calories': 2100, 'target': 2450, 'status': 'Đạt chuẩn'},
      {'day': 'Chủ nhật', 'date': '24/08', 'calories': 2600, 'target': 2450, 'status': 'Vượt nhẹ'},
      {'day': 'Thứ 7', 'date': '23/08', 'calories': 2250, 'target': 2450, 'status': 'Đạt chuẩn'},
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Lịch sử dinh dưỡng'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          // Weekly Average Card
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trung bình tuần này',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '2,330 kcal / ngày',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '95% Tuân thủ mục tiêu',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.greenAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          const Text(
            'Chi tiết theo ngày',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),

          ...historyDays.map((item) {
            final calories = item['calories'] as int;
            final target = item['target'] as int;
            final ratio = (calories / target).clamp(0.0, 1.2);

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${item['day']} (${item['date']})',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '$calories / $target kcal',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: ratio > 1.0 ? 1.0 : ratio,
                      backgroundColor: colors.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(
                        ratio > 1.05 ? Colors.orange : colors.primary,
                      ),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
