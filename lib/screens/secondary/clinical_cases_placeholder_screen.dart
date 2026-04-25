import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/design/app_colors.dart';
import '../../core/navigation/route_names.dart';
import '../../services/clinical_cases_service.dart';

class ClinicalCasesPlaceholderScreen extends StatefulWidget {
  const ClinicalCasesPlaceholderScreen({super.key});

  @override
  State<ClinicalCasesPlaceholderScreen> createState() =>
      _ClinicalCasesPlaceholderScreenState();
}

class _ClinicalCasesPlaceholderScreenState
    extends State<ClinicalCasesPlaceholderScreen> {
  bool _isLoadingCases = true;
  List<_ClinicalCaseData> _cases = const [];
  String _searchQuery = '';
  String _selectedCategoryId = 'all';

  void _handleBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.home);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCases();
  }

  Future<void> _loadCases() async {
    setState(() {
      _isLoadingCases = true;
    });
    try {
      final isAr = Localizations.localeOf(context).languageCode == 'ar';
      final rawCases = await ClinicalCasesService.instance.getCases(perPage: 20);
      final mapped = rawCases.map((e) => _mapApiCase(e, isAr)).toList();
      if (!mounted) return;
      setState(() {
        _cases = mapped.isEmpty ? _fallbackCases() : mapped;
        if (_cases.isNotEmpty && _cases.first.categoryId.isNotEmpty) {
          _selectedCategoryId = _cases.first.categoryId;
        } else {
          _selectedCategoryId = 'all';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cases = _fallbackCases();
        if (_cases.isNotEmpty && _cases.first.categoryId.isNotEmpty) {
          _selectedCategoryId = _cases.first.categoryId;
        } else {
          _selectedCategoryId = 'all';
        }
      });
    } finally {
      if (mounted) setState(() => _isLoadingCases = false);
    }
  }

  List<_ClinicalCaseData> _fallbackCases() => <_ClinicalCaseData>[
        const _ClinicalCaseData(
          id: '55099e0f-2670-4af9-9c15-6efe3a1eb13c',
          categoryId: '8c9aa259-03f2-4e0a-82c4-d9197e3cc5c7',
          label: 'FULL ARCH · B&B',
          title: 'All-on-4 Immediate Loading – Complete Rehabilitation',
          summary:
              'Patient presented with complete edentulism. Final zirconia bridge at 6 months.',
          details:
              'Clinical case from B&B Dental implantology collection.',
          categoryName: 'Subperiosteal Implants',
          categoryNameAr: 'زرعات تحت السمحاق',
          slug: 'bilateral-subperiosteal-customized-implants-on-atrophic-mandible',
          status: 'active',
          position: 1,
          gradientA: Color(0xFF3A0C10),
          gradientB: Color(0xFF6B040A),
        ),
        const _ClinicalCaseData(
          id: 'e5d94941-4d2b-4412-ba04-fa5efa79897a',
          categoryId: 'e416f32a-e4a8-4966-925d-50a83fdac908',
          label: 'SINGLE UNIT · B&B',
          title: 'Mandibular Molar Replacement with BLX System',
          summary:
              'Single unit immediate implant. ISQ 74 at placement. Final crown at 8 weeks.',
          details:
              'Clinical case from B&B Dental implantology collection.',
          categoryName: 'Guided Surgery',
          categoryNameAr: 'الجراحة الموجهة',
          slug: 'all-on-6-with-guided-surgery',
          status: 'active',
          position: 3,
          gradientA: Color(0xFF1B3E82),
          gradientB: Color(0xFF4B3B95),
        ),
        const _ClinicalCaseData(
          id: 'c132e013-247c-45cc-b777-2733e14cfbf2',
          categoryId: 'e416f32a-e4a8-4966-925d-50a83fdac908',
          label: 'GBR · REGENERATIVE',
          title: 'GBR with Collagen Membrane + Delayed Implant',
          summary:
              'Horizontal bone augmentation with Powerbone graft. Delayed implant at 6 months.',
          details:
              'Clinical case from B&B Dental implantology collection.',
          categoryName: 'Guided Surgery',
          categoryNameAr: 'الجراحة الموجهة',
          slug: '4-implants-guided-surgery-with-extractions-and-immediate-loading',
          status: 'active',
          position: 4,
          gradientA: Color(0xFF4F1B6B),
          gradientB: Color(0xFFD9072D),
        ),
      ];

  _ClinicalCaseData _mapApiCase(Map<String, dynamic> map, bool isAr) {
    final category = map['category'] is Map
        ? Map<String, dynamic>.from(map['category'] as Map)
        : <String, dynamic>{};

    Color parseHex(String? hex, Color fallback) {
      if (hex == null || hex.trim().isEmpty) return fallback;
      final clean = hex.trim().replaceAll('#', '');
      if (clean.length == 6) {
        final value = int.tryParse('FF$clean', radix: 16);
        if (value != null) return Color(value);
      } else if (clean.length == 8) {
        final value = int.tryParse(clean, radix: 16);
        if (value != null) return Color(value);
      }
      return fallback;
    }

    return _ClinicalCaseData(
      id: map['id']?.toString() ?? '',
      categoryId: map['categoryId']?.toString() ?? category['id']?.toString() ?? '',
      label: map['label']?.toString() ??
          '${map['category'] is Map ? ((map['category'] as Map)['name']?.toString() ?? 'CASE') : 'CASE'}',
      title: ClinicalCasesService.pickLocalized(
        map,
        'title',
        isAr,
        fallback: 'Clinical Case',
      ),
      summary: ClinicalCasesService.pickLocalized(
        map,
        'summary',
        isAr,
        fallback: map['details']?.toString() ?? '',
      ),
      details: ClinicalCasesService.pickLocalized(
        map,
        'details',
        isAr,
        fallback: '',
      ),
      categoryName: category['name']?.toString() ?? '',
      categoryNameAr: category['nameAr']?.toString() ?? category['name']?.toString() ?? '',
      slug: map['slug']?.toString() ?? '',
      status: map['status']?.toString() ?? '',
      featured: map['featured'] == true,
      position: ClinicalCasesService.toInt(map['position']),
      createdAt: map['createdAt']?.toString() ?? '',
      updatedAt: map['updatedAt']?.toString() ?? '',
      gradientA: parseHex(
        map['hero_gradient_a']?.toString(),
        const Color(0xFF3A0C10),
      ),
      gradientB: parseHex(
        map['hero_gradient_b']?.toString(),
        const Color(0xFF6B040A),
      ),
      thumbnailUrl: ApiEndpoints.getImageUrl(
        map['thumbnail']?.toString(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final source = _cases.isEmpty ? _fallbackCases() : _cases;
    final categoryFiltered = _selectedCategoryId == 'all'
        ? source
        : source.where((c) => c.categoryId == _selectedCategoryId).toList();
    final q = _searchQuery.trim().toLowerCase();
    final cases = q.isEmpty
        ? categoryFiltered
        : categoryFiltered
            .where((c) =>
                c.title.toLowerCase().contains(q) ||
                c.summary.toLowerCase().contains(q) ||
                c.label.toLowerCase().contains(q))
            .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFE9EBF0),
      body: Column(
        children: [
          _buildTopBar(context),
          _buildHero(),
          _buildFilters(context),
          Expanded(
            child: _isLoadingCases
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 18),
                    children: [
                      for (var i = 0; i < cases.length; i++) ...[
                        (() {
                          final caseItem = cases[i];
                          return _CaseCard(
                            data: caseItem,
                            onViewCase: () {
                              final hasUuidLikeId = caseItem.id.contains('-');
                              if (!hasUuidLikeId) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Invalid case id. Please refresh cases.',
                                      style: GoogleFonts.cairo(),
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
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
              GestureDetector(
                onTap: () async {
                  final ctrl = TextEditingController(text: _searchQuery);
                  final value = await showDialog<String>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(
                        'Search Cases',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                      ),
                      content: TextField(
                        controller: ctrl,
                        autofocus: true,
                        decoration: const InputDecoration(hintText: 'Type title...'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              Navigator.of(ctx).pop(ctrl.text.trim()),
                          child: const Text('Apply'),
                        ),
                      ],
                    ),
                  );
                  if (value != null && mounted) {
                    setState(() => _searchQuery = value);
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
                    Icons.search_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
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

  Widget _buildFilters(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final uniqueCategories = <String, _CategoryFilterOption>{};
    for (final item in _cases) {
      if (item.categoryId.isEmpty) continue;
      uniqueCategories[item.categoryId] = _CategoryFilterOption(
        id: item.categoryId,
        name: isAr
            ? (item.categoryNameAr.isNotEmpty ? item.categoryNameAr : item.categoryName)
            : item.categoryName,
      );
    }
    final categories = uniqueCategories.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    Widget topFilterChip(String text) => Container(
          height: 32,
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFECEEF2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFD9DDE4)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 11.5,
                    color: const Color(0xFF374151),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_drop_down_rounded,
                size: 16,
                color: Color(0xFF6B7280),
              ),
            ],
          ),
        );

    Widget categoryChip(
      String text, {
      required bool active,
      required VoidCallback onTap,
    }) =>
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 34,
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: active ? AppColors.primary : const Color(0xFFF7F7F8),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: active ? AppColors.primary : const Color(0xFFD1D5DB),
              ),
            ),
            child: Center(
              child: Text(
                text,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: active ? Colors.white : const Color(0xFF374151),
                  fontWeight: FontWeight.w700,
                ),
              ),
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
              Expanded(child: topFilterChip('All Categories')),
              Expanded(child: topFilterChip('By Year')),
              Expanded(child: topFilterChip('By Doctor')),
              Expanded(child: topFilterChip('By Country')),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                categoryChip(
                  isAr ? 'كل التصنيفات' : 'All Categories',
                  active: _selectedCategoryId == 'all',
                  onTap: () => setState(() => _selectedCategoryId = 'all'),
                ),
                ...categories.map(
                  (cat) => categoryChip(
                    cat.name,
                    active: _selectedCategoryId == cat.id,
                    onTap: () => setState(() => _selectedCategoryId = cat.id),
                  ),
                ),
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
                if (data.thumbnailUrl.isNotEmpty)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(14)),
                      child: Image.network(
                        data.thumbnailUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const SizedBox.shrink(),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(14)),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.black.withValues(alpha: 0.15),
                          Colors.black.withValues(alpha: 0.35),
                        ],
                      ),
                    ),
                  ),
                ),
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
                    _chip(data.categoryName.isNotEmpty ? data.categoryName : 'Category'),
                    const SizedBox(width: 6),
                    _chip(data.status.isNotEmpty ? data.status : 'active'),
                    if (data.featured) ...[
                      const SizedBox(width: 6),
                      _chip('featured'),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        '#${data.position == 0 ? 1 : data.position}',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 10,
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
                            data.slug.isNotEmpty ? data.slug : data.id,
                            style: GoogleFonts.cairo(
                                fontSize: 11.5, fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            data.createdAt.isNotEmpty
                                ? data.createdAt.replaceFirst('T', ' ').split('.').first
                                : 'No timestamp',
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
  final String id;
  final String categoryId;
  final String label;
  final String title;
  final String summary;
  final String details;
  final String categoryName;
  final String categoryNameAr;
  final String slug;
  final String status;
  final bool featured;
  final int position;
  final String createdAt;
  final String updatedAt;
  final Color gradientA;
  final Color gradientB;
  final String thumbnailUrl;

  const _ClinicalCaseData({
    required this.id,
    this.categoryId = '',
    required this.label,
    required this.title,
    required this.summary,
    this.details = '',
    this.categoryName = '',
    this.categoryNameAr = '',
    this.slug = '',
    this.status = '',
    this.featured = false,
    this.position = 0,
    this.createdAt = '',
    this.updatedAt = '',
    required this.gradientA,
    required this.gradientB,
    this.thumbnailUrl = '',
  });
}

class _CategoryFilterOption {
  final String id;
  final String name;
  const _CategoryFilterOption({required this.id, required this.name});
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
  bool _isSubmittingRating = false;
  bool _isLoadingDetail = true;
  Map<String, dynamic>? _detail;

  @override
  void initState() {
    super.initState();
    _loadCaseDetail();
  }

  Future<void> _loadCaseDetail() async {
    setState(() {
      _isLoadingDetail = true;
    });
    try {
      final detail =
          await ClinicalCasesService.instance.getCaseDetail(widget.data.id);
      if (!mounted) return;
      setState(() => _detail = detail);
    } catch (e) {
      if (!mounted) return;
      // Keep fallback UI without exposing raw backend errors.
    } finally {
      if (mounted) setState(() => _isLoadingDetail = false);
    }
  }

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
                      onPressed: _selectedRating == 0 || _isSubmittingRating
                          ? null
                          : () async {
                              setState(() => _isSubmittingRating = true);
                              try {
                                await ClinicalCasesService.instance.submitRating(
                                  caseId: widget.data.id,
                                  rating: _selectedRating,
                                );
                                if (!mounted) return;
                                Navigator.of(ctx).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Rating submitted ($_selectedRating/5)',
                                      style: GoogleFonts.cairo(),
                                    ),
                                  ),
                                );
                              } catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      e.toString().replaceFirst('Exception: ', ''),
                                      style: GoogleFonts.cairo(),
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } finally {
                                if (mounted) {
                                  setState(() => _isSubmittingRating = false);
                                  setSheetState(() {});
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSubmittingRating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
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
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final detail = _detail ?? <String, dynamic>{};
    final media = detail['media'] is Map
        ? Map<String, dynamic>.from(detail['media'] as Map)
        : <String, dynamic>{};
    final hero = detail['hero'] is Map
        ? Map<String, dynamic>.from(detail['hero'] as Map)
        : <String, dynamic>{};

    final title = ClinicalCasesService.pickLocalized(
      detail,
      'title',
      isAr,
      fallback: caseData.title,
    );
    final summaryText = ClinicalCasesService.pickLocalized(
      detail,
      'summary',
      isAr,
      fallback: caseData.summary,
    );
    final caseSummary = ClinicalCasesService.pickLocalized(
      detail,
      'case_summary',
      isAr,
      fallback: ClinicalCasesService.pickLocalized(
        detail,
        'details',
        isAr,
        fallback:
            'Patient presented with complete edentulism of maxillary arch. After CBCT planning, 4 BLX implants were placed (2 axial + 2 tilted at 30°). Provisional bridge delivered same day at 35 Ncm. Final zirconia bridge placed at 6 months. ISQ values at loading: 72–78.',
      ),
    );
    final categoryMap = detail['category'] is Map
        ? Map<String, dynamic>.from(detail['category'] as Map)
        : <String, dynamic>{};
    final category = isAr
        ? (categoryMap['nameAr']?.toString() ??
            categoryMap['name']?.toString() ??
            caseData.categoryNameAr)
        : (categoryMap['name']?.toString() ?? caseData.categoryName);
    final slug = detail['slug']?.toString() ?? caseData.slug;
    final status = detail['status']?.toString() ?? caseData.status;
    final featured = detail['featured'] == true || caseData.featured;
    final position = ClinicalCasesService.toInt(
      detail['position'],
      fallback: caseData.position,
    );
    final createdAt = detail['createdAt']?.toString() ?? caseData.createdAt;
    final updatedAt = detail['updatedAt']?.toString() ?? caseData.updatedAt;
    final videoUrl = media['video_url']?.toString() ?? detail['video_url']?.toString() ?? '';
    final pdfUrl = media['pdf_url']?.toString() ?? detail['pdf_url']?.toString() ?? '';
    final images = (media['images'] as List?)?.map((e) => e.toString()).toList() ?? <String>[];
    final imageCount = images.isNotEmpty
        ? images.length
        : ClinicalCasesService.toInt(detail['images_count'], fallback: 14);
    final gradientA = _parseHexColor(
      hero['gradient_a']?.toString(),
      fallback: caseData.gradientA,
    );
    final gradientB = _parseHexColor(
      hero['gradient_b']?.toString(),
      fallback: caseData.gradientB,
    );
    final thumbnailUrl = ApiEndpoints.getImageUrl(
      detail['thumbnail']?.toString() ?? caseData.thumbnailUrl,
    );

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
            child: _isLoadingDetail
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 240,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [gradientA, gradientB],
                      ),
                    ),
                    child: Stack(
                      children: [
                        if (thumbnailUrl.isNotEmpty)
                          Positioned.fill(
                            child: Image.network(
                              thumbnailUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                            ),
                          ),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.15),
                                  Colors.black.withValues(alpha: 0.45),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: Row(
                            children: [
                              _mediaTag('▶ Video', onTap: videoUrl.isEmpty ? null : () {}),
                              const SizedBox(width: 8),
                              _mediaTag('📄 PDF', onTap: pdfUrl.isEmpty ? null : () {}),
                              const SizedBox(width: 8),
                              _mediaTag('▦ $imageCount imgs', onTap: images.isEmpty ? null : () {}),
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
                                category,
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            if (featured) const SizedBox(width: 10),
                            if (featured)
                              Text(
                                'Featured',
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  color: const Color(0xFF047857),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          title,
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
                                '#$position',
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
                                    slug.isNotEmpty ? slug : caseData.id,
                                    style: GoogleFonts.cairo(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    status.isNotEmpty ? status : 'active',
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
                        Row(
                          children: [
                            Expanded(
                              child: _MetaBlock(
                                label: 'CREATED AT',
                                value: createdAt.isNotEmpty
                                    ? createdAt
                                        .replaceFirst('T', ' ')
                                        .split('.')
                                        .first
                                    : '-',
                              ),
                            ),
                            Expanded(
                              child: _MetaBlock(
                                label: 'UPDATED AT',
                                value: updatedAt.isNotEmpty
                                    ? updatedAt
                                        .replaceFirst('T', ' ')
                                        .split('.')
                                        .first
                                    : '-',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _MetaBlock(
                                label: 'CATEGORY',
                                value: category,
                              ),
                            ),
                            Expanded(
                              child: _MetaBlock(
                                label: 'CASE ID',
                                value: caseData.id.length > 12
                                    ? '${caseData.id.substring(0, 8)}...'
                                    : caseData.id,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _statusChip(status.isEmpty ? 'active' : status),
                            if (featured) _statusChip('featured'),
                            _statusChip('position: $position'),
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
                          summaryText,
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: const Color(0xFF4B5563),
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          caseSummary,
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
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (thumbnailUrl.isNotEmpty)
                              _statusChip('thumbnail'),
                            if (videoUrl.isNotEmpty) _statusChip('video'),
                            if (pdfUrl.isNotEmpty) _statusChip('pdf'),
                            if (images.isNotEmpty) _statusChip('images: ${images.length}'),
                            if (thumbnailUrl.isEmpty &&
                                videoUrl.isEmpty &&
                                pdfUrl.isEmpty &&
                                images.isEmpty)
                              Text(
                                'No media attached for this case',
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                          ],
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

  Widget _mediaTag(String text, {VoidCallback? onTap}) {
    final child = Container(
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
    if (onTap == null) return child;
    return GestureDetector(onTap: onTap, child: child);
  }

  Color _parseHexColor(String? hex, {required Color fallback}) {
    if (hex == null || hex.trim().isEmpty) return fallback;
    final clean = hex.trim().replaceAll('#', '');
    if (clean.length == 6) {
      final value = int.tryParse('FF$clean', radix: 16);
      if (value != null) return Color(value);
    } else if (clean.length == 8) {
      final value = int.tryParse(clean, radix: 16);
      if (value != null) return Color(value);
    }
    return fallback;
  }

  Widget _statusChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          fontSize: 12,
          color: const Color(0xFF374151),
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

