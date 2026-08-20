# M0-11/12 — Version và build-tool baseline

> Ngày khóa: 2026-08-19 · Trạng thái: ACCEPTED · Áp dụng cho local, CI, Docker và demo

## Runtime/framework được pin

| Thành phần | Phiên bản khóa | Cách thực thi |
|---|---:|---|
| Flutter | `3.44.4` | Pin bằng `.fvmrc`; CI dùng đúng release, không dùng channel trôi |
| Dart | `3.12.2` | Đi cùng Flutter 3.44.4; không nâng độc lập |
| Java | `21` LTS | Maven toolchain/compiler `release=21`; CI và container cùng major |
| Spring Boot | `3.5.16` | Parent/BOM pin exact trong `pom.xml` |
| Python | `3.12` minor | `.python-version` và Docker `python:3.12-slim`; patch được khóa bởi image digest ở M1 |
| FastAPI | `0.141.1` | Direct dependency exact trong `pyproject.toml` và `uv.lock` |
| PostgreSQL | `16.14` | Docker/Testcontainers/demo cùng `16.14`; production cùng major 16 |

Chọn Spring Boot 3.5.x thay vì 4.x để giữ đúng baseline thiết kế hiện tại và giảm migration risk cho đồ án; vẫn là nhánh stable được Spring công bố. Chọn PostgreSQL 16 thay vì major mới nhất để ưu tiên độ trưởng thành và giữ tương thích với schema hiện có; 16 vẫn còn được hỗ trợ. Flutter dùng bản stable đã công bố cùng Dart tương ứng.

Nguồn kiểm chứng ngày khóa: [Flutter SDK archive](https://docs.flutter.dev/install/archive), [Spring Boot stable versions](https://docs.spring.io/spring-boot/spring-projects.html), [FastAPI release notes](https://fastapi.tiangolo.com/release-notes/), [PostgreSQL versioning policy](https://www.postgresql.org/support/versioning/).

## Build và dependency management

- Backend dùng **Maven** duy nhất, có Maven Wrapper (`mvnw`, `mvnw.cmd`, `.mvn/wrapper/`). `pom.xml` là manifest; `dependencyManagement` của Spring Boot là baseline. CI chạy `./mvnw`, không phụ thuộc Maven cài sẵn và không tạo Gradle files.
- AI Service dùng **uv** duy nhất. `pyproject.toml` là manifest và `uv.lock` là lockfile bắt buộc phải commit. Local/CI/container cài bằng `uv sync --frozen`; không duy trì `requirements.txt`, Poetry lock hoặc Pipenv song song.
- Flutter commit `pubspec.yaml` và `pubspec.lock` cho application. CI chạy resolve ở chế độ không tự nâng dependency.
- Container image demo phải pin tag exact; trước release M1 sẽ pin digest. Cấm tag `latest`.

## Quy tắc nâng phiên bản

1. Dependency update đi trong PR riêng hoặc commit riêng, kèm changelog/risk và test.
2. Patch update được phép khi CI xanh; minor/major update phải cập nhật baseline/ADR nếu ảnh hưởng contract.
3. Không sửa lockfile thủ công. Regenerate bằng đúng package manager rồi review diff.
4. Local, CI, Testcontainers và Docker Compose không được lệch major runtime/database.

## Tiêu chí kiểm chứng tại M1

- `flutter --version`, `java -version`, `./mvnw --version`, `python --version`, `uv --version` được in trong CI.
- `flutter pub get`, `./mvnw verify` và `uv sync --frozen` chạy được từ clean checkout.
- PostgreSQL integration test báo major 16; Flyway chạy trên database rỗng.

