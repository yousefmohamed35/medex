import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/design/app_colors.dart';
import '../../core/navigation/route_names.dart';
import '../../services/cart_service.dart';

class StoreCheckoutScreen extends StatefulWidget {
  const StoreCheckoutScreen({super.key});

  @override
  State<StoreCheckoutScreen> createState() => _StoreCheckoutScreenState();
}

class _StoreCheckoutScreenState extends State<StoreCheckoutScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  String _paymentMethod = 'cash';
  bool _isProcessing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final cart = CartService.instance;

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
            child: Row(
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
                Text(
                  isAr ? 'إتمام الطلب' : 'Checkout',
                  style: GoogleFonts.cairo(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(
                      isAr ? 'معلومات التوصيل' : 'Delivery Information'),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _nameController,
                    label: isAr ? 'الاسم الكامل' : 'Full Name',
                    icon: Icons.person_rounded,
                    isAr: isAr,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _phoneController,
                    label: isAr ? 'رقم الهاتف' : 'Phone Number',
                    icon: Icons.phone_rounded,
                    keyboardType: TextInputType.phone,
                    isAr: isAr,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _addressController,
                    label: isAr ? 'عنوان التوصيل' : 'Delivery Address',
                    icon: Icons.location_on_rounded,
                    maxLines: 2,
                    isAr: isAr,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _notesController,
                    label: isAr ? 'ملاحظات (اختياري)' : 'Notes (Optional)',
                    icon: Icons.note_rounded,
                    maxLines: 2,
                    isAr: isAr,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle(isAr ? 'طريقة الدفع' : 'Payment Method'),
                  const SizedBox(height: 12),
                  _buildPaymentOption(
                      'cash',
                      isAr ? 'الدفع عند الاستلام' : 'Cash on Delivery',
                      Icons.money_rounded,
                      isAr),
                  const SizedBox(height: 8),
                  _buildPaymentOption(
                      'card',
                      isAr ? 'بطاقة ائتمان' : 'Credit Card',
                      Icons.credit_card_rounded,
                      isAr),
                  const SizedBox(height: 8),
                  _buildPaymentOption(
                      'wallet',
                      isAr ? 'محفظة إلكترونية' : 'E-Wallet',
                      Icons.account_balance_wallet_rounded,
                      isAr),
                  const SizedBox(height: 24),
                  _buildSectionTitle(isAr ? 'ملخص الطلب' : 'Order Summary'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        ...cart.items.map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${isAr ? item.product.nameAr : item.product.name} x${item.quantity}',
                                      style: GoogleFonts.cairo(
                                          fontSize: 13,
                                          color: AppColors.foreground),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    isAr
                                        ? '${item.totalPrice.toInt()} ج.م'
                                        : 'EGP ${item.totalPrice.toInt()}',
                                    style: GoogleFonts.cairo(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            )),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isAr ? 'الشحن' : 'Shipping',
                              style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  color: AppColors.mutedForeground),
                            ),
                            Text(
                              isAr ? 'مجاني' : 'Free',
                              style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isAr ? 'الإجمالي' : 'Total',
                              style: GoogleFonts.cairo(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              isAr
                                  ? '${cart.totalPrice.toInt()} ج.م'
                                  : 'EGP ${cart.totalPrice.toInt()}',
                              style: GoogleFonts.cairo(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
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
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4)),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing
                    ? null
                    : () async {
                        final name = _nameController.text.trim();
                        final phone = _phoneController.text.trim();
                        final address = _addressController.text.trim();
                        if (name.isEmpty || phone.isEmpty || address.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isAr
                                    ? 'برجاء إدخال بيانات التوصيل كاملة'
                                    : 'Please fill delivery information',
                                style: GoogleFonts.cairo(),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        setState(() => _isProcessing = true);
                        try {
                          // 1) create address and get id
                          final addressRes = await ApiClient.instance.post(
                            ApiEndpoints.storeAddresses,
                            body: {
                              'label': 'Checkout',
                              'full_name': name,
                              'phone': phone,
                              'country': 'EG',
                              'city': 'Giza',
                              'area': '',
                              'street': address,
                              'building': '',
                              'floor': '',
                              'apartment': '',
                              'postal_code': '',
                              'is_default': false,
                            },
                            requireAuth: true,
                          );
                          if (addressRes['success'] != true ||
                              addressRes['data'] == null) {
                            throw Exception(
                                addressRes['message'] ?? 'Address failed');
                          }
                          final addressId =
                              (addressRes['data'] as Map)['id']?.toString() ??
                                  '';
                          if (addressId.isEmpty) {
                            throw Exception('Invalid address id');
                          }

                          // 2) create order from server cart
                          final orderRes = await ApiClient.instance.post(
                            ApiEndpoints.storeOrders,
                            body: {
                              'address_id': addressId,
                              'shipping_method_id': 'standard',
                              'payment_method': _paymentMethod == 'cash'
                                  ? 'cash_on_delivery'
                                  : _paymentMethod,
                              'payment_token': _paymentMethod == 'cash'
                                  ? null
                                  : 'app_generated_token',
                              'notes': _notesController.text.trim(),
                            },
                            requireAuth: true,
                          );
                          if (orderRes['success'] != true) {
                            throw Exception(
                                orderRes['message'] ?? 'Order creation failed');
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$e', style: GoogleFonts.cairo()),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          setState(() => _isProcessing = false);
                          return;
                        }
                        if (!mounted) return;
                        CartService.instance.clearCart();
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.check_circle_rounded,
                                      size: 48, color: AppColors.success),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  isAr ? 'تم تأكيد الطلب!' : 'Order Confirmed!',
                                  style: GoogleFonts.cairo(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  isAr
                                      ? 'سيتم التواصل معك قريباً لتأكيد التفاصيل'
                                      : 'We will contact you soon to confirm details',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.cairo(
                                      fontSize: 14,
                                      color: AppColors.mutedForeground),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                      context.go(RouteNames.home);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                    ),
                                    child: Text(
                                        isAr
                                            ? 'العودة للرئيسية'
                                            : 'Back to Home',
                                        style: GoogleFonts.cairo(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                        setState(() => _isProcessing = false);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text(
                        isAr ? 'تأكيد الطلب' : 'Confirm Order',
                        style: GoogleFonts.cairo(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.foreground),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isAr,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        style: GoogleFonts.cairo(),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.cairo(color: AppColors.mutedForeground),
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
      String value, String label, IconData icon, bool isAr) {
    final isSelected = _paymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.mutedForeground,
                  size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.foreground,
              ),
            ),
            const Spacer(),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: 2),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: AppColors.primary),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
