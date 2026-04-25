# Home Quick Access API Contract (Medex)

This contract defines how backend should return Home **Quick Access** buttons so Flutter app can render and navigate dynamically.

Once applied, app reads `quick_access` from `GET /home` response and uses it directly.

## Endpoint

- **Method:** `GET`
- **Path:** `/home`
- **Auth:** Bearer token
- **Used by app:** `HomeService.getHomeData()`

## Request

No additional query/body needed.

### Headers

```http
Authorization: Bearer <access_token>
Accept: application/json
Accept-Language: ar | en
```

## Response: Required Section

Return `quick_access` inside `data`:

```json
{
  "success": true,
  "data": {
    "quick_access": [
      {
        "id": "store",
        "label_ar": "متجر ميديكس",
        "label_en": "Medex Store",
        "cta_route": "/store",
        "icon": "store",
        "color": "#E04F4D",
        "sort_order": 1,
        "is_active": true
      },
      {
        "id": "community",
        "label_ar": "المجتمع",
        "label_en": "Community",
        "cta_route": "/implant-community",
        "icon": "community",
        "color": "#2A7BD8",
        "sort_order": 2,
        "is_active": true
      },
      {
        "id": "academy",
        "label_ar": "الأكاديمية",
        "label_en": "Academy",
        "cta_route": "/medex-academy",
        "icon": "academy",
        "color": "#4E7E3E",
        "sort_order": 3,
        "is_active": true
      }
    ]
  }
}
```

## Item Field Rules

- `id`: unique key (string)
- `label_ar`, `label_en`: button title by language
- `cta_route`: app route to navigate on tap
- `icon`: optional icon key (supported keys listed below)
- `color`: optional hex color (`#RRGGBB` or `AARRGGBB`)
- `sort_order`: optional ordering number
- `is_active`: optional boolean flag; inactive items are ignored

## Supported `cta_route` Values (current app)

- `/store`
- `/implant-community`
- `/medex-academy`
- `/medex-offers`
- `/clinical-cases`
- `/product-learning-hub`
- `/events-exhibitions`
- `/dental-challenge`
- `/returns-exchanges`
- `/medex-ai-assistant`

Any other route is ignored by app for safety.

## Supported `icon` Keys

- `store`
- `community`
- `academy`
- `offers`
- `cases`
- `learning_hub`
- `events`
- `challenge`
- `returns`
- `ai`

If missing/invalid, app uses a fallback icon by route.

## Localization Fallback (client side)

For each item label:

1. Use `label_ar` or `label_en` based on locale
2. Fallback to generic `label` if provided
3. If invalid/missing, item is skipped

## Backend Behavior Recommendations

- Return only active items (`is_active=true`) sorted by `sort_order ASC`
- Keep item count between **6 and 10** for best layout (grid uses 5 columns)
- Prefer stable `id` values for analytics consistency

## Backward Compatibility

- If `quick_access` is missing or empty, app falls back automatically to the current hardcoded default buttons.
- So backend rollout can be incremental with no app breakage.

## QA Checklist

- [ ] `/home` returns `success=true`
- [ ] `data.quick_access` exists as array
- [ ] each active item has valid `label_ar/label_en` and supported `cta_route`
- [ ] tapping each button navigates to expected screen
- [ ] Arabic and English labels display correctly
