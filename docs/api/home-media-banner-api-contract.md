# Home Media Banner API Contract (Medex)

This document defines the backend contract required for the top home banner card/video in the app.
Once backend applies this contract, current Flutter code will consume it directly with no extra frontend changes.

## Goal

Provide a short welcome video banner at the top of Home screen with:

- Welcome video (or fallback image)
- Suitable welcome title
- Clear Play button text

## Endpoint

- **Method:** `GET`
- **Path:** `/home`
- **Auth:** Bearer token required
- **Used by app:** `HomeService.getHomeData()`

## Request

No extra request params are required for this feature.

### Headers

```http
Authorization: Bearer <access_token>
Accept: application/json
Accept-Language: ar | en
```

## Response Shape (required part)

`hero_banner` must be returned inside `data` in `/home` response.

```json
{
  "success": true,
  "data": {
    "hero_banner": {
      "media_type": "video",
      "media_url": "https://cdn.medex.com/banners/welcome.mp4",
      "video_url": "https://cdn.medex.com/banners/welcome.mp4",
      "image": "uploads/banners/welcome-thumb.jpg",
      "background_image": "uploads/banners/welcome-bg.jpg",
      "badge_text_ar": "MEDEX",
      "badge_text_en": "MEDEX",
      "title_ar": "فيديو ترحيبي سريع\nبتطبيق Medex",
      "title_en": "Quick Welcome Video\nAbout Medex App",
      "subtitle_ar": "شاهد فيديو قصير يعرّفك بخدمات ومزايا التطبيق",
      "subtitle_en": "Watch a short clip to discover app features",
      "primary_button_text_ar": "شاهد الآن",
      "primary_button_text_en": "Watch Now",
      "play_button_text_ar": "تشغيل",
      "play_button_text_en": "Play",
      "cta_route": "/medex-academy",
      "is_active": true,
      "sort_order": 1
    }
  }
}
```

## Field Rules

- `media_type`: `video` or `image`
- `media_url`: main media URL used by client
  - if `media_type=video` => direct video URL (mp4/hls)
  - if `media_type=image` => image URL
- `video_url`: optional compatibility fallback for old clients
- `image` and `background_image`: optional image fallback paths/URLs
- Text fields should be provided in both `*_ar` and `*_en`
- If `is_active=false`, backend can return `hero_banner: null` or omit it
- `cta_route`: internal app route for banner tap action (example: `/medex-academy`)

## Localization Contract

Preferred fields:

- `title_ar`, `title_en`
- `subtitle_ar`, `subtitle_en`
- `badge_text_ar`, `badge_text_en`
- `primary_button_text_ar`, `primary_button_text_en`
- `play_button_text_ar`, `play_button_text_en`

Frontend fallback order:

1. `field_ar` / `field_en` by locale
2. generic `field` if exists
3. hardcoded default text in app

## Media Notes

- URLs can be absolute (`https://...`) or relative (`uploads/...`).
- For `image` and `background_image`, backend can send relative path; app already prefixes API base URL.
- For `media_url` video, send full absolute URL to avoid ambiguity.
- Recommended max welcome video length: **15-45 seconds**.

## Backward Compatibility

Current app already supports old keys:

- `media_type`
- `media_url`
- `video_url`
- `image`
- `background_image`

So backend rollout can be incremental: old values continue working, and new text fields enhance UI immediately.

## Validation Checklist (Backend)

- [ ] `/home` returns `success=true`
- [ ] `data.hero_banner` exists and is active
- [ ] `media_type` + correct `media_url` are present
- [ ] `title_ar/title_en` are provided
- [ ] `play_button_text_ar/play_button_text_en` are provided
- [ ] response works for both `Accept-Language: ar` and `Accept-Language: en`

## QA Quick Test

1. Login as student
2. Open Home screen
3. Verify banner appears at top
4. Verify title/subtitle/button texts match current language
5. Verify Play button is visible when `media_type=video`
6. Verify tapping banner routes to configured action (`cta_route`), defaulting to Medex Academy when missing/invalid
