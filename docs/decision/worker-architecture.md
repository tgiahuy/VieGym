# ADR — Async Jobs & Worker Architecture cho VieGym

> Quyết định kiến trúc cho các tác vụ nền của VieGym.

---

## 1. Bối cảnh

VieGym có một số tác vụ không nhất thiết chạy đồng bộ trong request chính:

- Gửi email/OTP.
- Gửi notification nhắc lịch tập.
- Import dữ liệu món ăn Việt Nam số lượng lớn.
- Xử lý resize ảnh hoặc video thumbnail nếu có.
- Gọi AI Provider có timeout/retry/rate limit.
- Tổng hợp dashboard/statistics định kỳ.

---

## 2. Quyết định cho MVP

MVP ưu tiên đơn giản:

- Dùng Spring Scheduler cho job định kỳ nhẹ.
- Dùng Redis cho cache/rate limit/OTP nếu cần.
- AI call có timeout rõ ràng và fallback lỗi thân thiện.
- Import dữ liệu món ăn có thể chạy bằng admin endpoint hoặc script nội bộ.

Chưa bắt buộc RabbitMQ trong MVP nếu chưa có nhu cầu xử lý nền nặng.

---

## 3. Khi nào cần message queue

Bổ sung RabbitMQ hoặc queue tương đương khi:

- Import food database lớn làm request timeout.
- Notification cần gửi hàng loạt.
- Xử lý media/video nặng.
- AI workload cần retry, rate-limit, hàng đợi và quan sát trạng thái.
- Hệ thống scale nhiều backend instance.

---

## 4. Kiến trúc mở rộng đề xuất

```text
Spring Boot API
  ├── publish job: notification, food-import, media-process, ai-task
  ↓
RabbitMQ / Queue
  ↓
Worker Service
  ├── send notification
  ├── import/normalize foods
  ├── process media
  └── aggregate statistics
```

---

## 5. Job rules

- Job phải idempotent nếu có retry.
- Không đưa dữ liệu nhạy cảm không cần thiết vào message payload.
- Message chỉ nên chứa ID/tham chiếu, worker đọc dữ liệu mới nhất từ DB.
- Job thất bại cần lưu trạng thái lỗi để admin/debug.
- Không để job nền làm hỏng dữ liệu chính nếu thất bại giữa chừng.

---

## 6. Kết luận

Trong đồ án 6 tháng, chưa cần bắt buộc RabbitMQ. Thiết kế module nên đủ sạch để sau này thêm queue/worker mà không phải viết lại toàn bộ business logic.
