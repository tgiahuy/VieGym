# Nguyên Tắc Phát Triển VieGym

Đây là những quy tắc cốt lõi phải được tuân thủ trong suốt quá trình phát triển ứng dụng VieGym để đảm bảo tính nhất quán, chất lượng và tuân thủ đúng yêu cầu dự án.

## 1. Nguồn Tham Chiếu Chính Thức

*   **Source of Truth:** Tài liệu `../docs/frontend/phan_ra_man_hinh.md` là nguồn sự thật (source of truth) duy nhất và chính thức cho tất cả các màn hình và chức năng giao diện.
*   **Kiểm tra trước khi làm:** Luôn kiểm tra và đối chiếu với tài liệu này trước khi bắt đầu tạo mới hoặc chỉnh sửa bất kỳ màn hình nào.
*   **Tuân thủ phạm vi:**
    *   Không tự ý thêm chức năng không được mô tả trong tài liệu.
    *   Không tự ý xóa bỏ chức năng đã được mô tả.
*   **Làm rõ yêu cầu:** Nếu một yêu cầu trong tài liệu không rõ ràng hoặc có thể gây hiểu lầm, phải đặt câu hỏi để làm rõ trước khi đưa ra bất kỳ quyết định triển khai nào.

## 2. Nguyên Tắc Thiết Kế & Trải Nghiệm Người Dùng (UX)

*   **Mobile-First:** Mọi giao diện phải được thiết kế và xây dựng ưu tiên cho trải nghiệm trên thiết bị di động trước, sau đó mới mở rộng cho các màn hình lớn hơn.
*   **Ngôn ngữ:** Ngôn ngữ chính thức trên toàn bộ giao diện người dùng là **Tiếng Việt**.
*   **Sử dụng một tay:** Thiết kế cần tối ưu cho việc sử dụng bằng một tay, đặc biệt là các hành động chính và điều hướng cốt lõi.
*   **Thiết kế cao cấp:** Hướng đến phong cách thiết kế fitness hiện đại, tối giản, và cao cấp. Tránh các chi tiết rườm rà.
*   **Tính độc nhất:** Không sao chép trực tiếp hoặc mô phỏng y hệt giao diện của bất kỳ ứng dụng nào khác. Lấy cảm hứng nhưng phải tạo ra sản phẩm độc đáo.

## 3. Nguyên Tắc Kỹ Thuật & Phát Triển

*   **Design System:** Tất cả các màn hình phải tuân thủ một Design System nhất quán (màu sắc, font chữ, khoảng cách, icon, v.v.).
*   **Tái sử dụng (Reusability):** Bất kỳ component nào có khả năng được sử dụng lại ở nhiều nơi phải được tách thành một reusable component độc lập.
*   **Tính ổn định:** Không thay đổi các màn hình đã được đánh dấu là "hoàn thiện" trong khi đang phát triển một màn hình khác, trừ khi có yêu cầu trực tiếp để sửa lỗi hoặc cập nhật.
*   **Logic > Thẩm mỹ:** Không được thay đổi business logic đã được định nghĩa chỉ để làm cho giao diện trông có vẻ đẹp hơn. Chức năng và logic nghiệp vụ luôn được ưu tiên.
*   **Mock Data:** Đối với các chức năng chưa có Backend hoặc API hoàn chỉnh, phải sử dụng mock data để phát triển giao diện và luồng người dùng.
