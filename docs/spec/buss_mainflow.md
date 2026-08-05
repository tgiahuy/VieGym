# Luồng Nghiệp Vụ Chính — VieGym

> Mô tả các luồng nghiệp vụ cốt lõi của ứng dụng VieGym.

---

## 1. Tổng quan luồng chính

```text
Guest
  └── Đăng ký / Đăng nhập
        └── Hoàn thiện hồ sơ sức khỏe
              ├── Dashboard cá nhân
              ├── Luyện tập
              ├── Meal Planner
              ├── AI Coach
              └── Cửa hàng
```

---

## 2. Luồng đăng ký, đăng nhập và hồ sơ sức khỏe

```text
User mở app
  ↓
Đăng ký hoặc đăng nhập
  ↓
Backend xác thực và cấp JWT
  ↓
User nhập tuổi, giới tính, chiều cao, cân nặng, mức vận động, mục tiêu
  ↓
Backend tính BMI, BMR, TDEE, calories và macro mục tiêu
  ↓
Lưu HealthProfile
  ↓
Hiển thị Dashboard
```

Kết quả:

- User có hồ sơ sức khỏe hoàn chỉnh.
- Dashboard có dữ liệu calories/macro/cân nặng.
- AI Coach có context cơ bản để tư vấn.

---

## 3. Luồng luyện tập

```text
User vào Workout
  ↓
Xem thư viện bài tập
  ↓
Chọn giáo án mẫu hoặc tạo giáo án custom
  ↓
Thêm bài tập, sets, reps, rest time
  ↓
Tạo lịch tập theo tuần/tháng
  ↓
Đến ngày tập, user ghi nhận bài tập đã làm
  ↓
Nhập sets, reps, mức tạ
  ↓
Backend lưu WorkoutLog và cập nhật thống kê/PR
```

Trạng thái lịch tập:

- `SCHEDULED`: đã lên lịch.
- `COMPLETED`: đã hoàn thành.
- `MISSED`: đã quá hạn nhưng chưa hoàn thành.
- `CANCELLED`: đã hủy.

---

## 4. Luồng Meal Planner

```text
User mở Meal Planner hôm nay
  ↓
Tìm món ăn Việt Nam
  ↓
Xem calories/protein/carb/fat từng món
  ↓
Thêm món vào BREAKFAST / LUNCH / DINNER / SNACK
  ↓
Chọn khẩu phần
  ↓
Backend tính tổng calories và macro trong ngày
  ↓
So sánh với mục tiêu cá nhân
  ↓
Hiển thị cảnh báo hoặc gợi ý món phù hợp
```

Business rules:

- Mỗi user có một meal plan theo ngày.
- Mỗi entry lưu snapshot calories/macro tại thời điểm thêm.
- AI Coach có thể đọc meal plan hiện tại để tư vấn.

---

## 5. Luồng AI Coach

```text
User gửi câu hỏi
  ↓
Backend xác thực user
  ↓
Backend gom context được phép: health, workout, meal, goal
  ↓
Gửi request sang FastAPI AI Service
  ↓
AI Service gọi OpenAI/Gemini
  ↓
Trả câu trả lời tiếng Việt
  ↓
Backend lưu hội thoại và trả về app
```

Guardrails:

- Không thay thế bác sĩ.
- Với chấn thương/bệnh lý, khuyến nghị hỏi chuyên gia.
- Không gửi dữ liệu nhạy cảm không cần thiết sang AI Provider.

---

## 6. Luồng theo dõi cân nặng

```text
User nhập cân nặng theo ngày
  ↓
Backend lưu WeightLog
  ↓
Nếu trùng ngày thì cập nhật bản ghi hiện có
  ↓
Dashboard hiển thị cân nặng hiện tại và biểu đồ
  ↓
Hệ thống so sánh với mục tiêu
```

---

## 7. Luồng mua hàng

```text
User xem danh sách sản phẩm
  ↓
Xem chi tiết sản phẩm
  ↓
Thêm vào giỏ hàng
  ↓
Checkout
  ↓
Backend tạo Order và OrderItems snapshot giá
  ↓
Thanh toán COD hoặc online
  ↓
User theo dõi trạng thái đơn hàng
  ↓
Admin xác nhận/giao hàng/cập nhật trạng thái
```

---

## 8. Luồng Admin

Admin có thể:

- Quản lý người dùng.
- Quản lý bài tập, nhóm cơ, thiết bị.
- Quản lý món ăn Việt Nam và danh mục món ăn.
- Import/chuẩn hóa dữ liệu dinh dưỡng.
- Quản lý sản phẩm, danh mục sản phẩm, tồn kho.
- Quản lý đơn hàng.
- Xem dashboard admin.
- Xem audit log.
