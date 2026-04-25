import 'dart:developer' show log;

import 'package:flutter/foundation.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/community.dart';

class CommunityService extends ChangeNotifier {
  static final CommunityService instance = CommunityService._();
  CommunityService._();

  final List<CommunityPost> _posts = [];
  bool _isLoading = false;
  String? _error;

  List<CommunityPost> get posts => List.unmodifiable(_posts);
  bool get isLoading => _isLoading;
  String? get error => _error;

  static const String _logName = 'CommunityService';

  void _logRequest(String method, String url, [Object? body]) {
    if (!kDebugMode) return;
    log(
      'request $method $url${body != null ? ' body: $body' : ''}',
      name: _logName,
    );
  }

  void _logResponse(String method, String url, Object? response) {
    if (!kDebugMode) return;
    // Avoid stringifying huge JSON on the UI isolate (freezes + hides other logs).
    if (response is Map) {
      final keys = response.keys.take(12).join(', ');
      log(
        'response $method $url success=${response['success']} keys=[$keys]',
        name: _logName,
      );
    } else {
      log('response $method $url: $response', name: _logName);
    }
  }

  Future<void> fetchPosts({int page = 1, int perPage = 20}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final uri = Uri.parse(ApiEndpoints.communityPosts).replace(
        queryParameters: {
          'page': '$page',
          'per_page': '$perPage',
          'sort': 'latest',
        },
      );
      final response = await ApiClient.instance.get(
        uri.toString(),
        requireAuth: true,
      );
      _logResponse('GET', uri.toString(), response);
      if (kDebugMode) {
        log('fetchPosts full response: $response', name: _logName);
      }
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        List<dynamic> list = [];
        if (data is Map && data['posts'] is List) {
          list = data['posts'] as List;
        } else if (data is List) {
          list = data;
        }
        _posts
          ..clear()
          ..addAll(list.map((e) => _parsePost(e)).toList());
      } else {
        throw Exception(response['message'] ?? 'Failed to load posts');
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('❌ CommunityService.fetchPosts: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createPost({
    required String content,
    List<String> media = const [],
  }) async {
    final body = {
      'content': content,
      if (media.isNotEmpty) 'media': media,
    };
    _logRequest('POST', ApiEndpoints.communityPosts, body);
    final response = await ApiClient.instance.post(
      ApiEndpoints.communityPosts,
      body: body,
      requireAuth: true,
    );
    _logResponse('POST', ApiEndpoints.communityPosts, response);
    if (response['success'] == true && response['data'] != null) {
      _posts.insert(0, _parsePost(response['data']));
      notifyListeners();
      return;
    }
    throw Exception(response['message'] ?? 'Failed to create post');
  }

  Future<void> setReaction(String postId, String reaction) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index < 0) return;
    try {
      final url = ApiEndpoints.communityPostReactions(postId);
      final body = {'reaction': reaction};
      _logRequest('POST', url, body);
      final response = await ApiClient.instance.post(
        url,
        body: body,
        requireAuth: true,
      );
      _logResponse('POST', url, response);
      if (response['success'] == true) {
        final post = _posts[index];
        post.isLiked = true;
        post.reaction = reaction;
        final data = response['data'];
        if (data is Map && data['likes_count'] != null) {
          post.likesCount = (data['likes_count'] as num).toInt();
        } else {
          post.likesCount++;
        }
        notifyListeners();
      } else {
        throw Exception(response['message'] ?? 'Failed to react');
      }
    } catch (e) {
      if (kDebugMode) print('❌ CommunityService.setReaction: $e');
    }
  }

  Future<void> toggleLike(String postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index < 0) return;
    final post = _posts[index];
    if (post.isLiked) {
      try {
        final url = ApiEndpoints.communityPostReactions(postId);
        _logRequest('DELETE', url);
        final response = await ApiClient.instance.delete(
          url,
          requireAuth: true,
        );
        _logResponse('DELETE', url, response);
        if (response['success'] == true) {
          post.isLiked = false;
          post.reaction = '';
          if (post.likesCount > 0) post.likesCount--;
          notifyListeners();
        }
      } catch (e) {
        if (kDebugMode) {
          log('toggleLike DELETE failed: $e', name: _logName);
        }
      }
      return;
    }
    await setReaction(postId, 'like');
  }

  Future<void> addComment(String postId, PostComment comment) async {
    final url = ApiEndpoints.communityComments(postId);
    final body = {'content': comment.content};
    _logRequest('POST', url, body);
    final response = await ApiClient.instance.post(
      url,
      body: body,
      requireAuth: true,
    );
    _logResponse('POST', url, response);
    if (response['success'] == true && response['data'] != null) {
      final index = _posts.indexWhere((p) => p.id == postId);
      if (index >= 0) {
        _posts[index].comments.add(_parseComment(response['data']));
        _posts[index].commentsCount++;
        notifyListeners();
      }
      return;
    }
    throw Exception(response['message'] ?? 'Failed to add comment');
  }

  Future<CommunityPost?> fetchPostDetails(String postId) async {
    try {
      final url = ApiEndpoints.communityPost(postId);
      _logRequest('GET', url);
      final response = await ApiClient.instance.get(
        url,
        requireAuth: true,
      );
      _logResponse('GET', url, response);
      if (kDebugMode) {
        log('fetchPostDetails full response: $response', name: _logName);
      }
      if (response['success'] == true && response['data'] != null) {
        final parsed = _parsePost(response['data']);
        final index = _posts.indexWhere((p) => p.id == parsed.id);
        if (index >= 0) {
          _posts[index] = parsed;
        } else {
          _posts.insert(0, parsed);
        }
        notifyListeners();
        return parsed;
      }
      throw Exception(response['message'] ?? 'Failed to load post details');
    } catch (e) {
      if (kDebugMode) {
        log('fetchPostDetails failed: $e', name: _logName);
      }
      return null;
    }
  }

  Future<void> toggleCommentLike(String postId, String commentId) async {
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    if (postIndex < 0) return;
    final commentIndex =
        _posts[postIndex].comments.indexWhere((c) => c.id == commentId);
    if (commentIndex < 0) return;
    final comment = _posts[postIndex].comments[commentIndex];
    try {
      final url = ApiEndpoints.communityCommentReactions(commentId);
      final body = {'reaction': 'like'};
      _logRequest('POST', url, body);
      final response = await ApiClient.instance.post(
        url,
        body: body,
        requireAuth: true,
      );
      _logResponse('POST', url, response);
      if (kDebugMode) {
        log('toggleCommentLike full response: $response', name: _logName);
      }
      if (response['success'] == true) {
        comment.isLiked = !comment.isLiked;
        comment.likesCount += comment.isLiked ? 1 : -1;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> sharePost(String postId) async {
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.communityShare(postId),
        requireAuth: true,
      );
      if (response['success'] == true) {
        final index = _posts.indexWhere((p) => p.id == postId);
        if (index >= 0) {
          _posts[index].sharesCount++;
          notifyListeners();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        log('sharePost failed: $e', name: _logName);
      }
    }
  }

  CommunityPost _parsePost(dynamic raw) {
    final map = raw is Map<String, dynamic>
        ? raw
        : Map<String, dynamic>.from(raw as Map);
    final originalPost = map['originalPost'] is Map
        ? Map<String, dynamic>.from(map['originalPost'] as Map)
        : <String, dynamic>{};
    final source = originalPost.isNotEmpty ? originalPost : map;
    final author = map['author'] is Map
        ? Map<String, dynamic>.from(map['author'] as Map)
        : <String, dynamic>{};
    final media = source['media'] is List ? source['media'] as List : const [];
    String? imageUrl;
    String? videoUrl;
    if (media.isNotEmpty) {
      for (final item in media) {
        if (item is! Map) continue;
        final mediaMap = item;
        final url = ApiEndpoints.getImageUrl(mediaMap['url']?.toString() ?? '');
        if (url.isEmpty) continue;
        final type = (mediaMap['type']?.toString() ?? '').toLowerCase();
        if (type == 'video' && videoUrl == null) {
          videoUrl = url;
        } else if (imageUrl == null) {
          imageUrl = url;
        }
      }
    } else {
      imageUrl = ApiEndpoints.getImageUrl(source['image']?.toString() ?? '');
    }
    final commentsRaw =
        source['comments'] is List ? source['comments'] as List : const [];
    final content = (source['content'] ?? map['content'] ?? '').toString();
    final likesCount = _asInt(source['likesCount'] ?? source['likes_count']);
    final commentsCount =
        _asInt(source['commentsCount'] ?? source['comments_count']);
    final sharesCount = _asInt(
      source['shareCount'] ?? source['sharesCount'] ?? source['shares_count'],
    );
    final viewerReaction = (source['viewer_reaction'] ??
            source['viewerReaction'] ??
            (source['isLiked'] == true ? 'like' : ''))
        .toString();
    final isLiked = source['isLiked'] == true || viewerReaction.isNotEmpty;

    return CommunityPost(
      id: map['id']?.toString() ?? '',
      authorId: author['id']?.toString() ?? '',
      authorName: author['name']?.toString() ?? 'Unknown',
      authorAvatar:
          ApiEndpoints.getImageUrl(author['avatar']?.toString() ?? ''),
      authorTitle: author['title']?.toString() ?? '',
      content: content,
      imageUrl: imageUrl,
      videoUrl: videoUrl,
      createdAt: _parseDate(
        source['created_at'] ??
            source['createdAt'] ??
            source['published_at'] ??
            map['createdAt'] ??
            map['created_at'],
      ),
      likesCount: likesCount,
      commentsCount: commentsCount,
      sharesCount: sharesCount,
      isLiked: isLiked,
      comments: commentsRaw.map((e) => _parseComment(e)).toList(),
      reaction: viewerReaction,
    );
  }

  PostComment _parseComment(dynamic raw) {
    final map = raw is Map<String, dynamic>
        ? raw
        : Map<String, dynamic>.from(raw as Map);
    final author = map['author'] is Map
        ? Map<String, dynamic>.from(map['author'] as Map)
        : <String, dynamic>{};
    return PostComment(
      id: map['id']?.toString() ?? '',
      authorId: author['id']?.toString() ?? '',
      authorName: author['name']?.toString() ?? 'User',
      authorAvatar:
          ApiEndpoints.getImageUrl(author['avatar']?.toString() ?? ''),
      content: map['content']?.toString() ?? '',
      createdAt: _parseDate(map['created_at'] ?? map['createdAt']),
      likesCount: _asInt(map['likesCount'] ?? map['likes_count']),
      isLiked: map['isLiked'] == true ||
          (map['viewer_reaction']?.toString().isNotEmpty ?? false),
    );
  }

  DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();

    if (value is int) {
      // Supports both seconds and milliseconds timestamps.
      return value > 1000000000000
          ? DateTime.fromMillisecondsSinceEpoch(value)
          : DateTime.fromMillisecondsSinceEpoch(value * 1000);
    }
    if (value is double) {
      final ms = value.toInt();
      return ms > 1000000000000
          ? DateTime.fromMillisecondsSinceEpoch(ms)
          : DateTime.fromMillisecondsSinceEpoch(ms * 1000);
    }

    final raw = value.toString().trim();
    if (raw.isEmpty) return DateTime.now();

    final asInt = int.tryParse(raw);
    if (asInt != null) {
      return asInt > 1000000000000
          ? DateTime.fromMillisecondsSinceEpoch(asInt)
          : DateTime.fromMillisecondsSinceEpoch(asInt * 1000);
    }

    return DateTime.tryParse(raw)?.toLocal() ?? DateTime.now();
  }

  int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}
