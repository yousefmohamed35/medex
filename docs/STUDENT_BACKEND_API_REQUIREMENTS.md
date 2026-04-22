# MEDEX MOBILE - FINAL BACKEND API CONTRACT

Purpose: this file is the final handoff contract for backend implementation.
Everything in app must come from API (no static/sample/local fallback for production).

## 1) Global Standards

- Base URL: `https://medex2.anmka.com/api`
- Auth: `Authorization: Bearer <token>` on protected routes
- Headers:
  - `Content-Type: application/json`
  - `Accept: application/json`
- Time format: ISO8601 UTC (`2026-04-14T12:30:00Z`)
- Currency: `EGP`
- Pagination standard:
  - request: `page`, `per_page`
  - response: `meta.page`, `meta.per_page`, `meta.total`, `meta.last_page`

### 1.1 Unified Response Envelope
```json
{
  "success": true,
  "message": "Success message",
  "data": {},
  "meta": {
    "request_id": "req_9f02",
    "timestamp": "2026-04-14T12:30:00Z"
  }
}
```

### 1.2 Unified Error Envelope
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "email": ["Email is required"]
  },
  "meta": {
    "request_id": "req_9f03",
    "timestamp": "2026-04-14T12:31:00Z"
  }
}
```

## 2) Strict Data Completeness Rules (Important)

Backend must not send incomplete placeholder payloads in production.

- Do not return structural placeholders like:
  - `media: []` for posts that contain media
  - `instructor: {}` for course cards
  - `user_summary: null`
- If value exists in domain, it must be returned in response.
- If list has no items, return empty list only when truly no data, but all parent objects must still be complete.
- Required object shapes must always exist (ex: `totals`, `author`, `summary`, `meta`).

---

## 3) Feature: Authentication

### 3.1 Login
`POST /auth/login` (public)

Request:
```json
{
  "email": "student@example.com",
  "password": "12345678"
}
```

Response:
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "token": "jwt_access",
    "refresh_token": "jwt_refresh",
    "expires_in": 3600,
    "user": {
      "id": "u_1001",
      "name": "Ahmed Ali",
      "email": "student@example.com",
      "phone": "+201000000000",
      "role": "student",
      "status": "ACTIVE",
      "avatar": "/uploads/avatars/u_1001.jpg"
    }
  }
}
```

### 3.2 Register
`POST /auth/register` (public)
```json
{
  "name": "Ahmed Ali",
  "email": "student@example.com",
  "phone": "+201000000000",
  "password": "12345678",
  "role": "student",
  "student_type": "online"
}
```

### 3.3 Refresh Token
`POST /auth/refresh`
```json
{ "refreshToken": "jwt_refresh" }
```

### 3.4 Forgot Password
`POST /auth/forgot-password`
```json
{ "email": "student@example.com" }
```

### 3.5 Social Login
`POST /auth/social-login`
```json
{
  "provider": "google",
  "id_token": "google_id_token",
  "access_token": "google_access_token",
  "fcm_token": "fcm_123",
  "device": {
    "platform": "android",
    "model": "Samsung S24",
    "app_version": "1.0.0"
  }
}
```

### 3.6 Logout / Delete Account
- `POST /auth/logout`
- `DELETE /auth/delete-account`

---

## 4) Feature: Profile

- `GET /auth/me`
- `PUT /auth/profile`
- `POST /auth/change-password`
- `POST /auth/profile` (multipart avatar)

Update profile request:
```json
{
  "name": "Ahmed Ali Updated",
  "phone": "+201000000001",
  "bio": "Implantology student",
  "country": "EG",
  "timezone": "Africa/Cairo",
  "language": "ar"
}
```

---

## 5) Feature: App Config + Home

### 5.1 App Config
`GET /config/app` (public)

### 5.2 Home Feed
`GET /home` (protected)

Response (fully populated example):
```json
{
  "success": true,
  "data": {
    "user_summary": {
      "id": "u_1001",
      "name": "Ahmed Ali",
      "avatar": "/uploads/avatars/u_1001.jpg",
      "enrolled_courses_count": 8,
      "completed_courses_count": 3
    },
    "hero_banner": {
      "id": "hb_10",
      "title": "New Implantology Track",
      "subtitle": "Start now with top instructors",
      "image": "/uploads/banners/home_10.jpg",
      "cta_label": "Explore",
      "cta_url": "/courses?track=implant"
    },
    "categories": [
      {
        "id": "cat_1",
        "name": "Implantology",
        "name_ar": "زراعة الأسنان",
        "icon": "/uploads/icons/implant.png",
        "courses_count": 42
      }
    ],
    "featured_courses": [
      {
        "id": "c_1",
        "title": "Implant Basics",
        "thumbnail": "/uploads/courses/c1.jpg",
        "price": 1200,
        "rating": 4.8,
        "instructor": {
          "id": "t_1",
          "name": "Dr. Karim",
          "avatar": "/uploads/avatars/t1.jpg"
        }
      }
    ],
    "popular_courses": [
      {
        "id": "c_2",
        "title": "Advanced GBR",
        "thumbnail": "/uploads/courses/c2.jpg",
        "price": 1800,
        "rating": 4.9,
        "students_count": 540
      }
    ],
    "continue_learning": [
      {
        "id": "c_3",
        "title": "Digital Dentistry",
        "thumbnail": "/uploads/courses/c3.jpg",
        "progress_percent": 62,
        "next_lesson_id": "l_33"
      }
    ]
  }
}
```

---

## 6) Feature: Courses + Lessons + Progress

- `GET /courses`
- `GET /courses/:courseId`
- `GET /courses/:courseId/lessons/:lessonId`
- `GET /courses/:courseId/lessons/:lessonId/content`
- `POST /courses/:courseId/lessons/:lessonId/progress`
- `POST /courses/:courseId/enroll`
- `GET /enrollments`

Progress request:
```json
{
  "watched_seconds": 420,
  "is_completed": true
}
```

Progress response:
```json
{
  "success": true,
  "data": {
    "course_id": "c_1",
    "lesson_id": "l_2",
    "watched_seconds": 420,
    "is_completed": true,
    "course_progress_percent": 34
  }
}
```

---

## 7) Feature: Reviews + Wishlist + Search + Teachers

### Reviews
- `GET /courses/:courseId/reviews`
- `POST /courses/:courseId/reviews`

Review request:
```json
{
  "rating": 5,
  "title": "Excellent",
  "comment": "Very practical and clear."
}
```

### Wishlist
- `GET /wishlist`
- `POST /wishlist`
- `DELETE /wishlist/:courseId`

Add wishlist request:
```json
{ "course_id": "c_1" }
```

### Search
- `GET /search?q=implant&type=all&page=1&per_page=20`

### Teachers
- `GET /teachers`
- `GET /teachers/:teacherId`
- `GET /teachers/:teacherId/courses`

---

## 8) Feature: Exams

- `GET /courses/:courseId/exams`
- `GET /courses/:courseId/exams/:examId`
- `GET /admin/exams/:examId`
- `POST /admin/exams/:examId/start`
- `POST /admin/exams/:examId/submit`

Submit request:
```json
{
  "attempt_id": "att_1",
  "answers": [
    { "question_id": "q1", "answer": "A" },
    { "question_id": "q2", "answer": ["B", "D"] }
  ]
}
```

---

## 9) Feature: Payments (Courses)

- `POST /admin/payments`
- `POST /admin/payments/:checkoutSessionId/confirm`
- `POST /admin/payments/coupons/validate`

Initiate checkout request:
```json
{
  "course_id": "c_1",
  "payment_method": "card",
  "coupon_code": "WELCOME10"
}
```

Initiate checkout response:
```json
{
  "success": true,
  "data": {
    "checkout_session_id": "chk_123",
    "amount": 900,
    "currency": "EGP",
    "payment_url": "https://gateway.com/checkout/chk_123",
    "course_id": "c_1"
  }
}
```

---

## 10) Feature: Notifications + Certificates + Live + Downloads + Progress QR

### Notifications
- `GET /notifications`
- `POST /notifications/:notificationId/read`
- `POST /notifications/read-all`

### Certificates
- `GET /certificates`
- `GET /admin/certificates/:certificateId`

### Live
- `GET /live-courses`
- `POST /admin/live-sessions/:liveSessionId`

### Downloads
- `GET /admin/curriculum`
- `POST /admin/curriculum`
- `DELETE /admin/curriculum/:downloadId`

Download request:
```json
{ "resource_id": "res_123" }
```

### Progress + QR
- `GET /progress?period=weekly`
- `GET /attendance/my-qr-code`
- fallback: `GET /my-qr-code`

QR response:
```json
{
  "success": true,
  "data": {
    "qr_code": "encrypted_qr_payload_u_1001",
    "user": {
      "id": "u_1001",
      "name": "Ahmed Ali"
    }
  }
}
```

---

## 11) Feature: Upload

`POST /upload` (multipart)

- image upload:
  - field `type=image`
  - file field `image`
- file upload:
  - field `type=file`
  - file field `file`

Response:
```json
{
  "success": true,
  "data": {
    "url": "/uploads/files/doc_001.pdf",
    "mime_type": "application/pdf",
    "size_bytes": 582233
  }
}
```

---

## 12) Feature: Chat (REST + Socket)

### REST
- `GET /chat/conversations?page=1&limit=50`
- `POST /chat/conversations`
- `GET /chat/conversations/:conversationId/messages?page=1&limit=50`
- `POST /chat/conversations/:conversationId/messages`
- `PATCH /chat/messages/:messageId/read`

Create conversation request:
```json
{ "otherUserId": "u_2002" }
```

Send message request:
```json
{ "body": "Hello doctor" }
```

Message response:
```json
{
  "success": true,
  "data": {
    "id": "m_991",
    "conversation_id": "conv_1",
    "sender_id": "u_1001",
    "body": "Hello doctor",
    "is_read": false,
    "created_at": "2026-04-14T13:00:00Z"
  }
}
```

### Socket
- Base: `https://medex2.anmka.com`
- Path: `/api/socket.io`
- Auth payload:
```json
{ "token": "jwt_access" }
```
- Subscribe event payload:
```json
{ "conversationId": "conv_1" }
```
- Server emits:
  - `message`
  - `new_message`
  - `chat:message`

---

## 13) Feature: Community (Full API, no static)

Community in production must be 100% API-driven.

### 13.1 Feed
`GET /community/posts?page=1&per_page=20&sort=latest`

Response (non-empty media example):
```json
{
  "success": true,
  "data": {
    "posts": [
      {
        "id": "post_1",
        "author": {
          "id": "u_2001",
          "name": "د. أحمد محمود",
          "avatar": "/uploads/avatars/u_2001.jpg",
          "title": "أخصائي زراعة أسنان"
        },
        "content": "نتيجة حالة GBR بعد 6 شهور ممتازة.",
        "media": [
          {
            "id": "med_1",
            "type": "image",
            "url": "/uploads/community/post_1_img1.jpg",
            "thumbnail": "/uploads/community/post_1_thumb1.jpg",
            "width": 1200,
            "height": 900
          }
        ],
        "likes_count": 45,
        "comments_count": 12,
        "shares_count": 5,
        "viewer_reaction": "like",
        "created_at": "2026-04-14T10:30:00Z"
      }
    ],
    "meta": { "page": 1, "per_page": 20, "total": 340, "last_page": 17 }
  }
}
```

### 13.2 Search Community
`GET /community/search?q=powerbone&type=posts&page=1&per_page=20`

Allowed type:
- `posts`
- `users`
- `hashtags`
- `all`

Response:
```json
{
  "success": true,
  "data": {
    "posts": [
      {
        "id": "post_88",
        "content": "مين جرب Powerbone Surgical Kit؟",
        "author_name": "د. عمر خالد",
        "created_at": "2026-04-12T18:00:00Z",
        "highlight": "Powerbone Surgical Kit"
      }
    ],
    "users": [
      {
        "id": "u_500",
        "name": "Powerbone Academy",
        "avatar": "/uploads/avatars/u_500.jpg"
      }
    ],
    "hashtags": [
      {
        "tag": "#Powerbone",
        "posts_count": 128
      }
    ],
    "meta": { "page": 1, "per_page": 20, "total": 154, "last_page": 8 }
  }
}
```

### 13.3 Create Post
`POST /community/posts`

Request:
```json
{
  "content": "حالة جديدة مع صور قبل وبعد.",
  "media": [
    "/uploads/temp/post_img_1.jpg",
    "/uploads/temp/post_img_2.jpg"
  ]
}
```

### 13.4 Post Details
`GET /community/posts/:postId`

### 13.5 Comments
- `GET /community/posts/:postId/comments?page=1&per_page=30`
- `POST /community/posts/:postId/comments`

Comment request:
```json
{
  "content": "ممتاز جدًا، هل استخدمت membrane من نوع B&B؟"
}
```

### 13.6 Reactions
- `POST /community/posts/:postId/reactions`
- `DELETE /community/posts/:postId/reactions`
- `POST /community/comments/:commentId/reactions`

Reaction request:
```json
{ "reaction": "love" }
```

### 13.7 Share + Report
- `POST /community/posts/:postId/share`
- `POST /community/posts/:postId/report`
- `POST /community/comments/:commentId/report`

Report request:
```json
{
  "reason": "spam",
  "details": "Repeated promotional content"
}
```

---

## 14) Feature: E-commerce Store (Full API, no static)

Store screens currently have static data in app; production must use APIs below.

### 14.1 Categories
`GET /store/categories?page=1&per_page=20`

### 14.2 Products
`GET /store/products?page=1&per_page=20&category_id=bb-dental&sort=popular`

### 14.3 Product Details
`GET /store/products/:productId`

### 14.4 Cart
- `GET /store/cart`
- `POST /store/cart/items`
- `PATCH /store/cart/items/:itemId`
- `DELETE /store/cart/items/:itemId`
- `DELETE /store/cart/clear`

Add purchase request:
```json
{
  "product_id": "p_1",
  "quantity": 2,
  "is_rental": false
}
```

Add rental request:
```json
{
  "product_id": "p_1",
  "quantity": 1,
  "is_rental": true
}
```

Cart response:
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "ci_1",
        "product_id": "p_1",
        "name": "B&B Implant System - Standard",
        "name_ar": "نظام زراعة B&B - قياسي",
        "image_url": "/uploads/store/p1.jpg",
        "quantity": 2,
        "price": 4500,
        "rental_price": 1200,
        "is_rental": false,
        "line_total": 9000
      }
    ],
    "summary": {
      "item_count": 2,
      "subtotal": 9000,
      "discount": 900,
      "shipping": 150,
      "total": 8250
    }
  }
}
```

### 14.5 Addresses
- `GET /store/addresses`
- `POST /store/addresses`
- `PATCH /store/addresses/:addressId`
- `DELETE /store/addresses/:addressId`

### 14.6 Shipping Methods
`GET /store/shipping-methods?city=Giza&country=EG`

### 14.7 Checkout Preview
`POST /store/checkout/preview`
```json
{
  "address_id": "addr_1",
  "shipping_method_id": "ship_standard",
  "coupon_code": "WELCOME10",
  "payment_method": "card"
}
```

### 14.8 Orders
- `POST /store/orders`
- `GET /store/orders`
- `GET /store/orders/:orderId`
- `POST /store/orders/:orderId/cancel`

Create order request:
```json
{
  "address_id": "addr_1",
  "shipping_method_id": "ship_standard",
  "payment_method": "card",
  "payment_token": "gateway_token",
  "notes": "Call before delivery"
}
```

Create order response:
```json
{
  "success": true,
  "data": {
    "order_id": "ORD-2026-001",
    "status": "Processing",
    "status_ar": "قيد المعالجة",
    "total_amount": 16100,
    "shipping_address": "157 Sudan St, Giza",
    "tracking_number": "TRK-998877",
    "created_at": "2026-04-14T12:00:00Z"
  }
}
```

### 14.9 Store Coupons
`POST /store/coupons/validate`
```json
{
  "code": "WELCOME10",
  "cart_total": 9000
}
```

---

## 15) Admin/Instructor APIs Also Used by App

Must remain compatible:

- `/admin/dashboard/overview`
- `/admin/dashboard/charts`
- `/admin/dashboard/activity`
- `/admin/courses` and `/admin/courses/:id`
- `/admin/curriculum/:courseId` + sections/lessons CRUD
- `/admin/courses/:courseId/lectures` + lecture CRUD
- `/admin/users/me/earnings`
- `/admin/users/:userId/earnings`
- `/admin/teachers/me/salary-settings`
- `/admin/teachers/me/calculate-salary`
- `/admin/teachers/reports`
- `/admin/attendance`
- `/attendance/session`
- `/attendance/scan`
- `/attendance/my-attendance`
- `/admin/students/:studentId/parent-phone`

---

## 16) Required HTTP Status Codes

- `200` success read/update
- `201` resource created
- `400` business/validation error
- `401` unauthorized
- `403` forbidden
- `404` not found
- `409` conflict (duplicate/state conflict)
- `422` invalid input details
- `500` internal server error

---

## 17) Final Implementation Checklist

- All app features are API-driven (no static data in production).
- All endpoints above implemented with exact method/path.
- No incomplete placeholder payloads in production responses.
- All protected routes validate JWT token.
- Response envelope unified (`success`, `message`, `data`, `meta`).
- Pagination format unified.
- Media/file URLs always valid and reachable.
- Socket path fixed: `/api/socket.io`.
- Community and Store are fully API-ready (including search, comments, reactions, cart, orders).
# Medex Backend API Requirements (Feature-Based)

الملف ده مقسوم حسب الـ Features بشكل مباشر، وكل Feature فيها:
- endpoints المطلوبة
- مثال Request
- مثال Response
- أهم Error cases

## 0) Global Contract

- Base URL: `https://medex2.anmka.com/api`
- Protected endpoints لازم:
  - `Authorization: Bearer <access_token>`
- JSON headers:
  - `Content-Type: application/json`
  - `Accept: application/json`

### Success Envelope
```json
{
  "success": true,
  "message": "Success message",
  "data": {}
}
```

### Error Envelope
```json
{
  "success": false,
  "message": "Validation error",
  "errors": {
    "email": ["Email is required"]
  }
}
```

---

## 1) Feature: Authentication

### 1.1 Login
`POST /auth/login` (public)

Request:
```json
{
  "email": "student@example.com",
  "password": "12345678"
}
```

Response:
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "token": "jwt_access",
    "refresh_token": "jwt_refresh",
    "user": {
      "id": "u_1001",
      "name": "Ahmed Ali",
      "email": "student@example.com",
      "role": "student",
      "status": "ACTIVE"
    }
  }
}
```

### 1.2 Register
`POST /auth/register` (public)

Request:
```json
{
  "name": "Ahmed Ali",
  "email": "student@example.com",
  "phone": "+201000000000",
  "password": "12345678",
  "role": "student",
  "student_type": "online"
}
```

Response:
```json
{
  "success": true,
  "message": "Registered successfully",
  "data": {
    "token": "jwt_access",
    "refresh_token": "jwt_refresh",
    "status": "ACTIVE",
    "user": { "id": "u_1001", "role": "student" }
  }
}
```

### 1.3 Refresh Token
`POST /auth/refresh` (public)

Request:
```json
{ "refreshToken": "jwt_refresh" }
```

Response:
```json
{
  "success": true,
  "data": {
    "token": "new_jwt_access",
    "refresh_token": "new_jwt_refresh"
  }
}
```

### 1.4 Forgot Password
`POST /auth/forgot-password` (public)

Request:
```json
{ "email": "student@example.com" }
```

Response:
```json
{
  "success": true,
  "message": "Password reset link sent"
}
```

### 1.5 Social Login
`POST /auth/social-login` (public)

Request (Google):
```json
{
  "provider": "google",
  "id_token": "google_id_token",
  "access_token": "google_access_token",
  "fcm_token": "fcm_123",
  "device": {
    "platform": "android",
    "model": "Samsung S24",
    "app_version": "1.0.0"
  }
}
```

---

## 2) Feature: Profile

### 2.1 Get Profile
`GET /auth/me` (protected)

Response:
```json
{
  "success": true,
  "data": {
    "id": "u_1001",
    "name": "Ahmed Ali",
    "email": "student@example.com",
    "phone": "+201000000000",
    "avatar": "/uploads/avatars/u_1001.jpg",
    "bio": "Dental student",
    "language": "ar",
    "timezone": "Africa/Cairo"
  }
}
```

### 2.2 Update Profile
`PUT /auth/profile` (protected)

Request:
```json
{
  "name": "Ahmed Ali Updated",
  "phone": "+201000000001",
  "bio": "Implantology student",
  "country": "EG",
  "language": "ar"
}
```

### 2.3 Change Password
`POST /auth/change-password` (protected)

Request:
```json
{
  "currentPassword": "old_pass",
  "newPassword": "new_pass",
  "confirmPassword": "new_pass"
}
```

### 2.4 Upload Avatar
`POST /auth/profile` (multipart, protected)
- file field: `avatar`

---

## 3) Feature: Home

### 3.1 Home Feed
`GET /home` (protected)

Response:
```json
{
  "success": true,
  "data": {
    "user_summary": {
      "name": "Ahmed",
      "avatar": "/uploads/avatars/u_1001.jpg"
    },
    "hero_banner": {
      "title": "New Courses",
      "image": "/uploads/banners/home.jpg"
    },
    "categories": [],
    "featured_courses": [],
    "popular_courses": [],
    "continue_learning": []
  }
}
```

---

## 4) Feature: Courses & Learning

### 4.1 Courses List
`GET /courses` (protected)

Query used:
- `page`, `per_page`, `search`, `category_id`, `subcategory_id`, `instructor_id`, `price`, `level`, `sort`, `duration`

Response:
```json
{
  "success": true,
  "data": {
    "courses": [
      {
        "id": "c_1",
        "title": "Implant Basics",
        "thumbnail": "/uploads/courses/c1.jpg",
        "price": 1200,
        "level": "beginner",
        "instructor": {
          "id": "t_1",
          "name": "Dr. Karim",
          "avatar": "/uploads/avatars/t1.jpg"
        }
      }
    ],
    "meta": { "page": 1, "per_page": 20, "total": 57 }
  }
}
```

### 4.2 Course Details
`GET /courses/:courseId` (protected)

### 4.3 Lesson Details
`GET /courses/:courseId/lessons/:lessonId` (protected)

### 4.4 Lesson Content
`GET /courses/:courseId/lessons/:lessonId/content` (protected)

Response (example):
```json
{
  "success": true,
  "data": {
    "lesson_id": "l_1",
    "type": "video",
    "video_url": "https://cdn.medex.com/videos/l1.mp4",
    "pdf_url": null,
    "text_content": null,
    "duration_seconds": 980
  }
}
```

### 4.5 Update Lesson Progress
`POST /courses/:courseId/lessons/:lessonId/progress` (protected)

Request:
```json
{
  "watched_seconds": 420,
  "is_completed": true
}
```

### 4.6 Enroll Course
`POST /courses/:courseId/enroll` (protected)

### 4.7 My Enrollments
`GET /enrollments?status=all&page=1&per_page=20` (protected)

### 4.8 Course Reviews
- `GET /courses/:courseId/reviews` (protected)
- `POST /courses/:courseId/reviews` (protected)

Request:
```json
{
  "rating": 5,
  "title": "Excellent",
  "comment": "Very practical content"
}
```

---

## 5) Feature: Exams

- `GET /courses/:courseId/exams` (public in app)
- `GET /courses/:courseId/exams/:examId` (public in app)
- `GET /admin/exams/:examId` (protected)
- `POST /admin/exams/:examId/start` (protected)
- `POST /admin/exams/:examId/submit` (protected)

Submit Request:
```json
{
  "attempt_id": "att_1",
  "answers": [
    { "question_id": "q1", "answer": "A" },
    { "question_id": "q2", "answer": ["B", "D"] }
  ]
}
```

Submit Response:
```json
{
  "success": true,
  "data": {
    "score": 18,
    "total": 20,
    "passed": true,
    "result_id": "res_889"
  }
}
```

---

## 6) Feature: Wishlist

- `GET /wishlist` (protected)
- `POST /wishlist` (protected)
- `DELETE /wishlist/:courseId` (protected)

Add Request:
```json
{ "course_id": "c_1" }
```

---

## 7) Feature: Search & Teachers

- `GET /search?q=implant&type=all&page=1&per_page=20` (public)
- `GET /teachers` (protected)
- `GET /teachers/:teacherId` (protected)
- `GET /teachers/:teacherId/courses` (protected)

---

## 8) Feature: Payments (Courses)

- `POST /admin/payments` (protected)
- `POST /admin/payments/:checkoutSessionId/confirm` (protected)
- `POST /admin/payments/coupons/validate` (protected)

Initiate Checkout Request:
```json
{
  "course_id": "c_1",
  "payment_method": "card",
  "coupon_code": "WELCOME10"
}
```

Initiate Checkout Response:
```json
{
  "success": true,
  "data": {
    "checkout_session_id": "chk_123",
    "amount": 900,
    "currency": "EGP",
    "payment_url": "https://payment-gateway/checkout/chk_123"
  }
}
```

---

## 9) Feature: Notifications

- `GET /notifications?page=1&per_page=20&unread_only=false` (protected)
- `POST /notifications/:notificationId/read` (protected)
- `POST /notifications/read-all` (protected)

Mark All Response:
```json
{
  "success": true,
  "data": {
    "marked_count": 6,
    "unread_count": 0
  }
}
```

---

## 10) Feature: Certificates

- `GET /certificates` (protected)
- `GET /admin/certificates/:certificateId` (public in app for verification)

---

## 11) Feature: Live Courses

- `GET /live-courses` (protected)
- `POST /admin/live-sessions/:liveSessionId` (protected)

---

## 12) Feature: Downloads & Curriculum Resources

- `GET /admin/curriculum` (protected)
- `POST /admin/curriculum` (protected)
- `DELETE /admin/curriculum/:downloadId` (protected)

Download Request:
```json
{ "resource_id": "res_123" }
```

---

## 13) Feature: Progress & Attendance

- `GET /progress?period=weekly` (protected)
- `GET /attendance/my-qr-code` (protected)
- fallback: `GET /my-qr-code` (protected)

QR Response:
```json
{
  "success": true,
  "data": {
    "qr_code": "encrypted_student_payload",
    "user": { "id": "u_1001" }
  }
}
```

---

## 14) Feature: Uploads

`POST /upload` (multipart, protected)

Image upload:
- field `type=image`
- file field `image`

PDF/File upload:
- field `type=file`
- file field `file`

Response:
```json
{
  "success": true,
  "data": {
    "url": "/uploads/files/doc_001.pdf"
  }
}
```

---

## 15) Feature: Chat (REST + Socket)

### REST
- `GET /chat/conversations?page=1&limit=50` (protected)
- `POST /chat/conversations` (protected)
- `GET /chat/conversations/:conversationId/messages?page=1&limit=50` (protected)
- `POST /chat/conversations/:conversationId/messages` (protected)
- `PATCH /chat/messages/:messageId/read` (protected)

Create conversation request:
```json
{ "otherUserId": "u_2002" }
```

Send message request:
```json
{ "body": "Hello doctor" }
```

### Socket.IO
- Base: `https://medex2.anmka.com`
- Path: `/api/socket.io`
- Auth:
```json
{ "token": "jwt_access" }
```
- Subscribe emit:
```json
{ "conversationId": "conv_1" }
```
- Server events expected by app:
  - `message`
  - `new_message`
  - `chat:message`

---

## 16) Feature: Community (Posts / Comments / Reactions)

> ملاحظة: حاليًا في التطبيق `community_service.dart` بيستخدم local sample data.  
> القسم ده هو الـ backend contract المقترح علشان التحويل لـ live API.

### 16.1 List Posts
`GET /community/posts?page=1&per_page=20&sort=latest`

Response:
```json
{
  "success": true,
  "data": {
    "posts": [
      {
        "id": "post_1",
        "author": {
          "id": "u_2001",
          "name": "د. أحمد محمود",
          "avatar": "/uploads/avatars/u_2001.jpg",
          "title": "أخصائي زراعة أسنان"
        },
        "content": "تجربتي مع نظام زراعة B&B كانت ممتازة...",
        "media": [],
        "likes_count": 45,
        "comments_count": 12,
        "shares_count": 5,
        "viewer_reaction": "like",
        "created_at": "2026-04-14T10:30:00Z"
      }
    ],
    "meta": { "page": 1, "per_page": 20, "total": 340 }
  }
}
```

### 16.2 Create Post
`POST /community/posts` (protected)

Request:
```json
{
  "content": "سؤال للزملاء: مين جرب Powerbone Surgical Kit؟",
  "media": []
}
```

Response:
```json
{
  "success": true,
  "message": "Post created",
  "data": {
    "id": "post_987",
    "content": "سؤال للزملاء: مين جرب Powerbone Surgical Kit؟",
    "likes_count": 0,
    "comments_count": 0,
    "shares_count": 0,
    "created_at": "2026-04-14T12:20:00Z"
  }
}
```

### 16.3 Post Details
`GET /community/posts/:postId` (protected)

### 16.4 Add Comment
`POST /community/posts/:postId/comments` (protected)

Request:
```json
{
  "content": "أنا جربته وفعلا ممتاز خصوصًا في guided surgery."
}
```

Response:
```json
{
  "success": true,
  "message": "Comment added",
  "data": {
    "id": "c_1001",
    "post_id": "post_1",
    "author": {
      "id": "u_3001",
      "name": "د. سارة علي",
      "avatar": "/uploads/avatars/u_3001.jpg"
    },
    "content": "أنا جربته وفعلا ممتاز خصوصًا في guided surgery.",
    "likes_count": 0,
    "created_at": "2026-04-14T12:22:00Z"
  }
}
```

### 16.5 List Comments
`GET /community/posts/:postId/comments?page=1&per_page=30` (protected)

### 16.6 React to Post
`POST /community/posts/:postId/reactions` (protected)

Request:
```json
{
  "reaction": "like"
}
```

Valid values:
- `like`
- `love`
- `insightful`
- `support`

Response:
```json
{
  "success": true,
  "message": "Reaction updated",
  "data": {
    "post_id": "post_1",
    "viewer_reaction": "love",
    "likes_count": 46
  }
}
```

### 16.7 Remove Post Reaction
`DELETE /community/posts/:postId/reactions` (protected)

### 16.8 Like/Unlike Comment
`POST /community/comments/:commentId/reactions` (protected)

Request:
```json
{
  "reaction": "like"
}
```

### 16.9 Share Post
`POST /community/posts/:postId/share` (protected)

Response:
```json
{
  "success": true,
  "data": {
    "post_id": "post_1",
    "shares_count": 6,
    "share_link": "https://medex.app/community/post_1"
  }
}
```

### 16.10 Report Post/Comment
- `POST /community/posts/:postId/report`
- `POST /community/comments/:commentId/report`

Request:
```json
{
  "reason": "spam",
  "details": "Repeated advertisement"
}
```

### 16.11 Community Error Examples
Validation error:
```json
{
  "success": false,
  "message": "Post content is required",
  "errors": {
    "content": ["Content cannot be empty"]
  }
}
```

Forbidden action:
```json
{
  "success": false,
  "message": "You are not allowed to edit this post"
}
```

## 17) Feature: E-commerce Store (Products / Cart / Orders)

> الجزء ده مهم للتوسعة القادمة لأن شاشات Store موجودة حاليًا وتعتمد على sample data.

### 16.1 Categories
`GET /store/categories` (public or protected)

Response:
```json
{
  "success": true,
  "data": {
    "categories": [
      {
        "id": "bb-dental",
        "name": "B&B Dental",
        "name_ar": "B&B Dental",
        "brand": "B&B Dental",
        "origin": "Italy",
        "icon_name": "precision_manufacturing",
        "subcategories": ["Implant Systems", "Titanium Abutments"],
        "subcategories_ar": ["أنظمة الزراعة", "دعامات تيتانيوم"]
      }
    ]
  }
}
```

### 16.2 Products
`GET /store/products` (public or protected)

Query:
- `page`, `per_page`, `search`, `category_id`, `subcategory`, `brand`, `origin`, `is_rentable`, `in_stock`, `sort`

Response:
```json
{
  "success": true,
  "data": {
    "products": [
      {
        "id": "p_1",
        "name": "B&B Implant System - Standard",
        "name_ar": "نظام زراعة B&B - قياسي",
        "description": "Premium Italian implant system...",
        "description_ar": "نظام زراعة إيطالي...",
        "price": 4500,
        "rental_price": 1200,
        "discount": 10,
        "image_url": "/uploads/store/p1.jpg",
        "category": "Implant Systems",
        "category_ar": "أنظمة الزراعة",
        "brand": "B&B Dental",
        "origin": "Italy",
        "is_available": true,
        "is_rentable": true,
        "stock_qty": 15
      }
    ],
    "meta": { "page": 1, "per_page": 20, "total": 200 }
  }
}
```

### 16.3 Product Details
`GET /store/products/:productId`

### 16.4 Cart
- `GET /store/cart`
- `POST /store/cart/items`
- `PATCH /store/cart/items/:itemId`
- `DELETE /store/cart/items/:itemId`
- `DELETE /store/cart/clear`

Add item request:
```json
{
  "product_id": "p_1",
  "quantity": 2,
  "is_rental": false
}
```

Cart response:
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "ci_1",
        "product_id": "p_1",
        "name": "B&B Implant System - Standard",
        "name_ar": "نظام زراعة B&B - قياسي",
        "image_url": "/uploads/store/p1.jpg",
        "quantity": 2,
        "price": 4500,
        "is_rental": false,
        "line_total": 9000
      }
    ],
    "summary": {
      "item_count": 2,
      "subtotal": 9000,
      "discount": 0,
      "shipping": 150,
      "total": 9150
    }
  }
}
```

### 16.5 Addresses
- `GET /store/addresses`
- `POST /store/addresses`
- `PATCH /store/addresses/:addressId`
- `DELETE /store/addresses/:addressId`

Create address request:
```json
{
  "label": "Home",
  "full_name": "Ahmed Ali",
  "phone": "+201000000000",
  "country": "EG",
  "city": "Giza",
  "area": "Mohandessin",
  "street": "Sudan Street",
  "building": "157",
  "floor": "2",
  "apartment": "5",
  "postal_code": "12611",
  "is_default": true
}
```

### 16.6 Shipping Methods
`GET /store/shipping-methods?city=Giza&country=EG`

### 16.7 Checkout Preview
`POST /store/checkout/preview`

Request:
```json
{
  "address_id": "addr_1",
  "shipping_method_id": "ship_standard",
  "coupon_code": "WELCOME10",
  "payment_method": "card"
}
```

### 16.8 Create Order
`POST /store/orders`

Request:
```json
{
  "address_id": "addr_1",
  "shipping_method_id": "ship_standard",
  "payment_method": "card",
  "payment_token": "gateway_token",
  "notes": "Call before delivery"
}
```

Response:
```json
{
  "success": true,
  "data": {
    "order_id": "ORD-2026-001",
    "status": "Processing",
    "status_ar": "قيد المعالجة",
    "total_amount": 16100,
    "shipping_address": "157 Sudan St, Giza",
    "created_at": "2026-04-14T12:00:00Z"
  }
}
```

### 16.9 Orders
- `GET /store/orders?page=1&per_page=20&status=Processing`
- `GET /store/orders/:orderId`
- `POST /store/orders/:orderId/cancel`

### 16.10 Store Coupons
`POST /store/coupons/validate`

Request:
```json
{
  "code": "WELCOME10",
  "cart_total": 9000
}
```

---

## 18) Error Cases Required Across All Features

- `400` business/validation error
- `401` unauthorized token
- `403` forbidden
- `404` not found
- `422` validation details
- `500` server error

Example 401:
```json
{
  "success": false,
  "message": "Unauthorized"
}
```

Example stock error (store):
```json
{
  "success": false,
  "message": "Insufficient stock for product B&B Implant System - Standard"
}
```

---

## 19) Backend Checklist (Final)

- كل endpoint فوق متوفر بنفس method + path.
- كل response راجع بنفس envelope: `success`, `message`, `data`.
- كل protected endpoint يدعم JWT Bearer.
- الـ pagination موحدة: `page`, `per_page`.
- الـ upload multipart شغال لنفس أسماء الحقول.
- Socket.IO path ثابت: `/api/socket.io`.
- APIs الخاصة بالـ store جاهزة للتبديل من sample data إلى live backend.
# Medex App Backend API Requirements (Student-Focused)

This document is the implementation contract for backend APIs consumed by the app.
It is based on the app code under `lib/services` and `lib/core/api/api_endpoints.dart`.

## 1) Global API Rules

- **Base URL:** `https://medex2.anmka.com/api`
- **Content-Type:** `application/json` (except multipart upload endpoints)
- **Accept:** `application/json`
- **Auth header (required on protected routes):**
  - `Authorization: Bearer <access_token>`
- **Timeout expectation:** up to 45s for normal requests, 60s for multipart.

### 1.1 Standard Success Envelope

```json
{
  "success": true,
  "message": "Optional message",
  "data": {}
}
```

### 1.2 Standard Error Envelope

```json
{
  "success": false,
  "message": "Human-readable error message",
  "errors": {
    "field_name": ["Validation message"]
  }
}
```

## 2) Authentication APIs

### POST `/auth/login` (public)
- Login with **email+password** OR **phone+password**.

Request (email):
```json
{
  "email": "student@example.com",
  "password": "12345678"
}
```

Request (phone):
```json
{
  "phone": "+201000000000",
  "password": "12345678"
}
```

Response:
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "token": "jwt_access_token",
    "refresh_token": "jwt_refresh_token",
    "user": {
      "id": "u_123",
      "name": "Student Name",
      "email": "student@example.com",
      "phone": "+201000000000",
      "role": "student",
      "status": "ACTIVE"
    }
  }
}
```

### POST `/auth/register` (public)
- App sends role and optional student type.

Request:
```json
{
  "name": "Student Name",
  "email": "student@example.com",
  "phone": "+201000000000",
  "password": "12345678",
  "role": "student",
  "student_type": "online"
}
```

Response (active):
```json
{
  "success": true,
  "message": "Registered",
  "data": {
    "token": "jwt_access_token",
    "refresh_token": "jwt_refresh_token",
    "status": "ACTIVE",
    "user": { "id": "u_123", "role": "student" }
  }
}
```

Response (pending approval):
```json
{
  "success": true,
  "message": "Account pending admin approval",
  "data": {
    "status": "PENDING",
    "user": { "id": "u_123", "role": "student" }
  }
}
```

### POST `/auth/refresh` (public)
Request:
```json
{ "refreshToken": "jwt_refresh_token" }
```

Response:
```json
{
  "success": true,
  "data": {
    "token": "new_access_token",
    "refresh_token": "new_refresh_token",
    "user": { "id": "u_123", "role": "student" }
  }
}
```

### POST `/auth/forgot-password` (public)
Request:
```json
{ "email": "student@example.com" }
```

### POST `/auth/logout` (protected)
- No request body required.

### DELETE `/auth/delete-account` (protected)
- Deletes account permanently.

### POST `/auth/social-login` (public)
- Used for Google and Apple.

Request (Google):
```json
{
  "provider": "google",
  "id_token": "google_id_token",
  "access_token": "google_access_token",
  "fcm_token": "device_fcm_token",
  "device": {
    "platform": "android",
    "model": "Unknown",
    "app_version": "1.0.0"
  }
}
```

Request (Apple):
```json
{
  "provider": "apple",
  "id_token": "apple_identity_token",
  "nonce": "raw_nonce",
  "fcm_token": "device_fcm_token",
  "device": {
    "platform": "ios",
    "model": "Unknown",
    "app_version": "1.0.0"
  }
}
```

## 3) App Config and Home

### GET `/config/app` (public)
- Must return all app config fields needed by mobile startup.

### GET `/home` (protected)
- Home screen expects:
  - `user_summary`
  - `hero_banner`
  - `categories` (array)
  - `featured_courses` (array)
  - `popular_courses` (array)
  - `continue_learning` (array)

## 4) Profile APIs

### GET `/auth/me` (protected)
- Current user profile.

### PUT `/auth/profile` (protected)
Request example:
```json
{
  "name": "Updated Name",
  "phone": "+201000000000",
  "bio": "Dental student",
  "country": "EG",
  "timezone": "Africa/Cairo",
  "language": "ar"
}
```

### POST `/auth/profile` (multipart, protected)
- Avatar upload via field name `avatar`.

### POST `/auth/change-password` (protected)
Request:
```json
{
  "currentPassword": "old_pass",
  "newPassword": "new_pass",
  "confirmPassword": "new_pass"
}
```

## 5) Courses, Categories, Lessons, Enrollment, Reviews

### GET `/courses` (protected)
Query params used by app:
- `page`, `per_page`, `search`, `category_id`, `subcategory_id`, `instructor_id`, `price`, `level`, `sort`, `duration`

### GET `/courses/:courseId` (protected)
- Course details for student lesson/curriculum screen.

### GET `/courses/:courseId/lessons/:lessonId` (protected)
- Lesson details.

### GET `/courses/:courseId/lessons/:lessonId/content` (protected)
- Lesson content payload (video/pdf/text links, etc.).

### POST `/courses/:courseId/lessons/:lessonId/progress` (protected)
Request:
```json
{
  "watched_seconds": 420,
  "is_completed": true
}
```

### GET `/categories` (protected)
### GET `/categories/:categoryId/courses` (protected)
Query: `page`, `per_page`, `sort`, `price`, `level`, `subcategory_id`

### POST `/courses/:courseId/enroll` (protected)

### GET `/enrollments` (protected)
Query: `status` (`all|in_progress|completed`), `page`, `per_page`

### GET `/courses/:courseId/reviews` (protected)
Query: `page`, `per_page`, optional `rating`

### POST `/courses/:courseId/reviews` (protected)
Request:
```json
{
  "rating": 5,
  "title": "Excellent course",
  "comment": "Very practical and clear."
}
```

## 6) Exams APIs

### GET `/courses/:courseId/exams` (public in app)
### GET `/courses/:courseId/exams/:examId` (public in app)
### GET `/admin/exams/:examId` (protected)
### POST `/admin/exams/:examId/start` (protected)
### POST `/admin/exams/:examId/submit` (protected)
Request:
```json
{
  "attempt_id": "attempt_123",
  "answers": [
    { "question_id": "q1", "answer": "A" },
    { "question_id": "q2", "answer": ["B", "D"] }
  ]
}
```

## 7) Wishlist APIs

### GET `/wishlist` (protected)
### POST `/wishlist` (protected)
Request:
```json
{ "course_id": "course_123" }
```
### DELETE `/wishlist/:courseId` (protected)

## 8) Search and Teachers

### GET `/search` (public)
Query: `q`, `type` (`all|courses|instructors|categories`), `page`, `per_page`

### GET `/teachers` (protected)
Query: `page`, `per_page`, `search`, `sort`

### GET `/teachers/:teacherId` (protected)
### GET `/teachers/:teacherId/courses` (protected)
Query: `page`, `per_page`

## 9) Payments and Checkout

> Note: app currently calls admin payment paths. Keep these compatible with student checkout flow.

### POST `/admin/payments` (protected)
Request:
```json
{
  "course_id": "course_123",
  "payment_method": "card",
  "coupon_code": "WELCOME10"
}
```

Response must include checkout/session info (e.g., session id, client secret, payment URL) used by app.

### POST `/admin/payments/:checkoutSessionId/confirm` (protected)
Request:
```json
{
  "checkout_session_id": "chk_123",
  "payment_method": "card",
  "payment_token": "gateway_payment_token"
}
```

### POST `/admin/payments/coupons/validate` (protected)
Request:
```json
{
  "code": "WELCOME10",
  "course_id": "course_123"
}
```

## 10) Notifications APIs

### GET `/notifications` (protected)
Query: `page`, `per_page`, `unread_only`

### POST `/notifications/:notificationId/read` (protected)
### POST `/notifications/read-all` (protected)

Response for read-all should include:
```json
{
  "success": true,
  "data": {
    "marked_count": 12,
    "unread_count": 0
  }
}
```

## 11) Certificates APIs

### GET `/certificates` (protected)
### GET `/admin/certificates/:certificateId` (public in app)
- Used for certificate verification details.

## 12) Live Courses APIs

### GET `/live-courses` (protected)
### POST `/admin/live-sessions/:liveSessionId` (protected)
- Register/join action used by app.

## 13) Downloads and Curriculum Resources

### GET `/admin/curriculum` (protected)
### POST `/admin/curriculum` (protected)
Request:
```json
{ "resource_id": "res_123" }
```
### DELETE `/admin/curriculum/:downloadId` (protected)

## 14) Progress and Attendance

### GET `/progress?period={weekly|monthly}` (protected)
- Required keys used by app: `user`, `top_students`, progress metrics/charts.

### GET `/attendance/my-qr-code` (protected)
- Fallback endpoint in app: `/my-qr-code`

Expected response:
```json
{
  "success": true,
  "data": {
    "qr_code": "encoded_value",
    "user": { "id": "u_123" }
  }
}
```

## 15) Upload API

### POST `/upload` (multipart, protected)

Case A image upload:
- fields: `type=image`
- file field: `image`

Case B file upload:
- fields: `type=file`
- file field: `file`

Response accepted by app:
```json
{
  "success": true,
  "url": "/uploads/images/file.jpg"
}
```
or
```json
{
  "success": true,
  "data": {
    "url": "/uploads/files/file.pdf"
  }
}
```

## 16) Chat APIs + WebSocket

### REST
- `GET /chat/conversations?page=&limit=` (protected)
- `POST /chat/conversations` (protected)
  - body: `{ "otherUserId": "user_123" }`
- `GET /chat/conversations/:conversationId/messages?page=&limit=` (protected)
- `POST /chat/conversations/:conversationId/messages` (protected)
  - body: `{ "body": "Hello" }`
- `PATCH /chat/messages/:messageId/read` (protected)
  - body: `{}` (empty object)

### Socket.IO
- Base URL: `https://medex2.anmka.com`
- Path: `/api/socket.io`
- Auth payload:
```json
{ "token": "jwt_access_token" }
```
- Client emits:
```json
{
  "event": "subscribe",
  "data": { "conversationId": "conv_123" }
}
```
- Backend should emit new message events using one of:
  - `message`
  - `new_message`
  - `chat:message`

## 17) Instructor/Admin Endpoints Also Used In App

The app also consumes these endpoints in instructor flows and they must remain available:

- `/admin/dashboard/overview`
- `/admin/dashboard/charts`
- `/admin/dashboard/activity`
- `/admin/courses` and `/admin/courses/:id`
- `/admin/curriculum/:courseId` and nested section/lesson CRUD endpoints
- `/admin/courses/:courseId/lectures` and lecture CRUD endpoints
- `/admin/users/me/earnings`, `/admin/users/:userId/earnings`
- `/admin/teachers/me/salary-settings`
- `/admin/teachers/me/calculate-salary`
- `/admin/teachers/reports`
- `/admin/attendance`
- `/attendance/session`
- `/attendance/scan`
- `/attendance/my-attendance`
- `/admin/students/:studentId/parent-phone`

## 17.1) E-commerce Store APIs (Added)

The Store screens currently use local sample data, but for backend migration you should provide this full contract so mobile can switch to live APIs without UI changes.

### Product Catalog

#### GET `/store/categories` (public or protected)
- Query: `page`, `per_page`, `search`
- Response item fields expected by UI:
  - `id`, `name`, `name_ar`, `brand`, `origin`, `icon_name`
  - `subcategories` (array of string)
  - `subcategories_ar` (array of string)

#### GET `/store/products` (public or protected)
- Query:
  - `page`, `per_page`, `search`
  - `category_id`
  - `subcategory`
  - `brand`
  - `origin`
  - `is_rentable` (`true|false`)
  - `in_stock` (`true|false`)
  - `sort` (`newest|price_asc|price_desc|popular`)

Response example:
```json
{
  "success": true,
  "data": {
    "products": [
      {
        "id": "p_1",
        "name": "B&B Implant System - Standard",
        "name_ar": "نظام زراعة B&B - قياسي",
        "description": "Premium Italian implant system...",
        "description_ar": "نظام زراعة إيطالي متميز...",
        "price": 4500,
        "rental_price": 1200,
        "discount": 10,
        "final_price": 4050,
        "image": "/uploads/store/products/p1.jpg",
        "category": "Implant Systems",
        "category_ar": "أنظمة الزراعة",
        "brand": "B&B Dental",
        "origin": "Italy",
        "is_available": true,
        "is_rentable": true,
        "stock_qty": 23
      }
    ],
    "meta": {
      "page": 1,
      "per_page": 20,
      "total": 120
    }
  }
}
```

#### GET `/store/products/:productId` (public or protected)
- Full product details for product details screen.

### Cart

#### GET `/store/cart` (protected)
- Return server cart with item prices and totals.

#### POST `/store/cart/items` (protected)
Request:
```json
{
  "product_id": "p_1",
  "quantity": 2,
  "is_rental": false
}
```

#### PATCH `/store/cart/items/:itemId` (protected)
Request:
```json
{
  "quantity": 3
}
```

#### DELETE `/store/cart/items/:itemId` (protected)
#### DELETE `/store/cart/clear` (protected)

Cart response example:
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "ci_1",
        "product_id": "p_1",
        "name": "B&B Implant System - Standard",
        "name_ar": "نظام زراعة B&B - قياسي",
        "image": "/uploads/store/products/p1.jpg",
        "price": 4500,
        "rental_price": 1200,
        "is_rental": false,
        "quantity": 2,
        "line_total": 9000
      }
    ],
    "totals": {
      "subtotal": 9000,
      "discount": 0,
      "shipping": 150,
      "grand_total": 9150
    }
  }
}
```

### Checkout and Orders

#### POST `/store/checkout/preview` (protected)
- Validate stock, coupons, shipping, and return final payable total.

Request:
```json
{
  "address_id": "addr_1",
  "shipping_method_id": "ship_standard",
  "coupon_code": "WELCOME10",
  "payment_method": "card"
}
```

#### POST `/store/orders` (protected)
- Create order from cart.

Request:
```json
{
  "address_id": "addr_1",
  "shipping_method_id": "ship_standard",
  "payment_method": "card",
  "payment_token": "gateway_token_optional",
  "notes": "Deliver after 5 PM"
}
```

Response:
```json
{
  "success": true,
  "data": {
    "order_id": "ORD-2026-00123",
    "status": "Processing",
    "status_ar": "قيد المعالجة",
    "total_amount": 16100,
    "shipping_address": "157 شارع السودان، الجيزة",
    "created_at": "2026-04-14T10:30:00Z"
  }
}
```

#### GET `/store/orders` (protected)
- Query: `page`, `per_page`, `status`

#### GET `/store/orders/:orderId` (protected)
- Must include:
  - `id`, `status`, `status_ar`, `created_at`
  - `items[]` with product snapshot at purchase time
  - `total_amount`, `shipping_address`, `tracking_number` (if shipped)

#### POST `/store/orders/:orderId/cancel` (protected)
- Allowed only in cancellable states (e.g., Pending/Processing).

### Addresses and Shipping

#### GET `/store/addresses` (protected)
#### POST `/store/addresses` (protected)
#### PATCH `/store/addresses/:addressId` (protected)
#### DELETE `/store/addresses/:addressId` (protected)

Address request example:
```json
{
  "label": "Home",
  "full_name": "Student Name",
  "phone": "+201000000000",
  "country": "EG",
  "city": "Giza",
  "area": "Mohandessin",
  "street": "Sudan Street",
  "building": "157",
  "floor": "2",
  "apartment": "5",
  "postal_code": "12611",
  "is_default": true
}
```

#### GET `/store/shipping-methods` (protected)
- Query optional: `city`, `country`
- Return method id, label, ETA, and fee.

### Store Coupons

#### POST `/store/coupons/validate` (protected)
Request:
```json
{
  "code": "WELCOME10",
  "cart_total": 9000
}
```

### Stock and Availability Rules (Mandatory Behavior)

- Backend must re-check stock on:
  - add-to-cart
  - quantity update
  - checkout preview
  - final order creation
- If out of stock, return clear error:
```json
{
  "success": false,
  "message": "Insufficient stock for product B&B Implant System - Standard"
}
```

## 18) Required HTTP Status Handling

- `200/201`: success
- `400`: validation/business error with `message`
- `401`: unauthorized/expired token
- `403`: forbidden
- `404`: not found
- `422`: validation errors object
- `500`: internal error

Backend must always send JSON on errors so the app can display `message`.

## 19) Final Delivery Checklist (Backend Team)

- Implement all endpoints above with exact paths and methods.
- Keep response envelope compatible: `success`, `message`, `data`.
- Ensure JWT auth works for all protected routes.
- Support pagination query params where used by app.
- Keep multipart upload contract (`type`, `image|file`) stable.
- Keep Socket.IO path `/api/socket.io` and token auth handshake.

## 20) Strict Field Schema Matrix (Required vs Optional)

This section is authoritative for backend payload contracts.

### 20.1 Auth User Object

| Field | Type | Required | Validation |
|---|---|---|---|
| `id` | string | yes | non-empty, max 64 |
| `name` | string | yes | min 2, max 120 |
| `email` | string | yes | valid email format, max 190 |
| `phone` | string | yes | E.164 format (`+201...`), max 20 |
| `role` | string | yes | enum: `student`, `instructor`, `admin` |
| `status` | string | yes | enum: `ACTIVE`, `PENDING`, `BLOCKED` |
| `avatar` | string | no | valid URL/path, max 500 |

### 20.2 Course Card Object

| Field | Type | Required | Validation |
|---|---|---|---|
| `id` | string | yes | non-empty |
| `title` | string | yes | min 3, max 200 |
| `thumbnail` | string | yes | valid URL/path |
| `price` | number | yes | `>= 0`, max `999999` |
| `rating` | number | no | `0.0 - 5.0` |
| `students_count` | integer | no | `>= 0` |
| `instructor.id` | string | yes | non-empty |
| `instructor.name` | string | yes | min 2, max 120 |
| `instructor.avatar` | string | yes | valid URL/path |

### 20.3 Lesson Content Object

| Field | Type | Required | Validation |
|---|---|---|---|
| `lesson_id` | string | yes | non-empty |
| `type` | string | yes | enum: `video`, `pdf`, `text`, `quiz` |
| `video_url` | string/null | conditional | required if `type=video` |
| `pdf_url` | string/null | conditional | required if `type=pdf` |
| `text_content` | string/null | conditional | required if `type=text` |
| `duration_seconds` | integer | yes | `>= 0`, max `86400` |

### 20.4 Community Post Object

| Field | Type | Required | Validation |
|---|---|---|---|
| `id` | string | yes | non-empty |
| `author.id` | string | yes | non-empty |
| `author.name` | string | yes | min 2, max 120 |
| `author.avatar` | string | yes | valid URL/path |
| `author.title` | string | yes | min 2, max 120 |
| `content` | string | yes | min 1, max 5000 |
| `media` | array | yes | min 0, max 10 |
| `media[].id` | string | yes | non-empty |
| `media[].type` | string | yes | enum: `image`, `video` |
| `media[].url` | string | yes | valid URL/path |
| `likes_count` | integer | yes | `>= 0` |
| `comments_count` | integer | yes | `>= 0` |
| `shares_count` | integer | yes | `>= 0` |
| `viewer_reaction` | string/null | no | enum: `like`, `love`, `insightful`, `support` |
| `created_at` | string | yes | ISO8601 UTC |

### 20.5 Store Product Object

| Field | Type | Required | Validation |
|---|---|---|---|
| `id` | string | yes | non-empty |
| `name` | string | yes | min 2, max 200 |
| `name_ar` | string | yes | min 2, max 200 |
| `description` | string | yes | min 5, max 5000 |
| `description_ar` | string | yes | min 5, max 5000 |
| `price` | number | yes | `>= 0`, max `999999` |
| `rental_price` | number/null | no | `>= 0`, max `price` |
| `discount` | number | no | `0 - 100` |
| `image_url` | string | yes | valid URL/path |
| `category` | string | yes | min 2, max 120 |
| `category_ar` | string | yes | min 2, max 120 |
| `brand` | string | yes | min 2, max 120 |
| `origin` | string | yes | min 2, max 120 |
| `is_available` | boolean | yes | true/false |
| `is_rentable` | boolean | yes | true/false |
| `stock_qty` | integer | yes | `>= 0`, max `999999` |

### 20.6 Store Cart Item Object

| Field | Type | Required | Validation |
|---|---|---|---|
| `id` | string | yes | non-empty |
| `product_id` | string | yes | non-empty |
| `name` | string | yes | min 2, max 200 |
| `name_ar` | string | yes | min 2, max 200 |
| `image_url` | string | yes | valid URL/path |
| `quantity` | integer | yes | min 1, max 999 |
| `price` | number | yes | `>= 0` |
| `rental_price` | number/null | no | `>= 0` |
| `is_rental` | boolean | yes | true/false |
| `line_total` | number | yes | `>= 0` |

### 20.7 Order Object

| Field | Type | Required | Validation |
|---|---|---|---|
| `order_id` | string | yes | non-empty, max 64 |
| `status` | string | yes | enum: `Pending`, `Processing`, `Shipped`, `Delivered`, `Cancelled` |
| `status_ar` | string | yes | non-empty |
| `total_amount` | number | yes | `>= 0` |
| `shipping_address` | string | yes | min 5, max 500 |
| `tracking_number` | string/null | no | max 120 |
| `created_at` | string | yes | ISO8601 UTC |

### 20.8 Notification Object

| Field | Type | Required | Validation |
|---|---|---|---|
| `id` | string | yes | non-empty |
| `title` | string | yes | min 2, max 200 |
| `body` | string | yes | min 2, max 2000 |
| `type` | string | yes | enum: `course`, `payment`, `system`, `community`, `chat` |
| `is_read` | boolean | yes | true/false |
| `created_at` | string | yes | ISO8601 UTC |

## 21) Request Validation Rules (Per Feature)

### 21.1 Authentication
- Login: one of `email` or `phone` is required, plus `password`.
- Register:
  - `name` min 2 max 120
  - `email` valid format
  - `password` min 8 max 64
  - `student_type` enum: `online`, `offline`

### 21.2 Profile
- `name` min 2 max 120
- `bio` max 500
- `language` enum: `ar`, `en`
- Avatar upload:
  - mime: `image/jpeg`, `image/png`, `image/webp`
  - max size: 5 MB

### 21.3 Courses/Reviews
- Review:
  - `rating` integer `1..5`
  - `title` min 2 max 120
  - `comment` min 3 max 2000
- Progress:
  - `watched_seconds` integer `>= 0`
  - `is_completed` boolean

### 21.4 Exams
- Submit answers:
  - `attempt_id` required
  - `answers` array min 1
  - each answer must include `question_id`

### 21.5 Community
- Create post:
  - `content` min 1 max 5000
  - `media` array max 10
- Comment:
  - `content` min 1 max 1000
- Reaction:
  - enum only: `like`, `love`, `insightful`, `support`
- Search:
  - `q` min 1 max 120
  - `type` enum: `posts`, `users`, `hashtags`, `all`

### 21.6 Store
- Add to cart:
  - `product_id` required
  - `quantity` integer min 1 max 999
  - `is_rental` boolean
- Address:
  - `full_name` min 2 max 120
  - `phone` E.164 format
  - `street` min 2 max 200
  - `city` min 2 max 120
- Coupon validate:
  - `code` min 3 max 40
  - `cart_total` number >= 0
- Create order:
  - `address_id` required
  - `shipping_method_id` required
  - `payment_method` enum: `card`, `wallet`, `cash_on_delivery` (if supported)

### 21.7 Upload
- allowed mime:
  - images: `jpeg`, `png`, `webp`
  - files: `pdf`
- max file size:
  - image: 10 MB
  - pdf: 20 MB

## 22) Endpoint Error Code Catalog (Mandatory)

Backend should return machine-readable `error_code` with every failure.

Example:
```json
{
  "success": false,
  "message": "Invalid credentials",
  "error_code": "AUTH_001"
}
```

### 22.1 Authentication Codes
- `AUTH_001` invalid credentials
- `AUTH_002` account pending approval
- `AUTH_003` account blocked
- `AUTH_004` invalid refresh token
- `AUTH_005` token expired

### 22.2 Profile Codes
- `PROF_001` invalid profile payload
- `PROF_002` avatar too large
- `PROF_003` unsupported avatar format
- `PROF_004` wrong current password

### 22.3 Courses/Reviews Codes
- `COURSE_001` course not found
- `COURSE_002` lesson not found
- `COURSE_003` enrollment required
- `REVIEW_001` already reviewed
- `REVIEW_002` invalid rating

### 22.4 Exams Codes
- `EXAM_001` exam not found
- `EXAM_002` exam not available
- `EXAM_003` invalid attempt id
- `EXAM_004` submission window closed

### 22.5 Payments Codes
- `PAY_001` invalid coupon
- `PAY_002` coupon expired
- `PAY_003` payment failed
- `PAY_004` checkout session not found

### 22.6 Community Codes
- `COMM_001` post not found
- `COMM_002` comment not found
- `COMM_003` invalid reaction
- `COMM_004` content violates policy
- `COMM_005` report already submitted

### 22.7 Store Codes
- `CART_001` cart item not found
- `CART_002` invalid quantity
- `CART_003` insufficient stock
- `ORD_001` order not found
- `ORD_002` order cannot be cancelled
- `ADDR_001` address not found
- `SHIP_001` shipping method unavailable

### 22.8 Chat Codes
- `CHAT_001` conversation not found
- `CHAT_002` user not participant
- `CHAT_003` message too long
- `CHAT_004` websocket unauthorized

### 22.9 Upload/System Codes
- `UPL_001` file too large
- `UPL_002` unsupported file type
- `UPL_003` upload failed
- `SYS_001` internal server error
- `SYS_002` service temporarily unavailable

## 23) Definition of Done (DoD) for Backend Delivery

- Every endpoint has:
  - request validation
  - typed response object
  - `error_code` on failure
- No field ambiguity (`required`/`optional` respected)
- No placeholder production payloads when domain data exists
- All date fields in ISO8601 UTC
- All list endpoints support pagination consistently

## 24) Endpoint-Level Field Contracts (Strict)

This section defines exact field-level requirements per endpoint.

### 24.1 `POST /auth/login`

#### Request fields
| Field | Type | Required | Rules |
|---|---|---|---|
| `email` | string | conditional | required if `phone` missing, valid email |
| `phone` | string | conditional | required if `email` missing, E.164 |
| `password` | string | yes | min 8, max 64 |

#### Response `data` fields
| Field | Type | Required | Rules |
|---|---|---|---|
| `token` | string | yes | non-empty JWT |
| `refresh_token` | string | yes | non-empty |
| `expires_in` | integer | yes | `> 0` |
| `user` | object | yes | see `20.1` |

### 24.2 `POST /auth/register`

#### Request fields
| Field | Type | Required | Rules |
|---|---|---|---|
| `name` | string | yes | min 2, max 120 |
| `email` | string | yes | valid email |
| `phone` | string | yes | E.164 |
| `password` | string | yes | min 8, max 64 |
| `role` | string | yes | enum: `student`, `instructor` |
| `student_type` | string | conditional | required if `role=student`, enum: `online`, `offline` |

### 24.3 `GET /home`

#### Response `data` fields
| Field | Type | Required | Rules |
|---|---|---|---|
| `user_summary` | object | yes | non-null object |
| `hero_banner` | object | yes | non-null object |
| `categories` | array | yes | array of category objects |
| `featured_courses` | array | yes | array of course cards |
| `popular_courses` | array | yes | array of course cards |
| `continue_learning` | array | yes | array of continue objects |

### 24.4 `GET /courses`

#### Query fields
| Field | Type | Required | Rules |
|---|---|---|---|
| `page` | integer | yes | min 1 |
| `per_page` | integer | yes | min 1, max 100 |
| `search` | string | no | max 120 |
| `category_id` | string | no | max 64 |
| `subcategory_id` | string | no | max 64 |
| `instructor_id` | string | no | max 64 |
| `price` | string | no | enum: `all`, `free`, `paid` |
| `level` | string | no | enum: `all`, `beginner`, `intermediate`, `advanced` |
| `sort` | string | no | enum: `newest`, `popular`, `rating`, `price_low`, `price_high` |
| `duration` | string | no | enum: `all`, `short`, `medium`, `long` |

#### Response `data` fields
| Field | Type | Required | Rules |
|---|---|---|---|
| `courses` | array | yes | items follow `20.2` |
| `meta` | object | yes | pagination fields required |

### 24.5 `POST /courses/:courseId/lessons/:lessonId/progress`

#### Request fields
| Field | Type | Required | Rules |
|---|---|---|---|
| `watched_seconds` | integer | yes | min 0, max 86400 |
| `is_completed` | boolean | yes | true/false |

#### Response `data` fields
| Field | Type | Required | Rules |
|---|---|---|---|
| `course_id` | string | yes | non-empty |
| `lesson_id` | string | yes | non-empty |
| `watched_seconds` | integer | yes | `>= 0` |
| `is_completed` | boolean | yes | true/false |
| `course_progress_percent` | number | yes | `0..100` |

### 24.6 `POST /courses/:courseId/reviews`

#### Request fields
| Field | Type | Required | Rules |
|---|---|---|---|
| `rating` | integer | yes | min 1, max 5 |
| `title` | string | yes | min 2, max 120 |
| `comment` | string | yes | min 3, max 2000 |

### 24.7 `GET /community/posts`

#### Query fields
| Field | Type | Required | Rules |
|---|---|---|---|
| `page` | integer | yes | min 1 |
| `per_page` | integer | yes | min 1, max 100 |
| `sort` | string | no | enum: `latest`, `popular` |

#### Response `data` fields
| Field | Type | Required | Rules |
|---|---|---|---|
| `posts` | array | yes | post items follow `20.4` |
| `meta` | object | yes | pagination required |

### 24.8 `GET /community/search`

#### Query fields
| Field | Type | Required | Rules |
|---|---|---|---|
| `q` | string | yes | min 1, max 120 |
| `type` | string | no | enum: `posts`, `users`, `hashtags`, `all` |
| `page` | integer | yes | min 1 |
| `per_page` | integer | yes | min 1, max 100 |

### 24.9 `POST /community/posts/:postId/comments`

#### Request fields
| Field | Type | Required | Rules |
|---|---|---|---|
| `content` | string | yes | min 1, max 1000 |

### 24.10 `POST /community/posts/:postId/reactions`

#### Request fields
| Field | Type | Required | Rules |
|---|---|---|---|
| `reaction` | string | yes | enum: `like`, `love`, `insightful`, `support` |

### 24.11 `POST /store/cart/items`

#### Request fields
| Field | Type | Required | Rules |
|---|---|---|---|
| `product_id` | string | yes | non-empty |
| `quantity` | integer | yes | min 1, max 999 |
| `is_rental` | boolean | yes | true/false |

#### Response `data` fields
| Field | Type | Required | Rules |
|---|---|---|---|
| `items` | array | yes | cart items follow `20.6` |
| `summary` | object | yes | totals object required |

### 24.12 `PATCH /store/cart/items/:itemId`

#### Request fields
| Field | Type | Required | Rules |
|---|---|---|---|
| `quantity` | integer | yes | min 1, max 999 |

### 24.13 `POST /store/checkout/preview`

#### Request fields
| Field | Type | Required | Rules |
|---|---|---|---|
| `address_id` | string | yes | non-empty |
| `shipping_method_id` | string | yes | non-empty |
| `coupon_code` | string | no | min 3, max 40 |
| `payment_method` | string | yes | enum: `card`, `wallet`, `cash_on_delivery` |

#### Response `data` fields
| Field | Type | Required | Rules |
|---|---|---|---|
| `items_subtotal` | number | yes | `>= 0` |
| `coupon` | object/null | no | include if coupon passed |
| `shipping` | object | yes | fee + ETA required |
| `totals` | object | yes | subtotal/discount/shipping/grand_total |
| `stock_ok` | boolean | yes | true/false |

### 24.14 `POST /store/orders`

#### Request fields
| Field | Type | Required | Rules |
|---|---|---|---|
| `address_id` | string | yes | non-empty |
| `shipping_method_id` | string | yes | non-empty |
| `payment_method` | string | yes | enum: `card`, `wallet`, `cash_on_delivery` |
| `payment_token` | string | conditional | required for online methods |
| `notes` | string | no | max 500 |

#### Response `data` fields
| Field | Type | Required | Rules |
|---|---|---|---|
| `order_id` | string | yes | non-empty |
| `status` | string | yes | enum in `20.7` |
| `status_ar` | string | yes | non-empty |
| `total_amount` | number | yes | `>= 0` |
| `shipping_address` | string | yes | non-empty |
| `tracking_number` | string/null | no | max 120 |
| `created_at` | string | yes | ISO8601 UTC |

### 24.15 `POST /chat/conversations`

#### Request fields
| Field | Type | Required | Rules |
|---|---|---|---|
| `otherUserId` | string | yes | non-empty |

### 24.16 `POST /chat/conversations/:conversationId/messages`

#### Request fields
| Field | Type | Required | Rules |
|---|---|---|---|
| `body` | string | yes | min 1, max 4000 |

### 24.17 `PATCH /chat/messages/:messageId/read`

#### Request fields
| Field | Type | Required | Rules |
|---|---|---|---|
| body | object | yes | allow empty `{}` only |

## 25) Error Code Mapping by Endpoint

### 25.1 Authentication
- `POST /auth/login` -> `AUTH_001`, `AUTH_002`, `AUTH_003`
- `POST /auth/refresh` -> `AUTH_004`, `AUTH_005`

### 25.2 Courses/Reviews
- `GET /courses/:courseId` -> `COURSE_001`
- `POST /courses/:courseId/reviews` -> `COURSE_003`, `REVIEW_001`, `REVIEW_002`

### 25.3 Community
- `GET /community/posts/:postId` -> `COMM_001`
- `POST /community/posts/:postId/comments` -> `COMM_001`
- `POST /community/comments/:commentId/reactions` -> `COMM_002`, `COMM_003`

### 25.4 Store
- `POST /store/cart/items` -> `CART_002`, `CART_003`
- `PATCH /store/cart/items/:itemId` -> `CART_001`, `CART_002`, `CART_003`
- `POST /store/checkout/preview` -> `ADDR_001`, `SHIP_001`, `PAY_001`, `CART_003`
- `POST /store/orders` -> `ORD_001`, `PAY_003`, `CART_003`
- `POST /store/orders/:orderId/cancel` -> `ORD_001`, `ORD_002`

### 25.5 Chat
- `POST /chat/conversations` -> `CHAT_001`
- `POST /chat/conversations/:conversationId/messages` -> `CHAT_001`, `CHAT_002`, `CHAT_003`
- `PATCH /chat/messages/:messageId/read` -> `CHAT_001`, `CHAT_002`

## 26) Endpoint Error Response Examples (Strict)

All errors must include:
- `success=false`
- `message`
- `error_code`
- optional `errors` object (for validation details)
- `meta.request_id` and `meta.timestamp`

### 26.1 Login - invalid credentials
`POST /auth/login`
```json
{
  "success": false,
  "message": "Invalid credentials",
  "error_code": "AUTH_001",
  "meta": {
    "request_id": "req_auth_1001",
    "timestamp": "2026-04-14T15:01:00Z"
  }
}
```

### 26.2 Register - invalid email format
`POST /auth/register`
```json
{
  "success": false,
  "message": "Validation failed",
  "error_code": "AUTH_001",
  "errors": {
    "email": ["Email format is invalid"]
  },
  "meta": {
    "request_id": "req_auth_1002",
    "timestamp": "2026-04-14T15:03:00Z"
  }
}
```

### 26.3 Add review - already reviewed
`POST /courses/:courseId/reviews`
```json
{
  "success": false,
  "message": "You have already reviewed this course",
  "error_code": "REVIEW_001",
  "meta": {
    "request_id": "req_rev_2010",
    "timestamp": "2026-04-14T15:05:00Z"
  }
}
```

### 26.4 Community reaction - invalid value
`POST /community/posts/:postId/reactions`
```json
{
  "success": false,
  "message": "Invalid reaction value",
  "error_code": "COMM_003",
  "errors": {
    "reaction": ["Allowed values: like, love, insightful, support"]
  },
  "meta": {
    "request_id": "req_com_3012",
    "timestamp": "2026-04-14T15:07:00Z"
  }
}
```

### 26.5 Add cart item - insufficient stock
`POST /store/cart/items`
```json
{
  "success": false,
  "message": "Insufficient stock for requested quantity",
  "error_code": "CART_003",
  "errors": {
    "quantity": ["Available stock is 1"]
  },
  "meta": {
    "request_id": "req_cart_4022",
    "timestamp": "2026-04-14T15:09:00Z"
  }
}
```

### 26.6 Checkout preview - invalid coupon
`POST /store/checkout/preview`
```json
{
  "success": false,
  "message": "Coupon is invalid or expired",
  "error_code": "PAY_001",
  "meta": {
    "request_id": "req_pay_5005",
    "timestamp": "2026-04-14T15:11:00Z"
  }
}
```

### 26.7 Create order - payment failed
`POST /store/orders`
```json
{
  "success": false,
  "message": "Payment authorization failed",
  "error_code": "PAY_003",
  "errors": {
    "payment_token": ["Invalid or expired token"]
  },
  "meta": {
    "request_id": "req_ord_6004",
    "timestamp": "2026-04-14T15:13:00Z"
  }
}
```

### 26.8 Cancel order - not cancellable state
`POST /store/orders/:orderId/cancel`
```json
{
  "success": false,
  "message": "Order cannot be cancelled in current status",
  "error_code": "ORD_002",
  "meta": {
    "request_id": "req_ord_6009",
    "timestamp": "2026-04-14T15:15:00Z"
  }
}
```

### 26.9 Send chat message - body too long
`POST /chat/conversations/:conversationId/messages`
```json
{
  "success": false,
  "message": "Message exceeds maximum length",
  "error_code": "CHAT_003",
  "errors": {
    "body": ["Maximum length is 4000 characters"]
  },
  "meta": {
    "request_id": "req_chat_7002",
    "timestamp": "2026-04-14T15:17:00Z"
  }
}
```

## 27) Bilingual Error Message Catalog (EN/AR)

Backend should maintain standardized messages for each `error_code`.

| Error Code | English Message | Arabic Message |
|---|---|---|
| `AUTH_001` | Invalid credentials | بيانات تسجيل الدخول غير صحيحة |
| `AUTH_002` | Account pending approval | الحساب في انتظار الموافقة |
| `AUTH_003` | Account is blocked | تم حظر الحساب |
| `AUTH_004` | Invalid refresh token | رمز التحديث غير صالح |
| `AUTH_005` | Session expired, please login again | انتهت الجلسة، يرجى تسجيل الدخول مرة أخرى |
| `PROF_001` | Invalid profile data | بيانات الملف الشخصي غير صحيحة |
| `PROF_002` | Avatar file too large | حجم الصورة الشخصية كبير جدًا |
| `PROF_003` | Unsupported avatar format | صيغة الصورة الشخصية غير مدعومة |
| `PROF_004` | Current password is incorrect | كلمة المرور الحالية غير صحيحة |
| `COURSE_001` | Course not found | الكورس غير موجود |
| `COURSE_002` | Lesson not found | الدرس غير موجود |
| `COURSE_003` | Enrollment required to access this course | يجب الاشتراك في الكورس أولاً |
| `REVIEW_001` | You already reviewed this course | قمت بتقييم هذا الكورس مسبقًا |
| `REVIEW_002` | Invalid rating value | قيمة التقييم غير صحيحة |
| `EXAM_001` | Exam not found | الامتحان غير موجود |
| `EXAM_002` | Exam is not available now | الامتحان غير متاح حاليًا |
| `EXAM_003` | Invalid attempt ID | رقم المحاولة غير صالح |
| `EXAM_004` | Exam submission window is closed | تم إغلاق نافذة تسليم الامتحان |
| `PAY_001` | Coupon is invalid or expired | الكوبون غير صالح أو منتهي |
| `PAY_002` | Coupon usage limit reached | تم تجاوز الحد الأقصى لاستخدام الكوبون |
| `PAY_003` | Payment failed | فشلت عملية الدفع |
| `PAY_004` | Checkout session not found | جلسة الدفع غير موجودة |
| `COMM_001` | Post not found | المنشور غير موجود |
| `COMM_002` | Comment not found | التعليق غير موجود |
| `COMM_003` | Invalid reaction value | قيمة التفاعل غير صحيحة |
| `COMM_004` | Content violates community policy | المحتوى يخالف سياسات المجتمع |
| `COMM_005` | Report already submitted | تم إرسال البلاغ مسبقًا |
| `CART_001` | Cart item not found | عنصر السلة غير موجود |
| `CART_002` | Invalid quantity | الكمية غير صحيحة |
| `CART_003` | Insufficient stock | المخزون غير كافٍ |
| `ORD_001` | Order not found | الطلب غير موجود |
| `ORD_002` | Order cannot be cancelled in current status | لا يمكن إلغاء الطلب في حالته الحالية |
| `ADDR_001` | Address not found | العنوان غير موجود |
| `SHIP_001` | Shipping method unavailable | طريقة الشحن غير متاحة |
| `CHAT_001` | Conversation not found | المحادثة غير موجودة |
| `CHAT_002` | You are not allowed in this conversation | غير مسموح لك بهذه المحادثة |
| `CHAT_003` | Message too long | الرسالة طويلة جدًا |
| `CHAT_004` | Chat socket unauthorized | غير مصرح بالاتصال بالمحادثة |
| `UPL_001` | File too large | حجم الملف كبير جدًا |
| `UPL_002` | Unsupported file type | نوع الملف غير مدعوم |
| `UPL_003` | Upload failed | فشل رفع الملف |
| `SYS_001` | Internal server error | خطأ داخلي في الخادم |
| `SYS_002` | Service temporarily unavailable | الخدمة غير متاحة مؤقتًا |

## 28) Production Readiness Gate

Backend delivery is accepted only when:
- all endpoints return `error_code` on failures,
- all validation failures return field-level `errors`,
- EN/AR message catalog is consistently applied,
- no undocumented fields are removed without versioning,
- all required fields in section 24 are present in responses.

