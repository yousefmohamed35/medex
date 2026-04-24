import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design/app_colors.dart';
import '../core/navigation/route_names.dart';

class HomeQuickAccess extends StatelessWidget {
  const HomeQuickAccess({
    super.key,
    required this.isAr,
  });

  final bool isAr;

  @override
  Widget build(BuildContext context) {
    final items = isAr ? _itemsAr : _itemsEn;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isAr ? 'وصول سريع' : 'Quick Access',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.foreground,
            ),
          ),
          
          //  const SizedBox(height: 14),
          GridView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              mainAxisExtent: 78,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return _QuickAccessItem(
                item: item,
                onTap: () {
                  if (index == 0) {
                    context.go(RouteNames.store);
                  } else if (index == 1) {
                    context.go(RouteNames.implantCommunity);
                  } else if (index == 2) {
                    context.go(RouteNames.medexAcademy);
                  } else if (index == 3) {
                    context.go(RouteNames.medexOffers);
                  } else if (index == 4) {
                    context.go(RouteNames.clinicalCases);
                  } else if (index == 5) {
                    context.go(RouteNames.productLearningHub);
                  } else if (index == 6) {
                    context.go(RouteNames.eventsExhibitions);
                  } else if (index == 7) {
                    context.go(RouteNames.dentalChallenge);
                  } else if (index == 8) {
                    context.go(RouteNames.returnsExchanges);
                  } else if (index == 9) {
                    context.go(RouteNames.medexAiAssistant);
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuickAccessItem extends StatelessWidget {
  const _QuickAccessItem({
    required this.item,
    required this.onTap,
  });

  final _QuickAccessItemData item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F3),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE1E2E6)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(item.icon, color: item.color, size: 18),
            ),
            const SizedBox(height: 5),
            Text(
              item.label,
              style: GoogleFonts.cairo(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: AppColors.foreground,
                height: 1.15,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAccessItemData {
  const _QuickAccessItemData({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;
}

const List<_QuickAccessItemData> _itemsEn = [
  _QuickAccessItemData(
    icon: Icons.shopping_bag_outlined,
    label: 'Medex Store',
    color: Color(0xFFE04F4D),
  ),
  _QuickAccessItemData(
    icon: Icons.people_outline_rounded,
    label: 'Community',
    color: Color(0xFF2A7BD8),
  ),
  _QuickAccessItemData(
    icon: Icons.school_outlined,
    label: 'Academy',
    color: Color(0xFF4E7E3E),
  ),
  _QuickAccessItemData(
    icon: Icons.local_offer_outlined,
    label: 'Offers',
    color: Color(0xFFAA7C2C),
  ),
  _QuickAccessItemData(
    icon: Icons.search_rounded,
    label: 'Cases',
    color: Color(0xFF6A61D5),
  ),
  _QuickAccessItemData(
    icon: Icons.play_circle_outline_rounded,
    label: 'Learning Hub',
    color: Color(0xFFE04F4D),
  ),
  _QuickAccessItemData(
    icon: Icons.calendar_month_outlined,
    label: 'Events',
    color: Color(0xFF2A7BD8),
  ),
  _QuickAccessItemData(
    icon: Icons.emoji_events_outlined,
    label: 'Challenge',
    color: Color(0xFF8F5A15),
  ),
  _QuickAccessItemData(
    icon: Icons.reply_rounded,
    label: 'Returns',
    color: Color(0xFF1D8B59),
  ),
  _QuickAccessItemData(
    icon: Icons.smart_toy_outlined,
    label: 'AI Assistant',
    color: Color(0xFF6A61D5),
  ),
];

const List<_QuickAccessItemData> _itemsAr = [
  _QuickAccessItemData(
    icon: Icons.shopping_bag_outlined,
    label: 'متجر ميديكس',
    color: Color(0xFFE04F4D),
  ),
  _QuickAccessItemData(
    icon: Icons.people_outline_rounded,
    label: 'المجتمع',
    color: Color(0xFF2A7BD8),
  ),
  _QuickAccessItemData(
    icon: Icons.school_outlined,
    label: 'الأكاديمية',
    color: Color(0xFF4E7E3E),
  ),
  _QuickAccessItemData(
    icon: Icons.local_offer_outlined,
    label: 'العروض',
    color: Color(0xFFAA7C2C),
  ),
  _QuickAccessItemData(
    icon: Icons.search_rounded,
    label: 'الحالات',
    color: Color(0xFF6A61D5),
  ),
  _QuickAccessItemData(
    icon: Icons.play_circle_outline_rounded,
    label: 'مركز التعلم',
    color: Color(0xFFE04F4D),
  ),
  _QuickAccessItemData(
    icon: Icons.calendar_month_outlined,
    label: 'الفعاليات',
    color: Color(0xFF2A7BD8),
  ),
  _QuickAccessItemData(
    icon: Icons.emoji_events_outlined,
    label: 'التحدي',
    color: Color(0xFF8F5A15),
  ),
  _QuickAccessItemData(
    icon: Icons.reply_rounded,
    label: 'المرتجعات',
    color: Color(0xFF1D8B59),
  ),
  _QuickAccessItemData(
    icon: Icons.smart_toy_outlined,
    label: 'المساعد الذكي',
    color: Color(0xFF6A61D5),
  ),
];
