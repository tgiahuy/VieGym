# VieGym

> Ứng dụng theo dõi thể hình và dinh dưỡng toàn diện — Đồ án tốt nghiệp MVP P0

[![CI](https://github.com/your-org/VieGym/actions/workflows/ci.yml/badge.svg)](https://github.com/your-org/VieGym/actions/workflows/ci.yml)

---

## Kiến trúc

```
┌─────────────────────────────────────────────────────┐
│  Flutter Mobile App (Android)                        │
│  State: Riverpod  │  Router: go_router               │
│  HTTP: dart-dio (generated from OpenAPI)             │
└───────────────────────┬─────────────────────────────┘
│  React Web Frontend (TypeScript / Vite)               │
│  UI prototype and web client                          │
└───────────────────────┬─────────────────────────────┘
                        │ REST /api/v1
                        ▼
┌─────────────────────────────────────────────────────┐
│  Spring Boot Backend  (Java 21 / Maven)              │
│  Auth: Spring Security + JWT                         │
│  DB migration: Flyway  │  ORM: Spring Data JPA       │
└──────────┬──────────────────────────────────────────┘
           │ HTTP /internal/v1  (X-Internal-Token)
           ▼
┌─────────────────────────────────────────────────────┐
│  FastAPI AI Service  (Python 3.12 / uv)              │
│  Stateless — no DB access                            │
└─────────────────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────────────────┐
│  PostgreSQL 16   (Flyway-managed schema)             │
│  MinIO           (object storage — local dev)        │
└─────────────────────────────────────────────────────┘
```

---

## Yêu cầu

| Công cụ | Phiên bản |
|---------|-----------|
| Flutter | 3.44.4 (pin qua FVM) |
| Dart | ≥ 3.8 |
| Node.js | ≥ 20 |
| pnpm | ≥ 9 |
| Java | 21 (Temurin) |
| Maven Wrapper | bundled |
| Python | 3.12 |
| uv | latest |
| Docker | ≥ 24 |
| Docker Compose | ≥ 2.20 |
| Android SDK | API 34+ |

---

## 1. Cài đặt từ đầu (Clean Setup)

### 1.1 Clone repository

```bash
git clone https://github.com/your-org/VieGym.git
cd VieGym
```

### 1.2 Tạo file biến môi trường

```bash
cp .env.example .env
# Chỉnh sửa .env nếu cần thay đổi port, credentials, hoặc AI provider key
```

### 1.3 Khởi động hạ tầng (PostgreSQL + MinIO)

```bash
docker compose up -d
# Kiểm tra:
docker compose ps        # tất cả service phải ở trạng thái "healthy"
```

### 1.4 Backend — Spring Boot

Flyway sẽ tự động chạy migration khi backend khởi động.

```bash
cd backend
./mvnw spring-boot:run
```

Backend sẵn sàng tại: `http://localhost:8080`  
Swagger UI: `http://localhost:8080/swagger-ui.html`  
Liveness: `http://localhost:8080/actuator/health`

### 1.5 AI Service — FastAPI

```bash
cd ai-service
uv sync              # cài dependencies từ uv.lock
uv run uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

AI Service sẵn sàng tại: `http://localhost:8000`  
Docs: `http://localhost:8000/docs`  
Health: `http://localhost:8000/health`

### 1.6 Mobile — Flutter

Xem mục **Cấu hình Emulator/Device** bên dưới trước khi chạy.

```bash
cd mobile
flutter pub get
flutter run --dart-define=APP_ENV=dev
```

### 1.7 Frontend Web — React/Vite

```bash
cd frontend
pnpm install
pnpm dev
```

Vite hiển thị URL local sau khi development server khởi động.

---

## 2. Cấu hình Emulator và Thiết bị Android

### 2.1 Android Emulator (AVD)

Emulator dùng địa chỉ đặc biệt `10.0.2.2` để trỏ về `localhost` của máy host.  
Đây là giá trị **mặc định** trong `EnvConfig` — **không cần thêm flag**.

```bash
# Chạy app trên emulator (mặc định):
flutter run --dart-define=APP_ENV=dev
```

Kiểm tra emulator thấy backend:
```bash
adb shell curl http://10.0.2.2:8080/actuator/health
```

**Tạo AVD (nếu chưa có):**
1. Mở Android Studio → AVD Manager → Create Virtual Device
2. Chọn: Pixel 6 | API 34 | ABI x86_64
3. Nhấn Finish, sau đó Start

### 2.2 Thiết bị Android vật lý

Máy tính và thiết bị phải **cùng mạng Wi-Fi**.

```bash
# Lấy IP LAN của máy tính:
# macOS:
ipconfig getifaddr en0

# Chạy app với IP thực:
flutter run \
  --dart-define=API_BASE_URL=http://192.168.x.x:8080 \
  --dart-define=APP_ENV=dev
```

**Bật USB Debugging trên thiết bị:**
1. Settings → About Phone → tap "Build Number" 7 lần
2. Settings → Developer Options → bật "USB Debugging"
3. Kết nối USB, chấp nhận prompt trên thiết bị

**Kiểm tra thiết bị được nhận diện:**
```bash
flutter devices
adb devices
```

### 2.3 Kiểm tra kết nối Mobile → Backend

Sau khi app chạy, mở log và tìm dòng:
```
[Dio] GET http://10.0.2.2:8080/actuator/health
[Dio] Response: 200 {"status":"UP"}
```

---

## 3. Kiểm tra (Tests)

### Backend

```bash
cd backend
./mvnw test                    # unit tests
./mvnw verify                  # unit + integration (cần DB)
```

### AI Service

```bash
cd ai-service
uv run pytest -v               # tất cả tests
uv run pytest tests/test_health.py    # chỉ health tests
uv run pytest tests/test_generate.py  # chỉ generate tests
```

### Mobile

```bash
cd mobile
flutter test                   # widget + unit tests
flutter test --coverage        # với coverage report
```

### Frontend Web

```bash
cd frontend
pnpm lint
pnpm build
```

---

## 4. Biến môi trường

Xem [`.env.example`](.env.example) để biết toàn bộ biến có thể cấu hình.  
Các biến quan trọng nhất:

| Biến | Mặc định | Mô tả |
|------|----------|-------|
| `POSTGRES_DB` | `viegym` | Tên database |
| `POSTGRES_USER` | `viegym` | User PostgreSQL |
| `POSTGRES_PASSWORD` | *(xem .env.example)* | Mật khẩu — **đổi trong prod** |
| `INTERNAL_SERVICE_TOKEN` | `dev-secret-token` | Token giao tiếp Backend ↔ AI Service |
| `JWT_SECRET` | *(xem .env.example)* | Secret ký JWT — **đổi trong prod** |

> **Quan trọng:** Không commit file `.env` vào repository. Chỉ commit `.env.example`.

---

## 5. OpenAPI và Dart Client

Backend tự động tạo spec OpenAPI khi build:

```bash
cd backend
./mvnw package -DskipTests
# Spec xuất ra: backend/src/main/resources/openapi/openapi.json
```

Tái tạo Dart client (dart-dio) từ spec:

```bash
# Từ root của repository:
openapi-generator-cli generate \
  -i backend/src/main/resources/openapi/openapi.json \
  -g dart-dio \
  -o mobile/lib/api/generated \
  --additional-properties=pubName=viegym_api,pubVersion=0.1.0
```

CI tự động kiểm tra spec không bị stale (**OpenAPI no-diff gate**).

---

## 6. Troubleshooting

| Vấn đề | Giải pháp |
|--------|-----------|
| `Connection refused` trên emulator | Dùng `10.0.2.2` thay vì `localhost` |
| `Connection refused` trên thiết bị thật | Dùng IP LAN của máy tính (không phải `127.0.0.1`) |
| Backend không kết nối được DB | Chạy `docker compose ps` — đảm bảo postgres healthy |
| `Flyway migration failed` | Xoá volume: `docker compose down -v && docker compose up -d` |
| `uv sync` lỗi | Đảm bảo Python 3.12: `python --version` |
| Flutter `pub get` lỗi | Xoá cache: `flutter clean && flutter pub get` |
| `X-Internal-Token` 403 | Đảm bảo `INTERNAL_SERVICE_TOKEN` trong `.env` khớp với `config.py` |

---

## 7. Cấu trúc thư mục

```
VieGym/
├── frontend/         # React + TypeScript + Vite web app
│   ├── src/          # pages, components, layouts, hooks
│   └── public/       # static assets
├── mobile/           # Flutter app
│   └── lib/
│       ├── core/     # config, network, router, theme
│       ├── shared/   # reusable widgets
│       └── api/      # generated dart-dio client
├── backend/          # Spring Boot
│   └── src/
│       ├── main/resources/db/migration/  # Flyway scripts
│       └── main/resources/openapi/       # committed spec
├── ai-service/       # FastAPI
│   └── app/
│       ├── api/      # endpoint routers
│       ├── core/     # config, security
│       ├── models/   # Pydantic schemas
│       └── services/ # AI provider
├── docs/             # Project docs and frontend screen specification
├── checkM0/          # M0 milestone evidence
└── compose.yaml      # Docker Compose stack
```
