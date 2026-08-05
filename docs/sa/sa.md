# System Architecture — VieGym

> Kiến trúc hệ thống tổng quan và chi tiết cho ứng dụng VieGym.

---

## 1. High-Level Architecture

```text
┌──────────────────────┐
│ Flutter Mobile App   │
│ Android / iOS later  │
└──────────┬───────────┘
           │ HTTPS REST API
           ▼
┌──────────────────────┐
│ Spring Boot Backend  │
│ Auth + Business API  │
└───┬────────┬─────┬───┘
    │        │     │
    ▼        ▼     ▼
┌───────┐ ┌─────┐ ┌─────────────────┐
│ MySQL │ │Redis│ │ MinIO / S3      │
│ DB    │ │Cache│ │ Media Storage   │
└───────┘ └─────┘ └─────────────────┘
    │
    │ Context request
    ▼
┌──────────────────────┐
│ Python FastAPI       │
│ AI Service           │
└──────────┬───────────┘
           ▼
┌──────────────────────┐
│ OpenAI / Gemini API  │
└──────────────────────┘
```

---

## 2. Main Components

### Flutter Mobile App

- Hiển thị giao diện tiếng Việt.
- Quản lý state bằng Riverpod.
- Gọi REST API qua HTTPS.
- Hiển thị dashboard, biểu đồ, lịch tập, meal planner, shop, chat AI.
- Lưu token bằng cơ chế an toàn phía mobile.

### Spring Boot Backend

- Xác thực JWT và phân quyền User/Admin.
- Quản lý nghiệp vụ chính: user, health, workout, nutrition, shop, notification.
- Tính BMI/BMR/TDEE/calories/macro mục tiêu.
- Tổng hợp dashboard.
- Gửi context cần thiết sang AI Service.
- Ký URL hoặc quản lý media qua object storage.

### MySQL

- Source of truth cho dữ liệu nghiệp vụ.
- Lưu thông tin user, hồ sơ sức khỏe, bài tập, món ăn, meal plan, đơn hàng, AI history.

### Redis

- Cache dữ liệu ngắn hạn.
- Lưu OTP tạm thời nếu không lưu DB.
- Rate limit AI/chat/auth nếu cần.

### Object Storage

- Lưu avatar.
- Lưu ảnh món ăn.
- Lưu ảnh sản phẩm.
- Lưu video/GIF minh họa bài tập.

### AI Service

- Tách logic prompt/context khỏi backend chính.
- Đóng gói adapter gọi OpenAI hoặc Gemini.
- Trả response tiếng Việt theo guardrail.

---

## 3. Domain Architecture

```text
Identity Domain
├── User
├── RefreshToken
└── OtpCode

Health Domain
├── HealthProfile
├── WeightLog
└── NutritionTarget

Workout Domain
├── Exercise
├── MuscleGroup
├── Equipment
├── WorkoutProgram
├── WorkoutSchedule
└── WorkoutLog

Nutrition Domain
├── Food
├── FoodCategory
├── MealPlan
└── MealEntry

Shop Domain
├── Product
├── ProductCategory
├── Cart
├── Order
└── Payment

AI Domain
├── AiConversation
├── AiMessage
└── AiRecommendation
```

---

## 4. Key Flows

### 4.1. Onboarding & Health Profile

```text
Register/Login
  ↓
Create health profile
  ↓
Backend calculates BMI/BMR/TDEE
  ↓
Persist target calories/macros
  ↓
Dashboard becomes available
```

### 4.2. Meal Planner

```text
Open today's meal plan
  ↓
Search Vietnamese food database
  ↓
Add food to breakfast/lunch/dinner/snack
  ↓
Backend calculates daily total calories/macros
  ↓
Dashboard compares actual vs target
  ↓
AI Coach can suggest changes
```

### 4.3. Workout

```text
Choose/create workout program
  ↓
Generate workout schedule
  ↓
Complete workout session
  ↓
Log exercises, sets, reps, weight
  ↓
Update PR/progress stats
```

### 4.4. AI Coach

```text
User sends message
  ↓
Backend verifies auth and loads allowed context
  ↓
Backend calls FastAPI AI Service
  ↓
AI Service builds prompt and calls provider
  ↓
Response persisted and returned to mobile app
```

### 4.5. Shop Checkout

```text
Browse products
  ↓
Add to cart
  ↓
Create order from cart
  ↓
Snapshot product price/name into order items
  ↓
Payment COD/online
  ↓
Admin updates order status
```

---

## 5. Security Architecture

- JWT access token for private APIs.
- Refresh token can be revoked.
- Password hash with BCrypt.
- User data isolation by ownership check.
- Admin endpoints require role ADMIN.
- AI Provider API key only exists in backend/AI service environment.
- Media upload validates MIME/extension/size.

---

## 6. Scalability Direction

MVP chạy đơn giản bằng Docker Compose. Khi mở rộng startup:

- Tách backend API thành nhiều instance.
- Tách AI Service scale riêng.
- Dùng managed MySQL và object storage production.
- Bổ sung queue cho notification, email, import dữ liệu món ăn.
- Bổ sung analytics service nếu dashboard nặng.
