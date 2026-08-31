# M0-15 — Definition of Ready review cho M1 và M2

> Kết luận: **PASS — 50/50 ticket READY** · Ngày review: 2026-08-28

## Tiêu chí review

Mỗi ticket phải có: ID duy nhất; phạm vi/technical owner; input contract hoặc tài liệu owner; kết quả kiểm thử được; dependency hoặc fake/mock; không phụ thuộc ADR còn OPEN. Chi tiết implementation nhỏ được phép quyết định trong ticket nếu không đổi contract/phạm vi.

## M1 — 22/22 READY

| Ticket | Owner/phạm vi đã rõ | Output nghiệm thu và dependency |
|---|---|---|
| M1-01 | Mobile skeleton; baseline M0-11/ADR-001 | Flutter 3.44.4 project build được; không dependency |
| M1-02 | Backend skeleton; M0-11/12 | Spring Boot 3.5.16 + Java 21 + Maven Wrapper build được |
| M1-03 | AI skeleton; M0-11/12/ADR-002 | Python 3.12 + FastAPI 0.141.1 + `uv.lock`, health import được |
| M1-04 | Repo hygiene | `.gitignore`, `.editorconfig`, formatter/linter theo M0-14 |
| M1-05 | Configuration security | `.env.example`, secret scan; phụ thuộc skeleton |
| M1-06 | Container build | Backend/AI Dockerfile pin runtime, non-secret build |
| M1-07 | Local stack | Compose gồm Backend/AI/PostgreSQL 16.14/MinIO theo ADR-003 |
| M1-08 | Runtime network | Healthcheck/internal network test; phụ thuộc M1-06/07 |
| M1-09 | Backend persistence | Env datasource + connection integration test; phụ thuộc M1-02/07 |
| M1-10 | Schema migration | Flyway baseline trên DB rỗng; DATABASE.md là input |
| M1-11 | API common contract | Envelope/pagination/error theo API_SPEC; contract test |
| M1-12 | Error mapping | Validation/exception cases trả error canonical |
| M1-13 | Observability | Correlation ID + JSON log + redaction test; AC-19 |
| M1-14 | Backend health | Liveness/readiness phản ánh dependency đúng semantics |
| M1-15 | API documentation | OpenAPI/Swagger local khớp endpoint baseline |
| M1-16 | Mobile foundation | Theme/router/ProviderScope/env; phụ thuộc M1-01/ADR-001 |
| M1-17 | Mobile networking | Dio timeout/interceptor/error mapping; fake HTTP test |
| M1-18 | Shared UI state | Loading/empty/error/offline/retry widget states có widget test |
| M1-19 | AI internal guard | Health + service-token guard; phụ thuộc M1-03 |
| M1-20 | AI contract/fake | Pydantic request/response + fake provider theo ADR-002 |
| M1-21 | CI | Format/lint/test/migration/build cả ba project; phụ thuộc skeleton |
| M1-22 | Setup guide | Clean setup/run/test ≤30 phút; kiểm chứng trên checkout sạch |

## M2 — 28/28 READY

| Ticket | Traceability/contract | Output nghiệm thu và dependency |
|---|---|---|
| M2-01 | ST-01/02; DB Identity | Migration users/refresh_tokens/otp_codes; M1-10 |
| M2-02 | UC-01; FT-ID-010 | Enum role/status/purpose đồng bộ API/DB |
| M2-03 | ST-01; FT-ID-001 | Register pending, email/password validation, BCrypt; M2-01/02 |
| M2-04 | ST-01; FT-ID-001/008; ADR-005 | EmailSender adapter, fake local/test, Resend production |
| M2-05 | ST-01; AC-01 | Atomic consume OTP → activate → session; M2-03/04 |
| M2-06 | ST-01; FT-ID-008; ADR-005 | TTL/attempt/cooldown/rate-limit test chính xác |
| M2-07 | ST-02; FT-ID-002/010 | Login kiểm tra password + account status |
| M2-08 | ST-02; FT-ID-005; ADR-004 | JWT 15 phút, refresh rotation/reuse-family revoke |
| M2-09 | ST-02; FT-ID-004 | Logout revoke session, idempotent/expired cases |
| M2-10 | ST-03; FT-ID-006/008 | Forgot/reset purpose-isolated, enumeration-safe |
| M2-11 | ST-03; FT-ID-007 | Change password authenticated + revoke policy test |
| M2-12 | ST-03; FT-ID-003 | Verify Google issuer/audience/signature/expiry server-side |
| M2-13 | FT-ID-010; AC-01/02 | Public/private/admin policy integration test |
| M2-14 | AC-19; ADR-004/005 | Enumeration và log-redaction security tests |
| M2-15 | ST-04; FT-UP-001/003/004 | Migration profile/preference/equipment; M1-10 |
| M2-16 | ST-05; FT-HP-001..004 | Migration health/target/initial weight; M1-10 |
| M2-17 | ST-04; FT-UP-001; AC-02 | Profile whitelist + ownership API test |
| M2-18 | ST-04; FT-UP-003/004; AC-05 | Preference/equipment save/read test |
| M2-19 | ST-05; FT-HP-001 | Field/range validation fixtures từ SRS/API |
| M2-20 | ST-05; FT-HP-002/003; AC-03/04 | BMI/Mifflin/TDEE golden fixtures |
| M2-21 | ST-05; FT-HP-004; AC-03/04 | health-v1 calorie/macro/incomplete rule fixtures |
| M2-22 | ST-05; AC-03 | Atomic profile+metric+optional target+initial weight |
| M2-23 | ST-01/02; MH01/02/04/05/06 | Auth UI states + navigation/widget/integration test |
| M2-24 | ST-03; MH07/08/44/52/53 | Password/logout/biometric UI, không bypass server |
| M2-25 | ST-04/05; MH09/10 | Health/equipment onboarding + authoritative guard |
| M2-26 | ST-02; ADR-004 | Secure storage, memory access token, single-flight, clear logout |
| M2-27 | ST-01..05; AC-01..05/19 | Unit/integration/widget suite và E2E register/onboarding |
| M2-28 | ST-03; FT-ID-003; MH02/04/05 | Facebook SDK + Backend verifier + `FACEBOOK` migration/API + invalid/app/expiry/email/link tests; M2-02/08/12/23 |

## Audit dependency và quyết định mở

- M1/M2 không phụ thuộc production hosting, WAF, observability vendor, backup retention hay account purge; các mục này phải khóa trước production/dữ liệu thật, không chặn local MVP.
- Bảy ADR chặn bootstrap đều `ACCEPTED`; version/build baseline đã pin; fake email và fake AI provider cho phép CI chạy offline.
- API Spec, Database, screen breakdown và ST-01..ST-05 cung cấp input/acceptance cho M2. M1 là technical foundation nên UC/FT không bắt buộc khi output kỹ thuật đã kiểm thử được.

## Kết luận và điều kiện bắt đầu

M1-01 có thể bắt đầu ngay. M2 chỉ bắt đầu sau cổng M1; bên trong M2 phải giữ thứ tự dependency nêu trên. Nếu thay đổi ADR, API hoặc schema trước khi triển khai, ticket bị ảnh hưởng phải review DoR lại.
