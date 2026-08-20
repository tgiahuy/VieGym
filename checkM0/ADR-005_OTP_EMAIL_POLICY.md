# ADR-005 — Email OTP provider và security policy

- **Trạng thái:** ACCEPTED
- **Ngày áp dụng:** 2026-08-19
- **Owner:** Identity Backend
- **Phạm vi:** Register và password reset P0

## Bối cảnh

OTP cần policy chính xác để Backend, Mobile và test dùng cùng contract, đồng thời local/CI không phụ thuộc dịch vụ ngoài.

## Quyết định

Dùng adapter `EmailSender`: fake inbox cho local/test và Resend HTTP API cho production/demo online. OTP gồm 6 chữ số, TTL 10 phút, tối đa 5 lần nhập sai/challenge, cooldown gửi lại 60 giây. Giới hạn gửi: 5 lần/giờ theo email+purpose và 20 lần/giờ theo IP; giới hạn verify: 10 lần/15 phút theo IP ngoài giới hạn của challenge. P0 lưu counter/challenge trong PostgreSQL; Redis không bắt buộc.

Chỉ lưu HMAC-SHA-256 của code với server secret, so sánh constant-time. Resend tạo challenge/code mới và vô hiệu challenge cũ cùng email+purpose. Verify thành công consume một lần. Response request/resend dùng thông báo chung để chống account enumeration và trả `Retry-After` khi cooldown/rate limit xác định được.

## Phương án đã cân nhắc

- SMTP trực tiếp: khó quan sát lỗi/bounce và cấu hình hơn cho demo.
- Redis counter: chưa cần cho một instance MVP; có thể thêm sau.
- OTP sống lâu hoặc không giới hạn attempts: loại vì rủi ro brute-force.

## Hệ quả và rollback

Email delivery cần API key/domain từ môi trường; CI không gọi provider thật. Có thể thay Resend bằng adapter khác mà không đổi API. Policy phải được cấu hình server-side và trả thời điểm/cooldown cho Mobile.

