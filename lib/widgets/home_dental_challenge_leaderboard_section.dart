import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design/app_colors.dart';

/// Horizontal leaderboard-style cards shown after [HomeMedexDentalChallengeSection].
class HomeDentalChallengeLeaderboardSection extends StatelessWidget {
  const HomeDentalChallengeLeaderboardSection({
    super.key,
    required this.isAr,
    required this.onViewAllTap,
    this.onParticipantTap,
  });

  final bool isAr;
  final VoidCallback onViewAllTap;
  final void Function(int index)? onParticipantTap;

  static const Color _accentRed = Color(0xFFE61919);
  static const Color _statGray = Color(0xFF6B6B6B);
  static const Color _thumbYellow = Color(0xFFFFD719);
  static const Color _trophyBadgeBg = Color(0xFFFFD719);
  static const Color _trophyIcon = Color(0xFF141010);

  @override
  Widget build(BuildContext context) {
    final items = isAr ? _itemsAr : _itemsEn;

    return Container(
      width: double.infinity,
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                return _LeaderboardCard(
                  item: items[index],
                  thumbYellow: _thumbYellow,
                  statGray: _statGray,
                  trophyBadgeBg: _trophyBadgeBg,
                  trophyIcon: _trophyIcon,
                  isAr: isAr,
                  onTap: () {
                    if (onParticipantTap != null) {
                      onParticipantTap!(index);
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

class _LeaderboardItem {
  const _LeaderboardItem({
    required this.name,
    required this.likes,
    required this.views,
    required this.comments,
    required this.gradient,
  });

  final String name;
  final int likes;
  final int views;
  final int comments;
  final Gradient gradient;
}

final List<_LeaderboardItem> _itemsEn = [
  const _LeaderboardItem(
    name: 'Dr. Nour Khalil',
    likes: 142,
    views: 890,
    comments: 34,
    gradient: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xFF5C0A0A), Color(0xFFFF3B3B)],
    ),
  ),
  const _LeaderboardItem(
    name: 'Dr. Sami Amin',
    likes: 98,
    views: 640,
    comments: 22,
    gradient: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xFF5E2A8F), Color(0xFFE61919)],
    ),
  ),
  const _LeaderboardItem(
    name: 'Dr. Layla Hassan',
    likes: 76,
    views: 512,
    comments: 18,
    gradient: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xFF0D3B5C), Color(0xFF1E88C7)],
    ),
  ),
];

final List<_LeaderboardItem> _itemsAr = [
  const _LeaderboardItem(
    name: 'د. نور خليل',
    likes: 142,
    views: 890,
    comments: 34,
    gradient: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xFF5C0A0A), Color(0xFFFF3B3B)],
    ),
  ),
  const _LeaderboardItem(
    name: 'د. سامي أمين',
    likes: 98,
    views: 640,
    comments: 22,
    gradient: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xFF5E2A8F), Color(0xFFE61919)],
    ),
  ),
  const _LeaderboardItem(
    name: 'د. ليلى حسن',
    likes: 76,
    views: 512,
    comments: 18,
    gradient: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xFF0D3B5C), Color(0xFF1E88C7)],
    ),
  ),
];

class _LeaderboardCard extends StatelessWidget {
  const _LeaderboardCard({
    required this.item,
    required this.thumbYellow,
    required this.statGray,
    required this.trophyBadgeBg,
    required this.trophyIcon,
    required this.isAr,
    required this.onTap,
  });

  final _LeaderboardItem item;
  final Color thumbYellow;
  final Color statGray;
  final Color trophyBadgeBg;
  final Color trophyIcon;
  final bool isAr;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const radius = 28.0;
    const cardWidth = 200.0;
    const cardHeight = 200.0;
    const topHeight = 118.0;

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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 18,
                offset: const Offset(0, 8),
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
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      DecoratedBox(
                          decoration: BoxDecoration(gradient: item.gradient)),
                      PositionedDirectional(
                        top: 12,
                        end: 12,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: trophyBadgeBg,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.emoji_events_rounded,
                            color: trophyIcon,
                            size: 26,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.foreground,
                          height: 1.2,
                        ),
                        textDirection:
                            isAr ? TextDirection.rtl : TextDirection.ltr,
                      ),
                      const Spacer(),
                      _StatsRow(
                        likes: item.likes,
                        views: item.views,
                        comments: item.comments,
                        thumbYellow: thumbYellow,
                        statGray: statGray,
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

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.likes,
    required this.views,
    required this.comments,
    required this.thumbYellow,
    required this.statGray,
  });

  final int likes;
  final int views;
  final int comments;
  final Color thumbYellow;
  final Color statGray;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.thumb_up_rounded, size: 16, color: thumbYellow),
        const SizedBox(width: 4),
        Text(
          '$likes',
          style: GoogleFonts.cairo(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: statGray,
          ),
        ),
        _dot(statGray),
        Icon(Icons.visibility_rounded, size: 16, color: statGray),
        const SizedBox(width: 4),
        Text(
          '$views',
          style: GoogleFonts.cairo(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: statGray,
          ),
        ),
        _dot(statGray),
        Icon(Icons.chat_bubble_outline_rounded, size: 16, color: statGray),
        const SizedBox(width: 4),
        Text(
          '$comments',
          style: GoogleFonts.cairo(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: statGray,
          ),
        ),
      ],
    );
  }

  static Widget _dot(Color c) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Container(
          width: 3,
          height: 3,
          decoration: BoxDecoration(
              color: c.withValues(alpha: 0.45), shape: BoxShape.circle),
        ),
      );
}
