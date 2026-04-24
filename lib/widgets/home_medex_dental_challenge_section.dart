import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design/app_colors.dart';

/// "Medex Dental Challenge" promo card for the student home screen.
class HomeMedexDentalChallengeSection extends StatelessWidget {
  const HomeMedexDentalChallengeSection({
    super.key,
    required this.isAr,
    required this.onViewAllTap,
    required this.onJoinTap,
    this.weekLabel,
    this.headline,
    this.prizeLine,
    this.daysLeft,
    this.submissionsCount,
  });

  final bool isAr;
  final VoidCallback onViewAllTap;
  final VoidCallback onJoinTap;

  /// e.g. `WEEK 18 • 2025` / Arabic equivalent when provided.
  final String? weekLabel;
  final String? headline;
  final String? prizeLine;
  final int? daysLeft;
  final int? submissionsCount;

  static const Color _accentRed = Color(0xFFE61919);
  static const Color _cardBg = Color(0xFF1A0A0A);
  static const Color _countdownYellow = Color(0xFFFFD719);
  static const Color _mutedGray = Color(0xFFA0A0A0);
  static const Color _submissionsBoxBg = Color(0xFF2A2525);
  static const Color _onYellow = Color(0xFF141010);

  @override
  Widget build(BuildContext context) {
    final week = weekLabel ?? (isAr ? 'الأسبوع 18 • 2025' : 'WEEK 18 • 2025');
    final title = headline ??
        (isAr ? 'أفضل حالة زرع لهذا الشهر' : 'Best Implant Case of the Month');
    final prize = prizeLine ??
        (isAr ? 'اربح زرعات + شهادة' : 'Win implants + certificate');
    final days = daysLeft ?? 3;
    final subs = submissionsCount ?? 48;

    return Container(
      width: double.infinity,
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    isAr ? 'تحدي ميديكس للأسنان' : 'Medex Dental Challenge',
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.foreground,
                    ),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  week,
                                  style: GoogleFonts.cairo(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: _mutedGray,
                                    height: 1.2,
                                  ),
                                  textDirection: isAr
                                      ? TextDirection.rtl
                                      : TextDirection.ltr,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  title,
                                  style: GoogleFonts.cairo(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    height: 1.15,
                                  ),
                                  textDirection: isAr
                                      ? TextDirection.rtl
                                      : TextDirection.ltr,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  prize,
                                  style: GoogleFonts.cairo(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _mutedGray,
                                    height: 1.2,
                                  ),
                                  textDirection: isAr
                                      ? TextDirection.rtl
                                      : TextDirection.ltr,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: _countdownYellow,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  days.toString().padLeft(2, '0'),
                                  style: GoogleFonts.cairo(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: _onYellow,
                                    height: 1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isAr ? 'أيام\nمتبقية' : 'DAYS\nLEFT',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.cairo(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: _onYellow,
                                    height: 1.15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      // Row + stretch needs bounded height; scrollables pass
                      // unbounded max height to the Column, so IntrinsicHeight
                      // establishes a finite cross-axis extent for the Row.
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: _submissionsBoxBg,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$subs',
                                    style: GoogleFonts.cairo(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      height: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isAr ? 'مشاركات' : 'Submissions',
                                    style: GoogleFonts.cairo(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: _mutedGray,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Material(
                                color: _accentRed,
                                borderRadius: BorderRadius.circular(22),
                                child: InkWell(
                                  onTap: onJoinTap,
                                  borderRadius: BorderRadius.circular(22),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    child: Center(
                                      child: Text(
                                        isAr ? 'انضم الآن' : 'Join Now →',
                                        style: GoogleFonts.cairo(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
