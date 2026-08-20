# Phân Rã Tính Năng Hệ Thống — VieGym

> **Phiên bản:** 3.0
> **Ngày cập nhật:** 2026-08-19
> **Trạng thái:** Baseline triển khai MVP

## 1. Mục đích và nguồn tham chiếu

Tài liệu phân rã yêu cầu VieGym thành các feature có thể thiết kế, triển khai và kiểm thử. Nguồn tham chiếu, theo thứ tự ưu tiên khi có xung đột:

1. `specs.md` v3.0 — Source of Truth về yêu cầu và phạm vi.
2. `bussiness_mainflow.md` v3.0 — luồng nghiệp vụ end-to-end.
3. `phan_ra_phan_he_he_thong.md` v3.0 — subsystem owner và boundary.
4. Tài liệu này — feature breakdown phục vụ triển khai.

Nguyên tắc xuyên suốt:

> **Backend calculates. AI interprets and recommends. User decides. Backend executes.**

- Spring Boot Backend là business authority và source of truth.
- Mobile không tự tính metric authoritative và không gọi trực tiếp AI Service.
- AI Service không truy cập database và không tự mutation dữ liệu nghiệp vụ.
- Mỗi feature có một subsystem owner; subsystem khác chỉ là consumer.
- Private resource phải kiểm tra authentication, authorization và ownership tại Backend.

### 1.1. Mức ưu tiên

| Priority | Ý nghĩa |
|---|---|
| P0 | Bắt buộc để hoàn thiện và demo MVP |
| P1 | Chỉ triển khai sau khi P0 ổn định |
| P2 | Mở rộng, không bắt buộc cho MVP |
| Future | Ngoài phạm vi đồ án hiện tại |

### 1.2. Cấu trúc feature

Mỗi feature cần xác định chức năng, actor/trigger, input/output, luồng chính, business rule, dependency, priority và acceptance criteria. State machine hoặc error flow được nêu riêng khi ảnh hưởng trực tiếp đến nghiệp vụ.

### 1.3. Phạm vi

Tài liệu gồm 10 phân hệ: Identity & Auth; User Profile & Preference; Health Profile & Body Tracking; Workout; Nutrition & Meal Planner; Dashboard; AI Coach; Admin & Audit; Media & Storage; Notification.

Shop/Marketplace, Cart/Order/Payment, wearable, Apple Health/Google Fit, food image recognition, pose estimation/computer vision, ML prediction và AI tự thay đổi kế hoạch không cần user xác nhận đều ngoài MVP.

---

## 2. PH1 — Identity & Auth

### 2.1. Mục tiêu và feature

Quản lý account, xác thực, token, OTP, role và trạng thái tài khoản. PH1 cung cấp identity nhưng không sở hữu dữ liệu nghiệp vụ khác.

| ID | Feature | Priority |
|---|---|---|
| FT-ID-001 | Đăng ký local và kích hoạt bằng OTP | P0 |
| FT-ID-002 | Đăng nhập email/password | P0 |
| FT-ID-003 | Google Login server-side | P0 |
| FT-ID-004 | Đăng xuất và revoke token | P0 |
| FT-ID-005 | Refresh token | P0 |
| FT-ID-006 | Quên/đặt lại mật khẩu bằng OTP | P0 |
| FT-ID-007 | Đổi mật khẩu khi đã đăng nhập | P0 |
| FT-ID-008 | OTP lifecycle và rate limit | P0 |
| FT-ID-009 | Biometric unlock local | P0 |
| FT-ID-010 | Role, account status và authorization baseline | P0 |
| FT-ID-011 | Danh sách thiết bị/remote logout | P1 |

### 2.2. Chi tiết

#### FT-ID-001 — Đăng ký và OTP

- **Actor:** Guest.
- **Input:** Email, password và thông tin cơ bản được API cho phép.
- **Luồng:** Validate → tạo account `PENDING` → gửi OTP → verify → kích hoạt → cấp access/refresh token → Health onboarding.
- **Rules:** Email duy nhất; password được hash; account chưa verify không nhận token nghiệp vụ; lỗi không làm lộ email đã tồn tại.
- **AC:** OTP hợp lệ kích hoạt account; OTP sai, hết hạn hoặc vượt giới hạn không kích hoạt.

#### FT-ID-002/003 — Đăng nhập local và Google

- Backend kiểm tra credential và account status trước khi cấp token.
- Account pending, locked hoặc disabled bị từ chối bằng lỗi chuẩn.
- Google credential phải được verify server-side trước khi liên kết/tạo account.
- Số lần đăng nhập sai và cooldown là cấu hình bảo mật, không hard-code trong feature.

#### FT-ID-004/005 — Logout và refresh

- Logout revoke refresh token/session tương ứng.
- Refresh chỉ chấp nhận token còn hạn, chưa revoke và đúng account; mỗi lần refresh bắt buộc rotation. Reuse token cũ phải revoke token family theo policy.
- Password, OTP, access token và refresh token không được ghi log plaintext.

#### FT-ID-006/007/008 — Password và OTP lifecycle

- OTP P0 tách theo purpose `REGISTER`, `PASSWORD_RESET`; `LOGIN_VERIFY` chỉ áp dụng khi triển khai MFA P1.
- OTP có expiry, resend cooldown, attempts/rate limit và không dùng chéo purpose.
- Đổi mật khẩu cần phiên hợp lệ; local account xác minh mật khẩu hiện tại.
- Reset password thu hồi credential/session theo chính sách bảo mật triển khai.

#### FT-ID-009/010/011 — Local unlock, authorization và session

- Biometric chỉ mở token/session trong secure storage; không gửi dữ liệu sinh trắc lên Backend.
- Role tối thiểu: `USER`, `ADMIN`; private API kiểm tra JWT, role và ownership.
- Xem thiết bị/remote logout là P1.

**Dependencies:** Không phụ thuộc domain khác. **Consumers:** PH2–PH10.

---

## 3. PH2 — User Profile & Preference

### 3.1. Mục tiêu và feature

Sở hữu hồ sơ cơ bản, equipment, food/training preference và constraints do user khai báo.

| ID | Feature | Priority |
|---|---|---|
| FT-UP-001 | Xem/cập nhật hồ sơ cơ bản | P0 |
| FT-UP-002 | Avatar/profile media | P1 |
| FT-UP-003 | User Preference và constraints | P0 |
| FT-UP-004 | Equipment Preference | P0 |
| FT-UP-005 | Ghi nhận Apply/Dismiss feedback | P0 |
| FT-UP-006 | Preference Memory nâng cao | P1 |
| FT-UP-007 | Ngôn ngữ/theme/đơn vị hiển thị | P1 |

### 3.2. Chi tiết

#### FT-UP-001/002 — Hồ sơ cơ bản

- User xem/sửa field profile nằm trong whitelist và chỉ sửa resource của mình.
- Avatar upload dùng PH9 ở P1; P0 dùng placeholder/initial và không phụ thuộc profile media.
- Ngày sinh, giới tính, chiều cao, cân nặng, activity và fitness goal thuộc PH3 khi dùng cho health calculation.

#### FT-UP-003 — Preference và constraints

- Lưu món không thích, dị ứng/ràng buộc tự khai báo, meal preference, thời gian tập và lịch ưu tiên.
- Dị ứng/constraints ưu tiên hơn đề xuất tối ưu calories hoặc macro.
- Preference vẫn được lưu khi consent OFF; chỉ việc đưa vào AI context mới phụ thuộc consent.

#### FT-UP-004 — Equipment Preference

- User chọn khi onboarding/lần đầu cần tập và chỉnh sửa/reset trong Settings.
- Equipment tối thiểu: `BODYWEIGHT`, `DUMBBELL`, `BARBELL`, `BENCH`, `CABLE_MACHINE`, `MACHINE`, `RESISTANCE_BAND`, `KETTLEBELL`, `PULL_UP_BAR`, `TREADMILL`.
- Không chọn lại mỗi buổi; thay đổi không sửa WorkoutLog cũ.
- Nếu chưa chọn, Workout ưu tiên `BODYWEIGHT` và bài không cần thiết bị đặc thù.

#### FT-UP-005/006 — Feedback và Memory

- P0 lưu Apply/Dismiss status và feedback nếu user cung cấp.
- Dismiss không tự mutation preference hoặc domain data.
- Suy luận/cập nhật preference tự động là P1; proposal thay đổi cần user xác nhận và Backend validate.

**Dependencies:** PH1; PH9 cho avatar. **Consumers:** PH4, PH5, PH7.

---

## 4. PH3 — Health Profile & Body Tracking

### 4.1. Mục tiêu và feature

Sở hữu Health Profile, Nutrition Target, Weight Log và toàn bộ phép tính authoritative.

| ID | Feature | Priority |
|---|---|---|
| FT-HP-001 | Onboarding/xem/sửa Health Profile | P0 |
| FT-HP-002 | BMI | P0 |
| FT-HP-003 | BMR và TDEE | P0 |
| FT-HP-004 | Calories và Macro Target | P0 |
| FT-HP-005 | Weight Log và History | P0 |
| FT-HP-006 | Weight trend/summary 7–30 ngày | P0 |
| FT-HP-007 | Dữ liệu biểu đồ và progress | P0 |

### 4.2. Chi tiết

#### FT-HP-001 — Health Profile lifecycle

- **Input:** Tuổi/ngày sinh, gender hồ sơ, calculation sex tùy chọn, chiều cao, cân nặng, activity level, fitness goal, training experience.
- **Create:** Validate → tính metric → lưu `HealthProfile`, `WeightLog` và chỉ lưu `NutritionTarget` khi calculation `COMPLETE`, trong cùng transaction.
- **Update:** Validate → cập nhật → tính lại BMI/BMR/TDEE/target nếu field nền thay đổi.
- Thiếu dữ liệu bắt buộc thì không tính TDEE và yêu cầu hoàn thiện profile.

#### FT-HP-002/003 — BMI, BMR và TDEE

- `BMI = weightKg / heightM²`.
- BMR dùng Mifflin–St Jeor theo SRS.
- `TDEE = BMR × activityFactor`; factor do Backend quản lý.
- Mobile và AI không tự tính lại metric authoritative.

#### FT-HP-004 — Calories và Macro Target

- Backend tính từ TDEE, fitness goal và rule an toàn trong SRS.
- P0 dùng calories offset, protein factor và fat ratio deterministic trong SRS; không tự chọn một giá trị khác trong khoảng.
- `calculationSex=UNSPECIFIED` hoặc age dưới 18 trả calculation incomplete; Backend không suy ra calculation sex từ gender.
- Kết quả bất hợp lệ như calories dưới 1.200, carb âm hoặc không hữu hạn phải reject/để incomplete; không tự điều chỉnh âm thầm.
- `REVIEW_NUTRITION_TARGET_PROPOSAL` chỉ mở review, không trực tiếp sửa target.

#### FT-HP-005/006/007 — Weight Tracking

- User thêm/xem/cập nhật WeightLog của mình; API quyết định upsert hợp lệ theo ngày.
- Backend tạo trend/summary 7–30 ngày và dữ liệu chart/progress.
- WeightLog hằng ngày không tự thay đổi `NutritionTarget`.

**Dependencies:** PH1. **Consumers:** PH5, PH6, PH7.

---

## 5. PH4 — Workout

### 5.1. Mục tiêu và feature

Quản lý Exercise Library, Program, Schedule, Session và Log từ lúc chọn bài đến khi hoàn thành.

| ID | Feature | Priority |
|---|---|---|
| FT-WO-001 | Exercise Library: list/search/filter | P0 |
| FT-WO-002 | Exercise Detail và safety/media | P0 |
| FT-WO-003 | Equipment matching và bài thay thế | P0 |
| FT-WO-004 | Workout Program/Builder | P0 |
| FT-WO-005 | Workout Schedule | P0 |
| FT-WO-006 | Workout Session lifecycle | P0 |
| FT-WO-007 | Workout Log theo bài/set | P0 |
| FT-WO-008 | Volume và completion rate | P0 |
| FT-WO-009 | Workout History/progress | P0 |
| FT-WO-010 | Favorite Exercise | P1 |
| FT-WO-011 | Personal Record | P0 |

`FT-WO-003` tiêu thụ `FT-UP-004`, không sở hữu hoặc lưu Equipment Preference.

### 5.2. Chi tiết

#### FT-WO-001/002/003 — Exercise discovery

- List/search/filter theo tên, muscle group, equipment và difficulty.
- Detail gồm muscles, equipment, difficulty, mô tả, steps, common mistakes, safety notes và media.
- Ưu tiên bài phù hợp equipment; giảm ưu tiên bài không phù hợp và gợi ý bài thay thế cùng nhóm cơ.
- Exercise hidden giữ log cũ nhưng không được thêm vào program mới.

#### FT-WO-004 — Workout Program/Builder

- Tạo/chỉnh sửa/xóa/archive program thuộc user với PPL, Upper/Lower, Full Body hoặc Custom.
- Program chứa WorkoutDay/WorkoutExercise với sets, reps, rest, order và note.
- Mỗi user chỉ được có tối đa một program `ACTIVE` tại một thời điểm.

#### FT-WO-005 — Workout Schedule

- Tạo thủ công hoặc sinh từ Program; xem theo khoảng ngày.

```text
PLANNED
  ├── hoàn thành session → COMPLETED
  ├── quá hạn không hoàn thành → MISSED
  └── user hủy hợp lệ → CANCELLED
```

- Chỉ schedule thuộc user mới được sửa/hủy; program thay đổi không viết lại log cũ.

#### FT-WO-006/007 — Session và Log

```text
STARTED ↔ PAUSED
   ├── FINISH → tạo WorkoutLog → schedule COMPLETED
   └── DISCARD → không tạo completed log
```

- Start từ schedule hợp lệ; Backend ngăn active session trùng theo rule triển khai.
- Pause/Resume chỉ hợp lệ theo trạng thái hiện tại.
- Finish validate set/reps/weight/duration, lưu log và cập nhật schedule trong transaction.
- Discard không tạo achievement hoặc completion giả.

#### FT-WO-008/009/011 — Calculation và progress

- `setVolume = reps × weightKg`; workout volume là tổng volume hợp lệ.
- Completion rate = completed/scheduled, loại `CANCELLED` khỏi mẫu số.
- Backend xác định PR theo weight/reps/volume; Mobile chỉ hiển thị.
- History hỗ trợ xem log/progress theo khoảng thời gian.

**Dependencies:** PH1, PH2 Equipment Preference, PH9. **Consumers:** PH6, PH7, PH8.

---

## 6. PH5 — Nutrition & Meal Planner

### 6.1. Mục tiêu và feature

Quản lý Food Database món Việt, Meal Plan/Entry và tổng dinh dưỡng theo ngày.

| ID | Feature | Priority |
|---|---|---|
| FT-MP-001 | Food Library: list/search/filter | P0 |
| FT-MP-002 | Food Detail và serving | P0 |
| FT-MP-003 | Meal Plan theo ngày | P0 |
| FT-MP-004 | Meal Entry và serving multiplier | P0 |
| FT-MP-005 | Daily calories/macro summary | P0 |
| FT-MP-006 | Macro progress/distribution | P0 |
| FT-MP-007 | Favorite Food | P1 |
| FT-MP-008 | Recent Food | P1 |
| FT-MP-009 | Meal History/template | P0 |
| FT-MP-010 | Water Tracker | P1 |
| FT-MP-011 | AI Meal Proposal integration | P0 |

### 6.2. Chi tiết

#### FT-MP-001/002 — Food Database

- Food có tên, category, serving size/unit, calories, protein, carbohydrate, fat, source/note và media nếu có.
- Tìm/lọc Food public/active; dữ liệu demo ưu tiên món Việt và không phụ thuộc hoàn toàn API ngoài.
- Food hidden giữ history nhưng không được chọn cho Meal Entry mới.

#### FT-MP-003/004 — Meal Plan và Entry

- User xem/tạo plan theo ngày với `BREAKFAST`, `LUNCH`, `DINNER`, `SNACK`.
- Thêm/sửa/xóa entry; hỗ trợ gram, tô/chén/phần, quả/ly/miếng và multiplier hợp lệ.
- `entryNutrition = nutritionPerServing × servingMultiplier` sau chuẩn hóa đơn vị.
- Backend validate serving/multiplier dương và ownership trước mutation.

#### FT-MP-005/006/009 — Summary và History

- Backend tổng calories/protein/carbs/fat và remaining so với Nutrition Target.
- Mobile hiển thị progress/chart, không tự tính authoritative summary.
- User xem ngày trước và lưu/copy meal template; Backend validate target date và ownership.

#### FT-MP-011 — AI Meal Proposal

- Khi consent ON, AI có thể tạo `ADD_MEAL_ENTRY_PROPOSAL` dựa trên macro gap và preference.
- Chỉ mutation sau khi user APPLY và PH5 validate food, serving, constraints và ownership.

**Dependencies:** PH1, PH2, PH3, PH9. **Consumers:** PH6, PH7, PH8.

---

## 7. PH6 — Dashboard

### 7.1. Mục tiêu và feature

Cung cấp aggregate endpoint tổng hợp trạng thái ngày/tuần từ các domain owner.

| ID | Feature | Priority |
|---|---|---|
| FT-DB-001 | Daily Nutrition Summary | P0 |
| FT-DB-002 | Workout Today và Next | P0 |
| FT-DB-003 | Weekly Completion | P0 |
| FT-DB-004 | Current Weight/BMI/Progress | P0 |
| FT-DB-005 | Daily Recommendation/short insight | P0 |
| FT-DB-006 | Quick Actions | P1 |
| FT-DB-007 | Loading/error/empty states | P0 |

### 7.2. Business rules

- Backend aggregate theo user và ngày/timezone yêu cầu.
- Nutrition hiển thị target, consumed, remaining và macro.
- Workout hiển thị today, next và completion loại CANCELLED.
- Body dùng metric/trend do PH3 cung cấp.
- Chỉ hiển thị recommendation hợp lệ thuộc user; consent OFF không có personalized recommendation.
- Thiếu profile, target, meal, schedule hoặc recommendation phải có empty state phù hợp, không dùng dữ liệu giả.

**Dependencies:** PH1, PH3, PH4, PH5, PH7.

---

## 8. PH7 — AI Coach

### 8.1. Mục tiêu và feature

Cung cấp chat và recommendation an toàn từ context tối thiểu được Backend cho phép.

| ID | Feature | Priority |
|---|---|---|
| FT-AI-001 | AI Consent và consent history | P0 |
| FT-AI-002 | General Knowledge Mode | P0 |
| FT-AI-003 | Context Builder/whitelist/budget | P0 |
| FT-AI-004 | Rule Engine và signals | P0 |
| FT-AI-005 | AI Coach Chat | P0 |
| FT-AI-006 | Workout advice | P0 |
| FT-AI-007 | Nutrition advice | P0 |
| FT-AI-008 | Daily Recommendation | P0 |
| FT-AI-009 | Apply/Dismiss workflow | P0 |
| FT-AI-010 | Schema/business/safety validation | P0 |
| FT-AI-011 | Weekly Review | P1 |
| FT-AI-012 | Plan Adjustment Proposal | P1 |
| FT-AI-013 | Preference Memory | P1 |
| FT-AI-014 | Conversation History | P0 |
| FT-AI-015 | Conversation Summary/feedback nâng cao | P1 |

### 8.2. Consent, context và rules

#### FT-AI-001/002 — Consent modes

- Lưu `enabled`, `consent_version`, `accepted_at`, `updated_at` và lịch sử thay đổi cần thiết.
- Kiểm tra consent trước Context Builder.
- Khi OFF: không gửi Health/Workout/Nutrition/Weight/Preference cá nhân; chỉ General Knowledge Mode; không tạo Daily Recommendation cá nhân hóa.
- Khi ON: chỉ dùng context cần thiết cho tác vụ và nằm trong whitelist.

#### FT-AI-003/004 — Context và Rule Engine

- Backend tạo context theo `CHAT`, `DAILY_RECOMMENDATION`, `WEEKLY_REVIEW`, `PLAN_ADJUSTMENT`.
- Context áp dụng ownership, whitelist, data minimization, budget/version và không chứa credential.
- Rule Engine tạo signal deterministic: protein gap, calories over target, adherence issue, weight trend off goal, meal logging drop, preference conflict.
- Rule Engine quyết định WHAT; AI quyết định HOW.

### 8.3. Coach và recommendation

#### FT-AI-005/006/007/014 — AI Coach

- Backend nhận message → consent → context/signals → AI Service → validation → lưu conversation/message.
- Recent history được dùng theo budget; automatic summary là P1.
- User message, history, imported data và food/exercise text là untrusted input.
- AI không chẩn đoán, kê thuốc, cam kết điều trị hoặc khuyến nghị cực đoan; tình huống rủi ro trả safe response.

#### FT-AI-008 — Daily Recommendation

- Client gọi command generate → signals `rules-v1` → candidate shortlist → context → AI → validation → lưu 1–3 recommendation `PENDING` khi đủ dữ liệu.
- Dashboard và endpoint đọc Daily Recommendation không gọi AI Provider hoặc tạo dữ liệu.
- Recommendation gồm type, title, content, reason, priority, source metrics, safety level, timestamps/expiry và optional action.
- Chỉ `PENDING` mới Apply/Dismiss; hết hạn chuyển `EXPIRED`.
- Output safety `BLOCKED` chỉ ghi validation log và không trở thành recommendation.

#### FT-AI-009/010 — Apply/Dismiss và validation

```text
APPLY: authorization → ownership → status/expiry → action whitelist
       → schema/business/safety validation → domain mutation → audit → APPLIED

DISMISS: authorization → ownership → status validation
         → lưu status/feedback → DISMISSED (không domain mutation)
```

- APPLY lỗi không được mutation một phần.
- Output sai schema/business/safety bị fallback, regenerate hoặc block; không trở thành action hợp lệ.

### 8.4. Allowed Action Contract

| Action | Domain thực thi | Điều kiện APPLY | Kết quả |
|---|---|---|---|
| `NONE` | Không có | Không mutation | Chỉ hiển thị insight |
| `ADD_MEAL_ENTRY_PROPOSAL` | PH5 | Food thuộc shortlist; serving/constraint/`targetDate` hợp lệ | Tạo Meal Entry |
| `CREATE_WORKOUT_SCHEDULE_PROPOSAL` | PH4 | WorkoutDay thuộc shortlist; `targetDate` hợp lệ | Tạo Schedule |
| `UPDATE_USER_PREFERENCE_PROPOSAL` | PH2 | Field ∈ `disliked_foods`, `meal_preferences`, `training_preferences`, `preferred_training_time`; user xác nhận | Cập nhật preference |
| `REVIEW_NUTRITION_TARGET_PROPOSAL` | PH3 | Chỉ tạo review flow | Không tự sửa target |
| `LOG_REMINDER_ONLY` | PH10/client | Reserved P1; không nằm trong `allowedActions` P0 | Reminder khi Notification được bật |

Payload không chứa SQL, endpoint command, token, API key hoặc field ngoài whitelist.
`allergies` và `dietary_constraints` chỉ do user tự sửa, không bao giờ qua AI proposal.

### 8.5. P1

- Weekly Review dùng aggregate metrics do Backend tính.
- Plan Adjustment luôn là proposal PENDING.
- Preference Memory và conversation summary chỉ làm sau P0; vẫn tuân thủ consent và user confirmation khi thay đổi nghiệp vụ.

**Dependencies:** PH1–PH6. **Consumers:** PH6, PH8, PH10.

---

## 9. PH8 — Admin & Audit

### 9.1. Mục tiêu và feature

Quản trị catalog và truy vết thao tác nhạy cảm.

| ID | Feature | Priority |
|---|---|---|
| FT-AD-001 | Admin Dashboard | P1 |
| FT-AD-002 | User Management | P1 |
| FT-AD-003 | Exercise Management | P0 baseline |
| FT-AD-004 | Food Management | P0 baseline |
| FT-AD-005 | Import CSV/Excel preview/validation | P1 |
| FT-AD-006 | AI Rule Management | P1 |
| FT-AD-007 | Prompt Template/version Management | P1 |
| FT-AD-008 | Audit Log | P0 baseline |
| FT-AD-009 | AI Recommendation Metrics | P1 |

### 9.2. Business rules

- P0: CRUD/hide Exercise và Food đủ cho seed/demo; audit tối thiểu cho admin action và recommendation APPLY.
- P1: User Management, dashboard, import, AI Rule/Prompt và metrics.
- Import phải preview/validate trước commit và báo lỗi theo dòng.
- Exercise/Food đã có history nên ưu tiên hide/soft-delete.
- Audit ghi actor, action, target, time, result và metadata tối thiểu; không chứa credential hoặc raw personal context thừa.

UC-19 là P0 baseline đúng theo SRS: Admin quản lý Exercise/Food và xem Audit Log tối thiểu.
User Management, Admin Dashboard, Import và AI Rule/Prompt thuộc UC-20/P1 và không được gộp vào UC-19.

**Dependencies:** PH1, PH4, PH5, PH7, PH9.

---

## 10. PH9 — Media & Storage

### 10.1. Mục tiêu và feature

Quản lý media Exercise/Food/profile; không lưu binary trong PostgreSQL.

| ID | Feature | Priority |
|---|---|---|
| FT-MD-001 | Exercise image/video media | P0 baseline |
| FT-MD-002 | Food image media | P0 baseline |
| FT-MD-003 | Media metadata/access | P0 baseline |
| FT-MD-004 | Thumbnail/resize/compress | P1 |
| FT-MD-005 | Orphan cleanup | P2 |

- P0 chấp nhận URL/object storage/CDN hoặc asset demo hợp lệ; không yêu cầu streaming nâng cao.
- Upload validate MIME, size, role/ownership và entity link.
- Metadata gồm object key/URL, content type, size, uploader, target và timestamps cần thiết.
- Quyền upload Food/Exercise thuộc admin baseline; user upload cần requirement riêng.
- Xóa/thay media không làm hỏng history; cleanup tự động là P2.

**Dependencies:** PH1. **Consumers:** PH2, PH4, PH5, PH8.

---

## 11. PH10 — Notification

### 11.1. Mục tiêu và feature

Notification không thuộc P0. Local/in-app reminder làm sau core; push/automation là mở rộng.

| ID | Feature | Priority |
|---|---|---|
| FT-NT-001 | Local/in-app notification | P1 |
| FT-NT-002 | Workout reminder | P1 |
| FT-NT-003 | Meal/weight reminder | P1 |
| FT-NT-004 | Reminder preference và read state | P1 |
| FT-NT-005 | Push/automated AI notification | P2 |

- User bật/tắt loại reminder được hỗ trợ.
- `LOG_REMINDER_ONLY` không mutation Workout/Meal/Health.
- Notification lỗi không làm thất bại transaction chính; retry có giới hạn.

**Dependencies:** PH1; nhận event từ PH3, PH4, PH5, PH7 khi triển khai.

---

## 12. Quan hệ phụ thuộc

```text
PH1 Identity & Auth
  ├──→ PH2 User Profile & Preference
  ├──→ PH3 Health & Body
  └──→ PH8/PH9 authorization

PH2 Equipment/Constraints ──→ PH4 Workout / PH5 Nutrition
PH3 Metrics/Targets ────────→ PH5 Nutrition

PH3 Health ─┐
PH4 Workout ├──→ PH6 Dashboard
PH5 Meal ───┤
PH7 AI ─────┘

PH2–PH5 authorized data ──→ PH7 Context/Rule/Recommendation
PH7 approved action ──────→ PH2/PH3/PH4/PH5 domain owner
PH7/domain mutation ──────→ PH8 Audit
PH9 Media ────────────────→ PH2/PH4/PH5
PH3/PH4/PH5/PH7 events ──→ PH10 Notification (P1+)
```

- Không module nào bypass owner để sửa trực tiếp dữ liệu domain.
- Dashboard chỉ aggregate/read, không sở hữu metric nguồn.
- AI context chỉ được Backend tạo sau consent/ownership check.
- Apply do Backend điều phối nhưng mutation nằm tại service domain tương ứng.
- Notification/audit là side effect có kiểm soát, không phải business authority.

---

## 13. Traceability MVP

| Business flow | SRS Use Case | Feature IDs | Owner | Priority |
|---|---|---|---|---|
| Register/Login/OTP | UC-01 | FT-ID-001..010 | PH1 | P0 |
| Health onboarding/recalculation | UC-02/03 | FT-HP-001..004 | PH3 | P0 |
| Equipment/User Preference | UC-04/18 | FT-UP-003..005, FT-WO-003 | PH2; PH4 consumer | P0 |
| Exercise Library | UC-04 | FT-WO-001..003 | PH4 | P0 |
| Program/Schedule | UC-05/06 | FT-WO-004/005 | PH4 | P0 |
| Session/Log/Progress | UC-07 | FT-WO-006..009/011 | PH4 | P0 |
| Food Database/Meal Planner | UC-08/09 | FT-MP-001..006/009 | PH5 | P0 |
| AI Meal Proposal | UC-09/13/14 | FT-MP-011, FT-AI-008..010 | PH5/PH7 | P0 |
| Weight Tracking | UC-10 | FT-HP-005..007 | PH3 | P0 |
| Dashboard | UC-11 | FT-DB-001..005/007 | PH6 | P0 |
| AI Consent/Coach | UC-12/17 | FT-AI-001..007/014 | PH7 | P0 |
| Recommendation/Apply/Dismiss | UC-13/14 | FT-AI-008..010 | PH7 + domain | P0 |
| Admin Exercise/Food/Audit | UC-19 | FT-AD-003/004/008 | PH8 | P0 baseline |
| Exercise/Food media | UC-21 | FT-MD-001..003 | PH9 | P0 baseline |
| Weekly Review/Plan Adjustment | UC-15/16 | FT-AI-011/012 | PH7 | P1 |
| Admin mở rộng | UC-20 | FT-AD-001/002/005..007/009 | PH8 | P1 |
| Local/in-app reminder | Optional flow | FT-NT-001..004 | PH10 | P1 |

### 13.1. Migration mã feature từ bản 2.0

- Equipment Preference chuẩn là `FT-UP-004`; `FT-WO-003` chỉ là matching/consumer logic.
- Fitness goal thuộc `FT-HP-001`, không còn là feature do PH2 sở hữu.
- AI history là `FT-AI-014` P0; summary/feedback nâng cao là `FT-AI-015` P1.
- Admin User Management chuẩn hóa về P1; P0 chỉ giữ Exercise/Food/Audit baseline.
- Tài liệu màn hình/luồng còn dùng mã cũ cần tham chiếu bảng migration này khi cập nhật.

---

## 14. Acceptance Criteria cấp MVP

| ID | Acceptance Criteria |
|---|---|
| AC-01 | User đăng ký/verify OTP/đăng nhập được; private API yêu cầu JWT hợp lệ |
| AC-02 | User chỉ truy cập Health/Meal/Workout/AI resource của mình |
| AC-03 | Health Profile hợp lệ tạo BMI/BMR/TDEE/calorie/macro target tại Backend |
| AC-04 | Sửa field nền Health Profile tính lại metric/target nhất quán |
| AC-05 | Equipment Preference ảnh hưởng ranking nhưng không sửa log cũ |
| AC-06 | Session chỉ chuyển trạng thái hợp lệ; Finish tạo log, Discard không tạo thành tích giả |
| AC-07 | CANCELLED bị loại khỏi mẫu số completion rate |
| AC-08 | Meal summary được Backend tính đúng theo serving/multiplier và target |
| AC-09 | WeightLog tạo history/trend nhưng không tự sửa Nutrition Target |
| AC-10 | Dashboard aggregate đúng nguồn và có empty/error state |
| AC-11 | Consent OFF không gửi personal context hoặc tạo recommendation cá nhân hóa |
| AC-12 | AI Service không truy cập database; context tuân thủ whitelist/minimization |
| AC-13 | AI output sai schema/business/safety không thành action hợp lệ |
| AC-14 | Daily Recommendation tạo 1–3 item PENDING khi đủ điều kiện |
| AC-15 | APPLY chỉ chạy với recommendation đúng user, còn PENDING/chưa hết hạn và action hợp lệ |
| AC-16 | DISMISS chỉ đổi status/feedback, không mutation domain data |
| AC-17 | Mutation sau APPLY do domain owner thực hiện và có audit |
| AC-18 | Media P0 hiển thị asset hợp lệ và enforce quyền/validation |
| AC-19 | Audit không chứa password, token, OTP, API key hoặc personal context thừa |

---

## 15. Phạm vi triển khai

### P0 — Bắt buộc

- PH1 Identity & Auth baseline.
- PH2 profile, preference, constraints và equipment.
- PH3 Health calculation và Weight Tracking.
- PH4 Exercise, Program, Schedule, Session, Log và progress.
- PH5 Food Database, Meal Planner và nutrition summary.
- PH6 Dashboard.
- PH7 Consent, Context, Rule Engine, Coach, Daily Recommendation, Apply/Dismiss và validation.
- PH8 Exercise/Food/Audit baseline.
- PH9 Exercise/Food media baseline.

### P1 — Sau khi P0 ổn định

- Preference Memory, Weekly Review, Plan Adjustment, conversation summary/feedback.
- Favorite/recent food, favorite exercise, Water Tracker và app settings.
- Admin dashboard/user/import/AI Rule/Prompt/metrics.
- Local/in-app reminder.

### P2/Future

- Push automation, media cleanup và offline queue nâng cao.
- Shop/Marketplace, Cart/Order/Payment.
- Wearable/health platform integration.
- Food recognition, pose estimation/computer vision và ML prediction.
- AI automatic mutation không cần user approval luôn ngoài phạm vi.

---

## 16. Definition of Done của tài liệu

Tài liệu hoàn thiện khi:

- Mọi P0 trong SRS có feature, owner, priority và acceptance criteria truy vết được.
- Mỗi dữ liệu/feature có một subsystem owner; consumer được ghi rõ.
- Priority thống nhất với business flow và phân hệ.
- Luồng stateful có state/transition và điều kiện lỗi chính.
- AI Consent, trust boundary, validation và Apply/Dismiss không cho AI tự mutation.
- Không biến gợi ý triển khai thành business rule nếu SRS chưa chốt.
- Dependency graph, traceability và mã feature không mâu thuẫn nội bộ.
- Out-of-scope không xuất hiện trong core MVP feature list.
- Markdown không có heading, table hoặc code block bị lỗi.
