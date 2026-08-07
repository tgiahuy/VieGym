# Thiết Kế Chi Tiết — VieGym

> Tài liệu thiết kế chi tiết cho VieGym: API conventions, module backend, mobile structure, database domains, AI integration, security và luồng nghiệp vụ chính.

---

## 1. API Conventions

- Base path: `/api/v1`.
- Response JSON thống nhất qua `ApiResponse<T>`.
- Pagination dùng `page`, `size`, `totalElements`, `totalPages`.
- Access token gửi bằng `Authorization: Bearer <token>`.
- API cá nhân phải kiểm tra ownership theo `user_id` ở backend.
- API admin phải kiểm tra role `ADMIN`.

---

## 2. Backend Module Design

Package root đề xuất: `com.viegym`.

```text
com.viegym/
├── ViegymApplication.java
├── common/
│   ├── config/
│   ├── dto/
│   ├── exception/
│   ├── security/
│   └── util/
├── identity/
│   ├── controller/
│   ├── service/
│   ├── entity/
│   ├── repository/
│   ├── dto/
│   └── mapper/
├── health/
├── workout/
├── nutrition/
├── shop/
├── ai/
├── notification/
├── dashboard/
└── audit/
```

### Module responsibilities

| Module | Trách nhiệm |
|---|---|
| common | Response wrapper, exception handling, security config, shared utilities |
| identity | Auth, JWT, refresh token, OTP, user profile, Google Login |
| health | Health profile, BMI/BMR/TDEE, nutrition target, weight log |
| workout | Exercise library, workout program, schedule, workout log, PR/stats |
| nutrition | Food database, food category, meal planner, macro calculation |
| shop | Product, category, cart, order, payment |
| ai | AI Coach, sales chatbot, prompt/context orchestration, conversation history |
| notification | Reminder and app notification settings |
| dashboard | User dashboard and admin dashboard aggregation |
| audit | Audit log for admin/system-sensitive actions |

---

## 3. Flutter App Structure

```text
mobile/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── config/
│   │   ├── network/
│   │   ├── storage/
│   │   ├── theme/
│   │   └── widgets/
│   ├── features/
│   │   ├── auth/
│   │   ├── dashboard/
│   │   ├── health/
│   │   ├── workout/
│   │   ├── nutrition/
│   │   ├── ai_coach/
│   │   ├── shop/
│   │   ├── notification/
│   │   └── profile/
│   └── router/
└── pubspec.yaml
```

### Flutter rules

- Riverpod quản lý state.
- API client tập trung trong `core/network`.
- Mỗi feature có `data`, `domain`, `presentation` nếu cần tách rõ.
- Không lưu access token vào nơi thiếu an toàn nếu có lựa chọn secure storage.
- Giao diện và thông báo mặc định bằng tiếng Việt.

---

## 4. Health Calculation Design

### BMI

```text
BMI = weightKg / (heightM * heightM)
```

### BMR — Mifflin-St Jeor

```text
Nam: BMR = 10 * weightKg + 6.25 * heightCm - 5 * age + 5
Nữ:  BMR = 10 * weightKg + 6.25 * heightCm - 5 * age - 161
```

### TDEE

```text
TDEE = BMR * activityFactor
```

| ActivityLevel | Factor |
|---|---:|
| SEDENTARY | 1.2 |
| LIGHT | 1.375 |
| MODERATE | 1.55 |
| ACTIVE | 1.725 |
| VERY_ACTIVE | 1.9 |

Calories mục tiêu:

| Goal | Rule |
|---|---|
| WEIGHT_LOSS | TDEE - 300 đến 500 kcal |
| WEIGHT_GAIN | TDEE + 300 đến 500 kcal |
| MUSCLE_GAIN | TDEE + 200 đến 400 kcal |
| MAINTENANCE | Gần bằng TDEE |

---

## 5. AI Integration Design

### Runtime architecture

```text
Flutter App
   |
Spring Boot Backend
   | build context, enforce auth, persist conversation
   v
Python FastAPI AI Service
   | prompt template + provider adapter
   v
OpenAI API hoặc Gemini API
```

### Context policy

Backend chỉ gửi context cần thiết:

- Mục tiêu tập luyện.
- BMI/BMR/TDEE/calories/macro mục tiêu.
- Lịch tập hiện tại.
- Workout log gần đây.
- Meal plan hôm nay.
- Sản phẩm đang xem nếu chat bán hàng.

### Guardrails

- AI trả lời bằng tiếng Việt.
- Không chẩn đoán bệnh hoặc thay thế bác sĩ.
- Với chấn thương/bệnh lý/thực phẩm bổ sung nhạy cảm, AI khuyến nghị hỏi chuyên gia.
- Backend giới hạn token, rate limit và log lỗi AI.
- API key AI Provider chỉ nằm ở server-side.

---

## 6. Meal Planner Design

### Flow thêm món

```text
User chọn ngày/bữa
  ↓
Search món ăn Việt Nam
  ↓
Chọn món + khẩu phần
  ↓
Backend tạo meal_entry snapshot calories/macro
  ↓
Dashboard cộng tổng ngày và so sánh mục tiêu
```

Rules:

- Một user có một `meal_plan` cho mỗi ngày.
- `meal_entries` lưu snapshot dinh dưỡng để không bị thay đổi khi admin chỉnh food về sau.
- Tổng calories/macro = tổng entry theo ngày.
- Khi vượt calories hoặc thiếu macro, backend trả warning/suggestion cho UI.
- AI Coach có thể dùng meal plan để tư vấn thay thế/bổ sung món.

---

## 7. Workout Design

### Program flow

```text
Chọn template hoặc custom
  ↓
Tạo workout_program
  ↓
Tạo workout_days
  ↓
Thêm workout_exercises
  ↓
Sinh workout_schedules nếu user chọn lịch tuần
```

### Logging flow

```text
User bắt đầu/hoàn thành buổi tập
  ↓
Tạo workout_log
  ↓
Ghi workout_set_logs
  ↓
Cập nhật schedule COMPLETED
  ↓
Tính lại thống kê PR/progress
```

Rules:

- User chỉ xem/sửa workout data của chính mình.
- Exercise inactive không được thêm mới vào program, nhưng lịch sử cũ vẫn hiển thị được.
- PR có thể tính theo mức tạ lớn nhất hoặc estimated 1RM.

---

## 8. Shop Design

### Order flow

```text
Product list/detail
  ↓
Add to cart
  ↓
Checkout
  ↓
Create order + order_items snapshot
  ↓
Payment COD/online
  ↓
Admin xác nhận/giao hàng
```

Rules:

- `order_items` lưu snapshot tên sản phẩm, giá và số lượng.
- Không cho đặt vượt tồn kho nếu bật quản lý tồn kho realtime.
- User chỉ xem đơn của mình.
- Admin cập nhật trạng thái đơn hàng.

---

## 9. Notification Design

Notification types:

- Nhắc lịch tập.
- Nhắc cập nhật cân nặng.
- Nhắc nhập bữa ăn.
- Cập nhật đơn hàng.
- Gợi ý AI nếu user bật.

Rules:

- User có thể bật/tắt từng loại thông báo.
- Không gửi marketing nếu user chưa đồng ý.
- Notification theo múi giờ người dùng.

---

## 10. Security Design

- JWT cho API private.
- BCrypt cho password.
- OTP có TTL và giới hạn số lần thử.
- Backend kiểm tra ownership cho health, workout, meal, cart, order, AI conversation.
- Admin không được xem password/token.
- File media upload phải validate MIME/extension/size.
- Không đưa secret vào mobile app.

---

## 11. Deployment Design

MVP chạy bằng Docker Compose:

```text
Mobile App / Emulator
        |
        v
Nginx / Backend API: 8080
        |
        ├── PostgreSQL
        ├── Redis
        ├── MinIO
        └── FastAPI AI Service
                └── AI Provider
```

Ưu tiên hoàn thành demo local ổn định trước khi hardening production.
