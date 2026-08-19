# Phân Rã Màn Hình — VieGym

> **Phiên bản:** 3.0
> **Ngày cập nhật:** 2026-08-19
> **Trạng thái:** Baseline triển khai UI/UX MVP
> **Nền tảng chính:** Flutter Mobile App (Android)
> **Phạm vi:** User App và Admin UI tối thiểu phục vụ MVP/demo

---

## 1. Mục đích, phạm vi và nguồn sự thật

### 1.1. Mục đích

Tài liệu này chuyển các yêu cầu nghiệp vụ của VieGym thành cấu trúc giao diện có thể dùng trực tiếp cho thiết kế, phát triển Flutter, tích hợp Backend và kiểm thử.

Tài liệu phải trả lời được cho từng UI unit:

- Ai được sử dụng?
- Người dùng đi vào từ đâu và đi tiếp tới đâu?
- Dữ liệu nào được hiển thị, subsystem nào sở hữu dữ liệu đó?
- Hành động nào được phép và điều kiện thực hiện là gì?
- Có những trạng thái loading, empty, error, disabled hoặc expired nào?
- Feature, use case và acceptance criteria nào được màn hình hiện thực hóa?
- Màn hình thuộc P0, P1 hay P2/Future?

Mục tiêu cuối cùng là bảo đảm UI không tự tạo business rule, không che giấu trạng thái lỗi và không cho phép frontend hoặc AI vượt qua quyền quyết định của Backend và người dùng.

### 1.2. Nguồn tham chiếu và thứ tự ưu tiên

Khi có khác biệt, áp dụng thứ tự ưu tiên sau:

1. `specs.md` v3.0 — source of truth cấp yêu cầu và phạm vi.
2. `bussiness_mainflow.md` v3.0 — luồng nghiệp vụ end-to-end.
3. `phan_ra_phan_he_he_thong.md` v3.0 — owner, API boundary và dependency.
4. `phan_ra_tinh_nang.md` v3.0 — feature ID, priority và acceptance criteria triển khai.
5. Tài liệu này — đặc tả cách thể hiện trên UI.

Tài liệu màn hình không được dùng để thay đổi yêu cầu ở tài liệu có mức ưu tiên cao hơn.

### 1.3. Phạm vi UI

Bao gồm:

- Authentication, OTP, password và biometric unlock local.
- Health Profile, Health Metrics và Weight Tracking.
- Exercise Library, Program, Schedule, Session, Log và progress.
- Food Database, Meal Plan, Meal Entry, nutrition summary và template/history.
- Dashboard tổng hợp.
- User Profile, Equipment và User Preference.
- AI Consent, General Knowledge Mode, Personalized Chat, conversation history, Daily Recommendation và Apply/Dismiss.
- Admin Exercise/Food/Audit baseline và các màn hình Admin P1.
- Media hiển thị/upload ở nơi Exercise, Food hoặc Profile sử dụng.
- Global states, security, privacy và accessibility.

Không bao gồm trong core UI:

- Shop/Marketplace, Cart, Order, Payment.
- Wearable, Apple Health hoặc Google Fit.
- Food image recognition.
- Pose estimation hoặc Computer Vision.
- ML prediction.
- AI tự động sửa kế hoạch hoặc dữ liệu mà không có user approval.

### 1.4. Known discrepancies và quyết định áp dụng

Các tài liệu nguồn hiện có một số tham chiếu lịch sử chưa đồng nhất. Bản này áp dụng các quyết định sau:

- Dashboard giữ ID `MH03`; các bảng nguồn ghi Dashboard là `MH10` được xem là tham chiếu cũ.
- Equipment Onboarding là `MH10`, Equipment Settings là `MH37`; không sử dụng `MH39` cho Equipment.
- `MH39` trước đây là một bản sao của AI Consent. Bản này chỉ có một route AI Consent là `MH28`; `MH39` được giữ như alias deprecated để tránh hiểu nhầm khi đọc tài liệu cũ.
- Admin P0 baseline gồm Admin shell, Manage Exercise, Manage Food và Audit Log tối thiểu. Admin analytics Dashboard, User Management, Import và AI Rule/Prompt là P1 theo feature/subsystem breakdown mới nhất.
- Business flow có chỗ gọi việc rời Workout Session là `CANCELLED`, trong khi feature/subsystem dùng hành động `DISCARD`. UI dùng nhãn hành động `Hủy buổi tập`; trạng thái lưu trữ cuối cùng phải theo API Specification, không tự tạo enum ở Mobile.
- Offline queue/cache nâng cao là P2. P0 chỉ hiển thị trạng thái mất kết nối và không giả lập mutation thành công.

---

## 2. Cách đọc tài liệu và taxonomy UI

### 2.1. Priority

| Priority | Ý nghĩa trên UI |
|---|---|
| P0 | Bắt buộc để hoàn thiện và demo MVP |
| P1 | Chỉ bật sau khi P0 ổn định; phải được feature flag hoặc ẩn khỏi P0 navigation |
| P2 | Mở rộng; không được làm đường găng của MVP |
| Future | Không thiết kế như chức năng khả dụng trong phiên bản hiện tại |

### 2.2. Loại UI unit

| Loại | Khi sử dụng |
|---|---|
| Screen | Route có nhiệm vụ, trạng thái và navigation riêng |
| Wizard | Một route gồm nhiều bước liên tiếp và giữ form state |
| Bottom Sheet | Tác vụ ngắn trong context hiện tại, ví dụ Meal Entry |
| Dialog | Xác nhận hoặc quyết định ngắn, ví dụ Logout |
| State | Biến thể của cùng screen; không tạo ID mới |
| Entry point | Đường dẫn tới route đã tồn tại; không tính là screen mới |
| Shared component | Thành phần dùng lại, không sở hữu business logic |

### 2.3. Quy ước bắt buộc và khuyến nghị

- **Bắt buộc:** xuất phát từ SRS, business flow, feature hoặc subsystem boundary.
- **Khuyến nghị UX:** tối ưu cách trình bày; có thể điều chỉnh nếu không làm sai yêu cầu.
- **Contract pending:** feature đã có nhưng endpoint/payload chi tiết phải chờ API Specification; UI không tự phát minh contract.
- **Backend-only:** không tạo screen chỉ để thể hiện một bước kỹ thuật nội bộ.

### 2.4. Mẫu mô tả một màn hình

Mỗi màn hình được mô tả theo cấu trúc:

1. Metadata: actor, priority, type, feature, owner.
2. Mục tiêu.
3. Entry và precondition.
4. Nội dung/component.
5. Actions và validation.
6. Business rules.
7. States.
8. Navigation/back behavior.
9. Data/API boundary.
10. Acceptance criteria cấp UI.

---

## 3. Nguyên tắc xuyên suốt

### 3.1. Business authority

> **Backend calculates. AI interprets and recommends. User decides. Backend executes.**

- Flutter chỉ giao tiếp với Spring Boot Backend qua `/api/v1`.
- Flutter không gọi trực tiếp FastAPI AI Service hoặc AI Provider.
- Mobile không tự tính lại BMI, BMR, TDEE, calories target, macro target, nutrition summary, volume, completion rate, PR hoặc weight trend authoritative.
- AI output chỉ là response/proposal cho đến khi Backend validation hoàn tất.
- Mọi mutation do AI đề xuất chỉ xảy ra sau khi user chọn Apply.

### 3.2. Ownership và authorization

- Ẩn nút trên frontend không thay thế authorization ở Backend.
- User chỉ truy cập Health, Weight, Meal, Workout, AI và Preference resource của chính mình.
- Admin route yêu cầu JWT hợp lệ và role `ADMIN`.
- Với `401`, app thử refresh session theo contract. Nếu không thể phục hồi, clear session local an toàn và điều hướng về Login.
- Với `403`, hiển thị thông báo không có quyền; không tự động đổi role hoặc thử endpoint khác.
- Không hiển thị password, refresh token, OTP, AI API key, system prompt hoặc raw personal context.

### 3.3. CTA và thao tác

- Mỗi task screen có tối đa một primary CTA nổi bật tại một thời điểm.
- CTA dùng động từ cụ thể: `Bắt đầu tập`, `Thêm vào bữa`, `Lưu thay đổi`, `Áp dụng đề xuất`.
- CTA bất khả dụng phải có lý do, không chỉ đổi màu.
- Delete, discard, reset, logout, revoke và mutation quan trọng phải có confirmation phù hợp.
- Không đóng sheet/dialog trước khi request mutation có kết quả xác định.
- Retry mutation phải tránh tạo bản ghi trùng; idempotency do Backend bảo đảm theo contract.

### 3.4. Form

- Field có label cố định; placeholder không thay label.
- Validate format ở client để hỗ trợ UX và validate authoritative ở Backend.
- Lỗi field hiển thị gần field; lỗi form/global hiển thị ở vùng dễ thấy.
- Numeric field dùng keyboard số và cho biết đơn vị.
- Date/enum dùng picker phù hợp.
- Edit form prefill giá trị hiện tại.
- Có unsaved-change guard khi rời form đã thay đổi.
- Keyboard không che primary CTA.

### 3.5. Dữ liệu ước lượng

- Nutrition từ nguồn ước lượng phải có wording `Giá trị tham khảo` hoặc tương đương.
- AI insight phải nói rõ khi dữ liệu chưa đủ.
- Không dùng dữ liệu mẫu để che empty/error state trong runtime.

### 3.6. Accessibility

- Touch target tối thiểu khoảng 44–48dp.
- Text và icon quan trọng đủ tương phản.
- Không dùng màu làm tín hiệu duy nhất cho status.
- Icon có semantic label.
- Progress có text/semantic value.
- Form error được screen reader thông báo.
- Video có controls rõ, không autoplay âm thanh.
- Nội dung chính vẫn sử dụng được khi font scale tăng.

### 3.7. Visual direction — khuyến nghị

- Phong cách hiện đại, khỏe khoắn, rõ hierarchy và không dày đặc số liệu.
- Dùng card cho nhóm thông tin, list item cho dữ liệu lặp lại.
- Progress ring/bar chỉ dùng khi giúp so sánh target và actual.
- Theme nâng cao là P1; P0 không phụ thuộc Dark Mode.

---

## 4. Kiến trúc điều hướng

### 4.1. User App shell

Sau authentication và onboarding guard, user sử dụng 5 tab:

```text
Dashboard | Workout | Meal | AI | Profile
```

Quy tắc:

- Mỗi tab giữ navigation stack và trạng thái lọc/scroll hợp lý.
- Settings nằm trong Profile, không là tab thứ sáu.
- Deep link phải chạy qua session, role, ownership và onboarding guard trước khi mở nội dung.
- Back từ child screen quay về context trước đó; back từ tab root không nhảy sang tab khác ngoài quy ước hệ điều hành.

### 4.2. Authentication và onboarding guard

```text
MH01 Splash
├── Không có phiên phục hồi được → MH02 Welcome → MH04 Login / MH05 Register
├── Có local session + biometric bật → MH08 Biometric
└── Session hợp lệ
    ├── ADMIN → MH45 Admin Home
    └── USER
        ├── Health Profile thiếu → MH09
        ├── Equipment chưa thiết lập → MH10
        └── Đầy đủ → MH03 Dashboard

Register: MH05 → MH06 OTP Verification → MH09
Forgot:   MH52 Forgot Request → MH06 OTP Verification → MH07 Reset Password → MH04
```

Equipment có thể lưu tập rỗng; khi đó Backend áp dụng fallback BODYWEIGHT theo rule. Guard chỉ yêu cầu user đã hoàn thành bước lựa chọn, không bắt buộc phải chọn ít nhất một thiết bị.

### 4.3. User sitemap

```text
MH03 Dashboard
├── Workout today → MH17
├── Nutrition → MH20/MH23
├── Body → MH43
└── Recommendation → MH31

MH11 Workout
├── MH12 Exercise Library → MH13 Exercise Detail
├── MH14 Program List → MH15 Builder
├── MH16 Schedule → MH17 Session
├── MH18 History
└── MH19 Personal Record

MH20 Meal
├── MH21 Food Library → MH22 Food Detail → MH24 Meal Entry
├── MH23 Meal Plan → MH24 Meal Entry
├── MH25 Nutrition Summary
├── MH54 Meal History & Template
└── MH26 Water Tracker [P1]

MH27 AI
├── MH28 AI Consent
├── MH55 Conversation History → MH29 Chat
├── MH30 Recommendation List → MH31 Detail
└── MH32 Weekly Review [P1]

MH33 Profile
├── MH34 User Profile → MH35 Edit Profile
├── MH42 Health Profile
├── MH43 Weight Tracking
└── MH36 Settings
    ├── MH37 Equipment Preference
    ├── MH38 User Preference
    ├── MH28 AI Consent
    ├── MH53 Account Security
    ├── MH40 App Settings [P1]
    ├── MH41 Notification Settings [P1]
    └── MH44 Logout Dialog
```

### 4.4. Admin sitemap

```text
MH45 Admin Home/Shell
├── MH46 Manage Exercise [P0 baseline]
├── MH47 Manage Food [P0 baseline]
├── MH51 Audit Log [P0 baseline]
├── Analytics cards [P1]
├── MH49 Manage Users [P1]
├── MH48 Import Data [P1]
└── MH50 AI Rule/Prompt [P1]
```

Admin UI tách khỏi bottom navigation của USER. Route guard phải được Backend thực thi, không chỉ dựa vào menu.

---

## 5. Screen inventory

### 5.1. P0 User UI

| ID | Tên | Actor | Loại | Feature chính |
|---|---|---|---|---|
| MH01 | Splash / Session Bootstrap | USER, ADMIN | Screen | FT-ID-005, FT-ID-009, FT-ID-010 |
| MH02 | Welcome | Guest | Screen | Entry UX |
| MH03 | Dashboard | USER | Screen | FT-DB-001..005, FT-DB-007 |
| MH04 | Login | Guest | Screen | FT-ID-002, FT-ID-003, FT-ID-010 |
| MH05 | Register | Guest | Screen | FT-ID-001 |
| MH06 | OTP Verification | Guest | Screen | FT-ID-001, FT-ID-006, FT-ID-008 |
| MH07 | Reset Password | Guest | Screen | FT-ID-006, FT-ID-008 |
| MH08 | Biometric Unlock | USER | Dialog/Screen | FT-ID-009 |
| MH09 | Health Profile Onboarding | USER | Wizard | FT-HP-001..004 |
| MH10 | Equipment Onboarding | USER | Screen | FT-UP-004, FT-WO-003 |
| MH11 | Workout Tab | USER | Screen | PH4 entry |
| MH12 | Exercise Library | USER | Screen | FT-WO-001, FT-WO-003 |
| MH13 | Exercise Detail | USER | Screen | FT-WO-002, FT-MD-001 |
| MH14 | Workout Program List | USER | Screen | FT-WO-004 |
| MH15 | Workout Builder | USER | Screen | FT-WO-003, FT-WO-004 |
| MH16 | Workout Schedule | USER | Screen + Sheet | FT-WO-005 |
| MH17 | Workout Session | USER | Screen + Dialog | FT-WO-006, FT-WO-007 |
| MH18 | Workout History | USER | Screen | FT-WO-009 |
| MH19 | Personal Record | USER | Screen | FT-WO-008, FT-WO-011 |
| MH20 | Meal Tab | USER | Screen | PH5 entry, FT-MP-005/006 |
| MH21 | Food Library | USER | Screen | FT-MP-001 |
| MH22 | Food Detail | USER | Screen | FT-MP-002, FT-MD-002 |
| MH23 | Meal Plan | USER | Screen | FT-MP-003, FT-MP-005 |
| MH24 | Meal Entry Editor | USER | Bottom Sheet/Screen | FT-MP-004 |
| MH25 | Nutrition Summary | USER | Screen | FT-MP-005, FT-MP-006 |
| MH27 | AI Tab | USER | Screen | PH7 entry |
| MH28 | AI Consent | USER | Screen | FT-AI-001, FT-AI-002 |
| MH29 | AI Coach Chat | USER | Screen | FT-AI-002, FT-AI-005..007, FT-AI-014 |
| MH30 | Daily Recommendation List | USER | Screen | FT-AI-008 |
| MH31 | Recommendation Detail | USER | Sheet/Screen | FT-AI-009, FT-AI-010, FT-MP-011 |
| MH33 | Profile Tab | USER | Screen | PH2/PH3 entry |
| MH34 | User Profile | USER | Screen | FT-UP-001, FT-UP-002 |
| MH35 | Edit User Profile | USER | Screen | FT-UP-001, FT-UP-002 |
| MH36 | Settings | USER | Screen | PH1/PH2/PH7 entry |
| MH37 | Equipment Preference | USER | Screen | FT-UP-004, FT-WO-003 |
| MH38 | User Preference | USER | Screen | FT-UP-003, FT-UP-005 |
| MH42 | Health Profile View/Edit | USER | Screen | FT-HP-001..004 |
| MH43 | Weight Tracking | USER | Screen + Sheet | FT-HP-005..007 |
| MH44 | Logout | USER, ADMIN | Dialog | FT-ID-004 |
| MH52 | Forgot Password Request | Guest | Screen | FT-ID-006, FT-ID-008 |
| MH53 | Account Security / Change Password | USER | Screen | FT-ID-007 |
| MH54 | Meal History & Template | USER | Screen | FT-MP-009 |
| MH55 | AI Conversation History | USER | Screen | FT-AI-014 |

### 5.2. P0 Admin UI

| ID | Tên | Actor | Loại | Feature chính |
|---|---|---|---|---|
| MH45 | Admin Home/Shell | ADMIN | Screen | Navigation baseline; analytics FT-AD-001 là P1 |
| MH46 | Manage Exercise | ADMIN | Screen + Form | FT-AD-003, FT-MD-001/003 |
| MH47 | Manage Food | ADMIN | Screen + Form | FT-AD-004, FT-MD-002/003 |
| MH51 | Audit Log | ADMIN | Screen | FT-AD-008 |

### 5.3. P1 UI

| ID | Tên | Actor | Loại | Feature chính |
|---|---|---|---|---|
| MH26 | Water Tracker | USER | Screen | FT-MP-010 |
| MH32 | Weekly Review | USER | Screen | FT-AI-011 |
| MH40 | App Settings | USER | Screen | FT-UP-007 |
| MH41 | Notification Settings | USER | Screen | FT-NT-001, FT-NT-002, FT-NT-003, FT-NT-004 |
| MH48 | Import Data | ADMIN | Screen | FT-AD-005 |
| MH49 | Manage Users | ADMIN | Screen | FT-AD-002 |
| MH50 | AI Rule / Prompt Management | ADMIN | Screen | FT-AD-006/007/009 |

P1 Favorite Exercise (`FT-WO-010`), Favorite Food (`FT-MP-007`), Recent Food (`FT-MP-008`), Preference Memory (`FT-UP-006`, `FT-AI-013`) và conversation summary/feedback nâng cao (`FT-AI-015`) là state/component trong screen hiện có, không cần route riêng.

### 5.4. Alias và ID migration

| ID cũ | Quyết định |
|---|---|
| MH39 — AI Consent from Settings | Deprecated alias → MH28; Settings chỉ là entry point |
| MH06 — Forgot Password / Request OTP | MH06 chuẩn hóa thành OTP Verification |
| MH52 | Route mới cho Forgot Password Request |
| MH53 | Route mới cho Change Password |
| MH54 | Route mới cho Meal History & Template |
| MH55 | Route mới cho AI Conversation History |

---

## 6. Authentication và Account Security

### MH01 — Splash / Session Bootstrap

**Actor:** USER, ADMIN
**Priority:** P0
**Type:** Screen
**Feature:** FT-ID-005, FT-ID-009, FT-ID-010
**Owner:** PH1 Identity & Auth

#### Mục tiêu

Khởi tạo ứng dụng, phục hồi phiên nếu có thể và điều hướng qua đúng role/onboarding guard mà không để user nhìn thấy màn hình trung gian sai.

#### Entry và nội dung

- Entry duy nhất là app launch/cold start.
- Hiển thị logo, tên ứng dụng và loading indicator tối giản.
- Không hiển thị dữ liệu cá nhân trước khi session được xác nhận.

#### Luồng bắt buộc

```text
Đọc secure storage
→ Không có refresh token: MH02
→ Có refresh token:
   ├── Biometric local bật: MH08 trước khi mở token
   └── Không bật: gọi refresh
→ Refresh thành công: role/onboarding guard
→ Token expired/revoked/invalid: clear local session → MH04/MH02
```

#### States

- Bootstrapping.
- Biometric required.
- Session restored.
- Session expired/revoked.
- Temporary network failure: cho Retry hoặc `Đăng nhập lại`; không treo Splash vô hạn.

#### Data/API

- Secure storage local.
- `POST /api/v1/auth/refresh`.
- Biometric chỉ mở local credential; không gửi biometric data lên Backend.

#### Acceptance

- Không vào private route khi chưa có session hợp lệ.
- USER và ADMIN được điều hướng đúng shell.
- Refresh lỗi không làm lộ token hoặc lỗi kỹ thuật.

### MH02 — Welcome

**Actor:** Guest
**Priority:** P0
**Type:** Screen
**Feature:** Entry UX

#### Mục tiêu và nội dung

Giới thiệu ngắn gọn ba giá trị: luyện tập, dinh dưỡng món Việt và AI Coach có consent; đưa Guest đến Login hoặc Register.

#### Actions

- `Đăng nhập` → MH04.
- `Đăng ký` → MH05.
- `Tiếp tục với Google` → server-side Google Login flow.
- Skip onboarding giới thiệu → MH04; không cho skip authentication.

#### Rules

- Không mô tả AI như hệ thống tự ra quyết định.
- Google Login phải gọi Backend, không xác thực hoàn toàn ở client.
- Onboarding marketing đã xem có thể được lưu local; không ảnh hưởng Health onboarding.

### MH04 — Login

**Actor:** Guest
**Priority:** P0
**Type:** Screen
**Feature:** FT-ID-002, FT-ID-003, FT-ID-010
**Owner:** PH1

#### Components

- Email.
- Password và show/hide.
- `Đăng nhập`.
- `Tiếp tục với Google`.
- `Quên mật khẩu?` → MH52.
- `Chưa có tài khoản? Đăng ký` → MH05.

#### Validation và states

- Email bắt buộc, đúng format cơ bản.
- Password bắt buộc.
- Submitting khóa double submit.
- Sai credential: thông báo chung, không xác nhận email có tồn tại.
- Account pending: điều hướng MH06 theo `REGISTER` nếu Backend cho phép tiếp tục verify.
- Account locked/disabled: thông báo trạng thái chuẩn từ Backend, không cấp token.
- Rate limited: hiển thị thời gian chờ nếu Backend cung cấp.
- Network/server error: Retry, giữ email nhưng không giữ password nếu policy yêu cầu xóa.

#### Success navigation

- Health Profile thiếu → MH09.
- Health Profile đủ nhưng Equipment onboarding chưa hoàn tất → MH10.
- USER đầy đủ → MH03.
- ADMIN → MH45.

#### Data/API

- `POST /api/v1/auth/login`.
- `POST /api/v1/auth/google`.

### MH05 — Register

**Actor:** Guest
**Priority:** P0
**Type:** Screen
**Feature:** FT-ID-001
**Owner:** PH1

#### Components

- Họ tên nếu field này được register contract cho phép.
- Email.
- Password.
- Confirm password.
- Password requirements.
- `Đăng ký`.
- Link về MH04.

#### Rules

- Email duy nhất được Backend kiểm tra; thông báo không làm lộ dữ liệu ngoài policy.
- Password và confirm phải khớp; password không được log.
- Register thành công chỉ tạo account pending và gửi OTP.
- Chưa verify OTP không được cấp token nghiệp vụ.

#### Navigation

```text
Submit hợp lệ
→ Backend tạo account PENDING + gửi OTP
→ MH06 purpose=REGISTER
→ Verify thành công
→ nhận token
→ MH09
```

#### Data/API

- `POST /api/v1/auth/register`.

### MH06 — OTP Verification

**Actor:** Guest
**Priority:** P0
**Type:** Screen dùng chung theo purpose
**Feature:** FT-ID-001, FT-ID-006, FT-ID-008
**Owner:** PH1

#### Variants

- `REGISTER`: verify account pending, sau đó cấp token và mở MH09.
- `PASSWORD_RESET`: verify quyền reset, sau đó mở MH07 theo contract an toàn.
- `LOGIN_VERIFY`: chỉ hiển thị nếu Backend bật purpose này.

#### Components

- Email đã mask, ví dụ `n***@example.com`.
- OTP input theo độ dài do contract xác định.
- `Xác minh`.
- `Gửi lại mã` kèm countdown từ Backend/cooldown state.
- `Đổi email` chỉ quay về màn khởi tạo tương ứng, không sửa account ngầm.

#### States và error

- Waiting input.
- Verifying.
- Invalid code.
- Expired code.
- Attempts exceeded/temporarily blocked.
- Resend cooldown.
- Resend success.
- Network/server error.

#### Rules

- Không dùng OTP chéo purpose.
- Không tự hard-code expiry, cooldown hoặc attempt limit.
- Paste OTP được hỗ trợ nhưng không đọc clipboard liên tục.
- OTP không được ghi log, analytics hoặc crash report.

#### Data/API

- `POST /api/v1/auth/otp/verify`.
- `POST /api/v1/auth/otp/resend`.

### MH52 — Forgot Password Request

**Actor:** Guest
**Priority:** P0
**Type:** Screen
**Feature:** FT-ID-006, FT-ID-008
**Owner:** PH1

#### Components và actions

- Email.
- `Gửi mã đặt lại mật khẩu`.
- Back về MH04.

#### Rules và states

- Luôn dùng thông báo trung tính, ví dụ: `Nếu email hợp lệ, hướng dẫn sẽ được gửi`.
- Có submitting, cooldown/rate-limit, success và error state.
- Thành công → MH06 với purpose `PASSWORD_RESET`.

#### Data/API

- `POST /api/v1/auth/password/forgot`.

### MH07 — Reset Password

**Actor:** Guest
**Priority:** P0
**Type:** Screen
**Feature:** FT-ID-006, FT-ID-008
**Owner:** PH1

#### Components

- Mật khẩu mới.
- Xác nhận mật khẩu mới.
- Show/hide.
- Password requirements.
- `Đặt lại mật khẩu`.

OTP hoặc reset proof được truyền bằng flow state an toàn; không hiển thị token trên UI hoặc URL loggable.

#### Rules và navigation

- Password mới phải hợp lệ và hai field khớp.
- Reset success → confirmation → MH04.
- Credential/session cũ được thu hồi theo Backend policy.
- Reset proof expired → quay lại MH52/MH06 với giải thích rõ.

#### Data/API

- `POST /api/v1/auth/password/reset`.

### MH08 — Biometric Unlock

**Actor:** USER
**Priority:** P0
**Type:** System dialog hoặc app fallback screen
**Feature:** FT-ID-009
**Owner:** PH1 + client secure storage

#### Components và actions

- Lý do mở khóa.
- `Dùng sinh trắc học`.
- `Dùng mật khẩu` → MH04.
- Cancel theo hành vi hệ điều hành.

#### Rules

- Chỉ mở local token/session đã lưu an toàn.
- Không gửi hoặc lưu raw biometric data.
- Fail/cancel cho phép fallback; lockout theo OS policy.
- Unlock local không bỏ qua refresh token expiry/revocation.

### MH53 — Account Security / Change Password

**Actor:** USER
**Priority:** P0; remote sessions là P1
**Type:** Screen
**Feature:** FT-ID-007; FT-ID-011 [P1]
**Owner:** PH1

#### P0 components

- Mật khẩu hiện tại đối với local account.
- Mật khẩu mới.
- Confirm password.
- Show/hide và password requirements.
- `Đổi mật khẩu`.

#### Rules

- Chỉ local account dùng current password; Google-only account hiển thị hướng dẫn phù hợp với provider.
- Session hợp lệ là bắt buộc.
- Sau khi đổi, revoke/giữ phiên theo Backend security policy và thông báo kết quả rõ.
- Endpoint/payload chi tiết là contract pending trong API Specification; Mobile không tự đặt URL.

#### P1 extension

- Danh sách thiết bị/phiên.
- Remote logout từng phiên hoặc các phiên khác.

### MH44 — Logout

**Actor:** USER, ADMIN
**Priority:** P0
**Type:** Confirmation dialog
**Feature:** FT-ID-004
**Owner:** PH1

#### Nội dung và actions

```text
Đăng xuất khỏi VieGym?
Phiên hiện tại trên thiết bị này sẽ kết thúc.

[ Hủy ] [ Đăng xuất ]
```

- Confirm → gọi logout/revoke, clear local credential và về MH02/MH04.
- Request thất bại do mạng: không tuyên bố revoke server thành công; vẫn áp dụng local cleanup theo security policy và giải thích ngắn gọn nếu cần.

#### Data/API

- `POST /api/v1/auth/logout`.

---

## 7. Health và Equipment Onboarding

### MH09 — Health Profile Onboarding

**Actor:** USER
**Priority:** P0
**Type:** Wizard
**Feature:** FT-HP-001..004
**Owner:** PH3 Health & Body

#### Mục tiêu

Thu thập đủ dữ liệu để Backend tạo HealthProfile, WeightLog ban đầu, NutritionTarget và các metric authoritative.

#### Bước đề xuất

1. **Thông tin cơ bản:** ngày sinh/tuổi, giới tính.
2. **Cơ thể:** chiều cao, cân nặng.
3. **Mục tiêu:** activity level, fitness goal, training experience.

Các enum phải dùng giá trị mà Backend hỗ trợ:

- Gender: MALE, FEMALE, OTHER, UNSPECIFIED.
- Activity: SEDENTARY, LIGHT, MODERATE, ACTIVE, VERY_ACTIVE.
- Goal: LOSE_WEIGHT, MAINTAIN_WEIGHT, GAIN_WEIGHT, GAIN_MUSCLE.

#### UX và validation

- Có progress `1/3`, `2/3`, `3/3`.
- Back giữ dữ liệu trong wizard.
- Hiển thị đơn vị rõ; P0 lưu/submit theo contract chuẩn.
- Không hiển thị metric giả trước khi Backend tính.
- Field invalid được chỉ rõ; thiếu field bắt buộc không tính TDEE.
- Submit có loading và chống double submit.

#### Success flow

```text
Backend validate
→ tính BMI/BMR/TDEE/calories/macro
→ transaction lưu HealthProfile + WeightLog + NutritionTarget
→ MH10 Equipment Onboarding
```

#### Data/API

- `POST /api/v1/health/profile`.
- Metric trả về từ Backend; Mobile không chạy lại công thức để thay thế kết quả.

#### Acceptance

- Dữ liệu hợp lệ tạo đủ ba nhóm resource theo Backend response.
- Dữ liệu lỗi không tạo trạng thái một phần trên UI.
- User không sửa trực tiếp BMI/BMR/TDEE/targets.

### MH10 — Equipment Preference Onboarding

**Actor:** USER
**Priority:** P0
**Type:** Screen
**Feature:** FT-UP-004, FT-WO-003
**Owner:** PH2; PH4 là consumer

#### Components

- Danh sách multi-select: BODYWEIGHT, DUMBBELL, BARBELL, BENCH, CABLE_MACHINE, MACHINE, RESISTANCE_BAND, KETTLEBELL, PULL_UP_BAR, TREADMILL.
- `Full Gym` để chọn nhanh tập hợp seed phổ biến.
- `Bodyweight only`.
- `Bỏ chọn tất cả`.
- Primary CTA `Lưu và tiếp tục`.

#### Rules

- Tập rỗng là hợp lệ; hệ thống fallback ưu tiên BODYWEIGHT/bài không cần thiết bị đặc thù.
- `Full Gym` là preset UI, không phải enum thiết bị mới.
- Chỉ lưu preference; không tạo/chỉnh WorkoutLog.
- User không phải chọn lại mỗi buổi.
- Success → MH03.

#### Data/API

- `GET/PUT /api/v1/preferences/equipment`.

---

## 8. Dashboard

### MH03 — Dashboard

**Actor:** USER
**Priority:** P0; Quick Actions mở rộng là P1
**Type:** Screen/tab root
**Feature:** FT-DB-001..005, FT-DB-007; FT-DB-006 [P1]
**Owner:** PH6 Dashboard read model

#### Mục tiêu

Cho user biết nhanh hôm nay đang ở đâu và hành động tiếp theo là gì, dựa hoàn toàn trên aggregate do Backend cung cấp.

#### Thứ tự nội dung

1. Ngày hiện tại theo timezone của request/user.
2. Nutrition: target, consumed, remaining và macro.
3. Workout hôm nay hoặc buổi tiếp theo; weekly completion.
4. Body: current weight, BMI và progress/trend phù hợp.
5. Tối đa 1–3 Daily Recommendation còn hiệu lực khi consent cho phép.

#### Primary action theo context

- Có schedule PLANNED hôm nay → `Bắt đầu tập` → MH17.
- Chưa có schedule → `Tạo lịch tập` → MH16.
- Chưa có meal entry → `Thêm món` → MH24/MH21.
- Health Profile thiếu → `Hoàn thiện hồ sơ` → MH09; các section phụ thuộc bị khóa/empty.

Chỉ một CTA được nhấn mạnh nhất theo context; các action khác là secondary.

#### States

- Loading: skeleton theo section.
- Partial empty: từng section có message/CTA riêng; không biến toàn screen thành empty nếu các section khác có dữ liệu.
- Profile incomplete.
- No meal, no schedule, no weight.
- Consent OFF: không hiển thị personalized recommendation; có thể dùng CTA tới MH28 nhưng không gây áp lực.
- No recommendation: ẩn list hoặc hiển thị empty nhẹ; không tạo dữ liệu giả.
- Error toàn bộ: Retry.
- Lỗi một provider trong aggregate: hiển thị section unavailable nếu Backend contract hỗ trợ partial response.

#### Business rules

- Dashboard không sở hữu mutation hoặc metric gốc.
- Completion loại `CANCELLED` hợp lệ khỏi mẫu số theo dữ liệu Backend.
- Recommendation phải đúng user, còn hiệu lực và đúng trạng thái hiển thị.
- Notification bell chỉ xuất hiện khi notification P1 được triển khai; không có icon chết ở P0.

#### Data/API

- `GET /api/v1/dashboard`.
- CTA mutation điều hướng đến subsystem owner tương ứng.

#### Acceptance

- Sau khi Meal, Workout hoặc Weight mutation thành công, Dashboard refresh và hiển thị aggregate mới.
- Không tự cộng calories/macro hoặc tính completion ở Mobile.
- Empty state dẫn tới đúng task để bổ sung dữ liệu.

---

## 9. Workout

### 9.1. State model dùng chung

#### Workout Schedule

```text
PLANNED
├── Hoàn thành session hợp lệ → COMPLETED
├── Quá hạn không hoàn thành → MISSED
└── User hủy hợp lệ → CANCELLED
```

- Chỉ `PLANNED` mới có CTA bắt đầu session.
- `COMPLETED`, `MISSED`, `CANCELLED` là trạng thái đọc trong lịch sử trừ khi API định nghĩa transition khác.
- `CANCELLED` hợp lệ không nằm trong mẫu số completion rate.

#### Workout Session

```text
READY
└── Start → IN_PROGRESS
    ├── Pause → PAUSED → Resume → IN_PROGRESS
    ├── Finish → COMPLETED + WorkoutLog + Schedule COMPLETED
    └── Discard/Hủy → không tạo completed log hoặc PR
```

Tên enum lưu trữ chính xác của Session phải theo API contract. Mobile chỉ gửi action hợp lệ và hiển thị state Backend trả về.

### MH11 — Workout Tab

**Actor:** USER
**Priority:** P0
**Type:** Screen/tab root
**Feature:** PH4 entry
**Owner:** PH4 Workout

#### Mục tiêu và nội dung

Là điểm vào nhanh tới buổi tập hôm nay và toàn bộ công cụ Workout:

1. Workout hôm nay hoặc next workout.
2. Active Program.
3. Weekly completion từ Backend.
4. Lối vào Exercise Library, Program, Schedule, History và PR.

#### Actions theo context

- Schedule `PLANNED` hôm nay → `Bắt đầu tập` → MH17.
- Có active session → `Tiếp tục buổi tập` → MH17.
- Chưa có program → `Tạo chương trình` → MH15.
- Có program nhưng chưa có schedule → `Lập lịch tập` → MH16.

#### States

- No program.
- Program có nhưng không active.
- No schedule today.
- Active session đang PAUSED/IN_PROGRESS.
- Error/Retry.

#### Rules

- Không tự suy ra completion từ số card đã hiển thị.
- Program hoặc schedule thuộc user khác phải bị Backend từ chối.
- Không hiển thị reminder/notification CTA nếu P1 chưa bật.

### MH12 — Exercise Library

**Actor:** USER
**Priority:** P0; Favorite là P1
**Type:** Screen
**Feature:** FT-WO-001, FT-WO-003; FT-WO-010 [P1]
**Owner:** PH4; đọc Equipment từ PH2

#### Components

- Search theo tên.
- Filter theo muscle group, equipment, difficulty.
- Trạng thái filter đang áp dụng và `Xóa bộ lọc`.
- Exercise item: media thumbnail, tên, primary muscle, equipment, difficulty và equipment-match indicator.

#### Equipment personalization

- Bài phù hợp equipment được ưu tiên.
- Bài không phù hợp có thể hiển thị `Cần thiết bị: ...`; không bị ẩn khi user tìm thủ công.
- Khi chưa có preference, ưu tiên BODYWEIGHT/bài không yêu cầu thiết bị đặc thù.
- Matching chỉ thay ranking/gợi ý, không thay ownership của Equipment Preference.

#### States

- Initial loading/skeleton.
- Empty catalog.
- No search result → CTA xóa filter.
- Media unavailable → placeholder nhưng giữ nội dung text.
- Pagination/load-more error nếu API dùng pagination.

#### Rules

- Chỉ Exercise active/visible được dùng cho lựa chọn mới.
- Exercise hidden vẫn có thể xuất hiện dạng read-only trong history cũ.
- Favorite icon chỉ xuất hiện khi `FT-WO-010` P1 được triển khai.

#### Data/API

- `GET /api/v1/exercises` với query/filter do API Specification xác định.

### MH13 — Exercise Detail

**Actor:** USER
**Priority:** P0; Favorite là P1
**Type:** Screen
**Feature:** FT-WO-002, FT-MD-001; FT-WO-010 [P1]
**Owner:** PH4; media do PH9

#### Nội dung bắt buộc

- Tên, difficulty và equipment.
- Primary/secondary muscle.
- Mô tả.
- Instruction steps.
- Common mistakes.
- Safety notes.
- Video/image/GIF hợp lệ hoặc placeholder.

#### Actions

- Trong context Builder: `Thêm vào chương trình` và quay lại MH15 sau khi chọn.
- Từ Library thông thường: CTA thêm chỉ xuất hiện nếu app có context đích rõ; không thêm vào một program không xác định.
- Favorite [P1].

#### Rules và states

- Video không autoplay âm thanh; có play/pause/caption/semantic label phù hợp.
- Media error không làm mất hướng dẫn text.
- Exercise vừa bị hidden khi màn hình đang mở: cho đọc nếu quyền cho phép nhưng chặn thêm mới và giải thích.
- Nội dung exercise là untrusted input khi được đưa vào AI; UI không render HTML/script không an toàn.

#### Data/API

- `GET /api/v1/exercises/{id}`.
- Media URL/access metadata từ PH9.

### MH14 — Workout Program List

**Actor:** USER
**Priority:** P0
**Type:** Screen
**Feature:** FT-WO-004
**Owner:** PH4

#### Components

- Active Program nổi bật.
- Danh sách inactive/archived có status rõ.
- Tên, loại PPL/Upper Lower/Full Body/Custom, số ngày/buổi và updated time nếu Backend trả.
- `Tạo chương trình` → MH15 create mode.

#### Actions

- Open/Edit → MH15 edit mode.
- Set active.
- Archive.
- Delete chỉ khi business/API cho phép; ưu tiên archive để giữ lịch sử.

#### Rules

- User có thể có nhiều program nhưng tối đa một program `ACTIVE`.
- Set active phải được Backend thực hiện atomically; Mobile không tự deactivate program khác bằng nhiều request rời rạc.
- Archive/delete program không sửa WorkoutLog cũ.

#### States

- Empty → chọn template hoặc tạo Custom.
- No active program.
- Conflict khi program khác vừa được set active → refresh và hiển thị trạng thái mới.
- Destructive confirmation.

#### Data/API

- `GET/POST/PUT/DELETE /api/v1/workout-programs` theo operation contract.

### MH15 — Workout Builder

**Actor:** USER
**Priority:** P0
**Type:** Task screen
**Feature:** FT-WO-003, FT-WO-004
**Owner:** PH4; đọc Equipment từ PH2

#### Modes

- Create từ PPL, Upper/Lower, Full Body hoặc Custom.
- Edit program thuộc user.
- Read-only khi program không thể sửa theo Backend state.

#### Nội dung

- Program name/type/status.
- Workout Day list.
- Trong mỗi day: Exercise, sets, reps, rest, order và note.
- `Thêm bài` → MH12 với selection context.
- Reorder exercise/day nếu UI hỗ trợ.

#### Validation

- Tên và cấu trúc bắt buộc theo API.
- Sets/reps/rest dùng range do Backend contract xác định; không hard-code business limit chưa có trong SRS.
- Không cho lưu reference Exercise đã hidden.
- Unsaved-change guard.

#### Equipment mismatch

- Badge thiết bị thiếu.
- Gợi ý replacement cùng nhóm cơ nếu Backend cung cấp.
- Không tự thay bài; user phải xác nhận lựa chọn.

#### Actions và states

- `Lưu chương trình`.
- Saving/success/validation/conflict/error.
- Sau create success: mở Program hoặc đề xuất `Tạo lịch` → MH16; không tự tạo schedule nếu user chưa chọn.

#### Data/API

- `POST/PUT /api/v1/workout-programs`.
- Exercise discovery qua `/api/v1/exercises`.

### MH16 — Workout Schedule

**Actor:** USER
**Priority:** P0
**Type:** Screen + create/edit sheet
**Feature:** FT-WO-005
**Owner:** PH4

#### Views

- Week là mặc định.
- Day detail.
- Month chỉ là cách hiển thị tùy chọn, không tạo business feature mới.

Mỗi item hiển thị ngày/giờ theo timezone, workout/program và status `PLANNED`, `COMPLETED`, `MISSED`, `CANCELLED` bằng text + visual indicator.

#### Create/Edit Schedule sheet

- Chọn tạo thủ công hoặc sinh từ Program.
- Chọn program/workout day khi liên quan.
- Chọn ngày/giờ hợp lệ.
- Preview các lịch sẽ được tạo nếu sinh nhiều buổi.
- `Lưu lịch tập`.

#### Actions theo trạng thái

- PLANNED: Start, edit/reschedule hoặc cancel nếu Backend cho phép.
- COMPLETED: mở Workout History detail.
- MISSED: read-only hoặc reschedule bằng action tạo schedule mới theo contract; không đổi trực tiếp thành COMPLETED.
- CANCELLED: read-only; không tính completion denominator.

#### Rules

- Chỉ schedule thuộc user được sửa/hủy.
- Thay đổi Program sau này không viết lại schedule/log lịch sử ngoài contract rõ ràng.
- Completion rate luôn dùng Backend value.
- Notification/reminder chỉ hiển thị khi P1 được bật và user cho phép.

#### States

- Empty week → `Tạo lịch tập`.
- No active program → vẫn cho tạo thủ công hoặc điều hướng tạo program.
- Date conflict/business validation error.
- Stale status/conflict → refresh item; không overwrite trạng thái mới.

#### Data/API

- `GET/POST/PUT/DELETE /api/v1/workout-schedules`.

### MH17 — Workout Session

**Actor:** USER
**Priority:** P0
**Type:** Full-screen task + confirmation/result sheets
**Feature:** FT-WO-006, FT-WO-007
**Owner:** PH4

#### Entry/precondition

- Bắt đầu từ schedule hợp lệ hoặc tiếp tục active session thuộc user.
- Backend ngăn nhiều active session trái rule; nếu có session đang hoạt động, UI đề nghị tiếp tục session đó.

#### Nội dung

- Session state và elapsed/duration nếu có.
- Workout title, progress theo exercise/set.
- Current exercise và link MH13.
- Set rows: set number, reps, weight, completion; duration khi loại bài cần.
- Rest timer là hỗ trợ client; không thay đổi metric authoritative.
- Notes và next exercise.

#### Actions

- Start.
- Complete/Edit set.
- Add set nếu contract cho phép.
- Pause/Resume.
- Finish session.
- `Hủy buổi tập`/Discard qua confirmation.

#### Input rules

- Numeric keyboard; đơn vị rõ.
- Reps, weight và duration được validate theo loại exercise và Backend contract; bodyweight không bị ép nhập external weight dương.
- Set chưa hoàn thành không được hiển thị như completed.
- Không tự tính PR hoặc authoritative volume để ghi đè Backend; UI có thể hiển thị preview không-authoritative nếu được ghi nhãn rõ.

#### Exit behavior

```text
Back/Close khi IN_PROGRESS hoặc PAUSED
├── Tiếp tục tập → đóng dialog
├── Lưu và rời → chỉ hiện nếu Backend có persisted paused/draft contract
└── Hủy buổi tập → confirm → discard endpoint
```

Không dùng nhãn `Lưu nháp` nếu Backend chưa hỗ trợ persisted session.

#### Finish flow

```text
User chọn Finish
→ Preview summary + confirm
→ Backend validate logs
→ transaction lưu WorkoutLog/sets + tính volume/PR + Schedule COMPLETED
→ result state hiển thị duration, volume, PR do Backend trả
→ MH18 hoặc MH11/MH03
```

#### Failure states

- Schedule không còn PLANNED.
- Session state conflict.
- Validation lỗi tại set.
- Network loss trước mutation: giữ input local tạm thời trong vòng đời màn hình nhưng không báo thành công.
- Finish timeout/unknown result: kiểm tra lại session từ Backend trước khi cho retry để tránh log trùng.
- Discard success không hiển thị PR/completion.

#### Data/API

- `POST /api/v1/workout-sessions/{scheduleId}/start`.
- `POST /api/v1/workout-sessions/{id}/pause`.
- `POST /api/v1/workout-sessions/{id}/resume`.
- `POST /api/v1/workout-sessions/{id}/finish`.
- `POST /api/v1/workout-sessions/{id}/discard`.

### MH18 — Workout History

**Actor:** USER
**Priority:** P0
**Type:** Screen + detail state
**Feature:** FT-WO-009
**Owner:** PH4

#### List

- Khoảng ngày.
- Workout/program name.
- Completed date/time.
- Duration, exercise count và Backend volume nếu có.
- Không trộn discarded session vào completed history.

#### Detail

- Exercise logs, set/reps/weight/duration snapshot.
- Total volume và PR do Backend trả.
- Exercise hidden vẫn hiển thị bằng snapshot/read-only reference.

#### States và rules

- Empty: `Chưa có buổi tập đã hoàn thành` → MH11/MH16.
- Filter no result → reset filter.
- User chỉ xem log của mình.
- History không thay đổi khi Equipment Preference hoặc Program hiện tại đổi.

#### Data/API

- `GET /api/v1/workout-logs`.

### MH19 — Personal Record

**Actor:** USER
**Priority:** P0
**Type:** Screen
**Feature:** FT-WO-008, FT-WO-011
**Owner:** PH4

#### Nội dung

- Filter/search Exercise.
- Record type do Backend xác định, ví dụ weight/reps/volume.
- Giá trị, ngày đạt, workout liên quan và thay đổi so với record trước nếu API trả.

#### Rules và states

- Mobile chỉ hiển thị PR authoritative.
- Không gộp các loại record khác đơn vị thành một giá trị khó hiểu.
- Empty: cần ít nhất một WorkoutLog hợp lệ.
- Exercise hidden vẫn có thể xuất hiện trong PR/history read-only.

#### Data/API

- Dữ liệu progress/PR từ PH4; endpoint chi tiết là contract pending nếu chưa nằm trong `/api/v1/workout-logs`.

---

## 10. Nutrition và Meal Planner

### MH20 — Meal Tab

**Actor:** USER
**Priority:** P0
**Type:** Screen/tab root
**Feature:** PH5 entry, FT-MP-005/006
**Owner:** PH5 Nutrition; target từ PH3

#### Nội dung

1. Date selector, mặc định ngày hiện tại theo timezone.
2. Calories consumed/target/remaining.
3. Protein, carbohydrate và fat progress.
4. BREAKFAST, LUNCH, DINNER, SNACK cùng subtotal.
5. Primary CTA `Thêm món`.
6. Lối vào Food Library, Meal Plan, Summary và History/Template.

#### States và rules

- Thiếu NutritionTarget → CTA hoàn thiện/cập nhật Health Profile; không hiển thị target giả.
- No meal entry → empty theo ngày nhưng vẫn hiển thị target nếu có.
- Vượt target dùng wording trung tính, không phán xét.
- Total/remaining do Backend trả; Mobile không tự cộng làm authority.
- Favorite/Recent không xuất hiện trong P0 nếu feature P1 chưa bật.

### MH21 — Food Library

**Actor:** USER
**Priority:** P0; Favorite/Recent là P1
**Type:** Screen
**Feature:** FT-MP-001; FT-MP-007/008 [P1]
**Owner:** PH5

#### Components

- Search tên món.
- Category filter.
- Food item: ảnh/placeholder, tên, serving chuẩn, calories và macro chính.
- Context chọn bữa nếu mở từ MH24/MH23.

#### Rules

- Dữ liệu demo ưu tiên món Việt nhưng search không hard-code persona.
- Chỉ Food active/public phù hợp được chọn cho entry mới.
- Food hidden giữ history nhưng không xuất hiện như lựa chọn mới.
- Nutrition hiển thị theo serving và có nhãn tham khảo khi nguồn ước lượng.
- Favorite và Recent chỉ hiển thị dưới feature flag P1.

#### States

- Empty catalog.
- No search result → xóa filter.
- Media unavailable.
- Loading/pagination error.

#### Data/API

- `GET /api/v1/foods`.

### MH22 — Food Detail

**Actor:** USER
**Priority:** P0
**Type:** Screen
**Feature:** FT-MP-002, FT-MD-002
**Owner:** PH5; media do PH9

#### Nội dung

- Image/placeholder.
- Name, category.
- Serving size và unit.
- Calories, protein, carbohydrate, fat.
- Source/note và nhãn `Giá trị tham khảo` khi áp dụng.

#### Actions

- `Thêm vào bữa` → MH24 với Food đã chọn nếu có meal/date context.
- Nếu mở độc lập, yêu cầu chọn date/meal type trong MH24.

#### Rules và states

- Thay serving trong preview không được ghi dữ liệu trước khi Add/Save.
- Backend là authority cho giá trị sau chuẩn hóa serving.
- Food vừa bị hidden: cho xem detail/history nếu Backend trả nhưng disable Add.
- Media lỗi không làm mất nutrition text.

#### Data/API

- `GET /api/v1/foods/{id}`.

### MH23 — Meal Plan

**Actor:** USER
**Priority:** P0
**Type:** Screen
**Feature:** FT-MP-003, FT-MP-005, FT-MP-009
**Owner:** PH5

#### Nội dung

- Date selector.
- Bốn section BREAKFAST, LUNCH, DINNER, SNACK.
- Entry item: food snapshot, serving, calories và macro summary.
- Daily total/remaining từ Backend.
- `Thêm món` theo từng meal type.
- Lối vào MH25 và MH54.

#### Actions

- Add → MH24 create mode với date/meal type.
- Tap entry → MH24 edit mode.
- Delete entry qua confirmation.
- Chuyển ngày trước/sau.
- Save/copy template → MH54 hoặc action có preview.

#### Rules

- Một MealPlan cho mỗi user/ngày theo business flow.
- UI không phụ thuộc việc Backend lazy-create hay explicit-create plan.
- Entry hidden Food vẫn hiển thị snapshot trong lịch sử nhưng không được thêm lại nếu hiện không active.
- Mutation chỉ áp dụng resource thuộc user.

#### States

- Empty day.
- Missing NutritionTarget.
- Entry stale/deleted ở thiết bị khác → refresh.
- Date/ownership/validation error.

#### Data/API

- `GET /api/v1/meal-plans?date=`.
- Mutation entry qua endpoint của MH24.

### MH24 — Meal Entry Editor

**Actor:** USER
**Priority:** P0
**Type:** Bottom Sheet; full screen trên thiết bị nhỏ/keyboard
**Feature:** FT-MP-004
**Owner:** PH5

#### Modes

- Create từ Meal Plan/Meal Tab/Food Detail.
- Edit entry hiện có.
- Review proposal từ MH31 trước Apply; proposal mode không mutation trực tiếp tại sheet nếu Apply endpoint là authority.

#### Fields

- Date/context plan.
- Meal type: BREAKFAST, LUNCH, DINNER, SNACK.
- Food search/select.
- Serving unit khả dụng: gram hoặc đơn vị món như tô/chén/phần/quả/ly/miếng.
- Serving amount/multiplier; quick options 0.5, 1, 1.5, 2 chỉ là shortcut.
- Nutrition preview từ response/contract phù hợp.

#### Validation và rules

- Serving/multiplier phải dương và hợp lệ.
- Không thêm Food hidden/inactive.
- Allergy/constraint phải được tôn trọng trong suggestion; khi user chủ động chọn món xung đột, cách cảnh báo/chặn theo Backend contract, không tự suy diễn y tế.
- Không đóng sheet khi lỗi validation.
- Không báo thành công trước response.
- Edit/Delete giữ history/audit theo domain rule.

#### Actions

- Create: `Thêm vào bữa`.
- Edit: `Lưu thay đổi` và secondary `Xóa khỏi bữa`.
- Success cập nhật MH23, MH20 và invalidates MH03 aggregate.

#### Data/API

- `POST /api/v1/meal-plans/{id}/entries`.
- `PUT/DELETE /api/v1/meal-plans/{id}/entries/{entryId}`.

### MH25 — Nutrition Summary

**Actor:** USER
**Priority:** P0
**Type:** Screen
**Feature:** FT-MP-005, FT-MP-006
**Owner:** PH5; target từ PH3

#### Nội dung

- Date/range context rõ ràng; P0 tập trung ngày.
- Calories consumed/target/remaining.
- Protein, carbohydrate, fat consumed/target/remaining.
- Progress/distribution tối giản.
- Breakdown theo meal type nếu response hỗ trợ.

#### Rules và states

- Backend tính entry và daily total sau chuẩn hóa đơn vị.
- Negative remaining có thể hiển thị `Vượt ...`; không clamp về 0 nếu làm mất thông tin.
- Không dùng ngôn ngữ phán xét hoặc biến summary thành chẩn đoán.
- Missing target, empty meal, estimated data và error phải phân biệt.

#### Data/API

- Summary từ `GET /api/v1/meal-plans?date=` hoặc aggregate contract của PH5.

### MH54 — Meal History & Template

**Actor:** USER
**Priority:** P0
**Type:** Screen
**Feature:** FT-MP-009
**Owner:** PH5

#### Mục tiêu và nội dung

- Xem Meal Plan các ngày trước.
- Lưu cấu trúc bữa làm template khi Backend hỗ trợ.
- Xem template của user.
- Copy/apply template sang ngày đích với preview.

#### Rules

- Copy không sửa ngày nguồn.
- Trước copy, hiển thị ngày đích, số bữa/entry và item không còn active.
- Backend validate ownership, target date, Food availability và serving.
- Nếu một Food bị hidden, UI phải báo item bị bỏ/chặn theo kết quả validation; không âm thầm thay món.
- Endpoint/payload template là contract pending trong API Specification.

#### States

- No history.
- No template.
- Partial invalid template.
- Copy conflict/validation error.
- Success → mở MH23 ở ngày đích.

### MH26 — Water Tracker [P1]

**Actor:** USER
**Priority:** P1
**Type:** Screen
**Feature:** FT-MP-010
**Owner:** PH5

#### Scope

- Daily target/intake nếu data model P1 được chốt.
- Quick add và history.
- Không ảnh hưởng calories/macro P0 và không xuất hiện trong P0 navigation.
- Endpoint, target rule và unit contract phải được chốt trước triển khai; tài liệu này không tự định nghĩa business formula.

---

## 11. AI Coach và Personalization

### 11.1. Nguyên tắc UI bắt buộc

```text
AI suggests
→ User reviews
→ User decides
→ Backend authorizes + validates
→ Domain owner executes
```

- Consent được kiểm tra trước Context Builder.
- Consent OFF không gửi Health, Workout, Nutrition, Weight hoặc Preference cá nhân vào AI Service.
- Consent OFF vẫn cho phép General Knowledge Mode.
- Consent OFF không tạo Daily Recommendation cá nhân hóa.
- Mobile không gọi AI Service/Provider trực tiếp.
- AI không chẩn đoán, kê thuốc, cam kết điều trị hoặc khuyến nghị cực đoan.
- AI response có rủi ro y tế/chấn thương phải dùng safe response và hướng user tới chuyên gia phù hợp.
- User message, conversation history, imported text và Food/Exercise text là untrusted input; UI không render nội dung executable.

### 11.2. Recommendation state

```text
PENDING
├── Apply hợp lệ → APPLIED
├── Dismiss → DISMISSED
└── Hết hạn → EXPIRED
```

Chỉ recommendation đúng user, còn `PENDING` và chưa hết hạn mới có Apply/Dismiss khả dụng.

### MH27 — AI Tab

**Actor:** USER
**Priority:** P0
**Type:** Screen/tab root
**Feature:** PH7 entry
**Owner:** PH7 AI Coach

#### Consent ENABLED

- Hiển thị status personalization rõ nhưng không chiếm toàn bộ header.
- 1–3 recommendation hôm nay nếu có.
- `Mở AI Coach` → MH29.
- `Lịch sử trò chuyện` → MH55.
- `Xem tất cả đề xuất` → MH30.
- Weekly Review chỉ khi P1 bật.

#### Consent DISABLED

- Giải thích AI đang ở General Knowledge Mode.
- `Hỏi kiến thức chung` → MH29.
- `Bật cá nhân hóa` → MH28.
- Không hiển thị card personalized recommendation cũ như đề xuất hiện hành. History đã có có thể xem theo policy nhưng không được làm user hiểu rằng hệ thống đang tiếp tục cá nhân hóa.

#### States

- Loading.
- No conversation.
- No recommendation.
- AI temporarily unavailable.
- Consent state load error: mặc định an toàn, không giả định ENABLED.

### MH28 — AI Consent

**Actor:** USER
**Priority:** P0
**Type:** Screen; có entry từ MH27 và MH36
**Feature:** FT-AI-001, FT-AI-002
**Owner:** PH7

#### Nội dung

- Current mode: ENABLED/DISABLED.
- Mô tả mục đích personalization.
- Các nhóm dữ liệu có thể được dùng khi liên quan: Health/Metrics, Workout, Nutrition, Weight, Preference và recent Conversation.
- Nêu rõ data minimization: chỉ context cần thiết cho tác vụ.
- Nêu rõ tắt consent chuyển sang General Knowledge Mode.
- Consent version/updated time nếu Backend trả và có giá trị cho user.

#### Actions

- `Bật cá nhân hóa` hoặc `Tắt cá nhân hóa`.
- Tắt cần confirmation giải thích tác động; không dùng dark pattern.
- Save chỉ khả dụng khi state thay đổi.

#### Rules

- Không yêu cầu consent lại mỗi message.
- Tắt consent không xóa Health/Workout/Meal/Preference và không ngăn logic deterministic sử dụng dữ liệu theo nghiệp vụ.
- Backend lưu consent version/timestamp/history cần thiết.
- UI không có một route MH39 riêng; Settings điều hướng tới chính MH28.

#### States

- Loading current setting.
- Saving.
- Save success.
- Conflict/stale setting → refresh.
- Save error → giữ giá trị server trước đó; không hiển thị toggle giả đã lưu.

#### Data/API

- `GET/PUT /api/v1/ai/consent`.

### MH55 — AI Conversation History

**Actor:** USER
**Priority:** P0
**Type:** Screen
**Feature:** FT-AI-014; FT-AI-015 [P1]
**Owner:** PH7

#### Nội dung và actions

- Danh sách conversation thuộc user.
- Title/preview an toàn, last updated time và mode/context indicator nếu contract cung cấp.
- `Cuộc trò chuyện mới` → tạo conversation → MH29.
- Tap item → MH29 với conversation ID.

#### Rules

- Chỉ recent history cần thiết được gửi lại AI theo context budget; việc list toàn bộ cho user không có nghĩa toàn bộ được gửi mỗi request.
- Automatic conversation summary là P1.
- Không hiển thị internal prompt, context snapshot thô hoặc provider metadata kỹ thuật.

#### States

- Empty → bắt đầu chat mới.
- Loading/pagination.
- Conversation không còn tồn tại/không thuộc user → safe error và quay list.

#### Data/API

- `GET /api/v1/ai/conversations`.
- `POST /api/v1/ai/conversations`.

### MH29 — AI Coach Chat

**Actor:** USER
**Priority:** P0
**Type:** Screen
**Feature:** FT-AI-002, FT-AI-005..007, FT-AI-014
**Owner:** PH7

#### Modes

- **General Knowledge:** consent OFF; không dùng personal context.
- **Personalized:** consent ON; Backend chọn context tối thiểu liên quan câu hỏi.

Mode phải hiển thị đủ rõ để user hiểu phạm vi câu trả lời nhưng không làm lộ context nội bộ.

#### Components

- Conversation title/back/history.
- Message list phân biệt User/AI.
- Composer có multiline, send và disabled/loading state.
- Suggested prompts phù hợp mode.
- Safety/fallback banner khi cần.

#### Suggested prompts

- General: `Giải thích cách thực hiện squat an toàn.`
- Personalized chỉ khi consent ON: `Tôi nên ưu tiên gì trong buổi tập hôm nay?`

Không đưa prompt `Tôi còn thiếu bao nhiêu protein?` ở mode OFF vì câu hỏi cần dữ liệu cá nhân, trừ khi UI giải thích user phải tự cung cấp dữ liệu trong message.

#### Send flow

```text
User gửi message
→ Backend authorization + ownership
→ Consent check
├── OFF: General Knowledge Mode
└── ON: intent → Context Builder → Rule Engine nếu cần
→ AI Service
→ parse + schema/business/safety validation
→ lưu message/conversation
→ render response
```

#### States

- Initial conversation loading.
- Sending/preparing context.
- Generating.
- Success.
- Timeout/provider unavailable → retry giới hạn hoặc gửi lại theo contract.
- Safety fallback.
- Invalid output blocked/fallback; không render structured action lỗi như hợp lệ.
- Session expired/forbidden.

#### Rules

- Không hiển thị token count, prompt, provider key hoặc stack trace.
- Không coi text AI là mutation confirmation.
- Structured proposal từ chat phải mở review phù hợp, không thực thi trực tiếp.
- Retry phải tránh gửi message trùng nếu request trước có kết quả không rõ.

#### Data/API

- `POST /api/v1/ai/conversations/{id}/messages`.
- Conversation create/list qua endpoint MH55.

### MH30 — Daily Recommendation List

**Actor:** USER
**Priority:** P0
**Type:** Screen
**Feature:** FT-AI-008
**Owner:** PH7

#### Nội dung

- Date/context ngày.
- 1–3 recommendation khi đủ dữ liệu.
- Card: type, title, concise content/reason, priority, safety indicator khi cần, status và expiry.
- Filter type/status chỉ khi dữ liệu đủ lớn; filter không phải requirement bắt buộc của P0.

#### Status behavior

- PENDING: nổi bật, mở MH31.
- APPLIED: hiển thị kết quả đã áp dụng nếu Backend trả; không còn CTA mutation.
- DISMISSED: giảm emphasis; không còn Apply.
- EXPIRED: read-only và nêu đã hết hạn.

#### States và rules

- Consent OFF → không tạo/fetch personalized daily item; CTA MH28 tùy UX.
- Empty vì thiếu dữ liệu phải nói rõ giới hạn, không hứa chắc recommendation sẽ có.
- Recommendation phải thuộc user.
- Source metrics hiển thị dạng dữ liệu đã tổng hợp cần thiết, không dump raw context.

#### Data/API

- `GET /api/v1/ai/recommendations/daily`.

### MH31 — Recommendation Detail

**Actor:** USER
**Priority:** P0
**Type:** Bottom Sheet cho simple action; full screen cho review phức tạp
**Feature:** FT-AI-009, FT-AI-010, FT-MP-011, FT-UP-005
**Owner:** PH7 điều phối; mutation thuộc PH2/PH3/PH4/PH5

#### Nội dung chung

- Type, title, content, reason, priority, status, expiry và safety level.
- Source metrics tối thiểu, có đơn vị/thời điểm.
- Proposal preview nếu có action.
- Wording luôn là `Đề xuất`, không là `Đã thay đổi` trước Apply success.

#### UI theo Allowed Action Contract

| Action | UI review bắt buộc | Kết quả Apply |
|---|---|---|
| `NONE` | Insight/reason; không có mutation preview | Không mutation; có thể chỉ Dismiss/Close |
| `ADD_MEAL_ENTRY_PROPOSAL` | Food, meal type, date, serving, calories/macro và constraint warning | PH5 tạo Meal Entry sau validation |
| `CREATE_WORKOUT_SCHEDULE_PROPOSAL` | Program/workout, date/time và exercise summary | PH4 tạo Schedule hợp lệ |
| `UPDATE_USER_PREFERENCE_PROPOSAL` | Field whitelist và before/after | PH2 cập nhật field được user xác nhận |
| `REVIEW_NUTRITION_TARGET_PROPOSAL` | Lý do và metric; CTA mở review | Không tự sửa target; mở MH42/review flow |
| `LOG_REMINDER_ONLY` | Nội dung/thời điểm reminder | Chỉ khả dụng khi PH10/client P1 đã triển khai; không mutation domain |

#### Apply flow

```text
User chọn Áp dụng
→ Confirmation/preview cuối
→ Backend kiểm tra auth + ownership
→ kiểm tra PENDING + chưa expired
→ validate action whitelist + payload schema
→ business + safety validation
→ domain owner mutation trong transaction hợp lệ
→ audit
→ status APPLIED + result
```

#### Dismiss flow

```text
User chọn Bỏ qua
→ optional feedback
→ Backend kiểm tra ownership + PENDING
→ status DISMISSED
→ không mutation Health/Workout/Nutrition/Preference
```

Feedback P0 có thể được lưu như tín hiệu; không tự biến thành Preference mutation. Preference Memory suy luận nâng cao là P1.

#### States và error

- Applying/Dismissing: khóa double submit.
- Stale status/expired → disable action, refresh status.
- Validation failed → hiển thị lý do có thể hành động, không mutation một phần.
- Unknown result/timeout → fetch lại recommendation/domain result trước retry.
- Applied success → hiển thị chính xác resource/result do Backend trả và CTA mở resource tương ứng.

#### Data/API

- `POST /api/v1/ai/recommendations/{id}/apply`.
- `POST /api/v1/ai/recommendations/{id}/dismiss`.

### MH32 — Weekly Review [P1]

**Actor:** USER
**Priority:** P1
**Type:** Screen
**Feature:** FT-AI-011; FT-AI-012 có thể đi qua proposal P1
**Owner:** PH7

#### Nội dung

- Date range rõ.
- Average calories/protein.
- Workout completion.
- Meal logging rate.
- Weight change/trend.
- Strengths, improvement areas và focus tuần sau.

#### Rules

- Metric aggregate do Backend tính.
- Thiếu dữ liệu phải được nêu rõ.
- Không trình bày như báo cáo/chẩn đoán y tế.
- Plan Adjustment luôn là proposal PENDING và dùng review/Apply/Dismiss; không tự mutation.
- Screen bị ẩn hoàn toàn khi P1 chưa bật.

---

## 12. Profile, Preference, Health và Settings

### MH33 — Profile Tab

**Actor:** USER
**Priority:** P0
**Type:** Screen/tab root
**Feature:** Entry PH1/PH2/PH3/PH7
**Owner:** Composite navigation

#### Nội dung

- Avatar, display name và account email/provider summary.
- Hồ sơ cá nhân → MH34.
- Hồ sơ sức khỏe → MH42.
- Cân nặng → MH43.
- Equipment → MH37.
- Sở thích/ràng buộc → MH38.
- AI Personalization → MH28.
- Bảo mật tài khoản → MH53.
- Settings → MH36.
- Logout → MH44.

P1 App/Notification settings chỉ hiển thị khi feature tương ứng bật.

#### Rules

- Fitness goal không được coi là field của UserProfile; nếu hiển thị summary, nguồn vẫn là PH3 và tap mở MH42.
- Không tải raw Health/AI data chỉ để dựng Profile header nếu không cần.

### MH34 — User Profile

**Actor:** USER
**Priority:** P0
**Type:** Screen
**Feature:** FT-UP-001, FT-UP-002
**Owner:** PH2; identity email/provider từ PH1; avatar media từ PH9

#### Nội dung

- Avatar.
- Display name/thông tin cơ bản nằm trong UserProfile whitelist.
- Email và auth provider dạng read-only nếu không có feature đổi email.
- Created/joined metadata chỉ khi API cung cấp và có giá trị UX.
- `Chỉnh sửa hồ sơ` → MH35.

#### Boundary bắt buộc

Gender, date of birth/age, height, current weight, activity level, fitness goal và training experience thuộc Health Profile khi dùng cho calculation; không chỉnh ở MH34/MH35.

#### Data/API

- `GET /api/v1/users/me`.

### MH35 — Edit User Profile

**Actor:** USER
**Priority:** P0 baseline nếu Profile UI được triển khai
**Type:** Screen
**Feature:** FT-UP-001, FT-UP-002
**Owner:** PH2; media PH9

#### Fields

- Display name và field profile nằm trong API whitelist.
- Avatar select/upload/remove nếu baseline media hỗ trợ.
- Không chứa Health calculation fields.
- Số điện thoại chỉ xuất hiện nếu API requirement chính thức hỗ trợ; không tự thêm field.

#### Avatar states

- Local preview trước upload.
- Uploading/progress nếu cần.
- MIME/size/extension invalid.
- Upload success nhưng profile link failure: hiển thị trạng thái đúng, không giả thành công toàn bộ.

#### Rules

- Unsaved-change guard.
- Ownership chỉ user hiện tại.
- Không lưu binary trực tiếp vào PostgreSQL; UI dùng PH9 upload/access contract.

#### Data/API

- `PUT /api/v1/users/me`.
- Media endpoint PH9 khi dùng avatar.

### MH36 — Settings

**Actor:** USER
**Priority:** P0 shell
**Type:** Screen
**Feature:** Navigation PH1/PH2/PH7
**Owner:** Composite navigation

#### Sections

- Workout: MH37 Equipment.
- Nutrition/Personalization: MH38 Preference.
- AI: MH28 Consent.
- Account: MH53 Security, MH44 Logout.
- App: MH40 [P1].
- Notifications: MH41 [P1].

#### Rules

- Không hiển thị hàng P1 không hoạt động như một dead-end.
- Current state có thể hiển thị dạng summary, ví dụ `AI Personalization: Bật`, nhưng mutation thực hiện ở owner screen.
- MH39 không tồn tại như route riêng.

### MH37 — Equipment Preference

**Actor:** USER
**Priority:** P0
**Type:** Screen
**Feature:** FT-UP-004, FT-WO-003
**Owner:** PH2; PH4 consumer

#### Components và actions

- Cùng equipment set với MH10.
- Selected count và selected state rõ.
- Preset `Full Gym`, `Bodyweight only`, reset.
- `Lưu thay đổi` chỉ bật khi form dirty.

#### Rules

- Empty set hợp lệ và kích hoạt fallback BODYWEIGHT ở consumer logic.
- Thay đổi ảnh hưởng ranking/gợi ý tương lai, không sửa Program/Schedule/WorkoutLog cũ một cách tự động.
- Nếu user rời khi dirty, có confirmation.

#### Data/API

- `GET/PUT /api/v1/preferences/equipment`.

### MH38 — User Preference

**Actor:** USER
**Priority:** P0; Preference Memory suy luận là P1
**Type:** Screen
**Feature:** FT-UP-003, FT-UP-005; FT-UP-006/FT-AI-013 [P1]
**Owner:** PH2

#### Sections P0

- Món không thích.
- Dị ứng/ràng buộc do user tự khai báo.
- Meal preference.
- Thời gian/khung giờ tập và training preference được contract hỗ trợ.

Equipment được quản lý tại MH37, có thể liên kết từ đây nhưng không tạo hai nguồn chỉnh sửa khác nhau.

#### Rules

- User chủ động thêm/sửa/xóa preference của mình.
- Allergy/constraint ưu tiên hơn recommendation tối ưu macro.
- Consent OFF không xóa preference.
- Deterministic Exercise/Workout/Meal logic vẫn có thể dùng preference khi không gọi AI.
- Chỉ đưa preference vào AI context khi consent cho phép.
- Apply/Dismiss feedback được ghi từ MH31; màn hình này không tự suy luận preference ở P0.

#### States và API

- Loading, empty từng section, saving, validation, conflict/error.
- `GET/PUT /api/v1/preferences`.

### MH42 — Health Profile View/Edit

**Actor:** USER
**Priority:** P0
**Type:** Screen + edit mode
**Feature:** FT-HP-001..004
**Owner:** PH3

#### Input fields

- Date of birth/age.
- Gender.
- Height.
- Current weight theo Health Profile contract.
- Activity level.
- Fitness goal.
- Training experience.

#### Read-only authoritative metrics

- BMI.
- BMR.
- TDEE.
- Calories target.
- Protein, carbohydrate và fat target.
- Updated time nếu response có.

#### Edit flow

```text
Edit inputs
→ Backend validate
→ recalculation trong transaction hợp lệ
→ trả HealthProfile + NutritionTarget/metrics mới
→ cập nhật Dashboard/Meal/AI context ở lần đọc tiếp theo
```

#### Rules

- Không cho sửa trực tiếp BMI/BMR/TDEE/target output.
- Thay input không sửa WorkoutLog hoặc WeightLog lịch sử.
- Daily weight update ưu tiên đi qua MH43; nếu Health Profile cho sửa current weight, UI tuân theo contract PH3 và không tự tạo WeightLog thứ hai.
- `REVIEW_NUTRITION_TARGET_PROPOSAL` chỉ mở review tại đây; không tự áp target từ AI.

#### States

- Missing/incomplete profile → edit required.
- Recalculating.
- Validation error.
- Recalculation failure → không hiển thị input mới như đã lưu.
- Unsaved-change guard.

#### Data/API

- `GET/PUT /api/v1/health/profile`.
- `GET /api/v1/health/metrics`.

### MH43 — Weight Tracking

**Actor:** USER
**Priority:** P0
**Type:** Screen + add/edit sheet
**Feature:** FT-HP-005..007
**Owner:** PH3

#### Nội dung

- Current/latest weight và date.
- Trend/summary 7–30 ngày do Backend trả.
- Chart theo range được API hỗ trợ.
- Goal marker nếu có dữ liệu goal phù hợp.
- Weight history.
- CTA `Cập nhật cân nặng`.

#### Add/Edit sheet

- Date.
- Weight và unit hiển thị.
- Save.
- Khi đã có log cùng ngày, UI phải thể hiện đây là cập nhật/upsert, không tạo hai item giả.

#### Rules

- Một WeightLog chính/user/ngày.
- Backend tạo trend/summary trước khi AI sử dụng.
- Thêm WeightLog không tự thay NutritionTarget.
- Nếu cần review target, tạo/mở proposal review; user và Backend quyết định.
- Mobile không fit trend line hoặc tính BMI authoritative để ghi đè response.

#### States

- No log → CTA thêm lần đầu.
- Insufficient data for trend → nói rõ chưa đủ dữ liệu.
- Chart loading/error độc lập nếu cần.
- Save conflict cho cùng ngày → refresh và mở edit state.

#### Data/API

- `GET/POST/PUT /api/v1/weight-logs`.
- `GET /api/v1/weight-logs/trend`.

### MH40 — App Settings [P1]

**Actor:** USER
**Priority:** P1
**Type:** Screen
**Feature:** FT-UP-007
**Owner:** PH2/client setting theo contract

#### Scope

- Language.
- Theme System/Light/Dark.
- Display units kg/lb và cm/in.

Display conversion không sửa dữ liệu gốc hoặc metric Backend. Storage/sync policy phải được chốt trước triển khai; screen bị ẩn ở P0.

### MH41 — Notification Settings [P1]

**Actor:** USER
**Priority:** P1
**Type:** Screen
**Feature:** FT-NT-001, FT-NT-002, FT-NT-003, FT-NT-004
**Owner:** PH10 Notification

#### Scope

- Global notification state nếu contract có.
- Workout, meal, weight và AI/weekly reminder theo feature được hỗ trợ.
- OS permission state và link system settings.
- In-app notification list/panel, scheduled/sent/read state nếu feature này được bật; có thể là sheet từ AppShell thay vì route mới.
- Notification bell chỉ xuất hiện cùng P1 notification list/panel, không xuất hiện như icon chết ở P0.

#### Rules

- Notification không là điều kiện dùng core app.
- Không gửi personalized AI notification khi consent không cho phép.
- Lỗi notification không rollback transaction Workout/Meal/Weight.
- Push/automation nâng cao là P2, không gắn nhãn P1 như đã sẵn sàng.

#### Data/API

- `GET /api/v1/notifications`.
- `POST /api/v1/notifications/{id}/read`.
- `GET/PUT /api/v1/notifications/preferences`.

---

## 13. Admin và Media

### 13.1. Phạm vi Admin

Admin UI không nằm trong 5-tab USER shell.

- P0 baseline: shell/navigation, CRUD/hide Exercise, CRUD/hide Food và Audit Log tối thiểu.
- P1: analytics dashboard, User Management, Import CSV/Excel, AI Rule/Prompt và recommendation metrics.
- Mọi route yêu cầu role `ADMIN`; frontend guard chỉ hỗ trợ UX, Backend guard là bắt buộc.

### MH45 — Admin Home/Shell

**Actor:** ADMIN
**Priority:** P0 shell; analytics là P1
**Type:** Screen/root navigation
**Feature:** Navigation baseline; FT-AD-001 [P1]
**Owner:** PH8 Admin & Audit

#### P0 content

- Admin identity/role summary tối thiểu.
- Navigation tới MH46 Manage Exercise.
- Navigation tới MH47 Manage Food.
- Navigation tới MH51 Audit Log.
- Logout → MH44.

#### P1 content

- Aggregate cards: users, exercises, foods, AI requests/recommendations và validation/safety metrics khi API hỗ trợ.
- Links MH49, MH48, MH50.

#### Rules và states

- P1 cards/menu không xuất hiện như dead-end ở P0.
- Không hiển thị PII/raw AI context không cần thiết trong aggregate.
- USER truy cập route → 403 UX, không redirect giả sang Dashboard rồi che lỗi.
- Analytics dùng aggregate API; UI không scan toàn bộ list để tự tính.

#### Data/API

- P0 shell có thể không cần aggregate API.
- `GET /api/v1/admin/dashboard` [P1].

### MH46 — Manage Exercise

**Actor:** ADMIN
**Priority:** P0 baseline
**Type:** Screen list + create/edit form + media picker
**Feature:** FT-AD-003, FT-MD-001, FT-MD-003
**Owner:** PH8 điều phối; Exercise PH4; media PH9

#### List

- Search/filter theo name, muscle, equipment, difficulty và visibility nếu API hỗ trợ.
- Item hiển thị status active/hidden, media state và updated metadata cần thiết.
- Create, edit, hide/unhide.
- Delete chỉ xuất hiện khi business rule cho phép; mặc định ưu tiên hide/soft-delete.

#### Form

- Name.
- Primary/secondary muscle.
- Equipment.
- Difficulty.
- Description.
- Instruction steps.
- Common mistakes.
- Safety notes.
- Visibility.
- Image/video metadata hoặc upload.

#### Validation và rules

- Required field/enum theo API.
- Không publish reference media chưa upload/verify thành công.
- Hidden Exercise giữ WorkoutLog history và không được thêm vào Program mới.
- Preview trước publish là khuyến nghị UX; không thay Backend validation.
- Destructive/hide action có confirmation nêu tác động.
- Mọi mutation quan trọng được audit; không log raw media credential.

#### States

- Empty catalog.
- List/form loading.
- Upload progress/failure.
- Validation error theo field.
- Concurrent edit/conflict.
- Save success và list refresh.

#### Data/API

- `GET/POST/PUT/DELETE /api/v1/admin/exercises`.
- Media endpoints ở mục 13.2.

### MH47 — Manage Food

**Actor:** ADMIN
**Priority:** P0 baseline
**Type:** Screen list + create/edit form + media picker
**Feature:** FT-AD-004, FT-MD-002, FT-MD-003
**Owner:** PH8 điều phối; Food PH5; media PH9

#### List

- Search/filter category/visibility.
- Name, serving summary, calories/macros, source state và visibility.
- Create, edit, hide/unhide; delete chỉ theo contract.

#### Form

- Name, category.
- Serving size/unit.
- Calories, protein, carbohydrate, fat.
- Source/note.
- Visibility.
- Food image media.

#### Validation và rules

- Serving hợp lệ.
- Nutrition values không âm theo domain validation.
- Dữ liệu ước lượng có source/note phù hợp.
- Food hidden giữ Meal history snapshot nhưng không dùng cho Entry mới.
- Hide/delete có confirmation và audit.
- Preview không thay Backend calculation/validation.

#### States và API

- Tương tự MH46: loading, empty, upload, validation, conflict, error, success.
- `GET/POST/PUT/DELETE /api/v1/admin/foods`.
- Media endpoints ở mục 13.2.

### MH51 — Audit Log

**Actor:** ADMIN
**Priority:** P0 baseline
**Type:** Read-only screen + detail
**Feature:** FT-AD-008
**Owner:** PH8

#### Nội dung

- Filter actor/action/target/date/result nếu API hỗ trợ.
- List: timestamp, actor, action, target type/id và result.
- Detail: sanitized metadata cần thiết để truy vết.

#### Rules

- Read-only từ UI.
- Không hiển thị password, access/refresh token, OTP, API key, system prompt hoặc raw personal context thừa.
- Không gọi mọi validation event là actor `AI`; actor/action/result phải hiển thị đúng schema AuditLog của Backend.
- USER không truy cập được.

#### States và API

- Empty theo filter, loading/pagination, no permission, error.
- `GET /api/v1/admin/audit-logs`.

### MH48 — Import Data [P1]

**Actor:** ADMIN
**Priority:** P1
**Type:** Wizard
**Feature:** FT-AD-005
**Owner:** PH8

#### Flow

```text
Chọn CSV/Excel
→ upload/parse
→ preview
→ validation theo dòng
→ hiển thị valid/invalid + reason
→ Admin confirm
→ commit
→ summary
```

#### Rules

- Không commit ngay sau upload.
- File/imported text là untrusted input.
- Commit thất bại không được báo partial success nếu Backend rollback toàn bộ; nếu contract hỗ trợ partial import phải mô tả rõ từng kết quả.
- Không cho file content override authorization, prompt hoặc business rule.
- Error report download chỉ xuất hiện nếu feature/API hỗ trợ.

#### Data/API

- `POST /api/v1/admin/imports/preview`.
- `POST /api/v1/admin/imports/{id}/commit`.

### MH49 — Manage Users [P1]

**Actor:** ADMIN
**Priority:** P1
**Type:** Screen list + detail/action
**Feature:** FT-AD-002
**Owner:** PH8/PH1 theo operation

#### Scope

- Search/filter account theo role/status.
- Basic identity/account state cần thiết.
- Lock/unlock/deactivate theo API requirement.
- Không mở rộng thành quyền xem toàn bộ Health/Meal/Workout/AI data.

#### Rules

- Không hiển thị password hash, token, OTP hoặc secret.
- Lock/unlock cần confirmation và audit.
- Admin vẫn tuân thủ authorization đối với dữ liệu cá nhân.
- Screen bị ẩn ở P0.

#### Data/API

- `GET/POST/PUT /api/v1/admin/users` theo operation contract [P1].

### MH50 — AI Rule / Prompt Management [P1]

**Actor:** ADMIN
**Priority:** P1
**Type:** Screen với Rules/Prompts/Versions/Metrics states
**Feature:** FT-AD-006, FT-AD-007, FT-AD-009
**Owner:** PH8/PH7

#### Scope

- AI Rule: name, signal, condition representation, priority, enabled, version.
- Prompt template: version metadata, variables/schema, status và updated by.
- Recommendation metrics cơ bản nếu API hỗ trợ.

#### Rules

- Versioning bắt buộc theo feature; không chỉnh production prompt mà mất lịch sử.
- Draft/Review/Active workflow chỉ khẳng định khi Backend contract có state tương ứng.
- Không hiển thị provider credential, system secret hoặc raw context snapshot.
- Imported prompt/rule text là untrusted input.
- P1 screen không xuất hiện ở P0.

#### Data/API

- `GET/POST/PUT /api/v1/admin/ai-rules`.
- `GET/POST/PUT /api/v1/admin/prompts`.
- Metrics endpoint là contract pending.

### 13.2. Media UI contract dùng chung

Media không cần một screen độc lập trong P0; nó được nhúng tại MH13, MH22, MH35, MH46 và MH47.

#### Upload flow

```text
Chọn file
→ client kiểm tra sơ bộ
→ Backend khởi tạo upload
→ upload object
→ complete/verify metadata
→ liên kết với Exercise/Food/Profile
```

#### Rules

- Backend validate MIME thực tế, extension, size, role/ownership và entity link.
- PostgreSQL chỉ lưu metadata/object key, không lưu binary nghiệp vụ.
- URL/presigned access có thể hết hạn; UI phải xin URL mới theo contract thay vì lưu vĩnh viễn.
- Media replace/delete không làm hỏng history reference.
- Thumbnail/compress là P1; orphan cleanup/offline media nâng cao không cần UI P0.

#### Data/API

- `POST /api/v1/media/upload-init`.
- `POST /api/v1/media/{id}/upload-complete`.
- `GET /api/v1/media/{id}/access-url`.
- `DELETE /api/v1/media/{id}` khi quyền và business rule cho phép.

---

## 14. Global UI states và error handling

### 14.1. Data state contract

Mọi screen đọc Backend phải xét tối thiểu:

```text
Initial → Loading
Loading → Success(has data | empty)
Loading → Error(retry)
Success → Refreshing
Mutation → Submitting → Success | Validation Error | Conflict | Unknown Result
```

- Skeleton dùng khi cấu trúc nội dung đã biết.
- Spinner toàn màn hình chỉ dùng khi chưa thể render shell/task.
- Refresh không xóa dữ liệu đang hiển thị nếu chưa cần.
- Empty và Error là hai trạng thái khác nhau.

### 14.2. Empty state

Empty state gồm:

- Điều gì chưa có.
- Vì sao điều đó ảnh hưởng.
- Một CTA hợp lệ nếu user có thể xử lý.

Ví dụ chuẩn:

- Dashboard/Profile thiếu: `Hoàn thiện hồ sơ để xem mục tiêu cá nhân.`
- Workout: `Bạn chưa có lịch tập.` → `Tạo lịch tập`.
- Exercise filter: `Không tìm thấy bài phù hợp bộ lọc.` → `Xóa bộ lọc`.
- Meal: `Bạn chưa thêm món cho ngày này.` → `Thêm món`.
- Weight: `Chưa có dữ liệu cân nặng.` → `Cập nhật cân nặng`.
- AI: `Chưa có đề xuất hôm nay.`; CTA phụ thuộc consent/data, không hứa chắc sẽ sinh đề xuất.

### 14.3. Error categories

| Category | Hành vi UI |
|---|---|
| Validation | Gắn lỗi vào field/action; giữ dữ liệu nhập hợp lệ |
| Unauthenticated/session expired | Thử refresh theo contract; thất bại thì Login |
| Forbidden/ownership | Thông báo không có quyền; không retry vô hạn |
| Not found/hidden | Safe empty/not available; không lộ resource user khác |
| Conflict/stale state | Refresh resource và yêu cầu user review lại |
| Rate limit/cooldown | Hiển thị thời gian chờ nếu Backend cung cấp |
| Network/server | Retry; không hiển thị stack trace/provider detail |
| Unknown mutation result | Query lại source of truth trước khi retry |

API Specification quyết định status/error code cụ thể; UI không suy đoán từ text lỗi.

### 14.4. Offline P0

- Hiển thị banner `Không có kết nối` khi phát hiện mất mạng.
- Read screen có thể giữ dữ liệu đã có trong memory hiện tại nhưng phải ghi rõ có thể chưa mới.
- Mutation cần Backend bị chặn hoặc trả lỗi rõ; không xếp hàng ngầm và không báo success.
- Offline cache bền vững, conflict resolution và mutation queue là P2.

### 14.5. Success feedback

- Snackbar/inline success cho thao tác nhỏ.
- Result state cho Workout Finish, Recommendation Apply hoặc Import.
- Navigation back sau save chỉ khi user không cần xem result.
- Không dùng dialog success cho mọi mutation.

### 14.6. Date, timezone và unit

- Dashboard, Meal Plan, Schedule và Recommendation hiển thị date/time theo timezone thống nhất với request/Backend response.
- Không tự chuyển ngày chỉ dựa vào device clock nếu contract có timezone riêng.
- P0 dùng đơn vị chuẩn theo contract; conversion display P1 không sửa dữ liệu gốc.
- Mọi số calories, gram, kilogram, reps, duration có unit/label rõ.

### 14.7. Sensitive UI

- Password/OTP mặc định masked.
- Clipboard/autofill dùng theo platform security guideline.
- Screenshot prevention chỉ áp dụng nếu security spec yêu cầu; không tự thêm hạn chế gây hại UX.
- Crash/analytics log không chứa credential hoặc raw personal context.
- AI reason/source metrics không hiển thị toàn bộ context snapshot.

---

## 15. Component system đề xuất

```text
AppShell
├── RoleGuard / OnboardingGuard
├── AppBar / BottomNavigation
├── SectionHeader / StatusBadge
├── PrimaryButton / SecondaryButton / DestructiveButton
├── LabeledTextField / PasswordField / NumericField
├── SearchField / FilterChip / DateSelector
├── LoadingSkeleton / EmptyState / ErrorState / OfflineBanner
├── ProgressCard / MacroProgress / MetricValue
├── ExerciseCard / FoodCard / WorkoutCard / RecommendationCard
├── MediaViewer / MediaPicker
├── ConfirmationDialog
└── TaskBottomSheet
```

### 15.1. Component ownership

- Component chỉ render và phát event; không tự gọi repository/domain khác ngoài screen/controller contract.
- Metric component nhận authoritative value và metadata.
- StatusBadge nhận enum/status Backend trả; không tự suy diễn transition.
- RecommendationCard không chứa Apply logic đầy đủ; mở MH31 review.
- ErrorState nhận safe user message và retry callback; không render exception text.

### 15.2. Card và layout

- Card lớn cho một nhóm insight/summary.
- List item cho dữ liệu lặp lại.
- Bottom sheet cho add/edit nhanh có ít field.
- Full screen cho wizard, Builder, Session và review phức tạp.
- Dialog chỉ cho confirmation/decision ngắn.

---

## 16. End-to-end UX flows

### 16.1. Register và onboarding lần đầu

```text
MH02 Welcome
→ MH05 Register
→ MH06 OTP Verification [REGISTER]
→ account ACTIVE + token
→ MH09 Health Profile Wizard
→ Backend Health Metrics/Targets
→ MH10 Equipment Onboarding
→ MH03 Dashboard
```

Exit/Back không được bỏ qua OTP hoặc Health Profile bắt buộc. Nếu app bị đóng, lần mở sau MH01 phục hồi state từ Backend/local flow an toàn và đưa user tới bước hợp lệ, không tin hoàn toàn vào cờ local.

### 16.2. Login/returning user

```text
MH01
├── biometric local cần thiết → MH08
├── refresh thành công → role/onboarding guard
└── không phục hồi được → MH04
```

User đã onboarding không bị yêu cầu nhập lại. User pending/locked/disabled không vào Dashboard.

### 16.3. Forgot Password

```text
MH04
→ MH52 nhập email
→ MH06 [PASSWORD_RESET]
→ MH07 đặt mật khẩu mới
→ MH04 login
```

Mọi message phải chống account enumeration và tuân thủ cooldown/attempt từ Backend.

### 16.4. Workout core

```text
MH11
→ MH14/MH15 tạo hoặc chọn Program
→ MH16 tạo Schedule = PLANNED
→ MH17 Start/Pause/Resume
→ Finish hợp lệ
→ WorkoutLog + Schedule COMPLETED + volume/PR từ Backend
→ MH18/MH19
→ MH03 refresh
```

Nhánh Discard không tạo completed log, PR hoặc completion giả.

### 16.5. Meal core

```text
MH20/MH23 chọn ngày và meal type
→ MH21 tìm Food
→ MH22 xem serving/nutrition
→ MH24 Add/Edit Entry
→ Backend summary
→ MH23/MH25
→ MH03 refresh
```

History/template:

```text
MH54 chọn ngày/template nguồn
→ preview ngày đích
→ Backend validation
→ copy hợp lệ
→ MH23 ngày đích
```

### 16.6. Weight và Health recalculation

```text
MH43 thêm/cập nhật WeightLog
→ Backend trend/summary
→ không tự đổi NutritionTarget
→ nếu cần: REVIEW_NUTRITION_TARGET_PROPOSAL
→ user mở MH42 để review
→ Backend mới cập nhật khi flow hợp lệ
```

Sửa field nền tại MH42 làm Backend recalculation; Mobile chỉ render kết quả mới.

### 16.7. AI General Knowledge và Personalized Chat

```text
MH27/MH29
→ Consent check
├── DISABLED: General Knowledge, không personal context
└── ENABLED: context tối thiểu + rules + AI + validation
→ lưu conversation
→ MH29/MH55
```

### 16.8. Daily Recommendation Apply/Dismiss

```text
Consent ENABLED + đủ dữ liệu
→ Backend tạo signals
→ AI output
→ schema/business/safety validation
→ 1–3 PENDING
→ MH30/MH31
├── Apply → authorize/validate → domain mutation → audit → APPLIED
└── Dismiss → feedback/status only → DISMISSED
```

### 16.9. Admin baseline

```text
ADMIN login
→ MH45
├── MH46 Exercise + Media
├── MH47 Food + Media
└── MH51 Audit
```

P1 route chỉ được thêm sau P0 và vẫn dùng role guard/audit.

---

## 17. Traceability

### 17.1. Identity và Profile

| Feature | UI representation | Priority |
|---|---|---|
| FT-ID-001 Register + OTP | MH05, MH06 | P0 |
| FT-ID-002 Local Login | MH04 | P0 |
| FT-ID-003 Google Login | Action tại MH02/MH04; server-side flow | P0 |
| FT-ID-004 Logout/revoke | MH44 | P0 |
| FT-ID-005 Refresh token | MH01 và global session handling; không cần screen riêng | P0 |
| FT-ID-006 Forgot/Reset Password | MH52, MH06, MH07 | P0 |
| FT-ID-007 Change Password | MH53 | P0 |
| FT-ID-008 OTP lifecycle | States/rules tại MH06, MH52, MH07 | P0 |
| FT-ID-009 Biometric local | MH01, MH08 | P0 |
| FT-ID-010 Role/account/authorization | MH04 states, route guards, MH45 | P0 |
| FT-ID-011 Device/session list | MH53 extension | P1 |
| FT-UP-001 Basic Profile | MH34, MH35 | P0 |
| FT-UP-002 Avatar/media | MH34, MH35 + PH9 media states | P0 baseline |
| FT-UP-003 Preference/constraints | MH38 | P0 |
| FT-UP-004 Equipment | MH10, MH37; consumed tại MH12/MH15 | P0 |
| FT-UP-005 Apply/Dismiss feedback | MH31; preference view MH38 | P0 |
| FT-UP-006 Preference Memory | State/feedback extension MH31/MH38 | P1 |
| FT-UP-007 Language/theme/unit | MH40 | P1 |

### 17.2. Health và Dashboard

| Feature | UI representation | Priority |
|---|---|---|
| FT-HP-001 Health Profile lifecycle | MH09, MH42 | P0 |
| FT-HP-002 BMI | MH09 result, MH42, MH03 | P0 |
| FT-HP-003 BMR/TDEE | MH09 result, MH42 | P0 |
| FT-HP-004 Calories/Macro Target | MH09 result, MH42, MH03/MH20/MH25 | P0 |
| FT-HP-005 Weight Log/History | MH43 | P0 |
| FT-HP-006 Trend/Summary | MH43, MH03 | P0 |
| FT-HP-007 Chart/Progress data | MH43, MH03 | P0 |
| FT-DB-001 Daily Nutrition | MH03 | P0 |
| FT-DB-002 Workout Today/Next | MH03 | P0 |
| FT-DB-003 Weekly Completion | MH03 | P0 |
| FT-DB-004 Weight/BMI/Progress | MH03 | P0 |
| FT-DB-005 Recommendation/Insight | MH03 → MH31 | P0 |
| FT-DB-006 Quick Actions | Context actions tại MH03 | P1 |
| FT-DB-007 Loading/Error/Empty | MH03 states + mục 14 | P0 |

### 17.3. Workout

| Feature | UI representation | Priority |
|---|---|---|
| FT-WO-001 Exercise list/search/filter | MH12 | P0 |
| FT-WO-002 Exercise detail/safety/media | MH13 | P0 |
| FT-WO-003 Equipment matching/replacement | MH10, MH12, MH15, MH37 | P0 |
| FT-WO-004 Program/Builder | MH14, MH15 | P0 |
| FT-WO-005 Schedule | MH16 | P0 |
| FT-WO-006 Session lifecycle | MH17 | P0 |
| FT-WO-007 Set/Exercise Log | MH17, MH18 | P0 |
| FT-WO-008 Volume/Completion | MH11/MH16/MH18/MH19 hiển thị Backend value | P0 |
| FT-WO-009 History/Progress | MH18 | P0 |
| FT-WO-010 Favorite Exercise | Component tại MH12/MH13 | P1 |
| FT-WO-011 Personal Record | MH19 | P0 |

### 17.4. Nutrition

| Feature | UI representation | Priority |
|---|---|---|
| FT-MP-001 Food Library | MH21 | P0 |
| FT-MP-002 Food Detail/Serving | MH22 | P0 |
| FT-MP-003 Meal Plan | MH23 | P0 |
| FT-MP-004 Meal Entry/Multiplier | MH24 | P0 |
| FT-MP-005 Daily Summary | MH20, MH23, MH25, MH03 | P0 |
| FT-MP-006 Macro Progress | MH20, MH25 | P0 |
| FT-MP-007 Favorite Food | Component MH21 | P1 |
| FT-MP-008 Recent Food | Component MH21 | P1 |
| FT-MP-009 History/Template | MH23, MH54 | P0 |
| FT-MP-010 Water Tracker | MH26 | P1 |
| FT-MP-011 AI Meal Proposal | MH31 proposal review → PH5; MH24 review context | P0 |

### 17.5. AI

| Feature | UI representation | Priority |
|---|---|---|
| FT-AI-001 Consent/history | MH28; history lưu Backend, không cần route P0 riêng | P0 |
| FT-AI-002 General Knowledge Mode | MH27, MH29 | P0 |
| FT-AI-003 Context Builder | Backend-only; preparing/mode states MH29 | P0 |
| FT-AI-004 Rule Engine/signals | Backend-only; reason/source summary MH30/MH31 | P0 |
| FT-AI-005 Coach Chat | MH29 | P0 |
| FT-AI-006 Workout Advice | MH29 | P0 |
| FT-AI-007 Nutrition Advice | MH29 | P0 |
| FT-AI-008 Daily Recommendation | MH30, MH03 | P0 |
| FT-AI-009 Apply/Dismiss | MH31 | P0 |
| FT-AI-010 Validation | Error/safety/action states MH29/MH31; Backend authority | P0 |
| FT-AI-011 Weekly Review | MH32 | P1 |
| FT-AI-012 Plan Adjustment | Proposal review MH32/MH31 | P1 |
| FT-AI-013 Preference Memory | MH31/MH38 extension | P1 |
| FT-AI-014 Conversation History | MH55, MH29 | P0 |
| FT-AI-015 Summary/feedback nâng cao | MH55/MH29 extension | P1 |

### 17.6. Admin, Media và Notification

| Feature | UI representation | Priority |
|---|---|---|
| FT-AD-001 Admin Dashboard | Analytics state MH45 | P1 |
| FT-AD-002 User Management | MH49 | P1 |
| FT-AD-003 Exercise Management | MH46 | P0 baseline |
| FT-AD-004 Food Management | MH47 | P0 baseline |
| FT-AD-005 Import | MH48 | P1 |
| FT-AD-006 AI Rule | MH50 | P1 |
| FT-AD-007 Prompt/version | MH50 | P1 |
| FT-AD-008 Audit | MH51 | P0 baseline |
| FT-AD-009 Recommendation Metrics | MH50/MH45 analytics | P1 |
| FT-MD-001 Exercise media | MH13, MH46 | P0 baseline |
| FT-MD-002 Food media | MH22, MH47 | P0 baseline |
| FT-MD-003 Metadata/access | Shared media states mục 13.2 | P0 baseline |
| FT-MD-004 Thumbnail/compress | Không cần route; media extension | P1 |
| FT-MD-005 Orphan cleanup | Backend-only; không tạo UI | P2 |
| FT-NT-001, FT-NT-002, FT-NT-003, FT-NT-004 Local/in-app reminder | MH41 và entry P1 liên quan | P1 |
| FT-NT-005 Push/automated AI notification | Không có core UI | P2 |

### 17.7. Business flow và Use Case

| Business flow | Use Case | Screens/UI | Owner | Priority |
|---|---|---|---|---|
| Register/Login/OTP | UC-01 | MH04/05/06/07/52; MH01/08/44/53 | PH1 | P0 |
| Health onboarding/recalculation | UC-02/03 | MH09, MH42 | PH3 | P0 |
| Equipment/Exercise | UC-04 | MH10/37, MH12/13 | PH2/PH4 | P0 |
| Program/Schedule | UC-05/06 | MH14/15/16 | PH4 | P0 |
| Session/Log/Progress | UC-07 | MH17/18/19 | PH4 | P0 |
| Food/Meal | UC-08/09 | MH20..25, MH54 | PH5 | P0 |
| Weight | UC-10 | MH43 | PH3 | P0 |
| Dashboard | UC-11 | MH03 | PH6 | P0 |
| AI Coach/Consent | UC-12/17 | MH27/28/29/55 | PH7 | P0 |
| Recommendation/Apply/Dismiss | UC-13/14 | MH30/31 | PH7 + domain owner | P0 |
| User Preference | UC-18 | MH37/38 | PH2 | P0 |
| Admin baseline | UC-19 | MH45/46/47/51 | PH8 | P0 baseline |
| Media baseline | UC-21 | MH13/22/46/47 + shared media states | PH9 | P0 baseline |
| Weekly/Plan Adjustment | UC-15/16 | MH32/31 | PH7 | P1 |
| Admin mở rộng | UC-20 | MH45/48/49/50 | PH8 | P1 |

---

## 18. Release scope theo UI

### 18.1. P0 bắt buộc

- Auth/session: MH01, MH02, MH04, MH05, MH06, MH07, MH08, MH44, MH52, MH53.
- Onboarding/Health: MH09, MH10, MH42, MH43.
- Main shell: MH03, MH11, MH20, MH27, MH33, MH36.
- Workout: MH12–MH19.
- Nutrition: MH21–MH25, MH54.
- AI: MH28–MH31, MH55.
- Profile/Preference: MH34, MH35, MH37, MH38.
- Admin baseline: MH45 shell, MH46, MH47, MH51.
- Global loading/empty/error/security/accessibility states.

### 18.2. P1 sau khi P0 ổn định

- MH26 Water Tracker.
- MH32 Weekly Review và Plan Adjustment proposal.
- MH40 App Settings.
- MH41 Notification Settings/local reminder.
- MH45 analytics cards.
- MH48 Import.
- MH49 User Management.
- MH50 AI Rule/Prompt/Metrics.
- Favorite Exercise/Food, Recent Food, Preference Memory, conversation summary/feedback nâng cao.

### 18.3. P2/Future

- Push/automation notification.
- Offline queue/cache/conflict resolution nâng cao.
- Media cleanup UI hoặc operations nâng cao nếu sau này có requirement.
- Mọi chức năng đã liệt kê ngoài scope tại mục 1.3.

---

## 19. UX acceptance checklist

### 19.1. Navigation và scope

- [ ] 5 USER tabs hoạt động và giữ stack hợp lý.
- [ ] ADMIN dùng shell riêng; USER không vào Admin route.
- [ ] Deep link chạy qua session/role/ownership/onboarding guard.
- [ ] Không có dead-end hoặc menu P1 giả trong P0.
- [ ] `MH39` không được triển khai như screen trùng MH28.

### 19.2. Authentication

- [ ] Register luôn qua MH06 trước khi account active/token nghiệp vụ.
- [ ] Forgot Password đi MH52 → MH06 → MH07.
- [ ] OTP có invalid/expired/cooldown/attempt/rate-limit state.
- [ ] Login có pending/locked/disabled/error state an toàn.
- [ ] Change Password P0 hoạt động cho local account.
- [ ] Biometric chỉ mở local session và có password fallback.
- [ ] Logout revoke theo contract và clear local credential.

### 19.3. Health và Profile

- [ ] Health Profile tạo/recalculate metric tại Backend.
- [ ] Không sửa trực tiếp BMI/BMR/TDEE/targets.
- [ ] UserProfile không sở hữu field Health Calculation.
- [ ] Weight upsert theo ngày, trend do Backend trả.
- [ ] WeightLog không tự đổi NutritionTarget.

### 19.4. Workout

- [ ] Equipment ảnh hưởng ranking nhưng không sửa log cũ.
- [ ] Exercise hidden không thêm mới nhưng history còn đọc được.
- [ ] Tối đa một active Program theo Backend rule.
- [ ] Schedule hiển thị đúng bốn status.
- [ ] Session có Start/Pause/Resume/Finish/Discard rõ.
- [ ] Finish tạo log/schedule completed atomically; Discard không tạo PR/completion.
- [ ] Volume/completion/PR lấy từ Backend.

### 19.5. Nutrition

- [ ] Food search/detail/serving hỗ trợ core món Việt.
- [ ] Food hidden không dùng cho entry mới.
- [ ] Meal Entry add/edit/delete có validation serving dương.
- [ ] Daily summary/remaining do Backend tính.
- [ ] Giá trị ước lượng có nhãn tham khảo.
- [ ] Meal History/Template P0 có preview/copy validation.
- [ ] Favorite/Recent không bị xem là P0.

### 19.6. AI

- [ ] Consent OFF không gửi personal context và không tạo personalized recommendation.
- [ ] Chat hiển thị đúng General/Personalized mode.
- [ ] Conversation History P0 hoạt động theo ownership.
- [ ] Invalid/safety-failed output không thành structured action hợp lệ.
- [ ] Recommendation có status, expiry, reason và source summary tối thiểu.
- [ ] Chỉ PENDING/chưa expired mới Apply/Dismiss.
- [ ] Mỗi Allowed Action có preview đúng domain.
- [ ] Apply mutation qua domain owner và audit; Dismiss không mutation domain.
- [ ] Unknown result được query lại trước retry.

### 19.7. Admin và Media

- [ ] P0 Admin chỉ gồm shell + Exercise/Food/Audit baseline.
- [ ] User Management/Admin analytics/Import/Rule/Prompt được gắn P1.
- [ ] Exercise/Food dùng hide/soft-delete để bảo toàn history.
- [ ] Upload validate file và không lưu binary trong PostgreSQL.
- [ ] Audit read-only và không chứa secret/raw context thừa.

### 19.8. Accessibility và error

- [ ] Touch target, contrast, semantic label và font scale đạt yêu cầu.
- [ ] Loading, Empty và Error không bị trộn.
- [ ] Form error nằm gần field và được screen reader nhận biết.
- [ ] Offline P0 không giả success hoặc tự queue mutation.
- [ ] UI không hiển thị stack trace, provider detail hoặc credential.

---

## 20. Definition of Done cho một UI unit

Một screen/sheet/dialog được xem là hoàn thành khi:

1. Có ID duy nhất hoặc được ghi rõ là state/alias.
2. Actor, priority, feature và owner đúng.
3. Entry/precondition và navigation/back behavior đầy đủ.
4. Nội dung và CTA đúng business flow.
5. Có loading/empty/error/disabled/conflict/expired state phù hợp.
6. Input có client UX validation và Backend authoritative validation.
7. Mutation có submitting, success, failure và unknown-result handling.
8. Ownership/authorization được Backend kiểm tra.
9. Không tự tính/ghi đè metric authoritative.
10. Không tạo feature ngoài scope hoặc hiển thị P1 như P0.
11. Destructive action có confirmation.
12. Accessibility và responsive behavior được kiểm tra.
13. Không log/hiển thị secret hoặc raw personal context.
14. Có test theo acceptance criteria và feature mapping tương ứng.

---

## 21. Definition of Done của tài liệu

Tài liệu này hoàn thiện khi:

- Mọi feature P0 trong `phan_ra_tinh_nang.md` được map tới screen/component/state hoặc ghi rõ backend-only.
- Mỗi screen có actor, priority, owner và feature mapping.
- P0/P1/P2 nhất quán với baseline đã nêu và không có CTA dead-end.
- Register OTP, Change Password, Meal History/Template và AI Conversation History được bao phủ.
- Schedule, Session và Recommendation state machine có UI transition/error đầy đủ.
- User Profile và Health Profile không trùng ownership field.
- AI Consent, context boundary, safety và Apply/Dismiss không cho AI tự mutation.
- Admin/Media scope không làm mất history hoặc lộ dữ liệu nhạy cảm.
- Không còn tham chiếu phiên bản nguồn cũ hoặc file không tồn tại.
- Markdown có heading hierarchy, table và code block hợp lệ; ID không trùng.

---

## 22. Demo flow đề xuất

```text
1. MH05 Register
2. MH06 Verify OTP
3. MH09 Health Profile → Backend Metrics
4. MH10 Equipment
5. MH03 Dashboard empty/initial state
6. MH12 Exercise Library → MH13 Detail
7. MH14/MH15 Program
8. MH16 Schedule
9. MH17 Start/Finish Session
10. MH18/MH19 Log và PR
11. MH21 Food → MH22 Detail
12. MH24 Add Meal Entry
13. MH23/MH25 Summary
14. MH43 Weight Tracking
15. MH28 Consent ENABLED
16. MH29 AI Chat + MH55 History
17. MH30/MH31 Recommendation
18. Apply hoặc Dismiss
19. MH03 Dashboard cập nhật
20. MH37/MH38 chỉnh Preference
21. MH46/MH47/MH51 Admin baseline nếu cần demo quản trị
```

Flow phải chứng minh được:

```text
User input
→ Backend calculation/domain data
→ Dashboard aggregate
→ Consent-controlled AI context
→ Validated proposal
→ User approval
→ Domain mutation + audit
```

---

## 23. Kết luận thiết kế

VieGym UI lấy Dashboard làm trung tâm, nhưng dữ liệu và mutation vẫn thuộc các subsystem owner. Workout và Meal tối ưu cho thao tác hằng ngày; Health cung cấp metric authoritative; Profile tách rõ hồ sơ cơ bản và dữ liệu tính sức khỏe; AI luôn phân biệt General Knowledge với Personalized Mode và không tự thay đổi dữ liệu.

Nguyên tắc cuối cùng:

> User phải luôn biết mình đang ở đâu, dữ liệu đang ở trạng thái nào, hành động nào sắp xảy ra và ai là người quyết định thay đổi.
