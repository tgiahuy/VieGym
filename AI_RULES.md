# VieGym — AI_RULES.md

> Mandatory project rules for AI coding/design agents (Antigravity, Codex, Gemini, Claude, etc.).
>
> **Every agent MUST read this file before modifying the VieGym project.**
>
> **Canonical UI Design System & Architecture Specification for VieGym.**
>
> Last updated: 2026-09-09

---

# 1. Purpose of this file

This file defines the permanent development, UI/UX Design System, architecture, and safety rules for AI agents working on VieGym.

The goal is to ensure that AI-assisted changes:

- Keep the VieGym visual identity strictly consistent across all modules.
- Standardize all colors, surfaces, typography, buttons, and components according to the official VieGym Design System.
- Do not accidentally redesign unrelated screens or invent ad-hoc palettes.
- Do not break existing navigation, API integration, state management, or business logic.
- Reuse the centralized Flutter design system and semantic tokens.
- Produce maintainable Flutter code.
- Preserve the architecture already established in the project.
- Make UI improvements without turning each screen into a different design style.

**Strict Authority Rule:**
`AI_RULES.md` is the primary source of truth for the VieGym Design System. If a user UI request appears to conflict with this design system, follow `AI_RULES.md` unless the user explicitly commands a design system overhaul for the requested scope.

---

# 2. Project Context

## Product

**VieGym** is a Vietnamese fitness mobile application focused on:

- Personalized workout planning.
- AI-powered workout recommendations.
- Workout tracking.
- Exercise discovery.
- Vietnamese nutrition tracking.
- Meal planning.
- User health and fitness profiles.
- AI coaching and personalization.

The intended product experience is:

- Modern.
- Premium.
- Sporty.
- Energetic.
- Clean.
- Focused.
- Easy to use during workouts.
- Friendly for Vietnamese users.

---

# 3. Main Application Technology

The primary client application is Flutter.

Main Flutter source:

```text
/mobile
```

Important technologies currently used by the project include:

- Flutter
- Dart
- Material 3
- Riverpod
- go_router
- Dio / generated OpenAPI client

Backend:

```text
/backend
```

Backend technology:

- Java
- Spring Boot
- Spring Security
- JWT
- Spring Data JPA
- Flyway
- PostgreSQL

AI service:

```text
/ai-service
```

AI service technology:

- Python
- FastAPI

---

# 4. Critical Frontend Rule

When modifying the mobile application:

**DO NOT create React, Next.js, Vue, HTML, CSS, or another frontend implementation.**

The production mobile frontend is Flutter.

All mobile UI work must be performed inside:

```text
/mobile
```

unless the user explicitly requests otherwise.

---

# 5. Existing Flutter Architecture Must Be Preserved

The Flutter project is organized approximately as:

```text
mobile/lib/
├── api/
│   └── generated/
├── core/
│   ├── config/
│   ├── network/
│   ├── router/
│   └── theme/
├── features/
├── shared/
│   └── widgets/
└── main.dart
```

Agents must preserve this architecture.

Do not move files across major modules unless necessary.

Do not introduce a completely different application architecture.

---

# 6. VieGym Design Philosophy & Direction

VieGym uses a **Modern Fitness App** design direction:
- **Dark**
- **Clean**
- **Modern**
- **Premium fitness**
- **High contrast**
- **Strong typography**
- **Controlled brand red accent**
- **Subtle supporting colors**
- **Fitbod-inspired** (clean, scannable data layouts, but **KHÔNG copy Fitbod**).

VieGym maintains its own distinct visual identity.

---

### 6.1 Purpose-Driven Color Philosophy
VieGym sử dụng hệ màu mở rộng nhưng **màu sắc phải có ý nghĩa và vai trò rõ ràng**. Không được tùy ý lấy một màu bất kỳ chỉ để “làm giao diện đẹp hơn”.

Mọi màu sắc trong VieGym **BẮT BUỘC** thuộc về một trong 5 nhóm chức năng:
1. **Brand Colors:** Màu nhận diện thương hiệu cốt lõi (`VieGym Red`) dùng cho Primary CTA, key active states, brand cues.
2. **Neutral Colors:** Hệ thang xám tối có sắc tố, chiếm đại đa số diện tích UI (nền, surface, card, border, text).
3. **Semantic Colors:** Thể hiện trạng thái hệ thống và tương tác (`Success`, `Warning`, `Info`, `Error`).
4. **Feature Accent Colors:** Nhận diện và phân biệt từng tính năng nghiệp vụ (`AI Coach`, `Nutrition`, `Recovery`, `Streak`).
5. **Data Visualization Colors:** Biểu đồ nhiều series, bản đồ cơ bắp, phân bổ macro, thống kê tiến độ.

> **NGUYÊN TẮC CỐT LÕI:**
> - **Neutral colors** → chiếm phần lớn UI (tạo không gian trầm tĩnh, tập trung).
> - **VieGym Red** → brand + primary actions (tạo điểm nhấn năng lượng, quyết đoán).
> - **Supporting colors** → phân biệt feature / dữ liệu / trạng thái (tạo sự rõ ràng khi đọc thông tin).
> - **Cohesive & Unified** → VieGym có nhiều màu hơn nhưng luôn mang lại cảm giác nhất quán, không phân mảnh.

---

### 6.2 Visual Hierarchy & Color Priority (4 Cấp Độ Thị Giác)
Mọi màn hình VieGym phải thiết lập trật tự ưu tiên thị giác không thể nhầm lẫn:

- **LEVEL 1 — BRAND (VieGym Red `#F2305A`):**
  - Primary CTA (Hành động chính, quan trọng nhất viewport).
  - Active navigation item.
  - Selected primary control / indicator then chốt.
  - Brand identity cues.

- **LEVEL 2 — FEATURE ACCENT (Blue, Cyan, Violet, Orange, Amber, Green):**
  - Dùng để phân biệt các tính năng đặc thù hoặc dữ liệu quan trọng (AI Coach, Macro, Recovery, Streak).
  - Chỉ xuất hiện ở icon, badge nhỏ, chip selected, indicator, hoặc container mềm (`colorSoft`).

- **LEVEL 3 — SEMANTIC (Success Green, Warning Amber, Info Blue, Error Red):**
  - Phản ánh đúng trạng thái thực tế: Hoàn thành, Cảnh báo, Thông báo, Lỗi / Destructive.

- **LEVEL 4 — NEUTRAL (Dark Neutral 950–50):**
  - Chiếm hơn 80% bề mặt giao diện: Canvas background, card surfaces, borders, dividers, typography (Heading, Body, Caption).

> **Tuyệt đối không để tất cả thành phần cùng tranh giành độ nổi bật thị giác.**

---

### 6.3 Color Usage Ratio (Tỷ Lệ Phân Bổ Màu)
Toàn bộ UI VieGym hướng tới tỷ lệ thị giác hài hòa:
- **70% — Neutral Background & Surfaces:** (`neutral950` – `neutral650`)
- **20% — Typography & Neutral Elements:** (`neutral50` – `neutral400`)
- **7% — VieGym Brand Red:** (`primary`, `primarySoft`, `primaryBorder`)
- **3% — Supporting Accent & Semantic Colors:** (`violet`, `blue`, `cyan`, `green`, `amber`, `orange`)

---

### 6.4 One Viewport Accent Rule & Giới Hạn Màu Trên Một Màn Hình
Dù bảng màu đã được mở rộng phong phú, **một viewport thông thường KHÔNG ĐƯỢC sử dụng toàn bộ palette**.

- **Quy tắc Viewport chuẩn:**
  ```text
  Dark Neutral + VieGym Red + (1 hoặc tối đa 2 Supporting Accent Colors)
  ```
- **Ví dụ phân bổ hợp lý:**
  - *Màn hình Workout:* Neutral + VieGym Red + Cyan/Light Blue (chỉ số thời gian/nước).
  - *Màn hình AI Coach:* Neutral + Violet (AI identity) + VieGym Red (Primary CTA).
  - *Màn hình Nutrition:* Neutral + VieGym Red (CTA) + Nutrition Data Colors (theo mục 11.2).
- **Ngoại lệ:** Biểu đồ phức tạp nhiều series (Data Visualization) được dùng 3–4 màu cùng lúc. Nutrition visualization được dùng các màu metric cần thiết theo mục 11.2, kể cả khi có thêm Fiber / Water; chỉ áp dụng cho dữ liệu, không mở rộng sang nền hoặc navigation.

---

### 6.5 Do Not Create Rainbow UI (Không Tạo Giao Diện Cầu Vồng)
Mở rộng màu **KHÔNG ĐỒNG NGHĨA** với việc biến app thành một giao diện lòe loẹt:
- **KHÔNG** làm mỗi card một màu nền khác nhau (Card đỏ đứng cạnh Card tím, Card xanh, Card cam).
- **KHÔNG** làm mỗi button một màu ngẫu hứng.
- **KHÔNG** làm mỗi icon một màu nếu không có ý nghĩa dữ liệu.
- **KHÔNG** sử dụng màu neon có độ bão hòa quá cao trên bề mặt lớn.
- VieGym luôn giữ vững phong cách: **Dark, Premium, Controlled, Cohesive, Fitness-focused**.

---

### 6.6 Color Decision Checklist (8 Câu Hỏi Tự Kiểm Tra Trước Khi Áp Màu)
Trước khi thêm màu vào bất kỳ component nào, agent phải tự trả lời:
1. Element này thuộc nhóm nào trong 5 nhóm màu (Brand / Neutral / Semantic / Feature / Data Viz)?
2. Nó có phải Primary Action duy nhất của màn hình không?
3. Nó có phải active/selected state hay brand cue không?
4. Màu sắc này có đang truyền tải đúng ý nghĩa dữ liệu hoặc tính năng không?
5. Trạng thái này có semantic token tương ứng (Success / Warning / Error) chưa?
6. Neutral color có đủ để thể hiện sự trang nhã và rõ ràng cho element này không?
7. Viewport hiện tại đã có quá 2 màu accent cạnh tranh nhau chưa?
8. Màu mới có đảm bảo độ tương phản (contrast) và khả năng đọc trên Dark Theme không?

👉 **Nếu Neutral color đã đủ dùng thì LUÔN LUÔN ƯU TIÊN Neutral.**

---

### 6.7 Final Color Principle
> **“More colors does not mean more colorful UI.”**  
> VieGym có bảng màu phong phú để **tạo hierarchy, phân biệt dữ liệu, truyền tải ngữ nghĩa và nhận diện feature**, chứ KHÔNG PHẢI để sử dụng tất cả màu cùng lúc.  
> **Visual Identity cốt lõi của VieGym mãi mãi là: Dark Neutral + Controlled VieGym Red + Contextual Supporting Colors.**

---

# 7. Canonical VieGym Color System

The canonical source of truth for Flutter colors is:
```text
/mobile/lib/core/theme/app_theme.dart
```

Agents MUST inspect that file before applying colors. Do not invent an ad-hoc palette.

---

## 7.1 Core Brand Color System (Fitbod-inspired Cool Crimson Red)

VieGym's official Primary Brand Color is:
```text
PRIMARY BRAND COLOR:      #F2305A  (RGB: 242, 48, 90)
```
This is the permanent and authoritative Primary Brand Color for VieGym.

### Standardized Primary Tokens
| Token | HEX / Value | Role & Usage |
| :--- | :--- | :--- |
| `primary` | `#F2305A` | Màu thương hiệu cốt lõi, Primary CTA, Active navigation, Key highlight. |
| `primaryHover` | `#F4476D` | Trạng thái hover / highlight nhẹ. |
| `primaryPressed` | `#C32649` | Trạng thái pressed / tap down của Primary Button. |
| `primarySoft` | `#43202C` | Background container của selected items (~8–15% opacity tint). |
| `primaryBorder` | `#A72A49` | Border viền của selected items (~20–35% opacity tint). |
| `primaryHighlight` | `#F4476D` | Điểm sáng, high-intensity workout muscle visualization. |
| `primarySurface` | `#35202A` | Nền phụ của các khối cần liên kết thương hiệu mạnh. |
| `textOnPrimary` | `#FFFFFF` | Chữ trắng có độ tương phản tuyệt đối trên nền `primary`. |

### Strict Brand Red Integrity
- **Crimson red:** Sắc đỏ thẫm thể thao, cool tone, phảng phất undertone hồng nhẹ hiện đại.
- **TUYỆT ĐỐI KHÔNG ngả sang cam/gạch:** Cấm sử dụng `#CE3A31`, `#BE4639`, `#D9483B`, `#C84B3C`, `#E04A3A`.
- **Cấm tự ý thay Primary Red bằng Orange.** Orange là supporting color, không phải màu thương hiệu.

---

## 7.2 Supporting Accent Color System

Hệ màu accent hỗ trợ được thiết kế chuyên biệt cho ứng dụng thể hình cao cấp. **Các màu này KHÔNG thay thế VieGym Red** mà chỉ hỗ trợ phân biệt tính năng, phân loại dữ liệu và chỉ số thể chất.

Mỗi supporting accent tuân thủ cấu trúc 4 token: `base`, `soft`, `border`, `strong`.

### 1. Blue (Thông tin & Chỉ số kỹ thuật)
- **Base (`blue`):** `#4D8DFF`
- **Soft (`blueSoft`):** `rgba(77, 141, 255, 0.12)` (hoặc `#1E2A40`)
- **Border (`blueBorder`):** `rgba(77, 141, 255, 0.28)` (hoặc `#2D4570`)
- **Strong (`blueStrong`):** `#266CE6`
- **Vai trò:**
  - Thông tin hệ thống trung tính, hướng dẫn kỹ thuật (`Info`).
  - Chỉ số cơ thể kỹ thuật (Body metrics, chu vi cơ bắp, cân nặng kỹ thuật).
  - Lượng mỡ dinh dưỡng (`Fat` macro).
  - Chuỗi dữ liệu phụ thứ 2 trong biểu đồ (Secondary chart series).

### 2. Cyan / Teal (Phục hồi & Sức khỏe thể chất)
- **Base (`cyan`):** `#2CC7B5`
- **Soft (`cyanSoft`):** `rgba(44, 199, 181, 0.12)` (hoặc `#1B2E2B`)
- **Border (`cyanBorder`):** `rgba(44, 199, 181, 0.28)` (hoặc `#235048`)
- **Strong (`cyanStrong`):** `#18A897`
- **Vai trò:**
  - Trạng thái phục hồi cơ bắp (`Recovery status`).
  - Đạm trong dinh dưỡng (`Protein`), muscle recovery / fitness nutrition. Water dùng Light Blue theo mục 11.2.
  - Thời lượng buổi tập, hiệu suất cardio nhẹ (`Duration` / Aerobic performance).
  - Trạng thái sức khỏe tổng quát (Health score).

### 3. Green (Thành công & Mục tiêu đạt được)
- **Base (`green`):** `#35C76F`
- **Soft (`greenSoft`):** `rgba(53, 199, 111, 0.12)` (hoặc `#1C2E23`)
- **Border (`greenBorder`):** `rgba(53, 199, 111, 0.28)` (hoặc `#245235`)
- **Strong (`greenStrong`):** `#22A658`
- **Vai trò:**
  - Trạng thái hoàn thành xuất sắc buổi tập (`Completed workout`).
  - Mục tiêu thể lực đã đạt (`Goal achieved`).
  - Cơ bắp đã hồi phục 100% sẵn sàng tập tiếp (`Full recovery`).
  - Chất xơ trong dinh dưỡng (`Fiber` macro).
  - Semantic Success cho mọi tác vụ thành công.

### 4. Amber / Gold (Cảnh báo & Kỷ lục cá nhân)
- **Base (`amber`):** `#F4B740`
- **Soft (`amberSoft`):** `rgba(244, 183, 64, 0.12)` (hoặc `#30281A`)
- **Border (`amberBorder`):** `rgba(244, 183, 64, 0.28)` (hoặc `#544422`)
- **Strong (`amberStrong`):** `#D49B24`
- **Vai trò:**
  - Cảnh báo calo sắp chạm ngưỡng giới hạn (`Calories near limit`).
  - Mức phục hồi trung bình (`Medium recovery`).
  - Tinh bột trong dinh dưỡng (`Carbohydrates` macro).
  - Huy hiệu kỷ lục cá nhân (`Personal Record` / PR badge).
  - Semantic Warning cho các trạng thái cần chú ý.

### 5. Orange (Năng lượng & Chuỗi tập luyện)
- **Base (`orange`):** `#F28C38`
- **Soft (`orangeSoft`):** `rgba(242, 140, 56, 0.12)` (hoặc `#30231A`)
- **Border (`orangeBorder`):** `rgba(242, 140, 56, 0.28)` (hoặc `#543922`)
- **Strong (`orangeStrong`):** `#D3701E`
- **Vai trò:**
  - Năng lượng calo đốt cháy (`Active calories burned`).
  - Chuỗi ngày tập luyện liên tục (`Workout Streak` icon / flame).
  - Cường độ tập ấm nóng (Warm fitness metric).
  - **QUAN TRỌNG:** Orange CHỈ là supporting/data color. **TUYỆT ĐỐI KHÔNG dùng Orange cho Primary CTA, active navigation bar, hay branding VieGym.**

### 6. Violet (AI Coach & Trí Tuệ Nhân Tạo)
- **Base (`violet`):** `#9B7BFF`
- **Soft (`violetSoft`):** `rgba(155, 123, 255, 0.12)` (hoặc `#262238`)
- **Border (`violetBorder`):** `rgba(155, 123, 255, 0.28)` (hoặc `#453966`)
- **Strong (`violetStrong`):** `#7B58E6`
- **Vai trò:**
  - Tính năng AI Coach, trợ lý ảo tập luyện & dinh dưỡng.
  - Sparkle icon, AI badge, AI-generated suggestion chip.
  - Đề xuất thông minh được cá nhân hóa (`Smart recommendations`).
  - Không dùng Violet / Purple làm màu mặc định cho Protein hoặc nutrition metric chính (mục 11.2).

### 7. Pink / Magenta (Điểm nhấn đặc biệt & Thành tựu hiếm)
- **Base (`pink`):** `#E66BC5`
- **Soft (`pinkSoft`):** `rgba(230, 107, 197, 0.12)` (hoặc `#301F2B`)
- **Border (`pinkBorder`):** `rgba(230, 107, 197, 0.28)` (hoặc `#542E4B`)
- **Strong (`pinkStrong`):** `#C447A3`
- **Vai trò:**
  - Thành tựu đặc biệt, huy hiệu milestone đặc biệt (`Special milestone`).
  - Dải màu thứ 6 trong biểu đồ phân tích đa chiều (Advanced data viz).
  - **HẠN CHẾ:** Không sử dụng Pink làm màu phổ biến toàn app.

---

## 7.3 Color Saturation & Soft Color System Rules
Trong Dark Theme UI cao cấp:
1. **Strong Color (`base` / `strong`):** Chỉ dùng cho icon nhỏ, text ngắn quan trọng, dải line mảnh hoặc điểm dữ liệu then chốt.
2. **Large Surface (`soft`):** Các container lớn, khối card được highlight, hoặc chip background BẮT BUỘC dùng dạng `colorSoft` (tint 8–15% opacity).
3. **Cấm Solid Color Container:** Không tạo các khối card solid tím gắt, solid xanh gắt hay solid cam gắt trên màn hình dark theme vì sẽ gây chói mắt và phá vỡ sự sang trọng.

---

## 7.4 Data Visualization Palette (Bảng Màu Dành Cho Biểu Đồ & Thống Kê)

Khi hiển thị biểu đồ tập luyện, cân nặng, calo, và macro:

```text
chartPrimary:   #F2305A  (VieGym Red — Series chính, tạ nâng, volume chính)
chartBlue:      #4D8DFF  (Chuỗi phụ 1, thể tích, Fat)
chartCyan:      #2CC7B5  (Phục hồi, thời lượng, Protein)
chartGreen:     #35C76F  (Mục tiêu đạt, chuỗi hoàn thành, Fiber)
chartAmber:     #F4B740  (Carbs)
chartOrange:    #F28C38  (Calo đốt cháy thực tế, nhịp tim)
chartViolet:    #9B7BFF  (Dự đoán AI; nutrition metric vẫn theo mục 11.2)
chartPink:      #E66BC5  (Chỉ số phụ đặc biệt)
```

### Quy Tắc Vẽ Biểu Đồ:
**Nutrition charts ưu tiên mapping mục 11.2 với mọi số lượng series**, kể cả chart chỉ có một metric hoặc dữ liệu do AI tạo. Các quy tắc chọn màu theo số series dưới đây chỉ áp dụng cho dữ liệu chưa có mapping semantic cố định.
- **Biểu đồ 1 series:** Bắt buộc dùng `chartPrimary` (`#F2305A`).
- **Biểu đồ 2 series:** Dùng `chartPrimary` (`#F2305A`) + `chartBlue` (`#4D8DFF`) hoặc `chartCyan` (`#2CC7B5`).
- **Biểu đồ nhiều series:** Áp dụng tuần tự theo Data Visualization Palette.
- **CẤM:** Không dùng 5 sắc đỏ gần giống nhau để phân biệt các đường biểu đồ khác nhau.
- **CẤM:** Không dùng cùng một màu cho hai đại lượng đối nghịch trong cùng một biểu đồ.

---

## 7.5 Master Recommended Color Map (Bảng Tra Cứu Toàn Diện)

| Mục Đích Sử Dụng | Token Khuyên Dùng | Mã Màu Hex / Cấu Trúc |
| :--- | :--- | :--- |
| **Brand Identity / Primary CTA** | `primary` | `#F2305A` |
| **Primary Button Pressed** | `primaryPressed` | `#C32649` |
| **Primary Selected Surface** | `primarySoft` | `#43202C` |
| **Primary Selected Border** | `primaryBorder` | `#A72A49` |
| **Canvas Background (Chính)** | `neutral900` / `background` | `#0F1012` (hoặc `#1F1E2A`) |
| **Canvas Background (Sâu)** | `neutral950` / `backgroundDeep` | `#0B0C0E` (hoặc `#191922`) |
| **Card Surface (Mặc định)** | `neutral800` / `surface` | `#17181B` (hoặc `#272633`) |
| **Elevated Card / Modal** | `neutral750` / `surfaceElevated` | `#1C1D21` (hoặc `#2C2B39`) |
| **Nested Surface / Disabled** | `neutral700` / `surfaceNested` | `#222327` (hoặc `#31303F`) |
| **Input / Search Field** | `neutral650` / `surfaceInput` | `#292A2F` (hoặc `#292835`) |
| **Default Border / Divider** | `neutral650` / `borderDefault` | `#292A2F` (hoặc `#373644`) |
| **Strong Border** | `neutral600` / `borderStrong` | `#34363B` (hoặc `#464553`) |
| **Subtle Inner Divider** | `borderSubtle` | `#302F3C` |
| **Text Primary (Heading/Body)**| `neutral50` / `textPrimary` | `#F5F5F6` / `#FFFFFF` |
| **Text Secondary (Subtitles)** | `neutral300` / `textSecondary`| `#A7A9AE` / `#9B99A5` |
| **Text Muted / Metadata** | `neutral500` / `textMuted` | `#62656B` / `#74727F` |
| **Text Disabled** | `neutral500` / `textDisabled` | `#62656B` / `#575662` |
| **Success State** | `success` | `#35C76F` |
| **Warning State** | `warning` | `#F4B740` |
| **Info State** | `info` | `#4D8DFF` |
| **Error / Destructive Action** | `error` | `#FF5A5F` |
| **AI Coach / Recommendations** | `violet` | `#9B7BFF` |
| **Recovery / Health Metric** | `cyan` | `#2CC7B5` |
| **Energy / Active Calories** | `orange` | `#F28C38` |
| **Streak Flame** | `orange` | `#F28C38` |
| **Macro: Protein** | `nutritionProtein` (`cyan`) | `#2CC7B5` |
| **Macro: Carbohydrates** | `nutritionCarbs` (`amber`) | `#F4B740` |
| **Macro: Fat** | `nutritionFat` (`blue`) | `#4D8DFF` |
| **Macro: Fiber** | `nutritionFiber` (`green`) | `#35C76F` |
| **Hydration: Water** | `nutritionWater` (Light Blue) | `#55B7FF` |
| **Energy: Calories** | `nutritionCalories` / `textPrimary` | `#F5F5F5` (reuse neutral tương đương; mục 11.2) |

---

# 8. Dark Theme Surface & Neutral System

VieGym xây dựng chiều sâu thị giác thông qua **thang sắc độ Dark Neutral phân cấp tinh tế** kết hợp viền mờ, không lạm dụng drop shadow đen đục.

```text
App Canvas Background (neutral900 / #0F1012 / #1F1E2A)
         ↓
Primary Surface / Card (neutral800 / #17181B / #272633)
         ↓
Elevated Surface (neutral750 / #1C1D21 / #2C2B39)
         ↓
Nested Surface (neutral700 / #222327 / #31303F) & Input Surface (neutral650 / #292A2F)
         ↓
Borders (neutral650 / #292A2F, neutral600 / #34363B, subtle #302F3C)
         ↓
Content / Typography / Controlled Accents
```

### 8.1 Thang Độ Dark Neutral (Neutral 950 → 50 Scale)
Để đảm bảo giao diện dark theme có chiều sâu chuyên nghiệp và khả năng chuyển tiếp mượt mà giữa các khối:

| Token | HEX | Mục Đích Sử Dụng |
| :--- | :--- | :--- |
| `neutral950` | `#0B0C0E` | Deepest canvas, bottom nav background, backdrop overlay. |
| `neutral900` | `#0F1012` | App canvas background chuẩn, vùng nền chính của màn hình. |
| `neutral850` | `#131417` | Nền chuyển tiếp phụ, muscle canvas background. |
| `neutral800` | `#17181B` | Default card surface, list item tile, container cấp 1. |
| `neutral750` | `#1C1D21` | Elevated card, bottom sheet, floating action panel. |
| `neutral700` | `#222327` | Nested surface, inner container bên trong card, disabled button fill. |
| `neutral650` | `#292A2F` | Input field surface, search bar, default subtle border. |
| `neutral600` | `#34363B` | Emphasized card border, secondary button border, strong divider. |
| `neutral500` | `#62656B` | Placeholder text, disabled icon, subtle timestamp, muted caption. |
| `neutral400` | `#8A8D93` | Supporting icon, metadata label, helper text. |
| `neutral300` | `#A7A9AE` | Description text, secondary body, form label. |
| `neutral200` | `#C9CBD0` | High-legibility body text, subheader. |
| `neutral100` | `#E3E4E7` | Card title, section header, important metric text. |
| `neutral50` | `#F5F5F6` | Primary heading, key data value, highest contrast white-adjacent text. |

### 8.2 Quy Tắc Card & Surface
- **Default Card = Neutral Surface:** 100% card mặc định dùng `neutral800` (`#17181B` / `#272633`), viền `borderDefault` (`#373644`).
- **Special Card = Neutral Surface + Accent:** Card đặc biệt (ví dụ "Buổi tập hôm nay", "Gợi ý AI") vẫn giữ nền Neutral, chỉ nhấn bằng:
  1. Border `primaryBorder` hoặc `violetBorder`.
  2. Dải line mảnh hoặc badge nhỏ ở góc.
  3. Icon màu accent (`primary` hoặc `violet`).
  4. Nút CTA accent bên trong card.
- **CẤM:** Không đặt 4 card với 4 màu nền solid (Đỏ, Tím, Xanh dương, Cam) nằm cạnh nhau như dashboard đồ chơi.

---

# 9. Text & Icon Typography Colors

Hệ thống text và icon của VieGym tuân thủ tính tương phản cao và phân cấp thông tin rõ rệt:

### 9.1 Typography Hierarchy & Color Rules
- **Heading (Tiêu đề màn hình / Section title):** **BẮT BUỘC dùng `textPrimary` (`#FFFFFF` / `neutral50`). TUYỆT ĐỐI KHÔNG dùng VieGym Red cho heading thông thường.**
- **Body text:** Dùng `textPrimary` hoặc `textSecondary` (`neutral300` / `#9B99A5`).
- **Description / Helper text:** Dùng `textSecondary` (`#9B99A5`).
- **Metadata / Timestamps:** Dùng `textMuted` (`#74727F` / `neutral500`).
- **Disabled text:** Dùng `textDisabled` (`#575662` / `neutral500`).
- **Text on Primary CTA:** Bắt buộc dùng `textOnPrimary` (`#FFFFFF`).

### 9.2 Strict Text Red Rule
**VieGym Red CHỈ ĐƯỢC dùng cho text khi:**
1. Active state (Tab hoặc Chip đang chọn).
2. Clickable link hành động mang tính thương hiệu ("Xem tất cả", "Thử ngay").
3. Key metric thành tích then chốt (ví dụ: Tổng cân nặng kỷ lục nâng được).
4. Tên thương hiệu "VieGym".

---

### 9.3 Meaning-Driven Icon Colors (Màu Icon Theo Ý Nghĩa)
Icon chỉ mang màu khi màu sắc đó truyền tải đúng vai trò nghiệp vụ:
- **Workout / Brand Action:** `primary` (`#F2305A`).
- **AI Assistant / Insights:** `violet` (`#9B7BFF`).
- **Hydration / Water Intake:** `nutritionWater` (Light Blue, `#55B7FF`).
- **Nutrition / Macros:** Dùng đúng màu macro tương ứng (`cyan`, `amber`, `blue`, `green`; mục 11.2).
- **Success / Hoàn thành:** `success` (`#35C76F`).
- **Warning / Chú ý:** `warning` (`#F4B740`).
- **Info / Hướng dẫn:** `info` (`#4D8DFF`).
- **Inactive / Navigation chung:** `iconSecondary` (`#9B99A5`) hoặc `iconTertiary` (`#74727F`).

---

# 10. Semantic Color System & Destructive Actions

Semantic colors phản ánh chính xác trạng thái logic của hệ thống. **Phải phân biệt rạch ròi giữa Brand Red và Error Red:**

> **Brand Red (`#F2305A`) ≠ Error Red (`#FF5A5F`)**

### 10.1 Semantic Token Palette
| Trạng Thái | Base Token | Soft Token | Border Token | Ý Nghĩa Sử Dụng |
| :--- | :--- | :--- | :--- | :--- |
| **Success** | `success` (`#35C76F`) | `successSoft` (`rgba(53, 199, 111, 0.12)`) | `successBorder` (`rgba(53, 199, 111, 0.3)`) | Đã hoàn thành, mục tiêu đạt, đồng bộ thành công, phục hồi tốt. |
| **Warning** | `warning` (`#F4B740`) | `warningSoft` (`rgba(244, 183, 64, 0.12)`) | `warningBorder` (`rgba(244, 183, 64, 0.3)`) | Cảnh báo nhẹ, sắp vượt calo, sắp tới hạn, phục hồi vừa phải. |
| **Info** | `info` (`#4D8DFF`) | `infoSoft` (`rgba(77, 141, 255, 0.12)`) | `infoBorder` (`rgba(77, 141, 255, 0.3)`) | Hướng dẫn kỹ thuật, thông tin hệ thống trung tính. |
| **Error** | `error` (`#FF5A5F`) | `errorSoft` (`rgba(255, 90, 95, 0.12)`) | `errorBorder` (`rgba(255, 90, 95, 0.3)`) | Thất bại, dữ liệu lỗi, hành động hủy hoại (destructive). |

### 10.2 Destructive Action Hierarchy (Hành Động Phá Hủy)
- **Hành động phá hủy:** Xóa bài tập, hủy tài khoản, xóa thực đơn, reset dữ liệu.
- **Quy tắc:**
  - **CẤM dùng VieGym Brand Red (`#F2305A`) cho destructive actions.**
  - **BẮT BUỘC sử dụng Semantic Error (`#FF5A5F`)** để người dùng phân biệt rõ giữa hành động tích cực thương hiệu và hành động xóa dữ liệu nguy hiểm.

---

# 11. Feature Accent System & Component Color Rules

Hệ màu theo tính năng (Feature Accents) giúp người dùng nhận thức ngữ cảnh đang thao tác một cách tự nhiên.

### 11.1 Feature Accent Mapping
1. **Workout & Training:**
   - Primary: `VieGym Red` (`#F2305A`).
   - Secondary: `Neutral`.
   - Có thể dùng `Blue` hoặc `Cyan` trong chart / timers nếu cần.
2. **Muscle Distribution (Bản Đồ Nhóm Cơ):**
   - **Đơn sắc theo cường độ (Monochromatic intensity scale):**
     * 0%: `neutral700` (`#222327`)
     * 1–10%: Primary 25% opacity
     * 11–20%: Primary 50% opacity
     * 21–30%: Primary 75% opacity
     * >30%: Primary 100% full intensity (`#F2305A` + highlight `#F4476D`)
   - **CẤM:** Không dùng biểu đồ cầu vồng (đỏ, vàng, xanh lá, tím) trên bản đồ cơ một chiều.
3. **AI Coach (Trợ Lý AI):**
   - Primary Accent: `Violet` (`#9B7BFF`).
   - Secondary: `VieGym Red` (dành cho CTA).
   - Nền AI card vẫn phải là Neutral Dark.
4. **Progress & Achievements:**
   - Hoàn thành: `Green` (`#35C76F`).
   - Streak chuỗi ngày: `Orange` (`#F28C38`).
   - Kỷ lục cá nhân (PR): `Amber` (`#F4B740`).

---

### 11.2 Nutrition Data Rules (Quy Tắc Dinh Dưỡng Đồng Bộ Tuyệt Đối)

Đây là mapping semantic chuẩn cho mọi chỉ số dinh dưỡng trong VieGym. `AI_RULES.md` là **SOURCE OF TRUTH**; theme Flutter là nơi triển khai token, không được dùng mapping cũ trong code để ghi đè quy tắc này.

#### Final Nutrition Color Map

| Metric | Color | HEX | Role |
|---|---|---|---|
| Calories / kcal | White | #F5F5F5 | Total energy |
| Protein | Cyan / Teal | #2CC7B5 | Protein / muscle nutrition |
| Carbs | Amber | #F4B740 | Energy source |
| Fat | Blue | #4D8DFF | Fat macro |
| Fiber | Green | #35C76F | Fiber / healthy nutrition |
| Water | Light Blue | #55B7FF | Hydration |

- **AI / AI Coach → Violet / Purple:** dành cho AI-generated content, recommendation, badge, insight và icon. Không dùng tím làm màu mặc định cho Protein hoặc nutrition metric chính, kể cả trong AI Nutrition Assistant / AI Meal Generator.
- **VieGym Brand / Primary CTA → VieGym Red:** giữ vai trò Brand, Primary CTA, Active navigation, Selected important state, Workout accent và Brand emphasis. Nutrition chỉ dùng Red khi có ngữ nghĩa này thực sự phù hợp, không dùng làm màu mặc định cho kcal hoặc macro.

#### Vai trò và cách dùng từng metric

- **Calories / kcal:** metric tổng năng lượng trung tâm nhưng trung tính, dùng `#F5F5F5` hoặc `textPrimary` / `nutritionCalories` tương đương. Nổi bật bằng typography, size, weight và position; ví dụ số **1842** màu trắng với nhãn **kcal**. Không dùng mặc định Red, Orange, Purple hoặc gradient. Ngoại lệ rõ ràng được giữ: Orange cho **active calories burned trong Workout** theo mục 7.2 / 7.4, không áp dụng cho tổng kcal dinh dưỡng. Cảnh báo gần giới hạn vẫn dùng Warning cho trạng thái cảnh báo có label/icon, không đổi mapping của metric.
- **Protein:** Cyan / Teal đại diện muscle recovery / fitness nutrition; dùng nhất quán cho icon, progress, chart, small indicator, macro badge và selected nutrition visualization. Không dùng Cyan làm full card background; nền nhấn nhỏ dùng `nutritionProteinSoft` / `cyanSoft` (reuse `proteinSoft` nếu đã tương đương).
- **Carbohydrates / Carbs:** Amber đại diện energy source; dùng cho progress, icon, chart, indicator và badge. Tránh Yellow thuần quá sáng gây chói trên dark theme.
- **Fat:** Blue cho progress, icon, chart, indicator và badge; phân biệt rõ với Protein và Carbs. Không đổi Fat sang Cyan đã dành cho Protein.
- **Fiber:** Green đại diện health / healthy nutrition, dùng cho progress, chart, indicator và nutrition detail. Khi Green cũng là Success, context / icon / label phải phân biệt rõ hai ý nghĩa.
- **Water / Hydration:** Light Blue; giữ khác Cyan / Teal của Protein, không dùng lại Cyan Protein cho Water.

#### Token reuse & soft variants

Ưu tiên reuse token hiện tại có màu tương đương hoặc rất gần, không tạo duplicate palette. Các tên dưới đây là quy ước semantic / alias trong tài liệu; chỉ triển khai code khi task riêng cho phép.

- `nutritionCalories` → `textPrimary` / `neutral50` hiện có (`#F5F5F6`, rất gần chuẩn `#F5F5F5`); không cần đổi neutral palette.
- `nutritionProtein` → `cyan`; `nutritionCarbs` → `amber`; `nutritionFat` → `blue`; `nutritionFiber` → `green`.
- `nutritionCarb` hiện có được giữ làm alias tương đương `nutritionCarbs`, không tạo màu riêng.
- `nutritionWater` → Light Blue `#55B7FF`; reuse token tương đương nếu có. Theme hiện tại chưa có base Light Blue tương ứng.
- Khi hệ thống hỗ trợ, chuẩn hóa `nutritionCaloriesSoft`, `nutritionProteinSoft`, `nutritionProteinBorder`, `nutritionCarbsSoft`, `nutritionCarbsBorder`, `nutritionFatSoft`, `nutritionFatBorder`, `nutritionFiberSoft`, `nutritionWaterSoft`.
- Soft variants dùng khoảng **8–15% opacity trên dark surface**; Border variants dùng **20–35%**. Reuse `cyanSoft` / `cyanBorder`, `amberSoft` / `amberBorder`, `blueSoft` / `blueBorder`, `greenSoft` khi tương đương. CaloriesSoft và WaterSoft lấy từ base tương ứng; không tạo quá nhiều shade.

#### Nutrition card & phạm vi sử dụng

- Được dùng màu metric cho progress bar, chart, icon, small badge, small indicator, numeric accent và selected state có semantic dinh dưỡng.
- Không dùng làm toàn bộ page background, default card background, navigation, generic button hoặc generic title. Calories White trùng neutral text không biến generic title thành nutrition accent.
- **Default card luôn dùng Neutral Surface.** Ví dụ Macro Card: nền Neutral, Protein icon và progress Cyan, Protein value dùng `textPrimary` hoặc Cyan tùy hierarchy. Không tạo Solid Cyan Card; quy tắc tương tự cho Carbs và Fat.
- Soft tint chỉ dành cho vùng nhấn nhỏ trong card, không thay thế nền mặc định của card.

#### Consistency, charts & accessibility

- Mapping giữ nguyên tại Nutrition Home, Meal Plan / Meal Planner, Meal History / Food Log, Food Detail, Meal Detail, Daily Nutrition / Macro Rings / Bars, AI Nutrition Assistant, AI Meal Generator, Home Nutrition summary, Profile statistics, Charts, Dashboard widgets và mọi component liên quan macros.
- Chart Protein / Carbs / Fat dùng lần lượt `#2CC7B5` / `#F4B740` / `#4D8DFF`; nếu có kcal dùng `#F5F5F5` hoặc neutral token tương đương nêu trên. Fiber và Water giữ mapping trong bảng. Quy tắc này ưu tiên hơn thứ tự generic chart palette, màu AI hoặc giới hạn accent thông thường.
- Đảm bảo contrast rõ cho các đường dữ liệu trên nền tối. Không đổi mapping để “chart đẹp hơn”; consistency quan trọng hơn variation.
- Không dùng màu làm phương tiện duy nhất để phân biệt metric. Luôn có ít nhất một trong **label, icon, legend hoặc position nhất quán**; màu chỉ là secondary visual cue.

> “Nutrition metrics must use a stable semantic color mapping across the entire VieGym application.”
>
> “AI Violet must remain visually distinct from Nutrition metric colors.”
>
> “Calories are a neutral primary metric and should use white by default.”

---

### 11.3 Button Color Hierarchy (3 Cấp Button)
1. **Primary Button:**
   - Background: `primary` (`#F2305A`), Pressed: `primaryPressed` (`#C32649`).
   - Text: `textOnPrimary` (`#FFFFFF`), Height: `54px`, Radius: `16px`.
   - Giới hạn: Mỗi màn hình chỉ có **1 Primary CTA** nổi bật nhất.
2. **Secondary Button:**
   - Background: `surface` (`#272633` / `#17181B`), Border: `borderStrong` (`#464553`).
   - Text: `textPrimary`.
   - **Tuyệt đối không dùng solid red.**
3. **Tertiary / Ghost Button:**
   - Không nền, text `textSecondary` hoặc `primary` (nếu là link quan trọng).

---

### 11.4 Tab / Chip / Filter / Selection Rules
- **Unselected:** Background `surface` (`#272633`), Border `borderDefault` (`#373644`), Text `textSecondary`.
- **Selected:** Background `primarySoft` (`#43202C`), Border `primaryBorder` (`#A72A49`), Text/Icon `primary` (`#F2305A`).
- **Feature Filter (nếu có):** Ví dụ category AI filter có thể dùng `violetSoft` + `violetBorder` + `violet`.

---

# 12. Gradients, Accessibility & AI Prohibitions

### 12.1 Gradient Rules (Sử Dụng Giới Hạn Nghiêm Ngặt)
Chỉ cho phép gradient tinh tế trong 2 trường hợp cụ thể:
1. **AI Hero Banner:** Gradient nhẹ từ `violetSoft` (`rgba(155, 123, 255, 0.15)`) → `primarySoft` (`rgba(242, 48, 90, 0.10)`).
2. **Special Achievement Milestone:** Gradient nhẹ từ `amberSoft` → `orangeSoft`.
- **CẤM:** Không dùng gradient cho button thông thường, không dùng gradient toàn màn hình, không dùng gradient trên mọi card.

---

### 12.2 Accessibility & Contrast (Dễ Tiếp Cận & Khả Năng Đọc)
- Mọi màu text và icon phải đảm bảo tỷ lệ tương phản tối thiểu WCAG AA trên nền dark theme.
- **Không bao giờ dùng màu làm phương tiện duy nhất để truyền tải trạng thái:**
  * Success: Màu xanh + Icon check / Label "Đã xong".
  * Error: Màu đỏ + Icon cảnh báo / Message giải thích.
  * Selected: Màu + Viền nổi bật + Icon checkmark.

---

### 12.3 Token First Principle (Quy Tắc Ưu Tiên Token)
- Mọi màu mới được sử dụng trong dự án **BẮT BUỘC** phải được định nghĩa trong centralized token (`AppColors` hoặc theme extension).
- **CẤM:** Không hard-code `Color(0xFF...)` trực tiếp rải rác trong widget.

---

### 12.4 AI Prohibitions (Danh Sách BẮT BUỘC KHÔNG LÀM)
AI agent **TUYỆT ĐỐI KHÔNG ĐƯỢC:**
1. Tô đỏ toàn bộ giao diện (red heading, red card, red background).
2. Dùng màu cam thay thế cho VieGym Red.
3. Dùng VieGym Brand Red cho Destructive actions (phải dùng Error Red `#FF5A5F`).
4. Đổi màu Macro dinh dưỡng giữa các màn hình (Protein luôn là Cyan / Teal, Carb luôn là Amber, Fat luôn là Blue).
5. Tạo giao diện cầu vồng (mỗi card một màu sặc sỡ).
6. Sử dụng màu thuần (pure neon) với độ bão hòa quá cao trên diện tích lớn.
7. Đổi background chính sang màu sáng hoặc pure black `#000000`.
8. Tự ý phát minh mã màu ad-hoc ngoài Master Color Map.

---

### 12.5 Multi-Screen Consistency Rule
Tất cả các màn hình sau:
- Home
- Workout
- Workout Session
- Workout Schedule
- Exercise Library
- Muscle Distribution
- Nutrition
- Meal Planner
- AI Nutrition
- AI Coach
- History
- Profile
- Onboarding
- Authentication

**PHẢI sử dụng cùng một hệ design token thống nhất.** Tuyệt đối không tự tạo palette riêng cho từng màn hình.

---

---

# 13. Typography

The canonical typography is defined in:

```text
/mobile/lib/core/theme/app_theme.dart
```

Current hierarchy includes approximately:

```text
Display Large     57 / Regular
Display Medium    45 / Regular

Headline Large    32 / Extra Bold
Headline Medium   28 / Extra Bold
Headline Small    24 / Bold

Title Large       20 / Bold
Title Medium      16 / Semi Bold

Body Large        16 / Regular
Body Medium       14 / Regular

Label Large       14 / Semi Bold
```

Agents should use the existing theme:

```dart
Theme.of(context).textTheme
```

instead of creating arbitrary text styles.

---

# 14. Typography Rules

Use strong hierarchy.

Typical screen:

```text
Screen title
↓
Short supporting text
↓
Primary content
↓
Secondary information
↓
Primary CTA
```

Avoid:

- Too many font sizes.
- Huge titles on ordinary settings screens.
- Tiny unreadable labels.
- Bold typography everywhere.
- Different font families on different screens.
- Random letter spacing.

Do not add a new project-wide font unless explicitly requested.

---

# 15. Spacing System

Use a consistent spacing scale.

Preferred values:

```text
4
8
12
16
20
24
32
40
48
```

Default horizontal screen padding should normally be:

```text
16–20 px
```

Do not use arbitrary values such as:

```text
13
17
19
27
31
```

unless layout constraints genuinely require them.

Consistency is more important than microscopic visual differences.

---

# 16. Border Radius

The existing VieGym theme uses rounded geometry.

Canonical examples:

```text
Cards:          18px
Filled buttons: 16px
Elevated btn:   14px
Inputs:         14px
```

Agents should stay near these values.

Avoid mixing:

```text
4px
8px
17px
25px
34px
```

randomly across a single screen.

---

# 17. Cards

Card specifications:
- **Default Surface:** `neutral800` (`#17181B`) (tương thích `surfacePrimary` `#272633` trong theme hiện tại)
- **Border:** `neutral650` (`#292A2F`, 1px) (tương thích `borderDefault` `#373644`)
- **Border Radius:** `18px` (consistent project-wide)
- **Internal Spacing:** `16px` or `20px`
- **Elevated Surface:** `neutral750` (`#1C1D21`) (tương thích `surfaceElevated` `#2C2B39`)
- **Surface Strong:** `neutral700` (`#222327`)
- **Nested / Input Surface:** `neutral750` / `neutral700` (tương thích `surfaceNested` `#31303F`)

### Rules for Cards
- **No random colors:** Cards must NOT use random navy, pure gray, pitch black, or arbitrary hex codes.
- **Undertone consistency:** Mọi card và container phải mang cùng dark neutral undertone đồng bộ toàn app.
- **Card Color Rule:**
  * **Default Card:** Neutral Surface (`neutral800`).
  * **Special Card:** Neutral Surface + Subtle Accent (ví dụ: AI Card = neutral surface + violet accent/border; Nutrition Card = neutral surface + macro indicators; Workout Card = neutral surface + red CTA; Recovery Card = neutral surface + cyan/green indicator).
  * **TUYỆT ĐỐI KHÔNG TẠO:** Red Card, Purple Card, Blue Card, Orange Card đứng cạnh nhau như một dashboard sặc sỡ cầu vồng (Rainbow Dashboard).
- **No per-screen ad-hoc card colors:** Never hardcode a unique card color for each screen.
- Avoid "card inside card inside card" nesting.
- Do not wrap every single text item in an isolated card.

---

# 18. Buttons

Buttons must maintain strict project-wide consistency. Do NOT create differing styles across screens.

### 18.1 Primary Button (Filled — VieGym Red)
- **Quy tắc:** Chỉ dành cho hành động quan trọng nhất của màn hình. Hạn chế tối đa số lượng solid red primary button (tối ưu **1 button** duy nhất trong viewport).
- **Default Background:** `#F2305A` (Primary)
- **Pressed State:** `#C32649` (Primary Pressed)
- **Disabled State:** Background theo neutral surface (`#31303F`), text theo disabled text token (`#74727F`)
- **Text:** `#FFFFFF` (Bold / SemiBold, 16px)
- **Minimum Height:** `52px`
- **Border Radius:** `16px`
- **Fitbod Consistency:** Primary button phải trông chuẩn sắc đỏ crimson/cool red `#F2305A`. Không blend `#F2305A` với orange hoặc brown-red.
- **Ví dụ hành động:** "Bắt đầu tập", "Tiếp tục", "Tạo buổi tập", "Lưu", "Hoàn tất", "Tạo kế hoạch", "Tạo bằng AI".

### 18.2 Secondary Button (Surface / Outlined — Neutral)
- **Quy tắc:** **Tuyệt đối KHÔNG dùng solid red.** Dành cho các hành động phụ, điều hướng thứ cấp.
- **Background:** Neutral surface (`#272633` hoặc `#2C2B39`) hoặc `Colors.transparent`
- **Border:** `#373644` (Default Border) hoặc `#464553` (Strong Border, 1px)
- **Text:** `textPrimary` (`#FFFFFF` hoặc `#F3F2F5`)
- **Minimum Height:** `48px`–`52px`
- **Border Radius:** `16px`
- **Ví dụ hành động:** "Xem chi tiết", "Đổi bài", "Lịch sử", "Chỉnh sửa", "Xem tất cả".

### 18.3 Tertiary Button (Ghost / Text Button)
- **Quy tắc:** **Không có background.** Giảm tối đa sự cạnh tranh thị giác.
- **Background:** `Colors.transparent`
- **Border:** `none`
- **Text:** `textPrimary` (`#FFFFFF`) hoặc `textSecondary` (`#9B99A5`) tùy mức độ ưu tiên
- **Ví dụ hành động:** "Bỏ qua", "Hủy", "Để sau", "Chi tiết thêm".

### 18.4 Selected Filter / Toggle Button (Chips & Segmented Controls)
- **Background:** `#43202C` (Primary Soft)
- **Border:** `#A72A49` (Primary Border) hoặc `#F2305A` (Primary)
- **Text:** `#FFFFFF`
- **Icon:** `#F2305A`
- **Border Radius:** `16px`

### 18.5 Destructive Button (Error Semantic Color)
- **Quy tắc:** **Destructive action PHẢI có hierarchy riêng. KHÔNG dùng style Primary Brand Red CTA.**
- **Color Token:** Sử dụng Error Semantic Color (`#EF5565`).
- **Style:** Neutral surface với border/text `#EF5565`, hoặc nền mềm `#EF5565` với low opacity.
- **Ví dụ hành động:** "Xóa buổi tập", "Xóa tài khoản", "Hủy toàn bộ dữ liệu". Brand action và destructive action phải nhìn khác biệt hoàn toàn về ngữ nghĩa.

---

# 19. Inputs

Input fields follow:
- **Outer Set Container:** `#272633`
- **Input Field Background:** `#2C2B39` (Elevated Surface) / `#292835` (Input Surface)
- **Border:** `#373644` (Default Border, 1px)
- **Focused Border:** `#F2305A` (Primary)
- **Text:** `#FFFFFF` (Primary Text)
- **Label:** `#9B99A5` (Secondary Text)
- **Hint / Placeholder:** `#74727F` (Tertiary Text)
- **Border Radius:** `14px`
- **Padding:** Horizontal `16px`, Vertical `14px`

For onboarding screens with a single numeric/text input, it is acceptable to create a more focused input presentation if requested.

However:
- Preserve validation.
- Preserve controller/state behavior.
- Preserve accessibility.
- Preserve keyboard behavior.
- Preserve submit logic.

---

# 20. Navigation

The existing navigation architecture must be preserved.

VieGym uses:

```text
go_router
```

Agents must not:

- Rename routes without explicit instruction.
- Replace go_router.
- Create a second parallel navigation system.
- Break deep-link or redirect logic.
- Change navigation behavior merely to redesign a screen.

---

# 21. Bottom Navigation

Bottom Navigation is a key persistent navigation element across the application, styled in Fitbod dark UI fashion:

- **Background:** `#191922` (Deep Background)
- **Top Border:** `#373644` (Default Border)
- **Active Icon:** `#F2305A` (Primary)
- **Active Label:** `#FFFFFF` (Primary Text)
- **Inactive Icon:** `#74727F` (Tertiary Text)
- **Inactive Label:** `#74727F` (Tertiary Text)
- **Selected Navigation Container:** Background `#35202A` (Primary Surface), Border `#A72A49` (Primary Border).
- **No heavy red glow:** Không tạo glow đỏ mạnh; nếu có, chỉ dùng `#F2305A` với opacity rất thấp.

Agents must keep bottom navigation visually consistent between main tabs. Do not redesign it independently for a single tab.

---

# 22. State Management

VieGym currently uses Riverpod.

Agents MUST NOT introduce:

- Bloc
- GetX
- MobX
- Redux
- Provider replacement
- another state-management architecture

unless explicitly requested.

Reuse the existing Riverpod architecture.

---

# 23. API Integration

The mobile app communicates with the Spring Boot backend.

Generated API code may exist under:

```text
/mobile/lib/api/generated
```

Do not manually redesign generated API files.

Do not change API contracts when the request is only UI-related.

Do not change request/response models just to simplify frontend implementation.

---

# 24. Backend Protection Rule

If a task is specifically about UI:

**Do NOT modify `/backend`.**

Do not change:

- Controllers.
- Services.
- DTOs.
- Entities.
- Security.
- JWT handling.
- Database migrations.
- API contracts.

unless the requested UI change genuinely requires a backend change and the user explicitly authorizes it.

---

# 25. AI Service Protection Rule

If a task is specifically about UI:

**Do NOT modify `/ai-service`.**

AI interface improvements should normally affect Flutter presentation only.

Do not modify AI prompts, provider logic, FastAPI routes, or AI contracts merely because an AI screen is being redesigned.

---

# 26. Generated Code Rule

Generated code should be treated as generated code.

Before modifying a generated file:

1. Determine the source generator.
2. Determine whether the change belongs in the source schema/config instead.
3. Avoid manually editing generated output unless absolutely necessary.

---

# 27. Existing Screen Modification Workflow

Before editing an existing screen, the agent MUST:

1. Read `AI_RULES.md`.
2. Locate the target Flutter screen.
3. Read the complete screen implementation.
4. Inspect widgets used by that screen.
5. Inspect related provider/state/controller logic.
6. Inspect nearby screens in the same flow.
7. Inspect `/mobile/lib/core/theme/app_theme.dart`.
8. Identify existing reusable components.
9. Determine the smallest safe change set.
10. Implement only what is required.

---

# 28. Minimum Change Principle

When the user requests:

> "Change the nickname input design."

Do NOT interpret this as:

> "Redesign the entire onboarding."

When the user requests:

> "Improve this card."

Do NOT interpret this as:

> "Rewrite the entire dashboard."

Make the minimum changes necessary to satisfy the request well.

---

# 29. Preserve Business Logic

UI redesigns must preserve:

- Existing state.
- Validation.
- API calls.
- Data models.
- Loading states.
- Error handling.
- Navigation.
- Persistence.
- User data.
- Analytics hooks if present.
- Existing completed functionality.

When possible, isolate visual changes from business logic.

---

# 30. Shared Component Rule

Before building a new widget:

1. Search `/mobile/lib/shared`.
2. Search the current feature's widgets/components.
3. Search for an existing equivalent widget.
4. Reuse or extend it if appropriate.
5. Create a new component only when reuse would make the code worse.

Do not duplicate nearly identical widgets across multiple screens.

---

# 31. Global Theme Rule

Do NOT modify:

```text
/mobile/lib/core/theme/app_theme.dart
```

for a request affecting only one screen unless there is a clear design-system reason.

Changing the global theme can unintentionally alter every screen.

If a global token change is genuinely required:

- Explain why.
- Verify affected shared widgets.
- Verify important screens.
- Keep backward compatibility whenever possible.

---

# 32. Onboarding Design Rules

Onboarding should feel:

- Friendly.
- Focused.
- Motivational.
- Calm.
- Premium.
- Easy to complete.

Each onboarding screen should primarily focus on **one question or one decision**.

Examples:

- Nickname.
- Age.
- Height.
- Current weight.
- Target weight.
- Fitness goal.
- Training experience.
- Available equipment.
- Preferred workout schedule.

Avoid excessive cards and explanations.

---

# 33. Onboarding Layout Guidance

Preferred pattern:

```text
Progress / Back
        ↓
Question / Title
        ↓
Short explanation
        ↓
Main interaction
        ↓
Optional supporting information
        ↓
Primary CTA
```

The main interaction should be visually dominant.

Examples:

For nickname:

```text
What's your nickname?
      HUY
   ─────────
```

For target weight:

```text
Target weight

      70 kg

────|────|────|────
```

The user should immediately understand what to do.

---

# 34. Workout UI Rules

During an active workout, prioritize:

1. Current exercise.
2. Exercise media/instructions.
3. Sets.
4. Reps.
5. Weight.
6. Completed sets.
7. Workout progress.
8. Next exercise.
9. Exercise replacement when available.

The UI should be usable while the user is tired or moving.

Therefore:

- Large touch targets.
- Clear numbers.
- Minimal unnecessary typing.
- Important actions reachable with one hand where possible.
- Avoid dense paragraphs.
- Avoid hidden primary actions.

---

# 35. Exercise Cards & Muscle Highlight

Exercise cards should clearly communicate:

- Exercise name.
- Target muscle.
- Equipment.
- Sets/reps when relevant.
- Completion state.
- Exercise image/video where relevant.
- Replace/swap action where supported.

Do not overload cards with every available metric.

### 35.1 Workout Card Specifications
- **Default Workout Card:** `#272633` (Primary Surface / Card)
- **Selected Workout Card:** Background Neutral Surface (`#272633`) hoặc subtle `#35202A` (Primary Soft), Border `#A72A49` (Primary Border), Title dùng `textPrimary` (`#FFFFFF`), Active indicator/badge `#F2305A`.
- **Important CTA:** `#F2305A`.
- **Không biến card thành màu đỏ nguyên khối hay màu nâu/đỏ gạch.** Giữ card clean, tối giản và cao cấp.

### 35.2 Workout Session Specifications
- **Active Exercise Card:**
  * Background: `#272633` (Primary Surface) hoặc subtle `#35202A` (Primary Soft)
  * Border: `#A72A49` (Primary Border) hoặc `#F2305A` (1px accent border)
  * Title: `#FFFFFF` (textPrimary — **KHÔNG dùng VieGym Red cho card title/heading**)
  * Number Badge / Indicator: `#F2305A` (Accent indicator duy nhất để báo hiệu bài tập hiện tại)
  * Subtitle / Metadata: `#9B99A5` (Secondary Text)
- **Inactive Exercise Card:**
  * Background: `#272633` (Primary Surface)
  * Border: `#373644` (Default Border)
  * Title: `#F3F2F5` (Primary Soft Text)
  * Subtitle: `#74727F` (Tertiary Text)

### 35.3 Muscle Highlight System
When rendering anatomical muscle maps (SVG / CustomPaint):
- **Active Target Muscle (Primary):** `#F2305A` (Muscle Primary Highlight)
- **Secondary / Highlight Muscle:** `#F4476D` (Muscle Secondary Highlight)
- **Inactive Muscle:** `#686777` (neutral gray phù hợp SVG asset).
- **Muscle Illustration Background:** `#22212D` (Secondary Background).
- **Không dùng màu đỏ cam cũ:** Tuyệt đối không dùng màu đỏ cam cũ cho muscle SVG.
- **Consistency:** The muscle visualizer MUST remain identical in style and color across:
  * Workout Overview
  * Exercise Detail
  * Active Workout Session
  * Exercise Library
  * AI Coach recommendations

---

# 36. Nutrition UI Rules

Nutrition screens should prioritize:

```text
Calories
Protein
Carbohydrates
Fat
```

Macro values should be scannable.

Vietnamese dishes should be presented using familiar Vietnamese naming.

Avoid turning nutrition screens into an e-commerce aesthetic.

---

# 37. Macro & Nutrition Color Rule

Nutrition components MUST follow **section 11.2 — Nutrition Data Rules**, including its final color map, token aliases, card usage, chart precedence and accessibility rules. This reference replaces the previous duplicated macro palette; do not define a separate nutrition mapping here.

---

# 38. AI Feature UI & AI Coach Rules

AI is an important VieGym capability with a dedicated accent identity:

- **AI Primary Accent:** Violet (`#9B7BFF`, `violetSoft: rgba(155, 123, 255, 0.12)`, `violetBorder: rgba(155, 123, 255, 0.25)`)
- **Secondary Accent:** VieGym Brand Red (`#F2305A`)

### AI Accent Permitted Elements:
- AI badge / chip (e.g. "AI Coach", "AI Suggestion").
- Sparkle icon / AI avatar detail.
- Insight indicator or subtle border accent.
- AI-generated suggestion highlight container (using `violetSoft`).

### AI Accent Prohibitions:
- **DO NOT turn entire AI pages or cards into purple solid blocks.** Backgrounds must remain standard Dark Neutral (`neutral900` / `neutral800`).
- AI recommendations must communicate clearly and explainably:

```text
Recommendation
↓
Reason
↓
Suggested Action
```

AI recommendations should always be explainable and transparent.

### AI Component Rules:
- **Brand consistency & Secondary Identity:** AI components sử dụng Primary Brand Color (`#F2305A`) kết hợp với neutral surfaces (`#272633`, `#2C2B39`).
- **AI Secondary Accent:** Cho phép sử dụng một **accent Violet / Purple nhẹ** kết hợp VieGym Red cho:
  * AI icon
  * AI badge
  * AI indicator
  * Special AI action
- **AI Card Surface:** Nền card AI vẫn phải chủ yếu dùng **neutral surface** (`#272633` / `#2C2B39`).
- **KHÔNG ĐƯỢC:**
  * Biến toàn bộ màn hình AI thành gradient tím/đỏ.
  * Dùng gradient trên mọi card.
  * Làm màu AI cạnh tranh với Primary CTA.
  * Dùng neon glow sặc sỡ biến AI Coach thành một app hoàn toàn khác.
- Clearly distinguish:
  * AI recommendation.
  * Existing plan.
  * User choice.
  * Applied changes.

---

# 39. AI Personalization States

Where applicable, preserve distinctions such as:

```text
PENDING
APPLIED
DISMISSED
EXPIRED
```

Do not collapse meaningful product states for visual convenience.

---

# 40. Empty States

Empty states should:

- Explain what is missing.
- Provide one useful next action.
- Avoid looking like an error when nothing is actually wrong.

Example:

```text
Bạn chưa có lịch tập hôm nay.

[Tạo lịch tập]
```

Better than an empty blank container.

---

# 41. Loading States

Long-running operations should show feedback.

Preferred:

- Skeleton.
- Inline progress.
- Button loading state.
- Small progress indicator.

Avoid blocking full-screen loaders for minor actions.

---

# 42. Error States

Errors must be understandable.

Prefer:

```text
Không thể tải dữ liệu.
Thử lại
```

over raw technical messages.

Do not expose:

- Stack traces.
- Internal exception strings.
- Backend implementation details.
- Sensitive server responses.

---

# 43. Accessibility & Contrast

All UI changes must strictly prioritize high visual contrast and accessibility on dark backgrounds:

- **Contrast priority:** Text on dark surfaces must maintain high contrast (WCAG AA standard). Small text must be effortlessly readable against dark backgrounds (`neutral900` / `#0F1012`) and card surfaces (`neutral800` / `#17181B` or `#272633`).
- **Legibility constraints:**
  - DO NOT use overly dark gray text on dark surfaces (text must never blend indistinctly into the card).
  - DO NOT use low-opacity text for essential information.
  - DO NOT pair bright red with pure white text if contrast is compromised.
  - Text nhỏ phải luôn ưu tiên độ dễ đọc (readability) hơn tính trang trí màu sắc.
- **Primary CTA readability:** Primary buttons MUST use `#F2305A` background with `#FFFFFF` (`textOnPrimary`) for maximum visual clarity.
- **Touch target size:** Minimum 48–52px touch targets for buttons and interactive controls.
- **Dynamic layout & Safe areas:** Respect notch, home indicator, keyboard overlap, and long Vietnamese text labels without clipping.
- Do not design only for one simulator resolution.

---

# 44. Responsive Mobile Layout

VieGym is a mobile-first application.

Screens should work across common phone sizes.

Do not hardcode major layout dimensions based solely on one iPhone simulator.

Prefer:

- Expanded.
- Flexible.
- LayoutBuilder.
- MediaQuery where appropriate.
- SafeArea.
- Scrollable layouts where content may exceed the viewport.

Avoid fixed pixel positioning for major components.

---

# 45. iOS and Android

UI should remain functional on both platforms unless a feature is explicitly platform-specific.

Consider:

- Safe area.
- Keyboard.
- Back navigation.
- Status bar.
- Bottom gesture area.
- Text scaling.

Do not fix an iOS visual issue by breaking Android.

---

# 46. Animations

Animations should be:

- Smooth.
- Short.
- Intentional.
- Subtle.

Good uses:

- Selection changes.
- Progress transitions.
- Expand/collapse.
- Button feedback.
- Page state changes.

Avoid:

- Excessive bouncing.
- Constant glowing.
- Long cinematic transitions.
- Animating every element on screen.

---

# 47. Icons

Use the icon family already used by the application whenever possible.

Avoid mixing many unrelated icon styles.

Icons must communicate function clearly.

Do not replace text with ambiguous icons for important actions.

---

# 48. Images and Exercise Media

Images/videos must:

- Preserve aspect ratio.
- Avoid distortion.
- Load gracefully.
- Provide placeholders/fallbacks when needed.

Exercise media should support understanding the movement, not merely decorate the screen.

---

# 49. Vietnamese UX

VieGym primarily targets Vietnamese users.

User-facing copy should generally be natural Vietnamese unless a screen is intentionally English.

Avoid literal machine-translated Vietnamese.

Prefer concise language.

Example:

Good:

```text
Cân nặng mục tiêu
```

Less desirable:

```text
Mục tiêu của trọng lượng cơ thể của bạn
```

---

# 50. Do Not Invent Product Behavior

If the UI request does not define behavior:

- Inspect existing behavior.
- Preserve it.

Do not invent:

- New APIs.
- New onboarding questions.
- New business rules.
- New subscription/paywall behavior.
- New AI behavior.
- New navigation flows.

unless needed to fulfill an explicit user request.

---

# 51. Do Not Remove Features

Unless explicitly requested:

NEVER remove existing:

- Buttons.
- Navigation.
- Form fields.
- Validation.
- Workout controls.
- Nutrition controls.
- AI actions.
- History.
- Settings.
- Profile data.
- API integrations.

A redesign should not silently reduce functionality.

---

# 52. Forbidden Changes for UI-Only Tasks

For UI-only requests, the agent MUST NOT:

- Rewrite the whole project.
- Replace Riverpod.
- Replace go_router.
- Replace Dio.
- Change backend APIs.
- Modify DB schema.
- Rename routes.
- Rename models without reason.
- Delete working screens.
- Delete validation.
- Remove error states.
- Remove loading states.
- Change authentication flow.
- Add unrelated dependencies.
- Modify unrelated features.
- Change the entire color palette.
- Introduce a second design system.

---

# 53. Package Dependency Rule

Do not add a Flutter package merely to implement a minor visual detail.

Before adding a dependency, check whether Flutter already supports the behavior.

If a package is required:

- Prefer actively maintained packages.
- Avoid huge dependencies for tiny features.
- Confirm compatibility with the existing Flutter SDK.
- Explain why the dependency is needed.

---

# 54. Code Quality

UI code should remain:

- Readable.
- Modular.
- Testable.
- Consistent with existing code.
- Free from unnecessary duplication.

Avoid giant `build()` methods when meaningful subcomponents can improve readability.

However, do not over-engineer simple screens.

---

# 55. Comments

Comments should explain WHY, not obvious WHAT.

Avoid:

```dart
// Create a container
Container(...)
```

Useful:

```dart
// Keep CTA above the iOS home indicator while preserving onboarding spacing.
```

---

# 56. File Scope

Before editing, identify the files that are truly necessary.

For a small screen UI change, typically modify:

```text
1–3 files
```

not dozens.

A large diff is not automatically a better solution.

---

# 57. Existing UI Takes Priority

When a prompt includes a reference image:

Use the image to understand:

- Layout.
- Hierarchy.
- Interaction.
- Visual emphasis.

But preserve VieGym:

- Colors.
- Typography.
- Navigation.
- Components.
- Product identity.

Do not blindly reproduce the reference application's visual identity.

---

# 58. Reference Image Rule

If the user says:

> "Make this look like image 2."

Interpret it as:

> Use image 2 as a layout/UX reference while keeping VieGym's design system.

Do NOT:

- Copy unrelated colors.
- Copy brand logos.
- Copy another app's navigation.
- Replace VieGym design tokens.
- Rebuild unrelated parts of the screen.

---

# 59. Visual Improvement Rule

Agents are allowed to improve details not explicitly specified only when they are clearly within the same requested component.

Examples:

Allowed:

- Slightly improve spacing around the requested nickname input.
- Improve visual alignment of the requested weight ruler.
- Fix minor overflow directly caused by the redesigned component.

Not allowed:

- Redesign dashboard while editing onboarding.
- Change bottom navigation while editing a workout card.
- Replace the global theme while changing a single input.

---

# 60. Completion Checklist

Before declaring a task complete, verify:

### UI

- [ ] Matches VieGym design language.
- [ ] Uses existing theme colors.
- [ ] Text hierarchy is consistent.
- [ ] Spacing is consistent.
- [ ] No overflow.
- [ ] Works on common phone sizes.
- [ ] Safe areas are respected.
- [ ] Keyboard does not break layout.

### Functionality

- [ ] Existing actions still work.
- [ ] Navigation still works.
- [ ] Validation still works.
- [ ] State is preserved.
- [ ] API calls are preserved.
- [ ] Loading/error behavior is preserved.

### Code

- [ ] No unnecessary package added.
- [ ] No unrelated files changed.
- [ ] No duplicate component created unnecessarily.
- [ ] Flutter analyzer issues were not introduced.
- [ ] Formatting remains consistent.

---

# 61. Agent Output Requirement

After making code changes, the agent must provide a concise report.

Required format:

```text
Implementation summary

Modified files:
- ...

Created files:
- ...

Reused components:
- ...

UI changes:
- ...

Behavior changes:
- None / describe if applicable

Business logic:
- Preserved

Navigation:
- Preserved

API contracts:
- Preserved
```

If business logic was not intentionally modified, explicitly state:

```text
Business logic preserved.
```

---

# 62. Required Agent Instruction

For every Antigravity task, use this instruction at the beginning of the prompt:

```text
Before making any changes, read /AI_RULES.md completely and follow it as the authoritative project, Flutter, architecture, and VieGym UI/UX rule set.

Inspect the current implementation before editing.
Preserve existing business logic, navigation, state management, API integrations, and unrelated UI.
Make the minimum safe change required by this task.
```

---

# 63. Source of Truth Priority

When multiple sources disagree, follow this priority:

```text
1. Explicit current user request
2. Existing working application behavior
3. AI_RULES.md
4. Current Flutter theme/design system
5. Project specification/docs
6. Reference screenshots/apps
7. Agent assumptions
```

Agent assumptions always have the lowest priority.

---

# 64. Design Token Source of Truth & Flutter Implementation Rules

The canonical source of truth for Flutter colors will reside in:

```text
/mobile/lib/core/theme/app_theme.dart (and associated AppColors tokens)
```

### 64.1 Canonical Design Tokens (Standardized Master Palette)
```text
# CORE BRAND TOKENS
primary                     #F2305A
primaryHover                #D52B50
primaryPressed              #C32649
primarySoft                 rgba(242, 48, 90, 0.12) / #2D141C
primaryBorder               rgba(242, 48, 90, 0.25) / #4D1A25
primaryHighlight            #F4476D
primarySurface              #221318
textOnPrimary               #FFFFFF

# DARK NEUTRAL SYSTEM (14 steps)
neutral950 (Canvas)         #0B0C0E
neutral900 (Background)     #0F1012 (Legacy: #1F1E2A)
neutral850                  #131417
neutral800 (Card/Surface)   #17181B (Legacy: #272633)
neutral750 (Elevated Card)  #1C1D21 (Legacy: #2C2B39)
neutral700 (Surface Strong) #222327 (Legacy: #31303F)
neutral650 (Default Border) #292A2F (Legacy: #373644)
neutral600 (Border Strong)  #34363B (Legacy: #464553)
neutral500 (Text Muted)     #62656B (Legacy: #74727F)
neutral400                  #8A8D93
neutral300 (Text Secondary) #A7A9AE (Legacy: #9B99A5)
neutral200                  #C9CBD0
neutral100                  #E3E4E7
neutral50  (Text Primary)   #F5F5F6 (Legacy: #FFFFFF)

# SEMANTIC TOKENS
success                     #35C76F
successSoft                 rgba(53, 199, 111, 0.12)
successBorder               rgba(53, 199, 111, 0.25)

warning                     #F4B740
warningSoft                 rgba(244, 183, 64, 0.12)
warningBorder               rgba(244, 183, 64, 0.25)

info                        #4D8DFF
infoSoft                    rgba(77, 141, 255, 0.12)
infoBorder                  rgba(77, 141, 255, 0.25)

error (Destructive)         #FF5A5F
errorSoft                   rgba(255, 90, 95, 0.12)
errorBorder                 rgba(255, 90, 95, 0.25)

# SUPPORTING ACCENT TOKENS
blue (Info/Fat/Metrics)       #4D8DFF
cyan (Recovery/Protein/Time)   #2CC7B5
green (Success/Goals)         #35C76F
amber (Warning/Limit)         #F4B740
orange (Energy/Streak)        #F28C38 (Never brand/CTA)
violet (AI Coach/Insights)    #9B7BFF
pink (Special Achievement)    #E66BC5 (Rare accent only)

# NUTRITION MACRO TOKENS (semantic aliases; usage and variants: section 11.2)
nutritionCalories           textPrimary / neutral50 (target #F5F5F5; reuse #F5F5F6)
nutritionProtein            cyan  #2CC7B5
nutritionCarbs              amber #F4B740 (nutritionCarb is an equivalent alias)
nutritionFat                blue  #4D8DFF
nutritionFiber              green #35C76F
nutritionWater              #55B7FF (Light Blue)
# Soft / Border aliases and opacity ranges are defined in section 11.2.
```

### 64.2 Centralized Color Architecture Rule
Khi agent thực hiện code Flutter sau này:
- **KHÔNG ĐƯỢC hard-code** `Color(0xFFF2305A)` hoặc mã HEX trực tiếp rải rác trong các widget.
- **BẮT BUỘC thông qua centralized token** như `AppColors` hoặc `Theme.of(context).colorScheme`.
- Các biến thể phải sử dụng semantic tokens đầy đủ:
  * `backgroundPrimary`, `backgroundDeep`, `backgroundSecondary`
  * `surfacePrimary`, `surfaceElevated`, `surfaceNested`, `surfaceInput`
  * `primary`, `primaryHighlight`, `primaryDark`, `primaryPressed`, `primarySoft`, `primarySurface`, `primaryBorder`
  * `textPrimary`, `textSecondary`, `textTertiary`, `textDisabled`, `textInverse`
  * `borderDefault`, `borderStrong`, `borderSubtle`
  * `success`, `warning`, `error`, `information`
  * `nutritionProtein`, `nutritionCarbs`, `nutritionFat`, `nutritionFiber`, `nutritionWater`, `nutritionCalories`
  * `accentBlue`, `accentCyan`, `accentGreen`, `accentAmber`, `accentOrange`, `accentViolet`, `accentPink`

### 64.3 Multi-Screen Consistency Rule
The exact same design system and color palette must be shared across all modules without exception:
- Home
- Workout
- Workout Session
- Exercise Detail
- Exercise Library
- Workout Schedule
- Nutrition
- Meal Planner
- AI Nutrition
- AI Coach
- Profile
- Statistics
- Settings
- Onboarding

No screen or module is permitted to create its own independent color palette.

---

# 65. Strict Rule for Future AI Agents

Starting from this update:
1. **Mandatory Reading:** Every agent modifying VieGym frontend code MUST read `AI_RULES.md` before making any modifications.
2. **Precedence:** If a new user UI prompt appears to contradict the design system in `AI_RULES.md`, the agent must adhere to `AI_RULES.md` unless the user explicitly commands a design system change.
3. **Forbidden Actions:** Agents must NEVER independently:
   - Thay đổi Primary Brand Color (`#F2305A`).
   - Sử dụng các màu đỏ ngả cam/gạch (`#CE3A31`, `#BE4639`, `#D9483B`, `#C84B3C`, `#E04A3A`).
   - Nhầm lẫn VieGym Brand Red (`#F2305A`) với Error Red (`#FF5A5F`). Brand Red chỉ dành cho CTA/branding, Error Red dành cho lỗi/destructive.
   - Dùng Orange (`#F28C38`) thay thế VieGym Red cho Primary CTA hoặc Navigation.
   - Biến giao diện thành Rainbow UI (nhiều màu sặc sỡ trên cùng 1 card/màn hình).
   - Đổi màu macro dinh dưỡng giữa các màn hình (Calories = White, Protein = Cyan / Teal, Carbs = Amber, Fat = Blue, Fiber = Green, Water = Light Blue).
   - Tự ý tạo màu nền card riêng cho từng màn hình.
   - Tự ý tạo kiểu nút bấm ad-hoc.
   without explicit, justified instructions.

---

# 66. Final Principle

The most important rule when working on VieGym is:

> **Improve the requested part without making the rest of the application feel like a different product.**

Every screen should look and behave as if it belongs to the same VieGym application.

Consistency > novelty.

Clarity > decoration.

Functionality > visual tricks.

Minimal safe changes > unnecessary rewrites.
