#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
VieGym Vietnamese Food Dataset v1 Builder
Expands Golden Dataset (80 foods) to Full MVP Dataset (203+ foods)
Compliant with docs/VIEGYM_DATASET_ACQUISITION_PLAN.md
"""

import json
import re
import unicodedata
import os

def remove_accents(input_str: str) -> str:
    s = unicodedata.normalize('NFD', input_str)
    s = ''.join(c for c in s if unicodedata.category(c) != 'Mn')
    s = s.replace('đ', 'd').replace('Đ', 'D')
    s = re.sub(r'[^a-zA-Z0-9\s]', ' ', s)
    s = re.sub(r'\s+', ' ', s).strip().lower()
    return s

def make_slug(name_en: str) -> str:
    s = remove_accents(name_en)
    return re.sub(r'\s+', '-', s)

NEW_FOODS_DEF = [
    # --- 1. MÓN NƯỚC & SỢI VIỆT NAM (16 món) ---
    {
        "name": "Bún chả Hà Nội",
        "slug": "bun-cha-ha-noi",
        "category": "MON_NUOC",
        "servingUnit": "phần",
        "grams": 520,
        "protein": 32.0, "carbs": 62.0, "fat": 18.0,
        "note": "Bún tươi, chả thịt nướng than hoa, nước mắm dưa góp và rau thơm."
    },
    {
        "name": "Bún thịt nướng",
        "slug": "bun-thit-nuong",
        "category": "MON_NUOC",
        "servingUnit": "tô",
        "grams": 480,
        "protein": 28.0, "carbs": 65.0, "fat": 16.0,
        "note": "Bún tươi ăn kèm thịt heo nướng sả, đậu phộng, mỡ hành và nước mắm chua ngọt."
    },
    {
        "name": "Bún thang Hà Nội",
        "slug": "bun-thang-ha-noi",
        "category": "MON_NUOC",
        "servingUnit": "tô",
        "grams": 500,
        "protein": 26.0, "carbs": 54.0, "fat": 9.0,
        "note": "Bún nước thanh cảnh với thịt gà xé, giò lụa thái chỉ, trứng tráng mỏng và nấm hương."
    },
    {
        "name": "Bún ốc Hà Nội",
        "slug": "bun-oc-ha-noi",
        "category": "MON_NUOC",
        "servingUnit": "tô",
        "grams": 500,
        "protein": 18.0, "carbs": 58.0, "fat": 8.0,
        "note": "Bún nước giấm bỗng chua thanh, ốc nhồi béo giòn ăn kèm đậu phụ rán."
    },
    {
        "name": "Bún mắm miền Tây",
        "slug": "bun-mam-mien-tay",
        "category": "MON_NUOC",
        "servingUnit": "tô",
        "grams": 550,
        "protein": 34.0, "carbs": 60.0, "fat": 15.0,
        "note": "Bún nước lèo mắm cá linh cá sặc đậm đà với tôm, mực, heo quay và cà tím."
    },
    {
        "name": "Bún đậu mắm tôm",
        "slug": "bun-dau-mam-tom",
        "category": "MON_NUOC",
        "servingUnit": "mẹt",
        "grams": 450,
        "protein": 26.0, "carbs": 52.0, "fat": 22.0,
        "note": "Bún lá, đậu hũ rán giòn, thịt chân giò luộc, chả cốm ăn kèm mắm tôm pha quất."
    },
    {
        "name": "Bún mọc sườn non",
        "slug": "bun-moc-suon-non",
        "category": "MON_NUOC",
        "servingUnit": "tô",
        "grams": 520,
        "protein": 30.0, "carbs": 56.0, "fat": 14.0,
        "note": "Bún nước hầm xương ngọt thanh với viên mọc thịt nấm mèo và sườn non ninh mềm."
    },
    {
        "name": "Bánh canh ghẹ",
        "slug": "banh-canh-ghe",
        "category": "MON_NUOC",
        "servingUnit": "tô",
        "grams": 500,
        "protein": 28.0, "carbs": 60.0, "fat": 11.0,
        "note": "Sợi bánh canh bột lọc dẻo dai ăn với thịt ghẹ tươi và nước dùng sánh ngọt sệt."
    },
    {
        "name": "Bánh canh giò heo",
        "slug": "banh-canh-gio-heo",
        "category": "MON_NUOC",
        "servingUnit": "tô",
        "grams": 550,
        "protein": 32.0, "carbs": 58.0, "fat": 20.0,
        "note": "Bánh canh sợi to mềm ăn cùng khoanh giò heo luộc giòn sần sật."
    },
    {
        "name": "Bánh canh Trảng Bàng",
        "slug": "banh-canh-trang-bang",
        "category": "MON_NUOC",
        "servingUnit": "tô",
        "grams": 480,
        "protein": 25.0, "carbs": 55.0, "fat": 10.0,
        "note": "Bánh canh gạo Trảng Bàng ăn kèm thịt bắp heo luộc chấm nước mắm tiêu."
    },
    {
        "name": "Hủ tiếu gõ thịt nạc",
        "slug": "hu-tieu-go-thit-nac",
        "category": "MON_NUOC",
        "servingUnit": "tô",
        "grams": 450,
        "protein": 22.0, "carbs": 58.0, "fat": 9.0,
        "note": "Hủ tiếu bình dân thanh nhẹ với thịt heo nạc thái lát, hẹ và tóp mỡ."
    },
    {
        "name": "Hủ tiếu bò kho",
        "slug": "hu-tieu-bo-kho",
        "category": "MON_NUOC",
        "servingUnit": "tô",
        "grams": 500,
        "protein": 30.0, "carbs": 62.0, "fat": 16.0,
        "note": "Sợi hủ tiếu ngấm sốt bò kho thơm ngậy quế hồi sả, nạm bò mềm ngậy."
    },
    {
        "name": "Miến lươn xào giòn",
        "slug": "mien-luon-xao-gion",
        "category": "MON_NUOC",
        "servingUnit": "đĩa",
        "grams": 350,
        "protein": 24.0, "carbs": 48.0, "fat": 14.0,
        "note": "Miến dong dai xào cùng lươn giòn rụm, mộc nhĩ, giá đỗ và rau răm."
    },
    {
        "name": "Miến măng vịt",
        "slug": "mien-mang-vit",
        "category": "MON_NUOC",
        "servingUnit": "tô",
        "grams": 500,
        "protein": 29.0, "carbs": 50.0, "fat": 16.0,
        "note": "Miến dong nấu măng khô thanh mát với thịt vịt luộc chấm nước mắm gừng."
    },
    {
        "name": "Cháo sườn sụn",
        "slug": "chao-suon-sun",
        "category": "MON_NUOC",
        "servingUnit": "tô",
        "grams": 420,
        "protein": 22.0, "carbs": 46.0, "fat": 11.0,
        "note": "Cháo bột gạo xay mịn nấu sườn sụn giòn, rắc ruốc thịt và quẩy giòn."
    },
    {
        "name": "Cháo yến mạch ức gà",
        "slug": "chao-yen-mach-uc-ga",
        "category": "MON_NUOC",
        "servingUnit": "tô",
        "grams": 380,
        "protein": 36.0, "carbs": 38.0, "fat": 6.0,
        "note": "Món ăn Eat Clean lý tưởng cho gymer với yến mạch nấu nở mềm và ức gà xé."
    },

    # --- 2. CƠM & MÓN ĂN GIA ĐÌNH VIỆT NAM (18 món) ---
    {
        "name": "Cơm tấm sườn bì chả",
        "slug": "com-tam-suon-bi-cha",
        "category": "COM",
        "servingUnit": "đĩa",
        "grams": 500,
        "protein": 38.0, "carbs": 78.0, "fat": 26.0,
        "note": "Đĩa cơm tấm Sài Gòn đầy đủ sườn nướng mỡ hành, bì heo trộn thính và chả trứng hấp."
    },
    {
        "name": "Cơm chiên dưa bò",
        "slug": "com-chien-dua-bo",
        "category": "COM",
        "servingUnit": "đĩa",
        "grams": 420,
        "protein": 26.0, "carbs": 68.0, "fat": 18.0,
        "note": "Cơm rang săn hạt giòn tan xào với thịt bắp bò mềm và dưa cải muối chua giòn."
    },
    {
        "name": "Cơm chiên cá mặn",
        "slug": "com-chien-ca-man",
        "category": "COM",
        "servingUnit": "đĩa",
        "grams": 400,
        "protein": 22.0, "carbs": 66.0, "fat": 16.0,
        "note": "Cơm chiên tộ thơm lừng thịt gà xé và cá mặn bùi ngậy đậm đà."
    },
    {
        "name": "Cơm gà xối mỡ",
        "slug": "com-ga-xoi-mo",
        "category": "COM",
        "servingUnit": "đĩa",
        "grams": 450,
        "protein": 35.0, "carbs": 70.0, "fat": 24.0,
        "note": "Cơm chiên vàng rực ăn kèm góc đùi gà xối mỡ da giòn rụm."
    },
    {
        "name": "Sườn xào chua ngọt",
        "slug": "suon-xao-chua-ngot",
        "category": "DAM",
        "servingUnit": "phần",
        "grams": 220,
        "protein": 28.0, "carbs": 18.0, "fat": 19.0,
        "note": "Sườn non rán vàng sốt cùng nước mắm giấm đường ớt và hành tây cà chua."
    },
    {
        "name": "Thịt kho tàu nước dừa",
        "slug": "thit-kho-tau-nuoc-dua",
        "category": "DAM",
        "servingUnit": "phần",
        "grams": 250,
        "protein": 25.0, "carbs": 12.0, "fat": 28.0,
        "note": "Thịt ba chỉ thái vuông kho mềm rục với nước dừa xiêm và trứng vịt nâu óng."
    },
    {
        "name": "Cá nục kho tiêu",
        "slug": "ca-nuc-kho-tieu",
        "category": "DAM",
        "servingUnit": "con",
        "grams": 180,
        "protein": 32.0, "carbs": 5.0, "fat": 12.0,
        "note": "Cá nục tươi kho đẫm tiêu đen và ớt cay thơm nồng đưa cơm."
    },
    {
        "name": "Mực nhồi thịt sốt cà",
        "slug": "muc-nhoi-thit-sot-ca",
        "category": "DAM",
        "servingUnit": "phần",
        "grams": 240,
        "protein": 33.0, "carbs": 14.0, "fat": 12.0,
        "note": "Mực ống tươi nhồi thịt băm mộc nhĩ hấp chín rồi sốt cà chua đậm vị."
    },
    {
        "name": "Tôm rim thịt ba chỉ",
        "slug": "tom-rim-thit-ba-chi",
        "category": "DAM",
        "servingUnit": "phần",
        "grams": 200,
        "protein": 30.0, "carbs": 8.0, "fat": 18.0,
        "note": "Tôm đồng rim săn giòn cùng thịt ba chỉ cháy cạnh đượm màu cánh gián."
    },
    {
        "name": "Ức gà xào nấm đông cô",
        "slug": "uc-ga-xao-nam-dong-co",
        "category": "DAM",
        "servingUnit": "phần",
        "grams": 220,
        "protein": 42.0, "carbs": 8.0, "fat": 6.0,
        "note": "Ức gà phi lê xào ít dầu cùng nấm đông cô ngọt bùi, món giàu đạm chuẩn gym."
    },
    {
        "name": "Thịt bò xào hành tây cần tây",
        "slug": "thit-bo-xao-hanh-tay-can-tay",
        "category": "DAM",
        "servingUnit": "phần",
        "grams": 220,
        "protein": 36.0, "carbs": 9.0, "fat": 12.0,
        "note": "Thịt bò thăn thái mỏng xào lửa lớn cùng cần tây, hành tây thơm nức."
    },
    {
        "name": "Cá diêu hồng hấp xì dầu",
        "slug": "ca-dieu-hong-hap-xi-dau",
        "category": "DAM",
        "servingUnit": "phần",
        "grams": 250,
        "protein": 35.0, "carbs": 6.0, "fat": 8.0,
        "note": "Thịt cá diêu hồng trắng ngần ngọt thanh hấp cùng hành hoa gừng sợi xì dầu."
    },
    {
        "name": "Cá lóc kho tộ",
        "slug": "ca-loc-kho-to",
        "category": "DAM",
        "servingUnit": "khúc",
        "grams": 180,
        "protein": 30.0, "carbs": 6.0, "fat": 10.0,
        "note": "Cá quả đồng kho niêu đất thơm ngọt nước mắm ngon và ớt hiểm."
    },
    {
        "name": "Cơm gạo lứt thịt bằm sốt cà",
        "slug": "com-gao-lut-thit-bam-sot-ca",
        "category": "COM",
        "servingUnit": "đĩa",
        "grams": 380,
        "protein": 32.0, "carbs": 58.0, "fat": 10.0,
        "note": "Cơm gạo lứt dẻo ăn kèm sốt cà chua nấu thịt heo nạc băm ít béo."
    },
    {
        "name": "Cơm niêu thịt kho quẹt",
        "slug": "com-nieu-thit-kho-quet",
        "category": "COM",
        "servingUnit": "phần",
        "grams": 400,
        "protein": 22.0, "carbs": 68.0, "fat": 18.0,
        "note": "Cơm niêu cháy đáy giòn rụm chấm nước mắm kho quẹt tôm khô thịt mỡ."
    },
    {
        "name": "Cơm gà xé phay Tam Kỳ",
        "slug": "com-ga-xe-phay-tam-ky",
        "category": "COM",
        "servingUnit": "đĩa",
        "grams": 420,
        "protein": 34.0, "carbs": 65.0, "fat": 14.0,
        "note": "Cơm nấu nước luộc gà vàng ươm ăn cùng thịt gà ta xé bóp rau răm hành tây."
    },
    {
        "name": "Thịt bò sốt vang",
        "slug": "thit-bo-sot-vang",
        "category": "DAM",
        "servingUnit": "tô",
        "grams": 300,
        "protein": 34.0, "carbs": 12.0, "fat": 18.0,
        "note": "Thịt bắp bò hầm rượu vang đỏ, quế hồi sốt cà chua mềm sánh đậm đà."
    },
    {
        "name": "Cơm cháy chà bông",
        "slug": "com-chay-cha-bong",
        "category": "AN_VAT",
        "servingUnit": "miếng",
        "grams": 120,
        "protein": 12.0, "carbs": 62.0, "fat": 14.0,
        "note": "Cơm cháy giòn rụm phủ lớp ruốc thịt heo và mỡ hành ớt cay nhẹ."
    },

    # --- 3. MÓN BÁNH TRUYỀN THỐNG & ĂN SÁNG (15 món) ---
    {
        "name": "Bánh mì chảo xíu mại trứng",
        "slug": "banh-mi-chao-xiu-mai-trung",
        "category": "BANH",
        "servingUnit": "chảo",
        "grams": 320,
        "protein": 24.0, "carbs": 48.0, "fat": 22.0,
        "note": "Bánh mì giòn chấm chảo sốt xíu mại nóng hổi kèm trứng ốp la và pate."
    },
    {
        "name": "Bánh mì que Hải Phòng",
        "slug": "banh-mi-que-hai-phong",
        "category": "BANH",
        "servingUnit": "2 que",
        "grams": 120,
        "protein": 8.0, "carbs": 38.0, "fat": 12.0,
        "note": "Bánh mì cay que giòn thơm kẹp pate gan béo ngậy và tương ớt chí chương."
    },
    {
        "name": "Bánh mì chả lụa dưa leo",
        "slug": "banh-mi-cha-lua-dua-leo",
        "category": "BANH",
        "servingUnit": "ổ",
        "grams": 190,
        "protein": 16.0, "carbs": 46.0, "fat": 12.0,
        "note": "Bánh mì vỏ giòn kẹp chả lụa heo thái lát, dưa leo tươi mát và ngò rí."
    },
    {
        "name": "Bánh mì bò nướng bơ",
        "slug": "banh-mi-bo-nuong-bo",
        "category": "BANH",
        "servingUnit": "ổ",
        "grams": 210,
        "protein": 22.0, "carbs": 48.0, "fat": 16.0,
        "note": "Bánh mì kẹp xiên thịt bò tẩm ướp mật ong bơ nướng thơm nức mũi."
    },
    {
        "name": "Bánh hỏi heo quay",
        "slug": "banh-hoi-heo-quay",
        "category": "BANH",
        "servingUnit": "đĩa",
        "grams": 350,
        "protein": 24.0, "carbs": 52.0, "fat": 24.0,
        "note": "Bánh hỏi sợi nhuyễn thoa mỡ hành ăn cùng thịt heo quay da giòn chấm nước mắm tỏi ớt."
    },
    {
        "name": "Bánh bèo tôm chấy",
        "slug": "banh-beo-tom-chay",
        "category": "BANH",
        "servingUnit": "đĩa 6 chén",
        "grams": 240,
        "protein": 11.0, "carbs": 42.0, "fat": 6.0,
        "note": "Bánh bèo bột gạo mềm mịn xoáy tròn phủ tôm chấy đỏ cam và da heo giòn."
    },
    {
        "name": "Bánh nậm Huế",
        "slug": "banh-nam-hue",
        "category": "BANH",
        "servingUnit": "3 cái",
        "grams": 180,
        "protein": 9.0, "carbs": 32.0, "fat": 7.0,
        "note": "Bánh nậm gói lá chuối hình chữ nhật nhân tôm thịt băm nhuyễn chan nước mắm ngọt."
    },
    {
        "name": "Bánh bột lọc tôm thịt",
        "slug": "banh-bot-loc-tom-thit",
        "category": "BANH",
        "servingUnit": "đĩa 6 cái",
        "grams": 200,
        "protein": 14.0, "carbs": 44.0, "fat": 8.0,
        "note": "Bánh lọc trong suốt dai giòn bọc nguyên con tôm đỏ và miếng thịt ba rọi kho đậm."
    },
    {
        "name": "Bánh giò nhân thịt nấm",
        "slug": "banh-gio-nhan-thit-nam",
        "category": "BANH",
        "servingUnit": "cái",
        "grams": 220,
        "protein": 14.0, "carbs": 38.0, "fat": 15.0,
        "note": "Bánh bột gạo tẻ mềm mịn gói lá dong với nhân thịt nạc băm, mộc nhĩ và trứng cút."
    },
    {
        "name": "Bánh khọt Vũng Tàu",
        "slug": "banh-khot-vung-tau",
        "category": "BANH",
        "servingUnit": "đĩa 6 cái",
        "grams": 250,
        "protein": 15.0, "carbs": 42.0, "fat": 16.0,
        "note": "Bánh bột gạo chiên vàng giòn rụm trong khuôn tròn, nhân tôm tươi cuộn rau sống cải xanh."
    },
    {
        "name": "Bánh cống Sóc Trăng",
        "slug": "banh-cong-soc-trang",
        "category": "BANH",
        "servingUnit": "cái",
        "grams": 180,
        "protein": 12.0, "carbs": 36.0, "fat": 18.0,
        "note": "Bánh chiên giòn rụm làm từ bột gạo đậu xanh, thịt băm và tôm nguyên vỏ."
    },
    {
        "name": "Bánh tét nhân thịt mỡ",
        "slug": "banh-tet-nhan-thit-mo",
        "category": "BANH",
        "servingUnit": "khoanh",
        "grams": 200,
        "protein": 11.0, "carbs": 56.0, "fat": 15.0,
        "note": "Bánh tét nếp dẻo thơm nhân đậu xanh thịt ba chỉ gói lá chuối hình trụ truyền thống."
    },
    {
        "name": "Bánh tráng nướng Đà Lạt",
        "slug": "banh-trang-nuong-da-lat",
        "category": "BANH",
        "servingUnit": "cái",
        "grams": 150,
        "protein": 9.0, "carbs": 34.0, "fat": 14.0,
        "note": "Pizza Việt Nam nướng than hoa với trứng cút, hành hoa, xúc xích và ruốc khô."
    },
    {
        "name": "Bánh tráng cuốn thịt heo luộc",
        "slug": "banh-trang-cuon-thit-heo-luoc",
        "category": "BANH",
        "servingUnit": "phần",
        "grams": 350,
        "protein": 25.0, "carbs": 45.0, "fat": 18.0,
        "note": "Thịt ba chỉ luộc hai đầu da thái mỏng cuốn bánh tráng phơi sương chấm mắm nêm."
    },
    {
        "name": "Bánh pía sầu riêng trứng muối",
        "slug": "banh-pia-sau-rieng-trung-muoi",
        "category": "BANH",
        "servingUnit": "cái",
        "grams": 100,
        "protein": 6.0, "carbs": 55.0, "fat": 16.0,
        "note": "Vỏ bánh xốp nhiều lớp bọc nhân đậu xanh sầu riêng thơm nồng và lòng đỏ trứng muối."
    },

    # --- 4. NGUỒN ĐẠM & HẢI SẢN BỔ SUNG (20 món) ---
    {
        "name": "Lòng trắng trứng luộc",
        "slug": "long-trang-trung-luoc",
        "category": "DAM",
        "servingUnit": "4 lòng trắng",
        "grams": 130,
        "protein": 15.0, "carbs": 1.0, "fat": 0.2,
        "note": "Nguồn đạm siêu tinh khiết gần như không calo và không chất béo cho gymer siết cơ."
    },
    {
        "name": "Trứng cuộn rau củ",
        "slug": "trung-cuon-rau-cu",
        "category": "DAM",
        "servingUnit": "cuộn",
        "grams": 140,
        "protein": 14.0, "carbs": 4.0, "fat": 12.0,
        "note": "Trứng gà đánh tan cuộn cùng cà rốt thái hạt lựu, hành tây và đậu cove."
    },
    {
        "name": "Thịt bò bít tết áp chảo",
        "slug": "thit-bo-bit-tet-ap-chao",
        "category": "DAM",
        "servingUnit": "miếng",
        "grams": 180,
        "protein": 44.0, "carbs": 0.0, "fat": 15.0,
        "note": "Bò thăn ngoại áp chảo bơ hương thảo chín vừa mọng nước, giàu creatine và sắt tự nhiên."
    },
    {
        "name": "Thịt bê hấp gừng sả",
        "slug": "thit-be-hap-gung-sa",
        "category": "DAM",
        "servingUnit": "phần",
        "grams": 160,
        "protein": 38.0, "carbs": 2.0, "fat": 8.0,
        "note": "Thịt bê non da giòn hấp gừng sả thơm lừng chấm tương bần, ít mỡ giàu protein."
    },
    {
        "name": "Ức gà xé phay bóp gỏi",
        "slug": "uc-ga-xe-phay-bop-goi",
        "category": "DAM",
        "servingUnit": "phần",
        "grams": 220,
        "protein": 42.0, "carbs": 10.0, "fat": 5.0,
        "note": "Ức gà luộc xé bóp với hành tây, rau răm, nước cốt chanh chua ngọt thanh đạm."
    },
    {
        "name": "Gà hấp lá chanh",
        "slug": "ga-hap-la-chanh",
        "category": "DAM",
        "servingUnit": "phần",
        "grams": 200,
        "protein": 36.0, "carbs": 1.0, "fat": 14.0,
        "note": "Thịt gà ta da vàng ươm hấp cùng lá chanh bánh tẻ chấm muối tiêu chanh."
    },
    {
        "name": "Chim cút nướng ngũ vị",
        "slug": "chim-cut-nuong-ngu-vi",
        "category": "DAM",
        "servingUnit": "2 con",
        "grams": 200,
        "protein": 34.0, "carbs": 4.0, "fat": 16.0,
        "note": "Chim cút tẩm ngũ vị hương nướng than hoa vàng giòn thơm ngậy."
    },
    {
        "name": "Cá chẽm hấp hành gừng",
        "slug": "ca-chem-hap-hanh-gung",
        "category": "DAM",
        "servingUnit": "khúc",
        "grams": 200,
        "protein": 36.0, "carbs": 3.0, "fat": 6.0,
        "note": "Thịt cá chẽm trắng ngần mềm thơm hấp cùng gừng sợi và hành lá xì dầu."
    },
    {
        "name": "Cá ngừ đại dương áp chảo",
        "slug": "ca-ngu-dai-duong-ap-chao",
        "category": "DAM",
        "servingUnit": "miếng",
        "grams": 160,
        "protein": 42.0, "carbs": 0.0, "fat": 5.0,
        "note": "Cá ngừ đại dương giàu đạm nạc và omega-3, áp chảo tái lòng đào ăn bùi béo."
    },
    {
        "name": "Cá ngừ ngâm dầu đóng hộp",
        "slug": "ca-ngu-ngam-dau-dong-hop",
        "category": "DAM",
        "servingUnit": "hộp",
        "grams": 140,
        "protein": 32.0, "carbs": 0.0, "fat": 11.0,
        "note": "Nguồn protein tiện lợi nhanh chóng cho gymer chế biến salad hoặc kẹp bánh mì."
    },
    {
        "name": "Tôm nướng muối ớt",
        "slug": "tom-nuong-muoi-ot",
        "category": "DAM",
        "servingUnit": "phần",
        "grams": 180,
        "protein": 36.0, "carbs": 2.0, "fat": 3.0,
        "note": "Tôm sú xiên que nướng than hoa phủ muối ớt cay giòn sần sật ít chất béo."
    },
    {
        "name": "Mực hấp gừng sả",
        "slug": "muc-hap-gung-sa",
        "category": "DAM",
        "servingUnit": "phần",
        "grams": 180,
        "protein": 32.0, "carbs": 3.0, "fat": 3.0,
        "note": "Mực ống tươi hấp gừng sả ngọt lịm giòn sần sật, lượng calo cực thấp."
    },
    {
        "name": "Bạch tuộc nướng sa tế",
        "slug": "bach-tuoc-nuong-sa-te",
        "category": "DAM",
        "servingUnit": "phần",
        "grams": 200,
        "protein": 34.0, "carbs": 6.0, "fat": 6.0,
        "note": "Bạch tuộc nang ướp sa tế cay nướng giòn rụm thơm nồng."
    },
    {
        "name": "Cua biển hấp sả",
        "slug": "cua-bien-hap-sa",
        "category": "DAM",
        "servingUnit": "con",
        "grams": 250,
        "protein": 35.0, "carbs": 1.0, "fat": 4.0,
        "note": "Thịt cua biển ngọt đậm đà giàu kẽm, canxi và protein tinh khiết."
    },
    {
        "name": "Nghêu hấp sả ớt",
        "slug": "ngheu-hap-sa-ot",
        "category": "DAM",
        "servingUnit": "tô",
        "grams": 300,
        "protein": 22.0, "carbs": 8.0, "fat": 3.0,
        "note": "Nghêu tươi hấp sả thơm lừng với nước súp cay nồng ấm bụng."
    },
    {
        "name": "Đậu hũ non hấp hành xì dầu",
        "slug": "dau-hu-non-hap-hanh-xi-dau",
        "category": "DAM",
        "servingUnit": "phần",
        "grams": 220,
        "protein": 18.0, "carbs": 6.0, "fat": 8.0,
        "note": "Đậu hũ lụa non mềm mướt hấp ấm rưới xì dầu ít natri, đạm thực vật lành mạnh."
    },
    {
        "name": "Đậu hũ nhồi thịt hấp sốt cà",
        "slug": "dau-hu-nhoi-thit-hap-sot-ca",
        "category": "DAM",
        "servingUnit": "phần",
        "grams": 240,
        "protein": 24.0, "carbs": 12.0, "fat": 14.0,
        "note": "Đậu miếng khoét ruột nhồi thịt nạc băm hấp chín rồi sốt cà chua thanh mát."
    },
    {
        "name": "Chả lụa heo hấp",
        "slug": "cha-lua-heo-hap",
        "category": "DAM",
        "servingUnit": "3 khoanh",
        "grams": 100,
        "protein": 18.0, "carbs": 3.0, "fat": 10.0,
        "note": "Giò lụa truyền thống làm từ nạc mông heo quết nhuyễn gói lá chuối hấp chín."
    },
    {
        "name": "Chả bò Đà Nẵng",
        "slug": "cha-bo-da-nang",
        "category": "DAM",
        "servingUnit": "3 khoanh",
        "grams": 100,
        "protein": 20.0, "carbs": 2.0, "fat": 9.0,
        "note": "Chả bò miền Trung đậm đà thơm mùi tiêu đen và thì là giòn dai tự nhiên."
    },
    {
        "name": "Nem nướng Nha Trang",
        "slug": "nem-nuong-nha-trang",
        "category": "DAM",
        "servingUnit": "phần",
        "grams": 250,
        "protein": 26.0, "carbs": 28.0, "fat": 15.0,
        "note": "Nem thịt heo quết nướng than hoa cuộn bánh tráng, rau sống và nước chấm đậu phộng."
    },

    # --- 5. CANH & RAU CỦ BỔ SUNG (15 món) ---
    {
        "name": "Canh khổ qua nhồi thịt",
        "slug": "canh-kho-qua-nhoi-thit",
        "category": "CANH_RAU",
        "servingUnit": "tô",
        "grams": 320,
        "protein": 18.0, "carbs": 14.0, "fat": 9.0,
        "note": "Khổ qua hầm mềm nhồi thịt nạc băm, vị đắng thanh giải nhiệt bổ dưỡng."
    },
    {
        "name": "Canh cua mồng tơi mướp hương",
        "slug": "canh-cua-mong-toi-muop-huong",
        "category": "CANH_RAU",
        "servingUnit": "tô",
        "grams": 300,
        "protein": 14.0, "carbs": 12.0, "fat": 6.0,
        "note": "Canh cua đồng gạch béo nấu cùng rau mồng tơi và mướp hương thanh mát mùa hè."
    },
    {
        "name": "Canh gà lá giang",
        "slug": "canh-ga-la-giang",
        "category": "CANH_RAU",
        "servingUnit": "tô",
        "grams": 350,
        "protein": 24.0, "carbs": 8.0, "fat": 12.0,
        "note": "Thịt gà chặt miếng nấu lá giang chua dịu kích thích tiêu hóa."
    },
    {
        "name": "Canh sườn hầm rau củ",
        "slug": "canh-suon-ham-rau-cu",
        "category": "CANH_RAU",
        "servingUnit": "tô",
        "grams": 350,
        "protein": 20.0, "carbs": 22.0, "fat": 12.0,
        "note": "Sườn non hầm cùng khoai tây, cà rốt và bắp ngọt giàu vitamin và khoáng chất."
    },
    {
        "name": "Canh ngao nấu chua",
        "slug": "canh-ngao-nau-chua",
        "category": "CANH_RAU",
        "servingUnit": "tô",
        "grams": 320,
        "protein": 16.0, "carbs": 12.0, "fat": 4.0,
        "note": "Ngao tươi nấu dứa chua, cà chua, hành thì là ngọt thanh dễ ăn."
    },
    {
        "name": "Canh rong biển thịt bò",
        "slug": "canh-rong-bien-thit-bo",
        "category": "CANH_RAU",
        "servingUnit": "tô",
        "grams": 300,
        "protein": 18.0, "carbs": 8.0, "fat": 6.0,
        "note": "Rong biển bổ sung i-ốt và khoáng chất nấu cùng thịt thăn bò thái mỏng."
    },
    {
        "name": "Canh kim chi đậu phụ thịt nạc",
        "slug": "canh-kim-chi-dau-phu-thit-nac",
        "category": "CANH_RAU",
        "servingUnit": "tô",
        "grams": 320,
        "protein": 20.0, "carbs": 12.0, "fat": 8.0,
        "note": "Kim chi cay chua nấu đậu hũ mềm và thịt heo nạc ấm bụng ngày mưa."
    },
    {
        "name": "Rau củ luộc chấm kho quẹt",
        "slug": "rau-cu-luoc-cham-kho-quet",
        "category": "CANH_RAU",
        "servingUnit": "đĩa",
        "grams": 300,
        "protein": 8.0, "carbs": 26.0, "fat": 8.0,
        "note": "Đậu bắp, bầu, cà rốt, cải ngọt luộc chấm nước mắm kho quẹt bùi béo."
    },
    {
        "name": "Măng tây xào tỏi",
        "slug": "mang-tay-xao-toi",
        "category": "CANH_RAU",
        "servingUnit": "đĩa",
        "grams": 180,
        "protein": 5.0, "carbs": 10.0, "fat": 6.0,
        "note": "Măng tây xanh non xào dầu ô liu tỏi thơm giòn, giàu chất xơ và folate."
    },
    {
        "name": "Đậu cove xào thịt bò",
        "slug": "dau-cove-xao-thit-bo",
        "category": "CANH_RAU",
        "servingUnit": "đĩa",
        "grams": 220,
        "protein": 24.0, "carbs": 12.0, "fat": 9.0,
        "note": "Đậu cove luộc sơ rồi xào lửa lớn cùng thịt bắp bò mềm ngọt."
    },
    {
        "name": "Đọt bí xào tỏi",
        "slug": "dot-bi-xao-toi",
        "category": "CANH_RAU",
        "servingUnit": "đĩa",
        "grams": 200,
        "protein": 6.0, "carbs": 10.0, "fat": 8.0,
        "note": "Ngọn bí đỏ tước sạch xào tỏi đập dập thơm lừng giòn ngọt dân dã."
    },
    {
        "name": "Bắp cải luộc chấm trứng dầm nước mắm",
        "slug": "bap-cai-luoc-cham-trung",
        "category": "CANH_RAU",
        "servingUnit": "đĩa",
        "grams": 250,
        "protein": 10.0, "carbs": 14.0, "fat": 6.0,
        "note": "Bắp cải tươi luộc chín tới ngọt lịm chấm trứng gà luộc dầm nước mắm ngon."
    },
    {
        "name": "Bí ngòi nướng tiêu đen",
        "slug": "bi-ngoi-nuong-tieu-den",
        "category": "CANH_RAU",
        "servingUnit": "đĩa",
        "grams": 180,
        "protein": 3.0, "carbs": 8.0, "fat": 3.0,
        "note": "Bí ngòi thái lát tròn áp chảo với chút dầu ô liu và tiêu đen thơm nồng."
    },
    {
        "name": "Kim chi cải thảo truyền thống",
        "slug": "kim-chi-cai-thao-truyen-thong",
        "category": "CANH_RAU",
        "servingUnit": "phần",
        "grams": 100,
        "protein": 2.0, "carbs": 5.0, "fat": 0.5,
        "note": "Món ăn lên men tự nhiên bổ sung probiotics tốt cho hệ đường ruột người tập luyện."
    },
    {
        "name": "Nộm đu đủ bò khô",
        "slug": "nom-du-du-bo-kho",
        "category": "CANH_RAU",
        "servingUnit": "đĩa",
        "grams": 200,
        "protein": 14.0, "carbs": 24.0, "fat": 4.0,
        "note": "Đu đủ xanh bào sợi giòn sần sật trộn bò khô, rau kinh giới và lạc rang."
    },

    # --- 6. TINH BỘT CHẬM & EAT CLEAN NUTRITION (15 món) ---
    {
        "name": "Bánh mì đen nguyên cám",
        "slug": "banh-mi-den-nguyen-cam",
        "category": "TINH_BOT",
        "servingUnit": "2 lát",
        "grams": 80,
        "protein": 7.0, "carbs": 36.0, "fat": 2.0,
        "note": "Bánh mì lúa mạch đen nguyên cám giàu chất xơ, chỉ số đường huyết GI thấp."
    },
    {
        "name": "Yến mạch ngâm qua đêm (Overnight Oats)",
        "slug": "yen-mach-overnight-oats",
        "category": "TINH_BOT",
        "servingUnit": "hũ",
        "grams": 220,
        "protein": 14.0, "carbs": 44.0, "fat": 6.0,
        "note": "Yến mạch cán dẹt ngâm sữa tươi không đường, hạt chia và sữa chua Hy Lạp."
    },
    {
        "name": "Hạt diêm mạch Quinoa nấu chín",
        "slug": "hat-diem-mach-quinoa-nau-chin",
        "category": "TINH_BOT",
        "servingUnit": "chén",
        "grams": 150,
        "protein": 6.0, "carbs": 32.0, "fat": 3.0,
        "note": "Siêu thực phẩm chứa đủ 9 loại axit amin thiết yếu thay thế cơm trắng tuyệt vời."
    },
    {
        "name": "Cơm gạo lứt tím than",
        "slug": "com-gao-lut-tim-than",
        "category": "TINH_BOT",
        "servingUnit": "chén",
        "grams": 150,
        "protein": 5.0, "carbs": 36.0, "fat": 2.0,
        "note": "Gạo lứt tím giàu chất chống oxy hóa anthocyanin và chất xơ no lâu."
    },
    {
        "name": "Bún gạo lứt luộc",
        "slug": "bun-gao-lut-luoc",
        "category": "TINH_BOT",
        "servingUnit": "phần",
        "grams": 180,
        "protein": 5.0, "carbs": 42.0, "fat": 1.0,
        "note": "Sợi bún gạo lứt dai ngon thay thế bún trắng cho thực đơn ăn kiêng lành mạnh."
    },
    {
        "name": "Mì kiều mạch Soba luộc",
        "slug": "mi-kieu-mach-soba-luoc",
        "category": "TINH_BOT",
        "servingUnit": "phần",
        "grams": 160,
        "protein": 8.0, "carbs": 38.0, "fat": 1.0,
        "note": "Mì kiều mạch nguyên chất thơm bùi tốt cho tim mạch và kiểm soát cân nặng."
    },
    {
        "name": "Khoai môn hấp",
        "slug": "khoai-mon-hap",
        "category": "TINH_BOT",
        "servingUnit": "củ",
        "grams": 150,
        "protein": 3.0, "carbs": 39.0, "fat": 0.5,
        "note": "Khoai môn bùi ngọt thơm ngậy, tinh bột phức hợp cung cấp năng lượng bền vững."
    },
    {
        "name": "Khoai mỡ luộc",
        "slug": "khoai-mo-luoc",
        "category": "TINH_BOT",
        "servingUnit": "phần",
        "grams": 150,
        "protein": 2.5, "carbs": 35.0, "fat": 0.3,
        "note": "Khoai mỡ tím dẻo bùi giàu vitamin C và chất xơ tự nhiên."
    },
    {
        "name": "Hạt sen tươi hầm",
        "slug": "hat-sen-tuoi-ham",
        "category": "TINH_BOT",
        "servingUnit": "chén nhỏ",
        "grams": 120,
        "protein": 6.0, "carbs": 26.0, "fat": 0.6,
        "note": "Hạt sen bở tơi thanh ngọt an thần, bổ dưỡng cho phục hồi cơ bắp và giấc ngủ."
    },
    {
        "name": "Đậu đen hầm không đường",
        "slug": "dau-den-ham-khong-duong",
        "category": "TINH_BOT",
        "servingUnit": "chén",
        "grams": 150,
        "protein": 11.0, "carbs": 32.0, "fat": 0.8,
        "note": "Đậu đen giàu protein thực vật, anthocyanin và chất xơ hòa tan tốt cho tiêu hóa."
    },
    {
        "name": "Đậu đỏ hầm nhừ",
        "slug": "dau-do-ham-nhu",
        "category": "TINH_BOT",
        "servingUnit": "chén",
        "grams": 150,
        "protein": 10.0, "carbs": 34.0, "fat": 0.6,
        "note": "Đậu đỏ bùi ngọt giúp thanh lọc cơ thể và cung cấp năng lượng sạch."
    },
    {
        "name": "Đậu xanh nấu chín",
        "slug": "dau-xanh-nau-chin",
        "category": "TINH_BOT",
        "servingUnit": "chén",
        "grams": 150,
        "protein": 10.0, "carbs": 31.0, "fat": 0.8,
        "note": "Đậu xanh thanh nhiệt giải độc, giàu kali và magie chống chuột rút khi tập luyện."
    },
    {
        "name": "Granola yến mạch hạt nướng mật ong",
        "slug": "granola-yen-mach-hat-nuong",
        "category": "TINH_BOT",
        "servingUnit": "khẩu phần",
        "grams": 45,
        "protein": 6.0, "carbs": 24.0, "fat": 9.0,
        "note": "Yến mạch giòn rụm nướng cùng mật ong, hạt điều, hạnh nhân và nho khô."
    },
    {
        "name": "Hạt chia ngâm nước",
        "slug": "hat-chia-ngam-nuoc",
        "category": "TINH_BOT",
        "servingUnit": "muỗng canh",
        "grams": 15,
        "protein": 3.0, "carbs": 6.0, "fat": 4.5,
        "note": "Giàu chất xơ hòa tan và axit béo omega-3 thực vật hỗ trợ hấp thụ dưỡng chất."
    },
    {
        "name": "Bánh bao nguyên cám ức gà",
        "slug": "banh-bao-nguyen-cam-uc-ga",
        "category": "BANH",
        "servingUnit": "cái",
        "grams": 150,
        "protein": 20.0, "carbs": 38.0, "fat": 5.0,
        "note": "Bánh bao bột mì nguyên cám nhân ức gà nấm hương, bữa ăn phụ tiện lợi cho gymer."
    },

    # --- 7. TRÁI CÂY, HẠT & ĐỒ ĂN VẶT HEALTHY (14 món) ---
    {
        "name": "Kiwi xanh tươi",
        "slug": "kiwi-xanh-tuoi",
        "category": "TRAI_CAY",
        "servingUnit": "quả",
        "grams": 100,
        "protein": 1.1, "carbs": 15.0, "fat": 0.5,
        "note": "Kiwi chứa hàm lượng enzyme actinidin và vitamin C dồi dào hỗ trợ tiêu hóa đạm."
    },
    {
        "name": "Dâu tây tươi",
        "slug": "dau-tay-tuoi",
        "category": "TRAI_CAY",
        "servingUnit": "hộp nhỏ",
        "grams": 150,
        "protein": 1.0, "carbs": 12.0, "fat": 0.5,
        "note": "Dâu tây tươi mọng chua ngọt, cực kỳ ít calo và giàu chất chống oxy hóa."
    },
    {
        "name": "Việt quất tươi",
        "slug": "viet-quat-tuoi",
        "category": "TRAI_CAY",
        "servingUnit": "hộp nhỏ",
        "grams": 100,
        "protein": 0.7, "carbs": 14.0, "fat": 0.3,
        "note": "Việt quất giàu flavonoid giúp phục hồi viêm cơ bắp sau các buổi tập cường độ cao."
    },
    {
        "name": "Lựu đỏ tách hạt",
        "slug": "luu-do-tach-hat",
        "category": "TRAI_CAY",
        "servingUnit": "chén",
        "grams": 150,
        "protein": 2.5, "carbs": 28.0, "fat": 1.8,
        "note": "Hạt lựu đỏ mọng nước giàu nitric oxide tự nhiên giúp giãn mạch máu và bơm cơ tốt hơn."
    },
    {
        "name": "Nho đen không hạt",
        "slug": "nho-den-khong-hat",
        "category": "TRAI_CAY",
        "servingUnit": "chùm nhỏ",
        "grams": 150,
        "protein": 1.0, "carbs": 27.0, "fat": 0.2,
        "note": "Cung cấp đường đơn nhanh phục hồi glycogen ngay sau buổi tập mệt mỏi."
    },
    {
        "name": "Mãng cầu xiêm",
        "slug": "mang-cau-xiem",
        "category": "TRAI_CAY",
        "servingUnit": "phần",
        "grams": 200,
        "protein": 2.0, "carbs": 33.0, "fat": 0.6,
        "note": "Mãng cầu chua ngọt đậm vị giàu vitamin B1, B2 và khoáng chất tự nhiên."
    },
    {
        "name": "Hạt hạnh nhân sấy mộc",
        "slug": "hat-hanh-nhan-say-moc",
        "category": "AN_VAT",
        "servingUnit": "nắm",
        "grams": 30,
        "protein": 6.5, "carbs": 6.0, "fat": 15.0,
        "note": "Hạnh nhân giàu vitamin E, magie và chất béo không bão hòa đơn tốt cho tim mạch."
    },
    {
        "name": "Hạt óc chó sấy",
        "slug": "hat-oc-cho-say",
        "category": "AN_VAT",
        "servingUnit": "nắm",
        "grams": 30,
        "protein": 4.5, "carbs": 4.0, "fat": 20.0,
        "note": "Quả óc chó đứng đầu về hàm lượng axit béo omega-3 ALA tốt cho não bộ."
    },
    {
        "name": "Hạt macca sấy nứt vỏ",
        "slug": "hat-macca-say-nut-vo",
        "category": "AN_VAT",
        "servingUnit": "nắm",
        "grams": 30,
        "protein": 2.5, "carbs": 4.0, "fat": 22.0,
        "note": "Hạt macca béo ngậy thơm ngon chứa nhiều chất béo đơn không bão hòa."
    },
    {
        "name": "Hạt bí xanh bóc vỏ",
        "slug": "hat-bi-xanh-boc-vo",
        "category": "AN_VAT",
        "servingUnit": "nắm",
        "grams": 30,
        "protein": 9.0, "carbs": 4.0, "fat": 14.0,
        "note": "Hạt bí ngô giàu kẽm tự nhiên tăng cường testosterone sinh lý và sức mạnh cơ bắp."
    },
    {
        "name": "Bơ đậu phộng nguyên chất không đường",
        "slug": "bo-dau-phong-khong-duong",
        "category": "AN_VAT",
        "servingUnit": "muỗng canh",
        "grams": 32,
        "protein": 8.0, "carbs": 6.0, "fat": 16.0,
        "note": "100% đậu phộng rang xay mịn, nguồn đạm và chất béo tốt lý tưởng để phết bánh mì."
    },
    {
        "name": "Phô mai con bò cười",
        "slug": "pho-mai-con-bo-cuoi",
        "category": "AN_VAT",
        "servingUnit": "miếng tam giác",
        "grams": 15,
        "protein": 1.8, "carbs": 0.8, "fat": 3.8,
        "note": "Phô mai miếng mềm béo ngậy giàu canxi củng cố khung xương khớp chắc khỏe."
    },
    {
        "name": "Phô mai lát Cheddar",
        "slug": "pho-mai-lat-cheddar",
        "category": "AN_VAT",
        "servingUnit": "lát",
        "grams": 21,
        "protein": 5.0, "carbs": 0.5, "fat": 7.0,
        "note": "Phô mai lát vàng ươm thơm béo kẹp bánh mì sandwich tăng cường protein và chất béo."
    },
    {
        "name": "Sữa chua Hy Lạp hạt chia quả mọng",
        "slug": "sua-chua-hy-lap-hat-chia",
        "category": "AN_VAT",
        "servingUnit": "hộp",
        "grams": 180,
        "protein": 18.0, "carbs": 16.0, "fat": 5.0,
        "note": "Sữa chua Hy Lạp đậm đặc gấp đôi đạm kết hợp hạt chia và quả mọng thơm ngon."
    },

    # --- 8. THỰC PHẨM BỔ SUNG & ĐỒ UỐNG GYM THỂ THAO (11 món) ---
    {
        "name": "Whey Protein Isolate pha nước",
        "slug": "whey-protein-isolate",
        "category": "DO_UONG",
        "servingUnit": "muỗng scoop",
        "grams": 30,
        "protein": 25.0, "carbs": 1.5, "fat": 0.5,
        "note": "Bột đạm whey cô lập hấp thụ siêu nhanh trong 30 phút sau tập giúp phục hồi cơ bắp tối ưu."
    },
    {
        "name": "Casein Protein bột pha sữa",
        "slug": "casein-protein-bot",
        "category": "DO_UONG",
        "servingUnit": "muỗng scoop",
        "grams": 33,
        "protein": 24.0, "carbs": 3.0, "fat": 1.0,
        "note": "Đạm hấp thụ chậm duy trì nuôi dưỡng cơ bắp suốt 7-8 tiếng trong khi ngủ ban đêm."
    },
    {
        "name": "Sữa hạt hạnh nhân không đường",
        "slug": "sua-hat-hanh-nhan-khong-duong",
        "category": "DO_UONG",
        "servingUnit": "ly",
        "grams": 250,
        "protein": 2.5, "carbs": 3.0, "fat": 3.5,
        "note": "Sữa thực vật thơm bùi thanh mát, lượng calo chỉ khoảng 50 kcal mỗi ly."
    },
    {
        "name": "Sữa tươi tiệt trùng ít đường",
        "slug": "sua-tuoi-it-duong",
        "category": "DO_UONG",
        "servingUnit": "ly",
        "grams": 250,
        "protein": 8.0, "carbs": 18.0, "fat": 8.0,
        "note": "Sữa bò tươi bổ sung canxi, vitamin D và đạm chất lượng cao phát triển thể lực."
    },
    {
        "name": "Nước ép cần tây táo xanh",
        "slug": "nuoc-ep-can-tay-tao-xanh",
        "category": "DO_UONG",
        "servingUnit": "ly",
        "grams": 300,
        "protein": 1.5, "carbs": 18.0, "fat": 0.2,
        "note": "Thức uống detox thanh lọc cơ thể, giảm đầy hơi và cân bằng điện giải."
    },
    {
        "name": "Nước ép bưởi hồng nguyên chất",
        "slug": "nuoc-ep-buoi-hong-nguyen-chat",
        "category": "DO_UONG",
        "servingUnit": "ly",
        "grams": 250,
        "protein": 1.8, "carbs": 24.0, "fat": 0.2,
        "note": "Bưởi chứa naringin kích thích đốt mỡ tự nhiên và cung cấp vitamin C dồi dào."
    },
    {
        "name": "Nước ép cà rốt cam tươi",
        "slug": "nuoc-ep-ca-rot-cam-tuoi",
        "category": "DO_UONG",
        "servingUnit": "ly",
        "grams": 250,
        "protein": 2.0, "carbs": 26.0, "fat": 0.3,
        "note": "Bổ sung dồi dào beta-carotene tốt cho mắt và hệ miễn dịch khỏe mạnh."
    },
    {
        "name": "Trà xanh nguyên chất đá",
        "slug": "tra-xanh-nguyen-chat-da",
        "category": "DO_UONG",
        "servingUnit": "ly",
        "grams": 300,
        "protein": 0.0, "carbs": 1.0, "fat": 0.0,
        "note": "Trà xanh lá tươi giàu chất chống oxy hóa EGCG tăng tốc độ trao đổi chất."
    },
    {
        "name": "Trà tim sen thảo mộc",
        "slug": "tra-tim-sen-thao-moc",
        "category": "DO_UONG",
        "servingUnit": "tách",
        "grams": 200,
        "protein": 0.0, "carbs": 0.5, "fat": 0.0,
        "note": "Trà thảo mộc vị đắng dịu an thần, hạ huyết áp và tạo giấc ngủ sâu sau tập."
    },
    {
        "name": "Nước điện giải Isotonic thể thao",
        "slug": "nuoc-dien-giai-isotonic",
        "category": "DO_UONG",
        "servingUnit": "chai",
        "grams": 500,
        "protein": 0.0, "carbs": 30.0, "fat": 0.0,
        "note": "Bù nước và khoáng chất natri, kali, magie tức thì trong các bài tập cardio kéo dài."
    },
    {
        "name": "Sinh tố chuối bơ Whey Protein",
        "slug": "sinh-to-chuoi-bo-whey",
        "category": "DO_UONG",
        "servingUnit": "ly lớn",
        "grams": 400,
        "protein": 32.0, "carbs": 45.0, "fat": 12.0,
        "note": "Bữa ăn lỏng hoàn hảo trước hoặc sau tập với chuối tây, quả bơ, sữa tươi và whey protein."
    }
]

def main():
    print(f"Total new foods defined: {len(NEW_FOODS_DEF)}")
    
    # Check duplicate slugs inside new items
    slugs = set()
    for item in NEW_FOODS_DEF:
        if item["slug"] in slugs:
            raise ValueError(f"Duplicate slug in NEW_FOODS_DEF: {item['slug']}")
        slugs.add(item["slug"])
        
    print("All new food slugs are unique!")
    
    # Generate SQL file
    sql_lines = [
        "-- VieGym Vietnamese Food Dataset v1 Expansion",
        "-- Auto-generated by datasets/scripts/build_foods_v1.py",
        "-- Expanding from 80 Golden foods to 203+ MVP foods",
        "",
        "WITH new_seed(name, search_name, slug, category, serving_unit, grams, protein_g, carbs_g, fat_g, note) AS (",
        "    VALUES"
    ]
    
    val_rows = []
    for f in NEW_FOODS_DEF:
        name = f["name"].replace("'", "''")
        search_name = remove_accents(f["name"]).replace("'", "''")
        slug = f["slug"]
        cat = f["category"]
        unit = f["servingUnit"].replace("'", "''")
        grams = f["grams"]
        p = f["protein"]
        c = f["carbs"]
        fat = f["fat"]
        note = f["note"].replace("'", "''")
        val_rows.append(f"    ('{name}', '{search_name}', '{slug}', '{cat}', '{unit}', {grams}, {p}, {c}, {fat}, '{note}')")
        
    sql_lines.append(",\n".join(val_rows))
    sql_lines.extend([
        ")",
        "INSERT INTO foods (",
        "    name, search_name, slug, category, serving_amount, serving_unit, grams_per_serving,",
        "    calories_per_serving, protein_g_per_serving, carbs_g_per_serving, fat_g_per_serving,",
        "    data_source, source_note, is_estimated, visibility",
        ")",
        "SELECT name, search_name, slug, category, 1, serving_unit, grams,",
        "       ROUND(protein_g * 4 + carbs_g * 4 + fat_g * 9, 2),",
        "       protein_g, carbs_g, fat_g,",
        "       'VieGym Vietnamese Food Dataset v1',",
        "       note,",
        "       true, 'PUBLIC'",
        "FROM new_seed",
        "ON CONFLICT (slug) DO UPDATE SET",
        "    name = EXCLUDED.name,",
        "    search_name = EXCLUDED.search_name,",
        "    category = EXCLUDED.category,",
        "    serving_unit = EXCLUDED.serving_unit,",
        "    grams_per_serving = EXCLUDED.grams_per_serving,",
        "    calories_per_serving = EXCLUDED.calories_per_serving,",
        "    protein_g_per_serving = EXCLUDED.protein_g_per_serving,",
        "    carbs_g_per_serving = EXCLUDED.carbs_g_per_serving,",
        "    fat_g_per_serving = EXCLUDED.fat_g_per_serving,",
        "    data_source = EXCLUDED.data_source,",
        "    source_note = EXCLUDED.source_note,",
        "    updated_at = CURRENT_TIMESTAMP;",
        ""
    ])
    
    sql_path = "datasets/exports/import_new_foods.sql"
    with open(sql_path, "w", encoding="utf-8") as out_f:
        out_f.write("\n".join(sql_lines))
    print(f"Generated SQL file at {sql_path}")

if __name__ == "__main__":
    main()
