import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design/app_colors.dart';
import '../../core/navigation/route_names.dart';
import 'event_details_screen.dart';

class EventsExhibitionsPlaceholderScreen extends StatefulWidget {
  const EventsExhibitionsPlaceholderScreen({super.key});

  @override
  State<EventsExhibitionsPlaceholderScreen> createState() =>
      _EventsExhibitionsPlaceholderScreenState();
}

class _EventsExhibitionsPlaceholderScreenState
    extends State<EventsExhibitionsPlaceholderScreen> {
  bool _showUpcoming = true;

  void _handleBack() {
    if (Navigator.of(context).canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7E9EE),
      body: Column(
        children: [
          _buildHeader(),
          _buildHero(),
          _buildTabs(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
              children: _showUpcoming ? _buildUpcomingCards(context) : _buildPastCards(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
          child: Row(
            children: [
              GestureDetector(
                onTap: _handleBack,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 16),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Events & Exhibitions',
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
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '🗓 Upcoming 2025',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Where Knowledge\nMeets Practice',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 35 / 1.6,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '📍 Cairo · Alexandria · Online',
            style: GoogleFonts.cairo(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.55)),
              color: Colors.white.withValues(alpha: 0.1),
            ),
            child: Text(
              'Browse Events →',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 20 / 1.6,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    Widget tab(String text, bool selected, VoidCallback onTap) {
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 36,
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                text,
                style: GoogleFonts.cairo(
                  fontSize: 16 / 1.2,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : const Color(0xFF98A2B3),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 2),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD7DBE3)),
      ),
      child: Row(
        children: [
          tab('Upcoming', _showUpcoming, () => setState(() => _showUpcoming = true)),
          tab('Past Events', !_showUpcoming, () => setState(() => _showUpcoming = false)),
        ],
      ),
    );
  }

  List<Widget> _buildUpcomingCards(BuildContext context) {
    void go(EventDetailArgs args) {
      context.push(RouteNames.eventDetails, extra: args);
    }

    return [
      _EventCard(
        day: '22',
        month: 'MAY',
        title: 'Cairo International Implant Symposium',
        placeTime: '📍 Marriott Cairo · 9:00 AM – 6:00 PM · 8 CPD',
        tagA: 'Straumann Sponsored',
        tagB: '120 seats left',
        headerA: const Color(0xFFFF243A),
        headerB: const Color(0xFFFF5760),
        calendar: true,
        onRegister: () => go(EventDetailArgs.cairoSymposium()),
      ),
      _EventCard(
        day: '08',
        month: 'JUN',
        title: 'Live Surgery Workshop – Immediate Loading',
        placeTime: '📍 Medex Training Center · 5 CPD',
        tagA: 'Limited 20 seats',
        headerA: const Color(0xFF4B0D17),
        headerB: const Color(0xFFCC001B),
        onRegister: () => go(EventDetailArgs.liveSurgery()),
      ),
      _EventCard(
        day: '15',
        month: 'JUL',
        title: 'Prosthetic Planning Masterclass',
        placeTime: '📍 Alexandria Hub · 7 CPD',
        tagA: 'Early bird open',
        headerA: const Color(0xFF103E75),
        headerB: const Color(0xFF1E6E9E),
        onRegister: () => go(EventDetailArgs.prostheticMasterclass()),
      ),
    ];
  }

  List<Widget> _buildPastCards(BuildContext context) {
    void go(EventDetailArgs args) {
      context.push(RouteNames.eventDetails, extra: args);
    }

    return [
      _EventCard(
        day: '12',
        month: 'MAR',
        title: 'Digital Workflow Essentials',
        placeTime: '📍 Online Event · Completed',
        tagA: 'Replay available',
        headerA: const Color(0xFF455467),
        headerB: const Color(0xFF6B7A8D),
        onRegister: () => go(EventDetailArgs.digitalWorkflow()),
      ),
      _EventCard(
        day: '04',
        month: 'FEB',
        title: 'Bone Grafting Protocol Update',
        placeTime: '📍 Cairo Branch · Completed',
        tagA: 'Certificate issued',
        headerA: const Color(0xFF4E4954),
        headerB: const Color(0xFF776D7D),
        onRegister: () => go(EventDetailArgs.boneGrafting()),
      ),
    ];
  }
}

class _EventCard extends StatelessWidget {
  final String day;
  final String month;
  final String title;
  final String placeTime;
  final String tagA;
  final String? tagB;
  final Color headerA;
  final Color headerB;
  final bool calendar;
  final VoidCallback onRegister;

  const _EventCard({
    required this.day,
    required this.month,
    required this.title,
    required this.placeTime,
    required this.tagA,
    required this.headerA,
    required this.headerB,
    required this.onRegister,
    this.tagB,
    this.calendar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD7DBE3)),
      ),
      child: Column(
        children: [
          Container(
            height: 96,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [headerA, headerB]),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 12,
                  top: 8,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(day,
                            style: GoogleFonts.cairo(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 22 / 1.6)),
                        Text(month,
                            style: GoogleFonts.cairo(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 11)),
                      ],
                    ),
                  ),
                ),
                const Center(
                    child: Icon(Icons.circle_outlined,
                        color: Colors.white70, size: 36)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.cairo(
                        fontSize: 17 / 1.2, fontWeight: FontWeight.w800)),
                Text(placeTime,
                    style: GoogleFonts.cairo(
                        fontSize: 12.5, color: const Color(0xFF475467))),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _tag(tagA),
                    if (tagB != null) ...[
                      const SizedBox(width: 8),
                      _tag(tagB!),
                    ]
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onRegister,
                          borderRadius: BorderRadius.circular(11),
                          child: Ink(
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Center(
                              child: Text('Register Now →',
                                  style: GoogleFonts.cairo(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15 / 1.2)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (calendar) ...[
                      const SizedBox(width: 8),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Added to calendar — coming soon')),
                            );
                          },
                          borderRadius: BorderRadius.circular(11),
                          child: Ink(
                            width: 112,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7EDED),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Center(
                              child: Text('+ Calendar',
                                  style: GoogleFonts.cairo(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15 / 1.2)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _tag(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFF1E8EA),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(text,
            style: GoogleFonts.cairo(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 11)),
      );
}
