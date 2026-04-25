/// API Endpoints Configuration
class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://medex.anmka.com/api';

  /// Base URL for images and media files
  static const String imageBaseUrl = 'https://medex.anmka.com';

  /// Convert backend image path to full URL.
  /// Backend may send: relative "uploads/...", "/uploads/...", "/api/uploads/...", or full "https://...".
  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return '';
    }
    final trimmed = imagePath.trim();
    if (trimmed.isEmpty) return '';

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    String path = trimmed;
    if (path.startsWith('/uploads/')) {
      path = '/api$path';
    } else if (path.startsWith('uploads/')) {
      path = '/api/$path';
    } else if (path.startsWith('storage/') || path.startsWith('/storage/')) {
      path = path.startsWith('/') ? path : '/$path';
      if (!path.startsWith('/api/')) path = '/api$path';
    } else if (!path.startsWith('/api/')) {
      if (!path.startsWith('/')) path = '/$path';
      if (!path.startsWith('/api/')) path = '/api$path';
    }
    final noLeadingSlash = path.startsWith('/') ? path.substring(1) : path;
    return '$imageBaseUrl/$noLeadingSlash';
  }

  // App Configuration
  static String get appConfig => '$baseUrl/config/app';

  // Authentication
  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';
  static String get logout => '$baseUrl/auth/logout';
  static String get forgotPassword => '$baseUrl/auth/forgot-password';
  static String get refreshToken => '$baseUrl/auth/refresh';
  static String get me => '$baseUrl/auth/me';
  static String get profile => '$baseUrl/auth/profile';
  static String get changePassword => '$baseUrl/auth/change-password';
  static String get socialLogin => '$baseUrl/auth/social-login';
  static String get deleteAccount => '$baseUrl/auth/delete-account';

  // Home Page
  static String get home => '$baseUrl/home';

  // Categories
  static String get categories => '$baseUrl/categories';
  static String get adminCategories => '$baseUrl/admin/categories';
  static String categoryCourses(String id) => '$baseUrl/categories/$id/courses';

  // Courses
  static String get courses => '$baseUrl/courses';
  static String course(String id) => '$baseUrl/courses/$id';
  static String courseReviews(String id) => '$baseUrl/courses/$id/reviews';
  static String courseLesson(String courseId, String lessonId) =>
      '$baseUrl/courses/$courseId/lessons/$lessonId';
  static String courseLessonContent(String courseId, String lessonId) =>
      '$baseUrl/courses/$courseId/lessons/$lessonId/content';
  static String courseLessonProgress(String courseId, String lessonId) =>
      '$baseUrl/courses/$courseId/lessons/$lessonId/progress';

  // Enrollment
  static String enrollCourse(String id) => '$baseUrl/courses/$id/enroll';
  static String get enrollments => '$baseUrl/enrollments';

  // Payments & Checkout
  static String get payments => '$baseUrl/admin/payments';
  static String confirmPayment(String id) =>
      '$baseUrl/admin/payments/$id/confirm';
  static String get validateCoupon =>
      '$baseUrl/admin/payments/coupons/validate';

  // Exams
  static String get exams => '$baseUrl/admin/exams';
  static String exam(String id) => '$baseUrl/admin/exams/$id';
  static String startExam(String id) => '$baseUrl/admin/exams/$id/start';
  static String submitExam(String id) => '$baseUrl/admin/exams/$id/submit';

  // Course Exams
  static String courseExams(String courseId) =>
      '$baseUrl/courses/$courseId/exams';
  static String courseExamDetails(String courseId, String examId) =>
      '$baseUrl/courses/$courseId/exams/$examId';

  // Certificates
  static String get certificates => '$baseUrl/certificates';
  static String certificate(String id) => '$baseUrl/admin/certificates/$id';

  // Live Courses
  static String get liveCourses => '$baseUrl/live-courses';
  static String liveSession(String id) => '$baseUrl/admin/live-sessions/$id';

  // Notifications
  static String get notifications => '$baseUrl/notifications';
  static String markNotificationRead(String id) =>
      '$baseUrl/notifications/$id/read';
  static String get markAllNotificationsRead =>
      '$baseUrl/notifications/read-all';

  // Downloads
  static String get curriculum => '$baseUrl/admin/curriculum';
  static String curriculumItem(String id) => '$baseUrl/admin/curriculum/$id';

  // Search
  static String get search => '$baseUrl/search';

  // Upload (API_DOCUMENTATION - POST multipart, returns url)
  static String get upload => '$baseUrl/upload';

  // Wishlist
  static String get wishlist => '$baseUrl/wishlist';
  static String wishlistItem(String courseId) => '$baseUrl/wishlist/$courseId';

  // QR Code (student/teacher - TEACHER_DASHBOARD_API uses attendance path)
  static String get myQrCode => '$baseUrl/my-qr-code';
  static String get attendanceMyQrCode => '$baseUrl/attendance/my-qr-code';

  // Progress
  static String progress(String period) => '$baseUrl/progress?period=$period';

  // Teachers (public)
  static String get teachers => '$baseUrl/teachers';
  static String teacher(String id) => '$baseUrl/teachers/$id';
  static String teacherCourses(String id) => '$baseUrl/teachers/$id/courses';

  // Teacher dashboard (admin/instructor APIs - TEACHER_DASHBOARD_API.md)
  static String get adminDashboardOverview =>
      '$baseUrl/admin/dashboard/overview';
  static String get adminDashboardCharts => '$baseUrl/admin/dashboard/charts';
  static String get adminDashboardActivity =>
      '$baseUrl/admin/dashboard/activity';
  static String get adminCourses => '$baseUrl/admin/courses';
  static String adminCourse(String id) => '$baseUrl/admin/courses/$id';

  /// Curriculum per teacher reference: GET/PUT /api/admin/curriculum/:courseId
  static String adminCurriculum(String courseId) =>
      '$baseUrl/admin/curriculum/$courseId';
  static String adminCurriculumSections(String courseId) =>
      '$baseUrl/admin/curriculum/$courseId/sections';
  static String adminCurriculumSection(String courseId, String sectionId) =>
      '$baseUrl/admin/curriculum/$courseId/sections/$sectionId';
  static String adminCurriculumLessons(String courseId, String sectionId) =>
      '$baseUrl/admin/curriculum/$courseId/sections/$sectionId/lessons';
  static String adminCurriculumLesson(
          String courseId, String sectionId, String lessonId) =>
      '$baseUrl/admin/curriculum/$courseId/sections/$sectionId/lessons/$lessonId';
  static String adminCourseCurriculum(String courseId) =>
      '$baseUrl/admin/courses/$courseId/curriculum';
  static String adminCourseLectures(String courseId) =>
      '$baseUrl/admin/courses/$courseId/lectures';
  static String adminCourseLecture(String courseId, String lectureId) =>
      '$baseUrl/admin/courses/$courseId/lectures/$lectureId';
  static String get adminPayments => '$baseUrl/admin/payments';
  static String get adminUsersMeEarnings => '$baseUrl/admin/users/me/earnings';
  static String adminUsersEarnings(String userId) =>
      '$baseUrl/admin/users/$userId/earnings';
  static String get adminTeachersMeSalarySettings =>
      '$baseUrl/admin/teachers/me/salary-settings';
  static String get adminTeachersMeCalculateSalary =>
      '$baseUrl/admin/teachers/me/calculate-salary';
  static String get adminTeachersReports => '$baseUrl/admin/teachers/reports';

  // Attendance (teacher/instructor)
  static String get adminAttendance => '$baseUrl/admin/attendance';
  static String get attendanceMyAttendance =>
      '$baseUrl/attendance/my-attendance';
  static String get attendanceScan => '$baseUrl/attendance/scan';
  static String get attendanceSession => '$baseUrl/attendance/session';

  // Update student parent phone (teacher only - students in their courses)
  static String adminStudentParentPhone(String studentId) =>
      '$baseUrl/admin/students/$studentId/parent-phone';

  // Chat (teacher-student)
  static String get chatConversations => '$baseUrl/chat/conversations';

  /// Socket.IO base URL – same host as [baseUrl], HTTPS, no port (default 443).
  /// Use with socket_io_client at path /api/socket.io.
  static String get chatSocketBaseUrl {
    final url =
        baseUrl.replaceFirst('https://', '').replaceFirst('http://', '');
    final host = url.split('/').first;
    // Strip port if present; never add :0 or empty port
    final cleanHost = host.contains(':') ? host.split(':').first : host;
    return 'https://$cleanHost';
  }

  static String chatConversation(String id) =>
      '$baseUrl/chat/conversations/$id';
  static String chatMessages(String conversationId) =>
      '$baseUrl/chat/conversations/$conversationId/messages';
  static String chatMessageRead(String messageId) =>
      '$baseUrl/chat/messages/$messageId/read';

  // Community
  static String get communityPosts => '$baseUrl/community/posts';
  static String communityPost(String id) => '$baseUrl/community/posts/$id';
  static String get communitySearch => '$baseUrl/community/search';
  static String communityComments(String postId) =>
      '$baseUrl/community/posts/$postId/comments';
  static String communityPostReactions(String postId) =>
      '$baseUrl/community/posts/$postId/reactions';
  static String communityCommentReactions(String commentId) =>
      '$baseUrl/community/comments/$commentId/reactions';
  static String communityShare(String postId) =>
      '$baseUrl/community/posts/$postId/share';
  static String communityReportPost(String postId) =>
      '$baseUrl/community/posts/$postId/report';
  static String communityReportComment(String commentId) =>
      '$baseUrl/community/comments/$commentId/report';

  // Clinical Cases
  static String get clinicalCases => '$baseUrl/clinical-cases';
  static String clinicalCase(String caseId) => '$baseUrl/clinical-cases/$caseId';
  static String clinicalCaseRatings(String caseId) =>
      '$baseUrl/clinical-cases/$caseId/ratings';
  static String clinicalCaseEvents(String caseId) =>
      '$baseUrl/clinical-cases/$caseId/events';

  // Store
  static String get storeCategories => '$baseUrl/store/categories';
  static String get storeProducts => '$baseUrl/store/products';
  static String storeProduct(String productId) =>
      '$baseUrl/store/products/$productId';
  static String get storeCart => '$baseUrl/store/cart';
  static String get storeCartItems => '$baseUrl/store/cart/items';
  static String storeCartItem(String itemId) =>
      '$baseUrl/store/cart/items/$itemId';
  static String get storeCartClear => '$baseUrl/store/cart/clear';
  static String get storeAddresses => '$baseUrl/store/addresses';
  static String storeAddress(String addressId) =>
      '$baseUrl/store/addresses/$addressId';
  static String get storeShippingMethods => '$baseUrl/store/shipping-methods';
  static String get storeCheckoutPreview => '$baseUrl/store/checkout/preview';
  static String get storeOrders => '$baseUrl/store/orders';
  static String storeOrder(String orderId) => '$baseUrl/store/orders/$orderId';
  static String storeOrderMarkReceived(String orderId) =>
      '$baseUrl/store/orders/$orderId/mark-received';
  static String storeRentalMarkReceived(String rentalId) =>
      '$baseUrl/store/rentals/$rentalId/mark-received';
  static String cancelStoreOrder(String orderId) =>
      '$baseUrl/store/orders/$orderId/cancel';
  static String get storeValidateCoupon => '$baseUrl/store/coupons/validate';
}
