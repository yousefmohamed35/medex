import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Bundle tier for B&B × Medex implant offer (shared list + detail UIs).
class BbImplantBundle {
  const BbImplantBundle({
    required this.offerLabel,
    required this.implant,
    required this.abutment,
    required this.kit,
    required this.offerValue,
    required this.unitPrice,
  });

  final String offerLabel;
  final String implant;
  final String abutment;
  final String kit;
  final String offerValue;
  final String unitPrice;
}

const List<BbImplantBundle> kBbImplantBundlesRow1 = [
  BbImplantBundle(
    offerLabel: 'Offer 1',
    implant: '1',
    abutment: '1',
    kit: '-',
    offerValue: '4.100',
    unitPrice: '4.100',
  ),
  BbImplantBundle(
    offerLabel: 'Offer 5',
    implant: '5',
    abutment: '5',
    kit: '-',
    offerValue: '19.500',
    unitPrice: '3.900',
  ),
  BbImplantBundle(
    offerLabel: 'Offer 10',
    implant: '10',
    abutment: '10',
    kit: '-',
    offerValue: '38.000',
    unitPrice: '3.800',
  ),
];

const List<BbImplantBundle> kBbImplantBundlesRow2 = [
  BbImplantBundle(
    offerLabel: 'Offer 35',
    implant: '35',
    abutment: '35',
    kit: '1',
    offerValue: '140.000',
    unitPrice: '4.000',
  ),
  BbImplantBundle(
    offerLabel: 'Offer 50',
    implant: '50',
    abutment: '50',
    kit: '1',
    offerValue: '175.000',
    unitPrice: '3.500',
  ),
  BbImplantBundle(
    offerLabel: 'Offer 100',
    implant: '100',
    abutment: '100',
    kit: '1',
    offerValue: '335.000',
    unitPrice: '3.350',
  ),
];

/// Styling for offer column headers in list preview vs full detail screen.
enum BbImplantOfferGridTheme {
  /// Light grey header band, dark text (offers list card).
  listCard,

  /// Dark header, white text (offer detail mock).
  detailScreen,
}

class BbImplantOfferGrid extends StatelessWidget {
  const BbImplantOfferGrid({
    super.key,
    this.theme = BbImplantOfferGridTheme.listCard,
  });

  final BbImplantOfferGridTheme theme;

  static const Color _flyerRed = Color(0xFFD90E1C);
  static const Color _headerGrey = Color(0xFF4B5563);
  static const Color _detailHeaderBg = Color(0xFF374151);

  bool get _isDetail => theme == BbImplantOfferGridTheme.detailScreen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: kBbImplantBundlesRow1
                .map((b) => Expanded(child: _bundleCell(b)))
                .toList(),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: kBbImplantBundlesRow2
                .map((b) => Expanded(child: _bundleCell(b)))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _bundleCell(BbImplantBundle b) {
    final headerBg = _isDetail ? _detailHeaderBg : const Color(0xFFF3F4F6);
    final headerFg = _isDetail ? Colors.white : _headerGrey;
    final kitLabel = _isDetail ? 'Kit' : 'Surgical Kit';
    final valueLabel = _isDetail ? 'Value' : 'Offer Value';
    final unitLabel = _isDetail ? 'Unit' : 'Unit Price';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFD1D5DB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: _isDetail ? 5 : 4),
              decoration: BoxDecoration(
                color: headerBg,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(5)),
              ),
              child: Text(
                b.offerLabel,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: _isDetail ? 9.5 : 9,
                  fontWeight: FontWeight.w800,
                  color: headerFg,
                ),
              ),
            ),
            _specRow('Implant', b.implant),
            _specRow('Abutment', b.abutment),
            _specRow(kitLabel, b.kit),
            _specRow(valueLabel, b.offerValue, valueColor: _flyerRed),
            _specRow(unitLabel, b.unitPrice,
                valueColor: const Color(0xFF16A34A)),
          ],
        ),
      ),
    );
  }

  Widget _specRow(String label, String value, {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 11,
            child: Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: _isDetail ? 8 : 7.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            flex: 10,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.cairo(
                fontSize: _isDetail ? 8 : 7.5,
                fontWeight: FontWeight.w800,
                color: valueColor ?? const Color(0xFF111827),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
