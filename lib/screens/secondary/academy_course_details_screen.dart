import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design/app_colors.dart';
import '../../services/academy_service.dart';

class AcademyCourseDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? course;

  const AcademyCourseDetailsScreen({
    super.key,
    this.course,
  });

  @override
  State<AcademyCourseDetailsScreen> createState() =>
      _AcademyCourseDetailsScreenState();
}

class _AcademyCourseDetailsScreenState
    extends State<AcademyCourseDetailsScreen> {
  bool _isLoading = true;
  bool _isEnrolling = false;
  String? _errorMessage;

  Map<String, dynamic>? _courseDetails;
  List<Map<String, dynamic>> _modules = [];
  bool _isEnrolled = false;

  String get _courseId => widget.course?['id']?.toString() ?? '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (_courseId.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Missing course id';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final detailsResponse =
          await AcademyService.instance.getCourseDetails(_courseId);
      final curriculumResponse =
          await AcademyService.instance.getCourseCurriculum(_courseId);

      final detailsData = detailsResponse['data'] is Map<String, dynamic>
          ? detailsResponse['data'] as Map<String, dynamic>
          : <String, dynamic>{};

      final curriculumData = curriculumResponse['data'] is Map<String, dynamic>
          ? curriculumResponse['data'] as Map<String, dynamic>
          : <String, dynamic>{};

      final modulesRaw = curriculumData['modules'];
      final modules = modulesRaw is List
          ? modulesRaw
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
          : <Map<String, dynamic>>[];

      if (!mounted) return;
      setState(() {
        _courseDetails = detailsData;
        _modules = modules;
        _isEnrolled = detailsData['is_enrolled'] == true;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  String _displayText(Map<String, dynamic>? item, String primary,
      [String? alt]) {
    if (item == null) return 'N/A';
    final text = item[primary]?.toString().trim() ?? '';
    if (text.isNotEmpty) return text;
    if (alt != null) {
      final altText = item[alt]?.toString().trim() ?? '';
      if (altText.isNotEmpty) return altText;
    }
    return 'N/A';
  }

  String _formatPrice(Map<String, dynamic>? course) {
    if (course == null) return 'Free';
    final rawPrice = course['price'];
    final currency = (course['currency']?.toString().trim().isNotEmpty ?? false)
        ? course['currency'].toString().trim()
        : 'USD';

    final parsed = rawPrice is num
        ? rawPrice.toDouble()
        : double.tryParse(rawPrice?.toString() ?? '') ?? 0;

    if (parsed <= 0) return 'Free';
    return '${parsed.toStringAsFixed(parsed % 1 == 0 ? 0 : 2)} $currency';
  }

  Future<void> _enrollCourse() async {
    if (_isEnrolling || _courseId.isEmpty || _isEnrolled) return;
    setState(() => _isEnrolling = true);
    try {
      await AcademyService.instance.enrollInCourse(_courseId);
      if (!mounted) return;
      setState(() => _isEnrolled = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Enrollment successful',
            style: GoogleFonts.cairo(),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF027A48),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            style: GoogleFonts.cairo(),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _isEnrolling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFE9EBF0),
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFE9EBF0),
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: Text('Course Details', style: GoogleFonts.cairo()),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 52,
                  color: Colors.red.shade400,
                ),
                const SizedBox(height: 10),
                Text(
                  _errorMessage!,
                  style: GoogleFonts.cairo(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _loadData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Retry', style: GoogleFonts.cairo()),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final course = _courseDetails ?? widget.course ?? <String, dynamic>{};
    final title = _displayText(course, 'title_en', 'title_ar');
    final description =
        _displayText(course, 'description_en', 'description_ar');
    final thumbnail = course['thumbnail_url']?.toString() ??
        widget.course?['thumbnail_url']?.toString() ??
        '';
    final instructorName = (course['instructor'] is Map<String, dynamic>)
        ? (course['instructor']['name']?.toString() ?? 'Unknown')
        : (course['instructor_name']?.toString() ?? 'Unknown');
    final lessonsCount = course['lessons_count']?.toString() ?? '-';
    final duration = course['duration_minutes']?.toString() ?? '-';
    final rating = (course['rating_avg'] as num?)?.toDouble() ?? 0;
    final ratingCount = course['ratings_count']?.toString() ?? '0';

    return Scaffold(
      backgroundColor: const Color(0xFFE9EBF0),
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 230,
              pinned: true,
              backgroundColor: AppColors.primary,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => context.pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding:
                    const EdgeInsetsDirectional.only(start: 54, bottom: 14),
                title: Text(
                  'Course Details',
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    thumbnail.isNotEmpty
                        ? Image.network(
                            thumbnail,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFFB01E2D),
                            ),
                          )
                        : Container(color: const Color(0xFFB01E2D)),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black54],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.cairo(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF101828),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            description,
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              color: const Color(0xFF475467),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildMetaChip(
                                  Icons.person_rounded, instructorName),
                              _buildMetaChip(Icons.menu_book_rounded,
                                  '$lessonsCount lessons'),
                              _buildMetaChip(
                                  Icons.schedule_rounded, '$duration mins'),
                              _buildMetaChip(Icons.star_rounded,
                                  '${rating.toStringAsFixed(1)}'),
                              _buildMetaChip(Icons.rate_review_rounded,
                                  '$ratingCount reviews'),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Text(
                                _formatPrice(course),
                                style: GoogleFonts.cairo(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFFB42318),
                                ),
                              ),
                              const Spacer(),
                              SizedBox(
                                height: 42,
                                child: ElevatedButton.icon(
                                  onPressed: _isEnrolled ? null : _enrollCourse,
                                  icon: _isEnrolling
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Icon(
                                          _isEnrolled
                                              ? Icons.check_circle_rounded
                                              : Icons.school_rounded,
                                        ),
                                  label: Text(
                                    _isEnrolled ? 'Enrolled' : 'Enroll Now',
                                    style: GoogleFonts.cairo(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Curriculum',
                      style: GoogleFonts.cairo(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF101828),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_modules.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'No lessons available yet.',
                          style: GoogleFonts.cairo(
                            color: const Color(0xFF667085),
                          ),
                        ),
                      )
                    else
                      ..._modules.map(_buildModuleCard),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF667085)),
          const SizedBox(width: 5),
          Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF475467),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(Map<String, dynamic> module) {
    final moduleTitle = _displayText(module, 'title_en', 'title_ar');
    final lessonsRaw = module['lessons'];
    final lessons = lessonsRaw is List
        ? lessonsRaw
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList()
        : <Map<String, dynamic>>[];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        title: Text(
          moduleTitle,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF101828),
          ),
        ),
        subtitle: Text(
          '${lessons.length} lessons',
          style: GoogleFonts.cairo(
            fontSize: 12,
            color: const Color(0xFF667085),
          ),
        ),
        children: lessons.map(_buildLessonTile).toList(),
      ),
    );
  }

  Widget _buildLessonTile(Map<String, dynamic> lesson) {
    final title = _displayText(lesson, 'title_en', 'title_ar');
    final isPreview = lesson['is_preview'] == true;
    final isCompleted = lesson['is_completed'] == true;
    final isLocked = lesson['is_locked'] == true;
    final durationSeconds = lesson['duration_seconds'] as num?;
    final durationMinutes = durationSeconds == null
        ? '-'
        : (durationSeconds / 60).ceil().toString();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            isCompleted
                ? Icons.check_circle_rounded
                : isLocked
                    ? Icons.lock_rounded
                    : Icons.play_circle_fill_rounded,
            size: 18,
            color: isCompleted
                ? const Color(0xFF027A48)
                : (isLocked ? const Color(0xFF98A2B3) : AppColors.primary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF344054),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${durationMinutes}m${isPreview ? ' • Preview' : ''}',
            style: GoogleFonts.cairo(
              fontSize: 11,
              color: const Color(0xFF667085),
            ),
          ),
        ],
      ),
    );
  }
}
