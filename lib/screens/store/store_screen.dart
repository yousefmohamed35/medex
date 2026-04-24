import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design/app_colors.dart';
import '../../core/navigation/route_names.dart';
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
  String _searchQuery = '';
  String? _error;

  List<Product> _products = [];
  List<ProductCategory> _categories = [];
  int _selectedRailIndex = 0;

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
      final categories = await StoreService.instance.getCategories();
      final products = await StoreService.instance.getProducts(perPage: 100);
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _products = products;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Product> get _visibleProducts {
    if (_products.isEmpty) return [];
    final selected = _currentRailItem.toLowerCase();
    return _products.where((p) {
      final matchesRail = selected == 'all'
          ? true
          : p.brand.toLowerCase().contains(selected) ||
              p.category.toLowerCase().contains(selected);
      if (!matchesRail) return false;
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return p.name.toLowerCase().contains(q) ||
          p.nameAr.contains(_searchQuery) ||
          p.brand.toLowerCase().contains(q);
    }).toList();
  }

  List<Product> get _featuredProducts => _visibleProducts.take(6).toList();

  String get _currentRailItem {
    final items = _railItems;
    if (_selectedRailIndex >= items.length) return 'all';
    return items[_selectedRailIndex].label;
  }

  List<_RailItem> get _railItems {
    final unique = <String>{};
    final result = <_RailItem>[
      const _RailItem(icon: Icons.storefront_outlined, label: 'B&B Dental'),
    ];
    for (final c in _categories) {
      final label = c.name.trim().isEmpty ? c.brand : c.name;
      if (label.trim().isEmpty) continue;
      if (unique.add(label.toLowerCase())) {
        result.add(_RailItem(icon: _iconForLabel(label), label: label));
      }
      if (result.length >= 8) break;
    }
    return result;
  }

  IconData _iconForLabel(String label) {
    final s = label.toLowerCase();
    if (s.contains('implant')) return Icons.medical_services_outlined;
    if (s.contains('digital')) return Icons.monitor_heart_outlined;
    if (s.contains('surgical')) return Icons.receipt_long_outlined;
    if (s.contains('bio')) return Icons.biotech_outlined;
    if (s.contains('power')) return Icons.shield_outlined;
    return Icons.widgets_outlined;
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
                    : _error != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                _error!,
                                style: GoogleFonts.cairo(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : Row(
                            children: [
                              _buildLeftRail(isAr),
                              Expanded(child: _buildRightPanel(isAr)),
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
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
      ),
      padding: const EdgeInsets.fromLTRB(10, 38, 10, 8),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0x22FFFFFF),
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                const Icon(Icons.home_outlined, color: Colors.white, size: 17),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Container(
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFFFF5B68),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: isAr ? 'ابحث عن المنتجات...' : 'Search products...',
                  hintStyle: GoogleFonts.cairo(
                    color: const Color(0xFFFFA5AE),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 7),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFFFFC0C6),
                    size: 15,
                  ),
                  prefixIconConstraints:
                      const BoxConstraints(minWidth: 30, minHeight: 30),
                ),
              ),
            ),
          ),
          const SizedBox(width: 7),
          GestureDetector(
            onTap: () => context.push(RouteNames.cart),
            child: Stack(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0x22FFFFFF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.white,
                    size: 17,
                  ),
                ),
                if (CartService.instance.itemCount > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFE54F),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${CartService.instance.itemCount}',
                          style: GoogleFonts.cairo(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
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
    final items = _railItems;
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
            onTap: () => setState(() => _selectedRailIndex = index),
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
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(
                      item.icon,
                      size: 16,
                      color: const Color(0xFF5E6470),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isAr ? _toArLabel(item.label) : item.label,
                    style: GoogleFonts.cairo(
                      fontSize: 8.5,
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
    if (label == 'B&B Dental') return 'بي آند بي';
    if (label.toLowerCase().contains('implant')) return 'زرعات';
    if (label.toLowerCase().contains('digital')) return 'رقمي';
    if (label.toLowerCase().contains('surgical')) return 'جراحي';
    if (label.toLowerCase().contains('bio')) return 'مواد حيوية';
    return label;
  }

  Widget _buildRightPanel(bool isAr) {
    final products = _visibleProducts;
    return Container(
      color: const Color(0xFFE9EBF0),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                          _currentRailItem,
                          style: GoogleFonts.cairo(
                            fontSize: 23 / 1.9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          isAr ? 'إيطاليا · 12 منتج' : 'Italy · 12 Products',
                          style: GoogleFonts.cairo(
                            fontSize: 10,
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
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isAr ? '| التصنيفات' : '| CATEGORIES',
              style: GoogleFonts.cairo(
                color: const Color(0xFF485064),
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _categories.take(5).length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.05,
              ),
              itemBuilder: (context, index) {
                final c = _categories[index];
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F3F6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD7DAE2)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _iconForLabel(c.name),
                          color: AppColors.primary,
                          size: 19,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isAr ? c.nameAr : c.name,
                        style: GoogleFonts.cairo(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${(products.length / 2).ceil()} ${isAr ? 'عنصر' : 'Items'}',
                        style: GoogleFonts.cairo(
                          fontSize: 10,
                          color: const Color(0xFF98A0AE),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Text(
              isAr ? '| المنتجات المميزة' : '| FEATURED PRODUCTS',
              style: GoogleFonts.cairo(
                color: const Color(0xFF485064),
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            ..._featuredProducts.map((p) => _buildFeaturedTile(p, isAr)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedTile(Product p, bool isAr) {
    return GestureDetector(
      onTap: () => context.push(RouteNames.productDetails, extra: p),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD7DAE2)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  const Icon(Icons.circle_outlined, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAr ? p.nameAr : p.name,
                    style: GoogleFonts.cairo(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    isAr ? 'متوفر' : 'In Stock',
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      color: const Color(0xFF17A34A),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    isAr ? 'ج.م ${p.price.toInt()}' : 'EGP ${p.price.toInt()}',
                    style: GoogleFonts.cairo(
                      fontSize: 24 / 1.8,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                CartService.instance.addToCart(p);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(milliseconds: 900),
                    content: Text(
                      isAr ? 'تمت الإضافة للسلة' : 'Added to cart',
                    ),
                  ),
                );
              },
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add, color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RailItem {
  final IconData icon;
  final String label;

  const _RailItem({required this.icon, required this.label});
}
