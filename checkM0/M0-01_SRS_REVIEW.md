# M0-01 — Review SRS v3.0

> **Ngày review:** 2026-08-19  
> **Tài liệu:** `docs/spec/specs.md`  
> **Phiên bản được review:** 3.0  
> **Kết luận:** Đạt điều kiện làm Source of Truth cấp yêu cầu; 8/8 phát hiện đã được xử lý ngày 2026-08-19

## 1. Mục tiêu review

Xác nhận `specs.md` v3.0 có thể đóng vai trò tài liệu có quyền quyết định cao nhất về yêu cầu và phạm vi của VieGym trước khi bắt đầu triển khai source code.

Review này chỉ xác nhận vai trò và mức độ đầy đủ của SRS. Việc đối chiếu chi tiết SRS với các tài liệu cấp dưới thuộc M0-02; các lựa chọn kỹ thuật thuộc M0-04 đến M0-12.

## 2. Kết quả kiểm tra

### Nhận diện và quyền quyết định

- [x] Tiêu đề xác định rõ đây là Software Requirements Specification v3.0.
- [x] Tài liệu tự công bố là Source of Truth cấp yêu cầu.
- [x] Có ngày cập nhật 2026-08-19 và nền tảng MVP.
- [x] Có nguyên tắc kiến trúc xuyên suốt: Backend tính toán/thực thi, AI đề xuất, User quyết định.
- [x] Có danh sách tài liệu cấp dưới và mô tả ownership của từng tài liệu.

### Phạm vi

- [x] Phân biệt P0, P1, P2 và Out of Scope.
- [x] P0 bao phủ Auth, Health, Workout, Nutrition, Dashboard, AI, Admin/Audit và Media baseline.
- [x] Shop/Marketplace, Payment, Wearable, Computer Vision và AI tự mutation được loại khỏi MVP.
- [x] Admin P0 và Admin mở rộng P1 được tách rõ.
- [x] Weekly Review, Plan Adjustment và Preference Memory được đánh dấu P1.

### Yêu cầu nghiệp vụ

- [x] Có Core User Journey end-to-end.
- [x] Có actor USER, ADMIN và AI PROVIDER.
- [x] Có enum và state machine quan trọng.
- [x] Có functional requirements cho các domain P0.
- [x] Có công thức BMI, BMR, TDEE, calories, macro, workout và meal.
- [x] Có privacy, security và reliability baseline.

### AI và trust boundary

- [x] AI Service không được truy cập database hoặc tự mutation.
- [x] Consent được kiểm tra trước Context Builder.
- [x] Context có whitelist, minimization và budget.
- [x] AI output phải qua schema, business và safety validation.
- [x] Apply/Dismiss giữ quyền quyết định của User.
- [x] Có allowed-action contract và prompt-injection boundary.

### Khả năng nghiệm thu và truy vết

- [x] Có 21 mã Use Case từ UC-01 đến UC-21, gồm cả P0 và P1.
- [x] Có 19 Acceptance Criteria từ AC-01 đến AC-19.
- [x] Có traceability rút gọn từ requirement sang Use Case và Acceptance Criteria.
- [x] Có testing strategy cấp cao và E2E demo flow.
- [x] Có Definition of Done cấp hệ thống.
- [x] Toàn bộ 9 tài liệu được SRS liên kết đều tồn tại trong repository.

## 3. Điểm mạnh

1. **Boundary nghiệp vụ rõ:** Backend là business authority; PostgreSQL là source of truth; AI không có quyền mutation.
2. **Phạm vi được bảo vệ:** P0/P1/P2 và Out of Scope được ghi rõ, giúp hạn chế scope creep trong đồ án tốt nghiệp.
3. **Luồng AI an toàn:** consent, context whitelist, output validation và User approval tạo thành một chuỗi kiểm soát đầy đủ.
4. **Yêu cầu có thể kiểm thử:** 21 AC bao phủ ownership, transaction, state machine, AI safety, audit, Favorites và Notification.
5. **Có truy vết:** SRS liên kết Use Case, AC và các tài liệu API/DB/screen/architecture cấp dưới.
6. **Phù hợp triển khai theo vertical slice:** các Use Case được nhóm theo Auth, Health, Workout, Nutrition, AI và Admin/Media.

## 4. Điểm cần làm rõ

### F-01 — Tên loại đồ án cần được thống nhất

- **Trạng thái:** Đã xử lý.
- **Mức độ:** Trung bình, không chặn M1.
- **Vị trí:** Metadata SRS và file kế hoạch tiến độ.
- **Quan sát:** Hai tài liệu từng sử dụng cách gọi khác nhau.
- **Rủi ro:** Tài liệu nộp có metadata không nhất quán.
- **Xử lý đề xuất:** Xác nhận tên chính thức và dùng thống nhất trong toàn bộ tài liệu.
- **Cách xử lý:** Tên chính thức được xác nhận là “đồ án tốt nghiệp”; SRS, kế hoạch, review, kiến trúc, database và server đã được chuẩn hóa theo tên này.

### F-02 — `Gender` có giá trị chưa có công thức BMR

- **Trạng thái:** Đã xử lý.
- **Mức độ:** Cao, chặn M2-20 nếu không được quyết định.
- **Vị trí:** Enum cho phép `OTHER`, `UNSPECIFIED`; công thức BMR chỉ có Nam/Nữ.
- **Rủi ro:** Backend không có kết quả deterministic cho hai giá trị còn lại.
- **Xử lý đề xuất:** Chốt policy nghiệp vụ trong SRS/ADR: yêu cầu biological-sex input riêng cho calculation, chọn công thức với consent rõ ràng, hoặc trả trạng thái metric incomplete.
- **Cách xử lý:** Tách `calculationSex` khỏi `gender`; chỉ hỗ trợ `MALE/FEMALE` cho Mifflin–St Jeor. `UNSPECIFIED` hoặc age dưới 18 trả `INCOMPLETE`, không tạo BMR/TDEE/target giả.

### F-03 — Calories và macro dùng khoảng nhưng chưa có thuật toán chọn

- **Trạng thái:** Đã xử lý.
- **Mức độ:** Cao, chặn M2-21.
- **Vị trí:** Calories deficit/surplus và protein/fat đều là khoảng.
- **Rủi ro:** Hai implementation có thể cho target khác nhau nhưng đều “đúng tài liệu”.
- **Xử lý đề xuất:** Chốt giá trị mặc định hoặc rule theo goal/experience, minimum calories, rounding và precision.
- **Cách xử lý:** Chốt offset `-400/0/+400/+300`, protein factor `2.0/1.4/1.6/2.0 g/kg`, fat `25%`, ngưỡng 1.200 kcal, rule reject và precision hai chữ số.

### F-04 — Một số business rule vẫn dùng từ không bắt buộc

- **Trạng thái:** Đã xử lý.
- **Mức độ:** Trung bình.
- **Ví dụ:** refresh-token rotation “được khuyến nghị”; một active Workout Program “nên có”; Exercise hidden “không nên” được thêm mới.
- **Rủi ro:** Không rõ đây là AC bắt buộc hay lựa chọn implementation.
- **Xử lý đề xuất:** Chuyển thành `MUST/SHOULD` rõ ràng trong M0-02 hoặc ADR tương ứng.
- **Cách xử lý:** Rotation mỗi lần refresh, tối đa một program ACTIVE và cấm thêm Exercise hidden vào program mới đều được chuyển thành rule bắt buộc.

### F-05 — Persona demo sử dụng tính năng P1

- **Trạng thái:** Đã xử lý.
- **Mức độ:** Trung bình, có thể gây scope creep.
- **Vị trí:** Persona “Người duy trì sức khỏe” yêu cầu demo Weekly Review trong khi Weekly Review là P1.
- **Rủi ro:** P1 bị hiểu nhầm là bắt buộc trong demo P0.
- **Xử lý đề xuất:** Đổi demo persona sang Dashboard/Daily Recommendation hoặc ghi rõ đây là demo mở rộng.
- **Cách xử lý:** Persona “Người duy trì sức khỏe” dùng Daily Recommendation P0 thay cho Weekly Review P1.

### F-06 — NFR hiệu năng thiếu điều kiện đo

- **Trạng thái:** Đã xử lý.
- **Mức độ:** Thấp đến trung bình.
- **Vị trí:** P95 read API phổ biến dưới 500 ms.
- **Thiếu:** endpoint áp dụng, lượng dữ liệu seed, concurrency, warm-up và cấu hình máy.
- **Rủi ro:** Không thể tái lập kết quả nghiệm thu.
- **Xử lý đề xuất:** Tạo performance test profile cụ thể trước M8-13.
- **Cách xử lý:** Chốt endpoint, 4 vCPU/8 GB, dataset 100 user/40 Exercise/80 Food/90 ngày, 10 virtual users, warm-up 2 phút, đo 5 phút, P95 dưới 500 ms và error rate dưới 1%.

### F-07 — Chất lượng và nguồn dữ liệu Food/Exercise chưa có tiêu chí định lượng

- **Trạng thái:** Đã xử lý.
- **Mức độ:** Thấp.
- **Quan sát:** SRS yêu cầu “đủ dữ liệu demo” nhưng chưa quy định số lượng, trường bắt buộc, nguồn hoặc cách kiểm chứng.
- **Rủi ro:** Dataset demo bị đánh giá là thiếu hoặc không đáng tin cậy.
- **Xử lý đề xuất:** Chốt seed acceptance tại M0-02 hoặc trước M4-02/M5-02.
- **Cách xử lý:** Chốt tối thiểu 40 Exercise, 80 Food, coverage domain, field/source bắt buộc, idempotency và media tối thiểu cho demo.

### F-08 — Privacy retention và account deletion chưa được chốt

- **Trạng thái:** Đã xử lý trong phạm vi đồ án tốt nghiệp.
- **Mức độ:** Thấp cho demo, quan trọng nếu triển khai thực tế.
- **Quan sát:** Có consent history và data minimization nhưng chưa có retention/account purge cụ thể.
- **Rủi ro:** Không đủ policy nếu phạm vi chuyển sang production.
- **Xử lý đề xuất:** Giữ ngoài đường găng đồ án tốt nghiệp; ghi rõ demo scope và đưa vào ADR vận hành nếu cần.
- **Cách xử lý:** Chỉ dùng synthetic/demo data; purge trước bàn giao hoặc trong 30 ngày sau chấm. Self-service deletion/legal retention được ghi rõ ngoài P0 và bắt buộc có ADR trước dữ liệu thật/production.

## 5. Quyết định M0-01

`docs/spec/specs.md` v3.0 được **xác nhận là Source of Truth cấp yêu cầu** cho VieGym với thứ tự quyền quyết định sau:

1. SRS quyết định scope, requirement, priority, business rule cấp cao và Acceptance Criteria.
2. Business Flow diễn giải hành vi end-to-end nhưng không được thay đổi SRS.
3. Feature/Subsystem/Screen breakdown phân rã yêu cầu nhưng không được mở rộng P0 ngoài SRS.
4. API, Database, Architecture, Tech Stack và Server Specification hiện thực hóa yêu cầu nhưng không được tự sửa business rule.
5. Khi có mâu thuẫn, implementation phải dừng tại điểm bị ảnh hưởng, ghi issue/ADR và cập nhật tài liệu owner trước khi tiếp tục.

Các điểm F-01 đến F-08 đã được xử lý và đồng bộ vào SRS cùng các tài liệu owner liên quan. M0-02 vẫn phải thực hiện review chéo toàn bộ tài liệu trước khi xác nhận không còn mâu thuẫn khác.

## 6. Bằng chứng

- SRS đã được đọc đầy đủ: 1.434 dòng, 26 mục cấp cao.
- Kiểm tra nhận diện được 21 mã Use Case, 19 mã Acceptance Criteria và 9 mã NFR.
- Kiểm tra tồn tại của 9/9 tài liệu liên kết: đạt.
- File nguồn: `docs/spec/specs.md`.
- Tài liệu đã đồng bộ: SRS, API, Database, Feature Breakdown, Business Flow, Screen Breakdown, Subsystem Breakdown, System Architecture, Server và Master Design.
