import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AccountSecurityScreen extends StatefulWidget {
  const AccountSecurityScreen({super.key});

  @override
  State<AccountSecurityScreen> createState() => _AccountSecurityScreenState();
}

class _AccountSecurityScreenState extends State<AccountSecurityScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _twoFactorEnabled = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _changePassword() {
    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu mới phải có ít nhất 6 ký tự!')),
      );
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu xác nhận không khớp!')),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đổi mật khẩu thành công!')));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Bảo mật tài khoản'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
        children: [
          // Change Password Card
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Đổi mật khẩu',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _currentPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Mật khẩu hiện tại',
                      prefixIcon: Icon(Icons.lock_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Mật khẩu mới',
                      prefixIcon: Icon(Icons.lock_reset_rounded),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Xác nhận mật khẩu mới',
                      prefixIcon: Icon(Icons.check_circle_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _changePassword,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 46),
                    ),
                    child: const Text('Cập nhật mật khẩu'),
                  ),
                ],
              ),
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
            child: SwitchListTile(
              secondary: const Icon(Icons.security_rounded),
              title: const Text(
                'Xác thực OTP qua email/SĐT',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              subtitle: const Text(
                'Yêu cầu nhập mã xác thực 6 số mỗi khi đăng nhập trên thiết bị lạ.',
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
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.phone_iphone_rounded,
                    color: Colors.greenAccent,
                  ),
                  title: const Text(
                    'iPhone 15 Pro (Thiết bị này)',
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
    );
  }
}
