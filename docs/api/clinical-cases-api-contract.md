# Clinical Cases API Contract (Buttons, Requests, Responses)

This document defines the backend contract for the **Clinical Cases** module:

- Clinical cases listing screen
- Case detail screen
- Media actions (video/pdf/images)
- Rating flow

It is designed so frontend can map every button in the current UI to backend endpoints.

---

## 1) Base Rules

- **Auth:** Bearer token required
- **Headers**

```http
Authorization: Bearer <access_token>
Accept: application/json
Accept-Language: ar | en
Content-Type: application/json
```

- **Standard response envelope**

```json
{
  "success": true,
  "message": "optional",
  "data": {}
}
```

Error envelope:

```json
{
  "success": false,
  "message": "Human readable error",
  "errors": {
    "field": ["validation message"]
  }
}
```

---

## 2) Screens & Buttons Mapping

## A) Clinical Cases List Screen

UI buttons/actions:

- Back button
  - Navigation only
- Search icon / search input
  - `GET /clinical-cases?search=...`
- Filters:
  - `All Categories`
  - `By Year`
  - `By Doctor`
  - `By Country`
  - Brand chips (`B&B Implant`, `Point Implant`, ...)
  - All map to `GET /clinical-cases` query params
- `View Case` button on each card
  - Navigation to detail screen
  - (optional prefetch) `GET /clinical-cases/{caseId}`
- `PDF` button on each card
  - open case pdf URL from listing item OR call detail endpoint first

## B) Case Detail Screen

UI buttons/actions:

- Back button
  - Navigation only
- Top-right action icon (settings/filter icon in mock)
  - optional: open action sheet (no required API)
- Hero media chips:
  - `Video` -> open `video_url`
  - `PDF` -> open `pdf_url`
  - `14 imgs` -> open gallery viewer using `images[]`
- `Rate this Case ★`
  - opens rating sheet (local UI)
- Rating sheet:
  - `Submit Rating` -> `POST /clinical-cases/{caseId}/ratings`
  - `Skip` -> close sheet (no API)

---

## 3) Endpoints

## 3.1 List Clinical Cases

### Request

`GET /clinical-cases`

### Query params (all optional)

- `page` (int, default 1)
- `per_page` (int, default 10-20)
- `search` (string)
- `category` (string or id)
- `year` (int)
- `doctor_id` (string)
- `country` (string)
- `brand` (string)
- `sort` (`latest`, `top_rated`, `most_viewed`)

### Response

```json
{
  "success": true,
  "data": {
    "cases": [
      {
        "id": "case_001",
        "label": "FULL ARCH · B&B",
        "title_en": "All-on-4 Immediate Loading – Complete Rehabilitation",
        "title_ar": "تحميل فوري All-on-4 – إعادة تأهيل كاملة",
        "summary_en": "Patient presented with complete edentulism...",
        "summary_ar": "حضر المريض مع فقدان كامل للأسنان...",
        "doctor": {
          "id": "doc_12",
          "name": "Dr. Nour Khalil",
          "title_en": "Periodontist",
          "title_ar": "أخصائي لثة",
          "avatar_url": "https://cdn.medex.com/avatars/nour.jpg"
        },
        "location": {
          "city": "Cairo",
          "country": "EG Egypt"
        },
        "brand": "B&B Implant",
        "category": "FULL ARCH",
        "year": 2025,
        "follow_up_months": 12,
        "rating_avg": 4.8,
        "ratings_count": 24,
        "hero_gradient_a": "#3A0C10",
        "hero_gradient_b": "#6B040A",
        "hero_image_url": "https://cdn.medex.com/cases/case_001/hero.jpg",
        "video_url": "https://cdn.medex.com/cases/case_001/video.mp4",
        "pdf_url": "https://cdn.medex.com/cases/case_001/report.pdf",
        "images_count": 14
      }
    ],
    "filters": {
      "categories": ["FULL ARCH", "SINGLE UNIT", "GBR"],
      "years": [2026, 2025, 2024],
      "countries": ["EG", "SA", "AE"],
      "brands": ["B&B Implant", "Point Implant", "Powerbone"],
      "doctors": [{ "id": "doc_12", "name": "Dr. Nour Khalil" }]
    },
    "meta": {
      "page": 1,
      "per_page": 10,
      "total": 37,
      "total_pages": 4
    }
  }
}
```

---

## 3.2 Case Detail

### Request

`GET /clinical-cases/{caseId}`

### Response

```json
{
  "success": true,
  "data": {
    "id": "case_001",
    "label": "FULL ARCH · B&B",
    "title_en": "All-on-4 Immediate Loading – Complete Rehabilitation",
    "title_ar": "تحميل فوري All-on-4 – إعادة تأهيل كاملة",
    "doctor": {
      "id": "doc_12",
      "name": "Dr. Nour Khalil",
      "title_en": "Periodontist",
      "title_ar": "أخصائي لثة",
      "institution_en": "Cairo University",
      "institution_ar": "جامعة القاهرة",
      "avatar_url": "https://cdn.medex.com/avatars/nour.jpg"
    },
    "location": {
      "city": "Cairo",
      "country": "EG Egypt"
    },
    "patient": {
      "age": 54,
      "gender_en": "Female",
      "gender_ar": "أنثى"
    },
    "follow_up_months": 12,
    "implant_system": "B&B BLX 4.5mm",
    "loading_protocol_en": "Immediate",
    "loading_protocol_ar": "فوري",
    "case_summary_en": "Patient presented with complete edentulism of maxillary arch...",
    "case_summary_ar": "حضر المريض مع فقدان كامل للأسنان في الفك العلوي...",
    "before_image_url": "https://cdn.medex.com/cases/case_001/before.jpg",
    "after_image_url": "https://cdn.medex.com/cases/case_001/after.jpg",
    "hero": {
      "gradient_a": "#3A0C10",
      "gradient_b": "#6B040A",
      "hero_image_url": "https://cdn.medex.com/cases/case_001/hero.jpg"
    },
    "media": {
      "video_url": "https://cdn.medex.com/cases/case_001/video.mp4",
      "pdf_url": "https://cdn.medex.com/cases/case_001/report.pdf",
      "images": [
        "https://cdn.medex.com/cases/case_001/img1.jpg",
        "https://cdn.medex.com/cases/case_001/img2.jpg"
      ]
    },
    "rating": {
      "avg": 4.8,
      "count": 24,
      "user_rating": null
    }
  }
}
```

---

## 3.3 Submit Case Rating

### Request

`POST /clinical-cases/{caseId}/ratings`

```json
{
  "rating": 5,
  "comment": "optional"
}
```

### Validation

- `rating` required, integer, range `1..5`
- one rating per user per case (update existing if already rated)

### Response

```json
{
  "success": true,
  "message": "Rating submitted successfully",
  "data": {
    "case_id": "case_001",
    "user_rating": 5,
    "avg_rating": 4.9,
    "ratings_count": 25
  }
}
```

---

## 3.4 (Optional) Track Media/Case Events

If analytics is needed:

- `POST /clinical-cases/{caseId}/events`

```json
{
  "event": "view_case | open_video | open_pdf | open_gallery | rate_case",
  "meta": {}
}
```

---

## 4) Localization Rules

For all user-visible texts:

- Prefer explicit bilingual fields (`*_ar`, `*_en`)
- Frontend should use current locale field
- Fallback order:
  1. locale field (`title_ar`/`title_en`)
  2. generic field (`title`) if exists
  3. safe frontend fallback text

---

## 5) Media Requirements

- `video_url`: direct stream/file URL (mp4/hls)
- `pdf_url`: direct PDF URL
- `images`: array of image URLs for gallery
- All media URLs should be public or signed-valid for mobile client access

---

## 6) Minimal Fields Required To Render Current UI

For list card:

- `id`, `label`, `title_ar/title_en`, `summary_ar/summary_en`
- `doctor.name`, `location.city`, `location.country`
- `hero_gradient_a`, `hero_gradient_b`
- `video_url`, `pdf_url`, `images_count`

For detail:

- all list fields +
- patient metadata
- follow-up
- implant system
- loading protocol
- case summary
- before/after images
- media gallery array

---

## 7) QA Checklist

- [ ] `GET /clinical-cases` returns paginated list + filters
- [ ] tapping **View Case** can load full detail via `GET /clinical-cases/{id}`
- [ ] `Video` and `PDF` media links open successfully
- [ ] gallery images array renders and count matches
- [ ] `POST /clinical-cases/{id}/ratings` accepts values 1..5
- [ ] avg/count rating in response updates after submit
- [ ] Arabic and English content both available

---

## 8) Notes For Backend Team

- Keep response envelope consistent with existing Medex APIs.
- Keep IDs stable (`case_id`, `doctor_id`) for future analytics and caching.
- If some fields are unavailable initially, return empty strings/arrays instead of changing schema shape.
