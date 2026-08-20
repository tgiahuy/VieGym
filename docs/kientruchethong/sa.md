# System Architecture — VieGym

> Kiến trúc hệ thống tổng quan và chi tiết cho ứng dụng quản lý luyện tập,
> dinh dưỡng, sức khỏe và AI Coach cá nhân hóa VieGym.
>
> **Phiên bản tài liệu:** 1.0 — 2026-08-19  
> **Nguồn sự thật:** [SRS v3.0](../spec/specs.md),
> [phân rã phân hệ](../spec/phan_ra_phan_he_he_thong.md),
> [luồng nghiệp vụ](../spec/bussiness_mainflow.md),
> [phân rã tính năng](../spec/phan_ra_tinh_nang.md),
> [phân rã màn hình](../spec/phan_ra_man_hinh.md) và
> [Tech Stack](../kientruchatang/techstack.md).

---

## 1. Mục tiêu và nguyên tắc kiến trúc

VieGym được thiết kế quanh ba luồng nghiệp vụ cốt lõi:

1. Theo dõi sức khỏe, luyện tập và dinh dưỡng trên ứng dụng di động.
2. Tổng hợp dữ liệu authoritative thành dashboard và các chỉ số tiến độ.
3. Dùng AI để diễn giải và đề xuất trong phạm vi người dùng đã đồng ý,
   nhưng không trao quyền thay đổi dữ liệu trực tiếp cho AI.

Nguyên tắc xuyên suốt của hệ thống:

> **Backend calculates. AI interprets and recommends. User decides.
> Backend executes.**

- Spring Boot Backend là **business authority** và là thành phần duy nhất
  thực thi mutation nghiệp vụ.
- PostgreSQL là **source of truth** cho dữ liệu người dùng, sức khỏe,
  luyện tập, dinh dưỡng, consent, recommendation và audit.
- Flutter chỉ giao tiếp với Spring Boot qua REST API `/api/v1`; không gọi
  FastAPI AI Service hoặc AI Provider trực tiếp.
- FastAPI AI Service là thành phần điều phối AI stateless; không truy cập
  PostgreSQL và không sở hữu business rule.
- Mọi private resource phải được kiểm tra authentication, authorization và
  ownership ở Backend. Guard trên mobile chỉ phục vụ trải nghiệm người dùng.
- Mỗi entity có một phân hệ sở hữu. Phân hệ khác chỉ đọc hoặc yêu cầu thay
  đổi thông qua service/use case của owner.
- P0 ưu tiên kiến trúc đơn giản, kiểm thử được và đủ cho demo; không tách
  microservice khi chưa có nhu cầu scale hoặc ownership độc lập.

---

## 2. High-Level Architecture

```text
┌──────────────────────────────────────────────────────────────────────────┐
│                         Flutter Mobile App                               │
│  Auth · Health · Workout · Nutrition · Dashboard · AI · Admin tối thiểu │
└────────────────────────────────┬─────────────────────────────────────────┘
                                 │ HTTPS + REST /api/v1
                                 │ JWT access token
                                 ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                    Spring Boot Modular Monolith                          │
│                                                                          │
│  Identity    Preference    Health       Workout       Nutrition          │
│  Dashboard   AI Backend    Admin/Audit  Media         Notification       │
│                                                                          │
│  Authorization · Ownership · Calculation · Validation · Transaction      │
└──────────────┬──────────────────────┬───────────────────────┬─────────────┘
               │ JDBC/JPA             │ internal HTTP         │ S3 API
               ▼                      ▼                       ▼
      ┌─────────────────┐    ┌──────────────────┐    ┌───────────────────┐
      │ PostgreSQL      │    │ FastAPI AI       │    │ Object Storage    │
      │ source of truth │    │ Service          │    │ media binary      │
      └─────────────────┘    │ stateless        │    └───────────────────┘
               ▲             └────────┬─────────┘
               │                      │ server-side provider SDK
      ┌────────┴────────┐             ▼
      │ Redis optional │    ┌──────────────────┐
      │ cache/rate limit│    │ AI Provider/LLM  │
      └─────────────────┘    └──────────────────┘
```

### 2.1. Trách nhiệm thành phần

| Thành phần | Trách nhiệm | Không chịu trách nhiệm |
|---|---|---|
| **Flutter Mobile** | UI, client state, secure token storage, route theo role, loading/empty/error/offline state | Tính metric authoritative, ownership enforcement, gọi AI Provider |
| **Spring Boot Backend** | REST API, auth, ownership, calculation, validation, transaction, AI context/rule, mutation và audit | LLM inference, lưu media binary |
| **PostgreSQL** | Dữ liệu nghiệp vụ, quan hệ, constraint, transaction và audit | Lưu binary media, cache duy nhất |
| **FastAPI AI Service** | Provider abstraction, prompt execution, structured output parsing và fallback | Đọc database, authorization, mutation nghiệp vụ |
| **AI Provider** | LLM inference | Quyết định business rule hoặc truy cập VieGym trực tiếp |
| **Object Storage** | Lưu ảnh/video và cấp object theo key | Lưu quyền truy cập hoặc metadata authoritative |
| **Redis** | Cache/rate limit khi có nhu cầu đo được | Lưu business state duy nhất |

### 2.2. Kiến trúc triển khai

- **Mobile:** Flutter/Dart, MVP ưu tiên Android; USER và Admin UI tối thiểu
  cùng một ứng dụng nhưng tách route/shell theo role.
- **Backend:** Java 21+ và Spring Boot 3.x dưới dạng modular monolith.
- **AI Service:** Python 3.12+ và FastAPI, chỉ cung cấp internal API cho
  Backend.
- **Data:** PostgreSQL 16+; schema được version hóa bằng Flyway.
- **Media:** S3-compatible object storage. Demo có thể dùng URL/asset hợp lệ
  nếu upload chưa hoàn thiện theo phạm vi SRS.
- **Runtime demo:** Docker Compose cho Backend, PostgreSQL, AI Service và các
  dịch vụ hỗ trợ được bật.

---

## 3. Architectural Style và Software Design Patterns

### 3.1. Modular Monolith cho Backend

Spring Boot được chia theo business capability thay vì gom toàn bộ
controller/service/repository của hệ thống vào các package kỹ thuật chung.
Mỗi module sở hữu entity, repository và business rule của mình.

```text
HTTP Controller
    ↓ request DTO + validation
Application/Use Case Service
    ↓ orchestration + transaction boundary
Domain Service
    ↓ business rule/calculation/state transition
Repository / External Port
    ↓
PostgreSQL / Object Storage / AI Service
```

Quy tắc phụ thuộc:

- Module khác không ghi trực tiếp repository của domain owner.
- Dashboard chỉ tổng hợp read model; không sở hữu mutation.
- AI Apply handler định tuyến proposal đến domain service tương ứng.
- `common` chỉ chứa concern thực sự dùng chung; không trở thành nơi chứa
  business logic không rõ owner.

### 3.2. Layered/Clean Boundary trong từng module

- **Presentation:** REST controller, request/response DTO và validation cú pháp.
- **Application:** use case, orchestration, authorization theo resource và
  transaction boundary.
- **Domain:** business rule, calculation, state machine và policy.
- **Infrastructure:** JPA repository, object storage adapter, AI client và
  provider-specific integration.

Không bắt buộc tạo tầng hoặc interface rỗng chỉ để đúng mẫu. Boundary được
tách khi giúp cô lập business rule hoặc external dependency để kiểm thử.

### 3.3. Adapter Pattern — External Services

Các phụ thuộc ngoài business core được đặt sau abstraction:

```text
AiProvider
  ├── OpenAiProviderAdapter      (nếu chọn OpenAI)
  └── GeminiProviderAdapter      (nếu chọn Google Gemini)

ObjectStorageService
  └── S3CompatibleStorageAdapter

Token/Identity Verification
  ├── LocalCredentialService
  └── GoogleIdentityVerifier
```

MVP chọn một AI provider mặc định qua cấu hình. Adapter provider còn lại chỉ
được triển khai khi có yêu cầu fallback/cost routing rõ ràng.

### 3.4. Strategy Pattern — Calculation, Rule và Proposal Routing

- Health calculation chọn rule theo giới tính, activity level và fitness goal.
- Rule Engine tạo signal cá nhân hóa theo loại dữ liệu: nutrition gap,
  workout today, adherence, weight trend hoặc preference conflict.
- Proposal dispatcher chọn đúng domain handler theo `allowedAction`.
- Media validation chọn policy theo owner type, MIME và visibility.

Các phép tính authoritative như BMI, BMR, TDEE, calorie/macro target,
workout volume, completion rate và meal total luôn chạy ở Backend.

### 3.5. State Machine

State transition được kiểm tra trong domain service, không để client tự set
trạng thái tùy ý.

```text
Account: PENDING --OTP verify--> ACTIVE

WorkoutSchedule:
PLANNED ──► COMPLETED | MISSED | CANCELLED

WorkoutSession:
IN_PROGRESS ──► PAUSED ──► IN_PROGRESS
          └──────────────► COMPLETED
IN_PROGRESS | PAUSED ────► DISCARDED

AiRecommendation:
PENDING ──► APPLIED | DISMISSED | EXPIRED
```

- Mỗi user có tối đa một active session; một schedule không được start lại.
- Finish session validate log, tính metric và cập nhật schedule trong cùng
  transaction.
- Recommendation chỉ được Apply/Dismiss khi `PENDING`, thuộc đúng user và
  chưa hết hạn.
- Apply là idempotent; `DISCARDED` session không tạo PR; `CANCELLED` schedule
  hợp lệ không tính vào mẫu số completion rate.

### 3.6. Transaction Boundary

- Luồng ghi một aggregate hoặc nhiều bản ghi liên quan chạy trong transaction
  Spring (`@Transactional`).
- Luồng đọc dùng read-only transaction khi phù hợp.
- Cập nhật Health Profile và tính lại metric/target là một transaction.
- Finish Workout Session tạo log, tính volume/PR và cập nhật schedule là một
  transaction.
- Apply recommendation validate lại proposal rồi mutation qua domain owner và
  ghi audit trong boundary nhất quán.
- Media binary và lời gọi AI là external side effect; không giả định chúng có
  thể rollback cùng PostgreSQL. Trạng thái và retry/fallback phải được quản lý
  rõ ở use case tương ứng.

### 3.7. Domain Event — Tùy chọn để giảm coupling

Các event nội bộ có thể dùng sau khi transaction thành công:

```text
WorkoutCompleted       ──► Dashboard invalidation / Notification P1
MealEntryChanged       ──► Dashboard invalidation / signal refresh
WeightLogged           ──► Trend refresh / signal refresh
RecommendationApplied ──► Audit / preference feedback
```

Event broker không phải dependency P0 đã chốt. Với MVP có thể dùng
application event in-process; chỉ đưa message broker vào khi có yêu cầu xử lý
bất đồng bộ, retry bền vững hoặc scale độc lập được chứng minh.

### 3.8. DTO Mapping và API Error

- Entity không được trả trực tiếp qua REST API.
- MapStruct là lựa chọn đề xuất cho Entity ↔ DTO.
- Request phải qua Bean Validation rồi mới đến business validation.
- Response envelope, pagination và error code chi tiết phải được khóa tại
  `API_SPEC.md`; SA không tự tạo contract chưa được chốt.

---

## 4. Phân rã phân hệ và quyền sở hữu

| ID | Phân hệ | Dữ liệu sở hữu chính | Trách nhiệm |
|---|---|---|---|
| **PH1** | Identity & Auth | `User`, `RefreshToken`, `OtpCode` | Register/OTP, login, Google Login, refresh, logout, password và role |
| **PH2** | User Profile & Preference | `UserProfile`, `UserPreference`, `UserEquipmentPreference` | Hồ sơ cơ bản, equipment, food/training preference và constraint |
| **PH3** | Health & Body | `HealthProfile`, `NutritionTarget`, `WeightLog` | Metric authoritative, target, cân nặng và trend |
| **PH4** | Workout | Exercise, Program, Schedule, Session và Log | Thư viện bài tập, lập lịch, ghi buổi tập, volume/completion/PR |
| **PH5** | Nutrition | `Food`, `MealPlan`, `Meal`, `MealEntry` | Món Việt, serving, meal plan, nutrition snapshot và daily total |
| **PH6** | Dashboard | Read model/aggregate | Tổng hợp Health, Workout, Nutrition và recommendation |
| **PH7** | AI Coach | Consent, Conversation, Context Snapshot, Recommendation | Context, rule, chat, daily recommendation, validation và Apply/Dismiss |
| **PH8** | Admin & Audit | `AuditLog`; metadata admin | Quản trị Exercise/Food P0 và truy vết mutation nhạy cảm |
| **PH9** | Media & Storage | `MediaObject` | Upload, MIME/size validation, access policy và orphan cleanup |
| **PH10** | Notification | `Notification`, `NotificationPreference` | Reminder/in-app notification P1; không phải source of truth |

### 4.1. Dependency Graph

```text
                              ┌──────────────────┐
                              │ PH1 Identity     │
                              └────────┬─────────┘
                                       │ identity/ownership
             ┌─────────────────────────┼──────────────────────────┐
             ▼                         ▼                          ▼
  ┌──────────────────┐      ┌──────────────────┐       ┌──────────────────┐
  │ PH2 Preference   │      │ PH3 Health      │       │ PH8 Admin/Audit  │
  └────────┬─────────┘      └────────┬─────────┘       └────────▲─────────┘
           │                         │                          │ audit
     ┌─────┴───────────┐      ┌──────┴──────────┐              │
     ▼                 ▼      ▼                 ▼              │
┌─────────────┐  ┌───────────────┐       ┌──────────────┐      │
│ PH4 Workout │  │ PH5 Nutrition │       │ PH9 Media    │──────┘
└──────┬──────┘  └───────┬───────┘       └──────────────┘
       └──────────┬───────┴───────────────┐
                  ▼                       ▼
         ┌────────────────┐      ┌────────────────┐
         │ PH6 Dashboard  │      │ PH7 AI Coach   │
         └────────────────┘      └───────┬────────┘
                                         │ optional event
                                         ▼
                                ┌──────────────────┐
                                │ PH10 Notification│
                                └──────────────────┘
```

### 4.2. Cross-module Rules

| Từ → Đến | Quy tắc |
|---|---|
| All → Identity | Lấy actor, role và ownership context đã xác thực |
| Workout → Preference | Đọc equipment/training preference; không sở hữu preference |
| Nutrition → Health | Đọc `NutritionTarget` authoritative |
| Nutrition → Preference | Áp dụng allergy, dislike và constraint trước suggestion |
| Workout/Nutrition → Media | Chỉ tham chiếu metadata/object key qua Media service |
| Dashboard → Domain modules | Chỉ tổng hợp read model; không mutation |
| AI Backend → Domain modules | Đọc context tối thiểu sau consent qua service/query đã authorize |
| AI Apply → Domain owner | Mutation qua đúng domain service sau user approval |
| Sensitive mutation → Audit | Ghi actor/action/target/result, không ghi secret/context thừa |

---

## 5. Các luồng kiến trúc chính

### 5.1. Register, OTP và Session

```text
Flutter
  │ register(email, password)
  ▼
Spring Boot Identity
  │ validate uniqueness + BCrypt hash
  │ create account PENDING + OTP hash/TTL/attempt
  ▼
OTP Verify
  │ validate purpose + expiry + attempt/cooldown
  │ activate account
  ▼
Issue access token + refresh session
```

- Account chưa verify không được cấp token nghiệp vụ.
- Register và password reset dùng OTP purpose riêng.
- Refresh token có expiry, revoke và rotation.
- Google identity token được verify server-side.
- Biometric chỉ mở credential local trong secure storage; biometric data không
  gửi lên server.
- Response cho forgot/reset không làm lộ email có tồn tại hay không.

### 5.2. Health Profile và Recalculation

```text
Health Profile Input
  ↓ syntax + range validation
HealthCalculationService
  ├── BMI
  ├── BMR (Mifflin-St Jeor)
  ├── TDEE
  └── calories/macro target theo goal
  ↓ business/safety validation
PostgreSQL transaction
  ├── HealthProfile
  └── NutritionTarget
```

- Thiếu dữ liệu bắt buộc thì không tính TDEE.
- Sửa chiều cao, cân nặng trong profile, activity hoặc goal phải tính lại
  metric/target trong transaction.
- Ghi `WeightLog` hằng ngày không tự thay đổi `NutritionTarget`.
- Flutter và AI chỉ hiển thị/diễn giải metric Backend đã tính.

### 5.3. Workout Session Lifecycle

```text
Schedule PLANNED
  ↓ start (ownership + one-active-session check)
Session IN_PROGRESS
  ├── pause/resume
  ├── record set/reps/weight/duration
  ├── discard ──► no WorkoutLog/PR
  └── finish
        ↓ validate complete payload
        ↓ calculate volume/completion/PR
        ↓ transaction: WorkoutLog + set logs + schedule COMPLETED
```

Exercise đã hidden vẫn được giữ trong lịch sử nhưng không được thêm vào
program mới.

### 5.4. Meal Planner và Nutrition Summary

```text
Food serving data + servingMultiplier
  ↓
MealEntry nutrition snapshot
  ↓
Daily aggregate: calories/protein/carbs/fat
  ↓
Compare with NutritionTarget
  ↓
Dashboard summary + Rule Engine candidate signals
```

- `MealEntry` lưu nutrition snapshot để lịch sử không thay đổi khi Food master
  data được cập nhật.
- Allergy và constraint của user có độ ưu tiên cao hơn tối ưu macro.
- Dữ liệu nutrition ước lượng phải được thể hiện là tham khảo.
- User chỉ truy cập Meal Plan/Entry của chính mình.

### 5.5. Media Upload

```text
Admin/authorized client
  │ POST /api/v1/media/upload-init
  ▼
Backend: authorize + validate owner/type/declared metadata
  │ return short-lived presigned URL (nếu dùng direct upload)
  ▼
Client ──PUT binary──► Object Storage
  │ upload-complete
  ▼
Backend: verify object + MIME thực tế + extension + size
  │ mark MediaObject available / attach to Exercise or Food
  ▼
Authorized access-url with TTL
```

- PostgreSQL chỉ lưu metadata và object key, không lưu binary.
- Backend xác thực quyền trước khi cấp upload/access URL.
- Object upload dở dang hoặc không còn reference được cleanup theo chính sách
  orphan; media còn được lịch sử tham chiếu phải được bảo toàn.
- Streaming/transcoding video nâng cao nằm ngoài MVP.

---

## 6. AI Architecture và Trust Boundary

### 6.1. AI Decision Pipeline

```text
Flutter request + JWT
        ↓
Spring Boot Authentication / Ownership
        ↓
Consent Check
  ┌─────┴────────────────────────────────────────────┐
  │ DISABLED                                        │ ENABLED
  ▼                                                 ▼
General Knowledge Mode                       Context Builder
không personal context                       whitelist + budget
không daily personalization                         ↓
                                               Rule Engine
                                         quyết định WHAT/signal
                                                    ↓
                                               Prompt Builder
                                                    ↓ internal HTTP
                                            FastAPI AI Service
                                                    ↓
                                             Provider Adapter
                                                    ↓
                                                LLM Provider
                                                    ↓
                                         Structured Output Parser
                                                    ↓
                              Schema → Business → Safety Validation
                                                    ↓
                                  Answer hoặc Recommendation PENDING
```

### 6.2. Responsibility Boundary

| Boundary | Quy tắc |
|---|---|
| Mobile → Backend | Gửi JWT và request; không chứa AI provider key |
| Backend → AI Service | Chỉ gửi context đã authorize, consent-check và tối thiểu hóa |
| AI Service → Provider | Gọi server-side qua provider abstraction, timeout hữu hạn |
| AI output → Backend | Xem là untrusted output; parse và validate đầy đủ |
| Backend → PostgreSQL | Chỉ Backend được mutation sau policy và user approval |

FastAPI không kết nối trực tiếp PostgreSQL. AI Service không được nhận
password, token, OTP, API key, dữ liệu user khác hoặc raw history không cần
thiết.

### 6.3. Context Builder

Context được chọn theo tác vụ, không gửi toàn bộ hồ sơ:

| Context type | Dữ liệu chính |
|---|---|
| `CHAT` | Tin nhắn gần đây, conversation summary và dữ liệu liên quan câu hỏi |
| `DAILY_RECOMMENDATION` | Rule signals, nutrition hôm nay, workout hôm nay/tiếp theo, trend, preference và candidate shortlist tối thiểu |
| `WEEKLY_REVIEW` | Chỉ aggregated weekly metrics — P1 |
| `PLAN_ADJUSTMENT` | Plan summary, target, trend và constraint — P1 |

Budget đề xuất theo SRS:

- Workout: 7–14 ngày gần nhất kèm summary.
- Weight: trend 7–30 ngày.
- Meal: hôm nay và summary gần đây.
- Conversation: recent messages và summary, không gửi toàn bộ lịch sử.

`AiContextSnapshot` có thể lưu version, type, generated time và data hash để
truy vết mà không nhân bản raw personal data dư thừa.

### 6.4. Rule Engine và Provider

> **Rule Engine quyết định WHAT. AI quyết định HOW.**

Rule Engine dựa trên dữ liệu Backend authoritative để tạo signal tối thiểu:

- `nutrition_protein_gap`
- `calories_over_target`
- `workout_today`
- `adherence_issue`
- `weight_trend_off_goal`
- `meal_logging_drop`
- `preference_conflict`

AI Provider chỉ diễn giải signal và tạo nội dung/proposal đúng schema. Business
logic không phụ thuộc trực tiếp SDK provider; AI Service cung cấp hai khả năng
trừu tượng `generateResponse` và `generateStructuredResponse`.

Spring Boot sở hữu Rule Engine, versioned Prompt Builder và render prompt cuối
cùng. FastAPI chỉ nhận request nội bộ đã render + schema/candidates, gọi provider
qua adapter và parse structured output; không tự bổ sung business rule.

### 6.5. Allowed Action Contract

AI chỉ được trả proposal thuộc whitelist:

```text
NONE
ADD_MEAL_ENTRY_PROPOSAL
CREATE_WORKOUT_SCHEDULE_PROPOSAL
UPDATE_USER_PREFERENCE_PROPOSAL
REVIEW_NUTRITION_TARGET_PROPOSAL
```

`LOG_REMINDER_ONLY` dành cho notification P1, không xuất hiện trong P0.
Proposal tạo meal/schedule bắt buộc có `targetDate` trong cửa sổ cho phép và chỉ
tham chiếu ID nằm trong candidate shortlist. Preference payload chỉ nhận key và
value trong whitelist đã version hóa.

```text
APPLY
User Approval
  → Ownership
  → PENDING + expiry + idempotency check
  → Schema/Business/Safety Validation
  → Domain Owner Mutation
  → Audit Log

DISMISS
Ownership
  → PENDING check
  → DISMISSED + optional feedback
  → không mutation Health/Workout/Nutrition
```

Proposal không được chứa SQL, endpoint command, credential hoặc field ngoài
whitelist. AI không tự gọi mutation endpoint.

### 6.6. AI Safety và Prompt Security

- User message, imported data, Food/Exercise text và conversation history đều
  là untrusted input.
- Prompt Builder phân vùng system instruction, context, rule signals, user
  message và output schema.
- User input không được override authorization, consent, safety hoặc business
  rule.
- AI không chẩn đoán, kê thuốc, cam kết điều trị hay khuyến nghị giảm cân cực
  đoan. Trường hợp y tế/chấn thương phải dùng safe response phù hợp.
- Provider failure/timeout dùng retry giới hạn và fallback an toàn; không để
  request treo vô hạn.
- Prompt template có version; provider secret chỉ tồn tại server-side qua
  environment/secret manager.
- Output `BLOCKED` chỉ tạo validation/telemetry đã redact và safe response; không
  persist thành `AiRecommendation`.

---

## 7. Data Architecture

### 7.1. PostgreSQL Source of Truth

```text
User
 ├── UserProfile / UserPreference / EquipmentPreference
 ├── HealthProfile ── NutritionTarget
 ├── WeightLog
 ├── WorkoutProgram ── WorkoutDay ── WorkoutExercise
 ├── WorkoutSchedule ── WorkoutSession ── WorkoutLog/SetLog
 ├── MealPlan ── Meal ── MealEntry(snapshot)
 ├── AiConsentSetting / AiConsentHistory
 ├── AiConversation ── AiMessage / AiConversationSummary
 └── AiRecommendation ── AiRecommendationLog

Exercise ── MuscleGroup / Equipment / MediaObject
Food ── MediaObject
Sensitive mutation ── AuditLog
```

Nguyên tắc dữ liệu:

- Schema, constraint và index được quản lý bằng Flyway; không dùng ORM auto
  update schema ở production.
- Private entity luôn có `user_id` hoặc ownership relation rõ ràng.
- Foreign key, unique constraint và state constraint bảo vệ invariant ở tầng
  database khi phù hợp.
- Exercise/Food bị ẩn dùng soft delete/visibility để bảo toàn lịch sử.
- Các record phụ thuộc master data có thể thay đổi, đặc biệt `MealEntry`, phải
  lưu snapshot cần thiết.
- Timestamp lưu UTC; API/UI chuyển đổi theo timezone người dùng. Unit sức khỏe
  được chuẩn hóa trước khi tính toán/lưu authoritative value.
- Field-level schema và index chi tiết thuộc `DATABASE.md`, không lặp lại hoặc
  tự chốt tại SA.

### 7.2. Consistency

- PostgreSQL quyết định trạng thái nghiệp vụ; cache và object storage không
  được dùng làm nguồn sự thật cho quyền hoặc ownership.
- Dashboard đọc dữ liệu đã commit từ các domain owner.
- Sau khi dữ liệu thay đổi, cache/read model liên quan phải invalidated hoặc
  recompute từ PostgreSQL.
- External calls không nằm trong distributed transaction. Khi AI hoặc storage
  lỗi, Backend giữ trạng thái có thể retry/fallback thay vì giả định rollback
  xuyên dịch vụ.
- Apply recommendation phải kiểm tra lại dữ liệu hiện tại; không tin hoàn toàn
  context snapshot đã dùng để sinh proposal.

### 7.3. Redis — Optional

Redis 7+ chỉ thêm khi có bottleneck hoặc nhu cầu TTL/counter rõ ràng:

| Nhóm key đề xuất | Mục đích | Invalidation/TTL |
|---|---|---|
| Reference data | Exercise/Food/equipment đọc nhiều | TTL ngắn + evict khi Admin sửa |
| Dashboard summary | Giảm aggregate lặp lại | TTL ngắn + evict theo domain event |
| OTP/login counters | Rate limit phân tán | TTL theo security policy |

Nếu chưa dùng Redis, OTP/login rate limit có thể bắt đầu bằng PostgreSQL.
Redis mất dữ liệu không được làm mất session/business record authoritative.

### 7.4. Object Storage

- Binary ảnh/video nằm trong S3-compatible object storage; database giữ object
  key, MIME, size, owner, visibility và status.
- Object key không phải bằng chứng authorization.
- Presigned URL có TTL ngắn và chỉ được cấp sau access-policy check.
- MIME thực tế được kiểm tra, không chỉ tin extension hoặc client header.
- Production có thể đặt CDN trước object storage cho public media hợp lệ.

---

## 8. API và Integration Architecture

### 8.1. Public API Boundary

- Mobile chỉ gọi Spring Boot qua HTTPS và prefix `/api/v1`.
- Private endpoint yêu cầu JWT hợp lệ; Backend kiểm tra role và ownership.
- Request/response dùng JSON, trừ luồng upload trực tiếp tới presigned URL.
- OpenAPI/Swagger được sinh bằng `springdoc-openapi` cho demo và contract review.
- Flutter client được generate bằng OpenAPI Generator `dart-dio`, pin cùng một
  version trong local/CI; CI fail nếu generate lại tạo diff chưa commit.
- Pagination, response envelope, validation error và business error phải thống
  nhất trong `API_SPEC.md` trước khi implementation.

### 8.2. API Groups

```text
/api/v1/auth/**                    PH1 Identity
/api/v1/users/me                   PH2 Profile
/api/v1/preferences/**             PH2 Preference
/api/v1/health/**                  PH3 Health
/api/v1/weight-logs/**             PH3 Body Tracking
/api/v1/exercises/**               PH4 Exercise Catalog
/api/v1/workout-*/**               PH4 Workout
/api/v1/foods/**                   PH5 Food Catalog
/api/v1/meal-plans/**              PH5 Nutrition
/api/v1/dashboard                  PH6 Dashboard
/api/v1/ai/**                      PH7 AI Coach
/api/v1/admin/**                   PH8 Admin/Audit
/api/v1/media/**                   PH9 Media
/api/v1/notifications/**           PH10 Notification — P1
```

### 8.3. Internal AI API

- Chỉ Spring Boot được phép gọi FastAPI trong MVP.
- Internal request dùng schema versioned và correlation ID.
- Network policy/deployment không public expose AI Service.
- Backend đặt connect/read timeout, retry hữu hạn và circuit breaker khi cần.
- AI response luôn được Backend parse và validate trước khi trả client hoặc lưu
  recommendation.

### 8.4. Validation Pipeline

```text
HTTP Request
  ↓ DTO/Bean Validation
Authentication
  ↓ Role + Ownership Policy
Business Validation
  ↓ State transition / invariant / safety rule
Transaction / External Adapter
  ↓
Response DTO hoặc error chuẩn hóa
```

Đối với AI, pipeline bổ sung consent, context minimization và
schema/business/safety validation. Đối với media, pipeline bổ sung MIME, size,
extension, object existence và visibility policy.

---

## 9. Security, Authorization và Privacy

### 9.1. Authentication

- Local password được hash bằng BCrypt; không lưu plaintext.
- Access token được Spring Security OAuth2 Resource Server/JOSE JWT validate.
- Refresh token có expiry, revoke và rotation; logout revoke đúng session.
- OTP lưu dạng được bảo vệ, có purpose, TTL, attempts, resend cooldown và rate
  limit.
- Google token được verify server-side trước khi liên kết/cấp phiên.
- Token/session credential trên mobile nằm trong `flutter_secure_storage`,
  không lưu trong `shared_preferences`.

### 9.2. Authorization Matrix

| Resource/Action | USER | ADMIN |
|---|---|---|
| Hồ sơ, Health, Workout, Meal, Weight của chính mình | Read/Write theo use case | Chỉ khi endpoint/policy cho phép; không mặc định đọc dữ liệu riêng tư |
| Exercise/Food active | Read | Read/CRUD/Hide |
| AI Consent/Conversation/Recommendation của chính mình | Read/Write theo workflow | Không mặc định truy cập nội dung riêng tư |
| Apply/Dismiss recommendation | Chỉ resource của chính mình | Không Apply thay user |
| Audit Log | Không | Read theo phạm vi Admin |
| Admin Exercise/Food API | Không | Có |
| Admin User/Import/AI Rule/Prompt | Không | P1 |

Role check không thay thế ownership check. Mọi query private resource phải
scope theo actor hiện tại trước khi trả dữ liệu hoặc thực hiện mutation.

### 9.3. Secret và Log Hygiene

Không log hoặc đưa vào audit:

- Password/password hash, access token, refresh token và OTP.
- AI provider key hoặc credential hạ tầng.
- Raw health profile, AI context hoặc conversation dư thừa.
- Presigned URL còn hiệu lực nếu không cần thiết cho chẩn đoán.

Repository chỉ giữ `.env.example`; secret được truyền qua environment/secret
manager. Log và audit chỉ giữ dữ liệu tối thiểu phục vụ vận hành/truy vết.

### 9.4. AI Consent và Data Minimization

- Consent được kiểm tra trước Context Builder.
- Khi consent `DISABLED`, AI chỉ chạy General Knowledge Mode, không dùng dữ
  liệu Health/Workout/Nutrition/Weight/Preference cá nhân và không tạo Daily
  Recommendation cá nhân hóa.
- Lưu consent version/history để truy vết enable, disable hoặc revoke.
- User có thể tắt personalization; request mới phải áp dụng trạng thái mới.
- Context chỉ gồm field cần cho tác vụ và không chứa dữ liệu của user khác.

---

## 10. Performance, Reliability và Caching

### 10.1. Mục tiêu

- P95 cho Health Metrics, Exercise list, Food list, Weight Trend và Dashboard
  dưới 500 ms, error rate dưới 1%, không tính thời gian AI Provider. Benchmark
  chuẩn dùng Docker Compose 4 vCPU/8 GB, 100 user, 40 Exercise, 80 Food, 90 ngày
  dữ liệu cho user đo, 10 virtual users, warm-up 2 phút và đo 5 phút; báo cáo
  phải lưu P50/P95/error rate, commit, máy và dataset.
- AI timeout/failure phải trả fallback an toàn, không làm hỏng dữ liệu domain.
- Database constraint và transaction bảo vệ các invariant quan trọng.
- Core business vẫn hoạt động khi Redis không được triển khai hoặc cache bị mất.

### 10.2. Database Performance

- Tạo B-tree index cho foreign key, ownership/filter thường dùng và các cột
  ngày/trạng thái theo query thực tế.
- Dùng pagination cho Exercise, Food, Workout Log, Weight Log, Conversation và
  Audit Log.
- Dashboard và GET Daily Recommendation chỉ đọc dữ liệu đã commit, tuyệt đối
  không gọi provider hoặc tạo bản ghi. Generation chỉ chạy qua POST command.
- Dashboard aggregate theo user và khoảng thời gian; chỉ thêm cache/materialized
  read model khi profiling chứng minh cần thiết.
- Tránh N+1 query qua query projection/entity graph phù hợp; không serialize
  trực tiếp graph JPA.

### 10.3. AI Resilience

```text
Backend AI Client
  ├── connect/read timeout hữu hạn
  ├── retry giới hạn cho lỗi tạm thời
  ├── circuit breaker khi cần
  └── safe fallback/error code
```

- Không retry vô hạn hoặc retry action có nguy cơ tạo trùng.
- Structured response phải parse được schema; output lỗi bị reject, không cố
  mutation.
- Recommendation Apply dựa trên idempotency/state check ở Backend, không dựa
  vào độ tin cậy của provider.
- Provider smoke test tách khỏi CI mặc định để kiểm soát quota và secret.

### 10.4. Background Jobs

Không có background job nào là dependency bắt buộc cho core P0. Các job có thể
bổ sung theo phạm vi triển khai:

| Job | Mục đích | Phạm vi |
|---|---|---|
| Expire recommendation | Chuyển `PENDING` quá `expires_at` thành `EXPIRED` | P0 hoặc lazy-on-read/apply |
| Mark missed schedule | Lazy materialize sau cutoff + grace theo profile timezone; bỏ qua session active | P0 authoritative |
| Orphan media cleanup | Xóa object upload dở dang/không còn reference | P0 hardening |
| Conversation summary | Giới hạn context budget | P0/P1 theo dung lượng chat |
| Notification scheduler | Reminder workout/meal/weight | P1 |
| Weekly Review | Tạo aggregate/review tuần | P1 |

Trong môi trường nhiều instance, scheduled job cần cơ chế single-execution hoặc
idempotency trước khi scale ngang.

---

## 11. Observability và Audit

### 11.1. Logging và Correlation

- Log JSON có timestamp, level, service, correlation/request ID và error code.
- Correlation ID được truyền từ Spring Boot sang FastAPI và provider adapter khi
  có thể.
- Không log payload nhạy cảm; dùng ID/hash/metadata tối thiểu để truy vết.
- Phân biệt latency của Backend, AI Service và AI Provider.

### 11.2. Health và Metrics

- Spring Actuator cung cấp liveness/readiness cho Backend.
- FastAPI cung cấp `/health` nội bộ.
- Theo dõi database pool, API latency/error, AI timeout/parse/safety failure,
  upload failure và authentication rate-limit event.
- Object storage, AI Provider hoặc Redis không sẵn sàng phải phản ánh đúng ở
  readiness/degraded status theo mức ảnh hưởng.

### 11.3. Audit

Audit tối thiểu ghi:

```text
actorId · actorRole · action · targetType · targetId
result · timestamp · correlationId
```

Các thao tác cần audit gồm mutation Admin, thay đổi consent, security-sensitive
account action và Apply recommendation. Audit không lưu secret hoặc raw context
cá nhân dư thừa.

---

## 12. Backend và AI Package Structure

### 12.1. Spring Boot Backend

```text
backend/
├── src/main/java/com/viegym/
│   ├── ViegymApplication.java
│   ├── identity/                     ← PH1
│   ├── preference/                   ← PH2
│   ├── health/                       ← PH3
│   ├── workout/                      ← PH4
│   │   ├── exercise/
│   │   ├── program/
│   │   ├── schedule/
│   │   ├── session/
│   │   └── log/
│   ├── nutrition/                    ← PH5
│   ├── dashboard/                    ← PH6 read model
│   ├── ai/                           ← PH7 Backend orchestration
│   │   ├── consent/
│   │   ├── context/
│   │   ├── rule/
│   │   ├── conversation/
│   │   ├── recommendation/
│   │   └── validation/
│   ├── admin/                        ← PH8 use cases
│   ├── audit/                        ← PH8 audit
│   ├── media/                        ← PH9
│   ├── notification/                 ← PH10 P1
│   └── common/
│       ├── config/
│       ├── dto/
│       ├── exception/
│       └── security/
├── src/main/resources/
│   ├── db/migration/
│   ├── application.yml
│   ├── application-local.yml
│   └── application-prod.yml
├── src/test/
├── pom.xml
└── Dockerfile
```

Trong mỗi module, có thể tách `controller`, `service`, `entity`, `repository`,
`dto` và `mapper`. Chỉ tách sâu hơn khi complexity thực tế yêu cầu.

### 12.2. FastAPI AI Service

```text
ai-service/
├── app/
│   ├── main.py
│   ├── api/                           ← internal endpoints
│   ├── schemas/                       ← versioned input/output
│   ├── providers/                     ← provider adapters
│   ├── prompts/                       ← versioned templates
│   ├── validators/                    ← output/safety helpers
│   └── core/                          ← config, timeout, retry, logging
├── tests/
├── pyproject.toml
├── uv.lock hoặc poetry.lock           ← chọn một
└── Dockerfile
```

### 12.3. Flutter Mobile

```text
mobile/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── config/
│   │   ├── network/
│   │   ├── storage/
│   │   ├── theme/
│   │   └── widgets/
│   ├── features/
│   │   ├── auth/ · profile/ · health/ · workout/
│   │   ├── nutrition/ · dashboard/ · ai_coach/
│   │   └── media/ · notification/ · admin/
│   └── router/
├── test/
├── integration_test/
└── pubspec.yaml
```

State-management package chưa được tài liệu nguồn chốt. Khi bootstrap phải
chọn một giải pháp, ghi ADR và dùng nhất quán; không duy trì nhiều pattern state
song song.

---

## 13. Deployment Architecture

### 13.1. Local/Demo

```text
Flutter App trên emulator/device
        │
        ▼
docker-compose.yml
├── backend            Spring Boot API
├── ai-service         FastAPI internal service
├── postgres           business database
├── object-storage     nếu dùng upload media
└── redis              optional profile
        │
        └── AI Service ──HTTPS──► External AI Provider
```

- Chỉ Backend và endpoint cần cho demo được expose ra host.
- PostgreSQL, Redis, object storage admin port và AI Service ưu tiên internal
  network.
- Cấu hình URL/credential qua environment; dùng `.env.example` không chứa
  secret.
- Migration chạy có kiểm soát trước khi Backend nhận traffic.

### 13.2. Production Direction

```text
Mobile
  ↓ HTTPS
Load Balancer / API Gateway
  ↓
Spring Boot instances
  ├── PostgreSQL managed/HA
  ├── Object Storage + CDN
  ├── Redis optional
  └── FastAPI AI instances ──► AI Provider
```

Backend và AI Service có thể scale ngang khi đã externalize config/session và
đảm bảo scheduled task/idempotency. Database, connection pool, provider quota và
cost là các giới hạn phải đo trước khi tăng số instance.

### 13.3. CI/CD Pipeline

```text
Lint / Format
      ↓
Unit Test: Flutter + Backend + AI Service
      ↓
Integration Test: PostgreSQL + Object Storage nếu dùng
      ↓
Build Flutter APK + Backend/AI Docker Images
      ↓
Migration Check + Docker Compose Smoke Test + OpenAPI Check
```

Version Java, Flutter, Python, PostgreSQL và dependency phải được pin thống nhất
giữa local, CI và container.

---

## 14. Testing Strategy

### 14.1. Unit Test

- Health: BMI, BMR, TDEE, calorie/macro và boundary validation.
- Workout: state transition, volume, completion rate và PR.
- Nutrition: serving multiplier, snapshot, daily total và remaining target.
- AI Backend: consent, context whitelist/budget, Rule Engine, proposal routing,
  allowed action, idempotency và safety validation.
- Identity: OTP TTL/attempt/cooldown, token revoke/rotation và account state.

### 14.2. Integration/API Test

- Dùng Testcontainers PostgreSQL cho migration, constraint và transaction;
  không thay hành vi PostgreSQL bằng H2 ở test phụ thuộc database.
- Kiểm tra JWT, role và ownership trên mọi private resource.
- Kiểm tra finish workout, Health recalculation và recommendation Apply/Dismiss
  qua transaction thật.
- Kiểm tra upload MIME/size/access policy và orphan handling với object storage
  container nếu media upload được bật.
- Mock AI Provider để kiểm tra timeout, retry, invalid schema và fallback.

### 14.3. E2E MVP

```text
Register/Login
  → OTP/Session
  → Health Profile + authoritative metrics
  → Equipment Preference
  → Workout Program/Schedule/Session/Log
  → Meal Planner
  → Dashboard
  → AI Consent
  → AI Coach
  → Daily Recommendation
  → Apply/Dismiss
```

Các nhánh lỗi bắt buộc gồm consent OFF, ownership violation, OTP hết hạn,
provider failure, invalid AI output, workout state không hợp lệ và media sai
MIME/size.

---

## 15. Scalability và Release Scope

### 15.1. Scalability Direction

| Giai đoạn | Kiến trúc | Hướng mở rộng |
|---|---|---|
| **MVP/Demo** | Flutter + Spring modular monolith + PostgreSQL + FastAPI; Docker Compose | Index đúng query, transaction rõ, AI timeout/fallback, object storage khi cần |
| **Production ban đầu** | Nhiều instance stateless, managed PostgreSQL/object storage, Redis tùy nhu cầu | Load balancer, CDN, connection pooling, metric/alert và scheduled-job coordination |
| **Scale lớn** | Chỉ tách service theo bottleneck/ownership đã đo | Read model, async event/broker, partition workload AI/media, database HA |

Microservice, message broker, Kubernetes hoặc database bổ sung không thuộc kiến
trúc P0 đã chốt. Chỉ thêm bằng ADR khi có yêu cầu vận hành và số liệu chứng minh.

### 15.2. P0 — Bắt buộc

- PH1 Identity & Auth.
- PH2 User Profile & Preference.
- PH3 Health calculation và Weight Tracking.
- PH4 Exercise, Program, Schedule, Session và Log.
- PH5 Food Database và Meal Planner.
- PH6 Dashboard user.
- PH7 AI Consent, Context, Coach, Recommendation và Apply/Dismiss.
- PH8 Admin Exercise/Food và audit tối thiểu.
- PH9 Exercise/Food media baseline hoặc URL/asset demo hợp lệ theo SRS.
- Security, ownership, privacy và AI no-auto-mutation baseline.

### 15.3. P1

- Weekly Review, Preference Memory và Plan Adjustment Proposal.
- Admin User, import preview/validation, AI Rule/Prompt và metrics.
- Admin Dashboard.
- Local/in-app Notification.

### 15.4. P2/Future

- Push notification/automation và offline queue nâng cao.
- Shop/Marketplace, Cart/Order/Payment và supplement ecosystem.
- Wearable, Apple Health/Google Fit.
- Food image recognition, pose estimation/computer vision và ML prediction.
- AI tự động thay đổi kế hoạch không có user approval luôn nằm ngoài phạm vi.

---

## 16. Các quyết định bootstrap đã khóa

Các quyết định chặn M1/M2 đã được chấp nhận ngày 2026-08-19:

1. `flutter_riverpod` — ADR-001.
2. OpenAI Responses API và `gpt-5.6-luna` — ADR-002.
3. MinIO local/demo và Amazon S3 production — ADR-003.
4. Refresh token trong secure storage, access token trong memory — ADR-004.
5. Resend/fake adapter và policy OTP/PostgreSQL counter — ADR-005.
6. Media allowlist Exercise/Food — ADR-006.
7. Lazy-on-read/lazy-on-command cho recommendation/schedule expiry — ADR-007.
8. Response envelope, pagination, error code và idempotency đã được khóa tại
   `API_SPEC.md`.

Mỗi ADR ghi context, lựa chọn, phương án bị loại, hệ quả, owner và ngày áp
dụng. Các quyết định này không làm thay đổi các boundary cốt lõi:
Backend là business authority, PostgreSQL là source of truth, AI không mutation
và user là người quyết định cuối cùng.

---

## 17. Traceability

| Kiến trúc | Tài liệu nguồn |
|---|---|
| High-level components và responsibility boundary | `specs.md` §19–23; `techstack.md` §2–8 |
| 10 phân hệ và dependency graph | `phan_ra_phan_he_he_thong.md` |
| Auth, Health, Workout, Meal và AI lifecycle | `bussiness_mainflow.md` |
| P0/P1/P2 và allowed action | `specs.md`; `phan_ra_tinh_nang.md` |
| Mobile route/UI boundary và Admin shell | `phan_ra_man_hinh.md` |
| Runtime, testing và compatibility baseline | `techstack.md` |

Chi tiết field/table/index thuộc `DATABASE.md`; chi tiết request/response/error
thuộc `API_SPEC.md`; cấu hình hạ tầng triển khai thuộc `server.md`. Khi các tài
liệu này được hoàn thiện, chúng phải tuân thủ boundary và nguyên tắc trong SA,
đồng thời không thay đổi yêu cầu nghiệp vụ đã chốt trong SRS nếu chưa có ADR và
cập nhật traceability tương ứng.
