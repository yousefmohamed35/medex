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
    final author = map['author'] is Map
        ? Map<String, dynamic>.from(map['author'] as Map)
        : <String, dynamic>{};
    final media = map['media'] is List ? map['media'] as List : const [];
    String? imageUrl;
    if (media.isNotEmpty && media.first is Map) {
      imageUrl = ApiEndpoints.getImageUrl(
          (media.first as Map)['url']?.toString() ?? '');
    } else {
      imageUrl = ApiEndpoints.getImageUrl(map['image']?.toString() ?? '');
    }
    final commentsRaw = map['comments'] is List ? map['comments'] as List : [];
    return CommunityPost(
      id: map['id']?.toString() ?? '',
      authorId: author['id']?.toString() ?? '',
      authorName: author['name']?.toString() ?? 'Unknown',
      authorAvatar:
          ApiEndpoints.getImageUrl(author['avatar']?.toString() ?? ''),
      authorTitle: author['title']?.toString() ?? '',
      content: map['content']?.toString() ?? '',
      imageUrl: imageUrl,
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ??
          DateTime.now(),
      likesCount: (map['likes_count'] as num?)?.toInt() ?? 0,
      commentsCount: (map['comments_count'] as num?)?.toInt() ?? 0,
      sharesCount: (map['shares_count'] as num?)?.toInt() ?? 0,
      isLiked: (map['viewer_reaction']?.toString().isNotEmpty ?? false),
      comments: commentsRaw.map((e) => _parseComment(e)).toList(),
      reaction: map['viewer_reaction']?.toString() ?? '',
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
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ??
          DateTime.now(),
      likesCount: (map['likes_count'] as num?)?.toInt() ?? 0,
      isLiked: (map['viewer_reaction']?.toString().isNotEmpty ?? false),
    );
  }
}
