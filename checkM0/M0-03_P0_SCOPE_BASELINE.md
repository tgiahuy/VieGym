# M0-03 — P0 Scope Baseline

> **Ngày khóa:** 2026-08-19  
> **Nguồn:** SRS v3.0 và Feature Breakdown v3.0  
> **Trạng thái:** FROZEN cho MVP đồ án tốt nghiệp

## 1. Mục đích

Tài liệu này là danh sách P0 chính thức dùng để lập backlog, triển khai, kiểm thử và nghiệm thu. Tính năng không xuất hiện trong danh sách P0 dưới đây không được đưa vào đường găng MVP nếu chưa có quyết định thay đổi scope được phê duyệt.

## 2. Feature P0 chính thức — 62 feature

### PH1 Identity & Auth — 10

- FT-ID-001..010: đăng ký/OTP, login local/Google, logout, refresh rotation, password flows, biometric local, role/account/authorization.

### PH2 User Profile & Preference — 4

- FT-UP-001: Basic User Profile.
- FT-UP-003: User Preference và constraints.
- FT-UP-004: Equipment Preference.
- FT-UP-005: Apply/Dismiss feedback.

### PH3 Health & Body — 7

- FT-HP-001..007: Health Profile, BMI, BMR/TDEE, calories/macro target, Weight Log, trend và chart/progress.

### PH4 Workout — 10

- FT-WO-001..009: Exercise, matching, Program, Schedule, Session, Log, volume và history.
- FT-WO-011: Personal Record.

### PH5 Nutrition & Meal Planner — 8

- FT-MP-001..006: Food, Meal Plan/Entry và nutrition summary.
- FT-MP-009: Meal History/Template.
- FT-MP-011: AI Meal Proposal integration.

### PH6 Dashboard — 6

- FT-DB-001..005: nutrition/workout/body/AI cards và weekly completion.
- FT-DB-007: section-level empty/error/partial state.

### PH7 AI Coach — 11

- FT-AI-001..010: consent, context, rule engine, provider, chat, validation, recommendation và Apply/Dismiss.
- FT-AI-014: Conversation History.

### PH8 Admin & Audit — 3

- FT-AD-003: Manage Exercise.
- FT-AD-004: Manage Food.
- FT-AD-008: Audit Log.

### PH9 Media & Storage — 3

- FT-MD-001: Exercise media.
- FT-MD-002: Food media.
- FT-MD-003: Media metadata/access baseline.

### PH10 Notification

- Không có feature P0. Notification bắt đầu từ P1.

## 3. UI P0 chính thức — 47 UI unit

### USER — 43

- Auth/session: MH01, MH02, MH04, MH05, MH06, MH07, MH08, MH44, MH52, MH53.
- Health/onboarding: MH09, MH10, MH42, MH43.
- Main shell: MH03, MH11, MH20, MH27, MH33, MH36.
- Workout: MH12..MH19.
- Nutrition: MH21..MH25, MH54.
- AI: MH28..MH31, MH55.
- Profile/preference: MH34, MH35, MH37, MH38.

### ADMIN — 4

- MH45: Admin Home/Shell tối thiểu.
- MH46: Manage Exercise.
- MH47: Manage Food.
- MH51: Audit Log.

## 4. Acceptance và E2E P0

- AC-01..AC-19 là điều kiện nghiệm thu bắt buộc.
- E2E-01..E2E-07 phải có happy path và ít nhất một failure branch.
- Backend ownership/security test là bắt buộc kể cả khi UI đã có route guard.
- `calculationStatus=INCOMPLETE` là kết quả hợp lệ, không phải lý do bịa target.
- Schedule `CANCELLED`; Session `DISCARDED`.

## 5. P1 — Không triển khai trước khi P0 ổn định

- FT-ID-011.
- FT-UP-002, FT-UP-006, FT-UP-007.
- FT-WO-010.
- FT-MP-007, FT-MP-008, FT-MP-010.
- FT-DB-006.
- FT-AI-011, FT-AI-012, FT-AI-013, FT-AI-015.
- FT-AD-001, FT-AD-002, FT-AD-005, FT-AD-006, FT-AD-007, FT-AD-009.
- FT-MD-004.
- FT-NT-001..004.

Các UI P1: MH26, MH32, MH40, MH41, MH48, MH49, MH50 và các state/component Favorite/Recent/Preference Memory/Avatar upload.

## 6. P2/Future và Out of Scope

### P2

- FT-MD-005 orphan cleanup nâng cao.
- FT-NT-005 push/automated notification.
- Offline mutation queue/cache/conflict resolution nâng cao.

### Out of Scope

- Shop/Marketplace, Cart, Order và Payment.
- Wearable, Apple Health và Google Fit.
- Food image recognition.
- Pose estimation/Computer Vision.
- ML prediction riêng.
- AI tự mutation mà không có User approval.
- Microservices, Kubernetes, service mesh và message broker.
- Thu thập dữ liệu sức khỏe người dùng thật trong môi trường đồ án.
- Production legal-retention và self-service account deletion workflow.

## 7. Quy tắc thay đổi scope

Một đề xuất chỉ được thêm vào P0 khi đồng thời có:

1. Lý do bắt buộc để đạt một AC hiện có hoặc yêu cầu chính thức của giảng viên.
2. Phân tích ảnh hưởng timeline, API, database, UI và test.
3. Quyết định thay đổi được ghi trong SRS và tài liệu owner.
4. Backlog và Project Progress được cập nhật cùng change.

Nếu không đủ bốn điều kiện, đề xuất được đưa vào P1/P2 backlog và không triển khai trong MVP.

## 8. Kết luận

- P0 chính thức: 62 feature, 47 UI unit, 19 AC và 7 E2E.
- Không có Shop, Payment, Wearable hoặc feature P1 trong P0.
- Avatar upload là P1; Media P0 chỉ gồm Exercise/Food.
- Admin P0 chỉ gồm Exercise/Food/Audit.
