import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design/app_colors.dart';

const Color _kHubBlue = Color(0xFF0056A4);
const Color _kSectionTint = Color(0xFFECEEF1);

/// Horizontal "Product Learning Hub" strip (videos, PDFs, product education).
class HomeProductLearningHubSection extends StatelessWidget {
  const HomeProductLearningHubSection({
    super.key,
    required this.isAr,
    required this.onViewAllTap,
    this.onItemTap,
  });

  final bool isAr;
  final VoidCallback onViewAllTap;
  final void Function(int index)? onItemTap;

  @override
  Widget build(BuildContext context) {
    final items = isAr ? _itemsAr : _itemsEn;

    return Container(
      width: double.infinity,
      color: _kSectionTint,
      padding: const EdgeInsets.fromLTRB(0, 18, 0, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    isAr ? 'مركز تعلم المنتجات' : 'Product Learning Hub',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: AppColors.foreground,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: onViewAllTap,
                  child: Text(
                    isAr ? 'عرض الكل' : 'View All',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                return _LearningHubCard(
                  item: items[index],
                  onTap: () {
                    if (onItemTap != null) {
                      onItemTap!(index);
                    } else {
                      onViewAllTap();
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LearningHubCard extends StatelessWidget {
  const _LearningHubCard({
    required this.item,
    required this.onTap,
  });

  final _LearningHubItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const radius = 20.0;
    const cardWidth = 212.0;
    const cardHeight = 200.0;
    const topHeight = 102.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(radius),
                ),
                child: SizedBox(
                  height: topHeight,
                  child: ColoredBox(
                    color: item.topTint,
                    child: Center(child: item.buildIcon()),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.labelUpper,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: item.themeColor,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.foreground,
                          height: 1.22,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _HubMediaKind { video, pdf }

class _LearningHubItem {
  const _LearningHubItem({
    required this.labelUpper,
    required this.title,
    required this.themeColor,
    required this.topTint,
    required this.mediaKind,
  });

  final String labelUpper;
  final String title;
  final Color themeColor;
  final Color topTint;
  final _HubMediaKind mediaKind;

  Widget buildIcon() {
    switch (mediaKind) {
      case _HubMediaKind.video:
        return Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: themeColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: themeColor.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            Icons.play_arrow_rounded,
            size: 34,
            color: Colors.white.withValues(alpha: 0.95),
          ),
        );
      case _HubMediaKind.pdf:
        return Icon(
          Icons.description_rounded,
          size: 46,
          color: themeColor,
        );
    }
  }
}

const List<_LearningHubItem> _itemsEn = [
  _LearningHubItem(
    labelUpper: 'POINT IMPLANT',
    title: 'Surgical Overview',
    themeColor: AppColors.primary,
    topTint: Color(0xFFFFE8EA),
    mediaKind: _HubMediaKind.video,
  ),
  _LearningHubItem(
    labelUpper: 'POWERBONE',
    title: 'Graft Guide PDF',
    themeColor: _kHubBlue,
    topTint: Color(0xFFE3EEF8),
    mediaKind: _HubMediaKind.pdf,
  ),
  _LearningHubItem(
    labelUpper: 'SMARTBONE',
    title: 'Handling & Storage',
    themeColor: AppColors.primary,
    topTint: Color(0xFFF5F5F5),
    mediaKind: _HubMediaKind.video,
  ),
];

const List<_LearningHubItem> _itemsAr = [
  _LearningHubItem(
    labelUpper: 'POINT IMPLANT',
    title: 'نظرة جراحية',
    themeColor: AppColors.primary,
    topTint: Color(0xFFFFE8EA),
    mediaKind: _HubMediaKind.video,
  ),
  _LearningHubItem(
    labelUpper: 'POWERBONE',
    title: 'دليل الزرع PDF',
    themeColor: _kHubBlue,
    topTint: Color(0xFFE3EEF8),
    mediaKind: _HubMediaKind.pdf,
  ),
  _LearningHubItem(
    labelUpper: 'SMARTBONE',
    title: 'التعامل والتخزين',
    themeColor: AppColors.primary,
    topTint: Color(0xFFF5F5F5),
    mediaKind: _HubMediaKind.video,
  ),
];
