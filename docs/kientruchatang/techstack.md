# Tech Stack — VieGym

> Kế hoạch công nghệ cho VieGym Mobile App, Spring Boot Backend, AI Service, dữ liệu và hạ tầng triển khai MVP.
>
> Tài liệu này chỉ được tổng hợp từ [SRS](../spec/specs.md), [phân rã phân hệ](../spec/phan_ra_phan_he_he_thong.md), [luồng nghiệp vụ](../spec/bussiness_mainflow.md), [phân rã tính năng](../spec/phan_ra_tinh_nang.md) và [phân rã màn hình](../spec/phan_ra_man_hinh.md). `docs/design.md` không được dùng làm nguồn cho tài liệu này.

---

## 1. Mục tiêu và trạng thái quyết định

Tech stack phải hỗ trợ ba luồng cốt lõi của VieGym:

1. Theo dõi luyện tập, dinh dưỡng và sức khỏe trên ứng dụng di động.
2. Backend giữ vai trò business authority, source of truth và thực thi mọi mutation.
3. AI chỉ diễn giải, tư vấn và tạo proposal; người dùng quyết định, Backend kiểm tra rồi mới thực thi.

Quy ước trong tài liệu:

| Trạng thái | Ý nghĩa |
|---|---|
| **Đã chốt** | Được yêu cầu trực tiếp bởi SRS/thiết kế và là nền tảng của MVP |
| **Đề xuất** | Lựa chọn kỹ thuật để hiện thực hóa yêu cầu; cần khóa version khi tạo source code |
| **Tùy chọn** | Chỉ thêm khi có nhu cầu đo được; core business không được phụ thuộc |
| **P1/Future** | Không nằm trên đường găng hoàn thành MVP P0 |

> Các version dưới đây là **baseline tương thích đề xuất**, không phải bằng chứng rằng dependency đã được cài đặt. Khi khởi tạo dự án phải pin patch version trong lockfile/build file và xác nhận lại compatibility matrix bằng CI.

---

## 2. Tổng quan

```text
┌─────────────────────────────────────────────────────────────────────┐
│                         VIEGYM TECH STACK                            │
│                                                                     │
│  ┌─────────────────┐   HTTPS/REST   ┌────────────────────────────┐  │
│  │ Flutter Mobile  │ ─────────────► │ Spring Boot Backend        │  │
│  │ Dart            │                │ Java + Security + JPA      │  │
│  └─────────────────┘                └──────┬───────────┬─────────┘  │
│                                           │           │ internal    │
│                                    ┌──────▼──────┐    ▼             │
│                                    │ PostgreSQL  │ ┌──────────────┐ │
│                                    │ source of   │ │ FastAPI AI   │ │
│                                    │ truth       │ │ Python       │ │
│                                    └─────────────┘ └──────┬───────┘ │
│                                           │               ▼         │
│                                    ┌──────▼──────┐  OpenAI/Gemini   │
│                                    │ Object      │  provider adapter │
│                                    │ Storage     │                   │
│                                    └─────────────┘                    │
└─────────────────────────────────────────────────────────────────────┘

Tùy chọn hỗ trợ: Redis cho cache/rate limit.
Môi trường demo: Docker Compose.
```

### Stack được chọn

| Lớp | Công nghệ | Trạng thái | Vai trò |
|---|---|---|---|
| Mobile | Flutter + Dart | **Đã chốt** | Ứng dụng Android, gồm USER và Admin UI tối thiểu |
| State | Thư viện state management sẽ khóa khi bootstrap | **Đề xuất** | Quản lý application/client state |
| API chính | Java + Spring Boot | **Đã chốt** | REST API, business logic, authorization, validation và mutation |
| AI Service | Python + FastAPI | **Đã chốt** | Orchestration AI stateless, provider abstraction |
| Database | PostgreSQL | **Đã chốt** | Source of truth cho toàn bộ dữ liệu nghiệp vụ |
| Media | Object storage/CDN hoặc URL/asset demo hợp lệ | **Đã chốt về phương án** | Ảnh/video; PostgreSQL chỉ lưu metadata/object key |
| Cache | Redis | **Tùy chọn** | Cache và rate limit; không chứa business state duy nhất |
| Runtime demo | Docker Compose | **Đã chốt** | Khởi chạy Backend, Database, AI Service và dịch vụ hỗ trợ |

---

## 3. Mobile App — Flutter

### 3.1. Core framework

| Công nghệ | Baseline đề xuất | Mô tả |
|---|---:|---|
| **Flutter** | **3.44.4** | UI framework đa nền tảng; pin bằng `.fvmrc`, MVP ưu tiên Android |
| **Dart** | **3.12.2** | Đi cùng Flutter 3.44.4; không nâng độc lập |
| **Material 3** | Theo Flutter SDK | Design system và component nền |

> Không tạo React/Web Admin riêng trong MVP. Admin P0 dùng shell/route riêng trong Flutter cho Manage Exercise, Manage Food và Audit Log. Chỉ tách Web Admin ở P1 khi có yêu cầu vận hành thực tế.

### 3.2. State, routing và networking

| Thư viện | Trạng thái | Mục đích |
|---|---|---|
| **flutter_riverpod** | **Đã chốt/P0 — ADR-001** | State bất đồng bộ, dependency injection và test override; không dùng package state khác song song |
| **go_router** | **Đề xuất** | Declarative routing, auth redirect và route theo role |
| **Dio** | **Đề xuất** | HTTP client, timeout, interceptor, refresh token và error mapping |
| **Freezed** + **json_serializable** | **Đề xuất** | Immutable model, union state và JSON mapping sinh tự động |
| **OpenAPI Generator `dart-dio`** | **Đã chốt/P0** | Sinh API client/models từ contract Backend, không viết DTO trùng tay |

Các nguyên tắc bắt buộc:

- Mobile chỉ gọi Spring Boot qua `/api/v1`; không gọi FastAPI hoặc AI Provider trực tiếp.
- Backend guard là lớp bảo mật bắt buộc; route guard trên Flutter chỉ hỗ trợ UX.
- Không tự tính BMI/BMR/TDEE, nutrition summary, workout volume hoặc PR như kết quả authoritative.
- Mọi màn hình phải biểu diễn rõ loading, empty, error, offline và retry state.
- Pin exact OpenAPI Generator version. CI chạy regenerate và fail nếu generated
  client khác source đã commit.

### 3.3. Local storage và thiết bị

| Thư viện | Trạng thái | Mục đích |
|---|---|---|
| **flutter_secure_storage** | **Đã chốt/P0 — ADR-004** | Chỉ lưu refresh token opaque; access token giữ trong bộ nhớ |
| **local_auth** | **Đề xuất/P0** | Biometric chỉ mở credential local; không gửi biometric lên server |
| **shared_preferences** | **Đề xuất** | Preference không nhạy cảm như theme/onboarding flag |
| **image_picker** / **file_picker** | **Đề xuất** | Chọn avatar/media theo contract PH9 |
| **cached_network_image** | **Đề xuất** | Cache ảnh Exercise/Food/avatar trên client |

Không lưu password, AI API key hoặc token trong `shared_preferences`.

### 3.4. Cấu trúc source đề xuất

```text
mobile/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── config/              ← environment, feature flag
│   │   ├── network/             ← Dio client, interceptor, API error
│   │   ├── storage/             ← secure/local storage
│   │   ├── theme/
│   │   └── widgets/
│   ├── features/
│   │   ├── auth/
│   │   ├── profile/
│   │   ├── health/
│   │   ├── workout/
│   │   ├── nutrition/
│   │   ├── dashboard/
│   │   ├── ai_coach/
│   │   ├── media/
│   │   ├── notification/
│   │   └── admin/
│   └── router/
├── test/
├── integration_test/
└── pubspec.yaml
```

Mỗi feature có thể tách `data/`, `domain/`, `presentation/` khi độ phức tạp yêu cầu; không bắt buộc tạo tầng rỗng chỉ để đúng mẫu.

---

## 4. Backend API — Spring Boot

### 4.1. Core framework

| Công nghệ | Baseline đề xuất | Mô tả |
|---|---:|---|
| **Java** | **21 LTS** | Dùng cùng major ở local, CI và container |
| **Spring Boot** | **3.5.16** | Framework API chính; pin parent/BOM exact |
| **Spring Web MVC** | Theo Spring Boot BOM | REST API `/api/v1` |
| **Spring Validation** | Theo Spring Boot BOM | Validate request DTO |
| **Spring Data JPA** | Theo Spring Boot BOM | Data access và transaction |
| **PostgreSQL JDBC Driver** | Theo Spring Boot BOM | Kết nối PostgreSQL |
| **Flyway** | Version tương thích Spring Boot | Version hóa schema và seed reference data |

Chỉ sử dụng một build tool. **Maven** được đề xuất cho MVP (`pom.xml` + Maven Wrapper); không duy trì đồng thời Maven và Gradle.

### 4.2. Security và Identity

| Công nghệ | Trạng thái | Mục đích |
|---|---|---|
| **Spring Security** | **Đề xuất/P0** | Authentication, role và endpoint policy |
| **OAuth2 Resource Server + JOSE JWT** | **Đề xuất/P0** | Validate access token theo chuẩn, tránh custom auth filter không cần thiết |
| **BCrypt** | **Đã chốt/P0** | Hash local password |
| **Google Identity token verification** | **Đã chốt/P0** | Google Login được verify server-side |
| **Refresh token rotation/revocation** | **Đã chốt/P0** | Quản lý phiên đăng nhập và logout |
| **OTP hash + TTL + attempt/rate limit** | **Đã chốt/P0** | Register/password reset an toàn |

Authorization phải kiểm tra cả role và ownership ở Backend. Audit log không chứa password, token, OTP, API key hoặc raw AI context dư thừa.

### 4.3. Mapping, API docs và utilities

| Thư viện | Trạng thái | Mục đích |
|---|---|---|
| **MapStruct** | **Đề xuất** | Mapping Entity ↔ DTO ở compile time |
| **Lombok** | **Tùy chọn** | Giảm boilerplate; không dùng `@Data` bừa bãi trên JPA entity |
| **springdoc-openapi** | **Đã chốt về đầu ra** | Sinh OpenAPI và Swagger UI cho demo |
| **Micrometer + Actuator** | **Đề xuất** | Health/readiness và metric nền |
| **Resilience4j** | **Đề xuất** | Timeout/retry/circuit breaker giới hạn khi gọi AI Service |

Response envelope, pagination và error code phải được chốt trong `API_SPEC.md`; không tự suy ra contract từ tài liệu ngoài `docs/spec/`.

### 4.4. Media/Object Storage

| Công nghệ | Trạng thái | Mục đích |
|---|---|---|
| **S3-compatible SDK/presigner** | **Đề xuất** | Kết nối object storage được chọn cho local/production |
| **Apache Tika** | **Đề xuất** | Kiểm tra MIME thực tế của file upload |
| **Presigned URL có TTL** | **Đề xuất/P0** | Upload/access media không chuyển toàn bộ byte qua Backend |

Backend phải xác thực quyền trước khi cấp URL, kiểm tra object/metadata ở bước `upload-complete`, giới hạn MIME/extension/size và xử lý orphan. Không lưu binary nghiệp vụ trong PostgreSQL.

### 4.5. Cấu trúc source đề xuất

```text
backend/
├── src/main/java/com/viegym/
│   ├── ViegymApplication.java
│   ├── identity/                ← Auth, JWT, OTP, Google Login
│   ├── preference/
│   ├── health/
│   ├── workout/
│   │   ├── exercise/
│   │   ├── program/
│   │   ├── schedule/
│   │   ├── session/
│   │   └── log/
│   ├── nutrition/
│   ├── dashboard/
│   ├── ai/
│   │   ├── consent/
│   │   ├── context/
│   │   ├── rule/
│   │   ├── conversation/
│   │   ├── recommendation/
│   │   └── validation/
│   ├── admin/
│   ├── audit/
│   ├── media/
│   ├── notification/
│   └── common/
│       ├── config/
│       ├── dto/
│       ├── exception/
│       └── security/
├── src/main/resources/
│   ├── db/migration/
│   ├── application.yml
│   ├── application-local.yml
│   └── application-prod.yml
├── src/test/
├── pom.xml
└── Dockerfile
```

Ưu tiên modular monolith cho Spring Boot trong MVP. Không tách mỗi domain thành microservice khi chưa có nhu cầu scale hoặc ownership độc lập.

---

## 5. AI Service — FastAPI

### 5.1. Core framework

| Công nghệ | Baseline đề xuất | Mô tả |
|---|---:|---|
| **Python** | **3.12 minor** | Runtime AI Service; image patch pin digest ở M1 |
| **FastAPI** | **0.141.1** | Internal HTTP API chỉ Spring Boot được gọi; pin trong `uv.lock` |
| **Pydantic v2** | Theo FastAPI compatibility | Validate input/output schema |
| **HTTPX** | Version stable pin | Async HTTP client cho AI Provider |
| **Uvicorn** | Version stable pin | ASGI server |
| **OpenAI Python SDK** | **Đã chốt/P0 — ADR-002** | Responses API, Structured Outputs; model mặc định `gpt-5.6-luna` qua config |

> MVP dùng **OpenAI** làm provider mặc định qua biến môi trường. Gemini chỉ là khả năng mở rộng adapter sau P0; không triển khai multi-provider/fallback routing trong MVP.

### 5.2. Trust boundary và contract

```text
Flutter
   │ JWT + user request
   ▼
Spring Boot
   │ authorization → consent → context whitelist → rule/prompt
   ▼
FastAPI AI Service
   │ provider adapter → output parsing/schema validation
   ▼
Spring Boot
   │ business + safety validation → proposal
   ▼
User Apply/Dismiss → Backend thực thi hoặc không thực thi
```

Các ràng buộc bắt buộc:

- FastAPI stateless và không kết nối trực tiếp PostgreSQL.
- Chỉ nhận context tối thiểu đã được Backend authorize và consent-check.
- Không nhận password, token, API key hoặc lịch sử thô không cần thiết.
- Output là câu trả lời hoặc proposal có schema, không phải lệnh mutation.
- Timeout/retry phải hữu hạn; khi provider lỗi, trả fallback an toàn.
- Secret của provider chỉ nằm server-side qua environment/secret manager.
- Spring Boot sở hữu rule/prompt version và render prompt; FastAPI chỉ thực thi
  request đã render qua provider adapter rồi parse structured output.

### 5.3. Cấu trúc source đề xuất

```text
ai-service/
├── app/
│   ├── main.py
│   ├── api/                     ← Internal endpoint
│   ├── schemas/                 ← Input/output contract
│   ├── providers/               ← OpenAI/Gemini adapter
│   ├── prompts/                 ← Provider formatting; business prompt do Backend render
│   ├── validators/              ← Output/safety helpers
│   └── core/                    ← Config, timeout, retry, logging
├── tests/
├── pyproject.toml
├── lockfile                     ← uv.lock hoặc poetry.lock, chọn một
└── Dockerfile
```

---

## 6. Data, cache và storage

### 6.1. PostgreSQL

| Công nghệ | Baseline đề xuất | Vai trò |
|---|---:|---|
| **PostgreSQL** | **16.14; major 16 thống nhất Docker/CI/prod** | Source of truth, transaction và relational integrity |
| **Flyway** | Theo Backend | Schema migration, index, constraint và seed có kiểm soát |

Lý do chọn PostgreSQL:

- Dữ liệu VieGym có quan hệ chặt giữa User, Health, Workout, Meal và Recommendation.
- Cần transaction cho các luồng như finish workout, tạo health profile + target và Apply recommendation.
- Hỗ trợ constraint, index, JSONB khi thực sự cần metadata linh hoạt và aggregate dashboard.
- Phù hợp modular monolith và quy mô MVP, không cần thêm NoSQL database.

Nguyên tắc dữ liệu:

- Dùng migration; không để ORM tự cập nhật schema ở production.
- Private entity luôn gắn `user_id`/ownership rõ ràng.
- Meal entry, order-like record hoặc log cần snapshot dữ liệu có thể thay đổi về sau.
- Exercise/Food bị ẩn dùng soft delete/visibility để giữ lịch sử.
- Media chỉ lưu metadata và object key, không lưu binary.

Chi tiết bảng và index sẽ được quản lý tại [DATABASE.md](./DATABASE.md).

### 6.2. Redis — tùy chọn

| Công nghệ | Baseline đề xuất | Vai trò |
|---|---:|---|
| **Redis** | 7+ | Rate limit, cache reference data/dashboard ngắn hạn |

Redis không phải dependency bắt buộc của core MVP. Nếu chưa chứng minh được bottleneck, rate limit OTP/login có thể bắt đầu bằng PostgreSQL; chỉ thêm Redis khi cần scale hoặc TTL/counter hiệu quả hơn. Cache mất không được làm mất business data.

### 6.3. Object storage

| Môi trường | Công nghệ | Vai trò |
|---|---|---|
| Local/demo | **MinIO — ADR-003** | Bucket private, presigned PUT/GET và integration test |
| Production | **Amazon S3 — ADR-003** | Durable private storage; CDN chưa thuộc P0 |
| Fallback demo | URL/asset hợp lệ | Được SRS cho phép nếu upload chưa hoàn thiện |

Streaming/transcoding video nâng cao nằm ngoài MVP.

---

## 7. Testing và chất lượng

### 7.1. Mobile

| Công cụ | Loại test |
|---|---|
| `flutter_test` | Widget và unit test |
| `mocktail` | Mock dependency/API |
| `integration_test` | Auth, onboarding, workout, meal và AI happy path |
| Golden test — tùy chọn | Màn hình/component ổn định về giao diện |

### 7.2. Backend

| Công cụ | Loại test |
|---|---|
| JUnit 5 | Unit test |
| Mockito | Mocking |
| Spring Boot Test + MockMvc | API/integration test |
| Testcontainers PostgreSQL/object storage | Test transaction, constraint, migration và storage sát runtime |
| REST Assured — tùy chọn | End-to-end API contract |

Không dùng H2 để thay thế các integration test phụ thuộc hành vi PostgreSQL.

### 7.3. AI Service

| Công cụ | Loại test |
|---|---|
| pytest | Unit/integration test |
| pytest-asyncio | Async provider/client test |
| respx hoặc mock transport | Mock AI Provider, kiểm thử timeout/retry |
| JSON Schema/Pydantic fixtures | Contract và safety output test |

Không gọi provider thật trong unit test/CI mặc định. Provider smoke test phải tách riêng, dùng quota giới hạn và secret của môi trường.

### 7.4. Các test P0 bắt buộc

- Công thức BMI, BMR, TDEE, calories/macro và boundary validation.
- Ownership và role `USER`/`ADMIN` trên private/admin API.
- OTP TTL/attempt, refresh token revoke/rotation và Google token verification boundary.
- Workout session state machine, volume/completion/PR.
- Meal nutrition snapshot và daily aggregation.
- AI consent OFF, context whitelist, schema validation và no-auto-mutation.
- Recommendation `PENDING → APPLIED/DISMISSED/EXPIRED` và idempotency khi Apply.
- Upload MIME/size/access policy và orphan handling.

---

## 8. DevOps và vận hành

### 8.1. Local/demo environment

```text
docker-compose.yml
├── backend                  Spring Boot API
├── ai-service               FastAPI internal service
├── postgres                 business database
├── object-storage           tùy chọn theo phương án media được chốt
└── redis                    optional profile

Flutter App chạy trên emulator/device và gọi endpoint Backend được cấu hình.
```

### 8.2. Build và CI/CD

| Công cụ | Trạng thái | Mục đích |
|---|---|---|
| **Git** | **Đã chốt thực tế repo** | Version control |
| **Docker + Docker Compose** | **Đã chốt cho demo** | Reproducible runtime |
| **GitHub Actions** | **Đề xuất** | Lint, test, build image và kiểm tra migration |
| **Maven Wrapper** | **Đã chốt/M0-12** | Build Backend duy nhất và nhất quán; không dùng Gradle |
| **Flutter SDK pinning/FVM** | **Đề xuất** | Đồng nhất Flutter version |
| **uv + `uv.lock`** | **Đã chốt/M0-12** | Python dependency manager duy nhất; `uv.lock` bắt buộc commit |

Pipeline tối thiểu:

```text
Lint/format
   ↓
Unit test Mobile + Backend + AI Service
   ↓
OpenAPI generate `dart-dio` + no-diff contract check
   ↓
Integration test với PostgreSQL/object-storage container nếu sử dụng
   ↓
Build Flutter APK + Backend/AI Docker images
   ↓
Smoke test Docker Compose + OpenAPI endpoint
```

### 8.3. Observability và cấu hình

- Log JSON có correlation/request ID xuyên Backend → AI Service.
- Không log token, OTP, password, provider key hoặc raw health/AI context không cần thiết.
- Spring Actuator cung cấp liveness/readiness; FastAPI có `/health` nội bộ.
- Cấu hình qua environment; repository chỉ giữ `.env.example`, không commit secret.
- Theo dõi latency/error riêng cho AI Provider vì NFR P95 API thường không tính thời gian provider.

---

## 9. Compatibility matrix đề xuất

| Component | Baseline | Quy tắc khóa version |
|---|---:|---|
| Flutter | 3.44.4 | Pin bằng `.fvmrc` và CI image |
| Dart | 3.12.2 | Đi cùng Flutter 3.44.4 |
| Java | 21 LTS | Cùng toolchain ở Maven, CI và Docker |
| Spring Boot | 3.5.16 | Dùng Spring Boot BOM, pin exact |
| Python | 3.12 minor | `.python-version`; Docker patch pin digest ở M1 |
| FastAPI | 0.141.1 | Pin direct dependency và toàn bộ graph trong `uv.lock` |
| PostgreSQL | 16.14 | Cùng major 16 ở local, Testcontainers và production |
| Redis | 7+ | Chỉ bật nếu triển khai cache/rate limit |
| Object storage/S3 client | Release tương thích API đã chọn | Pin container tag và SDK BOM |

Không dùng tag `latest` trong CI hoặc môi trường demo dùng để chấm/đánh giá.

---

## 10. Quyết định phạm vi MVP

### Bắt buộc P0

- Flutter Android app với USER flow và Admin shell tối thiểu.
- Spring Boot REST API `/api/v1`, JWT, ownership và role.
- PostgreSQL + Flyway là source of truth.
- FastAPI AI Service stateless và consent-aware.
- Exercise/Food media baseline bằng object storage hoặc URL/asset demo hợp lệ.
- Swagger/OpenAPI, seed data ổn định và Docker Compose chạy được end-to-end.

### Có thể trì hoãn

- Redis nếu chưa có bottleneck/rate-limit scale thực tế.
- Push notification/FCM nâng cao.
- Web Admin riêng.
- Message broker, Kubernetes, service mesh và microservices.
- Video transcoding/streaming, semantic/vector database và analytics warehouse.
- Multi-provider AI routing phức tạp.

### Tiêu chí hoàn tất tech stack

- Mỗi dependency có owner/use case rõ ràng, version được pin và license phù hợp.
- Local setup chạy bằng tài liệu và Docker Compose có thể lặp lại.
- Mobile không biết AI provider secret và không bypass Backend.
- AI Service không có database credential.
- Migration chạy tự động trong test và có chiến lược rollback/backup cho môi trường triển khai.
- CI kiểm tra format, test, build và smoke test trước khi merge.

---

## 11. Thứ tự triển khai đề xuất

1. **Khóa nền tảng:** pin Flutter, Java, Spring Boot, Python và PostgreSQL; tạo lockfile/wrapper.
2. **Dựng local stack:** PostgreSQL, Backend, AI Service và phương án media đã chọn bằng Docker Compose.
3. **Hoàn thiện vertical slice Auth → Health:** JWT/OTP, secure storage, Health Profile và calculation test.
4. **Hoàn thiện Workout + Nutrition:** schema, API, Flutter feature và integration test.
5. **Tích hợp AI an toàn:** consent, context whitelist, provider adapter, schema/safety validation và Apply/Dismiss.
6. **Bổ sung Admin/Media:** Exercise, Food, Audit và presigned media flow.
7. **Hardening demo:** OpenAPI, seed, observability, CI, APK/image build và smoke test end-to-end.

Thứ tự này ưu tiên các vertical slice có thể demo và kiểm thử, đồng thời giữ AI/Redis/media nâng cao không cản trở business core.
