import 'dart:io';

import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';

class DentalChallengeService {
  DentalChallengeService._();
  static final DentalChallengeService instance = DentalChallengeService._();

  Future<Map<String, dynamic>> getHome() async {
    final res = await ApiClient.instance.get(
      ApiEndpoints.dentalChallengeHome,
      requireAuth: true,
      logTag: 'DentalChallengeService',
    );
    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Failed to load challenge home');
    }
    final data = res['data'];
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw Exception('Invalid challenge home response');
  }

  Future<List<Map<String, dynamic>>> getBrands() async {
    final res = await ApiClient.instance.get(
      ApiEndpoints.dentalChallengeBrands,
      requireAuth: true,
      logTag: 'DentalChallengeService',
    );
    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Failed to load challenge brands');
    }
    final data = res['data'];
    final list = data is Map && data['brands'] is List
        ? data['brands'] as List
        : (data is List ? data : <dynamic>[]);
    return list
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<Map<String, dynamic>> joinChallenge(String challengeId) async {
    final res = await ApiClient.instance.post(
      ApiEndpoints.dentalChallengeJoin(challengeId),
      requireAuth: true,
      body: {'source': 'challenge_hero'},
      logTag: 'DentalChallengeService',
    );
    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Join failed');
    }
    final data = res['data'];
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }

  Future<String> uploadAsset(File file) async {
    final ext = file.path.toLowerCase();
    final type = ext.endsWith('.pdf') ? 'file' : 'image';
    final res = await ApiClient.instance.postMultipart(
      ApiEndpoints.upload,
      fields: {'type': type, 'folder': 'dental-challenge'},
      files: {'file': file},
      requireAuth: true,
      logTag: 'DentalChallengeService',
    );
    final data = res['data'];
    final url = res['url']?.toString() ??
        (data is Map ? data['url']?.toString() : null);
    if (url != null && url.isNotEmpty) return url;
    throw Exception(res['message'] ?? 'Upload failed');
  }

  Future<Map<String, dynamic>> submitCase({
    required String challengeId,
    required String title,
    required String brandId,
    required List<Map<String, dynamic>> attachments,
    String description = '',
  }) async {
    final res = await ApiClient.instance.post(
      ApiEndpoints.dentalChallengeSubmissions(challengeId),
      requireAuth: true,
      logTag: 'DentalChallengeService',
      body: {
        'title': title,
        'brand_id': brandId,
        'description': description,
        'attachments': attachments,
      },
    );
    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Submit failed');
    }
    final data = res['data'];
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }

  static String pickLocalized(
    Map<String, dynamic> map,
    String baseKey,
    bool isAr, {
    String fallback = '',
  }) {
    final localized = isAr
        ? (map['${baseKey}_ar']?.toString() ?? map['${baseKey}Ar']?.toString())
        : (map['${baseKey}_en']?.toString() ??
            map['${baseKey}En']?.toString());
    if (localized != null && localized.trim().isNotEmpty) return localized.trim();
    final generic = map[baseKey]?.toString();
    if (generic != null && generic.trim().isNotEmpty) return generic.trim();
    return fallback;
  }
}

