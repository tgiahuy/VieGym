# ADR-006 — Media allowlist P0

- **Trạng thái:** ACCEPTED
- **Ngày áp dụng:** 2026-08-19
- **Owner:** Media Backend
- **Phạm vi:** Exercise và Food P0

## Quyết định

Allowlist áp dụng đồng thời cho extension, MIME khai báo và MIME được phát hiện từ nội dung:

| Owner | Media type | Extension | MIME | Tối đa |
|---|---|---|---|---:|
| EXERCISE | IMAGE | `.jpg`, `.jpeg`, `.png`, `.webp` | `image/jpeg`, `image/png`, `image/webp` | 5 MiB |
| EXERCISE | VIDEO | `.mp4`, `.webm` | `video/mp4`, `video/webm` | 50 MiB |
| FOOD | IMAGE | `.jpg`, `.jpeg`, `.png`, `.webp` | `image/jpeg`, `image/png`, `image/webp` | 5 MiB |

Food video, GIF, SVG và `USER_PROFILE` upload không thuộc P0. Backend kiểm tra size từ object metadata, phát hiện MIME bằng magic bytes/Apache Tika, đối chiếu cả ba yếu tố và xóa/quarantine object sai. Tên file người dùng không được dùng làm object key; không render nội dung chưa `READY`.

## Phương án đã cân nhắc

- Tin `Content-Type` client: loại vì giả mạo được.
- Cho phép SVG/GIF: loại để giảm XSS, decompression và animation risk.
- Video lớn/transcoding: nằm ngoài MVP.

## Hệ quả và rollback

Client lấy constraints từ API/config và validate sớm nhưng Backend vẫn authoritative. Mở rộng allowlist phải có security test và cập nhật ADR/API trong cùng thay đổi.

