# Phân Rã Màn Hình — VieGym

> Phân rã các màn hình chính của ứng dụng mobile VieGym và khu vực admin.

---

## 1. Sitemap Mobile App

```text
VieGym Mobile
├── Splash / Onboarding
├── Auth
│   ├── Login
│   ├── Register
│   ├── Forgot Password
│   └── OTP / Reset Password
├── Health Onboarding
│   └── Health Profile Form
├── Main Tabs
│   ├── Dashboard
│   ├── Workout
│   ├── Meal Planner
│   ├── AI Coach
│   └── Shop
└── Profile
    ├── Personal Info
    ├── Weight History
    ├── Orders
    ├── Notification Settings
    └── Change Password
```

---

## 2. Auth Screens

| Mã | Màn hình | Nội dung chính |
|---|---|---|
| MH01 | Splash / Onboarding | Giới thiệu VieGym, CTA đăng nhập/đăng ký |
| MH02 | Login | Email, password, Google Login, quên mật khẩu |
| MH03 | Register | Họ tên, email, password, confirm password |
| MH04 | Forgot Password / OTP / Reset | Gửi OTP, xác thực OTP, đặt mật khẩu mới |

---

## 3. Health & Dashboard Screens

| Mã | Màn hình | Nội dung chính |
|---|---|---|
| MH05 | Health Profile Form | Giới tính, tuổi, chiều cao, cân nặng, activity, goal |
| MH06 | Weight History | Nhập cân nặng, biểu đồ, tiến độ mục tiêu |
| MH07 | User Dashboard | Calories, macro, lịch tập hôm nay, cân nặng, tiến độ, gợi ý AI |

---

## 4. Workout Screens

| Mã | Màn hình | Nội dung chính |
|---|---|---|
| MH08 | Exercise Library | Search/filter bài tập theo nhóm cơ, thiết bị, độ khó |
| MH09 | Exercise Detail | Video/GIF, hướng dẫn, lỗi thường gặp |
| MH10 | Workout Builder | Template/custom program, sets, reps, rest |
| MH11 | Workout Calendar | Lịch tuần/tháng, tạo/sửa/hoàn thành/hủy |
| MH12 | Workout Logging | Nhập bài tập, sets, reps, kg, ghi chú |
| MH13 | Workout Progress | Tổng buổi tập, PR, biểu đồ volume/mức tạ/reps |

---

## 5. Meal Planner Screens

| Mã | Màn hình | Nội dung chính |
|---|---|---|
| MH14 | Meal Planner Today | Bữa sáng/trưa/tối/phụ, tổng calories/macro, cảnh báo |
| MH15 | Food Search | Tìm món ăn Việt Nam, filter danh mục, add to meal |
| MH16 | Food Detail | Ảnh, khẩu phần, calories, protein/carb/fat, thành phần |

---

## 6. AI Screens

| Mã | Màn hình | Nội dung chính |
|---|---|---|
| MH17 | AI Coach Chat | Chat tư vấn luyện tập/dinh dưỡng, quick prompts, cảnh báo an toàn |
| MH18 | Sales Chatbot | Chat tư vấn sản phẩm, gợi ý sản phẩm, thêm giỏ |

---

## 7. Shop Screens

| Mã | Màn hình | Nội dung chính |
|---|---|---|
| MH19 | Product List | Danh mục, search/filter, card sản phẩm |
| MH20 | Product Detail | Ảnh, tên, thương hiệu, giá, mô tả, cách dùng |
| MH21 | Cart | Items, cập nhật số lượng, tổng tiền, checkout |
| MH22 | Checkout | Địa chỉ, SĐT, thanh toán, xác nhận đặt hàng |
| MH23 | Order History / Detail | Danh sách đơn, trạng thái, chi tiết, tổng tiền |

---

## 8. Profile Screens

| Mã | Màn hình | Nội dung chính |
|---|---|---|
| MH24 | Profile | Avatar, họ tên/email, điều hướng cài đặt |
| MH25 | Notification Settings | Bật/tắt nhắc lịch tập, cân nặng, meal, đơn hàng, AI |

---

## 9. Admin Screens

Nếu có web/admin hoặc mobile admin:

- Admin Dashboard.
- User Management.
- Exercise Management.
- Food Management / Import Food.
- Product Management.
- Order Management.
- Audit Logs.
