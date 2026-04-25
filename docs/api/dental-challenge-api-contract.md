# Dental Challenge API Contract

This file defines all backend requests/responses required by `DentalChallengeScreen` UI.

## Base

- Base URL: `https://medex.anmka.com/api`
- Auth: `Authorization: Bearer <token>` (required for join + submit flows)
- Headers:
  - `Accept: application/json`
  - `Content-Type: application/json` (except multipart upload)
  - `Accept-Language: ar|en`
- Standard response envelope:

```json
{
  "success": true,
  "message": "Success",
  "data": {}
}
```

---

## 1) Challenge Home Screen Data

Used to populate all static/dynamic blocks:
- hero (week, title, subtitle, stats, join button)
- rules
- participation steps
- prizes
- winners card
- submissions gallery (first items)

### Endpoint

`GET /dental-challenge/home`

### Response

```json
{
  "success": true,
  "message": "Success",
  "data": {
    "challenge": {
      "id": "dc_2026_w18",
      "status": "open",
      "week_label_en": "WEEK 18 - 2026",
      "week_label_ar": "الأسبوع 18 - 2026",
      "title_en": "Best Implant Case of the Month",
      "title_ar": "أفضل حالة زراعة لهذا الشهر",
      "subtitle_en": "Win free implants + accessories + certificate",
      "subtitle_ar": "اربح زرعات مجانية + ملحقات + شهادة",
      "remaining_time_text_en": "3d 14h",
      "remaining_time_text_ar": "3 أيام 14 ساعة",
      "submissions_count": 48,
      "winners_count": 2,
      "can_join": true,
      "joined": false
    },
    "rules": [
      {
        "id": "rule_1",
        "text_en": "Use Medex products only",
        "text_ar": "استخدم منتجات ميدكس فقط",
        "sort_order": 1
      }
    ],
    "steps": [
      {
        "step_no": 1,
        "title_en": "Upload Your Case",
        "title_ar": "ارفع حالتك",
        "subtitle_en": "Before & After photos + X-rays",
        "subtitle_ar": "صور قبل وبعد + أشعة"
      }
    ],
    "prizes": [
      {
        "id": "prize_1",
        "emoji": "🦷",
        "title_en": "Free Dental Implant",
        "title_ar": "زرعة أسنان مجانية",
        "sort_order": 1
      }
    ],
    "last_week_winners": [
      {
        "rank": 1,
        "user_id": "usr_001",
        "doctor_name_en": "Dr. Nour Khalil",
        "doctor_name_ar": "د. نور خليل",
        "subtitle_en": "All-on-4 Immediate - Cairo",
        "subtitle_ar": "All-on-4 فوري - القاهرة",
        "points": 980,
        "avatar_url": "https://medex.anmka.com/api/uploads/users/nour.jpg"
      }
    ],
    "gallery_preview": [
      {
        "submission_id": "sub_1001",
        "doctor_name_en": "Dr. Nour Khalil",
        "doctor_name_ar": "د. نور خليل",
        "likes_count": 142,
        "views_count": 890,
        "comments_count": 34,
        "thumbnail_url": "https://medex.anmka.com/api/uploads/challenge/sub_1001.jpg",
        "is_winner": true
      }
    ]
  }
}
```

---

## 2) Join Challenge (Join Now button)

### Endpoint

`POST /dental-challenge/{challengeId}/join`

### Body

```json
{
  "source": "challenge_hero"
}
```

### Success

```json
{
  "success": true,
  "message": "Joined successfully",
  "data": {
    "challenge_id": "dc_2026_w18",
    "joined": true,
    "joined_at": "2026-04-25T22:45:00Z"
  }
}
```

### Errors

- `400`: challenge closed
- `401`: unauthorized
- `409`: already joined
- `404`: challenge not found

---

## 3) Upload Assets (photos/X-rays/PDF)

Used by “Tap to upload photos & X-rays”.

### Endpoint

`POST /upload` (multipart/form-data)

### Fields

- `file` (required)
- `folder` = `dental-challenge` (optional)

### Success

```json
{
  "success": true,
  "message": "Uploaded",
  "data": {
    "url": "https://medex.anmka.com/api/uploads/dental-challenge/file_1.jpg",
    "path": "uploads/dental-challenge/file_1.jpg",
    "mime_type": "image/jpeg",
    "size_bytes": 281903
  }
}
```

### Notes

- Max files in submission UI: `20`
- Allowed: `image/*`, `application/pdf`
- If backend supports batch upload, can expose:
  - `POST /dental-challenge/uploads/batch`

---

## 4) Brand Options (Dropdown)

Used by “Implant Brand Used”.

### Endpoint

`GET /dental-challenge/brands`

### Success

```json
{
  "success": true,
  "message": "Success",
  "data": {
    "brands": [
      { "id": "bb_implant", "name_en": "B&B Implant", "name_ar": "B&B Implant" },
      { "id": "point_implant", "name_en": "Point Implant", "name_ar": "Point Implant" },
      { "id": "powerbone", "name_en": "Powerbone", "name_ar": "Powerbone" }
    ]
  }
}
```

---

## 5) Submit Case (Submit Case button)

### Endpoint

`POST /dental-challenge/{challengeId}/submissions`

### Body

```json
{
  "title": "Immediate All-on-4 Rehabilitation",
  "brand_id": "bb_implant",
  "description": "Optional case summary and steps",
  "attachments": [
    {
      "type": "image",
      "url": "https://medex.anmka.com/api/uploads/dental-challenge/file_1.jpg"
    },
    {
      "type": "pdf",
      "url": "https://medex.anmka.com/api/uploads/dental-challenge/report.pdf"
    }
  ]
}
```

### Validation

- `title`: required, min 8 chars
- `brand_id`: required
- `attachments`: required, min 1, max 20
- at least one image required

### Success

```json
{
  "success": true,
  "message": "Case submitted successfully",
  "data": {
    "submission_id": "sub_1001",
    "challenge_id": "dc_2026_w18",
    "status": "pending_review",
    "submitted_at": "2026-04-25T22:55:00Z"
  }
}
```

---

## 6) Winners Block (Last Week's Winners)

If separate endpoint is preferred:

### Endpoint

`GET /dental-challenge/winners?period=last_week&limit=2`

### Success

```json
{
  "success": true,
  "message": "Success",
  "data": {
    "items": [
      {
        "rank": 1,
        "doctor_name_en": "Dr. Nour Khalil",
        "doctor_name_ar": "د. نور خليل",
        "subtitle_en": "All-on-4 Immediate - Cairo",
        "subtitle_ar": "All-on-4 فوري - القاهرة",
        "points": 980,
        "avatar_url": "https://medex.anmka.com/api/uploads/users/nour.jpg"
      }
    ]
  }
}
```

---

## 7) Submissions Gallery (preview + View All)

### Preview endpoint

`GET /dental-challenge/{challengeId}/submissions?sort=top&limit=10`

### View All endpoint

`GET /dental-challenge/{challengeId}/submissions?sort=top&page=1&per_page=20`

### Optional filters

- `brand_id`
- `period=week|month`
- `search`

### Success

```json
{
  "success": true,
  "message": "Success",
  "data": {
    "items": [
      {
        "submission_id": "sub_1001",
        "doctor_name_en": "Dr. Nour Khalil",
        "doctor_name_ar": "د. نور خليل",
        "likes_count": 142,
        "views_count": 890,
        "comments_count": 34,
        "thumbnail_url": "https://medex.anmka.com/api/uploads/challenge/sub_1001.jpg",
        "is_winner": true
      }
    ],
    "pagination": {
      "page": 1,
      "per_page": 20,
      "total": 95,
      "last_page": 5
    }
  }
}
```

---

## 8) Submission Details (if user taps gallery item)

### Endpoint

`GET /dental-challenge/submissions/{submissionId}`

### Success

```json
{
  "success": true,
  "message": "Success",
  "data": {
    "submission_id": "sub_1001",
    "challenge_id": "dc_2026_w18",
    "doctor_name_en": "Dr. Nour Khalil",
    "doctor_name_ar": "د. نور خليل",
    "title": "Immediate All-on-4 Rehabilitation",
    "description": "Case summary...",
    "brand_id": "bb_implant",
    "likes_count": 142,
    "views_count": 890,
    "comments_count": 34,
    "attachments": [
      {
        "type": "image",
        "url": "https://medex.anmka.com/api/uploads/challenge/sub_1001.jpg"
      }
    ]
  }
}
```

---

## 9) Reaction/Engagement (for gallery interactions)

### Like/Unlike

`POST /dental-challenge/submissions/{submissionId}/like`

Body:

```json
{
  "like": true
}
```

### Register view

`POST /dental-challenge/submissions/{submissionId}/view`

Body: empty

---

## Error Envelope

```json
{
  "success": false,
  "message": "Validation error",
  "errors": {
    "title": ["Title is required"]
  },
  "meta": {
    "request_id": "req_dc_1827",
    "timestamp": "2026-04-25T23:00:00Z"
  }
}
```

---

## Frontend Mapping Summary

- `Join Now` -> `POST /join`
- `Upload box` -> `POST /upload` (one/multiple files)
- `Implant Brand dropdown` -> `GET /brands`
- `Submit Case` -> `POST /submissions`
- `Last Week's Winners` -> `GET /winners` (or included in `/home`)
- `Submissions Gallery` -> `GET /submissions`
- `View All` -> same endpoint with pagination

---

## QA Checklist

- [ ] Home loads challenge blocks and hero stats correctly.
- [ ] Join button reflects joined state after API success.
- [ ] Upload accepts allowed file types and returns URLs.
- [ ] Submit validates required fields and max files.
- [ ] Winners section shows rank, name, points.
- [ ] Gallery preview counts match backend values.
- [ ] View All supports pagination + filters.
