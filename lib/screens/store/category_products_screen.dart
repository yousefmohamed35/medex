import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design/app_colors.dart';
import '../../core/navigation/route_names.dart';
import '../../models/product.dart';
import '../../services/store_service.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String? categoryId;
  final String? subcategory;

  const CategoryProductsScreen({super.key, this.categoryId, this.subcategory});

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  ProductCategory? _category;
  List<Product> _products = [];
  bool _isLoading = true;
  String? _error;

  String _norm(String s) => s.trim().toLowerCase();

  bool _sameSubcategory(Product p, String subcategoryEn) {
    final n = _norm(subcategoryEn);
    return _norm(p.category) == n || _norm(p.categoryAr) == n;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(CategoryProductsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categoryId != widget.categoryId ||
        oldWidget.subcategory != widget.subcategory) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final id = widget.categoryId?.trim();
      if (id == null || id.isEmpty) {
        throw Exception('Missing category id');
      }

      final categories = await StoreService.instance.getCategories();
      ProductCategory? selected;
      for (final c in categories) {
        if (c.id == id) {
          selected = c;
          break;
        }
      }
      if (selected == null) {
        if (!mounted) return;
        setState(() {
          _category = null;
          _products = [];
          _error = 'Category not found';
        });
        return;
      }

      final brand = selected.brand.isNotEmpty ? selected.brand : null;
      final sub = widget.subcategory;

      List<Product> products = await StoreService.instance.getAllProducts(
        categoryId: id,
        subcategory: sub,
        brand: brand,
      );

      if (products.isEmpty && brand != null) {
        final byBrand =
            await StoreService.instance.getAllProducts(brand: brand);
        if (sub != null && sub.isNotEmpty) {
          products = byBrand.where((p) => _sameSubcategory(p, sub)).toList();
        } else {
          products = byBrand;
        }
      }

      if (!mounted) return;
      setState(() {
        _category = selected;
        _products = products;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
          body: Center(
              child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(_error!, textAlign: TextAlign.center),
      )));
    }
    final category = _category;
    if (category == null || category.id.isEmpty) {
      return const Scaffold(body: Center(child: Text('Category not found')));
    }

    final products = _products;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFD42535), Color(0xFFB01E2D)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 24,
              left: 16,
              right: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 18),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAr ? category.nameAr : category.name,
                            style: GoogleFonts.cairo(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          Text(
                            widget.subcategory ?? category.origin,
                            style: GoogleFonts.cairo(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.8)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (widget.subcategory == null)
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  _buildSubCatChip(context, isAr ? 'الكل' : 'All', true, () {
                    // Already showing all
                  }),
                  ...List.generate(category.subcategories.length, (i) {
                    return _buildSubCatChip(
                      context,
                      isAr
                          ? category.subcategoriesAr[i]
                          : category.subcategories[i],
                      false,
                      () {
                        context.push(
                          '${RouteNames.categoryProducts}?id=${Uri.encodeComponent(category.id)}&sub=${Uri.encodeComponent(category.subcategories[i])}',
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          Expanded(
            child: products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_rounded,
                            size: 60,
                            color: AppColors.mutedForeground.withOpacity(0.3)),
                        const SizedBox(height: 12),
                        Text(
                          isAr
                              ? 'لا توجد منتجات في هذا التصنيف'
                              : 'No products in this category',
                          style: GoogleFonts.cairo(
                              fontSize: 16, color: AppColors.mutedForeground),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.68,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return _buildProductCard(context, product, isAr);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubCatChip(
      BuildContext context, String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border),
          ),
          child: Text(
            label,
            style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.foreground),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product, bool isAr) {
    return GestureDetector(
      onTap: () => context.push(RouteNames.productDetails, extra: product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.asset(
                  product.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                      Icons.medical_services_rounded,
                      size: 48,
                      color: AppColors.primary.withOpacity(0.3)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.brand,
                    style: GoogleFonts.cairo(
                        fontSize: 10,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isAr ? product.nameAr : product.name,
                    style: GoogleFonts.cairo(
                        fontSize: 12,
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
                        fontSize: 14,
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
  }
}
