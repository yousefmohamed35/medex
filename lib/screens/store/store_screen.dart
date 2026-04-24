import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design/app_colors.dart';
import '../../core/navigation/route_names.dart';
import '../../services/cart_service.dart';
import '../../widgets/bottom_nav.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final _searchController = TextEditingController();
  final bool _isLoading = false;
  String _searchQuery = '';
  int _selectedRailIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  _StoreSectionData get _activeSection => _storeSections[_selectedRailIndex];

  List<_StoreFeaturedProduct> get _activeFeaturedProducts {
    final items = _activeSection.featuredProducts;
    if (_searchQuery.trim().isEmpty) return items;
    final q = _searchQuery.toLowerCase();
    return items.where((p) => p.name.toLowerCase().contains(q)).toList();
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
      padding: const EdgeInsets.fromLTRB(10, 36, 10, 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF43446),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                const Icon(Icons.home_outlined, color: Colors.white, size: 21),
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
    if (label == 'B&B Dental') return 'بي آند بي';
    if (label.toLowerCase().contains('implant')) return 'زرعات';
    if (label.toLowerCase().contains('digital')) return 'رقمي';
    if (label.toLowerCase().contains('surgical')) return 'جراحي';
    if (label.toLowerCase().contains('bio')) return 'مواد حيوية';
    return label;
  }

  Widget _buildRightPanel(bool isAr) {
    final section = _activeSection;
    final categories = section.categories;
    final featured = _activeFeaturedProducts;
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
                          section.title,
                          style: GoogleFonts.cairo(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${section.country} · ${section.totalProducts} Products',
                          style: GoogleFonts.cairo(
                            fontSize: 11,
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
                      fontSize: 12.5,
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
                fontSize: 14,
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
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${c.itemsCount} Items',
                        style: GoogleFonts.cairo(
                          fontSize: 10.8,
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
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            ...featured.map((p) => _buildFeaturedTile(p, isAr)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedTile(_StoreFeaturedProduct p, bool isAr) {
    return GestureDetector(
      onTap: () {},
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
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.circle_outlined,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    style: GoogleFonts.cairo(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    p.inStock ? 'In Stock' : 'Out of Stock',
                    style: GoogleFonts.cairo(
                      fontSize: 10.8,
                      color: p.inStock
                          ? const Color(0xFF17A34A)
                          : const Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'EGP ${p.price}',
                    style: GoogleFonts.cairo(
                      fontSize: 14.5,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
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
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    const Icon(Icons.add, color: AppColors.primary, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const List<_StoreSectionData> _storeSections = [
  _StoreSectionData(
    title: 'B&B Dental',
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
          name: 'B&B Implant System -\nStraight', price: '4,500'),
      _StoreFeaturedProduct(name: 'B&B Titanium\nAbutment', price: '2,800'),
      _StoreFeaturedProduct(name: 'B&B Short Implant', price: '4,200'),
    ],
  ),
  _StoreSectionData(
    title: 'Macros Implants',
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
          name: 'Macros Tapered\nImplant 4.2mm', price: '3,900'),
      _StoreFeaturedProduct(
          name: 'Macros Bone Level\nImplant', price: '4,100', inStock: false),
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
      _StoreFeaturedProduct(name: 'Powerbone Surgical Kit', price: '12,500'),
      _StoreFeaturedProduct(name: 'Powerbone Compact\nKit', price: '9,800'),
      _StoreFeaturedProduct(
          name: 'Powerbone Expansion\nKit', price: '14,200', inStock: false),
    ],
  ),
  _StoreSectionData(
    title: 'MCTBIO Implant',
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
      _StoreFeaturedProduct(name: 'MCTBIO BL Implant\n3.8mm', price: '2,600'),
      _StoreFeaturedProduct(name: 'MCTBIO TL Implant\n4.5mm', price: '2,900'),
    ],
  ),
  _StoreSectionData(
    title: 'Biomaterials',
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
      _StoreFeaturedProduct(name: 'OsseoGraft 1.0g', price: '680'),
      _StoreFeaturedProduct(name: 'Collagen Membrane\n25×25mm', price: '950'),
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
  final String name;
  final String price;
  final bool inStock;

  const _StoreFeaturedProduct({
    required this.name,
    required this.price,
    this.inStock = true,
  });
}
