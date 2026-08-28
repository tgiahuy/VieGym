import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient / Glow
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.surface,
                    colors.surfaceContainerHighest.withValues(alpha: 0.4),
                    colors.surface,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primary.withValues(alpha: 0.12),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 20),
                  // Logo Center
                  Column(
                    children: [
                      Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: colors.primary.withValues(alpha: 0.45),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colors.primary.withValues(alpha: 0.35),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.fitness_center_rounded,
                            size: 52,
                            color: colors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'VIEGYM',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 2,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                  // Bottom Content & Actions
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tập thông minh.\nSống khoẻ mạnh.',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Huấn luyện viên thể hình & dinh dưỡng cá nhân hoá cùng trí tuệ nhân tạo AI.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                              height: 1.4,
                            ),
                      ),
                      const SizedBox(height: 28),
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
                          side: BorderSide(
                            color: colors.outlineVariant,
                          ),
                          backgroundColor: colors.surfaceContainer.withValues(alpha: 0.6),
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
