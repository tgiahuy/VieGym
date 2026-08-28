import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/application/auth_controller.dart';
import '../../onboarding/application/health_profile_controller.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(healthProfileProvider);
    final authState = ref.read(authProvider);
    final initialName = profile.nickname.isNotEmpty
        ? profile.nickname
        : (authState.user?.displayName ?? 'Nguyễn Văn Gym');
    _nameController = TextEditingController(text: initialName);
    _bioController = TextEditingController(
      text: 'Mục tiêu: Tăng cơ nạc, tập đều 5 buổi / tuần.',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      ref.read(healthProfileProvider.notifier).updateNickname(name);
      ref.read(authProvider.notifier).updateDisplayName(name);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã cập nhật thông tin cá nhân!')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Chỉnh sửa hồ sơ'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
        children: [
          // Avatar Center
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: colors.primary.withValues(alpha: 0.2),
                  child: Icon(Icons.person_rounded, size: 56, color: colors.primary),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.camera_alt_rounded, size: 16, color: colors.onPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Họ và tên',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _bioController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Mô tả / Châm ngôn luyện tập',
              prefixIcon: Icon(Icons.edit_note_rounded),
            ),
          ),
          const SizedBox(height: 28),

          FilledButton(
            onPressed: _saveProfile,
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Lưu thay đổi',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
