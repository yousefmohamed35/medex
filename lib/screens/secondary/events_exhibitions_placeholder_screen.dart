import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design/app_colors.dart';
import '../../core/navigation/route_names.dart';
import '../../services/events_service.dart';
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
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _events = [];
  Map<String, dynamic>? _hero;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final list = await EventsService.instance.getEvents(
        status: _showUpcoming ? 'upcoming' : 'past',
      );
      if (!mounted) return;
      setState(() {
        _events = list;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _events.isEmpty
                    ? Center(
                        child: Text(
                          _error == null
                              ? 'No events found'
                              : _error!.replaceFirst('Exception: ', ''),
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            color: const Color(0xFF667085),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadEvents,
                        color: AppColors.primary,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                          children: _buildCardsFromApi(context),
                        ),
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
              _pickLocalized('badge', fallback: 'Upcoming 2026'),
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _pickLocalized('title', fallback: 'Where Knowledge\nMeets Practice'),
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 35 / 1.6,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _pickLocalized('subtitle', fallback: 'Cairo · Alexandria · Online'),
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
              '${_pickLocalized('cta', fallback: 'Browse Events')} →',
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
          tab('Upcoming', _showUpcoming, () {
            if (_showUpcoming) return;
            setState(() => _showUpcoming = true);
            _loadEvents();
          }),
          tab('Past Events', !_showUpcoming, () {
            if (!_showUpcoming) return;
            setState(() => _showUpcoming = false);
            _loadEvents();
          }),
        ],
      ),
    );
  }

  List<Widget> _buildCardsFromApi(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return _events.map((item) {
      final eventId = item['id']?.toString() ?? '';
      final title = EventsService.pickLocalized(item, 'title', isAr,
          fallback: 'Event');
      final month = isAr
          ? (item['month_ar']?.toString() ?? item['month_en']?.toString() ?? '')
          : (item['month_en']?.toString() ?? item['month']?.toString() ?? '');
      final day = item['day']?.toString() ?? '--';
      final location = EventsService.pickLocalized(item, 'location', isAr);
      final timeText = EventsService.pickLocalized(item, 'time_text', isAr);
      final cpd = item['cpd_hours']?.toString() ?? '';
      final placeTime = [
        if (location.isNotEmpty) '📍 $location',
        if (timeText.isNotEmpty) timeText,
        if (cpd.isNotEmpty) '$cpd CPD',
      ].join(' · ');
      final tagA = EventsService.pickLocalized(item, 'tag_a', isAr);
      final tagB = EventsService.pickLocalized(item, 'tag_b', isAr);
      final headerA = _parseHexColor(
          item['header_gradient_a']?.toString(), const Color(0xFFFF243A));
      final headerB = _parseHexColor(
          item['header_gradient_b']?.toString(), const Color(0xFFFF5760));
      final showCalendar = item['show_add_to_calendar'] == true;
      return _EventCard(
        day: day,
        month: month,
        title: title,
        placeTime: placeTime,
        tagA: tagA.isEmpty ? (isAr ? 'فعالية' : 'Event') : tagA,
        tagB: tagB.isEmpty ? null : tagB,
        headerA: headerA,
        headerB: headerB,
        calendar: showCalendar,
        onRegister: () => _openDetails(eventId, item, isAr),
        onCalendar: showCalendar ? () => _addToCalendar(eventId) : null,
      );
    }).toList();
  }

  void _openDetails(String eventId, Map<String, dynamic> item, bool isAr) {
    if (eventId.isEmpty) return;
    final args = EventDetailArgs(
      id: eventId,
      day: item['day']?.toString() ?? '',
      monthYear: isAr
          ? (item['month_ar']?.toString() ?? item['month_en']?.toString() ?? '')
          : (item['month_en']?.toString() ?? item['month']?.toString() ?? ''),
      title: EventsService.pickLocalized(item, 'title', isAr, fallback: 'Event'),
      location: EventsService.pickLocalized(item, 'location', isAr),
      timeRange: EventsService.pickLocalized(item, 'time_text', isAr),
      cpdHours: item['cpd_hours'] != null ? '${item['cpd_hours']} CPD Hours' : '',
      attendees: item['attendees_expected'] != null
          ? '${item['attendees_expected']}+ Attendees Expected'
          : '',
      aboutBody: '',
      expectations: const [],
      showAddToCalendar: item['show_add_to_calendar'] == true,
      registrationOpen: item['registration_open'] != false,
    );
    context.push(RouteNames.eventDetails, extra: args);
  }

  Future<void> _addToCalendar(String eventId) async {
    if (eventId.isEmpty) return;
    try {
      final result = await EventsService.instance.addToCalendar(eventId);
      if (!mounted) return;
      final link =
          result['calendar_url']?.toString() ?? result['ics_url']?.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            link != null && link.isNotEmpty
                ? 'Calendar link created'
                : 'Added to calendar',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Color _parseHexColor(String? raw, Color fallback) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) return fallback;
    var hex = value.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    final intColor = int.tryParse(hex, radix: 16);
    if (intColor == null) return fallback;
    return Color(intColor);
  }

  String _pickLocalized(String baseKey, {required String fallback}) {
    if (_hero == null) return fallback;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return EventsService.pickLocalized(_hero!, baseKey, isAr, fallback: fallback);
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
  final VoidCallback? onCalendar;

  const _EventCard({
    required this.day,
    required this.month,
    required this.title,
    required this.placeTime,
    required this.tagA,
    required this.headerA,
    required this.headerB,
    required this.onRegister,
    this.onCalendar,
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
                          onTap: onCalendar,
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
