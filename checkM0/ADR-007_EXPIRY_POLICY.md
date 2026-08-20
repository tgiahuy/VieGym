# ADR-007 — Recommendation và Schedule expiry

- **Trạng thái:** ACCEPTED
- **Ngày áp dụng:** 2026-08-19
- **Owner:** AI/Workout Backend
- **Phạm vi:** MVP P0

## Bối cảnh

Trạng thái hết hạn phải đúng ngay cả khi không có worker/scheduler và khi ứng dụng chỉ chạy một instance cho demo.

## Quyết định

Dùng lazy-on-read/lazy-on-command làm cơ chế authoritative P0; không phụ thuộc scheduler.

- Recommendation `PENDING` có `expires_at`; daily recommendation hết hạn lúc bắt đầu ngày kế tiếp theo timezone IANA của user (fallback `Asia/Ho_Chi_Minh`). Mọi GET/Apply/Dismiss tính effective status; nếu `now >= expires_at`, Backend cập nhật `EXPIRED` idempotently. Apply luôn kiểm tra expiry trong cùng transaction/row lock.
- Workout Schedule `PLANNED` trở thành `MISSED` sau cuối `scheduled_date` cộng grace period cấu hình theo profile timezone, nếu không `COMPLETED`/`CANCELLED` và không có session active. List/detail/start tính effective status và cập nhật `MISSED` idempotently; schedule `MISSED` không được Start. Sau cutoff không cho cancel để loại lịch khỏi completion-rate denominator.
- Database luôn lưu instant UTC; trường local date đi cùng timezone dùng để suy ra boundary. So sánh dùng clock inject được trong test.

Job bảo trì quét bản ghi cũ có thể thêm ở P1 để materialize/reporting, nhưng không quyết định correctness.

## Phương án đã cân nhắc

- Scheduler-only: có cửa sổ sai trạng thái khi job trễ/hỏng và tăng vận hành.
- Chỉ tính trạng thái ảo không persist: query đơn giản nhưng reporting/index dễ lệch.

## Hệ quả và rollback

Repository query cần lọc theo effective state và mutation phải idempotent. Test bắt buộc gồm boundary timezone, grace/cutoff, session active, đúng thời điểm expiry, retry và concurrent Apply/Start.
