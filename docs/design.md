# VieGym — Master Technical Design

> **Phiên bản:** 1.0
>
> **Ngày cập nhật:** 2026-08-19
>
> **Trạng thái:** Baseline thiết kế triển khai MVP
>
> **Phạm vi:** Flutter Mobile App, Spring Boot Backend, PostgreSQL, FastAPI AI Service và hạ tầng hỗ trợ

---

## 1. Mục đích và phạm vi

Tài liệu này là bản thiết kế kỹ thuật tổng hợp của VieGym. Nó mô tả cách các
yêu cầu, use case và feature được hiện thực hóa thành những luồng hoàn chỉnh
trên Mobile, Backend, Database và AI Service.

Tài liệu phục vụ các nhóm sau:

- Mobile dùng để xác định screen, API, client state và trạng thái lỗi cần xử lý.
- Backend dùng để xác định use case, module owner, transaction và business rule.
- AI Service dùng để xác định input contract, trust boundary và output validation.
- QA dùng để truy vết requirement, flow, API, dữ liệu và acceptance criteria.
- Reviewer dùng để kiểm tra implementation có giữ đúng boundary hay không.

`design.md` tập trung vào **cách các thành phần phối hợp để hiện thực hóa một
vertical slice**. Tài liệu không thay thế schema, API contract, đặc tả màn hình
hoặc cấu hình triển khai chi tiết đã có tài liệu chuyên trách.

### 1.1. Trong phạm vi

- Authentication, session, OTP và Google Login.
- User Profile, User Preference và Equipment Preference.
- Health Profile, BMI, BMR, TDEE, calories/macro target và Weight Tracking.
- Exercise Library, Workout Program, Schedule, Session, Log và PR.
- Food Database, Meal Planner, nutrition summary và meal history/template.
- Dashboard tổng hợp dữ liệu authoritative.
- AI Consent, Context, Coach Chat, Daily Recommendation và Apply/Dismiss.
- Admin quản lý Exercise/Food và Audit Log ở mức P0 baseline.
- Media cho Exercise và Food ở mức P0 baseline; avatar Profile là P1.
- Notification, Weekly Review và các phần mở rộng được đánh dấu P1/P2.

### 1.2. Ngoài phạm vi

- Shop/Marketplace, Cart, Order, Payment và supplement commerce.
- Wearable, Apple Health và Google Fit.
- Food image recognition.
- Pose estimation hoặc computer vision.
- ML prediction độc lập ngoài luồng AI Provider đã định nghĩa.
- AI tự thay đổi kế hoạch hoặc dữ liệu mà không có xác nhận của User.
- Microservices, Kubernetes, service mesh và message broker trong MVP.

---

## 2. Nguồn tài liệu và quyền quyết định

### 2.1. Thứ tự ưu tiên

Khi có khác biệt, áp dụng thứ tự ưu tiên sau:

1. [SRS v3.0](./spec/specs.md) — source of truth về yêu cầu và phạm vi.
2. [Luồng nghiệp vụ](./spec/bussiness_mainflow.md) — hành vi end-to-end.
3. [Phân rã phân hệ](./spec/phan_ra_phan_he_he_thong.md) — owner và boundary.
4. [Phân rã tính năng](./spec/phan_ra_tinh_nang.md) — feature ID, priority và AC.
5. [System Architecture](./kientruchethong/sa.md) — kiến trúc và trust boundary.
6. [API Specification](./kientruchethong/API_SPEC.md) — API contract canonical.
7. [Database Schema](./kientruchatang/DATABASE.md) — data model canonical.
8. [Phân rã màn hình](./spec/phan_ra_man_hinh.md) — UI/UX contract.
9. [Tech Stack](./kientruchatang/techstack.md) và
   [Server & Deployment](./kientruchatang/server.md) — runtime và vận hành.
10. Tài liệu này — cách ghép các contract trên thành giải pháp triển khai.

Tài liệu cấp thấp không được tự thay đổi yêu cầu cấp cao. Nếu implementation
cần thay đổi scope, state, contract hoặc boundary, phải cập nhật tài liệu owner
và traceability trong cùng change.

### 2.2. Ownership của tài liệu

- Requirement, use case, priority: `specs.md`.
- Business flow và failure branch: `bussiness_mainflow.md`.
- Subsystem ownership và dependency: `phan_ra_phan_he_he_thong.md`.
- Feature ID và acceptance criteria: `phan_ra_tinh_nang.md`.
- Component/package boundary: `sa.md`.
- Endpoint, payload, HTTP status và error code: `API_SPEC.md`.
- Table, column, constraint, index và migration: `DATABASE.md`.
- Screen ID, navigation và UI state: `phan_ra_man_hinh.md`.
- Dependency/version: `techstack.md`.
- Container, network, backup và release: `server.md`.
- Orchestration xuyên các owner trên: `design.md`.

---

## 3. Mục tiêu, non-goal và invariant

### 3.1. Mục tiêu thiết kế

- Hoàn thành các vertical slice P0 có thể demo và kiểm thử end-to-end.
- Giữ business rule ở Backend thay vì phân tán sang Mobile hoặc AI Service.
- Cô lập AI Provider khỏi dữ liệu authoritative và mutation nghiệp vụ.
- Bảo vệ private resource bằng authentication, authorization và ownership.
- Giữ lịch sử đúng bằng snapshot, state machine, transaction và audit.
- Cho phép phát triển theo module nhưng tránh microservice complexity ở MVP.
- Làm rõ failure flow và fallback, đặc biệt với OTP, media và AI.

### 3.2. Non-goal

- Không thiết kế tối ưu sớm cho quy mô chưa được đo.
- Không tạo abstraction hoặc interface rỗng chỉ để tuân theo pattern.
- Không dùng Redis, event bus hoặc background job làm điều kiện để core flow chạy.
- Không đồng nhất client state với business state authoritative.
- Không lưu bí mật provider hoặc business authority trên Mobile.

### 3.3. Invariant bắt buộc

> **Backend calculates. AI interprets and recommends. User decides. Backend executes.**

1. Spring Boot Backend là business authority và thành phần duy nhất thực hiện
   mutation nghiệp vụ từ client hoặc AI proposal.
2. PostgreSQL là source of truth của account, health, workout, nutrition,
   consent, recommendation và audit.
3. Flutter chỉ gọi public API `/api/v1` của Backend; không gọi FastAPI hoặc AI
   Provider trực tiếp.
4. FastAPI AI Service không có database credential và không đọc PostgreSQL.
5. AI output luôn là dữ liệu chưa tin cậy cho đến khi Backend hoàn tất schema,
   safety và business validation.
6. Apply recommendation cần hành động rõ ràng của User; AI không được tự Apply.
7. Mọi private resource phải được kiểm tra role và ownership tại Backend.
8. Dashboard là read model tổng hợp; không sở hữu dữ liệu mutation.
9. Mỗi entity có đúng một module owner. Module khác không ghi trực tiếp
   repository của owner.
10. Mobile có thể kiểm tra để cải thiện UX nhưng không thay thế Backend guard.

---

## 4. Tổng quan thiết kế hệ thống

```text
┌──────────────────────────────────────────────────────────────────┐
│                       Flutter Mobile App                         │
│ Auth · Health · Workout · Nutrition · Dashboard · AI · Admin    │
└──────────────────────────────┬───────────────────────────────────┘
                               │ HTTPS / REST /api/v1 + JWT
                               ▼
┌──────────────────────────────────────────────────────────────────┐
│                 Spring Boot Modular Monolith                     │
│ Identity · Preference · Health · Workout · Nutrition · Dashboard│
│ AI Backend · Admin/Audit · Media · Notification                  │
└───────────────┬───────────────────┬───────────────────┬──────────┘
                │ JDBC/JPA          │ internal HTTP     │ S3 API
                ▼                   ▼                   ▼
       ┌────────────────┐  ┌─────────────────┐  ┌────────────────┐
       │ PostgreSQL     │  │ FastAPI AI      │  │ Object Storage │
       │ source of truth│  │ stateless       │  │ media binary   │
       └────────────────┘  └────────┬────────┘  └────────────────┘
                                    │ provider SDK
                                    ▼
                           ┌─────────────────┐
                           │ AI Provider/LLM │
                           └─────────────────┘
```

### 4.1. Luồng request chuẩn

```text
UI event
  → Mobile validation cơ bản
  → API request + access token + correlation metadata
  → Controller parse và validate cú pháp
  → Application service kiểm tra identity/role/ownership
  → Domain service áp dụng business rule
  → Repository/external port trong transaction phù hợp
  → Response DTO/error contract
  → Mobile cập nhật state từ response authoritative
```

### 4.2. Nguyên tắc đồng bộ

- Mutation thành công chỉ được hiển thị sau khi Backend xác nhận.
- P0 không giả lập mutation thành công khi offline.
- Retry tự động chỉ áp dụng cho thao tác an toàn hoặc có idempotency contract.
- Client refresh dữ liệu tổng hợp khi mutation làm thay đổi Dashboard.
- Thời gian lưu theo UTC; hiển thị theo timezone của User.
- Đơn vị canonical tuân theo API và database; quy đổi hiển thị thuộc client.

---

## 5. Component responsibility và ownership

### 5.1. Flutter Mobile

Chịu trách nhiệm:

- Render UI và quản lý client/application state.
- Điều hướng theo authentication, onboarding và role.
- Secure storage cho credential được phép lưu trên thiết bị.
- Form validation cơ bản và trạng thái loading/empty/error/offline.
- Gọi API, refresh session và map error thành thông báo phù hợp.

Không chịu trách nhiệm:

- Tính metric authoritative.
- Kiểm tra ownership cuối cùng.
- Tạo business state độc lập với Backend.
- Lưu AI Provider key hoặc gọi AI Service trực tiếp.

### 5.2. Spring Boot Backend

Chịu trách nhiệm:

- Public REST API và internal orchestration.
- Authentication, role, ownership và resource authorization.
- Calculation, validation, transaction và state transition.
- Xây context AI theo whitelist và consent.
- Validate proposal, thực hiện Apply/Dismiss và ghi audit.
- Quản lý metadata media và cấp quyền truy cập object.

Backend dùng modular monolith. Mỗi module chứa presentation, application,
domain và infrastructure boundary khi việc tách lớp giúp cô lập business rule
hoặc external dependency.

### 5.3. PostgreSQL

- Lưu business state authoritative và audit.
- Thực thi constraint, unique rule và referential integrity.
- Hỗ trợ transaction cho state transition và snapshot.
- Không lưu media binary hoặc provider secret.
- Migration được version hóa bằng Flyway; migration đã áp dụng không bị sửa.

### 5.4. FastAPI AI Service

- Nhận context tối thiểu do Backend cung cấp.
- Nhận prompt/schema đã được Spring Boot version/render, chọn provider adapter,
  gọi model và parse structured output.
- Trả về output hoặc failure chuẩn cho Backend.
- Stateless đối với dữ liệu nghiệp vụ; không authorization User và không mutation.

### 5.5. Object Storage và Redis

- Object Storage lưu binary; Backend giữ metadata, owner và access policy.
- Redis là optional cho cache/rate limit khi có nhu cầu đo được.
- Core business flow phải hoạt động khi Redis không được bật.

### 5.6. Module owner

- `identity`: account, credential, OTP, token và role.
- `preference`: user preference và equipment preference.
- `health`: health profile, metric, nutrition target và weight log.
- `workout`: exercise, program, schedule, session, set log và PR.
- `nutrition`: food, meal plan, meal entry, snapshot và nutrition summary.
- `dashboard`: query aggregation, không sở hữu mutation.
- `ai`: consent, context, conversation, rule, recommendation và Apply routing.
- `admin/audit`: admin use case và audit log.
- `media`: metadata, upload lifecycle và access policy.
- `notification`: notification/reminder P1.

Module consumer gọi application/domain service của owner. Không truy cập trực
tiếp repository của module khác để tránh bypass rule và transaction boundary.

---

## 6. Cấu trúc ứng dụng

### 6.1. Flutter theo feature

```text
mobile/lib/
├── app/                    # bootstrap, router, theme, app shell
├── core/                   # network, auth session, storage, error, shared UI
└── features/
    ├── auth/
    ├── profile/
    ├── health/
    ├── workout/
    ├── nutrition/
    ├── dashboard/
    ├── ai_coach/
    ├── admin/
    └── media/
```

Mỗi feature chỉ tách `data`, `domain`, `presentation` khi cần thiết. Mobile dùng
`flutter_riverpod` thống nhất theo [ADR-001](../checkM0/ADR-001_FLUTTER_STATE_MANAGEMENT.md).

### 6.2. Spring Boot theo business capability

```text
backend/src/main/java/com/viegym/
├── common/                 # technical cross-cutting, không chứa domain mơ hồ
├── identity/
├── preference/
├── health/
├── workout/
├── nutrition/
├── dashboard/
├── ai/
├── admin/
├── audit/
├── media/
└── notification/
```

Luồng trong một module:

```text
Controller → Application Use Case → Domain Policy/Service → Repository/Port
```

- Controller không chứa business rule.
- Application service là orchestration và transaction boundary.
- Domain giữ calculation, invariant và state transition.
- Infrastructure triển khai JPA, storage, email hoặc AI client.
- DTO API không được dùng trực tiếp làm entity persistence.

### 6.3. FastAPI theo internal contract

```text
ai-service/app/
├── api/                    # internal endpoint
├── schemas/                # input/output contract
├── orchestration/          # prompt, parsing, fallback
├── providers/              # provider adapter
├── safety/                 # output guard và policy
└── config/                 # server-side settings
```

AI Service không có package repository cho business database.

---

## 7. Thiết kế vertical slice P0

Mỗi slice dưới đây mô tả orchestration. Payload chính xác theo `API_SPEC.md`,
schema theo `DATABASE.md`, screen behavior theo `phan_ra_man_hinh.md`.

### 7.1. Register, OTP, Login và Health Onboarding

**Trace:** UC-01, UC-02, UC-03; FT-ID-001..010, FT-HP-001..004;
MH01, MH02, MH04, MH05, MH06, MH09 và MH10.

```text
Guest nhập thông tin đăng ký
  → Backend validate và tạo account PENDING
  → tạo OTP có TTL/attempt limit và gửi qua provider
  → User verify OTP
  → Backend kích hoạt account và cấp session
  → Mobile điều hướng Health Profile + Equipment onboarding
  → Backend lưu profile, tính metric/target trong một use case
  → Mobile vào Dashboard sau khi onboarding hợp lệ
```

Quy tắc:

- Email unique và được chuẩn hóa nhất quán.
- Password chỉ lưu dạng hash; OTP/token không log ở plaintext.
- Account chưa verify, locked hoặc disabled không nhận session nghiệp vụ.
- Refresh token có lifecycle, revoke và rotation theo API contract.
- Biometric chỉ mở khóa credential local; không thay thế xác thực Backend.
- Metric được Backend tính từ profile hợp lệ và trả kèm nguồn/thời điểm tính.

Failure flow:

- OTP sai, hết hạn, dùng lại hoặc vượt số lần thử bị từ chối.
- Resend tuân theo cooldown/rate limit và không làm lộ account enumeration.
- Nếu tạo profile thất bại, account vẫn hợp lệ nhưng onboarding chưa hoàn tất.
- Mobile resume onboarding theo trạng thái authoritative khi mở lại app.

Transaction:

- Tạo account và OTP phải tránh account active một phần.
- Verify OTP, activate account và consume OTP là atomic.
- Cập nhật Health Profile và metric/target liên quan là một transaction nghiệp vụ.

### 7.2. Health Profile, Weight và Dashboard

**Trace:** UC-02, UC-03, UC-10, UC-11; FT-HP-001..007,
FT-DB-001..005 và FT-DB-007; MH03, MH42 và MH43.

```text
User cập nhật Health Profile hoặc thêm Weight Log
  → Backend kiểm tra ownership và dữ liệu đầu vào
  → Health module tính metric; chỉ profile-domain change phù hợp mới đổi target
  → lưu profile/log và snapshot/target cần thiết
  → Dashboard query tổng hợp health + nutrition + workout + AI
  → Mobile render dữ liệu cùng trạng thái thời gian và đơn vị
```

Quy tắc:

- Công thức và rounding canonical nằm ở Health domain.
- Client có thể preview nhưng phải ghi rõ ước lượng và thay bằng kết quả Backend.
- Weight Log upsert theo `(user, loggedDate)`; chỉ log mới nhất sync current
  weight và BMI/BMR/TDEE, tuyệt đối không tự đổi Nutrition Target.
- Dashboard không ghi ngược vào Health, Workout, Nutrition hoặc AI.
- Thiếu một nguồn dữ liệu không làm toàn bộ Dashboard thất bại; section trả
  trạng thái phù hợp theo API contract.

Failure flow:

- Giá trị ngoài range hợp lệ trả validation error theo field.
- Dữ liệu chưa đủ để tính metric trả trạng thái incomplete, không tự bịa default.
- Query tổng hợp chậm hoặc lỗi một dependency nội bộ phải được quan sát bằng
  correlation ID và không làm lộ exception nội bộ.

### 7.3. Workout Program, Schedule, Session và Log

**Trace:** UC-04..UC-07; FT-WO-001..009 và FT-WO-011;
MH11..MH19.

```text
User xem Exercise Library theo equipment
  → tạo/chọn Workout Program
  → thêm workout day và exercise
  → tạo Schedule
  → start/pause/resume/finish hoặc discard Session
  → ghi set/reps/weight
  → Backend cập nhật Schedule, Log, volume và PR
  → Dashboard/History đọc kết quả mới
```

Quy tắc:

- Exercise catalog có thể public theo ứng dụng nhưng mutation catalog là Admin.
- Program, Schedule, Session và Log luôn kiểm tra ownership.
- Một User chỉ có một Session active; program update dùng stable child ID/diff.
- Exercise hidden/inactive không được chọn mới; lịch sử cũ vẫn đọc được.
- Session transition tuân theo state machine canonical trong API/database.
- Finish session validate set log, cập nhật schedule và thống kê trong transaction.
- PR/volume do Backend tính; không tin giá trị tổng hợp do Mobile gửi lên.

Concurrency và idempotency:

- Hai request finish đồng thời không được tạo hai workout log.
- Retry request start/finish phải theo idempotency/state transition contract.
- Update đồng thời phải phát hiện version/state không còn hợp lệ và trả conflict.

Failure flow:

- Không cho resume session đã finish/discard.
- Không cho sửa log của User khác.
- Khi mạng mất trong P0, Mobile giữ draft UI cần thiết nhưng không báo đã lưu.

### 7.4. Food, Meal Plan và Nutrition Summary

**Trace:** UC-08, UC-09; FT-MP-001..006, FT-MP-009 và FT-MP-011;
MH20..MH25 và MH54.

```text
User chọn ngày và bữa
  → tìm Food và chọn serving/quantity
  → GET chỉ đọc; mutation đầu tiên mới tạo Meal Plan + target snapshot
  → tạo Meal Entry với nutrition snapshot
  → tính daily calories/macro summary
  → Dashboard và Nutrition UI đọc summary mới
```

Quy tắc:

- Mỗi User có tối đa một Meal Plan canonical cho một local date.
- Entry lưu snapshot dinh dưỡng để lịch sử không đổi khi Food catalog bị sửa.
- Serving multiplier và tổng calories/macro được Backend tính.
- Nhập gram chỉ hợp lệ khi Food có `gramsPerServing`; lưu cả input unit/amount.
- Food P0 chỉ `PUBLIC/HIDDEN`; hidden không được chọn mới nhưng lịch sử vẫn đọc.
- Meal template/history sao chép thành entry mới, không liên kết mutable history.

Transaction và concurrency:

- Lazy-create Meal Plan tại mutation đầu phải chống tạo trùng theo User/date;
  target snapshot bất biến sau khi tạo.
- Thêm/sửa/xóa entry và cập nhật summary liên quan phải nhất quán.
- Request đồng thời không được làm mất entry hoặc tạo tổng sai.

Failure flow:

- Food bị hidden giữa lúc xem và lúc thêm trả conflict/not-found phù hợp.
- Serving không hợp lệ trả field validation; không clamp âm thầm.
- Vượt target là warning/insight, không mặc định chặn ghi meal.

### 7.5. AI Consent và Coach Chat

**Trace:** UC-12, UC-17; FT-AI-001..007, FT-AI-010 và FT-AI-014;
MH27, MH28, MH29 và MH55.

```text
User mở AI
  → Backend đọc consent
  ├── DISABLED: chỉ General Knowledge Mode, không dùng dữ liệu cá nhân
  └── ENABLED: Backend build context theo task whitelist và budget
        → gửi internal request tới FastAPI
        → FastAPI gọi provider và parse structured output
        → Backend validate schema/safety/business policy
        → lưu conversation/message phù hợp
        → trả response an toàn cho Mobile
```

Quy tắc:

- Consent phải được kiểm tra tại thời điểm build context, không chỉ ở UI.
- Context chỉ gồm field cần thiết cho tác vụ và không chứa secret/token.
- General Knowledge Mode không được ngầm dùng health/workout/nutrition của User.
- Prompt/provider output được xem là untrusted input.
- Chat không chẩn đoán bệnh và không thay thế chuyên gia y tế.
- Conversation của User nào chỉ User đó được đọc.

Fallback:

- Timeout/provider unavailable trả thông báo có thể retry nhưng không retry vô hạn.
- Output sai schema hoặc vi phạm safety bị chặn hoặc chuyển fallback an toàn.
- Tắt consent ngăn context cá nhân mới; retention/history theo privacy contract.

### 7.6. Daily Recommendation và Apply/Dismiss

**Trace:** UC-13, UC-14; FT-UP-005, FT-AI-003, FT-AI-004,
FT-AI-008..010; MH30 và MH31.

```text
Trigger daily recommendation
  → Backend kiểm tra consent và thu thập signal authoritative
  → Rule Engine `rules-v1` xác định nhu cầu/priority
  → Context Builder tạo context + candidate shortlist tối thiểu
  → FastAPI/Provider tạo explanation + allowed action proposal
  → Backend validate toàn batch và atomically lưu 1–3 Recommendation PENDING
  → User xem Recommendation
  ├── Dismiss → PENDING → DISMISSED + feedback/audit
  └── Apply
       → kiểm tra lại auth, owner, consent, status và dữ liệu hiện tại
       → route allowed action tới domain owner
       → domain owner validate và mutation trong transaction
       → PENDING → APPLIED + feedback/audit
```

Quy tắc:

- Recommendation không phải business command đã được phê duyệt.
- Chỉ action type/field nằm trong Allowed Action Contract được cân nhắc Apply.
- Dashboard và GET Recommendation chỉ đọc; POST generation command mới gọi
  provider. Output `BLOCKED` không được persist thành Recommendation.
- Proposal mutation phải có `targetDate`, ID thuộc shortlist và preference key
  thuộc whitelist; Apply validate lại theo dữ liệu hiện tại.
- Backend tính lại hoặc kiểm tra precondition tại thời điểm Apply; không tin snapshot
  cũ nếu business state đã thay đổi.
- Một recommendation chỉ có một terminal transition hợp lệ.
- Dismiss không mutation domain target.
- Apply thất bại không được đánh dấu APPLIED.

Concurrency và audit:

- Hai request Apply/Dismiss đồng thời chỉ một request thắng state transition.
- Transaction Apply gồm domain mutation, recommendation status và audit cần thiết.
- Audit ghi actor, action, target, outcome và correlation metadata; không ghi prompt
  hoặc health data nhạy cảm vượt nhu cầu.

### 7.7. Admin Exercise/Food, Media và Audit

**Trace:** UC-19, UC-21; FT-AD-003, FT-AD-004, FT-AD-008,
FT-MD-001..003; MH45, MH46, MH47 và MH51.

```text
Admin tạo/sửa Exercise hoặc Food
  → Backend kiểm tra role ADMIN
  → tạo resource `HIDDEN` trước
  → nếu có media: init upload theo owner + role + sort và cấp presigned contract
  → client upload binary trực tiếp vào Object Storage
  → complete upload để Backend verify metadata/state
  → liên kết media với catalog entity
  → ghi Audit Log cho hành động nhạy cảm
```

Quy tắc:

- UI Admin không thay thế role check ở Backend.
- Backend không proxy toàn bộ binary nếu dùng presigned upload.
- Object key do server kiểm soát; validate owner type, MIME, extension và size.
- Xóa/hide catalog không làm mất khả năng đọc lịch sử có snapshot/reference hợp lệ.
- Audit Log chỉ đọc bởi role được phép và không thể sửa qua API nghiệp vụ.

Failure flow:

- Upload chưa complete không được dùng như media active.
- Complete với object thiếu hoặc metadata sai bị từ chối.
- Catalog mutation rollback không được để metadata active trỏ tới object không hợp lệ.
- Orphan cleanup tối thiểu là P0 hardening; transcoding/cleanup nâng cao là P2.

---

## 8. AI Personalization và trust boundary

### 8.1. Pipeline canonical

```text
Consent Gate
  → Authoritative Data Fetch
  → Task-scoped Context Builder
  → Rule/Signal Evaluation
  → Internal AI Request
  → Provider Invocation
  → Structured Output Parse
  → Schema Validation
  → Safety Validation
  → Business Validation
  → Persist/Return
```

### 8.2. Context policy

- Context được tạo theo `AiContextType`, không tạo một hồ sơ tổng hợp vô hạn.
- Chỉ lấy field có trong whitelist của task.
- Ưu tiên summary/signal đủ dùng thay cho lịch sử thô dài.
- Context có budget, thời gian tạo và phiên bản schema.
- Mọi truy vấn context dùng identity của User hiện tại và ownership guard.
- Không gửi credential, token, OTP, internal authorization hoặc secret.

### 8.3. Output contract

AI output nên gồm explanation, type, priority, evidence/signal reference và
optional allowed action proposal theo schema. Văn bản tự do không được parse
thành business command bằng heuristic thiếu kiểm soát.

Backend kiểm tra:

1. Schema và enum.
2. Độ dài, field bắt buộc và content safety.
3. Action có nằm trong allowlist hay không.
4. Target có thuộc User hay không.
5. Giá trị có thỏa domain constraint hay không.
6. State hiện tại có cho phép proposal/apply hay không.

### 8.4. Provider failure

- Timeout hữu hạn và có circuit/fallback ở mức phù hợp.
- Retry chỉ cho lỗi transient, có backoff và giới hạn.
- Không đổi provider/model âm thầm nếu làm thay đổi contract hoặc privacy.
- Provider error được map thành lỗi nội bộ an toàn; không lộ prompt/secret.
- Chat/recommendation failure không làm rollback dữ liệu health/workout/nutrition
  đã commit độc lập trước đó.

---

## 9. Cross-cutting design

### 9.1. Authentication và session

- Access token gửi qua `Authorization: Bearer` theo API contract.
- Refresh token được rotate/revoke và lưu server-side ở dạng an toàn.
- Logout revoke session tương ứng; password reset/change có thể revoke session
  theo security policy canonical.
- Google token được Backend verify với issuer/audience/expiry; Mobile assertion
  không tự tạo account trust.

### 9.2. Authorization và ownership

Thứ tự guard khuyến nghị:

```text
Authenticate → account status → role → resource lookup scoped by owner
→ state/precondition → mutation
```

- Query private resource ưu tiên scope bằng `user_id` thay vì load rồi kiểm tra muộn.
- Response forbidden/not-found tuân theo API policy để tránh resource enumeration.
- Admin endpoint tách route và policy rõ ràng.

### 9.3. Validation và error

- Mobile validation phục vụ UX.
- Controller validate syntax, required field và format.
- Domain validate invariant, state transition và calculation constraint.
- Database constraint là lớp bảo vệ cuối, không thay thế domain error rõ ràng.
- Error response dùng envelope, code và correlation ID trong `API_SPEC.md`.
- Không trả stack trace, SQL, provider payload hoặc secret ra client.

### 9.4. Transaction và concurrency

- Transaction đặt quanh một business invariant, không quanh remote AI call dài.
- External call không được giữ database lock nếu có thể tách phase an toàn.
- Unique constraint bảo vệ lazy-create Meal Plan tại mutation đầu tiên và các natural invariant; GET không ghi database.
- State transition dùng conditional update/version để chống double submit.
- Idempotency áp dụng cho operation có khả năng retry gây duplicate side effect.

### 9.5. Snapshot và lịch sử

- Meal Entry lưu nutrition snapshot tại thời điểm ghi nhận.
- Workout Log giữ exercise/set result cần thiết để lịch sử không bị viết lại.
- Recommendation giữ context/output metadata tối thiểu phục vụ giải thích/audit.
- Snapshot không được dùng để bypass quyền hoặc business validation khi Apply.

### 9.6. Date, timezone và unit

- Timestamp persistence dùng UTC.
- Daily Meal Plan, Dashboard và Schedule xác định local date theo timezone User.
- API quy định rõ đơn vị kg, cm, kcal, gram và duration.
- Thay đổi timezone không được tự tạo hai record canonical cho cùng business key.

### 9.7. Observability và audit

- Request có correlation ID xuyên Mobile-facing Backend và internal AI call.
- Log structured gồm service, operation, outcome và latency phù hợp.
- Metric tối thiểu: API latency/error, DB pool, AI latency/error/schema rejection,
  OTP rate-limit và media failure.
- Audit dành cho hành động nhạy cảm; application log không thay thế audit.
- Log redaction áp dụng cho password, token, OTP, secret và health data nhạy cảm.

### 9.8. Offline và client state

- P0 hiển thị offline rõ ràng và không xác nhận mutation chưa được server nhận.
- Cache đọc có thể hiển thị dữ liệu cũ nếu ghi rõ trạng thái/staleness phù hợp.
- Advanced offline mutation queue là P2.
- Sau refresh token failure, Mobile xóa session phù hợp và điều hướng login.

### 9.9. Privacy và retention

- Thu thập và gửi AI context theo data minimization.
- Consent history được lưu theo policy; tắt consent có hiệu lực với request mới.
- Đồ án tốt nghiệp chỉ dùng synthetic/demo data và purge môi trường theo runbook trước
  bàn giao hoặc trong vòng 30 ngày sau chấm; legal retention, self-service
  account deletion và backup expiry cần ADR trước dữ liệu thật/production.
- Presigned URL có TTL và scope phù hợp; bucket không public mặc định.

---

## 10. Data và API strategy

### 10.1. API-first

- Public API version `/api/v1`; internal AI API có boundary riêng.
- Request/response DTO ổn định và độc lập với JPA entity.
- OpenAPI sinh hoặc kiểm tra từ contract đã chốt; Flutter client dùng generator `dart-dio` được pin và CI no-diff.
- Pagination, filter, status và error dùng convention chung.
- Breaking change cần versioning/migration plan, không sửa âm thầm contract P0.

### 10.2. Data ownership

- Mỗi bảng/entity thuộc một domain owner trong `DATABASE.md`.
- Dashboard sử dụng query/read projection nhưng không sở hữu bảng mutation.
- AI context đọc qua application/query service, không truy cập repository xuyên
  module tùy tiện.
- Foreign key, unique/index và soft-delete policy theo tài liệu database canonical.

### 10.3. Migration và seed

- Flyway migration chạy trên PostgreSQL sạch trong CI.
- Migration đã áp dụng là immutable; thay đổi dùng migration mới.
- Seed P0 idempotent, tối thiểu 40 Exercise/80 Food theo SRS và đủ media cho demo.
- Không seed password, OTP, token hoặc provider secret thật.

---

## 11. Deployment và runtime overview

### 11.1. Local/demo

Docker Compose khởi chạy tối thiểu:

- Spring Boot Backend.
- PostgreSQL.
- FastAPI AI Service.
- S3-compatible Object Storage khi media upload được bật.
- Redis chỉ trong optional profile nếu đã có quyết định sử dụng.

Flutter/emulator gọi Backend qua địa chỉ môi trường được cấu hình. Chỉ Backend
được phép gọi internal AI endpoint và truy cập database credential.

### 11.2. Runtime boundary

- Public ingress đi tới Backend; FastAPI và PostgreSQL nằm trong private network.
- TLS bắt buộc ngoài local.
- Secret lấy từ environment/secret manager, không commit vào source.
- Readiness phản ánh khả năng nhận traffic; liveness không phụ thuộc mù quáng
  vào external provider.
- Timeout của caller lớn hơn timeout nội bộ có kiểm soát; retry không nhân tầng.

### 11.3. Release order

1. Backup/restore readiness và migration compatibility.
2. Database migration tương thích ngược.
3. AI Service nếu internal contract thay đổi tương thích.
4. Backend.
5. Mobile release sau khi API tương thích đã sẵn sàng.
6. Smoke test các vertical slice P0.

Chi tiết container, proxy, backup, rollback và production hardening thuộc
`server.md`.

---

## 12. Testing và verification strategy

### 12.1. Unit test

- BMI/BMR/TDEE, calories/macro và rounding boundary.
- Workout volume/PR và state transition.
- Meal serving multiplier và snapshot calculation.
- Consent gate, context whitelist/budget và rule signal.
- Allowed Action validation và proposal routing.
- Authorization policy và error mapping thuần logic.

### 12.2. Integration/API test

- Auth/OTP/session lifecycle và rate limit.
- Ownership cho toàn bộ private resource.
- Unique constraint, transaction rollback và concurrent state transition.
- Meal Plan GET read-only; mutation đầu lazy-create plan với immutable target snapshot và input-unit snapshot.
- Workout finish không tạo duplicate log.
- AI internal contract, timeout, invalid schema và safety rejection.
- Media init/complete và metadata verification.
- Flyway migration trên PostgreSQL sạch.

### 12.3. Mobile test

- Router guard theo auth/onboarding/role.
- Loading, empty, validation, server error và offline state.
- Token refresh single-flight và logout khi refresh thất bại.
- Form mapping đúng API unit/enum.
- Apply/Dismiss chống double tap và refresh state từ Backend.

### 12.4. E2E P0

1. Register → OTP → Health/Equipment onboarding → Dashboard.
2. Login → Exercise → Program → Schedule → Session → Log/PR.
3. Food → Meal Plan → Entry → Nutrition Summary → Dashboard.
4. Weight Log → metric/progress refresh.
5. AI consent enable → personalized chat → daily recommendation.
6. Apply recommendation → domain mutation + audit; Dismiss không mutation.
7. Admin Exercise/Food + media baseline → User đọc catalog mới.

Mỗi E2E cần có ít nhất một failure branch quan trọng, không chỉ happy path.

---

## 13. Quyết định mở và ADR

Các quyết định chặn M1/M2 đã được khóa:

1. [ADR-001](../checkM0/ADR-001_FLUTTER_STATE_MANAGEMENT.md): `flutter_riverpod`.
2. [ADR-002](../checkM0/ADR-002_AI_PROVIDER.md): OpenAI Responses API, `gpt-5.6-luna`.
3. [ADR-003](../checkM0/ADR-003_OBJECT_STORAGE.md): MinIO local/demo, Amazon S3 production.
4. [ADR-004](../checkM0/ADR-004_MOBILE_REFRESH_TOKEN.md): refresh token trong secure storage, access token trong memory.
5. [ADR-005](../checkM0/ADR-005_OTP_EMAIL_POLICY.md): Resend/fake adapter và policy OTP chính xác; PostgreSQL là baseline counter P0.
6. [ADR-006](../checkM0/ADR-006_MEDIA_ALLOWLIST.md): allowlist media Exercise/Food P0.
7. [ADR-007](../checkM0/ADR-007_EXPIRY_POLICY.md): lazy-on-read/lazy-on-command authoritative.

Các quyết định không chặn môi trường local và M1/M2, nhưng phải khóa trước khi
dùng dữ liệu thật hoặc production: hosting/ingress/WAF, secret manager,
observability vendor, backup retention, RPO/RTO, privacy retention và account purge.

Mỗi ADR phải có:

- Context và vấn đề cần giải quyết.
- Các phương án đã cân nhắc.
- Quyết định và lý do.
- Hệ quả, rủi ro và rollback/migration nếu có.
- Owner, ngày áp dụng và trạng thái.

Trạng thái sử dụng: `OPEN`, `PROPOSED`, `ACCEPTED`, `SUPERSEDED`.

ADR không được phá các invariant ở mục 3.3 nếu SRS và kiến trúc chưa được thay
đổi chính thức.

---

## 14. Traceability

### 14.1. Chuỗi truy vết chuẩn

```text
SRS Requirement / Acceptance Criteria
  → Use Case
  → Business Flow
  → Feature ID
  → Screen ID
  → Subsystem Owner
  → API Contract
  → Database Domain
  → Automated Test
```

### 14.2. Traceability theo capability

- Identity/Auth: UC-01; FT-ID; MH01/MH02/MH04..MH08/MH52/MH53;
  Identity API và Identity/Profile database domain.
- Health/Profile: UC-02, UC-03, UC-10; FT-UP, FT-HP; MH09, MH10, MH33..MH38,
  MH42, MH43; Profile/Health API và Health database domain.
- Workout: UC-04..UC-07; FT-WO; MH11..MH19; Workout API và database domain.
- Nutrition: UC-08, UC-09; FT-MP; MH20..MH25, MH54; Food/Meal API và domain.
- Dashboard: UC-11; FT-DB; MH03; Dashboard API và cross-domain read model.
- AI: UC-12..UC-14, UC-17; FT-AI; MH27..MH32, MH55; AI public/internal API và
  AI Coach database domain.
- Admin/Media: UC-19, UC-21; FT-AD, FT-MD; MH45..MH51; Admin/Media API,
  Media và Audit database domain.
- Notification: FT-NT, MH40/MH41; P1/P2, không thuộc đường găng P0.

Khi thêm hoặc sửa feature, change phải cập nhật các mắt xích bị ảnh hưởng thay
vì chỉ cập nhật một tài liệu đơn lẻ.

---

## 15. Definition of Done của thiết kế

Tài liệu và implementation được xem là đồng bộ khi:

- Phạm vi không đưa Shop/Cart/Order/Payment vào MVP.
- P0, P1, P2/Future được đánh dấu nhất quán.
- Không có quyết định mở nào bị trình bày như đã chốt.
- Enum, state machine, API và database không mâu thuẫn nhau.
- Mỗi P0 vertical slice có owner, main flow, failure flow và transaction boundary.
- Mỗi private mutation có authentication, authorization và ownership guard.
- Mỗi AI flow có consent gate, context policy, output validation và fallback.
- Apply/Dismiss giữ quyền quyết định của User và mutation của Backend.
- Dashboard không trở thành owner của business data.
- Không giữ database transaction trong remote AI call dài.
- Link tới tài liệu owner hoạt động và không sao chép contract chi tiết không cần thiết.
- Unit, integration và E2E test truy được về requirement/feature tương ứng.
- Thay đổi boundary hoặc contract đi kèm ADR/migration và cập nhật traceability.

---

## 16. Hướng dẫn sử dụng tài liệu khi triển khai

Khi bắt đầu một feature:

1. Xác nhận priority và acceptance criteria trong SRS/feature breakdown.
2. Tìm vertical slice hoặc capability tương ứng trong tài liệu này.
3. Xác nhận owner/dependency trong System Architecture.
4. Đọc payload/error trong API Specification.
5. Đọc entity/constraint/transaction trong Database Schema.
6. Đọc screen state/navigation trong Screen Breakdown.
7. Kiểm tra quyết định mở; tạo ADR nếu implementation phụ thuộc vào lựa chọn đó.
8. Triển khai theo lát cắt Mobile → API → Domain → Data → Test.
9. Chạy test và cập nhật traceability nếu contract thay đổi.

`design.md` là bản đồ triển khai xuyên hệ thống. Tài liệu chuyên trách vẫn là
nguồn canonical cho chi tiết thuộc ownership của tài liệu đó.
