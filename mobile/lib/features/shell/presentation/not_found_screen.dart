import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key, this.errorMessage});

  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Không tìm thấy trang'),
        leading: IconButton(
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search_off_rounded,
                  size: 40,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '404',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Trang bạn tìm kiếm không tồn tại hoặc đã bị chuyển dời.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.redAccent),
                ),
              ],
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: () => context.go('/home'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.home_rounded),
                label: const Text(
                  'Quay về Trang chủ',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
