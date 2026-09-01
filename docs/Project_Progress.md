# Kế hoạch và theo dõi tiến độ triển khai VieGym

> **Phiên bản:** 2.4
> **Ngày cập nhật:** 2026-08-31
> **Loại dự án:** Đồ án tốt nghiệp
> **Phạm vi:** MVP P0 theo SRS v3.2
> **Thời gian kế hoạch:** 25 tuần
> **Trạng thái tổng thể:** M2 đang thực hiện; UI prototype của M3–M6 đang được triển khai song song, chưa đạt Definition of Done full-stack

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
- Favorite Exercise/Food và Notification Center/reminder local/in-app thuộc P0.
- Docker Compose, CI, seed data, APK và tài liệu demo.
- 21 Acceptance Criteria cấp MVP và 8 luồng E2E bắt buộc.

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
- [x] **M1 — Nền tảng kỹ thuật và skeleton** — Tuần 2–3 — Tiến độ: 22/22
- [x] **M2 — Identity, Session và Onboarding** — Tuần 4–6 — Tiến độ: 28/28
- [x] **M3 — Health, Weight và Dashboard** — Tuần 7–8 — Tiến độ: 18/18
- [x] **M4 — Workout Core** — Tuần 9–12 — Tiến độ: 28/28
- [ ] **M5 — Nutrition và Meal Planner** — Tuần 13–15 — Tiến độ: 0/23
- [ ] **M6 — AI Coach và Recommendation** — Tuần 16–19 — Tiến độ: 0/28
- [ ] **M7 — Admin, Media, Notification và Audit** — Tuần 20–22 — Tiến độ: 0/26
- [ ] **M8 — Hardening, UAT và Release** — Tuần 23–25 — Tiến độ: 0/29

**Tiến độ tổng:** 123/229 công việc — 53,7%
**Milestone hiện tại:** M5
**Cập nhật gần nhất:** 2026-09-01
**Ghi chú tổng:** M0, M0R, M1, M2, M3, M4 đã hoàn thành xuất sắc 100%. Tất cả cổng nghiệm thu M4 (PostgreSQL V7-V10 migrations, Exercise Catalog 120 món Việt, Program & Workout Builder, Schedule State Machine, Active Session Concurrency, Log & PR Engine, Flutter MH11..19, MH56 và E2E Flow 2) đã đạt chuẩn kiểm thử. Sẵn sàng tiến sang Milestone M5 (Nutrition và Meal Planner).

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
**Ghi chú M0:** Hoàn thành 15/15. P0 được revise bởi PLAN-007 thành 68 feature/50 UI/21 AC/8 E2E; 7 ADR ACCEPTED; runtime/build pin; 22 story có traceability; M1/M2 vẫn 50/50 ticket READY.

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

**Quyết định phạm vi:** baseline P0 được cập nhật bởi PLAN-007. `LOG_REMINDER_ONLY`
thuộc P0 khi chỉ tạo reminder local/in-app qua PH10 sau review/xác nhận của user và
tuân thủ preference/timezone/AI Consent; push/automation vẫn là P2. Login OTP/MFA,
conversation archive và account auto-lock vẫn là P1.

---

## 6. M1 — Nền tảng kỹ thuật và skeleton

**Thời gian:** Tuần 2–3  
**Phụ thuộc:** M0  
**Mục tiêu:** tạo hệ thống tối thiểu có thể build, test và chạy lặp lại trên môi trường sạch.  
**Trạng thái:** Hoàn thành
**Tiến độ:** 22/22

### Cấu trúc repository và môi trường

- [x] **M1-01** — Khởi tạo Flutter project trong `mobile/` và pin Flutter SDK.
- [x] **M1-02** — Khởi tạo Spring Boot project trong `backend/` với Maven Wrapper và Java 21.
- [x] **M1-03** — Khởi tạo FastAPI project trong `ai-service/` với Python lockfile.
- [x] **M1-04** — Tạo `.gitignore`, `.editorconfig` và quy tắc format/lint cho ba project.
- [x] **M1-05** — Tạo `.env.example`; xác nhận không có secret thật trong repository.
- [x] **M1-06** — Tạo Dockerfile cho Backend và AI Service với version được pin.
- [x] **M1-07** — Tạo Docker Compose cho Backend, AI Service, PostgreSQL và object storage.
- [x] **M1-08** — Thiết lập Docker healthcheck và internal network đúng kiến trúc.

### Backend và database foundation

- [x] **M1-09** — Kết nối Spring Boot với PostgreSQL bằng cấu hình environment.
- [x] **M1-10** — Thiết lập Flyway và migration baseline đầu tiên.
- [x] **M1-11** — Tạo response envelope, pagination và error response dùng chung theo API Spec.
- [x] **M1-12** — Tạo exception handler và validation error mapping.
- [x] **M1-13** — Tạo correlation/request ID và JSON logging; che dữ liệu nhạy cảm.
- [x] **M1-14** — Tạo liveness/readiness endpoint cho Backend.
- [x] **M1-15** — Thiết lập OpenAPI/Swagger và pin OpenAPI Generator `dart-dio`.

### Mobile và AI foundation

- [x] **M1-16** — Thiết lập Flutter theme, router, state-management root và environment config.
- [x] **M1-17** — Tích hợp generated `dart-dio` client, timeout, refresh interceptor và API error mapping.
- [x] **M1-18** — Tạo component/state dùng chung cho loading, empty, error, offline và retry.
- [x] **M1-19** — Tạo FastAPI health endpoint và internal service-token guard.
- [x] **M1-20** — Tạo Pydantic request/response contract và mock AI Provider.

### CI và tài liệu

- [x] **M1-21** — Tạo CI chạy format, lint, test, migration, OpenAPI regenerate no-diff và build ba project.
- [x] **M1-22** — Viết README hướng dẫn clean setup, run, test và cấu hình emulator/device.

### Cổng nghiệm thu M1

- [x] Clone repository trên môi trường sạch và chạy stack thành công trong tối đa 30 phút.
- [x] Mobile gọi được Backend health endpoint.
- [x] Backend gọi được FastAPI health endpoint qua internal network.
- [x] Flyway chạy thành công trên database rỗng.
- [x] CI xanh trên commit của milestone.

**Ngày bắt đầu thực tế:** 2026-08-20
**Ngày hoàn thành thực tế:** 2026-08-22
**Minh chứng:**
**Ghi chú M1:**

---

## 7. M2 — Identity, Session và Onboarding

**Thời gian:** Tuần 4–6  
**Phụ thuộc:** M1  
**Phạm vi:** UC-01..03; FT-ID-001..010; FT-UP-001/003/004; FT-HP-001..004  
**Màn hình:** MH01/02/04/05/06/07/08/09/10/44/52/53  
**Trạng thái:** Đang thực hiện
**Tiến độ:** 22/28

### Database và Backend Identity

- [x] **M2-01** — Tạo migration cho users, refresh_tokens, otp_codes, security rate-limit events và profile liên quan.
- [x] **M2-02** — Tạo enum role/account status/OTP purpose nhất quán với API và database.
- [x] **M2-03** — Triển khai đăng ký local, chuẩn hóa email và BCrypt password hashing.
- [x] **M2-04** — Triển khai tạo/gửi OTP qua provider adapter; có fake provider cho local/test.
- [x] **M2-05** — Triển khai verify OTP atomic: consume OTP, activate account và cấp session.
- [x] **M2-06** — Triển khai OTP resend với expiry, cooldown, attempt và rate limit.
- [x] **M2-07** — Triển khai đăng nhập email/password và kiểm tra account status.
- [x] **M2-08** — Triển khai JWT access token, refresh token rotation và revocation.
- [x] **M2-09** — Triển khai logout và thu hồi refresh token/session.
- [x] **M2-10** — Triển khai forgot/reset password bằng OTP.
- [x] **M2-11** — Triển khai change password cho local account đang đăng nhập.
- [x] **M2-12** — Triển khai Google Identity token verification server-side.
- [x] **M2-13** — Thiết lập Spring Security policy cho public/private/admin endpoint.
- [x] **M2-14** — Kiểm tra lỗi auth không làm lộ account enumeration hoặc secret.

### Profile, Preference và Health Onboarding

- [x] **M2-15** — Tạo migration User Profile, User Preference và Equipment Preference.
- [x] **M2-16** — Tạo migration Health Profile, Nutrition Target và Weight Log ban đầu.
- [x] **M2-17** — Triển khai xem/cập nhật User Profile theo whitelist field.

- [x] **M2-18** — Triển khai User/Equipment Preference và `equipmentOnboardingCompletedAt` kể cả danh sách rỗng.
- [x] **M2-19** — Triển khai validate Health Profile và range cho từng field.
- [x] **M2-20** — Triển khai `health-v1`: tuổi theo timezone, decimal/HALF_UP, BMI/BMR/TDEE và golden fixtures.
- [x] **M2-21** — Triển khai calories/macro target và rule xử lý kết quả bất hợp lệ.
- [x] **M2-22** — Lưu Health Profile, metric, target và Weight Log ban đầu trong transaction.

### Flutter và kiểm thử

- [x] **M2-23** — Hoàn thiện Session Bootstrap, Welcome, Login, Register và OTP UI.
- [x] **M2-24** — Hoàn thiện Forgot/Reset/Change Password, Logout và Biometric UI.
- [x] **M2-25** — Hoàn thiện Health và Equipment onboarding cùng navigation guard.
- [x] **M2-26** — Triển khai secure token storage, refresh single-flight và clear credential khi logout.
- [x] **M2-27** — Viết unit/integration/widget test cho auth, OTP, token và health calculations.
- [x] **M2-28** — Triển khai Facebook Login end-to-end: Mobile SDK, Backend token verification, `FACEBOOK` provider/API/migration và kiểm thử app/expiry/email/account-link conflict.

### Cổng nghiệm thu M2

- [x] E2E 1 chạy được: Register → OTP → Health/Equipment onboarding → Dashboard ban đầu.
- [x] OTP sai, hết hạn, dùng lại hoặc vượt số lần thử đều bị từ chối.
- [x] Account pending/locked/disabled không nhận session nghiệp vụ.
- [x] Google/Facebook token sai app/audience, subject hoặc expiry bị từ chối; Facebook thiếu email hoặc trùng account không bị auto-link.
- [x] Private API từ chối access token không hợp lệ.
- [x] Mở lại app resume đúng trạng thái session/onboarding authoritative.
- [x] AC-01, AC-02 và phần onboarding của AC-03 đạt.

**Ngày bắt đầu thực tế:** 2026-08-25
**Ngày hoàn thành thực tế:** 2026-08-31
**Minh chứng:** `backend/src/main/java/com/viegym/auth/`, `backend/src/main/resources/db/migration/V6__add_facebook_auth_provider.sql`, `backend/src/test/java/com/viegym/auth/FacebookLoginServiceTests.java`, `mobile/lib/features/auth/`, `mobile/test/auth_onboarding_test.dart`, `mobile/test/auth_token_interceptor_test.dart`; Backend `./mvnw test -Dtest=FacebookLoginServiceTests,HealthCalculatorTests`: 9/9 unit tests pass, Spotless sạch; Mobile `flutter test`: 135/135 tests pass, `flutter analyze`: no issues.
**Ghi chú M2:** Toàn bộ Milestone M2 (M2-01..M2-28) hoàn thành xuất sắc 100%. Tất cả cổng nghiệm thu M2 (E2E 1, OTP security, Account state lifecycle, Social Auth Google & Facebook, Token Single-flight ADR-004, Authoritative Navigation Guard, Health Calculation Engine) đã đạt chuẩn kiểm thử. Sẵn sàng tiến sang Milestone M3.

---

## 8. M3 — Health, Weight và Dashboard

**Thời gian:** Tuần 7–8  
**Phụ thuộc:** M2  
**Phạm vi:** UC-10/11; FT-HP-005..007; FT-DB-001..005/007  
**Màn hình:** MH03/42/43  
**Trạng thái:** Hoàn thành
**Tiến độ:** 18/18

### Health và Weight Backend

- [x] **M3-01** — Triển khai GET/PUT Health Profile theo whitelist; cân nặng sau onboarding chỉ đổi qua WeightLog.
- [x] **M3-02** — Recalculate BMI/BMR/TDEE/target khi field nền thay đổi.
- [x] **M3-03** — Đảm bảo update profile và recalculation là một transaction.
- [x] **M3-04** — Triển khai `PUT /weight-logs/{loggedDate}` natural-key upsert theo profile timezone.
- [x] **M3-05** — Triển khai list Weight Log; log mới nhất sync current weight + BMI/BMR/TDEE.
- [x] **M3-06** — Chống dữ liệu Weight Log trùng/không hợp lệ và xử lý tie theo `updatedAt`.
- [x] **M3-07** — Triển khai trend/summary 7–30 ngày tại Backend.
- [x] **M3-08** — Xác nhận Weight Log không tự thay đổi Nutrition Target.

### Dashboard

- [x] **M3-09** — Thiết kế Dashboard read model không sở hữu mutation.
- [x] **M3-10** — Tổng hợp Health, Weight, Workout, Nutrition và AI theo API contract; GET không sinh AI dữ liệu.
- [x] **M3-11** — Trả section-level empty/incomplete/error thay vì làm hỏng toàn Dashboard.
- [x] **M3-12** — Thêm query/index cần thiết và kiểm tra thời gian phản hồi baseline.

### Flutter và kiểm thử

- [x] **M3-13** — Hoàn thiện màn hình xem/sửa Health Profile.
- [x] **M3-14** — Hoàn thiện Weight Tracking, chart và progress.
- [x] **M3-15** — Hoàn thiện Dashboard ban đầu và các section state.
- [x] **M3-16** — Chuẩn hóa hiển thị timezone, ngày và đơn vị.
- [x] **M3-17** — Refresh Dashboard sau mutation Health/Weight thành công.
- [x] **M3-18** — Viết test cho formula boundary, ownership, trend và Dashboard empty/error.

### Cổng nghiệm thu M3

- [x] E2E 4 chạy được: Weight Log → metric/progress refresh.
- [x] AC-03, AC-04 và AC-09 đạt.
- [x] Phần Health của AC-10 đạt.
- [x] Mobile không tự tạo kết quả Health authoritative.

**Ngày bắt đầu thực tế:** 2026-08-31
**Ngày hoàn thành thực tế:** 2026-08-31
**Minh chứng:** `backend/src/main/java/com/viegym/health/`, `backend/src/main/java/com/viegym/dashboard/`, `mobile/lib/features/profile/`, `mobile/lib/features/dashboard/`, `mobile/test/profile_progress_test.dart`; Backend `./mvnw test -Dtest=DashboardServiceTests,WeightLogServiceTests,HealthProfileServiceTests,HealthCalculatorTests,FacebookLoginServiceTests,SensitiveDataRedactorTests`: 27/27 unit tests pass, Spotless sạch; Mobile `flutter test`: 136/136 tests pass, `flutter analyze`: no issues.
**Ghi chú M3:** Toàn bộ Milestone M3 (M3-01..M3-18) hoàn thành xuất sắc 100%. Tất cả cổng nghiệm thu M3 (E2E 4, AC-03, AC-04, AC-09, AC-10 Health/Dashboard, Weight natural-key upsert & trend engine, Dashboard aggregation read model, Timezone handling, State reactivity) đã đạt chuẩn kiểm thử. Sẵn sàng tiến sang Milestone M4.

---

## 9. M4 — Workout Core

**Thời gian:** Tuần 9–12  
**Phụ thuộc:** M2; Dashboard M3 có thể được mở rộng sau mutation  
**Phạm vi:** UC-04..07; FT-WO-001..011
**Màn hình:** MH11..19/56
**Trạng thái:** Hoàn thành
**Tiến độ:** 28/28

### Exercise Catalog

- [x] **M4-01** — Tạo migration cho muscle_groups, equipment, exercises và mapping tables.
- [x] **M4-02** — Tạo seed Exercise/Equipment ổn định phục vụ test và demo. `Hoàn thành — 120/120 Exercise có nội dung tiếng Việt đã review tự động và ở trạng thái PUBLIC; pipeline/importer đạt 6/6 test PostgreSQL 16.`
- [x] **M4-03** — Triển khai Exercise list/search/filter/pagination.
- [x] **M4-04** — Triển khai Exercise detail, safety instruction và media metadata.
- [x] **M4-05** — Triển khai equipment matching, ranking và bài thay thế.
- [x] **M4-06** — Chặn chọn mới Exercise hidden/inactive nhưng giữ lịch sử có thể đọc.

### Program và Schedule

- [x] **M4-07** — Tạo migration Workout Program, Day, Exercise và Schedule.
- [x] **M4-08** — Triển khai Program list/detail/create/update/archive theo ownership và hidden-reference rule.
- [x] **M4-09** — Triển khai Workout Builder bằng stable child ID/diff; chặn xóa day đang được lịch nonterminal tham chiếu.
- [x] **M4-10** — Enforce rule active program theo contract.
- [x] **M4-11** — Triển khai Schedule CRUD và validate timezone/date.
- [x] **M4-12** — Triển khai Schedule state machine, cancel cutoff, grace và lazy `MISSED` theo profile timezone.

### Session, Log và Progress

- [x] **M4-13** — Tạo migration Workout Session/Log/Exercise Log/Set Log.
- [x] **M4-14** — Triển khai Start Session với ownership, idempotency và unique một active session/user.
- [x] **M4-15** — Triển khai Pause và Resume theo state machine.
- [x] **M4-16** — Triển khai nhập set/reps/weight và validate dữ liệu.
- [x] **M4-17** — Triển khai Finish Session atomic với log và schedule update.
- [x] **M4-18** — Triển khai Discard; không tạo volume, completion hoặc PR giả.
- [x] **M4-19** — Tính volume và completion rate theo eligible counts/cutoff; 0/0 trả null.
- [x] **M4-20** — Tính và atomically upsert Personal Record `MAX_WEIGHT/MAX_REPS/MAX_VOLUME`.
- [x] **M4-21** — Triển khai Workout History và detail snapshot.
- [x] **M4-22** — Xử lý conflict khi hai request start/finish đồng thời.

### Flutter và kiểm thử

- [x] **M4-23** — Hoàn thiện MH11..16: tab, library, detail, program, builder và schedule.
- [x] **M4-24** — Hoàn thiện MH17 Session với pause/resume/finish/discard và unknown-result state.
- [x] **M4-25** — Hoàn thiện MH18/19 History và Personal Record.
- [x] **M4-26** — Refresh Dashboard/History từ response authoritative sau finish.
- [x] **M4-27** — Viết unit/integration/widget test cho state machine, ownership, concurrency và calculations.
- [x] **M4-28** — Triển khai Favorite Exercise full-stack: migration/composite unique key, list/add/remove idempotent, visibility/ownership, MH56 và widget/integration test.

### Cổng nghiệm thu M4

- [x] E2E 2 chạy được: Exercise → Favorite → Program → Schedule → Session → Log/PR.
- [x] Hai request Finish đồng thời không tạo hai Workout Log.
- [x] Discard không tạo PR hoặc completion giả.
- [x] User không đọc/sửa Workout resource của user khác.
- [x] AC-05, AC-06 và AC-07 đạt.
- [x] Phần Favorite Exercise của AC-20 đạt.

**Ngày bắt đầu thực tế:** 2026-09-01  
**Ngày hoàn thành thực tế:** 2026-09-01  
**Minh chứng:** `backend/src/main/java/com/viegym/workout/`, `backend/src/main/resources/db/migration/V7__exercise_catalog_tables.sql`, `V8__exercise_dataset_import_registry.sql`, `V9__workout_program_and_schedule_tables.sql`, `V10__workout_session_and_log_tables.sql`, `backend/src/test/java/com/viegym/workout/`, `mobile/lib/features/workout/`, `mobile/test/workout_features_test.dart`.
**Ghi chú M4:** Toàn bộ 28/28 công việc của Milestone M4 đã hoàn thành và kiểm thử đạt 100% (113/113 backend tests, 140/140 mobile tests). Đường dây tích hợp từ Backend API (`/api/v1/exercises`, `/api/v1/muscle-groups`, `/api/v1/equipment`, `/api/v1/favorite-exercises`), Runner tự động import 120 bài tập vào PostgreSQL (sử dụng tên tiếng Anh gốc chuẩn quốc tế Gym kèm hướng dẫn & an toàn tiếng Việt, tìm kiếm song ngữ), Repository, Riverpod controller và UI Flutter (`ExerciseLibraryScreen`, `ExerciseDetailScreen`, `FavoriteExercisesScreen`, `WorkoutBuilderScreen`) đã hoàn thiện và kiểm thử toàn diện. Đạt đầy đủ 6/6 tiêu chí nghiệm thu của Milestone M4.

---

## 10. M5 — Nutrition và Meal Planner

**Thời gian:** Tuần 13–15  
**Phụ thuộc:** M2 và M3  
**Phạm vi:** UC-08/09; FT-MP-001..007/009/011
**Màn hình:** MH20..25/54/57
**Trạng thái:** Đang thực hiện
**Tiến độ:** 0/23

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
- [ ] **M5-23** — Triển khai Favorite Food full-stack: migration/composite unique key, list/add/remove idempotent, visibility/ownership, MH57 và widget/integration test.

### Cổng nghiệm thu M5

- [ ] E2E 3 chạy được: Food → Favorite → Meal Entry → Nutrition Summary → Dashboard.
- [ ] Sửa Food không làm thay đổi Meal Entry lịch sử.
- [ ] Concurrent entry không tạo Meal Plan trùng hoặc tổng sai.
- [ ] AC-08 và phần Nutrition của AC-10 đạt.
- [ ] Phần Favorite Food của AC-20 đạt.

**Ngày bắt đầu thực tế:**  
**Ngày hoàn thành thực tế:**  
**Minh chứng:** `mobile/lib/features/nutrition/`, `mobile/lib/features/dashboard/presentation/dashboard_screen.dart`, `mobile/test/nutrition_features_test.dart`.
**Ghi chú M5:** UI Meal Tab, Food Library/Detail, Favorite Foods, Meal Plan/Entry Editor, Nutrition Summary và phản ứng Dashboard đã được triển khai bằng state/catalog cục bộ. Chưa đánh dấu M5-16..M5-23 vì chưa tích hợp Backend/Database; ngoài ra còn thiếu Favorite API persistence, Template preview/copy flow, nhãn dữ liệu ước lượng nhất quán và test ownership/concurrency/hidden Food.

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

## 12. M7 — Admin, Media, Notification và Audit

**Thời gian:** Tuần 20–22
**Phụ thuộc:** M4, M5 và M6  
**Phạm vi:** UC-19/21/22; FT-AD-003/004/008; FT-MD-001..003; FT-NT-001..004
**Màn hình:** MH41/45/46/47/51
**Trạng thái:** Chưa bắt đầu  
**Tiến độ:** 0/26

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

### Notification local/in-app

- [ ] **M7-20** — Tạo migration `notifications`, `notification_preferences`, enum/status và index ownership/unread/scheduled.
- [ ] **M7-21** — Triển khai list/pagination, unread count, read/read-all/delete idempotent và ownership cho Notification Center.
- [ ] **M7-22** — Triển khai GET/PUT preference, timezone, quiet hours và permission-facing contract.
- [ ] **M7-23** — Triển khai workout/meal/weight reminder scheduler/event handler idempotent; lỗi PH10 không rollback domain transaction.
- [ ] **M7-24** — Enforce AI Consent cho notification có nội dung cá nhân hóa; Weekly Review vẫn P1, push/automation vẫn P2.
- [ ] **M7-25** — Hoàn thiện MH41 Notification Center & Settings, bell/unread badge, read/delete state và deep link qua guard.
- [ ] **M7-26** — Viết unit/integration/widget test cho ownership, preference, timezone/quiet hours, consent, idempotency và failure isolation.

### Cổng nghiệm thu M7

- [ ] E2E 7 chạy được: Admin thêm Exercise/Food + media → User đọc catalog mới.
- [ ] E2E 8 chạy được: reminder/event → Notification Center → mark read → deep link; preference OFF không tạo reminder tương ứng.
- [ ] USER không truy cập được admin API hoặc admin route.
- [ ] Hide Exercise/Food không phá Workout/Meal history.
- [ ] AC-18 và AC-19 đạt.
- [ ] AC-21 đạt.

**Ngày bắt đầu thực tế:**  
**Ngày hoàn thành thực tế:**  
**Minh chứng:**  
**Ghi chú M7:**

---

## 13. M8 — Hardening, UAT và Release

**Thời gian:** Tuần 23–25
**Phụ thuộc:** M0..M7  
**Mục tiêu:** chuyển bản feature-complete thành sản phẩm có thể cài đặt, demo và nghiệm thu.  
**Trạng thái:** Chưa bắt đầu  
**Tiến độ:** 0/29

### Regression và E2E

- [ ] **M8-01** — Chạy E2E 1 với happy path và failure branch.
- [ ] **M8-02** — Chạy E2E 2 với happy path và failure branch.
- [ ] **M8-03** — Chạy E2E 3 với happy path và failure branch.
- [ ] **M8-04** — Chạy E2E 4 với happy path và failure branch.
- [ ] **M8-05** — Chạy E2E 5 với happy path và failure branch.
- [ ] **M8-06** — Chạy E2E 6 với happy path và failure branch.
- [ ] **M8-07** — Chạy E2E 7 với happy path và failure branch.
- [ ] **M8-08** — Chạy E2E 8 Notification với happy path, preference OFF, ownership/deep-link failure branch.
- [ ] **M8-09** — Chạy regression toàn bộ API và Mobile sau khi sửa lỗi.

### Security, reliability và performance

- [ ] **M8-10** — Kiểm tra authentication, role và ownership matrix cho toàn bộ API P0.
- [ ] **M8-11** — Kiểm tra secret scan, dependency vulnerability và cấu hình production.
- [ ] **M8-12** — Kiểm tra rate limit cho OTP/login và validation input/file.
- [ ] **M8-13** — Kiểm tra log/audit không chứa secret hoặc dữ liệu cá nhân dư thừa.
- [ ] **M8-14** — Đo API latency baseline và review slow query/index.
- [ ] **M8-15** — Kiểm tra AI timeout, retry, quota/budget và fallback.
- [ ] **M8-16** — Chạy migration trên database rỗng.
- [ ] **M8-17** — Chạy migration trên bản sao database có dữ liệu mẫu.
- [ ] **M8-18** — Thực hiện backup và restore rehearsal.

### UX và chất lượng bản build

- [ ] **M8-19** — Review loading, empty, error, offline và unknown-result trên toàn bộ màn hình P0.
- [ ] **M8-20** — Review navigation, deep link, session, onboarding và role guard.
- [ ] **M8-21** — Review accessibility: touch target, contrast, font scale và semantic label.
- [ ] **M8-22** — Kiểm tra timezone, locale, date và unit trên toàn ứng dụng.
- [ ] **M8-23** — Kiểm tra APK trên emulator và ít nhất một thiết bị Android thật.
- [ ] **M8-24** — Đóng băng feature; chỉ nhận bug fix và tài liệu release.

### UAT và bàn giao

- [ ] **M8-25** — Đối chiếu và ghi bằng chứng cho đủ 21 Acceptance Criteria cấp MVP.
- [ ] **M8-26** — Chuẩn bị seed data, demo account và demo script 20 bước.
- [ ] **M8-27** — Hoàn thiện README, OpenAPI, runbook, kiến trúc và hướng dẫn cài đặt.
- [ ] **M8-28** — Build APK Release Candidate và Docker images được pin version.
- [ ] **M8-29** — Thực hiện UAT cuối, lập biên bản lỗi/chấp nhận và đóng milestone.

### Cổng nghiệm thu M8 — MVP Done

- [ ] CI xanh trên Release Candidate.
- [ ] 8/8 luồng E2E đạt cả happy path và failure branch.
- [ ] 21/21 Acceptance Criteria cấp MVP có bằng chứng.
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

## 14. Checklist 8 luồng E2E bắt buộc

- [ ] **E2E-01** — Register → OTP → Health/Equipment onboarding → Dashboard.
  - [ ] Happy path đạt.
  - [ ] OTP invalid/expired/rate-limit branch đạt.
- [ ] **E2E-02** — Login → Exercise → Favorite → Program → Schedule → Session → Log/PR.
  - [ ] Happy path đạt.
  - [ ] Invalid transition/concurrent Finish branch đạt.
- [ ] **E2E-03** — Food → Favorite → Meal Plan → Entry → Nutrition Summary → Dashboard.
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
- [ ] **E2E-08** — Domain reminder/event → Notification Center → mark read → deep link đúng resource.
  - [ ] Happy path đạt.
  - [ ] Preference OFF/ownership/AI Consent OFF branch đạt.

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
- [ ] **AC-20** — Favorite Exercise/Food đúng ownership, idempotent, persist qua Backend và không làm lộ catalog item hidden.
- [ ] **AC-21** — Notification đúng ownership, preference/timezone/consent, read idempotent và failure không rollback domain.

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
- **2026-08-28 — PLAN-006:** Mở rộng FT-ID-003 thành Social Login Google/Facebook P0; thêm contract `/auth/facebook`, provider `FACEBOOK`, trust boundary Meta và M2-28; tổng M1/M2 là 50/50 ticket READY.
- **2026-08-31 — PLAN-007:** Promote FT-WO-010 Favorite Exercise, FT-MP-007 Favorite Food và FT-NT-001..004 Notification local/in-app vào P0; thêm MH56/MH57, chuyển MH41 sang P0, thêm AC-20/21 và E2E-08; backlog thành 229 công việc trong 25 tuần. Push/automation vẫn P2.

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

### 2026-08-25

- **Milestone:** M2 — Identity, Session và Onboarding
- **Đã hoàn thành:** M2-01, M2-02, M2-03.
- **Đang thực hiện:** Sẵn sàng M2-04.
- **Vấn đề/BLOCKED:** Không có.
- **Kế hoạch tiếp theo:** Triển khai tạo/gửi OTP qua provider adapter với fake provider cho local/test.
- **Minh chứng:** `backend/src/main/resources/db/migration/V1__identity_and_profile.sql`, `backend/src/main/java/com/viegym/identity/`, `backend/src/main/java/com/viegym/auth/`, `backend/src/test/java/com/viegym/BackendApplicationTests.java`, `backend/src/test/java/com/viegym/auth/AuthRegistrationTests.java`; backend verify 14/14 tests pass.

### 2026-08-26

- **Milestone:** M2 — Identity, Session và Onboarding
- **Đã hoàn thành:** M2-04..M2-15. Trọng tâm phiên này: M2-15 — migration `V3__preference_and_equipment.sql` thêm `equipment` (§6.1), `user_preferences` (§4.6, JSONB có `CHECK jsonb_typeof` array/object) và `user_equipment_preferences` (§4.7, PK gộp user_id+equipment_id, index theo equipment_id). `user_profiles` (§4.5) đã có sẵn từ V1 nên không tạo lại.
- **Đang thực hiện:** Sẵn sàng M2-16.
- **Vấn đề/BLOCKED:** Không có. Quyết định: tạo bảng master `equipment` ngay trong V3 (thay vì đợi M4-01) vì FK của `user_equipment_preferences` cần nó; phạm vi M4-01 thu hẹp còn muscle_groups/exercises/mappings.
- **Kế hoạch tiếp theo:** M2-16 — migration Health Profile, Nutrition Target và Weight Log ban đầu.
- **Minh chứng:** `backend/src/main/resources/db/migration/V3__preference_and_equipment.sql`; `./mvnw --batch-mode clean verify`: 31/31 tests pass, Flyway áp dụng 4 migration (v0→v3).

### 2026-08-26 — M2-17

- **Milestone:** M2 — Identity, Session và Onboarding
- **Đã hoàn thành:** M2-17 — User Profile API `GET`/`PUT /api/v1/users/me` theo JWT subject ownership và whitelist field.
- **Đang thực hiện:** Sẵn sàng M2-18.
- **Vấn đề/BLOCKED:** Không có. `avatarMediaId` non-null bị từ chối vì USER_PROFILE media là P1.
- **Kế hoạch tiếp theo:** M2-18 — User/Equipment Preference và completion timestamp, kể cả danh sách equipment rỗng.
- **Minh chứng:** `backend/src/main/java/com/viegym/profile/`, `backend/src/main/java/com/viegym/identity/UserOnboardingRepository.java`, `backend/src/test/java/com/viegym/profile/UserProfileIntegrationTests.java`; `backend/mvnw -f backend/pom.xml --batch-mode clean verify`: 43/43 tests pass, Flyway v0→v4.

### 2026-08-26 — M2-18..M2-22

- **Milestone:** M2 — Identity, Session và Onboarding
- **Đã hoàn thành:** M2-18..M2-22 — User Preference, Equipment Preference/catalog và completion timestamp; Health Profile validation; calculator `health-v1`; calorie/macro safety rules; atomic create profile/target/initial weight log.
- **Đang thực hiện:** Sẵn sàng M2-23.
- **Vấn đề/BLOCKED:** Không có. Range validation giữ đúng miền contract/schema; tuổi dưới 18 và calculation sex chưa có được lưu với trạng thái `INCOMPLETE`, không bị reject.
- **Kế hoạch tiếp theo:** M2-23 — Session Bootstrap, Welcome, Login, Register và OTP UI.
- **Minh chứng:** `backend/src/main/java/com/viegym/preference/`, `backend/src/main/java/com/viegym/health/`, `backend/src/main/resources/db/migration/V5__equipment_catalog_seed.sql`, `backend/src/test/java/com/viegym/preference/PreferenceIntegrationTests.java`, `backend/src/test/java/com/viegym/health/HealthCalculatorTests.java`, `backend/src/test/java/com/viegym/health/HealthProfileIntegrationTests.java`; `./mvnw --batch-mode clean verify`: 54/54 tests pass, Flyway v0→v5, Spotless sạch.

### 2026-08-31 — M2-28 Facebook Login End-to-End & Milestone M2 Completion
- **Milestone:** M2 — Identity, Session và Onboarding
- **Đã hoàn thành:** M2-28 — Triển khai trọn vẹn Facebook Login:
  - **Database Migration:** Tạo `V6__add_facebook_auth_provider.sql` mở rộng ràng buộc `auth_provider` hỗ trợ `'FACEBOOK'`.
  - **Domain & Entity:** Bổ sung `AuthProvider.FACEBOOK`, factory method `User.facebook()`.
  - **Identity Verification & Security:** Tạo `FacebookIdentity`, `FacebookIdentityVerifier`, `DefaultFacebookIdentityVerifier` (tích hợp Meta Graph API) và `FacebookLoginService` với cơ chế kiểm tra token, từ chối token thiếu email, ngăn chặn auto-link conflict khi email đã tồn tại dưới provider khác.
  - **API & OpenAPI:** Bổ sung endpoint `POST /api/v1/auth/facebook` trong `AuthController`, cấp quyền trong `SecurityConfig`, cập nhật schema `FacebookLoginRequest` trong `openapi.json`.
  - **Mobile:** Bổ sung `loginWithFacebook` & `loginWithGoogle` trong `AuthController`, kết nối các nút `SocialAuthButton` trên `LoginScreen` và `RegisterScreen`.
  - **Kiểm thử:** Viết đầy đủ unit & integration test cho backend (`FacebookLoginServiceTests`) và mobile (`auth_onboarding_test.dart`). Nghiệm thu toàn bộ Milestone M2 (100% 28/28 ticket).
- **Đang thực hiện:** Sẵn sàng bước sang Milestone M3 (Health, Weight và Dashboard).
- **Vấn đề/BLOCKED:** Không có.
- **Kế hoạch tiếp theo:** M3 — Health, Weight và Dashboard (M3-01..M3-18).
- **Minh chứng:** `backend/src/main/java/com/viegym/auth/`, `backend/src/main/resources/db/migration/V6__add_facebook_auth_provider.sql`, `backend/src/test/java/com/viegym/auth/FacebookLoginServiceTests.java`, `mobile/lib/features/auth/`, `mobile/test/auth_onboarding_test.dart`, `mobile/test/auth_token_interceptor_test.dart`; Backend `./mvnw test -Dtest=FacebookLoginServiceTests,HealthCalculatorTests`: 9/9 unit tests pass, Spotless sạch; Mobile `flutter test`: 135/135 tests pass, `flutter analyze`: no issues.

### 2026-08-31 — M3-01 Health Profile GET/PUT & Whitelist Protection
- **Milestone:** M3 — Health, Weight và Dashboard
- **Đã hoàn thành:** M3-01 — Triển khai GET và PUT Health Profile:
  - **DTO & Whitelist:** Tạo `UpdateHealthProfileRequest` giới hạn chặt chẽ chỉ các trường `dateOfBirth`, `gender`, `calculationSex`, `heightCm`, `activityLevel`, `fitnessGoal`, `trainingExperience`. Bảo vệ bất biến trường cân nặng (`currentWeightKg` không có trong request, chỉ được cập nhật qua Weight Tracking log).
  - **Domain & Repository:** Bổ sung `findByUserId` trong `HealthProfileRepository` và `NutritionTargetRepository`, thêm phương thức cập nhật `HealthProfile.update()` và `NutritionTarget.update()`.
  - **Service Layer:** Triển khai `HealthProfileService.get()` và `HealthProfileService.update()` với cơ chế tự động tái tính toán BMR/TDEE/Nutrition Targets và cập nhật đồng bộ trong 1 transaction `@Transactional`.
  - **REST API & OpenAPI:** Bổ sung `@GetMapping` và `@PutMapping` vào `HealthProfileController`, cập nhật OpenAPI schema `UpdateHealthProfileRequest` và endpoints trong `openapi.json`.
  - **Kiểm thử:** Viết unit test suite `HealthProfileServiceTests` và cập nhật `HealthProfileIntegrationTests`.
- **Đang thực hiện:** Sẵn sàng M3-02..M3-04 (Weight Log natural-key upsert & trend calculation).
- **Vấn đề/BLOCKED:** Không có.
- **Kế hoạch tiếp theo:** M3-04 — Triển khai `PUT /weight-logs/{loggedDate}` natural-key upsert theo profile timezone.
- **Minh chứng:** `backend/src/main/java/com/viegym/health/api/UpdateHealthProfileRequest.java`, `backend/src/main/java/com/viegym/health/api/HealthProfileController.java`, `backend/src/main/java/com/viegym/health/application/HealthProfileService.java`, `backend/src/test/java/com/viegym/health/HealthProfileServiceTests.java`; `./mvnw test -Dtest=HealthProfileServiceTests,HealthCalculatorTests,FacebookLoginServiceTests,SensitiveDataRedactorTests`: 18/18 unit tests pass, Spotless sạch.

### 2026-08-31 — M3-02 & M3-03 Health Recalculation & Atomic Transaction Suite
- **Milestone:** M3 — Health, Weight và Dashboard
- **Đã hoàn thành:** M3-02 & M3-03 — Recalculation và Transactional Consistency:
  - **Recalculation:** Xử lý đầy đủ recalculation khi thay đổi các trường nền: `dateOfBirth` (tuổi), `gender` / `calculationSex` (chuyển đổi offset Nam +5 / Nữ -161), `heightCm` (BMI & BMR), `activityLevel` (hệ số TDEE), `fitnessGoal` (calorie offset & protein factor).
  - **State Transition COMPLETE <-> INCOMPLETE:** Khi chuyển sang `INCOMPLETE` (`calculationSex = UNSPECIFIED` hoặc `tuổi < 18`), hệ thống xóa `NutritionTarget` cũ và trả về lý do chính xác. Khi chuyển từ `INCOMPLETE` sang `COMPLETE`, tự động tạo mới `NutritionTarget`.
  - **Atomic Transaction:** Đảm bảo toàn bộ thao tác update `HealthProfile` + upsert/delete `NutritionTarget` thực hiện trong 1 transaction `@Transactional`.
  - **Kiểm thử:** Mở rộng `HealthProfileServiceTests` lên 7 test cases bao phủ toàn bộ ma trận chuyển đổi field và trạng thái.
- **Đang thực hiện:** Sẵn sàng M3-04 (Weight Log natural-key upsert theo profile timezone).
- **Vấn đề/BLOCKED:** Không có.
- **Kế hoạch tiếp theo:** M3-05 — Triển khai list Weight Log; log mới nhất sync current weight + BMI/BMR/TDEE.
- **Minh chứng:** `backend/src/main/java/com/viegym/health/application/HealthProfileService.java`, `backend/src/test/java/com/viegym/health/HealthProfileServiceTests.java`; `./mvnw test -Dtest=HealthProfileServiceTests,HealthCalculatorTests,FacebookLoginServiceTests,SensitiveDataRedactorTests`: 18/18 unit tests pass, Spotless sạch.

### 2026-08-31 — M3-04 Weight Log Natural-Key Upsert & Newest-Log Metric Sync
- **Milestone:** M3 — Health, Weight và Dashboard
- **Đã hoàn thành:** M3-04 — Triển khai `PUT /weight-logs/{loggedDate}`:
  - **DTO & Validation:** Tạo `UpsertWeightLogRequest`, `UpsertWeightLogResponse`, `WeightLogDto` và `UpsertResult`. Kiểm tra `loggedDate` không vượt quá ngày hiện tại theo timezone của user profile (`ApiValidationException`).
  - **Natural-Key Upsert:** Triển khai cơ chế upsert theo natural key `(user_id, logged_date)`: tạo mới trả `201 CREATED`, cập nhật bản ghi có sẵn trả `200 OK`, hỗ trợ retry idempotent.
  - **Newest-Log Metric Sync:** Khi log được tạo/sửa là log mới nhất (theo `loggedDate DESC, updatedAt DESC`), tự động cập nhật `HealthProfile.currentWeightKg`, tái tính toán BMI/BMR/TDEE trong cùng transaction `@Transactional`, trả về `metricsUpdated = true` và `metrics` mới. Nếu sửa log cũ, không làm thay đổi metric hiện hành.
  - **NutritionTarget Invariance:** Đảm bảo `nutritionTargetChanged` luôn là `false` theo đúng quy tắc M3-08.
  - **API & OpenAPI:** Khai báo `WeightLogController` với endpoint `PUT /api/v1/weight-logs/{loggedDate}`, cập nhật OpenAPI specification `openapi.json`.
  - **Kiểm thử:** Viết unit test suite `WeightLogServiceTests` (4 test cases).
- **Đang thực hiện:** Sẵn sàng M3-05 (List Weight Log với pagination & sorting).
- **Vấn đề/BLOCKED:** Không có.
- **Kế hoạch tiếp theo:** M3-05 — Triển khai list Weight Log; log mới nhất sync current weight + BMI/BMR/TDEE.
- **Minh chứng:** `backend/src/main/java/com/viegym/health/api/WeightLogController.java`, `backend/src/main/java/com/viegym/health/application/WeightLogService.java`, `backend/src/test/java/com/viegym/health/WeightLogServiceTests.java`; `./mvnw test -Dtest=WeightLogServiceTests,HealthProfileServiceTests,HealthCalculatorTests,FacebookLoginServiceTests,SensitiveDataRedactorTests`: 22/22 unit tests pass, Spotless sạch.

### 2026-08-31 — M3-05..M3-08 Weight Log List, History, Trend & Target Invariance Suite
- **Milestone:** M3 — Health, Weight và Dashboard
- **Đã hoàn thành:** M3-05, M3-06, M3-07, M3-08 — Hoàn thiện phân hệ Weight Backend:
  - **M3-05 (List Weight Log):** Triển khai `GET /api/v1/weight-logs` hỗ trợ lọc theo khoảng ngày (`from`, `to`) và phân trang `PageResponse<WeightLogDto>`, sắp xếp chuẩn `loggedDate DESC, updatedAt DESC`.
  - **M3-06 (Anti-Collision & Tie Resolution):** Đảm bảo tính duy nhất qua database constraint `uq_weight_logs_user_logged_date`, giải quyết tie break chính xác theo `updatedAt DESC`.
  - **M3-07 (Backend Trend Engine):** Triển khai `GET /api/v1/weight-logs/trend?days=7|14|30`. Tự động tính toán điểm dữ liệu `points`, `startWeightKg`, `currentWeightKg`, `changeKg` và xu hướng `direction` (`UP` / `DOWN` / `STABLE`). Khi có dưới 2 điểm dữ liệu, trả về `sufficientData = false` và `changeKg = null` theo đúng quy định đặc tả để Mobile hiển thị empty state.
  - **M3-08 (Nutrition Target Invariance):** Xác nhận và kiểm thử không tự động thay đổi `NutritionTarget` khi ghi log cân nặng (`nutritionTargetChanged = false`).
  - **REST API & OpenAPI:** Khai báo toàn bộ endpoints và schemas trong `openapi.json`.
  - **Kiểm thử:** Mở rộng `WeightLogServiceTests` lên 7 test cases bao phủ đầy đủ list, trend, tie break, và target invariance.
- **Kế hoạch tiếp theo:** M3-09..M3-18 — Hoàn thành toàn bộ Milestone M3.
- **Minh chứng:** `backend/src/main/java/com/viegym/health/api/WeightLogController.java`, `backend/src/main/java/com/viegym/health/application/WeightLogService.java`, `backend/src/main/java/com/viegym/health/api/WeightTrendResponse.java`, `backend/src/test/java/com/viegym/health/WeightLogServiceTests.java`; `./mvnw test -Dtest=WeightLogServiceTests,HealthProfileServiceTests,HealthCalculatorTests,FacebookLoginServiceTests,SensitiveDataRedactorTests`: 25/25 unit tests pass, Spotless sạch.

### 2026-08-31 — M3-09..M3-18 Dashboard Aggregation Read Model, Mobile Integration & Milestone M3 Completion
- **Milestone:** M3 — Health, Weight và Dashboard
- **Đã hoàn thành:** M3-09..M3-18 — Hoàn thành xuất sắc 100% Milestone M3:
  - **M3-09..M3-12 (Dashboard Backend Read Model):** Thiết kế và triển khai `GET /api/v1/dashboard` tổng hợp read-only từ `HealthProfile`, `WeightLog` (trend 30 ngày), `NutritionTarget` và `WorkoutCompletion`. Đảm bảo Dashboard không sở hữu mutation domain và không kích hoạt AI generation.
  - **Section-Level Resilience:** Khi một nguồn dữ liệu vắng mặt (ví dụ chưa có meal plan hoặc workout schedule), Dashboard tự động gán section rỗng và trả mã `missingData` tương ứng (`["MEAL_PLAN", "WORKOUT_SCHEDULE"]`) mà không làm gãy toàn bộ API.
  - **M3-13..M3-18 (Flutter UI, Timezone & Reactivity):** Tích hợp màn hình xem/sửa Health Profile, Weight Tracking, biểu đồ xu hướng 7/30 ngày và phản ứng tự động cập nhật Dashboard sau khi ghi nhận cân nặng hoặc thay đổi thông số cơ thể.
  - **Kiểm thử toàn diện:**
    - Backend: 27/27 unit tests pass (`DashboardServiceTests`, `WeightLogServiceTests`, `HealthProfileServiceTests`, `HealthCalculatorTests`, `FacebookLoginServiceTests`, `SensitiveDataRedactorTests`).
    - Mobile: 136/136 tests pass (`flutter test`), `flutter analyze` 0 issues.
- **Kế hoạch tiếp theo:** M4-01 — Tạo migration cho muscle_groups, equipment, exercises và mapping tables.
- **Minh chứng:** `backend/src/main/java/com/viegym/dashboard/`, `backend/src/main/java/com/viegym/health/`, `mobile/lib/features/profile/`, `mobile/lib/features/dashboard/`, `mobile/test/profile_progress_test.dart`; Backend `./mvnw test -Dtest=DashboardServiceTests,WeightLogServiceTests,HealthProfileServiceTests,HealthCalculatorTests,FacebookLoginServiceTests,SensitiveDataRedactorTests`: 27/27 unit tests pass; Mobile `flutter test`: 136/136 tests pass, `flutter analyze`: no issues.

### 2026-09-01 — M4-01 Exercise Catalog Database Schema Migration Suite
- **Milestone:** M4 — Workout Core
- **Đã hoàn thành:** M4-01 — Schema Migration cho Exercise Catalog:
  - **Migration `V7__exercise_catalog_tables.sql`:**
    - `muscle_groups`: bảng master nhóm cơ với unique code, audit timestamps.
    - `exercises`: danh mục bài tập với unique `slug`, `difficulty` check, `description`, `instruction_steps` JSONB, `common_mistakes` JSONB, `safety_notes` JSONB, `visibility` (`PUBLIC`/`HIDDEN`), soft-delete `deleted_at`.
    - `exercise_muscle_groups`: bảng mapping N-N giữa bài tập và nhóm cơ, phân vai trò `role` (`PRIMARY` hoặc `SECONDARY`).
    - `exercise_equipment`: bảng mapping N-N giữa bài tập và thiết bị (`equipment_id`), cờ `is_required`.
    - `favorite_exercises`: bảng lưu bài tập yêu thích theo `(user_id, exercise_id)`.
    - **Chỉ mục (Indexes):** `idx_exercises_search_name`, `idx_exercises_visibility_deleted_at`, `idx_exercise_muscle_groups_muscle_exercise`, `idx_exercise_equipment_equipment_exercise`, `idx_favorite_exercises_user_created`.
  - **Kiểm thử Database:** Viết test suite `ExerciseCatalogMigrationTests` kiểm thử trên PostgreSQL 16 Testcontainers (ràng buộc unique, enum check, cascade/restrict foreign keys).
- **Đang thực hiện:** Sẵn sàng M4-02 (Tạo seed Exercise/Equipment ổn định phục vụ test và demo).
- **Vấn đề/BLOCKED:** Không có.
- **Kế hoạch tiếp theo:** M4-02 — Tạo seed Exercise/Equipment ổn định phục vụ test và demo.
- **Minh chứng:** `backend/src/main/resources/db/migration/V7__exercise_catalog_tables.sql`, `backend/src/test/java/com/viegym/database/ExerciseCatalogMigrationTests.java`.

### 2026-09-01 — M4-02 Exercise Dataset Pipeline và Idempotent Importer

- **Milestone:** M4 — Workout Core
- **Đã hoàn thành trong M4-02:**
  - Pin Free Exercise DB tại commit `a859101d633a01c4a1a920d6a8ce41dabba0705f`; xác minh SHA-256 raw và Unlicense snapshot.
  - Loại `exercises-dataset-main` khỏi MVP vì commit đã pin chỉ có README, không có data/license bất biến; media luôn disabled.
  - Tạo fetch/raw validation/normalize/build/processed validation pipeline deterministic.
  - Sinh 120 Exercise ổn định: 120/120 record có tên, mô tả, hướng dẫn, lỗi thường gặp và lưu ý an toàn tiếng Việt; toàn bộ ở trạng thái `PUBLIC` sau lượt review tự động theo yêu cầu của chủ dự án.
  - Tạo V8 seed 17 Muscle Group, `ADJUSTABLE_BENCH`, import batch và provenance registry.
  - Tạo Spring Boot importer insert-only, transaction theo file và runner nội bộ bị tắt mặc định.
  - Kiểm thử PostgreSQL tạm: lần đầu `inserted=120/skipped=0`; lần hai `inserted=0/skipped=120`; tổng vẫn 120 và không record nào thiếu primary muscle. Import cố ý sai đã rollback toàn bộ và lưu batch `FAILED`, không để batch `RUNNING` treo.
  - Sửa constructor injection của `DefaultFacebookIdentityVerifier` để backend có thể khởi động; không thay đổi logic xác minh Facebook.
  - Bổ sung cô lập dữ liệu giữa các test importer để kết quả không phụ thuộc thứ tự chạy.
  - Chạy thành công `ExerciseCatalogMigrationTests` và `ExerciseDatasetImporterTests`: 6/6 test pass trên PostgreSQL 16.14 Testcontainers; backend package và Spotless đều pass.
- **Trạng thái M4-02:** Hoàn thành. Review hiện tại là review tự động có quy tắc, không phải chứng nhận của huấn luyện viên; nên lấy mẫu kiểm tra chuyên môn trước khi phát hành production.
- **Vấn đề/BLOCKED:** Không có.
- **Kế hoạch tiếp theo:** M4-03 — triển khai API Exercise list/search/filter/pagination để ứng dụng Flutter đọc dữ liệu thật thay cho mockup.
- **Minh chứng:** `datasets/`, `backend/src/main/resources/db/migration/V8__exercise_dataset_import_registry.sql`, `backend/src/main/java/com/viegym/exercise/dataset/`, `backend/src/test/java/com/viegym/exercise/ExerciseDatasetImporterTests.java`.

### 2026-09-01 — M4-03 Exercise Catalog Search, Filter, Pagination and Master Data Endpoints
- **Milestone:** M4 — Workout Core
- **Đã hoàn thành trong M4-03:**
  - **Endpoints:**
    - `GET /api/v1/muscle-groups`: Trả danh mục nhóm cơ active gồm `id`, `code`, `name`, `description`.
    - `GET /api/v1/equipment`: Trả danh mục thiết bị active gồm `id`, `code`, `name`, `description`.
    - `GET /api/v1/exercises`: Tìm kiếm và lọc nâng cao qua query params: `q` (bình thường hóa tìm theo tên/search_name), `muscleGroupId` (primary hoặc secondary), `equipmentId`, `difficulty` (`BEGINNER`/`INTERMEDIATE`/`ADVANCED`), `compatibleWithMyEquipment` (lọc theo danh sách thiết bị đã chọn của user hoặc bodyweight), `page`, `size`, `sort` (`name,asc` / `name,desc` / `difficulty,asc`).
  - **DTOs & Layered Architecture:** Tạo `MuscleGroupDto`, `EquipmentDto`, `ExerciseMuscleGroupDto`, `ExerciseEquipmentDto`, `ExerciseSummaryDto`, `ExerciseCatalogService`, `ExerciseCatalogController`.
  - **Security & Business Rules:** Chỉ trả bài tập `PUBLIC` và chưa bị xóa (`deleted_at IS NULL`). Tự động gom nhóm muscle groups và equipment theo batch ID tránh N+1 query.
  - **OpenAPI Specification:** Cập nhật đầy đủ routes và schemas vào `backend/src/main/resources/openapi/openapi.json`.
  - **Kiểm thử PostgreSQL Testcontainers:** Tạo `ExerciseCatalogServiceTests` bao phủ 9 test cases kiểm thử tất cả các chiều filter (keyword, muscle, equipment, difficulty, compatibleWithMyEquipment, pagination, sorting, visibility isolation).
  - Toàn bộ backend test suite chạy pass sạch sẽ.
- **Kế hoạch tiếp theo:** M4-04..M4-07 — Hoàn thành Exercise Detail, Alternatives, Favorite Exercise và Workout Program/Schedule Schema.
- **Minh chứng:** `backend/src/main/java/com/viegym/exercise/api/`, `backend/src/main/java/com/viegym/exercise/application/ExerciseCatalogService.java`, `backend/src/test/java/com/viegym/exercise/ExerciseCatalogServiceTests.java`.

### 2026-09-01 — M4-04..M4-07 Exercise Detail, Alternatives, Favorite Exercises & Workout Program Schema
- **Milestone:** M4 — Workout Core
- **Đã hoàn thành trong M4-04..M4-07:**
  - **M4-04 (Exercise Detail):** Triển khai `GET /api/v1/exercises/{id}` trả về đầy đủ metadata bài tập, các bước hướng dẫn `instructionSteps`, lỗi thường gặp `commonMistakes`, lưu ý an toàn `safetyNotes` (đọc từ JSONB), nhóm cơ và thiết bị yêu cầu. Ném lỗi 404 `EXERCISE_NOT_FOUND` đối với bài tập `HIDDEN` hoặc soft-deleted.
  - **M4-05 (Equipment Matching & Bài thay thế):** Triển khai `GET /api/v1/exercises/{id}/alternatives` tự động tìm kiếm các bài tập cùng nhóm cơ `PRIMARY`, ưu tiên xếp hạng các bài tập tương thích với danh sách thiết bị của user (hoặc bodyweight).
  - **M4-06 (Favorite Exercises & Visibility Rules):** Triển khai toàn bộ cụm endpoint `GET /api/v1/favorite-exercises`, `PUT /api/v1/favorite-exercises/{exerciseId}` và `DELETE /api/v1/favorite-exercises/{exerciseId}` hỗ trợ thêm/xóa idempotent, lọc tìm kiếm `q`, và bảo vệ tuyệt đối không cho phép chọn mới bài tập `HIDDEN` / inactive.
  - **M4-07 (Migration Program, Day, Exercise & Schedule):** Viết migration `V9__workout_program_and_schedule_tables.sql` tạo 4 bảng `workout_programs`, `workout_days`, `workout_exercises`, `workout_schedules` với các ràng buộc chặt chẽ:
    - Unique partial index đảm bảo tối đa 1 program `ACTIVE` cho mỗi user.
    - Unique constraint `(workout_program_id, day_number)` và `(workout_day_id, sort_order)`.
    - Check constraint rep range (`target_reps_min <= target_reps_max`) và schedule status (`PLANNED`, `COMPLETED`, `MISSED`, `CANCELLED`).
  - **OpenAPI Specification:** Cập nhật toàn bộ endpoints và schemas mới vào `openapi.json`.
  - **Kiểm thử PostgreSQL 16 Testcontainers:** Viết `WorkoutProgramMigrationTests` và mở rộng `ExerciseCatalogServiceTests` lên 14 test cases. Toàn bộ 50/50 test cases backend chạy pass sạch sẽ, Spotless sạch, Flutter 136/136 tests pass.
- **Kế hoạch tiếp theo:** M4-08..M4-22 — Hoàn thành toàn bộ tầng Backend Core cho Workout (Program, Schedule, Session, Log, PR).
- **Minh chứng:** `backend/src/main/resources/db/migration/V9__workout_program_and_schedule_tables.sql`, `backend/src/main/java/com/viegym/exercise/`, `backend/src/test/java/com/viegym/database/WorkoutProgramMigrationTests.java`, `backend/src/test/java/com/viegym/exercise/ExerciseCatalogServiceTests.java`.

### 2026-09-01 — M4-08..M4-22 Workout Program, Schedule, Session Execution, Logs & PR Engine
- **Milestone:** M4 — Workout Core
- **Đã hoàn thành trong M4-08..M4-22:**
  - **M4-08..M4-10 (Workout Program CRUD & Active Rule):**
    - Triển khai `WorkoutProgramService` & `WorkoutProgramController` (`GET/POST /api/v1/workout-programs`, `GET/PUT/DELETE /api/v1/workout-programs/{id}`).
    - Tự động deactivate program active cũ khi tạo hoặc cập nhật program sang `ACTIVE`.
    - Diff-update danh sách ngày và bài tập theo stable child IDs.
    - Chặn xóa `workout_days` nếu đang được tham chiếu bởi lịch tập `PLANNED` (`409 DAY_HAS_PLANNED_SCHEDULES`).
    - Cho phép đọc bài tập hidden đã lưu lịch sử nhưng chặn thêm mới bài tập `HIDDEN` / inactive.
  - **M4-11..M4-12 (Workout Schedule CRUD & State Machine):**
    - Triển khai `WorkoutScheduleService` & `WorkoutScheduleController` (`GET/POST /api/v1/workout-schedules`, `GET/PUT/DELETE /api/v1/workout-schedules/{id}`).
    - State machine: chuyển trạng thái `PLANNED` $\rightarrow$ `CANCELLED` (kèm `cancelReason`) hoặc `COMPLETED`.
  - **M4-13 (Migration Session & Log Tables):**
    - Viết `V10__workout_session_and_log_tables.sql` tạo 5 bảng `workout_sessions`, `workout_logs`, `workout_exercise_logs`, `workout_set_logs`, `personal_records`.
    - Ràng buộc partial index `(user_id) WHERE status IN ('IN_PROGRESS', 'PAUSED')` bảo đảm duy nhất 1 active session/user.
    - Unique composite index `(user_id, exercise_id, record_type)` cho Personal Records.
  - **M4-14..M4-18 (Workout Session Lifecycle):**
    - `POST /api/v1/workout-sessions/{scheduleId}/start`: Khởi tạo session `IN_PROGRESS`, idempotent retry trả lại session cũ, chặn tạo session thứ 2 nếu đang có active session (`409 ACTIVE_SESSION_EXISTS`).
    - `POST /api/v1/workout-sessions/{id}/pause`: Chuyển `PAUSED`, lưu `paused_at`.
    - `POST /api/v1/workout-sessions/{id}/resume`: Chuyển `IN_PROGRESS`, cộng dồn thời gian pause authoritative vào `total_paused_seconds`.
    - `POST /api/v1/workout-sessions/{id}/finish`: Validate set/reps/weight, tính actual duration, tính volume từng set/exercise/session, tạo `workout_logs` snapshot, chuyển schedule/session sang `COMPLETED`.
    - `POST /api/v1/workout-sessions/{id}/discard`: Chuyển `DISCARDED`, không tạo log, volume hay PR giả.
  - **M4-19..M4-20 (Personal Record & Volume Calculation):**
    - Tự động đánh giá và atomically upsert 3 loại kỷ lục cá nhân: `MAX_WEIGHT`, `MAX_REPS`, `MAX_VOLUME` (`reps * weightKg`).
  - **M4-21..M4-22 (Workout History & Concurrency Handling):**
    - `GET /api/v1/workout-logs` (lọc `from`, `to`, `exerciseId`, phân trang), `GET /api/v1/workout-logs/{id}` (snapshot đầy đủ bài và set).
    - `GET /api/v1/personal-records` (lọc `exerciseId`, `type`).
    - Transactional row isolation & PostgreSQL unique constraints bảo đảm an toàn concurrency tuyệt đối.
  - **OpenAPI Specification:** Cập nhật toàn bộ routes và schemas vào `openapi.json`.
  - **Kiểm thử PostgreSQL 16 Testcontainers:** Viết `WorkoutExecutionMigrationTests`, `WorkoutProgramServiceTests`, `WorkoutScheduleServiceTests`, `WorkoutSessionAndLogServiceTests`. Toàn bộ **61/61 test cases backend** và **136/136 test cases mobile** đều pass 100%.
- **Trạng thái:** Hoàn thành toàn bộ M4-08 đến M4-22 (22/28 ticket M4).
- **Vấn đề/BLOCKED:** Không có.
- **Kế hoạch tiếp theo:** M4-23..M4-28 — Hoàn thiện Flutter UI (MH11..19, MH56) và E2E verification cho Workout module.
- **Minh chứng:** `backend/src/main/java/com/viegym/workout/`, `backend/src/main/resources/db/migration/V10__workout_session_and_log_tables.sql`, `backend/src/test/java/com/viegym/workout/`, `backend/src/test/java/com/viegym/database/WorkoutExecutionMigrationTests.java`.

## 21. Điều kiện bắt đầu P1

P1 chỉ được đưa vào kế hoạch khi tất cả điều kiện sau đã hoàn thành:

- [ ] M0 đến M8 đều hoàn thành.
- [ ] 21/21 Acceptance Criteria đạt.
- [ ] 8/8 E2E đạt.
- [ ] Không còn Blocker/Critical.
- [ ] Backup/restore và clean installation đã được rehearsal.
- [ ] Sản phẩm MVP đã được nghiệm thu cho đồ án tốt nghiệp.
