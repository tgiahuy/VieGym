# M0-02 — Review tính nhất quán bộ đặc tả

> **Ngày review/revise:** 2026-08-31
> **Nguồn ưu tiên:** SRS v3.2 → Business Flow → Subsystem Breakdown → Feature Breakdown → Screen Breakdown
> **Kết luận:** Đạt sau khi xử lý các mâu thuẫn phát hiện

## 1. Phạm vi kiểm tra

- `docs/spec/specs.md`
- `docs/spec/bussiness_mainflow.md`
- `docs/spec/phan_ra_phan_he_he_thong.md`
- `docs/spec/phan_ra_tinh_nang.md`
- `docs/spec/phan_ra_man_hinh.md`
- Đối chiếu contract liên quan trong API, Database, Architecture và Master Design.

## 2. Kết quả định lượng

- 21 Use Case trong SRS, gồm P0 và P1.
- 19 Acceptance Criteria trong SRS; 19/19 có mapping UI hoặc ghi rõ Backend-only.
- 10 subsystem có owner và boundary.
- 68 feature P0/P0 baseline và 18 feature P1 sau PLAN-007.
- 50 UI unit P0: 46 USER và 4 ADMIN.
- Tất cả feature P0 đều có tham chiếu trong Screen Breakdown hoặc được mô tả là shared/backend behavior.
- Không còn Session status dùng lẫn `CANCELLED` và `DISCARDED`.
- Không còn Avatar/Profile media bị gắn P0.

## 3. Mâu thuẫn đã xử lý

### C-01 — Workout Session dùng lẫn CANCELLED và DISCARDED

- **Quyết định:** `CANCELLED` chỉ thuộc Workout Schedule; Session đã bắt đầu dùng `DISCARDED` khi user hủy.
- **Contract P0:** Start tạo Session `IN_PROGRESS`; `IN_PROGRESS ↔ PAUSED`; Finish → `COMPLETED`; Discard → `DISCARDED`.
- **Đã đồng bộ:** Business Flow, Subsystem, Screen, API, Database và System Architecture.

### C-02 — Health onboarding luôn giả định tạo NutritionTarget

- **Quyết định:** HealthProfile và WeightLog được lưu khi input hồ sơ hợp lệ; NutritionTarget chỉ được tạo/upsert khi `calculationStatus=COMPLETE`.
- **INCOMPLETE:** calculation sex chưa cung cấp, age dưới 18, calories dưới safety threshold hoặc macro invalid.
- **Đã đồng bộ:** Feature, Screen, Business Flow, API và Database.

### C-03 — Admin overview hiển thị tính năng P1 như core

- **Quyết định:** P0 chỉ gồm Exercise, Food và Audit; User Management và AI Rule/Prompt là P1.
- **Đã đồng bộ:** Overview text/diagram và Admin flow chi tiết.

### C-04 — Avatar/Profile media vượt phạm vi SRS P0

- **Quyết định:** P0 dùng avatar placeholder/initial; upload avatar `FT-UP-002` là P1.
- **Media P0:** chỉ Exercise và Food.
- **Đã đồng bộ:** Feature priority, Screen inventory/traceability, Master Design và Project Progress.

### C-05 — SRS MVP table chưa liệt kê Admin/Media baseline

- **Quyết định:** thêm hai hàng Admin & Audit baseline và Media baseline vào danh sách MVP bắt buộc để khớp AC-18/19, UC-19/21 và Feature Breakdown.

### C-06 — Screen Breakdown chưa truy vết trực tiếp AC

- **Quyết định:** thêm mapping AC-01..AC-21 tới UI coverage chính và ghi rõ phần Backend-only.

## 4. Quy tắc canonical sau review

1. SRS quyết định scope, priority, business rule cấp cao và Acceptance Criteria.
2. Business Flow không được thêm actor/flow P0 ngoài SRS.
3. Feature Breakdown là danh sách ID/priority triển khai canonical.
4. Screen Breakdown chỉ hiện thực feature; backend-only behavior không tạo screen giả.
5. Schedule `CANCELLED` và Session `DISCARDED` là hai trạng thái khác nhau.
6. Health calculation có thể `INCOMPLETE`; UI không tạo target giả.
7. Media P0 chỉ áp dụng Exercise/Food; Profile avatar là P1.
8. Admin mở rộng và AI Rule/Prompt không được xuất hiện như chức năng khả dụng trong P0.

## 5. Bằng chứng hoàn thành

- Search toàn bộ tài liệu không còn stale Session `CANCELLED` transition.
- Search không còn `FT-UP-002` hoặc Profile media được gắn P0.
- 19/19 mã AC xuất hiện trong Screen Breakdown sau khi bổ sung traceability.
- 68/68 feature P0 có screen/shared/backend coverage.
- Các thay đổi contract đã được cập nhật đồng thời ở tài liệu owner.
