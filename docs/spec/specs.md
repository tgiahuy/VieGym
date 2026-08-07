# Đặc tả Yêu cầu Hệ thống — VieGym

> Tài liệu đặc tả yêu cầu phần mềm (SRS) cho ứng dụng di động VieGym — nền tảng hỗ trợ luyện tập, dinh dưỡng và mua sắm dành cho người Việt, có tích hợp trí tuệ nhân tạo.

---

## Thông tin tài liệu

| Thuộc tính      | Giá trị                                           |
| --------------- | ------------------------------------------------- |
| Tên tài liệu    | Đặc tả Yêu cầu Hệ thống VieGym                    |
| Loại tài liệu   | Software Requirements Specification (SRS)         |
| Phiên bản       | 1.0                                               |
| Phạm vi áp dụng | Đồ án 6 tháng và nền tảng mở rộng startup sau này |
| File chính thức | `docs/spec/specs.md`                              |
| Ngôn ngữ        | Tiếng Việt                                        |

---

## 1. Tổng quan dự án

### 1.1. Tên đề tài

**Nghiên cứu và phát triển ứng dụng di động VieGym – Nền tảng AI Coach cá nhân hóa luyện tập, dinh dưỡng và theo dõi tiến độ sức khỏe dành cho người Việt.**

### 1.2. Mục tiêu dự án

VieGym là ứng dụng di động hỗ trợ người dùng Việt Nam trong việc:

- Quản lý quá trình luyện tập thể hình.
- Quản lý chế độ dinh dưỡng hằng ngày.
- Theo dõi sự thay đổi của cơ thể theo thời gian.
- Nhận tư vấn luyện tập, dinh dưỡng và điều chỉnh kế hoạch thông qua AI Coach cá nhân hóa.
- Nhận gợi ý hằng ngày và tổng kết tiến độ theo tuần dựa trên dữ liệu cá nhân được người dùng cho phép sử dụng.

Điểm khác biệt chính của VieGym so với nhiều ứng dụng nước ngoài là tập trung vào **người dùng Việt Nam**, **dữ liệu món ăn Việt Nam**, **giao diện tiếng Việt** và khả năng AI hóa tư vấn theo thể trạng, mục tiêu, lịch tập, thói quen ăn uống và tiến độ thực tế của từng người dùng.

### 1.3. Mục tiêu hệ thống

Hệ thống hướng đến giải quyết ba bài toán chính:

| #   | Bài toán               | Mô tả                                                                                 |
| --- | ---------------------- | ------------------------------------------------------------------------------------- |
| 1   | Quản lý luyện tập      | Tạo giáo án, xem bài tập, ghi nhận buổi tập, theo dõi tiến bộ                         |
| 2   | Quản lý dinh dưỡng     | Tính nhu cầu calories, lập thực đơn, theo dõi macro, gợi ý món ăn Việt Nam            |
| 3   | AI cá nhân hóa tiến độ | Phân tích hồ sơ, meal plan, workout log và cân nặng để đưa ra gợi ý phù hợp từng user |

### 1.4. Core user journey

Giá trị cốt lõi của VieGym được thể hiện qua vòng lặp sử dụng hằng ngày:

1. Người dùng hoàn thiện hồ sơ sức khỏe và mục tiêu cá nhân.
2. Hệ thống tính BMI, BMR, TDEE, calories và macro mục tiêu.
3. Người dùng lập thực đơn, ghi nhận bữa ăn và buổi tập.
4. Dashboard cập nhật tiến độ về dinh dưỡng, luyện tập và cân nặng.
5. AI Coach phân tích dữ liệu được phép sử dụng và đưa ra gợi ý điều chỉnh.
6. Người dùng xác nhận hoặc tự áp dụng thay đổi để tiếp tục cải thiện.

Core loop này giúp các phân hệ Health Profile, Meal Planner, Workout Log, Dashboard và AI Coach liên kết với nhau, tránh việc hệ thống chỉ là tập hợp các chức năng rời rạc.

---

## 2. Phạm vi hệ thống

### 2.1. Trong phạm vi

| #   | Phân hệ              | Mô tả                                                                                                              |
| --- | -------------------- | ------------------------------------------------------------------------------------------------------------------ |
| 1   | Quản lý tài khoản    | Đăng ký, đăng nhập, Google Login, quên mật khẩu, OTP, đổi mật khẩu, cập nhật hồ sơ                                 |
| 2   | Hồ sơ sức khỏe       | Nhập chiều cao, cân nặng, tuổi, giới tính, mức độ vận động, mục tiêu; tính BMI/BMR/TDEE                            |
| 3   | AI Coach cá nhân hóa | Tư vấn lịch tập, bài tập, dinh dưỡng, daily recommendation, weekly review và điều chỉnh kế hoạch theo dữ liệu user |
| 4   | Workout Builder      | Chọn hoặc tự tạo giáo án Push Pull Legs, Upper Lower, Full Body                                                    |
| 5   | Thư viện bài tập     | Danh sách bài tập có video/GIF, nhóm cơ, thiết bị, độ khó, hướng dẫn và lỗi thường gặp                             |
| 6   | Theo dõi luyện tập   | Ghi nhận bài tập, số hiệp, số lần lặp, mức tạ, thống kê PR và biểu đồ tiến bộ                                      |
| 7   | Lịch tập             | Tạo lịch, sửa lịch, xem theo tuần/tháng, đánh dấu hoàn thành, nhắc lịch qua thông báo                              |
| 8   | Meal Planner         | Cơ sở dữ liệu món ăn Việt Nam, lập thực đơn, tính calories và macro theo ngày                                      |
| 9   | Theo dõi cân nặng    | Cập nhật cân nặng theo ngày, so sánh với mục tiêu, biểu đồ tăng/giảm                                               |
| 10  | Dashboard            | Tổng hợp calories, macro, lịch tập, cân nặng, insight cá nhân hóa và buổi tập tiếp theo                            |
| 11  | Quản trị dữ liệu     | Admin quản lý bài tập, món ăn, import dữ liệu và rule/prompt AI                                                    |

### 2.2. Ngoài phạm vi phiên bản đồ án

Các chức năng sau được định hướng phát triển sau đồ án, chưa bắt buộc trong phiên bản 6 tháng:

- AI nhận diện món ăn từ hình ảnh.
- AI phân tích tư thế tập luyện bằng camera.
- Đồng bộ Apple Health và Google Fit.
- Phiên bản Web dành cho huấn luyện viên.
- Hệ thống quản lý phòng gym.
- Machine Learning dự đoán tiến độ và tối ưu lịch tập dài hạn.
- Shop bán sản phẩm gym, giỏ hàng, đặt hàng, thanh toán, affiliate hoặc marketplace.

### 2.3. MVP Cut

Phiên bản MVP cần ưu tiên hoàn thành luồng cốt lõi sau:

1. Người dùng đăng ký/đăng nhập.
2. Người dùng tạo hồ sơ sức khỏe.
3. Hệ thống tính BMI, BMR, TDEE và calories mục tiêu.
4. Người dùng xem dashboard cá nhân.
5. Người dùng xem thư viện bài tập và tạo lịch tập cơ bản.
6. Người dùng ghi nhận buổi tập.
7. Người dùng tìm kiếm món ăn Việt Nam và lập thực đơn trong ngày.
8. AI Coach tư vấn dựa trên hồ sơ, mục tiêu, meal plan, workout log và cân nặng nếu người dùng bật cá nhân hóa AI.
9. Hệ thống hiển thị AI Daily Recommendation trên Dashboard.
10. Người dùng xem AI Weekly Review để hiểu tiến độ và đề xuất điều chỉnh.

Để giảm rủi ro scope trong thời gian 6 tháng, MVP nên được chia thành hai mức:

| Mức MVP                       | Nhóm chức năng                                                                                                                                                        | Mục tiêu                                                                                              |
| ----------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| MVP bắt buộc                  | Auth, Onboarding, Health Profile, BMI/BMR/TDEE, Dashboard, Exercise Library, Workout Schedule/Log, Food Database, Meal Planner, Weight Tracking, AI Coach cá nhân hóa | Chứng minh giá trị cốt lõi của VieGym: theo dõi ăn uống, luyện tập và nhận tư vấn cá nhân hóa bằng AI |
| MVP mở rộng nếu còn thời gian | AI Daily Recommendation, AI Weekly Review, AI Plan Adjustment, Admin import dữ liệu món ăn/bài tập, quản lý prompt/rule AI                                            | Làm nổi bật khả năng AI hóa trải nghiệm người dùng nhưng không mở rộng sang e-commerce                |

Shop, thanh toán online, giỏ hàng và đặt hàng được chuyển sang hướng phát triển sau đồ án để MVP tập trung vào AI cá nhân hóa luyện tập và dinh dưỡng.

### 2.4. Phân tách MVP, bản đầy đủ và sau đồ án

| Chức năng                           |           MVP đồ án            |               Bản đầy đủ trong 6 tháng               |                  Sau đồ án                  |
| ----------------------------------- | :----------------------------: | :--------------------------------------------------: | :-----------------------------------------: |
| Đăng ký/đăng nhập/JWT               |               Có               |                          Có                          |                     Có                      |
| Hồ sơ sức khỏe và tính BMI/BMR/TDEE |               Có               |                          Có                          |                     Có                      |
| Dashboard cá nhân                   |               Có               |                          Có                          |                     Có                      |
| Thư viện bài tập                    |               Có               |                          Có                          |                     Có                      |
| Workout Builder                     |             Cơ bản             |                Đầy đủ template/custom                |           Cá nhân hóa bằng AI/ML            |
| Lịch tập và workout log             |               Có               |                          Có                          |         Đồng bộ wearable/health app         |
| Meal Planner món Việt               |               Có               |                          Có                          |          Cá nhân hóa theo lịch sử           |
| AI Coach                            | Chat cá nhân hóa theo ngữ cảnh | Daily recommendation, weekly review, plan adjustment |       Nhận diện ảnh, phân tích tư thế       |
| Shop                                |     Không thuộc MVP đồ án      |               Không thuộc bản 6 tháng                | Marketplace/affiliate, giỏ hàng, thanh toán |
| Admin                               |    Quản lý dữ liệu cốt lõi     |     Import dữ liệu, rule/prompt AI, audit cơ bản     |           CMS/analytics nâng cao            |

---

## 3. Thuật ngữ và viết tắt

| Thuật ngữ         | Ý nghĩa                                                            |
| ----------------- | ------------------------------------------------------------------ |
| BMI               | Body Mass Index — chỉ số khối cơ thể                               |
| BMR               | Basal Metabolic Rate — năng lượng tiêu hao khi nghỉ ngơi           |
| TDEE              | Total Daily Energy Expenditure — tổng năng lượng tiêu hao mỗi ngày |
| Calories mục tiêu | Lượng kcal người dùng nên nạp mỗi ngày theo mục tiêu cá nhân       |
| Macro             | Các nhóm dinh dưỡng chính: protein, carbohydrate và fat            |
| PR                | Personal Record — thành tích tốt nhất của người dùng ở một bài tập |
| AI Coach          | Trợ lý AI tư vấn luyện tập và dinh dưỡng                           |
| Meal Planner      | Chức năng lập thực đơn và theo dõi dinh dưỡng hằng ngày            |
| JWT               | JSON Web Token dùng cho xác thực API                               |
| OTP               | One-Time Password dùng để xác minh hoặc đặt lại mật khẩu           |

---

## 4. Đối tượng sử dụng

| Actor      | Vai trò              | Quyền hạn chính                                                                            |
| ---------- | -------------------- | ------------------------------------------------------------------------------------------ |
| Guest      | Khách chưa đăng nhập | Xem màn giới thiệu, đăng ký, đăng nhập, quên mật khẩu                                      |
| User       | Người dùng ứng dụng  | Quản lý hồ sơ sức khỏe, lịch tập, thực đơn, cân nặng, chat với AI và xem gợi ý cá nhân hóa |
| Admin      | Quản trị viên        | Quản lý người dùng, bài tập, món ăn, import dữ liệu và rule/prompt AI                      |
| AI Service | Dịch vụ AI           | Nhận ngữ cảnh từ hệ thống và trả tư vấn luyện tập, dinh dưỡng, tiến độ cá nhân hóa         |

---

## 5. Use Case tổng quát

### 5.1. Danh sách use case chính

| Mã    | Actor chính | Use case                                                  | Mức ưu tiên |
| ----- | ----------- | --------------------------------------------------------- | ----------- |
| UC-01 | Guest       | Đăng ký tài khoản                                         | Must        |
| UC-02 | Guest       | Đăng nhập                                                 | Must        |
| UC-03 | User        | Hoàn thiện hồ sơ sức khỏe                                 | Must        |
| UC-04 | User        | Xem dashboard cá nhân                                     | Must        |
| UC-05 | User        | Tạo/chỉnh sửa giáo án tập                                 | Must        |
| UC-06 | User        | Tạo lịch tập và đánh dấu hoàn thành                       | Must        |
| UC-07 | User        | Ghi nhận workout log                                      | Must        |
| UC-08 | User        | Lập thực đơn trong ngày                                   | Must        |
| UC-09 | User        | Chat với AI Coach cá nhân hóa                             | Should      |
| UC-10 | User        | Xem AI Daily Recommendation                               | Should      |
| UC-11 | User        | Xem AI Weekly Review                                      | Should      |
| UC-12 | User        | Bật/tắt cá nhân hóa AI                                    | Must        |
| UC-13 | Admin       | Quản lý bài tập, món ăn, import dữ liệu và rule/prompt AI | Should      |

### 5.2. Use case UC-03 — Hoàn thiện hồ sơ sức khỏe

| Thuộc tính     | Nội dung                                                                                                                                                                                 |
| -------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Actor          | User                                                                                                                                                                                     |
| Tiền điều kiện | User đã đăng nhập                                                                                                                                                                        |
| Luồng chính    | User nhập giới tính, tuổi/ngày sinh, chiều cao, cân nặng, mức độ vận động và mục tiêu; hệ thống validate dữ liệu; hệ thống tính BMI/BMR/TDEE/calories/macro mục tiêu; hệ thống lưu hồ sơ |
| Luồng thay thế | Nếu thiếu dữ liệu bắt buộc hoặc dữ liệu không hợp lệ, hệ thống hiển thị lỗi và yêu cầu nhập lại                                                                                          |
| Hậu điều kiện  | User có health profile để dùng cho Dashboard, Meal Planner và AI Coach                                                                                                                   |

### 5.3. Use case UC-08 — Lập thực đơn trong ngày

| Thuộc tính     | Nội dung                                                                                                                                             |
| -------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| Actor          | User                                                                                                                                                 |
| Tiền điều kiện | User đã đăng nhập và có hồ sơ sức khỏe                                                                                                               |
| Luồng chính    | User mở Meal Planner; tìm món ăn; chọn món ăn; nhập khẩu phần; hệ thống thêm món vào meal plan; hệ thống cộng calories/macro và so sánh với mục tiêu |
| Luồng thay thế | Nếu món ăn inactive hoặc khẩu phần không hợp lệ, hệ thống từ chối thao tác và hiển thị lỗi                                                           |
| Hậu điều kiện  | Meal plan trong ngày được cập nhật và Dashboard phản ánh tổng calories/macro mới                                                                     |

### 5.4. Use case UC-09 — Chat với AI Coach

| Thuộc tính     | Nội dung                                                                                                                |
| -------------- | ----------------------------------------------------------------------------------------------------------------------- |
| Actor          | User                                                                                                                    |
| Tiền điều kiện | User đã đăng nhập; AI Service khả dụng                                                                                  |
| Luồng chính    | User gửi câu hỏi; backend lấy context được phép; AI Service sinh phản hồi; backend lưu hội thoại; app hiển thị phản hồi |
| Luồng thay thế | Nếu AI Provider lỗi, hệ thống trả thông báo thân thiện và không làm mất câu hỏi của user                                |
| Hậu điều kiện  | User nhận được tư vấn bằng tiếng Việt; hội thoại được lưu lại                                                           |

---

## 6. Onboarding và cá nhân hóa

### 6.1. Mục tiêu onboarding

Onboarding giúp hệ thống thu thập dữ liệu ban đầu để cá nhân hóa calories, macro, lịch tập, gợi ý món ăn và tư vấn AI.

### 6.2. Dữ liệu onboarding

| Nhóm dữ liệu      | Ví dụ                                                          |
| ----------------- | -------------------------------------------------------------- |
| Mục tiêu chính    | Giảm mỡ, tăng cơ, tăng cân, duy trì sức khỏe                   |
| Kinh nghiệm tập   | Mới bắt đầu, trung bình, nâng cao                              |
| Lịch rảnh         | Số buổi có thể tập mỗi tuần, thời lượng mỗi buổi               |
| Thiết bị có sẵn   | Gym đầy đủ, tạ đơn, dây kháng lực, bodyweight                  |
| Thói quen ăn uống | Ăn cơm gia đình, ăn ngoài, tự nấu, ăn chay, ăn ít rau          |
| Hạn chế thực phẩm | Dị ứng, không ăn được một số nhóm thực phẩm, ghi chú tùy chọn  |
| Cá nhân hóa AI    | Cho phép hoặc không cho phép AI dùng dữ liệu cá nhân để tư vấn |

### 6.3. Personalization rules

- Calories và macro mục tiêu được tính từ Health Profile, activity factor và mục tiêu chính.
- Gợi ý món ăn dựa trên calories/macro còn thiếu trong ngày, loại bữa ăn và thói quen ăn uống.
- Gợi ý lịch tập dựa trên mục tiêu, kinh nghiệm, số buổi/tuần và thiết bị có sẵn.
- Gợi ý của AI tập trung vào món ăn, lịch tập, thói quen và điều chỉnh kế hoạch; không ưu tiên bán hàng trong MVP.
- AI Coach chỉ dùng dữ liệu cá nhân khi người dùng đã cho phép cá nhân hóa AI.
- Mọi đề xuất cá nhân hóa chỉ mang tính tham khảo; người dùng cần xác nhận trước khi hệ thống thay đổi meal plan, workout schedule hoặc cart.

---

## 7. Phân hệ quản lý tài khoản

### 7.1. Chức năng

| Mã      | Chức năng               | Mô tả                                                                                     |
| ------- | ----------------------- | ----------------------------------------------------------------------------------------- |
| AUTH-01 | Đăng ký                 | Người dùng tạo tài khoản bằng email, mật khẩu và thông tin cơ bản                         |
| AUTH-02 | Đăng nhập               | Người dùng đăng nhập bằng email/mật khẩu                                                  |
| AUTH-03 | Đăng nhập Google        | Người dùng đăng nhập bằng tài khoản Google                                                |
| AUTH-04 | Quên mật khẩu           | Hệ thống gửi OTP hoặc liên kết đặt lại mật khẩu                                           |
| AUTH-05 | Xác thực OTP            | Xác minh email/số điện thoại hoặc xác nhận đặt lại mật khẩu                               |
| AUTH-06 | Đổi mật khẩu            | Người dùng đổi mật khẩu khi đã đăng nhập                                                  |
| AUTH-07 | Cập nhật hồ sơ          | Người dùng cập nhật họ tên, ngày sinh, giới tính, ảnh đại diện                            |
| AUTH-08 | Đăng xuất               | Thu hồi refresh token và kết thúc phiên đăng nhập                                         |
| AUTH-09 | Đăng nhập sinh trắc học | Người dùng mở khóa phiên đăng nhập đã lưu bằng Face ID hoặc vân tay trên thiết bị cá nhân |

### 7.2. Business rules

- Email phải duy nhất trong hệ thống.
- Mật khẩu phải được hash bằng BCrypt hoặc thuật toán tương đương.
- Access Token dùng JWT, thời hạn ngắn.
- Refresh Token phải được lưu an toàn và có khả năng thu hồi khi đăng xuất.
- Tài khoản bị khóa hoặc vô hiệu hóa không được đăng nhập.
- Google Login phải liên kết với email duy nhất trong hệ thống.
- Đăng nhập sinh trắc học chỉ được bật sau khi người dùng đăng nhập thành công ít nhất một lần bằng email/mật khẩu hoặc Google.
- Face ID/vân tay chỉ dùng để mở khóa phiên đăng nhập đã lưu trên thiết bị, không thay thế cơ chế xác thực backend.
- Ứng dụng không được lưu mật khẩu hoặc dữ liệu sinh trắc học; refresh token phải được lưu bằng secure storage của thiết bị.
- Khi xác thực sinh trắc học thành công, ứng dụng dùng refresh token để gọi API cấp access token mới.
- Nếu xác thực sinh trắc học thất bại, bị hủy, thiết bị không còn hỗ trợ biometric hoặc refresh token hết hạn, hệ thống phải đưa người dùng về màn hình đăng nhập thường.
- Người dùng phải có tùy chọn bật/tắt đăng nhập sinh trắc học trong phần cài đặt tài khoản.

### 7.3. Use case AUTH-09 — Đăng nhập sinh trắc học

| Thuộc tính     | Nội dung                                                                                                                                                                                                                            |
| -------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Actor          | User                                                                                                                                                                                                                                |
| Tiền điều kiện | User đã đăng nhập thành công trước đó; thiết bị hỗ trợ Face ID/vân tay; user đã bật đăng nhập sinh trắc học; refresh token còn hiệu lực trong secure storage                                                                        |
| Luồng chính    | User mở app; app kiểm tra cấu hình biometric và refresh token; app hiển thị prompt Face ID/vân tay; user xác thực thành công; app gọi `/api/v1/auth/refresh`; backend cấp access token mới; app chuyển vào màn hình chính           |
| Luồng thay thế | Nếu user hủy prompt, xác thực thất bại, thiết bị không hỗ trợ biometric, biometric chưa được thiết lập hoặc refresh token không hợp lệ/hết hạn, app xóa trạng thái phiên không hợp lệ nếu cần và hiển thị màn hình đăng nhập thường |
| Hậu điều kiện  | User được đăng nhập nhanh trên thiết bị đã bật biometric; backend vẫn kiểm soát phiên bằng JWT và refresh token                                                                                                                     |

### 7.4. Luồng bật/tắt đăng nhập sinh trắc học

- Sau khi đăng nhập thành công, nếu thiết bị hỗ trợ Face ID/vân tay, app có thể gợi ý user bật đăng nhập sinh trắc học.
- Khi user chọn bật, app phải yêu cầu xác thực Face ID/vân tay một lần trước khi lưu trạng thái `biometric_enabled`.
- Khi user chọn tắt, app xóa trạng thái `biometric_enabled` trên thiết bị hiện tại nhưng không bắt buộc đăng xuất khỏi tài khoản.
- Khi user đăng xuất, app phải xóa access token, refresh token và trạng thái biometric trên thiết bị hiện tại.
- Cấu hình biometric là theo từng thiết bị, không đồng bộ tự động sang thiết bị khác.

### 7.5. Yêu cầu bảo mật cho đăng nhập sinh trắc học

- Dữ liệu Face ID/vân tay không được gửi lên backend và không được lưu trong database.
- Mobile app không được lưu mật khẩu người dùng để phục vụ đăng nhập nhanh.
- Refresh token phải được lưu trong secure storage của hệ điều hành, ví dụ Keychain trên iOS hoặc Keystore trên Android thông qua thư viện bảo mật phù hợp.
- Backend chỉ lưu hash của refresh token và phải hỗ trợ revoke token khi logout.
- API private vẫn phải yêu cầu access token hợp lệ; biometric chỉ là bước xác thực cục bộ để lấy lại access token qua refresh token.

---

## 8. Phân hệ hồ sơ sức khỏe

### 8.1. Dữ liệu người dùng nhập

| Trường             | Mô tả                                         | Bắt buộc |
| ------------------ | --------------------------------------------- | :------: |
| Họ tên             | Tên hiển thị của người dùng                   |    Có    |
| Tuổi/ngày sinh     | Dùng để tính BMR                              |    Có    |
| Giới tính          | Nam/Nữ/Khác                                   |    Có    |
| Chiều cao          | Đơn vị cm                                     |    Có    |
| Cân nặng           | Đơn vị kg                                     |    Có    |
| Mức độ vận động    | Ít vận động, nhẹ, vừa, cao, rất cao           |    Có    |
| Mục tiêu tập luyện | Giảm cân, tăng cân, tăng cơ, duy trì sức khỏe |    Có    |

### 8.2. Chỉ số hệ thống tính toán

| Chỉ số                | Ý nghĩa                                       |
| --------------------- | --------------------------------------------- |
| BMI                   | Chỉ số khối cơ thể                            |
| BMR                   | Năng lượng cơ thể tiêu hao khi nghỉ ngơi      |
| TDEE                  | Tổng năng lượng tiêu hao mỗi ngày             |
| Calories mục tiêu     | Lượng calories nên nạp mỗi ngày theo mục tiêu |
| Protein mục tiêu      | Lượng protein khuyến nghị mỗi ngày            |
| Carbohydrate mục tiêu | Lượng carbohydrate khuyến nghị mỗi ngày       |
| Fat mục tiêu          | Lượng chất béo khuyến nghị mỗi ngày           |

### 8.3. Công thức đề xuất

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

### 8.4. Business rules

- Mỗi lần người dùng cập nhật cân nặng hoặc hồ sơ sức khỏe, hệ thống lưu lịch sử để vẽ biểu đồ.
- Nếu thiếu dữ liệu bắt buộc, hệ thống không tính TDEE và phải yêu cầu hoàn thiện hồ sơ.
- Calories và macro mục tiêu phải được dùng làm cơ sở cho Dashboard, Meal Planner và AI Coach.

---

## 9. Phân hệ AI Coach

### 9.1. Mục tiêu

AI Coach là chức năng nổi bật của VieGym, hỗ trợ người dùng nhận tư vấn luyện tập, dinh dưỡng và giải đáp các câu hỏi liên quan đến gym bằng tiếng Việt.

### 9.2. Chức năng

| Mã    | Chức năng                | Mô tả                                                                            |
| ----- | ------------------------ | -------------------------------------------------------------------------------- |
| AI-01 | Tư vấn lịch tập          | Đề xuất lịch tập theo mục tiêu, số buổi/tuần và kinh nghiệm                      |
| AI-02 | Tư vấn bài tập           | Gợi ý bài tập phù hợp với nhóm cơ, thiết bị và độ khó                            |
| AI-03 | Giải thích kỹ thuật      | Hướng dẫn cách thực hiện bài tập và lỗi thường gặp                               |
| AI-04 | Tư vấn dinh dưỡng        | Đề xuất món ăn, calories và macro theo mục tiêu                                  |
| AI-05 | Điều chỉnh kế hoạch      | Điều chỉnh lịch tập/thực đơn theo phản hồi của người dùng                        |
| AI-06 | Chat theo ngữ cảnh       | Trả lời dựa trên hồ sơ sức khỏe, lịch tập, thực đơn và tiến độ hiện tại          |
| AI-07 | Daily Recommendation     | Tạo gợi ý hôm nay dựa trên calories/macro còn thiếu, lịch tập và tiến độ gần đây |
| AI-08 | Weekly Review            | Tổng kết meal, workout, cân nặng và mức độ tuân thủ theo tuần                    |
| AI-09 | Plan Adjustment          | Đề xuất thay đổi lịch tập, calories/macro hoặc meal plan nhưng cần user xác nhận |
| AI-10 | Lưu phản hồi cá nhân hóa | Ghi nhận món không thích, thiết bị thiếu, thời gian rảnh hoặc ràng buộc cá nhân  |

### 9.3. Ngữ cảnh AI được phép sử dụng

AI Service có thể nhận các dữ liệu sau từ Backend:

- Mục tiêu tập luyện.
- Tuổi, giới tính, chiều cao, cân nặng.
- BMI, BMR, TDEE, calories mục tiêu.
- Lịch tập hiện tại.
- Lịch sử tập luyện gần đây.
- Thực đơn trong ngày.
- Mục tiêu macro.
- Xu hướng cân nặng gần đây.
- Tỷ lệ hoàn thành lịch tập trong tuần.
- Sở thích, hạn chế thực phẩm, thiết bị có sẵn và phản hồi cá nhân hóa đã lưu.

### 9.4. Business rules

- AI không được thay thế tư vấn y tế chuyên môn.
- Với câu hỏi liên quan đến bệnh lý, chấn thương hoặc tình trạng sức khỏe nghiêm trọng, AI phải khuyến nghị người dùng hỏi bác sĩ/chuyên gia.
- AI phải trả lời bằng tiếng Việt, dễ hiểu, phù hợp với người mới bắt đầu.
- Không gửi dữ liệu nhạy cảm không cần thiết sang AI Provider.
- Backend phải kiểm soát prompt, context và giới hạn token để tránh chi phí vượt kiểm soát.
- AI chỉ đưa ra đề xuất; các thay đổi vào lịch tập hoặc meal plan chỉ được áp dụng khi người dùng xác nhận.
- AI không được chẩn đoán bệnh, kê đơn thuốc, cam kết hiệu quả điều trị hoặc khuyến nghị chế độ giảm cân cực đoan.
- Với thực phẩm bổ sung, AI phải trình bày ở mức thông tin tham khảo và khuyến nghị đọc hướng dẫn sử dụng.

### 9.5. Quyền riêng tư và consent cho AI

Người dùng cần được biết dữ liệu nào có thể được dùng để cá nhân hóa tư vấn AI. Hệ thống nên hỗ trợ:

- Tùy chọn bật/tắt việc cho phép AI dùng hồ sơ sức khỏe, meal plan và workout log để tư vấn.
- Chỉ gửi context tối thiểu cần thiết cho câu hỏi hiện tại.
- Không gửi mật khẩu, token, email, số điện thoại hoặc dữ liệu không liên quan sang AI Provider.
- Khi user tắt cá nhân hóa AI, AI Coach vẫn có thể trả lời kiến thức chung nhưng không dùng dữ liệu cá nhân.
- Log hội thoại AI cần được bảo vệ như dữ liệu cá nhân và chỉ user sở hữu mới được xem.

### 9.6. AI Daily Recommendation

Dashboard có thể hiển thị gợi ý ngắn hằng ngày từ AI, ví dụ:

- Hôm nay bạn còn thiếu 35 g protein; có thể thêm trứng luộc hoặc ức gà nếu phù hợp khẩu vị.
- Hôm nay có lịch tập chân; nên ưu tiên ngủ đủ và ăn đủ carbohydrate trước buổi tập.
- Tuần này bạn mới hoàn thành 1/3 buổi tập; hãy chọn một buổi ngắn 30 phút nếu bận.

Daily Recommendation cần dựa trên dữ liệu đã được backend tổng hợp, không để AI tự truy cập database.

### 9.7. AI Weekly Review

Cuối tuần hoặc khi user mở màn tổng kết, hệ thống có thể tạo weekly review gồm:

| Nhóm             | Nội dung                                                        |
| ---------------- | --------------------------------------------------------------- |
| Dinh dưỡng       | Calories trung bình, protein đạt được, ngày vượt/thiếu mục tiêu |
| Luyện tập        | Số buổi hoàn thành, tỷ lệ hoàn thành lịch tập, bài tập tiến bộ  |
| Cân nặng         | Cân nặng đầu tuần/cuối tuần, xu hướng tăng/giảm                 |
| Nhận xét         | Một số insight ngắn bằng tiếng Việt, dễ hiểu                    |
| Đề xuất tuần sau | Điều chỉnh nhỏ về meal plan, lịch tập hoặc mục tiêu nếu cần     |

### 9.8. AI Plan Adjustment

AI có thể đề xuất điều chỉnh kế hoạch nhưng không tự áp dụng. Các loại điều chỉnh gồm:

- Đổi lịch tập 4 buổi/tuần thành 3 buổi/tuần khi user bận.
- Gợi ý tăng/giảm calories mục tiêu ở mức nhỏ khi tiến độ lệch mục tiêu.
- Gợi ý món thay thế nếu user không thích hoặc không có nguyên liệu.
- Gợi ý bài tập thay thế nếu user thiếu thiết bị hoặc bị đau nhẹ.

Mỗi đề xuất phải có trạng thái `PENDING`, `APPLIED` hoặc `DISMISSED` để user kiểm soát quyết định cuối cùng.

---

## 10. Phân hệ Workout Builder

### 10.1. Chức năng

Người dùng có thể chọn giáo án mẫu hoặc tự tạo giáo án cá nhân.

| Loại giáo án   | Mô tả                                                           |
| -------------- | --------------------------------------------------------------- |
| Push Pull Legs | Chia buổi theo nhóm đẩy, kéo, chân                              |
| Upper Lower    | Chia buổi thân trên và thân dưới                                |
| Full Body      | Tập toàn thân trong một buổi                                    |
| Custom         | Người dùng tự chọn bài tập, số hiệp, số lần lặp, thời gian nghỉ |

### 10.2. Dữ liệu giáo án

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

### 10.3. Business rules

- Một người dùng có thể có nhiều giáo án nhưng chỉ nên có một giáo án đang hoạt động tại một thời điểm.
- Người dùng có thể chỉnh sửa giáo án sau khi tạo.
- Khi tạo lịch tập từ giáo án, hệ thống sinh các buổi tập tương ứng trong lịch.
- Nếu bài tập bị Admin ẩn hoặc xóa mềm, giáo án cũ vẫn giữ lịch sử nhưng không cho thêm bài tập đó vào giáo án mới.

---

## 11. Phân hệ thư viện bài tập

### 11.1. Dữ liệu bài tập

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

### 11.2. Chức năng

- Xem danh sách bài tập.
- Xem chi tiết bài tập.
- Tìm kiếm theo tên bài tập.
- Lọc theo nhóm cơ.
- Lọc theo thiết bị.
- Lọc theo độ khó.
- Admin thêm, sửa, ẩn bài tập.

### 11.3. Business rules

- Người dùng chỉ thấy bài tập đang active.
- Admin có thể quản lý toàn bộ bài tập.
- Video/GIF phải được lưu bằng URL an toàn hoặc object storage.
- Nội dung hướng dẫn nên ưu tiên tiếng Việt.

---

## 12. Phân hệ theo dõi luyện tập

### 12.1. Chức năng

Sau mỗi buổi tập, người dùng có thể ghi nhận:

| Trường        | Mô tả                                   |
| ------------- | --------------------------------------- |
| Ngày tập      | Ngày hoàn thành buổi tập                |
| Bài tập       | Bài tập đã thực hiện                    |
| Số hiệp       | Tổng số hiệp                            |
| Số lần lặp    | Số reps mỗi hiệp                        |
| Mức tạ        | Khối lượng tạ theo kg                   |
| Thời gian tập | Tổng thời gian buổi tập                 |
| RPE           | Mức độ nặng cảm nhận, tùy chọn          |
| Ghi chú       | Cảm nhận, mức độ khó, tình trạng cơ thể |

Workout Log nên hỗ trợ ghi chi tiết theo từng set:

| Cấp dữ liệu        | Nội dung                                        |
| ------------------ | ----------------------------------------------- |
| WorkoutLog         | Một buổi tập hoàn chỉnh theo ngày               |
| WorkoutExerciseLog | Một bài tập trong buổi tập                      |
| WorkoutSetLog      | Từng set gồm reps, weight, RPE và note tùy chọn |

Người dùng có thể tạo log từ lịch tập đã có, chỉnh số set/reps/weight thực tế và lưu lại để phục vụ thống kê tiến bộ.

### 12.2. Thống kê

Hệ thống cần thống kê:

- Tổng số buổi tập.
- Tổng thời gian tập.
- Số buổi hoàn thành trong tuần/tháng.
- Personal Record theo bài tập.
- Biểu đồ tiến bộ theo mức tạ/reps/volume.
- Tỷ lệ hoàn thành lịch tập.

### 12.3. Business rules

- Người dùng chỉ xem và chỉnh sửa lịch sử tập luyện của chính mình.
- PR được tính theo bài tập và có thể dựa trên mức tạ lớn nhất, số reps cao nhất, tổng volume hoặc estimated 1RM.
- Volume của một bài tập được tính bằng tổng `sets * reps * weight` của các set có nhập mức tạ.
- Khi người dùng đánh dấu hoàn thành buổi tập trong lịch, hệ thống liên kết dữ liệu với workout log.
- Nếu người dùng tạo workout log từ lịch tập, hệ thống copy bài tập dự kiến sang log nhưng cho phép chỉnh lại dữ liệu thực tế.

---

## 13. Phân hệ lịch tập

### 13.1. Chức năng

| Mã     | Chức năng           | Mô tả                                      |
| ------ | ------------------- | ------------------------------------------ |
| SCH-01 | Tạo lịch tập        | Người dùng tạo lịch theo ngày/tuần/tháng   |
| SCH-02 | Sửa lịch            | Thay đổi ngày, giờ, bài tập, ghi chú       |
| SCH-03 | Xem lịch tuần       | Hiển thị lịch tập theo tuần                |
| SCH-04 | Xem lịch tháng      | Hiển thị lịch tập theo tháng               |
| SCH-05 | Đánh dấu hoàn thành | Người dùng đánh dấu buổi tập đã hoàn thành |
| SCH-06 | Nhắc lịch tập       | Gửi notification trước giờ tập             |

### 13.2. Trạng thái buổi tập

| Status    | Mô tả                        |
| --------- | ---------------------------- |
| SCHEDULED | Đã lên lịch                  |
| COMPLETED | Đã hoàn thành                |
| MISSED    | Đã qua nhưng chưa hoàn thành |
| CANCELLED | Đã hủy                       |

### 13.3. Business rules

- Người dùng có thể tạo lịch thủ công hoặc sinh lịch từ giáo án.
- Notification chỉ gửi khi người dùng bật quyền thông báo.
- Buổi tập quá hạn có thể tự chuyển sang MISSED theo job định kỳ hoặc khi người dùng mở app.

---

## 14. Phân hệ Meal Planner

### 14.1. Mục tiêu

Meal Planner là điểm khác biệt lớn của VieGym. Hệ thống cần có cơ sở dữ liệu dinh dưỡng món ăn Việt Nam, cho phép người dùng lập thực đơn hằng ngày và theo dõi calories, protein, carbohydrate, fat so với mục tiêu cá nhân.

### 14.2. Dữ liệu món ăn

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

### 14.3. Chức năng người dùng

- Tìm kiếm món ăn.
- Xem thông tin dinh dưỡng từng món.
- Thêm món vào bữa sáng, bữa trưa, bữa tối hoặc bữa phụ.
- Điều chỉnh khẩu phần.
- Xem tổng calories và macro trong ngày.
- So sánh lượng đã nạp với mục tiêu.
- Nhận cảnh báo khi vượt hoặc thiếu calories/macro.
- Nhận gợi ý món ăn phù hợp.
- Tạo món ăn cá nhân nếu món chưa có trong hệ thống.
- Sao chép thực đơn từ ngày trước để nhập liệu nhanh.
- Lưu meal template cho các bữa ăn thường dùng.

### 14.3.1. Khẩu phần món Việt

Meal Planner nên hỗ trợ khẩu phần gần với thói quen người Việt thay vì chỉ nhập gram:

| Loại khẩu phần       | Ví dụ                                        |
| -------------------- | -------------------------------------------- |
| Theo phần/tô/chén    | 1 tô phở, nửa tô, 1 chén cơm, 1 phần cơm tấm |
| Theo đơn vị phổ biến | 1 quả trứng, 1 ly sữa, 1 miếng ức gà         |
| Theo khối lượng      | 100 g, 150 g, 200 g                          |
| Theo hệ số khẩu phần | 0.5 phần, 1 phần, 1.5 phần, 2 phần           |

Mỗi món ăn cần có khẩu phần chuẩn để hệ thống quy đổi calories và macro khi người dùng thay đổi số lượng.

### 14.4. Nguồn dữ liệu và chất lượng dữ liệu

Dữ liệu món ăn Việt Nam cần được chuẩn hóa để Meal Planner đủ tin cậy trong demo và có thể mở rộng sau này.

| Nội dung               | Quy định đề xuất                                                                                     |
| ---------------------- | ---------------------------------------------------------------------------------------------------- |
| Nguồn dữ liệu          | Tổng hợp từ nguồn công khai, nhãn dinh dưỡng, dữ liệu tự chuẩn hóa hoặc nhập liệu thủ công bởi Admin |
| Khẩu phần chuẩn        | Mỗi món cần có khẩu phần mặc định rõ ràng, ví dụ 1 tô, 1 phần, 100 g                                 |
| Giá trị dinh dưỡng     | Calories, protein, carbohydrate và fat là bắt buộc; fiber/sodium là tùy chọn                         |
| Độ chính xác           | Hiển thị là giá trị ước lượng, không thay thế tư vấn dinh dưỡng chuyên môn                           |
| Dữ liệu người dùng tạo | Chỉ thuộc tài khoản của người tạo, trừ khi Admin duyệt thành món dùng chung                          |
| Duyệt dữ liệu          | Admin có thể chỉnh sửa, ẩn hoặc chuẩn hóa món ăn trước khi public                                    |

### 14.5. Dữ liệu món ăn mẫu

Các giá trị dưới đây chỉ là dữ liệu mẫu để seed/demo; khi triển khai cần chuẩn hóa lại nguồn dữ liệu và khẩu phần.

| Món ăn        | Khẩu phần | Calories | Protein | Carbohydrate |  Fat |
| ------------- | --------- | -------: | ------: | -----------: | ---: |
| Phở bò        | 1 tô      | 450 kcal |    25 g |         60 g | 12 g |
| Cơm tấm sườn  | 1 phần    | 650 kcal |    28 g |         85 g | 22 g |
| Bún chả       | 1 phần    | 550 kcal |    24 g |         70 g | 18 g |
| Ức gà áp chảo | 100 g     | 165 kcal |    31 g |          0 g |  4 g |
| Trứng luộc    | 1 quả     |  70 kcal |     6 g |          1 g |  5 g |
| Rau luộc      | 100 g     |  35 kcal |     2 g |          7 g |  0 g |

### 14.6. Loại bữa ăn

| Meal type | Mô tả    |
| --------- | -------- |
| BREAKFAST | Bữa sáng |
| LUNCH     | Bữa trưa |
| DINNER    | Bữa tối  |
| SNACK     | Bữa phụ  |

### 14.7. Business rules

- Mỗi người dùng có một meal plan theo từng ngày.
- Tổng calories/macro được tính bằng tổng các món đã thêm sau khi nhân với khẩu phần.
- Nếu calories đã nạp vượt mục tiêu, hệ thống hiển thị cảnh báo.
- Nếu calories/macro còn thiếu, hệ thống gợi ý món ăn phù hợp.
- AI Coach có thể đọc meal plan hiện tại để tư vấn bổ sung hoặc thay thế món ăn.
- Không nên phụ thuộc hoàn toàn vào API dinh dưỡng bên ngoài; hệ thống nên xây dựng Food Service riêng với dữ liệu món ăn Việt Nam được chuẩn hóa trong PostgreSQL.
- Món ăn do người dùng tự tạo chỉ thuộc phạm vi tài khoản của người dùng đó, trừ khi Admin duyệt thành món dùng chung.
- Khi dữ liệu dinh dưỡng chỉ là ước lượng, UI nên hiển thị rõ đây là giá trị tham khảo.

---

## 15. Phân hệ theo dõi cân nặng

### 15.1. Chức năng

Người dùng cập nhật cân nặng theo ngày để theo dõi tiến độ.

| Trường   | Mô tả            |
| -------- | ---------------- |
| Cân nặng | Đơn vị kg        |
| Ngày đo  | Ngày ghi nhận    |
| Ghi chú  | Ghi chú tùy chọn |

### 15.2. Thống kê

- Cân nặng hiện tại.
- Cân nặng mục tiêu.
- Mức tăng/giảm so với tuần trước/tháng trước.
- Biểu đồ thay đổi cân nặng.
- Tỷ lệ hoàn thành mục tiêu.

### 15.3. Business rules

- Một ngày có thể có một bản ghi cân nặng chính; nếu nhập lại cùng ngày thì cập nhật bản ghi hiện có.
- Khi cân nặng thay đổi, hệ thống có thể tính lại BMI và khuyến nghị calories nếu người dùng đồng ý cập nhật.

---

## 16. Hướng thương mại hóa sau đồ án

Shop không thuộc phạm vi MVP và bản demo 6 tháng. Phần này chỉ được giữ như định hướng phát triển sau khi core AI Coach cá nhân hóa đã ổn định.

### 16.1. Chức năng sau đồ án

| Nhóm chức năng        | Mô tả                                                                                 |
| --------------------- | ------------------------------------------------------------------------------------- |
| Product Catalog       | Danh sách sản phẩm gym như whey protein, creatine, vitamin, phụ kiện tập luyện        |
| Cart & Order          | Giỏ hàng, đặt hàng, theo dõi đơn hàng                                                 |
| Payment               | Thanh toán COD hoặc thanh toán online                                                 |
| Affiliate/Marketplace | Liên kết bán hàng hoặc marketplace cho sản phẩm/huấn luyện viên/chuyên gia dinh dưỡng |
| AI tư vấn sản phẩm    | Gợi ý sản phẩm dựa trên mục tiêu nhưng phải ưu tiên sức khỏe và nhu cầu thật của user |

### 16.2. Nguyên tắc khi phát triển sau này

- Không đưa Shop vào MVP để tránh làm loãng mục tiêu AI cá nhân hóa luyện tập và dinh dưỡng.
- AI phải ưu tiên gợi ý món ăn, lịch tập hoặc điều chỉnh thói quen trước khi gợi ý supplement.
- AI không được đưa ra cam kết y tế, điều trị bệnh hoặc khuyến nghị supplement quá mức.
- Shop chỉ nên triển khai sau khi hệ thống đã có dữ liệu người dùng đủ tốt để tư vấn có trách nhiệm.

---

## 17. Dashboard

### 17.1. Dashboard người dùng

Trang chủ ứng dụng hiển thị các thông tin quan trọng:

| Nhóm       | Thông tin                                                      |
| ---------- | -------------------------------------------------------------- |
| Dinh dưỡng | Calories mục tiêu, đã nạp, còn lại, protein, carbohydrate, fat |
| Luyện tập  | Lịch tập hôm nay, buổi tập tiếp theo, tỷ lệ hoàn thành tuần    |
| Cơ thể     | Cân nặng hiện tại, BMI, tiến độ mục tiêu                       |
| Gợi ý      | Gợi ý món ăn, bài tập hoặc điều chỉnh kế hoạch từ AI           |
| Insight    | Nhận xét ngắn về tiến độ và hành động nên làm tiếp theo        |

Dashboard nên hiển thị các insight ngắn, dễ hiểu, ví dụ:

- Bạn đã hoàn thành 3/4 buổi tập trong tuần này.
- Protein hôm nay còn thiếu khoảng 35 g.
- Cân nặng giảm 0.6 kg trong 7 ngày gần nhất.
- Bài tập Bench Press tăng 5 kg so với tháng trước.
- Bạn thường bỏ bữa sáng; hãy thêm một món nhẹ giàu protein nếu phù hợp mục tiêu.

### 17.2. Dashboard Admin

Admin có thể xem:

- Tổng số người dùng.
- Tổng số món ăn.
- Tổng số bài tập.
- Số lượt import dữ liệu.
- Số cuộc hội thoại AI.
- Số gợi ý AI được tạo/được áp dụng/bị bỏ qua.
- Món ăn/bài tập được xem nhiều.

---

## 18. Quản trị hệ thống

### 18.1. Admin quản lý dữ liệu

| Nhóm dữ liệu | Chức năng                                                             |
| ------------ | --------------------------------------------------------------------- |
| Người dùng   | Xem danh sách, khóa/mở khóa, xem chi tiết                             |
| Bài tập      | Thêm, sửa, ẩn, tìm kiếm, phân loại, import CSV/Excel                  |
| Món ăn       | Thêm, sửa, ẩn, import dữ liệu, chuẩn hóa dinh dưỡng, import CSV/Excel |
| Sản phẩm     | Thêm, sửa, ẩn, cập nhật giá/tồn kho, import CSV/Excel                 |
| Đơn hàng     | Xem, xác nhận, cập nhật trạng thái                                    |
| Nội dung AI  | Quản lý prompt mẫu, rule tư vấn, cảnh báo an toàn                     |

### 18.2. Business rules

- Admin không được xem mật khẩu hoặc refresh token của người dùng.
- Các thao tác quan trọng của Admin nên được ghi audit log.
- Xóa dữ liệu chính nên dùng soft delete để tránh mất dữ liệu trong quá trình làm đồ án và demo.
- Import CSV/Excel phải có bước preview trước khi ghi vào database.
- Dữ liệu import cần validate trường bắt buộc, định dạng số, calories/macro không âm, tên món/bài tập không trùng theo quy tắc hệ thống.
- Nếu import lỗi một phần, hệ thống phải báo rõ dòng lỗi để Admin sửa dữ liệu nguồn.

---

## 19. Kiến trúc hệ thống

### 19.1. Kiến trúc tổng quan

```text
Flutter Mobile App
        |
        | REST API / HTTPS
        v
Spring Boot Backend
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

### 19.2. Thành phần

| Thành phần       | Công nghệ                                     | Vai trò                                                   |
| ---------------- | --------------------------------------------- | --------------------------------------------------------- |
| Mobile App       | Flutter                                       | Giao diện người dùng trên mobile                          |
| Admin Web        | React + TypeScript                            | Giao diện admin trên website                              |
| State Management | Riverpod                                      | Quản lý state phía Flutter                                |
| Backend API      | Spring Boot                                   | Xử lý nghiệp vụ, REST API, tích hợp DB/storage/AI context |
| Security         | Spring Security + JWT                         | Xác thực và phân quyền                                    |
| Database         | PostgreSQL                                    | Lưu dữ liệu chính                                         |
| Cache            | Redis                                         | Cache session, OTP, dữ liệu truy cập nhanh                |
| AI Service       | Python FastAPI                                | Đóng gói logic AI Coach/chatbot                           |
| AI Provider      | OpenAI API hoặc Gemini API                    | Sinh phản hồi AI                                          |
| Storage          | MinIO hoặc Amazon S3                          | Lưu ảnh món ăn và video/GIF bài tập                       |
| DevOps           | Docker, Docker Compose, Nginx, GitHub Actions | Triển khai và vận hành                                    |
| Design           | Figma                                         | Thiết kế UI/UX                                            |

### 19.3. Nguyên tắc thiết kế

- Mobile App không truy cập trực tiếp database.
- Backend Spring Boot là nguồn sự thật cho dữ liệu nghiệp vụ.
- AI Service không tự ý truy cập database; chỉ nhận context cần thiết từ Backend.
- Ảnh/video/file media lưu trên object storage, database chỉ lưu metadata và object key/URL.
- API cần có OpenAPI/Swagger để phục vụ báo cáo và kiểm thử.

---

## 20. Mô hình dữ liệu mức khái niệm

### 20.1. Nhóm tài khoản và hồ sơ

| Entity        | Mô tả                                                           |
| ------------- | --------------------------------------------------------------- |
| User          | Tài khoản người dùng                                            |
| UserProfile   | Thông tin cá nhân                                               |
| HealthProfile | Chiều cao, cân nặng, tuổi, giới tính, mức độ vận động, mục tiêu |
| WeightLog     | Lịch sử cân nặng                                                |
| RefreshToken  | Phiên đăng nhập                                                 |
| OtpCode       | Mã OTP xác thực                                                 |

### 20.2. Nhóm luyện tập

| Entity             | Mô tả                           |
| ------------------ | ------------------------------- |
| Exercise           | Bài tập                         |
| MuscleGroup        | Nhóm cơ                         |
| Equipment          | Thiết bị                        |
| WorkoutProgram     | Giáo án tập                     |
| WorkoutDay         | Buổi tập trong giáo án          |
| WorkoutExercise    | Bài tập thuộc buổi tập          |
| WorkoutSchedule    | Lịch tập                        |
| WorkoutLog         | Nhật ký buổi tập                |
| WorkoutExerciseLog | Chi tiết bài tập trong buổi tập |
| WorkoutSetLog      | Chi tiết từng set               |

### 20.3. Nhóm dinh dưỡng

| Entity          | Mô tả                      |
| --------------- | -------------------------- |
| Food            | Món ăn/thực phẩm           |
| FoodCategory    | Danh mục món ăn            |
| MealPlan        | Thực đơn theo ngày         |
| MealEntry       | Món ăn được thêm vào bữa   |
| MealTemplate    | Mẫu bữa ăn thường dùng     |
| UserFood        | Món ăn cá nhân do user tạo |
| NutritionTarget | Mục tiêu calories và macro |

### 20.4. Nhóm AI, cá nhân hóa và log

| Entity           | Mô tả                                       |
| ---------------- | ------------------------------------------- |
| AiConversation   | Cuộc trò chuyện với AI                      |
| AiMessage        | Tin nhắn trong cuộc trò chuyện              |
| AiRecommendation | Gợi ý AI sinh ra                            |
| AiConsentSetting | Cấu hình cho phép AI dùng dữ liệu cá nhân   |
| UserPreference   | Sở thích và phản hồi cá nhân hóa của user   |
| WeeklyReview     | Tổng kết tiến độ theo tuần                  |
| AuditLog         | Nhật ký thao tác quan trọng                 |
| Notification     | Thông báo nhắc lịch tập/meal plan/AI review |

### 20.5. Nhóm cửa hàng sau đồ án

Các entity sau không thuộc MVP đồ án, chỉ dùng khi phát triển chức năng thương mại hóa sau này:

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

---

## 21. API Requirements mức cao

### 21.1. Auth API

| Method | Endpoint                     | Mô tả                          |
| ------ | ---------------------------- | ------------------------------ |
| POST   | /api/v1/auth/register        | Đăng ký                        |
| POST   | /api/v1/auth/login           | Đăng nhập                      |
| POST   | /api/v1/auth/google          | Đăng nhập Google               |
| POST   | /api/v1/auth/refresh         | Cấp access token mới           |
| POST   | /api/v1/auth/logout          | Đăng xuất                      |
| POST   | /api/v1/auth/logout-all      | Đăng xuất khỏi tất cả thiết bị |
| POST   | /api/v1/auth/forgot-password | Gửi OTP đặt lại mật khẩu       |
| POST   | /api/v1/auth/verify-otp      | Xác thực OTP                   |
| POST   | /api/v1/auth/reset-password  | Đặt lại mật khẩu               |

### 21.2. User & Health API

| Method | Endpoint                  | Mô tả                             |
| ------ | ------------------------- | --------------------------------- |
| GET    | /api/v1/users/me          | Lấy thông tin người dùng hiện tại |
| PUT    | /api/v1/users/me          | Cập nhật hồ sơ cá nhân            |
| GET    | /api/v1/health-profile/me | Lấy hồ sơ sức khỏe                |
| PUT    | /api/v1/health-profile/me | Tạo/cập nhật hồ sơ sức khỏe       |
| GET    | /api/v1/weight-logs       | Lấy lịch sử cân nặng              |
| POST   | /api/v1/weight-logs       | Thêm/cập nhật cân nặng            |

### 21.3. Workout API

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

### 21.4. Nutrition API

| Method | Endpoint                        | Mô tả               |
| ------ | ------------------------------- | ------------------- |
| GET    | /api/v1/foods                   | Tìm kiếm/lọc món ăn |
| GET    | /api/v1/foods/{id}              | Chi tiết món ăn     |
| GET    | /api/v1/meal-plans/today        | Thực đơn hôm nay    |
| GET    | /api/v1/meal-plans              | Thực đơn theo ngày  |
| POST   | /api/v1/meal-plans/entries      | Thêm món vào bữa    |
| PUT    | /api/v1/meal-plans/entries/{id} | Cập nhật khẩu phần  |
| DELETE | /api/v1/meal-plans/entries/{id} | Xóa món khỏi bữa    |

### 21.5. AI API

| Method | Endpoint                                | Mô tả                                |
| ------ | --------------------------------------- | ------------------------------------ |
| POST   | /api/v1/ai/coach/chat                   | Chat với AI Coach cá nhân hóa        |
| POST   | /api/v1/ai/coach/workout-plan           | Tạo gợi ý lịch tập                   |
| POST   | /api/v1/ai/coach/meal-advice            | Tư vấn thực đơn                      |
| GET    | /api/v1/ai/recommendations/today        | Lấy gợi ý AI hôm nay                 |
| POST   | /api/v1/ai/recommendations/{id}/apply   | Áp dụng gợi ý sau khi user xác nhận  |
| POST   | /api/v1/ai/recommendations/{id}/dismiss | Bỏ qua gợi ý và lưu phản hồi nếu cần |
| GET    | /api/v1/ai/weekly-review                | Xem tổng kết tiến độ theo tuần       |
| PUT    | /api/v1/ai/consent                      | Bật/tắt cá nhân hóa AI               |

### 21.6. Dashboard API

| Method | Endpoint                  | Mô tả                                  |
| ------ | ------------------------- | -------------------------------------- |
| GET    | /api/v1/dashboard/me      | Tổng hợp dashboard cá nhân             |
| GET    | /api/v1/dashboard/insight | Lấy insight ngắn dựa trên dữ liệu user |

### 21.7. Admin API

| Method       | Endpoint                       | Mô tả                  |
| ------------ | ------------------------------ | ---------------------- |
| GET          | /api/v1/admin/users            | Quản lý người dùng     |
| GET/POST/PUT | /api/v1/admin/exercises        | Quản lý bài tập        |
| GET/POST/PUT | /api/v1/admin/foods            | Quản lý món ăn         |
| POST         | /api/v1/admin/import/foods     | Import dữ liệu món ăn  |
| POST         | /api/v1/admin/import/exercises | Import dữ liệu bài tập |
| GET/POST/PUT | /api/v1/admin/ai-rules         | Quản lý rule/prompt AI |
| GET          | /api/v1/admin/dashboard        | Dashboard Admin cơ bản |

---

## 22. Giả định, ràng buộc và phụ thuộc

### 22.1. Giả định

- Người dùng có smartphone Android trong phạm vi demo đồ án; iOS là hướng mở rộng sau.
- Người dùng có kết nối Internet khi sử dụng các chức năng cần đồng bộ dữ liệu, AI hoặc mua hàng.
- Dữ liệu món ăn Việt Nam ban đầu được thu thập, chuẩn hóa và nhập vào PostgreSQL bởi Admin hoặc script nội bộ.
- AI Provider hoạt động ổn định trong thời điểm demo; nếu provider lỗi, hệ thống trả thông báo lỗi thân thiện thay vì làm treo ứng dụng.
- Các chức năng thương mại hóa như shop, giỏ hàng và thanh toán không thuộc phạm vi demo MVP.

### 22.2. Ràng buộc

- Giao diện và phản hồi AI mặc định sử dụng tiếng Việt.
- Mobile App không truy cập trực tiếp database hoặc AI Provider.
- API key, JWT secret, storage secret và AI provider secret chỉ được lưu ở server-side.
- Dữ liệu sức khỏe, thực đơn, lịch tập, workout log, cân nặng và hội thoại AI là dữ liệu cá nhân; backend phải kiểm tra quyền truy cập theo user.
- Ảnh, video và GIF không lưu trực tiếp trong database.
- Phiên bản đồ án ưu tiên hoàn thiện MVP trong 6 tháng, các tính năng nâng cao được đưa vào hướng phát triển sau đồ án.

### 22.2.1. Offline mode mức cơ bản

Trong MVP, các chức năng yêu cầu đồng bộ và AI cần kết nối Internet. Tuy nhiên mobile app nên hỗ trợ offline nhẹ nếu có thời gian:

- Cache danh sách bài tập đã tải gần đây.
- Cache danh sách món ăn phổ biến hoặc món người dùng hay dùng.
- Cho phép xem dashboard gần nhất khi mất mạng.
- Cho phép ghi workout log tạm thời trên thiết bị và đồng bộ khi có mạng.
- Hiển thị rõ trạng thái dữ liệu chưa đồng bộ để tránh hiểu nhầm.

Trạng thái đồng bộ đề xuất cho dữ liệu ghi offline:

| Trạng thái  | Ý nghĩa                                                  |
| ----------- | -------------------------------------------------------- |
| LOCAL_ONLY  | Dữ liệu mới chỉ có trên thiết bị                         |
| SYNCING     | App đang đồng bộ dữ liệu lên backend                     |
| SYNCED      | Dữ liệu đã được backend xác nhận lưu thành công          |
| SYNC_FAILED | Đồng bộ thất bại, user có thể thử lại hoặc chỉnh dữ liệu |

### 22.3. Phụ thuộc bên ngoài

| Phụ thuộc                   | Vai trò                        | Rủi ro                                     |
| --------------------------- | ------------------------------ | ------------------------------------------ |
| OpenAI API hoặc Gemini API  | Sinh phản hồi AI Coach/chatbot | Chi phí, rate limit, lỗi provider          |
| Google OAuth                | Đăng nhập Google               | Cần cấu hình OAuth client đúng môi trường  |
| MinIO hoặc Amazon S3        | Lưu media                      | Cần cấu hình bucket, quyền truy cập và URL |
| Firebase/local notification | Nhắc lịch và thông báo         | Cần quyền notification trên thiết bị       |

---

## 23. Yêu cầu giao diện ngoài

### 23.1. Giao diện người dùng

- Mobile App cần hỗ trợ các màn chính: đăng nhập/đăng ký, onboarding, hồ sơ sức khỏe, dashboard, workout, meal planner, AI Coach, weekly review và profile.
- Giao diện ưu tiên tiếng Việt, dễ dùng cho người mới tập gym.
- Các biểu đồ calories, macro, cân nặng và tiến bộ tập luyện phải dễ đọc trên màn hình điện thoại.
- Form nhập liệu cần có validation rõ ràng và thông báo lỗi dễ hiểu.

### 23.2. Giao diện phần mềm

| Thành phần                               | Giao tiếp          |
| ---------------------------------------- | ------------------ |
| Flutter Mobile App ↔ Spring Boot Backend | REST API qua HTTPS |
| Spring Boot Backend ↔ PostgreSQL         | JDBC/JPA           |
| Spring Boot Backend ↔ Redis              | Redis protocol     |
| Spring Boot Backend ↔ Object Storage     | S3-compatible API  |
| Spring Boot Backend ↔ FastAPI AI Service | HTTP API nội bộ    |
| FastAPI AI Service ↔ AI Provider         | Provider SDK/API   |

### 23.3. Giao diện phần cứng

- Ứng dụng chạy trên smartphone; không yêu cầu thiết bị phần cứng chuyên dụng trong MVP.
- Camera, cảm biến sức khỏe, Apple Health và Google Fit chưa thuộc phạm vi bắt buộc của phiên bản đồ án.

### 23.4. Giao diện truyền thông

- Tất cả giao tiếp giữa mobile app và backend nên dùng HTTPS khi triển khai thật.
- API trả JSON UTF-8.
- Media được truy cập qua URL do backend kiểm soát hoặc object storage đã cấu hình quyền phù hợp.

---

## 24. Yêu cầu phi chức năng

| #   | Yêu cầu          | Chi tiết                                                                                                         |
| --- | ---------------- | ---------------------------------------------------------------------------------------------------------------- |
| 1   | Hiệu năng API    | P95 API latency < 500ms với các API đọc phổ biến trong môi trường MVP                                            |
| 2   | Bảo mật          | Tất cả API riêng tư yêu cầu JWT; mật khẩu hash an toàn; phân quyền User/Admin                                    |
| 3   | Riêng tư dữ liệu | Chỉ người dùng sở hữu dữ liệu mới được xem hồ sơ sức khỏe, lịch tập, thực đơn, cân nặng và hội thoại AI của mình |
| 4   | Khả dụng         | Hệ thống hoạt động ổn định trong quá trình demo và kiểm thử                                                      |
| 5   | Mở rộng          | Kiến trúc tách Mobile, Backend, AI Service, Database, Storage                                                    |
| 6   | Dễ bảo trì       | REST API rõ ràng, có Swagger/OpenAPI, code chia theo module                                                      |
| 7   | Đa nền tảng      | Flutter có thể build Android trước, mở rộng iOS sau                                                              |
| 8   | Ngôn ngữ         | Giao diện và phản hồi AI mặc định bằng tiếng Việt                                                                |
| 9   | An toàn AI       | AI có guardrail với nội dung y tế, chấn thương, thực phẩm bổ sung                                                |
| 10  | Backup dữ liệu   | Database cần có quy trình backup khi triển khai thật                                                             |
| 11  | Media storage    | Ảnh/video không lưu trực tiếp trong database                                                                     |
| 12  | Logging          | Ghi log lỗi backend, AI request failure và thao tác quan trọng                                                   |

---

## 25. Bảo mật và phân quyền

### 25.1. Vai trò

| Role  | Quyền                                                                    |
| ----- | ------------------------------------------------------------------------ |
| USER  | Dùng các chức năng cá nhân: tập luyện, dinh dưỡng, AI, mua hàng          |
| ADMIN | Quản trị dữ liệu hệ thống, người dùng, món ăn, bài tập và rule/prompt AI |

### 25.2. Quy tắc bảo mật

- Người dùng chỉ được truy cập dữ liệu thuộc tài khoản của mình.
- Admin có quyền quản trị dữ liệu dùng chung nhưng không được xem thông tin nhạy cảm như mật khẩu/token.
- API phải kiểm tra authorization ở backend, không chỉ ẩn nút ở frontend.
- Refresh token cần có cơ chế revoke khi logout.
- OTP phải có thời hạn và giới hạn số lần thử.
- File upload ảnh/video phải validate MIME type, kích thước và extension.
- Không lưu API key AI Provider ở mobile app; API key chỉ nằm ở server-side.

---

## 26. Notification Requirements

| Loại thông báo     | Mô tả                                                        |
| ------------------ | ------------------------------------------------------------ |
| Nhắc lịch tập      | Gửi trước giờ tập theo cấu hình người dùng                   |
| Nhắc nhập cân nặng | Nhắc người dùng cập nhật cân nặng định kỳ                    |
| Nhắc meal plan     | Nhắc nhập bữa ăn nếu chưa ghi nhận                           |
| AI weekly review   | Thông báo khi có tổng kết tiến độ theo tuần                  |
| Gợi ý AI           | Gợi ý tập luyện/dinh dưỡng nếu người dùng bật nhận thông báo |

Business rules:

- Người dùng có thể bật/tắt notification.
- Không gửi thông báo marketing nếu người dùng chưa đồng ý.
- Notification phải phù hợp múi giờ của người dùng.

---

## 27. Rủi ro dự án và phương án xử lý

| Rủi ro                                  | Ảnh hưởng                                      | Phương án xử lý                                                                   |
| --------------------------------------- | ---------------------------------------------- | --------------------------------------------------------------------------------- |
| Thiếu dữ liệu món ăn Việt Nam chuẩn hóa | Meal Planner kém thuyết phục                   | Seed trước 50–100 món phổ biến, ghi rõ khẩu phần và nguồn dữ liệu trong báo cáo   |
| Scope quá rộng trong 6 tháng            | Không hoàn thành MVP                           | Ưu tiên Must have, cắt các chức năng Could/Won't have khỏi bản demo               |
| AI trả lời sai hoặc quá tự tin          | Ảnh hưởng trải nghiệm và an toàn người dùng    | Dùng guardrail, disclaimer y tế và giới hạn phạm vi tư vấn                        |
| Chi phí/rate limit AI Provider          | AI Coach không ổn định khi demo                | Có mock response hoặc fallback khi provider lỗi                                   |
| Cá nhân hóa AI chưa đủ ngữ cảnh         | AI trả lời chung chung, kém khác biệt          | Chuẩn hóa AI context gồm profile, meal plan, workout log, weight trend và consent |
| Media/video bài tập nặng                | Tốn storage và bandwidth                       | Dùng URL/object storage, giới hạn kích thước upload, seed dữ liệu mẫu             |
| Bảo mật dữ liệu cá nhân chưa chặt       | Lộ dữ liệu health/meal/workout/AI conversation | Kiểm tra ownership ở backend và test các API truy cập chéo user                   |

---

## 28. Yêu cầu kiểm thử

### 28.1. Nhóm kiểm thử

| Nhóm kiểm thử    | Nội dung                                                                                                      |
| ---------------- | ------------------------------------------------------------------------------------------------------------- |
| Unit test        | Tính BMI, BMR, TDEE, calories mục tiêu, macro, tổng calories meal plan                                        |
| API test         | Auth, health profile, exercise, workout schedule/log, food, meal plan, dashboard, AI, admin APIs              |
| Security test    | JWT thiếu/sai/hết hạn, user không truy cập được dữ liệu user khác, admin endpoint chặn user thường            |
| AI test          | Prompt tiếng Việt, context đúng, consent đúng, guardrail với chấn thương/bệnh lý/thực phẩm bổ sung            |
| UI test thủ công | Đăng nhập, onboarding, tạo hồ sơ, dashboard, thêm món, ghi buổi tập, chat AI, weekly review                   |
| E2E demo test    | Luồng đăng ký/đăng nhập → onboarding → health profile → meal planner → workout log → AI Coach → weekly review |

### 28.2. Done criteria kiểm thử

1. Các công thức sức khỏe trả kết quả đúng với dữ liệu mẫu.
2. API private trả `401/403` khi không có quyền.
3. User A không đọc/sửa được health profile, meal plan, workout log, weight log hoặc AI conversation của User B.
4. Dashboard cập nhật sau khi thêm món ăn, cập nhật cân nặng hoặc hoàn thành buổi tập.
5. AI Coach luôn trả lời bằng tiếng Việt và có cảnh báo khi câu hỏi liên quan y tế/chấn thương.

### 28.3. Success metrics cho đồ án

| Nhóm         | Chỉ số đề xuất                                                                                                           |
| ------------ | ------------------------------------------------------------------------------------------------------------------------ |
| Dữ liệu demo | Có tối thiểu 50 món ăn Việt Nam và 50 bài tập được seed vào database                                                     |
| Onboarding   | Người dùng mới có thể hoàn thiện hồ sơ sức khỏe trong dưới 3 phút                                                        |
| Meal Planner | Người dùng có thể thêm món vào bữa ăn và thấy tổng calories/macro cập nhật trong dưới 1 phút                             |
| Workout Log  | Người dùng có thể ghi nhận một buổi tập gồm nhiều bài và nhiều set                                                       |
| AI Coach     | AI trả lời bằng tiếng Việt, đúng ngữ cảnh trong phần lớn test case thủ công và có guardrail với câu hỏi y tế/chấn thương |
| Bảo mật      | 100% API private quan trọng có kiểm thử JWT và ownership dữ liệu                                                         |
| Triển khai   | Hệ thống chạy được bằng Docker Compose trong môi trường demo                                                             |

---

## 29. Traceability Matrix

| Requirement          | Màn hình liên quan                                                     | API liên quan                                                                                                                                                             | Acceptance Criteria               |
| -------------------- | ---------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------- |
| AUTH-01..AUTH-09     | Login, Register, Forgot Password, Profile, Biometric Login             | `/auth/register`, `/auth/login`, `/auth/google`, `/auth/refresh`, `/auth/logout`, `/auth/logout-all`, `/auth/forgot-password`, `/auth/verify-otp`, `/auth/reset-password` | AC-1, AC-16, AC-21                |
| HEALTH-01..HEALTH-08 | Health Profile, Weight History, Dashboard                              | `/health-profile/me`, `/health-profile/me/summary`, `/weight-logs`                                                                                                        | AC-2, AC-3, AC-8, AC-17           |
| WO-01..WO-12         | Exercise Library, Workout Builder, Calendar, Workout Logging, Progress | `/exercises`, `/workout-programs`, `/workout-schedules`, `/workout-logs`, `/workout-stats/summary`                                                                        | AC-4, AC-5, AC-6, AC-7            |
| NUTRI-01..NUTRI-10   | Meal Planner, Food Search, Food Detail, Dashboard                      | `/foods`, `/meal-plans`, `/meal-plans/today`, `/meal-plans/entries`, `/nutrition-targets/me`                                                                              | AC-3, AC-9, AC-10, AC-20          |
| AI-01..AI-10         | AI Coach Chat, Daily Recommendation, Weekly Review, AI Consent         | `/ai/coach/chat`, `/ai/coach/workout-plan`, `/ai/coach/meal-advice`, `/ai/recommendations/today`, `/ai/weekly-review`, `/ai/consent`                                      | AC-11, AC-12, AC-13, AC-14, AC-15 |
| ADM-01..ADM-06       | Admin Dashboard, User/Food/Exercise/Import/AI Rule Management          | `/admin/users`, `/admin/exercises`, `/admin/foods`, `/admin/import/foods`, `/admin/import/exercises`, `/admin/ai-rules`, `/admin/dashboard`                               | AC-18, AC-19                      |

---

## 30. Acceptance Criteria

| #   | Tiêu chí nghiệm thu                                                                                                                             |
| --- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | Người dùng đăng ký, đăng nhập, đăng xuất và đặt lại mật khẩu thành công.                                                                        |
| 2   | Người dùng hoàn thiện hồ sơ sức khỏe và hệ thống tính đúng BMI, BMR, TDEE, calories mục tiêu.                                                   |
| 3   | Dashboard hiển thị calories mục tiêu, calories đã nạp, macro, lịch tập hôm nay, cân nặng hiện tại và tiến độ mục tiêu.                          |
| 4   | Người dùng xem được thư viện bài tập, tìm kiếm/lọc theo nhóm cơ, thiết bị và độ khó.                                                            |
| 5   | Người dùng tạo được giáo án tập hoặc chọn giáo án mẫu.                                                                                          |
| 6   | Người dùng tạo lịch tập, xem lịch theo tuần/tháng và đánh dấu hoàn thành buổi tập.                                                              |
| 7   | Người dùng ghi nhận buổi tập với bài tập, sets, reps, mức tạ và xem lịch sử tiến bộ.                                                            |
| 8   | Người dùng cập nhật cân nặng và xem biểu đồ thay đổi theo thời gian.                                                                            |
| 9   | Người dùng tìm kiếm món ăn Việt Nam, xem dinh dưỡng và thêm vào từng bữa trong ngày.                                                            |
| 10  | Meal Planner tự cộng calories, protein, carbohydrate, fat và so sánh với mục tiêu cá nhân.                                                      |
| 11  | AI Coach trả lời bằng tiếng Việt và tư vấn lịch tập/thực đơn dựa trên hồ sơ, meal plan và workout log nếu user bật consent.                     |
| 12  | AI Coach có cảnh báo phù hợp với câu hỏi liên quan đến bệnh lý, chấn thương hoặc tư vấn y tế.                                                   |
| 13  | Dashboard hiển thị AI Daily Recommendation dựa trên calories/macro còn thiếu, lịch tập và tiến độ gần đây.                                      |
| 14  | Người dùng xem được AI Weekly Review tổng kết meal, workout, cân nặng và đề xuất điều chỉnh tuần tiếp theo.                                     |
| 15  | Người dùng có thể bật/tắt cá nhân hóa AI; khi tắt, AI không dùng dữ liệu cá nhân để tư vấn.                                                     |
| 16  | API riêng tư không cho phép truy cập khi thiếu hoặc sai JWT.                                                                                    |
| 17  | Người dùng không xem được dữ liệu cá nhân, meal plan, workout log, weight log hoặc AI conversation của người dùng khác.                         |
| 18  | Admin quản lý được bài tập, món ăn, import dữ liệu và rule/prompt AI.                                                                           |
| 19  | Hệ thống có Swagger/OpenAPI phục vụ kiểm thử và tài liệu kỹ thuật.                                                                              |
| 20  | Hệ thống có thể chạy bằng Docker Compose trong môi trường demo.                                                                                 |
| 21  | Người dùng có thể bật Face ID/vân tay để mở khóa phiên đăng nhập đã lưu; nếu xác thực thất bại hoặc token hết hạn thì quay về đăng nhập thường. |
| 22  | Dữ liệu món ăn Việt Nam được lưu trong database nội bộ thay vì phụ thuộc hoàn toàn vào API dinh dưỡng bên ngoài.                                |

---

## 31. Demo Scenario

Kịch bản demo đề xuất cho buổi bảo vệ đồ án:

1. Người dùng đăng ký hoặc đăng nhập vào ứng dụng.
2. Người dùng hoàn thiện onboarding và hồ sơ sức khỏe.
3. Hệ thống tính BMI, BMR, TDEE, calories và macro mục tiêu.
4. Người dùng xem dashboard cá nhân sau khi hoàn thiện hồ sơ.
5. Người dùng tìm món ăn Việt Nam, chọn khẩu phần và thêm vào meal plan trong ngày.
6. Dashboard cập nhật calories, macro còn lại và insight dinh dưỡng.
7. Người dùng xem thư viện bài tập và tạo lịch tập cơ bản.
8. Người dùng ghi nhận một buổi tập gồm nhiều bài, nhiều set, reps và mức tạ.
9. Dashboard cập nhật tiến độ luyện tập và cân nặng.
10. Dashboard hiển thị AI Daily Recommendation dựa trên dữ liệu hiện tại.
11. Người dùng hỏi AI Coach nên điều chỉnh ăn uống hoặc lịch tập như thế nào dựa trên dữ liệu hiện tại.
12. Người dùng xem AI Weekly Review để thấy tổng kết meal, workout, cân nặng và đề xuất tuần tiếp theo.
13. Người dùng bật/tắt cá nhân hóa AI trong phần cài đặt để chứng minh consent hoạt động.
14. Admin đăng nhập trang quản trị để quản lý món ăn, bài tập, import dữ liệu và rule/prompt AI.

---

## 32. Kế hoạch thực hiện 6 tháng

| Thời gian | Công việc                                                                                                                                     |
| --------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| Tháng 1   | Khảo sát hệ thống tương tự, phân tích yêu cầu, xác định core loop, thiết kế UI/UX Figma, ERD, kiến trúc hệ thống và luồng AI personalization. |
| Tháng 2   | Xây dựng Backend: auth, JWT, onboarding, hồ sơ sức khỏe, API bài tập, API thực phẩm, Meal Planner và CSDL cốt lõi.                            |
| Tháng 3   | Phát triển Flutter App: đăng nhập, onboarding, hồ sơ sức khỏe, Dashboard, thư viện bài tập, lịch tập, Workout Builder và kết nối Backend.     |
| Tháng 4   | Hoàn thiện Meal Planner, import dữ liệu món ăn Việt Nam/bài tập, workout log chi tiết, theo dõi cân nặng, dashboard insight và biểu đồ.       |
| Tháng 5   | Xây dựng AI Coach cá nhân hóa, AI Daily Recommendation, AI Weekly Review, AI Plan Adjustment, consent và guardrail.                           |
| Tháng 6   | Kiểm thử tổng thể, kiểm thử bảo mật ownership, tối ưu AI context, triển khai Docker, viết báo cáo, quay video demo và chuẩn bị bảo vệ.        |

---

## 33. Hướng phát triển sau đồ án

- AI nhận diện món ăn từ hình ảnh.
- AI phân tích tư thế tập luyện bằng camera.
- Đồng bộ với Apple Health và Google Fit.
- Phiên bản Web dành cho huấn luyện viên.
- Hệ thống quản lý phòng gym.
- Gợi ý thực đơn cá nhân hóa nâng cao dựa trên lịch sử dài hạn.
- Machine Learning dự đoán tiến độ và tối ưu lịch tập.
- Shop bán sản phẩm gym, affiliate hoặc marketplace sau khi core AI Coach ổn định.
- Marketplace cho huấn luyện viên và chuyên gia dinh dưỡng.
- Gói Premium với giáo án nâng cao và phân tích chuyên sâu.

---

## 34. Tài liệu liên quan

| Tài liệu            | Đường dẫn            |
| ------------------- | -------------------- |
| Kế hoạch phát triển | [plans.md](plans.md) |
