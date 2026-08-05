# API Specification — VieGym

> API documentation cho ứng dụng VieGym. Designed for OpenAPI 3 / Swagger integration.
>
> Ký hiệu: Public = không cần JWT, Auth = cần JWT, Admin = cần role ADMIN.

---

## 1. Global Standards

### Base URL

```text
Development: http://localhost:8080/api/v1
Production:  https://api.viegym.example.com/api/v1
```

### Authentication

- Access token dùng JWT, gửi qua header `Authorization: Bearer <token>`.
- Refresh token lưu an toàn ở server/client theo thiết kế mobile app.
- Tất cả API cá nhân yêu cầu Auth.
- API quản trị yêu cầu Admin.
- API key của AI Provider không được xuất hiện trong mobile app.

### Response wrapper

```json
{
  "success": true,
  "message": "Operation successful",
  "data": {}
}
```

Pagination:

```json
{
  "success": true,
  "data": {
    "content": [],
    "page": 0,
    "size": 20,
    "totalElements": 100,
    "totalPages": 5
  }
}
```

Error:

```json
{
  "success": false,
  "code": "VALIDATION_ERROR",
  "message": "Invalid request",
  "data": null
}
```

### Common error codes

| Code | Mô tả |
|---|---|
| USER_NOT_FOUND | Không tìm thấy user |
| EMAIL_ALREADY_EXISTS | Email đã tồn tại |
| INVALID_CREDENTIALS | Email hoặc mật khẩu sai |
| TOKEN_EXPIRED | JWT hết hạn |
| ACCESS_DENIED | Không đủ quyền |
| HEALTH_PROFILE_INCOMPLETE | Hồ sơ sức khỏe chưa đủ dữ liệu |
| EXERCISE_NOT_FOUND | Không tìm thấy bài tập |
| WORKOUT_PROGRAM_NOT_FOUND | Không tìm thấy giáo án |
| WORKOUT_SCHEDULE_NOT_FOUND | Không tìm thấy lịch tập |
| FOOD_NOT_FOUND | Không tìm thấy món ăn |
| MEAL_ENTRY_NOT_FOUND | Không tìm thấy món trong thực đơn |
| PRODUCT_NOT_FOUND | Không tìm thấy sản phẩm |
| CART_ITEM_NOT_FOUND | Không tìm thấy sản phẩm trong giỏ |
| ORDER_NOT_FOUND | Không tìm thấy đơn hàng |
| INSUFFICIENT_STOCK | Không đủ tồn kho |
| AI_SERVICE_UNAVAILABLE | Dịch vụ AI không khả dụng |
| PAYMENT_FAILED | Thanh toán thất bại |
| OTP_INVALID | OTP không hợp lệ |
| OTP_EXPIRED | OTP hết hạn |

---

## 2. Auth API

| Method | Endpoint | Access | Mô tả |
|---|---|---|---|
| POST | /auth/register | Public | Đăng ký tài khoản |
| POST | /auth/login | Public | Đăng nhập email/mật khẩu |
| POST | /auth/google | Public | Đăng nhập Google |
| POST | /auth/refresh | Public | Cấp access token mới |
| POST | /auth/logout | Auth | Đăng xuất |
| POST | /auth/forgot-password | Public | Gửi OTP đặt lại mật khẩu |
| POST | /auth/verify-otp | Public | Xác thực OTP |
| POST | /auth/reset-password | Public | Đặt lại mật khẩu |
| POST | /auth/change-password | Auth | Đổi mật khẩu |

### POST /auth/register

Request:

```json
{
  "email": "user@example.com",
  "password": "Password123!",
  "fullName": "Nguyễn Văn A"
}
```

Response:

```json
{
  "success": true,
  "data": {
    "id": 1,
    "email": "user@example.com",
    "fullName": "Nguyễn Văn A",
    "role": "USER"
  }
}
```

### POST /auth/login

Request:

```json
{
  "email": "user@example.com",
  "password": "Password123!"
}
```

Response:

```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOi...",
    "tokenType": "Bearer",
    "expiresIn": 900,
    "user": {
      "id": 1,
      "email": "user@example.com",
      "fullName": "Nguyễn Văn A",
      "role": "USER",
      "avatarUrl": null
    }
  }
}
```

---

## 3. User & Health API

| Method | Endpoint | Access | Mô tả |
|---|---|---|---|
| GET | /users/me | Auth | Thông tin user hiện tại |
| PUT | /users/me | Auth | Cập nhật hồ sơ cá nhân |
| PUT | /users/me/avatar | Auth | Cập nhật ảnh đại diện |
| GET | /health-profile/me | Auth | Lấy hồ sơ sức khỏe |
| PUT | /health-profile/me | Auth | Tạo/cập nhật hồ sơ sức khỏe |
| GET | /health-profile/me/summary | Auth | BMI/BMR/TDEE/calories/macro mục tiêu |
| GET | /weight-logs | Auth | Lịch sử cân nặng |
| POST | /weight-logs | Auth | Thêm/cập nhật cân nặng theo ngày |

### PUT /health-profile/me

```json
{
  "gender": "MALE",
  "birthDate": "2002-05-10",
  "heightCm": 175,
  "weightKg": 70,
  "activityLevel": "MODERATE",
  "goal": "MUSCLE_GAIN",
  "targetWeightKg": 75
}
```

Response:

```json
{
  "success": true,
  "data": {
    "bmi": 22.86,
    "bmr": 1665.5,
    "tdee": 2581.53,
    "targetCalories": 2881,
    "targetProteinGram": 140,
    "targetCarbGram": 360,
    "targetFatGram": 80
  }
}
```

---

## 4. Exercise & Workout API

| Method | Endpoint | Access | Mô tả |
|---|---|---|---|
| GET | /exercises | Auth | Danh sách bài tập, filter theo nhóm cơ/thiết bị/độ khó |
| GET | /exercises/{id} | Auth | Chi tiết bài tập |
| GET | /muscle-groups | Auth | Danh sách nhóm cơ |
| GET | /equipments | Auth | Danh sách thiết bị |
| GET | /workout-programs | Auth | Danh sách giáo án của user |
| POST | /workout-programs | Auth | Tạo giáo án |
| PUT | /workout-programs/{id} | Auth | Cập nhật giáo án |
| DELETE | /workout-programs/{id} | Auth | Xóa mềm giáo án |
| POST | /workout-programs/{id}/activate | Auth | Chọn giáo án đang hoạt động |
| GET | /workout-schedules | Auth | Lấy lịch tập theo ngày/tuần/tháng |
| POST | /workout-schedules | Auth | Tạo lịch tập |
| PUT | /workout-schedules/{id} | Auth | Cập nhật lịch tập |
| PATCH | /workout-schedules/{id}/complete | Auth | Đánh dấu hoàn thành |
| PATCH | /workout-schedules/{id}/cancel | Auth | Hủy buổi tập |
| GET | /workout-logs | Auth | Lịch sử tập luyện |
| POST | /workout-logs | Auth | Ghi nhận buổi tập |
| GET | /workout-stats/summary | Auth | Tổng buổi tập, PR, volume, biểu đồ tiến bộ |

---

## 5. Nutrition & Meal Planner API

| Method | Endpoint | Access | Mô tả |
|---|---|---|---|
| GET | /foods | Auth | Tìm kiếm/lọc món ăn Việt Nam |
| GET | /foods/{id} | Auth | Chi tiết dinh dưỡng món ăn |
| GET | /food-categories | Auth | Danh mục món ăn |
| GET | /meal-plans/today | Auth | Thực đơn hôm nay |
| GET | /meal-plans | Auth | Thực đơn theo ngày |
| POST | /meal-plans/entries | Auth | Thêm món vào bữa |
| PUT | /meal-plans/entries/{id} | Auth | Cập nhật khẩu phần |
| DELETE | /meal-plans/entries/{id} | Auth | Xóa món khỏi bữa |
| GET | /nutrition-targets/me | Auth | Calories/macro mục tiêu |
| PUT | /nutrition-targets/me | Auth | Override mục tiêu dinh dưỡng nếu cần |

### POST /meal-plans/entries

```json
{
  "date": "2026-08-05",
  "mealType": "LUNCH",
  "foodId": 10,
  "servingMultiplier": 1.5
}
```

---

## 6. AI API

| Method | Endpoint | Access | Mô tả |
|---|---|---|---|
| POST | /ai/coach/chat | Auth | Chat với AI Coach |
| POST | /ai/coach/workout-plan | Auth | Tạo gợi ý lịch tập |
| POST | /ai/coach/meal-advice | Auth | Tư vấn thực đơn |
| POST | /ai/sales/chat | Auth | Chatbot tư vấn sản phẩm |
| GET | /ai/conversations | Auth | Danh sách hội thoại AI |
| GET | /ai/conversations/{id}/messages | Auth | Tin nhắn trong hội thoại |

### POST /ai/coach/chat

```json
{
  "conversationId": null,
  "message": "Tôi muốn giảm mỡ nhưng chỉ tập được 3 buổi mỗi tuần",
  "includeHealthContext": true,
  "includeWorkoutContext": true,
  "includeMealContext": true
}
```

Business rules:

- Backend quyết định context nào được gửi sang AI Service.
- AI trả lời tiếng Việt.
- Câu hỏi y tế/chấn thương phải có cảnh báo tham khảo bác sĩ/chuyên gia.

---

## 7. Shop API

| Method | Endpoint | Access | Mô tả |
|---|---|---|---|
| GET | /products | Auth | Danh sách sản phẩm |
| GET | /products/{id} | Auth | Chi tiết sản phẩm |
| GET | /product-categories | Auth | Danh mục sản phẩm |
| GET | /cart | Auth | Giỏ hàng |
| POST | /cart/items | Auth | Thêm sản phẩm vào giỏ |
| PUT | /cart/items/{id} | Auth | Cập nhật số lượng |
| DELETE | /cart/items/{id} | Auth | Xóa khỏi giỏ |
| POST | /orders | Auth | Tạo đơn hàng |
| GET | /orders | Auth | Đơn hàng của user |
| GET | /orders/{id} | Auth | Chi tiết đơn hàng |
| PATCH | /orders/{id}/cancel | Auth | Hủy đơn hàng khi còn cho phép |
| POST | /payments | Auth | Tạo thanh toán |
| POST | /payments/webhook | Public | Webhook từ payment provider |

---

## 8. Dashboard & Notification API

| Method | Endpoint | Access | Mô tả |
|---|---|---|---|
| GET | /dashboard/me | Auth | Dashboard user: calories, macro, lịch tập, cân nặng, tiến độ |
| GET | /notifications | Auth | Danh sách thông báo |
| PATCH | /notifications/{id}/read | Auth | Đánh dấu đã đọc |
| PUT | /notification-settings/me | Auth | Bật/tắt nhắc lịch, meal plan, cân nặng, đơn hàng |

---

## 9. Admin API

| Method | Endpoint | Access | Mô tả |
|---|---|---|---|
| GET | /admin/dashboard | Admin | Thống kê user, bài tập, món ăn, sản phẩm, đơn hàng |
| GET | /admin/users | Admin | Danh sách user |
| PATCH | /admin/users/{id}/status | Admin | Khóa/mở khóa user |
| GET/POST/PUT | /admin/exercises | Admin | Quản lý bài tập |
| GET/POST/PUT | /admin/foods | Admin | Quản lý món ăn |
| POST | /admin/foods/import | Admin | Import dữ liệu món ăn Việt Nam |
| GET/POST/PUT | /admin/products | Admin | Quản lý sản phẩm |
| GET/PUT | /admin/orders | Admin | Quản lý đơn hàng |
| GET | /admin/audit-logs | Admin | Xem audit log |

---

## 10. Shared enums

| Enum | Values |
|---|---|
| Role | USER, ADMIN |
| Gender | MALE, FEMALE, OTHER |
| ActivityLevel | SEDENTARY, LIGHT, MODERATE, ACTIVE, VERY_ACTIVE |
| FitnessGoal | WEIGHT_LOSS, WEIGHT_GAIN, MUSCLE_GAIN, MAINTENANCE |
| Difficulty | BEGINNER, INTERMEDIATE, ADVANCED |
| MealType | BREAKFAST, LUNCH, DINNER, SNACK |
| ScheduleStatus | SCHEDULED, COMPLETED, MISSED, CANCELLED |
| OrderStatus | PENDING, CONFIRMED, PAID, SHIPPING, COMPLETED, CANCELLED, REFUNDED |
| PaymentStatus | PENDING, PAID, FAILED, REFUNDED |
