import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/design/app_colors.dart';
import '../../core/navigation/route_names.dart';
import '../../models/product.dart';
import '../../services/store_service.dart';
import '../../widgets/bottom_nav.dart';

class ProductCategoriesScreen extends StatefulWidget {
  const ProductCategoriesScreen({super.key});

  @override
  State<ProductCategoriesScreen> createState() =>
      _ProductCategoriesScreenState();
}

class _ProductCategoriesScreenState extends State<ProductCategoriesScreen> {
  static const String _logName = 'ProductCategoriesScreen';

  int _selectedIndex = 0;
  List<ProductCategory> _categories = [];
  List<Product> _products = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      log('request GET ${ApiEndpoints.storeCategories}', name: _logName);
      final categories = await StoreService.instance.getCategories();
      log(
        'response GET ${ApiEndpoints.storeCategories}: '
        '${categories.length} categories',
        name: _logName,
      );

      log(
        'request getAllProducts (paginated GET ${ApiEndpoints.storeProducts})',
        name: _logName,
      );
      final products = await StoreService.instance.getAllProducts(perPage: 100);
      log(
        'response getAllProducts: ${products.length} products (all pages)',
        name: _logName,
      );

      if (!mounted) return;
      setState(() {
        _categories = categories;
        _products = products;
      });
    } catch (e, st) {
      log('store load failed', name: _logName, error: e, stackTrace: st);
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'precision_manufacturing':
        return Icons.precision_manufacturing_rounded;
      case 'medical_services':
        return Icons.medical_services_rounded;
      case 'health_and_safety':
        return Icons.health_and_safety_rounded;
      case 'biotech':
        return Icons.biotech_rounded;
      case 'science':
        return Icons.science_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  /// Catalog strings from the API often differ by case or EN/AR; match loosely.
  bool _sameBrand(Product p, ProductCategory category) =>
      _norm(p.brand) == _norm(category.brand);

  bool _sameSubcategory(Product p, String subcategoryEn) {
    final n = _norm(subcategoryEn);
    return _norm(p.category) == n || _norm(p.categoryAr) == n;
  }

  String _norm(String s) => s.trim().toLowerCase();

  int _getProductCount(ProductCategory category, String subcategory) {
    return _products
        .where(
            (p) => _sameBrand(p, category) && _sameSubcategory(p, subcategory))
        .length;
  }

  int _getCategoryProductCount(ProductCategory category) {
    return _products.where((p) => _sameBrand(p, category)).length;
  }

  IconData _getSubcategoryIcon(String subcategory) {
    final lower = subcategory.toLowerCase();
    if (lower.contains('implant') && lower.contains('system'))
      return Icons.settings_suggest_rounded;
    if (lower.contains('implant') || lower.contains('fixture'))
      return Icons.push_pin_rounded;
    if (lower.contains('abutment')) return Icons.architecture_rounded;
    if (lower.contains('digital')) return Icons.computer_rounded;
    if (lower.contains('surgical') && lower.contains('kit'))
      return Icons.medical_services_rounded;
    if (lower.contains('surgical') || lower.contains('tool'))
      return Icons.build_rounded;
    if (lower.contains('multi')) return Icons.hub_rounded;
    if (lower.contains('healing')) return Icons.healing_rounded;
    if (lower.contains('impression')) return Icons.content_copy_rounded;
    if (lower.contains('membrane') ||
        lower.contains('bone') ||
        lower.contains('graft') ||
        lower.contains('allograft')) return Icons.science_rounded;
    return Icons.inventory_2_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(_error!, textAlign: TextAlign.center),
          ),
        ),
      );
    }
    if (_categories.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No categories found')),
      );
    }
    final selectedCategory = _categories[_selectedIndex];
    final subs = isAr
        ? selectedCategory.subcategoriesAr
        : selectedCategory.subcategories;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            Column(
              children: [
                // Header
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFD42535), Color(0xFFB01E2D)],
                    ),
                  ),
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 12,
                    bottom: 16,
                    left: 16,
                    right: 16,
                  ),
                  child: Column(
                    children: [
                      // Search bar
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                isAr ? 'ابحث...' : 'Search...',
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ),
                            Container(
                              width: 36,
                              height: 36,
                              margin: const EdgeInsets.only(left: 4, right: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.search_rounded,
                                  color: AppColors.primary, size: 20),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Body: sidebar + content
                Expanded(
                  child: Row(
                    children: [
                      // Left sidebar
                      Container(
                        width: 90,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            right: isAr
                                ? BorderSide.none
                                : BorderSide(color: Colors.grey.shade200),
                            left: isAr
                                ? BorderSide(color: Colors.grey.shade200)
                                : BorderSide.none,
                          ),
                        ),
                        child: ListView.builder(
                          padding: const EdgeInsets.only(top: 8, bottom: 120),
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            final cat = _categories[index];
                            final isSelected = index == _selectedIndex;
                            return GestureDetector(
                              onTap: () {
                                log(
                                  'sidebar: ${cat.name} (no HTTP; data filtered '
                                  'from loaded products)',
                                  name: _logName,
                                );
                                setState(() => _selectedIndex = index);
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 3),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary.withOpacity(0.08)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: isSelected
                                      ? Border(
                                          right: isAr
                                              ? BorderSide.none
                                              : const BorderSide(
                                                  color: AppColors.primary,
                                                  width: 3),
                                          left: isAr
                                              ? const BorderSide(
                                                  color: AppColors.primary,
                                                  width: 3)
                                              : BorderSide.none,
                                        )
                                      : null,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.primary
                                                .withOpacity(0.12)
                                            : Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(
                                        _getCategoryIcon(cat.iconName),
                                        size: 24,
                                        color: isSelected
                                            ? AppColors.primary
                                            : Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 2),
                                      child: Text(
                                        isAr ? cat.nameAr : cat.name,
                                        style: GoogleFonts.cairo(
                                          fontSize: 10,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w600,
                                          color: isSelected
                                              ? AppColors.primary
                                              : Colors.grey[700],
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Right content area
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 120),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Category title + "All Products" link
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 16, 16, 4),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        isAr
                                            ? selectedCategory.nameAr
                                            : selectedCategory.name,
                                        style: GoogleFonts.cairo(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.foreground,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        context.push(
                                          '${RouteNames.categoryProducts}?id=${Uri.encodeComponent(selectedCategory.id)}',
                                        );
                                      },
                                      child: Text(
                                        isAr ? 'كل المنتجات' : 'All Products',
                                        style: GoogleFonts.cairo(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                child: Text(
                                  '${selectedCategory.origin} • ${_getCategoryProductCount(selectedCategory)} ${isAr ? 'منتج' : 'products'}',
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ),

                              // Subcategories grid
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 1.0,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                  ),
                                  itemCount: subs.length,
                                  itemBuilder: (context, index) {
                                    final sub = subs[index];
                                    final subEn =
                                        selectedCategory.subcategories[index];
                                    final count = _getProductCount(
                                        selectedCategory, subEn);

                                    return GestureDetector(
                                      onTap: () {
                                        context.push(
                                          '${RouteNames.categoryProducts}?id=${Uri.encodeComponent(selectedCategory.id)}&sub=${Uri.encodeComponent(subEn)}',
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.04),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 56,
                                              height: 56,
                                              decoration: BoxDecoration(
                                                color: AppColors.primary
                                                    .withOpacity(0.08),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: Icon(
                                                _getSubcategoryIcon(subEn),
                                                size: 28,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8),
                                              child: Text(
                                                sub,
                                                style: GoogleFonts.cairo(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.foreground,
                                                ),
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (count > 0) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                '$count ${isAr ? 'منتج' : 'items'}',
                                                style: GoogleFonts.cairo(
                                                  fontSize: 10,
                                                  color: Colors.grey[500],
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Featured products from this category
                              _buildFeaturedProducts(selectedCategory, isAr),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            BottomNav(activeTab: 'store'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedProducts(ProductCategory category, bool isAr) {
    final products =
        _products.where((p) => _sameBrand(p, category)).take(4).toList();

    if (products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isAr ? 'منتجات مميزة' : 'Featured Products',
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.foreground,
                ),
              ),
            ],
          ),
        ),
        ...products.map((product) => _buildProductListItem(product, isAr)),
      ],
    );
  }

  Widget _buildProductListItem(Product product, bool isAr) {
    return GestureDetector(
      onTap: () => context.push(RouteNames.productDetails, extra: product),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  product.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.medical_services_rounded,
                    size: 24,
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAr ? product.nameAr : product.name,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.foreground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isAr ? product.categoryAr : product.category,
                    style: GoogleFonts.cairo(
                        fontSize: 10, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${product.price.toInt()} ${isAr ? 'ج.م' : 'EGP'}',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                if (product.discount != null && product.discount! > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '-${product.discount!.toInt()}%',
                      style: GoogleFonts.cairo(
                          fontSize: 10,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
