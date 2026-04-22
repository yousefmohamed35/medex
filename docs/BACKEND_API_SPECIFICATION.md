# مواصفات الـ Backend الكاملة — تطبيق Medex / LMS

هذا المستند مُستخرج من كود Flutter الحالي (`lib/core/api/api_endpoints.dart` + الخدمات). استخدمه كمرجع عند بناء أو استبدال الـ API.  
**المسار الأساسي الحالي:** `https://stp.anmka.com/api` — يُحدَّث من `ApiEndpoints.baseUrl`.

---

## 1. اتفاقيات عامة

### 1.1 تنسيق الاستجابة (Envelope)

- الطلبات الناجحة (HTTP 2xx) يجب أن ترجع **JSON object** يُفكّ في Dart كـ `Map<String, dynamic>`.
- الحقول التي يتوقعها التطبيق في أغلب الخدمات:
  - `success` (bool)
  - `message` (string، اختياري)
  - `data` (object | array | null حسب المسار)
  - `meta` (object، اختياري — للترقيم، `unread_count`, إلخ)

**أخطاء HTTP (4xx/5xx):** يُفضّل `{ "message": "..." }`. عند `401` قد يُفرغ التطبيق التوكن من التخزين المحلي.

### 1.2 المصادقة

- Header: `Authorization: Bearer <access_token>`
- `Content-Type: application/json` و `Accept: application/json`
- المسارات بدون توكن تُمرَّر بـ `requireAuth: false` في الكود.

### 1.3 التوكنات (Login / Register / Refresh / Social)

التطبيق يقرأ التوكن من **أكثر من مكان** داخل `data` (مرونة مع باكند مختلف):

| الحقل المقبول في `data` | ملاحظة |
|-------------------------|--------|
| `accessToken` | الأفضلية الأولى |
| `token` | بديل |
| `access_token` | snake_case |
| `refreshToken` / `refresh_token` | للتحديث |

**مستخدم المستخدم (`User`):** إما `data.user` (مثل تسجيل الدخول) أو `data` نفسه يمثل المستخدم (مثل بعض استجابات التسجيل).

حقول `User` المستخدمة في `User.fromJson`:

- `id`, `name` أو `nameAr`, `email`, `phone`, `avatar`, `avatar_thumbnail`, `role`, `is_verified`, `created_at`, `studentType` أو `student_type`

### 1.4 الصور والملفات

- المسارات النسبية تُحوَّل عبر `ApiEndpoints.getImageUrl()` إلى: `https://stp.anmka.com/api/...` حسب النمط.
- يُفضّل إرجاع **URL كامل** أو مسار يبدأ بـ `uploads/` أو `/api/uploads/...` لتوحيد السلوك.

### 1.5 رفع الملفات

- `POST /api/upload` — multipart:
  - صورة: حقول `type=image`، ملف الحقل `image`
  - PDF: حقول `type=file`، ملف الحقل `file`
- الاستجابة المقبولة: `url` في الجذر أو داخل `data.url`

### 1.6 ميزات بدون API حالياً (محلية في التطبيق)

| الميزة | المصدر في الكود |
|--------|------------------|
| المتجر، السلة، الطلبات، تصنيفات المنتجات الجانبية | `lib/data/sample_products.dart` + `CartService` |
| مجتمع (بوستات، تعليقات، رياكت) | `CommunityService` — بيانات وهمية |

لربطها بالباكند لاحقاً تحتاج endpoints جديدة غير موجودة في `ApiEndpoints` حالياً.

---

## 2. خريطة الشاشات ↔ الـ API

| منطقة التطبيق | الخدمة / الملف |
|---------------|----------------|
| Splash / إعدادات التطبيق عن بُعد | `AppConfigService` → `GET /config/app` |
| تسجيل الدخول، التسجيل، الخروج، التوكن، حذف الحساب | `AuthService` |
| الرئيسية (طالب) | `HomeService` → `GET /home` |
| قائمة الدورات، تفاصيل، درس، تقدم، اشتراك، مراجعات | `CoursesService` |
| التصنيفات (LMS) | `CoursesService.getCategories` |
| الملف الشخصي، تعديل، صورة، تغيير كلمة المرور | `ProfileService` |
| الإشعارات | `NotificationsService` |
| البحث | `SearchService` |
| المفضلة | `WishlistService` |
| الدفع وكوبونات الدورات | `PaymentsService` |
| الامتحانات | `ExamsService` |
| الشهادات | `CertificatesService` |
| التحميلات (منهج) | `DownloadsService` |
| البث / الجلسات الحية | `LiveCoursesService` |
| التقدم والإحصائيات | `ProgressService` |
| المدرسين | `TeachersService` |
| QR الطالب | `QrCodeService` |
| المحادثات + Socket | `ChatService` + `ChatWebSocketService` |
| لوحة المدرب | `TeacherDashboardService` |

---

## 3. Endpoints تفصيلية

### 3.1 إعداد التطبيق

**`GET /config/app`** — بدون توكن  

**`data` متوقع (نموذج `AppConfig`):**

```json
{
  "app_name": "",
  "app_name_ar": "",
  "tagline": "",
  "version": "1.0.0",
  "force_update": false,
  "min_version": "1.0.0",
  "theme": {
    "primary_color": "#7C3AED",
    "secondary_color": "#5B21B6",
    "accent_color": "#F97316",
    "success_color": "#10B981",
    "warning_color": "#EAB308",
    "error_color": "#EF4444",
    "background_color": "#FDF8F3",
    "card_color": "#FFFFFF",
    "text_color": "#1A1A2E",
    "muted_text_color": "#64748B"
  },
  "features": {
    "purchases_enabled": true,
    "free_mode": false,
    "show_prices": true,
    "show_free_badge": true,
    "live_courses_enabled": true,
    "certificates_enabled": true,
    "exams_enabled": true,
    "downloads_enabled": true
  },
  "social_links": {
    "facebook": "",
    "twitter": "",
    "instagram": "",
    "youtube": "",
    "whatsapp": ""
  },
  "support": {
    "email": "",
    "phone": "",
    "whatsapp": ""
  },
  "legal": {
    "terms_url": "",
    "privacy_url": ""
  }
}
```

---

### 3.2 المصادقة

| Method | Path | Auth | Body / ملاحظات |
|--------|------|------|----------------|
| POST | `/auth/login` | لا | `{ "email" \| "phone", "password" }` |
| POST | `/auth/register` | لا | `name`, `email`, `password`, `role`, اختياري `phone`, للطالب `student_type`: `online` \| `offline` |
| POST | `/auth/logout` | نعم | — |
| POST | `/auth/refresh` | لا | `{ "refreshToken": "..." }` |
| POST | `/auth/forgot-password` | لا | `{ "email": "..." }` |
| DELETE | `/auth/delete-account` | نعم | — |
| POST | `/auth/social-login` | لا | Google: `provider`, `id_token`, `access_token`, `fcm_token`, `device` — Apple: `provider`, `id_token`, `nonce`, `fcm_token`, `device` |

**استجابة نجاح:** `success: true` + `data` يحتوي التوكنات والمستخدم كما في القسم 1.3.

**تسجيل بحالة انتظار:** إذا `data.status == "PENDING"` التطبيق يعتبر الحساب بانتظار الموافقة وقد لا يوجد توكن بعد.

---

### 3.3 المستخدم الحالي والملف الشخصي

| Method | Path | Body |
|--------|------|------|
| GET | `/auth/me` | — |
| PUT | `/auth/profile` | JSON: `name`, `phone`, `bio`, `country`, `timezone`, `language` أو تفضيلات: `email_notifications`, `push_notifications`, `marketing_emails`, `course_reminders`, `exam_reminders` |
| POST | `/auth/profile` | multipart: ملف `avatar` (رفع الصورة) |
| POST | `/auth/change-password` | `currentPassword`, `newPassword`, `confirmPassword` |

**`GET /auth/me` → `data`:** نفس حقول المستخدم + أي حقول إضافية يعرضها الـ UI (مثل `id`).

---

### 3.4 الصفحة الرئيسية (طالب)

**`GET /home`** — يتطلب توكن  

**`data` المتوقع (معالجة في `HomeService`):**

```json
{
  "user_summary": {
    "avatar": "...",
    "name": "...",
    "...": "..."
  },
  "hero_banner": {
    "image": "...",
    "background_image": "...",
    "title": "...",
    "subtitle": "...",
    "link": "..."
  },
  "categories": [ { "id", "name", "name_ar", "icon", "image", "thumbnail", "color", "courses_count" } ],
  "featured_courses": [ /* كائن دورة */ ],
  "popular_courses": [ /* كائن دورة */ ],
  "continue_learning": [ /* كائن دورة */ ]
}
```

---

### 3.5 التصنيفات (LMS)

| Method | Path | ملاحظات |
|--------|------|---------|
| GET | `/categories` | استجابة: `data` **مصفوفة** تصنيفات |
| GET | `/admin/categories` | نفس الشكل؛ للمدرب عند `useAdmin: true` |

**عنصر تصنيف:** على الأقل `id`, `name`, `name_ar`, `icon` (قد يكون URL أو مفتاح), `color` (hex), `courses_count` (رقم).

---

### 3.6 الدورات — قائمة وتفاصيل ودروس

**`GET /courses`** — query (كما يبنيه التطبيق):

- `page`, `per_page`, `search`, `category_id`, `subcategory_id`, `instructor_id`, `price`, `level`, `sort`, `duration`

**شكل `data` المدعوم:**

- إما `{ "courses": [ ... ], "meta": { ... } }`
- أو `data` مباشرة `List` من الدورات

**`GET /courses/:id`** — تفاصيل الدورة  

حقول يقرأها `course_details_screen` وغيره (جزئياً):

- هوية وعناوين: `id`, `title`, `description`, `thumbnail`, `image`, `banner`, `cover_image`
- سعر وتسجيل: `price`, `is_free` / `isFree`, `is_enrolled`, `is_in_wishlist`
- إحصائيات: `rating`, `students_count` / `students`, `duration_hours` / `hours`
- تصنيف: `category` (نص أو `{ "name" }`)
- مدرب: `instructor_id` أو `instructor: { "id", "name", "avatar" }`
- منهج: **`curriculum`** (قائمة أقسام) و/أو **`lessons`** (قائمة مسطحة)
  - قسم: `id`, `title`, `order`, `type`, `duration_minutes`, `video`, `youtube_id`, `lessons` (دروس فرعية)
  - درس: `id`, `title`, `order`, `type`, `video`, `youtube_id`, `duration_minutes`, `is_locked`, `is_completed`, `content`...

**`GET /courses/:courseId/lessons/:lessonId`** — تفاصيل الدرس  

**`GET /courses/:courseId/lessons/:lessonId/content`** — محتوى الدرس (فيديو/نص/روابط حسب الباكند)

**`POST /courses/:courseId/lessons/:lessonId/progress`**  

Body:

```json
{ "watched_seconds": 0, "is_completed": false }
```

**`POST /courses/:id/enroll`** — الاشتراك في الدورة  

**`GET /enrollments`** — query: `status`, `page`, `per_page`  

`data` مدعوم كـ:

- `List` من عناصر اشتراك (غالباً فيها `course`)
- أو `Map` فيه `courses`

**`GET /categories/:id/courses`** — query: `page`, `per_page`, `sort`, `price`, `level`, `subcategory_id`  

`data` غالباً `{ "courses": [...] }`

**`GET /courses/:id/reviews`** — query: `page`, `per_page`, `rating`  

**`POST /courses/:id/reviews`** — body: `rating`, `title`, `comment`

---

### 3.7 البحث

**`GET /search`** — query: `q`, `type` (`all` \| `courses` \| `instructors` \| `categories`), `page`, `per_page` — **بدون توكن**

الاستجابة: `success` + `data` كـ object (هيكل يحدده الباكند؛ التطبيق يمرره كـ `Map`).

---

### 3.8 المفضلة

| Method | Path | Body |
|--------|------|------|
| GET | `/wishlist` | — |
| POST | `/wishlist` | `{ "course_id": "..." }` |
| DELETE | `/wishlist/:courseId` | — |

---

### 3.9 الدفع (دورات — ليس متجر المنتجات)

| Method | Path | Body |
|--------|------|------|
| POST | `/admin/payments` | `course_id`, `payment_method`, اختياري `coupon_code` |
| POST | `/admin/payments/:id/confirm` | `checkout_session_id`, `payment_method`, `payment_token` |
| POST | `/admin/payments/coupons/validate` | `code`, `course_id` |

---

### 3.10 الامتحانات

| Method | Path | ملاحظات |
|--------|------|---------|
| GET | `/admin/exams/:id` | تفاصيل امتحان |
| POST | `/admin/exams/:id/start` | بدء محاولة |
| POST | `/admin/exams/:id/submit` | `{ "attempt_id", "answers": [ { ... } ] }` |
| GET | `/admin/exams` | امتحانات المستخدم |
| GET | `/courses/:courseId/exams` | **بدون توكن** — قائمة |
| GET | `/courses/:courseId/exams/:examId` | **بدون توكن** — تفاصيل |

---

### 3.11 الشهادات

| Method | Path | Auth |
|--------|------|------|
| GET | `/certificates` | نعم — التطبيق يتوقع `success` وقد يستخدم الجسم كاملاً |
| GET | `/admin/certificates/:id` | لا — تحقق من شهادة |

---

### 3.12 التحميلات (Curriculum كموارد قابلة للتحميل)

| Method | Path | Body |
|--------|------|------|
| GET | `/admin/curriculum` | — |
| POST | `/admin/curriculum` | `{ "resource_id": "..." }` |
| DELETE | `/admin/curriculum/:id` | — |

---

### 3.13 البث المباشر

| Method | Path |
|--------|------|
| GET | `/live-courses` |
| POST | `/admin/live-sessions/:id` |

---

### 3.14 التقدم

**`GET /progress?period=...`** — `period` مثل `weekly` / `monthly` (نص حسب الاستخدام في الشاشة)

**`data`:** يُفضّل أن يحتوي على حقول للرسوم البيانية؛ التطبيق يعالج:

- `user.avatar`
- `top_students[].avatar`

---

### 3.15 الإشعارات

| Method | Path | Query / Body |
|--------|------|--------------|
| GET | `/notifications` | `page`, `per_page`, `unread_only` |
| POST | `/notifications/:id/read` | — |
| POST | `/notifications/read-all` | — |

**استجابة القائمة:** قد تكون `data` قائمة مباشرة أو داخل map؛ و`meta.unread_count` مفيد للواجهة.

**بعد read-all:** `data.marked_count`, `data.unread_count` (اختياري)

---

### 3.16 المدرسون (عام)

| Method | Path | Query |
|--------|------|--------|
| GET | `/teachers` | `page`, `per_page`, `sort`, `search` |
| GET | `/teachers/:id` | — |
| GET | `/teachers/:id/courses` | `page`, `per_page` |

**قائمة المدرسين:** `data` إما `{ "teachers": [...] }` أو `List` مباشرة.  

**دورات المدرس:** `data` مع `courses` أو قائمة دورات.

---

### 3.17 QR الحضور (طالب)

يُجرب التطبيق بالترتيب:

1. **`GET /attendance/my-qr-code`**
2. **`GET /my-qr-code`**

**`data` المتوقع:** `{ "qr_code": "..." }` أو `{ "user": { "id": "..." } }` كبديل لإنشاء QR من المعرف.

---

### 3.18 المحادثات (REST)

| Method | Path | Query / Body |
|--------|------|--------------|
| GET | `/chat/conversations` | `page`, `limit` |
| POST | `/chat/conversations` | `{ "otherUserId": "..." }` |
| GET | `/chat/conversations/:id/messages` | `page`, `limit` |
| POST | `/chat/conversations/:id/messages` | `{ "body": "..." }` |
| PATCH | `/chat/messages/:messageId/read` | `{}` |

**مرونة `data`:** قد يكون map فيه `conversations` / `messages` أو القوائم مباشرة.

### 3.19 Socket.IO (دردشة فورية)

- **Base URL:** نفس host الـ API بدون `/api` (مثال: `https://stp.anmka.com`)
- **Path:** `/api/socket.io`
- **Auth عند الاتصال:** `{ "token": "<access_token>" }`
- بعد الاتصال: emit **`subscribe`** مع `{ "conversationId": "..." }`
- الأحداث الواردة التي يستمع لها التطبيق: `message`, `new_message`, `chat:message`  
  الحمولة: يُفضّل object فيه حقول الرسالة (`id`, `body`, `senderId`, `createdAt`, …) أو متداخلة تحت `message` / `data`.

---

### 3.20 لوحة المدرب / الأدمن (Instructor)

كلها تتطلب توكن دور `instructor` / `teacher` (حسب الباكند).

| الوظيفة | Method | Path |
|---------|--------|------|
| نظرة عامة | GET | `/admin/dashboard/overview` |
| رسوم بيانية | GET | `/admin/dashboard/charts` |
| النشاط الأخير | GET | `/admin/dashboard/activity` |
| إنشاء دورة | POST | `/admin/courses` |
| دوراتي | GET | `/admin/courses?instructorId=&page=&limit=&status=` |
| تفاصيل دورة (أدمن) | GET | `/admin/courses/:id` |
| أرباحي | GET | `/admin/users/me/earnings` أو `/admin/users/:userId/earnings` |
| المدفوعات | GET | `/admin/payments?page=&limit=&status=` |
| إعدادات الراتب | GET | `/admin/teachers/me/salary-settings` |
| حساب الراتب | POST | `/admin/teachers/me/calculate-salary` body: `startDate`, `endDate` |
| تقارير | GET | `/admin/teachers/reports?teacherId=&startDate=&endDate=&summary=&page=&limit=` |
| حضور (إداري) | GET | `/admin/attendance?page=&limit=&courseId=&action=` |
| تحديث هاتف ولي أمر | PATCH | `/admin/students/:studentId/parent-phone` body: `{ "parentPhone": "" }` |
| منهج — جلب | GET | `/admin/curriculum/:courseId` |
| منهج — حفظ كامل | PUT | `/admin/curriculum/:courseId` body: `{ "sections": [ ... ] }` |
| قسم — إنشاء | POST | `/admin/curriculum/:courseId/sections` body: `title`, `order` |
| قسم — تحديث | PUT | `/admin/curriculum/:courseId/sections/:sectionId` |
| قسم — حذف | DELETE | `/admin/curriculum/:courseId/sections/:sectionId` |
| درس — إنشاء | POST | `/admin/curriculum/.../lessons` body: `title`, `type`, `duration`, `isFree`, `order`, اختياري `content`, `videoUrl`, `fileUrl` |
| درس — تحديث | PUT | `.../lessons/:lessonId` |
| درس — حذف | DELETE | `.../lessons/:lessonId` |
| محاضرات — قائمة | GET | `/admin/courses/:courseId/lectures?page=&limit=` |
| محاضرة — تفاصيل | GET | `/admin/courses/:courseId/lectures/:lectureId` |
| محاضرة — إضافة | POST | `/admin/courses/:courseId/lectures` body: حسب الشاشة |
| محاضرة — تحديث | PUT | `.../lectures/:lectureId` |
| محاضرة — حذف | DELETE | `.../lectures/:lectureId` |
| جلسة حضور | GET | `/attendance/session?course_id=&session_title=` |
| مسح QR حضور | POST | `/attendance/scan` body: `qr_code`, `course_id`, `session_title` |
| حضوري | GET | `/attendance/my-attendance?page=&limit=&startDate=&endDate=` |

**إنشاء دورة (POST `/admin/courses`) — body من التطبيق:**

`title`, `categoryId`, `instructorId`, `level`, `duration`, `status`, `isFeatured`, اختياري `description`, `thumbnail`, `price`, `discountPrice`

---

## 4. كائن «دورة» موحّد (توصية للباكند الجديد)

لتقليل الفروع في الواجهة، يُفضّل أن يعيد كل من `GET /courses` و `GET /courses/:id` وعناصر `home` نفس الشكل تقريباً:

```json
{
  "id": "string",
  "title": "string",
  "description": "string",
  "thumbnail": "string",
  "price": 0,
  "is_free": false,
  "is_enrolled": false,
  "is_in_wishlist": false,
  "rating": 4.5,
  "students_count": 0,
  "duration_hours": 0,
  "category": { "id": "string", "name": "string", "name_ar": "string" },
  "instructor": { "id": "string", "name": "string", "avatar": "string" },
  "curriculum": [
    {
      "id": "string",
      "title": "string",
      "order": 0,
      "lessons": [
        {
          "id": "string",
          "title": "string",
          "type": "video",
          "order": 0,
          "duration_minutes": 0,
          "video": "url|null",
          "youtube_id": "string|null",
          "is_locked": false,
          "is_completed": false
        }
      ]
    }
  ]
}
```

---

## 5. مراجع الملفات في المشروع

- المسارات: `lib/core/api/api_endpoints.dart`
- العميل: `lib/core/api/api_client.dart`
- نماذج: `lib/models/auth_response.dart`, `lib/models/user.dart`, `lib/models/app_config.dart`

---

*آخر تحديث: مُولَّد من تحليل الكود — راجع بعد أي تغيير على الخدمات.*
