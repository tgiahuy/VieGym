import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/application/auth_controller.dart';

class AiConsentNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() => state = !state;
  void setConsent(bool val) => state = val;
}

final aiConsentProvider = NotifierProvider<AiConsentNotifier, bool>(
  AiConsentNotifier.new,
);

class AudioCuesNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() => state = !state;
  void setAudio(bool val) => state = val;
}

final audioCuesProvider = NotifierProvider<AudioCuesNotifier, bool>(
  AudioCuesNotifier.new,
);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Đăng xuất tài khoản?'),
          content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng VieGym?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                ref.read(authProvider.notifier).logout();
                context.go('/welcome');
              },
              child: const Text('Đăng xuất'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiConsent = ref.watch(aiConsentProvider);
    final audioCues = ref.watch(audioCuesProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Cài đặt ứng dụng'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          // AI Personalization Section
          const Text(
            'Trí tuệ nhân tạo (AI Coach)',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(Icons.auto_awesome_rounded, color: colors.primary),
                  title: const Text(
                    'Cá nhân hóa AI theo hồ sơ',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Cho phép AI truy cập thể trạng & thiết bị để tư vấn bài tập chính xác nhất.',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: aiConsent,
                  onChanged: (val) {
                    ref.read(aiConsentProvider.notifier).setConsent(val);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          val
                              ? 'Đã bật cá nhân hóa AI theo hồ sơ'
                              : 'Đã chuyển sang chế độ Kiến thức chung',
                        ),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text(
                    'Chi tiết quyền riêng tư & Dữ liệu AI',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/ai/consent'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Workout & Notification Section
          const Text(
            'Luyện tập & Âm thanh',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.volume_up_rounded),
                  title: const Text(
                    'Âm thanh đếm ngược nghỉ',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Phát chuông thông báo khi kết thúc thời gian nghỉ giữa các hiệp.',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: audioCues,
                  onChanged: (val) =>
                      ref.read(audioCuesProvider.notifier).setAudio(val),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language_rounded),
                  title: const Text(
                    'Ngôn ngữ',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  trailing: const Text(
                    'Tiếng Việt (Mặc định)',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // About VieGym
          const Text(
            'Về ứng dụng',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info_outline_rounded),
                  title: Text(
                    'Phiên bản',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  trailing: Text(
                    'v1.0.0 (Flutter Native)',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text(
                    'Chính sách bảo mật & Điều khoản',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Logout Action
          OutlinedButton.icon(
            onPressed: () => _confirmLogout(context, ref),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: const BorderSide(color: Colors.redAccent),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Đăng xuất tài khoản', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
