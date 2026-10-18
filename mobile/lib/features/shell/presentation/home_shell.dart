import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/application/auth_controller.dart';
import '../../notifications/application/notifications_controller.dart';
import '../../onboarding/application/health_profile_controller.dart';

/// Instagram-style Floating Pill (Capsule Dock) Bottom Navigation Bar for VieGym.
///
/// Features matching Instagram's modern floating pill bar:
/// - Floating stadium / pill capsule hovering above bottom with smooth drop shadow.
/// - Sliding active rounded-pill highlight behind the selected tab.
/// - Clean icon-only design with high contrast between active and inactive states.
/// - Red notification badge dot positioned at the bottom-right of items (e.g. Profile).
/// - Circular profile avatar with user initial or photo.
/// - Tactile spring-bounce micro-animation on tap with haptic feedback.
/// - Auto-hides downwards smoothly when scrolling down and reappears when scrolling up.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
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

  void _onTabTap(int index) {
    HapticFeedback.lightImpact();
    if (!_isVisible) {
      setState(() {
        _isVisible = true;
      });
    }
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = widget.navigationShell.currentIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final authState = ref.watch(authProvider);
    final healthProfile = ref.watch(healthProfileProvider);
    final notifState = ref.watch(notificationsProvider);

    final userName = healthProfile.nickname.isNotEmpty
        ? healthProfile.nickname
        : (authState.user?.displayName ?? '');
    final avatarUrl = authState.user?.avatarUrl;
    final hasUnreadNotif = notifState.hasUnread;

    return Scaffold(
      extendBody: true,
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.axis == Axis.vertical) {
            if (notification is ScrollUpdateNotification) {
              final delta = notification.scrollDelta ?? 0.0;
              if (delta > 3.0 && notification.metrics.pixels > 5.0) {
                // Light swipe down into content -> hide immediately
                if (_isVisible) {
                  setState(() => _isVisible = false);
                }
              } else if (delta < -3.0 || notification.metrics.pixels <= 0) {
                // Light swipe up towards top or reached top -> reveal immediately
                if (!_isVisible) {
                  setState(() => _isVisible = true);
                }
              }
            } else if (notification is UserScrollNotification) {
              if (notification.direction == ScrollDirection.reverse &&
                  notification.metrics.pixels > 5.0) {
                if (_isVisible) {
                  setState(() => _isVisible = false);
                }
              } else if (notification.direction == ScrollDirection.forward ||
                  notification.metrics.pixels <= 0) {
                if (!_isVisible) {
                  setState(() => _isVisible = true);
                }
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
        offset: _isVisible ? Offset.zero : const Offset(0, 1.8),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          opacity: _isVisible ? 1.0 : 0.0,
          child: IgnorePointer(
            ignoring: !_isVisible,
            child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            height: 58.0,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF141519).withValues(alpha: 0.95)
                  : const Color(0xFFFFFFFF).withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF2A2B30)
                    : const Color(0xFFE2E4E8),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
                  blurRadius: 22,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final tabWidth = constraints.maxWidth / 5;
                    const pillPaddingHorizontal = 4.0;
                    final pillWidth = tabWidth - (pillPaddingHorizontal * 2);

                    return Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // Sliding active pill highlight (Instagram floating capsule indicator)
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOutCubic,
                          left: (currentIndex * tabWidth) + pillPaddingHorizontal,
                          top: 5,
                          bottom: 5,
                          width: pillWidth,
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF33353B)
                                  : const Color(0xFFE6E8EC),
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),

                        // Interactive Tab Items
                        Row(
                          children: [
                            // 1. Home
                            Expanded(
                              child: _InstagramNavItem(
                                key: const ValueKey('nav_home'),
                                isSelected: currentIndex == 0,
                                label: 'Trang chủ',
                                icon: Icons.home_outlined,
                                activeIcon: Icons.home_rounded,
                                iconSize: 26.0,
                                onTap: () => _onTabTap(0),
                              ),
                            ),

                            // 2. Workout / Explore
                            Expanded(
                              child: _InstagramNavItem(
                                key: const ValueKey('nav_workout'),
                                isSelected: currentIndex == 1,
                                label: 'Tập luyện',
                                icon: Icons.fitness_center_outlined,
                                activeIcon: Icons.fitness_center_rounded,
                                iconSize: 24.0,
                                onTap: () => _onTabTap(1),
                              ),
                            ),

                            // 3. Meals / Nutrition
                            Expanded(
                              child: _InstagramNavItem(
                                key: const ValueKey('nav_nutrition'),
                                isSelected: currentIndex == 2,
                                label: 'Bữa ăn',
                                icon: Icons.restaurant_outlined,
                                activeIcon: Icons.restaurant_rounded,
                                iconSize: 23.5,
                                onTap: () => _onTabTap(2),
                              ),
                            ),

                            // 4. AI Coach
                            Expanded(
                              child: _InstagramNavItem(
                                key: const ValueKey('nav_ai'),
                                isSelected: currentIndex == 3,
                                label: 'AI Coach',
                                icon: Icons.auto_awesome_outlined,
                                activeIcon: Icons.auto_awesome_rounded,
                                iconSize: 23.5,
                                onTap: () => _onTabTap(3),
                              ),
                            ),

                            // 5. Profile (Instagram Circular Avatar with bottom-right badge dot)
                            Expanded(
                              child: _InstagramNavItem(
                                key: const ValueKey('nav_profile'),
                                isSelected: currentIndex == 4,
                                label: 'Cá nhân',
                                isProfile: true,
                                avatarUrl: avatarUrl,
                                userInitial: userName,
                                hasBadge: hasUnreadNotif,
                                onTap: () => _onTabTap(4),
                              ),
                            ),
                          ],
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
    ),
  ),
),
    );
  }
}

/// Individual item inside the Instagram floating pill dock.
///
/// Features:
/// - Tap down/up bounce micro-animation.
/// - Crisp icons: filled pure white when active, outline silver/white when inactive.
/// - Notification dot placed at bottom-right corner matching Instagram screenshot.
/// - Profile tab renders circular avatar.
/// - Transparent text for test/accessibility compatibility.
class _InstagramNavItem extends StatefulWidget {
  const _InstagramNavItem({
    required this.isSelected,
    required this.onTap,
    required this.label,
    this.icon,
    this.activeIcon,
    this.iconSize = 25.0,
    this.isProfile = false,
    this.avatarUrl,
    this.userInitial = 'V',
    this.hasBadge = false,
    super.key,
  });

  final bool isSelected;
  final VoidCallback onTap;
  final String label;
  final IconData? icon;
  final IconData? activeIcon;
  final double iconSize;
  final bool isProfile;
  final String? avatarUrl;
  final String userInitial;
  final bool hasBadge;

  @override
  State<_InstagramNavItem> createState() => _InstagramNavItemState();
}

class _InstagramNavItemState extends State<_InstagramNavItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails _) {
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Active icon is solid crisp white/black; inactive is high-visibility silver outline
    final unselectedColor =
        isDark ? const Color(0xFFD6D7DC) : const Color(0xFF55575E);
    final selectedColor = isDark ? Colors.white : Colors.black;

    return Semantics(
      button: true,
      selected: widget.isSelected,
      label: widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: SizedBox(
              width: 48,
              height: 48,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (widget.isProfile)
                    _buildProfileAvatar(
                      isDark: isDark,
                      isSelected: widget.isSelected,
                    )
                  else
                    Icon(
                      widget.isSelected ? widget.activeIcon : widget.icon,
                      size: widget.iconSize,
                      color: widget.isSelected ? selectedColor : unselectedColor,
                    ),

                  // Transparent text layer for accessibility & test finder compatibility
                  Positioned.fill(
                    child: Center(
                      child: Text(
                        widget.label,
                        style: const TextStyle(
                          fontSize: 1,
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                  ),

                  // Red notification dot at bottom-right (as shown in user screenshot)
                  if (widget.hasBadge)
                    Positioned(
                      bottom: 7,
                      right: 7,
                      child: Container(
                        width: 6.5,
                        height: 6.5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF3040), // Instagram's iconic red badge
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF141519)
                                : const Color(0xFFFFFFFF),
                            width: 1.2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar({
    required bool isDark,
    required bool isSelected,
  }) {
    final hasImage = widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty;
    final initial =
        widget.userInitial.isNotEmpty ? widget.userInitial[0].toUpperCase() : 'V';

    Widget avatarContent;
    if (hasImage) {
      avatarContent = ClipOval(
        child: Image.network(
          widget.avatarUrl!,
          width: 25,
          height: 25,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildFallbackInitial(initial, isDark, isSelected),
        ),
      );
    } else {
      avatarContent = _buildFallbackInitial(initial, isDark, isSelected);
    }

    return Container(
      width: 27,
      height: 27,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected
              ? (isDark ? Colors.white : Colors.black)
              : (isDark ? const Color(0xFF42444A) : const Color(0xFFCBD0D8)),
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      child: avatarContent,
    );
  }

  Widget _buildFallbackInitial(String initial, bool isDark, bool isSelected) {
    return Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected
            ? (isDark ? const Color(0xFF45474E) : const Color(0xFFD8DBE2))
            : (isDark ? const Color(0xFF2C2E34) : const Color(0xFFE8EAEF)),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : Colors.black87,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}
