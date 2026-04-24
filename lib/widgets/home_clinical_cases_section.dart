import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design/app_colors.dart';

/// Horizontal "Clinical Cases" strip for the student home screen.
class HomeClinicalCasesSection extends StatelessWidget {
  const HomeClinicalCasesSection({
    super.key,
    required this.isAr,
    required this.onViewAllTap,
    this.onCaseTap,
  });

  final bool isAr;
  final VoidCallback onViewAllTap;
  final void Function(int index)? onCaseTap;

  static const Color _accentRed = Color(0xFFE31B23);
  static const Color _authorGray = Color(0xFF9E9E9E);
  static const Color _sectionTint = Color(0xFFECEEF1);
  static const Color _placeholderRing = Color(0xFFBDBDBD);

  @override
  Widget build(BuildContext context) {
    final cases = isAr ? _casesAr : _casesEn;

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
                  isAr ? 'الحالات السريرية' : 'Clinical Cases',
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
            height: 210,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: cases.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                return _ClinicalCaseCard(
                  item: cases[index],
                  accentRed: _accentRed,
                  authorGray: _authorGray,
                  placeholderRing: _placeholderRing,
                  onTap: () {
                    if (onCaseTap != null) {
                      onCaseTap!(index);
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

class _ClinicalCaseCard extends StatelessWidget {
  const _ClinicalCaseCard({
    required this.item,
    required this.accentRed,
    required this.authorGray,
    required this.placeholderRing,
    required this.onTap,
  });

  final _ClinicalCaseItem item;
  final Color accentRed;
  final Color authorGray;
  final Color placeholderRing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const radius = 24.0;
    const cardWidth = 268.0;
    const cardHeight = 248.0;
    const mediaHeight = 132.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(radius),
                ),
                child: SizedBox(
                  height: mediaHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      DecoratedBox(decoration: item.mediaDecoration),
                      PositionedDirectional(
                        top: 10,
                        start: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: accentRed,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            item.categoryLabel,
                            style: GoogleFonts.cairo(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: placeholderRing,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.foreground,
                          height: 1.25,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: item.avatarColor,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              item.initials,
                              style: GoogleFonts.cairo(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.doctorName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: authorGray,
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
    );
  }
}

class _ClinicalCaseItem {
  const _ClinicalCaseItem({
    required this.categoryLabel,
    required this.title,
    required this.doctorName,
    required this.initials,
    required this.avatarColor,
    required this.mediaDecoration,
  });

  final String categoryLabel;
  final String title;
  final String doctorName;
  final String initials;
  final Color avatarColor;
  final BoxDecoration mediaDecoration;
}

final List<_ClinicalCaseItem> _casesEn = [
  _ClinicalCaseItem(
    categoryLabel: 'FULL ARCH',
    title: 'All-on-4 Immediate Loading',
    doctorName: 'Dr. Nour Khalil',
    initials: 'NK',
    avatarColor: const Color(0xFFE31B23),
    mediaDecoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF8B1538),
          const Color(0xFF2A0A12),
        ],
      ),
    ),
  ),
  _ClinicalCaseItem(
    categoryLabel: 'SINGLE UNIT',
    title: 'Molar Replacement – BLX',
    doctorName: 'Dr. Sami Amin',
    initials: 'SA',
    avatarColor: const Color(0xFF1E3A5F),
    mediaDecoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF1E2D4A),
          const Color(0xFF0D1524),
        ],
      ),
    ),
  ),
];

final List<_ClinicalCaseItem> _casesAr = [
  _ClinicalCaseItem(
    categoryLabel: 'قوس كامل',
    title: 'All-on-4 مع التحميل الفوري',
    doctorName: 'د. نور خليل',
    initials: 'NK',
    avatarColor: const Color(0xFFE31B23),
    mediaDecoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF8B1538),
          const Color(0xFF2A0A12),
        ],
      ),
    ),
  ),
  _ClinicalCaseItem(
    categoryLabel: 'وحدة واحدة',
    title: 'استبدال الضرس – BLX',
    doctorName: 'د. سامي أمين',
    initials: 'SA',
    avatarColor: const Color(0xFF1E3A5F),
    mediaDecoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF1E2D4A),
          const Color(0xFF0D1524),
        ],
      ),
    ),
  ),
];
