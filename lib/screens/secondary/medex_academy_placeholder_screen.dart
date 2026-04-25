import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design/app_colors.dart';
import '../../core/navigation/route_names.dart';
import '../../services/academy_service.dart';
import '../../widgets/bottom_nav.dart';

class MedexAcademyPlaceholderScreen extends StatefulWidget {
  const MedexAcademyPlaceholderScreen({super.key});

  @override
  State<MedexAcademyPlaceholderScreen> createState() =>
      _MedexAcademyPlaceholderScreenState();
}

class _MedexAcademyPlaceholderScreenState
    extends State<MedexAcademyPlaceholderScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isCategoriesLoading = false;

  List<Map<String, dynamic>> _courses = [];
  List<Map<String, dynamic>> _categories = [];
  String? _selectedCategorySlug;

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
    _loadCategories();
    _loadAcademyCourses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _parseItems(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    return [];
  }

  String _displayText(Map<String, dynamic> item, String primary,
      [String? alt]) {
    final text = item[primary]?.toString().trim() ?? '';
    if (text.isNotEmpty) return text;
    if (alt != null) {
      final altText = item[alt]?.toString().trim() ?? '';
      if (altText.isNotEmpty) return altText;
    }
    return 'N/A';
  }

  String _formatPrice(Map<String, dynamic> course) {
    final rawPrice = course['price'];
    final currency = (course['currency']?.toString().trim().isNotEmpty ?? false)
        ? course['currency'].toString().trim()
        : 'USD';

    if (rawPrice is num) {
      if (rawPrice <= 0) return 'Free';
      return '${rawPrice.toStringAsFixed(rawPrice % 1 == 0 ? 0 : 2)} $currency';
    }

    final parsed = double.tryParse(rawPrice?.toString() ?? '');
    if (parsed == null || parsed <= 0) return 'Free';
    return '${parsed.toStringAsFixed(parsed % 1 == 0 ? 0 : 2)} $currency';
  }

  String _courseCategory(Map<String, dynamic> course) {
    final category = course['category'];
    if (category is Map<String, dynamic>) {
      return _displayText(category, 'name_en', 'name_ar');
    }
    return category?.toString() ?? 'General';
  }

  String _categoryLabel(Map<String, dynamic> category) {
    final nameEn = category['nameEn']?.toString().trim() ?? '';
    if (nameEn.isNotEmpty) return nameEn;

    final name = category['name']?.toString().trim() ?? '';
    if (name.isNotEmpty) return name;

    final legacy = _displayText(category, 'name_en', 'name_ar');
    if (legacy != 'N/A') return legacy;

    final slug = category['slug']?.toString().trim() ?? '';
    if (slug.isNotEmpty) return slug;

    return 'N/A';
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isCategoriesLoading = true;
    });
    try {
      final response = await AcademyService.instance.getCategories();
      final data = response['data'];
      final categoriesRaw =
          data is Map<String, dynamic> ? data['categories'] : data;
      final parsed = _parseItems(categoriesRaw);
      if (!mounted) return;
      setState(() {
        _categories = parsed;
        _isCategoriesLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isCategoriesLoading = false;
      });
      _showErrorSnack('Failed to load categories: $e');
    }
  }

  Future<void> _refreshAll() async {
    await _loadCategories();
    await _loadAcademyCourses();
  }

  Future<void> _loadAcademyCourses() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await AcademyService.instance.getCourses(
        page: 1,
        perPage: 10,
        categoryId: _selectedCategorySlug,
        search: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
      );

      final data = response['data'];
      final coursesRaw = data is Map<String, dynamic> ? data['courses'] : data;

      if (!mounted) return;
      setState(() {
        _courses = _parseItems(coursesRaw);
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

  void _showErrorSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.cairo(),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9EBF0),
      body: Stack(
        children: [
          SafeArea(
            top: false,
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(14)),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    14,
                    MediaQuery.of(context).padding.top + 10,
                    14,
                    12,
                  ),
                  child: Column(
                    children: [
                      Row(
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
                              'Medex Academy',
                              style: GoogleFonts.cairo(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Refresh',
                            onPressed: _isCategoriesLoading || _isLoading
                                ? null
                                : _refreshAll,
                            style: IconButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.15),
                              minimumSize: const Size(40, 40),
                              padding: EdgeInsets.zero,
                            ),
                            icon: _isCategoriesLoading || _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.refresh_rounded, size: 22),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              textInputAction: TextInputAction.search,
                              onSubmitted: (_) => _loadAcademyCourses(),
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                color: const Color(0xFF0F172A),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search courses',
                                hintStyle: GoogleFonts.cairo(
                                  fontSize: 13,
                                  color: const Color(0xFF98A2B3),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                prefixIcon: const Icon(
                                  Icons.search_rounded,
                                  color: Color(0xFF667085),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            height: 46,
                            child: ElevatedButton(
                              onPressed: _loadAcademyCourses,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1D2939),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 14),
                                elevation: 0,
                              ),
                              child: Text(
                                'Apply',
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildCategoryTabBar(),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _refreshAll,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                            children: [
                              _buildSectionTitle('Courses', _courses.length),
                              if (_isLoading)
                                _buildLoadingCard()
                              else if (_errorMessage != null)
                                _buildMessageCard(
                                  icon: Icons.error_outline_rounded,
                                  title: 'Could not load courses',
                                  subtitle: _errorMessage!,
                                  actionLabel: 'Retry',
                                  onAction: _loadAcademyCourses,
                                )
                              else if (_courses.isEmpty)
                                _buildMessageCard(
                                  icon: Icons.search_off_rounded,
                                  title: 'No courses found',
                                  subtitle:
                                      'Try another category or search keyword for courses.',
                                )
                              else
                                ..._courses.map(
                                  (course) => _buildCourseCard(course),
                                ),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const BottomNav(activeTab: 'academy'),
        ],
      ),
    );
  }

  Widget _buildCategoryTabBar() {
    return Material(
      color: Colors.white,
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isCategoriesLoading && _categories.isEmpty)
            const LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: Color(0xFFEEF2F6),
              color: AppColors.primary,
            )
          else
            const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryChip(
                    id: null,
                    label: 'All',
                    selected: _selectedCategorySlug == null,
                  ),
                  ..._categories.map((category) {
                    final categorySlug =
                        category['slug']?.toString().trim().isNotEmpty == true
                            ? category['slug']?.toString().trim()
                            : category['id']?.toString();
                    return _buildCategoryChip(
                      id: categorySlug,
                      label: _categoryLabel(category),
                      selected: _selectedCategorySlug == categorySlug,
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 6),
      child: Row(
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: GoogleFonts.cairo(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF344054),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    final title = _displayText(course, 'title_en', 'title_ar');
    final description = _displayText(
      course,
      'short_description_en',
      'short_description_ar',
    );
    final imageUrl = course['thumbnail_url']?.toString() ?? '';
    final instructor = course['instructor_name']?.toString() ?? 'Unknown';
    final level = course['level']?.toString().toUpperCase() ?? 'N/A';
    final duration = course['duration_minutes']?.toString() ?? '-';
    final lessons = course['lessons_count']?.toString() ?? '-';
    final rating = (course['rating_avg'] as num?)?.toDouble() ?? 0;
    final ratingCount = course['ratings_count']?.toString() ?? '0';
    final isEnrolled = course['is_enrolled'] == true;
    final category = _courseCategory(course);
    final priceText = _formatPrice(course);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAECF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => context.push(
          RouteNames.courseDetails,
          extra: course,
        ),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 150,
                width: double.infinity,
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _buildCourseImageFallback(),
                      )
                    : _buildCourseImageFallback(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          category,
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isEnrolled)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF3),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Enrolled',
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF027A48),
                            ),
                          ),
                        ),
                      const Spacer(),
                      Text(
                        priceText,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFB42318),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF101828),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: const Color(0xFF667085),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildMetaPill(Icons.trending_up_rounded, level),
                      _buildMetaPill(Icons.schedule_rounded, '$duration min'),
                      _buildMetaPill(
                          Icons.menu_book_rounded, '$lessons lessons'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_rounded,
                        size: 16,
                        color: Color(0xFF667085),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          instructor,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: const Color(0xFF344054),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.star_rounded,
                          size: 16, color: Color(0xFFF59E0B)),
                      Text(
                        '${rating.toStringAsFixed(1)} ($ratingCount)',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF475467),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: ElevatedButton(
                      onPressed: () => context.push(
                        RouteNames.courseDetails,
                        extra: course,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'View Details',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
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
    );
  }

  Widget _buildCourseImageFallback() {
    return Container(
      color: const Color(0xFFF2F4F7),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_rounded,
        size: 40,
        color: Color(0xFF98A2B3),
      ),
    );
  }

  Widget _buildMetaPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF667085)),
          const SizedBox(width: 4),
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

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Loading courses...',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: const Color(0xFF344054),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 36, color: const Color(0xFF475467)),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: const Color(0xFF667085),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 38,
              child: ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                ),
                child: Text(
                  actionLabel,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryChip({
    required String? id,
    required String label,
    required bool selected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          setState(() => _selectedCategorySlug = id);
          _loadAcademyCourses();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.primary : const Color(0xFFEAECF0),
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : const Color(0xFF344054),
            ),
          ),
        ),
      ),
    );
  }
}
