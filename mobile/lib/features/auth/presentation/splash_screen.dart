import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:viegym/shared/widgets/brand_icons.dart';
import '../../onboarding/application/health_profile_controller.dart';
import '../application/auth_controller.dart';
import '../domain/auth_state.dart';

/// MH01 — Splash / Session Bootstrap Screen
/// Khởi tạo ứng dụng, phục hồi phiên nếu có và điều hướng tới route hợp lệ.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Bắt đầu bootstrap phiên làm việc
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrapSession();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _bootstrapSession() async {
    setState(() {
      _hasError = false;
      _errorMessage = null;
    });

    try {
      // Đợi ngắn để hiển thị splash mượt mà và kiểm tra session
      await Future<void>.delayed(const Duration(milliseconds: 600));

      if (!mounted) return;

      // Khôi phục phiên từ secure storage nếu có
      await ref.read(authProvider.notifier).restoreSession();

      if (!mounted) return;

      final authState = ref.read(authProvider);

      if (authState.status == AuthStatus.authenticated &&
          authState.user != null) {
        final healthProfile = ref.read(healthProfileProvider);
        final equipmentCompleted = ref.read(
          equipmentOnboardingCompletedProvider,
        );
        final targetRoute = resolveOnboardingRoute(
          isAuthenticated: true,
          isHealthProfileCompleted: healthProfile.isCompleted,
          isEquipmentOnboardingCompleted: equipmentCompleted,
        );
        context.go(targetRoute);
      } else {
        // Chưa có phiên đăng nhập -> sang màn hình Welcome (MH02)
        context.go('/welcome');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Không thể kết nối đến máy chủ. Vui lòng thử lại.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Animated Brand Logo
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colors.primary.withValues(alpha: 0.25),
                            blurRadius: 32,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const VieGymLogo(size: 88, borderRadius: 24),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // App Name
                Text(
                  'VIEGYM',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 4,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 8),

                // Slogan
                Text(
                  'Luyện tập & Dinh dưỡng thông minh',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                    color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                  ),
                ),

                const Spacer(),

                // Loading or Error State
                if (_hasError) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.errorContainer.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colors.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.wifi_off_rounded,
                          color: colors.error,
                          size: 28,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage ?? 'Đã có lỗi xảy ra',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.onErrorContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _bootstrapSession,
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Thử lại'),
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: colors.onPrimary,
                            minimumSize: const Size(140, 42),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Đang khởi tạo phiên làm việc...',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
