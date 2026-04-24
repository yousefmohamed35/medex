# Home Banner Backend Requirements

This document defines the backend contract for the Home Banner shown in the student home screen.

The app supports banner media as:

- **Image**
- **Video**

Both asset and remote URLs are supported in the app, but backend integration should return **remote URLs**.

---

## Endpoint

Use one of these approaches:

- Include banner payload inside existing home endpoint response
- Or expose a dedicated endpoint

Suggested dedicated endpoint:

- `GET /api/v1/home/banner`

---

## Response Contract (Required)

```json
{
  "id": 1,
  "is_active": true,
  "media_type": "image",
  "media_url": "https://cdn.example.com/banners/home-banner.jpg",
  "thumbnail_url": "https://cdn.example.com/banners/home-banner-thumb.jpg",
  "redirect_type": "store",
  "redirect_value": "/store",
  "title_en": "Premium Dental Products",
  "title_ar": "منتجات طب أسنان متميزة",
  "subtitle_en": "Top products from Italy, Turkey & Korea",
  "subtitle_ar": "أفضل المنتجات من إيطاليا وتركيا وكوريا",
  "badge_text_en": "MEDEX",
  "badge_text_ar": "MEDEX",
  "cta_text_en": "Shop Now",
  "cta_text_ar": "تسوق الآن",
  "priority": 1,
  "starts_at": "2026-04-23T00:00:00Z",
  "ends_at": "2026-12-31T23:59:59Z"
}
```

---

## Field Rules

- `media_type`: must be one of:
  - `image`
  - `video`
- `media_url`: absolute URL to media file
  - image formats: `jpg`, `jpeg`, `png`, `webp`
  - video formats: `mp4` (recommended), `m3u8` (optional if supported by CDN)
- `thumbnail_url`: optional but **recommended** for video placeholder/loading state
- `is_active`: if `false`, app should ignore this banner
- `priority`: lower number = higher priority (used if multiple banners are returned)
- `starts_at`, `ends_at`: optional scheduling fields (UTC ISO-8601)

---

## Redirect Rules

- `redirect_type` recommended enum:
  - `store`
  - `course`
  - `category`
  - `external_url`
  - `none`
- `redirect_value`:
  - route path, id, or external URL based on `redirect_type`

If `redirect_type = none`, app ignores click action.

---

## If Returning Multiple Banners

If backend returns a list, use:

```json
{
  "items": [
    {
      "id": 1,
      "is_active": true,
      "media_type": "video",
      "media_url": "https://cdn.example.com/banners/home-banner.mp4",
      "thumbnail_url": "https://cdn.example.com/banners/home-banner-thumb.jpg",
      "priority": 1
    }
  ]
}
```

Selection logic on app side:

1. Keep only active and valid-date items
2. Sort by `priority` ascending
3. Use first item

---

## Error / Fallback Behavior

- If banner payload is missing or invalid:
  - app falls back to local default banner (image)
- If video fails to load:
  - app should show thumbnail (if provided) or fallback image

---

## Backend Validation Checklist

- Return full absolute URLs (https)
- Ensure `media_type` matches actual file type
- Ensure CORS/CDN allows media playback
- Optimize media size for mobile:
  - image <= 500 KB recommended
  - video <= 4 MB recommended for fast load

---

## Quick Examples

### Image Banner Example

```json
{
  "media_type": "image",
  "media_url": "https://cdn.example.com/banners/home.jpg",
  "redirect_type": "store",
  "redirect_value": "/store"
}
```

### Video Banner Example

```json
{
  "media_type": "video",
  "media_url": "https://cdn.example.com/banners/home.mp4",
  "thumbnail_url": "https://cdn.example.com/banners/home-thumb.jpg",
  "redirect_type": "store",
  "redirect_value": "/store"
}
```
