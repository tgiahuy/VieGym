# M0-13 — P0 backlog và traceability baseline

> Trạng thái: READY · Ngày revise: 2026-08-31 · Scope: 68 feature P0, 21 AC, 8 E2E

## Quy ước thực thi

- Thứ tự ưu tiên: `P0-Critical` chặn đăng nhập/core flow; `P0-High` hoàn thành vertical slice; `P0-Normal` hoàn thiện dashboard/admin.
- Một story chỉ Done khi DB migration, Backend/API, Mobile UI state và test liên quan đều đạt; story không có tầng nào thì ghi `—` rõ ràng.
- API path chi tiết tuân theo `kientruchethong/API_SPEC.md`; table/constraint tuân theo `kientruchatang/DATABASE.md`.
- Dependency dùng story ID trong file này. M1 foundation là dependency chung cho mọi story có code.

## Epic E1 — Identity, Profile và Health

| Story | Priority | Dependency | UC / FT / AC | MH | API / DB | Test bắt buộc |
|---|---|---|---|---|---|---|
| ST-01 Local register + OTP | P0-Critical | M1 | UC-01; FT-ID-001/008/010; AC-01/19 | MH05/06 | `/auth/register`, `/auth/otp/verify`, `/auth/otp/resend`; `users`, `otp_codes`, `audit_logs` | register pending, OTP success/wrong/expired/reuse/cooldown/rate-limit, enumeration/log redaction |
| ST-02 Login, refresh, logout | P0-Critical | ST-01 | UC-01; FT-ID-002/004/005/010; AC-01/02/19 | MH01/04/44 | `/auth/login`, `/auth/refresh`, `/auth/logout`; `users`, `refresh_tokens` | role/status guard, rotation, reuse revokes family, concurrent refresh single-flight, logout |
| ST-03 Password + social login + biometric | P0-High | ST-01/02 | UC-01; FT-ID-003/006/007/009; AC-01/19 | MH02/04/05/06/07/08/52/53 | forgot/reset/change + Google/Facebook endpoints; `users`, `otp_codes`, `refresh_tokens` | invalid Google/Facebook token, Facebook app/expiry/email/link conflict, reset purpose isolation, change password, biometric không bypass server |
| ST-04 User/equipment preference | P0-High | ST-02 | UC-04/18; FT-UP-001/003/004; AC-02/05 | MH10/34/35/37/38 | `/profile`, `/preferences`, `/equipment-preferences`; profile/preference/equipment tables | whitelist update, ownership, empty-equipment onboarding flag, equipment filter/match |
| ST-05 Health onboarding + calculation | P0-Critical | ST-02 | UC-02/03; FT-HP-001..004; AC-03/04 | MH09/42 | health profile/metric/target endpoints; `health_profiles`, `nutrition_targets`, `weight_logs` | range, calculationSex/age incomplete, BMI/BMR/TDEE/macro fixtures, atomic save |
| ST-06 Weight history/trend | P0-High | ST-05 | UC-10; FT-HP-005..007; AC-09 | MH43 | `PUT /weight-logs/{loggedDate}`, list/summary; `weight_logs` | natural-key upsert, newest-log metric sync, target unchanged, 7/30-day trend, chart insufficient-data state |

## Epic E2 — Workout

| Story | Priority | Dependency | UC / FT / AC | MH | API / DB | Test bắt buộc |
|---|---|---|---|---|---|---|
| ST-07 Exercise catalog + matching | P0-High | ST-04 | UC-04; FT-WO-001..003; AC-02/05 | MH12/13 | exercise list/detail/alternatives; exercise/equipment/muscle tables | search/filter/page, visibility, equipment match, safety/media fallback |
| ST-08 Program builder | P0-High | ST-07 | UC-05; FT-WO-004; AC-06 | MH14/15 | program CRUD/items; `workout_programs`, `workout_days`, `workout_exercises` | stable child ID diff, referenced-day delete guard, order/sets/reps, hidden exercise history |
| ST-09 Schedule | P0-High | ST-08 | UC-06; FT-WO-005; AC-06 | MH16 | schedule CRUD; `workout_schedules` | lazy MISSED cutoff+grace, cancel cutoff, active-session exclusion, timezone, ownership |
| ST-10 Session + log + PR | P0-Critical | ST-08/09 | UC-07; FT-WO-006..009/011; AC-02/06/07 | MH17/18/19 | session start/pause/resume/log/finish/discard/history/PR; execution + `personal_records` | one active session/user, idempotent finish, volume/completion/PR transaction, discard, offline retry |

## Epic E3 — Nutrition và Dashboard

| Story | Priority | Dependency | UC / FT / AC | MH | API / DB | Test bắt buộc |
|---|---|---|---|---|---|---|
| ST-11 Food catalog | P0-High | M1 | UC-08; FT-MP-001/002; AC-02/08 | MH21/22 | food list/detail/servings; food tables | normalized search, serving/gram conversion only with gramsPerServing, visibility |
| ST-12 Meal planner + summary | P0-Critical | ST-05/11 | UC-09; FT-MP-003..006; AC-02/08 | MH20/23/24/25 | meal plan/entry/daily summary; meal plan/meal/entry tables | GET no write, immutable target snapshot on first mutation, input-unit snapshot, aggregation, target incomplete |
| ST-13 Meal history/template | P0-High | ST-12 | UC-09; FT-MP-009/011; AC-08/13 | MH31/54 | meal history/template/proposal apply; meal template/entry tables | snapshot, copy template idempotency, AI proposal revalidation |
| ST-14 Dashboard read model | P0-Normal | ST-05/06/09/10/12 | UC-11; FT-DB-001..005/007; AC-10 | MH03 | `/dashboard`; aggregate queries, không table owner mới | loading/empty/partial error, today/timezone, ownership, aggregate fixtures |

## Epic E4 — AI Coach

| Story | Priority | Dependency | UC / FT / AC | MH | API / DB | Test bắt buộc |
|---|---|---|---|---|---|---|
| ST-15 Consent + context/rules | P0-Critical | ST-02/05 | UC-17; FT-AI-001..004; AC-11/12/19 | MH28/36 | consent/context/rule internal APIs; consent/rule/context-log tables | consent off sends no personal context, whitelist/budget, prompt/log redaction |
| ST-16 Coach + history | P0-High | ST-15 | UC-12; FT-AI-005..007/010/014; AC-12/13 | MH29/55 | conversation/message + internal AI endpoint; conversation/message/provider-call tables | provider timeout/fallback, structured-output invalid, ownership, workout/nutrition safety |
| ST-17 Daily recommendation | P0-High | ST-15/16 | UC-13; FT-AI-008/010; AC-12/13/14 | MH30 | read-only GET + POST generation command; generation/recommendation tables | `rules-v1`, candidate shortlist, batch idempotency, 1–3 atomic items, timezone expiry, BLOCKED not persisted |
| ST-18 Apply/Dismiss + feedback | P0-Critical | ST-17 plus target domain | UC-14; FT-AI-009/010; FT-UP-005; AC-02/13/15/16/17 | MH31/38 | apply/dismiss; recommendation/log/audit + target domain table | lock/version/idempotency, targetDate/candidate/preference whitelist revalidation, Apply transaction, Dismiss no mutation |

## Epic E5 — Admin, Media và Audit

| Story | Priority | Dependency | UC / FT / AC | MH | API / DB | Test bắt buộc |
|---|---|---|---|---|---|---|
| ST-19 Admin Exercise/Food + audit | P0-Normal | ST-07/11 | UC-19; FT-AD-003/004/008; AC-02/19 | MH45/46/47/51 | admin exercise/food CRUD, audit list; catalog/audit tables | ADMIN role, validation, hide preserves history, audit redaction/filter |
| ST-20 Media lifecycle | P0-High | ADR-003/006, ST-19 | UC-21; FT-MD-001..003; AC-18/19 | MH13/22/46/47 | resource-first upload-init/complete/access/delete; `media_objects` | non-null owner, role/sort, presigned TTL, MIME spoof/size, allowlist, orphan/failed state |

## Epic E6 — Favorites và Notification

| Story | Priority | Dependency | UC / FT / AC | MH | API / DB | Test bắt buộc |
|---|---|---|---|---|---|---|
| ST-21 Favorite Exercise/Food | P0-High | ST-07/11 | UC-04/08; FT-WO-010, FT-MP-007; AC-02/20 | MH12/13/21/22/56/57 | favorite list/add/remove; `favorite_exercises`, `favorite_foods` | ownership, composite uniqueness, add/remove idempotent, hidden visibility, restore after app restart |
| ST-22 Notification Center/Reminder | P0-High | ST-02/06/09/12/15 | UC-22; FT-NT-001..004; AC-02/11/21 | MH03/41 | `/notifications/**`; `notifications`, `notification_preferences` | ownership, list/read/read-all/delete/preference, timezone/quiet hours, consent, failure isolation, deep-link guard |

## Phủ phạm vi và E2E

- 68/68 feature P0 được gắn vào ST-01..ST-22; P1/P2 không nằm trong story acceptance.
- AC-01..AC-21 đều có ít nhất một story owner và test tương ứng.
- 8 E2E bắt buộc: register/onboarding (ST-01/05), workout (ST-07..10/21), meal (ST-11..13/21), weight/dashboard (ST-06/14), AI consent/chat (ST-15/16), recommendation Apply/Dismiss (ST-17/18), admin/media (ST-19/20), Notification Center/reminder (ST-22).
- Execution order: M1 foundation → ST-01..06 → ST-07..14/21 → ST-15..18 → ST-19..20/22; story độc lập trong cùng phase có thể làm song song nhưng không bỏ dependency.
