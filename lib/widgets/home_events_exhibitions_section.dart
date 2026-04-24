import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design/app_colors.dart';

enum _EventCardIcon { graduationCap, circleOutline }

/// Horizontal "Events & Exhibitions" strip for the student home screen.
class HomeEventsExhibitionsSection extends StatelessWidget {
  const HomeEventsExhibitionsSection({
    super.key,
    required this.isAr,
    required this.onViewAllTap,
    this.onEventTap,
  });

  final bool isAr;
  final VoidCallback onViewAllTap;
  final void Function(int index)? onEventTap;

  static const Color _accentRed = Color(0xFFE31B23);
  static const Color _metadataGray = Color(0xFF757575);
  static const Color _monthGray = Color(0xFF616161);
  static const Color _sectionTint = Color(0xFFECEEF1);

  @override
  Widget build(BuildContext context) {
    final events = isAr ? _eventsAr : _eventsEn;

    return Container(
      width: double.infinity,
      color: _sectionTint,
      padding: const EdgeInsets.fromLTRB(0, 18, 0, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isAr ? 'الفعاليات والمعارض' : 'Events & Exhibitions',
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.foreground,
                  ),
                ),
                GestureDetector(
                  onTap: onViewAllTap,
                  child: Text(
                    isAr ? 'عرض الكل' : 'View All',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _accentRed,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 190,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: events.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                return _EventCard(
                  item: events[index],
                  accentRed: _accentRed,
                  metadataGray: _metadataGray,
                  monthGray: _monthGray,
                  onTap: () {
                    if (onEventTap != null) {
                      onEventTap!(index);
                    } else {
                      onViewAllTap();
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeEventItem {
  const _HomeEventItem({
    required this.day,
    required this.month,
    required this.topColor,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final String day;
  final String month;
  final Color topColor;
  final _EventCardIcon icon;
  final String title;
  final String subtitle;
}

const List<_HomeEventItem> _eventsEn = [
  _HomeEventItem(
    day: '22',
    month: 'MAY',
    topColor: Color(0xFFF14343),
    icon: _EventCardIcon.graduationCap,
    title: 'Cairo Implant Symposium',
    subtitle: 'Marriott Cairo · 8 CPD',
  ),
  _HomeEventItem(
    day: '08',
    month: 'JUN',
    topColor: Color(0xFF7A1212),
    icon: _EventCardIcon.circleOutline,
    title: 'Live Surgery Workshop',
    subtitle: 'Online + Hands-on',
  ),
];

const List<_HomeEventItem> _eventsAr = [
  _HomeEventItem(
    day: '22',
    month: 'مايو',
    topColor: Color(0xFFF14343),
    icon: _EventCardIcon.graduationCap,
    title: 'ندوة القاهرة لزراعة الأسنان',
    subtitle: 'ماريوت القاهرة · 8 ساعات معتمدة',
  ),
  _HomeEventItem(
    day: '08',
    month: 'يونيو',
    topColor: Color(0xFF7A1212),
    icon: _EventCardIcon.circleOutline,
    title: 'ورشة الجراحة الحية',
    subtitle: 'أونلاين + تطبيق عملي',
  ),
];

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.item,
    required this.accentRed,
    required this.metadataGray,
    required this.monthGray,
    required this.onTap,
  });

  final _HomeEventItem item;
  final Color accentRed;
  final Color metadataGray;
  final Color monthGray;
  final VoidCallback onTap;

  static const double _radius = 20;
  static const double _cardWidth = 270;

  IconData get _centerIcon {
    switch (item.icon) {
      case _EventCardIcon.graduationCap:
        return Icons.school_outlined;
      case _EventCardIcon.circleOutline:
        return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_radius),
        child: Ink(
          width: _cardWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_radius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_radius),
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: ColoredBox(color: item.topColor),
                      ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item.day,
                                style: GoogleFonts.cairo(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  height: 1,
                                  color: accentRed,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.month,
                                style: GoogleFonts.cairo(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                  color: monthGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: Icon(
                          _centerIcon,
                          size: 72,
                          color: Colors.white.withValues(alpha: 0.28),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.foreground,
                              height: 1.25,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 1),
                              child: Icon(
                                Icons.location_on_rounded,
                                size: 16,
                                color: accentRed,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item.subtitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: metadataGray,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
