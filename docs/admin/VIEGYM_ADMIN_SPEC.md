# Đặc tả tổng thể VieGym Web Admin

> **Phiên bản:** 3.1 — UI implementation blueprint  
> **Cập nhật:** 03/10/2026  
> **Đối tượng sử dụng:** UI/UX, Frontend, Product, Backend, QA  
> **Actor chính:** `ADMIN`  
> **Trạng thái:** Đặc tả mục tiêu; các API trong tài liệu là contract dự kiến cho M7/M8  
> **Nguồn liên quan:** [Phân rã màn hình](../spec/phan_ra_man_hinh.md) · [Phân rã tính năng](../spec/phan_ra_tinh_nang.md) · [Tiến độ dự án](../Project_Progress.md) · [ADR-008](../../checkM0/ADR-008_ADMIN_WEB_ONLY.md)

## Mục lục

1. [Mục tiêu và phạm vi](#1-mục-tiêu-và-phạm-vi)
2. [Nguyên tắc trải nghiệm và bảo mật](#2-nguyên-tắc-trải-nghiệm-và-bảo-mật)
3. [Kiến trúc thông tin và khung giao diện](#3-kiến-trúc-thông-tin-và-khung-giao-diện)
4. [MH58 — Đăng nhập quản trị](#4-mh58--đăng-nhập-quản-trị)
5. [MH45 — Khung quản trị và điều hướng](#5-mh45--khung-quản-trị-và-điều-hướng)
6. [Dashboard thống kê](#6-dashboard-thống-kê--p1)
7. [MH46 — Quản lý bài tập](#7-mh46--quản-lý-bài-tập)
8. [MH47 — Quản lý thực phẩm](#8-mh47--quản-lý-thực-phẩm)
9. [Quản lý media dùng chung](#9-quản-lý-media-dùng-chung)
10. [MH49 — Quản lý người dùng](#10-mh49--quản-lý-người-dùng--p1)
11. [MH48 — Nhập dữ liệu hàng loạt](#11-mh48--nhập-dữ-liệu-hàng-loạt--p1)
12. [MH50 — Quản lý quy tắc và Prompt AI](#12-mh50--quản-lý-quy-tắc-và-prompt-ai--p1)
13. [MH51 — Nhật ký kiểm toán](#13-mh51--nhật-ký-kiểm-toán)
14. [API, dữ liệu và lỗi dùng chung](#14-api-dữ-liệu-và-lỗi-dùng-chung)
15. [Cấu trúc frontend đề xuất](#15-cấu-trúc-frontend-đề-xuất)
16. [Kế hoạch triển khai](#16-kế-hoạch-triển-khai)
17. [Definition of Done](#17-definition-of-done)
18. [Ma trận truy vết](#18-ma-trận-truy-vết)
19. [Quy tắc duy trì tài liệu](#19-quy-tắc-duy-trì-tài-liệu)

---

## 1. Mục tiêu và phạm vi

VieGym Web Admin là ứng dụng web riêng dành cho quản trị viên, dùng để quản lý dữ liệu nền tảng, người dùng, cấu hình AI và truy vết hoạt động hệ thống. Web Admin tách biệt hoàn toàn với ứng dụng Flutter dành cho người dùng.

Đây là **UI implementation blueprint**: người triển khai có thể dựa trực tiếp vào route, layout, kích thước, design token, component, field, state và interaction trong tài liệu để dựng giao diện. Khi một chi tiết UI không được mô tả, ưu tiên quy tắc dùng chung tại mục 2–3; không tự tạo pattern mới cho từng màn hình.

Tài liệu này là nguồn đặc tả duy nhất cho toàn bộ các màn hình Admin:

| Mã | Module | Route | Ưu tiên |
|---|---|---|---|
| MH58 | Đăng nhập quản trị | `/login` | P0 |
| MH45 | Khung quản trị và điều hướng | `/` | P0 |
| FT-AD-001 | Dashboard thống kê | `/dashboard` | P1 |
| MH46 | Quản lý bài tập | `/exercises` | P0 |
| MH47 | Quản lý thực phẩm | `/foods` | P0 |
| Shared | Quản lý media | Dùng trong Exercise/Food | P0 |
| MH49 | Quản lý người dùng | `/users` | P1 |
| MH48 | Nhập dữ liệu hàng loạt | `/imports` | P1 |
| MH50 | Quy tắc và Prompt AI | `/ai-config` | P1 |
| MH51 | Nhật ký kiểm toán | `/audit-logs` | P0 |

### 1.1. Phân kỳ triển khai

- **P0 — Bắt buộc cho MVP:** đăng nhập, khung quản trị, quản lý bài tập, quản lý thực phẩm, upload media và nhật ký kiểm toán.
- **P1 — Mở rộng:** dashboard, quản lý người dùng, import dữ liệu, quản lý quy tắc/prompt AI và chỉ số AI.
- Chức năng P1 chưa sẵn sàng phải được ẩn hoặc gắn nhãn “Sắp ra mắt”; không tạo menu dẫn tới trang trống.

### 1.2. Ngoài phạm vi

- Admin đăng nhập hoặc thao tác quản trị trên Mobile App.
- Admin tự đăng ký, đăng nhập Google/Facebook hoặc tự nâng quyền.
- Xem mật khẩu, token, OTP, API key, dữ liệu sức khỏe hoặc hội thoại AI riêng tư không cần thiết.
- Sửa hoặc xóa Audit Log từ giao diện.
- Xóa cứng dữ liệu đang được tham chiếu trong lịch sử người dùng.

---

## 2. Nguyên tắc trải nghiệm và bảo mật

### 2.1. Nguyên tắc giao diện

1. Giao diện tiếng Việt, thuật ngữ nhất quán và ưu tiên thao tác nhanh trên desktop.
2. Mỗi trang danh sách có tiêu đề, mô tả ngắn, tìm kiếm, bộ lọc, tổng số bản ghi, bảng dữ liệu và phân trang.
3. Thao tác chính nằm bên phải tiêu đề; thao tác nguy hiểm luôn yêu cầu xác nhận và mô tả hậu quả.
4. Lỗi validation hiển thị sát trường dữ liệu; lỗi hệ thống có thông báo dễ hiểu và nút thử lại.
5. Form đang sửa phải cảnh báo khi người dùng đóng, chuyển trang hoặc tải lại mà chưa lưu.
6. Bảng hỗ trợ kích thước trang 10/20/50; filter và page được phản ánh trên URL để có thể tải lại/chia sẻ trạng thái.
7. Thời gian hiển thị theo múi giờ Việt Nam (`Asia/Ho_Chi_Minh`) và định dạng `dd/MM/yyyy HH:mm:ss`.
8. Trạng thái không chỉ phân biệt bằng màu; luôn có nhãn hoặc biểu tượng kèm mô tả.

### 2.2. Trạng thái chuẩn của mọi màn hình

| Trạng thái | Yêu cầu hiển thị |
|---|---|
| Loading | Skeleton đúng cấu trúc nội dung, không làm nhảy layout |
| Empty | Giải thích chưa có dữ liệu và CTA phù hợp |
| No result | Thông báo không tìm thấy và nút xóa bộ lọc |
| Error | Thông báo dễ hiểu, mã tham chiếu nếu có và nút thử lại |
| Saving | Khóa nút submit, hiển thị tiến trình, chống gửi lặp |
| Success | Toast xác nhận và cập nhật dữ liệu trên màn hình |
| Conflict | Báo dữ liệu đã thay đổi ở nơi khác; cho tải lại trước khi ghi đè |
| Forbidden | Trang 403 rõ ràng, không giả vờ redirect sang trang hợp lệ |
| Session expired | Xóa state nhạy cảm và chuyển về trang đăng nhập |

### 2.3. Bảo mật bắt buộc

1. Web Admin chỉ chấp nhận tài khoản `ADMIN` và session có audience `ADMIN_WEB`.
2. Session lưu trong cookie `HttpOnly`, `Secure`, `SameSite=Strict`; không lưu access/refresh token trong `localStorage` hoặc `sessionStorage`.
3. Mọi request thay đổi dữ liệu (`POST`, `PUT`, `PATCH`, `DELETE`) phải gửi `X-CSRF-TOKEN`.
4. Backend là nơi quyết định authorization; ẩn nút ở UI không thay thế kiểm tra quyền.
5. Thông báo đăng nhập sai không được tiết lộ email có tồn tại hay vai trò của tài khoản.
6. Rate limit áp dụng cho đăng nhập và các thao tác nhạy cảm.
7. Audit phải loại bỏ password, token, OTP, API key, presigned URL, system prompt và raw personal context.
8. CSV/Excel, media, prompt và mọi nội dung nhập vào đều là dữ liệu không tin cậy, phải kiểm tra ở cả client và server.

---

## 3. Kiến trúc thông tin và khung giao diện

```text
┌──────────────────────────────────────────────────────────────────────┐
│ Header: Breadcrumbs            Trạng thái hệ thống     Admin ▾      │
├──────────────────┬───────────────────────────────────────────────────┤
│ VIEGYM ADMIN     │                                                   │
│                  │  Tiêu đề trang                      [CTA chính]  │
│ Tổng quan        │  Mô tả ngắn                                       │
│ • Dashboard      │                                                   │
│                  │  Bộ lọc / tìm kiếm                               │
│ Dữ liệu          │  ┌─────────────────────────────────────────────┐  │
│ • Bài tập        │  │ Nội dung, bảng, form hoặc biểu đồ          │  │
│ • Thực phẩm      │  └─────────────────────────────────────────────┘  │
│ • Nhập dữ liệu   │                                                   │
│                  │                                                   │
│ Vận hành         │                                                   │
│ • Người dùng     │                                                   │
│ • Quy tắc & AI   │                                                   │
│ • Nhật ký        │                                                   │
│                  │                                                   │
│ admin@viegym.com │                                                   │
│ [Đăng xuất]      │                                                   │
└──────────────────┴───────────────────────────────────────────────────┘
```

### 3.1. Sidebar

- Logo, tên hệ thống và phiên bản.
- Nhóm menu: Tổng quan, Dữ liệu, Vận hành.
- Highlight route hiện tại; hỗ trợ thu gọn trên tablet.
- Hiển thị email, role badge và nút đăng xuất ở cuối sidebar.
- Các mục P1 chưa phát hành được ẩn hoặc vô hiệu hóa kèm tooltip “Sắp ra mắt”.

### 3.2. Header

- Breadcrumb động theo route và ngữ cảnh create/edit/detail.
- Trạng thái Backend và AI Service: Online, Degraded hoặc Offline.
- Menu tài khoản: thông tin Admin và đăng xuất.
- Không hiển thị dữ liệu hệ thống nhạy cảm trong health indicator.

### 3.3. Responsive và accessibility

- Desktop là mục tiêu chính; tablet dùng sidebar thu gọn; mobile hiển thị drawer navigation.
- Tất cả thao tác dùng được bằng bàn phím, focus rõ ràng và có accessible label.
- Modal/drawer phải khóa focus, hỗ trợ `Esc` và trả focus về nút mở khi đóng.
- Màu chữ/nền đạt WCAG AA; bảng rộng cho phép scroll ngang mà không che cột thao tác.

### 3.4. Viewport, grid và kích thước cố định

| Chế độ | Breakpoint | Sidebar | Content padding | Hành vi chính |
|---|---:|---:|---:|---|
| Desktop rộng | `≥ 1440px` | 256px | 32px | Hiện đầy đủ label menu; form 2 cột khi phù hợp |
| Desktop | `1280–1439px` | 240px | 24px | Layout chuẩn; bảng ưu tiên giữ cột chính |
| Tablet | `768–1279px` | 72px | 20px | Sidebar chỉ icon + tooltip; filter có thể xuống dòng |
| Mobile web | `< 768px` | Drawer overlay | 16px | Card/list thay bảng nếu bảng không thể đọc được |

Thông số layout bắt buộc:

- Header cao `64px`, sticky ở trên; mobile cao `56px`.
- Sidebar cố định toàn chiều cao, có border phải `1px`; không che content.
- Main content rộng tối đa `1600px`, căn giữa trong phần còn lại; dashboard dùng grid 12 cột, gap `20px`.
- Khoảng cách dọc giữa page header, filter, summary và table là `20–24px`.
- Drawer tạo/sửa rộng `640px`; màn hình dưới `768px` dùng full width.
- Modal form tiêu chuẩn rộng `560px`; modal detail/diff rộng `760px`; confirm dialog rộng `440px`.
- Table header cao `44px`, row mặc định `56px`; row có thumbnail cao `64px`.
- Input/select/button cao `44px`; icon button tối thiểu `40px` nhưng vùng tương tác không nhỏ hơn `44px`.
- Sticky action footer trong drawer/modal cao tối thiểu `72px`, nền riêng và border trên để CTA luôn nhìn thấy.

### 3.5. Design tokens chuẩn

Web Admin dùng **dark-first theme** để đồng nhất VieGym Mobile. P0 không phụ thuộc Light Mode. Tất cả màu phải đi qua CSS variables/Tailwind theme, không viết hex rải rác trong component.

```css
:root {
  --bg-canvas: #0f1012;
  --bg-deep: #0b0c0e;
  --bg-secondary: #131417;
  --surface: #17181b;
  --surface-elevated: #1c1d21;
  --surface-strong: #222327;
  --border-default: #292a2f;
  --border-strong: #34363b;

  --text-primary: #f5f5f6;
  --text-secondary: #a7a9ae;
  --text-muted: #8a8d93;

  --brand: #f2305a;
  --brand-hover: #d52b50;
  --brand-pressed: #c32649;
  --success: #35c76f;
  --warning: #f4b740;
  --info: #4d8dff;
  --error: #ff5a5f;
  --ai: #9b7bff;
  --nutrition-protein: #2cc7b5;
  --nutrition-carbs: #35c76f;
  --nutrition-fat: #4d8dff;
  --nutrition-calories: #f28c38;
}
```

Quy tắc màu:

- `brand` chỉ dành cho CTA chính, focus ring, menu active và dữ liệu thương hiệu; không dùng như màu lỗi.
- Success/Warning/Error luôn đi kèm icon và text, không truyền nghĩa chỉ bằng màu.
- Card dùng `surface`; dropdown/dialog dùng `surface-elevated`; input dùng `surface-strong`.
- Border mặc định `1px`; focus ring `2px brand` với offset `2px` trên nền tối.
- Overlay modal dùng `rgba(0,0,0,.64)`; shadow chỉ dùng cho overlay/elevated surface, không phủ dày mọi card.

### 3.6. Typography, radius và spacing

- Font: `Inter`, fallback `ui-sans-serif, system-ui, -apple-system, "Segoe UI", sans-serif`.
- Page title: `28/36`, weight `700`; mobile `24/32`.
- Section title: `20/28`, weight `700`.
- Card metric: `28/34`, weight `700`, dùng tabular numbers.
- Body: `14/22`, weight `400`; body emphasis `14/22`, weight `600`.
- Label/table header: `12/18`, weight `600`, không viết hoa toàn bộ đoạn dài.
- Helper/error: `12/18`; button: `14/20`, weight `600`.
- Spacing dùng thang `4, 8, 12, 16, 20, 24, 32, 40, 48` px.
- Radius: badge `8px`, button `12px`, input `14px`, dialog `16px`, card `18px`, panel lớn `20px`, pill `999px`.
- Icon dùng Lucide, nét `1.75–2px`; size `16px` trong input, `18px` trong button, `20px` trong menu.

### 3.7. Component contract dùng chung

| Component | Cấu trúc và hành vi bắt buộc |
|---|---|
| `PageHeader` | Breadcrumb → title + description; CTA chính nằm bên phải, xuống hàng ở mobile |
| `SearchInput` | Icon search, clear button, debounce 300ms, rộng 280–360px desktop |
| `FilterBar` | Search bên trái, select/chip kế tiếp, “Xóa bộ lọc” chỉ hiện khi có filter; mobile mở filter sheet |
| `DataTable` | Header sticky trong vùng scroll; sort icon; loading skeleton; cột action sticky bên phải khi cần |
| `StatusBadge` | Icon/chấm + label; Active xanh, Hidden/Warning vàng, Locked/Error đỏ, Draft xám, AI tím |
| `Pagination` | Tổng bản ghi, page size, previous/next, page hiện tại; về page 1 khi filter đổi |
| `FormField` | Label cố định, dấu `*`, control, helper/error; `aria-describedby` nối đúng thông báo |
| `Button` | Primary, Secondary, Ghost, Destructive; không có hơn một Primary CTA trong một vùng |
| `ConfirmDialog` | Tên đối tượng, hậu quả, Cancel focus mặc định; destructive action dùng màu error |
| `Toast` | Góc phải trên desktop, dưới trên mobile; success tự đóng 4 giây, error không tự đóng quá nhanh |
| `EmptyState` | Icon/illustration nhỏ, title, một câu hướng dẫn và tối đa một CTA |
| `ErrorState` | Thông điệp thân thiện + correlation ID có thể copy + Retry nếu an toàn |
| `Skeleton` | Khớp kích thước nội dung thật; không dùng spinner toàn trang sau lần bootstrap đầu |
| `Drawer/Modal` | Focus trap, `Esc`, close button, unsaved-change guard, action footer sticky |
| `OverflowMenu` | Dùng cho thao tác phụ; action nguy hiểm đặt cuối và ngăn bằng divider |

### 3.8. Template trang danh sách

Mọi trang quản lý dữ liệu dùng cùng thứ tự khối:

```text
Breadcrumb
Title + mô tả                                      [Primary CTA]

[Search________________] [Filter 1] [Filter 2] [Filter 3] [Xóa lọc]
Tổng N bản ghi · Active A · Hidden H                 [Tùy chọn hiển thị]
┌────────────────────────────────────────────────────────────────────┐
│ Table header                                                       │
├────────────────────────────────────────────────────────────────────┤
│ Row                                                               │
│ Row                                                               │
└────────────────────────────────────────────────────────────────────┘
Hiển thị 1–20/N                         [20 / trang] [‹] 1/8 [›]
```

URL là nguồn state cho `q`, filter, sort, page và size. Khi quay lại từ edit/detail, phải khôi phục đúng filter, page và vị trí scroll.

### 3.9. Quy tắc responsive theo loại nội dung

| Nội dung | Desktop | Tablet | Mobile web |
|---|---|---|---|
| Page header | Title và CTA cùng hàng | Có thể cùng hàng | CTA full width dưới title |
| Filter | Inline, wrap khi cần | Search full row + filters | Search + nút “Bộ lọc (N)”; filter trong bottom sheet |
| Data table | Đủ cột | Ẩn cột phụ theo ưu tiên | Card list hoặc table scroll; không ép chữ quá hẹp |
| Drawer create/edit | 640px bên phải | 70–80vw | Full-screen |
| Detail drawer | 520–760px | 80vw | Full-screen |
| Form grid | 2–4 cột tùy nhóm | 2 cột | 1 cột, riêng macro có thể 2 cột |
| Dashboard | 12-column grid | 2 card/row | 1 card/row |

Breakpoint không được làm mất chức năng. Cột bị ẩn phải xuất hiện trong row detail/drawer. Sticky cột action chỉ áp dụng khi không che nội dung chính.

---

## 4. MH58 — Đăng nhập quản trị

### 4.1. Mục tiêu

Cổng xác thực duy nhất dành cho Admin. Nếu session còn hiệu lực, người dùng được chuyển thẳng đến trang mặc định; nếu không hợp lệ, hiển thị form đăng nhập.

### 4.2. Bố cục UI

```text
Desktop ≥ 1024px
┌────────────────────────────────────────────────────────────────────┐
│                                                                    │
│  Brand panel 44%                  Login panel 56%                  │
│  ┌──────────────────────┐        ┌──────────────────────────────┐ │
│  │ VieGym Admin         │        │ Đăng nhập quản trị          │ │
│  │ Vận hành khỏe hơn.   │        │ Truy cập hệ thống quản lý   │ │
│  │ Dữ liệu chính xác.   │        │                              │ │
│  │                      │        │ Email quản trị              │ │
│  │ [Brand graphic]      │        │ [________________________]  │ │
│  │                      │        │ Mật khẩu                    │ │
│  │ v1.0 · Secure Admin  │        │ [____________________] [👁] │ │
│  └──────────────────────┘        │ [Đăng nhập hệ thống       ] │ │
│                                  │ [Vùng lỗi chung]             │ │
│                                  └──────────────────────────────┘ │
└────────────────────────────────────────────────────────────────────┘
```

- Toàn màn hình, nền `bg-canvas`; card đăng nhập rộng `420px`, padding `32px`.
- Brand panel chỉ hiện từ `1024px`; dùng gradient rất nhẹ từ `bg-deep` tới `surface`, không dùng ảnh người tập gây nhiễu.
- Dưới `1024px`, card căn giữa; dưới `480px`, bỏ shadow/card border và dùng padding trang `20px`.
- Logo cao `36px`; khoảng cách từ title đến form `28px`; giữa các field `18px`.
- Nút submit full width, cao `48px`; lỗi chung nằm ngay trên nút để không làm dịch chuyển title.
- Autofocus email chỉ trên desktop. Enter submit khi form hợp lệ; icon mắt có accessible label “Hiện/Ẩn mật khẩu”.

**Thành phần bắt buộc**

- Logo VieGym Admin và phiên bản.
- Email quản trị: bắt buộc, đúng định dạng email.
- Mật khẩu: bắt buộc, hỗ trợ ẩn/hiện.
- Nút “Đăng nhập hệ thống”, loading và disabled state.
- Khu vực thông báo lỗi chung; không có đăng ký hoặc social login.

### 4.3. Luồng và tương tác

1. Tải CSRF token và kiểm tra session hiện tại.
2. Validate email/mật khẩu ở client.
3. Gửi request đăng nhập cùng CSRF token.
4. Thành công: backend set cookie, UI tải thông tin Admin và chuyển đến route hợp lệ gần nhất hoặc Dashboard/Exercises.
5. Thất bại: xử lý riêng 401, 403, 429 và lỗi mạng nhưng không tiết lộ account enumeration.

### 4.4. API dự kiến

| Method | Endpoint | Mục đích |
|---|---|---|
| `GET` | `/api/v1/admin/auth/csrf` | Lấy CSRF token |
| `POST` | `/api/v1/admin/auth/login` | Đăng nhập và tạo cookie session |
| `GET` | `/api/v1/admin/auth/session` | Bootstrap/kiểm tra session |
| `POST` | `/api/v1/admin/auth/refresh` | Rotation và gia hạn session |
| `POST` | `/api/v1/admin/auth/logout` | Thu hồi session và xóa cookie |

### 4.5. Tiêu chí nghiệm thu

- [ ] USER và session sai audience không thể vào Web Admin.
- [ ] Không có token trong response body hoặc Web Storage.
- [ ] Có validation inline, loading, lỗi credential, locked, rate limit và network retry.
- [ ] Đăng nhập thành công chuyển đúng trang; logout/expired session quay về `/login`.

---

## 5. MH45 — Khung quản trị và điều hướng

### 5.1. Chức năng

- Bootstrap session trước khi render nội dung bảo vệ.
- Route guard cho toàn bộ route Admin.
- Sidebar, header, breadcrumb, profile và vùng nội dung chung.
- Điều hướng không reload toàn trang.
- Logout có xác nhận, thu hồi session, xóa cache nhạy cảm và redirect về `/login`.
- Trang 403, 404 và trang lỗi hệ thống thống nhất.

### 5.2. Bố cục shell chính xác

```text
┌──────── Sidebar 256 ────────┬──────── Header 64, sticky ──────────────┐
│ Logo + tên                  │ Breadcrumbs          Health   Admin ▾  │
│                             ├──────────────────────────────────────────┤
│ TỔNG QUAN                   │                                          │
│ ▌ Dashboard                 │ Main content                             │
│                             │ max-width 1600, padding 24/32             │
│ DỮ LIỆU                     │                                          │
│   Bài tập                   │ PageHeader                               │
│   Thực phẩm                 │ Filters / content / pagination           │
│   Nhập dữ liệu              │                                          │
│                             │                                          │
│ VẬN HÀNH                    │                                          │
│   Người dùng                │                                          │
│   Quy tắc & AI              │                                          │
│   Nhật ký                   │                                          │
│                             │                                          │
│ Admin identity + Logout     │                                          │
└─────────────────────────────┴──────────────────────────────────────────┘
```

- Logo area cao `64px`; menu item cao `44px`, padding ngang `12px`, gap icon-label `12px`.
- Menu active có nền brand soft, chữ primary và vạch trái brand `3px`; hover dùng `surface-strong`.
- Section label cách nhóm trước `24px`, font `11px/16`, weight 600, text muted.
- Header có border dưới, breadcrumbs truncate từ giữa, health indicator không chiếm quá `160px`.
- Trên tablet sidebar 72px: logo icon, menu icon + tooltip; section label chuyển thành divider.
- Trên mobile: header có hamburger; sidebar là drawer rộng `280px`; đóng sau khi chọn route.
- Content không được render chớp trước khi session bootstrap hoàn tất; dùng shell skeleton tương ứng.

### 5.3. Quy tắc route

| Tình huống | Kết quả |
|---|---|
| Chưa đăng nhập | Chuyển tới `/login`, lưu route đích an toàn |
| Session hợp lệ, role ADMIN | Render shell và route con |
| Role/audience không hợp lệ | Hiển thị 403 và không tải dữ liệu Admin |
| Session hết hạn | Clear client state, chuyển `/login` |
| Route không tồn tại | Hiển thị 404 trong shell nếu đã đăng nhập |

### 5.4. Tiêu chí nghiệm thu

- [ ] Menu active, breadcrumb và tiêu đề trang đồng bộ với URL.
- [ ] Refresh trực tiếp ở route con vẫn bootstrap đúng session.
- [ ] Logout xóa session phía server và client.
- [ ] Sidebar responsive, keyboard accessible và không có dead-end P1.

---

## 6. Dashboard thống kê — P1

### 6.1. Mục tiêu

Cho Admin nhìn nhanh tình trạng vận hành mà không cần mở từng module.

### 6.2. Bộ lọc và chỉ số

- Khoảng thời gian: 7 ngày, 30 ngày, 90 ngày hoặc tùy chỉnh.
- Cards: tổng user, user active, bài tập active/hidden, thực phẩm active/hidden, lượt AI, tỷ lệ AI được áp dụng.
- Biểu đồ: user hoạt động theo ngày, buổi tập hoàn thành, lượt theo dõi dinh dưỡng, recommendation created/applied/dismissed.
- Cảnh báo dữ liệu: bài tập thiếu media, thực phẩm thiếu macro, import lỗi gần đây, dịch vụ đang degraded.
- Mỗi card có link drill-down tới module tương ứng khi được phép.

### 6.3. Bố cục UI

```text
Dashboard                                      [7 ngày ▾] [Tùy chỉnh]
Tổng quan hoạt động hệ thống                    Cập nhật 10:30

┌── Users ──┐ ┌─ Exercises ┐ ┌── Foods ──┐ ┌── AI usage ─┐
│  12,430   │ │    486     │ │   1,248   │ │   8,920     │
│ +8.4%     │ │ 462 active │ │ 18 thiếu  │ │ 64% applied │
└───────────┘ └─────────────┘ └───────────┘ └─────────────┘

┌──────────── Hoạt động theo ngày (8 cols) ─────┐ ┌─ Cảnh báo (4) ─┐
│ Line/bar chart, legend, tooltip                │ │ 18 foods thiếu  │
│                                               │ │  7 media lỗi    │
└───────────────────────────────────────────────┘ └─────────────────┘

┌──── Tỷ lệ hoàn thành (6 cols) ────┐ ┌──── AI outcome (6 cols) ────┐
└────────────────────────────────────┘ └───────────────────────────────┘
```

- Card grid: 4 cột desktop, 2 cột tablet, 1 cột mobile; card cao tối thiểu `132px`.
- Metric card gồm label, value, comparison, context và icon; toàn card chỉ clickable khi có drill-down.
- Chart card cao `360px`, padding `20px`; legend trên, tooltip theo theme, trục không quá dày.
- Giá trị rỗng hiển thị `—`, không hiển thị `0` nếu backend trả `null`.
- Bộ lọc ngày ở page header; thay đổi range refresh đồng bộ toàn dashboard.

### 6.4. Quy tắc

- Dùng aggregate API; UI không tải toàn bộ danh sách để tự tính.
- Không hiển thị PII hoặc nội dung hội thoại/prompt cá nhân.
- Hiển thị thời điểm cập nhật gần nhất và trạng thái stale/error.

### 6.5. API dự kiến

`GET /api/v1/admin/dashboard?from={iso}&to={iso}`

### 6.6. Tiêu chí nghiệm thu

- [ ] Card và biểu đồ thay đổi đúng theo khoảng thời gian.
- [ ] Có loading, no-data, partial error và retry theo từng widget.
- [ ] Số liệu aggregate khớp dữ liệu backend và không lộ PII.

---

## 7. MH46 — Quản lý bài tập

### 7.1. Bố cục UI

```text
Bài tập                                                   [+ Thêm bài tập]
Quản lý kho bài tập dùng trong lịch tập và AI

[🔍 Tìm tên VN/EN____________] [Nhóm cơ ▾] [Thiết bị ▾] [Cấp độ ▾] [Trạng thái ▾]
Tổng 486 · Active 462 · Hidden 24                              [Xóa bộ lọc]
┌──────┬──────────────────────┬──────────┬──────────┬──────┬──────────┬─────┐
│ Ảnh  │ Tên VN / EN         │ Nhóm cơ  │ Thiết bị │ Cấp │ Trạng thái│  ⋯  │
├──────┼──────────────────────┼──────────┼──────────┼──────┼──────────┼─────┤
│ 48px │ Đẩy ngực tạ đòn     │ Ngực     │ Barbell  │ TB   │ ● Active │  ⋯  │
│      │ Bench Press          │ +2 phụ   │          │      │          │     │
└──────┴──────────────────────┴──────────┴──────────┴──────┴──────────┴─────┘
1–20/486                                         [20/trang] [‹] 1/25 [›]
```

- CTA mở drawer `640px`; edit dùng cùng drawer và prefill từ detail API.
- Tên VN là dòng chính; tên EN là dòng phụ text secondary. Thumbnail `48×48`, radius `8px`, `object-fit: cover`.
- Tên và trạng thái luôn giữ trên tablet; nhóm cơ/thiết bị/cấp độ có thể ẩn lần lượt và xuất hiện trong row detail.
- Action chính “Sửa” có thể là icon button; các action Nhân bản/Ẩn/Xóa nằm trong overflow menu.
- Drawer header hiển thị mode + tên đối tượng; tabs sticky dưới header; footer có “Hủy” và “Lưu bài tập”.
- Nếu tab khác có lỗi, tab hiển thị error dot và submit tự focus field lỗi đầu tiên.

### 7.2. Danh sách và tìm kiếm

- Tìm theo tên tiếng Việt hoặc tiếng Anh, debounce 300 ms.
- Lọc theo nhóm cơ chính, thiết bị, cấp độ và trạng thái Active/Hidden.
- Sắp xếp theo tên, ngày tạo, ngày cập nhật và trạng thái.
- Cột: thumbnail, tên VN/EN, nhóm cơ, thiết bị, độ khó, trạng thái, ngày cập nhật, thao tác.
- Thao tác: xem, sửa, nhân bản, ẩn/hiện và xóa mềm.
- Hỗ trợ server-side pagination 10/20/50 và lưu filter trên URL.

### 7.3. Form tạo/sửa

**Tab Thông tin cơ bản**

| Trường | Bắt buộc | Quy tắc |
|---|---:|---|
| Tên tiếng Việt | Có | Tối đa 200 ký tự, không chỉ chứa khoảng trắng |
| Tên tiếng Anh | Có | Tối đa 200 ký tự |
| Nhóm cơ chính | Có | Một giá trị từ danh mục backend |
| Nhóm cơ phụ | Không | Nhiều giá trị, không trùng nhóm cơ chính |
| Thiết bị | Có | Một hoặc nhiều thiết bị theo contract |
| Cấp độ | Có | Beginner/Intermediate/Advanced |
| Mô tả | Không | Tối đa 2.000 ký tự |

**Tab Hướng dẫn và an toàn**

- Danh sách bước thực hiện có thể thêm, xóa và kéo thả sắp xếp.
- Lỗi sai thường gặp kèm cách khắc phục.
- Lưu ý an toàn, chống chỉ định và biến thể dễ/khó hơn.
- Preview nội dung như người dùng cuối sẽ nhìn thấy.

**Tab Media**

- Nhiều ảnh và tối đa một video theo giới hạn backend.
- Chọn ảnh đại diện, sắp xếp thứ tự, xem trước, thay thế và xóa.
- Chỉ được publish media đã upload và verify thành công.

### 7.4. Quy tắc nghiệp vụ

1. Bài tập Hidden không xuất hiện trong lựa chọn mới hoặc lịch tập mới.
2. Bài tập đã có trong Workout Log/Program cũ phải giữ snapshot và lịch sử.
3. Khi chương trình cũ tham chiếu bài tập Hidden, hiển thị cảnh báo và gợi ý bài thay thế; không tự ý sửa lịch sử.
4. Ưu tiên xóa mềm. Chỉ xóa cứng khi backend xác nhận không có tham chiếu và chính sách cho phép.
5. Create, update, hide, show, delete và media change đều ghi Audit Log.
6. Dùng optimistic locking/version để phát hiện chỉnh sửa đồng thời.

### 7.5. API dự kiến

| Method | Endpoint | Mục đích |
|---|---|---|
| `GET` | `/api/v1/admin/exercises` | Danh sách, search, filter, sort, page |
| `GET` | `/api/v1/admin/exercises/{id}` | Chi tiết |
| `POST` | `/api/v1/admin/exercises` | Tạo mới |
| `PUT` | `/api/v1/admin/exercises/{id}` | Cập nhật |
| `PATCH` | `/api/v1/admin/exercises/{id}/visibility` | Ẩn/hiện |
| `DELETE` | `/api/v1/admin/exercises/{id}` | Xóa mềm |

### 7.6. Tiêu chí nghiệm thu

- [ ] Search, filter, sort và phân trang kết hợp đúng.
- [ ] Form create/edit validate đầy đủ và giữ dữ liệu khi API lỗi.
- [ ] Có preview, unsaved-change guard và conflict handling.
- [ ] Ẩn/xóa có confirm nêu rõ tác động tới dữ liệu người dùng.
- [ ] Sau mutation, bảng và thống kê được cập nhật, có toast và Audit Log.

---

## 8. MH47 — Quản lý thực phẩm

### 8.1. Bố cục UI

```text
Thực phẩm                                               [+ Thêm thực phẩm]
Quản lý dữ liệu khẩu phần và giá trị dinh dưỡng

[🔍 Tìm tên____________] [Nhóm ▾] [Nguồn ▾] [Dữ liệu ▾] [Trạng thái ▾]
Tổng 1,248 · Active 1,212 · Cần bổ sung 18                 [Xóa bộ lọc]
┌───────────────┬──────────┬──────┬───────┬───────┬──────┬──────────┬─────┐
│ Thực phẩm     │ Khẩu phần│ kcal │Protein│ Carbs │ Fat  │Trạng thái│  ⋯  │
├───────────────┼──────────┼──────┼───────┼───────┼──────┼──────────┼─────┤
│ [img] Ức gà  │ 100 g    │ 165  │ 31 g  │ 0 g   │3.6 g │ ● Active │  ⋯  │
└───────────────┴──────────┴──────┴───────┴───────┴──────┴──────────┴─────┘
```

- Calories dùng accent cam; Protein cyan; Carbs xanh; Fat xanh dương. Màu chỉ là hỗ trợ, nhãn/cột vẫn bắt buộc.
- Form create/edit dùng modal `720px` trên desktop vì dữ liệu dinh dưỡng cần bố cục 2 cột; mobile full-screen.
- Form chia bốn section: Nhận diện, Khẩu phần, Dinh dưỡng, Nguồn & Media.
- Nhóm bốn macro hiển thị grid 4 cột ở desktop, 2 cột tablet/mobile; mỗi field có suffix đơn vị cố định.
- Preview bên dưới macro: “Theo khẩu phần X: Y kcal · P/C/F”; cập nhật tức thời nhưng gắn nhãn “Xem trước”.
- Row thiếu dữ liệu có icon warning cạnh tên và tooltip liệt kê trường thiếu; không tô vàng cả hàng gây giảm khả năng đọc.

### 8.2. Danh sách và tìm kiếm

- Tìm theo tên món/thực phẩm và tên thay thế.
- Lọc theo nhóm thực phẩm, nguồn dữ liệu, mức độ đầy đủ dinh dưỡng và trạng thái.
- Cột: ảnh, tên, khẩu phần chuẩn, kcal, protein, carbs, fat, nguồn, trạng thái và thao tác.
- Dòng thiếu hoặc bất thường về dinh dưỡng có cảnh báo rõ ràng.
- Thao tác: xem, sửa, nhân bản, ẩn/hiện và xóa mềm.

### 8.3. Form tạo/sửa

| Nhóm | Trường chính | Quy tắc |
|---|---|---|
| Nhận diện | Tên, tên thay thế, nhóm thực phẩm | Tên bắt buộc, tối đa 200 ký tự |
| Khẩu phần | Khối lượng gram, tên đơn vị | Gram > 0; đơn vị tối đa 50 ký tự |
| Dinh dưỡng | Kcal, protein, carbs, fat, fiber | Không âm; lưu rõ cơ sở trên mỗi khẩu phần |
| Nguồn | USDA/Viện DD/Custom, URL/ghi chú | Dữ liệu ước lượng phải có nguồn hoặc ghi chú |
| Media | Một ảnh minh họa | JPG/PNG/WebP, tối đa 5 MB |
| Trạng thái | Active/Hidden | Hidden không dùng cho entry mới |

UI hiển thị preview quy đổi dinh dưỡng theo khẩu phần để giúp Admin kiểm tra, nhưng backend vẫn là nguồn tính toán và validation cuối cùng.

### 8.4. Quy tắc nghiệp vụ

1. Giá trị dinh dưỡng và serving không được âm; serving weight phải lớn hơn 0.
2. Thực phẩm Hidden không xuất hiện trong tìm kiếm/entry mới nhưng lịch sử bữa ăn vẫn giữ snapshot.
3. Không coi giá trị `0` là thiếu nếu đó là dữ liệu hợp lệ; cần phân biệt `null`, `unknown` và `0`.
4. Món Việt được ưu tiên về dữ liệu và đơn vị, nhưng hệ thống không hard-code theo một persona.
5. Hide/delete và mọi thay đổi dinh dưỡng phải có Audit Log.

### 8.5. API dự kiến

| Method | Endpoint | Mục đích |
|---|---|---|
| `GET` | `/api/v1/admin/foods` | Danh sách, search, filter, sort, page |
| `GET` | `/api/v1/admin/foods/{id}` | Chi tiết |
| `POST` | `/api/v1/admin/foods` | Tạo mới |
| `PUT` | `/api/v1/admin/foods/{id}` | Cập nhật |
| `PATCH` | `/api/v1/admin/foods/{id}/visibility` | Ẩn/hiện |
| `DELETE` | `/api/v1/admin/foods/{id}` | Xóa mềm |

### 8.6. Tiêu chí nghiệm thu

- [ ] Bảng hiển thị đúng khẩu phần và bốn macro chính.
- [ ] Search/filter/sort/page hoạt động kết hợp.
- [ ] Form phân biệt dữ liệu thiếu với giá trị 0 hợp lệ.
- [ ] Có cảnh báo dữ liệu thiếu, preview khẩu phần và nguồn tham khảo.
- [ ] Ẩn/xóa giữ nguyên lịch sử Meal Log và ghi Audit Log.

---

## 9. Quản lý media dùng chung

### 9.1. Bố cục component

```text
Media                                                   2/5 tệp
┌──────────────────────────────────────────────────────────────┐
│                 ↑ Kéo thả ảnh hoặc video                    │
│          hoặc [Chọn tệp] · JPG/PNG/WebP/MP4                 │
│                 Ảnh 5 MB · Video 50 MB                      │
└──────────────────────────────────────────────────────────────┘

┌────────┐  bench-press.jpg                 1.8 MB    [⋯]
│ preview│  ███████████████████████ 100%    ✓ Hoàn tất
└────────┘  [Ảnh đại diện]
```

- Dropzone cao tối thiểu `148px`, border dashed; drag-over đổi border brand và nền brand soft.
- Mỗi file là một row cao tối thiểu `72px`, có preview `56×56`, tên ellipsis, size, progress/status và menu.
- Khi nhiều file, hỗ trợ kéo thả sắp xếp với drag handle riêng; không biến toàn row thành drag target.
- Lỗi hiển thị ngay trong row, không làm mất file khác; Retry giữ nguyên metadata file.
- Nút xóa media đã liên kết phải mở confirm; media mới chưa lưu có thể remove trực tiếp khỏi draft.

### 9.2. Chức năng

- Kéo thả hoặc chọn file; hỗ trợ nhiều file cho bài tập và một ảnh cho thực phẩm.
- Validate MIME thực tế, extension, kích thước và số lượng trước khi upload.
- Hiển thị progress từng file; cho hủy, retry, thay thế và xóa.
- Preview ảnh; video có thumbnail và controls, không autoplay âm thanh.
- Chọn ảnh đại diện và sắp xếp thứ tự media của bài tập.

### 9.3. Giới hạn mặc định

| Loại | MIME | Kích thước tối đa | Số lượng mặc định |
|---|---|---:|---:|
| Ảnh | JPEG, PNG, WebP | 5 MB/file | Exercise: 5; Food: 1 |
| Video | MP4 | 50 MB/file | Exercise: 1; Food: 0 |

Giới hạn thực tế phải lấy từ cấu hình backend để UI và server không lệch nhau.

### 9.4. Luồng upload

1. Client kiểm tra file.
2. Gọi init-upload để nhận `uploadId` và presigned URL ngắn hạn.
3. Upload trực tiếp tới object storage và theo dõi tiến trình.
4. Gọi complete để backend kiểm tra và tạo media metadata.
5. Chỉ gắn `mediaId` đã complete vào Exercise/Food.
6. File bỏ dở được backend dọn theo retention policy.

### 9.5. API dự kiến

| Method | Endpoint | Mục đích |
|---|---|---|
| `POST` | `/api/v1/admin/media/init-upload` | Khởi tạo upload |
| `PUT` | Presigned URL | Upload binary |
| `POST` | `/api/v1/admin/media/complete` | Verify và hoàn tất |
| `DELETE` | `/api/v1/admin/media/{mediaId}` | Xóa media chưa/không còn liên kết |

### 9.6. Tiêu chí nghiệm thu

- [ ] Không thể bypass MIME/size bằng cách đổi extension.
- [ ] Progress, cancel, retry, preview, replace và remove hoạt động độc lập từng file.
- [ ] Presigned URL/credential không bị ghi log hoặc lưu bền ở client.
- [ ] Media chưa verify không thể publish cùng nội dung.

---

## 10. MH49 — Quản lý người dùng — P1

### 10.1. Bố cục UI

```text
Người dùng
Tra cứu tài khoản và kiểm soát trạng thái truy cập

[🔍 Email hoặc nickname________] [Vai trò ▾] [Trạng thái ▾] [Ngày đăng ký ▾]
┌────────────────────────┬────────────┬───────┬──────────┬──────────────┬─────┐
│ Email                  │ Nickname   │ Role  │ Trạng thái│ Đăng nhập cuối│ ⋯  │
├────────────────────────┼────────────┼───────┼──────────┼──────────────┼─────┤
│ minh***@gmail.com      │ Minh Anh   │ USER  │ ● Active │ 02/10 21:40  │ ⋯  │
└────────────────────────┴────────────┴───────┴──────────┴──────────────┴─────┘
```

- Click row hoặc “Xem chi tiết” mở drawer `520px` chỉ chứa account metadata được phép.
- Drawer có summary identity ở đầu, account status, timestamps và action zone ở cuối.
- Action “Khóa tài khoản” dùng destructive styling nhưng không đặt cạnh “Đóng” để tránh click nhầm.
- Dialog khóa gồm tên/email đã mask, textarea lý do bắt buộc, tùy chọn thời hạn nếu contract hỗ trợ và mô tả việc thu hồi session.
- Không thiết kế tab Health, Workout, Meal hoặc AI history trong User Detail.

### 10.2. Danh sách và chi tiết tối thiểu

- Tìm theo email/nickname; lọc theo role, Active/Locked/Disabled và ngày đăng ký.
- Cột: email đã mask khi phù hợp, nickname, role, trạng thái, ngày đăng ký, lần đăng nhập cuối và thao tác.
- Trang chi tiết chỉ có metadata tài khoản cần cho hỗ trợ vận hành; không mở rộng sang hồ sơ sức khỏe, bữa ăn, lịch tập hoặc hội thoại AI.

### 10.3. Thao tác

- Khóa tài khoản: bắt buộc nhập lý do, xác nhận và có thể chọn thời hạn nếu backend hỗ trợ.
- Mở khóa tài khoản: xác nhận và ghi lý do.
- Thu hồi toàn bộ session của user khi khóa.
- Không cho Admin tự khóa chính mình hoặc khóa Admin cuối cùng của hệ thống.
- P1 không bao gồm đổi mật khẩu hộ, đăng nhập giả danh hoặc xem secret của user.

### 10.4. API dự kiến

| Method | Endpoint | Mục đích |
|---|---|---|
| `GET` | `/api/v1/admin/users` | Danh sách và filter |
| `GET` | `/api/v1/admin/users/{id}` | Metadata tài khoản |
| `PUT` | `/api/v1/admin/users/{id}/lock` | Khóa và thu hồi session |
| `PUT` | `/api/v1/admin/users/{id}/unlock` | Mở khóa |

### 10.5. Tiêu chí nghiệm thu

- [ ] Không hiển thị hash mật khẩu, token, OTP, secret hay dữ liệu sức khỏe cá nhân.
- [ ] Lock/unlock cần lý do, confirm, CSRF và Audit Log.
- [ ] User bị khóa mất session và không thể đăng nhập lại.
- [ ] Có bảo vệ self-lock và last-admin lock.

---

## 11. MH48 — Nhập dữ liệu hàng loạt — P1

### 11.1. Bố cục UI

```text
Nhập dữ liệu                                      [Lịch sử nhập dữ liệu]
Thêm nhiều bài tập hoặc thực phẩm từ CSV/XLSX

  ① Tải file ───── ② Ánh xạ & kiểm tra ───── ③ Xác nhận ───── ④ Kết quả

┌────────────────────────────────────────────────────────────────────┐
│ Nội dung của bước hiện tại                                        │
│                                                                    │
│ Loại dữ liệu [Bài tập ▾]         [Tải file mẫu]                   │
│ ┌──────────────── Dropzone ─────────────────────────────────────┐ │
│ └───────────────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────────────┘
                                               [Hủy] [Tiếp tục →]
```

- Wizard container rộng tối đa `1120px`; stepper sticky dưới page header khi nội dung dài.
- Chỉ bước hiện tại có màu brand; bước hoàn tất có check success; bước lỗi có icon error.
- Footer action sticky: Back bên trái, Cancel/Continue bên phải; “Commit” chỉ xuất hiện ở bước 3.
- Preview table có cột `Dòng`, `Trạng thái`, dữ liệu chính và `Lỗi`; row lỗi mở rộng để hiển thị field/value/cách sửa.
- Summary validation luôn thấy: tổng, hợp lệ, cảnh báo, lỗi. Filter nhanh theo từng trạng thái.
- Bước kết quả dùng bốn cards Created/Updated/Skipped/Failed và link quay về module tương ứng.

### 11.2. Quy trình bốn bước

1. **Tải file:** chọn Exercise/Food, tải template và upload `.csv` hoặc `.xlsx`.
2. **Mapping và kiểm tra:** ánh xạ cột nếu cần, preview từng dòng, tổng hợp hợp lệ/cảnh báo/lỗi.
3. **Xác nhận:** chọn chiến lược duplicate và xác nhận số dòng sẽ ghi/bỏ qua.
4. **Kết quả:** hiển thị created/updated/skipped/failed và cho tải error report nếu API hỗ trợ.

### 11.3. Quy tắc

- Không commit ngay sau upload; bắt buộc preview và validate.
- Giới hạn dung lượng, số dòng và thời gian xử lý do backend cấu hình.
- Duplicate strategy phải rõ: bỏ qua, cập nhật theo khóa hợp lệ hoặc báo lỗi; không âm thầm ghi đè.
- Backend công bố import là atomic hay partial; UI phải phản ánh đúng, không báo partial success khi transaction đã rollback.
- Import lặp lại với cùng idempotency key không được tạo bản ghi trùng.
- File và error report có thời hạn lưu; không cho nội dung file override authorization/business rule.

### 11.4. API dự kiến

| Method | Endpoint | Mục đích |
|---|---|---|
| `GET` | `/api/v1/admin/imports/templates/{type}` | Tải file mẫu |
| `POST` | `/api/v1/admin/imports/preview` | Parse, mapping và validation |
| `POST` | `/api/v1/admin/imports/{id}/commit` | Commit với idempotency key |
| `GET` | `/api/v1/admin/imports/{id}` | Theo dõi trạng thái/kết quả |

### 11.5. Tiêu chí nghiệm thu

- [ ] File sai loại, quá lớn hoặc sai schema bị từ chối với lý do cụ thể.
- [ ] Preview chỉ rõ sheet/row/column/value và cách sửa từng lỗi.
- [ ] Commit cần confirm, chống gửi lặp và ghi Audit Log.
- [ ] Kết quả phản ánh đúng atomic/partial behavior của backend.

---

## 12. MH50 — Quản lý quy tắc và Prompt AI — P1

### 12.1. Bố cục UI

```text
Quy tắc & AI
Kiểm soát hành vi AI, prompt được phát hành và chỉ số vận hành

[Quy tắc an toàn] [Prompt templates] [Chỉ số AI]
─────────────────────────────────────────────────────────────────────
[🔍 Tìm kiếm____________] [Use case ▾] [Trạng thái ▾]        [+ Tạo draft]
┌────────────────────────────────────────────────────────────────────┐
│ Danh sách rule/prompt hoặc dashboard metric theo tab              │
└────────────────────────────────────────────────────────────────────┘
```

- Tabs nằm dưới page header và sticky khi scroll; URL giữ tab bằng route con hoặc `?tab=`.
- Rules dùng table; Prompt dùng master-detail: list `360px` bên trái, editor bên phải trên màn hình ≥1280px.
- Editor prompt dùng monospace `13/20`, line number, variable highlight và panel “Variables cho phép”.
- Diff version mở modal `900px` hoặc full-screen; old/new có legend rõ, không chỉ dùng đỏ/xanh.
- Trạng thái Draft/Review/Active/Archived luôn hiển thị cạnh version. Active version có banner “Đang dùng trong production”.
- Publish/Activate nằm trong sticky footer và tách khỏi “Lưu draft”; không dùng cùng label/màu cho hai hành động.
- Tab metrics tái sử dụng dashboard cards/charts nhưng dùng accent AI tím cho series AI, không dùng tím cho error.

### 12.2. Cấu trúc màn hình

Ba tab: **Quy tắc an toàn**, **Prompt templates**, **Chỉ số AI**.

### 12.3. Quy tắc AI

- Danh sách tên, loại tín hiệu/điều kiện, hành động, độ ưu tiên, phiên bản và trạng thái.
- Tạo/sửa draft, validate xung đột, bật/tắt có xác nhận.
- Quy tắc an toàn bắt buộc không thể bị tắt nếu policy backend không cho phép.
- Mọi thay đổi đều versioned và audit.

### 12.4. Prompt templates

- Quản lý theo use case: Workout Planner, Meal Planner, AI Coach.
- Trường: tên, mô tả, template, variables cho phép, phiên bản và trạng thái Draft/Review/Active/Archived.
- Preview/test chỉ dùng dữ liệu mẫu đã ẩn danh; không dùng raw context của user.
- Publish tạo phiên bản bất biến mới; rollback thực chất là kích hoạt lại một phiên bản cũ và vẫn tạo Audit Log.
- Không hiển thị provider credential, secret hoặc system context ngoài phạm vi được phép.

### 12.5. Chỉ số AI

- Số recommendation created/applied/dismissed, tỷ lệ apply, latency, timeout/fallback và lỗi theo use case.
- Chỉ hiển thị aggregate; không hiển thị prompt/response cá nhân.

### 12.6. API dự kiến

| Method | Endpoint | Mục đích |
|---|---|---|
| `GET/POST/PUT` | `/api/v1/admin/ai-rules` | Danh sách và quản lý draft rule |
| `POST` | `/api/v1/admin/ai-rules/{id}/activate` | Kích hoạt phiên bản rule |
| `GET/POST/PUT` | `/api/v1/admin/prompts` | Danh sách và quản lý prompt draft |
| `POST` | `/api/v1/admin/prompts/{id}/publish` | Publish phiên bản |
| `POST` | `/api/v1/admin/prompts/{id}/activate` | Kích hoạt/rollback |
| `GET` | `/api/v1/admin/ai-metrics` | Aggregate metrics |

### 12.7. Tiêu chí nghiệm thu

- [ ] Không thể sửa trực tiếp phiên bản Active đã publish.
- [ ] Variable ngoài allowlist và template không hợp lệ bị chặn.
- [ ] Publish/activate/disable cần confirm, version và Audit Log.
- [ ] Test prompt không lộ hoặc lưu raw context cá nhân.

---

## 13. MH51 — Nhật ký kiểm toán

### 13.1. Bố cục UI

```text
Nhật ký kiểm toán
Theo dõi các thay đổi và sự kiện nhạy cảm trong hệ thống

[Từ ngày — Đến ngày] [Actor ▾] [Action ▾] [Đối tượng ▾] [Kết quả ▾]
[🔍 Target ID / Correlation ID________________________] [Xóa bộ lọc]
┌─────────────────┬──────────────────┬────────┬─────────────┬──────────┬─────┐
│ Thời gian       │ Người thực hiện │ Action │ Đối tượng   │ Kết quả │ Xem │
├─────────────────┼──────────────────┼────────┼─────────────┼──────────┼─────┤
│ 03/10 10:30:12 │ admin@...        │ UPDATE │ FOOD #45    │ ✓ Thành công│ → │
└─────────────────┴──────────────────┴────────┴─────────────┴──────────┴─────┘
```

- Filter bar cho phép xuống hai dòng; date range và search giữ label rõ ràng.
- Action badge dùng semantic riêng theo loại nhưng không tô cả row.
- Click row mở detail drawer `760px`; URL có thể chứa `?event={id}` để back/forward hoạt động.
- Drawer detail: metadata card trên cùng, diff bên dưới, sanitized notice luôn thấy trước dữ liệu.
- Diff field dạng bảng `Field | Trước | Sau` cho object phẳng; JSON tree chỉ dùng cho object/array lồng nhau.
- Giá trị dài wrap và có copy button; secret bị redacted hiển thị `[REDACTED]`, không để ô trống gây hiểu nhầm.
- Không có checkbox chọn nhiều, edit, delete hoặc export nếu policy/API chưa duyệt.

### 13.2. Danh sách và bộ lọc

- Khoảng thời gian mặc định bảy ngày gần nhất.
- Lọc theo actor, action, target type, target ID, kết quả và request/correlation ID.
- Cột: thời gian, actor, hành động, đối tượng, kết quả, IP đã mask nếu policy cho phép và nút chi tiết.
- Phân trang server-side 20/50; sắp xếp mới nhất trước.

### 13.3. Chi tiết sự kiện

- Metadata: timestamp, actor, action, target, result, correlation ID.
- Diff old/new đã sanitize; highlight trường thêm, sửa và xóa.
- Failure reason được chuẩn hóa, không chứa stack trace hoặc secret.
- Chỉ đọc tuyệt đối; không có sửa/xóa từ UI.

### 13.4. Sự kiện tối thiểu phải audit

- Admin login success/failure theo chính sách bảo mật, logout và session revoke.
- Exercise/Food create, update, hide, show, delete và media change.
- User lock/unlock.
- Import preview/commit/failure.
- AI rule/prompt create, update, publish, activate, rollback và disable.
- AI recommendation apply khi thuộc baseline audit của hệ thống.

### 13.5. Quy tắc

1. Audit Log là append-only đối với Admin UI.
2. Actor phải là danh tính thực (`admin`, `system`, service), không gắn nhãn “AI” cho mọi validation event.
3. Không lưu password, token, OTP, API key, presigned URL, system prompt hoặc raw personal context.
4. Timestamp lưu UTC ở backend và chuyển sang giờ Việt Nam khi hiển thị.
5. Retention, export và quyền xem IP phải theo policy backend; không tự suy diễn ở UI.

### 13.6. API dự kiến

| Method | Endpoint | Mục đích |
|---|---|---|
| `GET` | `/api/v1/admin/audit-logs` | Danh sách và bộ lọc |
| `GET` | `/api/v1/admin/audit-logs/{id}` | Chi tiết sanitized |

### 13.7. Tiêu chí nghiệm thu

- [ ] Filter kết hợp đúng và giữ trên URL.
- [ ] Diff old/new dễ đọc, hỗ trợ object/array dài và copy phần đã sanitize.
- [ ] Không có mutation từ UI; API mutation audit bị từ chối.
- [ ] Secret và dữ liệu cá nhân nhạy cảm không xuất hiện trong list/detail.

---

## 14. API, dữ liệu và lỗi dùng chung

### 14.1. Quy ước danh sách

Các API danh sách nên hỗ trợ `page`, `size`, `sort`, `q` và các filter riêng. Response cần có `items`, `page`, `size`, `totalItems`, `totalPages` theo convention chung của backend.

### 14.2. Quy ước mutation

- Gửi CSRF token và cookie session.
- Hỗ trợ idempotency key cho import và thao tác có nguy cơ gửi lặp.
- Dùng `version` hoặc `If-Match` cho optimistic locking.
- Thành công trả entity/version mới; UI không tự suy đoán dữ liệu sau ghi.

### 14.3. Mã lỗi UI phải xử lý

| HTTP | Ý nghĩa UI |
|---:|---|
| 400 | Validation chung hoặc request sai |
| 401 | Session không hợp lệ/hết hạn |
| 403 | Sai role/audience/CSRF hoặc không có quyền |
| 404 | Đối tượng không tồn tại hoặc đã bị xóa |
| 409 | Duplicate hoặc chỉnh sửa đồng thời |
| 413 | File vượt giới hạn |
| 415 | MIME không hỗ trợ |
| 422 | Validation nghiệp vụ |
| 429 | Rate limit, hiển thị thời gian thử lại nếu có |
| 500/503 | Lỗi hệ thống/dịch vụ tạm thời, cho retry an toàn |

---

## 15. Cấu trúc frontend đề xuất

```text
admin-web/src/
├── app/                 # router, providers, query client
├── core/
│   ├── api/             # client, endpoints, error mapping
│   ├── auth/            # session, CSRF, route guard
│   └── config/          # environment, feature flags
├── components/
│   ├── layout/          # sidebar, header, breadcrumbs
│   ├── common/          # table, filters, dialog, states
│   └── media/           # uploader, preview, progress
├── features/
│   ├── auth/
│   ├── dashboard/
│   ├── exercises/
│   ├── foods/
│   ├── users/
│   ├── imports/
│   ├── ai-config/
│   └── audit/
└── test/                # fixtures, handlers, helpers
```

Stack đề xuất: React + TypeScript + Vite, React Router, TanStack Query, React Hook Form + Zod, Axios/fetch client có `credentials: include`, Tailwind/Shadcn và Recharts cho P1.

### 15.1. Route và page component

| Route | Page component | Overlay/child chính | Guard |
|---|---|---|---|
| `/login` | `LoginPage` | `LoginForm` | Chỉ guest; session hợp lệ redirect |
| `/` | `AdminLayout` | `Outlet` | `AdminProtectedRoute` |
| `/dashboard` | `DashboardPage` | Date range picker | ADMIN + feature flag P1 |
| `/exercises` | `ExerciseListPage` | `ExerciseFormDrawer`, detail/confirm | ADMIN |
| `/foods` | `FoodListPage` | `FoodFormModal`, detail/confirm | ADMIN |
| `/users` | `UserListPage` | `UserDetailDrawer`, lock dialog | ADMIN + feature flag P1 |
| `/imports` | `ImportWizardPage` | Preview/result table | ADMIN + feature flag P1 |
| `/ai-config` | `AiConfigPage` | Rule form, prompt editor, version diff | ADMIN + feature flag P1 |
| `/audit-logs` | `AuditLogPage` | `AuditDetailDrawer` | ADMIN |
| `*` | `NotFoundPage` | — | Theo session hiện tại |

### 15.2. Component ownership

```text
components/
├── layout/
│   ├── AdminLayout.tsx
│   ├── AdminSidebar.tsx
│   ├── AdminHeader.tsx
│   ├── Breadcrumbs.tsx
│   └── MobileNavigationDrawer.tsx
├── data-display/
│   ├── DataTable.tsx
│   ├── StatusBadge.tsx
│   ├── MetricCard.tsx
│   ├── JsonDiff.tsx
│   └── Pagination.tsx
├── forms/
│   ├── SearchInput.tsx
│   ├── FilterBar.tsx
│   ├── FormField.tsx
│   └── UnsavedChangesGuard.tsx
├── feedback/
│   ├── ConfirmDialog.tsx
│   ├── EmptyState.tsx
│   ├── ErrorState.tsx
│   ├── LoadingSkeleton.tsx
│   └── ToastProvider.tsx
└── media/
    ├── MediaUploader.tsx
    ├── MediaFileRow.tsx
    └── MediaPreview.tsx
```

Feature component không được tự tạo biến thể khác của button, badge, table, dialog hoặc toast nếu component chung đáp ứng được. Khác biệt hợp lệ phải được thêm bằng variant có tên và cập nhật tài liệu.

### 15.3. State và query convention

- Server state dùng TanStack Query; form state dùng React Hook Form; URL state dùng router search params.
- Không copy nguyên server list vào global store. Global client state chỉ gồm session metadata, sidebar state, theme/feature flags không nhạy cảm.
- Query keys có cấu trúc: `['admin', resource, 'list', normalizedParams]` và `['admin', resource, 'detail', id]`.
- Mutation thành công invalidate đúng list/detail/dashboard liên quan; không reload toàn trang.
- Search debounce nhưng select filter áp dụng ngay; thay filter reset page về `1`.
- Giữ previous data khi chuyển trang; hiển thị trạng thái fetching nhẹ ở table thay vì xóa toàn bộ nội dung.
- Không optimistic update cho hide/delete/lock/publish; chỉ cập nhật khi backend xác nhận.

### 15.4. Layer và overlay

| Layer | Z-index đề xuất |
|---|---:|
| Base content | 0 |
| Sticky table/header | 10–20 |
| Sidebar/header | 30 |
| Dropdown/popover | 50 |
| Drawer/modal overlay | 60 |
| Drawer/modal content | 70 |
| Toast | 80 |

Dropdown bên trong dialog phải render đúng portal trên dialog nhưng dưới toast. Chỉ một modal blocking được mở tại một thời điểm; confirm dialog có thể mở trên drawer đang chỉnh sửa.

### 15.5. Nội dung UI chuẩn

- Dùng “Bài tập”, “Thực phẩm”, “Người dùng”, “Nhật ký kiểm toán”; không trộn “Exercise/Food/User” trên label hiển thị.
- Nút tạo: “Thêm bài tập”, “Thêm thực phẩm”, “Tạo bản nháp”.
- Nút lưu: “Lưu bài tập”, “Lưu thực phẩm”, “Lưu bản nháp”; khi loading: “Đang lưu…”.
- Empty không filter: “Chưa có …”; empty có filter: “Không tìm thấy kết quả phù hợp”.
- Không dùng thông báo mơ hồ như “Có lỗi xảy ra” nếu đã có error code/field cụ thể.
- Destructive confirm phải nhắc lại tên đối tượng và hậu quả, ví dụ: “Ẩn ‘Bench Press’? Bài tập sẽ không còn xuất hiện trong lựa chọn mới.”

---

## 16. Kế hoạch triển khai

### Giai đoạn 1 — Nền tảng

- Bootstrap `admin-web`, CI, lint, unit test và build.
- Auth cookie/session/CSRF, MH58, MH45, route guard và logout.
- Component chung: DataTable, FilterBar, form state, confirm dialog và error mapping.

### Giai đoạn 2 — Dữ liệu P0

- MH46 Exercise CRUD/visibility/soft-delete.
- MH47 Food CRUD/visibility/soft-delete.
- Media upload, preview, retry và storage lifecycle.

### Giai đoạn 3 — Audit và hardening

- Audit schema/service, redaction và MH51.
- Accessibility, responsive, concurrency, rate limit và security tests.
- E2E: Admin login → tạo Exercise/Food + media → Audit → User thấy catalog mới.

### Giai đoạn 4 — P1

- Dashboard, User Management, Import Wizard và AI Config.
- Aggregate metrics, versioning, idempotency và workflow publish/rollback.

---

## 17. Definition of Done

Một module Admin chỉ được xem là hoàn thành khi:

- [ ] Chức năng và business rule trong tài liệu đã được triển khai hoặc có quyết định loại khỏi scope.
- [ ] API contract/OpenAPI đồng bộ với frontend types.
- [ ] UI dùng đúng token màu, typography, spacing, radius và kích thước layout trong mục 3.
- [ ] Không có component tự phát trùng chức năng với design-system component dùng chung.
- [ ] Có loading, empty, no-result, error, success, forbidden và conflict state phù hợp.
- [ ] Mutation có CSRF, authorization backend, confirm khi nguy hiểm và Audit Log.
- [ ] Không lưu token/secret trong Web Storage, log, URL hoặc thông báo lỗi.
- [ ] Unit/component test cho validation và trạng thái chính.
- [ ] Integration test cho role/audience/CSRF/concurrency.
- [ ] E2E cho happy path và ít nhất một failure path quan trọng.
- [ ] Visual QA ở `1440×900`, `1280×800`, `1024×768`, `768×1024`, `390×844` và zoom trình duyệt 200%.
- [ ] Keyboard navigation, focus order/trap, contrast, screen-reader label và responsive đạt yêu cầu.
- [ ] Text dài, số lớn, dữ liệu `null`, bảng rỗng và API chậm không làm vỡ layout.
- [ ] Không có layout shift đáng kể giữa skeleton và nội dung thật.
- [ ] Product, Backend, Frontend và QA cùng xác nhận acceptance criteria.

---

## 18. Ma trận truy vết

| Chức năng | Màn hình | Feature | Mốc |
|---|---|---|---|
| Admin login/session | MH58/MH45 | FT-ID-002, FT-ID-010 | P0 |
| Exercise management | MH46 | FT-AD-003, FT-MD-001/003 | P0 |
| Food management | MH47 | FT-AD-004, FT-MD-002/003 | P0 |
| Audit Log | MH51 | FT-AD-008 | P0 |
| Dashboard | MH45/Dashboard | FT-AD-001 | P1 |
| User management | MH49 | FT-AD-002 | P1 |
| Import | MH48 | FT-AD-005 | P1 |
| AI rules | MH50 | FT-AD-006 | P1 |
| Prompt/version | MH50 | FT-AD-007 | P1 |
| AI metrics | MH50/Dashboard | FT-AD-009 | P1 |

---

## 19. Quy tắc duy trì tài liệu

1. Chỉ cập nhật file này khi thay đổi phạm vi hoặc hành vi Web Admin.
2. Endpoint trong tài liệu phải được đối chiếu OpenAPI trước khi triển khai; nếu khác, cập nhật cả hai trong cùng thay đổi.
3. Không tạo lại file đặc tả riêng theo từng MH để tránh trùng lặp.
4. Mọi thay đổi business rule phải cập nhật acceptance criteria và ma trận truy vết tương ứng.
