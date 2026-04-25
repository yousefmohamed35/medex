# Events Screen API Contract

This contract defines all API requests/responses needed for:

- `EventsExhibitionsPlaceholderScreen`
- `EventDetailsScreen`

It is designed so frontend can replace current mock data without UI rework.

## Base Rules

- Base URL: `https://medex.anmka.com/api`
- Auth: `Authorization: Bearer <token>` (required for registration actions)
- Headers:
  - `Content-Type: application/json`
  - `Accept: application/json`
  - `Accept-Language: ar|en`
- Standard envelope:

```json
{
  "success": true,
  "message": "Success",
  "data": {}
}
```

---

## 1) Events Listing (Upcoming / Past tabs)

### Endpoint

`GET /events`

### Query Params

- `status` (`upcoming` | `past`) - required for tab behavior
- `page` (number, optional, default `1`)
- `per_page` (number, optional, default `10`)
- `city` (optional)
- `format` (`online` | `offline` | `hybrid`, optional)
- `q` (optional text search)

### Example Request

`GET /events?status=upcoming&page=1&per_page=10`

### Response Example

```json
{
  "success": true,
  "message": "Success",
  "data": {
    "items": [
      {
        "id": "evt_55099e0f_2670_4af9_9c15_6efe3a1eb13c",
        "status": "upcoming",
        "title_en": "Cairo International Implant Symposium",
        "title_ar": "المؤتمر الدولي لزراعة الأسنان - القاهرة",
        "date_iso": "2026-05-22T09:00:00+02:00",
        "day": "22",
        "month_en": "MAY",
        "month_ar": "مايو",
        "location_en": "Marriott Cairo",
        "location_ar": "ماريوت القاهرة",
        "city_en": "Cairo",
        "city_ar": "القاهرة",
        "time_text_en": "9:00 AM - 6:00 PM",
        "time_text_ar": "9:00 ص - 6:00 م",
        "cpd_hours": 8,
        "attendees_expected": 500,
        "tag_a_en": "Straumann Sponsored",
        "tag_a_ar": "برعاية شتراومان",
        "tag_b_en": "120 seats left",
        "tag_b_ar": "متبقي 120 مقعد",
        "header_gradient_a": "#FF243A",
        "header_gradient_b": "#FF5760",
        "show_add_to_calendar": true,
        "registration_open": true,
        "registered": false,
        "thumbnail_url": "https://medex.anmka.com/api/uploads/events/evt_1.jpg"
      }
    ],
    "pagination": {
      "page": 1,
      "per_page": 10,
      "total": 34,
      "last_page": 4
    },
    "meta": {
      "request_id": "req_ev_9a27",
      "timestamp": "2026-04-25T21:00:00Z"
    }
  }
}
```

### UI Mapping Notes

- Tabs:
  - `Upcoming` => `status=upcoming`
  - `Past Events` => `status=past`
- Card fields come from each item:
  - day/month, title, place-time, tags, gradient colors
  - `show_add_to_calendar` controls `+ Calendar` button visibility

---

## 2) Event Details

### Endpoint

`GET /events/{eventId}`

### Example Request

`GET /events/evt_55099e0f_2670_4af9_9c15_6efe3a1eb13c`

### Response Example

```json
{
  "success": true,
  "message": "Success",
  "data": {
    "id": "evt_55099e0f_2670_4af9_9c15_6efe3a1eb13c",
    "status": "upcoming",
    "title_en": "Cairo International Implant Symposium",
    "title_ar": "المؤتمر الدولي لزراعة الأسنان - القاهرة",
    "day": "22",
    "month_year_en": "MAY 2026",
    "month_year_ar": "مايو 2026",
    "location_en": "Marriott Hotel Cairo, Egypt",
    "location_ar": "فندق ماريوت القاهرة، مصر",
    "time_range_en": "9:00 AM - 6:00 PM",
    "time_range_ar": "9:00 ص - 6:00 م",
    "cpd_hours_text_en": "8 CPD Hours",
    "cpd_hours_text_ar": "8 ساعات تدريب معتمدة",
    "attendees_text_en": "500+ Attendees Expected",
    "attendees_text_ar": "متوقع حضور أكثر من 500",
    "about_body_en": "The symposium brings together leading implantologists...",
    "about_body_ar": "يجمع المؤتمر نخبة من خبراء زراعة الأسنان...",
    "expectations_en": [
      "6 keynote speakers from 4 countries",
      "Live implant surgery demonstrations",
      "Certificate of attendance"
    ],
    "expectations_ar": [
      "6 متحدثين رئيسيين من 4 دول",
      "عروض جراحية مباشرة",
      "شهادة حضور"
    ],
    "banner_image_url": "https://medex.anmka.com/api/uploads/events/evt_1_banner.jpg",
    "show_add_to_calendar": true,
    "registration_open": true,
    "registered": false,
    "available_seats": 120
  }
}
```

---

## 3) Register Now (Card + Detail button)

### Endpoint

`POST /events/{eventId}/registrations`

### Request Body

```json
{
  "source": "events_screen",
  "notes": ""
}
```

### Success Response

```json
{
  "success": true,
  "message": "Registration completed",
  "data": {
    "registration_id": "reg_8b73cb2d",
    "event_id": "evt_55099e0f_2670_4af9_9c15_6efe3a1eb13c",
    "status": "confirmed",
    "registered_at": "2026-04-25T21:05:00Z",
    "qr_code_url": "https://medex.anmka.com/api/uploads/qr/reg_8b73cb2d.png"
  }
}
```

### Error Cases

- `409` already registered
- `400` registration closed / no seats left
- `404` event not found

---

## 4) Add to Calendar (`+ Calendar`)

### Endpoint

`POST /events/{eventId}/calendar`

### Request Body

```json
{
  "provider": "google",
  "timezone": "Africa/Cairo"
}
```

### Success Response

```json
{
  "success": true,
  "message": "Calendar link created",
  "data": {
    "event_id": "evt_55099e0f_2670_4af9_9c15_6efe3a1eb13c",
    "calendar_url": "https://calendar.google.com/calendar/render?action=TEMPLATE&text=...",
    "ics_url": "https://medex.anmka.com/api/events/evt_55099e0f-ics"
  }
}
```

---

## 5) Optional Hero Block (Top banner text)

If backend wants hero to be dynamic instead of hardcoded:

### Endpoint

`GET /events/hero`

### Response Example

```json
{
  "success": true,
  "message": "Success",
  "data": {
    "badge_en": "Upcoming 2026",
    "badge_ar": "فعاليات قادمة 2026",
    "title_en": "Where Knowledge Meets Practice",
    "title_ar": "حيث يلتقي العلم بالتطبيق",
    "subtitle_en": "Cairo - Alexandria - Online",
    "subtitle_ar": "القاهرة - الإسكندرية - أونلاين",
    "cta_en": "Browse Events",
    "cta_ar": "تصفح الفعاليات"
  }
}
```

---

## Validation Rules

- `id` must be stable unique string.
- Color fields must be valid hex `#RRGGBB`.
- For `past` events: `registration_open=false`.
- If `show_add_to_calendar=false`, frontend hides calendar button.
- Localized fields must return both `_ar` and `_en`.

---

## Frontend QA Checklist

- [ ] Opening Events screen fetches `GET /events?status=upcoming`.
- [ ] Switching to Past tab fetches `GET /events?status=past`.
- [ ] Tap card `Register Now` opens details and/or sends registration correctly.
- [ ] Tap details `Register Now` sends `POST /events/{id}/registrations`.
- [ ] Tap `+ Calendar` sends `POST /events/{id}/calendar` and opens returned link.
- [ ] Localization switches between Arabic and English texts correctly.
