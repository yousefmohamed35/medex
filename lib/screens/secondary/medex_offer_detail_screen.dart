import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/design/app_colors.dart';
import '../../core/navigation/route_names.dart';
import '../../widgets/bb_implant_offer_grid.dart';

class MedexOfferDetailScreen extends StatefulWidget {
  const MedexOfferDetailScreen({super.key, required this.offerId});

  final String offerId;

  @override
  State<MedexOfferDetailScreen> createState() => _MedexOfferDetailScreenState();
}

class _MedexOfferDetailScreenState extends State<MedexOfferDetailScreen> {
  static const Color _flyerRed = Color(0xFFD90E1C);
  static const Color _footerDark = Color(0xFF374151);

  String get _offerId => widget.offerId;

  bool get _isBbImplant => _offerId == 'bb-implant';

  String _appBarTitle(bool isAr) {
    switch (_offerId) {
      case 'bb-implant':
        return isAr ? 'عرض زرعات B&B' : 'B&B Implant Offer';
      case 'powerbone':
        return isAr ? 'عرض باوربون' : 'Powerbone Offer';
      case 'macros':
        return isAr ? 'عرض ماكروس' : 'Macros Offer';
      default:
        return isAr ? 'تفاصيل العرض' : 'Offer details';
    }
  }

  String _shareBody(bool isAr) {
    switch (_offerId) {
      case 'bb-implant':
        return isAr
            ? 'عرض زرعات B&B × ميدكس — تفاصيل من تطبيق ميدكس'
            : 'B&B Implant Offer × Medex — see Medex app for details.';
      case 'powerbone':
        return isAr ? 'عرض باوربون × ميدكس' : 'Powerbone × Medex offer';
      case 'macros':
        return isAr ? 'عرض ماكروس × ميدكس' : 'Macros × Medex offer';
      default:
        return isAr ? 'عرض ميدكس' : 'Medex offer';
    }
  }

  Future<void> _onShare(bool isAr) => Share.share(_shareBody(isAr));

  void _onEnquire(bool isAr) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isAr ? 'تم إرسال استفسار الطلب ✓' : 'Order enquiry sent ✓',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        backgroundColor: const Color(0xFF101828),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFE9EBF0),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildAppBar(context, isAr),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(12, 12, 12, 16 + bottomInset),
              child: _isBbImplant
                  ? _buildBbImplantBody(isAr)
                  : _buildGenericOfferBody(isAr),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isAr) {
    return Material(
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 12),
          child: Row(
            children: [
              _roundBarButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () {
                  if (Navigator.of(context).canPop()) {
                    context.pop();
                  } else {
                    context.go(RouteNames.medexOffers);
                  }
                },
              ),
              Expanded(
                child: Text(
                  _appBarTitle(isAr),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _roundBarButton(
                icon: Icons.share_outlined,
                onTap: () => _onShare(isAr),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roundBarButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }

  Widget _buildBbImplantBody(bool isAr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: _flyerRed,
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'm',
                          style: GoogleFonts.cairo(
                            color: _flyerRed,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'ميدكس',
                      style: GoogleFonts.cairo(
                        color: Colors.white.withValues(alpha: 0.95),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'MEDEX',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
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
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Medex Dental Implant System',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 9,
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
                        horizontal: 5, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      'B&B\nDENTAL',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        color: _flyerRed,
                        fontSize: 8,
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
        const SizedBox(height: 10),
        Text(
          'سعر الزرعة خارج العروض 4100 جنيه شامل الأباتمنت',
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
            height: 1.35,
          ),
        ),
        const SizedBox(height: 12),
        const ColoredBox(
          color: Colors.white,
          child: BbImplantOfferGrid(
            theme: BbImplantOfferGridTheme.detailScreen,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: _footerDark,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '2025/9/22',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'هذه الاسعار قابله للتغيير',
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'غير محدد',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => _onEnquire(isAr),
            child: Text(
              isAr ? 'استفسر عن هذا العرض ←' : 'Enquire about this Offer →',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenericOfferBody(bool isAr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD8DBE3)),
          ),
          child: Column(
            children: [
              Icon(
                Icons.local_offer_outlined,
                size: 48,
                color: AppColors.primary.withValues(alpha: 0.85),
              ),
              const SizedBox(height: 12),
              Text(
                isAr
                    ? 'تفاصيل العرض الكاملة ستُعرض هنا قريباً.'
                    : 'Full offer artwork and pricing will appear here soon.',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF667085),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => _onEnquire(isAr),
            child: Text(
              isAr ? 'استفسر عن هذا العرض ←' : 'Enquire about this Offer →',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
