# Home Featured Products Backend Requirements

This document defines the backend contract for the **Featured Products** section on the home screen.

---

## Endpoint

Recommended:

- `GET /api/v1/home/featured-products`

Or include this list inside existing home response:

- `data.featured_products`

---

## Response Contract

```json
{
  "items": [
    {
      "id": "product_123",
      "name": "BLX Implant 4.5x10mm",
      "name_ar": "زرعة BLX 4.5x10 مم",
      "brand": "Straumann",
      "price": 1850,
      "discount": 30,
      "image_url": "https://cdn.example.com/products/blx-45x10.png",
      "is_available": true,
      "is_featured": true,
      "priority": 1
    }
  ]
}
```

---

## Required Fields

Each featured product item must include:

- `id` (string or number)
- `name` (string)
- `name_ar` (string)
- `brand` (string)
- `price` (number)
- `image_url` (string, absolute URL preferred)

---

## Optional Fields

- `discount` (number, percentage value)
- `is_available` (boolean)
- `is_featured` (boolean)
- `priority` (integer, lower number first)
- `starts_at`, `ends_at` (ISO-8601 UTC date-time)

---

## Validation / UI Rules

- Return image URLs that are valid and optimized for mobile.
- Keep `name` / `name_ar` concise:
  - recommended <= 32 chars (best fit in product cards)
- `brand` recommended <= 20 chars.
- `price` should be numeric (app formats to EGP display).
- `discount` should be numeric only (app renders as `-XX%`).

---

## App-side Selection Logic

1. Keep items where `is_available != false`
2. Keep in active date range (if schedule fields exist)
3. Sort by `priority` ascending
4. Render first 6 items in horizontal list

---

## Minimal Example

```json
{
  "items": [
    {
      "id": "p1",
      "name": "BLX Implant 4.5x10mm",
      "name_ar": "زرعة BLX 4.5x10 مم",
      "brand": "Straumann",
      "price": 1850,
      "discount": 30,
      "image_url": "https://cdn.example.com/products/p1.png",
      "priority": 1
    },
    {
      "id": "p2",
      "name": "Nobel Active RP 4.3",
      "name_ar": "Nobel Active RP 4.3",
      "brand": "Nobel Biocare",
      "price": 2100,
      "discount": 20,
      "image_url": "https://cdn.example.com/products/p2.png",
      "priority": 2
    }
  ]
}
```
