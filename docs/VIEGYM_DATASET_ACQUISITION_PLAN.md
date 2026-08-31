# VieGym — Kế hoạch thu thập và triển khai dữ liệu Exercise, Equipment và Food

> **Phiên bản:** 1.0
> **Ngày:** 2026-08-31
> **Phạm vi:** Dataset phục vụ MVP P0 theo SRS v3.2
> **Đối tượng:** Exercise, Equipment, Muscle Group và Food Việt Nam
> **Không thuộc phạm vi tài liệu:** Barcode, branded product, avatar media, Water Tracker và các tính năng P1/P2

---

## 1. Mục tiêu

Tạo dữ liệu đủ sạch để VieGym có thể:

- tìm kiếm và lọc bài tập;
- lọc bài theo thiết bị user đã chọn;
- hiển thị nhóm cơ và body muscle map;
- tạo chương trình/lịch tập;
- thay thế bài tập theo muscle, movement pattern và equipment;
- lưu Favorite Exercise/Food;
- tạo Meal Entry và Nutrition Summary;
- cung cấp candidate ID hợp lệ cho AI;
- giữ PostgreSQL là nguồn dữ liệu authoritative duy nhất khi runtime.

Không đưa raw dataset trực tiếp vào PostgreSQL production và không để Mobile hoặc FastAPI đọc raw file.

```text
External sources
      ↓
Pinned raw snapshot + manifest
      ↓
Python ETL: normalize → merge → validate
      ↓
VieGym processed dataset có version
      ↓
Spring Boot importer idempotent
      ↓
PostgreSQL
      ↓
/api/v1 → Flutter
      ↓
Backend candidate shortlist → FastAPI
```

---

## 2. Source of truth và nguyên tắc không được phá vỡ

Thứ tự ưu tiên khi có mâu thuẫn:

1. Yêu cầu hiện tại của user.
2. `AI_RULES.md`.
3. `docs/spec/specs.md`.
4. `docs/kientruchatang/DATABASE.md`.
5. `docs/kientruchethong/API_SPEC.md`.
6. `docs/Project_Progress.md`.
7. Tài liệu dataset và dữ liệu external.

Quy tắc bắt buộc:

- Giữ `BIGINT` identity làm primary key trong PostgreSQL.
- External ID chỉ dùng cho provenance và import idempotent.
- Giữ tên bảng canonical của dự án.
- Không tạo `user_equipment`; dùng `user_equipment_preferences` đã có.
- Không tạo `muscles`; dùng `muscle_groups`.
- Không tạo `exercise_muscles`; dùng `exercise_muscle_groups`.
- P0 Nutrition dùng `foods`, không thay bằng runtime schema `ingredients + dishes`.
- Mobile chỉ gọi Spring Boot `/api/v1`.
- FastAPI không có PostgreSQL credential và không query dataset trực tiếp.
- AI chỉ được trả ID thuộc candidate shortlist do Spring Boot gửi.
- Flyway chỉ quản lý schema và lookup nhỏ; không nhét hàng trăm/hàng nghìn bản ghi vào migration.
- Không sửa migration đã chạy. Migration mới dùng version trống tiếp theo tại thời điểm triển khai.

---

## 3. Mục tiêu dữ liệu theo từng cấp

### 3.1. Golden Dataset — dùng để unblock Backend và demo

- 120 Exercise được review thủ công.
- 20–30 Equipment phổ biến.
- Khoảng 20 Muscle Group/code canonical.
- 60–100 Food Việt Nam phổ biến được review serving và macro.
- Không bắt buộc có external image/video.

Golden Dataset phải bao phủ:

- Chest, Back, Shoulders, Biceps, Triceps.
- Quadriceps, Hamstrings, Glutes, Calves.
- Abs/Core và Cardio cơ bản.
- Bodyweight, Dumbbell, Barbell, Bench, Cable, Machine, Resistance Band, Kettlebell và Pull-up Bar.
- Các món sáng, trưa, tối, snack phổ biến của người Việt.

### 3.2. MVP Dataset — hoàn thành trước khi đóng M4/M5

- 300–500 Exercise đã qua structural validation.
- 20–30 Equipment active; có thể mở rộng tối đa khoảng 40–60 sau MVP.
- 150–300 Food Việt Nam hoặc nguyên liệu/món ăn đã flatten thành `foods` P0.
- Mọi record `PUBLIC` phải có tên tiếng Việt đã review.
- Mọi nutrition value phải có source hoặc ghi rõ `is_estimated=true`.

### 3.3. Sau MVP

- Exercise: mở rộng dần lên 1.000+.
- Food: mở rộng theo nhu cầu thực tế và số liệu sử dụng.
- Ingredient/Dish composition chi tiết chỉ thực hiện sau ADR riêng; không tự đưa vào P0.
- Media expansion thực hiện qua PH9/M7, không để chặn Exercise/Food API.

---

## 4. Nguồn dữ liệu Exercise

### 4.1. Free Exercise DB — nguồn metadata/enrichment ưu tiên

Nguồn:

- Repository: <https://github.com/yuhonas/free-exercise-db>
- Combined JSON: <https://github.com/yuhonas/free-exercise-db/blob/main/dist/exercises.json>
- License: Unlicense/public domain theo repository.

Có thể lấy:

- tên bài tập;
- difficulty/level;
- force;
- mechanic;
- equipment;
- primary/secondary muscles;
- instructions;
- category.

Không được giả định dữ liệu hoàn hảo:

- `force`, `mechanic` và `equipment` có thể null;
- một số image có thể trùng;
- tên muscle/equipment vẫn cần canonical mapping;
- không import image trước khi xác minh provenance của từng nhóm asset.

### 4.2. exercises-dataset-main — nguồn bổ sung coverage/instruction

Nguồn:

- Repository: <https://github.com/plataformafitness/exercises-dataset-main>
- Data: `data/exercises.json` trong repository.

Có thể lấy:

- metadata của khoảng 1.324 Exercise;
- target/body part/equipment;
- instruction text;
- external ID để cross-match.

Điều kiện:

- pin commit SHA cụ thể;
- lưu checksum file raw;
- lưu bản license/NOTICE tại thời điểm download;
- metadata/instruction chỉ được dùng theo điều khoản của snapshot đã pin;
- không lấy image/GIF Gym Visual nếu VieGym chưa có license riêng;
- giữ attribution nếu điều khoản yêu cầu.

### 4.3. Vai trò của hai nguồn

Không chọn source nào làm dữ liệu production trực tiếp.

```text
Free Exercise DB
      +
exercises-dataset-main metadata
      ↓
VieGym matching/merge rules
      ↓
VieGym Exercise Dataset v1
```

Nguyên tắc merge:

- Match bằng normalized name + equipment + primary muscle.
- Không merge chỉ vì tên gần giống.
- Nếu muscle/equipment xung đột, record phải vào manual review.
- Dữ liệu VieGym đã review luôn có ưu tiên cao hơn external source.
- Không để source enrichment tự ghi đè field đã được VieGym verify.

---

## 5. Cách tạo Equipment Dataset

Không cần tải thêm một equipment dataset độc lập.

Equipment được tạo từ:

1. Catalog đã seed tại `V5__equipment_catalog_seed.sql`.
2. Giá trị equipment xuất hiện trong hai Exercise source.
3. Mapping thủ công do VieGym review.
4. Multi-equipment rule của từng Exercise.

Catalog hiện có phải được giữ:

- `BODYWEIGHT`
- `DUMBBELL`
- `BARBELL`
- `BENCH`
- `CABLE_MACHINE`
- `MACHINE`
- `RESISTANCE_BAND`
- `KETTLEBELL`
- `PULL_UP_BAR`
- `TREADMILL`

Có thể bổ sung bằng migration mới khi thật sự cần, ví dụ:

- `ADJUSTABLE_BENCH`
- `EZ_BAR`
- `SMITH_MACHINE`
- `LEG_PRESS`
- `LAT_PULLDOWN`
- `SEATED_ROW`
- `DIP_STATION`
- `GYM_MAT`
- `EXERCISE_BIKE`
- `ROWING_MACHINE`

Không tạo equipment theo tên hãng hoặc model máy.

### 5.1. Equipment mapping

Ví dụ processed mapping:

```json
{
  "dumbbell": "DUMBBELL",
  "dumbbells": "DUMBBELL",
  "db": "DUMBBELL",
  "body weight": "BODYWEIGHT",
  "bodyweight": "BODYWEIGHT",
  "cable": "CABLE_MACHINE",
  "leverage machine": "MACHINE"
}
```

Mọi raw value chưa có mapping phải làm validator fail. Không tự map unknown value thành `MACHINE` nếu chưa review.

### 5.2. Multi-equipment

Raw source thường chỉ ghi một equipment, nhưng VieGym phải lưu tất cả equipment bắt buộc.

Ví dụ:

```text
Barbell Bench Press
→ BARBELL required
→ BENCH required
```

```text
Incline Dumbbell Press
→ DUMBBELL required
→ ADJUSTABLE_BENCH required
```

Processed record map vào `exercise_equipment`:

```json
{
  "exerciseImportKey": "FREE_EXERCISE_DB:Barbell_Bench_Press",
  "equipment": [
    { "code": "BARBELL", "required": true },
    { "code": "BENCH", "required": true }
  ]
}
```

---

## 6. Muscle Group và body map

Raw muscle phải map vào code VieGym cố định.

Ví dụ:

```json
{
  "pectorals": "CHEST",
  "pecs": "CHEST",
  "quadriceps": "QUADRICEPS",
  "quads": "QUADRICEPS",
  "lats": "LATS",
  "abdominals": "ABS"
}
```

Không lưu raw muscle text vào relation production.

Canonical tables:

- `muscle_groups`
- `exercise_muscle_groups`

Role P0:

- `PRIMARY`
- `SECONDARY`

Nếu raw source có `STABILIZER`, giữ trong processed metadata hoặc tạo ADR/schema change trước khi import. Không tự mở rộng enum production.

Mỗi muscle code nên có mapping sang SVG/body map, nhưng `svg_key` không bắt buộc phải thêm vào DB nếu Mobile đã có mapping code → region ổn định.

---

## 7. Nguồn dữ liệu Food Việt Nam

### 7.1. Vietnam Food Composition Table 2007 — nguồn Việt Nam chính

Nguồn:

- FAO directory: <https://www.fao.org/food-composition/tables-and-databases/detail/%28viet-nam--2007%29-vietnamese-food-composition-table/en>
- Tài liệu được FAO mô tả là static PDF/free access.

Dùng cho:

- tên nguyên liệu/thực phẩm Việt Nam;
- energy;
- protein;
- carbohydrate;
- fat;
- edible portion;
- fiber/sodium nếu dữ liệu đủ rõ.

Trước khi ETL phải:

- lưu bản PDF nguồn;
- ghi URL, ngày truy cập và checksum;
- ghi rõ trang/table nguồn cho mỗi batch trích xuất;
- xác minh điều khoản tái sử dụng trước khi commit hoặc phân phối processed data;
- không giả định “free access” đồng nghĩa với mọi quyền tái phân phối.

### 7.2. USDA FoodData Central — nguồn fill-gap

Nguồn:

- Downloads: <https://fdc.nal.usda.gov/download-datasets/>
- API/licensing: <https://fdc.nal.usda.gov/api-guide/>

USDA FoodData Central công bố dữ liệu theo CC0/public domain và đề nghị ghi nguồn.

Dùng khi Vietnam FCT thiếu:

- nguyên liệu nhập khẩu;
- thực phẩm phổ biến mới;
- giá trị macro cần kiểm tra chéo.

Ưu tiên:

1. Foundation Foods.
2. SR Legacy.
3. FNDDS khi cần serving/portion tham khảo.

Không tải toàn bộ Branded Foods cho MVP.

Mỗi item lấy từ USDA phải lưu `fdcId`, release date và data type.

### 7.3. Food.com — chỉ dùng làm recipe candidate

Nguồn:

- <https://www.kaggle.com/datasets/irkaal/foodcom-recipes-and-reviews>
- Dataset page hiện ghi CC0/public domain.

Chỉ dùng để:

- tìm candidate recipe;
- tham khảo ingredient list;
- tham khảo serving structure;
- cross-check nutrition.

Không dùng Food.com macro làm source of truth và không import 522K recipes.

Món Việt quan trọng phải được VieGym review lại ingredient, gram và serving.

### 7.4. Runtime P0 vẫn dùng `foods`

ETL có thể dùng cấu trúc ingredient/recipe nội bộ, nhưng output cuối phải flatten theo schema P0:

```text
foods
```

Không tạo API `/ingredients` hoặc `/dishes` trong P0.

Ví dụ processed Food:

```json
{
  "importKey": "VIEGYM_FOOD:pho-bo-standard-v1",
  "name": "Phở bò",
  "searchName": "pho bo",
  "slug": "pho-bo",
  "category": "Món nước",
  "servingAmount": 1,
  "servingUnit": "tô",
  "gramsPerServing": 350,
  "caloriesPerServing": 450,
  "proteinGPerServing": 25,
  "carbsGPerServing": 55,
  "fatGPerServing": 14,
  "dataSource": "VIEGYM_CALCULATED_FROM_VN_FCT_USDA",
  "sourceNote": "Recipe v1; giá trị tham khảo",
  "estimated": true,
  "visibility": "PUBLIC"
}
```

---

## 8. Công thức và quy tắc Food ETL

Chuẩn hóa nutrient ingredient về 100 g edible portion:

```text
ingredient nutrient
= ingredient_weight_g / 100 × nutrient_per_100g
```

Tổng recipe:

```text
recipe nutrient
= tổng nutrient của mọi ingredient
```

Per serving:

```text
nutrition_per_serving
= recipe_total / serving_count
```

Sanity check calories:

```text
estimated kcal ≈ protein × 4 + carbohydrate × 4 + fat × 9
```

Không yêu cầu bằng tuyệt đối vì fiber, alcohol, rounding và phương pháp phân tích có thể tạo chênh lệch. Chênh lệch vượt threshold đã chốt phải chuyển record sang manual review.

Quy tắc:

- Không cho nutrient âm.
- Không chấp nhận serving bằng 0.
- `gramsPerServing` chỉ có khi có cơ sở quy đổi.
- Nếu không biết gram, để null; không tự bịa.
- Mọi record ước lượng phải có `is_estimated=true`.
- UI phải trình bày giá trị ước lượng là tham khảo.
- Không dùng dữ liệu VieGym để chẩn đoán hoặc điều trị y khoa.

---

## 9. Cấu trúc thư mục cần tạo khi bắt đầu M4/M5

```text
datasets/
├── manifests/
│   ├── exercise_sources.json
│   └── nutrition_sources.json
├── exercise/
│   ├── raw/
│   ├── mappings/
│   │   ├── equipment_mapping.json
│   │   ├── muscle_mapping.json
│   │   ├── exercise_aliases.json
│   │   └── multi_equipment_overrides.json
│   ├── review/
│   └── processed/
├── nutrition/
│   ├── raw/
│   ├── mappings/
│   │   ├── food_aliases.json
│   │   ├── nutrient_mapping.json
│   │   └── serving_mapping.json
│   ├── review/
│   └── processed/
├── exports/
│   ├── viegym_exercises_v1.json
│   ├── viegym_equipment_v1.json
│   ├── viegym_muscle_groups_v1.json
│   └── viegym_foods_v1.json
└── scripts/
    ├── fetch_sources.py
    ├── normalize_exercises.py
    ├── normalize_foods.py
    ├── validate_exercises.py
    ├── validate_foods.py
    └── build_exports.py
```

Raw file lớn hoặc bị giới hạn tái phân phối:

- không commit trực tiếp;
- lưu download script, URL, version và checksum;
- thêm pattern tương ứng vào `.gitignore`;
- chỉ commit mapping, manifest được phép, processed output được phép và script.

Không tạo thư mục `frontend/`; production client duy nhất là Flutter trong `mobile/`.

---

## 10. Source manifest bắt buộc

Ví dụ:

```json
{
  "source": "FREE_EXERCISE_DB",
  "url": "https://github.com/yuhonas/free-exercise-db",
  "commitSha": "PINNED_COMMIT_SHA",
  "downloadedAt": "2026-08-31T00:00:00Z",
  "license": "Unlicense",
  "licenseFileChecksum": "sha256:...",
  "dataFile": "dist/exercises.json",
  "dataChecksum": "sha256:...",
  "redistributionAllowed": true,
  "mediaAllowed": false,
  "notes": "Metadata enrichment; media disabled until provenance review"
}
```

Không cho pipeline chạy nếu thiếu:

- URL;
- source version/commit/release;
- checksum;
- license hoặc quyết định legal review;
- redistribution flag;
- media permission flag.

---

## 11. Exercise ETL — thứ tự thực hiện

### E0 — License và snapshot

- Pin commit của từng repository.
- Lưu license/NOTICE.
- Tính SHA-256.
- Chặn media chưa đủ quyền.

### E1 — Raw schema validation

- Validate JSON parse được.
- Kiểm tra required field theo từng source.
- Thống kê null/unknown/duplicate.
- Không sửa raw file.

### E2 — Normalize text

- Trim/collapse whitespace.
- Unicode normalize.
- Sinh `search_name` deterministic, bỏ dấu để search tiếng Việt.
- Sinh slug deterministic.

### E3 — Normalize Equipment

- Map toàn bộ raw equipment vào code canonical.
- Unknown value làm pipeline fail.
- Áp multi-equipment override.

### E4 — Normalize Muscle

- Map primary và secondary muscle.
- Mỗi Exercise phải có ít nhất một `PRIMARY`.
- Unknown muscle chuyển manual review.

### E5 — Dedupe và merge

Candidate match dựa trên:

- normalized English name;
- equipment set;
- primary muscle;
- movement pattern nếu có.

Không tự merge record có xung đột primary muscle hoặc movement pattern.

### E6 — Difficulty và movement pattern

Difficulty chỉ dùng:

- `BEGINNER`
- `INTERMEDIATE`
- `ADVANCED`

Movement pattern phải thuộc whitelist được chốt trước M4-05.

### E7 — Tên và hướng dẫn tiếng Việt

- AI có thể tạo bản dịch nháp.
- Record chỉ thành `PUBLIC` sau manual review.
- Ưu tiên thuật ngữ người tập gym Việt Nam thực sự dùng.
- Safety note không được dịch máy rồi publish không kiểm tra.

### E8 — Export

Export phải deterministic:

- sort theo import key/code;
- cùng input + mapping phải tạo cùng output/checksum;
- ghi dataset version và build timestamp riêng;
- không dùng timestamp để làm thay đổi nội dung record.

---

## 12. Food ETL — thứ tự thực hiện

### F0 — License và source snapshot

- Pin Vietnam FCT PDF/version.
- Pin USDA release/FDC IDs.
- Pin Food.com dataset version nếu sử dụng.
- Lưu checksum và attribution.

### F1 — Extract và normalize nutrient

- Chuẩn hóa tên nutrient.
- Chuẩn hóa unit kcal/g/mg.
- Chuẩn hóa về 100 g edible portion.
- Giữ raw value và transformed value trong ETL audit output.

### F2 — Food alias

Ví dụ:

```text
ức gà
thịt ức gà
chicken breast
→ canonical ingredient candidate: Ức gà
```

Alias chỉ phục vụ ETL/search; không tạo duplicate production row.

### F3 — Recipe candidate

- Chọn món Việt phổ biến theo scope MVP.
- Map ingredient về source nutrition đã verify.
- Chuẩn hóa toàn bộ quantity về gram.
- Candidate chưa map đủ ingredient không được publish.

### F4 — Calculate và flatten

- Tính tổng macro từ ingredient.
- Chia theo serving.
- Flatten thành record `foods` P0.
- Lưu source note và `is_estimated`.

### F5 — Manual review

Review:

- tên món;
- serving name;
- grams per serving;
- calorie/macro plausibility;
- source note;
- estimated flag.

### F6 — Export

Xuất `viegym_foods_v1.json` đúng field contract của bảng `foods`.

---

## 13. Processed Exercise contract

Processed JSON có thể chứa provenance field ngoài DB để importer sử dụng:

```json
{
  "importKey": "FREE_EXERCISE_DB:Barbell_Bench_Press",
  "source": "FREE_EXERCISE_DB",
  "sourceExternalId": "Barbell_Bench_Press",
  "sourceVersion": "PINNED_COMMIT_SHA",
  "nameEn": "Barbell Bench Press",
  "nameVi": "Đẩy ngực với thanh đòn",
  "searchName": "day nguc voi thanh don barbell bench press",
  "slug": "barbell-bench-press",
  "difficulty": "INTERMEDIATE",
  "description": "...",
  "instructionSteps": ["..."],
  "commonMistakes": ["..."],
  "safetyNotes": ["..."],
  "movementPattern": "HORIZONTAL_PUSH",
  "visibility": "PUBLIC",
  "verified": true,
  "muscleGroups": [
    { "code": "CHEST", "role": "PRIMARY" },
    { "code": "TRICEPS", "role": "SECONDARY" }
  ],
  "equipment": [
    { "code": "BARBELL", "required": true },
    { "code": "BENCH", "required": true }
  ],
  "media": []
}
```

Trước khi triển khai importer phải chốt cách lưu provenance và `nameEn/nameVi/movementPattern`:

- nếu cần trong runtime, thêm migration/schema/API chính thức;
- nếu chưa cần, giữ trong processed dataset/import audit và map field canonical hiện có;
- không tự thêm column chỉ vì raw source có field đó.

---

## 14. Importer vào PostgreSQL

### 14.1. Phân trách nhiệm

Python ETL:

- download/read raw;
- normalize;
- merge;
- validate;
- export processed JSON;
- không kết nối production database.

Spring Boot importer:

- đọc processed JSON đã validate;
- chạy trong profile/command nội bộ, không public cho user;
- validate lại enum/reference;
- upsert idempotent;
- ghi import batch/provenance;
- transaction theo batch phù hợp;
- xuất import report.

### 14.2. Không dùng Flyway cho bulk dataset

Flyway chỉ dùng cho:

- tạo/thay đổi schema;
- constraint/index;
- small lookup và catalog code nhỏ.

Không tạo migration chứa 300–500 Exercise hoặc hàng trăm Food bằng `INSERT` dài.

### 14.3. Idempotency

Importer phải bảo đảm:

- chạy lại cùng dataset version không tạo duplicate;
- record đã được Admin sửa không bị external import âm thầm ghi đè;
- source record biến mất không bị hard delete tự động;
- thay đổi visibility cần policy rõ ràng;
- relation equipment/muscle được diff, không delete/recreate tùy tiện nếu đã có reference;
- lỗi giữa batch có report và rollback boundary rõ ràng.

Khuyến nghị unique import key:

```text
UNIQUE(source, source_external_id)
```

Nếu chưa thêm provenance column vào master table, tạo import registry/batch table bằng ADR/migration riêng.

---

## 15. Quality Gate

### 15.1. Exercise gate

Dataset chỉ đạt khi:

- 100% import key unique.
- 100% slug unique.
- 100% Exercise có tên và difficulty hợp lệ.
- 100% Exercise có ít nhất một primary muscle.
- 100% equipment/muscle reference resolve được.
- 0 raw equipment/muscle value chưa mapping trong record publish.
- 0 Exercise `PUBLIC` chưa review tên tiếng Việt.
- 0 media được publish khi thiếu license/attribution.
- Multi-equipment golden fixtures đạt 100%.
- Bodyweight Exercise có compatibility rule rõ ràng.

Golden fixtures tối thiểu:

- Barbell Bench Press cần Barbell + Bench.
- Incline Dumbbell Press cần Dumbbell + Adjustable Bench.
- Pull-up cần Pull-up Bar hoặc rule bodyweight-equipment đã chốt.
- Cable Fly không hợp lệ khi user chỉ có Dumbbell + Bench.
- Hidden Exercise không xuất hiện trong lựa chọn mới.

### 15.2. Food gate

- 100% Food có name/searchName/slug/category.
- 100% serving amount > 0.
- 100% calories/protein/carbs/fat không âm.
- 100% record có data source hoặc source note.
- `gramsPerServing` chỉ tồn tại khi có conversion hợp lệ.
- Record ước lượng có `is_estimated=true`.
- Duplicate canonical food name/serving được review.
- Macro sanity check không có outlier chưa giải quyết.
- Food hidden không xuất hiện khi thêm Meal Entry mới.
- Thay đổi Food không làm đổi Meal Entry snapshot lịch sử.

### 15.3. Import/API gate

- Import lần một thành công.
- Import lại cùng version tạo 0 duplicate.
- Migration chạy được từ DB rỗng.
- Migration nâng cấp được từ DB có V0..current.
- `GET /api/v1/exercises` search/filter/pagination đúng.
- `compatibleWithMyEquipment=true` dùng preference authoritative.
- `GET /api/v1/foods` search/filter/pagination đúng.
- User thường không được sửa master data.
- Admin hide không phá lịch sử.
- OpenAPI regenerate không tạo diff ngoài dự kiến.

---

## 16. Media strategy

MVP không được phụ thuộc media external để Exercise/Food API hoạt động.

Thứ tự:

1. Import metadata không media.
2. Dùng placeholder/body muscle visualization của VieGym.
3. Review license từng media source.
4. Chỉ thêm media qua `media_objects` trong M7/PH9.
5. Lưu source, license và attribution trong metadata liên quan.

Không tạo runtime table `exercise_media`/`food_media` song song với `media_objects` nếu chưa có ADR thay đổi kiến trúc.

---

## 17. Tích hợp AI

AI chỉ được tích hợp sau khi Exercise/Food query và rule engine đã có test.

Workout:

```text
User profile + equipment + history
        ↓
Spring Boot ownership/context check
        ↓
Exercise eligibility filter
        ↓
20–50 candidate Exercise IDs
        ↓
FastAPI ranking
        ↓
Spring Boot validate IDs/rules
        ↓
Proposal để user review
```

Nutrition:

```text
Nutrition target + consumed + preference
        ↓
Spring Boot Food filter
        ↓
Candidate Food IDs
        ↓
FastAPI ranking
        ↓
Spring Boot validate macro/source/constraint
        ↓
Meal proposal để user review
```

Không gửi toàn bộ 300–500 Exercise hoặc toàn bộ Food catalog cho LLM mỗi request.

---

## 18. Ánh xạ vào backlog hiện tại

### M4 — Workout Core

- `M4-01`: schema delta cho muscle/exercise/mapping/provenance cần thiết.
- `M4-02`: ETL, golden dataset, importer và demo seed.
- `M4-03`: list/search/filter/pagination.
- `M4-04`: detail, instruction, safety và media metadata.
- `M4-05`: equipment matching, ranking và alternatives.
- `M4-06`: visibility/hidden-reference.
- `M4-27`: dataset, ownership, compatibility và concurrency test.
- `M4-28`: Favorite Exercise.

### M5 — Nutrition

- `M5-01`: giữ schema `foods` + Meal domain canonical.
- `M5-02`: ETL Food Việt, processed export và importer.
- `M5-03..05`: Food API, detail và visibility.
- `M5-21`: nhãn dữ liệu ước lượng.
- `M5-22`: snapshot/summary/ownership/concurrency test.
- `M5-23`: Favorite Food.

### M6 — AI

- Dùng Exercise/Food candidate từ Backend.
- Không query raw dataset hoặc PostgreSQL từ FastAPI.
- Output ngoài shortlist phải reject/fallback.

### M7 — Admin/Media/Audit

- Admin sửa/hide master data.
- Media qua `media_objects`.
- Audit import/admin mutation và redaction.

### M8 — Hardening

- Migration rehearsal.
- Import rerun test.
- Query/index performance.
- License/attribution audit.
- Demo seed và backup/restore.

---

## 19. Thứ tự triển khai đề xuất

Không bắt đầu dataset production trước khi đóng M2 và M3 contract liên quan.

### Chuẩn bị trước M4

1. Chốt nguồn và license matrix.
2. Chốt schema delta so với `DATABASE.md`.
3. Chốt code Equipment/Muscle canonical.
4. Tạo manifest và mapping template.

### Tuần đầu M4

1. Pin/download raw Exercise sources.
2. Viết raw schema validator.
3. Hoàn thiện Equipment/Muscle mapping.
4. Tạo 120 Exercise golden.
5. Viết processed validator.
6. Tạo importer idempotent.

### Phần còn lại M4

1. Mở rộng 300–500 Exercise.
2. Hoàn thiện Exercise API và matching.
3. Tích hợp Workout/Favorite.
4. Đóng E2E-02.

### Đầu M5

1. Pin Vietnam FCT/USDA sources.
2. Tạo 60–100 Food golden.
3. Flatten thành `foods` P0.
4. Mở rộng 150–300 Food.
5. Hoàn thiện Meal/Favorite và E2E-03.

---

## 20. Deliverables bắt buộc

- [ ] Source/license decision matrix.
- [ ] Source manifests có commit/release/checksum.
- [ ] Equipment mapping.
- [ ] Muscle mapping.
- [ ] Exercise alias và multi-equipment override.
- [ ] Food/nutrient/serving mapping.
- [ ] Python ETL scripts có test.
- [ ] `viegym_exercises_v1.json`.
- [ ] `viegym_equipment_v1.json`.
- [ ] `viegym_muscle_groups_v1.json`.
- [ ] `viegym_foods_v1.json`.
- [ ] Validation reports.
- [ ] Manual-review reports.
- [ ] Spring Boot importer idempotent.
- [ ] Import batch/provenance report.
- [ ] Exercise/Food API integration tests.
- [ ] OpenAPI/dart-dio no-diff evidence.
- [ ] E2E-02 và E2E-03 evidence.
- [ ] Attribution/license inventory cho media được sử dụng.

---

## 21. Definition of Done

Dataset acquisition được coi là hoàn thành cho MVP khi:

- nguồn, version, checksum và license của mọi input đã được ghi;
- raw data không được runtime sử dụng;
- processed export deterministic và có version;
- importer chạy lại không tạo duplicate;
- schema/API giữ đúng baseline VieGym;
- Exercise matching theo equipment/muscle hoạt động;
- Food macro/serving có nguồn và estimated flag phù hợp;
- AI không thể chọn ID ngoài shortlist;
- master data hidden không phá lịch sử;
- không có external media chưa đủ quyền;
- M4/M5 integration test và E2E tương ứng đạt;
- tài liệu `Project_Progress.md`, API, DB và traceability được cập nhật bằng minh chứng thực tế.

---

## 22. Việc đầu tiên cần làm khi bắt đầu workstream dataset

Không download hàng loạt ngay.

Thực hiện theo thứ tự:

1. Tạo source/license decision matrix.
2. Pin commit Free Exercise DB và exercises-dataset-main.
3. Quyết định metadata nào được phép dùng; media mặc định `disabled`.
4. Chốt Equipment/Muscle code với schema hiện hành.
5. Chốt schema delta/provenance bằng ADR nếu cần.
6. Tạo manifest và raw validator.
7. Chỉ sau đó mới download snapshot và bắt đầu ETL.

Nếu bất kỳ nguồn nào không xác minh được quyền sử dụng hoặc provenance, bỏ nguồn đó khỏi MVP và thay bằng dữ liệu VieGym tự biên soạn/manual verified.
