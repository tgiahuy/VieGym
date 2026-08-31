import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:viegym/shared/widgets/brand_icons.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background Gradient / Glow
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    colors.surface.withValues(alpha: 0.08),
                    colors.surface.withValues(alpha: 0.62),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Logo Top-Left Corner
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const VieGymLogo(size: 44, borderRadius: 14),
                      const SizedBox(width: 12),
                      Text(
                        'VIEGYM',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 2,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Bottom Content & Actions
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tập thông minh.\nSống khoẻ mạnh.',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Huấn luyện viên thể hình & dinh dưỡng cá nhân hoá cùng trí tuệ nhân tạo AI.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                          height: 1.45,
                          fontSize: 14.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      FilledButton(
                        onPressed: () => context.push('/register'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Bắt đầu ngay',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => context.push('/login'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: BorderSide(color: colors.outlineVariant),
                          backgroundColor: colors.surfaceContainer.withValues(
                            alpha: 0.6,
                          ),
                        ),
                        child: Text(
                          'Bạn đã có tài khoản?',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
