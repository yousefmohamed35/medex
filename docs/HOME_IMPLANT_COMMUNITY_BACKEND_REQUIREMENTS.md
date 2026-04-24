# Home Implant Community Backend Requirements

This document defines the backend contract for the **Implant Community** section on the home screen.

---

## Endpoint

Recommended endpoint:

- `GET /api/v1/home/implant-community`

Or include inside existing home payload as:

- `data.implant_community`

---

## Response Contract

```json
{
  "items": [
    {
      "id": "post_901",
      "is_active": true,
      "title_en": "Complex sinus lift case - opinions?",
      "title_ar": "حالة رفع جيب معقدة - الآراء؟",
      "author_name_en": "Dr. Nour K.",
      "author_name_ar": "د. نور ك.",
      "replies_count": 34,
      "cover_type": "gradient",
      "cover_image_url": null,
      "cover_gradient_start": "#1F0B13",
      "cover_gradient_end": "#5B0009",
      "cover_icon": "groups",
      "priority": 1,
      "redirect_type": "community_post",
      "redirect_value": "post_901",
      "starts_at": "2026-04-23T00:00:00Z",
      "ends_at": "2026-12-31T23:59:59Z"
    }
  ]
}
```

---

## Required Fields

Per item:

- `id`
- `is_active`
- `title_en`
- `title_ar`
- `author_name_en`
- `author_name_ar`
- `replies_count`
- `priority`

---

## Optional Visual Fields

- `cover_type`: `gradient` | `image`
- `cover_image_url`: absolute image URL (if `cover_type = image`)
- `cover_gradient_start`: hex color (if `cover_type = gradient`)
- `cover_gradient_end`: hex color (if `cover_type = gradient`)
- `cover_icon`: icon key string (example: `groups`, `chat`)

If no visual fields are provided, app uses built-in gradient + icon fallback.

---

## Optional Navigation Fields

- `redirect_type`: `community_post` | `community` | `external_url` | `none`
- `redirect_value`: post id / route / URL depending on `redirect_type`

---

## Validation / UI Rules

- Keep title short for card fit:
  - recommended <= 52 chars
- `author_name_*` recommended <= 24 chars
- `replies_count` must be numeric
- Return max 6 items (home preview list)
- Sort by `priority` ascending

---

## App Selection Logic

1. Keep active and in-range items (`is_active`, date range)
2. Sort by `priority`
3. Render first items in horizontal list
4. `View All` navigates to community main screen

---

## Minimal Example

```json
{
  "items": [
    {
      "id": "post_901",
      "is_active": true,
      "title_en": "Complex sinus lift case - opinions?",
      "title_ar": "حالة رفع جيب معقدة - الآراء؟",
      "author_name_en": "Dr. Nour K.",
      "author_name_ar": "د. نور ك.",
      "replies_count": 34,
      "priority": 1
    },
    {
      "id": "post_902",
      "is_active": true,
      "title_en": "BLX vs Nobel - which platform?",
      "title_ar": "BLX أم Nobel - أي منصة أفضل؟",
      "author_name_en": "Dr. Sami A.",
      "author_name_ar": "د. سامي أ.",
      "replies_count": 58,
      "priority": 2
    }
  ]
}
```
