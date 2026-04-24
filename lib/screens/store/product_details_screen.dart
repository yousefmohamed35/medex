import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design/app_colors.dart';
import '../../core/navigation/route_names.dart';
import '../../models/product.dart';
import '../../services/cart_service.dart';
import '../../widgets/bottom_nav.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product? product;

  const ProductDetailsScreen({super.key, this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _selectedRail = 0;
  bool _favourite = false;

  static const List<_RailBrand> _railBrands = [
    _RailBrand('B&B Dental', Icons.medical_services_outlined),
    _RailBrand('Macros Implants', Icons.grid_view_rounded),
    _RailBrand('Powerbone', Icons.shield_outlined),
    _RailBrand('MCTBIO Mplant', Icons.biotech_outlined),
    _RailBrand('Biomaterials', Icons.layers_outlined),
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    if (p != null) {
      _selectedRail = _railIndexForBrand(p.brand);
    }
  }

  int _railIndexForBrand(String brand) {
    final b = brand.toLowerCase();
    if (b.contains('b&b') || b.contains('bb ') || b == 'bb') return 0;
    if (b.contains('macros')) return 1;
    if (b.contains('powerbone')) return 2;
    if (b.contains('mctbio')) return 3;
    if (b.contains('biomaterial') || b.contains('osseo') || b.contains('graft')) return 4;
    return 0;
  }

  void _toast(BuildContext context, String message, {IconData? icon}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 100, left: 48, right: 48),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  message,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 8),
                Icon(icon, color: Colors.white, size: 18),
              ],
            ],
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  bool _isNetworkImage(String path) {
    final p = path.toLowerCase();
    return p.startsWith('http://') || p.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final product = widget.product;

    if (product == null) {
      return Scaffold(
        body: Center(child: Text(isAr ? 'المنتج غير موجود' : 'Product not found')),
      );
    }

    final displayName = isAr ? product.nameAr : product.name;
    final displayCategory = isAr ? product.categoryAr : product.category;
    final displayDescription = isAr ? product.descriptionAr : product.description;
    final breadcrumbBrand = _railBrands[_selectedRail].label;
    final priceStr = isAr ? '${product.price.toInt()} ج.م' : 'EGP ${product.price.toInt()}';

    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      body: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBrandRail(),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          12,
                          MediaQuery.paddingOf(context).top + 8,
                          14,
                          120,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTopBar(context, isAr),
                            const SizedBox(height: 8),
                            Text(
                              '$breadcrumbBrand > $displayCategory',
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                color: const Color(0xFF667085),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 14),
                            _buildImageBlock(product),
                            const SizedBox(height: 16),
                            Text(
                              displayName,
                              style: GoogleFonts.cairo(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF101828),
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              priceStr,
                              style: GoogleFonts.cairo(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 18,
                                  color: product.isAvailable ? const Color(0xFF16A34A) : const Color(0xFF98A2B3),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  product.isAvailable
                                      ? (isAr ? 'متوفر' : 'In Stock')
                                      : (isAr ? 'غير متوفر' : 'Out of stock'),
                                  style: GoogleFonts.cairo(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: product.isAvailable ? const Color(0xFF16A34A) : const Color(0xFF98A2B3),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 22),
                            Text(
                              isAr ? 'الوصف' : 'Description',
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF101828),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              displayDescription.isNotEmpty
                                  ? displayDescription
                                  : (isAr
                                      ? 'نظام زرع عالي الجودة من التيتانيوم الدرجة الرابعة، مناسب للتحميل الفوري والحالات المعقدة.'
                                      : 'High-performance implant system in Grade 4 titanium, designed for primary stability and predictable osseointegration across a wide range of clinical indications.'),
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                height: 1.55,
                                color: const Color(0xFF667085),
                              ),
                            ),
                            const SizedBox(height: 22),
                            Text(
                              isAr ? 'المواصفات' : 'Specifications',
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF101828),
                              ),
                            ),
                            const SizedBox(height: 10),
                            _specTable(isAr),
                            if (product.isRentable) ...[
                              const SizedBox(height: 16),
                              Text(
                                isAr ? 'متاح للتأجير — أضف للسلة كخيار تأجير من السلة' : 'Rental available — add from cart options',
                                style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF667085)),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    _buildFooter(context, product, isAr),
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

  Widget _buildBrandRail() {
    return Container(
      width: 72,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Color(0xFFE4E7EC)),
        ),
      ),
      child: ListView.separated(
        padding: EdgeInsets.only(
          top: MediaQuery.paddingOf(context).top + 12,
          bottom: 100,
        ),
        itemCount: _railBrands.length,
        separatorBuilder: (_, __) => const SizedBox(height: 6),
        itemBuilder: (context, index) {
          final item = _railBrands[index];
          final selected = _selectedRail == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedRail = index),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFFFF0F1) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border(
                  right: BorderSide(
                    color: selected ? AppColors.primary : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.white
                          : const Color(0xFFF2F4F7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      item.icon,
                      size: 20,
                      color: selected ? AppColors.primary : const Color(0xFF667085),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      height: 1.05,
                      color: selected ? AppColors.primary : const Color(0xFF475467),
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

  Widget _buildTopBar(BuildContext context, bool isAr) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (Navigator.of(context).canPop()) {
              context.pop();
            } else {
              context.go(RouteNames.store);
            }
          },
          child: Row(
            children: [
              const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                isAr ? 'رجوع' : 'Back',
                style: GoogleFonts.cairo(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageBlock(Product product) {
    return Hero(
      tag: 'store_product_image_${product.id}',
      child: AspectRatio(
        aspectRatio: 1,
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE8EAEF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFD0D5DD)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (_isNetworkImage(product.imageUrl))
                  Image.network(
                    product.imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => _placeholderGraphic(),
                  )
                else
                  Image.asset(
                    product.imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => _placeholderGraphic(),
                  ),
                if (product.discount != null && product.discount! > 0)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '-${product.discount!.toInt()}%',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
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

  Widget _placeholderGraphic() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFB8BCC8), width: 3),
            ),
          ),
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _specTable(bool isAr) {
    final rows = [
      (
        isAr ? 'المادة' : 'Material',
        isAr ? 'تيتانيوم درجة 4' : 'Titanium Grade 4',
      ),
      (
        isAr ? 'السطح' : 'Surface',
        isAr ? 'مقذوف بالرمل ومحفر بالحمض' : 'Sandblasted & Acid Etched',
      ),
      (
        isAr ? 'الاتصال' : 'Connection',
        isAr ? 'سداسي داخلي' : 'Internal Hex',
      ),
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: Color(0xFFE4E7EC)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      rows[i].$1,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: const Color(0xFF667085),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      rows[i].$2,
                      textAlign: TextAlign.end,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF101828),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, Product product, bool isAr) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        12,
        12,
        MediaQuery.paddingOf(context).bottom + 72,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF2F3F5),
        border: Border(top: BorderSide(color: Color(0xFFE4E7EC))),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 50,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFF101828), width: 1),
                  ),
                ),
                onPressed: () {
                  CartService.instance.addToCart(product, isRental: false);
                  _toast(
                    context,
                    isAr ? 'تمت الإضافة إلى السلة' : 'Added to cart',
                    icon: Icons.check_rounded,
                  );
                },
                child: Text(
                  isAr ? 'أضف إلى السلة' : 'Add to Cart',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 50,
            height: 50,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF101828),
                padding: EdgeInsets.zero,
                side: const BorderSide(color: Color(0xFFD0D5DD)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                setState(() => _favourite = !_favourite);
                _toast(
                  context,
                  _favourite
                      ? (isAr ? 'تم الحفظ في المفضلة' : 'Saved to favourites ❤')
                      : (isAr ? 'تم الإزالة من المفضلة' : 'Removed from favourites'),
                );
              },
              child: Icon(
                _favourite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                size: 22,
                color: _favourite ? AppColors.primary : const Color(0xFF344054),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RailBrand {
  const _RailBrand(this.label, this.icon);

  final String label;
  final IconData icon;
}
