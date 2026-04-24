import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design/app_colors.dart';
import '../../core/navigation/route_names.dart';

class ProductLearningHubScreen extends StatefulWidget {
  const ProductLearningHubScreen({super.key});

  @override
  State<ProductLearningHubScreen> createState() =>
      _ProductLearningHubScreenState();
}

class _ProductLearningHubScreenState extends State<ProductLearningHubScreen> {
  int? _selectedBrandIndex;
  int? _selectedProductIndex;

  _Brand? get _selectedBrand =>
      _selectedBrandIndex != null ? _brands[_selectedBrandIndex!] : null;

  _BrandItem? get _selectedProduct =>
      _selectedProductIndex != null ? _brandItems[_selectedProductIndex!] : null;

  void _handleBack() {
    if (_selectedProductIndex != null) {
      setState(() => _selectedProductIndex = null);
      return;
    }
    if (_selectedBrandIndex != null) {
      setState(() => _selectedBrandIndex = null);
      return;
    }
    if (Navigator.of(context).canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.home);
    }
  }

  void _openProduct(int index) {
    setState(() => _selectedProductIndex = index);
  }

  void _backToProducts() {
    setState(() => _selectedProductIndex = null);
  }

  void _backToBrands() {
    setState(() {
      _selectedBrandIndex = null;
      _selectedProductIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E9EE),
      body: Column(
        children: [
          _buildRedHeaderBlock(),
          if (_selectedBrandIndex == null) _buildIntro(),
          Expanded(child: _buildMainBody()),
        ],
      ),
    );
  }

  Widget _buildRedHeaderBlock() {
    final brand = _selectedBrand;
    final product = _selectedProduct;

    return Material(
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: _handleBack,
                    child: Container(
                      width: 36,
                      height: 36,
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Product Learning Hub',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              if (product != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    GestureDetector(
                      onTap: _backToProducts,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 11,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Products',
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        product.title,
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ] else if (brand != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    GestureDetector(
                      onTap: _backToBrands,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 11, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '← Brands',
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        brand.name,
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntro() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFE8E9EE),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Text(
        'Select a brand to explore content',
        style: GoogleFonts.cairo(
          color: const Color(0xFF475467),
          fontSize: 16 / 1.2,
        ),
      ),
    );
  }

  Widget _buildMainBody() {
    if (_selectedBrandIndex == null) {
      return _buildBrandGrid();
    }
    if (_selectedProductIndex == null) {
      return _buildBrandItemsList();
    }
    return _buildProductLearningTabs();
  }

  Widget _buildProductLearningTabs() {
    final product = _selectedProduct!;
    return DefaultTabController(
      key: ValueKey(product.title),
      length: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Colors.white,
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: AppColors.primary,
              unselectedLabelColor: const Color(0xFF98A2B3),
              indicatorColor: AppColors.primary,
              indicatorWeight: 2.5,
              labelStyle: GoogleFonts.cairo(
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
              unselectedLabelStyle: GoogleFonts.cairo(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Videos'),
                Tab(text: 'Downloads'),
                Tab(text: 'Cases'),
                Tab(text: 'Reviews'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _ProductOverviewTab(productTitle: product.title),
                const _ProductHubPlaceholderTab(
                    label: 'Videos', icon: Icons.play_circle_outline_rounded),
                const _ProductHubPlaceholderTab(
                    label: 'Downloads', icon: Icons.download_outlined),
                const _ProductHubPlaceholderTab(
                    label: 'Cases', icon: Icons.folder_open_outlined),
                const _ProductHubPlaceholderTab(
                    label: 'Reviews', icon: Icons.star_outline_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      itemCount: _brands.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 12,
        mainAxisExtent: 160,
      ),
      itemBuilder: (context, index) {
        final brand = _brands[index];
        return GestureDetector(
          onTap: () => setState(() => _selectedBrandIndex = index),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF6F7FA),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFD9DDE5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 95,
                  decoration: BoxDecoration(
                    color: brand.softColor,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(18)),
                  ),
                  child: Center(
                    child: Icon(brand.icon, color: brand.color, size: 44),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 11, 14, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        brand.name,
                        style: GoogleFonts.cairo(
                          fontSize: 17 / 1.2,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${brand.videos} videos · ${brand.products} products',
                        style: GoogleFonts.cairo(
                          fontSize: 12.5,
                          color: const Color(0xFF475467),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBrandItemsList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
      itemCount: _brandItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = _brandItems[index];
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () => _openProduct(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F5F7),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFD4D8E0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5EBEC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.icon, color: AppColors.primary, size: 30),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: GoogleFonts.cairo(
                            fontSize: 18 / 1.2,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${item.videos} videos · ${item.pdfs} PDFs',
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            color: const Color(0xFF475467),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: Color(0xFF98A2B3), size: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProductOverviewTab extends StatelessWidget {
  const _ProductOverviewTab({required this.productTitle});

  final String productTitle;

  static const String _blxAbout =
      'The BLX implant features a unique thread design with tapered body for '
      'primary stability in any bone quality. Suitable for immediate loading '
      'protocols with torque values up to 50 Ncm.';

  @override
  Widget build(BuildContext context) {
    final isBlx = productTitle.toLowerCase().contains('blx');
    final about = isBlx
        ? _blxAbout
        : 'Product overview and clinical highlights for $productTitle will appear here.';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About this Product',
            style: GoogleFonts.cairo(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            about,
            style: GoogleFonts.cairo(
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF475467),
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: isBlx
                ? const [
                    _SpecTile(label: 'DIAMETER', value: '3.3 – 6.0 mm'),
                    _SpecTile(label: 'MATERIAL', value: 'Ti Grade 4'),
                    _SpecTile(label: 'SURFACE', value: 'SLActive'),
                    _SpecTile(label: 'MAX TORQUE', value: '50 Ncm'),
                  ]
                : [
                    _SpecTile(label: 'PRODUCT', value: productTitle),
                    const _SpecTile(label: 'FORMAT', value: 'Learning hub'),
                    const _SpecTile(label: 'CONTENT', value: 'Videos · PDFs'),
                    const _SpecTile(label: 'STATUS', value: 'Available'),
                  ],
          ),
        ],
      ),
    );
  }
}

class _SpecTile extends StatelessWidget {
  const _SpecTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF5D0D4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: const Color(0xFF667085),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductHubPlaceholderTab extends StatelessWidget {
  const _ProductHubPlaceholderTab({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: const Color(0xFF98A2B3)),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF344054),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Content for this section is coming soon.',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: const Color(0xFF667085),
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Brand {
  final String name;
  final int videos;
  final int products;
  final Color color;
  final Color softColor;
  final IconData icon;

  const _Brand({
    required this.name,
    required this.videos,
    required this.products,
    required this.color,
    required this.softColor,
    required this.icon,
  });
}

class _BrandItem {
  final String title;
  final int videos;
  final int pdfs;
  final IconData icon;

  const _BrandItem({
    required this.title,
    required this.videos,
    required this.pdfs,
    required this.icon,
  });
}

const List<_Brand> _brands = [
  _Brand(
    name: 'B&B Implant',
    videos: 48,
    products: 12,
    color: Color(0xFFEA1720),
    softColor: Color(0xFFF5E9EA),
    icon: Icons.adjust_rounded,
  ),
  _Brand(
    name: 'Point Implant',
    videos: 36,
    products: 8,
    color: Color(0xFF1F63AA),
    softColor: Color(0xFFE8EFF8),
    icon: Icons.circle_outlined,
  ),
  _Brand(
    name: 'Powerbone',
    videos: 24,
    products: 6,
    color: Color(0xFF2D5D1A),
    softColor: Color(0xFFE6F1EB),
    icon: Icons.shield_outlined,
  ),
  _Brand(
    name: 'Biomaterials',
    videos: 18,
    products: 5,
    color: Color(0xFF5D50B7),
    softColor: Color(0xFFEEEAF8),
    icon: Icons.view_week_outlined,
  ),
];

const List<_BrandItem> _brandItems = [
  _BrandItem(
    title: 'BLX Tapered Implant',
    videos: 5,
    pdfs: 2,
    icon: Icons.adjust_rounded,
  ),
  _BrandItem(
    title: 'BLT Bone Level',
    videos: 8,
    pdfs: 3,
    icon: Icons.crop_3_2_rounded,
  ),
  _BrandItem(
    title: 'TL Tissue Level',
    videos: 6,
    pdfs: 1,
    icon: Icons.circle_outlined,
  ),
  _BrandItem(
    title: 'Prosthetic Components',
    videos: 10,
    pdfs: 4,
    icon: Icons.add_rounded,
  ),
];
