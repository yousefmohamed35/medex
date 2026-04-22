import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design/app_colors.dart';
import '../core/navigation/route_names.dart';

class BottomNav extends StatelessWidget {
  final String activeTab;

  const BottomNav({
    super.key,
    required this.activeTab,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.fromLTRB(
              8,
              6,
              8,
              bottomInset > 0 ? bottomInset + 4 : 6,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.9),
                  Colors.white.withOpacity(0.8),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: _NavItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    id: 'home',
                    activeTab: activeTab,
                    onTap: () => context.go(RouteNames.home),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.store_rounded,
                    label: 'Medex Store',
                    id: 'store',
                    activeTab: activeTab,
                    onTap: () => context.go(RouteNames.store),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.people_alt_rounded,
                    label: 'Implant Community',
                    id: 'community',
                    activeTab: activeTab,
                    onTap: () => context.go(RouteNames.community),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.school_rounded,
                    label: 'Medex Academy',
                    id: 'academy',
                    activeTab: activeTab,
                    onTap: () => context.go(RouteNames.allCourses),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.person_rounded,
                    label: 'My Account',
                    id: 'dashboard',
                    activeTab: activeTab,
                    onTap: () => context.go(RouteNames.dashboard),
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

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String id;
  final String activeTab;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.id,
    required this.activeTab,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = activeTab == id;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 6 : 4,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.15),
                    AppColors.primary.withOpacity(0.08),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              child: Icon(
                icon,
                size: isActive ? 22 : 20,
                color: isActive ? AppColors.primary : Colors.grey[500],
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: GoogleFonts.cairo(
                  fontSize: isActive ? 9 : 8,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? AppColors.primary : Colors.grey[500],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
