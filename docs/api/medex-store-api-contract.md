# Medex Store API Contract (Buttons, Requests, Responses)

This document is the backend integration contract for the Medex Store module.
It covers:

- All key store screens and main user buttons
- API requests triggered by each action
- Expected response bodies
- Current implementation notes (already wired vs pending)

---

## 1) Base Rules

- **Base URL:** same API base used in app config.
- **Auth:** all store endpoints require bearer token.
- **Headers**

```http
Authorization: Bearer <access_token>
Accept: application/json
Accept-Language: ar | en
Content-Type: application/json
```

- **Standard envelope**

```json
{
  "success": true,
  "message": "optional",
  "data": {}
}
```

On failure:

```json
{
  "success": false,
  "message": "Human readable error",
  "errors": {
    "field_name": ["validation message"]
  }
}
```

---

## 2) Endpoints Used by App

- `GET /store/categories`
- `GET /store/products`
- `GET /store/products/{productId}` (reserved for details)
- `GET /store/cart`
- `POST /store/cart/items`
- `PATCH /store/cart/items/{itemId}`
- `DELETE /store/cart/items/{itemId}`
- `DELETE /store/cart/clear`
- `POST /store/addresses`
- `GET /store/addresses` (reserved)
- `POST /store/orders`
- `GET /store/orders`
- `GET /store/orders/{orderId}` (reserved)
- `POST /store/orders/{orderId}/mark-received`
- `POST /store/rentals/{rentalId}/mark-received`
- `POST /store/coupons/validate` (reserved)
- `GET /store/shipping-methods` (reserved)
- `POST /store/checkout/preview` (reserved)

---

## 3) Buttons -> API Mapping (By Screen)

## `StoreScreen`

- **Search field change** (`Search products...`)
  - Current behavior: local filtering in UI.
  - Backend-ready behavior: call `GET /store/products?search=...`.
- **Cart icon**
  - Navigation only to cart screen, no request.
- **All Categories card**
  - Navigation only.
- **Category card tap**
  - Navigation only.
- **Featured product tile tap**
  - Navigation only to product details.
- **Featured tile `+` (Add to cart)**
  - `POST /store/cart/items`
  - Body:
    ```json
    { "product_id": "123", "quantity": 1, "is_rental": false }
    ```
  - Then app refreshes cart with `GET /store/cart`.

## `StoreCategoryListingScreen`

- **Search field**
  - Current behavior: local filtering.
  - Backend-ready: `GET /store/products` with filters.
- **Cart icon**
  - Navigation only.
- **Product row tap / thumbnail tap**
  - Navigation only.
- **Product row `+` (Add to cart)**
  - `POST /store/cart/items` + cart refresh `GET /store/cart`.
- **Filter button**
  - Placeholder in app now ("coming soon"), no request yet.

## `CategoryProductsScreen`

- **Screen load / subcategory changes**
  - `GET /store/categories`
  - `GET /store/products` (paged internally through multiple calls)
  - Params used:
    - `category_id`
    - `subcategory`
    - `brand`
    - `page`
    - `per_page`
- **Subcategory chip tap**
  - Navigation + reload logic (same requests above).
- **Product card tap**
  - Navigation only.

## `ProductDetailsScreen`

- **Add to cart button**
  - `POST /store/cart/items` + cart refresh.
- **Favourite button**
  - Local UI only now (no backend endpoint yet).

## `CartScreen`

- **Clear All**
  - `DELETE /store/cart/clear`
- **Delete item**
  - `DELETE /store/cart/items/{itemId}`
- **Quantity - / +**
  - `PATCH /store/cart/items/{itemId}`
  - Body:
    ```json
    { "quantity": 3 }
    ```
- **Checkout**
  - Navigation to checkout screen.
- **Screen sync**
  - `GET /store/cart`

## `StoreCheckoutScreen`

- **Confirm Order**
  - Step 1: `POST /store/addresses`
  - Step 2: `POST /store/orders`
  - On success app clears cart with `DELETE /store/cart/clear`.

## `OrdersScreen`

- **Screen load**
  - `GET /store/orders`
- **Mark order as received** (purchase)
  - `POST /store/orders/{orderId}/mark-received`
- **Mark rental as received** (rental)
  - `POST /store/rentals/{rentalId}/mark-received`

---

## 4) Request/Response Contracts

## 4.1 Categories

### Request

`GET /store/categories`

### Response

```json
{
  "success": true,
  "data": {
    "categories": [
      {
        "id": "cat_implants",
        "name": "Implant Systems",
        "name_ar": "أنظمة الزرعات",
        "brand": "B&B Dental",
        "origin": "Italy",
        "icon_name": "category",
        "subcategories": ["Straight", "Tapered"],
        "subcategories_ar": ["مستقيم", "مخروطي"]
      }
    ]
  }
}
```

---

## 4.2 Products List

### Request

`GET /store/products?page=1&per_page=20&search=&category_id=&subcategory=&brand=&sort=`

### Response

```json
{
  "success": true,
  "data": {
    "products": [
      {
        "id": "prod_1",
        "name": "B&B Implant System",
        "name_ar": "نظام زرعات بي آند بي",
        "title": "B&B Implant System",
        "title_ar": "نظام زرعات بي آند بي",
        "description": "High performance implant",
        "description_ar": "زرعة عالية الأداء",
        "price": 4500,
        "rental_price": 900,
        "image_url": "https://cdn.medex.com/store/prod_1.jpg",
        "image": "uploads/store/prod_1.jpg",
        "thumbnail": "uploads/store/prod_1_thumb.jpg",
        "category": "Implant Systems",
        "category_ar": "أنظمة الزرعات",
        "brand": "B&B Dental",
        "origin": "Italy",
        "is_available": true,
        "is_rentable": true,
        "discount": 10
      }
    ],
    "meta": {
      "page": 1,
      "per_page": 20,
      "total": 120,
      "total_pages": 6
    }
  }
}
```

---

## 4.3 Cart Read

### Request

`GET /store/cart`

### Response

```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "cart_item_1",
        "product_id": "prod_1",
        "name": "B&B Implant System",
        "name_ar": "نظام زرعات بي آند بي",
        "description": "High performance implant",
        "description_ar": "زرعة عالية الأداء",
        "price": 4500,
        "rental_price": 900,
        "image_url": "https://cdn.medex.com/store/prod_1.jpg",
        "category": "Implant Systems",
        "category_ar": "أنظمة الزرعات",
        "brand": "B&B Dental",
        "origin": "Italy",
        "is_rentable": true,
        "is_rental": false,
        "discount": 10,
        "quantity": 2
      }
    ],
    "summary": {
      "items_count": 2,
      "subtotal": 9000,
      "shipping": 0,
      "total": 9000
    }
  }
}
```

---

## 4.4 Cart Add

### Request

`POST /store/cart/items`

```json
{
  "product_id": "prod_1",
  "quantity": 1,
  "is_rental": false
}
```

### Response

```json
{
  "success": true,
  "message": "Item added to cart",
  "data": {
    "id": "cart_item_1"
  }
}
```

---

## 4.5 Cart Update Quantity

### Request

`PATCH /store/cart/items/{itemId}`

```json
{
  "quantity": 3
}
```

### Response

```json
{
  "success": true,
  "message": "Cart item updated",
  "data": {
    "id": "cart_item_1",
    "quantity": 3
  }
}
```

---

## 4.6 Cart Remove Item

### Request

`DELETE /store/cart/items/{itemId}`

### Response

```json
{
  "success": true,
  "message": "Cart item removed",
  "data": {}
}
```

---

## 4.7 Cart Clear

### Request

`DELETE /store/cart/clear`

### Response

```json
{
  "success": true,
  "message": "Cart cleared",
  "data": {}
}
```

---

## 4.8 Create Address (Checkout Step 1)

### Request

`POST /store/addresses`

```json
{
  "label": "Checkout",
  "full_name": "Dr. Ahmed",
  "phone": "+201000000000",
  "country": "EG",
  "city": "Giza",
  "area": "Dokki",
  "street": "123 Main St",
  "building": "B1",
  "floor": "3",
  "apartment": "12",
  "postal_code": "12345",
  "is_default": false
}
```

### Response

```json
{
  "success": true,
  "message": "Address created",
  "data": {
    "id": "addr_1"
  }
}
```

---

## 4.9 Create Order (Checkout Step 2)

### Request

`POST /store/orders`

```json
{
  "address_id": "addr_1",
  "shipping_method_id": "standard",
  "payment_method": "cash_on_delivery",
  "payment_token": null,
  "notes": "Call before delivery"
}
```

> For card/wallet, app currently sends `payment_token: "app_generated_token"` placeholder. Backend team can enforce real token integration later.

### Response

```json
{
  "success": true,
  "message": "Order created successfully",
  "data": {
    "id": "order_1",
    "status": "PENDING",
    "status_ar": "قيد الانتظار",
    "total": 9000,
    "items": [
      {
        "product": {
          "id": "prod_1",
          "name": "B&B Implant System",
          "name_ar": "نظام زرعات بي آند بي",
          "image_url": "https://cdn.medex.com/store/prod_1.jpg"
        },
        "quantity": 2,
        "is_rental": false
      }
    ],
    "shipping_address": "123 Main St, Giza",
    "created_at": "2026-04-25T12:00:00Z"
  }
}
```

---

## 4.10 Orders List

### Request

`GET /store/orders?page=1&per_page=20`

### Response

```json
{
  "success": true,
  "data": {
    "orders": [
      {
        "id": "order_1",
        "status": "SHIPPED",
        "status_ar": "تم الشحن",
        "total": 9000,
        "shipping_address": "123 Main St, Giza",
        "created_at": "2026-04-25T12:00:00Z",
        "is_rental": false,
        "items": [
          {
            "product": {
              "id": "prod_1",
              "name": "B&B Implant System",
              "name_ar": "نظام زرعات بي آند بي",
              "image_url": "https://cdn.medex.com/store/prod_1.jpg"
            },
            "quantity": 2,
            "is_rental": false
          }
        ]
      }
    ],
    "meta": {
      "page": 1,
      "per_page": 20,
      "total": 6,
      "total_pages": 1
    }
  }
}
```

---

## 4.11 Mark Received (Purchase)

### Request

`POST /store/orders/{orderId}/mark-received`

```json
{}
```

### Response

```json
{
  "success": true,
  "message": "Order marked as delivered",
  "data": {
    "id": "order_1",
    "status": "DELIVERED",
    "status_ar": "تم التسليم",
    "total": 9000,
    "created_at": "2026-04-25T12:00:00Z",
    "items": []
  }
}
```

`items` may be omitted/empty; app already merges existing line items safely.

---

## 4.12 Mark Received (Rental)

### Request

`POST /store/rentals/{rentalId}/mark-received`

```json
{}
```

### Response

```json
{
  "success": true,
  "message": "Rental marked as received",
  "data": {
    "id": "rental_1",
    "status": "DELIVERED",
    "status_ar": "تم التسليم",
    "total": 1200,
    "created_at": "2026-04-25T12:00:00Z",
    "is_rental": true
  }
}
```

---

## 5) Validation Checklist (Backend)

- [ ] `GET /store/categories` returns `data.categories` array
- [ ] `GET /store/products` supports filters used by app (`search`, `category_id`, `subcategory`, `brand`, `sort`, `page`, `per_page`)
- [ ] cart endpoints support add/update/delete/clear with stable `cart item id`
- [ ] `POST /store/addresses` returns address `id`
- [ ] `POST /store/orders` accepts checkout payload and creates order from server cart
- [ ] `GET /store/orders` returns list under `data.orders`
- [ ] mark-received endpoints work for purchase and rental
- [ ] all responses keep `success/message/data` envelope
- [ ] Arabic and English text fields exist where applicable (`name_ar`, `description_ar`, `category_ar`, `status_ar`)

---

## 6) Important Current Notes

- Some store UI sections still use local sample data for display in specific screens, but cart/checkout/orders APIs are already live-wired.
- This contract is designed so backend can be applied immediately without breaking current app behavior.
- If backend wants full dynamic store homepage content (rail brands, featured products, category cards) from API, we can add a dedicated `/store/home` contract in a follow-up file.
