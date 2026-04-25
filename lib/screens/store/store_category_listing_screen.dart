import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/design/app_colors.dart';
import '../../core/navigation/route_names.dart';
import '../../data/sample_products.dart';
import '../../models/product.dart';
import '../../services/cart_service.dart';
import '../../services/store_service.dart';
import '../../widgets/bottom_nav.dart';

/// Store “all categories” product list: red app bar, brand rail, category header,
/// scrollable products (matches Medex Store category mock).
class StoreCategoryListingScreen extends StatefulWidget {
  const StoreCategoryListingScreen({
    super.key,
    required this.initialBrandRail,
    required this.categoryTitle,
    this.showAllProductsInSection = false,
  });

  final int initialBrandRail;
  final String categoryTitle;

  /// When true, list every product for the selected brand rail (all categories).
  final bool showAllProductsInSection;

  @override
  State<StoreCategoryListingScreen> createState() =>
      _StoreCategoryListingScreenState();
}

class _StoreCategoryListingScreenState extends State<StoreCategoryListingScreen> {
  late int _railIndex;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _loadingProducts = true;
  List<Product> _mergedProducts = [];

  /// Same order and semantics as [StoreScreen] side rail.
  static const List<_ListingRail> _rails = [
    _ListingRail('B&B Dental', Icons.widgets_outlined),
    _ListingRail('Macros Implants', Icons.event_outlined),
    _ListingRail('Powerbone', Icons.shield_outlined),
    _ListingRail('MCTBIO Implant', Icons.adjust_rounded),
    _ListingRail('Biomaterials', Icons.sync_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _railIndex = widget.initialBrandRail.clamp(0, _rails.length - 1);
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final api = await StoreService.instance.getProducts(perPage: 100);
      if (!mounted) return;
      final byId = <String, Product>{};
      for (final p in SampleProducts.products) {
        byId[p.id] = p;
      }
      for (final p in api) {
        byId[p.id] = p;
      }
      setState(() {
        _mergedProducts = byId.values.toList();
        _loadingProducts = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _mergedProducts = List<Product>.from(SampleProducts.products);
        _loadingProducts = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _canon(String s) =>
      s.replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();

  bool _brandMatches(Product p, int rail) {
    final b = p.brand.toLowerCase().trim();
    if (b.isEmpty) return true;
    switch (rail) {
      case 0:
        return b.contains('b&b') || b.contains('bb');
      case 1:
        return b.contains('macros');
      case 2:
        return b.contains('powerbone');
      case 3:
        return b.contains('mctbio');
      case 4:
        return b.contains('biomaterial') ||
            b.contains('graft') ||
            b.contains('regenerative') ||
            b.contains('dora') ||
            b.contains('osseo');
      default:
        return false;
    }
  }

  bool _categoryMatches(Product p) {
    if (widget.showAllProductsInSection) return true;
    final want = _canon(widget.categoryTitle.replaceAll('\n', ' '));
    if (want.isEmpty) return true;
    final c = _canon(p.category);
    final ca = _canon(p.categoryAr);
    return c == want || ca == want || c.contains(want) || want.contains(c);
  }

  List<Product> get _filtered {
    final source =
        _mergedProducts.isEmpty ? SampleProducts.products : _mergedProducts;
    final q = _searchQuery.trim().toLowerCase();
    return source.where((p) {
      if (!_brandMatches(p, _railIndex) || !_categoryMatches(p)) return false;
      if (q.isEmpty) return true;
      final name = '${p.name} ${p.nameAr}'.toLowerCase();
      return name.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final products = _filtered;
    final categoryTitle = widget.showAllProductsInSection
        ? (isAr ? 'كل المنتجات' : 'All products')
        : widget.categoryTitle.replaceAll('\n', ' ').trim();

    return Scaffold(
      backgroundColor: const Color(0xFFE9EBF0),
      body: Stack(
        children: [
          Column(
            children: [
              _buildTopBar(isAr),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildBrandRail(isAr),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildListHeader(context, isAr, categoryTitle,
                              products.length),
                          Expanded(
                            child: _loadingProducts
                                ? const Center(child: CircularProgressIndicator())
                                : products.isEmpty
                                    ? Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(24),
                                          child: Text(
                                            isAr
                                                ? (widget.showAllProductsInSection
                                                    ? 'لا توجد منتجات في هذا القسم'
                                                    : 'لا توجد منتجات في هذا التصنيف')
                                                : (widget.showAllProductsInSection
                                                    ? 'No products in this section'
                                                    : 'No products in this category'),
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.cairo(
                                              fontSize: 15,
                                              color: const Color(0xFF667085),
                                            ),
                                          ),
                                        ),
                                      )
                                    : ListView.separated(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 8, 10, 100),
                                        itemCount: products.length,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(height: 8),
                                        itemBuilder: (context, i) =>
                                            _buildProductRow(
                                                context, products[i], isAr),
                                      ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const BottomNav(activeTab: 'store'),
        ],
      ),
    );
  }

  Widget _buildTopBar(bool isAr) {
    return ListenableBuilder(
      listenable: CartService.instance,
      builder: (context, _) {
        return Container(
          decoration: const BoxDecoration(color: AppColors.primary),
          padding: EdgeInsets.fromLTRB(
            10,
            MediaQuery.paddingOf(context).top + 8,
            10,
            10,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => context.go(RouteNames.home),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF43446),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.home_outlined,
                    color: Colors.white,
                    size: 21,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF43446),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    cursorColor: Colors.white,
                    style: GoogleFonts.cairo(
                      color: const Color(0xFF6D7E86),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          isAr ? 'ابحث عن المنتجات...' : 'Search products...',
                      hintStyle: GoogleFonts.cairo(
                        color: const Color(0xFF6D7E86),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.only(top: 10),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFFF0EDED),
                        size: 20,
                      ),
                      prefixIconConstraints: const BoxConstraints(
                          minWidth: 42, minHeight: 44),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => context.push(RouteNames.cart),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF43446),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shopping_cart_outlined,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    if (CartService.instance.itemCount > 0)
                      Positioned(
                        top: -3,
                        right: -2,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFE219),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${CartService.instance.itemCount}',
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF1E1E1E),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBrandRail(bool isAr) {
    return Container(
      width: 64,
      decoration: const BoxDecoration(
        color: Color(0xFFF3F4F7),
        border: Border(
          right: BorderSide(color: Color(0xFFE4E7EC)),
        ),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 12, bottom: 100),
        itemCount: _rails.length,
        itemBuilder: (context, index) {
          final item = _rails[index];
          final active = _railIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _railIndex = index),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
              decoration: BoxDecoration(
                color: active ? const Color(0xFFFFF0F1) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: BorderDirectional(
                  end: BorderSide(
                    color: active ? AppColors.primary : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(
                      item.icon,
                      size: 18,
                      color: active
                          ? AppColors.primary
                          : const Color(0xFF5E6470),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isAr ? _railAr(item.label) : item.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: active
                          ? AppColors.primary
                          : const Color(0xFF313741),
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _railAr(String label) {
    if (label.contains('B&B')) return 'بي آند بي';
    if (label.contains('Macros')) return 'ماكروز';
    if (label.contains('Powerbone')) return 'باوربون';
    if (label.contains('MCTBIO')) return 'إم سي تي بايو';
    if (label.contains('Biomaterials')) return 'مواد حيوية';
    return label;
  }

  Widget _buildListHeader(
    BuildContext context,
    bool isAr,
    String categoryTitle,
    int count,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 10, 8, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  if (Navigator.of(context).canPop()) {
                    context.pop();
                  } else {
                    context.go(RouteNames.store);
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.only(top: 2, left: 4, right: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        isAr ? 'رجوع' : 'Back',
                        style: GoogleFonts.cairo(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  categoryTitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF101828),
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isAr ? 'عوامل التصفية قريباً' : 'Filters coming soon',
                        style: GoogleFonts.cairo(),
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF344054),
                  side: const BorderSide(color: Color(0xFFD0D5DD)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.filter_list_rounded, size: 18),
                label: Text(
                  isAr ? 'تصفية' : 'Filter',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isAr ? '$count منتج' : '$count Products',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 12.5,
              color: const Color(0xFF667085),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _openProductDetail(BuildContext context, Product p) {
    context.push(RouteNames.productDetails, extra: p);
  }

  bool _isNetworkImage(String path) {
    final x = path.toLowerCase();
    return x.startsWith('http://') || x.startsWith('https://');
  }

  Widget _buildProductRow(BuildContext context, Product p, bool isAr) {
    final name = isAr ? p.nameAr : p.name;
    final egp = NumberFormat('#,###', 'en_US').format(p.price.toInt());
    final priceStr = isAr ? '$egp ج.م' : 'EGP $egp';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 0,
      shadowColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE4E7EC)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            _productThumbTapTarget(context, p),
            const SizedBox(width: 10),
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _openProductDetail(context, p),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF101828),
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          p.isAvailable
                              ? (isAr ? 'متوفر' : 'In Stock')
                              : (isAr ? 'غير متوفر' : 'Out of Stock'),
                          style: GoogleFonts.cairo(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: p.isAvailable
                                ? const Color(0xFF16A34A)
                                : const Color(0xFF9CA3AF),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          priceStr,
                          style: GoogleFonts.cairo(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Material(
              color: const Color(0xFFFFF0F1),
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: () {
                  if (!p.isAvailable) return;
                  CartService.instance.addToCart(p, isRental: false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isAr ? 'تمت الإضافة إلى السلة' : 'Added to cart',
                        style: GoogleFonts.cairo(),
                      ),
                      duration: const Duration(milliseconds: 900),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 38,
                  height: 38,
                  child: Icon(
                    Icons.add_rounded,
                    color: p.isAvailable
                        ? AppColors.primary
                        : const Color(0xFFCBD5E1),
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  /// Tapping the list thumbnail opens the full product detail (large image) screen.
  Widget _productThumbTapTarget(BuildContext context, Product p) {
    return Hero(
      tag: 'store_product_image_${p.id}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openProductDetail(context, p),
          borderRadius: BorderRadius.circular(12),
          child: _productThumbVisual(p),
        ),
      ),
    );
  }

  Widget _productThumbVisual(Product p) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EAEF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD0D5DD)),
      ),
      clipBehavior: Clip.antiAlias,
      child: _thumbImageOrPlaceholder(p),
    );
  }

  Widget _thumbImageOrPlaceholder(Product p) {
    if (_isNetworkImage(p.imageUrl)) {
      return Image.network(
        p.imageUrl,
        fit: BoxFit.cover,
        width: 56,
        height: 56,
        errorBuilder: (_, __, ___) => Center(child: _listRingPlaceholder()),
      );
    }
    return Image.asset(
      p.imageUrl,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Center(child: _listRingPlaceholder()),
    );
  }

  /// Matches list-card mock: red outer ring, grey inner disc.
  Widget _listRingPlaceholder() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 3),
          ),
        ),
        Container(
          width: 16,
          height: 16,
          decoration: const BoxDecoration(
            color: Color(0xFFC8CDD4),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}

class _ListingRail {
  const _ListingRail(this.label, this.icon);
  final String label;
  final IconData icon;
}
