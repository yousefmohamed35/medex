import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design/app_colors.dart';
import '../../core/navigation/route_names.dart';

class ClinicalCasesPlaceholderScreen extends StatelessWidget {
  const ClinicalCasesPlaceholderScreen({super.key});

  void _handleBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9EBF0),
      body: Column(
        children: [
          _buildTopBar(context),
          _buildHero(),
          _buildFilters(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 18),
              children: const [
                _CaseCard(
                  label: 'FULL ARCH · B&B',
                  title: 'All-on-4 Immediate Loading – Complete Rehabilitation',
                  summary:
                      'Patient presented with complete edentulism. Final zirconia bridge at 6 months.',
                  doctor: 'Dr. Nour Khalil',
                  location: 'Eg Egypt · Cairo',
                  gradientA: Color(0xFF3A0C10),
                  gradientB: Color(0xFF6B040A),
                ),
                SizedBox(height: 10),
                _CaseCard(
                  label: 'SINGLE UNIT · B&B',
                  title: 'Mandibular Molar Replacement with BLX System',
                  summary:
                      'Single unit immediate implant. ISQ 74 at placement. Final crown at 8 weeks.',
                  doctor: 'Dr. Sami Amin',
                  location: 'Eg Egypt · Alexandria',
                  gradientA: Color(0xFF1B3E82),
                  gradientB: Color(0xFF4B3B95),
                ),
                SizedBox(height: 10),
                _CaseCard(
                  label: 'GBR · REGENERATIVE',
                  title: 'GBR with Collagen Membrane + Delayed Implant',
                  summary:
                      'Horizontal bone augmentation with Powerbone graft. Delayed implant at 6 months.',
                  doctor: 'Dr. Rania Fouad',
                  location: 'Eg Egypt · Giza',
                  gradientA: Color(0xFF4F1B6B),
                  gradientB: Color(0xFFD9072D),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => _handleBack(context),
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
                  'Clinical Cases',
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
                  Icons.search_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2B0A10), Color(0xFF6A0008)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'MEDEX CLINICAL CASES',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Real Cases.\nReal Results.',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 34 / 1.6,
              height: 1.15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '"Selected clinical cases using Medex Dental implants. All cases are\nreviewed by our professional team to provide clear insights."',
            style: GoogleFonts.cairo(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    Widget chip(String text, {bool active = false}) => Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : const Color(0xFFF1F2F5),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: active ? AppColors.primary : const Color(0xFFD6D9E0),
            ),
          ),
          child: Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 12.5,
              color: active ? Colors.white : const Color(0xFF667085),
              fontWeight: FontWeight.w700,
            ),
          ),
        );

    return Container(
      color: const Color(0xFFE9EBF0),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: chip('All Categories ▾')),
              Expanded(child: chip('By Year ▾')),
              Expanded(child: chip('By Doctor ▾')),
              Expanded(child: chip('By Country ▾')),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                chip('B&B Implant', active: true),
                chip('Point Implant'),
                chip('Powerbone'),
                chip('Regenerative'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CaseCard extends StatelessWidget {
  final String label;
  final String title;
  final String summary;
  final String doctor;
  final String location;
  final Color gradientA;
  final Color gradientB;

  const _CaseCard({
    required this.label,
    required this.title,
    required this.summary,
    required this.doctor,
    required this.location,
    required this.gradientA,
    required this.gradientB,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3F6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD8DBE3)),
      ),
      child: Column(
        children: [
          Container(
            height: 145,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [gradientA, gradientB],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      label,
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const Center(
                  child: Icon(Icons.circle_outlined,
                      color: Colors.white54, size: 40),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 17 / 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  summary,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: const Color(0xFF4B5563),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _chip('Full Arch'),
                    const SizedBox(width: 6),
                    _chip('12 months'),
                    const SizedBox(width: 6),
                    _chip('Excellent'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        doctor.split(' ').take(2).map((e) => e[0]).join(),
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor,
                            style: GoogleFonts.cairo(
                                fontSize: 12.5, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            location,
                            style: GoogleFonts.cairo(
                                fontSize: 11, color: const Color(0xFF667085)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'View Case',
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 76,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E9E9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '📄 PDF',
                          style: GoogleFonts.cairo(
                              color: const Color(0xFF8B1D1D),
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _chip(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFE6E8ED),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF475467)),
        ),
      );
}
