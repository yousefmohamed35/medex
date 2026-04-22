# Backend requirements: admin approval for new accounts

This document describes what the **Medex mobile app** expects from the backend so that **newly registered users cannot use the app until an administrator approves** the account, and **login is blocked** with a clear signal until approval.

The Flutter app shows an **“account under review”** dialog when it detects a pending account on **register** or **login**.

---

## 1. Business rules

1. On **registration**, new users (at least **students** and **instructors**, unless you scope differently) should be created in a **non-active** state until an admin approves them in the **admin dashboard**.
2. **JWT / session tokens must not be issued** (or must not grant API access) until the account is **approved / active**.
3. **Login** for a user who is not yet approved must **fail** in a way the app can recognize (see sections 3–4).
4. After approval, **login** and **register** responses should behave as today: `success: true`, valid tokens, and user `status` indicating an active account.

---

## 2. Suggested user lifecycle fields

Use a single canonical field the API returns on auth responses, for example:

| Value | Meaning |
|--------|--------|
| `PENDING` / `PENDING_APPROVAL` / `UNDER_REVIEW` | Registered, waiting for admin (app shows “under review” dialog, no session). |
| `ACTIVE` (or `APPROVED`) | Admin approved; issue tokens and allow login. |
| `REJECTED` / `SUSPENDED` | Optional; app may treat as generic error unless you define separate UX. |

**Important:** Return this status in a **consistent** place (see below).

---

## 3. `POST /auth/register` (or your equivalent)

### When registration is accepted but **not** yet approved

- HTTP **200** (or **201**) with JSON, for example:

```json
{
  "success": true,
  "message": "Account pending admin approval",
  "data": {
    "status": "PENDING",
    "user": {
      "id": "uuid",
      "name": "…",
      "email": "…",
      "role": "student",
      "status": "PENDING"
    }
  }
}
```

**Requirements:**

- `success: true` is acceptable **only if** you do **not** include usable `token` / `accessToken` / `refreshToken` in `data` (omit them or send empty strings — the app treats missing tokens + pending status as “under review”).
- Prefer including **`data.status`** and/or **`data.user.status`** with one of the pending values listed in section 2.

### When registration creates an **immediately active** account (if you ever allow that)

- Same as today: `success: true`, `data` includes **non-empty** access + refresh tokens and `user.status` (or `data.status`) indicating **active**.

---

## 4. `POST /auth/login`

The app must be able to detect “valid credentials but **not approved yet**” without issuing a session.

### Option A (recommended): HTTP **403** with structured JSON

```json
{
  "success": false,
  "message": "Your account is under review",
  "error_code": "ACCOUNT_PENDING_APPROVAL",
  "data": {
    "status": "PENDING"
  }
}
```

- **`error_code`**: use a stable machine-readable code; the app recognizes values such as `ACCOUNT_PENDING_APPROVAL`, `USER_PENDING_APPROVAL`, `PENDING_APPROVAL`, or codes containing `PENDING` + `ACCOUNT` / `USER` / `APPROV`.
- **`message`**: human-readable; optional extra line in the dialog if provided.

### Option B: HTTP **200** with `success: true` but **no tokens** and pending status

If you return `success: true` with **`data.user.status`** (or **`data.status`**) set to a pending value and **no** `token` / `accessToken`, the app will treat it as pending approval (same UX as register).

### Avoid

- Returning **200 + valid JWT** for a user who is still pending approval (the app will treat them as logged in).

---

## 5. Admin dashboard / API (for your team)

Document and implement (names are suggestions):

- List users with `status = PENDING` (filters, pagination).
- **Approve** user: set status to `ACTIVE`, optionally send email/push “your account is active”.
- **Reject** user: set status to `REJECTED` and optional reason (app can show generic error until you add dedicated UX).

Ensure approval **invalidates** any stale partial state on the server side and that **tokens issued only after approval** are the only ones that pass `Authorization` checks on protected routes.

---

## 6. Consistency checklist for the mobile team

- [ ] Register: pending users get **no usable tokens**; **`status`** in `data` or `data.user`.
- [ ] Login: pending users get **403 + `error_code`**, or **200 without tokens** + pending **`status`**.
- [ ] `GET /auth/me` (if called with a token): should return **401/403** if someone bypasses the client with an old token; ideally **no token** exists until approved.
- [ ] Social login (`/auth/social-login`): same rules if social sign-up creates a local user record that also requires approval.

---

## 7. Contact

If the backend uses different field names or HTTP codes, share a **sample JSON** for pending register + pending login; the app can align parsers to your contract.
