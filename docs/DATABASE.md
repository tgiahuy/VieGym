# Database Schema — VieGym

> Thiết kế cơ sở dữ liệu mức logic cho VieGym. Database chính dùng MySQL; Redis dùng cho cache/OTP/session ngắn hạn.

---

## 1. Base conventions

Tất cả entity chính nên có:

| Column | Type | Mô tả |
|---|---|---|
| id | BIGINT | Primary key, auto increment |
| created_at | DATETIME | Thời điểm tạo |
| updated_at | DATETIME | Thời điểm cập nhật |
| deleted_at | DATETIME NULL | Soft delete nếu áp dụng |

Quy ước:

- Dữ liệu cá nhân của user phải luôn có `user_id` để kiểm tra ownership.
- Dữ liệu dùng chung do admin quản lý có `status` hoặc `is_active`.
- Ảnh/video/file lưu ở object storage; DB chỉ lưu URL/object key.
- Giá sản phẩm tại thời điểm đặt hàng phải copy vào `order_items`.

---

## 2. Entity Relationship Overview

```text
users 1──1 user_profiles
users 1──1 health_profiles
users 1──N weight_logs
users 1──N workout_programs
users 1──N workout_schedules
users 1──N workout_logs
users 1──N meal_plans
users 1──1 carts
users 1──N orders
users 1──N ai_conversations

exercises N──1 muscle_groups
exercises N──1 equipments
workout_programs 1──N workout_days
workout_days 1──N workout_exercises
workout_logs 1──N workout_set_logs

foods N──1 food_categories
meal_plans 1──N meal_entries
meal_entries N──1 foods

products N──1 product_categories
carts 1──N cart_items
orders 1──N order_items
orders 1──1 payments
```

---

## 3. Identity Domain

### users

| Column | Type | Constraints | Mô tả |
|---|---|---|---|
| id | BIGINT | PK | |
| email | VARCHAR(255) | NOT NULL, UNIQUE | Email đăng nhập |
| password_hash | VARCHAR(255) | NULL | Null nếu chỉ dùng OAuth |
| full_name | VARCHAR(150) | NOT NULL | Họ tên |
| phone | VARCHAR(20) | NULL, UNIQUE | Số điện thoại |
| avatar_url | VARCHAR(500) | NULL | Ảnh đại diện |
| role | VARCHAR(20) | NOT NULL | USER, ADMIN |
| status | VARCHAR(20) | NOT NULL | ACTIVE, INACTIVE, BANNED |
| google_id | VARCHAR(255) | NULL, UNIQUE | Liên kết Google Login |
| last_login_at | DATETIME | NULL | Lần đăng nhập gần nhất |
| created_at | DATETIME | NOT NULL | |
| updated_at | DATETIME | NULL | |
| deleted_at | DATETIME | NULL | Soft delete |

### refresh_tokens

| Column | Type | Constraints | Mô tả |
|---|---|---|---|
| id | BIGINT | PK | |
| user_id | BIGINT | FK users(id) | Chủ sở hữu token |
| token_hash | VARCHAR(255) | NOT NULL, UNIQUE | Hash refresh token |
| expires_at | DATETIME | NOT NULL | Hết hạn |
| revoked_at | DATETIME | NULL | Thu hồi |
| device_info | VARCHAR(255) | NULL | Thiết bị |
| ip_address | VARCHAR(45) | NULL | IP |

### otp_codes

| Column | Type | Constraints | Mô tả |
|---|---|---|---|
| id | BIGINT | PK | |
| email | VARCHAR(255) | NOT NULL | Email nhận OTP |
| code_hash | VARCHAR(255) | NOT NULL | Hash OTP |
| purpose | VARCHAR(50) | NOT NULL | VERIFY_EMAIL, RESET_PASSWORD |
| expires_at | DATETIME | NOT NULL | Hết hạn |
| used_at | DATETIME | NULL | Đã dùng |
| attempt_count | INT | NOT NULL DEFAULT 0 | Số lần thử |

---

## 4. Health Domain

### health_profiles

| Column | Type | Constraints | Mô tả |
|---|---|---|---|
| id | BIGINT | PK | |
| user_id | BIGINT | FK users(id), UNIQUE | User sở hữu |
| gender | VARCHAR(20) | NOT NULL | MALE, FEMALE, OTHER |
| birth_date | DATE | NOT NULL | Ngày sinh |
| height_cm | DECIMAL(5,2) | NOT NULL | Chiều cao |
| weight_kg | DECIMAL(5,2) | NOT NULL | Cân nặng hiện tại |
| activity_level | VARCHAR(30) | NOT NULL | SEDENTARY, LIGHT, MODERATE, ACTIVE, VERY_ACTIVE |
| goal | VARCHAR(30) | NOT NULL | WEIGHT_LOSS, WEIGHT_GAIN, MUSCLE_GAIN, MAINTENANCE |
| target_weight_kg | DECIMAL(5,2) | NULL | Cân nặng mục tiêu |
| bmi | DECIMAL(5,2) | NOT NULL | Tính từ height/weight |
| bmr | DECIMAL(8,2) | NOT NULL | Mifflin-St Jeor |
| tdee | DECIMAL(8,2) | NOT NULL | BMR * activity factor |
| target_calories | INT | NOT NULL | Calories mục tiêu |
| target_protein_g | DECIMAL(8,2) | NOT NULL | Protein mục tiêu |
| target_carb_g | DECIMAL(8,2) | NOT NULL | Carb mục tiêu |
| target_fat_g | DECIMAL(8,2) | NOT NULL | Fat mục tiêu |
| created_at | DATETIME | NOT NULL | |
| updated_at | DATETIME | NULL | |

### weight_logs

| Column | Type | Constraints | Mô tả |
|---|---|---|---|
| id | BIGINT | PK | |
| user_id | BIGINT | FK users(id) | User sở hữu |
| weight_kg | DECIMAL(5,2) | NOT NULL | Cân nặng |
| measured_date | DATE | NOT NULL | Ngày đo |
| note | VARCHAR(500) | NULL | Ghi chú |
| created_at | DATETIME | NOT NULL | |

Unique index: `(user_id, measured_date)`.

---

## 5. Workout Domain

### muscle_groups

| Column | Type | Mô tả |
|---|---|---|
| id | BIGINT | PK |
| name | VARCHAR(100) | Ngực, lưng, vai, tay, chân, bụng... |
| slug | VARCHAR(120) | Unique |
| is_active | BOOLEAN | Trạng thái |

### equipments

| Column | Type | Mô tả |
|---|---|---|
| id | BIGINT | PK |
| name | VARCHAR(100) | Tạ đơn, tạ đòn, máy, bodyweight... |
| slug | VARCHAR(120) | Unique |
| is_active | BOOLEAN | Trạng thái |

### exercises

| Column | Type | Mô tả |
|---|---|---|
| id | BIGINT | PK |
| name | VARCHAR(150) | Tên bài tập |
| slug | VARCHAR(180) | Unique |
| description | TEXT | Mô tả |
| instruction | TEXT | Hướng dẫn |
| common_mistakes | TEXT | Lỗi thường gặp |
| primary_muscle_group_id | BIGINT | FK muscle_groups(id) |
| equipment_id | BIGINT | FK equipments(id) |
| difficulty | VARCHAR(30) | BEGINNER, INTERMEDIATE, ADVANCED |
| video_url | VARCHAR(500) | Video minh họa |
| gif_url | VARCHAR(500) | GIF minh họa |
| is_active | BOOLEAN | Chỉ user thấy active |
| created_at | DATETIME | |
| updated_at | DATETIME | |
| deleted_at | DATETIME | Soft delete |

### workout_programs

| Column | Type | Mô tả |
|---|---|---|
| id | BIGINT | PK |
| user_id | BIGINT | FK users(id) |
| name | VARCHAR(150) | Tên giáo án |
| program_type | VARCHAR(50) | PUSH_PULL_LEGS, UPPER_LOWER, FULL_BODY, CUSTOM |
| goal | VARCHAR(30) | Mục tiêu |
| sessions_per_week | INT | Số buổi/tuần |
| is_active | BOOLEAN | Giáo án đang dùng |
| created_at | DATETIME | |
| updated_at | DATETIME | |
| deleted_at | DATETIME | |

### workout_days

| Column | Type | Mô tả |
|---|---|---|
| id | BIGINT | PK |
| workout_program_id | BIGINT | FK workout_programs(id) |
| day_name | VARCHAR(100) | Push Day, Pull Day... |
| day_order | INT | Thứ tự |

### workout_exercises

| Column | Type | Mô tả |
|---|---|---|
| id | BIGINT | PK |
| workout_day_id | BIGINT | FK workout_days(id) |
| exercise_id | BIGINT | FK exercises(id) |
| sets | INT | Số hiệp |
| reps | VARCHAR(50) | 8-12, 10, AMRAP... |
| rest_seconds | INT | Nghỉ giữa hiệp |
| note | VARCHAR(500) | Ghi chú |
| exercise_order | INT | Thứ tự |

### workout_schedules

| Column | Type | Mô tả |
|---|---|---|
| id | BIGINT | PK |
| user_id | BIGINT | FK users(id) |
| workout_program_id | BIGINT | FK workout_programs(id), NULL |
| scheduled_date | DATE | Ngày tập |
| scheduled_time | TIME | Giờ tập |
| title | VARCHAR(150) | Tên buổi tập |
| status | VARCHAR(30) | SCHEDULED, COMPLETED, MISSED, CANCELLED |
| reminder_enabled | BOOLEAN | Nhắc lịch |
| note | VARCHAR(500) | Ghi chú |

### workout_logs và workout_set_logs

`workout_logs` lưu buổi tập đã thực hiện; `workout_set_logs` lưu từng set gồm reps, weight kg, duration, note.

---

## 6. Nutrition Domain

### food_categories

| Column | Type | Mô tả |
|---|---|---|
| id | BIGINT | PK |
| name | VARCHAR(100) | Cơm, phở/bún/mì, thịt, rau, đồ uống... |
| slug | VARCHAR(120) | Unique |
| is_active | BOOLEAN | Trạng thái |

### foods

| Column | Type | Mô tả |
|---|---|---|
| id | BIGINT | PK |
| food_category_id | BIGINT | FK food_categories(id) |
| name | VARCHAR(150) | Tên món ăn Việt Nam |
| slug | VARCHAR(180) | Unique |
| image_url | VARCHAR(500) | Ảnh món ăn |
| serving_size | DECIMAL(8,2) | Khẩu phần |
| serving_unit | VARCHAR(50) | g, tô, phần, ly... |
| calories | DECIMAL(8,2) | kcal/khẩu phần |
| protein_g | DECIMAL(8,2) | Protein |
| carb_g | DECIMAL(8,2) | Carb |
| fat_g | DECIMAL(8,2) | Fat |
| fiber_g | DECIMAL(8,2) | Chất xơ |
| sodium_mg | DECIMAL(8,2) | Natri |
| ingredients | TEXT | Thành phần |
| is_active | BOOLEAN | Trạng thái |
| created_at | DATETIME | |
| updated_at | DATETIME | |
| deleted_at | DATETIME | |

### meal_plans

| Column | Type | Mô tả |
|---|---|---|
| id | BIGINT | PK |
| user_id | BIGINT | FK users(id) |
| plan_date | DATE | Ngày thực đơn |
| target_calories | INT | Snapshot mục tiêu |
| target_protein_g | DECIMAL(8,2) | Snapshot protein |
| target_carb_g | DECIMAL(8,2) | Snapshot carb |
| target_fat_g | DECIMAL(8,2) | Snapshot fat |

Unique index: `(user_id, plan_date)`.

### meal_entries

| Column | Type | Mô tả |
|---|---|---|
| id | BIGINT | PK |
| meal_plan_id | BIGINT | FK meal_plans(id) |
| food_id | BIGINT | FK foods(id) |
| meal_type | VARCHAR(30) | BREAKFAST, LUNCH, DINNER, SNACK |
| serving_multiplier | DECIMAL(6,2) | Hệ số khẩu phần |
| calories | DECIMAL(8,2) | Snapshot sau nhân khẩu phần |
| protein_g | DECIMAL(8,2) | Snapshot |
| carb_g | DECIMAL(8,2) | Snapshot |
| fat_g | DECIMAL(8,2) | Snapshot |

---

## 7. Shop Domain

### product_categories và products

`product_categories` lưu danh mục như Whey Protein, Creatine, Vitamin, Phụ kiện. `products` lưu tên, thương hiệu, ảnh, mô tả, thành phần, cách dùng, giá, tồn kho, trạng thái active.

### carts và cart_items

Mỗi user có một cart active. `cart_items` gồm product_id, quantity, selected flag và thời điểm thêm.

### orders

| Column | Type | Mô tả |
|---|---|---|
| id | BIGINT | PK |
| user_id | BIGINT | FK users(id) |
| order_code | VARCHAR(50) | Unique |
| status | VARCHAR(30) | PENDING, CONFIRMED, PAID, SHIPPING, COMPLETED, CANCELLED, REFUNDED |
| subtotal_amount | DECIMAL(12,2) | Tạm tính |
| shipping_fee | DECIMAL(12,2) | Phí giao hàng |
| discount_amount | DECIMAL(12,2) | Giảm giá |
| total_amount | DECIMAL(12,2) | Tổng tiền |
| receiver_name | VARCHAR(150) | Người nhận |
| receiver_phone | VARCHAR(20) | SĐT nhận |
| shipping_address | VARCHAR(500) | Địa chỉ |
| note | VARCHAR(500) | Ghi chú |
| created_at | DATETIME | |

### order_items

Lưu snapshot `product_name`, `unit_price`, `quantity`, `total_price` tại thời điểm đặt hàng.

### payments

Lưu provider, amount, status, transaction_ref, paid_at và raw response nếu cần debug.

---

## 8. AI, Notification & Audit Domain

### ai_conversations / ai_messages

Lưu hội thoại AI Coach hoặc chatbot bán hàng. Tin nhắn cần có role `USER`, `ASSISTANT`, `SYSTEM`, nội dung và metadata context tối thiểu.

### ai_recommendations

Lưu các gợi ý AI sinh ra: loại gợi ý `WORKOUT`, `MEAL`, `PRODUCT`, nội dung, liên kết entity nếu có.

### notifications

Lưu notification nhắc lịch tập, meal plan, cân nặng, đơn hàng. Có `read_at` và `delivered_at`.

### audit_logs

Ghi thao tác quan trọng: admin tạo/sửa/xóa bài tập, món ăn, sản phẩm, cập nhật đơn hàng, user đăng nhập, thay đổi hồ sơ.

---

## 9. Index khuyến nghị

- `users.email`, `users.google_id` unique.
- `health_profiles.user_id` unique.
- `weight_logs(user_id, measured_date)` unique.
- `foods(name)`, `foods(food_category_id, is_active)`.
- `exercises(name)`, `exercises(primary_muscle_group_id, equipment_id, difficulty, is_active)`.
- `meal_plans(user_id, plan_date)` unique.
- `workout_schedules(user_id, scheduled_date, status)`.
- `orders(user_id, created_at)`, `orders(order_code)` unique.
- `products(product_category_id, is_active)`, `products(name)`.
