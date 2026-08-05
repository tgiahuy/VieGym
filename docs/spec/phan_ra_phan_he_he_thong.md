# Phân Rã Phân Hệ Hệ Thống — VieGym

> Mô tả các phân hệ chính của VieGym và quan hệ phụ thuộc giữa chúng.

---

## 1. Tổng quan phân hệ

VieGym gồm 9 phân hệ backend chính:

```text
VieGym System
├── Identity & Auth
├── Health Profile
├── Workout
├── Nutrition / Meal Planner
├── AI Coach
├── Shop
├── Notification
├── Dashboard
└── Admin / Audit
```

---

## 2. Identity & Auth

Chức năng: đăng ký, đăng nhập, Google Login, JWT, refresh token, OTP, đổi mật khẩu, profile cá nhân.

Entity chính: User, RefreshToken, OtpCode.

Phụ thuộc: được tất cả phân hệ khác dùng để xác định current user.

---

## 3. Health Profile

Chức năng: lưu hồ sơ sức khỏe, tính BMI/BMR/TDEE, calories/macro mục tiêu, lịch sử cân nặng.

Entity chính: HealthProfile, WeightLog, NutritionTarget.

Phụ thuộc: Identity, Nutrition, AI Coach, Dashboard.

---

## 4. Workout

Chức năng: thư viện bài tập, nhóm cơ, thiết bị, Workout Builder, lịch tập, workout log, PR và biểu đồ tiến bộ.

Entity chính: Exercise, MuscleGroup, Equipment, WorkoutProgram, WorkoutDay, WorkoutExercise, WorkoutSchedule, WorkoutLog, WorkoutSetLog.

Phụ thuộc: Identity, Health, AI Coach, Notification.

---

## 5. Nutrition / Meal Planner

Chức năng: cơ sở dữ liệu món ăn Việt Nam, danh mục món ăn, meal plan theo ngày, tính calories/macro, cảnh báo vượt/thiếu mục tiêu.

Entity chính: Food, FoodCategory, MealPlan, MealEntry.

Phụ thuộc: Health, AI Coach, Dashboard.

---

## 6. AI Coach

Chức năng: chat tư vấn luyện tập/dinh dưỡng, gợi ý lịch tập, tư vấn thực đơn, chatbot bán hàng, lưu hội thoại.

Entity chính: AiConversation, AiMessage, AiRecommendation.

Phụ thuộc: Identity, Health, Workout, Nutrition, Shop, FastAPI AI Service.

---

## 7. Shop

Chức năng: sản phẩm, danh mục, giỏ hàng, đặt hàng, thanh toán, theo dõi đơn, admin quản lý đơn.

Entity chính: ProductCategory, Product, Cart, CartItem, Order, OrderItem, Payment, ShippingAddress.

Phụ thuộc: Identity, AI Coach, Notification.

---

## 8. Notification

Chức năng: nhắc lịch tập, cập nhật cân nặng, meal plan, đơn hàng và thông báo gợi ý AI.

Entity chính: Notification, NotificationSetting.

---

## 9. Dashboard

Dashboard User tổng hợp calories, macro, lịch tập, cân nặng và tiến độ. Dashboard Admin tổng hợp user, bài tập, món ăn, sản phẩm, đơn hàng và doanh thu nếu có.

---

## 10. Admin / Audit

Admin quản lý user, exercise, food, product, order và nội dung AI cơ bản. Audit ghi các thao tác quan trọng phục vụ truy vết.
