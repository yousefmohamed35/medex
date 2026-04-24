import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design/app_colors.dart';

class HomeImplantCommunitySection extends StatelessWidget {
  const HomeImplantCommunitySection({
    super.key,
    required this.isAr,
    required this.onViewAllTap,
  });

  final bool isAr;
  final VoidCallback onViewAllTap;

  @override
  Widget build(BuildContext context) {
    final items = isAr ? _communityItemsAr : _communityItemsEn;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isAr ? 'مجتمع الزرعات' : 'Implant Community',
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
          height: 184,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return _CommunityCard(item: item);
            },
          ),
        ),
      ],
    );
  }
}

class _CommunityCard extends StatelessWidget {
  const _CommunityCard({required this.item});

  final _CommunityItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 296,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 122,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: item.backgroundColors,
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(17)),
            ),
            child: Center(
              child: Icon(
                item.icon,
                color: Colors.white.withOpacity(0.75),
                size: 40,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.foreground,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
            child: Text(
              item.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommunityItem {
  const _CommunityItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.backgroundColors,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> backgroundColors;
}

const List<_CommunityItem> _communityItemsEn = [
  _CommunityItem(
    title: 'Complex sinus lift case - opinions?',
    subtitle: 'Dr. Nour K. . 34 replies',
    icon: Icons.groups_2_outlined,
    backgroundColors: [Color(0xFF1F0B13), Color(0xFF5B0009)],
  ),
  _CommunityItem(
    title: 'BLX vs Nobel - which platform?',
    subtitle: 'Dr. Sami A. . 58 replies',
    icon: Icons.chat_bubble_outline_rounded,
    backgroundColors: [Color(0xFF123A72), Color(0xFF1A2E5B)],
  ),
];

const List<_CommunityItem> _communityItemsAr = [
  _CommunityItem(
    title: 'حالة رفع جيب معقدة - الآراء؟',
    subtitle: 'د. نور ك. . 34 رد',
    icon: Icons.groups_2_outlined,
    backgroundColors: [Color(0xFF1F0B13), Color(0xFF5B0009)],
  ),
  _CommunityItem(
    title: 'BLX أم Nobel - أي منصة أفضل؟',
    subtitle: 'د. سامي أ. . 58 رد',
    icon: Icons.chat_bubble_outline_rounded,
    backgroundColors: [Color(0xFF123A72), Color(0xFF1A2E5B)],
  ),
];
