# Phân Rã Tính Năng — VieGym

> Phân rã tính năng theo từng phân hệ của VieGym.

---

## 1. Auth & Account

| Mã | Tính năng | Mô tả |
|---|---|---|
| AUTH-01 | Đăng ký | Tạo tài khoản bằng email/mật khẩu |
| AUTH-02 | Đăng nhập | Xác thực email/mật khẩu |
| AUTH-03 | Google Login | Đăng nhập bằng Google |
| AUTH-04 | Refresh token | Cấp access token mới |
| AUTH-05 | Quên mật khẩu | Gửi OTP đặt lại mật khẩu |
| AUTH-06 | Verify OTP | Xác thực OTP |
| AUTH-07 | Reset password | Đặt lại mật khẩu |
| AUTH-08 | Đổi mật khẩu | Đổi mật khẩu khi đã đăng nhập |
| AUTH-09 | Cập nhật profile | Cập nhật họ tên, ảnh đại diện, số điện thoại |

---

## 2. Health Profile

| Mã | Tính năng | Mô tả |
|---|---|---|
| HEALTH-01 | Nhập hồ sơ sức khỏe | Tuổi, giới tính, chiều cao, cân nặng, activity, goal |
| HEALTH-02 | Tính BMI | Chỉ số khối cơ thể |
| HEALTH-03 | Tính BMR | Mifflin-St Jeor |
| HEALTH-04 | Tính TDEE | BMR * activity factor |
| HEALTH-05 | Tính calories mục tiêu | Theo goal giảm/tăng/duy trì |
| HEALTH-06 | Tính macro mục tiêu | Protein/carb/fat khuyến nghị |
| HEALTH-07 | Weight log | Ghi cân nặng theo ngày |
| HEALTH-08 | Weight chart | Biểu đồ cân nặng và tiến độ |

---

## 3. Workout

| Mã | Tính năng | Mô tả |
|---|---|---|
| WO-01 | Exercise library | Danh sách bài tập |
| WO-02 | Exercise detail | Video/GIF, nhóm cơ, thiết bị, hướng dẫn, lỗi thường gặp |
| WO-03 | Exercise search/filter | Tìm theo tên, nhóm cơ, thiết bị, độ khó |
| WO-04 | Workout template | Push Pull Legs, Upper Lower, Full Body |
| WO-05 | Custom program | User tự tạo giáo án |
| WO-06 | Program editor | Thêm/sửa bài tập, sets, reps, rest |
| WO-07 | Schedule generator | Sinh lịch từ giáo án |
| WO-08 | Calendar view | Xem tuần/tháng |
| WO-09 | Complete workout | Đánh dấu hoàn thành |
| WO-10 | Workout log | Ghi bài tập, sets, reps, kg |
| WO-11 | PR tracking | Theo dõi Personal Record |
| WO-12 | Progress chart | Biểu đồ tiến bộ |

---

## 4. Nutrition / Meal Planner

| Mã | Tính năng | Mô tả |
|---|---|---|
| NUTRI-01 | Food database | Dữ liệu món ăn Việt Nam |
| NUTRI-02 | Food search/filter | Tìm món ăn theo tên/danh mục |
| NUTRI-03 | Food detail | Calories, protein, carb, fat, khẩu phần |
| NUTRI-04 | Daily meal plan | Thực đơn theo ngày |
| NUTRI-05 | Add meal entry | Thêm món vào bữa sáng/trưa/tối/phụ |
| NUTRI-06 | Serving adjustment | Điều chỉnh khẩu phần |
| NUTRI-07 | Macro total | Cộng tổng calories/macro ngày |
| NUTRI-08 | Target comparison | So sánh với mục tiêu cá nhân |
| NUTRI-09 | Warning | Cảnh báo vượt/thiếu calories |
| NUTRI-10 | Food suggestion | Gợi ý món phù hợp |

---

## 5. AI Coach

| Mã | Tính năng | Mô tả |
|---|---|---|
| AI-01 | Coach chat | Chat tiếng Việt về gym/dinh dưỡng |
| AI-02 | Workout advice | Tư vấn lịch tập theo mục tiêu |
| AI-03 | Technique explanation | Giải thích kỹ thuật tập |
| AI-04 | Meal advice | Tư vấn thực đơn theo macro |
| AI-05 | Plan adjustment | Điều chỉnh lịch/thực đơn theo phản hồi |
| AI-06 | Contextual answer | Dựa trên health/workout/meal context |
| AI-07 | Safety guardrail | Cảnh báo khi liên quan y tế/chấn thương |
| AI-08 | Conversation history | Lưu hội thoại |

---

## 6. Shop & Sales Chatbot

| Mã | Tính năng | Mô tả |
|---|---|---|
| SHOP-01 | Product list | Danh sách sản phẩm |
| SHOP-02 | Product detail | Ảnh, giá, mô tả, thành phần, cách dùng |
| SHOP-03 | Product search/filter | Tìm theo tên/danh mục/thương hiệu |
| SHOP-04 | Cart | Thêm/xóa/cập nhật số lượng |
| SHOP-05 | Checkout | Tạo đơn hàng |
| SHOP-06 | Payment | COD hoặc online |
| SHOP-07 | Order tracking | Theo dõi trạng thái đơn |
| SALES-01 | Product advice | Gợi ý sản phẩm theo mục tiêu/ngân sách |

---

## 7. Dashboard & Admin

| Mã | Tính năng | Mô tả |
|---|---|---|
| DASH-01 | User dashboard | Calories, macro, lịch tập, cân nặng, tiến độ |
| DASH-02 | Admin dashboard | Tổng user, bài tập, món ăn, sản phẩm, đơn hàng |
| ADM-01 | User management | Xem/khóa/mở khóa user |
| ADM-02 | Exercise management | CRUD bài tập |
| ADM-03 | Food management | CRUD/import món ăn Việt Nam |
| ADM-04 | Product management | CRUD sản phẩm |
| ADM-05 | Order management | Cập nhật trạng thái đơn |
| ADM-06 | Audit log | Xem thao tác quan trọng |
