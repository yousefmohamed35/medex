import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../core/design/app_colors.dart';
import '../../core/localization/localization_helper.dart';
import '../../services/notifications_service.dart';

/// Notifications — Medex-style header, filters, and cards (API + demo fallback).
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _rawNotifications = [];
  int _unreadCount = 0;
  int _filterIndex = 0;
  final Set<String> _readDemoIds = {};

  static const _filterKeys = ['all', 'orders', 'offers', 'learning', 'events'];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final response = await NotificationsService.instance.getNotifications(
        page: 1,
        perPage: 50,
        unreadOnly: false,
      );

      List<Map<String, dynamic>> notificationsList = [];
      final data = response['data'];

      if (data != null) {
        if (data is List) {
          try {
            notificationsList = data.map((item) {
              if (item is Map<String, dynamic>) return item;
              if (item is Map) return Map<String, dynamic>.from(item);
              return <String, dynamic>{};
            }).toList();
          } catch (e) {
            debugPrint('Error parsing notifications list: $e');
          }
        } else if (data is Map<String, dynamic>) {
          for (final key in ['notifications', 'items', 'list', 'data']) {
            if (data[key] is List) {
              try {
                notificationsList = (data[key] as List).map((item) {
                  if (item is Map<String, dynamic>) return item;
                  if (item is Map) return Map<String, dynamic>.from(item);
                  return <String, dynamic>{};
                }).toList();
                break;
              } catch (e) {
                debugPrint('Error parsing $key: $e');
              }
            }
          }
        }
      }

      int unreadCount = 0;
      if (response['meta'] != null && response['meta'] is Map) {
        unreadCount = (response['meta'] as Map)['unread_count'] ?? 0;
      } else if (response['data'] != null && response['data'] is Map) {
        unreadCount = (response['data'] as Map)['unread_count'] ?? 0;
      }
      if (unreadCount == 0) {
        unreadCount = notificationsList
            .where((n) => (n['is_read'] ?? true) == false)
            .length;
      }

      setState(() {
        _rawNotifications = notificationsList;
        _unreadCount = unreadCount;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      setState(() => _isLoading = false);
      if (mounted) {
        debugPrint('Error loading notifications: $e\n$stackTrace');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.errorLoadingNotifications(e.toString())),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      await NotificationsService.instance.markAsRead(notificationId);
      setState(() {
        final index = _rawNotifications.indexWhere(
          (n) => n['id']?.toString() == notificationId,
        );
        if (index != -1) {
          _rawNotifications[index]['is_read'] = true;
          _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
        }
      });
      await _loadNotifications();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.errorUpdatingNotification(e.toString())),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await NotificationsService.instance.markAllAsRead();
      setState(() {
        for (final n in _rawNotifications) {
          n['is_read'] = true;
        }
        _unreadCount = 0;
      });
      await _loadNotifications();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.errorUpdatingNotifications(e.toString())),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _back() {
    if (Navigator.of(context).canPop()) {
      context.pop();
    }
  }

  List<_NotifUi> get _items {
    if (_rawNotifications.isNotEmpty) {
      return _rawNotifications.map(_NotifUi.fromApi).toList();
    }
    return _demoNotifications.map((d) {
      final read = d.id != null && _readDemoIds.contains(d.id);
      return _NotifUi(
        id: d.id,
        title: d.title,
        body: d.body,
        category: d.category,
        unread: d.unread && !read,
        icon: d.icon,
        iconColor: d.iconColor,
        iconBg: d.iconBg,
        timeLabel: d.timeLabel,
      );
    }).toList();
  }

  void _onNotificationTap(_NotifUi n) {
    if (n.id != null && n.id!.startsWith('demo-')) {
      setState(() => _readDemoIds.add(n.id!));
      return;
    }
    if (n.id != null) _markAsRead(n.id!);
  }

  List<_NotifUi> get _filtered {
    final key = _filterKeys[_filterIndex];
    if (key == 'all') return _items;
    return _items.where((e) => e.category == key).toList();
  }

  String _formatTime(BuildContext context, String? createdAt) {
    if (createdAt == null) return context.l10n.recently;
    try {
      final date = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(date);
      if (difference.inMinutes < 1) return context.l10n.now;
      if (difference.inMinutes < 60) {
        return context.l10n.minutesAgoShort(difference.inMinutes);
      }
      if (difference.inHours < 24) {
        return context.l10n.hoursAgoShort(difference.inHours);
      }
      if (difference.inDays < 7) {
        return context.l10n.daysAgoShort(difference.inDays);
      }
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return context.l10n.recently;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final filters = isAr
        ? ['الكل', 'الطلبات', 'العروض', 'التعلم', 'الفعاليات']
        : ['All', 'Orders', 'Offers', 'Learning', 'Events'];

    return Scaffold(
      backgroundColor: const Color(0xFFE8EAEF),
      body: Column(
        children: [
          _buildHeader(context, filters),
          Expanded(
            child: _isLoading
                ? _buildSkeleton()
                : RefreshIndicator(
                    onRefresh: _loadNotifications,
                    color: AppColors.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
                      itemCount: _filtered.isEmpty ? 1 : _filtered.length,
                      itemBuilder: (context, index) {
                        if (_filtered.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 48),
                            child: Center(
                              child: Text(
                                context.l10n.noNotifications,
                                style: GoogleFonts.cairo(
                                  fontSize: 15,
                                  color: const Color(0xFF667085),
                                ),
                              ),
                            ),
                          );
                        }
                        final n = _filtered[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _NotificationCard(
                            item: n,
                            timeLabel: n.createdAt != null
                                ? _formatTime(context, n.createdAt)
                                : n.timeLabel!,
                            onTap: () => _onNotificationTap(n),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, List<String> filters) {
    final hasUnread = _unreadCount > 0 ||
        _items.any((e) => e.unread) ||
        _rawNotifications.any((n) => n['is_read'] != true);

    return Container(
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
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
                  Expanded(
                    child: Text(
                      context.l10n.notificationsTitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: hasUnread ? _markAllAsRead : null,
                    child: Text(
                      context.l10n.markAllAsRead,
                      style: GoogleFonts.cairo(
                        color: Colors.white.withValues(alpha: hasUnread ? 1 : 0.45),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        Localizations.localeOf(context).languageCode == 'ar'
                            ? 'التقييم قريباً'
                            : 'Rating — coming soon',
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 4, 10, 12),
                  child: Row(
                    children: [
                      Icon(Icons.star_outline_rounded,
                          color: Colors.white.withValues(alpha: 0.95), size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          Localizations.localeOf(context).languageCode == 'ar'
                              ? 'كيف كانت آخر طلبية؟ اضغط للتقييم!'
                              : 'How was your last order? Tap to rate!',
                          style: GoogleFonts.cairo(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded,
                          color: Colors.white.withValues(alpha: 0.85), size: 22),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              color: const Color(0xFFE8EAEF),
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: filters.length,
                  itemBuilder: (context, i) {
                    final selected = _filterIndex == i;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Material(
                        color: selected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          onTap: () => setState(() => _filterIndex = i),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected
                                    ? AppColors.primary
                                    : const Color(0xFFD0D5DD),
                              ),
                            ),
                            child: Text(
                              filters[i],
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: selected
                                    ? Colors.white
                                    : const Color(0xFF667085),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: 6,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotifUi {
  _NotifUi({
    this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.unread,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.createdAt,
    this.timeLabel,
  });

  final String? id;
  final String title;
  final String body;
  final String category;
  final bool unread;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String? createdAt;
  final String? timeLabel;

  static _NotifUi fromApi(Map<String, dynamic> n) {
    final title = (n['title'] ?? '').toString();
    final body = (n['body'] ?? n['message'] ?? '').toString();
    final cat = _inferCategory(n);
    final unread = n['is_read'] != true;
    final iconName = n['icon']?.toString();
    final pack = _iconPackForCategory(cat, iconName);

    return _NotifUi(
      id: n['id']?.toString(),
      title: title.isEmpty ? '—' : title,
      body: body.isEmpty ? '' : body,
      category: cat,
      unread: unread,
      icon: pack.icon,
      iconColor: pack.iconColor,
      iconBg: pack.iconBg,
      createdAt: n['created_at']?.toString(),
    );
  }
}

({IconData icon, Color iconColor, Color iconBg}) _iconPackForCategory(
  String category,
  String? iconName,
) {
  IconData icon = Icons.notifications_outlined;
  Color c = AppColors.primary;
  Color bg = const Color(0xFFFFE4E6);

  switch (category) {
    case 'orders':
      icon = Icons.local_shipping_outlined;
      c = const Color(0xFF1D4ED8);
      bg = const Color(0xFFDBEAFE);
      break;
    case 'offers':
      icon = Icons.local_offer_outlined;
      c = AppColors.primary;
      bg = const Color(0xFFFFE4E6);
      break;
    case 'events':
      icon = Icons.calendar_today_outlined;
      c = const Color(0xFF1D4ED8);
      bg = const Color(0xFFDBEAFE);
      break;
    case 'learning':
      icon = Icons.search_rounded;
      c = const Color(0xFF047857);
      bg = const Color(0xFFD1FAE5);
      break;
    default:
      break;
  }

  if (iconName != null) {
    final map = {
      'book': Icons.menu_book,
      'emoji_events': Icons.emoji_events_outlined,
      'campaign': Icons.campaign_outlined,
      'school': Icons.school_outlined,
    };
    icon = map[iconName.toLowerCase()] ?? icon;
  }

  return (icon: icon, iconColor: c, iconBg: bg);
}

String _inferCategory(Map<String, dynamic> n) {
  final s =
      '${n['category'] ?? ''} ${n['type'] ?? ''} ${n['title'] ?? ''} ${n['body'] ?? n['message'] ?? ''}'
          .toLowerCase();
  if (s.contains('order') || s.contains('ship') || s.contains('delivery') || s.contains('ord-')) {
    return 'orders';
  }
  if (s.contains('offer') || s.contains('discount') || s.contains('%')) {
    return 'offers';
  }
  if (s.contains('event') || s.contains('symposium') || s.contains('registration') || s.contains('seat')) {
    return 'events';
  }
  if (s.contains('challenge') || s.contains('rank') || s.contains('case') || s.contains('course') || s.contains('lesson')) {
    return 'learning';
  }
  return 'learning';
}

final List<_NotifUi> _demoNotifications = [
  _NotifUi(
    id: 'demo-1',
    title: 'New Offer: 30% off BLX System',
    body: 'Straumann BLX complete kit. Valid until May 31.',
    category: 'offers',
    unread: true,
    icon: Icons.local_offer_outlined,
    iconColor: AppColors.primary,
    iconBg: const Color(0xFFFFE4E6),
    timeLabel: '2 hours ago',
  ),
  _NotifUi(
    id: 'demo-2',
    title: 'Event Registration Open',
    body: 'Cairo Implant Symposium – May 22. 120 seats left.',
    category: 'events',
    unread: true,
    icon: Icons.calendar_today_outlined,
    iconColor: const Color(0xFF1D4ED8),
    iconBg: const Color(0xFFDBEAFE),
    timeLabel: '5 hours ago',
  ),
  _NotifUi(
    id: 'demo-3',
    title: 'New Case Published',
    body: 'Dr. Nour Khalil shared All-on-4 case. 14 images + video.',
    category: 'learning',
    unread: true,
    icon: Icons.search_rounded,
    iconColor: const Color(0xFF047857),
    iconBg: const Color(0xFFD1FAE5),
    timeLabel: 'Yesterday',
  ),
  _NotifUi(
    id: 'demo-4',
    title: 'Challenge Results – Week 17',
    body: 'You ranked #5 this week! Keep going.',
    category: 'learning',
    unread: false,
    icon: Icons.emoji_events_outlined,
    iconColor: const Color(0xFFB45309),
    iconBg: const Color(0xFFFEF9C3),
    timeLabel: '2 days ago',
  ),
  _NotifUi(
    id: 'demo-5',
    title: 'Order Shipped #ORD-2847',
    body: 'Your BLX implants are on the way. ETA: 2 days.',
    category: 'orders',
    unread: false,
    icon: Icons.local_shipping_outlined,
    iconColor: const Color(0xFF1D4ED8),
    iconBg: const Color(0xFFDBEAFE),
    timeLabel: '3 days ago',
  ),
];

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.item,
    required this.timeLabel,
    required this.onTap,
  });

  final _NotifUi item;
  final String timeLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: item.iconBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.icon, color: item.iconColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: GoogleFonts.cairo(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF101828),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.body,
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            height: 1.35,
                            color: const Color(0xFF667085),
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          timeLabel,
                          style: GoogleFonts.cairo(
                            fontSize: 11.5,
                            color: const Color(0xFF98A2B3),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (item.unread)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
