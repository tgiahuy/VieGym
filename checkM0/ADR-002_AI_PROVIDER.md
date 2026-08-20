# ADR-002 — AI Provider, model và SDK

- **Trạng thái:** ACCEPTED
- **Ngày áp dụng:** 2026-08-19
- **Owner:** AI Service
- **Phạm vi:** MVP P0

## Bối cảnh

AI Coach cần chi phí phù hợp đồ án, output có cấu trúc và provider được cô lập sau adapter. Model không được trở thành business authority.

## Quyết định

Dùng OpenAI làm provider mặc định, gọi `v1/responses` bằng OpenAI Python SDK chính thức. Model mặc định là alias `gpt-5.6-luna`, cấu hình bằng `AI_MODEL`; đặt reasoning effort `low`, Structured Outputs theo JSON Schema và timeout/retry hữu hạn. SDK được pin trong `uv.lock`, không để kiểu dữ liệu SDK lan ra contract nội bộ.

Spring Boot sở hữu `rules-v1`, candidate shortlist, prompt template/version và render prompt cuối cùng. FastAPI chỉ nhận request nội bộ đã render, gọi provider qua adapter và parse structured output; không tự thêm business rule. Output `BLOCKED` chỉ trả safe result và validation telemetry đã redact, không được persist thành recommendation.

Model alias được chọn vì OpenAI mô tả Luna cho workload nhạy chi phí; model hỗ trợ Responses API và Structured Outputs. Trước buổi nghiệm thu phải chạy bộ eval cố định và lưu model name cùng prompt/rule version. Nếu alias thay đổi làm eval suy giảm, pin model khả dụng đã qua eval hoặc chuyển model qua cấu hình mà không sửa business code.

Nguồn chính thức: [GPT-5.6 Luna](https://developers.openai.com/api/docs/models/gpt-5.6-luna), [Responses API](https://developers.openai.com/api/docs/guides/responses-vs-chat-completions), [Structured Outputs](https://developers.openai.com/api/docs/guides/structured-outputs).

## Phương án đã cân nhắc

- GPT-5.6 Terra: chất lượng cao hơn nhưng chi phí vượt nhu cầu mặc định của MVP.
- Gemini: giữ khả năng thêm adapter, nhưng không triển khai multi-provider P0.
- Gọi provider trực tiếp từ Spring/Mobile: loại vì phá trust boundary và làm lộ secret.

## Hệ quả và rollback

CI chỉ dùng fake provider; smoke test thật chạy thủ công với quota giới hạn. Backend vẫn validate schema, safety và domain trước Apply. Có thể đổi `AI_MODEL` hoặc bổ sung adapter mà không đổi API Mobile/Backend.
