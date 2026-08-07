# TÀI LIỆU PHÂN RÃ TÍNH NĂNG HỆ THỐNG

## Dự án: VieGym – Nền tảng hỗ trợ luyện tập và dinh dưỡng tích hợp AI

Phiên bản: 1.0

---

# 1. Giới thiệu

## 1.1 Mục đích

Tài liệu Phân rã tính năng (Feature Breakdown Specification) mô tả chi tiết toàn bộ các tính năng của hệ thống VieGym dựa trên tài liệu Đặc tả yêu cầu phần mềm (SRS) và tài liệu Phân rã phân hệ hệ thống.

Mục tiêu của tài liệu bao gồm:

- Xác định đầy đủ các tính năng của từng phân hệ.
- Làm cơ sở cho việc thiết kế Database.
- Làm cơ sở xây dựng API.
- Hỗ trợ lập kế hoạch phát triển theo Sprint.
- Hỗ trợ kiểm thử và nghiệm thu hệ thống.

---

## 1.2 Phạm vi

Tài liệu mô tả toàn bộ tính năng của các phân hệ:

- Identity & Authentication
- User Profile
- Health Profile
- Dashboard
- Workout
- Meal Planner
- AI Coach
- Shop
- Notification
- Media
- Admin CMS

---

## 1.3 Quy tắc phân rã

Mỗi phân hệ sẽ được phân tích theo cấu trúc thống nhất:

- Mục tiêu
- Danh sách Feature
- Mô tả Feature
- Chức năng chi tiết
- Business Rule
- Input
- Output
- Phụ thuộc
- MVP Scope
- Future Scope

---

# 2. Identity & Authentication

## 2.1 Mục tiêu

Phân hệ Identity & Authentication chịu trách nhiệm quản lý định danh người dùng, xác thực, phân quyền và duy trì phiên đăng nhập an toàn.

---

## 2.2 Danh sách Feature

| ID        | Feature                 | Priority |
| --------- | ----------------------- | -------- |
| FT-ID-001 | Đăng ký tài khoản       | High     |
| FT-ID-002 | Đăng nhập               | High     |
| FT-ID-003 | Đăng xuất               | High     |
| FT-ID-004 | Quên mật khẩu           | High     |
| FT-ID-005 | Đổi mật khẩu            | High     |
| FT-ID-006 | Refresh Token           | High     |
| FT-ID-007 | Quản lý phiên đăng nhập | Medium   |
| FT-ID-008 | Phân quyền người dùng   | High     |

---

## FT-ID-001 Đăng ký tài khoản

### Mục đích

Cho phép người dùng tạo tài khoản mới.

### Chức năng

- Nhập Email
- Nhập Password
- Xác nhận Password
- Kiểm tra Email tồn tại
- Tạo User mới
- Gửi Email xác thực (Future)

### Input

- Email
- Password

### Output

Tài khoản được tạo thành công.

### Business Rule

- Email phải duy nhất.
- Password tối thiểu 8 ký tự.
- Password phải được mã hóa trước khi lưu.

### Dependency

- User
- JWT Service

### MVP

Có

---

## FT-ID-002 Đăng nhập

### Mục đích

Cho phép người dùng truy cập hệ thống.

### Chức năng

- Email Login
- Password Verification
- JWT Generation
- Refresh Token

### Business Rule

- Sai quá 5 lần khóa tài khoản tạm thời.
- JWT có thời hạn.
- Refresh Token được lưu riêng.

---

## FT-ID-003 Đăng xuất

### Chức năng

- Thu hồi Refresh Token
- Xóa Session

---

## FT-ID-004 Quên mật khẩu

### Chức năng

- Gửi OTP
- Xác minh OTP
- Đặt lại Password

Future Scope:

- Email Link
- SMS OTP

---

## FT-ID-005 Đổi mật khẩu

### Chức năng

- Kiểm tra mật khẩu cũ
- Nhập mật khẩu mới
- Xác nhận mật khẩu

---

## FT-ID-006 Refresh Token

### Chức năng

- Gia hạn Access Token
- Kiểm tra Refresh Token

---

## FT-ID-007 Quản lý phiên đăng nhập

### Chức năng

- Danh sách thiết bị
- Đăng xuất thiết bị khác

Future Scope

---

## FT-ID-008 Phân quyền

### Chức năng

- User
- Admin

Business Rule

- User không được truy cập Admin API.

---

# 3. User Profile

## 3.1 Mục tiêu

Quản lý thông tin cá nhân của người dùng phục vụ cá nhân hóa trải nghiệm.

---

## 3.2 Danh sách Feature

| ID        | Feature            |
| --------- | ------------------ |
| FT-UP-001 | Xem hồ sơ          |
| FT-UP-002 | Chỉnh sửa hồ sơ    |
| FT-UP-003 | Avatar             |
| FT-UP-004 | Mục tiêu tập luyện |
| FT-UP-005 | Thiết lập ứng dụng |

---

## FT-UP-001 Hồ sơ cá nhân

### Chức năng

- Họ tên
- Ngày sinh
- Giới tính
- Số điện thoại
- Avatar

---

## FT-UP-002 Chỉnh sửa hồ sơ

### Chức năng

- Cập nhật thông tin
- Upload Avatar
- Thay đổi ảnh đại diện

Business Rule

- Chỉ chủ tài khoản được chỉnh sửa.

---

## FT-UP-003 Avatar

### Chức năng

- Upload
- Crop
- Replace
- Delete

Future Scope

- AI Avatar

---

## FT-UP-004 Mục tiêu luyện tập

### Chức năng

- Giảm cân
- Tăng cân
- Giữ cân
- Tăng cơ

Output

- Đồng bộ với AI Coach
- Đồng bộ Meal Planner

---

## FT-UP-005 Thiết lập

### Chức năng

- Ngôn ngữ
- Theme
- Notification
- Đơn vị đo

---

# 4. Health Profile

## 4.1 Mục tiêu

Lưu trữ các thông số sức khỏe phục vụ tính toán BMI, TDEE và cá nhân hóa hệ thống.

---

## 4.2 Danh sách Feature

| ID        | Feature           |
| --------- | ----------------- |
| FT-HP-001 | Hồ sơ sức khỏe    |
| FT-HP-002 | BMI               |
| FT-HP-003 | TDEE              |
| FT-HP-004 | Mục tiêu Calories |
| FT-HP-005 | Lịch sử cân nặng  |

---

## FT-HP-001 Hồ sơ sức khỏe

### Thông tin

- Chiều cao
- Cân nặng
- Tuổi
- Giới tính
- Activity Level
- Goal

Business Rule

- Chiều cao > 0
- Cân nặng > 0

---

## FT-HP-002 BMI

### Chức năng

- Tính BMI
- Phân loại BMI
- Hiển thị kết quả

Output

- BMI Value
- BMI Category

---

## FT-HP-003 TDEE

### Chức năng

- Tính BMR
- Tính TDEE
- Calories Target

---

## FT-HP-004 Calories Target

### Chức năng

- Calories mỗi ngày
- Protein
- Carb
- Fat

Output

Được Meal Planner sử dụng.

---

## FT-HP-005 Lịch sử cân nặng

### Chức năng

- Ghi nhận cân nặng
- Biểu đồ tiến trình
- So sánh theo tuần
- So sánh theo tháng

Future Scope

- Body Fat
- Muscle Mass
- Body Water
- Smart Scale Integration

# 5. Dashboard

## 5.1 Mục tiêu

Dashboard là màn hình trung tâm của hệ thống VieGym, giúp người dùng theo dõi tổng quan tình trạng sức khỏe, tiến độ luyện tập, dinh dưỡng và các mục tiêu cá nhân.

Dashboard không lưu trữ dữ liệu riêng mà tổng hợp dữ liệu từ nhiều phân hệ khác như Health Profile, Workout, Meal Planner và AI Coach.

---

## 5.2 Danh sách Feature

| ID        | Feature            | Priority |
| --------- | ------------------ | -------- |
| FT-DB-001 | Dashboard Overview | High     |
| FT-DB-002 | Daily Progress     | High     |
| FT-DB-003 | Weekly Statistics  | High     |
| FT-DB-004 | Monthly Statistics | Medium   |
| FT-DB-005 | Goal Progress      | High     |
| FT-DB-006 | AI Suggestion      | Medium   |
| FT-DB-007 | Quick Actions      | Medium   |

---

## FT-DB-001 Dashboard Overview

### Mục đích

Hiển thị tổng quan toàn bộ dữ liệu quan trọng của người dùng khi đăng nhập.

### Chức năng

- Chào mừng người dùng
- Hiển thị Avatar
- Hiển thị Goal hiện tại
- Hiển thị BMI
- Hiển thị TDEE
- Hiển thị Calories còn lại
- Hiển thị Workout hôm nay
- Hiển thị Meal Plan hôm nay

### Input

- User Profile
- Health Profile
- Workout
- Meal Planner

### Output

Dashboard tổng quan.

### Business Rule

- Chỉ hiển thị dữ liệu của ngày hiện tại.
- Nếu chưa có dữ liệu thì hiển thị trạng thái Empty.

---

## FT-DB-002 Daily Progress

### Chức năng

- Calories đã nạp
- Calories đã tiêu hao
- Protein
- Carb
- Fat
- Nước uống
- Workout Completion

### Output

Thanh tiến trình theo ngày.

---

## FT-DB-003 Weekly Statistics

### Chức năng

- Tổng số buổi tập
- Tổng Calories
- Cân nặng
- Thời gian luyện tập

---

## FT-DB-004 Monthly Statistics

### Chức năng

- Biểu đồ cân nặng
- Biểu đồ Calories
- Workout Frequency
- Meal Compliance

Future Scope

---

## FT-DB-005 Goal Progress

### Chức năng

- Tiến độ giảm cân
- Tiến độ tăng cơ
- Tiến độ tăng cân

Output

Progress %

---

## FT-DB-006 AI Suggestion

### Chức năng

Hiển thị gợi ý từ AI dựa trên:

- Workout
- Meal
- Health
- Goal

---

## FT-DB-007 Quick Actions

### Chức năng

- Add Meal
- Start Workout
- Chat AI
- Scan Food (Future)

---

# 6. Workout Module

## 6.1 Mục tiêu

Workout Module hỗ trợ người dùng xây dựng kế hoạch luyện tập, thực hiện các buổi tập và theo dõi tiến trình trong suốt quá trình sử dụng hệ thống.

Đây là phân hệ cốt lõi của VieGym.

---

## 6.2 Danh sách Feature

| ID        | Feature            | Priority |
| --------- | ------------------ | -------- |
| FT-WO-001 | Exercise Library   | High     |
| FT-WO-002 | Exercise Detail    | High     |
| FT-WO-003 | Favorite Exercise  | Medium   |
| FT-WO-004 | Workout Builder    | High     |
| FT-WO-005 | Workout Schedule   | High     |
| FT-WO-006 | Workout Session    | High     |
| FT-WO-007 | Workout Tracking   | High     |
| FT-WO-008 | Workout History    | High     |
| FT-WO-009 | Workout Statistics | Medium   |
| FT-WO-010 | Personal Record    | Medium   |

---

## FT-WO-001 Exercise Library

### Mục đích

Hiển thị toàn bộ thư viện bài tập.

### Chức năng

- Danh sách bài tập
- Search
- Filter
- Sort
- Pagination

### Filter

- Muscle Group
- Difficulty
- Equipment
- Category

### Output

Danh sách bài tập.

---

## FT-WO-002 Exercise Detail

### Chức năng

- Hình ảnh
- Video
- GIF
- Mô tả
- Hướng dẫn
- Nhóm cơ
- Thiết bị
- Calories Estimate

Business Rule

- Video phải hợp lệ.
- Chỉ hiển thị Exercise Active.

---

## FT-WO-003 Favorite Exercise

### Chức năng

- Add Favorite
- Remove Favorite
- Favorite List

---

## FT-WO-004 Workout Builder

### Mục đích

Cho phép người dùng tạo chương trình tập luyện.

### Chức năng

- Create Program
- Edit Program
- Delete Program
- Duplicate Program
- Activate Program

Input

- Exercise
- Sets
- Reps
- Weight
- Rest Time

---

## FT-WO-005 Workout Schedule

### Chức năng

- Calendar
- Weekly Schedule
- Monthly Schedule
- Reminder

Business Rule

Một ngày có thể có nhiều Workout.

---

## FT-WO-006 Workout Session

### Chức năng

- Start Workout
- Pause
- Resume
- Finish
- Cancel

Output

Workout Session

---

## FT-WO-007 Workout Tracking

### Chức năng

Trong mỗi bài tập:

- Weight
- Set
- Rep
- Duration
- Rest Timer
- Note

Output

Workout Log

---

## FT-WO-008 Workout History

### Chức năng

- Theo ngày
- Theo tuần
- Theo tháng
- Theo chương trình

---

## FT-WO-009 Workout Statistics

### Chức năng

- Total Workout
- Total Time
- Calories Burned
- Workout Frequency
- Streak

Output

Chart

---

## FT-WO-010 Personal Record

### Chức năng

Theo dõi:

- Bench Press PR
- Squat PR
- Deadlift PR
- Running Record

Future Scope

---

# 7. Exercise Library

## 7.1 Mục tiêu

Exercise Library là kho dữ liệu bài tập chuẩn phục vụ Workout Builder và AI Coach.

---

## 7.2 Danh sách Feature

| ID        | Feature                 |
| --------- | ----------------------- |
| FT-EL-001 | Exercise Management     |
| FT-EL-002 | Muscle Group            |
| FT-EL-003 | Equipment               |
| FT-EL-004 | Difficulty              |
| FT-EL-005 | Video Resource          |
| FT-EL-006 | Exercise Recommendation |

---

## FT-EL-001 Exercise Management

### Chức năng

- Create Exercise
- Update Exercise
- Delete Exercise
- Archive Exercise

(Admin)

---

## FT-EL-002 Muscle Group

### Chức năng

Phân loại theo:

- Chest
- Back
- Shoulder
- Biceps
- Triceps
- Forearm
- Core
- Glutes
- Quadriceps
- Hamstrings
- Calves
- Full Body

---

## FT-EL-003 Equipment

### Chức năng

- Dumbbell
- Barbell
- Machine
- Resistance Band
- Bodyweight
- Kettlebell
- Cable

---

## FT-EL-004 Difficulty

### Chức năng

- Beginner
- Intermediate
- Advanced

---

## FT-EL-005 Video Resource

### Chức năng

- GIF
- MP4
- Thumbnail
- YouTube Link (Future)

---

## FT-EL-006 Exercise Recommendation

### Chức năng

Đề xuất bài tập theo:

- Goal
- Muscle Group
- Difficulty
- Equipment
- AI Coach

Output

Suggested Exercise List

Dependency

- AI Coach
- Health Profile

# 8. Meal Planner

## 8.1 Mục tiêu

Meal Planner là phân hệ hỗ trợ người dùng xây dựng chế độ dinh dưỡng hằng ngày dựa trên mục tiêu luyện tập, tình trạng sức khỏe và nhu cầu năng lượng được tính toán từ Health Profile.

Hệ thống cho phép người dùng tìm kiếm món ăn, xây dựng thực đơn, theo dõi lượng Calories và các chất dinh dưỡng (Protein, Carbohydrate, Fat) đã tiêu thụ, đồng thời nhận gợi ý từ AI Coach.

---

## 8.2 Danh sách Feature

| ID        | Feature                | Priority |
| --------- | ---------------------- | -------- |
| FT-MP-001 | Food Library           | High     |
| FT-MP-002 | Food Search            | High     |
| FT-MP-003 | Food Detail            | High     |
| FT-MP-004 | Meal Planner           | High     |
| FT-MP-005 | Meal Entry             | High     |
| FT-MP-006 | Nutrition Summary      | High     |
| FT-MP-007 | Macro Distribution     | High     |
| FT-MP-008 | Favorite Food          | Medium   |
| FT-MP-009 | Recent Food            | Medium   |
| FT-MP-010 | Meal History           | Medium   |
| FT-MP-011 | Water Tracker          | Medium   |
| FT-MP-012 | AI Meal Recommendation | Medium   |

---

# FT-MP-001 Food Library

## Mục đích

Quản lý cơ sở dữ liệu thực phẩm phục vụ Meal Planner.

## Chức năng

- Danh sách món ăn
- Danh sách nguyên liệu
- Danh mục thực phẩm
- Thông tin dinh dưỡng
- Khẩu phần tiêu chuẩn

## Output

Danh sách thực phẩm.

## Business Rule

- Mỗi thực phẩm có mã định danh duy nhất.
- Calories được tính theo 100g hoặc khẩu phần chuẩn.
- Chỉ hiển thị dữ liệu đang hoạt động.

---

# FT-MP-002 Food Search

## Chức năng

Người dùng có thể tìm kiếm thực phẩm theo:

- Tên món ăn
- Danh mục
- Calories
- Protein
- Carbohydrate
- Fat
- Giá trị năng lượng
- Món ăn phổ biến

## Bộ lọc

- Healthy
- High Protein
- Low Carb
- Low Fat
- Vegetarian
- Vegan (Future)

## Output

Danh sách món ăn phù hợp.

---

# FT-MP-003 Food Detail

## Chức năng

Hiển thị:

- Tên món ăn
- Hình ảnh
- Thành phần
- Calories
- Protein
- Carb
- Fat
- Chất xơ
- Đường
- Natri
- Khẩu phần
- Nguồn dữ liệu

## Business Rule

Thông tin dinh dưỡng chỉ mang tính tham khảo.

---

# FT-MP-004 Meal Planner

## Mục đích

Xây dựng thực đơn trong ngày.

## Chức năng

- Breakfast
- Lunch
- Dinner
- Snack

Mỗi bữa ăn có thể chứa nhiều món.

## Output

Meal Plan trong ngày.

---

# FT-MP-005 Meal Entry

## Chức năng

- Thêm món ăn
- Xóa món ăn
- Chỉnh sửa khẩu phần
- Sao chép sang ngày khác

Input

- Food
- Portion

Output

Meal Entry

Business Rule

Calories được tính lại ngay sau khi thay đổi khẩu phần.

---

# FT-MP-006 Nutrition Summary

## Chức năng

Tổng hợp:

- Calories
- Protein
- Carb
- Fat

So sánh với mục tiêu trong ngày.

Output

Nutrition Summary

---

# FT-MP-007 Macro Distribution

## Chức năng

Hiển thị tỷ lệ

- Protein
- Carbohydrate
- Fat

Biểu đồ:

- Pie Chart
- Progress Bar

---

# FT-MP-008 Favorite Food

## Chức năng

- Thêm yêu thích
- Xóa yêu thích
- Danh sách yêu thích

Output

Favorite List

---

# FT-MP-009 Recent Food

## Chức năng

Hiển thị

- Hôm nay
- 7 ngày gần nhất
- 30 ngày gần nhất

Cho phép

Add Again

---

# FT-MP-010 Meal History

## Chức năng

Tra cứu lịch sử:

- Theo ngày
- Theo tuần
- Theo tháng

Hiển thị

- Calories
- Macro
- Meal Plan

---

# FT-MP-011 Water Tracker

## Mục đích

Theo dõi lượng nước uống.

## Chức năng

- Thêm nước
- Chỉnh sửa
- Xóa

Hiển thị

- Đã uống
- Mục tiêu
- Tiến độ

Future

- Nhắc uống nước.

---

# FT-MP-012 AI Meal Recommendation

## Chức năng

AI đề xuất

- Món ăn
- Thực đơn
- Khẩu phần
- Calories

Dựa trên

- Goal
- BMI
- TDEE
- Workout
- Meal History

Dependency

- AI Coach

---

# 9. Food Library

## 9.1 Mục tiêu

Food Library là kho dữ liệu thực phẩm và món ăn phục vụ Meal Planner, AI Coach và Dashboard.

Nguồn dữ liệu ưu tiên sử dụng Bộ dữ liệu dinh dưỡng Việt Nam, đồng thời có khả năng mở rộng tích hợp các nguồn dữ liệu khác trong tương lai.

---

## 9.2 Danh sách Feature

| ID        | Feature               |
| --------- | --------------------- |
| FT-FD-001 | Food Management       |
| FT-FD-002 | Food Category         |
| FT-FD-003 | Nutrition Information |
| FT-FD-004 | Portion Management    |
| FT-FD-005 | Dataset Import        |
| FT-FD-006 | Food Recommendation   |

---

# FT-FD-001 Food Management

## Chức năng

(Admin)

- Thêm món ăn
- Cập nhật
- Xóa
- Khóa
- Khôi phục

---

# FT-FD-002 Food Category

## Danh mục

- Cơm
- Phở
- Bún
- Mì
- Cháo
- Thịt
- Cá
- Hải sản
- Rau
- Trái cây
- Đồ uống
- Đồ ăn nhanh
- Bánh kẹo

Future

Cho phép tạo danh mục động.

---

# FT-FD-003 Nutrition Information

## Thông tin

- Calories
- Protein
- Carb
- Fat
- Fiber
- Sugar
- Sodium
- Cholesterol

Đơn vị

100g

hoặc

1 Serving.

---

# FT-FD-004 Portion Management

## Chức năng

- Gram
- Serving
- Piece
- Bowl
- Cup

Business Rule

Hệ thống tự quy đổi về gram để tính Calories.

---

# FT-FD-005 Dataset Import

## Chức năng

Admin có thể

- Import CSV
- Import Excel
- Đồng bộ Dataset

Nguồn dữ liệu

- Bộ dữ liệu dinh dưỡng Việt Nam
- Dataset mở (Future)

Business Rule

Không tạo dữ liệu trùng lặp.

---

# FT-FD-006 Food Recommendation

## Chức năng

Đề xuất món ăn theo

- Goal
- Calories
- Protein
- Carb
- Fat
- Meal Time

Dependency

- AI Coach
- Meal Planner

# 10. AI Coach

## 10.1 Mục tiêu

AI Coach là phân hệ trí tuệ nhân tạo của VieGym, hỗ trợ người dùng trong quá trình luyện tập, xây dựng chế độ dinh dưỡng và giải đáp các câu hỏi liên quan đến sức khỏe.

AI Coach sử dụng dữ liệu từ các phân hệ khác để tạo ngữ cảnh (Context) trước khi gửi yêu cầu đến mô hình AI, từ đó đưa ra câu trả lời mang tính cá nhân hóa thay vì trả lời chung chung.

---

## 10.2 Danh sách Feature

| ID        | Feature              | Priority |
| --------- | -------------------- | -------- |
| FT-AI-001 | AI Conversation      | High     |
| FT-AI-002 | Context Builder      | High     |
| FT-AI-003 | Prompt Builder       | High     |
| FT-AI-004 | Workout Advisor      | High     |
| FT-AI-005 | Nutrition Advisor    | High     |
| FT-AI-006 | Product Advisor      | Medium   |
| FT-AI-007 | Conversation History | Medium   |
| FT-AI-008 | AI Memory            | Medium   |
| FT-AI-009 | Response Validation  | High     |
| FT-AI-010 | AI Feedback          | Medium   |

---

# FT-AI-001 AI Conversation

## Mục đích

Cho phép người dùng trao đổi trực tiếp với AI thông qua giao diện Chat.

## Chức năng

- Gửi tin nhắn
- Nhận phản hồi
- Hiển thị trạng thái đang xử lý
- Hỗ trợ Markdown
- Hiển thị lịch sử hội thoại

## Business Rule

- Chỉ người dùng đã đăng nhập mới được sử dụng AI Coach.
- Tin nhắn phải được lưu vào lịch sử hội thoại.

---

# FT-AI-002 Context Builder

## Mục đích

Tổng hợp dữ liệu người dùng để tạo ngữ cảnh trước khi gửi yêu cầu đến AI.

## Dữ liệu sử dụng

- Hồ sơ cá nhân
- BMI
- TDEE
- Mục tiêu luyện tập
- Lịch sử tập luyện
- Meal Planner
- Lịch sử cân nặng

## Output

AI Context

## Dependency

- User Profile
- Health Profile
- Workout
- Meal Planner

---

# FT-AI-003 Prompt Builder

## Chức năng

Xây dựng Prompt gửi tới mô hình AI.

Prompt bao gồm

- System Prompt
- User Prompt
- Context
- Conversation History

## Business Rule

Không gửi dữ liệu nhạy cảm của người dùng ngoài phạm vi cần thiết.

---

# FT-AI-004 Workout Advisor

## Chức năng

AI hỗ trợ

- Gợi ý lịch tập
- Điều chỉnh bài tập
- Đề xuất nhóm cơ
- Phân tích tiến độ
- Giải thích kỹ thuật

Output

Workout Recommendation

---

# FT-AI-005 Nutrition Advisor

## Chức năng

AI hỗ trợ

- Gợi ý thực đơn
- Điều chỉnh Calories
- Phân tích Macro
- Đề xuất khẩu phần
- Gợi ý thay thế món ăn

Dependency

Meal Planner

---

# FT-AI-006 Product Advisor

## Chức năng

AI gợi ý sản phẩm phù hợp dựa trên

- Goal
- Workout
- Meal Plan

Ví dụ

- Whey Protein
- Creatine
- Vitamin
- Bình nước
- Dụng cụ tập

Business Rule

Không bắt buộc người dùng mua sản phẩm.

---

# FT-AI-007 Conversation History

## Chức năng

- Lưu lịch sử hội thoại
- Xem lại
- Xóa hội thoại
- Tìm kiếm hội thoại

---

# FT-AI-008 AI Memory

## Chức năng

AI ghi nhớ

- Goal
- Thói quen tập luyện
- Thực đơn
- Sản phẩm thường dùng

Future Scope

Cho phép người dùng bật hoặc tắt AI Memory.

---

# FT-AI-009 Response Validation

## Chức năng

Kiểm tra phản hồi AI trước khi hiển thị.

Bao gồm

- Lọc nội dung không phù hợp
- Kiểm tra định dạng
- Kiểm tra độ dài
- Xử lý lỗi phản hồi

Business Rule

Nếu AI không phản hồi, hệ thống trả về thông báo thân thiện với người dùng.

---

# FT-AI-010 AI Feedback

## Chức năng

Người dùng có thể

- Thích câu trả lời
- Không thích câu trả lời
- Báo cáo phản hồi không chính xác

Output

Feedback phục vụ cải thiện hệ thống.

---

# 11. Notification

## 11.1 Mục tiêu

Notification chịu trách nhiệm gửi thông báo đến người dùng nhằm nhắc nhở luyện tập, ăn uống và cập nhật trạng thái hệ thống.

---

## 11.2 Danh sách Feature

| ID        | Feature             |
| --------- | ------------------- |
| FT-NT-001 | In-App Notification |
| FT-NT-002 | Push Notification   |
| FT-NT-003 | Workout Reminder    |
| FT-NT-004 | Meal Reminder       |
| FT-NT-005 | Water Reminder      |
| FT-NT-006 | Order Notification  |

---

# FT-NT-001 In-App Notification

## Chức năng

- Danh sách thông báo
- Đánh dấu đã đọc
- Xóa thông báo

---

# FT-NT-002 Push Notification

## Chức năng

Gửi thông báo đến thiết bị thông qua Firebase Cloud Messaging (FCM).

---

# FT-NT-003 Workout Reminder

## Chức năng

Nhắc người dùng

- Đến giờ tập
- Chưa hoàn thành buổi tập
- Hoàn thành mục tiêu tuần

---

# FT-NT-004 Meal Reminder

## Chức năng

Nhắc

- Ăn sáng
- Ăn trưa
- Ăn tối
- Ăn nhẹ

---

# FT-NT-005 Water Reminder

## Chức năng

Nhắc uống nước theo khoảng thời gian người dùng thiết lập.

---

# FT-NT-006 Order Notification

## Chức năng

Thông báo

- Đặt hàng thành công
- Đang giao
- Đã giao
- Hủy đơn

Dependency

Shop Module

---

# 12. Media

## 12.1 Mục tiêu

Media Module quản lý toàn bộ tài nguyên hình ảnh và video được sử dụng trong hệ thống.

---

## 12.2 Danh sách Feature

| ID        | Feature           |
| --------- | ----------------- |
| FT-MD-001 | Image Upload      |
| FT-MD-002 | Video Upload      |
| FT-MD-003 | Media Storage     |
| FT-MD-004 | Image Compression |
| FT-MD-005 | Media Management  |

---

# FT-MD-001 Image Upload

## Chức năng

- Upload Avatar
- Upload Product
- Upload Exercise
- Upload Food

Business Rule

Chỉ chấp nhận

- JPG
- PNG
- WEBP

---

# FT-MD-002 Video Upload

## Chức năng

Lưu video hướng dẫn bài tập.

Future

Streaming Video

---

# FT-MD-003 Media Storage

## Chức năng

Lưu trữ

- Hình ảnh
- Video
- Thumbnail

Đề xuất sử dụng

- MinIO
- AWS S3 (Future)

---

# FT-MD-004 Image Compression

## Chức năng

- Resize
- Compress
- Tạo Thumbnail

Business Rule

Không làm giảm chất lượng ảnh quá mức.

---

# FT-MD-005 Media Management

(Admin)

## Chức năng

- Danh sách Media
- Xóa
- Khôi phục
- Thống kê dung lượng
- Kiểm tra Media không sử dụng

# 13. Shop

## 13.1 Mục tiêu

Shop Module cung cấp nền tảng thương mại điện tử trong hệ thống VieGym, cho phép người dùng tìm kiếm, mua sắm các sản phẩm hỗ trợ luyện tập và dinh dưỡng như Whey Protein, Creatine, Vitamin, dụng cụ tập luyện và phụ kiện.

Module được thiết kế theo hướng mở để có thể tích hợp nhiều phương thức thanh toán và mở rộng trong tương lai.

---

## 13.2 Danh sách Feature

| ID        | Feature          | Priority |
| --------- | ---------------- | -------- |
| FT-SP-001 | Product Catalog  | High     |
| FT-SP-002 | Product Detail   | High     |
| FT-SP-003 | Product Search   | High     |
| FT-SP-004 | Shopping Cart    | High     |
| FT-SP-005 | Checkout         | High     |
| FT-SP-006 | Order Management | High     |
| FT-SP-007 | Payment          | High     |
| FT-SP-008 | Order History    | Medium   |
| FT-SP-009 | Product Review   | Future   |
| FT-SP-010 | Wishlist         | Future   |

---

# FT-SP-001 Product Catalog

## Chức năng

- Danh sách sản phẩm
- Phân trang
- Sắp xếp
- Lọc theo danh mục
- Hiển thị sản phẩm nổi bật

---

# FT-SP-002 Product Detail

## Chức năng

Hiển thị

- Hình ảnh
- Mô tả
- Giá
- Thương hiệu
- Tồn kho
- Thành phần
- Hướng dẫn sử dụng

---

# FT-SP-003 Product Search

## Chức năng

Tìm kiếm theo

- Tên
- Danh mục
- Giá
- Thương hiệu

Bộ lọc

- Giá thấp → cao
- Giá cao → thấp
- Mới nhất
- Bán chạy

---

# FT-SP-004 Shopping Cart

## Chức năng

- Thêm sản phẩm
- Xóa sản phẩm
- Cập nhật số lượng
- Tính tổng tiền

Business Rule

Không vượt quá số lượng tồn kho.

---

# FT-SP-005 Checkout

## Chức năng

- Chọn địa chỉ
- Chọn phương thức giao hàng
- Chọn phương thức thanh toán
- Xác nhận đơn hàng

---

# FT-SP-006 Order Management

## Chức năng

Theo dõi trạng thái

- Pending
- Confirmed
- Shipping
- Completed
- Cancelled

---

# FT-SP-007 Payment

## Chức năng

MVP

- Thanh toán khi nhận hàng (COD)

Future Scope

- VNPay
- MoMo
- ZaloPay
- Stripe

---

# FT-SP-008 Order History

## Chức năng

- Danh sách đơn hàng
- Chi tiết đơn hàng
- Mua lại

---

# FT-SP-009 Product Review (Future)

## Chức năng

- Đánh giá sao
- Bình luận
- Hình ảnh

---

# FT-SP-010 Wishlist (Future)

## Chức năng

- Thêm yêu thích
- Xóa yêu thích

---

# 14. Admin CMS

## 14.1 Mục tiêu

Admin CMS cho phép quản trị viên quản lý toàn bộ dữ liệu của hệ thống.

---

## 14.2 Danh sách Feature

| ID        | Feature              |
| --------- | -------------------- |
| FT-AD-001 | Dashboard            |
| FT-AD-002 | User Management      |
| FT-AD-003 | Exercise Management  |
| FT-AD-004 | Food Management      |
| FT-AD-005 | Product Management   |
| FT-AD-006 | Order Management     |
| FT-AD-007 | AI Prompt Management |
| FT-AD-008 | Dataset Import       |
| FT-AD-009 | Audit Log            |
| FT-AD-010 | System Configuration |

---

# FT-AD-001 Dashboard

Hiển thị

- Tổng người dùng
- Tổng đơn hàng
- Tổng doanh thu
- Người dùng mới
- Workout nhiều nhất
- Món ăn phổ biến

---

# FT-AD-002 User Management

## Chức năng

- Xem User
- Khóa User
- Mở khóa
- Phân quyền

---

# FT-AD-003 Exercise Management

## Chức năng

CRUD

- Exercise
- Muscle Group
- Equipment

---

# FT-AD-004 Food Management

## Chức năng

CRUD

- Food
- Category
- Nutrition

---

# FT-AD-005 Product Management

## Chức năng

CRUD

- Product
- Brand
- Category
- Inventory

---

# FT-AD-006 Order Management

## Chức năng

- Xác nhận
- Giao hàng
- Hủy
- Hoàn tiền (Future)

---

# FT-AD-007 AI Prompt Management

## Chức năng

- System Prompt
- Prompt Template
- Version

---

# FT-AD-008 Dataset Import

## Chức năng

Import

- CSV
- Excel

Nguồn dữ liệu

- Bộ dữ liệu dinh dưỡng Việt Nam

---

# FT-AD-009 Audit Log

## Chức năng

Theo dõi

- Login
- CRUD
- Import
- Export

---

# FT-AD-010 System Configuration

## Chức năng

- Banner
- Notification
- AI Setting
- Upload Limit

---

# 15. Feature Dependency

Các phân hệ của VieGym có mối quan hệ phụ thuộc như sau:

```text
Identity
        │
        ▼
User Profile
        │
        ▼
Health Profile
        │
 ┌──────┼───────────┐
 ▼      ▼           ▼
Workout MealPlanner Dashboard
   │        │          │
   └────────┼──────────┘
            ▼
         AI Coach
            │
            ▼
           Shop

Notification nhận sự kiện từ:
- Workout
- Meal Planner
- Shop
- AI Coach
```

---

# 16. MVP Scope

Các tính năng được triển khai trong phiên bản đầu tiên.

## Identity

- Register
- Login
- JWT

## User Profile

- Hồ sơ
- Avatar
- Goal

## Health Profile

- BMI
- TDEE
- Calories

## Workout

- Exercise Library
- Workout Builder
- Workout Tracking

## Meal Planner

- Food Library
- Meal Planner
- Nutrition Summary

## AI Coach

- Chat AI
- Workout Advisor
- Meal Advisor

## Shop

- Product
- Cart
- Order
- COD

## Notification

- Workout Reminder
- Meal Reminder

## Admin

- CRUD User
- CRUD Exercise
- CRUD Food
- CRUD Product

---

# 17. Future Scope

Các tính năng dự kiến phát triển trong các phiên bản tiếp theo.

## Workout

- Wearable Integration
- Apple Health
- Google Fit
- Smart Watch

---

## Meal Planner

- Barcode Scanner
- OCR Food Recognition
- AI Food Image Recognition
- Meal Template Marketplace

---

## AI Coach

- Voice Chat
- AI Memory
- AI Vision
- AI Personal Trainer

---

## Shop

- Online Payment
- Wishlist
- Voucher
- Flash Sale
- Product Review
- Affiliate

---

## Notification

- Email Notification
- SMS Notification
- Push Notification nâng cao

---

## Dashboard

- Achievement
- XP
- Level
- Badge
- Social Ranking

---

## Admin

- Analytics Dashboard
- Revenue Report
- BI Dashboard
- AI Statistics

---
