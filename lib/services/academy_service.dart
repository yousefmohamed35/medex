import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';

/// Service for Medex Academy endpoints.
class AcademyService {
  AcademyService._();

  static final AcademyService instance = AcademyService._();

  Future<Map<String, dynamic>> getCategories() async {
    final response = await ApiClient.instance.get(
      ApiEndpoints.categories,
      requireAuth: true,
      logTag: 'AcademyCategories',
    );

    if (response['success'] == true) return response;
    throw Exception(
        response['message'] ?? 'Failed to fetch academy categories');
  }

  Future<Map<String, dynamic>> getCourses({
    int page = 1,
    int perPage = 10,
    String? categoryId,
    String? level,
    String? search,
    String? sort,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
      if (categoryId != null && categoryId.trim().isNotEmpty)
        'category_id': categoryId.trim(),
      if (level != null && level.trim().isNotEmpty) 'level': level.trim(),
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      if (sort != null && sort.trim().isNotEmpty) 'sort': sort.trim(),
    };

    final url =
        '${ApiEndpoints.academyCourses}?${Uri(queryParameters: queryParams).query}';
    final response = await ApiClient.instance.get(
      url,
      requireAuth: true,
      logTag: 'AcademyCourses',
    );

    if (response['success'] == true) return response;
    throw Exception(response['message'] ?? 'Failed to fetch academy courses');
  }

  Future<Map<String, dynamic>> getCourseDetails(String courseId) async {
    final response = await ApiClient.instance.get(
      ApiEndpoints.academyCourse(courseId),
      requireAuth: true,
      logTag: 'AcademyCourseDetails',
    );

    if (response['success'] == true) return response;
    throw Exception(response['message'] ?? 'Failed to fetch academy course');
  }

  Future<Map<String, dynamic>> enrollInCourse(String courseId) async {
    final response = await ApiClient.instance.post(
      ApiEndpoints.academyEnrollCourse(courseId),
      body: {'source': 'student_app'},
      requireAuth: true,
      logTag: 'AcademyEnrollCourse',
    );

    if (response['success'] == true) return response;
    throw Exception(
        response['message'] ?? 'Failed to enroll in academy course');
  }

  Future<Map<String, dynamic>> getCourseCurriculum(String courseId) async {
    final response = await ApiClient.instance.get(
      ApiEndpoints.academyCourseCurriculum(courseId),
      requireAuth: true,
      logTag: 'AcademyCourseCurriculum',
    );

    if (response['success'] == true) return response;
    throw Exception(
        response['message'] ?? 'Failed to fetch academy curriculum');
  }

  Future<Map<String, dynamic>> getLessonDetails(String lessonId) async {
    final response = await ApiClient.instance.get(
      ApiEndpoints.academyLesson(lessonId),
      requireAuth: true,
      logTag: 'AcademyLessonDetails',
    );

    if (response['success'] == true) return response;
    throw Exception(response['message'] ?? 'Failed to fetch academy lesson');
  }

  Future<Map<String, dynamic>> saveLessonProgress(
    String lessonId, {
    required int watchedSeconds,
    required int durationSeconds,
    required bool isCompleted,
  }) async {
    final response = await ApiClient.instance.post(
      ApiEndpoints.academyLessonProgress(lessonId),
      body: {
        'watched_seconds': watchedSeconds,
        'duration_seconds': durationSeconds,
        'is_completed': isCompleted,
      },
      requireAuth: true,
      logTag: 'AcademyLessonProgress',
    );

    if (response['success'] == true) return response;
    throw Exception(response['message'] ?? 'Failed to save lesson progress');
  }

  Future<Map<String, dynamic>> completeLesson(String lessonId) async {
    final response = await ApiClient.instance.post(
      ApiEndpoints.academyLessonComplete(lessonId),
      body: <String, dynamic>{},
      requireAuth: true,
      logTag: 'AcademyLessonComplete',
    );

    if (response['success'] == true) return response;
    throw Exception(response['message'] ?? 'Failed to complete lesson');
  }

  Future<Map<String, dynamic>> search({
    required String query,
    int page = 1,
    int perPage = 10,
  }) async {
    final queryParams = <String, String>{
      'q': query.trim(),
      'page': page.toString(),
      'per_page': perPage.toString(),
    };

    final url =
        '${ApiEndpoints.academySearch}?${Uri(queryParameters: queryParams).query}';
    final response = await ApiClient.instance.get(
      url,
      requireAuth: true,
      logTag: 'AcademySearch',
    );

    if (response['success'] == true) return response;
    throw Exception(response['message'] ?? 'Failed to search academy');
  }
}
