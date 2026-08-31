import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/application/auth_controller.dart';
import '../../onboarding/application/health_profile_controller.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final healthProfile = ref.watch(healthProfileProvider);
    final user = authState.user;
    final colors = Theme.of(context).colorScheme;

    final displayName = healthProfile.nickname.isNotEmpty
        ? healthProfile.nickname
        : (user?.displayName ?? 'Gia Huy');
    final email = user?.email ?? 'viegym.user@gmail.com';
    final phoneNumber = user?.phoneNumber ?? '0987 654 321';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Hồ sơ tài khoản'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        children: [
          // Avatar & Name Card
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: colors.primary.withValues(alpha: 0.15),
                    child: Text(
                      displayName.isNotEmpty
                          ? displayName[0].toUpperCase()
                          : 'G',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: colors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.tonalIcon(
                    onPressed: () => context.push('/profile/edit'),
                    icon: const Icon(Icons.edit_rounded, size: 16),
                    label: const Text('Chỉnh sửa hồ sơ'),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Account Details Box
          const Text(
            'THÔNG TIN TÀI KHOẢN',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),

          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.person_outline_rounded, size: 20),
                  ),
                  title: const Text(
                    'Tên hiển thị',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  subtitle: Text(
                    displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.mail_outline_rounded, size: 20),
                  ),
                  title: const Text(
                    'Email đăng nhập',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  subtitle: Text(
                    email,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'ĐÃ XÁC THỰC',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.greenAccent,
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.phone_outlined, size: 20),
                  ),
                  title: const Text(
                    'Số điện thoại',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  subtitle: Text(
                    phoneNumber,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'ĐÃ XÁC THỰC',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.greenAccent,
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.shield_outlined, size: 20),
                  ),
                  title: const Text(
                    'Phương thức đăng nhập',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  subtitle: const Text(
                    'Email & Mật khẩu',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.calendar_month_outlined, size: 20),
                  ),
                  title: const Text(
                    'Ngày gia nhập',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  subtitle: const Text(
                    'Tháng 8, 2026',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
