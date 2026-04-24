import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design/app_colors.dart';
import '../core/localization/localization_helper.dart';
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
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final homeLabel = context.l10n.home;
    final storeLabel = isAr ? 'متجر ميدكس' : 'Medex Store';
    final communityLabel = isAr ? 'المجتمع' : 'Community';
    final academyLabel = isAr ? 'الأكاديمية' : 'Academy';
    final accountLabel = context.l10n.myAccount;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.only(bottom: bottomInset),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(26),
            topRight: Radius.circular(26),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 18,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6, 6, 6, 4),
            child: Row(
              children: [
                Expanded(
                  child: _NavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: homeLabel,
                    id: 'home',
                    activeTab: activeTab,
                    onTap: () => context.go(RouteNames.home),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.shopping_bag_outlined,
                    activeIcon: Icons.shopping_bag_rounded,
                    label: storeLabel,
                    id: 'store',
                    activeTab: activeTab,
                    onTap: () => context.go(RouteNames.store),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.groups_2_outlined,
                    activeIcon: Icons.groups_2_rounded,
                    label: communityLabel,
                    id: 'community',
                    activeTab: activeTab,
                    onTap: () => context.go(RouteNames.implantCommunity),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.school_outlined,
                    activeIcon: Icons.school_rounded,
                    label: academyLabel,
                    id: 'academy',
                    activeTab: activeTab,
                    onTap: () => context.go(RouteNames.medexAcademy),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                    label: accountLabel,
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
  final IconData activeIcon;
  final String label;
  final String id;
  final String activeTab;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
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
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 24,
              color: isActive ? AppColors.primary : const Color(0xFFACB0B8),
            ),
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: GoogleFonts.cairo(
                  fontSize: 10.5,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                  color:
                      isActive ? AppColors.primary : const Color(0xFF9EA3AC),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
