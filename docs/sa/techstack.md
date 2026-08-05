# Tech Stack — VieGym

> Công nghệ sử dụng cho ứng dụng VieGym theo kế hoạch dự án.

---

## 1. Tổng quan

```text
Flutter Mobile App
        |
        | REST API / HTTPS
        v
Spring Boot Backend
        |
        ├── MySQL
        ├── Redis
        ├── MinIO / Amazon S3
        └── Python FastAPI AI Service
                └── OpenAI API hoặc Gemini API
```

---

## 2. Mobile App

| Công nghệ | Vai trò |
|---|---|
| Flutter | Framework xây dựng ứng dụng mobile |
| Dart | Ngôn ngữ Flutter |
| Riverpod | State management |
| Dio hoặc http | HTTP client gọi REST API |
| Flutter Secure Storage | Lưu token/thông tin nhạy cảm phía client |
| go_router | Routing/navigation |
| fl_chart | Biểu đồ calories, macro, cân nặng, tiến bộ tập luyện |
| Firebase Cloud Messaging hoặc local notifications | Nhắc lịch tập/cân nặng/đơn hàng nếu tích hợp |

Project structure đề xuất:

```text
mobile/lib/
├── core/
│   ├── config/
│   ├── network/
│   ├── storage/
│   ├── theme/
│   └── widgets/
├── features/
│   ├── auth/
│   ├── dashboard/
│   ├── health/
│   ├── workout/
│   ├── nutrition/
│   ├── ai_coach/
│   ├── shop/
│   └── profile/
└── router/
```

---

## 3. Backend API

| Công nghệ | Vai trò |
|---|---|
| Java | Ngôn ngữ backend |
| Spring Boot | REST API và nghiệp vụ chính |
| Spring Web | HTTP API |
| Spring Security | Authentication/authorization |
| JWT | Access token |
| Spring Data JPA | ORM truy cập MySQL |
| Jakarta Bean Validation | Validate DTO request |
| BCrypt | Hash mật khẩu |
| SpringDoc OpenAPI | Swagger API docs |
| MapStruct | Mapping Entity ↔ DTO |
| Lombok | Giảm boilerplate nếu dùng |
| Maven hoặc Gradle | Build tool |

Module backend:

```text
backend/src/main/java/com/viegym/
├── common/
├── identity/
├── health/
├── workout/
├── nutrition/
├── shop/
├── ai/
├── notification/
├── dashboard/
└── audit/
```

---

## 4. AI Service

| Công nghệ | Vai trò |
|---|---|
| Python | Ngôn ngữ AI service |
| FastAPI | HTTP service cho AI Coach/chatbot |
| Pydantic | Validate request/response |
| OpenAI API hoặc Gemini API | AI provider |
| Uvicorn | ASGI server |

AI Service nhận context từ Spring Boot Backend, không truy cập trực tiếp database trong MVP.

---

## 5. Database & Storage

| Thành phần | Công nghệ | Vai trò |
|---|---|---|
| Database | MySQL | Lưu user, health, workout, nutrition, shop, AI history |
| Cache | Redis | Cache OTP/session ngắn hạn, rate limit, dữ liệu truy cập nhanh |
| Object Storage | MinIO local / Amazon S3 production | Ảnh món ăn, ảnh sản phẩm, video/GIF bài tập, avatar |

---

## 6. DevOps

| Công nghệ | Vai trò |
|---|---|
| Docker | Đóng gói service |
| Docker Compose | Chạy local demo gồm backend, MySQL, Redis, MinIO, AI service |
| Nginx | Reverse proxy production nếu cần |
| GitHub | Quản lý source code |
| GitHub Actions | CI/CD, test/build |
| Figma | Thiết kế UI/UX |

---

## 7. Lựa chọn ưu tiên cho đồ án

- Android build trước, iOS để mở rộng sau.
- MySQL là source of truth cho dữ liệu nghiệp vụ.
- Không phụ thuộc hoàn toàn API dinh dưỡng bên ngoài; tự xây Food Service/database món ăn Việt Nam.
- AI tích hợp qua service riêng để dễ kiểm soát prompt, context và chi phí.
- Docker Compose phải chạy được toàn bộ backend stack để demo/bảo vệ.
