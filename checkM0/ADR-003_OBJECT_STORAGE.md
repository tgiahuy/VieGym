# ADR-003 — Object storage cho media

- **Trạng thái:** ACCEPTED
- **Ngày áp dụng:** 2026-08-19
- **Owner:** Backend/Infrastructure
- **Phạm vi:** Media P0 của Exercise và Food

## Bối cảnh

MVP cần upload ảnh/video có thể chạy local, test và triển khai mà không lưu binary trong PostgreSQL.

## Quyết định

Dùng MinIO trong Docker Compose cho local/demo và Amazon S3 cho production. Backend dùng AWS SDK for Java v2 qua một storage port S3-compatible, bucket private, object key ngẫu nhiên và presigned PUT/GET TTL 5 phút. Local bật path-style access; production dùng region và virtual-hosted style của S3. Không bật CDN, transcoding hoặc public bucket trong P0.

Upload gồm `upload-init` → client PUT trực tiếp → `upload-complete`; Backend HEAD object, kiểm tra size/MIME thực và chỉ sau đó chuyển media sang `READY`. Bootstrap bucket local phải idempotent.

## Phương án đã cân nhắc

- Lưu file trên filesystem Backend: loại vì khó scale/backup và container không bền.
- Chỉ dùng URL/asset tĩnh: vẫn là fallback demo nhưng không đáp ứng media lifecycle đầy đủ.
- Provider S3-compatible khác: có thể thay sau qua adapter/config, chưa cần cho P0.

## Hệ quả và rollback

Cần test integration với MinIO và không thay hostname của URL sau khi presign. Có thể chuyển managed provider bằng storage adapter/migration object key; metadata DB không đổi.

