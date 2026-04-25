import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';

class ClinicalCasesService {
  ClinicalCasesService._();
  static final ClinicalCasesService instance = ClinicalCasesService._();

  Future<List<Map<String, dynamic>>> getCases({
    int page = 1,
    int perPage = 10,
    String? search,
    String? category,
    int? year,
    String? doctorId,
    String? country,
    String? brand,
    String? sort,
  }) async {
    final query = <String, String>{
      'page': '$page',
      'per_page': '$perPage',
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      if (category != null && category.trim().isNotEmpty)
        'category': category.trim(),
      if (year != null) 'year': '$year',
      if (doctorId != null && doctorId.trim().isNotEmpty)
        'doctor_id': doctorId.trim(),
      if (country != null && country.trim().isNotEmpty) 'country': country.trim(),
      if (brand != null && brand.trim().isNotEmpty) 'brand': brand.trim(),
      if (sort != null && sort.trim().isNotEmpty) 'sort': sort.trim(),
    };

    final url = Uri.parse(ApiEndpoints.clinicalCases)
        .replace(queryParameters: query)
        .toString();
    final response = await ApiClient.instance.get(
      url,
      requireAuth: true,
      logTag: 'ClinicalCasesService',
    );
    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to fetch clinical cases');
    }

    final data = response['data'];
    final root = data is Map && data['data'] is Map ? data['data'] : data;
    final list = root is Map && root['cases'] is List
        ? root['cases'] as List
        : (root is List ? root : <dynamic>[]);
    return list
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<Map<String, dynamic>> getCaseDetail(String caseId) async {
    final response = await ApiClient.instance.get(
      ApiEndpoints.clinicalCase(caseId),
      requireAuth: true,
      logTag: 'ClinicalCasesService',
    );
    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to fetch case detail');
    }
    final data = response['data'];
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw Exception('Invalid case detail response');
  }

  Future<Map<String, dynamic>> submitRating({
    required String caseId,
    required int rating,
    String? comment,
  }) async {
    final response = await ApiClient.instance.post(
      ApiEndpoints.clinicalCaseRatings(caseId),
      body: {
        'rating': rating,
        if (comment != null && comment.trim().isNotEmpty) 'comment': comment.trim(),
      },
      requireAuth: true,
      logTag: 'ClinicalCasesService',
    );
    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to submit case rating');
    }
    final data = response['data'];
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

  static int toInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static String mediaUrl(dynamic value) {
    final url = value?.toString() ?? '';
    return ApiEndpoints.getImageUrl(url);
  }
}
