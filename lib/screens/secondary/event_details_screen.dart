import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design/app_colors.dart';
import '../../core/navigation/route_names.dart';
import '../../services/events_service.dart';

/// Passed via `context.push(RouteNames.eventDetails, extra: args)`.
class EventDetailArgs {
  const EventDetailArgs({
    required this.id,
    required this.day,
    required this.monthYear,
    required this.title,
    required this.location,
    required this.timeRange,
    required this.cpdHours,
    required this.attendees,
    required this.aboutBody,
    required this.expectations,
    this.showAddToCalendar = true,
    this.registrationOpen = true,
  });

  final String id;
  final String day;
  final String monthYear;
  final String title;
  final String location;
  final String timeRange;
  final String cpdHours;
  final String attendees;
  final String aboutBody;
  final List<String> expectations;
  final bool showAddToCalendar;
  final bool registrationOpen;
}

class EventDetailsScreen extends StatefulWidget {
  const EventDetailsScreen({super.key, this.args});

  final EventDetailArgs? args;

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  bool _loading = true;
  bool _submittingRegistration = false;
  bool _submittingCalendar = false;
  String? _error;
  Map<String, dynamic>? _detailRaw;

  EventDetailArgs get _seed => widget.args ??
      const EventDetailArgs(
        id: '',
        day: '',
        monthYear: '',
        title: 'Event Details',
        location: '',
        timeRange: '',
        cpdHours: '',
        attendees: '',
        aboutBody: '',
        expectations: <String>[],
      );

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final id = _seed.id.trim();
    if (id.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final details = await EventsService.instance.getEventDetail(id);
      if (!mounted) return;
      setState(() {
        _detailRaw = details;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _handleBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.eventsExhibitions);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = _resolvedData(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF0F1F5),
      body: Column(
        children: [
          _AppBar(onBack: () => _handleBack(context)),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : Stack(
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
                            if (_error != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  _error!.replaceFirst('Exception: ', ''),
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    color: const Color(0xFFB42318),
                                    fontWeight: FontWeight.w700,
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
                  child: _BottomActions(
                    showCalendar: d.showAddToCalendar,
                    registrationEnabled:
                        d.registrationOpen && !_submittingRegistration,
                    calendarEnabled: !_submittingCalendar,
                    onRegister: _register,
                    onCalendar: _addToCalendar,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  EventDetailArgs _resolvedData(BuildContext context) {
    final raw = _detailRaw;
    if (raw == null) return _seed;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final expectationsRaw = (isAr ? raw['expectations_ar'] : raw['expectations_en']) ??
        raw['expectations'];
    final expectations = expectationsRaw is List
        ? expectationsRaw.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList()
        : _seed.expectations;
    return EventDetailArgs(
      id: raw['id']?.toString() ?? _seed.id,
      day: raw['day']?.toString() ?? _seed.day,
      monthYear: isAr
          ? (raw['month_year_ar']?.toString() ??
              raw['month_year_en']?.toString() ??
              _seed.monthYear)
          : (raw['month_year_en']?.toString() ??
              raw['month_year']?.toString() ??
              _seed.monthYear),
      title: EventsService.pickLocalized(raw, 'title', isAr, fallback: _seed.title),
      location: EventsService.pickLocalized(raw, 'location', isAr,
          fallback: _seed.location),
      timeRange: EventsService.pickLocalized(raw, 'time_range', isAr,
          fallback: _seed.timeRange),
      cpdHours: EventsService.pickLocalized(raw, 'cpd_hours_text', isAr,
          fallback: _seed.cpdHours),
      attendees: EventsService.pickLocalized(raw, 'attendees_text', isAr,
          fallback: _seed.attendees),
      aboutBody: EventsService.pickLocalized(raw, 'about_body', isAr,
          fallback: _seed.aboutBody),
      expectations: expectations,
      showAddToCalendar: raw['show_add_to_calendar'] != false,
      registrationOpen: raw['registration_open'] != false,
    );
  }

  Future<void> _register() async {
    final id = _resolvedData(context).id.trim();
    if (id.isEmpty) return;
    setState(() => _submittingRegistration = true);
    try {
      await EventsService.instance.registerForEvent(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration completed')),
      );
      await _loadDetails();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _submittingRegistration = false);
    }
  }

  Future<void> _addToCalendar() async {
    final id = _resolvedData(context).id.trim();
    if (id.isEmpty) return;
    setState(() => _submittingCalendar = true);
    try {
      await EventsService.instance.addToCalendar(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Calendar link created')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _submittingCalendar = false);
    }
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
  const _BottomActions({
    required this.showCalendar,
    required this.registrationEnabled,
    required this.calendarEnabled,
    required this.onRegister,
    required this.onCalendar,
  });

  final bool showCalendar;
  final bool registrationEnabled;
  final bool calendarEnabled;
  final VoidCallback onRegister;
  final VoidCallback onCalendar;

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
                    onPressed: registrationEnabled ? onRegister : null,
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
              if (showCalendar) ...[
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
                      onPressed: calendarEnabled ? onCalendar : null,
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
            ],
          ),
        ),
      ),
    );
  }
}
