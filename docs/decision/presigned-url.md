# ADR — Media Upload & Object Storage cho VieGym

> Quyết định kiến trúc cho việc lưu avatar, ảnh món ăn, ảnh sản phẩm và video/GIF bài tập.

---

## 1. Bối cảnh

VieGym cần lưu các loại media:

- Avatar người dùng.
- Ảnh món ăn Việt Nam.
- Ảnh sản phẩm.
- Video/GIF minh họa bài tập.

Không nên lưu binary trực tiếp trong MySQL vì làm database phình to, backup chậm và khó phục vụ file hiệu quả.

---

## 2. Quyết định

- Dùng object storage cho media.
- Local/dev dùng MinIO.
- Production có thể dùng Amazon S3 hoặc S3-compatible storage.
- MySQL chỉ lưu metadata: URL/object key, MIME type, size, owner/entity reference.
- Backend kiểm tra quyền và validate file trước/sau upload.

---

## 3. Upload strategy

MVP có thể chọn một trong hai cách:

### Cách A — Backend nhận multipart rồi upload storage

Phù hợp giai đoạn đồ án vì đơn giản:

```text
Flutter multipart upload
  ↓
Spring Boot validate file
  ↓
Spring Boot upload MinIO/S3
  ↓
Lưu object key vào MySQL
```

### Cách B — Presigned URL

Phù hợp khi scale:

```text
Flutter xin upload URL
  ↓
Backend validate metadata và ký presigned PUT URL
  ↓
Flutter upload trực tiếp lên storage
  ↓
Flutter gọi complete
  ↓
Backend validate object và lưu metadata
```

---

## 4. Validation rules

- Chỉ cho phép media type cần thiết: jpg, jpeg, png, webp, gif, mp4 nếu dùng video.
- Giới hạn kích thước theo loại file.
- Object key do backend sinh, không dùng filename user nhập làm path.
- Không public write bucket.
- Không lưu secret storage trong mobile app.

---

## 5. Khi nào dùng presigned URL

Dùng presigned URL khi:

- File video/GIF lớn.
- Nhiều user/admin upload cùng lúc.
- Backend bị tốn bandwidth vì proxy file.
- Cần scale object storage độc lập với API server.

Với MVP đồ án, multipart qua backend là đủ nếu triển khai nhanh hơn.
