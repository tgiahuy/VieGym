# Phân Rã Phân Hệ Hệ Thống — VieGym

> Mô tả cách VieGym được phân rã thành các phân hệ, trách nhiệm, dữ liệu
> sở hữu, API boundary và quan hệ phụ thuộc.
>
> **Nguồn:** `specs.md` v3.2 và `bussiness_mainflow.md` v3.2
> **Phiên bản:** 3.2 — 2026-08-31

---

## Tổng quan phân hệ

VieGym gồm **10 phân hệ triển khai chính**:

```text
┌────────────────────────────────────────────────────────────────────────────┐
│                              HỆ THỐNG VIEGYM                               │
│                                                                            │
│  PH1 Identity      PH2 User Preference       PH3 Health & Body             │
│       │                    │                        │                       │
│       └────────────┬───────┴────────────┬───────────┘                       │
│                    ▼                    ▼                                  │
│              PH4 Workout         PH5 Nutrition                            │
│                    └──────────┬─────────┘                                  │
│                               ▼                                            │
│                      PH6 Dashboard                                         │
│                               ▲                                            │
│  PH9 Media ──→ Workout/Nutrition ──→ PH7 AI Coach ──→ PH10 Notification   │
│                               │                                            │
│                               └────────→ PH8 Admin & Audit                  │
└────────────────────────────────────────────────────────────────────────────┘
```

Nguyên tắc xuyên suốt:

> **Backend calculates. AI interprets and recommends. User decides.
> Backend executes.**

- Spring Boot Backend là business authority và source of truth.
- Flutter chỉ gọi Backend qua `/api/v1`, không gọi trực tiếp AI Service.
- AI Service không truy cập PostgreSQL và không tự mutation dữ liệu.
- Mỗi entity có một subsystem owner; module khác dùng qua service/API
  hoặc context được kiểm soát.
- Private resource phải kiểm tra authentication, authorization và
  ownership ở Backend.
- Shop/Marketplace, Cart/Order/Payment và Sales AI không thuộc MVP.

---

## PH1: Identity & Auth — Danh tính và Xác thực

### Mô tả

Quản lý tài khoản, xác thực, phiên đăng nhập và role. PH1 cung cấp
identity cho toàn hệ thống nhưng không sở hữu dữ liệu nghiệp vụ khác.

### Entities

| Entity | Mô tả |
|---|---|
| `User` | Email, password hash, provider, role và trạng thái |
| `RefreshToken` | Phiên có expiry, revoke và bắt buộc rotation khi refresh |
| `OtpCode` | OTP theo purpose, expiry, attempts và cooldown |

### Chức năng chính

- Đăng ký local, email duy nhất và password hash — P0.
- Register + OTP: account `PENDING` → verify → activate → cấp token — P0.
- Login, logout, refresh và revoke session — P0.
- Google/Facebook Login verify server-side — P0.
- Forgot/Reset Password bằng OTP purpose riêng — P0.
- Biometric chỉ mở local session/token trong secure storage — P0.
- Role `USER`/`ADMIN`, locked/disabled và ownership baseline — P0.

### API Endpoints

| Method | Endpoint | Mô tả |
|---|---|---|
| POST | `/api/v1/auth/register` | Tạo account pending và gửi OTP |
| POST | `/api/v1/auth/otp/verify` | Verify OTP theo purpose |
| POST | `/api/v1/auth/otp/resend` | Resend theo cooldown/rate limit |
| POST | `/api/v1/auth/login` | Đăng nhập local |
| POST | `/api/v1/auth/google` | Google Login server-side |
| POST | `/api/v1/auth/facebook` | Facebook Login server-side |
| POST | `/api/v1/auth/refresh` | Làm mới/rotation token |
| POST | `/api/v1/auth/logout` | Revoke phiên |
| POST | `/api/v1/auth/password/forgot` | Khởi tạo reset password |
| POST | `/api/v1/auth/password/reset` | Đặt mật khẩu mới |

### Sub-components

```text
Identity & Auth
  ├── AuthenticationService
  ├── TokenService
  ├── OtpService
  ├── PasswordResetService
  └── AuthorizationService
```

### Business rules

- Account chưa verify không được cấp token nghiệp vụ.
- Không làm lộ email tồn tại qua lỗi OTP/reset.
- Không log password, refresh token, OTP hoặc credential plaintext.
- Private API yêu cầu JWT; ADMIN chỉ truy cập API được cấp phép.

---

## PH2: User Profile & Preference — Hồ sơ và Sở thích

### Mô tả

Quản lý hồ sơ cơ bản và preference do user khai báo. PH2 sở hữu
equipment, food/training preference và constraints; Workout, Nutrition
và AI chỉ là consumer.

### Entities

| Entity | Mô tả |
|---|---|
| `UserProfile` | Thông tin cơ bản không thuộc Health Profile |
| `UserPreference` | Dislikes, meal/training preference và constraints |
| `UserEquipmentPreference` | Thiết bị user có thể sử dụng |

### Chức năng chính

- Xem/cập nhật hồ sơ cơ bản — P0.
- Chọn equipment khi onboarding/lần đầu cần và sửa trong Settings — P0.
- Lưu món không thích, dị ứng/ràng buộc user khai báo — P0.
- Lưu thời gian tập, meal preference và lịch ưu tiên — P0.
- Lưu Apply/Dismiss feedback làm tín hiệu preference phù hợp — P0.
- Preference Memory nâng cao — P1.

### API Endpoints

| Method | Endpoint | Mô tả |
|---|---|---|
| GET/PUT | `/api/v1/users/me` | Xem/sửa profile cơ bản |
| GET/PUT | `/api/v1/preferences` | Xem/sửa preference |
| GET/PUT | `/api/v1/preferences/equipment` | Available equipment |

### Business rules

- Dị ứng/ràng buộc ưu tiên hơn recommendation tối ưu macro.
- User không phải chọn lại equipment ở mỗi buổi tập.
- AI không sở hữu và không tự cập nhật preference.
- Proposal cập nhật preference cần user APPLY và Backend validation.

---

## PH3: Health Profile & Body Tracking — Sức khỏe và Cơ thể

### Mô tả

Quản lý Health Profile, phép tính authoritative, Nutrition Target,
Weight Log và trend cho Nutrition, Dashboard và AI Context.

### Entities

| Entity | Mô tả |
|---|---|
| `HealthProfile` | Tuổi, giới tính, chiều cao, cân nặng, activity, goal, experience |
| `NutritionTarget` | Calories, protein, carbohydrate và fat target |
| `WeightLog` | Lịch sử cân nặng theo ngày |

### Chức năng chính

- Onboarding Health Profile và validation — P0.
- Tính BMI, BMR Mifflin-St Jeor, TDEE, calorie/macro target — P0.
- Xem/sửa Health Profile và recalculation ở Backend — P0.
- WeightLog ban đầu và lịch sử cân nặng — P0.
- Weight trend/summary 7–30 ngày — P0.

### API Endpoints

| Method | Endpoint | Mô tả |
|---|---|---|
| GET/POST/PUT | `/api/v1/health/profile` | Tạo, xem, cập nhật profile |
| GET | `/api/v1/health/metrics` | Metric authoritative hiện tại |
| GET | `/api/v1/weight-logs` | Lịch sử cân nặng |
| PUT | `/api/v1/weight-logs/{loggedDate}` | Upsert theo ngày nghiệp vụ |
| GET | `/api/v1/weight-logs/trend` | Trend do Backend tính |

### Sub-components

```text
Health & Body
  ├── HealthProfileService
  ├── HealthCalculationService
  ├── NutritionTargetService
  └── WeightTrackingService
```

### Business rules

- Thiếu dữ liệu bắt buộc thì không tính TDEE.
- Mobile và AI không tự tính metric authoritative.
- Sửa chiều cao, cân nặng trong profile, activity hoặc goal phải tính
  lại metric/target trong transaction hợp lệ.
- WeightLog mới nhất đồng bộ current weight và tính lại BMI/BMR/TDEE trong transaction; không tự thay đổi NutritionTarget.
- User chỉ truy cập Health resource của chính mình.

---

## PH4: Workout — Quản lý Luyện tập (Core Domain)

### Mô tả

Quản lý Exercise Library, Workout Program, Schedule, Session và Log từ
lúc chọn bài đến khi hoàn thành và tổng hợp tiến độ.

### Entities

| Entity | Mô tả |
|---|---|
| `Exercise` | Bài tập, difficulty, instruction, mistakes, safety, media |
| `MuscleGroup` | Nhóm cơ chính/phụ |
| `Equipment` | Thiết bị của bài tập |
| `WorkoutProgram` | Chương trình của user |
| `WorkoutDay` | Buổi/ngày trong chương trình |
| `WorkoutExercise` | Bài, sets, reps, rest và note |
| `WorkoutSchedule` | Lịch và trạng thái kế hoạch |
| `WorkoutSession` | Start/Pause/Resume/Finish |
| `WorkoutLog` | Kết quả buổi tập |
| `WorkoutExerciseLog` | Kết quả theo bài |
| `WorkoutSetLog` | Set/reps/weight thực tế |

### Chức năng chính

- Tìm/lọc Exercise theo tên, muscle, equipment, difficulty — P0.
- Xem video, steps, common mistakes và safety notes — P0.
- Ưu tiên bài phù hợp equipment preference — P0.
- Tạo PPL, Upper/Lower, Full Body hoặc Custom Program — P0.
- Tạo Schedule thủ công hoặc từ Program — P0.
- Start, Pause, Resume, Finish, Discard Session — P0.
- Ghi set/reps/weight/duration — P0.
- Backend tính volume, completion rate và PR — P0.

### API Endpoints

| Method | Endpoint | Mô tả |
|---|---|---|
| GET | `/api/v1/exercises` | Danh sách/tìm/lọc Exercise |
| GET | `/api/v1/exercises/{id}` | Chi tiết Exercise |
| GET | `/api/v1/exercises/{id}/alternatives` | Bài thay thế cùng nhóm cơ |
| GET | `/api/v1/muscle-groups` | Catalog nhóm cơ |
| GET | `/api/v1/equipment` | Catalog thiết bị |
| GET/POST/PUT/DELETE | `/api/v1/workout-programs` | Program thuộc user |
| GET/POST/PUT/DELETE | `/api/v1/workout-schedules` | Lịch tập |
| POST | `/api/v1/workout-sessions/{scheduleId}/start` | Bắt đầu session |
| POST | `/api/v1/workout-sessions/{id}/pause` | Tạm dừng |
| POST | `/api/v1/workout-sessions/{id}/resume` | Tiếp tục |
| POST | `/api/v1/workout-sessions/{id}/finish` | Hoàn thành/tạo log |
| POST | `/api/v1/workout-sessions/{id}/discard` | Hủy session |
| GET | `/api/v1/workout-logs` | Lịch sử và tiến độ |
| GET | `/api/v1/workout-logs/{id}` | Chi tiết log |
| GET | `/api/v1/personal-records` | PR authoritative |

### Sub-components

```text
Workout
  ├── ExerciseCatalogService
  ├── EquipmentMatcherService
  ├── WorkoutProgramService
  ├── WorkoutScheduleService
  ├── WorkoutSessionService
  ├── WorkoutLogService
  └── WorkoutProgressService
```

### State machine và business rules

```text
WorkoutSchedule: PLANNED → COMPLETED | MISSED | CANCELLED

WorkoutSession:
IN_PROGRESS → PAUSED → IN_PROGRESS
IN_PROGRESS → COMPLETED
IN_PROGRESS/PAUSED → DISCARDED
```

- Mỗi user có tối đa một active session; response conflict trả active session hiện hành.
- Finish validate log, tính metric và cập nhật schedule trong cùng
  transaction.
- Schedule `CANCELLED` hợp lệ không tính vào mẫu số completion rate.
- Session `DISCARDED` không tạo WorkoutLog hoặc PR.
- Exercise hidden giữ lịch sử nhưng không thêm vào program mới.
- Sửa program dùng stable child ID/diff; không xoá WorkoutDay còn schedule non-terminal tham chiếu.

---

## PH5: Nutrition & Meal Planner — Dinh dưỡng (Core Domain)

### Mô tả

Quản lý Food Database món Việt, Meal Plan theo ngày, serving và tổng
calories/macros so với Nutrition Target.

### Entities

| Entity | Mô tả |
|---|---|
| `Food` | Serving chuẩn, calories và macros |
| `MealPlan` | Kế hoạch ăn theo user/ngày |
| `Meal` | BREAKFAST, LUNCH, DINNER hoặc SNACK |
| `MealEntry` | Food, serving multiplier và nutrition snapshot |

### Chức năng chính

- Tìm/lọc Food Database món Việt — P0.
- Xem Meal Plan theo ngày/Meal Type — P0.
- Thêm, sửa, xóa MealEntry và serving — P0.
- Backend tính daily total và remaining target — P0.
- Cảnh báo vượt target/tạo candidate signal khi thiếu macro — P0.
- Áp dụng allergy/constraint từ PH2 cho suggestion — P0.

### API Endpoints

| Method | Endpoint | Mô tả |
|---|---|---|
| GET | `/api/v1/foods` | Tìm/lọc Food active |
| GET | `/api/v1/foods/{id}` | Nutrition/serving |
| GET | `/api/v1/meal-plans?date=` | Meal Plan theo ngày |
| POST | `/api/v1/meal-plans/{planDate}/entries` | Thêm entry/get-or-create plan |
| PUT/DELETE | `/api/v1/meal-plans/{planDate}/entries/{entryId}` | Sửa/xóa entry |

### Business rules

- `entryNutrition = nutritionPerServing × servingMultiplier`.
- Nhập gram chỉ khi Food có `gramsPerServing`; Backend snapshot input amount/unit.
- Total/remaining do Backend tính.
- User chỉ truy cập Meal Plan/Entry của mình.
- Food/imported text là untrusted input với AI.
- Giá trị ước lượng phải được trình bày là tham khảo.

---

## PH6: Dashboard — Tổng hợp Tiến độ

### Mô tả

Read model tổng hợp Nutrition, Workout, Body và AI Recommendation.
Dashboard không sở hữu logic hay dữ liệu nghiệp vụ gốc.

### Chức năng chính

- Calories/macros consumed, target và remaining — P0.
- Workout hôm nay/tiếp theo, completion và progress — P0.
- Current weight, BMI và trend — P0.
- Hiển thị 1–3 Daily Recommendation còn hiệu lực — P0.
- Empty state/CTA khi thiếu profile, meal hoặc schedule — P0.
- Admin Dashboard/analytics — P1.
- Dashboard không gọi AI Provider và không sinh/regenerate recommendation.

### API Endpoints

| Method | Endpoint | Mô tả |
|---|---|---|
| GET | `/api/v1/dashboard` | Dashboard user hiện tại |
| GET | `/api/v1/admin/dashboard` | Dashboard Admin — P1 |

### Sub-components

```text
Dashboard
  ├── NutritionSummaryProvider
  ├── WorkoutSummaryProvider
  ├── BodySummaryProvider
  ├── RecommendationSummaryProvider
  └── DashboardQueryService
```

### Business rules

- Mobile không tự tính metric authoritative.
- Recommendation phải thuộc user, còn hiệu lực và đúng trạng thái.
- Dữ liệu thiếu dùng empty state, không dùng dữ liệu giả.
- Mutation phải gọi subsystem owner, không thực hiện ở Dashboard.

---

## PH7: AI Coach — Personalization và Recommendation

### Mô tả

Quản lý AI Consent, Context Layer, Rule Engine, AI Coach Chat, Daily
Recommendation, validation và Apply/Dismiss có kiểm soát.

### Entities

| Entity | Mô tả |
|---|---|
| `AiConsentSetting` | Trạng thái, version và thời điểm consent |
| `AiConsentHistory` | Lịch sử enable/disable/revoke |
| `AiConversation` | Cuộc hội thoại |
| `AiMessage` | Tin nhắn user/assistant |
| `AiConversationSummary` | Summary cho context budget |
| `AiContextSnapshot` | Context tối thiểu tại request |
| `AiRecommendation` | Proposal, priority, status, metrics, expiry |
| `AiRecommendationLog` | Apply/Dismiss, feedback và result |
| `AiRequest` | Provider, latency và status |
| `AiValidationLog` | Schema/business/safety result |
| `WeeklyReview` | Tổng kết tuần — P1 |
| `AiRule` | Rule/signal runtime; Admin quản trị ở P1 |

### Chức năng chính

- Bật/tắt personalization, lưu consent version/history — P0.
- General Knowledge Mode khi consent OFF — P0.
- Context Builder theo whitelist/budget — P0.
- Rule Engine tạo signals từ dữ liệu authoritative — P0.
- AI Coach Chat cá nhân hóa khi consent ON — P0.
- Daily Recommendation 1–3 đề xuất/ngày — P0.
- Schema, business, safety validation — P0.
- Apply/Dismiss recommendation — P0.
- Weekly Review, Preference Memory, Plan Adjustment Proposal — P1.

### API Endpoints

| Method | Endpoint | Mô tả |
|---|---|---|
| GET/PUT | `/api/v1/ai/consent` | Xem/thay đổi consent |
| POST | `/api/v1/ai/conversations` | Tạo conversation |
| GET | `/api/v1/ai/conversations` | Conversation thuộc user |
| POST | `/api/v1/ai/conversations/{id}/messages` | Chat qua Backend |
| GET | `/api/v1/ai/recommendations/daily` | Recommendation trong ngày |
| POST | `/api/v1/ai/recommendations/daily/generations` | Command sinh/refresh recommendation |
| POST | `/api/v1/ai/recommendations/{id}/apply` | Xác nhận proposal |
| POST | `/api/v1/ai/recommendations/{id}/dismiss` | Từ chối proposal |

### AI Decision Pipeline

```text
Flutter → Spring Boot Authentication/Ownership → Consent Check
  ├── OFF → General Knowledge Mode, không personal context/recommendation
  └── ON → Context Builder → Rule Engine → Prompt Builder
             ↓
           FastAPI AI Service → Provider Adapter → LLM
             ↓
           Output Parser → Schema/Business/Safety Validation
             ↓
           Response hoặc Recommendation PENDING
```

### Allowed Action Contract

AI chỉ trả proposal thuộc whitelist:

- `NONE`
- `ADD_MEAL_ENTRY_PROPOSAL`
- `CREATE_WORKOUT_SCHEDULE_PROPOSAL`
- `UPDATE_USER_PREFERENCE_PROPOSAL`
- `REVIEW_NUTRITION_TARGET_PROPOSAL`
- `LOG_REMINDER_ONLY`

`LOG_REMINDER_ONLY` thuộc P0 cho reminder local/in-app sau user review/xác nhận;
PH10 kiểm tra preference/timezone/consent và không mutation domain.

```text
APPLY: User Approval → Ownership → PENDING/Expiry Check
→ Schema/Business Validation → Domain Mutation → Audit

DISMISS: Ownership → PENDING Check → DISMISSED + optional feedback
→ không mutation Health/Workout/Nutrition
```

### Business rules và guardrails

- Kiểm tra consent trước Context Builder.
- Consent OFF không gửi context cá nhân và không tạo Daily
  Recommendation cá nhân hóa.
- Context tối thiểu theo `CHAT`, `DAILY_RECOMMENDATION`,
  `WEEKLY_REVIEW`, `PLAN_ADJUSTMENT`.
- Không gửi password, token, API key, dữ liệu user khác hoặc raw history
  không cần thiết.
- Chỉ recommendation `PENDING`, thuộc user, chưa hết hạn mới được
  Apply/Dismiss; Apply phải idempotent.
- Daily generation dùng `rules-v1`, candidate shortlist và generation key; ID ngoài shortlist bị reject.
- `BLOCKED` chỉ lưu validation log, không persist thành recommendation.
- Preference proposal không được sửa allergy/dietary constraint; meal/schedule proposal bắt buộc có `targetDate`.
- AI không chẩn đoán, kê thuốc, cam kết điều trị hoặc khuyến nghị cực đoan.
- User input, Food/Exercise/imported text là untrusted input.
- Provider credential chỉ server-side; có timeout, retry giới hạn và
  fallback an toàn.

---

## PH8: Admin & Audit — Quản trị và Truy vết

### Mô tả

Quản trị dữ liệu dùng chung và audit thao tác quan trọng. Exercise/Food
và audit tối thiểu là UC-19/P0 baseline theo business flow; UC-20 và các
khả năng Admin mở rộng vẫn là P1 theo SRS.

### Entities

| Entity | Mô tả |
|---|---|
| `AuditLog` | Actor, action, target, result và timestamp |
| `PromptVersion` | Metadata/version prompt — P1 |
| `AiRule` | Rule do Admin quản trị — P1 |
| `ImportJob` | Preview, validation và kết quả import — P1 |

### Chức năng chính

- CRUD/ẩn hiện Exercise, Food tối thiểu — P0 baseline.
- Audit mutation nhạy cảm và Apply — P0 baseline.
- User management/deactivate — P1.
- CSV/Excel import có preview/validation — P1.
- AI Rule, prompt version, recommendation metrics — P1.

### API Endpoints

| Method | Endpoint | Mô tả |
|---|---|---|
| GET/POST/PUT/DELETE | `/api/v1/admin/exercises` | Quản trị Exercise |
| GET/POST/PUT/DELETE | `/api/v1/admin/foods` | Quản trị Food |
| GET | `/api/v1/admin/audit-logs` | Tra cứu audit |
| GET/POST/PUT | `/api/v1/admin/users` | User management — P1 |
| POST | `/api/v1/admin/imports/preview` | Preview/validate — P1 |
| POST | `/api/v1/admin/imports/{id}/commit` | Commit import — P1 |
| GET/POST/PUT | `/api/v1/admin/ai-rules` | AI Rule — P1 |
| GET/POST/PUT | `/api/v1/admin/prompts` | Prompt version — P1 |

### Business rules

- Chỉ ADMIN hợp lệ được gọi API quản trị.
- Không xem/log password, token, OTP, API key hoặc raw context thừa.
- Import phải preview/validate trước commit và rollback khi thất bại.
- Exercise/Food dùng soft delete để bảo toàn lịch sử.
- Audit không trở thành nơi lưu dư thừa dữ liệu cá nhân.

---

## PH9: Media & Storage — Media Bài tập và Món ăn

### Mô tả

Quản lý object storage và metadata Exercise/Food; không lưu binary trực
tiếp trong PostgreSQL.

### Entities

| Entity | Mô tả |
|---|---|
| `MediaObject` | Owner type/id, object key, MIME, size, visibility, status |

### Chức năng chính

- Exercise video/GIF/image và Food image — P0 baseline.
- Validate MIME thực tế, extension và size — P0 baseline.
- Backend upload hoặc presigned URL có thời hạn — P0 baseline.
- Access URL theo public/private visibility — P0 baseline.
- Dọn orphan và bảo toàn media còn được lịch sử tham chiếu — P0.
- Streaming/transcoding nâng cao — Future.

### API Endpoints

| Method | Endpoint | Mô tả |
|---|---|---|
| POST | `/api/v1/media/upload-init` | Khởi tạo upload |
| POST | `/api/v1/media/{id}/upload-complete` | Verify object/metadata |
| GET | `/api/v1/media/{id}/access-url` | URL theo quyền |
| DELETE | `/api/v1/media/{id}` | Xóa/gỡ tham chiếu kiểm soát |

### Sub-components

```text
Media & Storage
  ├── MediaUploadService
  ├── MediaValidationService
  ├── ObjectStorageService
  ├── MediaAccessPolicyService
  └── OrphanCleanupService
```

---

## PH10: Notification — Nhắc nhở và Thông báo

### Mô tả

Reminder/thông báo local/in-app thuộc P0 nhưng không phải source of truth.
Push/automation bên ngoài ứng dụng vẫn là P2.

### Entities

| Entity | Mô tả |
|---|---|
| `Notification` | Type, content, scheduled/sent/read status |
| `NotificationPreference` | Cấu hình bật/tắt theo loại |

### Chức năng chính

- Local/in-app workout, meal, weight reminder — P0.
- Notification Center, read state và preference — P0.
- Recommendation notification theo consent — P0; Weekly Review vẫn P1.
- Push, automation và scheduling nâng cao — P2.

### API Endpoints

| Method | Endpoint | Mô tả |
|---|---|---|
| GET | `/api/v1/notifications` | Danh sách thông báo |
| POST | `/api/v1/notifications/{id}/read` | Đánh dấu đã đọc |
| GET/PUT | `/api/v1/notifications/preferences` | Cấu hình |

### Business rules

- Không tự mutation Health, Workout hoặc Nutrition.
- Không gửi AI personalization khi consent không cho phép.
- Lỗi Notification không làm thất bại transaction nghiệp vụ gốc.

---

## Dependency Graph — Quan hệ phụ thuộc

```text
                              ┌──────────────────┐
                              │ PH1: IDENTITY    │
                              └────────┬─────────┘
                                       │ identity/ownership
             ┌─────────────────────────┼──────────────────────────┐
             ▼                         ▼                          ▼
  ┌──────────────────┐      ┌──────────────────┐       ┌──────────────────┐
  │ PH2: PREFERENCE  │      │ PH3: HEALTH     │       │ PH8: ADMIN/AUDIT│
  └────────┬─────────┘      └────────┬─────────┘       └────────▲─────────┘
           │                         │                          │ audit
     ┌─────┴───────────┐      ┌──────┴──────────┐              │
     ▼                 ▼      ▼                 ▼              │
┌─────────────┐  ┌───────────────┐       ┌──────────────┐      │
│ PH4: WORKOUT│  │ PH5: NUTRITION│       │ PH9: MEDIA   │──────┘
└──────┬──────┘  └───────┬───────┘       └──────────────┘
       └──────────┬───────┴───────────────┐
                  ▼                       ▼
         ┌────────────────┐      ┌────────────────┐
         │ PH6: DASHBOARD │      │ PH7: AI COACH  │
         └────────────────┘      └───────┬────────┘
                                         │ optional event
                                         ▼
                                ┌──────────────────┐
                                │ PH10: NOTIFY     │
                                └──────────────────┘
```

### Quy tắc phụ thuộc

| Từ → Đến | Quan hệ |
|---|---|
| All → Identity | Xác thực actor, role và ownership |
| Workout → Preference | Đọc equipment/training preference |
| Nutrition → Health | Đọc NutritionTarget authoritative |
| Nutrition → Preference | Đọc allergy, constraint và meal preference |
| Workout/Nutrition → Media | Tham chiếu metadata/object access |
| Dashboard → Health/Workout/Nutrition/AI | Chỉ tổng hợp read model |
| AI → Health/Workout/Nutrition/Preference | Context tối thiểu sau consent |
| AI Apply → Domain Owner | Gọi domain service sau approval/validation |
| Sensitive mutation → Audit | Ghi actor/action/target/result, không secret |
| Workout/AI → Notification | Optional event, không coupling transaction |

### Ghi chú coupling AI và domain

- Context Builder đọc qua domain service/query đã authorize; AI Service
  không đọc database.
- Rule Engine quyết định tín hiệu; LLM diễn giải và tạo proposal đúng
  schema.
- Apply handler định tuyến proposal tới đúng domain owner, không để AI
  gọi repository/mutation endpoint.
- Có thể dùng domain event như `WorkoutCompleted`, `MealEntryChanged`,
  `WeightLogged`, `RecommendationApplied` để giảm coupling.

---

## Mapping với Package Structure

### Spring Boot Backend

```text
com.viegym
├── identity/                     ← PH1
│   ├── controller/
│   ├── service/
│   ├── entity/
│   ├── repository/
│   └── dto/
├── preference/                   ← PH2
├── health/                       ← PH3
├── workout/                      ← PH4
│   ├── exercise/
│   ├── program/
│   ├── schedule/
│   ├── session/
│   └── log/
├── nutrition/                    ← PH5
├── dashboard/                    ← PH6
├── ai/                           ← PH7 Backend orchestration
│   ├── consent/
│   ├── context/
│   ├── rule/
│   ├── conversation/
│   ├── recommendation/
│   └── validation/
├── admin/                        ← PH8 admin use cases
├── audit/                        ← PH8 audit
├── media/                        ← PH9
├── notification/                 ← PH10
└── common/
    ├── config/
    ├── exception/
    ├── security/
    └── dto/
```

### FastAPI AI Service

```text
app/
├── api/                           — Internal endpoint chỉ Backend gọi
├── schemas/                       — Input/output contract
├── providers/                     — OpenAI/Gemini adapter
├── prompts/                       — Prompt builder/template
├── validators/                    — Output/safety helper
└── core/                          — Config, timeout, retry, logging
```

AI Service là stateless decision-support component; business validation
cuối cùng và mọi mutation vẫn thuộc Spring Boot Backend.

---

## Traceability với SRS và Business Flow

| Business flow | SRS Use Case | Feature / Screen | Owner | Priority |
|---|---|---|---|---|
| Register / OTP | UC-01 | FT-ID-001/006/008; MH05/MH06 | PH1 | P0 |
| Health onboarding/recalculation | UC-02/03 | FT-HP-001..004; MH09/MH42 | PH3 | P0 |
| Equipment/User Preference | UC-04/18 | FT-UP-003..005, FT-WO-003; MH10/MH37/MH38 | PH2, PH4 consumer | P0 |
| Exercise/Program/Schedule/Session/Log/Favorite | UC-04..07 | FT-WO-001..011; MH11..19/MH56 | PH4 | P0 |
| Food/Meal Planner/Favorite | UC-08/09 | FT-MP-001..007/009; MH20..25/MH57 | PH5 | P0 |
| Weight Tracking | UC-10 | FT-HP-005..007; MH43 | PH3 | P0 |
| Dashboard | UC-11 | FT-DB-001..005/007; MH03 | PH6 | P0 |
| AI Consent/Coach | UC-12/17 | FT-AI-001..007/014; MH28/MH29/MH55 | PH7 | P0 |
| Recommendation/Apply/Dismiss | UC-13/14 | FT-AI-008..010; MH30/MH31 | PH7 + domain | P0 |
| Admin Exercise/Food/Audit | UC-19 | FT-AD-003/004/008; MH45/46/47/51 | PH8 | P0 baseline |
| Exercise/Food media | UC-21 | FT-MD-001..003 | PH9 | P0 baseline |
| Weekly Review/Plan Adjustment | UC-15/16 | FT-AI-011/012; MH32 | PH7 | P1 |
| Admin User/Import/Rule/Prompt | UC-20 | FT-AD-002/005/006/007; MH48/MH49/MH50 | PH8 | P1 |
| Local/in-app reminder | UC-22 | FT-NT-001..004; MH41 | PH10 | P0 |
| Push/automation | Future flow | FT-NT-005 | PH10 | P2 |

---

## Phạm vi triển khai

### P0 — Bắt buộc

- PH1 Identity & Auth.
- PH2 User Profile & Preference.
- PH3 Health calculation và Weight Tracking.
- PH4 Exercise, Program, Schedule, Session và Log.
- PH5 Food Database và Meal Planner.
- PH6 Dashboard user.
- PH7 Consent, Context, Coach, Recommendation, Apply/Dismiss.
- PH8 Exercise/Food admin và audit tối thiểu phục vụ demo.
- PH9 Exercise/Food media baseline.
- PH10 Notification local/in-app, workout/meal/weight reminder, preference và read/delete state.

### P1 — Chỉ làm khi P0 ổn định

- Weekly Review, Preference Memory và Plan Adjustment Proposal.
- Admin User, import preview/validation, AI Rule/Prompt và metrics.
- Admin Dashboard.

### P2 / Future

- Push notification/automation và offline queue nâng cao.
- Shop/Marketplace, Cart/Order/Payment và supplement ecosystem.
- Wearable, Apple Health/Google Fit.
- Food image recognition, pose estimation/computer vision, ML prediction.
- AI tự động thay đổi kế hoạch không có user approval luôn ngoài phạm vi.
