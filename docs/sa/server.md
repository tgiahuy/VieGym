# Server & Deployment — VieGym

> Cấu hình server, môi trường chạy và triển khai cho VieGym.

---

## 1. Development Architecture

```text
Local Machine / Docker Compose
├── Spring Boot Backend: 8080
├── Python FastAPI AI Service: 8000
├── MySQL: 3306
├── Redis: 6379
├── MinIO: 9000 / 9001
└── Flutter App chạy bằng emulator/device
```

---

## 2. Docker Compose đề xuất

```yaml
services:
  backend:
    build: ./backend
    ports:
      - "8080:8080"
    environment:
      SPRING_PROFILES_ACTIVE: dev
      SPRING_DATASOURCE_URL: jdbc:mysql://mysql:3306/viegym
      SPRING_DATASOURCE_USERNAME: viegym_user
      SPRING_DATASOURCE_PASSWORD: viegym_password
      SPRING_DATA_REDIS_HOST: redis
      SPRING_DATA_REDIS_PORT: 6379
      JWT_SECRET: change-me-to-a-secure-secret
      AI_SERVICE_BASE_URL: http://ai-service:8000
      STORAGE_ENDPOINT: http://minio:9000
      STORAGE_BUCKET: viegym-media
      STORAGE_ACCESS_KEY: viegym_minio
      STORAGE_SECRET_KEY: viegym_minio_password
    depends_on:
      - mysql
      - redis
      - minio
      - ai-service

  ai-service:
    build: ./ai-service
    ports:
      - "8000:8000"
    environment:
      AI_PROVIDER: openai
      OPENAI_API_KEY: ${OPENAI_API_KEY}
      GEMINI_API_KEY: ${GEMINI_API_KEY}

  mysql:
    image: mysql:8.4
    ports:
      - "3306:3306"
    environment:
      MYSQL_DATABASE: viegym
      MYSQL_USER: viegym_user
      MYSQL_PASSWORD: viegym_password
      MYSQL_ROOT_PASSWORD: root_password
      TZ: Asia/Ho_Chi_Minh
    volumes:
      - mysql-data:/var/lib/mysql

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data

  minio:
    image: minio/minio:latest
    command: server /data --console-address ":9001"
    ports:
      - "9000:9000"
      - "9001:9001"
    environment:
      MINIO_ROOT_USER: viegym_minio
      MINIO_ROOT_PASSWORD: viegym_minio_password
    volumes:
      - minio-data:/data

volumes:
  mysql-data:
  redis-data:
  minio-data:
```

---

## 3. Environment Variables

### Backend

| Biến | Mô tả |
|---|---|
| SPRING_PROFILES_ACTIVE | `dev`, `prod` |
| SPRING_DATASOURCE_URL | JDBC URL MySQL |
| SPRING_DATASOURCE_USERNAME | DB username |
| SPRING_DATASOURCE_PASSWORD | DB password |
| SPRING_DATA_REDIS_HOST | Redis host |
| SPRING_DATA_REDIS_PORT | Redis port |
| JWT_SECRET | Secret ký JWT |
| JWT_ACCESS_EXPIRATION | TTL access token |
| JWT_REFRESH_EXPIRATION | TTL refresh token |
| AI_SERVICE_BASE_URL | URL FastAPI AI Service |
| STORAGE_ENDPOINT | MinIO/S3 endpoint |
| STORAGE_BUCKET | Bucket media |
| STORAGE_ACCESS_KEY | Access key |
| STORAGE_SECRET_KEY | Secret key |
| CORS_ORIGINS | Origin được phép gọi API |

### AI Service

| Biến | Mô tả |
|---|---|
| AI_PROVIDER | `openai` hoặc `gemini` |
| OPENAI_API_KEY | API key nếu dùng OpenAI |
| GEMINI_API_KEY | API key nếu dùng Gemini |
| MAX_OUTPUT_TOKENS | Giới hạn output AI |
| REQUEST_TIMEOUT_SECONDS | Timeout gọi provider |

---

## 4. Production Direction

```text
Mobile App
   |
Nginx / Load Balancer
   |
Spring Boot Backend xN
   ├── Managed MySQL
   ├── Redis
   ├── S3-compatible Object Storage
   └── FastAPI AI Service xN
          └── AI Provider
```

Production cần bổ sung:

- HTTPS/TLS.
- Secret manager hoặc biến môi trường an toàn.
- Backup MySQL định kỳ.
- Private bucket cho media.
- Monitoring logs/errors.
- Rate limit auth và AI chat.
- CI/CD GitHub Actions.

---

## 5. Demo checklist

- Backend chạy được ở `http://localhost:8080/api/v1`.
- Swagger/OpenAPI truy cập được.
- MySQL có schema và seed dữ liệu mẫu.
- Redis chạy ổn định.
- MinIO bucket tạo sẵn cho media.
- AI Service trả được response mock hoặc provider thật.
- Flutter app đăng nhập, dashboard, meal planner, workout và shop gọi được API.
