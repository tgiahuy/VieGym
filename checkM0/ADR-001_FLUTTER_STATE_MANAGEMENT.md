# ADR-001 — Flutter state management

- **Trạng thái:** ACCEPTED
- **Ngày áp dụng:** 2026-08-19
- **Owner:** Mobile
- **Phạm vi:** MVP P0

## Bối cảnh

Mobile cần một cơ chế duy nhất cho dependency injection, state bất đồng bộ, auth bootstrap và refresh dữ liệu theo feature. Giải pháp phải dễ kiểm thử và không buộc đồ án một người phải duy trì nhiều pattern.

## Quyết định

Dùng `flutter_riverpod` cho toàn bộ state ứng dụng. Dùng `Provider`, `NotifierProvider` và `AsyncNotifierProvider`; UI chỉ quan sát state qua `ConsumerWidget`/`ConsumerStatefulWidget`. Không dùng Bloc, Provider package hoặc GetX song song. Code generation của Riverpod không bắt buộc trong P0.

State nghiệp vụ authoritative vẫn ở Backend. Riverpod chỉ quản lý state phía client, cache ngắn hạn và điều phối request. Provider phải có test bằng `ProviderContainer` và dependency override.

## Phương án đã cân nhắc

- Bloc/Cubit: rõ event/state nhưng tạo nhiều boilerplate hơn nhu cầu MVP.
- Provider: đơn giản nhưng kém thuận tiện hơn cho async state và dependency override quy mô feature.
- GetX: nhiều capability trong một package nhưng làm boundary và test khó kiểm soát hơn.

## Hệ quả và rollback

M1 phải thiết lập `ProviderScope`, convention provider theo feature và lint chống gọi network trực tiếp từ widget. Nếu đổi framework, migrate từng feature qua repository/use-case interface; model/API contract không đổi.

