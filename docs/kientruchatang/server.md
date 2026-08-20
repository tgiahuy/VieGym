# Server & Deployment — VieGym

> Cấu hình server, topology triển khai và baseline vận hành cho VieGym.
>
> Tài liệu này mô tả target architecture. Các image/dependency phải được pin patch hoặc digest khi bootstrap source code; ví dụ cấu hình không thay thế secret manager hay quy trình production review.

---

## 1. Mục tiêu và nguyên tắc triển khai

Server VieGym phải giữ đúng các boundary đã chốt:

1. Flutter chỉ gọi Spring Boot qua REST API `/api/v1`.
2. Spring Boot là business authority: authentication, authorization, calculation, validation và domain mutation.
3. PostgreSQL là source of truth duy nhất cho business state.
4. FastAPI AI Service là stateless internal service, không có database credential và không được Mobile gọi trực tiếp.
5. Object storage giữ binary media; PostgreSQL chỉ giữ metadata/object key.
6. Redis là tùy chọn; core business phải hoạt động khi không có Redis.
7. AI chỉ trả nội dung/proposal. User quyết định và Spring Boot validate trước khi thực thi.

Các thành phần không thuộc P0: RabbitMQ/message broker, Kubernetes, service mesh, microservice theo domain, video transcoding, analytics warehouse và multi-provider routing phức tạp.

---

## 2. Server Architecture

### 2.1. Local và Demo — Docker Compose

```text
Flutter App (emulator/device)
        │
        │ HTTP/REST :8080/api/v1
        ▼
┌────────────────────────────────────────────────────────────┐
│ Docker Compose                                             │
│                                                            │
│  Spring Boot Backend :8080                                 │
│    ├── JDBC ───────────────► PostgreSQL :5432              │
│    ├── internal HTTP ──────► FastAPI AI Service :8000      │
│    │                           └── HTTPS ► AI Provider      │
│    ├── S3 API ─────────────► Object Storage :9000          │
│    └── optional ───────────► Redis :6379                   │
│                                                            │
│  Browser/device ── presigned PUT/GET ──► Object Storage    │
└────────────────────────────────────────────────────────────┘
```

- Chỉ Backend và endpoint object storage cần cho direct upload/download được expose ra host trong local/demo.
- PostgreSQL, Redis và FastAPI chỉ ở internal network.
- Object storage console chỉ expose trong profile phục vụ development, không phải runtime demo bắt buộc.
- Flutter Android emulator thường gọi host bằng `10.0.2.2`; iOS simulator có thể dùng `localhost`; thiết bị vật lý dùng IP LAN hoặc tunnel HTTPS phù hợp.
- Nếu media upload chưa hoàn thiện, demo được dùng URL/asset hợp lệ theo SRS nhưng metadata/API vẫn phải giữ boundary PH9.

### 2.2. Production ban đầu

```text
Flutter Mobile
    │ HTTPS
    ▼
DNS / WAF / Load Balancer / API Gateway
    │
    ▼
Spring Boot Backend xN
    ├── TLS ──► PostgreSQL managed/HA
    ├── HTTPS ► S3-compatible Object Storage ──► CDN (public media hợp lệ)
    ├── HTTP(S) internal ──► FastAPI AI Service xN ──HTTPS──► AI Provider
    └── TLS ──► Redis optional

Observability ── logs / metrics / alerts
Backup system ── database backups + object versioning/lifecycle
```

- Load balancer là public ingress duy nhất; Backend, AI Service, database và Redis nằm trong private network.
- Backend và AI Service có thể scale ngang vì session/business state đã externalize vào PostgreSQL; AI Service hoàn toàn stateless.
- Không public expose Swagger UI, Actuator chi tiết, FastAPI docs, database, Redis hoặc object storage admin console.
- Database pool, AI provider quota/cost và object-storage bandwidth phải được đo trước khi tăng instance.

### 2.3. Ranh giới mạng

| Nguồn | Đích | Cho phép | Ghi chú |
|---|---|---:|---|
| Mobile | Load balancer/Backend | Có | HTTPS `/api/v1/**` |
| Mobile | Object storage | Có điều kiện | Chỉ presigned URL TTL ngắn |
| Mobile | FastAPI | Không | Không có public route |
| Backend | PostgreSQL | Có | TLS ở production, least-privilege credential |
| Backend | FastAPI | Có | Internal auth + correlation ID |
| Backend | Object storage | Có | Sign URL, HEAD/verify/delete object |
| Backend | Redis | Tùy chọn | Cache/rate limit, không giữ state duy nhất |
| FastAPI | PostgreSQL/Object storage | Không | Không cấp credential |
| FastAPI | AI Provider | Có | HTTPS egress allowlist khi khả thi |

---

## 3. Docker Compose Baseline

Ví dụ dưới đây là blueprint cho local/demo. Image do project build và third-party image phải được pin version/digest trong file Compose thực tế; không dùng tag `latest`.

```yaml
name: viegym

services:
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    ports:
      - "8080:8080"
    depends_on:
      postgres:
        condition: service_healthy
      ai-service:
        condition: service_healthy
      minio:
        condition: service_healthy
    environment:
      SPRING_PROFILES_ACTIVE: local
      SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/viegym
      SPRING_DATASOURCE_USERNAME: ${POSTGRES_USER:-viegym_app}
      SPRING_DATASOURCE_PASSWORD: ${POSTGRES_PASSWORD:?set POSTGRES_PASSWORD}
      JWT_SIGNING_KEY: ${JWT_SIGNING_KEY:?set JWT_SIGNING_KEY}
      JWT_ACCESS_TTL: ${JWT_ACCESS_TTL:-PT15M}
      JWT_REFRESH_TTL: ${JWT_REFRESH_TTL:-P7D}
      AI_SERVICE_BASE_URL: http://ai-service:8000
      AI_SERVICE_TOKEN: ${AI_SERVICE_TOKEN:?set AI_SERVICE_TOKEN}
      STORAGE_ENDPOINT: http://minio:9000
      STORAGE_PUBLIC_ENDPOINT: ${STORAGE_PUBLIC_ENDPOINT:-http://localhost:9000}
      STORAGE_BUCKET: ${STORAGE_BUCKET:-viegym-media}
      STORAGE_ACCESS_KEY: ${MINIO_ROOT_USER:?set MINIO_ROOT_USER}
      STORAGE_SECRET_KEY: ${MINIO_ROOT_PASSWORD:?set MINIO_ROOT_PASSWORD}
      STORAGE_REGION: ${STORAGE_REGION:-us-east-1}
      STORAGE_PATH_STYLE_ACCESS: "true"
      STORAGE_UPLOAD_TTL: ${STORAGE_UPLOAD_TTL:-PT5M}
      STORAGE_ACCESS_TTL: ${STORAGE_ACCESS_TTL:-PT5M}
      CORS_ALLOWED_ORIGINS: ${CORS_ALLOWED_ORIGINS:-}
      APP_DEFAULT_TIMEZONE: Asia/Ho_Chi_Minh
    networks:
      - app-net
    healthcheck:
      test: ["CMD", "curl", "-fsS", "http://localhost:8080/actuator/health/liveness"]
      interval: 15s
      timeout: 5s
      retries: 10
      start_period: 45s
    restart: unless-stopped

  ai-service:
    build:
      context: ./ai-service
      dockerfile: Dockerfile
    expose:
      - "8000"
    environment:
      APP_ENV: local
      INTERNAL_SERVICE_TOKEN: ${AI_SERVICE_TOKEN:?set AI_SERVICE_TOKEN}
      AI_PROVIDER: ${AI_PROVIDER:?set AI_PROVIDER}
      AI_MODEL: ${AI_MODEL:?set AI_MODEL}
      AI_PROVIDER_API_KEY: ${AI_PROVIDER_API_KEY:?set AI_PROVIDER_API_KEY}
      AI_CONNECT_TIMEOUT_SECONDS: ${AI_CONNECT_TIMEOUT_SECONDS:-3}
      AI_READ_TIMEOUT_SECONDS: ${AI_READ_TIMEOUT_SECONDS:-20}
      AI_MAX_ATTEMPTS: ${AI_MAX_ATTEMPTS:-2}
      LOG_LEVEL: ${AI_LOG_LEVEL:-INFO}
    networks:
      - app-net
    healthcheck:
      test: ["CMD", "python", "-c", "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')"]
      interval: 15s
      timeout: 5s
      retries: 10
      start_period: 20s
    restart: unless-stopped

  postgres:
    image: ${POSTGRES_IMAGE:-postgres:16-alpine}
    expose:
      - "5432"
    environment:
      POSTGRES_DB: ${POSTGRES_DB:-viegym}
      POSTGRES_USER: ${POSTGRES_USER:-viegym_app}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:?set POSTGRES_PASSWORD}
      TZ: UTC
    volumes:
      - postgres-data:/var/lib/postgresql/data
    networks:
      - app-net
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U $${POSTGRES_USER} -d $${POSTGRES_DB}"]
      interval: 10s
      timeout: 5s
      retries: 10
    restart: unless-stopped

  minio:
    image: ${MINIO_IMAGE:?pin a MinIO release image}
    command: server /data --console-address ":9001"
    ports:
      - "9000:9000"
    expose:
      - "9001"
    environment:
      MINIO_ROOT_USER: ${MINIO_ROOT_USER:?set MINIO_ROOT_USER}
      MINIO_ROOT_PASSWORD: ${MINIO_ROOT_PASSWORD:?set MINIO_ROOT_PASSWORD}
    volumes:
      - minio-data:/data
    networks:
      - app-net
    healthcheck:
      test: ["CMD", "curl", "-fsS", "http://localhost:9000/minio/health/live"]
      interval: 15s
      timeout: 5s
      retries: 10
    restart: unless-stopped

  redis:
    image: ${REDIS_IMAGE:-redis:7-alpine}
    profiles: ["cache"]
    expose:
      - "6379"
    command: ["redis-server", "--appendonly", "no"]
    networks:
      - app-net
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 10
    restart: unless-stopped

volumes:
  postgres-data:
  minio-data:

networks:
  app-net:
    driver: bridge
```

### 3.1. Chạy theo profile

```bash
# Core P0
docker compose up --build

# Bật Redis khi đã chọn dùng cache/rate limit
docker compose --profile cache up --build
```

Không đưa giá trị secret thật vào Compose. File `.env.example` chỉ liệt kê key/giá trị giả; `.env` phải bị ignore.

### 3.2. Presigned URL trong local

Backend dùng hai endpoint storage khác nhau:

- `STORAGE_ENDPOINT=http://minio:9000`: endpoint nội bộ để SDK gọi HEAD/DELETE và kiểm tra object.
- `STORAGE_PUBLIC_ENDPOINT`: host mà Flutter/emulator/device truy cập được và được dùng khi ký URL.

Ví dụ:

| Client | `STORAGE_PUBLIC_ENDPOINT` thường dùng |
|---|---|
| Flutter desktop/iOS simulator cùng máy | `http://localhost:9000` |
| Android emulator mặc định | `http://10.0.2.2:9000` |
| Thiết bị vật lý cùng LAN | `http://<IP-LAN-máy-dev>:9000` |

Host trong presigned URL là một phần chữ ký; không ký bằng `minio:9000` rồi thay hostname ở client.

Bucket `viegym-media` phải được một bootstrap job/script idempotent tạo trước khi Backend nhận traffic và luôn giữ private policy. Backend runtime không nên có quyền thay đổi bucket policy; production provisioning thuộc IaC/platform, không thuộc application startup.

---

## 4. Environment Configuration

### 4.1. Ma trận biến môi trường

| Biến | Service | Bắt buộc | Mô tả |
|---|---|:---:|---|
| `SPRING_PROFILES_ACTIVE` | Backend | Có | `local`, `test`, `prod` |
| `SPRING_DATASOURCE_URL` | Backend | Có | JDBC PostgreSQL URL |
| `SPRING_DATASOURCE_USERNAME/PASSWORD` | Backend | Có | App DB credential |
| `JWT_SIGNING_KEY` hoặc key pair | Backend | Có | Ký/verify access token; production ưu tiên key rotation được quản lý |
| `JWT_ACCESS_TTL` | Backend | Có | Mặc định contract `PT15M` |
| `JWT_REFRESH_TTL` | Backend | Có | Mặc định contract `P7D` |
| `GOOGLE_CLIENT_ID` | Backend | Khi bật Google Login | Audience dùng verify token |
| `OTP_TTL`, `OTP_MAX_ATTEMPTS`, `OTP_RESEND_COOLDOWN` | Backend | Có | ADR-005: `PT10M`, 5 attempts, `PT1M`; client không hard-code |
| `SCHEDULE_MISSED_GRACE` | Backend | Có | Grace sau cuối ngày local trước khi materialize `MISSED`; pin cùng ADR-007 |
| `MAIL_PROVIDER_*` | Backend | Khi gửi OTP email | Resend production/demo online; fake inbox local/test |
| `AI_SERVICE_BASE_URL` | Backend | Có khi bật AI | Internal URL |
| `AI_SERVICE_TOKEN` | Backend/FastAPI | Có | Internal service authentication |
| `AI_PROVIDER`, `AI_MODEL` | FastAPI | Có khi bật AI | Một provider mặc định cho MVP |
| `AI_PROVIDER_API_KEY` | FastAPI | Có khi bật AI | Secret provider |
| `STORAGE_ENDPOINT` | Backend | Khi bật upload | S3 endpoint nội bộ |
| `STORAGE_PUBLIC_ENDPOINT` | Backend | Khi direct upload | Endpoint được embed trong presigned URL |
| `STORAGE_BUCKET` | Backend | Khi bật upload | Bucket private |
| `STORAGE_ACCESS_KEY/SECRET_KEY` | Backend | Khi bật upload | Storage credential |
| `STORAGE_UPLOAD_TTL/ACCESS_TTL` | Backend | Có | TTL ngắn, đề xuất `PT5M` baseline |
| `MEDIA_MAX_*_BYTES` | Backend | Có | ADR-006: image 5 MiB, Exercise video 50 MiB; không GIF P0 |
| `CORS_ALLOWED_ORIGINS` | Backend/storage | Khi có browser client | Allowlist cụ thể, không wildcard với credential |
| `REDIS_URL` | Backend | Không | Chỉ khi profile Redis được bật |
| `LOG_LEVEL` | Cả hai | Có | Không bật debug payload ở production |

Các giá trị này tuân theo ADR-002..ADR-006 và vẫn phải cấu hình server-side; Mobile không hard-code policy.

### 4.2. Spring Boot `application.yml`

```yaml
server:
  port: ${SERVER_PORT:8080}
  shutdown: graceful
  forward-headers-strategy: framework

spring:
  application:
    name: viegym-backend
  lifecycle:
    timeout-per-shutdown-phase: 30s
  datasource:
    url: ${SPRING_DATASOURCE_URL}
    username: ${SPRING_DATASOURCE_USERNAME}
    password: ${SPRING_DATASOURCE_PASSWORD}
    hikari:
      maximum-pool-size: ${DB_POOL_MAX_SIZE:10}
      minimum-idle: ${DB_POOL_MIN_IDLE:2}
      connection-timeout: ${DB_CONNECTION_TIMEOUT_MS:3000}
  jpa:
    open-in-view: false
    hibernate:
      ddl-auto: validate
    properties:
      hibernate.jdbc.time_zone: UTC
  flyway:
    enabled: true
    locations: classpath:db/migration
    validate-on-migrate: true
  jackson:
    time-zone: UTC
  servlet:
    multipart:
      max-file-size: 1MB
      max-request-size: 1MB

management:
  endpoints:
    web:
      exposure:
        include: health,info,prometheus
  endpoint:
    health:
      probes:
        enabled: true
      show-details: never

app:
  api-prefix: /api/v1
  default-timezone: ${APP_DEFAULT_TIMEZONE:Asia/Ho_Chi_Minh}
  security:
    jwt:
      signing-key: ${JWT_SIGNING_KEY}
      access-ttl: ${JWT_ACCESS_TTL:PT15M}
      refresh-ttl: ${JWT_REFRESH_TTL:P7D}
    otp:
      ttl: ${OTP_TTL:PT10M}
      max-attempts: ${OTP_MAX_ATTEMPTS:5}
      resend-cooldown: ${OTP_RESEND_COOLDOWN:PT1M}
  ai:
    base-url: ${AI_SERVICE_BASE_URL:http://ai-service:8000}
    service-token: ${AI_SERVICE_TOKEN}
    connect-timeout: ${AI_CONNECT_TIMEOUT:PT3S}
    read-timeout: ${AI_READ_TIMEOUT:PT20S}
    max-attempts: ${AI_MAX_ATTEMPTS:2}
  storage:
    endpoint: ${STORAGE_ENDPOINT:http://minio:9000}
    public-endpoint: ${STORAGE_PUBLIC_ENDPOINT:http://localhost:9000}
    bucket: ${STORAGE_BUCKET:viegym-media}
    access-key: ${STORAGE_ACCESS_KEY}
    secret-key: ${STORAGE_SECRET_KEY}
    region: ${STORAGE_REGION:us-east-1}
    path-style-access: ${STORAGE_PATH_STYLE_ACCESS:true}
    upload-ttl: ${STORAGE_UPLOAD_TTL:PT5M}
    access-ttl: ${STORAGE_ACCESS_TTL:PT5M}
```

`multipart` được giữ nhỏ vì binary đi trực tiếp vào object storage. Nếu triển khai backend-upload fallback, tạo endpoint/limit riêng thay vì nới toàn bộ API không kiểm soát.

### 4.3. FastAPI settings

```text
APP_ENV=local|test|prod
INTERNAL_SERVICE_TOKEN=<secret>
AI_PROVIDER=<one configured provider>
AI_MODEL=<pinned model/config>
AI_PROVIDER_API_KEY=<secret>
AI_CONNECT_TIMEOUT_SECONDS=3
AI_READ_TIMEOUT_SECONDS=20
AI_MAX_ATTEMPTS=2
AI_MAX_CONTEXT_BYTES=<budget>
AI_MAX_OUTPUT_TOKENS=<budget>
LOG_LEVEL=INFO
```

- Pydantic settings phải fail fast khi thiếu config bắt buộc.
- FastAPI không nhận `SPRING_DATASOURCE_*`, storage credential, JWT signing key hoặc Google client secret.
- Provider name/model có thể ghi telemetry; API key và full prompt/context không được log.

### 4.4. Profiles

| Profile | Database | Storage | AI Provider | Redis |
|---|---|---|---|---|
| `local` | PostgreSQL container | MinIO hoặc asset demo | Mock hoặc provider thật có quota dev | Off mặc định |
| `test` | Testcontainers PostgreSQL | Testcontainers storage/S3 mock | Mock transport | Off |
| `prod` | Managed PostgreSQL/HA | Managed S3-compatible + CDN khi phù hợp | Provider qua secret manager | Chỉ bật khi có nhu cầu đo được |

Không dùng H2 cho integration test phụ thuộc constraint/transaction PostgreSQL.

---

## 5. Container Images

### 5.1. Backend Dockerfile

```dockerfile
# Pin image patch/digest trong source thực tế
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /workspace
COPY pom.xml mvnw ./
COPY .mvn .mvn
RUN ./mvnw -B -DskipTests dependency:go-offline
COPY src src
RUN ./mvnw -B -DskipTests package

FROM eclipse-temurin:21-jre
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --system --uid 10001 --create-home appuser
WORKDIR /app
COPY --from=build /workspace/target/*.jar app.jar
USER 10001
EXPOSE 8080
ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75", "-jar", "/app/app.jar"]
```

- CI chạy test trước bước image build; không xem `-DskipTests` trong Docker stage là thay thế CI.
- Runtime image không chứa Maven, source hoặc build credential.
- Container chạy non-root và filesystem read-only khi platform cho phép; chỉ mount volume nếu use case thật sự cần.

### 5.2. AI Service Dockerfile

```dockerfile
# Pin image patch/digest trong source thực tế
FROM python:3.12-slim
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1
RUN useradd --system --uid 10001 --create-home appuser
WORKDIR /app
COPY pyproject.toml uv.lock ./
RUN pip install --no-cache-dir uv && uv sync --frozen --no-dev
COPY app app
USER 10001
EXPOSE 8000
CMD ["uv", "run", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--no-access-log"]
```

Chọn một dependency manager (`uv` hoặc Poetry) và giữ lockfile tương ứng; không duy trì hai flow song song.

### 5.3. Image rules

- Pin Java 21, Python 3.12, PostgreSQL 16 và dependency patch tương thích giữa local/CI/prod.
- Không dùng `latest`.
- Scan OS/package vulnerability và tạo SBOM trong CI khi pipeline hỗ trợ.
- Không bake `.env`, provider key, DB password, signing key hoặc cloud credential vào image/layer.
- Tag image bằng commit SHA/release; deploy bằng immutable digest ở production.

---

## 6. Reverse Proxy / Load Balancer

VieGym là mobile-first nên không cần frontend Nginx container. Production ingress chỉ reverse proxy API; object binary đi trực tiếp bằng presigned URL.

```nginx
upstream viegym_backend {
    server backend:8080;
    keepalive 32;
}

server {
    listen 443 ssl http2;
    server_name api.viegym.example.com;

    # Certificate/key do platform hoặc secret mount quản lý.
    ssl_certificate     /run/secrets/tls.crt;
    ssl_certificate_key /run/secrets/tls.key;

    client_max_body_size 1m;
    proxy_connect_timeout 3s;
    proxy_read_timeout 30s;

    location /api/v1/ {
        proxy_pass http://viegym_backend;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Correlation-Id $request_id;
    }

    location /actuator/ {
        deny all;
    }
}
```

- TLS kết thúc tại managed load balancer hoặc proxy; traffic nội bộ cũng dùng TLS khi threat model/platform yêu cầu.
- Không đặt AI endpoint dưới public ingress.
- Rate limit coarse-grained có thể ở gateway; OTP/login limit authoritative vẫn do Backend thực hiện để có error code/cooldown đúng contract.
- Nếu Swagger UI bật ở demo, production phải tắt hoặc bảo vệ bằng network/admin policy.

---

## 7. PostgreSQL Runtime

### 7.1. Source of truth

- PostgreSQL 16+ là database duy nhất cho Identity, Health, Workout, Nutrition, AI metadata, consent, recommendation, media metadata và audit.
- Timestamp lưu UTC; business date được xác định theo timezone user.
- ORM dùng `ddl-auto=validate`; Flyway quản lý toàn bộ DDL/index/seed.
- Không sửa migration đã chạy; thêm migration mới và chạy validation trong CI.
- App credential chỉ có quyền cần cho runtime. Production có thể tách migration credential có DDL permission khỏi runtime credential.

### 7.2. Migration order

```text
V1__identity_and_profile.sql
V2__health_and_body.sql
V3__workout_master_and_program.sql
V4__workout_execution.sql
V5__nutrition.sql
V6__ai_consent_and_conversation.sql
V7__ai_recommendation_and_audit.sql
V8__media.sql
V9__indexes_and_constraints.sql
V10__seed_reference_data.sql
```

Trước khi Backend nhận traffic:

1. Backup/snapshot nếu migration production có rủi ro.
2. Chạy `flyway validate`.
3. Chạy migration bằng một deploy job/single instance.
4. Smoke test constraint/query quan trọng.
5. Mở traffic cho Backend version tương thích.

Migration phá vỡ backward compatibility cần expand/migrate/contract qua nhiều release; không đổi schema đồng thời theo cách làm instance cũ lỗi ngay.

### 7.3. Connection pool

- Tổng `maximumPoolSize × số Backend instance` phải thấp hơn database connection budget sau khi chừa chỗ cho migration/ops.
- Baseline local `10` chỉ là điểm khởi đầu; production tune bằng load test và metric wait/usage.
- Transaction không được mở trong lúc gọi AI provider hoặc chờ object storage.
- Query list phải pagination; theo dõi N+1, slow query và index usage trước khi cache.

### 7.4. Transaction/concurrency quan trọng

| Use case | Bảo vệ bắt buộc |
|---|---|
| Verify OTP | Consume OTP, activate account và session metadata atomically |
| Health update | Profile, calculation và NutritionTarget cùng transaction |
| Finish workout | Lock session/schedule, persist log/snapshot, metric/PR và state atomically |
| Weight log | Upsert theo user/ngày; log mới nhất sync Health metrics nhưng không tự đổi target |
| Meal entry | Lazily tạo plan + target snapshot ở mutation đầu; validate Food, calculate snapshot và persist atomically |
| Consent change | Current setting và history cùng transaction |
| Apply recommendation | Ownership/state/expiry/version lock, domain mutation, log/audit và `APPLIED` cùng transaction |

External AI/storage side effect dùng trạng thái retry/fallback (`ai_requests`, `media_objects`), không dùng distributed transaction.

---

## 8. Object Storage

### 8.1. Bucket và quyền

- Bucket mặc định private; chặn anonymous list/read/write.
- Browser/device chỉ dùng presigned PUT/GET sau Backend authorization.
- CDN chỉ đặt trước object public hợp lệ; private avatar/media vẫn qua access policy và signed access.
- Bật server-side encryption, versioning/lifecycle và access logging theo khả năng provider production.
- CORS object storage chỉ allow origin/method/header thực sự dùng. Flutter native không dựa vào browser CORS, nhưng web/admin tương lai vẫn cần allowlist đúng.

### 8.2. Object key

```text
viegym-media/
└── media/
    ├── exercise/{uuid}.{ext}
    ├── food/{uuid}.{ext}
    └── user-profile/{uuid}.{ext}
```

- Backend sinh UUID/object key; không dùng filename, email hoặc user-supplied path để quyết định quyền.
- `original_file_name` chỉ là metadata đã sanitize.
- Object key không phải bằng chứng authorization; owner/visibility/status trong PostgreSQL mới quyết định access.

### 8.3. Upload lifecycle

```text
resource create/update (HIDDEN với Admin catalog mới)
  → upload-init
  → authorize owner/type + validate declared size/MIME/extension
  → MediaObject(PENDING_UPLOAD) + presigned PUT TTL ngắn
  → client PUT trực tiếp
  → upload-complete
  → Backend HEAD/inspect object + verify actual size/MIME
  → READY hoặc FAILED
```

- Apache Tika hoặc cơ chế tương đương kiểm tra MIME thực tế.
- Chỉ cấp access URL khi status `READY` và access policy pass.
- Complete lặp lại phải idempotent.
- Streaming/transcoding video nâng cao ngoài MVP.

### 8.4. Orphan cleanup

- Object upload quá hạn/chưa complete được chuyển `FAILED/ORPHANED` trước khi xóa vật lý.
- Delete object phải idempotent; object đã mất có thể xem là hoàn tất nhưng vẫn ghi metric/audit phù hợp.
- Không xóa media còn được Exercise/Food/history tham chiếu.
- Multi-instance scheduler cần distributed lock hoặc job idempotency.

---

## 9. AI Service Runtime

### 9.1. Internal contract

```text
Spring Boot
  → authentication/ownership
  → consent check
  → context whitelist/budget
  → rule engine + candidate shortlist + render versioned prompt
  → POST FastAPI internal API + schemaVersion + correlationId
FastAPI
  → provider adapter
  → parse/schema/safety helper
Spring Boot
  → business/safety validation
  → response hoặc PENDING proposal
```

GET Dashboard/Recommendation không đi qua pipeline này. Chỉ POST generation/chat
command mới được gọi provider. Daily generation dùng idempotency key + batch
record; toàn bộ 1–3 item phải pass validation trước khi persist. Output `BLOCKED`
chỉ ghi telemetry đã redact, không tạo recommendation.

- Internal request contract theo phần `Internal AI Service Contract` trong `API_SPEC.md`.
- FastAPI không tự authorize user, không đọc database và không mutation Health/Workout/Nutrition.
- Backend không gửi password, token, OTP, provider key, dữ liệu user khác hoặc raw history không cần thiết.

### 9.2. Service-to-service security

- Local: shared internal token qua secret environment là baseline đơn giản.
- Production: private network + workload identity/mTLS hoặc rotated service credential.
- FastAPI reject request thiếu/sai internal auth trước khi parse context sâu.
- Không forward Mobile JWT cho provider; correlation ID không chứa PII.

### 9.3. Timeout, retry và fallback

- Backend có connect/read timeout hữu hạn khi gọi FastAPI.
- FastAPI có timeout hữu hạn khi gọi provider.
- Retry tối đa cho lỗi tạm thời và chỉ với operation an toàn; không retry vô hạn.
- Circuit breaker có thể bật bằng Resilience4j sau khi threshold được đo.
- Output không parse/schema/safety pass trả error/fallback an toàn, không mutation.
- Provider latency được tách khỏi P95 API thường; theo dõi quota, token usage và cost.

### 9.4. Provider policy

- MVP chọn một provider mặc định bằng config; adapter giữ business contract độc lập SDK.
- Không gọi nhiều provider đồng thời nếu chưa có use case/cost routing rõ.
- Unit/CI dùng mock transport; provider smoke test tách riêng, quota giới hạn và chạy bằng environment secret.
- Model/provider thay đổi cần regression test prompt, schema, safety và cost trước rollout.

---

## 10. Redis — Optional Profile

Redis 7+ chỉ bật khi profiling hoặc yêu cầu distributed counter cho thấy cần thiết.

| Key group | Vai trò | TTL/invalidation |
|---|---|---|
| Exercise/Food/equipment reference | Cache read-heavy | TTL ngắn; evict khi Admin mutation |
| Dashboard summary | Giảm aggregate lặp | TTL ngắn; evict theo domain mutation |
| OTP/login counters | Distributed rate limit | TTL đúng security policy |

Quy tắc:

- PostgreSQL vẫn giữ refresh token, OTP challenge và mọi business record authoritative.
- Cache miss/mất Redis không làm mất dữ liệu hoặc phá transaction.
- Redis unavailable phải degrade cache/rate-limit theo policy an toàn; không mặc định fail-open cho abuse-sensitive endpoint.
- Không lưu raw health profile, conversation hoặc AI context lâu dài trong cache.

---

## 11. Background Jobs

Core P0 không phụ thuộc message broker hoặc worker riêng. Job có thể chạy trong Backend theo scheduler/lazy evaluation:

| Job | Cách P0 | Khi chạy nền | Tính chất |
|---|---|---|---|
| Expire recommendation | Lazy khi read/apply hoặc scheduler | Theo interval cấu hình | Idempotent `PENDING → EXPIRED` |
| Mark missed schedule | Lazy authoritative; scheduler chỉ materialize sớm | Sau cuối ngày + grace theo profile timezone | Bỏ qua session active; không đổi `CANCELLED/COMPLETED` |
| Orphan media cleanup | Scheduler hardening | Theo retention/TTL | Xóa idempotent, bảo toàn reference |
| Conversation summary | Khi context vượt budget | Sau message/async nội bộ | Không là source of truth domain |
| Notification scheduler | Không P0 | P1 | Lỗi không rollback domain |
| Weekly Review | Không P0 | P1 | Tuân consent |

Khi Backend chạy nhiều instance:

- Dùng database advisory lock/ShedLock hoặc cơ chế single-execution tương đương.
- Query batch có giới hạn, checkpoint và retry; tránh full-table scan/lock dài.
- Mỗi handler idempotent vì lock không thay thế khả năng retry sau crash.
- Chỉ thêm broker/worker qua ADR khi scheduler nội bộ trở thành bottleneck đo được.

---

## 12. Observability

### 12.1. Structured logging

Log JSON tối thiểu:

```json
{
  "timestamp": "2026-08-19T08:30:00Z",
  "level": "INFO",
  "service": "viegym-backend",
  "correlationId": "2b651bb2-154f-4c90-8c70-cb182d741a27",
  "event": "recommendation.apply",
  "result": "SUCCEEDED",
  "durationMs": 84
}
```

- Truyền/echo `X-Correlation-Id` từ Backend sang FastAPI và provider adapter khi có thể.
- Không log password/hash, access/refresh token, OTP/code hash, presigned URL, provider key, full prompt, raw personal context hoặc conversation dư thừa.
- User/resource ID chỉ log khi cần và theo privacy policy; không dùng email làm label metric.
- Production access log phải redact Authorization, query/payload nhạy cảm.

### 12.2. Health endpoints

| Service | Endpoint | Public | Mục đích |
|---|---|:---:|---|
| Backend | `/actuator/health/liveness` | Không | Process/JVM còn sống |
| Backend | `/actuator/health/readiness` | LB/platform only | Sẵn sàng nhận traffic |
| Backend | `/actuator/prometheus` | Metrics network only | Micrometer scrape |
| FastAPI | `/health` | Internal only | Process/config health |
| FastAPI | `/ready` nếu tách | Internal only | Readiness không gọi provider tốn phí |

Liveness không phụ thuộc AI provider/database theo cách gây restart loop. Readiness phản ánh dependency bắt buộc; dependency tùy chọn như Redis có thể báo degraded thay vì làm core unavailable.

### 12.3. Metrics và alerts

Theo dõi tối thiểu:

- HTTP request count, latency P50/P95/P99, 4xx/5xx theo route template.
- JVM memory/GC/thread, Hikari pool usage/wait, database connection/error/slow query.
- Auth failure, OTP resend/rate-limit và token reuse/revoke event.
- Workout invalid transition/concurrent conflict.
- AI Service/provider latency, timeout, retry, circuit state, parse/schema/safety failure và token/cost metadata.
- Recommendation created/applied/dismissed/expired và apply conflict; không dùng user ID làm metric label.
- Media init/complete/failure/MIME mismatch/orphan cleanup và storage latency.
- Scheduler duration, scanned/succeeded/failed count và lock contention.

Alert cho sustained 5xx, readiness failure, DB pool exhaustion, migration failure, AI timeout spike, backup failure và storage upload failure spike.

### 12.4. Audit

Audit tối thiểu cho Admin mutation, consent change, security-sensitive account action và recommendation Apply:

```text
actorId · actorRole · action · targetType · targetId
result · correlationId · timestamp · redacted change summary
```

Audit không thay thế application log và không trở thành kho raw PII/context.

---

## 13. Backup, Restore & Retention

### 13.1. PostgreSQL

- Production dùng managed automated backup/PITR khi khả dụng; nếu self-hosted, kết hợp logical backup và WAL/physical strategy phù hợp.
- Backup được mã hóa, tách credential/quyền khỏi runtime app và lưu khác failure domain.
- Chụp backup/snapshot trước migration rủi ro.
- Không coi backup thành công nếu chưa có restore test định kỳ.
- Môi trường đồ án tốt nghiệp chỉ dùng dữ liệu synthetic/demo và phải có runbook reset
  database/object storage trước bàn giao hoặc trong vòng 30 ngày sau khi kết
  thúc chấm. RPO/RTO, legal retention, self-service account deletion và backup
  expiry phải được khóa riêng trước khi dùng dữ liệu thật/production.

### 13.2. Object storage

- Bật versioning/lifecycle theo provider và chi phí.
- Database backup và object backup/version phải có khả năng khôi phục nhất quán ở mức business chấp nhận được.
- Orphan cleanup không được xóa object còn reference; lifecycle rule không được ngắn hơn retention nghiệp vụ cần thiết.
- Không backup presigned URL; chỉ backup object và metadata/object key.

### 13.3. Restore runbook

1. Cô lập môi trường đích và xác định recovery point.
2. Restore PostgreSQL vào instance mới, không overwrite trực tiếp khi chưa xác minh.
3. Validate Flyway history, schema constraint và row counts chính.
4. Khôi phục/đối chiếu object storage; phát hiện missing/orphan object.
5. Rotate credential có nguy cơ lộ.
6. Chạy smoke test Auth → Health → Workout → Meal → Dashboard → AI boundary.
7. Chỉ chuyển traffic sau khi consistency/security check pass.

---

## 14. CI/CD & Release

### 14.1. Pipeline

```text
Lint / Format
      ↓
Unit Test: Flutter + Backend + AI Service
      ↓
Generate OpenAPI `dart-dio` client + fail on uncommitted diff
      ↓
Integration Test: PostgreSQL + Object Storage
      ↓
Security/dependency scan + secret scan
      ↓
Build APK + immutable Backend/AI images
      ↓
Flyway migration check + OpenAPI compatibility check
      ↓
Docker Compose smoke test
      ↓
Deploy staging → smoke/E2E → production approval
```

Provider thật không được gọi trong CI mặc định. Testcontainers dùng cùng PostgreSQL major với production target.

### 14.2. Release order

1. Deploy backward-compatible schema migration.
2. Deploy FastAPI version tương thích cả Backend cũ/mới nếu internal schema đổi.
3. Deploy Backend bằng rolling/blue-green strategy.
4. Chạy health/smoke/metric check.
5. Phát hành Mobile sau khi API tương thích được xác nhận.
6. Contract cleanup chỉ thực hiện ở release sau khi client cũ hết support window.

### 14.3. Rollback

- Rollback image bằng immutable tag/digest.
- Không tự động undo destructive migration. Dùng forward-fix hoặc restore theo runbook đã thử.
- Feature flag/config có thể tắt AI provider, media upload hoặc job không cốt lõi để giữ Health/Workout/Nutrition hoạt động.
- Recommendation/output sinh từ version lỗi phải được đánh dấu/expire theo business rule, không âm thầm apply.

---

## 15. Capacity & Port Mapping

### 15.1. Port mapping

| Component | Container port | Local host | Production exposure |
|---|---:|---:|---|
| Spring Boot Backend | `8080` | `8080` | Qua LB/API Gateway |
| FastAPI AI Service | `8000` | Không mặc định | Internal only |
| PostgreSQL | `5432` | Không mặc định | Private DB network |
| Object storage S3 API | `9000` | `9000` khi direct upload local | Managed/private + signed access |
| Object storage console | `9001` | Chỉ dev profile nếu cần | Không public |
| Redis | `6379` | Không mặc định | Private, optional |

### 15.2. Planning baseline

Không có tải/user concurrency chính thức trong SRS, vì vậy cấu hình CPU/RAM không phải acceptance requirement. Điểm khởi đầu để chạy demo trên một máy:

| Thành phần | CPU planning | RAM planning | Ghi chú |
|---|---:|---:|---|
| Backend | 1–2 vCPU | 1–2 GB | Tune JVM/container limit |
| FastAPI | 0.5–1 vCPU | 512 MB–1 GB | Provider chạy ngoài process |
| PostgreSQL | 1–2 vCPU | 1–2 GB | Phụ thuộc seed/query/concurrency |
| MinIO local | 0.5–1 vCPU | 512 MB–1 GB | Video demo làm tăng disk/bandwidth |
| Redis optional | 0.25–0.5 vCPU | 128–256 MB | Chỉ cache/counter |

Một máy dev/demo khoảng 4 vCPU, 8 GB RAM và disk đủ media thường thuận tiện; minimum thực tế phải xác nhận bằng Compose smoke test. Production sizing phải dựa trên load test, DB working set, media traffic và AI quota, không sao chép con số demo.

### 15.3. Performance target

- P95 của Health Metrics, Exercise list, Food list, Weight Trend và Dashboard
  dưới `500 ms`, error rate dưới `1%`, không tính AI Provider. Chạy với Docker
  Compose 4 vCPU/8 GB, 100 user, 40 Exercise, 80 Food, 90 ngày dữ liệu cho user
  đo, 10 virtual users, warm-up 2 phút và đo 5 phút; lưu cấu hình, commit,
  dataset, P50/P95 và error rate trong báo cáo.
- List endpoint pagination mặc định 20, tối đa 100 theo API Spec.
- Dashboard chỉ cache/materialize sau khi profiling chứng minh cần.
- AI timeout/failure trả fallback an toàn và không làm hỏng domain transaction.

---

## 16. Production Hardening Checklist

### Network và TLS

- [ ] HTTPS bắt buộc; HSTS và TLS policy do ingress quản lý.
- [ ] Backend/AI/DB/Redis/storage admin đặt private network/security group.
- [ ] Không public FastAPI docs, Swagger production, Actuator detail hoặc admin console.
- [ ] Egress từ AI Service chỉ tới provider/DNS/telemetry cần thiết khi platform hỗ trợ.

### Identity và secret

- [ ] Password dùng BCrypt; OTP/refresh token chỉ lưu hash.
- [ ] JWT key có rotation/`kid` strategy và không nằm trong repository/image.
- [ ] Google token verify issuer/audience/signature/expiry server-side.
- [ ] Secret lấy từ secret manager/workload identity; có rotation runbook.
- [ ] Rate limit login/OTP/forgot-password theo subject/IP/device phù hợp, chống enumeration.

### Authorization và privacy

- [ ] Mọi private query scope `user_id`; role không thay ownership.
- [ ] Admin không mặc định đọc private Health/Meal/Workout/AI data.
- [ ] Consent check xảy ra trước Context Builder.
- [ ] Log/audit/metric redaction đã có automated test.
- [ ] Retention/purge cho OTP, token, AI context, conversation, audit và account deletion được phê duyệt.

### Database và storage

- [ ] Flyway validate; runtime không có quyền DDL không cần thiết.
- [ ] Backup/PITR và restore drill đã pass; RPO/RTO được khóa.
- [ ] Bucket private, encryption/versioning/lifecycle đúng policy.
- [ ] MIME/extension/size được verify ở upload-complete; presigned URL TTL ngắn.
- [ ] Orphan cleanup idempotent và bảo toàn history reference.

### Runtime và supply chain

- [ ] Image pin digest, non-root, vulnerability scan và SBOM.
- [ ] Resource request/limit, graceful shutdown, readiness/liveness đúng semantics.
- [ ] DB pool budget phù hợp số instance; timeout/retry hữu hạn.
- [ ] Scheduled job có lock/idempotency khi scale ngang.
- [ ] Alert/backup/deploy rollback runbook đã diễn tập.

---

## 17. Quyết định cần khóa bằng ADR

Các điểm dưới đây chưa có một lựa chọn implementation duy nhất trong tài liệu nguồn:

1. Production hosting platform, secret manager, ingress/WAF và observability vendor.
2. Backup retention, RPO/RTO, privacy retention và account deletion/purge process.

Các quyết định storage, AI, OTP, Redis P0, media allowlist và expiry đã được khóa
tại `checkM0/ADR-002` đến `ADR-007`. Redis không thuộc dependency bắt buộc P0;
PostgreSQL giữ counter OTP/rate-limit baseline.

ADR phải ghi context, lựa chọn, phương án loại, hệ quả, owner và ngày áp dụng. Không quyết định nào được phá các invariant: Backend là business authority, PostgreSQL là source of truth, FastAPI không có DB access và AI không tự mutation.

---

## 18. Tài liệu liên quan

| Tài liệu | Quan hệ |
|---|---|
| [`techstack.md`](./techstack.md) | Runtime/dependency baseline và compatibility matrix |
| [`DATABASE.md`](./DATABASE.md) | Schema, transaction, index, migration và privacy |
| [`../kientruchethong/sa.md`](../kientruchethong/sa.md) | System architecture, boundary, deployment và reliability |
| [`../kientruchethong/API_SPEC.md`](../kientruchethong/API_SPEC.md) | Public/internal API, security, status/error và media contract |
| [`../spec/specs.md`](../spec/specs.md) | SRS, NFR, P0/P1 và out-of-scope |
| [`../spec/bussiness_mainflow.md`](../spec/bussiness_mainflow.md) | E2E business flow và failure branches |
| [`../spec/phan_ra_phan_he_he_thong.md`](../spec/phan_ra_phan_he_he_thong.md) | Subsystem ownership và dependency |

Server/deployment change làm thay đổi boundary, API, data lifecycle hoặc release scope phải cập nhật đồng thời tài liệu liên quan và được kiểm tra trong CI/smoke test.
