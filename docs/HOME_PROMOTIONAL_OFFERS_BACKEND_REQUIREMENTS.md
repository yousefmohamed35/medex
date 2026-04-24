# Home Promotional Offers Backend Requirements

This document defines the backend contract for the **Promotional Offers** section on the student home screen.

---

## Endpoint

Recommended endpoint:

- `GET /api/v1/home/promotional-offers`

You can also include this payload inside the existing home endpoint response.

---

## Response Contract (List)

```json
{
  "items": [
    {
      "id": 101,
      "is_active": true,
      "badge_text_en": "LIMITED TIME",
      "badge_text_ar": "لفترة محدودة",
      "title_line1_en": "Straumann BLX",
      "title_line1_ar": "Straumann BLX",
      "title_line2_en": "Complete System",
      "title_line2_ar": "نظام كامل",
      "discount_text": "30%",
      "background_color": "#E5091E",
      "priority": 1,
      "redirect_type": "store_product",
      "redirect_value": "product_123",
      "starts_at": "2026-04-23T00:00:00Z",
      "ends_at": "2026-12-31T23:59:59Z"
    }
  ]
}
```

---

## Required Fields

For each offer item:

- `id` (number or string)
- `is_active` (boolean)
- `badge_text_en` (string)
- `badge_text_ar` (string)
- `title_line1_en` (string)
- `title_line1_ar` (string)
- `title_line2_en` (string)
- `title_line2_ar` (string)
- `discount_text` (string, example: `30%`)
- `background_color` (hex color string, example: `#E5091E`)
- `priority` (integer, lower number = higher priority)

---

## Optional Fields

- `redirect_type` (enum): `store`, `store_product`, `category`, `course`, `external_url`, `none`
- `redirect_value` (string): route/id/url based on `redirect_type`
- `starts_at`, `ends_at` (ISO-8601 UTC datetime)

---

## Validation Rules

- Return **only active offers** or include `is_active` so app can filter.
- Keep titles short to avoid overflow on small mobile widths:
  - `title_line1_*`: recommended <= 22 chars
  - `title_line2_*`: recommended <= 24 chars
- `discount_text` should be short (example: `20%`, `30%`, `-15%`).
- `background_color` must be a valid 6-digit hex color.
- If schedule fields are used, return only currently valid offers when possible.

---

## App-side Selection Logic

1. Keep items where `is_active = true`
2. Keep items within schedule (if dates provided)
3. Sort by `priority` ascending
4. Render top items in horizontal list

---

## Minimal Example

```json
{
  "items": [
    {
      "id": 101,
      "is_active": true,
      "badge_text_en": "LIMITED TIME",
      "badge_text_ar": "لفترة محدودة",
      "title_line1_en": "Straumann BLX",
      "title_line1_ar": "Straumann BLX",
      "title_line2_en": "Complete System",
      "title_line2_ar": "نظام كامل",
      "discount_text": "30%",
      "background_color": "#E5091E",
      "priority": 1
    },
    {
      "id": 102,
      "is_active": true,
      "badge_text_en": "BUNDLE DEAL",
      "badge_text_ar": "عرض باقة",
      "title_line1_en": "Nobel Active RP",
      "title_line1_ar": "Nobel Active RP",
      "title_line2_en": "Buy 10 Get 1",
      "title_line2_ar": "اشتر 10 واحصل على 1",
      "discount_text": "20%",
      "background_color": "#1F2937",
      "priority": 2
    }
  ]
}
```
