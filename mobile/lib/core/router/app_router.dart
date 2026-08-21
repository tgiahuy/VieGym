import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Central router for VieGym.
///
/// Route hierarchy (P0 — full routes implemented in M2+):
/// ```
/// /                   → SplashScreen (session bootstrap)
/// /welcome            → WelcomeScreen
/// /login              → LoginScreen
/// /register           → RegisterScreen
/// /otp                → OtpScreen
/// /onboarding/health  → HealthOnboardingScreen
/// /onboarding/equip   → EquipmentOnboardingScreen
/// /home               → HomeShell (BottomNavigationBar)
///   /home/dashboard   → DashboardScreen
///   /home/workout     → WorkoutTab
///   /home/nutrition   → NutritionTab
///   /home/ai          → AICoachTab
///   /home/profile     → ProfileScreen
/// /admin              → AdminShell (role-guarded)
/// ```
///
/// Navigation guards (redirect logic) are added in M2 once session state is
/// available. For now the router exposes a placeholder home screen so the
/// app can build and run end-to-end from M1.
final routerProvider = Provider<GoRouter>(
  (ref) {
    return GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true, // disabled in prod via kReleaseMode in M8
      routes: [
        GoRoute(
          path: '/',
          name: 'splash',
          builder: (context, state) =>
              const _PlaceholderScreen(title: 'VieGym'),
        ),
      ],
    );
  },
  name: 'routerProvider',
);

/// Temporary placeholder used until real screens are implemented in M2+.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center,
                size: 72, color: theme.colorScheme.primary),
            const SizedBox(height: 24),
            Text(
              'VieGym',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Backend kết nối và stack đang chạy ✓',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
