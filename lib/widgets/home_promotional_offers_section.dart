import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design/app_colors.dart';

class HomePromotionalOffersSection extends StatelessWidget {
  const HomePromotionalOffersSection({super.key, required this.isAr});

  final bool isAr;

  @override
  Widget build(BuildContext context) {
    final offers = isAr ? _offersAr : _offersEn;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isAr ? 'العروض الترويجية' : 'Promotional Offers',
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.foreground,
                  height: 1.1,
                ),
              ),
              Text(
                isAr ? 'عرض الكل' : 'View All',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 118,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: offers.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final offer = offers[index];
              return _OfferCard(offer: offer);
            },
          ),
        ),
      ],
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.offer});

  final _OfferData offer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 194,
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
      decoration: BoxDecoration(
        color: offer.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    offer.badgeText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Color(0xFFFDE047),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    offer.discountText,
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            offer.titleLine1,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            offer.titleLine2,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferData {
  const _OfferData({
    required this.badgeText,
    required this.titleLine1,
    required this.titleLine2,
    required this.discountText,
    required this.backgroundColor,
  });

  final String badgeText;
  final String titleLine1;
  final String titleLine2;
  final String discountText;
  final Color backgroundColor;
}

const List<_OfferData> _offersEn = [
  _OfferData(
    badgeText: 'LIMITED TIME',
    titleLine1: 'Straumann BLX',
    titleLine2: 'Complete System',
    discountText: '30%',
    backgroundColor: Color(0xFFE5091E),
  ),
  _OfferData(
    badgeText: 'BUNDLE DEAL',
    titleLine1: 'Nobel Active RP',
    titleLine2: 'Buy 10 Get 1',
    discountText: '20%',
    backgroundColor: Color(0xFF1F2937),
  ),
];

const List<_OfferData> _offersAr = [
  _OfferData(
    badgeText: 'لفترة محدودة',
    titleLine1: 'Straumann BLX',
    titleLine2: 'نظام كامل',
    discountText: '30%',
    backgroundColor: Color(0xFFE5091E),
  ),
  _OfferData(
    badgeText: 'عرض باقة',
    titleLine1: 'Nobel Active RP',
    titleLine2: 'اشتر 10 واحصل على 1',
    discountText: '20%',
    backgroundColor: Color(0xFF1F2937),
  ),
];
