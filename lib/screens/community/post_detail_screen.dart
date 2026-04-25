import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design/app_colors.dart';
import '../../models/community.dart';
import '../../services/community_service.dart';

class PostDetailScreen extends StatefulWidget {
  final CommunityPost? post;
  const PostDetailScreen({super.key, this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _communityService = CommunityService.instance;
  final _commentController = TextEditingController();
  final _focusNode = FocusNode();
  late CommunityPost _post;
  bool _isLoadingDetails = false;

  @override
  void initState() {
    super.initState();
    _post = widget.post ?? _communityService.posts.first;
    _communityService.addListener(_onUpdate);
    _loadPostDetails();
  }

  @override
  void dispose() {
    _communityService.removeListener(_onUpdate);
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) {
      final idx = _communityService.posts.indexWhere((p) => p.id == _post.id);
      if (idx >= 0) setState(() => _post = _communityService.posts[idx]);
    }
  }

  Future<void> _loadPostDetails() async {
    setState(() => _isLoadingDetails = true);
    final detailed = await _communityService.fetchPostDetails(_post.id);
    if (!mounted) return;
    if (detailed != null) {
      setState(() => _post = detailed);
    }
    setState(() => _isLoadingDetails = false);
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    try {
      await _communityService.addComment(
        _post.id,
        PostComment(
          id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
          authorId: 'current_user',
          authorName: 'أنا',
          authorAvatar: '',
          content: text,
          createdAt: DateTime.now(),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$e', style: GoogleFonts.cairo()),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    _commentController.clear();
    _focusNode.unfocus();
  }

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} د';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} س';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  Widget _buildAvatar({
    required String name,
    required String avatarUrl,
    required double radius,
    Color? fallbackBackground,
  }) {
    final hasAvatar = avatarUrl.trim().isNotEmpty;
    if (hasAvatar) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: fallbackBackground ?? Colors.grey.shade200,
        backgroundImage: NetworkImage(avatarUrl),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: fallbackBackground ?? Colors.grey.shade200,
      child: Text(
        name.isNotEmpty ? name[0] : '?',
        style: GoogleFonts.cairo(
          fontSize: radius * 0.8,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildPostMedia(bool isAr) {
    if (_post.videoUrl != null && _post.videoUrl!.isNotEmpty) {
      return Container(
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
            const Icon(Icons.play_circle_fill_rounded,
                size: 56, color: Colors.white),
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
      );
    }
    if (_post.imageUrl != null && _post.imageUrl!.isNotEmpty) {
      final imageUrl = _post.imageUrl!;
      final fallbackUrl = _alternateMediaUrl(imageUrl);
      return Container(
        margin: const EdgeInsets.only(top: 12),
        width: double.infinity,
        height: 220,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            if (fallbackUrl != null && fallbackUrl != imageUrl) {
              return Image.network(
                fallbackUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[200],
                  child: Icon(Icons.image_not_supported_outlined,
                      size: 48, color: Colors.grey[400]),
                ),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
              );
            }
            return Container(
              color: Colors.grey[200],
              child: Icon(Icons.image_not_supported_outlined,
                  size: 48, color: Colors.grey[400]),
            );
          },
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
        ),
      );
    }
    return const SizedBox.shrink();
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

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            isAr ? 'المنشور' : 'Post',
            style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.foreground),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPostContent(isAr),
                    _buildReactionsBar(isAr),
                    Divider(height: 1, color: Colors.grey.shade200),
                    _buildActionButtons(isAr),
                    Divider(height: 1, color: Colors.grey.shade200),
                    _buildCommentsSection(isAr),
                  ],
                ),
              ),
            ),
            _buildCommentInput(isAr),
          ],
        ),
      ),
    );
  }

  Widget _buildPostContent(bool isAr) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildAvatar(
                name: _post.authorName,
                avatarUrl: _post.authorAvatar,
                radius: 24,
                fallbackBackground: _post.authorId == 'u6'
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.grey.shade200,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(_post.authorName,
                            style: GoogleFonts.cairo(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                        if (_post.authorId == 'u6') ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified,
                              color: AppColors.primary, size: 16),
                        ],
                      ],
                    ),
                    Row(
                      children: [
                        if (_post.authorTitle.isNotEmpty) ...[
                          Text(_post.authorTitle,
                              style: GoogleFonts.cairo(
                                  fontSize: 12, color: Colors.grey[600])),
                          Text(' • ',
                              style:
                                  GoogleFonts.cairo(color: Colors.grey[400])),
                        ],
                        Text(_timeAgo(_post.createdAt),
                            style: GoogleFonts.cairo(
                                fontSize: 12, color: Colors.grey[500])),
                        const SizedBox(width: 4),
                        Icon(Icons.public, size: 13, color: Colors.grey[500]),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.more_horiz, color: Colors.grey[600]),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _post.content,
            style: GoogleFonts.cairo(
                fontSize: 15, height: 1.7, color: AppColors.foreground),
          ),
          _buildPostMedia(isAr),
        ],
      ),
    );
  }

  Widget _buildReactionsBar(bool isAr) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          if (_post.likesCount > 0) ...[
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primary.withOpacity(0.3), blurRadius: 4)
                ],
              ),
              child: const Icon(Icons.thumb_up, color: Colors.white, size: 11),
            ),
            const SizedBox(width: 2),
            Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                  color: Colors.red, shape: BoxShape.circle),
              child: const Icon(Icons.favorite, color: Colors.white, size: 11),
            ),
            const SizedBox(width: 6),
            Text('${_post.likesCount}',
                style:
                    GoogleFonts.cairo(fontSize: 14, color: Colors.grey[600])),
          ],
          const Spacer(),
          if (_post.commentsCount > 0)
            Text('${_post.commentsCount} ${isAr ? 'تعليق' : 'comments'}',
                style:
                    GoogleFonts.cairo(fontSize: 13, color: Colors.grey[600])),
          if (_post.sharesCount > 0) ...[
            Text(' • ', style: GoogleFonts.cairo(color: Colors.grey[400])),
            Text('${_post.sharesCount} ${isAr ? 'مشاركة' : 'shares'}',
                style:
                    GoogleFonts.cairo(fontSize: 13, color: Colors.grey[600])),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isAr) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionBtn(
            icon: _post.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
            label: _post.isLiked
                ? (isAr ? 'أعجبني' : 'Liked')
                : (isAr ? 'أعجبني' : 'Like'),
            color: _post.isLiked ? AppColors.primary : Colors.grey[700]!,
            onTap: () async => _communityService.toggleLike(_post.id),
          ),
          _ActionBtn(
            icon: Icons.chat_bubble_outline,
            label: isAr ? 'تعليق' : 'Comment',
            color: Colors.grey[700]!,
            onTap: () => _focusNode.requestFocus(),
          ),
          _ActionBtn(
            icon: Icons.share_outlined,
            label: isAr ? 'مشاركة' : 'Share',
            color: Colors.grey[700]!,
            onTap: () async => _communityService.sharePost(_post.id),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection(bool isAr) {
    final comments = _post.comments;

    if (_isLoadingDetails && comments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 12),
              Text(
                isAr ? 'جاري تحميل التعليقات...' : 'Loading comments...',
                style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    if (comments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.chat_bubble_outline,
                  size: 48, color: Colors.grey[300]),
              const SizedBox(height: 12),
              Text(
                isAr ? 'لا توجد تعليقات بعد' : 'No comments yet',
                style: GoogleFonts.cairo(fontSize: 15, color: Colors.grey[500]),
              ),
              const SizedBox(height: 4),
              Text(
                isAr ? 'كن أول من يعلق!' : 'Be the first to comment!',
                style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            isAr ? 'التعليقات' : 'Comments',
            style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.foreground),
          ),
        ),
        ...comments.map((comment) => _buildCommentItem(comment, isAr)),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildCommentItem(PostComment comment, bool isAr) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(
            name: comment.authorName,
            avatarUrl: comment.authorAvatar,
            radius: 18,
            fallbackBackground: comment.authorId == 'current_user'
                ? AppColors.primary.withOpacity(0.15)
                : Colors.grey.shade200,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.authorName,
                        style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.foreground),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        comment.content,
                        style: GoogleFonts.cairo(
                            fontSize: 14,
                            height: 1.5,
                            color: AppColors.foreground),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Text(_timeAgo(comment.createdAt),
                          style: GoogleFonts.cairo(
                              fontSize: 11, color: Colors.grey[500])),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () async => _communityService.toggleCommentLike(
                            _post.id, comment.id),
                        child: Text(
                          isAr ? 'أعجبني' : 'Like',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: comment.isLiked
                                ? AppColors.primary
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        isAr ? 'رد' : 'Reply',
                        style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600]),
                      ),
                      if (comment.likesCount > 0) ...[
                        const Spacer(),
                        Icon(Icons.thumb_up,
                            size: 12,
                            color: AppColors.primary.withOpacity(0.7)),
                        const SizedBox(width: 3),
                        Text('${comment.likesCount}',
                            style: GoogleFonts.cairo(
                                fontSize: 11, color: Colors.grey[600])),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(bool isAr) {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: const Icon(Icons.person, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      focusNode: _focusNode,
                      style: GoogleFonts.cairo(fontSize: 14),
                      decoration: InputDecoration(
                        hintText:
                            isAr ? 'اكتب تعليقاً...' : 'Write a comment...',
                        hintStyle: GoogleFonts.cairo(
                            color: Colors.grey[500], fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _submitComment(),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(Icons.emoji_emotions_outlined,
                          size: 22, color: Colors.grey[500]),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(Icons.image_outlined,
                          size: 22, color: Colors.grey[500]),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _submitComment(),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xFFD42535), Color(0xFFB01E2D)]),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.send_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
