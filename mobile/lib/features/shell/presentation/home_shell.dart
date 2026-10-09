import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  bool _isVisible = true;

  @override
  void didUpdateWidget(covariant HomeShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.navigationShell.currentIndex !=
        widget.navigationShell.currentIndex) {
      if (!_isVisible) {
        setState(() {
          _isVisible = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final currentIndex = widget.navigationShell.currentIndex;

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
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.axis == Axis.vertical) {
            if (notification.direction == ScrollDirection.reverse) {
              // User scrolling down (dragging finger up to see lower content) -> hide
              if (_isVisible) {
                setState(() {
                  _isVisible = false;
                });
              }
            } else if (notification.direction == ScrollDirection.forward) {
              // User scrolling up (dragging finger down to see upper content) -> show
              if (!_isVisible) {
                setState(() {
                  _isVisible = true;
                });
              }
            }
          }
          return false;
        },
        child: widget.navigationShell,
      ),
      bottomNavigationBar: AnimatedSlide(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeInOutCubic,
        offset: _isVisible ? Offset.zero : const Offset(0, 1.0),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _isVisible ? 1.0 : 0.0,
          child: IgnorePointer(
            ignoring: !_isVisible,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.backgroundDeep.withValues(alpha: 0.98),
                border: Border(
                  top: BorderSide(
                    color: AppColors.borderDefault.withValues(alpha: 0.5),
                    width: 0.8,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final tabWidth = constraints.maxWidth / tabs.length;

                    return Stack(
                      children: [
                        // Facebook-style Active Top Accent Bar
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeOutCubic,
                          left: currentIndex * tabWidth,
                          width: tabWidth,
                          top: 0,
                          height: 3,
                          child: Center(
                            child: Container(
                              width: tabWidth * 0.55,
                              height: 3,
                              decoration: BoxDecoration(
                                color: colors.primary,
                                borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Navigation Items
                        Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 4),
                          child: Row(
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
                                    if (!_isVisible) {
                                      setState(() {
                                        _isVisible = true;
                                      });
                                    }
                                    widget.navigationShell.goBranch(
                                      index,
                                      initialLocation:
                                          index ==
                                          widget.navigationShell.currentIndex,
                                    );
                                  },
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: primaryColor.withValues(alpha: 0.12),
          highlightColor: primaryColor.withValues(alpha: 0.06),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSelected ? destination.activeIcon : destination.icon,
                  size: 24,
                  color: isSelected ? primaryColor : AppColors.textTertiary,
                ),
                const SizedBox(height: 3),
                Text(
                  destination.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? primaryColor : AppColors.textTertiary,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
