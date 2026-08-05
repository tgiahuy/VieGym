# Project Rules — VieGym

> Quy tắc phát triển cho dự án VieGym. Đây là tài liệu định hướng coding convention, module boundary và nguyên tắc thiết kế.

---

## 1. Tổng quan dự án

| Thuộc tính | Giá trị |
|---|---|
| Tên dự án | VieGym |
| Mục tiêu | Ứng dụng mobile hỗ trợ luyện tập, dinh dưỡng, theo dõi sức khỏe, AI Coach và mua sắm sản phẩm gym |
| Người dùng chính | Người tập gym Việt Nam |
| Actors | Guest, User, Admin, AI Service, Payment Provider |
| Mobile | Flutter + Riverpod |
| Backend | Spring Boot + Spring Security + JWT |
| Database | MySQL |
| AI | Python FastAPI + OpenAI/Gemini |

---

## 2. Nguyên tắc sản phẩm

- Ưu tiên trải nghiệm tiếng Việt rõ ràng, dễ hiểu cho người mới tập.
- Dữ liệu món ăn Việt Nam là điểm khác biệt chính, không phụ thuộc hoàn toàn API dinh dưỡng bên ngoài.
- AI Coach là trợ lý luyện tập/dinh dưỡng, không thay thế bác sĩ hoặc chuyên gia y tế.
- Mọi dữ liệu cá nhân của user phải được cô lập theo tài khoản.
- MVP ưu tiên chạy được end-to-end hơn là làm quá nhiều tính năng nâng cao.

---

## 3. Backend package rules

Root package: `com.viegym`.

```text
common/
identity/
health/
workout/
nutrition/
shop/
ai/
notification/
dashboard/
audit/
```

Rules:

- Mỗi phân hệ có controller, service, entity, repository, dto, mapper nếu cần.
- DTO của module nằm trong module đó; `common/dto` chỉ chứa `ApiResponse`, `PageResponse`.
- Business logic nằm trong service, không đặt trong controller.
- Repository chỉ truy vấn dữ liệu, không chứa logic nghiệp vụ phức tạp.
- API private phải kiểm tra current user hoặc role admin ở backend.

---

## 4. Naming conventions

| Loại | Pattern | Ví dụ |
|---|---|---|
| Entity | PascalCase | User, HealthProfile, WorkoutProgram |
| Controller | FeatureController | AuthController, FoodController |
| Service | FeatureService | MealPlanService, AiCoachService |
| Repository | FeatureRepository | UserRepository |
| Request DTO | ActionRequest | LoginRequest, CreateOrderRequest |
| Response DTO | FeatureResponse | ProductResponse |
| Enum | PascalCase | FitnessGoal, MealType |

Variables/methods dùng `camelCase`; constants dùng `UPPER_SNAKE_CASE`.

---

## 5. API rules

- Base path: `/api/v1`.
- Response thống nhất bằng `ApiResponse<T>`.
- Error response có `code`, `message`, `data = null`.
- Pagination dùng `page` bắt đầu từ 0.
- Không trả password hash, refresh token, OTP hash, API key.
- User không được truyền `userId` để thao tác dữ liệu cá nhân nếu có thể lấy từ JWT.
- Admin endpoints đặt dưới `/admin`.

---

## 6. Security rules

- Password hash bằng BCrypt.
- JWT access token có TTL ngắn.
- Refresh token phải revoke được.
- OTP có TTL và giới hạn số lần thử.
- Backend kiểm tra ownership cho health, workout, meal, cart, order, AI conversation.
- AI Provider API key chỉ nằm ở backend/AI service env.
- File upload validate size, extension và MIME.

---

## 7. Database rules

- MySQL là source of truth.
- Dùng soft delete cho dữ liệu chính nếu cần giữ lịch sử demo.
- Dữ liệu theo user phải có `user_id` và index phù hợp.
- `order_items` và `meal_entries` lưu snapshot dữ liệu quan trọng tại thời điểm tạo.
- Không lưu ảnh/video binary trong DB.

---

## 8. AI rules

- Backend quyết định context gửi sang AI Service.
- AI trả lời bằng tiếng Việt.
- AI không đưa ra chẩn đoán y tế.
- Với chấn thương/bệnh lý/thực phẩm bổ sung, phản hồi phải khuyến nghị hỏi chuyên gia.
- Log lỗi AI provider nhưng không log dữ liệu nhạy cảm không cần thiết.

---

## 9. MVP priority

1. Auth.
2. Health profile + BMI/BMR/TDEE.
3. Dashboard.
4. Exercise library.
5. Workout program/schedule/log.
6. Vietnamese food database + Meal Planner.
7. AI Coach basic chat.
8. Shop product/cart/order.
9. Admin management.
10. Docker Compose demo.
