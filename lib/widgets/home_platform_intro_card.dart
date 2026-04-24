import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design/app_colors.dart';

class HomePlatformIntroCard extends StatelessWidget {
  const HomePlatformIntroCard({super.key, required this.isAr});

  final bool isAr;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEEF0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isAr
                  ? 'أول منصة ذكية لزراعة الأسنان'
                  : 'THE FIRST SMART IMPLANT PLATFORM',
              style: GoogleFonts.cairo(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isAr
                ? 'ميديكس - أول منصة ذكية لزراعة الأسنان في العالم'
                : 'Medex - The First Smart Implant Platform in the World',
            style: GoogleFonts.cairo(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: AppColors.foreground,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _featureChip(isAr ? 'شركة واحدة' : 'One Company'),
              _featureChip(isAr ? 'حلول متنوعة' : 'Unique Solutions'),
              _featureChip(isAr ? 'تنوع غير محدود' : 'Unlimited Variety'),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            isAr
                ? 'أكثر من مجرد شركة - نظام متكامل لزراعة الأسنان (حلول - تعليم - مجتمع)'
                : 'More than a company - a complete dental implant ecosystem (Solutions - Education - Community)',
            style: GoogleFonts.cairo(
              fontSize: 10,
              color: const Color(0xFF6B7280),
              height: 1.25,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F0F1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFD1D6)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.smartphone_rounded,
                      size: 16, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 64,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFE8E8E8)),
                  ),
                  child: const Icon(Icons.view_agenda_rounded,
                      size: 16, color: Color(0xFFC9CDD3)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                isAr ? 'استكشف المنصة' : 'Explore Platform',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
