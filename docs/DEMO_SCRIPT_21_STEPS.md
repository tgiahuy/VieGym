# VieGym — Kịch bản Demo 21 Bước (UAT & Báo cáo Tốt nghiệp)

> **Tài liệu chuẩn bị cho:** Milestone M8 — Hardening, UAT và Release  
> **Phiên bản:** Release Candidate 1.0 (MVP P0)  
> **Ngày cập nhật:** 2026-10-24  

---

## 1. Tài khoản Demo & Môi trường

| Loại tài khoản | Email | Quyền hạn | Mục đích sử dụng |
| :--- | :--- | :---: | :--- |
| **ADMIN** | `admin@viegym.com` | `ADMIN` | Quản trị catalog Bài tập, Món ăn, Media, Audit Logs (chỉ đăng nhập Web Admin) |
| **USER 1** | `tgiahuy.shu@gmail.com` | `USER` | Người dùng chính: có lịch sử tập luyện, nhật ký dinh dưỡng và cân nặng thực tế |
| **USER 2 (Dev/Test)** | `dev@viegym.local` | `USER` | Tài khoản kiểm thử nhanh / Demo onboarding từ đầu |

- **Web Admin URL:** `http://localhost:3000` (hoặc `npm run dev` trong `admin-web/`)
- **Backend API URL:** `http://localhost:8080` (hoặc `http://10.0.2.2:8080` từ Android Emulator)
- **MinIO S3 Console:** `http://localhost:9000` (Storage Media)

---

## 2. Kịch bản 21 Bước Demo Toàn Trình (End-to-End)

### PHẦN I: Quản trị Hệ thống (Web Admin — React & TypeScript)

#### Bước 1: Đăng nhập Web Admin an toàn (MH58)
- Truy cập `http://localhost:3000`.
- Nhập tài khoản Admin: `admin@viegym.com`.
- **Điểm nhấn kỹ thuật:** Session được cấp qua cookie `HttpOnly`, `Secure`, `SameSite=Strict` với audience `ADMIN_WEB`; token hoàn toàn không lưu trong `localStorage`/`sessionStorage` để chống XSS.

#### Bước 2: Quản lý Thư viện Bài tập (MH46)
- Vào menu **Bài tập (Exercises)**.
- Tạo bài tập mới: `"Incline Dumbbell Press"`, chọn Nhóm cơ chính (*Ngực trên*), Thiết bị (*Tạ đơn*).
- **Điểm nhấn kỹ thuật:** Hỗ trợ upload ảnh/video minh họa với presigned URL S3 TTL ngắn và kiểm tra MIME type thực tế.

#### Bước 3: Quản lý Cơ sở dữ liệu Món ăn Việt (MH47)
- Vào menu **Món ăn (Foods)**.
- Tìm kiếm trong kho 80 món Việt có sẵn.
- Thêm món ăn mới: `"Phở bò tái lăn"`, nhập khẩu phần gram, calories, protein, carb, fat.

#### Bước 4: Kiểm tra Nhật ký Kiểm toán & Redaction (MH51)
- Vào menu **Audit Logs**.
- Xem chi tiết các mutation vừa thực hiện.
- **Điểm nhấn kỹ thuật:** Hệ thống tự động bôi đỏ/redact mật khẩu, token, OTP và dữ liệu nhạy cảm theo tiêu chuẩn bảo mật.

#### Bước 5: Đăng xuất Admin (Thu hồi Token)
- Bấm **Đăng xuất**.
- **Điểm nhấn kỹ thuật:** Server lập tức thu hồi `refresh_token` trong DB và xoá toàn bộ Auth Cookies.

---

### PHẦN II: Người dùng Cá nhân (Mobile App — Flutter)

#### Bước 6: Đăng ký & Kích hoạt tài khoản (MH01, MH02)
- Mở ứng dụng VieGym trên điện thoại.
- Đăng ký tài khoản mới với email, nhận mã OTP 6 số xác thực.
- **Điểm nhấn kỹ thuật:** Cơ chế Rate limit chống brute-force và bảo vệ chống replay OTP.

#### Bước 7: Khảo sát Sinh trắc & Mục tiêu Onboarding (MH03..MH07)
- Hoàn thành luồng Onboarding 11 bước: Giới tính sinh học, ngày sinh, chiều cao (Ruler Picker), cân nặng hiện tại, cân nặng mục tiêu, mức độ hoạt động và mục tiêu thể hình (*Tăng cơ / Giảm mỡ / Duy trì*).
- **Điểm nhấn kỹ thuật:** Tự động tính toán chỉ số BMI, BMR và TDEE chuẩn xác tại Backend.

#### Bước 8: Cấu hình Thiết bị Tập luyện (MH08..MH10)
- Chọn không gian tập: *Full Gym*, *Tạ đơn & Dây kháng lực*, hoặc *Tập tại nhà (Bodyweight)*.
- Lưu tuỳ chọn: Hệ thống tự động lọc các bài tập phù hợp với thiết bị sẵn có.

#### Bước 9: Tổng quan Trang chủ Dashboard (MH09)
- Xem lời chào cá nhân hóa theo nickname.
- Xem số calo mục tiêu trong ngày, phân bổ macro (Đạm, Tinh bột, Béo), trạng thái buổi tập hôm nay và xu hướng cân nặng.

#### Bước 10: Tra cứu & Yêu thích Bài tập (MH11, MH12, MH56)
- Vào tab **Tập luyện** -> **Thư viện bài tập**.
- Tìm kiếm theo từ khóa hoặc bộ lọc nhóm cơ.
- Bấm icon Trái tim để lưu vào danh sách **Yêu thích** (đồng bộ tức thì lên Server).

#### Bước 11: Thiết lập Giáo án & Lịch tập (MH13, MH14)
- Tạo giáo án tập cá nhân hóa hoặc dùng mẫu Push-Pull-Legs.
- Gán lịch tập vào các ngày trong tuần (Thứ 2, Thứ 4, Thứ 6...).

#### Bước 12: Thực hiện Buổi tập Trực tiếp (MH15, MH16)
- Bấm **Bắt đầu tập** hôm nay.
- Nhập mức tạ (kg) và số reps cho từng hiệp tập; bấm tick hoàn thành hiệp.
- Đồng hồ đếm ngược thời gian nghỉ tự động kích hoạt.

#### Bước 13: Hoàn thành Buổi tập & Tự động ghi nhận Kỷ lục PR (MH17, MH18)
- Bấm **Hoàn thành buổi tập**.
- Xem trang Tổng kết: Tổng khối lượng nâng (Volume), thời gian tập, calo tiêu hao.
- Hệ thống AI tự động phát hiện và gắn huy hiệu **Kỷ lục cá nhân (PR)** mới.

#### Bước 14: Trang Cá nhân với Số liệu Thật (MH26)
- Vào tab **Cá nhân**.
- Kiểm tra chỉ số cơ thể, chuỗi ngày tập liên tiếp (Streak), thời lượng và biểu đồ khối lượng 7 ngày thực tế với cột hôm nay được đánh dấu chuẩn xác theo thời gian thực.
- Biểu đồ xu hướng cân nặng 30 ngày vẽ từ dữ liệu cân thực tế.

#### Bước 15: Phân tích Chuyên sâu & Phục hồi Nhóm cơ (MH28)
- Mở trang **Tiến độ & Phân tích**.
- Lọc theo *Tuần này / Tháng này / 3 tháng qua*: xem tổng tải trọng, tỷ lệ tăng trưởng % Progressive Overload, phân bổ tải Đẩy/Kéo/Chân.
- Xem ma trận **Phục hồi nhóm cơ**: Thời gian phục hồi tính theo giờ thực tế kể từ buổi tập gần nhất.

#### Bước 16: Ghi nhận Cân nặng Định kỳ (MH27)
- Bấm **Cập nhật cân nặng**.
- Nhập mốc cân mới: Hệ thống tự động tính lại BMI, BMR, TDEE và vẽ lại đường xu hướng cân nặng.

#### Bước 17: Tra cứu Dinh dưỡng Món ăn Việt (MH20, MH21)
- Vào tab **Dinh dưỡng** -> Tra cứu món ăn Việt Nam trong cơ sở dữ liệu.
- Lưu các món ăn thường dùng vào danh sách **Yêu thích**.

#### Bước 18: Ghi nhật ký Bữa ăn & Cảnh báo Macro (MH22, MH23, MH24)
- Thêm món ăn vào bữa Sáng, Trưa, Tối: nhập số gram hoặc số phần ăn.
- Thanh tiến trình calo và macro tự động cập nhật số calo đã nạp và còn lại.
- Nếu vượt quá calo mục tiêu, hệ thống hiển thị cảnh báo trực quan nhưng không chặn ghi nhật ký.

#### Bước 19: Trung tâm Thông báo & Lời nhắc Tập luyện (MH41)
- Bấm vào biểu tượng Chuông thông báo trên Header.
- Xem các lời nhắc tập luyện, nhắc uống nước và cập nhật tiến độ.
- Thao tác đánh dấu đã đọc hoặc xóa thông báo (idempotent).

#### Bước 20: AI Coach & Cá nhân hóa Dinh dưỡng/Tập luyện (MH30, MH31)
- Vào tab **AI Coach**: Bật tính năng **Cá nhân hóa AI** (AI Consent).
- Đặt câu hỏi tư vấn về kỹ thuật tập luyện hoặc gợi ý thực đơn tăng cơ giảm mỡ.
- AI phản hồi dựa trên ngữ cảnh thể trạng thực tế của người dùng.

#### Bước 21: Bảo mật Tài khoản & Kiểm thử Phân quyền (MH37)
- Vào **Cài đặt** -> **Bảo mật tài khoản**.
- Kiểm tra trạng thái xác thực 2 lớp, đổi mật khẩu.
- Thử nghiệm đăng nhập tài khoản ADMIN trên app Mobile: Hệ thống từ chối an toàn với mã lỗi `ADMIN_WEB_ONLY`.

---

## 3. Tiêu chí Đạt (Pass Criteria) cho UAT

1. **Tính trọn vẹn (Completeness):** Cả 21 bước đều thực hiện mượt mà không gặp lỗi crash hoặc đơ giao diện.
2. **Dữ liệu thật (No Fake Mock):** Toàn bộ số liệu cân nặng, khối lượng tập, streak, dinh dưỡng và PR hiển thị đúng từ cơ sở dữ liệu PostgreSQL.
3. **Bảo mật phân quyền (Security Boundary):** Phân định rạch ròi giữa Web Admin và Mobile App.
4. **Hiệu năng (Performance):** Thời gian phản hồi API trung bình dưới 20ms đối với các tác vụ thông thường.
