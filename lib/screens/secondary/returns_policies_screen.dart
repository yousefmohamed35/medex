import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design/app_colors.dart';
import '../../core/navigation/route_names.dart';

class ReturnsPoliciesScreen extends StatefulWidget {
  const ReturnsPoliciesScreen({super.key, this.initialExpandedIndex});

  /// When opened from the hub list, expand this section only.
  final int? initialExpandedIndex;

  @override
  State<ReturnsPoliciesScreen> createState() => _ReturnsPoliciesScreenState();
}

class _ReturnsPoliciesScreenState extends State<ReturnsPoliciesScreen> {
  late final List<bool> _open;

  @override
  void initState() {
    super.initState();
    final n = _policies.length;
    _open = List<bool>.filled(n, false);
    final i = widget.initialExpandedIndex;
    if (i != null && i >= 0 && i < n) {
      _open[i] = true;
    } else {
      // Demo default: first two expanded (matches second mock)
      if (n >= 2) {
        _open[0] = true;
        _open[1] = true;
      }
    }
  }

  void _back(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.returnsExchanges);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EAEF),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 56,
        leading: Center(
          child: GestureDetector(
            onTap: () => _back(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
            ),
          ),
        ),
        title: Text(
          'Policies',
          style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
        itemCount: _policies.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final p = _policies[index];
          final expanded = _open[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE4E7EC)),
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: () => setState(() => _open[index] = !expanded),
                  borderRadius: BorderRadius.vertical(
                    top: const Radius.circular(14),
                    bottom: Radius.circular(expanded ? 0 : 14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    child: Row(
                      children: [
                        Text(p.emoji, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            p.title,
                            style: GoogleFonts.cairo(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF101828),
                            ),
                          ),
                        ),
                        Icon(
                          expanded
                              ? Icons.expand_more_rounded
                              : Icons.chevron_right_rounded,
                          color: Colors.grey.shade400,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
                if (expanded) ...[
                  const Divider(height: 1, color: Color(0xFFE4E7EC)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: p.bullets.map(_bullet).toList(),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, right: 10),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.cairo(
                fontSize: 13.5,
                height: 1.45,
                color: const Color(0xFF475467),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class _Policy {
  const _Policy({
    required this.emoji,
    required this.title,
    required this.bullets,
  });

  final String emoji;
  final String title;
  final List<String> bullets;
}

const List<_Policy> _policies = [
  _Policy(
    emoji: '📦',
    title: 'Returns Policy',
    bullets: [
      'Returns accepted within 7 days of delivery',
      'Product must be unopened and in original packaging',
      'Proof of purchase required',
      'Sterile items are non-returnable once opened',
      'Contact support@medex.com to initiate',
    ],
  ),
  _Policy(
    emoji: '🔄',
    title: 'Exchange Policy',
    bullets: [
      'Exchanges for wrong item or factory defect',
      'Exchange request within 14 days',
      'Medex covers shipping for defective items',
      'Size/type exchanges subject to availability',
    ],
  ),
  _Policy(
    emoji: '🚚',
    title: 'Shipping Policy',
    bullets: [
      'Orders processed within 1–2 business days',
      'Tracking sent by email once shipped',
      'International duties may apply',
      'Damaged shipments: report within 48 hours with photos',
    ],
  ),
  _Policy(
    emoji: '💳',
    title: 'Payment Terms',
    bullets: [
      'Major cards and local payment methods accepted',
      'Prices in EGP unless stated otherwise',
      'Invoices available in your account area',
      'Refunds follow the returns timeline after inspection',
    ],
  ),
  _Policy(
    emoji: '🛡️',
    title: 'Warranty',
    bullets: [
      'Manufacturer warranty applies per product leaflet',
      'Register serial numbers where required',
      'Warranty void if misuse or non-clinical use',
      'Claims handled through official Medex channels only',
    ],
  ),
  _Policy(
    emoji: '📄',
    title: 'General Terms & Conditions',
    bullets: [
      'Use of the Medex platform implies acceptance of these terms',
      'Product information is for professional use',
      'Medex may update policies; continued use constitutes acceptance',
      'For disputes, contact support@medex.com',
    ],
  ),
];
