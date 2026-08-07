# Phân Rã Phân Hệ Hệ Thống — VieGym

> Tài liệu phân rã hệ thống VieGym theo các phân hệ nghiệp vụ và kỹ thuật, dẫn xuất từ tài liệu đặc tả yêu cầu hệ thống `docs/spec/specs.md`.

---

## Thông tin tài liệu

| Thuộc tính      | Giá trị                                               |
| --------------- | ----------------------------------------------------- |
| Tên tài liệu    | Phân rã phân hệ hệ thống VieGym                       |
| Loại tài liệu   | System Decomposition / Module Breakdown              |
| Nguồn tham chiếu | `docs/spec/specs.md`                                  |
| Phạm vi áp dụng | MVP đồ án 6 tháng và nền tảng mở rộng sau đồ án       |
| Ngôn ngữ        | Tiếng Việt                                            |

---

## 1. Mục tiêu tài liệu

Tài liệu này mô tả cách hệ thống VieGym được chia thành các phân hệ/module để phục vụ thiết kế và triển khai.

Mỗi phân hệ được mô tả theo các nội dung chính:

- Mục tiêu nghiệp vụ.
- Chức năng chính.
- Dữ liệu/entity do phân hệ sở hữu.
- API hoặc nhóm API liên quan.
- Phân hệ phụ thuộc và phân hệ sử dụng dữ liệu.
- Ràng buộc bảo mật, nghiệp vụ và kỹ thuật.
- Phạm vi MVP và phần có thể mở rộng sau.

Tài liệu này không thay thế SRS. Khi có mâu thuẫn, `docs/spec/specs.md` là nguồn yêu cầu chính cần được ưu tiên đối chiếu.

---

## 2. Nguyên tắc phân rã

VieGym được phân rã theo domain nghiệp vụ, ưu tiên ranh giới rõ giữa dữ liệu, hành vi và trách nhiệm của từng module.

Các nguyên tắc chính:

- Mobile App và Admin Web chỉ giao tiếp với Backend thông qua REST API.
- Spring Boot Backend là nguồn sự thật cho dữ liệu nghiệp vụ.
- Mỗi phân hệ sở hữu dữ liệu cốt lõi của mình, các phân hệ khác chỉ đọc qua service/API nội bộ.
- Dashboard là phân hệ tổng hợp dữ liệu, không sở hữu logic nghiệp vụ gốc.
- AI Service không truy cập database trực tiếp; Backend chuẩn bị context cần thiết rồi gọi AI Service.
- Dữ liệu sức khỏe, thực đơn, lịch tập, workout log và đơn hàng là dữ liệu cá nhân, phải kiểm tra quyền sở hữu ở Backend.
- Ảnh, video và GIF không lưu trực tiếp trong database; database chỉ lưu metadata, object key hoặc URL.
- Admin quản trị dữ liệu dùng chung nhưng không được xem mật khẩu, refresh token hoặc secret của người dùng.
- Các API riêng tư phải yêu cầu JWT và phân quyền USER/ADMIN rõ ràng.

---

## 3. Kiến trúc tổng quan

```text
Flutter Mobile App
        |
        | REST API / HTTPS
        v
Spring Boot Backend  <---------------- React Admin Web
        |
        |------------------- PostgreSQL
        |------------------- Redis
        |------------------- MinIO / Amazon S3
        |
        v
Python FastAPI AI Service
        |
        v
OpenAI API hoặc Gemini API
```

### 3.1. Thành phần hệ thống

| Thành phần       | Công nghệ                                     | Vai trò                                                |
| ---------------- | --------------------------------------------- | ------------------------------------------------------ |
| Mobile App       | Flutter                                       | Giao diện người dùng trên mobile                       |
| Admin Web        | React + TypeScript                            | Giao diện quản trị dữ liệu và đơn hàng                 |
| Backend API      | Spring Boot                                   | Xử lý nghiệp vụ, REST API, bảo mật và tích hợp hạ tầng |
| Security         | Spring Security + JWT                         | Xác thực, phân quyền USER/ADMIN                        |
| Database         | PostgreSQL                                    | Lưu dữ liệu nghiệp vụ chính                            |
| Cache            | Redis                                         | Cache OTP, session/token ngắn hạn, dữ liệu truy cập nhanh |
| AI Service       | Python FastAPI                                | Đóng gói logic AI Coach và Sales AI                    |
| AI Provider      | OpenAI API hoặc Gemini API                    | Sinh phản hồi AI                                       |
| Object Storage   | MinIO hoặc Amazon S3                          | Lưu ảnh món ăn, ảnh sản phẩm, video/GIF bài tập        |
| DevOps           | Docker, Docker Compose, Nginx, GitHub Actions | Triển khai, reverse proxy và CI/CD                     |

---

## 4. Mapping SRS sang phân hệ

| Mục trong SRS | Nội dung yêu cầu                                  | Phân hệ triển khai                         |
| ------------- | ------------------------------------------------- | ------------------------------------------ |
| 4, 6, 25      | Actor, tài khoản, xác thực, phân quyền            | Identity & Auth                            |
| 7, 14         | Hồ sơ sức khỏe, BMI/BMR/TDEE, cân nặng            | Health Profile & Body Tracking             |
| 9             | Tạo/chỉnh sửa giáo án tập                         | Workout / Workout Builder                  |
| 10            | Thư viện bài tập                                  | Workout / Exercise Library                 |
| 11            | Theo dõi luyện tập, workout log, PR               | Workout / Workout Tracking                 |
| 12            | Lịch tập, trạng thái buổi tập, nhắc lịch          | Workout / Workout Schedule, Notification   |
| 13            | Meal Planner, món ăn Việt Nam, calories/macro     | Nutrition / Meal Planner                   |
| 8             | AI Coach luyện tập và dinh dưỡng                  | AI Coach & Sales AI                        |
| 15            | Cửa hàng, giỏ hàng, đơn hàng, thanh toán          | Shop & Order                               |
| 16            | Chatbot tư vấn sản phẩm                           | AI Coach & Sales AI, Shop & Order          |
| 17            | Dashboard người dùng và dashboard admin           | Dashboard                                  |
| 18            | Quản trị dữ liệu hệ thống                         | Admin & Audit                              |
| 19, 22, 23    | Kiến trúc, phụ thuộc ngoài, giao tiếp phần mềm    | Integration, Media / Storage, Infrastructure |
| 24, 25, 26    | Phi chức năng, bảo mật, notification              | Tất cả phân hệ                             |

---

## 5. Tổng quan phân hệ

VieGym gồm 10 phân hệ chính:

| #  | Phân hệ                            | Vai trò chính                                                | MVP |
| -- | ---------------------------------- | ------------------------------------------------------------ | :-: |
| 1  | Identity & Auth                    | Tài khoản, xác thực, JWT, OTP, phân quyền                    | Có  |
| 2  | Health Profile & Body Tracking     | Hồ sơ sức khỏe, chỉ số cơ thể, lịch sử cân nặng              | Có  |
| 3  | Workout                            | Bài tập, giáo án, lịch tập, workout log                      | Có  |
| 4  | Nutrition / Meal Planner           | Món ăn Việt Nam, meal plan, calories và macro                | Có  |
| 5  | AI Coach & Sales AI                | Tư vấn luyện tập, dinh dưỡng và sản phẩm bằng AI             | Có bản cơ bản |
| 6  | Shop & Order                       | Sản phẩm, giỏ hàng, đơn hàng, thanh toán                     | Có bản cơ bản |
| 7  | Dashboard                          | Tổng hợp dữ liệu người dùng và admin                         | Có  |
| 8  | Notification                       | Nhắc lịch, nhắc meal, đơn hàng, gợi ý AI                     | Cơ bản |
| 9  | Admin & Audit                      | Quản trị dữ liệu dùng chung và ghi log thao tác quan trọng   | Có bản cơ bản |
| 10 | Media / Storage                    | Lưu trữ ảnh, video, GIF và metadata media                    | Có bản cơ bản |

---

## 6. Identity & Auth

### 6.1. Mục tiêu

Phân hệ Identity & Auth quản lý danh tính người dùng, phiên đăng nhập, phân quyền và hồ sơ cá nhân cơ bản. Đây là phân hệ nền tảng vì hầu hết chức năng của VieGym đều yêu cầu xác định người dùng hiện tại.

### 6.2. Chức năng chính

| Mã      | Chức năng        | Mô tả                                                             |
| ------- | ---------------- | ----------------------------------------------------------------- |
| AUTH-01 | Đăng ký          | Người dùng tạo tài khoản bằng email, mật khẩu và thông tin cơ bản |
| AUTH-02 | Đăng nhập        | Đăng nhập bằng email và mật khẩu                                  |
| AUTH-03 | Google Login     | Đăng nhập bằng tài khoản Google                                   |
| AUTH-04 | Refresh token    | Cấp access token mới bằng refresh token hợp lệ                    |
| AUTH-05 | Đăng xuất        | Thu hồi refresh token và kết thúc phiên đăng nhập                 |
| AUTH-06 | Quên mật khẩu    | Gửi OTP hoặc liên kết đặt lại mật khẩu                            |
| AUTH-07 | Xác thực OTP     | Xác minh OTP cho email hoặc reset password                        |
| AUTH-08 | Cập nhật hồ sơ   | Cập nhật họ tên, ngày sinh, giới tính, ảnh đại diện               |
| AUTH-09 | Phân quyền       | Phân biệt quyền USER và ADMIN                                     |

### 6.3. Entity sở hữu

| Entity       | Mô tả                         |
| ------------ | ----------------------------- |
| User         | Tài khoản người dùng          |
| UserProfile  | Thông tin cá nhân cơ bản      |
| RefreshToken | Phiên đăng nhập có thể thu hồi |
| OtpCode      | Mã OTP xác thực hoặc reset password |

### 6.4. API liên quan

| Method | Endpoint                     | Mô tả                    |
| ------ | ---------------------------- | ------------------------ |
| POST   | `/api/v1/auth/register`      | Đăng ký                  |
| POST   | `/api/v1/auth/login`         | Đăng nhập                |
| POST   | `/api/v1/auth/google`        | Đăng nhập Google         |
| POST   | `/api/v1/auth/refresh`       | Cấp access token mới     |
| POST   | `/api/v1/auth/logout`        | Đăng xuất                |
| POST   | `/api/v1/auth/forgot-password` | Gửi OTP đặt lại mật khẩu |
| POST   | `/api/v1/auth/verify-otp`    | Xác thực OTP             |
| POST   | `/api/v1/auth/reset-password` | Đặt lại mật khẩu         |
| GET    | `/api/v1/users/me`           | Lấy thông tin user hiện tại |
| PUT    | `/api/v1/users/me`           | Cập nhật hồ sơ cá nhân   |

### 6.5. Phụ thuộc

| Phụ thuộc | Mục đích |
| --------- | -------- |
| PostgreSQL | Lưu User, UserProfile, RefreshToken, OtpCode |
| Redis | Lưu OTP hoặc dữ liệu ngắn hạn nếu cần |
| Google OAuth | Đăng nhập Google |
| Spring Security + JWT | Xác thực và phân quyền API |

### 6.6. Business rules

- Email phải duy nhất trong hệ thống.
- Mật khẩu phải được hash bằng BCrypt hoặc thuật toán tương đương.
- Access token dùng JWT và có thời hạn ngắn.
- Refresh token phải có khả năng thu hồi khi đăng xuất.
- OTP phải có thời hạn và giới hạn số lần thử.
- Tài khoản bị khóa hoặc vô hiệu hóa không được đăng nhập.
- Google Login phải liên kết theo email duy nhất.

### 6.7. MVP scope

Bắt buộc trong MVP. Cần hoàn thành trước các phân hệ cá nhân hóa như Health, Workout, Nutrition, AI, Shop và Dashboard.

---

## 7. Health Profile & Body Tracking

### 7.1. Mục tiêu

Phân hệ Health Profile & Body Tracking lưu hồ sơ sức khỏe, tính toán chỉ số cơ thể và theo dõi cân nặng theo thời gian. Đây là nguồn dữ liệu nền cho Dashboard, Meal Planner và AI Coach.

### 7.2. Chức năng chính

| Mã        | Chức năng             | Mô tả                                                        |
| --------- | --------------------- | ------------------------------------------------------------ |
| HEALTH-01 | Tạo/cập nhật hồ sơ    | Lưu chiều cao, cân nặng, tuổi/ngày sinh, giới tính, mức vận động, mục tiêu |
| HEALTH-02 | Tính BMI              | Tính chỉ số khối cơ thể                                      |
| HEALTH-03 | Tính BMR              | Tính năng lượng cơ bản theo công thức Mifflin-St Jeor         |
| HEALTH-04 | Tính TDEE             | Tính tổng năng lượng tiêu hao theo activity factor            |
| HEALTH-05 | Tính calories mục tiêu | Đề xuất calories theo mục tiêu giảm cân, tăng cân, tăng cơ, duy trì |
| HEALTH-06 | Tính macro mục tiêu   | Đề xuất protein, carbohydrate và fat mục tiêu                 |
| WEIGHT-01 | Ghi nhận cân nặng     | Thêm hoặc cập nhật cân nặng theo ngày                         |
| WEIGHT-02 | Thống kê cân nặng     | Xem cân nặng hiện tại, mục tiêu, thay đổi theo tuần/tháng, biểu đồ |

### 7.3. Entity sở hữu

| Entity          | Mô tả                                                           |
| --------------- | --------------------------------------------------------------- |
| HealthProfile   | Chiều cao, cân nặng, tuổi, giới tính, mức độ vận động, mục tiêu |
| WeightLog       | Lịch sử cân nặng                                                |
| NutritionTarget | Mục tiêu calories và macro                                      |

### 7.4. API liên quan

| Method | Endpoint                     | Mô tả                       |
| ------ | ---------------------------- | --------------------------- |
| GET    | `/api/v1/health-profile/me`  | Lấy hồ sơ sức khỏe          |
| PUT    | `/api/v1/health-profile/me`  | Tạo/cập nhật hồ sơ sức khỏe |
| GET    | `/api/v1/weight-logs`        | Lấy lịch sử cân nặng        |
| POST   | `/api/v1/weight-logs`        | Thêm/cập nhật cân nặng      |

### 7.5. Phụ thuộc và dữ liệu cung cấp

| Loại | Phân hệ | Mô tả |
| ---- | ------- | ----- |
| Phụ thuộc | Identity & Auth | Xác định user sở hữu hồ sơ |
| Cung cấp | Dashboard | BMI, cân nặng, calories/macro target, tiến độ mục tiêu |
| Cung cấp | Nutrition / Meal Planner | Calories và macro mục tiêu |
| Cung cấp | AI Coach & Sales AI | Context sức khỏe và mục tiêu cá nhân |

### 7.6. Business rules

- Nếu thiếu dữ liệu bắt buộc, hệ thống không tính TDEE và yêu cầu hoàn thiện hồ sơ.
- Mỗi lần cập nhật cân nặng hoặc hồ sơ sức khỏe quan trọng, hệ thống lưu lịch sử để phục vụ biểu đồ.
- Một ngày có thể có một bản ghi cân nặng chính; nếu nhập lại cùng ngày thì cập nhật bản ghi hiện có.
- Khi cân nặng thay đổi, hệ thống có thể tính lại BMI và đề xuất cập nhật calories nếu người dùng đồng ý.
- User chỉ xem và sửa hồ sơ sức khỏe của chính mình.

### 7.7. MVP scope

Bắt buộc trong MVP. Cần có hồ sơ sức khỏe, BMI, BMR, TDEE, calories target, macro target và weight log cơ bản.

---

## 8. Workout

### 8.1. Mục tiêu

Phân hệ Workout quản lý toàn bộ trải nghiệm luyện tập: thư viện bài tập, giáo án, lịch tập và nhật ký tập luyện. Đây là một trong các luồng cốt lõi của VieGym.

### 8.2. Tiểu phân hệ

| Tiểu phân hệ | Vai trò |
| ------------ | ------- |
| Exercise Library | Quản lý và hiển thị danh sách bài tập |
| Workout Builder | Tạo giáo án mẫu hoặc giáo án cá nhân |
| Workout Schedule | Tạo lịch tập, xem lịch, đánh dấu trạng thái buổi tập |
| Workout Tracking | Ghi nhận buổi tập, sets, reps, mức tạ, thời gian, PR |

### 8.3. Exercise Library

#### Chức năng

- Xem danh sách bài tập.
- Xem chi tiết bài tập.
- Tìm kiếm theo tên bài tập.
- Lọc theo nhóm cơ, thiết bị, độ khó.
- Hiển thị video/GIF minh họa, hướng dẫn và lỗi thường gặp.
- Admin thêm, sửa, ẩn bài tập.

#### Entity

| Entity      | Mô tả           |
| ----------- | --------------- |
| Exercise    | Bài tập         |
| MuscleGroup | Nhóm cơ         |
| Equipment   | Thiết bị tập    |

#### API

| Method | Endpoint | Mô tả |
| ------ | -------- | ----- |
| GET | `/api/v1/exercises` | Danh sách bài tập |
| GET | `/api/v1/exercises/{id}` | Chi tiết bài tập |

### 8.4. Workout Builder

#### Chức năng

- Chọn giáo án mẫu Push Pull Legs, Upper Lower, Full Body.
- Tạo giáo án custom.
- Thêm bài tập vào từng buổi.
- Cấu hình sets, reps, rest time và ghi chú.
- Chỉnh sửa giáo án sau khi tạo.
- Sinh lịch tập từ giáo án.

#### Entity

| Entity          | Mô tả                  |
| --------------- | ---------------------- |
| WorkoutProgram  | Giáo án tập            |
| WorkoutDay      | Buổi tập trong giáo án |
| WorkoutExercise | Bài tập thuộc buổi tập |

#### API

| Method | Endpoint | Mô tả |
| ------ | -------- | ----- |
| GET | `/api/v1/workout-programs` | Danh sách giáo án của user |
| POST | `/api/v1/workout-programs` | Tạo giáo án |
| PUT | `/api/v1/workout-programs/{id}` | Cập nhật giáo án |

### 8.5. Workout Schedule

#### Chức năng

- Tạo lịch tập thủ công.
- Sinh lịch tập từ giáo án.
- Xem lịch theo tuần/tháng.
- Sửa ngày, giờ, bài tập và ghi chú.
- Đánh dấu hoàn thành.
- Hủy hoặc ghi nhận missed.
- Gửi notification nhắc lịch nếu người dùng bật.

#### Trạng thái buổi tập

| Status | Mô tả |
| ------ | ----- |
| SCHEDULED | Đã lên lịch |
| COMPLETED | Đã hoàn thành |
| MISSED | Đã qua nhưng chưa hoàn thành |
| CANCELLED | Đã hủy |

#### Entity

| Entity | Mô tả |
| ------ | ----- |
| WorkoutSchedule | Lịch tập theo ngày/giờ |

#### API

| Method | Endpoint | Mô tả |
| ------ | -------- | ----- |
| GET | `/api/v1/workout-schedules` | Lấy lịch tập |
| POST | `/api/v1/workout-schedules` | Tạo lịch tập |
| PATCH | `/api/v1/workout-schedules/{id}/complete` | Đánh dấu hoàn thành |

### 8.6. Workout Tracking

#### Chức năng

- Ghi nhận buổi tập đã thực hiện.
- Lưu bài tập, sets, reps, mức tạ, thời gian tập và ghi chú.
- Liên kết workout log với schedule khi đánh dấu hoàn thành.
- Thống kê tổng số buổi tập, tổng thời gian, số buổi hoàn thành theo tuần/tháng.
- Tính Personal Record theo bài tập.
- Hiển thị tiến bộ theo mức tạ, reps hoặc volume.

#### Entity

| Entity        | Mô tả             |
| ------------- | ----------------- |
| WorkoutLog    | Nhật ký buổi tập  |
| WorkoutSetLog | Chi tiết từng set |

#### API

| Method | Endpoint | Mô tả |
| ------ | -------- | ----- |
| GET | `/api/v1/workout-logs` | Lấy lịch sử tập luyện |
| POST | `/api/v1/workout-logs` | Ghi nhận buổi tập |

### 8.7. Phụ thuộc

| Phụ thuộc | Mục đích |
| --------- | -------- |
| Identity & Auth | Xác định user sở hữu giáo án, lịch tập, workout log |
| Health Profile & Body Tracking | Dùng mục tiêu và chỉ số sức khỏe để gợi ý phù hợp |
| Media / Storage | Lưu video/GIF/ảnh bài tập |
| Notification | Nhắc lịch tập |
| Dashboard | Tổng hợp lịch tập, tỷ lệ hoàn thành, tiến độ |
| AI Coach & Sales AI | Cung cấp context luyện tập cho AI |
| Admin & Audit | Quản lý bài tập dùng chung |

### 8.8. Business rules

- Người dùng chỉ xem và chỉnh sửa giáo án, lịch tập, workout log của chính mình.
- Người dùng có thể có nhiều giáo án nhưng chỉ nên có một giáo án active tại một thời điểm.
- Bài tập inactive vẫn được giữ trong lịch sử cũ nhưng không cho thêm vào giáo án mới.
- Buổi tập quá hạn có thể tự chuyển sang MISSED theo job định kỳ hoặc khi người dùng mở app.
- PR được tính theo bài tập và có thể dựa trên mức tạ lớn nhất hoặc estimated 1RM.

### 8.9. MVP scope

MVP cần có Exercise Library, Workout Schedule cơ bản và Workout Log cơ bản. Workout Builder nên có bản tối giản với giáo án mẫu hoặc custom đơn giản; thống kê PR/volume nâng cao có thể làm sau.

---

## 9. Nutrition / Meal Planner

### 9.1. Mục tiêu

Phân hệ Nutrition / Meal Planner giúp người dùng Việt Nam lập thực đơn hằng ngày, theo dõi calories và macro dựa trên dữ liệu món ăn Việt Nam.

### 9.2. Chức năng chính

| Mã       | Chức năng             | Mô tả |
| -------- | --------------------- | ----- |
| NUTRI-01 | Quản lý dữ liệu món ăn | Lưu món ăn, khẩu phần, calories, protein, carbohydrate, fat, fiber, sodium |
| NUTRI-02 | Danh mục món ăn       | Phân loại cơm, phở/bún/mì, món thịt, rau, đồ uống, snack |
| NUTRI-03 | Tìm kiếm món ăn       | Tìm theo tên món hoặc thành phần |
| NUTRI-04 | Xem chi tiết món ăn   | Hiển thị dinh dưỡng theo khẩu phần |
| NUTRI-05 | Lập meal plan         | Tạo thực đơn theo ngày |
| NUTRI-06 | Thêm món vào bữa      | Thêm món vào bữa sáng, trưa, tối hoặc bữa phụ |
| NUTRI-07 | Điều chỉnh khẩu phần  | Tính lại calories/macro theo khẩu phần |
| NUTRI-08 | Tổng hợp dinh dưỡng   | Tính tổng calories, protein, carb, fat trong ngày |
| NUTRI-09 | So sánh với mục tiêu  | So sánh lượng đã nạp với calories/macro target |
| NUTRI-10 | Gợi ý/cảnh báo        | Cảnh báo vượt/thiếu và cung cấp context cho AI |

### 9.3. Entity sở hữu

| Entity          | Mô tả                      |
| --------------- | -------------------------- |
| Food            | Món ăn/thực phẩm           |
| FoodCategory    | Danh mục món ăn            |
| MealPlan        | Thực đơn theo ngày         |
| MealEntry       | Món ăn được thêm vào bữa   |
| NutritionTarget | Mục tiêu calories và macro |

### 9.4. API liên quan

| Method | Endpoint | Mô tả |
| ------ | -------- | ----- |
| GET | `/api/v1/foods` | Tìm kiếm/lọc món ăn |
| GET | `/api/v1/foods/{id}` | Chi tiết món ăn |
| GET | `/api/v1/meal-plans/today` | Thực đơn hôm nay |
| GET | `/api/v1/meal-plans` | Thực đơn theo ngày |
| POST | `/api/v1/meal-plans/entries` | Thêm món vào bữa |
| PUT | `/api/v1/meal-plans/entries/{id}` | Cập nhật khẩu phần |
| DELETE | `/api/v1/meal-plans/entries/{id}` | Xóa món khỏi bữa |

### 9.5. Phụ thuộc

| Phụ thuộc | Mục đích |
| --------- | -------- |
| Identity & Auth | Xác định user sở hữu meal plan |
| Health Profile & Body Tracking | Lấy calories/macro target |
| Media / Storage | Lưu ảnh món ăn |
| Dashboard | Tổng hợp calories/macro trong ngày |
| AI Coach & Sales AI | Cung cấp context dinh dưỡng |
| Admin & Audit | Quản lý/import dữ liệu món ăn |

### 9.6. Business rules

- Mỗi user có meal plan theo từng ngày.
- Tổng calories/macro bằng tổng các món đã thêm sau khi nhân với khẩu phần.
- Nếu calories đã nạp vượt mục tiêu, hệ thống hiển thị cảnh báo.
- Nếu calories/macro còn thiếu, hệ thống có thể gợi ý món ăn phù hợp.
- AI Coach có thể đọc meal plan hiện tại để tư vấn bổ sung hoặc thay thế món ăn.
- Hệ thống không nên phụ thuộc hoàn toàn vào API dinh dưỡng bên ngoài; dữ liệu món ăn Việt Nam cần được chuẩn hóa trong database nội bộ.

### 9.7. MVP scope

Bắt buộc trong MVP. Cần có dữ liệu món ăn Việt Nam mẫu, search food, food detail, meal plan theo ngày, meal entry theo bữa và tổng hợp calories/macro.

---

## 10. AI Coach & Sales AI

### 10.1. Mục tiêu

Phân hệ AI Coach & Sales AI cung cấp tư vấn bằng tiếng Việt cho luyện tập, dinh dưỡng và mua sắm sản phẩm gym. AI là điểm khác biệt quan trọng nhưng phải được kiểm soát bằng context, guardrail và giới hạn chi phí.

### 10.2. Chức năng chính

| Mã          | Chức năng             | Mô tả |
| ----------- | --------------------- | ----- |
| AI-01       | Tư vấn lịch tập       | Đề xuất lịch tập theo mục tiêu, số buổi/tuần, kinh nghiệm |
| AI-02       | Tư vấn bài tập        | Gợi ý bài tập theo nhóm cơ, thiết bị, độ khó |
| AI-03       | Giải thích kỹ thuật   | Hướng dẫn cách tập và lỗi thường gặp |
| AI-04       | Tư vấn dinh dưỡng     | Gợi ý calories, macro, món ăn phù hợp |
| AI-05       | Điều chỉnh kế hoạch   | Điều chỉnh lịch tập/thực đơn theo phản hồi |
| AI-06       | Chat theo ngữ cảnh    | Trả lời dựa trên hồ sơ, lịch tập, thực đơn, tiến độ |
| SALES-AI-01 | Tư vấn sản phẩm       | Gợi ý sản phẩm theo mục tiêu tập luyện |
| SALES-AI-02 | So sánh sản phẩm      | So sánh thành phần, giá, công dụng |
| SALES-AI-03 | Gợi ý theo ngân sách  | Đề xuất lựa chọn phù hợp ngân sách |
| SALES-AI-04 | Giải đáp thông tin    | Trả lời cách dùng, thời điểm dùng, lưu ý |
| SALES-AI-05 | Điều hướng mua hàng   | Gợi ý xem chi tiết hoặc thêm sản phẩm vào giỏ |

### 10.3. Entity sở hữu

| Entity           | Mô tả                          |
| ---------------- | ------------------------------ |
| AiConversation   | Cuộc trò chuyện với AI         |
| AiMessage        | Tin nhắn trong cuộc trò chuyện |
| AiRecommendation | Gợi ý AI sinh ra               |

### 10.4. API liên quan

| Method | Endpoint | Mô tả |
| ------ | -------- | ----- |
| POST | `/api/v1/ai/coach/chat` | Chat với AI Coach |
| POST | `/api/v1/ai/coach/workout-plan` | Tạo gợi ý lịch tập |
| POST | `/api/v1/ai/coach/meal-advice` | Tư vấn thực đơn |
| POST | `/api/v1/ai/sales/chat` | Chatbot tư vấn sản phẩm |

### 10.5. Context AI được phép sử dụng

Backend có thể chuẩn bị và gửi cho AI Service các nhóm dữ liệu sau:

- Mục tiêu tập luyện.
- Tuổi, giới tính, chiều cao, cân nặng.
- BMI, BMR, TDEE, calories mục tiêu.
- Macro mục tiêu.
- Lịch tập hiện tại.
- Lịch sử tập luyện gần đây.
- Thực đơn trong ngày.
- Sản phẩm người dùng đang quan tâm nếu ở luồng mua sắm.

### 10.6. Phụ thuộc

| Phụ thuộc | Mục đích |
| --------- | -------- |
| Identity & Auth | Xác định user và quyền truy cập hội thoại |
| Health Profile & Body Tracking | Context sức khỏe, mục tiêu, BMI/BMR/TDEE |
| Workout | Context lịch tập, bài tập, workout log |
| Nutrition / Meal Planner | Context meal plan, calories và macro |
| Shop & Order | Context sản phẩm cho Sales AI |
| FastAPI AI Service | Đóng gói prompt, guardrail và gọi provider |
| AI Provider | Sinh phản hồi AI |

### 10.7. Business rules và guardrail

- AI không được thay thế tư vấn y tế chuyên môn.
- Với câu hỏi về bệnh lý, chấn thương hoặc tình trạng sức khỏe nghiêm trọng, AI phải khuyến nghị người dùng hỏi bác sĩ/chuyên gia.
- Với thực phẩm bổ sung, AI phải khuyến nghị đọc kỹ hướng dẫn sử dụng và tham khảo chuyên gia nếu có bệnh lý.
- AI phải trả lời bằng tiếng Việt, dễ hiểu, phù hợp với người mới bắt đầu.
- Không gửi dữ liệu nhạy cảm không cần thiết sang AI Provider.
- Backend phải kiểm soát prompt, context và giới hạn token.
- Sales AI chỉ được gợi ý sản phẩm active và còn hàng nếu hệ thống quản lý tồn kho.

### 10.8. MVP scope

MVP cần AI Coach chat cơ bản có context từ hồ sơ sức khỏe, mục tiêu, meal plan và workout. Sales AI có thể làm mức cơ bản hoặc nâng cấp sau nếu thiếu thời gian.

---

## 11. Shop & Order

### 11.1. Mục tiêu

Phân hệ Shop & Order hỗ trợ người dùng xem sản phẩm gym, thêm vào giỏ hàng, đặt hàng và theo dõi đơn hàng.

### 11.2. Chức năng chính

| Mã      | Chức năng         | Mô tả |
| ------- | ----------------- | ----- |
| SHOP-01 | Xem danh mục      | Xem sản phẩm theo danh mục |
| SHOP-02 | Tìm kiếm sản phẩm | Tìm theo tên, thương hiệu, mục tiêu sử dụng |
| SHOP-03 | Xem chi tiết      | Xem ảnh, giá, mô tả, thành phần, cách dùng, tồn kho |
| SHOP-04 | Giỏ hàng          | Thêm, xóa, cập nhật số lượng sản phẩm |
| SHOP-05 | Đặt hàng          | Tạo đơn hàng từ giỏ hàng |
| SHOP-06 | Thanh toán        | Thanh toán COD hoặc online/sandbox |
| SHOP-07 | Theo dõi đơn hàng | Xem trạng thái đơn hàng |
| SHOP-08 | Quản lý đơn hàng  | Admin xem và cập nhật trạng thái đơn hàng |

### 11.3. Entity sở hữu

| Entity          | Mô tả                   |
| --------------- | ----------------------- |
| Product         | Sản phẩm                |
| ProductCategory | Danh mục sản phẩm       |
| Cart            | Giỏ hàng                |
| CartItem        | Sản phẩm trong giỏ      |
| Order           | Đơn hàng                |
| OrderItem       | Sản phẩm trong đơn hàng |
| Payment         | Giao dịch thanh toán    |
| ShippingAddress | Địa chỉ nhận hàng       |

### 11.4. Trạng thái đơn hàng

| Status | Mô tả |
| ------ | ----- |
| PENDING | Đơn hàng mới tạo, chờ xác nhận |
| CONFIRMED | Đã xác nhận |
| PAID | Đã thanh toán |
| SHIPPING | Đang giao hàng |
| COMPLETED | Hoàn thành |
| CANCELLED | Đã hủy |
| REFUNDED | Đã hoàn tiền |

### 11.5. API liên quan

| Method | Endpoint | Mô tả |
| ------ | -------- | ----- |
| GET | `/api/v1/products` | Danh sách sản phẩm |
| GET | `/api/v1/products/{id}` | Chi tiết sản phẩm |
| GET | `/api/v1/cart` | Xem giỏ hàng |
| POST | `/api/v1/cart/items` | Thêm sản phẩm vào giỏ |
| PUT | `/api/v1/cart/items/{id}` | Cập nhật số lượng |
| DELETE | `/api/v1/cart/items/{id}` | Xóa khỏi giỏ |
| POST | `/api/v1/orders` | Tạo đơn hàng |
| GET | `/api/v1/orders` | Danh sách đơn hàng của user |
| GET | `/api/v1/orders/{id}` | Chi tiết đơn hàng |
| POST | `/api/v1/payments` | Tạo thanh toán |

### 11.6. Phụ thuộc

| Phụ thuộc | Mục đích |
| --------- | -------- |
| Identity & Auth | Xác định user sở hữu cart/order |
| Media / Storage | Lưu ảnh sản phẩm |
| AI Coach & Sales AI | Cung cấp dữ liệu sản phẩm cho tư vấn bán hàng |
| Notification | Thông báo trạng thái đơn hàng |
| Payment Provider | Thanh toán online nếu có |
| Admin & Audit | Quản lý sản phẩm và đơn hàng |

### 11.7. Business rules

- Giá sản phẩm tại thời điểm đặt hàng phải được lưu vào order item.
- Không cho đặt số lượng vượt tồn kho nếu quản lý tồn kho realtime.
- Người dùng chỉ xem đơn hàng của chính mình.
- Admin có quyền xem và cập nhật trạng thái tất cả đơn hàng.
- Chatbot bán hàng chỉ gợi ý sản phẩm active và còn hàng nếu có quản lý tồn kho.

### 11.8. MVP scope

MVP cần product list, product detail, cart và create order cơ bản. Thanh toán online thật có thể dùng mock/sandbox hoặc để sau MVP.

---

## 12. Dashboard

### 12.1. Mục tiêu

Dashboard tổng hợp dữ liệu quan trọng để người dùng theo dõi tiến độ sức khỏe, dinh dưỡng, luyện tập và mua sắm. Dashboard không sở hữu dữ liệu gốc mà đọc từ các phân hệ khác.

### 12.2. Dashboard người dùng

| Nhóm | Thông tin hiển thị | Nguồn dữ liệu |
| ---- | ------------------ | ------------- |
| Dinh dưỡng | Calories mục tiêu, đã nạp, còn lại, protein, carbohydrate, fat | Nutrition, Health |
| Luyện tập | Lịch tập hôm nay, buổi tập tiếp theo, tỷ lệ hoàn thành tuần | Workout |
| Cơ thể | Cân nặng hiện tại, BMI, tiến độ mục tiêu | Health, WeightLog |
| Gợi ý | Gợi ý món ăn, bài tập hoặc sản phẩm | AI Coach, Shop |

### 12.3. Dashboard Admin

| Nhóm | Thông tin hiển thị | Nguồn dữ liệu |
| ---- | ------------------ | ------------- |
| Người dùng | Tổng số user, user active/locked nếu có | Identity & Auth |
| Nội dung | Tổng bài tập, món ăn, sản phẩm | Workout, Nutrition, Shop |
| Đơn hàng | Tổng đơn hàng, trạng thái đơn hàng | Shop & Order |
| Doanh thu | Doanh thu theo ngày/tháng nếu có thanh toán | Shop & Order, Payment |
| Phân tích | Sản phẩm bán chạy, món ăn/bài tập được xem nhiều nếu có tracking | Shop, Nutrition, Workout |

### 12.4. API liên quan

| Method | Endpoint | Mô tả |
| ------ | -------- | ----- |
| GET | `/api/v1/dashboard/me` | Dashboard người dùng |
| GET | `/api/v1/admin/dashboard` | Dashboard admin |

### 12.5. Business rules

- Dashboard người dùng chỉ tổng hợp dữ liệu của user hiện tại.
- Dashboard admin yêu cầu role ADMIN.
- Logic tính toán gốc nằm ở phân hệ sở hữu dữ liệu, Dashboard chỉ tổng hợp hoặc trình bày lại.
- Dashboard cần cập nhật sau khi user thêm món ăn, cập nhật cân nặng, hoàn thành buổi tập hoặc tạo đơn hàng.

### 12.6. MVP scope

Bắt buộc trong MVP. Cần có dashboard người dùng cơ bản với calories, macro, lịch tập hôm nay, cân nặng, BMI và tiến độ mục tiêu. Dashboard admin có thể làm bản tối giản.

---

## 13. Notification

### 13.1. Mục tiêu

Phân hệ Notification gửi nhắc nhở và thông báo theo các sự kiện quan trọng của người dùng.

### 13.2. Loại thông báo

| Loại thông báo | Mô tả | Nguồn trigger |
| -------------- | ----- | ------------- |
| Nhắc lịch tập | Gửi trước giờ tập theo cấu hình user | Workout Schedule |
| Nhắc nhập cân nặng | Nhắc cập nhật cân nặng định kỳ | Health / WeightLog |
| Nhắc meal plan | Nhắc nhập bữa ăn nếu chưa ghi nhận | Nutrition / Meal Planner |
| Cập nhật đơn hàng | Thông báo khi đơn hàng đổi trạng thái | Shop & Order |
| Gợi ý AI | Gợi ý tập luyện/dinh dưỡng nếu user bật | AI Coach |

### 13.3. Entity sở hữu

| Entity | Mô tả |
| ------ | ----- |
| Notification | Thông báo đã tạo/gửi cho user |
| NotificationSetting | Cấu hình bật/tắt từng loại notification |

### 13.4. API liên quan

| Method | Endpoint | Mô tả |
| ------ | -------- | ----- |
| GET | `/api/v1/notifications` | Danh sách thông báo của user |
| PATCH | `/api/v1/notifications/{id}/read` | Đánh dấu đã đọc |
| GET | `/api/v1/notification-settings/me` | Lấy cấu hình thông báo |
| PUT | `/api/v1/notification-settings/me` | Cập nhật cấu hình thông báo |

### 13.5. Phụ thuộc

| Phụ thuộc | Mục đích |
| --------- | -------- |
| Identity & Auth | Xác định user nhận thông báo |
| Workout Schedule | Nhắc lịch tập |
| Health Profile & Body Tracking | Nhắc nhập cân nặng |
| Nutrition / Meal Planner | Nhắc ghi nhận bữa ăn |
| Shop & Order | Thông báo trạng thái đơn hàng |
| Firebase/local notification | Gửi notification trên thiết bị |

### 13.6. Business rules

- User có thể bật/tắt notification.
- Không gửi thông báo marketing nếu user chưa đồng ý.
- Notification phải phù hợp múi giờ của user.
- Notification chỉ gửi khi user bật quyền thông báo trên thiết bị và trong cấu hình ứng dụng.

### 13.7. MVP scope

Có thể làm bản cơ bản trong MVP, ưu tiên nhắc lịch tập và thông báo trạng thái đơn hàng. Các nhắc nhở nâng cao có thể phát triển sau.

---

## 14. Admin & Audit

### 14.1. Mục tiêu

Phân hệ Admin & Audit hỗ trợ quản trị dữ liệu dùng chung của hệ thống và ghi nhận các thao tác quan trọng để phục vụ kiểm tra, demo và vận hành.

### 14.2. Chức năng chính

| Nhóm dữ liệu | Chức năng |
| ------------ | --------- |
| Người dùng | Xem danh sách, khóa/mở khóa, xem chi tiết |
| Bài tập | Thêm, sửa, ẩn, tìm kiếm, phân loại |
| Món ăn | Thêm, sửa, ẩn, import dữ liệu, chuẩn hóa dinh dưỡng |
| Sản phẩm | Thêm, sửa, ẩn, cập nhật giá/tồn kho |
| Đơn hàng | Xem, xác nhận, cập nhật trạng thái |
| Nội dung AI | Quản lý prompt mẫu, rule tư vấn, cảnh báo an toàn |
| Audit | Ghi nhận thao tác quan trọng của admin |

### 14.3. Entity liên quan

| Entity | Vai trò |
| ------ | ------- |
| User | Đối tượng quản lý tài khoản |
| Exercise | Nội dung bài tập dùng chung |
| Food | Dữ liệu món ăn Việt Nam |
| Product | Sản phẩm trong shop |
| Order | Đơn hàng cần xử lý |
| AuditLog | Nhật ký thao tác quan trọng |

### 14.4. API liên quan

| Method | Endpoint | Mô tả |
| ------ | -------- | ----- |
| GET | `/api/v1/admin/users` | Quản lý người dùng |
| GET/POST/PUT | `/api/v1/admin/exercises` | Quản lý bài tập |
| GET/POST/PUT | `/api/v1/admin/foods` | Quản lý món ăn |
| GET/POST/PUT | `/api/v1/admin/products` | Quản lý sản phẩm |
| GET/PUT | `/api/v1/admin/orders` | Quản lý đơn hàng |
| GET | `/api/v1/admin/dashboard` | Dashboard admin |

### 14.5. Phụ thuộc

| Phụ thuộc | Mục đích |
| --------- | -------- |
| Identity & Auth | Kiểm tra role ADMIN |
| Workout | Quản lý Exercise, MuscleGroup, Equipment |
| Nutrition | Quản lý Food, FoodCategory |
| Shop & Order | Quản lý Product, Order |
| Media / Storage | Upload ảnh/video cho bài tập, món ăn, sản phẩm |

### 14.6. Business rules

- Chỉ ADMIN được truy cập admin APIs.
- Admin không được xem mật khẩu hoặc refresh token của user.
- Các thao tác quan trọng nên được ghi AuditLog.
- Xóa dữ liệu chính nên dùng soft delete để tránh mất dữ liệu khi demo.
- Bài tập, món ăn, sản phẩm inactive không hiển thị cho user thường nhưng vẫn có thể được admin quản lý.

### 14.7. MVP scope

MVP nên có admin CRUD cơ bản cho bài tập, món ăn, sản phẩm và đơn hàng. Audit log có thể làm mức tối thiểu cho thao tác quan trọng.

---

## 15. Media / Storage

### 15.1. Mục tiêu

Phân hệ Media / Storage quản lý việc lưu trữ và truy cập ảnh, video, GIF phục vụ bài tập, món ăn và sản phẩm.

### 15.2. Chức năng chính

- Upload ảnh món ăn.
- Upload ảnh sản phẩm.
- Upload video/GIF bài tập.
- Validate MIME type, extension và kích thước file.
- Lưu metadata, object key hoặc URL vào database.
- Trả URL an toàn cho client.
- Xóa mềm hoặc vô hiệu hóa media khi nội dung bị inactive.

### 15.3. Dữ liệu liên quan

| Dữ liệu | Mô tả |
| ------- | ----- |
| objectKey | Khóa file trong object storage |
| originalFileName | Tên file gốc |
| contentType | MIME type |
| fileSize | Kích thước file |
| publicUrl/presignedUrl | URL truy cập nếu có |

### 15.4. Phụ thuộc

| Phụ thuộc | Mục đích |
| --------- | -------- |
| MinIO hoặc Amazon S3 | Lưu file media |
| Admin & Audit | Upload/quản lý media từ admin |
| Workout | Video/GIF bài tập |
| Nutrition | Ảnh món ăn |
| Shop & Order | Ảnh sản phẩm |

### 15.5. Business rules

- Không lưu ảnh/video/GIF trực tiếp trong database.
- File upload phải validate MIME type, extension và size.
- URL media cần được Backend kiểm soát hoặc storage cấu hình quyền phù hợp.
- Không expose storage secret cho Mobile App hoặc Admin Web.

### 15.6. MVP scope

MVP có thể dùng MinIO local trong Docker Compose hoặc URL seed sẵn. Upload đầy đủ có thể triển khai sau nếu cần rút gọn phạm vi demo.

---

## 16. Ma trận sở hữu dữ liệu và phụ thuộc

| Phân hệ | Sở hữu dữ liệu | Đọc từ | Được dùng bởi |
| ------- | -------------- | ------ | ------------- |
| Identity & Auth | User, UserProfile, RefreshToken, OtpCode | Redis, Google OAuth | Tất cả phân hệ private |
| Health Profile & Body Tracking | HealthProfile, WeightLog, NutritionTarget | Identity | Dashboard, Nutrition, AI Coach |
| Workout | Exercise, MuscleGroup, Equipment, WorkoutProgram, WorkoutDay, WorkoutExercise, WorkoutSchedule, WorkoutLog, WorkoutSetLog | Identity, Health, Media | Dashboard, AI Coach, Notification, Admin |
| Nutrition / Meal Planner | Food, FoodCategory, MealPlan, MealEntry | Identity, Health, Media | Dashboard, AI Coach, Admin |
| AI Coach & Sales AI | AiConversation, AiMessage, AiRecommendation | Identity, Health, Workout, Nutrition, Shop | Mobile App, Dashboard |
| Shop & Order | Product, ProductCategory, Cart, CartItem, Order, OrderItem, Payment, ShippingAddress | Identity, Media, Payment Provider | Sales AI, Dashboard, Notification, Admin |
| Dashboard | View model/tổng hợp tạm thời | Health, Workout, Nutrition, Shop, AI, Identity | Mobile App, Admin Web |
| Notification | Notification, NotificationSetting | Identity, Workout, Health, Nutrition, Shop, AI | Mobile App |
| Admin & Audit | AuditLog, thao tác quản trị | Identity, Workout, Nutrition, Shop, Media | Admin Web, vận hành hệ thống |
| Media / Storage | Metadata media, object key/URL | Object Storage | Workout, Nutrition, Shop, Admin |

Nguyên tắc ownership:

- Phân hệ sở hữu dữ liệu là nơi thực hiện validate và ghi dữ liệu gốc.
- Phân hệ khác không tự ghi trực tiếp vào bảng của phân hệ không sở hữu.
- Dashboard chỉ đọc và tổng hợp.
- AI chỉ nhận context đã được Backend lọc, không tự truy vấn database.
- Notification nhận trigger từ phân hệ nghiệp vụ nhưng tự sở hữu lịch sử thông báo.

---

## 17. Bảng API theo phân hệ

| Phân hệ | API group chính | Mục đích |
| ------- | --------------- | -------- |
| Identity & Auth | `/api/v1/auth/**`, `/api/v1/users/me` | Đăng ký, đăng nhập, token, hồ sơ cá nhân |
| Health Profile & Body Tracking | `/api/v1/health-profile/**`, `/api/v1/weight-logs/**` | Hồ sơ sức khỏe và cân nặng |
| Workout | `/api/v1/exercises/**`, `/api/v1/workout-programs/**`, `/api/v1/workout-schedules/**`, `/api/v1/workout-logs/**` | Bài tập, giáo án, lịch tập, log |
| Nutrition / Meal Planner | `/api/v1/foods/**`, `/api/v1/meal-plans/**` | Món ăn và thực đơn |
| AI Coach & Sales AI | `/api/v1/ai/**` | Chat AI, tư vấn lịch tập, thực đơn, sản phẩm |
| Shop & Order | `/api/v1/products/**`, `/api/v1/cart/**`, `/api/v1/orders/**`, `/api/v1/payments/**` | Sản phẩm, giỏ hàng, đơn hàng, thanh toán |
| Dashboard | `/api/v1/dashboard/**`, `/api/v1/admin/dashboard` | Tổng hợp dữ liệu user/admin |
| Notification | `/api/v1/notifications/**`, `/api/v1/notification-settings/**` | Thông báo và cấu hình thông báo |
| Admin & Audit | `/api/v1/admin/**` | Quản trị dữ liệu hệ thống |
| Media / Storage | `/api/v1/media/**` | Upload và truy cập media nếu triển khai |

---

## 18. MVP và hướng mở rộng

### 18.1. Bắt buộc trong MVP

| Nhóm | Chức năng |
| ---- | --------- |
| Auth | Đăng ký, đăng nhập, JWT, refresh token, logout, forgot/reset password cơ bản |
| Health | Hồ sơ sức khỏe, BMI, BMR, TDEE, calories/macro target |
| Dashboard | Dashboard người dùng cơ bản |
| Workout | Exercise Library, Workout Schedule, Workout Log cơ bản |
| Nutrition | Food Database món Việt, Food Search, Meal Planner trong ngày |
| AI | AI Coach chat cơ bản có context và guardrail |
| Shop | Product list, product detail, cart, create order cơ bản |
| Admin | CRUD cơ bản cho Exercise, Food, Product, Order |
| Media | Lưu hoặc tham chiếu ảnh/video/GIF phục vụ demo |

### 18.2. Nên có nếu kịp tiến độ

| Nhóm | Chức năng |
| ---- | --------- |
| AI | Gợi ý workout plan, meal advice theo context sâu hơn |
| Shop | Theo dõi đơn hàng đầy đủ, payment sandbox |
| Dashboard | Biểu đồ tiến bộ luyện tập, dinh dưỡng và cân nặng |
| Notification | Nhắc lịch tập, nhắc meal plan, nhắc cân nặng |
| Admin | Audit log và dashboard admin cơ bản |

### 18.3. Sau đồ án

| Nhóm | Chức năng |
| ---- | --------- |
| AI nâng cao | Nhận diện món ăn bằng ảnh, phân tích tư thế bằng camera |
| Tích hợp ngoài | Apple Health, Google Fit |
| Sản phẩm mở rộng | Web cho huấn luyện viên, quản lý phòng gym |
| Machine Learning | Dự đoán tiến độ, tối ưu lịch tập dài hạn |
| Commerce | Marketplace, affiliate, payment production đầy đủ |
| Premium | Giáo án nâng cao, phân tích chuyên sâu |

---

## 19. Ràng buộc bảo mật và phi chức năng

| Nhóm | Ràng buộc |
| ---- | --------- |
| Xác thực | Tất cả API riêng tư yêu cầu JWT hợp lệ |
| Phân quyền | USER chỉ dùng dữ liệu cá nhân; ADMIN dùng admin APIs |
| Ownership | User không được truy cập health profile, meal plan, workout log hoặc order của user khác |
| Token | Refresh token phải revoke được; JWT secret chỉ lưu server-side |
| Mật khẩu | Mật khẩu phải hash an toàn, không lưu plain text |
| OTP | OTP có thời hạn và giới hạn số lần thử |
| Upload | File upload validate MIME type, extension, size |
| AI | Không gửi dữ liệu nhạy cảm không cần thiết; có guardrail y tế/chấn thương/thực phẩm bổ sung |
| API | REST API trả JSON UTF-8, có Swagger/OpenAPI |
| Hiệu năng | API đọc phổ biến hướng đến P95 latency dưới 500ms trong môi trường MVP |
| Logging | Ghi log lỗi backend, AI request failure và thao tác quan trọng |
| Backup | Database cần có phương án backup khi triển khai thật |

---

## 20. Luồng dữ liệu tiêu biểu

### 20.1. Luồng tạo hồ sơ sức khỏe

```text
Mobile App
  -> Backend Auth kiểm tra JWT
  -> Health Profile validate dữ liệu
  -> Tính BMI/BMR/TDEE/calories/macro target
  -> Lưu HealthProfile, WeightLog, NutritionTarget
  -> Dashboard đọc dữ liệu mới
```

### 20.2. Luồng thêm món vào Meal Planner

```text
Mobile App
  -> Backend Auth kiểm tra JWT
  -> Nutrition kiểm tra Food active
  -> Meal Planner thêm MealEntry theo ngày và bữa
  -> Tính lại calories/macro đã nạp
  -> Dashboard cập nhật tổng dinh dưỡng
  -> AI Coach có thể dùng meal plan làm context
```

### 20.3. Luồng hoàn thành buổi tập

```text
Mobile App
  -> Backend Auth kiểm tra JWT
  -> Workout Schedule kiểm tra lịch thuộc user hiện tại
  -> Cập nhật trạng thái COMPLETED
  -> Workout Tracking tạo WorkoutLog/WorkoutSetLog nếu có dữ liệu tập
  -> Dashboard cập nhật tỷ lệ hoàn thành và tiến độ
```

### 20.4. Luồng chat AI Coach

```text
Mobile App
  -> Backend Auth kiểm tra JWT
  -> Backend lấy context được phép từ Health, Workout, Nutrition
  -> Backend gửi context tối thiểu sang FastAPI AI Service
  -> AI Service áp dụng prompt/guardrail và gọi AI Provider
  -> Backend lưu AiConversation/AiMessage
  -> Mobile App hiển thị phản hồi tiếng Việt
```

### 20.5. Luồng tạo đơn hàng

```text
Mobile App
  -> Backend Auth kiểm tra JWT
  -> Shop kiểm tra cart, product active, tồn kho nếu có
  -> Lưu Order và OrderItem với giá tại thời điểm đặt hàng
  -> Payment xử lý COD hoặc payment sandbox
  -> Notification gửi cập nhật đơn hàng nếu user bật
```

---

## 21. Tiêu chí hoàn thành tài liệu phân rã

Tài liệu phân rã được xem là đạt khi:

1. Bao phủ toàn bộ phân hệ trong phạm vi SRS.
2. Mỗi phân hệ có mục tiêu, chức năng, entity, API, phụ thuộc và MVP scope.
3. Có mapping rõ từ SRS sang phân hệ triển khai.
4. Có ma trận ownership dữ liệu và phụ thuộc giữa các phân hệ.
5. Có phân loại MVP, nên có và sau đồ án.
6. Có ràng buộc bảo mật, phân quyền và phi chức năng.
7. Không mâu thuẫn với kiến trúc trong `docs/spec/specs.md`.
8. Có thể dùng làm đầu vào để thiết kế package/module backend, Flutter feature module và Admin Web.

---

## 22. Ghi chú triển khai tiếp theo

Sau tài liệu này, nên tiếp tục hoàn thiện các tài liệu chi tiết hơn:

- `docs/spec/phan_ra_tinh_nang.md`: phân rã chức năng theo mã feature/use case.
- `docs/spec/phan_ra_man_hinh.md`: phân rã màn hình Mobile App và Admin Web.
- `docs/sa/server.md`: thiết kế module/package backend và API chi tiết.
- `docs/sa/sa.md`: kiến trúc tổng thể và sơ đồ triển khai.
- `docs/sa/techstack.md`: chốt công nghệ database, storage, AI provider và deployment.
