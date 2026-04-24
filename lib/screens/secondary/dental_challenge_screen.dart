import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design/app_colors.dart';
import '../../core/navigation/route_names.dart';

class DentalChallengeScreen extends StatefulWidget {
  const DentalChallengeScreen({super.key});

  @override
  State<DentalChallengeScreen> createState() => _DentalChallengeScreenState();
}

class _DentalChallengeScreenState extends State<DentalChallengeScreen> {
  final _titleController = TextEditingController(text: '');
  String _implantBrand = 'B&B Implant';

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _back() {
    if (Navigator.of(context).canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F1F5),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildRedAppBar()),
          SliverToBoxAdapter(child: _buildHero()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _rulesCard(),
                const SizedBox(height: 20),
                _howToParticipate(),
                const SizedBox(height: 20),
                _prizesCard(),
                const SizedBox(height: 16),
                _submitCard(context),
                const SizedBox(height: 20),
                _winnersCard(),
                const SizedBox(height: 20),
                _gallerySection(context),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRedAppBar() {
    return Container(
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
          child: Row(
            children: [
              GestureDetector(
                onTap: _back,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Dental Challenge',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A0A0C),
            Color(0xFF121214),
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WEEK 18 — 2025',
            style: GoogleFonts.cairo(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Best Implant Case\nof the Month',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Win free implants + accessories + certificate',
            style: GoogleFonts.cairo(
              color: Colors.white.withValues(alpha: 0.88),
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _statBox(
                  top: '3d 14h',
                  bottom: 'REMAINING',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _statBox(
                  top: '48',
                  bottom: 'SUBMISSIONS',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _statBox(
                  top: '2',
                  bottom: 'WINNERS',
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 88,
                child: Material(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Joined — coming soon')),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 64,
                      alignment: Alignment.center,
                      child: Text(
                        'Join\nNow',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBox({required String top, required String bottom}) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            top,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            bottom,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              color: const Color(0xFF9CA3AF),
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _rulesCard() {
    const rules = [
      'Use Medex products only',
      'Submit real clinical case',
      'Clear Before & After photos',
      'Brief description & steps',
    ];
    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.article_outlined, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                'Challenge Rules',
                style: GoogleFonts.cairo(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF101828),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...rules.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: GoogleFonts.cairo(color: const Color(0xFF475467), fontSize: 14)),
                  Expanded(
                    child: Text(
                      r,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        height: 1.4,
                        color: const Color(0xFF475467),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _howToParticipate() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How to Participate',
          style: GoogleFonts.cairo(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF101828),
          ),
        ),
        const SizedBox(height: 10),
        _whiteCard(
          child: Column(
            children: [
              _stepRow(
                n: 1,
                title: 'Upload Your Case',
                subtitle: 'Before & After photos + X-rays',
              ),
              const Divider(height: 20, color: Color(0xFFE4E7EC)),
              _stepRow(
                n: 2,
                title: 'Add Description',
                subtitle: 'Case summary + products used',
              ),
              const Divider(height: 20, color: Color(0xFFE4E7EC)),
              _stepRow(
                n: 3,
                title: 'Submit',
                subtitle: 'Community votes via likes & comments',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepRow({
    required int n,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$n',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF101828),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.cairo(
                  fontSize: 12.5,
                  color: const Color(0xFF667085),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _prizesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD84D),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎁 Prizes',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF8B1538),
            ),
          ),
          const SizedBox(height: 12),
          _prizeLine('🦷', 'Free Dental Implant'),
          _prizeLine('📦', 'Accessories or Bone Graft'),
          _prizeLine('🏷️', 'Exclusive Discounts'),
          _prizeLine('🎓', 'Certified Certificate'),
        ],
      ),
    );
  }

  Widget _prizeLine(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF3D2914),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _submitCard(BuildContext context) {
    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Submit Your Case',
            style: GoogleFonts.cairo(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 14),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Upload — coming soon')),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 22),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFCBD2E0),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.photo_camera_outlined, size: 36, color: Color(0xFF98A2B3)),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to upload photos & X-rays',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF475467),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Max 20 photos • PDF allowed',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Case Title',
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF344054),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'e.g. Immediate All-on-4 Rehabilitation',
              hintStyle: GoogleFonts.cairo(fontSize: 13, color: const Color(0xFF98A2B3)),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
              ),
            ),
            style: GoogleFonts.cairo(fontSize: 14),
          ),
          const SizedBox(height: 14),
          Text(
            'Implant Brand Used',
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF344054),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFD0D5DD)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _implantBrand,
                style: GoogleFonts.cairo(fontSize: 14, color: const Color(0xFF101828)),
                items: const [
                  DropdownMenuItem(value: 'B&B Implant', child: Text('B&B Implant')),
                  DropdownMenuItem(value: 'Point Implant', child: Text('Point Implant')),
                  DropdownMenuItem(value: 'Powerbone', child: Text('Powerbone')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _implantBrand = v);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Case submitted — coming soon')),
                );
              },
              child: Text(
                'Submit Case →',
                style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _winnersCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E7EC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            color: const Color(0xFFFFD84D),
            child: Row(
              children: [
                const Icon(Icons.emoji_events_rounded, color: Color(0xFF8B1538), size: 22),
                const SizedBox(width: 8),
                Text(
                  "Last Week's Winners",
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF3D2914),
                  ),
                ),
              ],
            ),
          ),
          _winnerRow(rank: 1, medal: const Color(0xFFFFC107), initials: 'NK', avatarBg: AppColors.primary, name: 'Dr. Nour Khalil', sub: 'All-on-4 Immediate · Cairo', pts: '980 pts'),
          const Divider(height: 1, color: Color(0xFFE4E7EC)),
          _winnerRow(rank: 2, medal: const Color(0xFFB0BEC5), initials: 'SA', avatarBg: const Color(0xFF1E3A5F), name: 'Dr. Sami Amin', sub: 'Sinus Lift · Alexandria', pts: '870 pts'),
        ],
      ),
    );
  }

  Widget _winnerRow({
    required int rank,
    required Color medal,
    required String initials,
    required Color avatarBg,
    required String name,
    required String sub,
    required String pts,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: medal, shape: BoxShape.circle),
            child: Text(
              '$rank',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: rank == 1 ? const Color(0xFF5D3A00) : const Color(0xFF37474F),
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 20,
            backgroundColor: avatarBg,
            child: Text(
              initials,
              style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 14)),
                Text(sub, style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF667085))),
              ],
            ),
          ),
          Text(
            pts,
            style: GoogleFonts.cairo(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _gallerySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Submissions Gallery',
              style: GoogleFonts.cairo(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF101828),
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('View all — coming soon')),
                );
              },
              child: Text(
                'View All',
                style: GoogleFonts.cairo(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 168,
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            children: [
              _galleryCard(
                name: 'Dr. Nour Khalil',
                likes: 142,
                views: 890,
                comments: 34,
                gradient: const [Color(0xFF5C0A14), Color(0xFFE31E24)],
                trophy: true,
              ),
              const SizedBox(width: 12),
              _galleryCard(
                name: 'Dr. Sami Amin',
                likes: 98,
                views: 640,
                comments: 22,
                gradient: const [Color(0xFF4A1B6B), Color(0xFFC41E3A)],
                trophy: false,
              ),
              const SizedBox(width: 12),
              _galleryCard(
                name: 'Dr. Rania Fouad',
                likes: 76,
                views: 512,
                comments: 18,
                gradient: const [Color(0xFF0D2847), Color(0xFF1E5A8E)],
                trophy: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _galleryCard({
    required String name,
    required int likes,
    required int views,
    required int comments,
    required List<Color> gradient,
    required bool trophy,
  }) {
    return SizedBox(
      width: 148,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE4E7EC)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: gradient,
                        ),
                      ),
                    ),
                  ),
                  if (trophy)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFD84D),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.emoji_events, size: 16, color: Color(0xFF5D3A00)),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 12.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '👍 $likes · 👁 $views · 💬 $comments',
                    style: GoogleFonts.cairo(fontSize: 10.5, color: const Color(0xFF667085)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _whiteCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E7EC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
