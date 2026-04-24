import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design/app_colors.dart';

/// Medex Academy horizontal course strip (home).
class HomeMedexAcademySection extends StatelessWidget {
  const HomeMedexAcademySection({
    super.key,
    required this.isAr,
    required this.onViewAllTap,
    this.onCourseTap,
  });

  final bool isAr;
  final VoidCallback onViewAllTap;
  final void Function(int index)? onCourseTap;

  static const Color _accentRed = Color(0xFFE31B23);
  static const Color _metadataGray = Color(0xFF757575);
  static const Color _sectionTint = Color(0xFFECEEF1);

  @override
  Widget build(BuildContext context) {
    final courses = isAr ? _coursesAr : _coursesEn;

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
                  isAr ? 'أكاديمية ميدكس' : 'Medex Academy',
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
            height: 228,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: courses.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                return _AcademyCourseCard(
                  course: courses[index],
                  accentRed: _accentRed,
                  metadataGray: _metadataGray,
                  onTap: () {
                    if (onCourseTap != null) {
                      onCourseTap!(index);
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

class _AcademyCourseCard extends StatelessWidget {
  const _AcademyCourseCard({
    required this.course,
    required this.accentRed,
    required this.metadataGray,
    required this.onTap,
  });

  final _AcademyCourseItem course;
  final Color accentRed;
  final Color metadataGray;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const radius = 24.0;
    const thumbFraction = 0.58;
    const cardWidth = 268.0;
    const cardHeight = 228.0;
    final thumbHeight = cardHeight * thumbFraction;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          width: cardWidth,
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
                  height: thumbHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      DecoratedBox(
                        decoration: course.thumbDecoration,
                      ),
                      Center(
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: accentRed,
                            size: 36,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        course.metaLine,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: metadataGray,
                        ),
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

class _AcademyCourseItem {
  const _AcademyCourseItem({
    required this.title,
    required this.metaLine,
    required this.thumbDecoration,
  });

  final String title;
  final String metaLine;
  final BoxDecoration thumbDecoration;
}

final List<_AcademyCourseItem> _coursesEn = [
  _AcademyCourseItem(
    title: 'BLX Surgical Protocol',
    metaLine: '24 lessons · 6h',
    thumbDecoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF8B1538),
          const Color(0xFF1A0508),
        ],
      ),
    ),
  ),
  _AcademyCourseItem(
    title: 'Immediate Loading Techniques',
    metaLine: '18 lessons · 4.5h',
    thumbDecoration: const BoxDecoration(
      color: Color(0xFF142444),
    ),
  ),
];

final List<_AcademyCourseItem> _coursesAr = [
  _AcademyCourseItem(
    title: 'بروتوكول جراحة BLX',
    metaLine: '24 درسًا · 6 س',
    thumbDecoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF8B1538),
          const Color(0xFF1A0508),
        ],
      ),
    ),
  ),
  _AcademyCourseItem(
    title: 'تقنيات التحميل الفوري',
    metaLine: '18 درسًا · 4.5 س',
    thumbDecoration: const BoxDecoration(
      color: Color(0xFF142444),
    ),
  ),
];
