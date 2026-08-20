# Kế hoạch và theo dõi tiến độ triển khai VieGym

> **Phiên bản:** 2.1
> **Ngày cập nhật:** 2026-08-20
> **Loại dự án:** Đồ án tốt nghiệp
> **Phạm vi:** MVP P0 theo SRS v3.0  
> **Thời gian kế hoạch:** 24 tuần  
> **Trạng thái tổng thể:** M0R đã hoàn thành; sẵn sàng thực hiện M1

## 1. Cách sử dụng tài liệu

Đây là file kế hoạch chính đồng thời là checklist theo dõi tiến độ của dự án.

- Khi bắt đầu công việc, giữ `[ ]` và thêm `Đang thực hiện` vào ghi chú nếu cần.
- Khi công việc đã đáp ứng đầy đủ tiêu chí hoàn thành, đổi `[ ]` thành `[x]`.
- Không đánh dấu hoàn thành chỉ vì đã viết code; test và tài liệu liên quan cũng phải hoàn tất.
- Sau mỗi buổi làm việc, cập nhật mục **Nhật ký triển khai** ở cuối file.
- Sau mỗi milestone, cập nhật tiến độ tổng quan và điền minh chứng nghiệm thu.
- Nếu thay đổi phạm vi hoặc thiết kế, ghi quyết định vào ADR và liên kết trong ghi chú.
- Không triển khai P1/P2 trước khi toàn bộ milestone P0 đã hoàn thành.

Quy ước trạng thái công việc:

- `[ ]`: Chưa hoàn thành.
- `[x]`: Đã hoàn thành và có thể kiểm chứng.
- Công việc bị chặn: giữ `[ ]` và ghi `BLOCKED — lý do` trong phần ghi chú milestone.
- Công việc bị loại khỏi phạm vi: giữ `[ ]`, ghi `CANCELLED — lý do` và cập nhật tài liệu phạm vi.

## 2. Mục tiêu sản phẩm

Hoàn thành một MVP Android của VieGym có thể cài đặt, chạy end-to-end, demo và nghiệm thu. Sản phẩm gồm:

- Flutter Mobile App cho USER và Admin P0.
- Spring Boot Backend cung cấp REST API `/api/v1`.
- PostgreSQL là nguồn dữ liệu authoritative và được quản lý bằng Flyway.
- FastAPI AI Service stateless, chỉ nhận context do Backend cung cấp.
- Media baseline cho Exercise và Food; avatar Profile thuộc P1.
- Docker Compose, CI, seed data, APK và tài liệu demo.
- 19 Acceptance Criteria cấp MVP và 7 luồng E2E bắt buộc.

## 3. Nguyên tắc triển khai

- Triển khai theo **vertical slice**: Database → Backend → Mobile → Test → Demo.
- Backend tính toán, kiểm tra và thực hiện mutation nghiệp vụ.
- AI chỉ diễn giải và đề xuất; User quyết định; Backend validate rồi mới thực hiện.
- Mobile không gọi FastAPI hoặc AI Provider trực tiếp.
- Mọi private resource phải kiểm tra authentication, role và ownership tại Backend.
- Mỗi thay đổi phải truy vết được qua `AC → UC → FT → MH → API → DB → Test`.
- Không đưa Redis, microservice, Kubernetes, web admin riêng hoặc tính năng P1 vào đường găng MVP.

## 4. Bảng điều khiển tiến độ

> Cập nhật phần này khi hoàn thành một milestone. Số công việc được tính theo các checkbox có mã trong từng milestone.

- [x] **M0 — Khóa phạm vi và quyết định kỹ thuật** — Tuần 1 — Tiến độ: 15/15
- [x] **M0R — Remediation sau independent review** — Gate trước M1 — Tiến độ: 12/12
- [ ] **M1 — Nền tảng kỹ thuật và skeleton** — Tuần 2–3 — Tiến độ: 0/22
- [ ] **M2 — Identity, Session và Onboarding** — Tuần 4–6 — Tiến độ: 0/27
- [ ] **M3 — Health, Weight và Dashboard** — Tuần 7–8 — Tiến độ: 0/18
- [ ] **M4 — Workout Core** — Tuần 9–12 — Tiến độ: 0/27
- [ ] **M5 — Nutrition và Meal Planner** — Tuần 13–15 — Tiến độ: 0/22
- [ ] **M6 — AI Coach và Recommendation** — Tuần 16–19 — Tiến độ: 0/28
- [ ] **M7 — Admin, Media và Audit** — Tuần 20–21 — Tiến độ: 0/19
- [ ] **M8 — Hardening, UAT và Release** — Tuần 22–24 — Tiến độ: 0/28

**Tiến độ tổng:** 27/218 công việc — 12,4%
**Milestone hiện tại:** M1
**Cập nhật gần nhất:** 2026-08-20
**Ghi chú tổng:** M0 và gate M0R hoàn thành. P0 không bị thu hẹp; contract đã được hòa giải trước khi bootstrap M1.

---

## 5. M0 — Khóa phạm vi và quyết định kỹ thuật

**Thời gian:** Tuần 1  
**Phụ thuộc:** Bộ đặc tả hiện tại  
**Mục tiêu:** tạo backlog có thể triển khai và đóng các quyết định kỹ thuật đang chặn bootstrap.  
**Trạng thái:** Hoàn thành
**Tiến độ:** 15/15

### Công việc

- [x] **M0-01** — Đọc và xác nhận SRS v3.0 là source of truth về yêu cầu và phạm vi.
- [x] **M0-02** — Kiểm tra tính nhất quán giữa SRS, business flow, feature breakdown và screen breakdown.
- [x] **M0-03** — Lập danh sách P0 chính thức; xác nhận không có Shop, Payment, Wearable hoặc tính năng P1.
- [x] **M0-04** — Chọn một state-management package cho Flutter và tạo ADR.
- [x] **M0-05** — Chọn AI Provider, model mặc định, SDK và tạo ADR.
- [x] **M0-06** — Chọn object storage local/demo và phương án media production, tạo ADR.
- [x] **M0-07** — Chốt cơ chế lưu refresh token trên Mobile và tạo ADR.
- [x] **M0-08** — Chọn OTP email provider; chốt TTL, số lần thử, cooldown và rate limit.
- [x] **M0-09** — Chốt MIME, extension và kích thước tối đa cho từng loại media P0.
- [x] **M0-10** — Chốt cơ chế hết hạn Recommendation/Schedule: scheduler hoặc lazy-on-read.
- [x] **M0-11** — Pin Flutter/Dart, Java/Spring Boot, Python/FastAPI và PostgreSQL version.
- [x] **M0-12** — Chọn Maven và một Python package manager; xác định lockfile bắt buộc.
- [x] **M0-13** — Chia P0 thành epic/story và gắn UC, FT, MH, API, DB, test cho từng story.
- [x] **M0-14** — Chốt Git workflow, quy tắc đặt branch/commit/PR và coding convention.
- [x] **M0-15** — Kiểm tra toàn bộ ticket của M1 và M2 đạt Definition of Ready.

### Cổng nghiệm thu M0

- [x] Tất cả ADR chặn triển khai đã ở trạng thái `ACCEPTED`.
- [x] Backlog P0 có priority, dependency và acceptance criteria rõ ràng.
- [x] Không còn quyết định OPEN nào chặn M1 hoặc M2.
- [x] Milestone M0 đã được review kỹ thuật; review với giảng viên sẽ thực hiện riêng nếu được yêu cầu.

**Ngày bắt đầu thực tế:** 2026-08-19
**Ngày hoàn thành thực tế:** 2026-08-19
**Minh chứng:** [`M0-01_SRS_REVIEW.md`](../checkM0/M0-01_SRS_REVIEW.md), [`M0-02_SPEC_CONSISTENCY_REVIEW.md`](../checkM0/M0-02_SPEC_CONSISTENCY_REVIEW.md), [`M0-03_P0_SCOPE_BASELINE.md`](../checkM0/M0-03_P0_SCOPE_BASELINE.md), [`ADR-001`](../checkM0/ADR-001_FLUTTER_STATE_MANAGEMENT.md) đến [`ADR-007`](../checkM0/ADR-007_EXPIRY_POLICY.md), [`M0-11_12_VERSION_BUILD_BASELINE.md`](../checkM0/M0-11_12_VERSION_BUILD_BASELINE.md), [`M0-13_P0_BACKLOG_TRACEABILITY.md`](../checkM0/M0-13_P0_BACKLOG_TRACEABILITY.md), [`M0-14_GIT_AND_CODING_CONVENTIONS.md`](../checkM0/M0-14_GIT_AND_CODING_CONVENTIONS.md), [`M0-15_DEFINITION_OF_READY_REVIEW.md`](../checkM0/M0-15_DEFINITION_OF_READY_REVIEW.md)
**Ghi chú M0:** Hoàn thành 15/15. P0 frozen; 7 ADR ACCEPTED; runtime/build pin; 20 story có traceability; 49/49 ticket M1/M2 READY.

---

## 5A. M0R — Remediation sau independent review

**Phụ thuộc:** M0 và ba báo cáo review ngày 2026-08-20
**Mục tiêu:** hòa giải contract trước khi sinh migration/OpenAPI/source code mà không tự ý giảm P0.
**Trạng thái:** Hoàn thành
**Tiến độ:** 12/12

- [x] **M0R-01** — Khóa profile IANA timezone là nguồn authoritative cho ngày nghiệp vụ.
- [x] **M0R-02** — Khóa health-v1: calculation sex, age, decimal/HALF_UP và golden test.
- [x] **M0R-03** — Chốt WeightLog natural-key upsert và rule đồng bộ latest weight/metrics, không đổi target.
- [x] **M0R-04** — Chốt completion-rate, cutoff/grace và lazy `MISSED` theo ADR-007.
- [x] **M0R-05** — Chốt stable Program child ID, hidden-reference và một active Session/user.
- [x] **M0R-06** — Chốt Food gram conversion, normalized search và Meal target/input snapshot.
- [x] **M0R-07** — Tách read-only Dashboard/GET Recommendation khỏi POST generation command.
- [x] **M0R-08** — Chốt `rules-v1`, candidate shortlist, targetDate/preference whitelist và BLOCKED non-persistence.
- [x] **M0R-09** — Bổ sung recommendation generation batch/idempotency và PR read model.
- [x] **M0R-10** — Chốt resource-first Media lifecycle với owner/role/sort bắt buộc.
- [x] **M0R-11** — Chốt error-code/HTTP matrix, pagination và OpenAPI `dart-dio` no-diff CI gate.
- [x] **M0R-12** — Đồng bộ SRS, flow, feature, screen, subsystem, API, DB, SA, server, tech stack và backlog.

**Quyết định phạm vi:** giữ nguyên P0 frozen. `LOG_REMINDER_ONLY`, Login OTP/MFA,
conversation archive và account auto-lock không được lén đưa vào P0; chúng vẫn là P1.

---

## 6. M1 — Nền tảng kỹ thuật và skeleton

**Thời gian:** Tuần 2–3  
**Phụ thuộc:** M0  
**Mục tiêu:** tạo hệ thống tối thiểu có thể build, test và chạy lặp lại trên môi trường sạch.  
**Trạng thái:** Chưa bắt đầu  
**Tiến độ:** 0/22

### Cấu trúc repository và môi trường

- [ ] **M1-01** — Khởi tạo Flutter project trong `mobile/` và pin Flutter SDK.
- [ ] **M1-02** — Khởi tạo Spring Boot project trong `backend/` với Maven Wrapper và Java 21.
- [ ] **M1-03** — Khởi tạo FastAPI project trong `ai-service/` với Python lockfile.
- [ ] **M1-04** — Tạo `.gitignore`, `.editorconfig` và quy tắc format/lint cho ba project.
- [ ] **M1-05** — Tạo `.env.example`; xác nhận không có secret thật trong repository.
- [ ] **M1-06** — Tạo Dockerfile cho Backend và AI Service với version được pin.
- [ ] **M1-07** — Tạo Docker Compose cho Backend, AI Service, PostgreSQL và object storage.
- [ ] **M1-08** — Thiết lập Docker healthcheck và internal network đúng kiến trúc.

### Backend và database foundation

- [ ] **M1-09** — Kết nối Spring Boot với PostgreSQL bằng cấu hình environment.
- [ ] **M1-10** — Thiết lập Flyway và migration baseline đầu tiên.
- [ ] **M1-11** — Tạo response envelope, pagination và error response dùng chung theo API Spec.
- [ ] **M1-12** — Tạo exception handler và validation error mapping.
- [ ] **M1-13** — Tạo correlation/request ID và JSON logging; che dữ liệu nhạy cảm.
- [ ] **M1-14** — Tạo liveness/readiness endpoint cho Backend.
- [ ] **M1-15** — Thiết lập OpenAPI/Swagger và pin OpenAPI Generator `dart-dio`.

### Mobile và AI foundation

- [ ] **M1-16** — Thiết lập Flutter theme, router, state-management root và environment config.
- [ ] **M1-17** — Tích hợp generated `dart-dio` client, timeout, refresh interceptor và API error mapping.
- [ ] **M1-18** — Tạo component/state dùng chung cho loading, empty, error, offline và retry.
- [ ] **M1-19** — Tạo FastAPI health endpoint và internal service-token guard.
- [ ] **M1-20** — Tạo Pydantic request/response contract và mock AI Provider.

### CI và tài liệu

- [ ] **M1-21** — Tạo CI chạy format, lint, test, migration, OpenAPI regenerate no-diff và build ba project.
- [ ] **M1-22** — Viết README hướng dẫn clean setup, run, test và cấu hình emulator/device.

### Cổng nghiệm thu M1

- [ ] Clone repository trên môi trường sạch và chạy stack thành công trong tối đa 30 phút.
- [ ] Mobile gọi được Backend health endpoint.
- [ ] Backend gọi được FastAPI health endpoint qua internal network.
- [ ] Flyway chạy thành công trên database rỗng.
- [ ] CI xanh trên commit của milestone.

**Ngày bắt đầu thực tế:**  
**Ngày hoàn thành thực tế:**  
**Minh chứng:**  
**Ghi chú M1:**

---

## 7. M2 — Identity, Session và Onboarding

**Thời gian:** Tuần 4–6  
**Phụ thuộc:** M1  
**Phạm vi:** UC-01..03; FT-ID-001..010; FT-UP-001/003/004; FT-HP-001..004  
**Màn hình:** MH01/02/04/05/06/07/08/09/10/44/52/53  
**Trạng thái:** Chưa bắt đầu  
**Tiến độ:** 0/27

### Database và Backend Identity

- [ ] **M2-01** — Tạo migration cho users, refresh_tokens, otp_codes, security rate-limit events và profile liên quan.
- [ ] **M2-02** — Tạo enum role/account status/OTP purpose nhất quán với API và database.
- [ ] **M2-03** — Triển khai đăng ký local, chuẩn hóa email và BCrypt password hashing.
- [ ] **M2-04** — Triển khai tạo/gửi OTP qua provider adapter; có fake provider cho local/test.
- [ ] **M2-05** — Triển khai verify OTP atomic: consume OTP, activate account và cấp session.
- [ ] **M2-06** — Triển khai OTP resend với expiry, cooldown, attempt và rate limit.
- [ ] **M2-07** — Triển khai đăng nhập email/password và kiểm tra account status.
- [ ] **M2-08** — Triển khai JWT access token, refresh token rotation và revocation.
- [ ] **M2-09** — Triển khai logout và thu hồi refresh token/session.
- [ ] **M2-10** — Triển khai forgot/reset password bằng OTP.
- [ ] **M2-11** — Triển khai change password cho local account đang đăng nhập.
- [ ] **M2-12** — Triển khai Google Identity token verification server-side.
- [ ] **M2-13** — Thiết lập Spring Security policy cho public/private/admin endpoint.
- [ ] **M2-14** — Kiểm tra lỗi auth không làm lộ account enumeration hoặc secret.

### Profile, Preference và Health Onboarding

- [ ] **M2-15** — Tạo migration User Profile, User Preference và Equipment Preference.
- [ ] **M2-16** — Tạo migration Health Profile, Nutrition Target và Weight Log ban đầu.
- [ ] **M2-17** — Triển khai xem/cập nhật User Profile theo whitelist field.
- [ ] **M2-18** — Triển khai User/Equipment Preference và `equipmentOnboardingCompletedAt` kể cả danh sách rỗng.
- [ ] **M2-19** — Triển khai validate Health Profile và range cho từng field.
- [ ] **M2-20** — Triển khai `health-v1`: tuổi theo timezone, decimal/HALF_UP, BMI/BMR/TDEE và golden fixtures.
- [ ] **M2-21** — Triển khai calories/macro target và rule xử lý kết quả bất hợp lệ.
- [ ] **M2-22** — Lưu Health Profile, metric, target và Weight Log ban đầu trong transaction.

### Flutter và kiểm thử

- [ ] **M2-23** — Hoàn thiện Session Bootstrap, Welcome, Login, Register và OTP UI.
- [ ] **M2-24** — Hoàn thiện Forgot/Reset/Change Password, Logout và Biometric UI.
- [ ] **M2-25** — Hoàn thiện Health và Equipment onboarding cùng navigation guard.
- [ ] **M2-26** — Triển khai secure token storage, refresh single-flight và clear credential khi logout.
- [ ] **M2-27** — Viết unit/integration/widget test cho auth, OTP, token và health calculations.

### Cổng nghiệm thu M2

- [ ] E2E 1 chạy được: Register → OTP → Health/Equipment onboarding → Dashboard ban đầu.
- [ ] OTP sai, hết hạn, dùng lại hoặc vượt số lần thử đều bị từ chối.
- [ ] Account pending/locked/disabled không nhận session nghiệp vụ.
- [ ] Private API từ chối access token không hợp lệ.
- [ ] Mở lại app resume đúng trạng thái session/onboarding authoritative.
- [ ] AC-01, AC-02 và phần onboarding của AC-03 đạt.

**Ngày bắt đầu thực tế:**  
**Ngày hoàn thành thực tế:**  
**Minh chứng:**  
**Ghi chú M2:**

---

## 8. M3 — Health, Weight và Dashboard

**Thời gian:** Tuần 7–8  
**Phụ thuộc:** M2  
**Phạm vi:** UC-10/11; FT-HP-005..007; FT-DB-001..005/007  
**Màn hình:** MH03/42/43  
**Trạng thái:** Chưa bắt đầu  
**Tiến độ:** 0/18

### Health và Weight Backend

- [ ] **M3-01** — Triển khai GET/PUT Health Profile theo whitelist; cân nặng sau onboarding chỉ đổi qua WeightLog.
- [ ] **M3-02** — Recalculate BMI/BMR/TDEE/target khi field nền thay đổi.
- [ ] **M3-03** — Đảm bảo update profile và recalculation là một transaction.
- [ ] **M3-04** — Triển khai `PUT /weight-logs/{loggedDate}` natural-key upsert theo profile timezone.
- [ ] **M3-05** — Triển khai list Weight Log; log mới nhất sync current weight + BMI/BMR/TDEE.
- [ ] **M3-06** — Chống dữ liệu Weight Log trùng/không hợp lệ và xử lý tie theo `updatedAt`.
- [ ] **M3-07** — Triển khai trend/summary 7–30 ngày tại Backend.
- [ ] **M3-08** — Xác nhận Weight Log không tự thay đổi Nutrition Target.

### Dashboard

- [ ] **M3-09** — Thiết kế Dashboard read model không sở hữu mutation.
- [ ] **M3-10** — Tổng hợp Health, Weight, Workout, Nutrition và AI theo API contract; GET không sinh AI dữ liệu.
- [ ] **M3-11** — Trả section-level empty/incomplete/error thay vì làm hỏng toàn Dashboard.
- [ ] **M3-12** — Thêm query/index cần thiết và kiểm tra thời gian phản hồi baseline.

### Flutter và kiểm thử

- [ ] **M3-13** — Hoàn thiện màn hình xem/sửa Health Profile.
- [ ] **M3-14** — Hoàn thiện Weight Tracking, chart và progress.
- [ ] **M3-15** — Hoàn thiện Dashboard ban đầu và các section state.
- [ ] **M3-16** — Chuẩn hóa hiển thị timezone, ngày và đơn vị.
- [ ] **M3-17** — Refresh Dashboard sau mutation Health/Weight thành công.
- [ ] **M3-18** — Viết test cho formula boundary, ownership, trend và Dashboard empty/error.

### Cổng nghiệm thu M3

- [ ] E2E 4 chạy được: Weight Log → metric/progress refresh.
- [ ] AC-03, AC-04 và AC-09 đạt.
- [ ] Phần Health của AC-10 đạt.
- [ ] Mobile không tự tạo kết quả Health authoritative.

**Ngày bắt đầu thực tế:**  
**Ngày hoàn thành thực tế:**  
**Minh chứng:**  
**Ghi chú M3:**

---

## 9. M4 — Workout Core

**Thời gian:** Tuần 9–12  
**Phụ thuộc:** M2; Dashboard M3 có thể được mở rộng sau mutation  
**Phạm vi:** UC-04..07; FT-WO-001..009/011  
**Màn hình:** MH11..19  
**Trạng thái:** Chưa bắt đầu  
**Tiến độ:** 0/27

### Exercise Catalog

- [ ] **M4-01** — Tạo migration cho muscle_groups, equipment, exercises và mapping tables.
- [ ] **M4-02** — Tạo seed Exercise/Equipment ổn định phục vụ test và demo.
- [ ] **M4-03** — Triển khai Exercise list/search/filter/pagination.
- [ ] **M4-04** — Triển khai Exercise detail, safety instruction và media metadata.
- [ ] **M4-05** — Triển khai equipment matching, ranking và bài thay thế.
- [ ] **M4-06** — Chặn chọn mới Exercise hidden/inactive nhưng giữ lịch sử có thể đọc.

### Program và Schedule

- [ ] **M4-07** — Tạo migration Workout Program, Day, Exercise và Schedule.
- [ ] **M4-08** — Triển khai Program list/detail/create/update/archive theo ownership và hidden-reference rule.
- [ ] **M4-09** — Triển khai Workout Builder bằng stable child ID/diff; chặn xóa day đang được lịch nonterminal tham chiếu.
- [ ] **M4-10** — Enforce rule active program theo contract.
- [ ] **M4-11** — Triển khai Schedule CRUD và validate timezone/date.
- [ ] **M4-12** — Triển khai Schedule state machine, cancel cutoff, grace và lazy `MISSED` theo profile timezone.

### Session, Log và Progress

- [ ] **M4-13** — Tạo migration Workout Session/Log/Exercise Log/Set Log.
- [ ] **M4-14** — Triển khai Start Session với ownership, idempotency và unique một active session/user.
- [ ] **M4-15** — Triển khai Pause và Resume theo state machine.
- [ ] **M4-16** — Triển khai nhập set/reps/weight và validate dữ liệu.
- [ ] **M4-17** — Triển khai Finish Session atomic với log và schedule update.
- [ ] **M4-18** — Triển khai Discard; không tạo volume, completion hoặc PR giả.
- [ ] **M4-19** — Tính volume và completion rate theo eligible counts/cutoff; 0/0 trả null.
- [ ] **M4-20** — Tính và atomically upsert Personal Record `MAX_WEIGHT/MAX_REPS/MAX_VOLUME`.
- [ ] **M4-21** — Triển khai Workout History và detail snapshot.
- [ ] **M4-22** — Xử lý conflict khi hai request start/finish đồng thời.

### Flutter và kiểm thử

- [ ] **M4-23** — Hoàn thiện MH11..16: tab, library, detail, program, builder và schedule.
- [ ] **M4-24** — Hoàn thiện MH17 Session với pause/resume/finish/discard và unknown-result state.
- [ ] **M4-25** — Hoàn thiện MH18/19 History và Personal Record.
- [ ] **M4-26** — Refresh Dashboard/History từ response authoritative sau finish.
- [ ] **M4-27** — Viết unit/integration/widget test cho state machine, ownership, concurrency và calculations.

### Cổng nghiệm thu M4

- [ ] E2E 2 chạy được: Exercise → Program → Schedule → Session → Log/PR.
- [ ] Hai request Finish đồng thời không tạo hai Workout Log.
- [ ] Discard không tạo PR hoặc completion giả.
- [ ] User không đọc/sửa Workout resource của user khác.
- [ ] AC-05, AC-06 và AC-07 đạt.

**Ngày bắt đầu thực tế:**  
**Ngày hoàn thành thực tế:**  
**Minh chứng:**  
**Ghi chú M4:**

---

## 10. M5 — Nutrition và Meal Planner

**Thời gian:** Tuần 13–15  
**Phụ thuộc:** M2 và M3  
**Phạm vi:** UC-08/09; FT-MP-001..006/009/011  
**Màn hình:** MH20..25/54  
**Trạng thái:** Chưa bắt đầu  
**Tiến độ:** 0/22

### Food và Meal Backend

- [ ] **M5-01** — Tạo migration Food (`searchName`, `gramsPerServing`), Meal Plan/Entry snapshot và Template.
- [ ] **M5-02** — Tạo seed Food món Việt với serving và nutrition data hợp lệ.
- [ ] **M5-03** — Triển khai Food list/search/filter/pagination.
- [ ] **M5-04** — Triển khai Food detail và serving-unit contract.
- [ ] **M5-05** — Enforce PUBLIC/HIDDEN; hidden chỉ dùng để bảo toàn lịch sử, không có private Food P0.
- [ ] **M5-06** — Triển khai GET Meal Plan không ghi DB; tạo plan + immutable target snapshot tại mutation đầu.
- [ ] **M5-07** — Tạo unique constraint chống Meal Plan trùng user/date.
- [ ] **M5-08** — Triển khai add Meal Entry; nhập gram chỉ khi có `gramsPerServing`.
- [ ] **M5-09** — Lưu input amount/unit và nutrition snapshot khi tạo Meal Entry.
- [ ] **M5-10** — Triển khai update/delete Meal Entry theo ownership.
- [ ] **M5-11** — Tính calories/macro daily summary và remaining tại Backend.
- [ ] **M5-12** — Xử lý concurrent mutation không làm mất entry hoặc sai tổng.
- [ ] **M5-13** — Triển khai Meal History và Meal Template.
- [ ] **M5-14** — Copy template/history thành entry mới và validate Food hiện tại.
- [ ] **M5-15** — Trả warning/insight khi vượt target, không chặn ghi meal mặc định.

### Flutter và kiểm thử

- [ ] **M5-16** — Hoàn thiện Meal Tab, Food Library và Food Detail.
- [ ] **M5-17** — Hoàn thiện Meal Plan và Meal Entry Editor.
- [ ] **M5-18** — Hoàn thiện Nutrition Summary và trạng thái vượt target.
- [ ] **M5-19** — Hoàn thiện Meal History/Template preview và copy flow.
- [ ] **M5-20** — Refresh Dashboard sau add/update/delete Meal Entry.
- [ ] **M5-21** — Gắn nhãn tham khảo cho giá trị dinh dưỡng ước lượng.
- [ ] **M5-22** — Viết test cho snapshot, summary, ownership, concurrency và hidden Food.

### Cổng nghiệm thu M5

- [ ] E2E 3 chạy được: Food → Meal Entry → Nutrition Summary → Dashboard.
- [ ] Sửa Food không làm thay đổi Meal Entry lịch sử.
- [ ] Concurrent entry không tạo Meal Plan trùng hoặc tổng sai.
- [ ] AC-08 và phần Nutrition của AC-10 đạt.

**Ngày bắt đầu thực tế:**  
**Ngày hoàn thành thực tế:**  
**Minh chứng:**  
**Ghi chú M5:**

---

## 11. M6 — AI Coach và Recommendation

**Thời gian:** Tuần 16–19  
**Phụ thuộc:** M3, M4 và M5  
**Phạm vi:** UC-12..14/17; FT-AI-001..010/014  
**Màn hình:** MH27..31/55  
**Trạng thái:** Chưa bắt đầu  
**Tiến độ:** 0/28

### Consent và Context

- [ ] **M6-01** — Tạo migration AI Consent và Consent History.
- [ ] **M6-02** — Triển khai GET/PUT consent với ownership và audit.
- [ ] **M6-03** — Chặn personal context tại Backend khi consent OFF.
- [ ] **M6-04** — Triển khai General Knowledge Mode không dùng dữ liệu cá nhân.
- [ ] **M6-05** — Xây Context Builder theo task whitelist, candidate shortlist và field minimization.
- [ ] **M6-06** — Áp dụng context/token budget và không gửi secret/credential.
- [ ] **M6-07** — Lưu context snapshot tối thiểu theo retention policy.

### FastAPI và Provider

- [ ] **M6-08** — Triển khai internal `/internal/v1/ai/generate` contract.
- [ ] **M6-09** — Triển khai provider adapter cho provider đã chọn.
- [ ] **M6-10** — Version hóa `rules-v1`, prompt/model metadata; Spring Boot render prompt, FastAPI chỉ execute/parse.
- [ ] **M6-11** — Thiết lập connect/read timeout, retry hữu hạn và correlation ID.
- [ ] **M6-12** — Parse output thành Pydantic structured response.
- [ ] **M6-13** — Trả fallback an toàn khi provider timeout/error/invalid output.
- [ ] **M6-14** — Xác nhận FastAPI không có PostgreSQL/object-storage credential.

### Conversation và Recommendation

- [ ] **M6-15** — Tạo migration Conversation/Message effective mode, Request/Validation, Generation batch và Recommendation.
- [ ] **M6-16** — Triển khai create/list/detail Conversation theo ownership.
- [ ] **M6-17** — Triển khai gửi message cho General và Personalized mode.
- [ ] **M6-18** — Validate schema/safety/business, targetDate/candidate/preference whitelist; BLOCKED không persist.
- [ ] **M6-19** — Triển khai read-only GET và POST generation idempotent, atomically tạo 1–3 item.
- [ ] **M6-20** — Enforce state `PENDING/APPLIED/DISMISSED/EXPIRED`.
- [ ] **M6-21** — Triển khai preview Allowed Action theo domain owner.
- [ ] **M6-22** — Triển khai Apply idempotent qua domain owner và ghi audit.
- [ ] **M6-23** — Triển khai Dismiss chỉ đổi status/feedback, không mutation domain.
- [ ] **M6-24** — Xử lý double tap, conflict, expired và unknown-result.

### Flutter và kiểm thử

- [ ] **M6-25** — Hoàn thiện AI Tab, Consent và Conversation History.
- [ ] **M6-26** — Hoàn thiện Coach Chat và hiển thị đúng General/Personalized mode.
- [ ] **M6-27** — Hoàn thiện Recommendation List/Detail, Apply/Dismiss và trạng thái lỗi.
- [ ] **M6-28** — Viết test cho consent, context whitelist, invalid output, injection, timeout và idempotency.

### Cổng nghiệm thu M6

- [ ] E2E 5 chạy được: Consent → Personalized Chat → Daily Recommendation.
- [ ] E2E 6 chạy được: Apply → mutation + audit; Dismiss → không mutation.
- [ ] Consent OFF không gửi dữ liệu cá nhân hoặc tạo recommendation cá nhân hóa.
- [ ] Output sai schema/safety/business rule không trở thành action hợp lệ.
- [ ] AC-11 đến AC-17 đạt.

**Ngày bắt đầu thực tế:**  
**Ngày hoàn thành thực tế:**  
**Minh chứng:**  
**Ghi chú M6:**

---

## 12. M7 — Admin, Media và Audit

**Thời gian:** Tuần 20–21  
**Phụ thuộc:** M4, M5 và M6  
**Phạm vi:** UC-19/21; FT-AD-003/004/008; FT-MD-001..003  
**Màn hình:** MH45/46/47/51  
**Trạng thái:** Chưa bắt đầu  
**Tiến độ:** 0/19

### Admin và Audit

- [ ] **M7-01** — Tạo Admin shell/route riêng và role guard trên Flutter.
- [ ] **M7-02** — Enforce ADMIN role trên toàn bộ admin API tại Backend.
- [ ] **M7-03** — Triển khai Admin Exercise list/create/update/hide.
- [ ] **M7-04** — Triển khai Admin Food list/create/update/hide.
- [ ] **M7-05** — Giữ lịch sử khi Exercise/Food bị hide hoặc soft-delete.
- [ ] **M7-06** — Tạo/hoàn thiện Audit Log schema và service dùng chung.
- [ ] **M7-07** — Ghi audit cho admin mutation và AI Apply.
- [ ] **M7-08** — Redact password, token, OTP, API key và context không cần thiết khỏi audit.
- [ ] **M7-09** — Triển khai Audit Log read-only list/filter/detail cho Admin.

### Media

- [ ] **M7-10** — Tạo/hoàn thiện Media Object schema và ownership model.
- [ ] **M7-11** — Triển khai upload-init và presigned URL TTL ngắn.
- [ ] **M7-12** — Validate owner type, extension, MIME thực tế và file size.
- [ ] **M7-13** — Triển khai upload-complete với HEAD/object verification.
- [ ] **M7-14** — Triển khai access-url theo visibility và ownership.
- [ ] **M7-15** — Triển khai delete/hide metadata và xử lý object theo policy.
- [ ] **M7-16** — Tích hợp media cho Exercise và Food P0.

### Flutter và kiểm thử

- [ ] **M7-17** — Hoàn thiện Manage Exercise, Manage Food và Audit Log UI.
- [ ] **M7-18** — Hoàn thiện media picker/upload/progress/error/retry UI.
- [ ] **M7-19** — Viết test cho role, ownership, MIME/size, audit redaction và history preservation.

### Cổng nghiệm thu M7

- [ ] E2E 7 chạy được: Admin thêm Exercise/Food + media → User đọc catalog mới.
- [ ] USER không truy cập được admin API hoặc admin route.
- [ ] Hide Exercise/Food không phá Workout/Meal history.
- [ ] AC-18 và AC-19 đạt.

**Ngày bắt đầu thực tế:**  
**Ngày hoàn thành thực tế:**  
**Minh chứng:**  
**Ghi chú M7:**

---

## 13. M8 — Hardening, UAT và Release

**Thời gian:** Tuần 22–24  
**Phụ thuộc:** M0..M7  
**Mục tiêu:** chuyển bản feature-complete thành sản phẩm có thể cài đặt, demo và nghiệm thu.  
**Trạng thái:** Chưa bắt đầu  
**Tiến độ:** 0/28

### Regression và E2E

- [ ] **M8-01** — Chạy E2E 1 với happy path và failure branch.
- [ ] **M8-02** — Chạy E2E 2 với happy path và failure branch.
- [ ] **M8-03** — Chạy E2E 3 với happy path và failure branch.
- [ ] **M8-04** — Chạy E2E 4 với happy path và failure branch.
- [ ] **M8-05** — Chạy E2E 5 với happy path và failure branch.
- [ ] **M8-06** — Chạy E2E 6 với happy path và failure branch.
- [ ] **M8-07** — Chạy E2E 7 với happy path và failure branch.
- [ ] **M8-08** — Chạy regression toàn bộ API và Mobile sau khi sửa lỗi.

### Security, reliability và performance

- [ ] **M8-09** — Kiểm tra authentication, role và ownership matrix cho toàn bộ API P0.
- [ ] **M8-10** — Kiểm tra secret scan, dependency vulnerability và cấu hình production.
- [ ] **M8-11** — Kiểm tra rate limit cho OTP/login và validation input/file.
- [ ] **M8-12** — Kiểm tra log/audit không chứa secret hoặc dữ liệu cá nhân dư thừa.
- [ ] **M8-13** — Đo API latency baseline và review slow query/index.
- [ ] **M8-14** — Kiểm tra AI timeout, retry, quota/budget và fallback.
- [ ] **M8-15** — Chạy migration trên database rỗng.
- [ ] **M8-16** — Chạy migration trên bản sao database có dữ liệu mẫu.
- [ ] **M8-17** — Thực hiện backup và restore rehearsal.

### UX và chất lượng bản build

- [ ] **M8-18** — Review loading, empty, error, offline và unknown-result trên toàn bộ màn hình P0.
- [ ] **M8-19** — Review navigation, deep link, session, onboarding và role guard.
- [ ] **M8-20** — Review accessibility: touch target, contrast, font scale và semantic label.
- [ ] **M8-21** — Kiểm tra timezone, locale, date và unit trên toàn ứng dụng.
- [ ] **M8-22** — Kiểm tra APK trên emulator và ít nhất một thiết bị Android thật.
- [ ] **M8-23** — Đóng băng feature; chỉ nhận bug fix và tài liệu release.

### UAT và bàn giao

- [ ] **M8-24** — Đối chiếu và ghi bằng chứng cho đủ 19 Acceptance Criteria cấp MVP.
- [ ] **M8-25** — Chuẩn bị seed data, demo account và demo script 20 bước.
- [ ] **M8-26** — Hoàn thiện README, OpenAPI, runbook, kiến trúc và hướng dẫn cài đặt.
- [ ] **M8-27** — Build APK Release Candidate và Docker images được pin version.
- [ ] **M8-28** — Thực hiện UAT cuối, lập biên bản lỗi/chấp nhận và đóng milestone.

### Cổng nghiệm thu M8 — MVP Done

- [ ] CI xanh trên Release Candidate.
- [ ] 7/7 luồng E2E đạt cả happy path và failure branch.
- [ ] 19/19 Acceptance Criteria cấp MVP có bằng chứng.
- [ ] Không còn bug Blocker hoặc Critical.
- [ ] Bug Major còn lại có quyết định xử lý hoặc chấp nhận rõ ràng.
- [ ] Clean install, migration, backup/restore và APK install đều đạt.
- [ ] Demo hoàn chỉnh không cần sửa tay database.
- [ ] Sản phẩm và tài liệu đã sẵn sàng để nộp đồ án.

**Ngày bắt đầu thực tế:**  
**Ngày hoàn thành thực tế:**  
**Minh chứng:**  
**Ghi chú M8:**

---

## 14. Checklist 7 luồng E2E bắt buộc

- [ ] **E2E-01** — Register → OTP → Health/Equipment onboarding → Dashboard.
  - [ ] Happy path đạt.
  - [ ] OTP invalid/expired/rate-limit branch đạt.
- [ ] **E2E-02** — Login → Exercise → Program → Schedule → Session → Log/PR.
  - [ ] Happy path đạt.
  - [ ] Invalid transition/concurrent Finish branch đạt.
- [ ] **E2E-03** — Food → Meal Plan → Entry → Nutrition Summary → Dashboard.
  - [ ] Happy path đạt.
  - [ ] Hidden Food/invalid serving/concurrency branch đạt.
- [ ] **E2E-04** — Weight Log → metric/progress refresh.
  - [ ] Happy path đạt.
  - [ ] Invalid value/ownership branch đạt.
- [ ] **E2E-05** — AI consent enable → personalized chat → daily recommendation.
  - [ ] Happy path đạt.
  - [ ] Consent OFF/provider failure/invalid output branch đạt.
- [ ] **E2E-06** — Apply recommendation → domain mutation + audit; Dismiss → không mutation.
  - [ ] Apply happy path đạt.
  - [ ] Expired/double request/ownership branch đạt.
- [ ] **E2E-07** — Admin Exercise/Food + media → User đọc catalog mới.
  - [ ] Happy path đạt.
  - [ ] USER role/MIME invalid/hidden history branch đạt.

## 15. Checklist Acceptance Criteria cấp MVP

- [ ] **AC-01** — Đăng ký/OTP/đăng nhập hoạt động; private API yêu cầu JWT hợp lệ.
- [ ] **AC-02** — User chỉ truy cập Health/Meal/Workout/AI resource của mình.
- [ ] **AC-03** — Health Profile hợp lệ tạo metric và target tại Backend.
- [ ] **AC-04** — Sửa field nền tính lại metric/target nhất quán.
- [ ] **AC-05** — Equipment Preference ảnh hưởng ranking, không sửa log cũ.
- [ ] **AC-06** — Session transition hợp lệ; Finish/Discard tạo đúng kết quả.
- [ ] **AC-07** — CANCELLED bị loại khỏi completion-rate denominator.
- [ ] **AC-08** — Meal summary đúng serving, multiplier và target.
- [ ] **AC-09** — WeightLog tạo trend nhưng không tự sửa Nutrition Target.
- [ ] **AC-10** — Dashboard aggregate đúng nguồn và có empty/error state.
- [ ] **AC-11** — Consent OFF không gửi personal context/recommendation cá nhân hóa.
- [ ] **AC-12** — AI Service không truy cập DB; context đúng whitelist.
- [ ] **AC-13** — AI output sai không trở thành action hợp lệ.
- [ ] **AC-14** — Daily Recommendation tạo 1–3 PENDING item khi đủ điều kiện.
- [ ] **AC-15** — Apply chỉ chạy cho recommendation hợp lệ của đúng user.
- [ ] **AC-16** — Dismiss không mutation domain data.
- [ ] **AC-17** — Apply mutation qua domain owner và có audit.
- [ ] **AC-18** — Media hiển thị hợp lệ và enforce quyền/validation.
- [ ] **AC-19** — Audit không chứa secret hoặc personal context thừa.

## 16. Definition of Ready

Một công việc chỉ được bắt đầu khi:

- [ ] Có mã milestone và mã công việc duy nhất.
- [ ] Có UC/FT/MH liên quan hoặc được ghi rõ là technical task.
- [ ] API payload/error và schema/constraint liên quan đã rõ.
- [ ] Acceptance criteria có thể kiểm thử.
- [ ] Dependency đã hoàn thành hoặc có mock/fake được thống nhất.
- [ ] Không phụ thuộc ADR còn OPEN.

## 17. Definition of Done

Một công việc/vertical slice chỉ được đánh dấu `[x]` khi:

- [ ] Code đã hoàn thành và được format/lint.
- [ ] Happy path hoạt động từ Mobile đến Database nếu có UI.
- [ ] Failure path quan trọng đã được xử lý.
- [ ] Authentication, role và ownership guard đã kiểm tra.
- [ ] Unit/integration/widget test liên quan đã pass.
- [ ] Loading/empty/error/offline/unknown-result state đã xử lý khi phù hợp.
- [ ] Migration, OpenAPI và seed data đã cập nhật khi phù hợp.
- [ ] Không log secret hoặc dữ liệu nhạy cảm không cần thiết.
- [ ] Traceability và tài liệu liên quan đã cập nhật.
- [ ] CI xanh và có minh chứng demo/test.

## 18. Danh sách lỗi và vấn đề đang mở

> Thêm một dòng cho mỗi vấn đề. Khi đã xử lý, đổi `[ ]` thành `[x]` và ghi ngày đóng.

- [x] **ISSUE-001** — Không có vấn đề mở tại thời điểm đóng M0.
  **Mức độ:**  
  **Milestone liên quan:**  
  **Người xử lý:**  
  **Hạn xử lý:**  
  **Ghi chú/giải pháp:**

## 19. Nhật ký quyết định và thay đổi phạm vi

> Ghi các quyết định ảnh hưởng đến kế hoạch, contract, kiến trúc hoặc deadline.

- **2026-08-19 — PLAN-001:** Tạo kế hoạch triển khai MVP P0 trong 24 tuần.
- **2026-08-19 — PLAN-002:** Chuyển kế hoạch thành master checklist theo milestone để theo dõi tiến độ đồ án.
- **2026-08-19 — PLAN-003:** Xử lý 8 phát hiện M0-01; khóa calculation sex, health-v1, mandatory rules, benchmark, seed baseline và demo-data retention.
- **2026-08-19 — PLAN-004:** Frozen P0 gồm 62 feature, 47 UI, 19 AC và 7 E2E.
- **2026-08-19 — PLAN-005:** Chấp nhận ADR-001..ADR-007; pin runtime/build tool; tạo 20 story và xác nhận 49/49 ticket M1/M2 READY.

## 20. Nhật ký triển khai

> Cập nhật sau mỗi buổi hoặc ít nhất mỗi tuần. Không xóa lịch sử cũ.

### Mẫu ghi nhật ký

```text
Ngày: YYYY-MM-DD
Milestone: Mx
Đã hoàn thành: Mx-xx, Mx-yy
Đang thực hiện: Mx-zz
Vấn đề/BLOCKED:
Quyết định hoặc thay đổi:
Kế hoạch buổi tiếp theo:
Minh chứng: commit/PR/test/screenshot/link
```

### 2026-08-19

- **Milestone:** M0
- **Đã hoàn thành:** M0-01..M0-15; khóa scope, 7 ADR, runtime/build tool, P0 backlog, convention và DoR M1/M2.
- **Đang thực hiện:** Chưa bắt đầu M1; milestone kế tiếp là M1-01.
- **Vấn đề/BLOCKED:** Không có.
- **Kế hoạch tiếp theo:** Thực hiện M1-01 theo version baseline, sau đó M1-02..M1-22 theo dependency.
- **Minh chứng:** `docs/Project_Progress.md` và toàn bộ baseline/ADR trong `checkM0/` (`M0-01..03`, `ADR-001..007`, `M0-11_12`, `M0-13..15`).

## 21. Điều kiện bắt đầu P1

P1 chỉ được đưa vào kế hoạch khi tất cả điều kiện sau đã hoàn thành:

- [ ] M0 đến M8 đều hoàn thành.
- [ ] 19/19 Acceptance Criteria đạt.
- [ ] 7/7 E2E đạt.
- [ ] Không còn Blocker/Critical.
- [ ] Backup/restore và clean installation đã được rehearsal.
- [ ] Sản phẩm MVP đã được nghiệm thu cho đồ án tốt nghiệp.
