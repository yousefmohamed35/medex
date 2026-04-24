import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design/app_colors.dart';
import '../../core/navigation/route_names.dart';

/// Passed via `context.push(RouteNames.eventDetails, extra: args)`.
class EventDetailArgs {
  const EventDetailArgs({
    required this.day,
    required this.monthYear,
    required this.title,
    required this.location,
    required this.timeRange,
    required this.cpdHours,
    required this.attendees,
    required this.aboutBody,
    required this.expectations,
  });

  final String day;
  final String monthYear;
  final String title;
  final String location;
  final String timeRange;
  final String cpdHours;
  final String attendees;
  final String aboutBody;
  final List<String> expectations;

  static EventDetailArgs cairoSymposium() => const EventDetailArgs(
        day: '22',
        monthYear: 'MAY 2025',
        title: 'Cairo International Implant Symposium',
        location: 'Marriott Hotel Cairo, Egypt',
        timeRange: '9:00 AM – 6:00 PM',
        cpdHours: '8 CPD Hours',
        attendees: '500+ Attendees Expected',
        aboutBody:
            'The Cairo International Implant Symposium brings together leading implantologists, prosthodontists, and dental educators for a full day of case presentations, live surgeries, and hands-on workshops.',
        expectations: [
          '6 keynote speakers from 4 countries',
          'Live implant surgery demonstrations',
          'Hands-on workshop stations',
          'Industry exhibition floor',
          'Certificate of attendance',
        ],
      );

  static EventDetailArgs liveSurgery() => const EventDetailArgs(
        day: '08',
        monthYear: 'JUN 2025',
        title: 'Live Surgery Workshop – Immediate Loading',
        location: 'Medex Training Center, Cairo',
        timeRange: '10:00 AM – 4:00 PM',
        cpdHours: '5 CPD Hours',
        attendees: '20 Seats · Limited',
        aboutBody:
            'An intensive hands-on workshop focused on immediate loading protocols, case selection, and prosthetic steps with live demonstrations.',
        expectations: [
          'Live surgery observation',
          'Q&A with surgical team',
          'Printed protocol booklet',
          'CPD certificate',
        ],
      );

  static EventDetailArgs prostheticMasterclass() => const EventDetailArgs(
        day: '15',
        monthYear: 'JUL 2025',
        title: 'Prosthetic Planning Masterclass',
        location: 'Alexandria Hub, Egypt',
        timeRange: '9:00 AM – 5:00 PM',
        cpdHours: '7 CPD Hours',
        attendees: '150+ Attendees Expected',
        aboutBody:
            'Deep dive into digital and analog prosthetic planning for complex implant cases with expert-led sessions.',
        expectations: [
          'Digital workflow demos',
          'Case planning breakout',
          'Materials exhibition',
          'Networking lunch',
          'Certificate of attendance',
        ],
      );

  static EventDetailArgs digitalWorkflow() => const EventDetailArgs(
        day: '12',
        monthYear: 'MAR 2025',
        title: 'Digital Workflow Essentials',
        location: 'Online Event',
        timeRange: 'Recorded sessions',
        cpdHours: '4 CPD Hours',
        attendees: '1,200+ Registered',
        aboutBody:
            'On-demand sessions covering scanning, design, and manufacturing workflows for the modern dental practice.',
        expectations: [
          'Lifetime replay access',
          'Downloadable resources',
          'CPD certificate',
        ],
      );

  static EventDetailArgs boneGrafting() => const EventDetailArgs(
        day: '04',
        monthYear: 'FEB 2025',
        title: 'Bone Grafting Protocol Update',
        location: 'Cairo Branch, Egypt',
        timeRange: 'Full day',
        cpdHours: '6 CPD Hours',
        attendees: 'Completed',
        aboutBody:
            'Review of contemporary bone grafting materials and surgical protocols with case discussions.',
        expectations: [
          'Expert panel',
          'Case reviews',
          'Certificate issued',
        ],
      );
}

class EventDetailsScreen extends StatelessWidget {
  const EventDetailsScreen({super.key, this.args});

  final EventDetailArgs? args;

  EventDetailArgs get _data => args ?? EventDetailArgs.cairoSymposium();

  void _handleBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.eventsExhibitions);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = _data;
    return Scaffold(
      backgroundColor: const Color(0xFFF0F1F5),
      body: Column(
        children: [
          _AppBar(onBack: () => _handleBack(context)),
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 88),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Banner(day: d.day, monthYear: d.monthYear),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 36, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              d.title,
                              style: GoogleFonts.cairo(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF101828),
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _DetailRow(
                              icon: Icons.location_on_rounded,
                              iconColor: AppColors.primary,
                              text: d.location,
                            ),
                            const SizedBox(height: 12),
                            _DetailRow(
                              icon: Icons.schedule_rounded,
                              iconColor: const Color(0xFF667085),
                              text: d.timeRange,
                            ),
                            const SizedBox(height: 12),
                            _DetailRow(
                              icon: Icons.school_outlined,
                              iconColor: const Color(0xFF667085),
                              text: d.cpdHours,
                            ),
                            const SizedBox(height: 12),
                            _DetailRow(
                              icon: Icons.videocam_outlined,
                              iconColor: const Color(0xFF667085),
                              text: d.attendees,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'About the Event',
                              style: GoogleFonts.cairo(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF101828),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              d.aboutBody,
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                height: 1.5,
                                color: const Color(0xFF475467),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'What to Expect',
                              style: GoogleFonts.cairo(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF101828),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...d.expectations.map(
                              (line) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 22,
                                      height: 22,
                                      margin: const EdgeInsets.only(top: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF16A34A),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: const Icon(
                                        Icons.check_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        line,
                                        style: GoogleFonts.cairo(
                                          fontSize: 14,
                                          height: 1.45,
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
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _BottomActions(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
          child: Row(
            children: [
              GestureDetector(
                onTap: onBack,
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
                'Event Details',
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
}

class _Banner extends StatelessWidget {
  const _Banner({required this.day, required this.monthYear});

  final String day;
  final String monthYear;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 212,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomLeft,
        children: [
          Positioned.fill(
            child: Container(color: AppColors.primary),
          ),
          Positioned(
            left: 16,
            bottom: 0,
            child: Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day,
                  style: GoogleFonts.cairo(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  monthYear,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF344054),
                    letterSpacing: 0.5,
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
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.text,
    this.iconColor = const Color(0xFF667085),
  });

  final IconData icon;
  final Color iconColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 14,
              height: 1.35,
              color: const Color(0xFF475467),
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF0F1F5),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Expanded(
                flex: 13,
                child: SizedBox(
                  height: 48,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Registration — coming soon')),
                      );
                    },
                    child: Text(
                      'Register Now →',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 7,
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Calendar — coming soon')),
                      );
                    },
                    child: Text(
                      '+ Calendar',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
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
