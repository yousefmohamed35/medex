import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../core/design/app_colors.dart';
import '../models/product.dart';

class HomeFeaturedProductsSection extends StatelessWidget {
  const HomeFeaturedProductsSection({
    super.key,
    required this.isAr,
    required this.isLoading,
    required this.products,
    required this.onViewAllTap,
    required this.onProductTap,
    required this.onAddToCartTap,
  });

  final bool isAr;
  final bool isLoading;
  final List<Product> products;
  final VoidCallback onViewAllTap;
  final ValueChanged<Product> onProductTap;
  final ValueChanged<Product> onAddToCartTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isAr ? 'منتجات مميزة' : 'Featured Products',
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.foreground,
                ),
              ),
              GestureDetector(
                onTap: onViewAllTap,
                child: Text(
                  isAr ? 'عرض الكل' : 'View All',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 250,
          child: isLoading
              ? Skeletonizer(
                  enabled: true,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: 3,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) => const _FeaturedProductCard(
                      isAr: false,
                      title: 'BLX Implant 4.5x10mm',
                      subtitle: 'Straumann',
                      priceText: 'EGP 1,850',
                      imageUrl: '',
                      discountText: '30%',
                      onTap: null,
                      onAddToCartTap: null,
                    ),
                  ),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final p = products[index];
                    final priceText = isAr
                        ? '${p.price.toInt()} ج.م'
                        : 'EGP ${p.price.toInt()}';
                    return _FeaturedProductCard(
                      isAr: isAr,
                      title: isAr ? p.nameAr : p.name,
                      subtitle: p.brand,
                      priceText: priceText,
                      imageUrl: p.imageUrl,
                      discountText: p.discount != null
                          ? '-${p.discount!.toInt()}%'
                          : null,
                      onTap: () => onProductTap(p),
                      onAddToCartTap: () => onAddToCartTap(p),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _FeaturedProductCard extends StatelessWidget {
  const _FeaturedProductCard({
    required this.isAr,
    required this.title,
    required this.subtitle,
    required this.priceText,
    required this.imageUrl,
    required this.discountText,
    required this.onTap,
    required this.onAddToCartTap,
  });

  final bool isAr;
  final String title;
  final String subtitle;
  final String priceText;
  final String imageUrl;
  final String? discountText;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCartTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 208,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8FA),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 118,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F1F4),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(17)),
              ),
              child: Stack(
                children: [
                  Center(child: _buildImage()),
                  if (discountText != null)
                    Positioned(
                      top: 10,
                      left: isAr ? null : 10,
                      right: isAr ? 10 : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          discountText!,
                          style: GoogleFonts.cairo(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.foreground,
                  height: 1.15,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
              child: Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  fontSize: 7,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFA0A6B0),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
              child: Text(
                priceText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  height: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: GestureDetector(
                onTap: onAddToCartTap,
                child: Container(
                  width: double.infinity,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      isAr ? '+ أضف إلى السلة' : '+ Add to Cart',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    final path = imageUrl.trim();
    if (path.isEmpty) {
      return const Icon(Icons.gps_fixed_rounded,
          size: 52, color: AppColors.primary);
    }

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        width: 96,
        height: 84,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(Icons.gps_fixed_rounded,
            size: 52, color: AppColors.primary),
      );
    }

    return Image.asset(
      path,
      width: 96,
      height: 84,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const Icon(Icons.gps_fixed_rounded,
          size: 52, color: AppColors.primary),
    );
  }
}
