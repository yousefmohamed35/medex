import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Profile header: solid red hero, left-aligned identity, overlapping stat cards.
class ProfileHeroHeader extends StatelessWidget {
  const ProfileHeroHeader({
    super.key,
    required this.name,
    required this.roleLine,
    required this.memberIdDisplay,
    required this.initials,
    this.avatarUrl,
    required this.statCourses,
    required this.statCertificates,
    required this.statLearningHours,
    required this.statOrders,
    this.goldMemberLabel = 'Gold Member',
    this.discountLabel = '15% OFF',
    this.isLoading = false,
  });

  /// Spec red (distinct from app primary for this header).
  static const Color headerRed = Color(0xFFE30613);

  final String name;
  final String roleLine;
  final String memberIdDisplay;
  final String initials;
  final String? avatarUrl;
  final int statCourses;
  final int statCertificates;
  final int statLearningHours;
  final int statOrders;
  final String goldMemberLabel;
  final String discountLabel;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          color: headerRed,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 12, 56),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  if (isLoading)
                    SizedBox(
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.white.withValues(alpha: 0.9),
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  else ...[
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: _Avatar(
                        initials: initials,
                        avatarUrl: avatarUrl,
                        headerRed: headerRed,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      name,
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      roleLine,
                      style: GoogleFonts.cairo(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.workspace_premium_rounded,
                              color: Color(0xFFFFD700),
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              goldMemberLabel,
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD84D),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                discountLabel,
                                style: GoogleFonts.cairo(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      memberIdDisplay,
                      style: GoogleFonts.cairo(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 12,
          right: 12,
          bottom: -36,
          child: Row(
            children: [
              Expanded(
                child: _StatCard(
                  value: '$statCourses',
                  label: 'Courses',
                  headerRed: headerRed,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  value: '$statCertificates',
                  label: 'Certificates',
                  headerRed: headerRed,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  value: '${statLearningHours}h',
                  label: 'Learning',
                  headerRed: headerRed,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  value: '$statOrders',
                  label: 'Orders',
                  headerRed: headerRed,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.initials,
    required this.avatarUrl,
    required this.headerRed,
  });

  final String initials;
  final String? avatarUrl;
  final Color headerRed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: avatarUrl != null && avatarUrl!.isNotEmpty
          ? Image.network(
              avatarUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Center(
                child: Text(
                  initials,
                  style: GoogleFonts.cairo(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: headerRed,
                  ),
                ),
              ),
            )
          : Center(
              child: Text(
                initials,
                style: GoogleFonts.cairo(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: headerRed,
                ),
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.headerRed,
  });

  final String value;
  final String label;
  final Color headerRed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: headerRed,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF667085),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
