import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/design/app_colors.dart';
import '../../core/navigation/route_names.dart';
import '../../widgets/bb_implant_offer_grid.dart';

class MedexOffersPlaceholderScreen extends StatefulWidget {
  const MedexOffersPlaceholderScreen({super.key});

  @override
  State<MedexOffersPlaceholderScreen> createState() =>
      _MedexOffersPlaceholderScreenState();
}

class _MedexOffersPlaceholderScreenState
    extends State<MedexOffersPlaceholderScreen> {
  static const String _bbShareText =
      'B&B Dental × Medex — B&B Implant Offer\n'
      'Start: 22 Sep 2025 · End: Open\n'
      'See Medex app → Offers for full pricing.';

  Future<void> _shareBbOffer() async {
    await Share.share(_bbShareText);
  }

  void _showBbFlyerExpanded(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const SingleChildScrollView(
          padding: EdgeInsets.all(12),
          child: _BbImplantFlyerBody(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      backgroundColor: const Color(0xFFE9EBF0),
      body: Column(
        children: [
          _buildTopSection(context),
          _buildBrandsStrip(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 20),
              children: [
                _buildBbDentalOfferCard(context, isAr),
                const SizedBox(height: 10),
                _buildOfferCard(
                  title: 'Powerbone × Medex',
                  subtitle: 'Surgical Kits Offer',
                  tag: 'HOT',
                  tagColor: const Color(0xFF255400),
                  bannerColor: const Color(0xFF2F6C0C),
                  bannerIcon: Icons.shield_outlined,
                  bannerTitle: 'Powerbone Offer Image',
                  validity: 'Valid: May 2025',
                  onShare: () => Share.share('Powerbone × Medex — Surgical Kits Offer'),
                  onOpenDetail: () => context
                      .push(RouteNames.medexOfferDetailPath('powerbone')),
                ),
                const SizedBox(height: 10),
                _buildOfferCard(
                  title: 'Macros × Medex',
                  subtitle: 'Bundle Deal',
                  tag: 'NEW',
                  tagColor: const Color(0xFF113C80),
                  bannerColor: const Color(0xFF1F5FA9),
                  bannerIcon: Icons.event_outlined,
                  bannerTitle: 'Macros Offer Image',
                  validity: 'Valid: June 2025',
                  onShare: () => Share.share('Macros × Medex — Bundle Deal'),
                  onOpenDetail: () =>
                      context.push(RouteNames.medexOfferDetailPath('macros')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBbDentalOfferCard(BuildContext context, bool isAr) {
    final expandHint = isAr ? 'اضغط للتوسيع' : 'Tap to expand';
    void openDetail() =>
        context.push(RouteNames.medexOfferDetailPath('bb-implant'));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD8DBE3)),
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: openDetail,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: const Color(0xFF101828),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              'm',
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'B&B Dental × Medex',
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                'B&B Implant Offer',
                                style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  color: const Color(0xFF667085),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'NEW',
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: const _BbImplantFlyerBody(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => _showBbFlyerExpanded(context),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                expandHint,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF98A2B3),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 15, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Start: 22 Sep 2025 · End: Open',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF5B636F),
                    ),
                  ),
                ),
                Material(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: _shareBbOffer,
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      child: Text(
                        isAr ? 'مشاركة' : 'Share',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
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
    );
  }

  Widget _buildTopSection(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (Navigator.of(context).canPop()) {
                        context.pop();
                      } else {
                        context.go(RouteNames.home);
                      }
                    },
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Medex Offers',
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Special Offers',
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Exclusive deals designed by Medex for our doctors and partners. Each\noffer is uploaded by our team as a designed image.',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.95),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandsStrip() {
    Widget chip(String text, {bool active = false}) {
      return Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : const Color(0xFFF1F2F5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppColors.primary : const Color(0xFFD6D9E0),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.cairo(
            color: active ? Colors.white : const Color(0xFF6B7280),
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Container(
      color: const Color(0xFFE9EBF0),
      padding: const EdgeInsets.only(top: 6, bottom: 4),
      child: Column(
        children: [
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                chip('All Brands', active: true),
                chip('B&B Dental'),
                chip('Powerbone'),
                chip('Macros'),
                chip('MCTBIO'),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                const Icon(Icons.arrow_left, color: Color(0xFF7A7A7A)),
                Expanded(
                  child: Container(
                    height: 12,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    alignment: Alignment.center,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF777777),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const Icon(Icons.arrow_right, color: Color(0xFF7A7A7A)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard({
    required String title,
    required String subtitle,
    required String tag,
    required Color tagColor,
    required Color bannerColor,
    required IconData bannerIcon,
    required String bannerTitle,
    required String validity,
    VoidCallback? onShare,
    VoidCallback? onOpenDetail,
  }) {
    final card = Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3F6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD8DBE3)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: bannerColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(bannerIcon, color: bannerColor, size: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: const Color(0xFF667085),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: tagColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tag,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            height: 132,
            decoration: BoxDecoration(
              color: bannerColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(bannerIcon, color: Colors.white70, size: 34),
                  const SizedBox(height: 6),
                  Text(
                    bannerTitle,
                    style: GoogleFonts.cairo(
                      color: Colors.white70,
                      fontSize: 16 / 1.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    validity,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: const Color(0xFF5B636F),
                    ),
                  ),
                ),
                Material(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: onShare ?? () => Share.share('$title — $subtitle'),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Text(
                        'Share',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
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
    );
    if (onOpenDetail == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onOpenDetail,
        child: card,
      ),
    );
  }
}

class _BbImplantFlyerBody extends StatelessWidget {
  const _BbImplantFlyerBody();

  static const Color _flyerRed = Color(0xFFD90E1C);
  static const Color _footerDark = Color(0xFF374151);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: _flyerRed,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ميدكس',
                        style: GoogleFonts.cairo(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Medex',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      Text(
                        'B&B implant offer',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Medex Dental Implant System',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 8.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        'B&B\nDENTAL',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          color: _flyerRed,
                          fontSize: 7.5,
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            color: const Color(0xFFE5E7EB),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Text(
              'سعر الزرعة خارج العروض 4100 جنيه شامل الأباتمنت',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4B5563),
                height: 1.25,
              ),
            ),
          ),
          const BbImplantOfferGrid(theme: BbImplantOfferGridTheme.listCard),
          Container(
            color: _footerDark,
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'هذه الاسعار قابلة للتغيير',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
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
