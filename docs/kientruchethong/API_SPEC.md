# API Specification — VieGym

> REST API contract cho ứng dụng quản lý luyện tập, dinh dưỡng món Việt và AI Coach có kiểm soát.
> Tài liệu được thiết kế để triển khai bằng Spring Boot và sinh OpenAPI 3/Swagger.
>
> Ký hiệu: 🔓 Public | 🔒 Authenticated/owner | 👑 Admin only | `[P1]` Sau khi P0 ổn định

---

## 1. Global Standards & Conventions

### 1.1. Base URL và versioning

```text
Development: http://localhost:8080/api/v1
Production:  https://api.viegym.example.com/api/v1
```

- Mobile chỉ gọi Spring Boot qua HTTPS; không gọi FastAPI AI Service hoặc AI provider trực tiếp.
- Breaking change phải tạo API version mới. Field bổ sung trong `v1` phải backward-compatible.
- Các path bên dưới đã bỏ prefix `/api/v1` cho ngắn gọn.

### 1.2. Media type, naming và đơn vị

- Request/response dùng `application/json; charset=utf-8`, trừ PUT file vào presigned URL.
- JSON field dùng `camelCase`; database dùng `snake_case`.
- ID public là số nguyên 64-bit dương.
- Timestamp dùng ISO-8601 UTC, ví dụ `2026-08-19T08:30:00Z`.
- Ngày nghiệp vụ dùng `YYYY-MM-DD` theo timezone của user; giờ dùng `HH:mm:ss`.
- Khối lượng: `kg`; chiều cao: `cm`; thời lượng: giây; năng lượng: `kcal`; macro: gram.
- Decimal được truyền dưới dạng JSON number. Backend dùng decimal chính xác, không dùng giá trị client tính làm source of truth.

**Ngày nghiệp vụ và timezone:** `user_profiles.timezone` (IANA) là nguồn authoritative cho
“hôm nay”, cutoff, expiry và background/lazy evaluation; fallback là `Asia/Ho_Chi_Minh`. Client
gửi `date`/`loggedDate`/`scheduledDate`/`targetDate` tường minh khi browse hoặc mutation. Device
timezone chỉ dùng hiển thị và không tự thay đổi nghĩa dữ liệu server. Đổi timezone profile chỉ
ảnh hưởng boundary tương lai, không viết lại local date đã lưu.

### 1.3. Authentication, session và authorization

- Endpoint private nhận `Authorization: Bearer <accessToken>`.
- Access token JWT ngắn hạn; refresh token được rotation/revoke và chỉ lưu an toàn trên thiết bị.
- OTP, password, access/refresh token và presigned URL còn hiệu lực không được ghi log.
- Role `USER` và `ADMIN` không thay thế ownership check. Resource riêng tư luôn được scope theo subject trong JWT.
- Admin không mặc định được đọc Health, Meal, Workout, conversation hoặc recommendation riêng tư của user.
- Google ID token chỉ được Backend verify server-side.

### 1.4. Request headers

| Header | Bắt buộc | Mô tả |
|---|:---:|---|
| `Authorization` | Private API | `Bearer <JWT>` |
| `Content-Type` | Request có body | `application/json` |
| `Accept-Language` | Không | Ưu tiên `vi-VN` |
| `X-Correlation-Id` | Không | Client có thể gửi UUID; server sinh nếu thiếu và echo lại |
| `Idempotency-Key` | Apply recommendation, khuyến nghị cho create/action | Chuỗi duy nhất tối đa 100 ký tự |

### 1.5. Response envelope

Mọi JSON endpoint trả envelope thống nhất.

**Success:**

```json
{
  "success": true,
  "message": "Operation successful",
  "data": {}
}
```

Mọi response echo `X-Correlation-Id` header. Header là nguồn correlation canonical; body chỉ lặp
`correlationId` trong error để hỗ trợ báo lỗi. Success không thêm timestamp/correlation trùng lặp.

**Pagination (page zero-based):**

```json
{
  "success": true,
  "data": {
    "content": [],
    "page": 0,
    "size": 20,
    "totalElements": 42,
    "totalPages": 3,
    "hasNext": true
  }
}
```

**Error:**

```json
{
  "success": false,
  "code": "VALIDATION_ERROR",
  "message": "Request data is invalid",
  "data": null,
  "errors": [
    { "field": "heightCm", "code": "POSITIVE", "message": "heightCm must be greater than 0" }
  ],
  "correlationId": "2b651bb2-154f-4c90-8c70-cb182d741a27",
  "timestamp": "2026-08-19T08:30:00Z"
}
```

Không trả stack trace, SQL, provider credential hoặc chi tiết nội bộ trong error.
Mọi list phân trang luôn nằm trong `data.content` cùng metadata; không endpoint nào trả page ở
top-level hoặc mảng trần thay cho cấu trúc này.

### 1.6. Pagination, sorting và filter

- Query chung: `page=0`, `size=20`, `sort=createdAt,desc`.
- `size` mặc định `20`, tối đa `100`.
- Date range dùng `from`, `to` và bao gồm cả hai đầu; reject nếu `from > to`.
- Search text dùng `q`, trim hai đầu; endpoint tự quy định độ dài tối thiểu.
- Sort field phải thuộc allowlist của từng endpoint; không chuyển raw field từ client vào SQL.

### 1.7. HTTP status

| Code | Khi sử dụng |
|---:|---|
| `200` | GET/PUT/action thành công |
| `201` | Tạo resource thành công |
| `202` | Tác vụ bất đồng bộ đã được nhận |
| `204` | Xóa thành công, không có body |
| `400` | JSON/query/validation hoặc transition không hợp lệ |
| `401` | Thiếu, sai hoặc hết hạn credential |
| `403` | Không đủ role/quyền; AI consent không cho phép tác vụ |
| `404` | Resource không tồn tại hoặc không được tiết lộ do ownership |
| `409` | Duplicate, stale state, active session hoặc idempotency conflict |
| `410` | Resource/token upload đã hết hạn và không còn dùng được |
| `413` | Media vượt giới hạn cấu hình |
| `415` | MIME/extension không hỗ trợ |
| `422` | Request đúng cú pháp nhưng vi phạm business/safety rule |
| `429` | Rate limit/OTP cooldown; có `Retry-After` khi xác định được |
| `502` | AI/storage/email provider trả lỗi không hợp lệ |
| `503` | Dependency tạm thời không sẵn sàng |

### 1.8. Error codes và HTTP status

| Code | HTTP | Ý nghĩa |
|---|---:|---|
| `VALIDATION_ERROR` | 400 | Field/query không hợp lệ |
| `UNAUTHENTICATED`, `TOKEN_EXPIRED`, `TOKEN_REVOKED`, `INVALID_CREDENTIALS` | 401 | Credential/session không hợp lệ |
| `ACCESS_DENIED`, `ACCOUNT_PENDING`, `ACCOUNT_LOCKED`, `ACCOUNT_DISABLED`, `AI_CONSENT_REQUIRED` | 403 | Không đủ quyền/trạng thái không cho phép |
| `RESOURCE_NOT_FOUND`, `EXERCISE_NOT_FOUND`, `FOOD_NOT_FOUND`, `RESOURCE_HIDDEN` | 404 | Không tồn tại hoặc không tiết lộ |
| `EMAIL_ALREADY_EXISTS`, `ACTIVE_PROGRAM_EXISTS`, `ACTIVE_SESSION_EXISTS`, `INVALID_STATE_TRANSITION`, `SCHEDULE_NO_LONGER_PLANNED`, `DAY_HAS_PLANNED_SCHEDULES`, `RECOMMENDATION_NOT_PENDING`, `RECOMMENDATION_EXPIRED`, `IDEMPOTENCY_CONFLICT` | 409 | Duplicate/stale/conflict |
| `OTP_INVALID`, `OTP_EXPIRED` | 400 | OTP sai/hết hạn |
| `OTP_ATTEMPTS_EXCEEDED`, `OTP_COOLDOWN`, `RATE_LIMITED`, `DAILY_GENERATION_LIMIT_REACHED` | 429 | Vượt ngưỡng/cooldown; có `Retry-After` |
| `PASSWORD_CHANGE_NOT_SUPPORTED`, `HEALTH_PROFILE_REQUIRED`, `HEALTH_CALCULATION_UNAVAILABLE`, `SESSION_LOG_INVALID`, `FOOD_NOT_SELECTABLE`, `MEAL_TEMPLATE_ITEM_UNAVAILABLE`, `PROPOSAL_TARGET_INVALID` | 422 | Business/safety precondition |
| `AI_PROVIDER_UNAVAILABLE`, `AI_OUTPUT_INVALID` | 502 | AI/provider output không dùng được |
| `MEDIA_SIZE_EXCEEDED` | 413 | Media quá kích thước |
| `MEDIA_TYPE_NOT_SUPPORTED`, `MEDIA_MIME_MISMATCH` | 415 | Media type/MIME không hợp lệ |
| `UPLOAD_NOT_COMPLETED` | 409 | Upload chưa hoàn tất |
| `UPLOAD_EXPIRED` | 410 | Upload URL/TTL hết hạn |

Một error code chỉ ánh xạ tới một HTTP status trên toàn hệ thống. UI map hành vi theo `code`,
không parse `message`. Output safety `BLOCKED` không tạo recommendation nên không có
`RECOMMENDATION_BLOCKED` trong luồng P0.

### 1.9. Shared enums

| Enum | Values |
|---|---|
| `UserRole` | `USER`, `ADMIN` |
| `AccountStatus` | `PENDING`, `ACTIVE`, `LOCKED`, `DISABLED` |
| `AuthProvider` | `LOCAL`, `GOOGLE` |
| `OtpPurpose` | `REGISTER`, `PASSWORD_RESET`; `LOGIN_VERIFY` reserved ngoài P0 |
| `Gender` | `MALE`, `FEMALE`, `OTHER`, `UNSPECIFIED` |
| `CalculationSex` | `MALE`, `FEMALE`, `UNSPECIFIED` |
| `HealthCalculationStatus` | `COMPLETE`, `INCOMPLETE` |
| `HealthIncompleteReason` | `CALCULATION_SEX_REQUIRED`, `UNSUPPORTED_AGE`, `CALORIES_BELOW_SAFETY_THRESHOLD`, `INVALID_MACRO_RESULT` |
| `ActivityLevel` | `SEDENTARY`, `LIGHT`, `MODERATE`, `ACTIVE`, `VERY_ACTIVE` |
| `FitnessGoal` | `LOSE_WEIGHT`, `MAINTAIN_WEIGHT`, `GAIN_WEIGHT`, `GAIN_MUSCLE` |
| `TrainingExperience` | `BEGINNER`, `INTERMEDIATE`, `ADVANCED` |
| `ProgramStatus` | `ACTIVE`, `INACTIVE`, `ARCHIVED` |
| `ScheduleStatus` | `PLANNED`, `COMPLETED`, `MISSED`, `CANCELLED` |
| `SessionStatus` | `IN_PROGRESS`, `PAUSED`, `COMPLETED`, `DISCARDED` |
| `Difficulty` | `BEGINNER`, `INTERMEDIATE`, `ADVANCED` |
| `MealType` | `BREAKFAST`, `LUNCH`, `DINNER`, `SNACK` |
| `FoodVisibility` | `PUBLIC`, `HIDDEN` |
| `ConsentMode` | `ENABLED`, `DISABLED` |
| `RecommendationType` | `NUTRITION`, `WORKOUT`, `RECOVERY`, `HABIT`, `PLAN` |
| `RecommendationStatus` | `PENDING`, `APPLIED`, `DISMISSED`, `EXPIRED` |
| `AiPriority` | `LOW`, `MEDIUM`, `HIGH` |
| `AiSafetyLevel` | Provider/validation: `NORMAL`, `CAUTION`, `BLOCKED`; persisted recommendation: `NORMAL`, `CAUTION` |
| `AllowedAction` | P0: `NONE`, `ADD_MEAL_ENTRY_PROPOSAL`, `CREATE_WORKOUT_SCHEDULE_PROPOSAL`, `UPDATE_USER_PREFERENCE_PROPOSAL`, `REVIEW_NUTRITION_TARGET_PROPOSAL`; `LOG_REMINDER_ONLY` reserved P1 |

---

## 2. Identity & Authentication

### `POST /auth/register` 🔓

Tạo local account `PENDING` và gửi OTP `REGISTER`. Chưa cấp token.

```json
{
  "displayName": "Nguyễn Minh An",
  "email": "an@example.com",
  "password": "StrongPassword123!"
}
```

**201:**

```json
{
  "success": true,
  "message": "Verification instructions have been sent if the address is eligible",
  "data": {
    "challengeId": "otp_7b9d8f",
    "maskedDestination": "a***@example.com",
    "purpose": "REGISTER",
    "expiresAt": "2026-08-19T08:40:00Z",
    "resendAvailableAt": "2026-08-19T08:31:00Z"
  }
}
```

Email được lowercase/trim. Password policy do cấu hình server công bố; password/confirm password không bao giờ được echo.

### `POST /auth/otp/verify` 🔓

```json
{
  "challengeId": "otp_7b9d8f",
  "purpose": "REGISTER",
  "code": "483921"
}
```

- `REGISTER`: activate account và trả `AuthSession`.
- `PASSWORD_RESET`: trả `resetProof` một lần, TTL ngắn; không đặt proof trong URL.
- OTP không dùng chéo purpose và bị consume sau khi thành công.

```json
{
  "success": true,
  "data": {
    "verified": true,
    "purpose": "REGISTER",
    "session": {
      "accessToken": "eyJ...",
      "refreshToken": "rt_...",
      "tokenType": "Bearer",
      "expiresIn": 900,
      "user": {
        "id": 12,
        "email": "an@example.com",
        "displayName": "Nguyễn Minh An",
        "role": "USER",
        "status": "ACTIVE",
        "authProvider": "LOCAL",
        "onboarding": { "healthProfileCompleted": false, "equipmentCompleted": false }
      }
    }
  }
}
```

Với `PASSWORD_RESET`, `session` là `null` và response có `resetProof`.

### `POST /auth/otp/resend` 🔓

```json
{
  "challengeId": "otp_7b9d8f",
  "purpose": "REGISTER"
}
```

**200:** trả challenge hiện hành/mới cùng `expiresAt`, `resendAvailableAt`. Rate limit trả `429 OTP_COOLDOWN` và `Retry-After`.

### `POST /auth/login` 🔓

```json
{
  "email": "an@example.com",
  "password": "StrongPassword123!",
  "deviceInfo": "VieGym Android 1.0"
}
```

**200:** trả `AuthSession` như trên. Sai email hoặc password luôn dùng `INVALID_CREDENTIALS`; account pending có thể kèm challenge để tiếp tục verify nhưng không cấp token.

### `POST /auth/google` 🔓

```json
{
  "idToken": "google-id-token",
  "deviceInfo": "VieGym iOS 1.0"
}
```

Backend verify issuer, audience, signature, expiry và subject. **200/201:** trả `AuthSession`; user mới có onboarding flags bằng `false`.

### `POST /auth/refresh` 🔓

```json
{ "refreshToken": "rt_...", "deviceInfo": "VieGym Android 1.0" }
```

**200:** rotation token cũ và trả access/refresh token mới. Reuse token đã rotate phải revoke token family theo policy.

### `POST /auth/logout` 🔒

```json
{ "refreshToken": "rt_..." }
```

**200:** revoke đúng session. Client xóa credential local kể cả khi session server đã hết hạn.

### `POST /auth/password/forgot` 🔓

```json
{ "email": "an@example.com" }
```

Luôn trả **200** với thông điệp trung tính. Khi hợp lệ, `data` có challenge đã mask; không tiết lộ email có tồn tại hay không.

### `POST /auth/password/reset` 🔓

```json
{
  "resetProof": "rp_once_...",
  "newPassword": "AnotherStrongPassword123!"
}
```

**200:** đổi password, consume proof và revoke các session theo security policy.

### `POST /auth/password/change` 🔒

Contract khóa cho màn Account Security của local account.

```json
{
  "currentPassword": "StrongPassword123!",
  "newPassword": "AnotherStrongPassword123!"
}
```

Google-only account trả `422 PASSWORD_CHANGE_NOT_SUPPORTED`. Thành công không trả password/token trong response.

---

## 3. User Profile, Preference & Health

### `GET /users/me` 🔒

```json
{
  "success": true,
  "data": {
    "id": 12,
    "email": "an@example.com",
    "displayName": "Nguyễn Minh An",
    "avatar": { "mediaId": 91, "accessUrl": "https://storage/...", "expiresAt": "2026-08-19T08:40:00Z" },
    "timezone": "Asia/Ho_Chi_Minh",
    "locale": "vi-VN",
    "role": "USER",
    "authProvider": "LOCAL",
    "onboarding": { "healthProfileCompleted": true, "equipmentCompleted": true }
  }
}
```

### `PUT /users/me` 🔒

```json
{
  "displayName": "Minh An",
  "avatarMediaId": 91,
  "timezone": "Asia/Ho_Chi_Minh",
  "locale": "vi-VN"
}
```

Không nhận email, role, account status hoặc Health fields tại endpoint này.

### `GET /preferences` 🔒 / `PUT /preferences` 🔒

```json
{
  "dislikedFoods": ["mướp đắng"],
  "allergies": ["PEANUT"],
  "dietaryConstraints": ["NO_PORK"],
  "mealPreferences": { "preferredCuisine": ["VIETNAMESE"] },
  "trainingPreferences": { "preferredProgramType": "FULL_BODY", "daysPerWeek": 3 },
  "preferredTrainingTime": "18:30:00"
}
```

`PUT` thay thế toàn bộ preference document. Dị ứng/ràng buộc là dữ liệu user khai báo và luôn ưu tiên hơn AI optimization.

### `GET /preferences/equipment` 🔒

Trả catalog active và danh sách đã chọn.

```json
{
  "success": true,
  "data": {
    "selectedEquipmentIds": [1, 2],
    "equipment": [
      { "id": 1, "code": "BODYWEIGHT", "name": "Trọng lượng cơ thể", "selected": true }
    ]
  }
}
```

### `PUT /preferences/equipment` 🔒

```json
{ "equipmentIds": [1, 2, 5] }
```

Thay thế tập thiết bị; mảng rỗng hợp lệ và Backend fallback sang bài bodyweight/không cần thiết bị. `Full Gym` chỉ là preset UI.

### `GET /health/profile` 🔒

Trả input profile và metric authoritative. `404 HEALTH_PROFILE_REQUIRED` nếu chưa onboarding.

### `POST /health/profile` 🔒

Tạo lần đầu HealthProfile, WeightLog ban đầu và, khi calculation đủ điều kiện, NutritionTarget trong một transaction.

```json
{
  "dateOfBirth": "1998-05-20",
  "gender": "MALE",
  "calculationSex": "MALE",
  "heightCm": 172.5,
  "currentWeightKg": 70.2,
  "activityLevel": "MODERATE",
  "fitnessGoal": "GAIN_MUSCLE",
  "trainingExperience": "INTERMEDIATE"
}
```

**201:**

```json
{
  "success": true,
  "data": {
    "profile": {
      "dateOfBirth": "1998-05-20",
      "gender": "MALE",
      "calculationSex": "MALE",
      "heightCm": 172.5,
      "currentWeightKg": 70.2,
      "activityLevel": "MODERATE",
      "fitnessGoal": "GAIN_MUSCLE",
      "trainingExperience": "INTERMEDIATE",
      "calculationVersion": "health-v1",
      "calculatedAt": "2026-08-19T08:30:00Z"
    },
    "calculationStatus": "COMPLETE",
    "metrics": { "bmi": 23.59, "bmrKcal": 1645.13, "tdeeKcal": 2549.95 },
    "nutritionTarget": { "caloriesKcal": 2849.95, "proteinG": 140.4, "carbsG": 393.96, "fatG": 79.17 }
  }
}
```

Với `calculationSex=UNSPECIFIED`, Backend trả `calculationStatus=INCOMPLETE`, vẫn trả BMI nếu đủ chiều cao/cân nặng, trả `bmrKcal/tdeeKcal/nutritionTarget=null` và `incompleteReason=CALCULATION_SEX_REQUIRED`. Với User dưới 18 tuổi dùng `UNSUPPORTED_AGE`; calories dưới ngưỡng dùng `CALORIES_BELOW_SAFETY_THRESHOLD`; macro âm/không hữu hạn dùng `INVALID_MACRO_RESULT`. Backend không suy ra calculation sex từ `gender`; Mobile phải hiển thị trạng thái cần bổ sung/không hỗ trợ.

### `PUT /health/profile` 🔒

Nhận các editable field như POST ngoại trừ `currentWeightKg`; sau onboarding cân nặng chỉ đổi qua
WeightLog. Backend không nhận `bmi`, `bmrKcal`, `tdeeKcal` hoặc macro target từ client; mọi
metric/target được tính lại atomically.

### `GET /health/metrics` 🔒

Trả `calculationStatus`, `bmi`, `bmrKcal`, `tdeeKcal`, `nutritionTarget`, `calculationVersion`, `calculatedAt` và `incompleteReason` khi phù hợp. Mobile và AI không tự tính để thay thế kết quả.

### `GET /weight-logs` 🔒

Query: `from`, `to`, `page`, `size`, `sort=loggedDate,desc`.

### `PUT /weight-logs/{loggedDate}` 🔒

```json
{ "weightKg": 70.2, "note": "Buổi sáng" }
```

Natural-key upsert theo `(user, loggedDate)`: chưa có trả `201`, đã có trả `200`. Retry cùng
payload là idempotent. Không cho đổi ngày của record; muốn ghi ngày khác dùng path ngày khác.

Nếu `loggedDate` là ngày mới nhất sau mutation, Backend cập nhật
`HealthProfile.currentWeightKg` và tính lại BMI/BMR/TDEE trong cùng transaction. Sửa log cũ
không làm thay đổi metric hiện tại. NutritionTarget không tự đổi ở luồng này.

Response trả `weightLog`, `metricsUpdated`, `metrics` khi cập nhật và
`nutritionTargetChanged=false`.

### `GET /weight-logs/trend` 🔒

Query `days=7|14|30` (mặc định `30`).

```json
{
  "success": true,
  "data": {
    "days": 30,
    "from": "2026-07-21",
    "to": "2026-08-19",
    "startWeightKg": 71.5,
    "currentWeightKg": 70.2,
    "changeKg": -1.3,
    "direction": "DOWN",
    "sufficientData": true,
    "points": [{ "date": "2026-08-19", "weightKg": 70.2 }]
  }
}
```

Khi có dưới hai điểm: `sufficientData=false`, `changeKg=null`, `direction=null`; Mobile hiển thị
“chưa đủ dữ liệu” thay vì suy trend.

---

## 4. Exercise Catalog & Workout

### `GET /muscle-groups` 🔒

Trả catalog active gồm `id`, `code`, `name`; không phân trang vì danh mục nhỏ.

### `GET /equipment` 🔒

Trả catalog active gồm `id`, `code`, `name`. Đây là catalog thuần; trạng thái selected của user
thuộc `GET /preferences/equipment`.

### `GET /exercises` 🔒

Query: `q`, `muscleGroupId`, `equipmentId`, `difficulty`, `compatibleWithMyEquipment`, `page`, `size`, `sort=name,asc`.

Chỉ trả Exercise `PUBLIC`/chưa xóa. `compatibleWithMyEquipment=true` ưu tiên/giới hạn theo equipment preference tùy filter contract, nhưng tập preference rỗng vẫn cho bài bodyweight phù hợp.

### `GET /exercises/{id}` 🔒

```json
{
  "success": true,
  "data": {
    "id": 101,
    "name": "Barbell Back Squat",
    "slug": "barbell-back-squat",
    "difficulty": "INTERMEDIATE",
    "description": "Bài squat với thanh đòn",
    "instructionSteps": ["Đặt thanh đòn", "Hạ người có kiểm soát"],
    "commonMistakes": ["Gối đổ vào trong"],
    "safetyNotes": ["Dùng mức tạ phù hợp"],
    "muscleGroups": [{ "id": 1, "code": "QUADS", "name": "Đùi trước", "role": "PRIMARY" }],
    "equipment": [{ "id": 2, "code": "BARBELL", "name": "Thanh đòn", "required": true }],
    "media": []
  }
}
```

### `GET /exercises/{id}/alternatives` 🔒

Query `limit` mặc định 5, tối đa 20. Trả Exercise `PUBLIC` cùng primary muscle group, ưu tiên
khớp equipment preference và loại exercise nguồn. Dùng cho hidden/missing-equipment warning.

### Workout program CRUD 🔒

| Method | Endpoint | Ý nghĩa |
|---|---|---|
| `GET` | `/workout-programs` | List program của user; filter `status`, pagination |
| `POST` | `/workout-programs` | Tạo program |
| `GET` | `/workout-programs/{id}` | Chi tiết program/day/exercise |
| `PUT` | `/workout-programs/{id}` | Thay thế cấu hình program |
| `DELETE` | `/workout-programs/{id}` | Archive/soft delete, bảo toàn history |

```json
{
  "name": "Full Body 3 buổi",
  "programType": "FULL_BODY",
  "description": "Chương trình cá nhân",
  "status": "ACTIVE",
  "days": [
    {
      "dayNumber": 1,
      "name": "Full Body A",
      "note": null,
      "exercises": [
        {
          "exerciseId": 101,
          "sortOrder": 1,
          "targetSets": 3,
          "targetRepsMin": 8,
          "targetRepsMax": 12,
          "targetDurationSeconds": null,
          "restSeconds": 90,
          "note": null
        }
      ]
    }
  ]
}
```

Tối đa một program `ACTIVE`/user. Với PUT, `dayId` và `workoutExerciseId` hiện có được gửi để
Backend diff-update thay vì xóa/tạo lại toàn bộ child. Exercise hidden chỉ bị reject khi được
thêm mới; reference hidden đã tồn tại được giữ với `hidden=true` + warning để user còn sửa phần
khác. `targetRepsMin <= targetRepsMax`; bài theo reps hoặc duration phải có target phù hợp.

Xóa WorkoutDay có schedule `PLANNED` hoặc có active session tham chiếu trả
`409 DAY_HAS_PLANNED_SCHEDULES`. Với schedule terminal, service giữ snapshot và có thể set
`workoutDayId=null`; không cascade history.

### Workout schedule CRUD 🔒

| Method | Endpoint | Ý nghĩa |
|---|---|---|
| `GET` | `/workout-schedules` | Query `from`, `to`, `status`, pagination |
| `POST` | `/workout-schedules` | Tạo lịch thủ công/từ program day |
| `GET` | `/workout-schedules/{id}` | Chi tiết schedule và active session nếu có |
| `PUT` | `/workout-schedules/{id}` | Sửa lịch còn hợp lệ |
| `DELETE` | `/workout-schedules/{id}` | Chuyển `CANCELLED`, không hard delete |

```json
{
  "workoutProgramId": 10,
  "workoutDayId": 31,
  "scheduledDate": "2026-08-20",
  "scheduledTime": "18:30:00",
  "title": "Full Body A"
}
```

DELETE nhận query tùy chọn `cancelReason`; chỉ schedule chưa qua effective cutoff mới được
`CANCELLED`. Schedule quá hạn trả `409 INVALID_STATE_TRANSITION` và được materialize `MISSED`;
`CANCELLED` bị loại khỏi mẫu số completion rate.

### `POST /workout-sessions/{scheduleId}/start` 🔒

Tạo/start session của schedule `PLANNED`. **201:** trả session `IN_PROGRESS`, snapshot bài dự
kiến và `startedAt`. Mỗi user chỉ có tối đa một session `IN_PROGRESS/PAUSED`; nếu đã có ở
schedule khác trả `409 ACTIVE_SESSION_EXISTS` kèm `activeSessionId`. Retry cùng idempotency key
trả resource cũ.

### `POST /workout-sessions/{id}/pause` 🔒

`IN_PROGRESS → PAUSED`; trả session mới. Transition khác trả `409 INVALID_STATE_TRANSITION`.

### `POST /workout-sessions/{id}/resume` 🔒

`PAUSED → IN_PROGRESS`; Backend cộng thời gian pause authoritative.

### `POST /workout-sessions/{id}/finish` 🔒

```json
{
  "note": "Buổi tập tốt",
  "exercises": [
    {
      "exerciseId": 101,
      "sortOrder": 1,
      "durationSeconds": 600,
      "completed": true,
      "sets": [
        { "setNumber": 1, "reps": 10, "weightKg": 40, "durationSeconds": null, "rpe": 7.5, "completed": true }
      ]
    }
  ]
}
```

Backend atomically validate log, tính duration/volume/PR, tạo WorkoutLog và chuyển session/schedule `COMPLETED`. Client không gửi `totalVolumeKg` hoặc PR authoritative.

### `POST /workout-sessions/{id}/discard` 🔒

```json
{ "reason": "Bắt đầu nhầm buổi" }
```

Chuyển active session sang `DISCARDED`; không tạo WorkoutLog/PR.

### `GET /workout-logs` 🔒

Query: `from`, `to`, `exerciseId`, `page`, `size`, `sort=completedAt,desc`. Item trả duration,
total volume, completion và PR summary.

### `GET /workout-logs/{id}` 🔒

Trả detail exercise/set snapshots, duration, volume và PR đạt trong buổi; bắt buộc ownership.

### `GET /personal-records` 🔒

Query `exerciseId`, `type`, `page`, `size`. Mỗi record trả `MAX_WEIGHT`, `MAX_REPS` hoặc
`MAX_VOLUME`, `value`, `achievedAt`, `workoutLogId`, `previousValue`. `MAX_VOLUME` là
`reps × weightKg` của một set completed; chỉ session `COMPLETED` được tính, bằng record cũ thì
không thay `achievedAt`.

---

## 5. Food, Meal Planner & Dashboard

### `GET /foods` 🔒

Query: `q`, `category`, `page`, `size`, `sort=name,asc`. P0 chỉ trả Food `PUBLIC`; không trả
`HIDDEN`. Food riêng của user ngoài phạm vi P0.

### `GET /foods/{id}` 🔒

```json
{
  "success": true,
  "data": {
    "id": 201,
    "name": "Phở bò",
    "category": "Món nước",
    "serving": { "amount": 1, "unit": "tô", "gramsPerServing": 350 },
    "nutritionPerServing": { "caloriesKcal": 450, "proteinG": 25, "carbsG": 55, "fatG": 14 },
    "dataSource": "Seed dataset",
    "sourceNote": null,
    "estimated": true,
    "media": []
  }
}
```

Giá trị có `estimated=true` phải được UI trình bày là tham khảo.

### `GET /meal-plans?date=2026-08-19` 🔒

Trả plan ngày của user và aggregate authoritative. GET không ghi database. Nếu chưa có plan,
trả `id=null`, bốn meal section rỗng và target hiện hành với `targetSource=CURRENT`.

```json
{
  "success": true,
  "data": {
    "id": 301,
    "planDate": "2026-08-19",
    "targetSource": "SNAPSHOT",
    "target": { "caloriesKcal": 2200, "proteinG": 130, "carbsG": 270, "fatG": 65 },
    "consumed": { "caloriesKcal": 450, "proteinG": 25, "carbsG": 55, "fatG": 14 },
    "remaining": { "caloriesKcal": 1750, "proteinG": 105, "carbsG": 215, "fatG": 51 },
    "meals": [
      {
        "id": 401,
        "mealType": "BREAKFAST",
        "name": null,
        "sortOrder": 1,
        "entries": []
      }
    ]
  }
}
```

Plan được tạo trong mutation entry đầu tiên; `nutritionTargetSnapshot` được chụp lúc đó và giữ
bất biến để lịch sử deterministic. Khi chưa có plan, `targetSource=CURRENT`; khi đã có plan,
Dashboard và Meal UI cùng ngày dùng snapshot và trả `targetSource=SNAPSHOT`.

### `POST /meal-plans/{planDate}/entries` 🔒

```json
{
  "mealType": "BREAKFAST",
  "mealSortOrder": 1,
  "foodId": 201,
  "servingMultiplier": 1.5,
  "inputAmount": null,
  "inputUnit": null,
  "note": null
}
```

**201:** Backend get-or-create plan/meal trong transaction, trả entry có input/serving/nutrition
snapshot và plan totals mới. Khi `inputUnit=GRAM`, Food phải có `gramsPerServing`; Backend tự
tính multiplier. Nếu không nhập gram, `inputAmount/inputUnit=null` và dùng multiplier.

### `PUT /meal-plans/{planDate}/entries/{entryId}` 🔒

```json
{ "mealType": "LUNCH", "mealSortOrder": 1, "servingMultiplier": 1, "note": "Ít nước dùng" }
```

Chỉ cho sửa entry thuộc plan/owner; Backend tính lại snapshot và aggregate.

### `DELETE /meal-plans/{planDate}/entries/{entryId}` 🔒

**204.** Không xóa Food nguồn; plan total được tính lại.

### Meal template contract 🔒

Khóa endpoint cho FT-MP-009:

| Method | Endpoint | Mô tả |
|---|---|---|
| `GET` | `/meal-templates` | List template của user |
| `POST` | `/meal-templates` | Tạo từ items hoặc `sourceMealPlanId` |
| `GET` | `/meal-templates/{id}` | Chi tiết |
| `PUT` | `/meal-templates/{id}` | Sửa metadata/items |
| `DELETE` | `/meal-templates/{id}` | Xóa template, không sửa plan nguồn |
| `POST` | `/meal-templates/{id}/apply` | Preview/validate rồi copy sang `targetDate` |

```json
{ "targetDate": "2026-08-20", "mode": "MERGE" }
```

Food hidden phải được trả trong validation result là item bị chặn/bỏ; không tự thay món. `mode` P0: `MERGE`; mode ghi đè chỉ thêm khi business rule được chốt.

### `GET /dashboard` 🔒

Query tùy chọn `date` (mặc định hôm nay theo user timezone). Đây là read model, không mutation domain.

```json
{
  "success": true,
  "data": {
    "date": "2026-08-19",
    "nutrition": { "target": {}, "consumed": {}, "remaining": {}, "hasMealPlan": true },
    "workout": {
      "today": [],
      "next": null,
      "completion": {
        "windowFrom": "2026-08-17",
        "windowTo": "2026-08-19",
        "scheduledEligible": 3,
        "completedEligible": 2,
        "rate": 0.67
      }
    },
    "body": { "currentWeightKg": 70.2, "bmi": 23.59, "trend": "DOWN" },
    "recommendations": [],
    "missingData": [],
    "generatedAt": "2026-08-19T08:30:00Z"
  }
}
```

Thiếu dữ liệu trả `null`/empty state và mã trong `missingData` (`HEALTH_PROFILE`, `MEAL_PLAN`, `WORKOUT_SCHEDULE`), không dùng dữ liệu giả.
Endpoint này không gọi AI Provider và không tạo/regenerate recommendation.
`scheduledEligible` chỉ gồm lịch đã completed hoặc đã đến hạn sau cutoff+grace; loại
`CANCELLED`, lịch tương lai/chưa đến hạn và lịch có session active. Nếu mẫu số bằng 0,
`rate=null`.

---

## 6. AI Coach & Recommendation

### Nguyên tắc bắt buộc

- Consent được kiểm tra trước Context Builder.
- `DISABLED`: chỉ General Knowledge Mode, không gửi dữ liệu Health/Workout/Nutrition/Weight/Preference và không tạo daily recommendation cá nhân hóa.
- Output provider luôn qua schema, business và safety validation tại Backend.
- AI chỉ tạo proposal; domain mutation chỉ xảy ra sau APPLY hợp lệ.

### `GET /ai/consent` 🔒

```json
{
  "success": true,
  "data": {
    "mode": "DISABLED",
    "consentVersion": "v1.0",
    "acceptedAt": null,
    "updatedAt": "2026-08-19T08:30:00Z"
  }
}
```

### `PUT /ai/consent` 🔒

```json
{ "mode": "ENABLED", "consentVersion": "v1.0", "source": "SETTINGS" }
```

Setting và consent history được ghi cùng transaction. `ENABLED` yêu cầu version hiện hành; disable/revoke áp dụng ngay cho request mới.

### `POST /ai/conversations` 🔒

```json
{ "title": "Kế hoạch tập tuần này", "requestedMode": "PERSONALIZED" }
```

- Consent ON: cho `PERSONALIZED`.
- Consent OFF: server buộc `GENERAL_KNOWLEDGE`; không âm thầm dùng context cá nhân.
- **201:** trả conversation `ACTIVE`.

### `GET /ai/conversations` 🔒

Query `page`, `size`, `sort=lastMessageAt,desc`. P0 chỉ có conversation `ACTIVE`; `ARCHIVED` là
reserved và không xuất hiện trong filter khi chưa có archive endpoint. Chỉ trả conversation của
actor, preview message tối thiểu; không trả raw context.

### `GET /ai/conversations/{id}` 🔒

Contract phục vụ màn history/detail. Query `messagePage`, `messageSize`; trả messages của conversation thuộc user.

### `POST /ai/conversations/{id}/messages` 🔒

```json
{ "content": "Tôi nên sắp xếp buổi tập thế nào?" }
```

**200:**

```json
{
  "success": true,
  "data": {
    "userMessage": { "id": 501, "role": "USER", "content": "Tôi nên sắp xếp buổi tập thế nào?" },
    "assistantMessage": {
      "id": 502,
      "role": "ASSISTANT",
      "content": "Bạn có thể bố trí ba buổi cách ngày...",
      "safetyLevel": "NORMAL",
      "disclaimer": null
    },
    "mode": "PERSONALIZED",
    "correlationId": "2b651bb2-154f-4c90-8c70-cb182d741a27"
  }
}
```

Effective mode được xác định cho từng message theo consent tại thời điểm gửi. Conversation tạo
lúc `PERSONALIZED` nhưng consent hiện đã OFF vẫn nhận message ở `GENERAL_KNOWLEDGE`, không dùng
personal context; response trả `mode=GENERAL_KNOWLEDGE` để UI hiển thị banner đổi mode.

Nội dung có giới hạn kích thước. Không trả full prompt/context snapshot/provider credential. Provider lỗi dùng fallback an toàn và error đã sanitize.

### `GET /ai/recommendations/daily` 🔒

Query `date` (mặc định ngày nghiệp vụ theo profile timezone). Đây là read endpoint thuần, không
gọi provider hoặc tạo dữ liệu. Consent OFF trả danh sách rỗng kèm
`personalizationEnabled=false`.

```json
{
  "success": true,
  "data": {
    "date": "2026-08-19",
    "personalizationEnabled": true,
    "recommendations": [
      {
        "id": 601,
        "type": "NUTRITION",
        "title": "Bổ sung protein bữa tối",
        "content": "Lượng protein hôm nay đang thấp hơn mục tiêu.",
        "reason": "Protein còn thiếu theo meal plan hiện tại",
        "priority": "MEDIUM",
        "status": "PENDING",
        "sourceMetrics": { "remainingProteinG": 42 },
        "safetyLevel": "NORMAL",
        "allowedAction": "ADD_MEAL_ENTRY_PROPOSAL",
        "actionPreview": { "foodId": 205, "mealType": "DINNER", "servingMultiplier": 1, "targetDate": "2026-08-19" },
        "expiresAt": "2026-08-19T17:00:00Z"
      }
    ]
  }
}
```

Trả tối đa 1–3 recommendation active của generation mới nhất/user/ngày; chỉ trả resource thuộc
user và còn phù hợp với query.

### `POST /ai/recommendations/daily/generations` 🔒

Command sinh recommendation cho `targetDate` (mặc định ngày nghiệp vụ hiện tại). Header
`Idempotency-Key` bắt buộc. Backend tạo generation/batch row unique theo
`(userId, targetDate, generationNo)`, dựng `rules-v1` + candidate shortlist rồi gọi AI ngoài DB
transaction. Request trùng trả batch hiện có; batch đang chạy trả `202` với status `STARTED`; hoàn tất trả
`201` với 1–3 items. P0 cho generation đầu tiên và tối đa hai refresh chủ động/ngày; refresh tạo
generation mới, không ghi đè item đã APPLIED/DISMISSED. Trong transaction persist batch mới,
các item `PENDING` của generation trước trong cùng ngày chuyển `EXPIRED`; vì vậy chỉ generation
mới nhất có tối đa 1–3 item active.

Response `202` dùng `data.status=STARTED` (không tạo enum `GENERATING` riêng). Vượt ba
generation/ngày trả `429 DAILY_GENERATION_LIMIT_REACHED`.

Structured action chỉ được tham chiếu ID trong shortlist. Meal/Schedule action bắt buộc
`targetDate`; preference action chỉ được chứa field whitelist và không được sửa
`allergies/dietaryConstraints`. `ADD_MEAL_ENTRY_PROPOSAL.targetDate` phải bằng
`recommendationDate`; `CREATE_WORKOUT_SCHEDULE_PROPOSAL.targetDate` nằm trong
`[recommendationDate, recommendationDate + 14 ngày]`, đều theo profile timezone. Preference
whitelist P0 là `dislikedFoods`, `mealPreferences`, `trainingPreferences`,
`preferredTrainingTime`.

### `POST /ai/recommendations/{id}/apply` 🔒

Header `Idempotency-Key` bắt buộc.

```json
{ "expectedVersion": 0 }
```

Backend lock recommendation, kiểm tra owner + `PENDING` + expiry + safety, validate lại domain data, gọi đúng domain owner, ghi recommendation log/audit và chuyển `APPLIED` trong một transaction.

```json
{
  "success": true,
  "data": {
    "recommendationId": 601,
    "status": "APPLIED",
    "allowedAction": "ADD_MEAL_ENTRY_PROPOSAL",
    "mutationResult": { "targetType": "MEAL_ENTRY", "targetId": 701 },
    "appliedAt": "2026-08-19T08:35:00Z"
  }
}
```

Retry cùng key/payload trả cùng kết quả. Expired hoặc non-PENDING không được apply. Output
`BLOCKED` không tồn tại dưới dạng recommendation persisted.

### `POST /ai/recommendations/{id}/dismiss` 🔒

```json
{ "expectedVersion": 0, "feedback": "Tôi không có nguyên liệu này" }
```

Chuyển `PENDING → DISMISSED`, lưu feedback tối thiểu; tuyệt đối không mutation Health/Workout/Nutrition. Retry phải idempotent.

---

## 7. Media & Storage

### Media policy

- Owner/media P0 theo ADR-006: `EXERCISE` nhận `IMAGE`/`VIDEO`, `FOOD` chỉ nhận `IMAGE`. `USER_PROFILE` và `GIF` là P1.
- Status: `PENDING_UPLOAD`, `READY`, `FAILED`, `ORPHANED`, `DELETED`.
- Backend sinh `objectKey`; filename chỉ dùng để hiển thị sau sanitize.
- Allowlist P0: ảnh `.jpg/.jpeg/.png/.webp` với `image/jpeg`, `image/png`, `image/webp`, tối đa 5 MiB; Exercise video `.mp4/.webm` với `video/mp4`, `video/webm`, tối đa 50 MiB. Backend đối chiếu extension, MIME khai báo và MIME từ nội dung; API trả constraint để client không hard-code.
- Access/upload URL có TTL ngắn và chỉ cấp sau role/ownership/visibility check.
- Admin create Exercise/Food trước ở `HIDDEN`, nhận owner ID, sau đó upload/attach và mới publish.
  P0 không tạo unattached media với `ownerId=null`.

### `POST /media/upload-init` 🔒

```json
{
  "ownerType": "EXERCISE",
  "ownerId": 101,
  "mediaType": "IMAGE",
  "role": "THUMBNAIL",
  "sortOrder": 1,
  "originalFileName": "back-squat.jpg",
  "declaredMimeType": "image/jpeg",
  "fileSizeBytes": 245010,
  "visibility": "PUBLIC"
}
```

**201:**

```json
{
  "success": true,
  "data": {
    "mediaId": 91,
    "status": "PENDING_UPLOAD",
    "uploadUrl": "https://storage.example/presigned-put",
    "method": "PUT",
    "requiredHeaders": { "Content-Type": "image/jpeg" },
    "expiresAt": "2026-08-19T08:40:00Z",
    "constraints": { "maxSizeBytes": 5242880, "allowedMimeTypes": ["image/jpeg", "image/png", "image/webp"] }
  }
}
```

P0 chỉ Admin được gắn media vào Exercise/Food dùng chung. Avatar user thuộc P1.
`role` nhận `THUMBNAIL`, `PRIMARY_VIDEO`, `GALLERY`; `sortOrder` dương và unique trong
`(ownerType, ownerId, role, sortOrder)` theo policy hiển thị.

### `POST /media/{id}/upload-complete` 🔒

Backend HEAD object, kiểm tra tồn tại/size/MIME thực tế/extension rồi chuyển `READY` hoặc `FAILED`.

```json
{ "fileSizeBytes": 245010 }
```

Không tin MIME client khai báo. Complete lặp lại với object đã `READY` trả metadata hiện tại.

### `GET /media/{id}/access-url` 🔒

**200:** `{ "url": "https://...", "expiresAt": "...", "mimeType": "image/jpeg" }`. Chỉ cấp cho media `READY`; URL không phải bằng chứng authorization lâu dài.

### `DELETE /media/{id}` 🔒

**204.** Gỡ/xóa có kiểm soát theo owner policy; chuyển orphan trước khi xóa vật lý và không xóa object còn được history tham chiếu.

---

## 8. Admin & Audit

Tất cả endpoint trong phần này yêu cầu role `ADMIN`. Mutation ghi audit đã redact.

### Admin Exercise CRUD 👑

| Method | Endpoint | Mô tả |
|---|---|---|
| `GET` | `/admin/exercises` | List gồm `PUBLIC/HIDDEN`, filter/search/page |
| `POST` | `/admin/exercises` | Tạo Exercise |
| `GET` | `/admin/exercises/{id}` | Chi tiết quản trị |
| `PUT` | `/admin/exercises/{id}` | Cập nhật |
| `DELETE` | `/admin/exercises/{id}` | Soft delete/`HIDDEN` |

Request dùng các field `name`, `slug`, `difficulty`, `description`, `instructionSteps`, `commonMistakes`, `safetyNotes`, `visibility`, `muscleGroups[{muscleGroupId,role}]`, `equipment[{equipmentId,required}]`. Slug unique; hide không phá lịch sử. Create có thể lưu `HIDDEN` chưa media, sau đó media được attach bằng owner ID; publish chỉ khi required content/media hợp lệ.

### Admin Food CRUD 👑

| Method | Endpoint | Mô tả |
|---|---|---|
| `GET` | `/admin/foods` | List/filter/search/page |
| `POST` | `/admin/foods` | Tạo Food dùng chung |
| `GET` | `/admin/foods/{id}` | Chi tiết quản trị |
| `PUT` | `/admin/foods/{id}` | Cập nhật |
| `DELETE` | `/admin/foods/{id}` | Soft delete/`HIDDEN` |

```json
{
  "name": "Cơm tấm sườn",
  "slug": "com-tam-suon",
  "category": "Cơm",
  "servingAmount": 1,
  "servingUnit": "phần",
  "gramsPerServing": 420,
  "caloriesPerServing": 650,
  "proteinGPerServing": 30,
  "carbsGPerServing": 80,
  "fatGPerServing": 22,
  "dataSource": "Nguồn dữ liệu",
  "sourceNote": "Giá trị trung bình",
  "estimated": true,
  "visibility": "PUBLIC"
}
```

### `GET /admin/audit-logs` 👑

Query: `actorId`, `action`, `targetType`, `targetId`, `result`, `from`, `to`, `correlationId`, pagination. Response không chứa password/token/OTP/API key/raw AI context hoặc health/conversation dư thừa.

### `GET /admin/dashboard` 👑 `[P1]`

Read model thống kê vận hành đã aggregate; không cung cấp nội dung riêng tư mặc định.

### Admin user management 👑 `[P1]`

| Method | Endpoint | Mô tả |
|---|---|---|
| `GET` | `/admin/users` | List/filter account |
| `GET` | `/admin/users/{id}` | Metadata account tối thiểu |
| `POST` | `/admin/users` | Tạo/invite account theo policy |
| `PUT` | `/admin/users/{id}` | Role/status/deactivate được allowlist |

Không trả password hash, token, OTP hoặc dữ liệu domain riêng tư.

### Admin import 👑 `[P1]`

- `POST /admin/imports/preview`: nhận `sourceMediaId`, `importType=EXERCISE|FOOD`; parse và trả `importId`, row counts, preview, validation errors.
- `POST /admin/imports/{id}/commit`: chỉ commit job `VALIDATED`; toàn bộ import chạy transaction và rollback khi thất bại.

### AI rule và prompt metadata 👑 `[P1]`

- `GET/POST/PUT /admin/ai-rules[/{id}]`: quản trị rule có version, active state và structured condition; không nhận executable code tùy ý.
- `GET/POST/PUT /admin/prompts[/{id}]`: quản trị metadata/version/template theo policy; không chứa provider secret.

---

## 9. Notification `[P1]`

### `GET /notifications` 🔒

Query `status`, `type`, pagination. Chỉ trả notification của user hiện tại.

### `POST /notifications/{id}/read` 🔒

Idempotently chuyển notification thuộc user sang `READ`, set `readAt` và trả resource hiện tại.

### `GET /notifications/preferences` 🔒 / `PUT /notifications/preferences` 🔒

```json
{
  "workoutEnabled": true,
  "mealEnabled": true,
  "weightEnabled": false,
  "recommendationEnabled": true,
  "weeklyReviewEnabled": false,
  "quietHoursStart": "22:00:00",
  "quietHoursEnd": "07:00:00",
  "timezone": "Asia/Ho_Chi_Minh"
}
```

Notification không phải source of truth; lỗi gửi không rollback transaction domain. Notification AI cá nhân hóa phải tuân theo consent.

---

## 10. Internal AI Service Contract

Internal API không public expose và chỉ nhận request từ Spring Boot qua network policy/service credential. Mọi request có `schemaVersion` và `correlationId`.

### `POST /internal/v1/ai/generate`

```json
{
  "schemaVersion": "1.0",
  "correlationId": "2b651bb2-154f-4c90-8c70-cb182d741a27",
  "requestType": "CHAT",
  "promptVersion": "chat-v1",
  "renderedPrompt": "<provider-neutral prompt rendered by Backend>",
  "context": {
    "contextVersion": "context-v1",
    "consentMode": "ENABLED",
    "data": {}
  },
  "candidates": {
    "foods": [{ "id": 205, "name": "Ức gà luộc", "servingUnit": "phần", "caloriesKcal": 165, "proteinG": 31 }],
    "workoutDays": []
  },
  "messages": [{ "role": "USER", "content": "..." }],
  "allowedActions": ["NONE", "CREATE_WORKOUT_SCHEDULE_PROPOSAL"]
}
```

```json
{
  "schemaVersion": "1.0",
  "correlationId": "2b651bb2-154f-4c90-8c70-cb182d741a27",
  "content": "...",
  "safetyLevel": "NORMAL",
  "items": [],
  "providerMetadata": { "provider": "configured-adapter", "model": "configured-model", "latencyMs": 820 }
}
```

Với `requestType=CHAT`, response dùng `content` và `items=[]`. Với
`requestType=DAILY_RECOMMENDATION`, response dùng `content=null` và `items` có 1–3 object, mỗi
object gồm `type`, `title`, `content`, `reason`, `priority`, `safetyLevel`, `proposal`. Proposal
chỉ được dùng candidate ID trong request. Backend validate toàn batch trước khi persist.

Prompt template và Prompt Builder thuộc Spring Boot; FastAPI nhận prompt/provider request đã
render và chỉ làm provider adapter + parse schema sơ bộ. Không duy trì template thứ hai trong
FastAPI.

Spring Boot vẫn phải parse và chạy schema/business/safety validation. FastAPI không kết nối trực tiếp PostgreSQL, không tự mutation domain và không quyết định authorization.

---

## 11. Concurrency, Idempotency & Security Tests

### State/concurrency rules

- `start` khóa/check schedule để bảo đảm tối đa một active session.
- `finish` atomically tạo log con, metric/PR và hoàn tất session/schedule.
- Apply recommendation dùng optimistic `expectedVersion` và row lock.
- Health update và recalculation/target lưu trong cùng transaction.
- Consent setting/history lưu cùng transaction.
- Meal entry snapshot và aggregate được Backend tính từ current authoritative data.

### API/security test P0 tối thiểu

- JWT invalid/expired/revoked; USER gọi Admin API.
- User A đọc/sửa resource Health, Workout, Meal, AI hoặc Media private của user B.
- OTP sai purpose, expired, vượt attempts, resend cooldown và chống email enumeration.
- Register/login/refresh/logout và Google token invalid.
- Concurrent session start/finish; invalid state transition; discarded session không sinh PR.
- Health input không cho ghi metric; `calculationSex` không bị suy ra từ `gender`, và `UNSPECIFIED`/age dưới 18 phải trả calculation incomplete.
- Meal totals bỏ qua giá trị client giả mạo.
- Consent OFF không dựng personal context và không sinh daily recommendation.
- Apply lặp cùng idempotency key, apply expired/blocked/non-owner recommendation.
- Media giả MIME, quá size, upload hết hạn và access URL sai quyền.
- Audit/log redaction cho password, OTP, token, provider key và personal context.

---

## 12. API Summary

| Nhóm | Endpoint chính | Scope |
|---|---|---|
| Identity | `/auth/**` | P0 |
| Profile/Preference | `/users/me`, `/preferences/**` | P0 |
| Health/Body | `/health/**`, `/weight-logs/**` | P0 |
| Workout | `/exercises/**`, `/workout-programs/**`, `/workout-schedules/**`, `/workout-sessions/**`, `/workout-logs/**` | P0 |
| Nutrition | `/foods/**`, `/meal-plans/**`, `/meal-templates/**` | P0 |
| Dashboard | `/dashboard` | P0 |
| AI Coach | `/ai/**` | P0 |
| Admin baseline | `/admin/exercises/**`, `/admin/foods/**`, `/admin/audit-logs` | P0 |
| Media | `/media/**` | P0 |
| Admin mở rộng | `/admin/dashboard`, `/admin/users/**`, `/admin/imports/**`, `/admin/ai-rules/**`, `/admin/prompts/**` | P1 |
| Notification | `/notifications/**` | P1 |

---

## 13. Tài liệu liên quan và traceability

| Tài liệu | Phần được dùng để khóa contract |
|---|---|
| [`../spec/specs.md`](../spec/specs.md) | SRS, enum, calculation, consent, AI trust boundary, P0/P1 |
| [`../spec/bussiness_mainflow.md`](../spec/bussiness_mainflow.md) | Luồng register/onboarding/workout/meal/AI Apply-Dismiss/Admin |
| [`../spec/phan_ra_phan_he_he_thong.md`](../spec/phan_ra_phan_he_he_thong.md) | API groups, ownership và subsystem business rules |
| [`../spec/phan_ra_tinh_nang.md`](../spec/phan_ra_tinh_nang.md) | Feature priority và acceptance behavior |
| [`../spec/phan_ra_man_hinh.md`](../spec/phan_ra_man_hinh.md) | Screen data/API, UI state và navigation contract |
| [`../kientruchatang/DATABASE.md`](../kientruchatang/DATABASE.md) | Field, constraint, snapshot, lifecycle và transaction |
| [`sa.md`](sa.md) | Public/internal boundary, security, validation và deployment architecture |
| [`../kientruchatang/techstack.md`](../kientruchatang/techstack.md) | Spring Boot, JWT, springdoc-openapi, storage và FastAPI adapter |

Khi implementation khác tài liệu này, thay đổi phải được review đồng thời với SRS/Database/Screen contract liên quan; không để Swagger và tài liệu kiến trúc lệch nhau.
