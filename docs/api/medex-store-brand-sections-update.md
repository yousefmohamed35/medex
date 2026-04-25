# Medex Store Brand Sections Update (UI + Backend Alignment)

This document explains the latest Medex Store behavior updates so backend can align data and expected UX.

## Updated UX Behavior

Store now behaves as **5 brand sections** in the left rail:

1. `B&B`
2. `Macros`
3. `Powerbone`
4. `MCTBIO`
5. `Biomaterials/Regenerative`

For each selected brand:

- Categories grid shows only categories that belong to that brand section.
- Featured products list shows only products that belong to that brand section.
- Clicking a category filters featured products to that category only.
- Clicking **All Products** clears category filter and shows products from **all categories** within the selected brand section.

## Important UI Label Change

- Previous label: `All Categories`
- New label: `All Products`

## Frontend Filtering Logic

Brand matching is done from product/category `brand` text (case-insensitive) using these rules:

- `B&B` section: brand contains `b&b` or `bb`
- `Macros` section: brand contains `macros`
- `Powerbone` section: brand contains `powerbone`
- `MCTBIO` section: brand contains `mctbio`
- `Biomaterials/Regenerative` section: brand contains one of:
  - `biomaterial`
  - `graft`
  - `regenerative`

## Backend Requirements To Make This Reliable

To ensure correct grouping/filtering, backend should provide consistent product fields:

- `brand` (required, stable normalized naming)
- `category` and/or `category_ar`
- `name`, `name_ar`
- `price`
- `is_available`
- `image_url` (or image fallback fields already supported)

For categories endpoint:

- `name`, `name_ar`
- `brand` (recommended)
- `subcategories` (optional)

## Suggested Brand Values (canonical)

Use one of these canonical values for best results:

- `B&B Dental`
- `Macros Implants`
- `Powerbone`
- `MCTBIO`
- `Biomaterials`

## APIs Used By Store Screen

- `GET /store/categories`
- `GET /store/products`

Both are already used on screen load, and results are applied to side rail section rendering behavior.

## QA Checklist

- [ ] Tap each side brand and verify categories/products change.
- [ ] Tap one category and verify featured products narrow to that category.
- [ ] Tap **All Products** and verify full brand products return.
- [ ] Verify no cross-brand products appear in wrong section.
