import 'dart:developer' show log;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design/app_colors.dart';
import '../../core/navigation/route_names.dart';
import '../../models/community.dart';
import '../../services/community_service.dart';
import '../../widgets/bottom_nav.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  static const String _logName = 'CommunityScreen';

  bool _wasLoading = false;
  final _communityService = CommunityService.instance;

  @override
  void initState() {
    super.initState();
    _communityService.addListener(_onUpdate);
    _communityService.fetchPosts();
  }

  @override
  void dispose() {
    _communityService.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    if (kDebugMode) {
      final s = _communityService;
      if (_wasLoading && !s.isLoading) {
        final line =
            'Community: fetchPosts done — ${s.posts.length} posts, error: ${s.error}';
        debugPrint(line);
        log(line, name: _logName);
      }
      _wasLoading = s.isLoading;
    }
    if (mounted) setState(() {});
  }

  void _logUiRequest(String action, Object? detail) {
    if (kDebugMode) {
      final line = 'Community ui $action: $detail';
      debugPrint(line);
      log(line, name: _logName);
    }
  }

  void _toggleLike(String postId) {
    _logUiRequest('toggleLike', postId);
    _communityService.toggleLike(postId);
  }

  void _applyReaction(String postId, String reaction) {
    _logUiRequest('setReaction', {'postId': postId, 'reaction': reaction});
    _communityService.setReaction(postId, reaction);
  }

  String _timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  IconData _getReactionIcon(String reaction) {
    switch (reaction) {
      case 'love':
        return Icons.favorite;
      case 'haha':
        return Icons.sentiment_very_satisfied;
      case 'wow':
        return Icons.mood;
      case 'sad':
        return Icons.sentiment_dissatisfied;
      case 'angry':
        return Icons.mood_bad;
      default:
        return Icons.thumb_up;
    }
  }

  Color _getReactionColor(String reaction) {
    switch (reaction) {
      case 'love':
        return Colors.red;
      case 'haha':
        return Colors.amber;
      case 'wow':
        return Colors.amber.shade700;
      case 'sad':
        return Colors.amber.shade800;
      case 'angry':
        return Colors.orange.shade800;
      default:
        return AppColors.primary;
    }
  }

  String? _alternateMediaUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.contains('/api/uploads/')) {
      return url.replaceFirst('/api/uploads/', '/uploads/');
    }
    if (url.contains('/uploads/')) {
      return url.replaceFirst('/uploads/', '/api/uploads/');
    }
    return null;
  }

  Widget _buildPostImage(String imageUrl) {
    final fallbackUrl = _alternateMediaUrl(imageUrl);
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: double.infinity,
      height: 220,
      color: Colors.grey[200],
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (_, __, ___) {
          if (fallbackUrl != null && fallbackUrl != imageUrl) {
            return Image.network(
              fallbackUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(
                Icons.image_not_supported_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
            );
          }
          return Icon(
            Icons.image_not_supported_outlined,
            size: 48,
            color: Colors.grey[400],
          );
        },
      ),
    );
  }

  void _showReactionPicker(String postId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ReactionButton(
                emoji: '👍',
                label: 'أعجبني',
                onTap: () {
                  _applyReaction(postId, 'like');
                  Navigator.pop(ctx);
                }),
            _ReactionButton(
                emoji: '❤️',
                label: 'أحببته',
                onTap: () {
                  _communityService.setReaction(postId, 'love');
                  Navigator.pop(ctx);
                }),
            _ReactionButton(
                emoji: '😂',
                label: 'هاها',
                onTap: () {
                  _communityService.setReaction(postId, 'haha');
                  Navigator.pop(ctx);
                }),
            _ReactionButton(
                emoji: '😮',
                label: 'واو',
                onTap: () {
                  _applyReaction(postId, 'wow');
                  Navigator.pop(ctx);
                }),
            _ReactionButton(
                emoji: '😢',
                label: 'حزين',
                onTap: () {
                  _communityService.setReaction(postId, 'sad');
                  Navigator.pop(ctx);
                }),
            _ReactionButton(
                emoji: '😡',
                label: 'غاضب',
                onTap: () {
                  _applyReaction(postId, 'angry');
                  Navigator.pop(ctx);
                }),
          ],
        ),
      ),
    );
  }

  void _showShareSheet(CommunityPost post) {
    _communityService.sharePost(post.id);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            Text('مشاركة المنشور',
                style: GoogleFonts.cairo(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ShareOption(
                    icon: Icons.copy_rounded,
                    label: 'نسخ الرابط',
                    color: Colors.grey.shade700,
                    onTap: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('تم نسخ الرابط',
                                style: GoogleFonts.cairo()),
                            backgroundColor: AppColors.primary),
                      );
                    }),
                _ShareOption(
                    icon: Icons.message_rounded,
                    label: 'رسالة',
                    color: Colors.blue,
                    onTap: () => Navigator.pop(ctx)),
                _ShareOption(
                    icon: Icons.share_rounded,
                    label: 'مشاركة',
                    color: Colors.green,
                    onTap: () => Navigator.pop(ctx)),
                _ShareOption(
                    icon: Icons.bookmark_outline_rounded,
                    label: 'حفظ',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('تم حفظ المنشور',
                                style: GoogleFonts.cairo()),
                            backgroundColor: AppColors.primary),
                      );
                    }),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final posts = _communityService.posts;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                _buildAppBar(isAr),
                SliverToBoxAdapter(child: _buildCreatePostCard(isAr)),
                //  SliverToBoxAdapter(child: _buildStorySection()),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (_communityService.isLoading && posts.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (index == posts.length) {
                        return const SizedBox(height: 120);
                      }
                      return _buildPostCard(posts[index], isAr);
                    },
                    childCount: posts.length + 1,
                  ),
                ),
              ],
            ),
            const BottomNav(activeTab: 'community'),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isAr) {
    return SliverAppBar(
      expandedHeight: 110,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFD42535), Color(0xFFB01E2D)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.people_alt_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? 'مجتمع ميدكس' : 'Medex Community',
                          style: GoogleFonts.cairo(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Text(
                          isAr
                              ? 'تواصل مع أطباء الأسنان'
                              : 'Connect with dentists',
                          style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.85)),
                        ),
                      ],
                    ),
                  ),
                  _buildHeaderIcon(Icons.search_rounded, () {}),
                  const SizedBox(width: 8),
                  _buildHeaderIcon(Icons.notifications_outlined,
                      () => context.push(RouteNames.notifications)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildCreatePostCard(bool isAr) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => context.push(RouteNames.createPost),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: const Icon(Icons.person_rounded,
                      color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      isAr
                          ? 'شارك شيئاً مع المجتمع...'
                          : 'Share something with the community...',
                      style: GoogleFonts.cairo(
                          color: Colors.grey[500], fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: Colors.grey.shade200),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _QuickAction(
                  icon: Icons.image_rounded,
                  label: isAr ? 'صورة' : 'Photo',
                  color: Colors.green,
                  onTap: () => context.push(RouteNames.createPost)),
              _QuickAction(
                  icon: Icons.videocam_rounded,
                  label: isAr ? 'فيديو' : 'Video',
                  color: AppColors.primary,
                  onTap: () => context.push(RouteNames.createPost)),
              _QuickAction(
                  icon: Icons.article_rounded,
                  label: isAr ? 'مقال' : 'Article',
                  color: Colors.orange,
                  onTap: () => context.push(RouteNames.createPost)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStorySection() {
    final stories = [
      {'name': 'إضافة', 'icon': Icons.add, 'isAdd': true},
      {'name': 'د. أحمد', 'icon': Icons.person, 'isAdd': false},
      {'name': 'Medex', 'icon': Icons.business, 'isAdd': false},
      {'name': 'د. سارة', 'icon': Icons.person, 'isAdd': false},
      {'name': 'د. محمد', 'icon': Icons.person, 'isAdd': false},
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: stories.length,
        itemBuilder: (context, index) {
          final story = stories[index];
          final isAdd = story['isAdd'] as bool;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isAdd
                        ? null
                        : const LinearGradient(
                            colors: [Color(0xFFD42535), Color(0xFFB01E2D)],
                          ),
                    color: isAdd ? AppColors.background : null,
                    border: isAdd
                        ? Border.all(color: Colors.grey.shade300, width: 2)
                        : null,
                  ),
                  child: Container(
                    margin: EdgeInsets.all(isAdd ? 0 : 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isAdd ? null : Colors.white,
                    ),
                    child: Container(
                      margin: EdgeInsets.all(isAdd ? 0 : 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            isAdd ? null : AppColors.primary.withOpacity(0.1),
                      ),
                      child: Icon(
                        story['icon'] as IconData,
                        color: isAdd ? Colors.grey : AppColors.primary,
                        size: isAdd ? 28 : 26,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  story['name'] as String,
                  style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostCard(CommunityPost post, bool isAr) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: post.authorId == 'u6'
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.grey.shade200,
                  child: post.authorId == 'u6'
                      ? Image.asset('assets/images/medex_logo.png',
                          width: 26,
                          height: 26,
                          errorBuilder: (_, __, ___) => const Icon(
                              Icons.business,
                              color: AppColors.primary,
                              size: 22))
                      : Text(
                          post.authorName.isNotEmpty ? post.authorName[0] : '?',
                          style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary),
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              post.authorName,
                              style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.foreground),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (post.authorId == 'u6') ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified,
                                color: AppColors.primary, size: 16),
                          ],
                        ],
                      ),
                      Row(
                        children: [
                          if (post.authorTitle.isNotEmpty) ...[
                            Flexible(
                              child: Text(
                                post.authorTitle,
                                style: GoogleFonts.cairo(
                                    fontSize: 11, color: Colors.grey[600]),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(' • ',
                                style: GoogleFonts.cairo(
                                    fontSize: 11, color: Colors.grey[400])),
                          ],
                          Text(
                            _timeAgo(post.createdAt),
                            style: GoogleFonts.cairo(
                                fontSize: 11, color: Colors.grey[500]),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.public, size: 12, color: Colors.grey[500]),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_horiz, color: Colors.grey[600]),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  onSelected: (value) {
                    if (value == 'save') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('تم حفظ المنشور',
                                style: GoogleFonts.cairo()),
                            backgroundColor: AppColors.primary),
                      );
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                        value: 'save',
                        child: Row(children: [
                          const Icon(Icons.bookmark_outline, size: 20),
                          const SizedBox(width: 8),
                          Text('حفظ المنشور', style: GoogleFonts.cairo())
                        ])),
                    PopupMenuItem(
                        value: 'hide',
                        child: Row(children: [
                          const Icon(Icons.visibility_off_outlined, size: 20),
                          const SizedBox(width: 8),
                          Text('إخفاء المنشور', style: GoogleFonts.cairo())
                        ])),
                    PopupMenuItem(
                        value: 'report',
                        child: Row(children: [
                          Icon(Icons.flag_outlined,
                              size: 20, color: Colors.red[400]),
                          const SizedBox(width: 8),
                          Text('الإبلاغ',
                              style: GoogleFonts.cairo(color: Colors.red[400]))
                        ])),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Text(
              post.content,
              style: GoogleFonts.cairo(
                  fontSize: 14, height: 1.6, color: AppColors.foreground),
            ),
          ),

          if (post.videoUrl != null && post.videoUrl!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.play_circle_fill_rounded,
                    size: 56,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isAr ? 'تم إرفاق فيديو' : 'Video attached',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          // Post image
          if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
            _buildPostImage(post.imageUrl!),

          // Reactions & counts
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                if (post.likesCount > 0) ...[
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 4)
                      ],
                    ),
                    child: const Icon(Icons.thumb_up,
                        color: Colors.white, size: 10),
                  ),
                  const SizedBox(width: 2),
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                    child: const Icon(Icons.favorite,
                        color: Colors.white, size: 10),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${post.likesCount}',
                    style: GoogleFonts.cairo(
                        fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
                const Spacer(),
                if (post.commentsCount > 0)
                  GestureDetector(
                    onTap: () =>
                        context.push(RouteNames.postDetail, extra: post),
                    child: Text(
                      '${post.commentsCount} ${isAr ? 'تعليق' : 'comments'}',
                      style: GoogleFonts.cairo(
                          fontSize: 13, color: Colors.grey[600]),
                    ),
                  ),
                if (post.commentsCount > 0 && post.sharesCount > 0)
                  Text(' • ',
                      style: GoogleFonts.cairo(color: Colors.grey[400])),
                if (post.sharesCount > 0)
                  Text(
                    '${post.sharesCount} ${isAr ? 'مشاركة' : 'shares'}',
                    style: GoogleFonts.cairo(
                        fontSize: 13, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),

          Divider(
              height: 24,
              color: Colors.grey.shade200,
              indent: 16,
              endIndent: 16),

          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _PostActionButton(
                  icon: post.isLiked
                      ? _getReactionIcon(post.reaction)
                      : Icons.thumb_up_outlined,
                  label: post.isLiked
                      ? _getReactionLabel(post.reaction, isAr)
                      : (isAr ? 'أعجبني' : 'Like'),
                  color: post.isLiked
                      ? _getReactionColor(post.reaction)
                      : Colors.grey[700]!,
                  onTap: () => _toggleLike(post.id),
                  onLongPress: () => _showReactionPicker(post.id),
                ),
                _PostActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: isAr ? 'تعليق' : 'Comment',
                  color: Colors.grey[700]!,
                  onTap: () => context.push(RouteNames.postDetail, extra: post),
                ),
                _PostActionButton(
                  icon: Icons.share_outlined,
                  label: isAr ? 'مشاركة' : 'Share',
                  color: Colors.grey[700]!,
                  onTap: () => _showShareSheet(post),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getReactionLabel(String reaction, bool isAr) {
    if (!isAr) {
      switch (reaction) {
        case 'love':
          return 'Love';
        case 'haha':
          return 'Haha';
        case 'wow':
          return 'Wow';
        case 'sad':
          return 'Sad';
        case 'angry':
          return 'Angry';
        default:
          return 'Like';
      }
    }
    switch (reaction) {
      case 'love':
        return 'أحببته';
      case 'haha':
        return 'هاها';
      case 'wow':
        return 'واو';
      case 'sad':
        return 'حزين';
      case 'angry':
        return 'غاضب';
      default:
        return 'أعجبني';
    }
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700])),
        ],
      ),
    );
  }
}

class _PostActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _PostActionButton(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap,
      this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 6),
            Text(label,
                style: GoogleFonts.cairo(
                    fontSize: 13, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}

class _ReactionButton extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;

  const _ReactionButton(
      {required this.emoji, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 2),
            Text(label,
                style: GoogleFonts.cairo(fontSize: 9, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShareOption(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey[700])),
        ],
      ),
    );
  }
}
