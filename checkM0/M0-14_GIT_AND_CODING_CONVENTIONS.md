# M0-14 — Git workflow và coding conventions

> Trạng thái: ACCEPTED · Ngày áp dụng: 2026-08-19 · Phù hợp đồ án một người

## Git workflow

- `main` luôn build được và là nhánh tích hợp duy nhất. Không dùng Git Flow/develop branch.
- Mỗi task tạo nhánh ngắn từ `main`: `feat/m2-03-local-register`, `fix/m4-12-session-state`, `docs/m0-14-git-convention`, `chore/m1-21-ci`.
- Một nhánh giải quyết một task/story; rebase/update từ `main` trước khi merge. Xóa nhánh sau merge.
- Với đồ án một người, PR là khuyến nghị cho thay đổi code lớn và bắt buộc trước release milestone; thay đổi docs nhỏ có thể commit trực tiếp nếu đã tự review diff và test liên quan.

## Commit và PR

Commit dùng Conventional Commits: `type(scope): mô tả mệnh lệnh ngắn`.

- Type: `feat`, `fix`, `test`, `docs`, `refactor`, `chore`, `build`, `ci`, `perf`, `revert`.
- Scope: `mobile`, `backend`, `ai`, `db`, `infra`, `docs` hoặc domain (`auth`, `workout`, `meal`).
- Footer liên kết task khi có: `Refs: M2-03`, `Refs: ST-01`; breaking contract dùng `BREAKING CHANGE:`.
- Không trộn format toàn repo, dependency upgrade và feature vào cùng commit. Không commit secret, `.env`, build output, IDE state hoặc `.DS_Store`.

PR/milestone review phải có: mục tiêu, phạm vi ngoài thay đổi, task/AC liên quan, migration/API impact, test đã chạy, ảnh/video cho UI và rollback nếu có. Merge bằng squash khi nhánh có commit sửa vụn; giữ merge history đơn giản.

## Convention chung

- UTF-8, LF, newline cuối file, 2 spaces cho YAML/JSON, 4 spaces cho Java/Python theo formatter; `.editorconfig` là authoritative.
- Tên code/identifier bằng tiếng Anh; tài liệu và UI có thể dùng tiếng Việt. Thời gian lưu UTC; API ISO-8601; boundary ngày dùng timezone IANA.
- Không log password, token, OTP, secret, presigned URL còn hiệu lực hoặc raw personal/AI context.
- Business rule ở Backend; Mobile không tự tính authoritative; AI không mutation. Không bypass module owner repository.
- Mọi API/schema change cập nhật API Spec/Database/migration/test và traceability trong cùng change.

## Flutter/Dart

- Tuân `dart format` và `flutter analyze`; lint từ `flutter_lints` plus rule dự án.
- File `snake_case.dart`, class/type `UpperCamelCase`, variable/function `lowerCamelCase`.
- Feature-first; widget không gọi Dio trực tiếp. Riverpod provider gọi use-case/repository; async state phải có loading/error/retry.
- Model immutable; JSON mapping thống nhất. Không dùng `dynamic` để né contract trừ adapter boundary có validation.

## Java/Spring

- Package lowercase theo capability `com.viegym.<module>`; class `UpperCamelCase`, method/field `lowerCamelCase`.
- Controller chỉ map/validate/authorize input; application service giữ use case/transaction; repository thuộc module owner.
- DTO không expose JPA entity. Validation lỗi dùng error envelope canonical. Constructor injection; không field injection.
- Format/lint bằng Spotless (Google Java Format) và test bằng Maven `verify`. Migration Flyway append-only sau khi đã merge/release.

## Python/FastAPI

- Python 3.12 typing bắt buộc cho public function; Pydantic model ở boundary; provider output luôn validate.
- File/module/function `snake_case`, class `UpperCamelCase`, constant `UPPER_SNAKE_CASE`.
- Ruff chịu trách nhiệm format + lint; pytest cho test. FastAPI route không chứa provider-specific business logic.
- Cấu hình qua environment/Pydantic Settings; không đọc secret trong module import và không log payload nhạy cảm.

## Quality gate trước merge

1. Diff không có secret/generated junk/unrelated change.
2. Format, lint, unit test của component liên quan xanh.
3. API/schema/migration và docs đồng bộ; backward compatibility được nêu.
4. Acceptance criteria và failure path chính có test.
5. Checklist task trong `Project_Progress.md` chỉ đổi `[x]` sau khi có minh chứng.

