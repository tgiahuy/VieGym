import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/utils/greeting_utils.dart';
import '../../../shared/widgets/auth_header.dart';
import '../../../shared/widgets/bouncing_icon_button.dart';
import '../../../shared/widgets/brand_icons.dart';
import '../../../shared/widgets/social_auth_button.dart';
import '../../onboarding/application/health_profile_controller.dart';
import '../../workout/application/workout_schedule_controller.dart';
import '../application/auth_controller.dart';
import '../domain/auth_state.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<String> _resolveTargetRoute() async {
    final user = ref.read(authProvider).user;
    var isHealthCompleted = user?.healthProfileCompleted ?? false;
    if (isHealthCompleted) {
      await ref.read(healthProfileProvider.notifier).loadProfileFromRemote();
    } else {
      isHealthCompleted = ref.read(healthProfileProvider).isCompleted;
    }
    final isEquipmentCompleted =
        (user?.equipmentCompleted ?? false) ||
        ref.read(equipmentOnboardingCompletedProvider);
    return resolveOnboardingRoute(
      isAuthenticated: true,
      isHealthProfileCompleted: isHealthCompleted,
      isEquipmentOnboardingCompleted: isEquipmentCompleted,
    );
  }

  Future<void> _handleLogin() async {
    final isBypass = ref.read(devBypassAuthProvider);
    if (isBypass) {
      final emailInput = _emailController.text.trim();
      final effectiveEmail = emailInput.isNotEmpty
          ? emailInput
          : 'athlete@viegym.vn';
      final effectiveName = effectiveEmail.split('@').first;
      ref
          .read(authProvider.notifier)
          .devBypassLogin(
            email: effectiveEmail,
            displayName: effectiveName.isNotEmpty
                ? effectiveName
                : 'VieGym Athlete',
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng nhập thành công (Bypass Auth)!')),
        );
      }
      final targetRoute = await _resolveTargetRoute();
      if (mounted) {
        context.go(targetRoute);
      }
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(authProvider.notifier)
        .login(
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (mounted) {
      final authState = ref.read(authProvider);
      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đăng nhập thành công!')));
        final targetRoute = await _resolveTargetRoute();
        try {
          await ref.read(workoutScheduleProvider.notifier).syncCurrentPeriod();
        } catch (_) {}
        if (mounted) {
          context.go(targetRoute);
        }
      } else if (authState.isPendingVerification) {
        final email = _emailController.text.trim();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authState.errorMessage ??
                  'Tài khoản chưa kích hoạt. Vui lòng nhập OTP.',
            ),
          ),
        );
        context.push(
          '/otp',
          extra: {'email': email, 'purpose': OtpPurpose.register},
        );
      } else {
        final error = authState.errorMessage;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error ?? 'Đăng nhập thất bại')));
      }
    }
  }

  Future<void> _handleBiometricLogin() async {
    final isBypass = ref.read(devBypassAuthProvider);
    if (isBypass) {
      ref
          .read(authProvider.notifier)
          .devBypassLogin(displayName: 'Biometric Athlete');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xác thực Sinh trắc học thành công (Bypass Auth)!'),
          ),
        );
      }
      final targetRoute = await _resolveTargetRoute();
      if (mounted) {
        context.go(targetRoute);
      }
      return;
    }
    final colors = Theme.of(context).colorScheme;

    final authenticated = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: colors.surfaceContainer,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Biometric Scanner Pulse Icon
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.fingerprint_rounded,
                    size: 40,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Xác thực Sinh trắc học',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sử dụng Face ID hoặc cảm biến vân tay trên thiết bị để đăng nhập nhanh vào VieGym.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(sheetContext, false),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Hủy'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => Navigator.pop(sheetContext, true),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 18,
                        ),
                        label: const Text('Xác thực ngay'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (authenticated == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Sinh trắc học chưa được cấu hình với phiên đăng nhập thật.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthHeader(
                  title: 'Đăng nhập',
                  subtitle:
                      '${getTimeBasedGreeting()}! Chào mừng bạn quay trở lại VieGym',
                  onBack: () => context.pop(),
                ),
                const SizedBox(height: 28),
                Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: 'ten@example.com',
                    prefixIcon: const Icon(Icons.email_outlined, size: 20),
                    filled: true,
                    fillColor: colors.surfaceContainer,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    if (!value.contains('@')) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Mật khẩu',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleLogin(),
                  decoration: InputDecoration(
                    hintText: 'Nhập mật khẩu',
                    prefixIcon: const Icon(
                      Icons.lock_outline_rounded,
                      size: 20,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    filled: true,
                    fillColor: colors.surfaceContainer,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu';
                    }
                    return null;
                  },
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: Text(
                      'Quên mật khẩu?',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ),
                if (ref.watch(devBypassAuthProvider)) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.bolt_rounded,
                          size: 20,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Bypass Auth đang bật: Bấm "Đăng nhập" để vào thẳng Onboarding mà không cần mật khẩu.',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.onSurface,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Login action row with Face ID / Biometrics button
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: authState.isLoading ? null : _handleLogin,
                        child: authState.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Đăng nhập',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Biometric Authentication (Face ID / Fingerprint) button
                    BouncingIconButton(
                      tooltip: 'Đăng nhập bằng Face ID / Vân tay',
                      icon: const Icon(Icons.fingerprint_rounded, size: 28),
                      backgroundColor: colors.surfaceContainer,
                      color: colors.onSurface,
                      borderRadius: 16,
                      padding: const EdgeInsets.all(12),
                      enableGlow: false,
                      onPressed: _handleBiometricLogin,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: colors.outlineVariant.withValues(alpha: 0.6),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'Hoặc tiếp tục với',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: colors.outlineVariant.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Enhanced Google and Facebook Social Login Buttons
                Row(
                  children: [
                    Expanded(
                      child: SocialAuthButton(
                        label: 'Google',
                        icon: const GoogleLogo(size: 20),
                        onPressed: () async {
                          if (ref.read(devBypassAuthProvider)) {
                            ref
                                .read(authProvider.notifier)
                                .devBypassLogin(
                                  email: 'google.athlete@viegym.vn',
                                  displayName: 'Google Athlete',
                                );
                            final targetRoute = await _resolveTargetRoute();
                            if (context.mounted) {
                              context.go(targetRoute);
                            }
                            return;
                          }
                          final success = await ref
                              .read(authProvider.notifier)
                              .loginWithGoogle();
                          if (context.mounted && success) {
                            final targetRoute = await _resolveTargetRoute();
                            if (context.mounted) {
                              context.go(targetRoute);
                            }
                          } else if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  ref.read(authProvider).errorMessage ??
                                      'Đăng nhập Google thất bại',
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SocialAuthButton(
                        label: 'Facebook',
                        icon: const FacebookLogo(size: 20),
                        onPressed: () async {
                          if (ref.read(devBypassAuthProvider)) {
                            ref
                                .read(authProvider.notifier)
                                .devBypassLogin(
                                  email: 'facebook.athlete@viegym.vn',
                                  displayName: 'Facebook Athlete',
                                );
                            final targetRoute = await _resolveTargetRoute();
                            if (context.mounted) {
                              context.go(targetRoute);
                            }
                            return;
                          }
                          final success = await ref
                              .read(authProvider.notifier)
                              .loginWithFacebook();
                          if (context.mounted && success) {
                            final targetRoute = await _resolveTargetRoute();
                            if (context.mounted) {
                              context.go(targetRoute);
                            }
                          } else if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  ref.read(authProvider).errorMessage ??
                                      'Đăng nhập Facebook thất bại',
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Chưa có tài khoản?',
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/register'),
                      child: Text(
                        'Đăng ký ngay',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
