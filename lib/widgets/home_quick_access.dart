import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design/app_colors.dart';
import '../core/navigation/route_names.dart';

class HomeQuickAccess extends StatelessWidget {
  const HomeQuickAccess({
    super.key,
    required this.isAr,
    this.items,
  });

  final bool isAr;
  final List<Map<String, dynamic>>? items;

  @override
  Widget build(BuildContext context) {
    final items = _resolveItems(isAr);

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
                  if (item.route.isNotEmpty) {
                    context.go(item.route);
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }

  List<_QuickAccessItemData> _resolveItems(bool isAr) {
    final incoming = items ?? const [];
    final fromApi = <_QuickAccessItemData>[];
    for (final raw in incoming) {
      final item = _fromApiMap(raw, isAr);
      if (item != null) fromApi.add(item);
    }
    if (fromApi.isNotEmpty) return fromApi;
    return isAr ? _defaultItemsAr : _defaultItemsEn;
  }

  _QuickAccessItemData? _fromApiMap(
    Map<String, dynamic> raw,
    bool isAr,
  ) {
    final enabled = raw['is_active'];
    if (enabled == false || enabled == 0 || enabled == '0') return null;

    final route = raw['cta_route']?.toString().trim() ??
        raw['route']?.toString().trim() ??
        '';
    if (!_allowedRoutes.contains(route)) return null;

    final label = _pickLocalizedLabel(raw, isAr);
    if (label.isEmpty) return null;

    final icon = _iconFromString(raw['icon']?.toString()) ??
        _iconByRoute[route] ??
        Icons.apps_rounded;
    final color = _colorFromHex(raw['color']?.toString()) ??
        _colorByRoute[route] ??
        const Color(0xFFE04F4D);

    return _QuickAccessItemData(
      icon: icon,
      label: label,
      color: color,
      route: route,
    );
  }

  String _pickLocalizedLabel(Map<String, dynamic> raw, bool isAr) {
    final langLabel = isAr
        ? raw['label_ar']?.toString()
        : raw['label_en']?.toString();
    if (langLabel != null && langLabel.trim().isNotEmpty) {
      return langLabel.trim();
    }
    final generic = raw['label']?.toString();
    if (generic != null && generic.trim().isNotEmpty) return generic.trim();
    return '';
  }

  Color? _colorFromHex(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final hex = value.trim().replaceAll('#', '');
    if (hex.length == 6) {
      final parsed = int.tryParse('FF$hex', radix: 16);
      if (parsed != null) return Color(parsed);
    } else if (hex.length == 8) {
      final parsed = int.tryParse(hex, radix: 16);
      if (parsed != null) return Color(parsed);
    }
    return null;
  }

  IconData? _iconFromString(String? key) {
    if (key == null || key.trim().isEmpty) return null;
    return _iconByKey[key.trim().toLowerCase()];
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
    required this.route,
  });

  final IconData icon;
  final String label;
  final Color color;
  final String route;
}

const _allowedRoutes = <String>{
  RouteNames.store,
  RouteNames.implantCommunity,
  RouteNames.medexAcademy,
  RouteNames.medexOffers,
  RouteNames.clinicalCases,
  RouteNames.productLearningHub,
  RouteNames.eventsExhibitions,
  RouteNames.dentalChallenge,
  RouteNames.returnsExchanges,
  RouteNames.medexAiAssistant,
};

const Map<String, IconData> _iconByRoute = {
  RouteNames.store: Icons.shopping_bag_outlined,
  RouteNames.implantCommunity: Icons.people_outline_rounded,
  RouteNames.medexAcademy: Icons.school_outlined,
  RouteNames.medexOffers: Icons.local_offer_outlined,
  RouteNames.clinicalCases: Icons.search_rounded,
  RouteNames.productLearningHub: Icons.play_circle_outline_rounded,
  RouteNames.eventsExhibitions: Icons.calendar_month_outlined,
  RouteNames.dentalChallenge: Icons.emoji_events_outlined,
  RouteNames.returnsExchanges: Icons.reply_rounded,
  RouteNames.medexAiAssistant: Icons.smart_toy_outlined,
};

const Map<String, Color> _colorByRoute = {
  RouteNames.store: Color(0xFFE04F4D),
  RouteNames.implantCommunity: Color(0xFF2A7BD8),
  RouteNames.medexAcademy: Color(0xFF4E7E3E),
  RouteNames.medexOffers: Color(0xFFAA7C2C),
  RouteNames.clinicalCases: Color(0xFF6A61D5),
  RouteNames.productLearningHub: Color(0xFFE04F4D),
  RouteNames.eventsExhibitions: Color(0xFF2A7BD8),
  RouteNames.dentalChallenge: Color(0xFF8F5A15),
  RouteNames.returnsExchanges: Color(0xFF1D8B59),
  RouteNames.medexAiAssistant: Color(0xFF6A61D5),
};

const Map<String, IconData> _iconByKey = {
  'store': Icons.shopping_bag_outlined,
  'community': Icons.people_outline_rounded,
  'academy': Icons.school_outlined,
  'offers': Icons.local_offer_outlined,
  'cases': Icons.search_rounded,
  'learning_hub': Icons.play_circle_outline_rounded,
  'events': Icons.calendar_month_outlined,
  'challenge': Icons.emoji_events_outlined,
  'returns': Icons.reply_rounded,
  'ai': Icons.smart_toy_outlined,
};

const List<_QuickAccessItemData> _defaultItemsEn = [
  _QuickAccessItemData(
    icon: Icons.shopping_bag_outlined,
    label: 'Medex Store',
    color: Color(0xFFE04F4D),
    route: RouteNames.store,
  ),
  _QuickAccessItemData(
    icon: Icons.people_outline_rounded,
    label: 'Community',
    color: Color(0xFF2A7BD8),
    route: RouteNames.implantCommunity,
  ),
  _QuickAccessItemData(
    icon: Icons.school_outlined,
    label: 'Academy',
    color: Color(0xFF4E7E3E),
    route: RouteNames.medexAcademy,
  ),
  _QuickAccessItemData(
    icon: Icons.local_offer_outlined,
    label: 'Offers',
    color: Color(0xFFAA7C2C),
    route: RouteNames.medexOffers,
  ),
  _QuickAccessItemData(
    icon: Icons.search_rounded,
    label: 'Cases',
    color: Color(0xFF6A61D5),
    route: RouteNames.clinicalCases,
  ),
  _QuickAccessItemData(
    icon: Icons.play_circle_outline_rounded,
    label: 'Learning Hub',
    color: Color(0xFFE04F4D),
    route: RouteNames.productLearningHub,
  ),
  _QuickAccessItemData(
    icon: Icons.calendar_month_outlined,
    label: 'Events',
    color: Color(0xFF2A7BD8),
    route: RouteNames.eventsExhibitions,
  ),
  _QuickAccessItemData(
    icon: Icons.emoji_events_outlined,
    label: 'Challenge',
    color: Color(0xFF8F5A15),
    route: RouteNames.dentalChallenge,
  ),
  _QuickAccessItemData(
    icon: Icons.reply_rounded,
    label: 'Returns',
    color: Color(0xFF1D8B59),
    route: RouteNames.returnsExchanges,
  ),
  _QuickAccessItemData(
    icon: Icons.smart_toy_outlined,
    label: 'AI Assistant',
    color: Color(0xFF6A61D5),
    route: RouteNames.medexAiAssistant,
  ),
];

const List<_QuickAccessItemData> _defaultItemsAr = [
  _QuickAccessItemData(
    icon: Icons.shopping_bag_outlined,
    label: 'متجر ميديكس',
    color: Color(0xFFE04F4D),
    route: RouteNames.store,
  ),
  _QuickAccessItemData(
    icon: Icons.people_outline_rounded,
    label: 'المجتمع',
    color: Color(0xFF2A7BD8),
    route: RouteNames.implantCommunity,
  ),
  _QuickAccessItemData(
    icon: Icons.school_outlined,
    label: 'الأكاديمية',
    color: Color(0xFF4E7E3E),
    route: RouteNames.medexAcademy,
  ),
  _QuickAccessItemData(
    icon: Icons.local_offer_outlined,
    label: 'العروض',
    color: Color(0xFFAA7C2C),
    route: RouteNames.medexOffers,
  ),
  _QuickAccessItemData(
    icon: Icons.search_rounded,
    label: 'الحالات',
    color: Color(0xFF6A61D5),
    route: RouteNames.clinicalCases,
  ),
  _QuickAccessItemData(
    icon: Icons.play_circle_outline_rounded,
    label: 'مركز التعلم',
    color: Color(0xFFE04F4D),
    route: RouteNames.productLearningHub,
  ),
  _QuickAccessItemData(
    icon: Icons.calendar_month_outlined,
    label: 'الفعاليات',
    color: Color(0xFF2A7BD8),
    route: RouteNames.eventsExhibitions,
  ),
  _QuickAccessItemData(
    icon: Icons.emoji_events_outlined,
    label: 'التحدي',
    color: Color(0xFF8F5A15),
    route: RouteNames.dentalChallenge,
  ),
  _QuickAccessItemData(
    icon: Icons.reply_rounded,
    label: 'المرتجعات',
    color: Color(0xFF1D8B59),
    route: RouteNames.returnsExchanges,
  ),
  _QuickAccessItemData(
    icon: Icons.smart_toy_outlined,
    label: 'المساعد الذكي',
    color: Color(0xFF6A61D5),
    route: RouteNames.medexAiAssistant,
  ),
];
