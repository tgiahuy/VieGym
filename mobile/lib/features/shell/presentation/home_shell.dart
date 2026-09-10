import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final currentIndex = navigationShell.currentIndex;

    final tabs = const [
      _NavDestination(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: 'Trang chủ',
      ),
      _NavDestination(
        icon: Icons.fitness_center_outlined,
        activeIcon: Icons.fitness_center_rounded,
        label: 'Tập luyện',
      ),
      _NavDestination(
        icon: Icons.restaurant_outlined,
        activeIcon: Icons.restaurant_rounded,
        label: 'Bữa ăn',
      ),
      _NavDestination(
        icon: Icons.auto_awesome_outlined,
        activeIcon: Icons.auto_awesome_rounded,
        label: 'AI Coach',
      ),
      _NavDestination(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: 'Cá nhân',
      ),
    ];

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.only(bottom: 10),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.backgroundDeep.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: AppColors.borderDefault, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tabWidth = constraints.maxWidth / tabs.length;

              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Sliding Liquid Bubble Indicator
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutBack,
                    left: currentIndex * tabWidth,
                    width: tabWidth,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.primaryBorder,
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),

                  // Navigation Tab Items Row
                  Row(
                    children: List.generate(tabs.length, (index) {
                      final tab = tabs[index];
                      final isSelected = index == currentIndex;

                      return Expanded(
                        child: _NavBarItem(
                          destination: tab,
                          isSelected: isSelected,
                          primaryColor: colors.primary,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            navigationShell.goBranch(
                              index,
                              initialLocation:
                                  index == navigationShell.currentIndex,
                            );
                          },
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavDestination {
  const _NavDestination({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.destination,
    required this.isSelected,
    required this.primaryColor,
    required this.onTap,
  });

  final _NavDestination destination;
  final bool isSelected;
  final Color primaryColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: destination.label,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pop & Scale animation on icon when active
              TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: isSelected ? 0.82 : 1.0,
                  end: isSelected ? 1.08 : 1.0,
                ),
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutBack,
                builder: (context, scale, child) {
                  return Transform.scale(scale: scale, child: child);
                },
                child: Icon(
                  isSelected ? destination.activeIcon : destination.icon,
                  size: 22,
                  color: isSelected ? primaryColor : AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                destination.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.textTertiary,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
