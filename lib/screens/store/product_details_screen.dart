import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design/app_colors.dart';
import '../../core/navigation/route_names.dart';
import '../../models/product.dart';
import '../../services/cart_service.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product? product;

  const ProductDetailsScreen({super.key, this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;
  bool _isRental = false;

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final product = widget.product;

    if (product == null) {
      return Scaffold(
        body: Center(child: Text(isAr ? 'المنتج غير موجود' : 'Product not found')),
      );
    }

    final price = _isRental ? (product.rentalPrice ?? product.price) : product.price;
    final totalPrice = price * _quantity;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  backgroundColor: Colors.white,
                  leading: GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                    ),
                  ),
                  actions: [
                    GestureDetector(
                      onTap: () => context.push(RouteNames.cart),
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
                        ),
                        child: const Icon(Icons.shopping_cart_rounded, size: 20),
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      color: Colors.white,
                      child: Stack(
                        children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40),
                              child: Image.asset(
                                product.imageUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.medical_services_rounded,
                                  size: 80,
                                  color: AppColors.primary.withOpacity(0.2),
                                ),
                              ),
                            ),
                          ),
                          if (product.discount != null)
                            Positioned(
                              top: 100,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '-${product.discount!.toInt()}%',
                                  style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  product.brand,
                                  style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.muted,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.flag_rounded, size: 14, color: AppColors.mutedForeground),
                                    const SizedBox(width: 4),
                                    Text(
                                      product.origin,
                                      style: GoogleFonts.cairo(fontSize: 12, color: AppColors.mutedForeground),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            isAr ? product.nameAr : product.name,
                            style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.foreground),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isAr ? product.categoryAr : product.category,
                            style: GoogleFonts.cairo(fontSize: 14, color: AppColors.mutedForeground),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            isAr ? product.descriptionAr : product.description,
                            style: GoogleFonts.cairo(fontSize: 14, color: AppColors.mutedForeground, height: 1.7),
                          ),
                          const SizedBox(height: 24),
                          if (product.isRentable) ...[
                            Text(
                              isAr ? 'نوع الطلب' : 'Order Type',
                              style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _isRental = false),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      decoration: BoxDecoration(
                                        color: !_isRental ? AppColors.primary : Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: !_isRental ? AppColors.primary : AppColors.border, width: 2),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(Icons.shopping_bag_rounded, color: !_isRental ? Colors.white : AppColors.foreground, size: 24),
                                          const SizedBox(height: 4),
                                          Text(
                                            isAr ? 'شراء' : 'Buy',
                                            style: GoogleFonts.cairo(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: !_isRental ? Colors.white : AppColors.foreground,
                                            ),
                                          ),
                                          Text(
                                            isAr ? '${product.price.toInt()} ج.م' : 'EGP ${product.price.toInt()}',
                                            style: GoogleFonts.cairo(
                                              fontSize: 12,
                                              color: !_isRental ? Colors.white.withOpacity(0.8) : AppColors.mutedForeground,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _isRental = true),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      decoration: BoxDecoration(
                                        color: _isRental ? AppColors.info : Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: _isRental ? AppColors.info : AppColors.border, width: 2),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(Icons.access_time_rounded, color: _isRental ? Colors.white : AppColors.foreground, size: 24),
                                          const SizedBox(height: 4),
                                          Text(
                                            isAr ? 'تأجير' : 'Rent',
                                            style: GoogleFonts.cairo(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: _isRental ? Colors.white : AppColors.foreground,
                                            ),
                                          ),
                                          Text(
                                            isAr ? '${(product.rentalPrice ?? product.price).toInt()} ج.م' : 'EGP ${(product.rentalPrice ?? product.price).toInt()}',
                                            style: GoogleFonts.cairo(
                                              fontSize: 12,
                                              color: _isRental ? Colors.white.withOpacity(0.8) : AppColors.mutedForeground,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                          ],
                          Text(
                            isAr ? 'الكمية' : 'Quantity',
                            style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (_quantity > 1) setState(() => _quantity--);
                                  },
                                  icon: const Icon(Icons.remove_rounded),
                                  color: AppColors.foreground,
                                ),
                                Container(
                                  width: 48,
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$_quantity',
                                    style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => setState(() => _quantity++),
                                  icon: const Icon(Icons.add_rounded),
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4)),
              ],
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isAr ? 'الإجمالي' : 'Total',
                      style: GoogleFonts.cairo(fontSize: 12, color: AppColors.mutedForeground),
                    ),
                    Text(
                      isAr ? '${totalPrice.toInt()} ج.م' : 'EGP ${totalPrice.toInt()}',
                      style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      for (int i = 0; i < _quantity; i++) {
                        CartService.instance.addToCart(product, isRental: _isRental);
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isAr ? 'تمت الإضافة إلى السلة' : 'Added to cart',
                            style: GoogleFonts.cairo(),
                          ),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          action: SnackBarAction(
                            label: isAr ? 'عرض السلة' : 'View Cart',
                            textColor: Colors.white,
                            onPressed: () => context.push(RouteNames.cart),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_cart_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _isRental
                              ? (isAr ? 'أضف للسلة (تأجير)' : 'Add to Cart (Rent)')
                              : (isAr ? 'أضف للسلة' : 'Add to Cart'),
                          style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
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
}
