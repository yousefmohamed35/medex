import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design/app_colors.dart';
import '../../core/navigation/route_names.dart';
import '../../data/sample_products.dart';
import '../../models/product.dart';
import '../../services/cart_service.dart';
import '../../services/store_service.dart';
import '../../widgets/bottom_nav.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final _searchController = TextEditingController();
  bool _isLoading = true;
  String? _apiError;
  List<Product> _apiProducts = [];
  String _searchQuery = '';
  int _selectedRailIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadStoreData();
  }

  Future<void> _loadStoreData() async {
    setState(() {
      _isLoading = true;
      _apiError = null;
    });
    try {
      final results = await Future.wait([
        StoreService.instance.getCategories(),
        StoreService.instance.getProducts(perPage: 20),
      ]);
      if (!mounted) return;
      setState(() {
        // Keep categories request active for backend verification/logging,
        // even though the UI now derives visible categories from product data.
        final _ = results[0] as List<ProductCategory>;
        _apiProducts = results[1] as List<Product>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _apiError = e.toString();
        _isLoading = false;
      });
    }
  }

  _StoreSectionData get _activeSection => _storeSections[_selectedRailIndex];

  List<Product> get _railProducts {
    if (_apiProducts.isEmpty) return const [];
    return _apiProducts.where((p) {
      if (p.brand.trim().isEmpty) return true;
      return _matchesSelectedRailBrand(p.brand);
    }).toList();
  }

  bool _matchesSelectedRailBrand(String rawBrand) {
    final brand = rawBrand.toLowerCase().trim();
    switch (_selectedRailIndex) {
      case 0:
        return brand.contains('b&b') || brand.contains('bb');
      case 1:
        return brand.contains('macros');
      case 2:
        return brand.contains('powerbone');
      case 3:
        return brand.contains('mctbio');
      case 4:
        return brand.contains('biomaterial') ||
            brand.contains('graft') ||
            brand.contains('regenerative');
      default:
        return true;
    }
  }

  List<_StoreFeaturedProduct> get _activeFeaturedProducts {
    if (_railProducts.isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      final filtered = q.isEmpty
          ? _railProducts
          : _railProducts
              .where((p) =>
                  p.name.toLowerCase().contains(q) ||
                  p.nameAr.toLowerCase().contains(q))
              .toList();
      return filtered
          .take(6)
          .map(
            (p) => _StoreFeaturedProduct(
              productId: p.id,
              name: p.name,
              price: p.price.toStringAsFixed(0),
              inStock: p.isAvailable,
            ),
          )
          .toList();
    }
    // Fallback featured picks for current hardcoded brand section.
    return _activeSection.featuredProducts;
  }

  List<_StoreCategoryCardData> get _visibleCategories {
    if (_railProducts.isNotEmpty) {
      final map = <String, int>{};
      for (final p in _railProducts) {
        final key = p.category.trim().isEmpty ? 'General' : p.category.trim();
        map[key] = (map[key] ?? 0) + 1;
      }
      final q = _searchQuery.trim().toLowerCase();
      final mapped = map.entries
          .map(
            (e) => _StoreCategoryCardData(
              title: e.key,
              itemsCount: e.value,
              icon: Icons.category_outlined,
            ),
          )
          .toList()
        ..sort((a, b) => a.title.compareTo(b.title));
      if (q.isEmpty) return mapped;
      return mapped
          .where((c) => c.title.toLowerCase().replaceAll('\n', ' ').contains(q))
          .toList();
    }
    final list = _activeSection.categories;
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return list;
    return list
        .where((c) =>
            c.title.toLowerCase().replaceAll('\n', ' ').contains(q))
        .toList();
  }

  String _normalizeCategoryTitle(String title) =>
      title.replaceAll('\n', ' ').trim();

  void _openCategoryListing(String categoryTitle) {
    final cat = Uri.encodeComponent(_normalizeCategoryTitle(categoryTitle));
    context.push(
      '${RouteNames.storeCategoryListing}?brand=$_selectedRailIndex&cat=$cat',
    );
  }

  void _openDefaultCategoryListing() {
    context.push(
      '${RouteNames.storeCategoryListing}?brand=$_selectedRailIndex&all=1',
    );
  }

  Product? _productById(String id) {
    for (final p in _apiProducts) {
      if (p.id == id) return p;
    }
    for (final p in SampleProducts.products) {
      if (p.id == id) return p;
    }
    return null;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      backgroundColor: const Color(0xFFE9EBF0),
      body: Stack(
        children: [
          Column(
            children: [
              _buildTopBar(isAr),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: _loadStoreData,
                        color: AppColors.primary,
                        child: Row(
                          children: [
                            _buildLeftRail(isAr),
                            Expanded(child: _buildRightPanel(isAr)),
                          ],
                        ),
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
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
      ),
      padding: const EdgeInsets.fromLTRB(10, 36, 10, 10),
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
                  hintText: isAr ? 'ابحث عن المنتجات...' : 'Search products...',
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
                  prefixIconConstraints:
                      const BoxConstraints(minWidth: 42, minHeight: 44),
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
  }

  Widget _buildLeftRail(bool isAr) {
    final items = _storeSections
        .map((s) => _RailItem(icon: s.railIcon, label: s.title))
        .toList();
    return Container(
      width: 64,
      color: const Color(0xFFF3F4F7),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final isActive = _selectedRailIndex == index;
          return GestureDetector(
            onTap: () => setState(() {
              _selectedRailIndex = index;
            }),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 3),
              decoration: BoxDecoration(
                color: isActive ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: isActive
                    ? Border.all(color: const Color(0xFFE2E4EA))
                    : null,
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
                      color: const Color(0xFF5E6470),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isAr ? _toArLabel(item.label) : item.label,
                    style: GoogleFonts.cairo(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? AppColors.primary
                          : const Color(0xFF313741),
                      height: 1.1,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _toArLabel(String label) {
    if (label == 'B&B') return 'بي آند بي';
    if (label.toLowerCase().contains('macros')) return 'ماكروز';
    if (label.toLowerCase().contains('powerbone')) return 'باوربون';
    if (label.toLowerCase().contains('mctbio')) return 'إم سي تي بايو';
    if (label.toLowerCase().contains('biomaterials')) return 'المواد الحيوية/التجديد';
    return label;
  }

  Widget _buildRightPanel(bool isAr) {
    final section = _activeSection;
    final categories = _visibleCategories;
    final featured = _activeFeaturedProducts;
    return Container(
      color: const Color(0xFFE9EBF0),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_apiError != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFFCDD2)),
                ),
                child: Text(
                  _apiError!.replaceFirst('Exception: ', ''),
                  style: GoogleFonts.cairo(
                    fontSize: 11.5,
                    color: const Color(0xFFB71C1C),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _openDefaultCategoryListing,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFDADDE5)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              section.title,
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                                '${section.country} · ${_railProducts.isNotEmpty ? _railProducts.length : section.totalProducts} Products · ${categories.length} Categories',
                              style: GoogleFonts.cairo(
                                fontSize: 11.5,
                                color: const Color(0xFF7D8391),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        isAr ? 'كل المنتجات >' : 'All Products >',
                        style: GoogleFonts.cairo(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isAr ? '| التصنيفات' : '| CATEGORIES',
              style: GoogleFonts.cairo(
                color: const Color(0xFF485064),
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                fontSize: 13.5,
              ),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.05,
              ),
              itemBuilder: (context, index) {
                final c = categories[index];
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _openCategoryListing(c.title),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F3F6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFD7DAE2)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.07),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              c.icon,
                              color: AppColors.primary,
                              size: 21,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            c.title,
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            isAr
                                ? '${c.itemsCount} منتج'
                                : '${c.itemsCount} Items',
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              color: const Color(0xFF98A0AE),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            if (categories.isEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDADDE5)),
                ),
                child: Text(
                  isAr
                      ? 'لا توجد تصنيفات متاحة لهذا القسم حالياً.'
                      : 'No categories available for this section yet.',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: const Color(0xFF667085),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Text(
              isAr ? '| المنتجات المميزة' : '| FEATURED PRODUCTS',
              style: GoogleFonts.cairo(
                color: const Color(0xFF485064),
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                fontSize: 13.5,
              ),
            ),
            const SizedBox(height: 8),
            ...featured.map((p) => _buildFeaturedTile(p, isAr)),
            if (featured.isEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 2),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDADDE5)),
                ),
                child: Text(
                  isAr
                      ? 'لا توجد منتجات مطابقة حالياً. جرّب اختيار "كل المنتجات".'
                      : 'No matching products right now. Try selecting "All Products".',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: const Color(0xFF667085),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedTile(_StoreFeaturedProduct f, bool isAr) {
    final product = _productById(f.productId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (product == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isAr ? 'المنتج غير متوفر' : 'Product unavailable',
                    style: GoogleFonts.cairo(),
                  ),
                ),
              );
              return;
            }
            context.push(RouteNames.productDetails, extra: product);
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD7DAE2)),
            ),
            child: Row(
              children: [
                _featuredThumb(product),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        f.name,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        f.inStock
                            ? (isAr ? 'متوفر' : 'In Stock')
                            : (isAr ? 'غير متوفر' : 'Out of Stock'),
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: f.inStock
                              ? const Color(0xFF17A34A)
                              : const Color(0xFF9CA3AF),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'EGP ${f.price}',
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                Material(
                  color: const Color(0xFFFFF0F1),
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      if (product == null || !product.isAvailable) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: const Duration(milliseconds: 900),
                            content: Text(
                              isAr
                                  ? 'لا يمكن إضافة هذا المنتج'
                                  : 'This product cannot be added',
                              style: GoogleFonts.cairo(),
                            ),
                          ),
                        );
                        return;
                      }
                      CartService.instance.addToCart(product, isRental: false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(milliseconds: 900),
                          content: Text(
                            isAr ? 'تمت الإضافة للسلة' : 'Added to cart',
                            style: GoogleFonts.cairo(),
                          ),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: Icon(
                        Icons.add_rounded,
                        color: product != null && product.isAvailable
                            ? AppColors.primary
                            : const Color(0xFFCBD5E1),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _featuredThumb(Product? product) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EAEF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD0D5DD)),
      ),
      clipBehavior: Clip.antiAlias,
      child: product == null
          ? const Center(
              child: Icon(Icons.image_not_supported_outlined,
                  size: 20, color: Color(0xFF98A2B3)),
            )
          : _featuredThumbImage(product),
    );
  }

  bool _isNetworkImage(String path) {
    final x = path.toLowerCase();
    return x.startsWith('http://') || x.startsWith('https://');
  }

  Widget _featuredThumbImage(Product product) {
    if (_isNetworkImage(product.imageUrl)) {
      return Image.network(
        product.imageUrl,
        fit: BoxFit.cover,
        width: 46,
        height: 46,
        errorBuilder: (_, __, ___) => Center(child: _featuredRing()),
      );
    }
    return Image.asset(
      product.imageUrl,
      fit: BoxFit.cover,
      width: 46,
      height: 46,
      errorBuilder: (_, __, ___) => Center(child: _featuredRing()),
    );
  }

  Widget _featuredRing() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
          ),
        ),
        Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: Color(0xFFC8CDD4),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}

const List<_StoreSectionData> _storeSections = [
  _StoreSectionData(
    title: 'B&B',
    country: 'Italy',
    totalProducts: 12,
    railIcon: Icons.widgets_outlined,
    categories: [
      _StoreCategoryCardData(
          title: 'Implant Systems', itemsCount: 24, icon: Icons.gps_fixed),
      _StoreCategoryCardData(
          title: 'Titanium\nAbutments', itemsCount: 12, icon: Icons.add),
      _StoreCategoryCardData(
          title: 'Digital Dentistry',
          itemsCount: 8,
          icon: Icons.desktop_windows),
      _StoreCategoryCardData(
          title: 'Surgical Kits',
          itemsCount: 5,
          icon: Icons.receipt_long_outlined),
      _StoreCategoryCardData(
          title: 'Multi-Unit\nSolutions',
          itemsCount: 6,
          icon: Icons.hub_outlined),
    ],
    featuredProducts: [
      _StoreFeaturedProduct(
        productId: '1',
        name: 'B&B Implant System -\nStraight',
        price: '4,500',
      ),
      _StoreFeaturedProduct(
        productId: '2',
        name: 'B&B Titanium\nAbutment',
        price: '2,800',
      ),
      _StoreFeaturedProduct(
        productId: '16',
        name: 'B&B Short Implant',
        price: '4,800',
      ),
    ],
  ),
  _StoreSectionData(
    title: 'Macros',
    country: 'Germany',
    totalProducts: 8,
    railIcon: Icons.event_outlined,
    categories: [
      _StoreCategoryCardData(
          title: 'Implant Systems',
          itemsCount: 18,
          icon: Icons.adjust_outlined),
      _StoreCategoryCardData(
          title: 'Surgical Kits',
          itemsCount: 6,
          icon: Icons.crop_square_outlined),
    ],
    featuredProducts: [
      _StoreFeaturedProduct(
        productId: '20',
        name: 'Macros Tapered\nImplant 4.2mm',
        price: '3,900',
      ),
      _StoreFeaturedProduct(
        productId: '21',
        name: 'Macros Bone Level\nImplant',
        price: '4,100',
        inStock: false,
      ),
    ],
  ),
  _StoreSectionData(
    title: 'Powerbone',
    country: 'Switzerland',
    totalProducts: 6,
    railIcon: Icons.shield_outlined,
    categories: [
      _StoreCategoryCardData(
          title: 'Bone Graft', itemsCount: 8, icon: Icons.shield_outlined),
      _StoreCategoryCardData(
          title: 'Surgical Kits',
          itemsCount: 4,
          icon: Icons.crop_square_outlined),
    ],
    featuredProducts: [
      _StoreFeaturedProduct(
        productId: '8',
        name: 'Powerbone Surgical Kit',
        price: '12,000',
      ),
      _StoreFeaturedProduct(
        productId: '23',
        name: 'Powerbone Compact\nKit',
        price: '9,800',
      ),
      _StoreFeaturedProduct(
        productId: '22',
        name: 'Powerbone Expansion\nKit',
        price: '14,200',
        inStock: false,
      ),
    ],
  ),
  _StoreSectionData(
    title: 'MCTBIO',
    country: 'South Korea',
    totalProducts: 10,
    railIcon: Icons.adjust_rounded,
    categories: [
      _StoreCategoryCardData(
          title: 'Implant Systems', itemsCount: 14, icon: Icons.adjust_rounded),
      _StoreCategoryCardData(
          title: 'Abutments', itemsCount: 10, icon: Icons.add),
    ],
    featuredProducts: [
      _StoreFeaturedProduct(
        productId: '9',
        name: 'MCTBIO Implant Fixture\n4.5×13mm',
        price: '3,200',
      ),
      _StoreFeaturedProduct(
        productId: '10',
        name: 'MCTBIO Digital Scan Body',
        price: '800',
      ),
    ],
  ),
  _StoreSectionData(
    title: 'Biomaterials/Regenerative',
    country: 'Multi-brand',
    totalProducts: 14,
    railIcon: Icons.sync_outlined,
    categories: [
      _StoreCategoryCardData(
          title: 'Bone Graft\nMaterials',
          itemsCount: 12,
          icon: Icons.circle_outlined),
      _StoreCategoryCardData(
          title: 'Membranes', itemsCount: 8, icon: Icons.crop_square_outlined),
      _StoreCategoryCardData(
          title: 'Regenerative', itemsCount: 6, icon: Icons.sync_outlined),
    ],
    featuredProducts: [
      _StoreFeaturedProduct(
        productId: '24',
        name: 'OsseoGraft 1.0g',
        price: '680',
      ),
      _StoreFeaturedProduct(
        productId: '25',
        name: 'Collagen Membrane\n25×25mm',
        price: '950',
      ),
    ],
  ),
];

class _RailItem {
  final IconData icon;
  final String label;

  const _RailItem({required this.icon, required this.label});
}

class _StoreSectionData {
  final String title;
  final String country;
  final int totalProducts;
  final IconData railIcon;
  final List<_StoreCategoryCardData> categories;
  final List<_StoreFeaturedProduct> featuredProducts;

  const _StoreSectionData({
    required this.title,
    required this.country,
    required this.totalProducts,
    required this.railIcon,
    required this.categories,
    required this.featuredProducts,
  });
}

class _StoreCategoryCardData {
  final String title;
  final int itemsCount;
  final IconData icon;

  const _StoreCategoryCardData({
    required this.title,
    required this.itemsCount,
    required this.icon,
  });
}

class _StoreFeaturedProduct {
  final String productId;
  final String name;
  final String price;
  final bool inStock;

  const _StoreFeaturedProduct({
    required this.productId,
    required this.name,
    required this.price,
    this.inStock = true,
  });
}
