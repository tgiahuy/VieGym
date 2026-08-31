import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../profile/presentation/settings_screen.dart';

class AiConsentScreen extends ConsumerWidget {
  const AiConsentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiConsent = ref.watch(aiConsentProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Cài đặt AI & Quyền riêng tư'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
        children: [
          const Text(
            'Cá nhân hóa AI (VieGym AI)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          const Text(
            'Kiểm soát cách VieGym AI sử dụng dữ liệu của bạn để đưa ra các đề xuất luyện tập và phục hồi.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 18),

          // Master Switch Card
          Card(
            margin: EdgeInsets.zero,
            child: SwitchListTile(
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.auto_awesome_rounded, color: colors.primary),
              ),
              title: const Text(
                'Bật AI Cá nhân hóa',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
              subtitle: const Text(
                'Cho phép AI đọc mục tiêu, thiết bị và mức phục hồi cơ bắp của bạn.',
                style: TextStyle(fontSize: 12),
              ),
              value: aiConsent,
              onChanged: (val) {
                ref.read(aiConsentProvider.notifier).setConsent(val);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      val
                          ? 'Đã bật Chế độ AI Cá nhân hóa'
                          : 'Đã chuyển sang Chế độ Kiến thức Phổ quát',
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Status Explanation Card
          if (aiConsent)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 18,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Chế độ Cá nhân hóa đang hoạt động',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '• AI tự động điều chỉnh bài tập theo thiết bị hiện có của bạn.\n'
                    '• Tránh các nhóm cơ chưa hồi phục hoàn toàn.\n'
                    '• Tính toán số rep, hiệp và mức tạ phù hợp với trình độ.',
                    style: TextStyle(fontSize: 12, height: 1.5),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.visibility_off_rounded,
                        size: 18,
                        color: Colors.amber,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Chế độ Kiến thức Phổ quát (General Knowledge)',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'AI sẽ chỉ tạo các buổi tập theo giáo án tiêu chuẩn cơ bản. Mọi thông tin sức khỏe, mức phục hồi cơ và cấu hình thiết bị cá nhân sẽ được ẩn hoàn toàn.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          // Privacy Card
          Card(
            margin: EdgeInsets.zero,
            color: Theme.of(context).colorScheme.surfaceContainer,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 18,
                        color: Colors.blueAccent,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Cam kết an toàn dữ liệu VieGym',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Dữ liệu của bạn được bảo mật nghiêm ngặt và chỉ phục vụ cho việc tính toán luyện tập cá nhân. Bạn có thể thay đổi tùy chọn này bất cứ lúc nào.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          OutlinedButton(
            onPressed: () => context.pop(),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Xong',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
