# Đặc tả Yêu cầu Hệ thống — VieGym

> Tài liệu đặc tả yêu cầu phần mềm (SRS) cho ứng dụng di động VieGym — nền tảng hỗ trợ luyện tập, dinh dưỡng và mua sắm dành cho người Việt, có tích hợp trí tuệ nhân tạo.

---

## Thông tin tài liệu

| Thuộc tính | Giá trị |
| --- | --- |
| Tên tài liệu | Đặc tả Yêu cầu Hệ thống VieGym |
| Loại tài liệu | Software Requirements Specification (SRS) |
| Phiên bản | 1.0 |
| Phạm vi áp dụng | Đồ án 6 tháng và nền tảng mở rộng startup sau này |
| File chính thức | `docs/spec/specs.md` |
| Ngôn ngữ | Tiếng Việt |

---

## 1. Tổng quan dự án

### 1.1. Tên đề tài

**Nghiên cứu và phát triển ứng dụng di động VieGym – Nền tảng hỗ trợ luyện tập, dinh dưỡng và mua sắm dành cho người Việt ứng dụng trí tuệ nhân tạo.**

### 1.2. Mục tiêu dự án

VieGym là ứng dụng di động hỗ trợ người dùng Việt Nam trong việc:

- Quản lý quá trình luyện tập thể hình.
- Quản lý chế độ dinh dưỡng hằng ngày.
- Theo dõi sự thay đổi của cơ thể theo thời gian.
- Nhận tư vấn luyện tập và dinh dưỡng thông qua AI Coach.
- Mua sắm các sản phẩm hỗ trợ tập luyện như whey protein, creatine, vitamin và phụ kiện gym.

Điểm khác biệt chính của VieGym so với nhiều ứng dụng nước ngoài là tập trung vào **người dùng Việt Nam**, **dữ liệu món ăn Việt Nam**, **giao diện tiếng Việt** và khả năng tư vấn phù hợp với thói quen ăn uống, luyện tập của người Việt.

### 1.3. Mục tiêu hệ thống

Hệ thống hướng đến giải quyết bốn bài toán chính:

| #   | Bài toán           | Mô tả                                                                          |
| --- | ------------------ | ------------------------------------------------------------------------------ |
| 1   | Quản lý luyện tập  | Tạo giáo án, xem bài tập, ghi nhận buổi tập, theo dõi tiến bộ                  |
| 2   | Quản lý dinh dưỡng | Tính nhu cầu calories, lập thực đơn, theo dõi macro, gợi ý món ăn Việt Nam     |
| 3   | Theo dõi cơ thể    | Theo dõi cân nặng, BMI, BMR, TDEE, biểu đồ thay đổi theo thời gian             |
| 4   | Hỗ trợ mua sắm     | Cửa hàng sản phẩm gym, giỏ hàng, đặt hàng, thanh toán, chatbot tư vấn sản phẩm |

---

## 2. Phạm vi hệ thống

### 2.1. Trong phạm vi

| #   | Phân hệ            | Mô tả                                                                                     |
| --- | ------------------ | ----------------------------------------------------------------------------------------- |
| 1   | Quản lý tài khoản  | Đăng ký, đăng nhập, Google Login, quên mật khẩu, OTP, đổi mật khẩu, cập nhật hồ sơ        |
| 2   | Hồ sơ sức khỏe     | Nhập chiều cao, cân nặng, tuổi, giới tính, mức độ vận động, mục tiêu; tính BMI/BMR/TDEE   |
| 3   | AI Coach           | Tư vấn lịch tập, bài tập, kỹ thuật tập, dinh dưỡng và điều chỉnh theo mục tiêu người dùng |
| 4   | Workout Builder    | Chọn hoặc tự tạo giáo án Push Pull Legs, Upper Lower, Full Body                           |
| 5   | Thư viện bài tập   | Danh sách bài tập có video/GIF, nhóm cơ, thiết bị, độ khó, hướng dẫn và lỗi thường gặp    |
| 6   | Theo dõi luyện tập | Ghi nhận bài tập, số hiệp, số lần lặp, mức tạ, thống kê PR và biểu đồ tiến bộ             |
| 7   | Lịch tập           | Tạo lịch, sửa lịch, xem theo tuần/tháng, đánh dấu hoàn thành, nhắc lịch qua thông báo     |
| 8   | Meal Planner       | Cơ sở dữ liệu món ăn Việt Nam, lập thực đơn, tính calories và macro theo ngày             |
| 9   | Theo dõi cân nặng  | Cập nhật cân nặng theo ngày, so sánh với mục tiêu, biểu đồ tăng/giảm                      |
| 10  | Cửa hàng           | Danh mục sản phẩm, chi tiết sản phẩm, giỏ hàng, đặt hàng, thanh toán, theo dõi đơn hàng   |
| 11  | Chatbot bán hàng   | AI tư vấn, so sánh, gợi ý sản phẩm theo mục tiêu, nhu cầu và ngân sách                    |
| 12  | Dashboard          | Tổng hợp calories, macro, lịch tập, cân nặng, tiến độ mục tiêu và buổi tập tiếp theo      |
| 13  | Quản trị dữ liệu   | Admin quản lý bài tập, món ăn, sản phẩm, đơn hàng và dữ liệu hệ thống                     |

### 2.2. Ngoài phạm vi phiên bản đồ án

Các chức năng sau được định hướng phát triển sau đồ án, chưa bắt buộc trong phiên bản 6 tháng:

- AI nhận diện món ăn từ hình ảnh.
- AI phân tích tư thế tập luyện bằng camera.
- Đồng bộ Apple Health và Google Fit.
- Phiên bản Web dành cho huấn luyện viên.
- Hệ thống quản lý phòng gym.
- Machine Learning dự đoán tiến độ và tối ưu lịch tập dài hạn.

### 2.3. MVP Cut

Phiên bản MVP cần ưu tiên hoàn thành luồng cốt lõi sau:

1. Người dùng đăng ký/đăng nhập.
2. Người dùng tạo hồ sơ sức khỏe.
3. Hệ thống tính BMI, BMR, TDEE và calories mục tiêu.
4. Người dùng xem dashboard cá nhân.
5. Người dùng xem thư viện bài tập và tạo lịch tập cơ bản.
6. Người dùng ghi nhận buổi tập.
7. Người dùng tìm kiếm món ăn Việt Nam và lập thực đơn trong ngày.
8. AI Coach tư vấn ở mức hội thoại dựa trên hồ sơ, mục tiêu và dữ liệu người dùng.
9. Cửa hàng hiển thị sản phẩm, thêm vào giỏ hàng và tạo đơn hàng cơ bản.

---

## 3. Thuật ngữ và viết tắt

| Thuật ngữ | Ý nghĩa |
| --- | --- |
| BMI | Body Mass Index — chỉ số khối cơ thể |
| BMR | Basal Metabolic Rate — năng lượng tiêu hao khi nghỉ ngơi |
| TDEE | Total Daily Energy Expenditure — tổng năng lượng tiêu hao mỗi ngày |
| Calories mục tiêu | Lượng kcal người dùng nên nạp mỗi ngày theo mục tiêu cá nhân |
| Macro | Các nhóm dinh dưỡng chính: protein, carbohydrate và fat |
| PR | Personal Record — thành tích tốt nhất của người dùng ở một bài tập |
| AI Coach | Trợ lý AI tư vấn luyện tập và dinh dưỡng |
| Meal Planner | Chức năng lập thực đơn và theo dõi dinh dưỡng hằng ngày |
| JWT | JSON Web Token dùng cho xác thực API |
| OTP | One-Time Password dùng để xác minh hoặc đặt lại mật khẩu |

---

## 4. Đối tượng sử dụng

| Actor            | Vai trò              | Quyền hạn chính                                                             |
| ---------------- | -------------------- | --------------------------------------------------------------------------- |
| Guest            | Khách chưa đăng nhập | Xem màn giới thiệu, đăng ký, đăng nhập, quên mật khẩu                       |
| User             | Người dùng ứng dụng  | Quản lý hồ sơ sức khỏe, lịch tập, thực đơn, cân nặng, đơn hàng, chat với AI |
| Admin            | Quản trị viên        | Quản lý người dùng, bài tập, món ăn, sản phẩm, đơn hàng, nội dung hệ thống  |
| AI Service       | Dịch vụ AI           | Nhận ngữ cảnh từ hệ thống và trả tư vấn luyện tập, dinh dưỡng, sản phẩm     |
| Payment Provider | Cổng thanh toán      | Xử lý giao dịch thanh toán đơn hàng                                         |

---

## 5. Phân hệ quản lý tài khoản

### 5.1. Chức năng

| Mã      | Chức năng        | Mô tả                                                             |
| ------- | ---------------- | ----------------------------------------------------------------- |
| AUTH-01 | Đăng ký          | Người dùng tạo tài khoản bằng email, mật khẩu và thông tin cơ bản |
| AUTH-02 | Đăng nhập        | Người dùng đăng nhập bằng email/mật khẩu                          |
| AUTH-03 | Đăng nhập Google | Người dùng đăng nhập bằng tài khoản Google                        |
| AUTH-04 | Quên mật khẩu    | Hệ thống gửi OTP hoặc liên kết đặt lại mật khẩu                   |
| AUTH-05 | Xác thực OTP     | Xác minh email/số điện thoại hoặc xác nhận đặt lại mật khẩu       |
| AUTH-06 | Đổi mật khẩu     | Người dùng đổi mật khẩu khi đã đăng nhập                          |
| AUTH-07 | Cập nhật hồ sơ   | Người dùng cập nhật họ tên, ngày sinh, giới tính, ảnh đại diện    |
| AUTH-08 | Đăng xuất        | Thu hồi refresh token và kết thúc phiên đăng nhập                 |

### 5.2. Business rules

- Email phải duy nhất trong hệ thống.
- Mật khẩu phải được hash bằng BCrypt hoặc thuật toán tương đương.
- Access Token dùng JWT, thời hạn ngắn.
- Refresh Token phải được lưu an toàn và có khả năng thu hồi khi đăng xuất.
- Tài khoản bị khóa hoặc vô hiệu hóa không được đăng nhập.
- Google Login phải liên kết với email duy nhất trong hệ thống.

---

## 6. Phân hệ hồ sơ sức khỏe

### 6.1. Dữ liệu người dùng nhập

| Trường             | Mô tả                                         | Bắt buộc |
| ------------------ | --------------------------------------------- | :------: |
| Họ tên             | Tên hiển thị của người dùng                   |    Có    |
| Tuổi/ngày sinh     | Dùng để tính BMR                              |    Có    |
| Giới tính          | Nam/Nữ/Khác                                   |    Có    |
| Chiều cao          | Đơn vị cm                                     |    Có    |
| Cân nặng           | Đơn vị kg                                     |    Có    |
| Mức độ vận động    | Ít vận động, nhẹ, vừa, cao, rất cao           |    Có    |
| Mục tiêu tập luyện | Giảm cân, tăng cân, tăng cơ, duy trì sức khỏe |    Có    |

### 6.2. Chỉ số hệ thống tính toán

| Chỉ số                | Ý nghĩa                                       |
| --------------------- | --------------------------------------------- |
| BMI                   | Chỉ số khối cơ thể                            |
| BMR                   | Năng lượng cơ thể tiêu hao khi nghỉ ngơi      |
| TDEE                  | Tổng năng lượng tiêu hao mỗi ngày             |
| Calories mục tiêu     | Lượng calories nên nạp mỗi ngày theo mục tiêu |
| Protein mục tiêu      | Lượng protein khuyến nghị mỗi ngày            |
| Carbohydrate mục tiêu | Lượng carbohydrate khuyến nghị mỗi ngày       |
| Fat mục tiêu          | Lượng chất béo khuyến nghị mỗi ngày           |

### 6.3. Công thức đề xuất

BMI:

```text
BMI = cân nặng (kg) / (chiều cao (m) * chiều cao (m))
```

BMR theo Mifflin-St Jeor:

```text
Nam: BMR = 10 * weightKg + 6.25 * heightCm - 5 * age + 5
Nữ:  BMR = 10 * weightKg + 6.25 * heightCm - 5 * age - 161
```

TDEE:

```text
TDEE = BMR * activityFactor
```

Activity factor:

| Mức độ vận động  | Hệ số |
| ---------------- | ----: |
| Ít vận động      |   1.2 |
| Vận động nhẹ     | 1.375 |
| Vận động vừa     |  1.55 |
| Vận động cao     | 1.725 |
| Vận động rất cao |   1.9 |

Calories mục tiêu:

| Mục tiêu | Quy tắc đề xuất                              |
| -------- | -------------------------------------------- |
| Giảm cân | TDEE - 300 đến 500 kcal                      |
| Tăng cân | TDEE + 300 đến 500 kcal                      |
| Tăng cơ  | TDEE + 200 đến 400 kcal, ưu tiên protein cao |
| Duy trì  | Gần bằng TDEE                                |

### 6.4. Business rules

- Mỗi lần người dùng cập nhật cân nặng hoặc hồ sơ sức khỏe, hệ thống lưu lịch sử để vẽ biểu đồ.
- Nếu thiếu dữ liệu bắt buộc, hệ thống không tính TDEE và phải yêu cầu hoàn thiện hồ sơ.
- Calories và macro mục tiêu phải được dùng làm cơ sở cho Dashboard, Meal Planner và AI Coach.

---

## 7. Phân hệ AI Coach

### 7.1. Mục tiêu

AI Coach là chức năng nổi bật của VieGym, hỗ trợ người dùng nhận tư vấn luyện tập, dinh dưỡng và giải đáp các câu hỏi liên quan đến gym bằng tiếng Việt.

### 7.2. Chức năng

| Mã    | Chức năng           | Mô tả                                                                   |
| ----- | ------------------- | ----------------------------------------------------------------------- |
| AI-01 | Tư vấn lịch tập     | Đề xuất lịch tập theo mục tiêu, số buổi/tuần và kinh nghiệm             |
| AI-02 | Tư vấn bài tập      | Gợi ý bài tập phù hợp với nhóm cơ, thiết bị và độ khó                   |
| AI-03 | Giải thích kỹ thuật | Hướng dẫn cách thực hiện bài tập và lỗi thường gặp                      |
| AI-04 | Tư vấn dinh dưỡng   | Đề xuất món ăn, calories và macro theo mục tiêu                         |
| AI-05 | Điều chỉnh kế hoạch | Điều chỉnh lịch tập/thực đơn theo phản hồi của người dùng               |
| AI-06 | Chat theo ngữ cảnh  | Trả lời dựa trên hồ sơ sức khỏe, lịch tập, thực đơn và tiến độ hiện tại |

### 7.3. Ngữ cảnh AI được phép sử dụng

AI Service có thể nhận các dữ liệu sau từ Backend:

- Mục tiêu tập luyện.
- Tuổi, giới tính, chiều cao, cân nặng.
- BMI, BMR, TDEE, calories mục tiêu.
- Lịch tập hiện tại.
- Lịch sử tập luyện gần đây.
- Thực đơn trong ngày.
- Mục tiêu macro.
- Sản phẩm người dùng đang quan tâm nếu đang ở luồng mua sắm.

### 7.4. Business rules

- AI không được thay thế tư vấn y tế chuyên môn.
- Với câu hỏi liên quan đến bệnh lý, chấn thương hoặc tình trạng sức khỏe nghiêm trọng, AI phải khuyến nghị người dùng hỏi bác sĩ/chuyên gia.
- AI phải trả lời bằng tiếng Việt, dễ hiểu, phù hợp với người mới bắt đầu.
- Không gửi dữ liệu nhạy cảm không cần thiết sang AI Provider.
- Backend phải kiểm soát prompt, context và giới hạn token để tránh chi phí vượt kiểm soát.

---

## 8. Phân hệ Workout Builder

### 8.1. Chức năng

Người dùng có thể chọn giáo án mẫu hoặc tự tạo giáo án cá nhân.

| Loại giáo án   | Mô tả                                                           |
| -------------- | --------------------------------------------------------------- |
| Push Pull Legs | Chia buổi theo nhóm đẩy, kéo, chân                              |
| Upper Lower    | Chia buổi thân trên và thân dưới                                |
| Full Body      | Tập toàn thân trong một buổi                                    |
| Custom         | Người dùng tự chọn bài tập, số hiệp, số lần lặp, thời gian nghỉ |

### 8.2. Dữ liệu giáo án

| Trường             | Mô tả                                     |
| ------------------ | ----------------------------------------- |
| Tên giáo án        | Tên do hệ thống hoặc người dùng đặt       |
| Mục tiêu           | Giảm cân, tăng cơ, tăng sức mạnh, duy trì |
| Số buổi/tuần       | Số ngày tập trong tuần                    |
| Danh sách buổi tập | Các ngày/buổi trong giáo án               |
| Danh sách bài tập  | Bài tập thuộc từng buổi                   |
| Sets               | Số hiệp                                   |
| Reps               | Số lần lặp                                |
| Rest time          | Thời gian nghỉ giữa các hiệp              |
| Note               | Ghi chú cá nhân                           |

### 8.3. Business rules

- Một người dùng có thể có nhiều giáo án nhưng chỉ nên có một giáo án đang hoạt động tại một thời điểm.
- Người dùng có thể chỉnh sửa giáo án sau khi tạo.
- Khi tạo lịch tập từ giáo án, hệ thống sinh các buổi tập tương ứng trong lịch.
- Nếu bài tập bị Admin ẩn hoặc xóa mềm, giáo án cũ vẫn giữ lịch sử nhưng không cho thêm bài tập đó vào giáo án mới.

---

## 9. Phân hệ thư viện bài tập

### 9.1. Dữ liệu bài tập

| Trường         | Mô tả                                             |
| -------------- | ------------------------------------------------- |
| Tên bài tập    | Tên tiếng Việt hoặc tiếng Anh phổ biến            |
| Video minh họa | URL video hoặc file lưu trên storage              |
| GIF minh họa   | Ảnh động minh họa động tác                        |
| Nhóm cơ chính  | Ngực, lưng, vai, tay, chân, bụng...               |
| Nhóm cơ phụ    | Các nhóm cơ phụ được tác động                     |
| Thiết bị       | Tạ đơn, tạ đòn, máy, dây kháng lực, bodyweight... |
| Độ khó         | Beginner, Intermediate, Advanced                  |
| Hướng dẫn      | Các bước thực hiện                                |
| Lỗi thường gặp | Các lỗi kỹ thuật người tập hay gặp                |
| Trạng thái     | Active/Inactive                                   |

### 9.2. Chức năng

- Xem danh sách bài tập.
- Xem chi tiết bài tập.
- Tìm kiếm theo tên bài tập.
- Lọc theo nhóm cơ.
- Lọc theo thiết bị.
- Lọc theo độ khó.
- Admin thêm, sửa, ẩn bài tập.

### 9.3. Business rules

- Người dùng chỉ thấy bài tập đang active.
- Admin có thể quản lý toàn bộ bài tập.
- Video/GIF phải được lưu bằng URL an toàn hoặc object storage.
- Nội dung hướng dẫn nên ưu tiên tiếng Việt.

---

## 10. Phân hệ theo dõi luyện tập

### 10.1. Chức năng

Sau mỗi buổi tập, người dùng có thể ghi nhận:

| Trường        | Mô tả                                   |
| ------------- | --------------------------------------- |
| Ngày tập      | Ngày hoàn thành buổi tập                |
| Bài tập       | Bài tập đã thực hiện                    |
| Số hiệp       | Tổng số hiệp                            |
| Số lần lặp    | Số reps mỗi hiệp                        |
| Mức tạ        | Khối lượng tạ theo kg                   |
| Thời gian tập | Tổng thời gian buổi tập                 |
| Ghi chú       | Cảm nhận, mức độ khó, tình trạng cơ thể |

### 10.2. Thống kê

Hệ thống cần thống kê:

- Tổng số buổi tập.
- Tổng thời gian tập.
- Số buổi hoàn thành trong tuần/tháng.
- Personal Record theo bài tập.
- Biểu đồ tiến bộ theo mức tạ/reps/volume.
- Tỷ lệ hoàn thành lịch tập.

### 10.3. Business rules

- Người dùng chỉ xem và chỉnh sửa lịch sử tập luyện của chính mình.
- PR được tính theo bài tập và có thể dựa trên mức tạ lớn nhất hoặc estimated 1RM.
- Khi người dùng đánh dấu hoàn thành buổi tập trong lịch, hệ thống liên kết dữ liệu với workout log.

---

## 11. Phân hệ lịch tập

### 11.1. Chức năng

| Mã     | Chức năng           | Mô tả                                      |
| ------ | ------------------- | ------------------------------------------ |
| SCH-01 | Tạo lịch tập        | Người dùng tạo lịch theo ngày/tuần/tháng   |
| SCH-02 | Sửa lịch            | Thay đổi ngày, giờ, bài tập, ghi chú       |
| SCH-03 | Xem lịch tuần       | Hiển thị lịch tập theo tuần                |
| SCH-04 | Xem lịch tháng      | Hiển thị lịch tập theo tháng               |
| SCH-05 | Đánh dấu hoàn thành | Người dùng đánh dấu buổi tập đã hoàn thành |
| SCH-06 | Nhắc lịch tập       | Gửi notification trước giờ tập             |

### 11.2. Trạng thái buổi tập

| Status    | Mô tả                        |
| --------- | ---------------------------- |
| SCHEDULED | Đã lên lịch                  |
| COMPLETED | Đã hoàn thành                |
| MISSED    | Đã qua nhưng chưa hoàn thành |
| CANCELLED | Đã hủy                       |

### 11.3. Business rules

- Người dùng có thể tạo lịch thủ công hoặc sinh lịch từ giáo án.
- Notification chỉ gửi khi người dùng bật quyền thông báo.
- Buổi tập quá hạn có thể tự chuyển sang MISSED theo job định kỳ hoặc khi người dùng mở app.

---

## 12. Phân hệ Meal Planner

### 12.1. Mục tiêu

Meal Planner là điểm khác biệt lớn của VieGym. Hệ thống cần có cơ sở dữ liệu dinh dưỡng món ăn Việt Nam, cho phép người dùng lập thực đơn hằng ngày và theo dõi calories, protein, carbohydrate, fat so với mục tiêu cá nhân.

### 12.2. Dữ liệu món ăn

| Trường       | Mô tả                                                 |
| ------------ | ----------------------------------------------------- |
| Tên món      | Ví dụ: cơm tấm, phở bò, bún chả, ức gà áp chảo        |
| Hình ảnh     | Ảnh món ăn                                            |
| Khẩu phần    | Đơn vị khẩu phần tiêu chuẩn                           |
| Calories     | kcal/khẩu phần                                        |
| Protein      | gram/khẩu phần                                        |
| Carbohydrate | gram/khẩu phần                                        |
| Fat          | gram/khẩu phần                                        |
| Fiber        | Chất xơ, nếu có                                       |
| Sodium       | Natri, nếu có                                         |
| Thành phần   | Nguyên liệu chính                                     |
| Danh mục     | Cơm, phở/bún/mì, món thịt, món rau, đồ uống, snack... |
| Trạng thái   | Active/Inactive                                       |

### 12.3. Chức năng người dùng

- Tìm kiếm món ăn.
- Xem thông tin dinh dưỡng từng món.
- Thêm món vào bữa sáng, bữa trưa, bữa tối hoặc bữa phụ.
- Điều chỉnh khẩu phần.
- Xem tổng calories và macro trong ngày.
- So sánh lượng đã nạp với mục tiêu.
- Nhận cảnh báo khi vượt hoặc thiếu calories/macro.
- Nhận gợi ý món ăn phù hợp.

### 12.4. Loại bữa ăn

| Meal type | Mô tả    |
| --------- | -------- |
| BREAKFAST | Bữa sáng |
| LUNCH     | Bữa trưa |
| DINNER    | Bữa tối  |
| SNACK     | Bữa phụ  |

### 12.5. Business rules

- Mỗi người dùng có một meal plan theo từng ngày.
- Tổng calories/macro được tính bằng tổng các món đã thêm sau khi nhân với khẩu phần.
- Nếu calories đã nạp vượt mục tiêu, hệ thống hiển thị cảnh báo.
- Nếu calories/macro còn thiếu, hệ thống gợi ý món ăn phù hợp.
- AI Coach có thể đọc meal plan hiện tại để tư vấn bổ sung hoặc thay thế món ăn.
- Không nên phụ thuộc hoàn toàn vào API dinh dưỡng bên ngoài; hệ thống nên xây dựng Food Service riêng với dữ liệu món ăn Việt Nam được chuẩn hóa trong MySQL.

---

## 13. Phân hệ theo dõi cân nặng

### 13.1. Chức năng

Người dùng cập nhật cân nặng theo ngày để theo dõi tiến độ.

| Trường   | Mô tả            |
| -------- | ---------------- |
| Cân nặng | Đơn vị kg        |
| Ngày đo  | Ngày ghi nhận    |
| Ghi chú  | Ghi chú tùy chọn |

### 13.2. Thống kê

- Cân nặng hiện tại.
- Cân nặng mục tiêu.
- Mức tăng/giảm so với tuần trước/tháng trước.
- Biểu đồ thay đổi cân nặng.
- Tỷ lệ hoàn thành mục tiêu.

### 13.3. Business rules

- Một ngày có thể có một bản ghi cân nặng chính; nếu nhập lại cùng ngày thì cập nhật bản ghi hiện có.
- Khi cân nặng thay đổi, hệ thống có thể tính lại BMI và khuyến nghị calories nếu người dùng đồng ý cập nhật.

---

## 14. Phân hệ cửa hàng

### 14.1. Danh mục sản phẩm

Hệ thống hỗ trợ bán các sản phẩm phục vụ luyện tập:

- Whey Protein.
- Creatine.
- Vitamin.
- Bình nước.
- Găng tay.
- Dây kháng lực.
- Phụ kiện tập luyện.

### 14.2. Chức năng

| Mã      | Chức năng         | Mô tả                                                |
| ------- | ----------------- | ---------------------------------------------------- |
| SHOP-01 | Xem danh mục      | Người dùng xem sản phẩm theo danh mục                |
| SHOP-02 | Tìm kiếm sản phẩm | Tìm sản phẩm theo tên, thương hiệu, mục tiêu sử dụng |
| SHOP-03 | Xem chi tiết      | Xem ảnh, giá, mô tả, thành phần, cách dùng, tồn kho  |
| SHOP-04 | Giỏ hàng          | Thêm, xóa, cập nhật số lượng sản phẩm                |
| SHOP-05 | Đặt hàng          | Tạo đơn hàng từ giỏ hàng                             |
| SHOP-06 | Thanh toán        | Thanh toán COD hoặc online tùy tích hợp              |
| SHOP-07 | Theo dõi đơn hàng | Xem trạng thái đơn hàng                              |
| SHOP-08 | Quản lý đơn hàng  | Admin xem và cập nhật trạng thái đơn hàng            |

### 14.3. Trạng thái đơn hàng

| Status    | Mô tả                          |
| --------- | ------------------------------ |
| PENDING   | Đơn hàng mới tạo, chờ xác nhận |
| CONFIRMED | Đã xác nhận                    |
| PAID      | Đã thanh toán                  |
| SHIPPING  | Đang giao hàng                 |
| COMPLETED | Hoàn thành                     |
| CANCELLED | Đã hủy                         |
| REFUNDED  | Đã hoàn tiền                   |

### 14.4. Business rules

- Giá sản phẩm tại thời điểm đặt hàng phải được lưu vào order item, không phụ thuộc giá sản phẩm thay đổi sau này.
- Không cho đặt số lượng vượt tồn kho nếu hệ thống quản lý tồn kho realtime.
- Người dùng chỉ xem đơn hàng của chính mình.
- Admin có quyền xem và cập nhật trạng thái tất cả đơn hàng.

---

## 15. Phân hệ Chatbot bán hàng

### 15.1. Chức năng

Chatbot bán hàng hỗ trợ người dùng trong quá trình chọn sản phẩm.

| Mã          | Chức năng            | Mô tả                                                  |
| ----------- | -------------------- | ------------------------------------------------------ |
| SALES-AI-01 | Tư vấn sản phẩm      | Gợi ý sản phẩm theo mục tiêu tập luyện                 |
| SALES-AI-02 | So sánh sản phẩm     | So sánh thành phần, giá, công dụng giữa các sản phẩm   |
| SALES-AI-03 | Gợi ý theo ngân sách | Đưa ra lựa chọn phù hợp với ngân sách người dùng       |
| SALES-AI-04 | Giải đáp thông tin   | Trả lời câu hỏi về cách dùng, thời điểm dùng, lưu ý    |
| SALES-AI-05 | Điều hướng mua hàng  | Gợi ý thêm sản phẩm vào giỏ hoặc xem chi tiết sản phẩm |

### 15.2. Business rules

- Chatbot chỉ được gợi ý sản phẩm đang active và còn hàng nếu có quản lý tồn kho.
- Chatbot không được đưa ra cam kết y tế hoặc điều trị bệnh.
- Với thực phẩm bổ sung, chatbot phải khuyến nghị người dùng đọc kỹ hướng dẫn sử dụng và tham khảo chuyên gia nếu có bệnh lý.

---

## 16. Dashboard

### 16.1. Dashboard người dùng

Trang chủ ứng dụng hiển thị các thông tin quan trọng:

| Nhóm       | Thông tin                                                      |
| ---------- | -------------------------------------------------------------- |
| Dinh dưỡng | Calories mục tiêu, đã nạp, còn lại, protein, carbohydrate, fat |
| Luyện tập  | Lịch tập hôm nay, buổi tập tiếp theo, tỷ lệ hoàn thành tuần    |
| Cơ thể     | Cân nặng hiện tại, BMI, tiến độ mục tiêu                       |
| Gợi ý      | Gợi ý món ăn, bài tập hoặc sản phẩm từ AI                      |

### 16.2. Dashboard Admin

Admin có thể xem:

- Tổng số người dùng.
- Tổng số bài tập.
- Tổng số món ăn.
- Tổng số sản phẩm.
- Tổng số đơn hàng.
- Doanh thu theo ngày/tháng nếu có thanh toán.
- Sản phẩm bán chạy.
- Món ăn/bài tập được xem nhiều.

---

## 17. Quản trị hệ thống

### 17.1. Admin quản lý dữ liệu

| Nhóm dữ liệu | Chức năng                                           |
| ------------ | --------------------------------------------------- |
| Người dùng   | Xem danh sách, khóa/mở khóa, xem chi tiết           |
| Bài tập      | Thêm, sửa, ẩn, tìm kiếm, phân loại                  |
| Món ăn       | Thêm, sửa, ẩn, import dữ liệu, chuẩn hóa dinh dưỡng |
| Sản phẩm     | Thêm, sửa, ẩn, cập nhật giá/tồn kho                 |
| Đơn hàng     | Xem, xác nhận, cập nhật trạng thái                  |
| Nội dung AI  | Quản lý prompt mẫu, rule tư vấn, cảnh báo an toàn   |

### 17.2. Business rules

- Admin không được xem mật khẩu hoặc refresh token của người dùng.
- Các thao tác quan trọng của Admin nên được ghi audit log.
- Xóa dữ liệu chính nên dùng soft delete để tránh mất dữ liệu trong quá trình làm đồ án và demo.

---

## 18. Kiến trúc hệ thống

### 18.1. Kiến trúc tổng quan

```text
Flutter Mobile App
        |
        | REST API / HTTPS
        v
Spring Boot Backend
        |
        |------------------- MySQL
        |------------------- Redis
        |------------------- MinIO / Amazon S3
        |
        v
Python FastAPI AI Service
        |
        v
OpenAI API hoặc Gemini API
```

### 18.2. Thành phần

| Thành phần       | Công nghệ                                     | Vai trò                                                |
| ---------------- | --------------------------------------------- | ------------------------------------------------------ |
| Mobile App       | Flutter                                       | Giao diện người dùng trên mobile                       |
| State Management | Riverpod                                      | Quản lý state phía Flutter                             |
| Backend API      | Spring Boot                                   | Xử lý nghiệp vụ, REST API, tích hợp DB/storage/payment |
| Security         | Spring Security + JWT                         | Xác thực và phân quyền                                 |
| Database         | MySQL                                         | Lưu dữ liệu chính                                      |
| Cache            | Redis                                         | Cache session, OTP, dữ liệu truy cập nhanh             |
| AI Service       | Python FastAPI                                | Đóng gói logic AI Coach/chatbot                        |
| AI Provider      | OpenAI API hoặc Gemini API                    | Sinh phản hồi AI                                       |
| Storage          | MinIO hoặc Amazon S3                          | Lưu ảnh món ăn, ảnh sản phẩm, video/GIF bài tập        |
| DevOps           | Docker, Docker Compose, Nginx, GitHub Actions | Triển khai và vận hành                                 |
| Design           | Figma                                         | Thiết kế UI/UX                                         |

### 18.3. Nguyên tắc thiết kế

- Mobile App không truy cập trực tiếp database.
- Backend Spring Boot là nguồn sự thật cho dữ liệu nghiệp vụ.
- AI Service không tự ý truy cập database; chỉ nhận context cần thiết từ Backend.
- Ảnh/video/file media lưu trên object storage, database chỉ lưu metadata và object key/URL.
- API cần có OpenAPI/Swagger để phục vụ báo cáo và kiểm thử.

---

## 19. Mô hình dữ liệu mức khái niệm

### 19.1. Nhóm tài khoản và hồ sơ

| Entity        | Mô tả                                                           |
| ------------- | --------------------------------------------------------------- |
| User          | Tài khoản người dùng                                            |
| UserProfile   | Thông tin cá nhân                                               |
| HealthProfile | Chiều cao, cân nặng, tuổi, giới tính, mức độ vận động, mục tiêu |
| WeightLog     | Lịch sử cân nặng                                                |
| RefreshToken  | Phiên đăng nhập                                                 |
| OtpCode       | Mã OTP xác thực                                                 |

### 19.2. Nhóm luyện tập

| Entity          | Mô tả                  |
| --------------- | ---------------------- |
| Exercise        | Bài tập                |
| MuscleGroup     | Nhóm cơ                |
| Equipment       | Thiết bị               |
| WorkoutProgram  | Giáo án tập            |
| WorkoutDay      | Buổi tập trong giáo án |
| WorkoutExercise | Bài tập thuộc buổi tập |
| WorkoutSchedule | Lịch tập               |
| WorkoutLog      | Nhật ký buổi tập       |
| WorkoutSetLog   | Chi tiết từng set      |

### 19.3. Nhóm dinh dưỡng

| Entity          | Mô tả                      |
| --------------- | -------------------------- |
| Food            | Món ăn/thực phẩm           |
| FoodCategory    | Danh mục món ăn            |
| MealPlan        | Thực đơn theo ngày         |
| MealEntry       | Món ăn được thêm vào bữa   |
| NutritionTarget | Mục tiêu calories và macro |

### 19.4. Nhóm cửa hàng

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

### 19.5. Nhóm AI và log

| Entity           | Mô tả                            |
| ---------------- | -------------------------------- |
| AiConversation   | Cuộc trò chuyện với AI           |
| AiMessage        | Tin nhắn trong cuộc trò chuyện   |
| AiRecommendation | Gợi ý AI sinh ra                 |
| AuditLog         | Nhật ký thao tác quan trọng      |
| Notification     | Thông báo nhắc lịch tập/đơn hàng |

---

## 20. API Requirements mức cao

### 20.1. Auth API

| Method | Endpoint                     | Mô tả                    |
| ------ | ---------------------------- | ------------------------ |
| POST   | /api/v1/auth/register        | Đăng ký                  |
| POST   | /api/v1/auth/login           | Đăng nhập                |
| POST   | /api/v1/auth/google          | Đăng nhập Google         |
| POST   | /api/v1/auth/refresh         | Cấp access token mới     |
| POST   | /api/v1/auth/logout          | Đăng xuất                |
| POST   | /api/v1/auth/forgot-password | Gửi OTP đặt lại mật khẩu |
| POST   | /api/v1/auth/verify-otp      | Xác thực OTP             |
| POST   | /api/v1/auth/reset-password  | Đặt lại mật khẩu         |

### 20.2. User & Health API

| Method | Endpoint                  | Mô tả                             |
| ------ | ------------------------- | --------------------------------- |
| GET    | /api/v1/users/me          | Lấy thông tin người dùng hiện tại |
| PUT    | /api/v1/users/me          | Cập nhật hồ sơ cá nhân            |
| GET    | /api/v1/health-profile/me | Lấy hồ sơ sức khỏe                |
| PUT    | /api/v1/health-profile/me | Tạo/cập nhật hồ sơ sức khỏe       |
| GET    | /api/v1/weight-logs       | Lấy lịch sử cân nặng              |
| POST   | /api/v1/weight-logs       | Thêm/cập nhật cân nặng            |

### 20.3. Workout API

| Method | Endpoint                                | Mô tả                            |
| ------ | --------------------------------------- | -------------------------------- |
| GET    | /api/v1/exercises                       | Danh sách bài tập                |
| GET    | /api/v1/exercises/{id}                  | Chi tiết bài tập                 |
| GET    | /api/v1/workout-programs                | Danh sách giáo án của người dùng |
| POST   | /api/v1/workout-programs                | Tạo giáo án                      |
| PUT    | /api/v1/workout-programs/{id}           | Cập nhật giáo án                 |
| GET    | /api/v1/workout-schedules               | Lấy lịch tập                     |
| POST   | /api/v1/workout-schedules               | Tạo lịch tập                     |
| PATCH  | /api/v1/workout-schedules/{id}/complete | Đánh dấu hoàn thành              |
| GET    | /api/v1/workout-logs                    | Lấy lịch sử tập luyện            |
| POST   | /api/v1/workout-logs                    | Ghi nhận buổi tập                |

### 20.4. Nutrition API

| Method | Endpoint                        | Mô tả               |
| ------ | ------------------------------- | ------------------- |
| GET    | /api/v1/foods                   | Tìm kiếm/lọc món ăn |
| GET    | /api/v1/foods/{id}              | Chi tiết món ăn     |
| GET    | /api/v1/meal-plans/today        | Thực đơn hôm nay    |
| GET    | /api/v1/meal-plans              | Thực đơn theo ngày  |
| POST   | /api/v1/meal-plans/entries      | Thêm món vào bữa    |
| PUT    | /api/v1/meal-plans/entries/{id} | Cập nhật khẩu phần  |
| DELETE | /api/v1/meal-plans/entries/{id} | Xóa món khỏi bữa    |

### 20.5. AI API

| Method | Endpoint                      | Mô tả                   |
| ------ | ----------------------------- | ----------------------- |
| POST   | /api/v1/ai/coach/chat         | Chat với AI Coach       |
| POST   | /api/v1/ai/coach/workout-plan | Tạo gợi ý lịch tập      |
| POST   | /api/v1/ai/coach/meal-advice  | Tư vấn thực đơn         |
| POST   | /api/v1/ai/sales/chat         | Chatbot tư vấn sản phẩm |

### 20.6. Shop API

| Method | Endpoint                | Mô tả                             |
| ------ | ----------------------- | --------------------------------- |
| GET    | /api/v1/products        | Danh sách sản phẩm                |
| GET    | /api/v1/products/{id}   | Chi tiết sản phẩm                 |
| GET    | /api/v1/cart            | Xem giỏ hàng                      |
| POST   | /api/v1/cart/items      | Thêm sản phẩm vào giỏ             |
| PUT    | /api/v1/cart/items/{id} | Cập nhật số lượng                 |
| DELETE | /api/v1/cart/items/{id} | Xóa khỏi giỏ                      |
| POST   | /api/v1/orders          | Tạo đơn hàng                      |
| GET    | /api/v1/orders          | Danh sách đơn hàng của người dùng |
| GET    | /api/v1/orders/{id}     | Chi tiết đơn hàng                 |
| POST   | /api/v1/payments        | Tạo thanh toán                    |

### 20.7. Admin API

| Method       | Endpoint                | Mô tả              |
| ------------ | ----------------------- | ------------------ |
| GET          | /api/v1/admin/users     | Quản lý người dùng |
| GET/POST/PUT | /api/v1/admin/exercises | Quản lý bài tập    |
| GET/POST/PUT | /api/v1/admin/foods     | Quản lý món ăn     |
| GET/POST/PUT | /api/v1/admin/products  | Quản lý sản phẩm   |
| GET/PUT      | /api/v1/admin/orders    | Quản lý đơn hàng   |
| GET          | /api/v1/admin/dashboard | Dashboard Admin    |

---

## 21. Giả định, ràng buộc và phụ thuộc

### 21.1. Giả định

- Người dùng có smartphone Android trong phạm vi demo đồ án; iOS là hướng mở rộng sau.
- Người dùng có kết nối Internet khi sử dụng các chức năng cần đồng bộ dữ liệu, AI hoặc mua hàng.
- Dữ liệu món ăn Việt Nam ban đầu được thu thập, chuẩn hóa và nhập vào MySQL bởi Admin hoặc script nội bộ.
- AI Provider hoạt động ổn định trong thời điểm demo; nếu provider lỗi, hệ thống trả thông báo lỗi thân thiện thay vì làm treo ứng dụng.
- Thanh toán online có thể tích hợp ở mức mô phỏng hoặc sandbox nếu chưa đăng ký cổng thanh toán thật.

### 21.2. Ràng buộc

- Giao diện và phản hồi AI mặc định sử dụng tiếng Việt.
- Mobile App không truy cập trực tiếp database hoặc AI Provider.
- API key, JWT secret, storage secret và payment secret chỉ được lưu ở server-side.
- Dữ liệu sức khỏe, thực đơn, lịch tập, workout log và đơn hàng là dữ liệu cá nhân; backend phải kiểm tra quyền truy cập theo user.
- Ảnh, video và GIF không lưu trực tiếp trong database.
- Phiên bản đồ án ưu tiên hoàn thiện MVP trong 6 tháng, các tính năng nâng cao được đưa vào hướng phát triển sau đồ án.

### 21.3. Phụ thuộc bên ngoài

| Phụ thuộc | Vai trò | Rủi ro |
| --- | --- | --- |
| OpenAI API hoặc Gemini API | Sinh phản hồi AI Coach/chatbot | Chi phí, rate limit, lỗi provider |
| Google OAuth | Đăng nhập Google | Cần cấu hình OAuth client đúng môi trường |
| Payment Provider | Thanh toán online | Có thể cần tài khoản merchant/sandbox |
| MinIO hoặc Amazon S3 | Lưu media | Cần cấu hình bucket, quyền truy cập và URL |
| Firebase/local notification | Nhắc lịch và thông báo | Cần quyền notification trên thiết bị |

---

## 22. Yêu cầu giao diện ngoài

### 22.1. Giao diện người dùng

- Mobile App cần hỗ trợ các màn chính: đăng nhập/đăng ký, hồ sơ sức khỏe, dashboard, workout, meal planner, AI Coach, shop, profile.
- Giao diện ưu tiên tiếng Việt, dễ dùng cho người mới tập gym.
- Các biểu đồ calories, macro, cân nặng và tiến bộ tập luyện phải dễ đọc trên màn hình điện thoại.
- Form nhập liệu cần có validation rõ ràng và thông báo lỗi dễ hiểu.

### 22.2. Giao diện phần mềm

| Thành phần | Giao tiếp |
| --- | --- |
| Flutter Mobile App ↔ Spring Boot Backend | REST API qua HTTPS |
| Spring Boot Backend ↔ MySQL | JDBC/JPA |
| Spring Boot Backend ↔ Redis | Redis protocol |
| Spring Boot Backend ↔ Object Storage | S3-compatible API |
| Spring Boot Backend ↔ FastAPI AI Service | HTTP API nội bộ |
| FastAPI AI Service ↔ AI Provider | Provider SDK/API |

### 22.3. Giao diện phần cứng

- Ứng dụng chạy trên smartphone; không yêu cầu thiết bị phần cứng chuyên dụng trong MVP.
- Camera, cảm biến sức khỏe, Apple Health và Google Fit chưa thuộc phạm vi bắt buộc của phiên bản đồ án.

### 22.4. Giao diện truyền thông

- Tất cả giao tiếp giữa mobile app và backend nên dùng HTTPS khi triển khai thật.
- API trả JSON UTF-8.
- Media được truy cập qua URL do backend kiểm soát hoặc object storage đã cấu hình quyền phù hợp.

---

## 23. Yêu cầu phi chức năng

| #   | Yêu cầu          | Chi tiết                                                                                           |
| --- | ---------------- | -------------------------------------------------------------------------------------------------- |
| 1   | Hiệu năng API    | P95 API latency < 500ms với các API đọc phổ biến trong môi trường MVP                              |
| 2   | Bảo mật          | Tất cả API riêng tư yêu cầu JWT; mật khẩu hash an toàn; phân quyền User/Admin                      |
| 3   | Riêng tư dữ liệu | Chỉ người dùng sở hữu dữ liệu mới được xem hồ sơ sức khỏe, lịch tập, thực đơn và đơn hàng của mình |
| 4   | Khả dụng         | Hệ thống hoạt động ổn định trong quá trình demo và kiểm thử                                        |
| 5   | Mở rộng          | Kiến trúc tách Mobile, Backend, AI Service, Database, Storage                                      |
| 6   | Dễ bảo trì       | REST API rõ ràng, có Swagger/OpenAPI, code chia theo module                                        |
| 7   | Đa nền tảng      | Flutter có thể build Android trước, mở rộng iOS sau                                                |
| 8   | Ngôn ngữ         | Giao diện và phản hồi AI mặc định bằng tiếng Việt                                                  |
| 9   | An toàn AI       | AI có guardrail với nội dung y tế, chấn thương, thực phẩm bổ sung                                  |
| 10  | Backup dữ liệu   | Database cần có quy trình backup khi triển khai thật                                               |
| 11  | Media storage    | Ảnh/video không lưu trực tiếp trong database                                                       |
| 12  | Logging          | Ghi log lỗi backend, AI request failure và thao tác quan trọng                                     |

---

## 24. Bảo mật và phân quyền

### 24.1. Vai trò

| Role  | Quyền                                                           |
| ----- | --------------------------------------------------------------- |
| USER  | Dùng các chức năng cá nhân: tập luyện, dinh dưỡng, AI, mua hàng |
| ADMIN | Quản trị dữ liệu hệ thống, người dùng, sản phẩm, đơn hàng       |

### 24.2. Quy tắc bảo mật

- Người dùng chỉ được truy cập dữ liệu thuộc tài khoản của mình.
- Admin có quyền quản trị dữ liệu dùng chung nhưng không được xem thông tin nhạy cảm như mật khẩu/token.
- API phải kiểm tra authorization ở backend, không chỉ ẩn nút ở frontend.
- Refresh token cần có cơ chế revoke khi logout.
- OTP phải có thời hạn và giới hạn số lần thử.
- File upload ảnh/video phải validate MIME type, kích thước và extension.
- Không lưu API key AI Provider ở mobile app; API key chỉ nằm ở server-side.

---

## 25. Notification Requirements

| Loại thông báo     | Mô tả                                                        |
| ------------------ | ------------------------------------------------------------ |
| Nhắc lịch tập      | Gửi trước giờ tập theo cấu hình người dùng                   |
| Nhắc nhập cân nặng | Nhắc người dùng cập nhật cân nặng định kỳ                    |
| Nhắc meal plan     | Nhắc nhập bữa ăn nếu chưa ghi nhận                           |
| Cập nhật đơn hàng  | Thông báo khi đơn hàng đổi trạng thái                        |
| Gợi ý AI           | Gợi ý tập luyện/dinh dưỡng nếu người dùng bật nhận thông báo |

Business rules:

- Người dùng có thể bật/tắt notification.
- Không gửi thông báo marketing nếu người dùng chưa đồng ý.
- Notification phải phù hợp múi giờ của người dùng.

---

## 26. Acceptance Criteria

| #   | Tiêu chí nghiệm thu                                                                                                    |
| --- | ---------------------------------------------------------------------------------------------------------------------- |
| 1   | Người dùng đăng ký, đăng nhập, đăng xuất và đặt lại mật khẩu thành công.                                               |
| 2   | Người dùng hoàn thiện hồ sơ sức khỏe và hệ thống tính đúng BMI, BMR, TDEE, calories mục tiêu.                          |
| 3   | Dashboard hiển thị calories mục tiêu, calories đã nạp, macro, lịch tập hôm nay, cân nặng hiện tại và tiến độ mục tiêu. |
| 4   | Người dùng xem được thư viện bài tập, tìm kiếm/lọc theo nhóm cơ, thiết bị và độ khó.                                   |
| 5   | Người dùng tạo được giáo án tập hoặc chọn giáo án mẫu.                                                                 |
| 6   | Người dùng tạo lịch tập, xem lịch theo tuần/tháng và đánh dấu hoàn thành buổi tập.                                     |
| 7   | Người dùng ghi nhận buổi tập với bài tập, sets, reps, mức tạ và xem lịch sử tiến bộ.                                   |
| 8   | Người dùng cập nhật cân nặng và xem biểu đồ thay đổi theo thời gian.                                                   |
| 9   | Người dùng tìm kiếm món ăn Việt Nam, xem dinh dưỡng và thêm vào từng bữa trong ngày.                                   |
| 10  | Meal Planner tự cộng calories, protein, carbohydrate, fat và so sánh với mục tiêu cá nhân.                             |
| 11  | AI Coach trả lời bằng tiếng Việt và tư vấn lịch tập/thực đơn dựa trên hồ sơ người dùng.                                |
| 12  | AI Coach có cảnh báo phù hợp với câu hỏi liên quan đến bệnh lý, chấn thương hoặc tư vấn y tế.                          |
| 13  | Người dùng xem sản phẩm, thêm vào giỏ hàng và tạo đơn hàng.                                                            |
| 14  | Chatbot bán hàng gợi ý sản phẩm phù hợp với mục tiêu, nhu cầu và ngân sách.                                            |
| 15  | Admin quản lý được bài tập, món ăn, sản phẩm, đơn hàng và người dùng.                                                  |
| 16  | API riêng tư không cho phép truy cập khi thiếu hoặc sai JWT.                                                           |
| 17  | Người dùng không xem được dữ liệu cá nhân, meal plan, workout log hoặc đơn hàng của người dùng khác.                   |
| 18  | Hệ thống có Swagger/OpenAPI phục vụ kiểm thử và tài liệu kỹ thuật.                                                     |
| 19  | Hệ thống có thể chạy bằng Docker Compose trong môi trường demo.                                                        |
| 20  | Dữ liệu món ăn Việt Nam được lưu trong database nội bộ thay vì phụ thuộc hoàn toàn vào API dinh dưỡng bên ngoài.       |

---

## 27. Kế hoạch thực hiện 6 tháng

| Thời gian | Công việc                                                                                                                                  |
| --------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| Tháng 1   | Khảo sát hệ thống tương tự, phân tích yêu cầu, xác định phạm vi, thiết kế UI/UX Figma, thiết kế CSDL, Use Case, ERD và kiến trúc hệ thống. |
| Tháng 2   | Xây dựng Backend: auth, JWT, quản lý tài khoản, hồ sơ sức khỏe, API bài tập, API thực phẩm, Meal Planner và CSDL hoàn chỉnh.               |
| Tháng 3   | Phát triển Flutter App: đăng nhập, hồ sơ sức khỏe, Dashboard, thư viện bài tập, lịch tập, Workout Builder và kết nối Backend.              |
| Tháng 4   | Hoàn thiện Meal Planner, import dữ liệu món ăn Việt Nam, xây dựng AI Coach, chatbot bán hàng, theo dõi cân nặng, thống kê và biểu đồ.      |
| Tháng 5   | Xây dựng cửa hàng, giỏ hàng, đặt hàng, thanh toán, tối ưu giao diện, kiểm thử chức năng, xử lý lỗi, tối ưu hiệu năng và bảo mật.           |
| Tháng 6   | Kiểm thử tổng thể, triển khai bằng Docker, viết báo cáo đồ án, hoàn thiện tài liệu kỹ thuật, quay video demo và chuẩn bị bảo vệ.           |

---

## 28. Hướng phát triển sau đồ án

- AI nhận diện món ăn từ hình ảnh.
- AI phân tích tư thế tập luyện bằng camera.
- Đồng bộ với Apple Health và Google Fit.
- Phiên bản Web dành cho huấn luyện viên.
- Hệ thống quản lý phòng gym.
- Gợi ý thực đơn cá nhân hóa dựa trên lịch sử người dùng.
- Machine Learning dự đoán tiến độ và tối ưu lịch tập.
- Marketplace cho huấn luyện viên và chuyên gia dinh dưỡng.
- Gói Premium với giáo án nâng cao và phân tích chuyên sâu.

---

## 29. Tài liệu liên quan

| Tài liệu            | Đường dẫn              |
| ------------------- | ---------------------- |
| Kế hoạch phát triển | [spec/plans.md](../../spec/plans.md) |
