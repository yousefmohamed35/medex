class CommunityPost {
  final String id;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final String authorTitle;
  final String content;
  final String? imageUrl;
  final String? videoUrl;
  final DateTime createdAt;
  int likesCount;
  int commentsCount;
  int sharesCount;
  bool isLiked;
  final List<PostComment> comments;
  String reaction; // '', 'like', 'love', 'haha', 'wow', 'sad', 'angry'

  CommunityPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    this.authorTitle = '',
    required this.content,
    this.imageUrl,
    this.videoUrl,
    required this.createdAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.isLiked = false,
    this.comments = const [],
    this.reaction = '',
  });
}

class PostComment {
  final String id;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final String content;
  final DateTime createdAt;
  int likesCount;
  bool isLiked;

  PostComment({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    required this.content,
    required this.createdAt,
    this.likesCount = 0,
    this.isLiked = false,
  });
}
