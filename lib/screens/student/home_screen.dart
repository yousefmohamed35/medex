import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../core/design/app_colors.dart';
import '../../core/navigation/route_names.dart';
import '../../core/api/api_endpoints.dart';
import '../../widgets/home_media_banner.dart';
import '../../widgets/home_featured_products_section.dart';
import '../../widgets/home_implant_community_section.dart';
import '../../widgets/home_platform_intro_card.dart';
import '../../widgets/home_promotional_offers_section.dart';
import '../../widgets/home_quick_access.dart';
import '../../widgets/premium_course_card.dart';
import '../../widgets/bottom_nav.dart';
import '../../services/home_service.dart';
import '../../services/profile_service.dart';
import '../../services/notifications_service.dart';
import '../../services/cart_service.dart';
import '../../services/store_service.dart';
import '../../models/product.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const bool _showProductCategoriesSection = false;

  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _userProfile;
  int _notificationsCount = 0;
  List<Map<String, dynamic>> _featuredCourses = [];
  List<Map<String, dynamic>> _popularCourses = [];
  List<Map<String, dynamic>> _continueLearning = [];
  List<Map<String, dynamic>> _quickAccessItems = [];
  Map<String, dynamic>? _heroBanner;
  List<ProductCategory> _storeCategories = [];
  List<Product> _storeProducts = [];

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final homeData = await HomeService.instance.getHomeData();

      // Run independent calls in parallel — sequential awaits were stacking latency.
      Future<Map<String, dynamic>?> profileJob() async {
        try {
          return await ProfileService.instance.getProfile();
        } catch (e) {
          if (kDebugMode) print('Profile load error: $e');
          return null;
        }
      }

      Future<Map<String, dynamic>> notificationsJob() async {
        try {
          return await NotificationsService.instance
              .getNotifications(unreadOnly: true, perPage: 1);
        } catch (e) {
          return {};
        }
      }

      Future<List<ProductCategory>> categoriesJob() async {
        try {
          return await StoreService.instance.getCategories();
        } catch (e) {
          if (kDebugMode) print('Store categories error: $e');
          return [];
        }
      }

      Future<List<Product>> productsJob() async {
        try {
          // Home preview only — avoid perPage: 100 (large JSON + slow decode).
          return await StoreService.instance.getProducts(perPage: 20);
        } catch (e) {
          if (kDebugMode) print('Store products error: $e');
          return [];
        }
      }

      final parallel = await Future.wait([
        profileJob(),
        notificationsJob(),
        categoriesJob(),
        productsJob(),
      ]);

      final profile = parallel[0] as Map<String, dynamic>?;
      final notifications = parallel[1] as Map<String, dynamic>;
      final storeCategories = parallel[2] as List<ProductCategory>;
      final storeProducts = parallel[3] as List<Product>;

      if (!mounted) return;
      setState(() {
        _heroBanner = homeData['hero_banner'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(homeData['hero_banner'])
            : null;
        _userProfile = profile;
        _notificationsCount = notifications['meta']?['unread_count'] ?? 0;
        _featuredCourses =
            List<Map<String, dynamic>>.from(homeData['featured_courses'] ?? []);
        _popularCourses =
            List<Map<String, dynamic>>.from(homeData['popular_courses'] ?? []);
        _continueLearning = List<Map<String, dynamic>>.from(
            homeData['continue_learning'] ?? []);
        _quickAccessItems =
            List<Map<String, dynamic>>.from(homeData['quick_access'] ?? []);
        _storeCategories = storeCategories;
        _storeProducts = storeProducts;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    final statusBarHeight = MediaQuery.of(context).padding.top;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: _buildCategoryDrawer(isAr),
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(statusBarHeight, isAr),
              Expanded(
                child: _errorMessage != null
                    ? _buildErrorView(isAr)
                    : RefreshIndicator(
                        onRefresh: _loadHomeData,
                        color: AppColors.primary,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              HomeMediaBanner(
                                isAr: isAr,
                                mediaType: _resolveBannerType(),
                                mediaPath: _resolveBannerPath(),
                                isAsset: _resolveBannerIsAsset(),
                                badgeText: _resolveBannerBadge(isAr),
                                titleText: _resolveBannerTitle(isAr),
                                subtitleText: _resolveBannerSubtitle(isAr),
                                primaryButtonText:
                                    _resolveBannerPrimaryButtonText(isAr),
                                playButtonText:
                                    _resolveBannerPlayButtonText(isAr),
                                showPlayButton: _resolveBannerType() ==
                                    HomeBannerMediaType.video,
                                onTap: _onHeroBannerTap,
                              ),
                              const SizedBox(height: 24),
                              HomeQuickAccess(
                                isAr: isAr,
                                items: _quickAccessItems,
                              ),
                              const SizedBox(height: 20),
                              HomePlatformIntroCard(isAr: isAr),
                              const SizedBox(height: 24),
                              HomePromotionalOffersSection(isAr: isAr),
                              const SizedBox(height: 24),
                              if (_showProductCategoriesSection)
                                _buildProductCategoriesSection(isAr),
                              if (_showProductCategoriesSection)
                                const SizedBox(height: 24),
                              HomeFeaturedProductsSection(
                                isAr: isAr,
                                isLoading: _isLoading,
                                products: _getFeaturedProducts(),
                                onViewAllTap: () =>
                                    context.go(RouteNames.store),
                                onProductTap: (product) => context.push(
                                  RouteNames.productDetails,
                                  extra: product,
                                ),
                                onAddToCartTap: (product) {
                                  CartService.instance.addToCart(product);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isAr
                                            ? 'تمت إضافة المنتج إلى السلة'
                                            : 'Product added to cart',
                                      ),
                                      duration:
                                          const Duration(milliseconds: 1200),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 24),
                              HomeImplantCommunitySection(
                                isAr: isAr,
                                onViewAllTap: () =>
                                    context.push(RouteNames.community),
                              ),
                              const SizedBox(height: 24),
                              if (_featuredCourses.isNotEmpty || _isLoading)
                                _buildCoursesSection(isAr),
                              if (_continueLearning.isNotEmpty)
                                _buildContinueLearningSection(isAr),
                              if (_popularCourses.isNotEmpty || _isLoading)
                                _buildPopularCoursesSection(isAr),
                              const SizedBox(height: 140),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
          const BottomNav(activeTab: 'home'),
        ],
      ),
    );
  }

  Widget _buildHeader(double statusBarHeight, bool isAr) {
    final userName =
        _userProfile?['name']?.toString() ?? (isAr ? 'دكتور' : 'Doctor');
    final profilePending = _isLoading && _userProfile == null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: statusBarHeight + 12,
          bottom: 12,
          left: 20,
          right: 20,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isAr ? 'صباح الخير' : 'Good morning,',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Skeletonizer(
                    enabled: profilePending,
                    child: Text(
                      userName,
                      style: GoogleFonts.cairo(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.05,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => context.push(RouteNames.notifications),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE93A48),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    const Center(
                      child: Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    if (_notificationsCount > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFD235),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => context.go(RouteNames.dashboard),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE93A48),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  HomeBannerMediaType _resolveBannerType() {
    final type = _heroBanner?['media_type']?.toString().toLowerCase().trim();
    if (type == 'video') return HomeBannerMediaType.video;

    final videoUrl = _heroBanner?['video_url']?.toString();
    if (videoUrl != null && videoUrl.isNotEmpty) {
      return HomeBannerMediaType.video;
    }

    return HomeBannerMediaType.image;
  }

  String _resolveBannerPath() {
    final type = _resolveBannerType();
    if (type == HomeBannerMediaType.video) {
      final videoUrl = _heroBanner?['media_url']?.toString();
      if (videoUrl != null && videoUrl.isNotEmpty) return videoUrl;

      final fallbackVideoUrl = _heroBanner?['video_url']?.toString();
      if (fallbackVideoUrl != null && fallbackVideoUrl.isNotEmpty) {
        return fallbackVideoUrl;
      }
    } else {
      final mediaUrl = _heroBanner?['media_url']?.toString();
      if (mediaUrl != null && mediaUrl.isNotEmpty) return mediaUrl;

      final image = _heroBanner?['image']?.toString();
      if (image != null && image.isNotEmpty) return image;

      final backgroundImage = _heroBanner?['background_image']?.toString();
      if (backgroundImage != null && backgroundImage.isNotEmpty) {
        return backgroundImage;
      }
    }

    return 'assets/images/medex_hero.png';
  }

  bool _resolveBannerIsAsset() {
    final path = _resolveBannerPath().toLowerCase();
    return !(path.startsWith('http://') || path.startsWith('https://'));
  }

  String _pickLocalizedBannerValue({
    required bool isAr,
    required String baseKey,
    String? fallback,
  }) {
    final direct = _heroBanner?[baseKey];
    if (direct is String && direct.trim().isNotEmpty) return direct.trim();

    final localizedMap = _heroBanner?['${baseKey}_localized'];
    if (localizedMap is Map<String, dynamic>) {
      final localized =
          isAr ? localizedMap['ar']?.toString() : localizedMap['en']?.toString();
      if (localized != null && localized.trim().isNotEmpty) {
        return localized.trim();
      }
    }

    final langKey = isAr ? '${baseKey}_ar' : '${baseKey}_en';
    final langDynamicValue = _heroBanner?[langKey];
    final langValue = langDynamicValue?.toString();
    if (langValue != null && langValue.trim().isNotEmpty) {
      return langValue.trim();
    }

    final commonValue = _heroBanner?[baseKey]?.toString();
    if (commonValue != null && commonValue.trim().isNotEmpty) {
      return commonValue.trim();
    }

    return fallback ?? '';
  }

  String _resolveBannerBadge(bool isAr) {
    return _pickLocalizedBannerValue(
      isAr: isAr,
      baseKey: 'badge_text',
      fallback: 'MEDEX',
    );
  }

  String _resolveBannerTitle(bool isAr) {
    return _pickLocalizedBannerValue(
      isAr: isAr,
      baseKey: 'title',
      fallback: isAr
          ? 'فيديو ترحيبي سريع\nبتطبيق Medex'
          : 'Quick Welcome Video\nAbout Medex App',
    );
  }

  String _resolveBannerSubtitle(bool isAr) {
    return _pickLocalizedBannerValue(
      isAr: isAr,
      baseKey: 'subtitle',
      fallback: isAr
          ? 'شاهد فيديو قصير يعرّفك بخدمات ومزايا التطبيق'
          : 'Watch a short clip to discover app features',
    );
  }

  String _resolveBannerPrimaryButtonText(bool isAr) {
    return _pickLocalizedBannerValue(
      isAr: isAr,
      baseKey: 'primary_button_text',
      fallback: isAr ? 'شاهد الآن' : 'Watch Now',
    );
  }

  String _resolveBannerPlayButtonText(bool isAr) {
    return _pickLocalizedBannerValue(
      isAr: isAr,
      baseKey: 'play_button_text',
      fallback: isAr ? 'تشغيل' : 'Play',
    );
  }

  void _onHeroBannerTap() {
    // Backend can control banner destination through hero_banner.cta_route.
    final rawRoute = _heroBanner?['cta_route']?.toString().trim();
    final allowedRoutes = <String>{
      RouteNames.home,
      RouteNames.courses,
      RouteNames.progress,
      RouteNames.dashboard,
      RouteNames.allCourses,
      RouteNames.medexAcademy,
      RouteNames.medexOffers,
      RouteNames.clinicalCases,
      RouteNames.productLearningHub,
      RouteNames.eventsExhibitions,
      RouteNames.dentalChallenge,
      RouteNames.returnsExchanges,
      RouteNames.returnsPolicies,
      RouteNames.medexAiAssistant,
      RouteNames.community,
      RouteNames.implantCommunity,
      RouteNames.notifications,
    };

    final targetRoute = (rawRoute != null && allowedRoutes.contains(rawRoute))
        ? rawRoute
        : RouteNames.medexAcademy;
    context.go(targetRoute);
  }

  List<Product> _getFeaturedProducts() {
    var featuredProducts = _storeProducts
        .where((p) => (p.discount != null && p.discount! > 0) || p.isRentable)
        .take(6)
        .toList();
    if (featuredProducts.isEmpty && _storeProducts.isNotEmpty) {
      featuredProducts = _storeProducts.take(6).toList();
    }
    return featuredProducts;
  }

  Widget _buildProductCategoriesSection(bool isAr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          isAr ? 'تصنيفات المنتجات' : 'Product Categories',
          () => context.go(RouteNames.store),
          isAr,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 118,
          child: _isLoading
              ? Skeletonizer(
                  enabled: true,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      final colors = [
                        AppColors.primary,
                        AppColors.info,
                        AppColors.success,
                        AppColors.warning,
                        const Color(0xFF8B5CF6),
                      ];
                      final color = colors[index % colors.length];
                      return Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 8)
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.medical_services_rounded,
                                  color: color, size: 22),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                isAr ? 'تصنيف' : 'Category',
                                style: GoogleFonts.cairo(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.foreground),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Text(
                              '—',
                              style: GoogleFonts.cairo(
                                  fontSize: 9,
                                  color: AppColors.mutedForeground),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _storeCategories.length,
                  itemBuilder: (context, index) {
                    final category = _storeCategories[index];
                    final colors = [
                      AppColors.primary,
                      AppColors.info,
                      AppColors.success,
                      AppColors.warning,
                      const Color(0xFF8B5CF6),
                    ];
                    final color = colors[index % colors.length];
                    return GestureDetector(
                      onTap: () => context.push(
                          '${RouteNames.categoryProducts}?id=${category.id}'),
                      child: Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 8)
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.medical_services_rounded,
                                  color: color, size: 22),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                isAr ? category.nameAr : category.name,
                                style: GoogleFonts.cairo(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.foreground),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              category.origin,
                              style: GoogleFonts.cairo(
                                  fontSize: 9,
                                  color: AppColors.mutedForeground),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ignore: unused_element
  Widget _buildFeaturedProductsSection(bool isAr) {
    if (_isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            isAr ? 'منتجات مميزة' : 'Featured Products',
            () => context.go(RouteNames.store),
            isAr,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 236,
            child: Skeletonizer(
              enabled: true,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 4,
                itemBuilder: (context, index) {
                  return Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 110,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Brand',
                                style: GoogleFonts.cairo(
                                    fontSize: 9,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isAr ? 'اسم المنتج' : 'Product name',
                                style: GoogleFonts.cairo(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.foreground),
                                maxLines: 2,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isAr ? '٠ ج.م' : 'EGP 0',
                                style: GoogleFonts.cairo(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      );
    }

    // Only discounted (>0) or rentable items were shown before; most catalogs
    // have neither on every SKU, so the row looked empty while categories worked.
    var featuredProducts = _storeProducts
        .where((p) => (p.discount != null && p.discount! > 0) || p.isRentable)
        .take(6)
        .toList();
    if (featuredProducts.isEmpty && _storeProducts.isNotEmpty) {
      featuredProducts = _storeProducts.take(6).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          isAr ? 'منتجات مميزة' : 'Featured Products',
          () => context.go(RouteNames.store),
          isAr,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 236,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: featuredProducts.length,
            itemBuilder: (context, index) {
              final product = featuredProducts[index];
              return GestureDetector(
                onTap: () =>
                    context.push(RouteNames.productDetails, extra: product),
                child: Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: 110,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16)),
                            ),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16)),
                              child: Image.asset(
                                product.imageUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.medical_services_rounded,
                                  size: 40,
                                  color: AppColors.primary.withOpacity(0.2),
                                ),
                              ),
                            ),
                          ),
                          if (product.discount != null)
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '-${product.discount!.toInt()}%',
                                  style: GoogleFonts.cairo(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              product.brand,
                              style: GoogleFonts.cairo(
                                  fontSize: 9,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isAr ? product.nameAr : product.name,
                              style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.foreground),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isAr
                                  ? '${product.price.toInt()} ج.م'
                                  : 'EGP ${product.price.toInt()}',
                              style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCoursesSection(bool isAr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          isAr ? 'الدورات المميزة' : 'Featured Courses',
          () => context.push(RouteNames.allCourses),
          isAr,
        ),
        const SizedBox(height: 12),
        if (_isLoading)
          SizedBox(
            height: 288,
            child: Skeletonizer(
              enabled: true,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 3,
                itemBuilder: (context, index) => Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 288,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _featuredCourses.length,
              itemBuilder: (context, index) {
                final course = _featuredCourses[index];
                return Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 12),
                  child: PremiumCourseCard(
                    course: course,
                    onTap: () =>
                        context.push(RouteNames.courseDetails, extra: course),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildContinueLearningSection(bool isAr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          isAr ? 'أكمل التعلم' : 'Continue Learning',
          () => context.push(RouteNames.enrolled),
          isAr,
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount:
              _continueLearning.length > 3 ? 3 : _continueLearning.length,
          itemBuilder: (context, index) {
            final course = _continueLearning[index];
            final title = course['title']?.toString() ?? '';
            final progress = (course['progress'] as num?)?.toDouble() ?? 0;
            final imageUrl = course['thumbnail']?.toString() ??
                course['image']?.toString() ??
                '';

            return GestureDetector(
              onTap: () =>
                  context.push(RouteNames.courseDetails, extra: course),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.03), blurRadius: 8)
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                ApiEndpoints.getImageUrl(imageUrl),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                    Icons.school_rounded,
                                    color: AppColors.primary.withOpacity(0.3)),
                              )
                            : Icon(Icons.school_rounded,
                                color: AppColors.primary.withOpacity(0.3)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.foreground),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: progress / 100,
                                    backgroundColor: AppColors.muted,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            AppColors.primary),
                                    minHeight: 5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${progress.toInt()}%',
                                style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPopularCoursesSection(bool isAr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          isAr ? 'الدورات الشائعة' : 'Popular Courses',
          () => context.push(RouteNames.allCourses),
          isAr,
        ),
        const SizedBox(height: 12),
        if (_isLoading)
          SizedBox(
            height: 288,
            child: Skeletonizer(
              enabled: true,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 3,
                itemBuilder: (context, index) => Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 288,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _popularCourses.length,
              itemBuilder: (context, index) {
                final course = _popularCourses[index];
                return Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 12),
                  child: PremiumCourseCard(
                    course: course,
                    onTap: () =>
                        context.push(RouteNames.courseDetails, extra: course),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onViewAll, bool isAr) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.foreground),
          ),
          GestureDetector(
            onTap: onViewAll,
            child: Row(
              children: [
                Text(
                  isAr ? 'عرض الكل' : 'View All',
                  style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary),
                ),
                const SizedBox(width: 4),
                Icon(
                    isAr
                        ? Icons.arrow_back_ios_rounded
                        : Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppColors.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(bool isAr) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded,
              size: 64, color: AppColors.mutedForeground.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            isAr ? 'حدث خطأ في تحميل البيانات' : 'Error loading data',
            style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.mutedForeground),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadHomeData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(isAr ? 'إعادة المحاولة' : 'Retry',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDrawer(bool isAr) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFD42535), Color(0xFFB01E2D)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/medex_logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                            Icons.medical_services_rounded,
                            color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'MEDEX',
                    style: GoogleFonts.cairo(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2),
                  ),
                  Text(
                    isAr ? 'تصنيفات المنتجات' : 'Product Categories',
                    style: GoogleFonts.cairo(
                        fontSize: 13, color: Colors.white.withOpacity(0.8)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading && _storeCategories.isEmpty
                  ? Skeletonizer(
                      enabled: true,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: 8,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.medical_services_rounded,
                                  color: AppColors.primary, size: 18),
                            ),
                            title: Text(
                              isAr ? 'تصنيف' : 'Category',
                              style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.foreground),
                            ),
                            subtitle: Text(
                              '—',
                              style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  color: AppColors.mutedForeground),
                            ),
                          );
                        },
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _storeCategories.length,
                      itemBuilder: (context, index) {
                        final category = _storeCategories[index];
                        return ExpansionTile(
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.medical_services_rounded,
                                color: AppColors.primary, size: 18),
                          ),
                          title: Text(
                            isAr ? category.nameAr : category.name,
                            style: GoogleFonts.cairo(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.foreground),
                          ),
                          subtitle: Text(
                            category.origin,
                            style: GoogleFonts.cairo(
                                fontSize: 11, color: AppColors.mutedForeground),
                          ),
                          children: [
                            ...List.generate(category.subcategories.length,
                                (i) {
                              final subSlug = category.subcategories[i];
                              final label = isAr
                                  ? (i < category.subcategoriesAr.length
                                      ? category.subcategoriesAr[i]
                                      : subSlug)
                                  : subSlug;
                              return ListTile(
                                contentPadding:
                                    const EdgeInsets.only(left: 72, right: 16),
                                title: Text(
                                  label,
                                  style: GoogleFonts.cairo(
                                      fontSize: 13,
                                      color: AppColors.foreground),
                                ),
                                trailing: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 14,
                                    color: AppColors.mutedForeground),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  context.push(
                                    '${RouteNames.categoryProducts}?id=${category.id}&sub=${Uri.encodeComponent(subSlug)}',
                                  );
                                },
                              );
                            }),
                            ListTile(
                              contentPadding:
                                  const EdgeInsets.only(left: 72, right: 16),
                              title: Text(
                                isAr ? 'عرض المنتجات' : 'View Products',
                                style: GoogleFonts.cairo(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary),
                              ),
                              trailing: Icon(Icons.arrow_forward_rounded,
                                  size: 18, color: AppColors.primary),
                              onTap: () {
                                Navigator.of(context).pop();
                                context.push(
                                    '${RouteNames.categoryProducts}?id=${category.id}');
                              },
                            ),
                          ],
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.push(RouteNames.orders);
                      },
                      icon: const Icon(Icons.receipt_long_rounded, size: 18),
                      label: Text(isAr ? 'طلباتي' : 'My Orders',
                          style:
                              GoogleFonts.cairo(fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(
                            color: AppColors.primary.withOpacity(0.3)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.push(RouteNames.contactUs);
                      },
                      icon: const Icon(Icons.headset_mic_rounded, size: 18),
                      label: Text(isAr ? 'تواصل معنا' : 'Contact Us',
                          style:
                              GoogleFonts.cairo(fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.mutedForeground,
                        side: BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
}
