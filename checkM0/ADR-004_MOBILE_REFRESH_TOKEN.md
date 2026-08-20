# ADR-004 — Lưu và truyền refresh token trên Mobile

- **Trạng thái:** ACCEPTED
- **Ngày áp dụng:** 2026-08-19
- **Owner:** Mobile/Identity Backend
- **Phạm vi:** MVP P0

## Bối cảnh

Mobile cần duy trì phiên nhưng phải giảm thiệt hại khi token bị lộ và xử lý refresh đồng thời ổn định.

## Quyết định

Access token chỉ giữ trong bộ nhớ, TTL 15 phút và truyền bằng `Authorization: Bearer`. Refresh token opaque chỉ lưu bằng `flutter_secure_storage` (Android Keystore-backed), không lưu trong SharedPreferences, log, analytics hay state có thể serialize.

Dio interceptor thực hiện refresh single-flight khi nhận lỗi access token hết hạn. Backend rotate refresh token ở mỗi lần dùng; lưu hash, gắn device/session và token family. Phát hiện reuse token đã rotate thì revoke cả family. Logout revoke server-side trước, sau đó luôn xóa credential local. Biometric chỉ mở credential local, không thay thế xác thực server.

## Phương án đã cân nhắc

- Lưu cả hai token trong SharedPreferences: loại vì không phải secure storage.
- Access token dài hạn: loại vì tăng cửa sổ rủi ro.
- Cookie HttpOnly: phù hợp web hơn; không chọn cho Flutter native API client P0.

## Hệ quả và rollback

Cần test cold start, refresh đồng thời, refresh bị revoke và logout khi offline. Nếu secure storage lỗi/không đọc được, clear session và yêu cầu đăng nhập lại.

