import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/application/auth_controller.dart';
import '../../onboarding/application/health_profile_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

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
    final authState = ref.watch(authProvider);
    final healthProfile = ref.watch(healthProfileProvider);
    final userEquipment = ref.watch(userEquipmentProvider);
    final colors = Theme.of(context).colorScheme;

    final userName = healthProfile.nickname.isNotEmpty
        ? healthProfile.nickname
        : (authState.user?.displayName ?? 'Nguyễn Văn Gym');
    final userEmail = authState.user?.email ?? 'viegym.user@gmail.com';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
        actions: [
          IconButton(
            onPressed: () => context.push('/profile/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
        children: [
          // User Info Header Card
          Card(
            margin: EdgeInsets.zero,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.push('/profile/user'),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: colors.primary.withValues(alpha: 0.15),
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'G',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: colors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                userName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'PRO',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.amber,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            userEmail,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: colors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Physical Metrics Overview Card
          Card(
            margin: EdgeInsets.zero,
            color: colors.primary.withValues(alpha: 0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: colors.primary.withValues(alpha: 0.3)),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => context.push('/profile/health'),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.monitor_heart_rounded,
                                size: 18, color: colors.primary),
                            const SizedBox(width: 6),
                            Text(
                              'Chỉ số thể chất & Thể trạng',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: colors.primary,
                              ),
                            ),
                          ],
                        ),
                        const Icon(Icons.edit_outlined, size: 16),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(
                          label: 'CÂN NẶNG',
                          value: '${healthProfile.weightKg} kg',
                        ),
                        _StatItem(
                          label: 'BMI',
                          value: healthProfile.bmi.toStringAsFixed(1),
                          valueColor: Colors.greenAccent,
                        ),
                        _StatItem(
                          label: 'TDEE',
                          value: '${healthProfile.tdee.toStringAsFixed(0)} kcal',
                          valueColor: Colors.orange,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Menu Sections
          const Text(
            'Quản lý & Thiết lập',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),

          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.trending_up_rounded, color: Colors.blueAccent),
                  title: const Text('Tiến độ & Thống kê tập luyện', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/progress'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.favorite_outline_rounded, color: Colors.redAccent),
                  title: const Text('Chỉ số thể chất & Mục tiêu', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/profile/health'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.fitness_center_rounded, color: Colors.amber),
                  title: const Text('Thiết bị tập luyện', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  subtitle: Text('${userEquipment.length} thiết bị đã chọn', style: const TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/profile/equipment'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.tune_rounded, color: Colors.deepPurpleAccent),
                  title: const Text('Tùy chọn & Ràng buộc cá nhân', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/profile/preferences'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.security_rounded, color: Colors.greenAccent),
                  title: const Text('Bảo mật tài khoản', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/profile/security'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Cài đặt ứng dụng', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/profile/settings'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Logout Button
          OutlinedButton.icon(
            onPressed: () => _confirmLogout(context, ref),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: const BorderSide(color: Colors.redAccent),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
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

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: colors.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: valueColor ?? colors.onSurface,
          ),
        ),
      ],
    );
  }
}
