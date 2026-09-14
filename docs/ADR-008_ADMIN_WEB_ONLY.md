# ADR-008 — Admin chỉ đăng nhập và vận hành trên Web Admin

> **Trạng thái:** ACCEPTED  
> **Ngày:** 2026-09-14  
> **Phạm vi:** P0 Admin & Audit

## Bối cảnh

Kế hoạch cũ đặt USER và ADMIN trong cùng Flutter Mobile App, chỉ tách route/shell
theo role. Yêu cầu mới là ứng dụng di động chỉ phục vụ USER; ADMIN phải đăng nhập
và thực hiện nghiệp vụ quản trị trên một website riêng biệt.

Việc chỉ ẩn menu Admin trên Mobile không tạo ra boundary bảo mật. Backend phải
phân biệt loại client/session và không cấp phiên ADMIN qua luồng đăng nhập USER.

## Quyết định

1. `mobile/` là Flutter USER App, không chứa Admin route, Admin screen hoặc Admin
   API client.
2. Tạo `admin-web/` bằng React + TypeScript + Vite cho MH58 Admin Login,
   MH45 Admin Shell, MH46 Manage Exercise, MH47 Manage Food và MH51 Audit Log.
3. Luồng `/auth/**` dành cho USER App. Nếu credential hợp lệ thuộc role `ADMIN`,
   Backend trả `403 ADMIN_WEB_ONLY` và không cấp access/refresh token cho Mobile.
4. Web Admin đăng nhập qua `/admin/auth/login`. P0 chỉ hỗ trợ local
   email/password cho tài khoản ADMIN đã được provision; không đăng ký hoặc social
   login trên Web Admin.
5. Phiên Admin dùng cookie `HttpOnly`, `Secure`, `SameSite=Strict`, thời hạn ngắn,
   rotation/revocation và CSRF protection. JavaScript không được đọc token Admin.
6. Admin session/token có audience `ADMIN_WEB`. Mọi `/admin/**` API yêu cầu đồng
   thời account `ACTIVE`, role `ADMIN` và audience `ADMIN_WEB`; token USER/Mobile
   không hợp lệ với Admin API kể cả khi payload bị giả mạo ở client.
7. Web Admin và API dùng HTTPS. CORS chỉ allowlist origin Web Admin theo môi
   trường; CORS không thay thế authentication/authorization.
8. Admin không mặc định được đọc Health, Meal, Workout hoặc AI conversation riêng
   tư của USER. Mutation quan trọng tiếp tục được audit và redact.

## Contract P0

```text
Flutter USER App ── /auth/** ──────────────► USER session (aud=MOBILE_USER)
      ADMIN credential ────────────────────► 403 ADMIN_WEB_ONLY, không cấp token

Web Admin ──────── /admin/auth/login ─────► ADMIN web session (aud=ADMIN_WEB)
Web Admin ──────── /admin/** + CSRF ──────► role + audience + account-status guard
```

Endpoint phiên Admin tối thiểu:

- `POST /api/v1/admin/auth/login`
- `POST /api/v1/admin/auth/refresh`
- `POST /api/v1/admin/auth/logout`
- `GET /api/v1/admin/auth/session`

## Hệ quả

- Web Admin trở thành deliverable P0 và được thêm vào build, CI, Docker Compose,
  smoke test và E2E Admin.
- Flutter bỏ toàn bộ kế hoạch Admin shell/route và không lưu Admin credential.
- Backend Identity dùng chung account store nhưng tách login/session policy theo
  client audience.
- M7 giữ nguyên phạm vi nghiệp vụ Exercise/Food/Audit, nhưng UI được triển khai ở
  `admin-web/` thay vì Flutter.
- P1 vẫn giữ Admin Dashboard, User Management, Import và AI Rule/Prompt.

## Tiêu chí kiểm chứng

- ADMIN đăng nhập tại `/auth/login` nhận `403 ADMIN_WEB_ONLY` và không có token.
- USER đăng nhập tại `/admin/auth/login` nhận lỗi xác thực chung và không có cookie.
- USER token hoặc token sai audience gọi `/admin/**` nhận `403`.
- Admin session cookie có `HttpOnly`, `Secure`, `SameSite=Strict`; mutation thiếu
  hoặc sai CSRF token bị từ chối.
- Web Admin login/logout/refresh, Exercise/Food/Audit và E2E Admin đều có test.
