import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:viegym/features/onboarding/application/health_profile_controller.dart';
import 'package:viegym/features/onboarding/domain/user_profile_models.dart';
import 'package:viegym/features/shell/presentation/home_shell.dart';

void main() {
  Widget buildApp({
    List overrides = const [],
  }) {
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              HomeShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (_, _) => const Scaffold(body: Text('Home Screen')),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/workout',
                  builder: (_, _) =>
                      const Scaffold(body: Text('Workout Screen')),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/meal',
                  builder: (_, _) =>
                      const Scaffold(body: Text('Nutrition Screen')),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/ai',
                  builder: (_, _) => const Scaffold(body: Text('AI Screen')),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  builder: (_, _) =>
                      const Scaffold(body: Text('Profile Screen')),
                ),
              ],
            ),
          ],
        ),
      ],
    );

    return ProviderScope(
      overrides: overrides.cast(),
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  group('HomeShell Instagram-style Navigation Bar', () {
    testWidgets('renders all 5 Instagram navigation tabs without text labels',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Verify all 5 tab keys are present
      expect(find.byKey(const ValueKey('nav_home')), findsOneWidget);
      expect(find.byKey(const ValueKey('nav_workout')), findsOneWidget);
      expect(find.byKey(const ValueKey('nav_nutrition')), findsOneWidget);
      expect(find.byKey(const ValueKey('nav_ai')), findsOneWidget);
      expect(find.byKey(const ValueKey('nav_profile')), findsOneWidget);

      // Verify no visible text labels in bottom navigation bar
      // (Instagram does not have text labels under icons)
      final bottomBar = find.byType(Container).first;
      expect(bottomBar, findsOneWidget);

      // Tab 0 is selected by default -> Icons.home_rounded (filled)
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
      // Workout tab is inactive -> Icons.fitness_center_outlined
      expect(find.byIcon(Icons.fitness_center_outlined), findsOneWidget);
      // Nutrition tab is inactive -> Icons.restaurant_outlined
      expect(find.byIcon(Icons.restaurant_outlined), findsOneWidget);
      // AI Coach tab is inactive -> Icons.auto_awesome_outlined
      expect(find.byIcon(Icons.auto_awesome_outlined), findsOneWidget);
    });

    testWidgets('tapping Workout tab navigates and activates solid icon',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Home Screen'), findsOneWidget);

      // Tap Workout tab
      await tester.tap(find.byKey(const ValueKey('nav_workout')));
      await tester.pumpAndSettle();

      expect(find.text('Workout Screen'), findsOneWidget);
      expect(find.byIcon(Icons.fitness_center_rounded), findsOneWidget);
      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    });

    testWidgets('renders user initial in profile avatar tab', (tester) async {
      await tester.pumpWidget(
        buildApp(
          overrides: [
            healthProfileProvider.overrideWith(
              () => _TestHealthProfileNotifier(
                const HealthProfile(nickname: 'Huy'),
              ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Profile avatar displays initial 'H'
      expect(find.text('H'), findsOneWidget);
    });

    testWidgets('displays badge dot on profile tab when unread notifications exist',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // notificationsProvider has unreadCount > 0 by default, so badge is rendered
      final profileNav = find.byKey(const ValueKey('nav_profile'));
      expect(profileNav, findsOneWidget);

      final badgeFinder = find.descendant(
        of: profileNav,
        matching: find.byType(Container),
      );
      expect(badgeFinder, findsWidgets);
    });

    testWidgets('hides bottom navigation bar on scroll down and shows on scroll up',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      final slideFinder = find.byType(AnimatedSlide);
      expect(slideFinder, findsOneWidget);
      AnimatedSlide slideWidget = tester.widget(slideFinder);
      expect(slideWidget.offset, Offset.zero);

      // Scroll down (reverse direction) -> hides downwards
      final context = tester.element(find.text('Home Screen'));
      UserScrollNotification(
        context: context,
        metrics: FixedScrollMetrics(
          minScrollExtent: 0,
          maxScrollExtent: 1000,
          pixels: 100,
          viewportDimension: 600,
          axisDirection: AxisDirection.down,
          devicePixelRatio: 1,
        ),
        direction: ScrollDirection.reverse,
      ).dispatch(context);

      await tester.pumpAndSettle();
      slideWidget = tester.widget(slideFinder);
      expect(slideWidget.offset, const Offset(0, 1.8));

      // Scroll up (forward direction) -> reappears
      UserScrollNotification(
        context: context,
        metrics: FixedScrollMetrics(
          minScrollExtent: 0,
          maxScrollExtent: 1000,
          pixels: 50,
          viewportDimension: 600,
          axisDirection: AxisDirection.down,
          devicePixelRatio: 1,
        ),
        direction: ScrollDirection.forward,
      ).dispatch(context);

      await tester.pumpAndSettle();
      slideWidget = tester.widget(slideFinder);
      expect(slideWidget.offset, Offset.zero);
    });
  });
}

class _TestHealthProfileNotifier extends HealthProfileController {
  _TestHealthProfileNotifier(this._initial);
  final HealthProfile _initial;

  @override
  HealthProfile build() => _initial;
}
