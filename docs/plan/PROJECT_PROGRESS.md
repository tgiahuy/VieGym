# Theo dõi tiến độ triển khai dự án VieGym

File này dùng để theo dõi tiến độ triển khai theo kế hoạch 6 tháng. Khi hoàn thành một công việc, đổi `[ ]` thành `[x]` và cập nhật ghi chú nếu cần.

## Quy ước trạng thái

- `[ ]` Chưa làm
- `[x]` Hoàn thành
- `Ghi chú:` mô tả ngắn kết quả, blocker hoặc quyết định liên quan

---

## Tháng 1 — Phân tích, thiết kế và chuẩn bị

- [ ] Khảo sát các ứng dụng tương tự về gym, dinh dưỡng và AI Coach
- [ ] Chốt phạm vi MVP từ SRS
- [ ] Thiết kế UI/UX trên Figma
- [ ] Thiết kế Use Case Diagram
- [ ] Thiết kế ERD
- [ ] Thiết kế kiến trúc hệ thống
- [ ] Chuẩn hóa tài liệu specs/docs theo VieGym
    - Ghi chú: `spec/specs.md` và bộ docs chính đã được viết lại theo hướng VieGym.
- [ ] Khởi tạo repository GitHub
    - Ghi chú: Repository đã init và push README lên remote main.

---

## Tháng 2 — Backend core

### Auth & Identity

- [ ] Tạo Spring Boot backend project
- [ ] Cấu hình MySQL, JPA và migration
- [ ] Tạo module `identity`
- [ ] Tạo bảng `users`, `refresh_tokens`, `otp_codes`
- [ ] Triển khai đăng ký
- [ ] Triển khai đăng nhập email/password
- [ ] Triển khai Google Login
- [ ] Triển khai JWT access token
- [ ] Triển khai refresh token
- [ ] Triển khai quên mật khẩu, OTP, reset password
- [ ] Triển khai đổi mật khẩu
- [ ] Triển khai profile cá nhân

### Health

- [ ] Tạo module `health`
- [ ] Tạo bảng `health_profiles`
- [ ] Tạo bảng `weight_logs`
- [ ] Triển khai API hồ sơ sức khỏe
- [ ] Tính BMI
- [ ] Tính BMR theo Mifflin-St Jeor
- [ ] Tính TDEE theo activity factor
- [ ] Tính calories/macro mục tiêu
- [ ] Triển khai API lịch sử cân nặng

### Master data MVP

- [ ] Tạo module `workout`
- [ ] Tạo bảng muscle groups, equipments, exercises
- [ ] Tạo API danh sách/chi tiết bài tập
- [ ] Tạo module `nutrition`
- [ ] Tạo bảng food categories, foods
- [ ] Tạo API tìm kiếm/lọc món ăn
- [ ] Seed dữ liệu bài tập mẫu
- [ ] Seed/import dữ liệu món ăn Việt Nam mẫu

---

## Tháng 3 — Flutter App và workout core

### Flutter foundation

- [ ] Tạo Flutter project
- [ ] Cấu hình Riverpod
- [ ] Cấu hình routing
- [ ] Cấu hình API client
- [ ] Cấu hình theme tiếng Việt
- [ ] Xây màn onboarding/login/register
- [ ] Kết nối auth API

### Health & Dashboard UI

- [ ] Xây màn hồ sơ sức khỏe
- [ ] Xây màn nhập/cập nhật cân nặng
- [ ] Xây dashboard calories/macro/lịch tập/cân nặng
- [ ] Hiển thị biểu đồ cân nặng

### Workout UI

- [ ] Xây màn thư viện bài tập
- [ ] Xây màn chi tiết bài tập
- [ ] Xây Workout Builder
- [ ] Xây lịch tập tuần/tháng
- [ ] Xây màn ghi nhận buổi tập
- [ ] Kết nối workout API

---

## Tháng 4 — Meal Planner, AI Coach và thống kê

### Meal Planner

- [ ] Hoàn thiện API meal plan
- [ ] Tạo bảng meal_plans và meal_entries
- [ ] Tính tổng calories/protein/carb/fat theo ngày
- [ ] Cảnh báo vượt/thiếu calories
- [ ] Gợi ý món ăn phù hợp macro
- [ ] Xây màn Meal Planner Flutter
- [ ] Xây màn tìm kiếm món ăn Việt Nam
- [ ] Kết nối meal planner với dashboard

### AI Coach

- [ ] Tạo Python FastAPI AI Service
- [ ] Tạo module `ai` trong backend
- [ ] Thiết kế prompt AI Coach tiếng Việt
- [ ] Gửi context health/workout/meal sang AI Service
- [ ] Triển khai endpoint `/ai/coach/chat`
- [ ] Lưu hội thoại AI
- [ ] Guardrail cho câu hỏi y tế/chấn thương
- [ ] Xây màn chat AI Coach trên Flutter

### Stats

- [ ] Thống kê tổng buổi tập
- [ ] Thống kê PR
- [ ] Biểu đồ tiến bộ workout
- [ ] Biểu đồ calories/macro theo ngày

---

## Tháng 5 — Cửa hàng, chatbot bán hàng, tối ưu

### Shop

- [ ] Tạo module `shop`
- [ ] Tạo bảng product_categories, products
- [ ] Tạo bảng carts, cart_items
- [ ] Tạo bảng orders, order_items, payments
- [ ] API danh sách/chi tiết sản phẩm
- [ ] API giỏ hàng
- [ ] API tạo đơn hàng
- [ ] API theo dõi đơn hàng
- [ ] API admin cập nhật đơn hàng
- [ ] Xây UI shop/product detail/cart/checkout/order history

### Sales chatbot

- [ ] Thiết kế prompt chatbot bán hàng
- [ ] Endpoint `/ai/sales/chat`
- [ ] Chatbot gợi ý sản phẩm theo mục tiêu/ngân sách
- [ ] Chatbot chỉ gợi ý sản phẩm active/còn hàng

### Hardening MVP

- [ ] Kiểm thử bảo mật auth/JWT
- [ ] Kiểm tra ownership dữ liệu user
- [ ] Tối ưu API đọc phổ biến P95 < 500ms trong demo
- [ ] Tối ưu UI mobile golden path
- [ ] Xử lý lỗi network/loading/empty state

---

## Tháng 6 — Kiểm thử, triển khai và bảo vệ

- [ ] Hoàn thiện Docker Compose backend stack
- [ ] Seed dữ liệu demo đầy đủ: user, bài tập, món ăn, sản phẩm
- [ ] Kiểm thử end-to-end auth → health → dashboard → workout → meal → AI → shop
- [ ] Viết báo cáo đồ án
- [ ] Hoàn thiện tài liệu kỹ thuật
- [ ] Quay video demo
- [ ] Chuẩn bị slide bảo vệ
- [ ] Tổng kiểm thử trước bảo vệ

---

## Hướng phát triển sau đồ án

- [ ] AI nhận diện món ăn từ hình ảnh
- [ ] AI phân tích tư thế tập luyện bằng camera
- [ ] Đồng bộ Apple Health / Google Fit
- [ ] Web dành cho huấn luyện viên
- [ ] Hệ thống quản lý phòng gym
- [ ] ML dự đoán tiến độ và tối ưu lịch tập
- [ ] Marketplace huấn luyện viên/chuyên gia dinh dưỡng
