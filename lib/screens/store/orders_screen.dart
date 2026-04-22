import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design/app_colors.dart';
import '../../models/product.dart';
import '../../services/store_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _isLoading = true;
  String? _error;
  List<Order> _orders = [];
  final Set<String> _markingReceivedIds = {};

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      debugPrint('🛒 Orders Request: getOrders()');
      final orders = await StoreService.instance.getOrders();
      debugPrint(
          '✅ Orders Response: success, totalOrders=${orders.length}, orderIds=${orders.map((o) => o.id).toList()}');
      if (!mounted) return;
      setState(() => _orders = orders);
    } catch (e) {
      debugPrint('❌ Orders Response Error: $e');
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markReceived(Order order) async {
    if (_markingReceivedIds.contains(order.id)) return;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    setState(() => _markingReceivedIds.add(order.id));
    try {
      final updated = order.isRental
          ? await StoreService.instance
              .markRentalReceived(order.id, current: order)
          : await StoreService.instance
              .markOrderReceived(order.id, current: order);
      if (!mounted) return;
      setState(() {
        final i = _orders.indexWhere((o) => o.id == order.id);
        if (i != -1) _orders[i] = updated;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            order.isRental
                ? (isAr
                    ? 'تم تأكيد استلام الإيجار'
                    : 'Rental marked as received')
                : (isAr ? 'تم تأكيد استلام الطلب' : 'Order marked as received'),
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _markingReceivedIds.remove(order.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final orders = _orders;

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
                  isAr ? 'طلباتي' : 'My Orders',
                  style: GoogleFonts.cairo(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(_error!, textAlign: TextAlign.center),
                      ))
                    : orders.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.receipt_long_rounded,
                                    size: 80,
                                    color: AppColors.mutedForeground
                                        .withOpacity(0.3)),
                                const SizedBox(height: 16),
                                Text(
                                  isAr ? 'لا توجد طلبات' : 'No Orders Yet',
                                  style: GoogleFonts.cairo(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.mutedForeground),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: orders.length,
                            itemBuilder: (context, index) {
                              final order = orders[index];
                              final canMark =
                                  order.status.trim().toUpperCase() ==
                                      'SHIPPED';
                              return _OrderCard(
                                order: order,
                                isAr: isAr,
                                isMarkingReceived:
                                    _markingReceivedIds.contains(order.id),
                                onMarkReceived:
                                    canMark ? () => _markReceived(order) : null,
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final bool isAr;
  final bool isMarkingReceived;
  final VoidCallback? onMarkReceived;

  const _OrderCard({
    required this.order,
    required this.isAr,
    this.isMarkingReceived = false,
    this.onMarkReceived,
  });

  String get _normalizedStatus => order.status.trim().toUpperCase();

  static const Duration _lateThreshold = Duration(days: 7);

  bool get _isLateOrder {
    const inProgress = {'PENDING', 'PROCESSING', 'SHIPPED'};
    if (!inProgress.contains(_normalizedStatus)) return false;
    return DateTime.now().toUtc().difference(order.createdAt.toUtc()) >
        _lateThreshold;
  }

  String get _effectiveStatus => _isLateOrder ? 'OVERDUE' : _normalizedStatus;

  Color _getStatusColor() {
    switch (_effectiveStatus) {
      case 'DELIVERED':
        return AppColors.success;
      case 'SHIPPED':
        return AppColors.info;
      case 'OVERDUE':
        return AppColors.destructive;
      case 'CANCELLED':
      case 'HANDED':
        return AppColors.destructive;
      case 'PROCESSING':
      case 'PENDING':
        return AppColors.warning;
      default:
        return AppColors.mutedForeground;
    }
  }

  IconData _getStatusIcon() {
    switch (_effectiveStatus) {
      case 'DELIVERED':
        return Icons.check_circle_rounded;
      case 'SHIPPED':
        return Icons.local_shipping_rounded;
      case 'OVERDUE':
        return Icons.warning_amber_rounded;
      case 'CANCELLED':
      case 'HANDED':
        return Icons.cancel_rounded;
      case 'PROCESSING':
      case 'PENDING':
        return Icons.hourglass_top_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  String _statusLabel(bool isArabic) {
    switch (_effectiveStatus) {
      case 'PENDING':
        return isArabic ? 'قيد الانتظار' : 'Pending';
      case 'PROCESSING':
        return isArabic ? 'قيد المعالجة' : 'Processing';
      case 'SHIPPED':
        return isArabic ? 'تم الشحن' : 'Shipped';
      case 'DELIVERED':
        return isArabic ? 'تم التسليم' : 'Delivered';
      case 'HANDED':
        return isArabic ? 'تم الإلغاء' : 'Cancelled';
      case 'CANCELLED':
        return isArabic ? 'تم الإلغاء' : 'Cancelled';
      case 'OVERDUE':
        return isArabic ? 'متأخر' : 'Overdue';
      default:
        return isArabic ? order.statusAr : order.status;
    }
  }

  String _shortOrderId(String id) {
    final t = id.trim();
    if (t.length <= 14) return t;
    return '${t.substring(0, 8)}…${t.substring(t.length - 4)}';
  }

  String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final itemCount = order.items.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.65)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 4,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFD42535), Color(0xFFB01E2D)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAr ? 'رقم الطلب' : 'Order',
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.mutedForeground,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.receipt_long_rounded,
                                size: 18,
                                color: AppColors.primary.withOpacity(0.85),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  _shortOrderId(order.id),
                                  style: GoogleFonts.cairo(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.foreground,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: statusColor.withOpacity(0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_getStatusIcon(), size: 16, color: statusColor),
                          const SizedBox(width: 6),
                          Text(
                            _statusLabel(isAr),
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 16,
                      color: AppColors.mutedForeground,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isAr
                          ? (itemCount == 1 ? 'منتج واحد' : '$itemCount منتجات')
                          : (itemCount == 1 ? '1 item' : '$itemCount items'),
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (order.items.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.border.withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      isAr ? 'لا تفاصيل للمنتجات' : 'No line items',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  )
                else
                  ...order.items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.border.withOpacity(0.45),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.border.withOpacity(0.4),
                                ),
                              ),
                              child: item.product.imageUrl.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(11),
                                      child: Image.network(
                                        item.product.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Icon(
                                          Icons.medical_services_rounded,
                                          size: 22,
                                          color: AppColors.primary
                                              .withOpacity(0.35),
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      Icons.medical_services_rounded,
                                      size: 22,
                                      color:
                                          AppColors.primary.withOpacity(0.35),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isAr
                                        ? item.product.nameAr
                                        : item.product.name,
                                    style: GoogleFonts.cairo(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.foreground,
                                      height: 1.25,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isAr
                                        ? 'الكمية: ${item.quantity}'
                                        : 'Qty ${item.quantity}',
                                    style: GoogleFonts.cairo(
                                      fontSize: 11.5,
                                      color: AppColors.mutedForeground,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    );
                  }),
                // if (shipping.isNotEmpty) ...[
                //   const SizedBox(height: 6),
                //   Row(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Padding(
                //         padding: const EdgeInsets.only(top: 2),
                //         child: Icon(
                //           Icons.location_on_outlined,
                //           size: 18,
                //           color: AppColors.mutedForeground,
                //         ),
                //       ),
                //       const SizedBox(width: 8),
                //       Expanded(
                //         child: Text(
                //           shipping,
                //           style: GoogleFonts.cairo(
                //             fontSize: 12,
                //             height: 1.35,
                //             color: AppColors.mutedForeground,
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ],
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lavenderLight.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 16,
                        color: AppColors.primary.withOpacity(0.9),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(order.createdAt),
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.foreground,
                        ),
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            isAr ? 'الإجمالي' : 'Total',
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.mutedForeground,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isAr
                                ? '${order.totalAmount.toInt()} ج.م'
                                : 'EGP ${order.totalAmount.toInt()}',
                            style: GoogleFonts.cairo(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (_effectiveStatus == 'SHIPPED' ||
                    _effectiveStatus == 'OVERDUE') ...[
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: _effectiveStatus == 'OVERDUE' ? 0.85 : 0.6,
                      backgroundColor: AppColors.muted,
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _effectiveStatus == 'OVERDUE'
                        ? (isAr
                            ? 'الطلب متأخر عن موعده'
                            : 'Order delivery is overdue')
                        : (isAr
                            ? 'الطلب في الطريق إليك'
                            : 'Your order is on its way'),
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                  if (onMarkReceived != null) ...[
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: isMarkingReceived ? null : onMarkReceived,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              AppColors.success.withOpacity(0.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isMarkingReceived
                            ? SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.inventory_2_outlined,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    order.isRental
                                        ? (isAr
                                            ? 'تأكيد استلام الإيجار'
                                            : 'Mark rental as received')
                                        : (isAr
                                            ? 'تأكيد استلام الطلب'
                                            : 'Mark order as received'),
                                    style: GoogleFonts.cairo(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ],
                if (_effectiveStatus == 'PROCESSING' ||
                    _effectiveStatus == 'PENDING') ...[
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: _effectiveStatus == 'PENDING' ? 0.22 : 0.38,
                      backgroundColor: AppColors.muted,
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isAr ? 'جاري تجهيز الطلب' : 'Order is being prepared',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
