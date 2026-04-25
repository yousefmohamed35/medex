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
    final cases = <_ClinicalCaseData>[
      const _ClinicalCaseData(
        label: 'FULL ARCH · B&B',
        title: 'All-on-4 Immediate Loading – Complete Rehabilitation',
        summary:
            'Patient presented with complete edentulism. Final zirconia bridge at 6 months.',
        doctor: 'Dr. Nour Khalil',
        location: 'Eg Egypt · Cairo',
        gradientA: Color(0xFF3A0C10),
        gradientB: Color(0xFF6B040A),
      ),
      const _ClinicalCaseData(
        label: 'SINGLE UNIT · B&B',
        title: 'Mandibular Molar Replacement with BLX System',
        summary:
            'Single unit immediate implant. ISQ 74 at placement. Final crown at 8 weeks.',
        doctor: 'Dr. Sami Amin',
        location: 'Eg Egypt · Alexandria',
        gradientA: Color(0xFF1B3E82),
        gradientB: Color(0xFF4B3B95),
      ),
      const _ClinicalCaseData(
        label: 'GBR · REGENERATIVE',
        title: 'GBR with Collagen Membrane + Delayed Implant',
        summary:
            'Horizontal bone augmentation with Powerbone graft. Delayed implant at 6 months.',
        doctor: 'Dr. Rania Fouad',
        location: 'Eg Egypt · Giza',
        gradientA: Color(0xFF4F1B6B),
        gradientB: Color(0xFFD9072D),
      ),
    ];

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
              children: [
                for (var i = 0; i < cases.length; i++) ...[
                  // Capture current item per iteration to avoid closure/index issues.
                  (() {
                    final caseItem = cases[i];
                    return _CaseCard(
                      data: caseItem,
                      onViewCase: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                ClinicalCaseDetailScreen(data: caseItem),
                          ),
                        );
                      },
                    );
                  })(),
                  if (i != cases.length - 1) const SizedBox(height: 10),
                ],
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
              fontSize: 21,
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
  final _ClinicalCaseData data;
  final VoidCallback onViewCase;

  const _CaseCard({
    required this.data,
    required this.onViewCase,
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
                colors: [data.gradientA, data.gradientB],
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
                      data.label,
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const Center(
                  child:
                      Icon(Icons.circle_outlined, color: Colors.white54, size: 40),
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
                  data.title,
                  style: GoogleFonts.cairo(
                    fontSize: 14.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.summary,
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
                        data.doctor.split(' ').take(2).map((e) => e[0]).join(),
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
                            data.doctor,
                            style: GoogleFonts.cairo(
                                fontSize: 12.5, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            data.location,
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
                      child: GestureDetector(
                        onTap: onViewCase,
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

class _ClinicalCaseData {
  final String label;
  final String title;
  final String summary;
  final String doctor;
  final String location;
  final Color gradientA;
  final Color gradientB;

  const _ClinicalCaseData({
    required this.label,
    required this.title,
    required this.summary,
    required this.doctor,
    required this.location,
    required this.gradientA,
    required this.gradientB,
  });
}

class ClinicalCaseDetailScreen extends StatefulWidget {
  const ClinicalCaseDetailScreen({super.key, required this.data});

  final _ClinicalCaseData data;

  @override
  State<ClinicalCaseDetailScreen> createState() =>
      _ClinicalCaseDetailScreenState();
}

class _ClinicalCaseDetailScreenState extends State<ClinicalCaseDetailScreen> {
  int _selectedRating = 0;

  void _openRatingSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD0D5DD),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'How was your experience?',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'tap a star to rate',
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: const Color(0xFF667085),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final active = _selectedRating > index;
                      return IconButton(
                        onPressed: () {
                          setState(() => _selectedRating = index + 1);
                          setSheetState(() {});
                        },
                        icon: Icon(
                          active
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: active
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF1F2937),
                          size: 34,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedRating == 0
                          ? null
                          : () {
                              Navigator.of(ctx).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Rating submitted ($_selectedRating/5)',
                                    style: GoogleFonts.cairo(),
                                  ),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Submit Rating',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF344054),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Skip',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final caseData = widget.data;
    return Scaffold(
      backgroundColor: const Color(0xFFE5E7EB),
      body: Column(
        children: [
          Container(
            color: AppColors.primary,
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: 64,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 17,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Case Detail',
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(
                          Icons.tune_rounded,
                          color: Colors.white,
                          size: 19,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 240,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [caseData.gradientA, caseData.gradientB],
                      ),
                    ),
                    child: Stack(
                      children: [
                        const Center(
                          child: Icon(
                            Icons.circle_outlined,
                            color: Colors.white54,
                            size: 56,
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: Row(
                            children: [
                              _mediaTag('▶ Video'),
                              const SizedBox(width: 8),
                              _mediaTag('📄 PDF'),
                              const SizedBox(width: 8),
                              _mediaTag('▦ 14 imgs'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                    decoration: const BoxDecoration(color: Color(0xFFE5E7EB)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'FULL ARCH',
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'B&B Implant',
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: const Color(0xFF6B7280),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          caseData.title,
                          style: GoogleFonts.cairo(
                            fontSize: 20,
                            height: 1.2,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.primary,
                              child: Text(
                                'NK',
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    caseData.doctor,
                                    style: GoogleFonts.cairo(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    'Periodontist · Cairo University · EG Egypt',
                                    style: GoogleFonts.cairo(
                                      fontSize: 10,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Row(
                          children: [
                            Expanded(
                              child: _MetaBlock(
                                label: 'AGE / GENDER',
                                value: '54 · Female',
                              ),
                            ),
                            Expanded(
                              child: _MetaBlock(
                                label: 'FOLLOW-UP',
                                value: '12 months',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Row(
                          children: [
                            Expanded(
                              child: _MetaBlock(
                                label: 'IMPLANT SYSTEM',
                                value: 'B&B BLX 4.5mm',
                              ),
                            ),
                            Expanded(
                              child: _MetaBlock(
                                label: 'LOADING',
                                value: 'Immediate',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Row(
                          children: [
                            Expanded(
                              child: _BeforeAfterCard(
                                title: 'BEFORE',
                                background: Color(0xFFF3F4F6),
                                emoji: '😬',
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: _BeforeAfterCard(
                                title: 'AFTER',
                                background: Color(0xFFF1E4E4),
                                emoji: '😁',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 16, 14, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Case Summary',
                          style: GoogleFonts.cairo(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Patient presented with complete edentulism of maxillary arch. '
                          'After CBCT planning, 4 BLX implants were placed (2 axial + 2 tilted at 30°). '
                          'Provisional bridge delivered same day at 35 Ncm. Final zirconia bridge placed at 6 months. '
                          'ISQ values at loading: 72–78.',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: const Color(0xFF4B5563),
                            height: 1.65,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Media Gallery',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 94,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: const [
                              _GalleryThumb(
                                gradient: [Color(0xFF3A0C10), Color(0xFFD9072D)],
                              ),
                              SizedBox(width: 10),
                              _GalleryThumb(
                                gradient: [Color(0xFF1E3A8A), Color(0xFF4338CA)],
                              ),
                              SizedBox(width: 10),
                              _GalleryThumb(
                                gradient: [Color(0xFF4C1D95), Color(0xFFE11D48)],
                                label: '▶ Video',
                              ),
                              SizedBox(width: 10),
                              _GalleryThumb(pdf: true, label: '📄 PDF'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: const Color(0xFF9CA3AF),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _openRatingSheet,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                            ),
                            child: Text(
                              'Rate this Case ★',
                              style: GoogleFonts.cairo(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
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
        ],
      ),
    );
  }

  Widget _mediaTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          color: Colors.white,
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MetaBlock extends StatelessWidget {
  const _MetaBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12,
            color: const Color(0xFF9CA3AF),
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: const Color(0xFF111827),
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _BeforeAfterCard extends StatelessWidget {
  const _BeforeAfterCard({
    required this.title,
    required this.background,
    required this.emoji,
  });

  final String title;
  final Color background;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 3),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Center(
              child: Text(
                title,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 100,
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 40)),
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryThumb extends StatelessWidget {
  const _GalleryThumb({
    this.gradient,
    this.label,
    this.pdf = false,
  });

  final List<Color>? gradient;
  final String? label;
  final bool pdf;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 94,
      decoration: BoxDecoration(
        color: pdf ? const Color(0xFFF2E8E8) : null,
        gradient: gradient != null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradient!,
              )
            : null,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: pdf ? const Color(0xFFE5BDBD) : Colors.transparent,
        ),
      ),
      child: Center(
        child: Text(
          label ?? '',
          style: GoogleFonts.cairo(
            color: pdf ? AppColors.primary : Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
