import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/application/auth_controller.dart';
import '../../onboarding/application/health_profile_controller.dart';
import '../application/progress_controller.dart';

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
        final colors = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          icon: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors.error.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.logout_rounded, color: colors.error, size: 24),
          ),
          title: const Text(
            'Đăng xuất tài khoản?',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
          content: const Text(
            'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng VieGym?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5, color: Colors.grey),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: BorderSide(
                        color: colors.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      'Hủy',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.error,
                      foregroundColor: colors.onError,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      ref.read(authProvider.notifier).logout();
                      context.go('/welcome');
                    },
                    child: const Text(
                      'Đăng xuất',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
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
    final userEquipment = ref.watch(userEquipmentProvider);
    final progressState = ref.watch(progressProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text(
          'Cài đặt',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          // 1. Quản lý & Thiết lập tập luyện
          Text(
            'Quản lý & Thiết lập',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              color: colors.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.emoji_events_rounded,
                    color: Colors.amber,
                  ),
                  title: const Text(
                    'Kỷ lục cá nhân (PR)',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  subtitle: Text(
                    '${progressState.personalRecords.length} kỷ lục đã ghi nhận',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/profile/records'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.fitness_center_rounded,
                    color: Color(0xFFFF2E54),
                  ),
                  title: const Text(
                    'Thiết bị tập luyện',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  subtitle: Text(
                    '${userEquipment.length} thiết bị đã chọn',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/profile/equipment'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.tune_rounded,
                    color: Colors.deepPurpleAccent,
                  ),
                  title: const Text(
                    'Tùy chọn & Ràng buộc cá nhân',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/profile/preferences'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.security_rounded,
                    color: Colors.greenAccent,
                  ),
                  title: const Text(
                    'Bảo mật tài khoản',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/profile/security'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 2. AI Personalization Section
          Text(
            'Trí tuệ nhân tạo (AI Coach)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              color: colors.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(
                    Icons.auto_awesome_rounded,
                    color: colors.primary,
                  ),
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

          // 3. Workout & Sound Section
          Text(
            'Luyện tập & Âm thanh',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              color: colors.onSurface.withValues(alpha: 0.8),
            ),
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
                    'Tiếng Việt',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 4. About VieGym
          Text(
            'Về ứng dụng',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              color: colors.onSurface.withValues(alpha: 0.8),
            ),
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
                  subtitle: const Text(
                    'Nội dung pháp lý đang được cập nhật',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.schedule_rounded, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // 5. Logout Action
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
            label: const Text(
              'Đăng xuất tài khoản',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
