# VieGym — Software Requirements Specification (SRS) v3.0

> **Mục đích:** Source of Truth cấp yêu cầu cho VieGym Mobile App, Backend và AI Service trong phạm vi đồ án tốt nghiệp.
>
> **Phiên bản:** 3.0  
> **Ngày cập nhật:** 2026-08-19  
> **Nền tảng MVP:** Flutter Mobile App + Spring Boot Backend + PostgreSQL + Python FastAPI AI Service
>
> **Cập nhật đồng bộ:** chuẩn hóa Admin P0/P1, canonical screen ID, Use Case UC-01..UC-21 và Acceptance Criteria AC-01..AC-19.

---

# 1. Tổng quan dự án

## 1.1. Tên dự án

**VieGym — Nền tảng luyện tập, dinh dưỡng và AI Coach cá nhân hóa**

## 1.2. Mục tiêu

VieGym kết hợp ba nhóm chức năng:

1. Quản lý luyện tập.
2. Quản lý dinh dưỡng và Meal Planner món Việt.
3. AI Coach cá nhân hóa dựa trên dữ liệu người dùng được cho phép sử dụng.

## 1.3. Core User Journey

1. User đăng ký/đăng nhập.
2. User hoàn thiện Health Profile và mục tiêu.
3. Backend tính BMI, BMR, TDEE, calories và macro mục tiêu.
4. User lập Meal Plan, ghi nhận bữa ăn, tạo lịch tập và Workout Log.
5. Dashboard tổng hợp tiến độ.
6. Khi AI personalization được bật, Backend tạo context tối thiểu theo tác vụ.
7. Rule Engine xác định các tín hiệu cần chú ý.
8. AI tạo giải thích/recommendation.
9. Backend validation/safety kiểm tra kết quả.
10. User xem, Apply hoặc Dismiss recommendation.
11. Nếu có thay đổi nghiệp vụ, Backend chỉ thực hiện sau khi User xác nhận.

## 1.4. Nguyên tắc kiến trúc cốt lõi

> **Backend calculates. AI interprets and recommends. User decides. Backend executes.**

- Backend là business authority và source of truth.
- AI Service không truy cập database trực tiếp.
- AI không tự mutation dữ liệu nghiệp vụ.
- User là người quyết định cuối cùng đối với thay đổi do AI đề xuất.

---

# 2. Phạm vi hệ thống

## 2.1. MVP bắt buộc

| Phân hệ | Chức năng |
|---|---|
| Authentication | Đăng ký, đăng nhập, JWT, Google Login, refresh token, OTP, quên mật khẩu, biometric unlock local |
| Health Profile | Thông tin sức khỏe, mục tiêu, mức vận động |
| Health Calculation | BMI, BMR, TDEE, calories/macro target |
| Dashboard | Calories, macro, workout, weight, AI recommendation |
| Exercise Library | Bài tập, nhóm cơ, thiết bị, video hướng dẫn, mô tả, lỗi sai thường gặp |
| Gym Equipment Preference | Chọn thiết bị có sẵn khi onboarding/lần đầu tập và chỉnh sửa trong Settings |
| Workout Builder | Tạo/chọn chương trình và buổi tập cơ bản |
| Workout Schedule | Lịch tập |
| Workout Log | Ghi nhận set/reps/weight và tiến độ |
| Food Database | Món ăn Việt Nam và thông tin dinh dưỡng |
| Meal Planner | Lập thực đơn, ghi nhận meal và nutrition |
| Weight Tracking | Lịch sử và xu hướng cân nặng |
| AI Consent | Bật/tắt AI personalization |
| AI Context Layer | Backend tạo context theo tác vụ |
| AI Coach Chat | Chat cá nhân hóa |
| AI Daily Recommendation | 1–3 recommendation/ngày |
| Recommendation Apply/Dismiss | User quyết định trước khi thay đổi dữ liệu |
| Admin & Audit baseline | Admin quản lý/hide Exercise, Food và xem Audit Log tối thiểu |
| Media baseline | Ảnh/video Exercise và ảnh Food qua URL/asset hoặc object storage hợp lệ |

## 2.2. MVP mở rộng nếu còn thời gian

- AI Weekly Review.
- User Preference Memory.
- Admin quản lý AI Rule/Prompt.
- AI Plan Adjustment Proposal.

## 2.3. MVP Priority

| Priority | Nhóm chức năng | Mục tiêu |
|---|---|---|
| P0 | Auth, Health Profile, Health Calculation, Dashboard cơ bản | Hoàn thiện tài khoản, hồ sơ và metric authoritative |
| P0 | Food Database, Meal Planner, Exercise Library, Equipment Preference, Workout Log | Chứng minh luồng ăn uống + luyện tập |
| P0 | AI Consent, AI Context, AI Coach, Daily Recommendation | Chứng minh AI personalization an toàn |
| P0 | Recommendation Apply/Dismiss, Ownership, Security baseline | Chứng minh AI không tự mutation và dữ liệu được bảo vệ |
| P0 baseline | Admin quản lý Exercise/Food và Audit Log | Đủ dữ liệu catalog và truy vết cho demo |
| P1 | Weekly Review, Plan Adjustment, Preference Memory, Admin mở rộng, notification local/in-app | Chỉ triển khai khi P0 ổn định |
| P2 | Push automation, offline queue nâng cao, media cleanup | Không bắt buộc cho demo MVP |

## 2.4. Ngoài MVP

- Shop/Marketplace.
- Cart/Order/Payment.
- Wearable integration.
- Apple Health/Google Fit.
- Food image recognition.
- Pose estimation/computer vision.
- ML prediction.
- AI tự động thay đổi kế hoạch không cần User approval.

---

# 3. Actors và Persona

## 3.1. Actor

| Actor | Vai trò |
|---|---|
| USER | Người dùng luyện tập, dinh dưỡng và sử dụng AI |
| ADMIN | Quản trị dữ liệu, AI rule/prompt và audit |
| AI PROVIDER | Provider LLM bên ngoài; chỉ được gọi bởi AI Service |

## 3.2. Persona demo

| Persona | Mục tiêu | Demo cần chứng minh |
|---|---|---|
| Người mới tập giảm cân | Giảm mỡ an toàn | Health Profile → calorie target → meal suggestion → daily recommendation |
| Người tập tăng cơ | Tăng cơ và theo dõi tiến bộ | Workout Log → volume/PR → protein gap → AI advice |
| Người duy trì sức khỏe | Duy trì cân nặng | Meal Planner món Việt → Dashboard → Daily Recommendation |

Persona phục vụ thiết kế, seed data và demo; hệ thống không hard-code logic theo persona.

---

# 4. Thuật ngữ và trạng thái chính

| Thuật ngữ | Ý nghĩa |
|---|---|
| BMI | Body Mass Index |
| BMR | Basal Metabolic Rate |
| TDEE | Total Daily Energy Expenditure |
| Macro | Protein, carbohydrate và fat |
| PR | Personal Record |
| RPE | Rating of Perceived Exertion |
| JWT | JSON Web Token |
| OTP | One-Time Password |
| PI | Personalization Intelligence |

## 4.1. Enum chính

### Account/Auth
- `UserRole`: USER, ADMIN
- `AuthProvider`: LOCAL, GOOGLE
- `OtpPurpose`: REGISTER, PASSWORD_RESET; `LOGIN_VERIFY` reserved P1/MFA
- `TokenStatus`: ACTIVE, REVOKED, EXPIRED

### Health/Nutrition
- `Gender`: MALE, FEMALE, OTHER, UNSPECIFIED
- `CalculationSex`: MALE, FEMALE, UNSPECIFIED
- `HealthCalculationStatus`: COMPLETE, INCOMPLETE
- `HealthIncompleteReason`: CALCULATION_SEX_REQUIRED, UNSUPPORTED_AGE, CALORIES_BELOW_SAFETY_THRESHOLD, INVALID_MACRO_RESULT
- `ActivityLevel`: SEDENTARY, LIGHT, MODERATE, ACTIVE, VERY_ACTIVE
- `FitnessGoal`: LOSE_WEIGHT, MAINTAIN_WEIGHT, GAIN_WEIGHT, GAIN_MUSCLE
- `MealType`: BREAKFAST, LUNCH, DINNER, SNACK
- `FoodVisibility`: PUBLIC, HIDDEN

### Workout
- `WorkoutProgramStatus`: ACTIVE, INACTIVE, ARCHIVED
- `WorkoutScheduleStatus`: PLANNED, COMPLETED, MISSED, CANCELLED
- `ExerciseDifficulty`: BEGINNER, INTERMEDIATE, ADVANCED
- `ExerciseVisibility`: PUBLIC, HIDDEN

### AI
- `AiConsentMode`: ENABLED, DISABLED
- `AiContextType`: CHAT, DAILY_RECOMMENDATION, WEEKLY_REVIEW, PLAN_ADJUSTMENT
- `AiRecommendationType`: NUTRITION, WORKOUT, RECOVERY, HABIT, PLAN
- `AiRecommendationStatus`: PENDING, APPLIED, DISMISSED, EXPIRED
- `AiPriority`: LOW, MEDIUM, HIGH
- `AiSafetyLevel`: NORMAL, CAUTION, BLOCKED

## 4.2. State machine

### Recommendation

```text
PENDING
  ├── APPLY hợp lệ → APPLIED
  ├── DISMISS → DISMISSED
  └── hết hạn → EXPIRED
```

Chỉ PENDING mới được APPLY/DISMISS.

### Workout Schedule

```text
PLANNED
  ├── hoàn thành → COMPLETED
  ├── quá hạn không hoàn thành → MISSED
  └── hủy hợp lệ → CANCELLED
```

CANCELLED không tính vào mẫu số completionRate nếu user hủy hợp lệ.

---

# 5. Functional Requirements

## 5.1. Authentication

- User có thể đăng ký, đăng nhập, refresh token, logout và reset password.
- Google Login được xử lý server-side qua Backend.
- Password không được lưu plaintext.
- OTP phải có expiry, resend cooldown và giới hạn attempts/rate limit.
- Refresh token phải có expiry, rotation theo mỗi lần refresh và revoke. Reuse token đã rotate phải làm vô hiệu token family theo policy bảo mật.
- Private API yêu cầu JWT hợp lệ.
- User chỉ truy cập resource thuộc chính mình.

## 5.2. Health Profile

User có thể quản lý:

- tuổi/ngày sinh.
- giới tính.
- calculation sex dùng riêng cho công thức BMR; có thể để UNSPECIFIED.
- chiều cao.
- cân nặng.
- activity level.
- fitness goal.
- training experience.

Backend chịu trách nhiệm tính:

- BMI.
- BMR.
- TDEE.
- calories target.
- macro target.

AI không thay thế các phép tính deterministic này.

## 5.3. Exercise Library

Mỗi Exercise P0 phải có:

- tên.
- nhóm cơ chính/phụ.
- thiết bị.
- độ khó.
- mô tả.
- video hướng dẫn.
- instruction steps.
- common mistakes.
- safety notes.

Video có thể dùng URL/object storage/CDN hoặc asset demo hợp lệ. MVP không yêu cầu streaming nâng cao.

## 5.4. Gym Equipment Preference

Flow:

```text
Onboarding / Lần đầu bắt đầu tập
        ↓
User chọn thiết bị
        ↓
Backend lưu UserPreference
        ↓
Exercise Library / Workout Builder ưu tiên bài phù hợp
        ↓
User có thể chỉnh trong Settings
```

Rules:

- Không yêu cầu chọn lại thiết bị ở mỗi buổi tập.
- Settings cho phép thêm/xóa/sửa/reset thiết bị.
- Thay đổi preference không làm thay đổi WorkoutLog cũ.
- Nếu chưa chọn thiết bị, ưu tiên BODYWEIGHT và bài không yêu cầu thiết bị đặc thù.
- Preset `Full Gym` tương ứng toàn bộ Equipment có `is_active=true` trong seed data tại thời điểm user lưu lựa chọn. Backend lưu tập ID cụ thể; việc Admin thêm Equipment mới sau đó không âm thầm thay đổi preference đã lưu.

Equipment tối thiểu:

`BODYWEIGHT, DUMBBELL, BARBELL, BENCH, CABLE_MACHINE, MACHINE, RESISTANCE_BAND, KETTLEBELL, PULL_UP_BAR, TREADMILL`

## 5.5. Workout Builder

Hỗ trợ:

- Push Pull Legs.
- Upper Lower.
- Full Body.
- Custom workout cơ bản.

Workout Builder ưu tiên bài tập phù hợp với `available_equipment`.

Nếu user không có thiết bị cần thiết:

1. Giảm độ ưu tiên bài đó.
2. Gợi ý bài thay thế cùng nhóm cơ.
3. Vẫn cho phép user tìm thủ công.

## 5.6. Workout Schedule

- User tạo/chọn chương trình.
- Có thể sinh lịch tập từ chương trình.
- Lịch có trạng thái PLANNED/COMPLETED/MISSED/CANCELLED.
- Một user chỉ được có tối đa một Workout Program `ACTIVE` tại một thời điểm.

## 5.7. Workout Log

User ghi:

- exercise.
- set.
- reps.
- weight.
- duration nếu có.
- completion.

Backend tính:

- volume.
- completion rate.
- PR.

Định nghĩa PR P0:

- `MAX_WEIGHT`: `weightKg` lớn nhất của một set `completed=true`.
- `MAX_REPS`: `reps` lớn nhất của một set `completed=true`.
- `MAX_VOLUME`: `reps × weightKg` lớn nhất của một set `completed=true`.
- Chỉ tính set thuộc Workout Session `COMPLETED`; nếu bằng record hiện tại thì giữ record cũ và `achievedAt` cũ.

Exercise bị ẩn vẫn giữ được lịch sử log nhưng không được thêm vào program mới.

## 5.8. Food Database

Food hỗ trợ:

- tên món.
- category.
- serving size.
- calories.
- protein.
- carbohydrate.
- fat.
- source/ghi chú dữ liệu.

Food Database nội bộ phải có đủ dữ liệu demo món Việt và không phụ thuộc hoàn toàn vào API bên ngoài.

## 5.9. Meal Planner

User có thể:

- tìm món.
- thêm món vào bữa.
- thay đổi serving.
- xem calories/macro.
- xem tổng ngày.
- lưu meal template.

Meal type tối thiểu:

`BREAKFAST, LUNCH, DINNER, SNACK`

Meal Planner hỗ trợ khẩu phần:

- tô/chén/phần.
- đơn vị phổ biến như quả, ly, miếng.
- gram.
- multiplier như 0.5, 1, 1.5, 2 phần.

Quy đổi gram chỉ khả dụng khi Food có `gramsPerServing`. Khi user nhập gram, Backend quy đổi
`servingMultiplier = inputGrams / gramsPerServing` và lưu snapshot cả giá trị user nhập
(`inputAmount`, `inputUnit`) lẫn serving/macro đã tính. Food không có quy đổi gram chỉ cho nhập
theo serving chuẩn; Mobile không tự ước lượng khối lượng một tô/chén/phần.

## 5.10. Weight Tracking

User có thể:

- thêm weight log.
- xem lịch sử.
- xem chart/trend.
- so sánh với goal.

Backend tính trend/summary trước khi gửi context cho AI.

## 5.11. Dashboard

Dashboard hiển thị:

### Nutrition
- target calories.
- consumed calories.
- remaining calories.
- protein/carbs/fat.

### Workout
- today's workout.
- next workout.
- weekly completion.

### Body
- current weight.
- BMI.
- progress.

### AI
- Daily Recommendation.
- short insight.
- action tiếp theo.

Mobile không tự tính lại các metric authoritative đã được Backend cung cấp.

## 5.12. User Preference

Có thể lưu:

- món không thích.
- dị ứng/ràng buộc do user khai báo.
- available equipment.
- thời gian tập.
- meal preference.
- apply/dismiss feedback.

Preference về dị ứng/ràng buộc được ưu tiên hơn recommendation tối ưu macro.

## 5.13. Admin

Phạm vi Admin được chia theo priority:

- **P0 baseline:** quản lý/hide Exercise, quản lý/hide Food và xem Audit Log tối thiểu.
- **P1:** quản lý User, Admin Dashboard, import CSV/Excel qua preview/validation, quản lý AI Rule, prompt version và xem AI recommendation metrics cơ bản.

Exercise/Food đã có history nên ưu tiên hide/soft-delete. Mọi thao tác quản trị quan trọng phải được phân quyền và ghi audit mà không lưu credential hoặc personal context dư thừa.

Shop/Order/Payment không thuộc MVP.

---

# 6. Business Rules và Calculation

## 6.1. BMI

```text
BMI = weightKg / (heightM * heightM)
```

## 6.2. BMR — Mifflin-St Jeor

```text
Nam: BMR = 10 * weightKg + 6.25 * heightCm - 5 * age + 5
Nữ:  BMR = 10 * weightKg + 6.25 * heightCm - 5 * age - 161
```

Mifflin–St Jeor là phép ước lượng theo biến số sex `MALE/FEMALE`. Trong P0:

- `calculationSex=MALE` dùng công thức Nam và `calculationSex=FEMALE` dùng công thức Nữ; field này tách biệt với `gender` dùng cho hồ sơ.
- `calculationSex=UNSPECIFIED` không bị Backend tự ánh xạ sang một công thức.
- Khi calculation sex chưa được cung cấp hoặc User dưới 18 tuổi, Backend vẫn tính BMI nhưng trả `BMR/TDEE/NutritionTarget = INCOMPLETE` với reason tương ứng.
- Mobile phải giải thích dữ liệu còn thiếu; không tự tính hoặc tự chọn công thức thay Backend.
- Công thức là giá trị ước lượng cho người trưởng thành và không thay thế đánh giá y khoa.

Tham chiếu công thức: [Mifflin et al., 1990](https://pubmed.ncbi.nlm.nih.gov/2305711/). Phạm vi sử dụng và cảnh báo sức khỏe tham chiếu [NIDDK Body Weight Planner](https://www.niddk.nih.gov/bwp).

## 6.3. TDEE

```text
TDEE = BMR * activityFactor
```

| Activity Level | Hệ số |
|---|---:|
| SEDENTARY | 1.2 |
| LIGHT | 1.375 |
| MODERATE | 1.55 |
| ACTIVE | 1.725 |
| VERY_ACTIVE | 1.9 |

## 6.4. Calories Target

| Goal | Offset P0 mặc định |
|---|---|
| LOSE_WEIGHT | TDEE - 400 kcal |
| MAINTAIN_WEIGHT | TDEE |
| GAIN_WEIGHT | TDEE + 400 kcal |
| GAIN_MUSCLE | TDEE + 300 kcal |

Đây là baseline deterministic phục vụ MVP, không phải chỉ định điều trị. Backend không công bố Nutrition Target khi input chưa đủ, calories target dưới 1.200 kcal/ngày, hoặc kết quả calculation không hữu hạn/dương. Trường hợp bị chặn trả trạng thái `INCOMPLETE` hoặc validation/safety error thay vì tự clamp âm thầm. Ngưỡng cảnh báo tham chiếu [NIDDK Diabetes Prevention guidance](https://www.niddk.nih.gov/health-information/diabetes/overview/preventing-type-2-diabetes/game-plan).

## 6.5. Macro Target

```text
proteinTargetGram = bodyWeightKg * proteinFactor
fatTargetGram = caloriesTarget * fatRatio / 9
carbTargetGram =
  (caloriesTarget - proteinTargetGram * 4 - fatTargetGram * 9) / 4
```

| Goal | Protein factor P0 | Fat ratio P0 |
|---|---:|---:|
| LOSE_WEIGHT | 2.0 g/kg | 25% |
| GAIN_MUSCLE | 2.0 g/kg | 25% |
| GAIN_WEIGHT | 1.6 g/kg | 25% |
| MAINTAIN_WEIGHT | 1.4 g/kg | 25% |

Backend tính bằng decimal, lưu calories và macro với tối đa hai chữ số thập phân; Mobile mặc định hiển thị calories làm tròn đến kcal và macro làm tròn đến gram. Nếu carb target âm hoặc cấu hình không hợp lệ, Backend phải trả validation/safety error và không lưu target; không tự điều chỉnh âm thầm.

Mọi phép tính Health dùng decimal và chỉ làm tròn `HALF_UP` đến hai chữ số thập phân ở bước cuối.
Tuổi là số năm tròn theo ngày sinh nhật, tính tại ngày nghiệp vụ trong timezone IANA của user.

## 6.6. Workout Calculation

```text
setVolume = reps * weightKg
exerciseVolume = sum(setVolume)
workoutVolume = sum(exerciseVolume)
completionRate =
  completedEligible / scheduledEligible
```

`scheduledEligible` gồm schedule của user trong cửa sổ báo cáo đã `COMPLETED` hoặc đã qua cuối
ngày + grace period theo profile timezone sau effective-state evaluation. `CANCELLED`, schedule
tương lai/chưa qua cutoff+grace và schedule có session active không thuộc mẫu số.

`completedEligible` là tập con có trạng thái `COMPLETED`. Dashboard mặc định dùng tuần hiện tại
từ Thứ Hai đến ngày nghiệp vụ. Khi `scheduledEligible = 0`, API trả `completionRate = null`.
Schedule chỉ được chuyển `CANCELLED` trước khi quá cutoff; lịch quá hạn phải trở thành `MISSED`
và không được cancel để thay đổi completion rate.

## 6.7. Meal Calculation

```text
entryCalories = foodCaloriesPerServing * servingMultiplier
entryProtein = foodProteinPerServing * servingMultiplier
entryCarbs = foodCarbsPerServing * servingMultiplier
entryFat = foodFatPerServing * servingMultiplier

dailyCalories = sum(entryCalories)
dailyProtein = sum(entryProtein)
dailyCarbs = sum(entryCarbs)
dailyFat = sum(entryFat)

remainingCalories = caloriesTarget - dailyCalories
remainingProtein = proteinTarget - dailyProtein
remainingCarbs = carbsTarget - dailyCarbs
remainingFat = fatTarget - dailyFat
```

Dữ liệu nutrition được hiển thị là giá trị tham khảo khi nguồn chỉ là ước lượng.

---

# 7. AI Requirements

## 7.1. AI Use Cases

| ID | Chức năng | Priority |
|---|---|---|
| AI-01 | AI Coach Chat | P0 |
| AI-02 | Workout advice | P0 |
| AI-03 | Nutrition advice | P0 |
| AI-04 | Daily Recommendation | P0 |
| AI-05 | Weekly Review | P1 |
| AI-06 | Plan Adjustment Proposal | P1 |
| AI-07 | Preference Memory | P1 |

## 7.2. AI được phép

- Hiểu câu hỏi tự nhiên.
- Giải thích dữ liệu.
- Tạo insight.
- Đưa recommendation.
- Đề xuất thay đổi.

## 7.3. AI không được phép

- Truy cập database trực tiếp.
- Tự sửa database.
- Tự thay đổi Meal Plan/Workout Schedule.
- Tự tính lại metric authoritative.
- Đưa chẩn đoán hoặc điều trị y tế.
- Truy cập user data khác.
- Yêu cầu password, token hoặc API key.

---

# 8. AI Architecture, Personalization và Trust Boundary

## 8.1. AI Decision Pipeline

```text
Flutter
  ↓
Spring Boot
  ↓
Authorization
  ↓
Consent Check
  ↓
Context Builder
  ↓
Rule Engine
  ↓
Prompt Builder
  ↓
FastAPI AI Service
  ↓
AI Provider
  ↓
Output Parser
  ↓
Schema Validation
  ↓
Business Validation
  ↓
Safety Validation
  ↓
Flutter
```

## 8.2. AI Trust Boundary

| Boundary | Rule |
|---|---|
| Mobile → Backend | Mobile gửi request/JWT; không gửi AI API key |
| Backend → AI Service | Chỉ gửi context đã authorize, consent-check và tối thiểu hóa |
| AI Service → Provider | Gọi provider server-side qua abstraction |
| AI Output → Backend | Output là response/proposal; Backend parse và validate |
| Backend → Database | Chỉ Backend có quyền mutation |

AI Service là **stateless decision-support component**, không phải business authority, database owner hay authorization layer.

## 8.3. Context Groups

| Context | Nội dung |
|---|---|
| Health | age, gender, height, weight, goal, activity |
| Health Metrics | BMI, BMR, TDEE, calories/macro target |
| Workout | schedule, recent logs, completion, PR |
| Nutrition | meal summary, calories/macro remaining |
| Weight | recent trend |
| Preference | dislikes, constraints, equipment, schedule |
| Conversation | recent messages + summary |
| Safety | thông tin chấn thương/y tế do user cung cấp khi được phép |

## 8.4. Context Whitelist

| Context Type | Context chính |
|---|---|
| CHAT | Recent messages, summary và dữ liệu liên quan câu hỏi |
| DAILY_RECOMMENDATION | Rule signals, nutrition ngày đích, workout ngày đích/tiếp theo, weight trend, preference cần thiết và candidate shortlist do Backend chọn |
| WEEKLY_REVIEW | Aggregated weekly metrics |
| PLAN_ADJUSTMENT | Current plan summary, targets, trends, constraints/preference |

Không gửi:

- raw database history không cần thiết.
- dữ liệu user khác.
- password/token/API key.
- mutation command trực tiếp.

### 8.4.1. Candidate shortlist

Structured action chỉ được tham chiếu ID nằm trong candidate shortlist do Backend dựng sau khi
đã kiểm tra ownership, visibility, allergy, dietary constraint và trạng thái hiện hành. Food
shortlist chứa tối đa 10 món; WorkoutDay shortlist chứa tối đa 7 ngày tập thuộc program ACTIVE.
AI trả ID ngoài shortlist phải bị Business Validation reject và không được persist thành
recommendation.

## 8.5. Context Budget

Ví dụ:

- Workout: 7–14 ngày gần nhất + summary.
- Weight: trend 7–30 ngày.
- Meal: hôm nay + summary gần đây.
- Conversation: recent messages + summary.

`AiContextSnapshot` có thể lưu:

- context_version.
- context_type.
- generated_at.
- data_hash.

---

# 9. Personalization Intelligence (PI)

PI là lớp nghiệp vụ cá nhân hóa, không nhất thiết là một model riêng trong MVP.

## 9.1. Nguồn dữ liệu

- Health Profile.
- Health Metrics.
- Workout.
- Nutrition.
- Weight.
- User Preference.
- Feedback từ Apply/Dismiss.

## 9.2. Nguyên tắc

- PI không mutation database trực tiếp.
- AI personalization chỉ sử dụng dữ liệu khi consent cho phép.
- Preference về dị ứng/ràng buộc phải được ưu tiên.
- Dữ liệu quá ít phải được nói rõ là giới hạn.
- Recommendation nên ưu tiên hành động nhỏ, có thể thực hiện ngay.
- Không ưu tiên bán hàng/supplement trong MVP.

## 9.3. Signals tối thiểu — `rules-v1`

| Signal | Điều kiện định lượng P0 | Priority | Cooldown |
|---|---|---|---|
| `nutrition_protein_gap` | Có target/meal data; giờ local ≥ 15:00; remaining protein > 30% target | MEDIUM | 1/ngày |
| `calories_over_target` | Có target/meal data; consumed calories > 110% target | MEDIUM | 1/ngày |
| `workout_today` | Có schedule `PLANNED` trong ngày nghiệp vụ | LOW | 1/ngày |
| `adherence_issue` | Cửa sổ 7 ngày có `scheduledEligible ≥ 2` và completionRate < 0.5 | HIGH | 1/3 ngày |
| `weight_trend_off_goal` | Có ≥ 2 điểm/14 ngày và thay đổi ngược goal ít nhất 0.5 kg | HIGH | 1/7 ngày |
| `meal_logging_drop` | User đã từng log meal và 3 ngày nghiệp vụ liên tiếp gần nhất không có MealEntry | LOW | 1/3 ngày |

`preference_conflict` là Business/Safety Validation sau AI output, không phải candidate signal.
Khi có trên ba signal, sắp theo priority `HIGH > MEDIUM > LOW`, sau đó theo signal code để kết
quả deterministic, và lấy tối đa ba. Có ít nhất một signal hợp lệ nghĩa là “đủ dữ liệu” cho
AC-14. Các ngưỡng thuộc `rules-v1`; thay đổi số phải tạo rule version mới và test vector mới.

Nguyên tắc:

> **Rule Engine quyết định WHAT. AI quyết định HOW.**

---

# 10. AI Consent và Privacy

## 10.1. AiConsentSetting

Các thuộc tính chính:

- user_id.
- enabled.
- consent_version.
- accepted_at.
- updated_at.

## 10.2. Khi ENABLE

Backend được phép sử dụng context cá nhân phù hợp với tác vụ và whitelist.

## 10.3. Khi DISABLE

AI hoạt động ở **General Knowledge Mode**:

- Chỉ trả lời kiến thức chung.
- Không dùng Health/Workout/Nutrition/Weight/Preference cá nhân làm context AI.
- Không tạo Daily Recommendation cá nhân hóa.
- Nếu user yêu cầu personalization, phải nói rõ cần bật personalization hoặc user cung cấp thông tin thủ công trong câu hỏi.

Consent phải được kiểm tra **trước Context Builder**.

## 10.4. Consent History

Nên lưu:

- previous_mode.
- new_mode.
- consent_version.
- changed_at.
- source.
- revoked_at nếu có.

---

# 11. AI Recommendation Workflow

## 11.1. Daily Recommendation

Backend tạo candidate signals từ:

- calories remaining.
- macro gap.
- workout schedule.
- workout adherence.
- weight trend.
- meal logging.
- preference.

AI tạo 1–3 recommendation.

P0 cho tối đa ba generation/ngày (lần đầu + hai refresh chủ động). Mỗi generation có 1–3 item;
khi generation mới thành công, item `PENDING` của generation cũ cùng ngày chuyển `EXPIRED`, còn
item đã `APPLIED`/`DISMISSED` được giữ làm lịch sử.

Recommendation có:

- type.
- title.
- content.
- reason.
- priority.
- status.
- source_metrics.
- created_at.
- expires_at.
- safety_level.

## 11.2. Recommendation State

```text
AI
 ↓
PENDING
 ↓
User
 ├── APPLY
 └── DISMISS
```

### APPLY

```text
User Approval
 ↓
Backend Authorization
 ↓
Business Validation
 ↓
Database Mutation
 ↓
Audit Log
```

### DISMISS

- Lưu trạng thái.
- Có thể lưu feedback.
- Có thể dùng feedback để điều chỉnh preference.

AI không được tự gọi mutation endpoint.

## 11.3. Allowed Action Contract

AI có thể trả proposal như:

- `NONE`
- `ADD_MEAL_ENTRY_PROPOSAL`
- `CREATE_WORKOUT_SCHEDULE_PROPOSAL`
- `UPDATE_USER_PREFERENCE_PROPOSAL`
- `REVIEW_NUTRITION_TARGET_PROPOSAL`
- `LOG_REMINDER_ONLY`

Mọi action phải:

1. Nằm trong whitelist.
2. Có payload hợp lệ.
3. Được Backend validate lại.
4. Chỉ mutation sau khi User APPLY.

Trong P0, `LOG_REMINDER_ONLY` là giá trị reserved và không được gửi trong `allowedActions` vì
Notification thuộc P1. Hai action `ADD_MEAL_ENTRY_PROPOSAL` và
`CREATE_WORKOUT_SCHEDULE_PROPOSAL` bắt buộc có `targetDate`; Apply phải validate ngày đích chưa
qua và resource liên quan vẫn hợp lệ. P0 khóa cửa sổ: Meal Entry chỉ cho đúng
`recommendationDate`; Workout Schedule cho khoảng từ `recommendationDate` đến tối đa 14 ngày
sau đó, tính theo profile timezone.

`UPDATE_USER_PREFERENCE_PROPOSAL` chỉ được sửa `disliked_foods`, `meal_preferences`,
`training_preferences` và `preferred_training_time`. AI không bao giờ được đề xuất sửa
`allergies` hoặc `dietary_constraints`; output như vậy bị reject trước UI và ghi validation log.

Không được chứa SQL, endpoint command, token, API key hoặc field ngoài whitelist.

---

# 12. AI Safety và Prompt Security

## 12.1. Safety

AI phải:

- tránh chẩn đoán bệnh.
- tránh kê thuốc.
- tránh cam kết điều trị.
- tránh khuyến nghị giảm cân cực đoan.
- cảnh báo khi user đề cập chấn thương hoặc dấu hiệu y tế nghiêm trọng.
- không tiết lộ dữ liệu user khác.
- không yêu cầu password/API key/token.
- không tự thay đổi dữ liệu nghiệp vụ.

Output bị Safety Validation đánh giá `BLOCKED` không được persist thành `AiRecommendation`; chỉ
lưu kết quả validation đã sanitize để audit/quan sát. Recommendation đã persist chỉ có
`NORMAL` hoặc `CAUTION`.

Tình huống y tế/chấn thương phải chuyển sang safe response và khuyến nghị tìm chuyên gia phù hợp.

## 12.2. Prompt Injection Boundary

- User message, imported data, food/exercise text và conversation history là untrusted input.
- Prompt Builder phải phân vùng system instruction, context, user message, rule signals và output schema.
- User input không được override authorization, consent, safety policy hoặc business rule.
- AI không được tiết lộ system prompt, internal context, credential hoặc dữ liệu user khác.
- Structured action phải qua allowed-action validation.

Prompt template có `prompt_version`.

---

# 13. AI Provider và Conversation Memory

## 13.1. Provider Abstraction

Business logic không phụ thuộc trực tiếp vào SDK/provider cụ thể.

Khả năng tối thiểu:

```text
generateResponse(request)
generateStructuredResponse(request, schema)
```

Lợi ích:

- dễ đổi provider.
- dễ mock khi test.
- giảm vendor lock-in.
- hỗ trợ fallback.

## 13.2. Conversation Memory

Entities chính:

- AiConversation.
- AiMessage.
- AiConversationSummary.

Flow:

```text
Old Messages
    ↓
Summary
    ↓
Recent Messages
    ↓
Current Context
    ↓
AI
```

Không gửi toàn bộ lịch sử chat trong mọi request.

---

# 14. Weekly Review và Plan Adjustment

## 14.1. Weekly Review — P1

Backend tạo aggregated metrics:

- average calories.
- average protein.
- workout completion.
- meal logging rate.
- weight change.
- progress trend.

AI tạo:

1. Summary.
2. Nutrition insight.
3. Workout insight.
4. Weight insight.
5. Strengths.
6. Improvement areas.
7. Next-week recommendations.

## 14.2. Plan Adjustment — P1

Plan Adjustment là **proposal**, không phải automatic mutation.

Có thể đề xuất:

- workout frequency.
- meal structure.
- calories/macro review.

Flow:

```text
AI Proposal
 ↓
PENDING
 ↓
User Review
 ├── APPLY
 └── DISMISS
```

Backend validate proposal trước khi apply.

---

# 15. Security và Non-functional Requirements

## 15.1. Security

| ID | Requirement | Priority |
|---|---|---|
| NFR-SEC-001 | Private API yêu cầu JWT và ownership check | P0 |
| NFR-SEC-002 | Password/refresh token/OTP được bảo vệ bằng hash, expiry, revoke và rate limit | P0 |
| NFR-SEC-003 | Google Login được verify server-side | P0 |
| NFR-SEC-004 | AI API key và provider credential chỉ nằm server-side | P0 |
| NFR-SEC-005 | Audit log không chứa password, token, API key hoặc raw personal context thừa | P0 |

## 15.2. Privacy

| ID | Requirement | Priority |
|---|---|---|
| NFR-PRIV-001 | AI personalization tuân thủ consent | P0 |
| NFR-PRIV-002 | AI context áp dụng data minimization | P0 |
| NFR-PRIV-003 | User có thể tắt personalization | P0 |
| NFR-PRIV-004 | Ownership được kiểm tra ở mọi private resource | P0 |

Baseline riêng cho môi trường đồ án tốt nghiệp:

- Chỉ sử dụng tài khoản và dữ liệu synthetic/demo; không mời người dùng thật nhập dữ liệu sức khỏe cá nhân.
- Reset/purge toàn bộ database và object-storage demo phải có runbook và được thực hiện trước khi bàn giao môi trường hoặc trong vòng 30 ngày sau khi kết thúc chấm đồ án.
- Self-service account deletion, legal retention và production account purge không thuộc P0.
- Trước khi chuyển sang pilot/production hoặc thu thập dữ liệu người dùng thật, bắt buộc có ADR/policy riêng cho retention, account deletion, backup expiry và quyền riêng tư.

## 15.3. Performance/Reliability

- P95 của các read API P0 phổ biến phải dưới 500 ms và error rate dưới 1% trong benchmark MVP; không tính thời gian AI Provider.
- Profile benchmark chuẩn: Docker Compose local được cấp 4 vCPU/8 GB RAM; PostgreSQL có 100 user, 40 Exercise, 80 Food và 90 ngày dữ liệu Workout/Meal/Weight cho user đo; 10 virtual users, warm-up 2 phút, đo liên tục 5 phút.
- Endpoint đo tối thiểu: Health Metrics, Exercise list, Food list, Weight Trend và Dashboard. Kết quả phải ghi commit, cấu hình máy, dataset, kịch bản và P50/P95/error rate để tái lập.
- AI provider timeout/failure phải có retry giới hạn và fallback an toàn.
- Docker Compose đủ cho môi trường demo.
- PostgreSQL là source of truth.
- Redis chỉ là thành phần hỗ trợ cache/rate limit nếu triển khai; core business không phụ thuộc Redis.

---

# 16. Use Cases chính

| ID | Use Case | Priority |
|---|---|---|
| UC-01 | Đăng ký/đăng nhập | P0 |
| UC-02 | Hoàn thiện Health Profile | P0 |
| UC-03 | Tính và xem Health Metrics | P0 |
| UC-04 | Exercise Library + Equipment Preference | P0 |
| UC-05 | Tạo Workout Program | P0 |
| UC-06 | Workout Schedule | P0 |
| UC-07 | Workout Log | P0 |
| UC-08 | Food Database | P0 |
| UC-09 | Meal Planner | P0 |
| UC-10 | Weight Tracking | P0 |
| UC-11 | Dashboard | P0 |
| UC-12 | AI Coach Chat | P0 |
| UC-13 | Daily Recommendation | P0 |
| UC-14 | Apply/Dismiss Recommendation | P0 |
| UC-15 | Weekly Review | P1 |
| UC-16 | Plan Adjustment | P1 |
| UC-17 | AI Consent | P0 |
| UC-18 | User Preference | P0 |
| UC-19 | Admin quản lý Exercise/Food và Audit Log | P0 baseline |
| UC-20 | Admin mở rộng: User/Import/AI Rule/Prompt | P1 |
| UC-21 | Media/Storage baseline cho Exercise/Food | P0 baseline |

## 16.1. Use Case chi tiết P0

### UC-01 — Authentication

**Actor:** Guest, User

**Luồng chính:**

1. Guest đăng ký local; Backend validate, hash password, tạo account PENDING và gửi OTP.
2. Guest verify OTP hợp lệ; Backend kích hoạt account rồi mới cấp access token + refresh token.
3. Hoặc Guest đăng nhập local/Google; Backend xác thực credential và account status trước khi cấp token.
4. Mobile lưu session credential được phép bằng secure storage.

**Luồng thay thế:** Email trùng, sai credential, OTP hết hạn, Google token không hợp lệ hoặc rate limit → lỗi chuẩn.

**Hậu điều kiện:** User có phiên hợp lệ.

### UC-02 — Health Profile

**Luồng chính:**

1. User nhập Health Profile.
2. Backend validate.
3. Backend tính Health Metrics.
4. Dashboard hiển thị kết quả.

**Hậu điều kiện:** HealthProfile và WeightLog ban đầu được lưu theo user; NutritionTarget chỉ
được lưu khi `calculationStatus=COMPLETE`.

### UC-03 — Health Metrics

1. User xem hoặc cập nhật Health Profile.
2. Backend validate các field nền.
3. Backend tính hoặc tính lại BMI, BMR, TDEE, calories và macro target trong cùng transaction.
4. Mobile chỉ hiển thị kết quả authoritative từ Backend.

**Luồng thay thế:** Thiếu dữ liệu bắt buộc hoặc kết quả vi phạm rule an toàn → không công bố target không hợp lệ và yêu cầu user bổ sung/chỉnh sửa dữ liệu.

### UC-04 — Exercise Library + Equipment

**Luồng chính:**

1. User chọn thiết bị trong onboarding/lần đầu tập.
2. Backend lưu UserPreference.
3. Exercise Library và Workout Builder ưu tiên bài phù hợp.
4. User có thể sửa equipment trong Settings.

**Hậu điều kiện:** Không phải chọn lại thiết bị ở mỗi buổi tập.

### UC-05 — Workout Program

1. User tạo/chọn loại chương trình PPL, Upper/Lower, Full Body hoặc Custom.
2. User thêm Workout Day và Exercise với sets, reps, rest, order và note.
3. Backend validate ownership, exercise visibility và dữ liệu đầu vào.
4. Backend lưu chương trình; một user có tối đa một program ACTIVE theo rule triển khai.

### UC-06 — Workout Schedule

1. User tạo lịch thủ công hoặc sinh lịch từ Workout Program.
2. Backend validate program, ngày tập và ownership.
3. Schedule bắt đầu ở trạng thái PLANNED.
4. Schedule chuyển sang COMPLETED, MISSED hoặc CANCELLED theo state machine hợp lệ.

### UC-07 — Workout Log

**Luồng chính:**

1. User chọn buổi tập.
2. Nhập set/reps/weight/duration.
3. Backend tính volume/completion/PR.
4. Dashboard cập nhật tiến độ.

Finish session phải tạo WorkoutLog và cập nhật schedule trong một transaction. Discard không tạo completed log, PR hoặc achievement giả.

### UC-08 — Food Database

1. User tìm hoặc lọc món ăn public/active.
2. Backend trả thông tin serving, calories, protein, carbohydrate, fat và nguồn dữ liệu.
3. User xem Food Detail hoặc chọn món để thêm vào Meal Plan.

Food bị hidden vẫn giữ history nhưng không được chọn cho Meal Entry mới.

### UC-09 — Meal Planner

**Luồng chính:**

1. User tìm món.
2. Chọn serving.
3. Thêm vào meal.
4. Backend tính tổng calories/macros và remaining target.

### UC-10 — Weight Tracking

1. User thêm hoặc cập nhật WeightLog thuộc chính mình.
2. Backend lưu history và tính trend/summary 7–30 ngày.
3. Mobile hiển thị chart/progress và so sánh với goal.

WeightLog hằng ngày không tự thay đổi NutritionTarget.

WeightLog của ngày mới nhất là nguồn cân nặng hiện tại: Backend đồng bộ
`HealthProfile.currentWeightKg` và tính lại BMI/BMR/TDEE trong cùng transaction, nhưng không tự
đổi NutritionTarget. Sửa log cũ không làm thay đổi metric hiện tại.

### UC-11 — Dashboard

Mobile gọi dashboard endpoint; Backend tổng hợp nutrition, workout, body và AI recommendation. Mobile không tự tính lại metric authoritative.

### UC-12 — AI Coach

**Luồng chính:**

1. Backend kiểm tra consent.
2. Context Builder tạo context tối thiểu.
3. Rule Engine tạo signals.
4. AI Service tạo câu trả lời.
5. Backend validate/safety.
6. Trả response cho Mobile.

**Consent OFF:** General Knowledge Mode.

### UC-13 — Daily Recommendation

1. Backend tạo candidate signals và candidate shortlist hợp lệ.
2. Client gọi command generate; AI tạo 1–3 recommendation. Dashboard và endpoint đọc không gọi provider.
3. Validation kiểm tra schema/business/safety.
4. Dashboard hiển thị PENDING.

### UC-14 — Apply/Dismiss

**APPLY:** Authorization → Business Validation → Mutation → Audit.

**DISMISS:** Lưu trạng thái/feedback, không mutation business data.

### UC-17 — AI Consent

User bật/tắt personalization. Backend lưu consent version và thời gian thay đổi. Trạng thái consent được kiểm tra trước Context Builder.

### UC-18 — User Preference

User xem/cập nhật món không thích, ràng buộc/dị ứng tự khai báo, meal preference, thời gian tập và equipment. Preference vẫn được lưu khi consent OFF nhưng chỉ được đưa vào AI context khi consent ON và đúng whitelist.

### UC-19 — Admin Exercise/Food/Audit baseline

1. Backend xác thực JWT và role ADMIN.
2. Admin tạo/sửa/hide Exercise hoặc Food phục vụ catalog demo.
3. Backend validate dữ liệu, media và reference history.
4. Backend ghi Audit Log cho thao tác quan trọng.

User Management, Admin Dashboard, Import và AI Rule/Prompt không thuộc slice P0 này.

### UC-21 — Media/Storage baseline

1. Admin khởi tạo upload cho ảnh/video Exercise hoặc ảnh Food.
2. Backend kiểm tra role, target, MIME, extension và size rồi cấp presigned URL TTL ngắn hoặc nhận asset demo hợp lệ.
3. Client upload object và gọi upload-complete.
4. Backend xác minh object/metadata trước khi chuyển media sang READY và liên kết với entity.

PostgreSQL chỉ lưu metadata/object key; không lưu binary media nghiệp vụ.

---

# 17. Acceptance Criteria

| ID | Acceptance Criteria |
|---|---|
| AC-01 | User đăng ký, verify OTP và đăng nhập được; private API yêu cầu JWT hợp lệ |
| AC-02 | User chỉ truy cập Health/Meal/Workout/AI/Media private resource của mình |
| AC-03 | Health Profile hợp lệ tạo BMI/BMR/TDEE/calorie/macro target tại Backend |
| AC-04 | Sửa field nền Health Profile tính lại metric/target nhất quán trong transaction |
| AC-05 | Equipment Preference ảnh hưởng ranking nhưng không sửa WorkoutLog cũ |
| AC-06 | Workout Session chỉ chuyển trạng thái hợp lệ; Finish tạo log, Discard không tạo thành tích giả |
| AC-07 | CANCELLED bị loại khỏi mẫu số completion rate |
| AC-08 | Meal summary được Backend tính đúng theo serving/multiplier và NutritionTarget |
| AC-09 | WeightLog tạo history/trend nhưng không tự sửa NutritionTarget |
| AC-10 | Dashboard aggregate đúng nguồn và có loading/empty/error state |
| AC-11 | Consent OFF không gửi personal context hoặc tạo Daily Recommendation cá nhân hóa |
| AC-12 | AI Service không truy cập database; context tuân thủ ownership, whitelist và data minimization |
| AC-13 | AI output sai schema/business/safety không trở thành structured action hợp lệ |
| AC-14 | Daily Recommendation tạo 1–3 item PENDING khi đủ dữ liệu |
| AC-15 | APPLY chỉ chạy với recommendation đúng user, còn PENDING, chưa hết hạn và action hợp lệ |
| AC-16 | DISMISS chỉ đổi status/feedback, không mutation domain data |
| AC-17 | Mutation sau APPLY do domain owner thực hiện atomically và có audit |
| AC-18 | Media P0 hiển thị asset hợp lệ và enforce role/ownership/MIME/size validation |
| AC-19 | Audit/log không chứa password, token, OTP, API key hoặc personal context dư thừa |

---

# 18. Traceability rút gọn

| Requirement | Use Case | Acceptance |
|---|---|---|
| Authentication | UC-01 | AC-01 |
| Ownership | UC-04/07/09/10/14/19 | AC-02 |
| Health Calculation/Recalculation | UC-02/03 | AC-03/04 |
| Equipment matching | UC-04 | AC-05 |
| Workout Session/Progress | UC-05/06/07 | AC-06/07 |
| Nutrition | UC-08/09 | AC-08 |
| Weight Tracking | UC-10 | AC-09 |
| Dashboard | UC-11 | AC-10 |
| AI Consent | UC-17 | AC-11 |
| AI Context/Trust Boundary | UC-12/13 | AC-12 |
| AI Validation | UC-12/13/14 | AC-13 |
| Daily Recommendation | UC-13 | AC-14 |
| Recommendation Apply/Dismiss | UC-14 | AC-15/16/17 |
| Media | UC-21 | AC-18 |
| Admin/Audit | UC-19 | AC-19 |

---

# 19. Kiến trúc hệ thống cấp cao

```text
┌───────────────────────────────┐
│       Flutter Mobile App      │
│ Auth / Health / Workout /     │
│ Nutrition / Dashboard / AI    │
└───────────────┬───────────────┘
                │ REST API
                ▼
┌───────────────────────────────┐
│        Spring Boot API        │
│ Auth / Business Logic /       │
│ Calculation / Ownership /     │
│ Context / Rule / Validation   │
└───────┬───────────────┬───────┘
        │               │
        ▼               ▼
┌───────────────┐   ┌────────────────┐
│ PostgreSQL    │   │ FastAPI AI      │
│ Source of     │   │ AI Service      │
│ Truth         │   │ Stateless       │
└───────────────┘   └───────┬────────┘
                            │
                            ▼
                     ┌──────────────┐
                     │ AI Provider  │
                     │ LLM          │
                     └──────────────┘
```

## 19.1. Responsibility Boundary

| Component | Responsibility |
|---|---|
| Flutter | UI, local state, secure token storage, presentation |
| Spring Boot | Business authority, calculation, authorization, ownership, context, rule, validation, mutation |
| PostgreSQL | Business data source of truth |
| FastAPI AI Service | AI orchestration/stateless decision support |
| AI Provider | LLM inference |

---

# 20. Data Model cấp cao

Các entity chính:

```text
User
 ├── HealthProfile
 ├── WeightLog
 ├── NutritionTarget
 ├── UserPreference
 ├── WorkoutProgram
 ├── WorkoutSchedule
 ├── WorkoutLog
 ├── MealPlan
 ├── AiConsentSetting
 ├── AiConversation
 │    ├── AiMessage
 │    └── AiConversationSummary
 └── AiRecommendation

Exercise
 └── Equipment

WorkoutProgram
 └── WorkoutDay
      └── WorkoutExercise

MealPlan
 └── Meal
      └── MealEntry

Food
```

Database schema chi tiết, field-level validation và index được quản lý trong **Database Specification**, không lặp lại trong SRS.

---

# 21. API và Integration Boundary

- Mobile giao tiếp với Spring Boot qua REST API version `/api/v1`.
- Spring Boot là API chính cho Mobile.
- AI Service không được Mobile gọi trực tiếp trong MVP.
- AI provider credential chỉ nằm server-side.
- API private yêu cầu authentication/authorization.
- API contract chi tiết, request/response schema và error code được quản lý trong **API Specification**.

---

# 22. Testing Strategy cấp cao

## Unit Test

- Health calculation.
- Nutrition calculation.
- Workout calculation.
- Rule Engine.
- Validation.

## API/Integration Test

- Authentication.
- Ownership.
- Meal/Workout CRUD.
- AI consent.
- Recommendation Apply/Dismiss.

## AI Test

- Context whitelist.
- Consent OFF.
- Invalid structured output.
- Prompt injection.
- Safety scenarios.
- Provider failure/fallback.

## E2E Demo Flow

```text
Register/Login
    ↓
Health Profile
    ↓
Health Metrics
    ↓
Equipment Preference
    ↓
Workout
    ↓
Meal Planner
    ↓
Dashboard
    ↓
AI Consent
    ↓
AI Coach
    ↓
Daily Recommendation
    ↓
Apply/Dismiss
```

Test Plan chi tiết được quản lý riêng.

---

# 23. Deployment và Demo Scope

MVP demo có thể triển khai bằng Docker Compose:

```text
Flutter App
     ↓
Spring Boot
     ├── PostgreSQL
     └── FastAPI AI Service
              ↓
         AI Provider
```

Yêu cầu demo:

- Có seed/demo users.
- Có tối thiểu 40 Exercise, bao phủ chest/back/shoulders/arms/legs/core và ít nhất 6 nhóm equipment; mỗi record có muscle group, difficulty, instruction và safety note.
- Có tối thiểu 80 Food món Việt, bao phủ 4 meal type và ít nhất 8 category; mỗi record có serving, calories, protein, carbohydrate, fat và source/note.
- Tất cả code/slug hoặc normalized name dùng cho seed là duy nhất; seed chạy lại không tạo bản ghi trùng.
- Mọi Exercise/Food xuất hiện trong demo flow có URL/asset media hợp lệ; tối thiểu 20 Exercise và 20 Food có media để kiểm tra catalog.
- Seed có thể chạy lại ổn định.
- Swagger/OpenAPI cho Backend.
- Có thể chạy toàn bộ stack trong môi trường demo.

Production hardening nằm ngoài MVP.

---

# 24. Out of Scope và Future Scope

## Out of Scope

- Shop/Marketplace.
- Payment.
- Wearables.
- Apple Health/Google Fit.
- Computer Vision.
- Pose estimation.
- Food image recognition.
- ML prediction.
- Automatic plan mutation.
- Thu thập dữ liệu sức khỏe của người dùng thật trong môi trường đồ án.
- Self-service account deletion và legal-retention workflow cho production.

## Future Scope

- AI Weekly Review nâng cao.
- AI Plan Adjustment.
- Preference Memory nâng cao.
- Notification nâng cao.
- Offline queue nâng cao.
- Wearable integration.
- Computer Vision.
- ML prediction.
- Marketplace/Supplement ecosystem.

---

# 25. Tài liệu liên quan

Để tránh SRS trở thành tài liệu quá dài, chi tiết triển khai và traceability được quản lý trong các tài liệu hiện có:

| Tài liệu | Nội dung |
|---|---|
| [`bussiness_mainflow.md`](bussiness_mainflow.md) | Luồng nghiệp vụ end-to-end và demo flow |
| [`phan_ra_phan_he_he_thong.md`](phan_ra_phan_he_he_thong.md) | Phân hệ, ownership và dependency |
| [`phan_ra_tinh_nang.md`](phan_ra_tinh_nang.md) | Feature ID, priority và acceptance behavior |
| [`phan_ra_man_hinh.md`](phan_ra_man_hinh.md) | Màn hình, điều hướng, UI state và API mapping |
| [`../kientruchethong/API_SPEC.md`](../kientruchethong/API_SPEC.md) | Endpoint, request/response, error code và authentication |
| [`../kientruchatang/DATABASE.md`](../kientruchatang/DATABASE.md) | ERD, entity, field, FK, index và constraint |
| [`../kientruchethong/sa.md`](../kientruchethong/sa.md) | Kiến trúc hệ thống, AI trust boundary và security |
| [`../kientruchatang/server.md`](../kientruchatang/server.md) | Triển khai server, runtime và vận hành |
| [`../kientruchatang/techstack.md`](../kientruchatang/techstack.md) | Technology baseline và quyết định cần khóa khi bootstrap |

**SRS này chỉ giữ yêu cầu, business rules, architecture boundary và acceptance criteria cần thiết để làm Source of Truth của đồ án.**

---

# 26. Definition of Done cấp hệ thống

VieGym MVP được xem là đạt mức demo khi:

- Authentication hoạt động.
- Health Profile và Health Calculation hoạt động.
- Exercise Library và Equipment Preference hoạt động.
- Workout Builder/Schedule/Log hoạt động ở mức P0.
- Food Database và Meal Planner hoạt động.
- Weight Tracking và Dashboard hoạt động.
- AI Consent hoạt động.
- AI Context được tạo ở Backend.
- AI Service không truy cập Database.
- AI Coach hoạt động ở General Knowledge Mode và Personalized Mode theo consent.
- Daily Recommendation có validation.
- Recommendation APPLY/DISMISS có Backend authorization.
- AI không tự mutation.
- Private resources có ownership check.
- Admin quản lý Exercise/Food và xem Audit Log ở mức P0 baseline.
- Exercise/Food media hợp lệ, có kiểm tra quyền và validation tối thiểu.
- Các acceptance criteria AC-01..AC-19 có test tương ứng ở đúng tầng.
- Demo flow chạy end-to-end.
