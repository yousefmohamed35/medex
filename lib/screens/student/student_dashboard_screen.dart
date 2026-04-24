import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/design/app_colors.dart';
import '../../core/navigation/route_names.dart';
import '../../core/api/api_endpoints.dart';
import '../../widgets/bottom_nav.dart';
import '../../services/auth_service.dart';
import '../../services/profile_service.dart';
import '../../l10n/app_localizations.dart';

/// Student profile / account hub (dashboard route).
class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _statistics;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final profile = await ProfileService.instance.getProfile();
      if (kDebugMode) {
        debugPrint('StudentDashboard profile: ${profile['name']}');
      }
      setState(() {
        _profile = profile;
        _statistics = profile['statistics'] as Map<String, dynamic>?;
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading profile: $e');
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDeleteAccount(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          l10n.deleteAccount,
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: Text(
          Localizations.localeOf(context).languageCode == 'ar'
              ? 'هل أنت متأكد من حذف حسابك؟ سيتم حذف جميع بياناتك بشكل نهائي ولا يمكن التراجع عن هذا الإجراء.'
              : 'Are you sure you want to delete your account? All your data will be permanently deleted and this action cannot be undone.',
          style: GoogleFonts.cairo(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              l10n.cancel,
              style: GoogleFonts.cairo(color: AppColors.mutedForeground),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.deleteAccount,
              style: GoogleFonts.cairo(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.red),
              const SizedBox(height: 16),
              Text(
                Localizations.localeOf(context).languageCode == 'ar'
                    ? 'جاري حذف الحساب...'
                    : 'Deleting account...',
                style: GoogleFonts.cairo(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      await AuthService.instance.deleteAccount();

      if (!context.mounted) return;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('hasLaunched');

      if (context.mounted) Navigator.of(context).pop();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Localizations.localeOf(context).languageCode == 'ar'
                  ? 'تم حذف الحساب بنجاح'
                  : 'Account deleted successfully',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.go(RouteNames.splash);
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          AppLocalizations.of(context)!.logout,
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          AppLocalizations.of(context)!.confirmLogout,
          style: GoogleFonts.cairo(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: GoogleFonts.cairo(
                color: AppColors.mutedForeground,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              AppLocalizations.of(context)!.logout,
              style: GoogleFonts.cairo(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout != true || !context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.loggingOut,
                style: GoogleFonts.cairo(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      await AuthService.instance.logout();

      if (!context.mounted) return;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('hasLaunched');

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (context.mounted) {
        context.go(RouteNames.splash);
      }
    } catch (e) {
      if (!context.mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!
                .errorLoggingOut(e.toString().replaceFirst('Exception: ', '')),
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return 'ME';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.length >= 2 ? name.substring(0, 2).toUpperCase() : name[0].toUpperCase();
  }

  String _roleLine() {
    final role = _profile?['role']?.toString().toUpperCase() ?? 'STUDENT';
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    if (role.contains('INSTRUCTOR')) {
      return isAr ? 'مدرب · حساب طبيب' : 'Instructor · Doctor Account';
    }
    return isAr ? 'طبيب · حساب طبيب' : 'Periodontist · Doctor Account';
  }

  String _memberId() {
    final raw = _profile?['id']?.toString().replaceAll('-', '') ?? '';
    if (raw.length >= 5) {
      return 'MX-2024-${raw.substring(raw.length - 5).toUpperCase()}';
    }
    return 'MX-2024-00847';
  }

  int _statInt(String key, int fallback) {
    final v = _statistics?[key];
    if (v is int) return v;
    if (v is num) return v.toInt();
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    final l10n = AppLocalizations.of(context)!;
    final name = _profile?['name']?.toString() ?? l10n.user;
    final enrolled = _statInt('enrolled_courses', 12);
    final certificates = _statInt('certificates_earned', 5);

    return Scaffold(
      backgroundColor: const Color(0xFFE8EAEF),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(child: _buildHeroHeader(context, name)),
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 44, 16, 0),
                            sliver: SliverList(
                              delegate: SliverChildListDelegate([
                                _accessPassCard(context),
                                const SizedBox(height: 22),
                                _sectionLabel('LEARNING & DEVELOPMENT'),
                                _groupedCard(
                                  children: [
                                    _menuTile(
                                      icon: Icons.school_rounded,
                                      iconBg: const Color(0xFFD1FAE5),
                                      iconColor: const Color(0xFF047857),
                                      title: l10n.enrolledLessons,
                                      trailing: _redCountBadge('$enrolled'),
                                      onTap: () => context.push(RouteNames.enrolled),
                                    ),
                                    const _TileDivider(),
                                    _menuTile(
                                      icon: Icons.fact_check_outlined,
                                      iconBg: const Color(0xFFDBEAFE),
                                      iconColor: const Color(0xFF1D4ED8),
                                      title: l10n.myExams,
                                      onTap: () => context.push(RouteNames.myExams),
                                    ),
                                    const _TileDivider(),
                                    _menuTile(
                                      icon: Icons.play_circle_outline_rounded,
                                      iconBg: const Color(0xFFFFE4E6),
                                      iconColor: AppColors.primary,
                                      title: l10n.liveCourses,
                                      onTap: () => context.push(RouteNames.liveCourses),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                _groupedCard(
                                  children: [
                                    _menuTile(
                                      icon: Icons.workspace_premium_rounded,
                                      iconBg: const Color(0xFFFEF9C3),
                                      iconColor: const Color(0xFFB45309),
                                      title: l10n.certificates,
                                      trailing: _redCountBadge('$certificates'),
                                      onTap: () => context.push(RouteNames.certificates),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                _sectionLabel('STORE & ORDERS'),
                                _groupedCard(
                                  children: [
                                    _menuTile(
                                      icon: Icons.local_shipping_outlined,
                                      iconBg: const Color(0xFFDBEAFE),
                                      iconColor: const Color(0xFF1D4ED8),
                                      title: Localizations.localeOf(context).languageCode == 'ar'
                                          ? 'طلباتي'
                                          : 'My Orders',
                                      trailing: _pillBadge('2 new'),
                                      onTap: () => context.push(RouteNames.orders),
                                    ),
                                    const _TileDivider(),
                                    _menuTile(
                                      icon: Icons.attach_money_rounded,
                                      iconBg: const Color(0xFFD1FAE5),
                                      iconColor: const Color(0xFF047857),
                                      title: Localizations.localeOf(context).languageCode == 'ar'
                                          ? 'كشف حساب'
                                          : 'Account Statement',
                                      onTap: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Coming soon')),
                                        );
                                      },
                                    ),
                                    const _TileDivider(),
                                    _menuTile(
                                      icon: Icons.sell_outlined,
                                      iconBg: const Color(0xFFFEF9C3),
                                      iconColor: const Color(0xFFB45309),
                                      title: Localizations.localeOf(context).languageCode == 'ar'
                                          ? 'خصوماتي'
                                          : 'My Discounts',
                                      onTap: () => context.push(RouteNames.medexOffers),
                                    ),
                                    const _TileDivider(),
                                    _menuTile(
                                      icon: Icons.favorite_outline_rounded,
                                      iconBg: const Color(0xFFFFE4E6),
                                      iconColor: AppColors.primary,
                                      title: Localizations.localeOf(context).languageCode == 'ar'
                                          ? 'منتجات محفوظة'
                                          : 'Saved Products',
                                      onTap: () => context.push(RouteNames.store),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                _sectionLabel('DOWNLOADS'),
                                _groupedCard(
                                  children: [
                                    _menuTile(
                                      icon: Icons.description_outlined,
                                      iconBg: const Color(0xFFFFE4E6),
                                      iconColor: AppColors.primary,
                                      title: Localizations.localeOf(context).languageCode == 'ar'
                                          ? 'كتالوج المنتجات'
                                          : 'Product Catalog',
                                      trailingText: '12.8 MB',
                                      onTap: () => context.push(RouteNames.downloads),
                                    ),
                                    const _TileDivider(),
                                    _menuTile(
                                      icon: Icons.article_outlined,
                                      iconBg: const Color(0xFFDBEAFE),
                                      iconColor: const Color(0xFF1D4ED8),
                                      title: Localizations.localeOf(context).languageCode == 'ar'
                                          ? 'دليل جراحي'
                                          : 'Surgical Guide',
                                      trailingText: '4.2 MB',
                                      onTap: () => context.push(RouteNames.downloads),
                                    ),
                                    const _TileDivider(),
                                    _menuTile(
                                      icon: Icons.ondemand_video_outlined,
                                      iconBg: const Color(0xFFD1FAE5),
                                      iconColor: const Color(0xFF047857),
                                      title: Localizations.localeOf(context).languageCode == 'ar'
                                          ? 'فيديوهات تدريبية'
                                          : 'Training Videos',
                                      onTap: () => context.push(RouteNames.downloads),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                _sectionLabel('SUPPORT & FEEDBACK'),
                                _groupedCard(
                                  children: [
                                    _menuTile(
                                      icon: Icons.chat_bubble_outline_rounded,
                                      iconBg: const Color(0xFFEDE9FE),
                                      iconColor: const Color(0xFF6D28D9),
                                      title: Localizations.localeOf(context).languageCode == 'ar'
                                          ? 'محادثة الدعم'
                                          : 'Chat with Support',
                                      onTap: () => context.push(RouteNames.chatConversations),
                                    ),
                                    const _TileDivider(),
                                    _menuTile(
                                      icon: Icons.star_outline_rounded,
                                      iconBg: const Color(0xFFFEF9C3),
                                      iconColor: const Color(0xFFB45309),
                                      title: Localizations.localeOf(context).languageCode == 'ar'
                                          ? 'قيّمنا'
                                          : 'Rate Us',
                                      onTap: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Thanks — coming soon')),
                                        );
                                      },
                                    ),
                                    const _TileDivider(),
                                    _menuTile(
                                      icon: Icons.policy_outlined,
                                      iconBg: const Color(0xFFD1FAE5),
                                      iconColor: const Color(0xFF047857),
                                      title: Localizations.localeOf(context).languageCode == 'ar'
                                          ? 'السياسات والشروط'
                                          : 'Policies & Terms',
                                      onTap: () => context.go(RouteNames.returnsExchanges),
                                    ),
                                    const _TileDivider(),
                                    _menuTile(
                                      icon: Icons.logout_rounded,
                                      iconBg: const Color(0xFFFFE4E6),
                                      iconColor: AppColors.primary,
                                      title: l10n.logout,
                                      titleColor: AppColors.primary,
                                      showChevron: false,
                                      onTap: () => _handleLogout(context),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Center(
                                  child: TextButton(
                                    onPressed: () => _handleDeleteAccount(context),
                                    child: Text(
                                      l10n.deleteAccount,
                                      style: GoogleFonts.cairo(
                                        fontSize: 13,
                                        color: Colors.red.shade300,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 120),
                              ]),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
          const BottomNav(activeTab: 'dashboard'),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context, String name) {
    final initials = _initials(name);
    final avatarUrl = _profile?['avatar'] != null
        ? ApiEndpoints.getImageUrl(_profile!['avatar']?.toString())
        : null;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          color: AppColors.primary,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 56),
              child: Column(
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 4),
                      const Spacer(),
                      IconButton(
                        onPressed: () => context.push(RouteNames.settings),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.settings_outlined, size: 22),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: avatarUrl != null && avatarUrl.isNotEmpty
                        ? Image.network(
                            avatarUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(
                                initials,
                                style: GoogleFonts.cairo(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              initials,
                              style: GoogleFonts.cairo(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _roleLine(),
                    style: GoogleFonts.cairo(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFD700), size: 20),
                        const SizedBox(width: 6),
                        Text(
                          'Gold Member',
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD84D),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '15% OFF',
                            style: GoogleFonts.cairo(
                              color: Colors.black,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ID: ${_memberId()}',
                    style: GoogleFonts.cairo(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 12,
          right: 12,
          bottom: -36,
          child: Row(
            children: [
              Expanded(child: _statCard('${_statInt('enrolled_courses', 12)}', 'Courses')),
              const SizedBox(width: 8),
              Expanded(child: _statCard('${_statInt('certificates_earned', 5)}', 'Certificates')),
              const SizedBox(width: 8),
              Expanded(child: _statCard('${_statInt('total_learning_hours', 42)}h', 'Learning')),
              const SizedBox(width: 8),
              Expanded(child: _statCard('${_statInt('orders_count', 47)}', 'Orders')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF667085),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _accessPassCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E7EC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Access Pass',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Show at counter for instant discount',
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: const Color(0xFF667085),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE4E7EC)),
              ),
              child: CustomPaint(
                painter: _QrPlaceholderPainter(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_offer_outlined, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  'Doctor Discount: 15%',
                  style: GoogleFonts.cairo(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Download pass — coming soon')),
                );
              },
              child: Text(
                'Download Pass',
                style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: const Color(0xFF667085),
        ),
      ),
    );
  }

  Widget _groupedCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
    String? trailingText,
    Color? titleColor,
    bool showChevron = true,
  }) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: titleColor ?? const Color(0xFF101828),
                  ),
                ),
              ),
              if (trailing != null) trailing,
              if (trailingText != null)
                Text(
                  trailingText,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: const Color(0xFF98A2B3),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (showChevron && trailing == null && trailingText == null)
                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _redCountBadge(String count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      alignment: Alignment.center,
      child: Text(
        count,
        style: GoogleFonts.cairo(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _pillBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _TileDivider extends StatelessWidget {
  const _TileDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFE4E7EC));
  }
}

/// Simple QR-like grid placeholder.
class _QrPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / 12;
    final paint = Paint()..color = const Color(0xFF1A1A2E);
    for (var i = 0; i < 12; i++) {
      for (var j = 0; j < 12; j++) {
        if ((i + j) % 2 == 0 || (i < 3 && j < 3) || (i < 3 && j > 8) || (i > 8 && j < 3)) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(i * cell, j * cell, cell * 0.92, cell * 0.92),
              const Radius.circular(1),
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
