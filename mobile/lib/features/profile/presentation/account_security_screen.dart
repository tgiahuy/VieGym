import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/application/auth_controller.dart';

/// MH53 — Account Security & Change Password Screen
class AccountSecurityScreen extends ConsumerStatefulWidget {
  const AccountSecurityScreen({super.key});

  @override
  ConsumerState<AccountSecurityScreen> createState() =>
      _AccountSecurityScreenState();
}

class _AccountSecurityScreenState extends ConsumerState<AccountSecurityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  bool _twoFactorEnabled = true;
  bool _biometricEnabled = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).changePassword(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
          confirmPassword: _confirmPasswordController.text,
        );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đổi mật khẩu thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      } else {
        final error = ref.read(authProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Đổi mật khẩu thất bại'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Bảo mật tài khoản'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
          children: [
            // Change Password Card (MH53)
            Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              color: colors.surfaceContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: colors.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lock_reset_rounded, color: colors.primary),
                        const SizedBox(width: 8),
                        const Text(
                          'Đổi mật khẩu',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Current Password
                    TextFormField(
                      controller: _currentPasswordController,
                      obscureText: _obscureCurrentPassword,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu hiện tại',
                        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureCurrentPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureCurrentPassword = !_obscureCurrentPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập mật khẩu hiện tại';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // New Password
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: _obscureNewPassword,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu mới',
                        prefixIcon: const Icon(Icons.key_rounded, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNewPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureNewPassword = !_obscureNewPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập mật khẩu mới';
                        }
                        if (value.length < 6) {
                          return 'Mật khẩu phải có ít nhất 6 ký tự';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Confirm New Password
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _changePassword(),
                      decoration: InputDecoration(
                        labelText: 'Xác nhận mật khẩu mới',
                        prefixIcon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng xác nhận mật khẩu mới';
                        }
                        if (value != _newPasswordController.text) {
                          return 'Mật khẩu xác nhận không khớp';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    FilledButton(
                      onPressed: authState.isLoading ? null : _changePassword,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: authState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Cập nhật mật khẩu',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Biometric Settings (MH08)
            const Text(
              'Xác thực Sinh trắc học',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              color: colors.surfaceContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: colors.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: SwitchListTile(
                secondary: Icon(Icons.fingerprint_rounded, color: colors.primary),
                title: const Text(
                  'Mở khóa nhanh Face ID / Vân tay',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                subtitle: const Text(
                  'Sử dụng sinh trắc học thiết bị để đăng nhập nhanh mà không cần nhập lại mật khẩu.',
                  style: TextStyle(fontSize: 12),
                ),
                value: _biometricEnabled,
                onChanged: (val) {
                  setState(() => _biometricEnabled = val);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        val
                            ? 'Đã bật xác thực sinh trắc học'
                            : 'Đã tắt xác thực sinh trắc học',
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Two-Factor Auth
            const Text(
              'Bảo vệ 2 lớp (2FA)',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              color: colors.surfaceContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: colors.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: SwitchListTile(
                secondary: const Icon(Icons.security_rounded),
                title: const Text(
                  'Xác thực OTP qua email',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                subtitle: const Text(
                  'Yêu cầu nhập mã OTP 6 số mỗi khi đăng nhập trên thiết bị lạ.',
                  style: TextStyle(fontSize: 12),
                ),
                value: _twoFactorEnabled,
                onChanged: (val) => setState(() => _twoFactorEnabled = val),
              ),
            ),
            const SizedBox(height: 20),

            // Active Devices
            const Text(
              'Thiết bị đang đăng nhập',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              color: colors.surfaceContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: colors.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.phone_iphone_rounded,
                      color: Colors.greenAccent,
                    ),
                    title: const Text(
                      'iPhone 17 Pro Max (Thiết bị này)',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    subtitle: const Text(
                      'Hồ Chí Minh, Việt Nam • Đang hoạt động',
                      style: TextStyle(fontSize: 12),
                    ),
                    trailing: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
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
