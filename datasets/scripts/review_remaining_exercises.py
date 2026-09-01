#!/usr/bin/env python3
from __future__ import annotations

import sys
from pathlib import Path
from typing import Any

from common import DATASETS_ROOT, load_json, write_json


VIETNAMESE_NAMES = {
    "3_4_Sit-Up": "Gập bụng 3/4",
    "Ab_Crunch_Machine": "Gập bụng với máy",
    "Advanced_Kettlebell_Windmill": "Kettlebell windmill nâng cao",
    "Alternate_Hammer_Curl": "Cuốn tạ búa luân phiên",
    "Alternate_Heel_Touchers": "Chạm gót chân luân phiên",
    "Alternate_Incline_Dumbbell_Curl": "Cuốn tạ đơn trên ghế nghiêng luân phiên",
    "Alternating_Cable_Shoulder_Press": "Đẩy vai cáp luân phiên",
    "Alternating_Deltoid_Raise": "Nâng vai tạ đơn luân phiên",
    "Alternating_Floor_Press": "Đẩy tạ ấm trên sàn luân phiên",
    "Alternating_Hang_Clean": "Kettlebell hang clean luân phiên",
    "Alternating_Kettlebell_Press": "Đẩy tạ ấm qua đầu luân phiên",
    "Alternating_Kettlebell_Row": "Kéo tạ ấm luân phiên",
    "Alternating_Renegade_Row": "Renegade row luân phiên",
    "Anti-Gravity_Press": "Anti-gravity press với thanh đòn",
    "Arnold_Dumbbell_Press": "Arnold press với tạ đơn",
    "Around_The_Worlds": "Vòng tạ đơn quanh ngực",
    "Back_Flyes_-_With_Bands": "Dang vai sau với dây kháng lực",
    "Band_Hip_Adductions": "Khép hông với dây kháng lực",
    "Band_Pull_Apart": "Kéo giãn dây ngang ngực",
    "Band_Skull_Crusher": "Duỗi tay sau nằm với dây kháng lực",
    "Barbell_Ab_Rollout": "Lăn thanh đòn tập bụng",
    "Barbell_Ab_Rollout_-_On_Knees": "Lăn thanh đòn quỳ gối",
    "Barbell_Curls_Lying_Against_An_Incline": "Cuốn thanh đòn tựa ghế nghiêng",
    "Barbell_Guillotine_Bench_Press": "Guillotine bench press với thanh đòn",
    "Barbell_Hack_Squat": "Hack squat với thanh đòn",
    "Barbell_Incline_Bench_Press_-_Medium_Grip": "Đẩy ngực trên với thanh đòn",
    "Barbell_Lunge": "Chùng chân với thanh đòn",
    "Barbell_Rollout_from_Bench": "Lăn thanh đòn từ ghế",
    "Barbell_Seated_Calf_Raise": "Nhón bắp chân ngồi với thanh đòn",
    "Barbell_Shrug": "Nhún cầu vai với thanh đòn",
    "Barbell_Shrug_Behind_The_Back": "Nhún cầu vai với thanh đòn sau lưng",
    "Barbell_Side_Bend": "Nghiêng thân bên với thanh đòn",
    "Barbell_Side_Split_Squat": "Split squat ngang với thanh đòn",
    "Barbell_Squat": "Squat với thanh đòn",
    "Barbell_Squat_To_A_Bench": "Squat thanh đòn chạm ghế",
    "Barbell_Step_Ups": "Bước lên bục với thanh đòn",
    "Barbell_Walking_Lunge": "Chùng chân bước đi với thanh đòn",
    "Bench_Dips": "Dip tay sau trên ghế",
    "Bench_Press_-_With_Bands": "Đẩy ngực với dây kháng lực",
    "Bent-Arm_Barbell_Pullover": "Pullover tay cong với thanh đòn",
    "Bent-Arm_Dumbbell_Pullover": "Pullover tay cong với tạ đơn",
    "Bent_Over_Barbell_Row": "Kéo thanh đòn gập người",
    "Bent_Over_One-Arm_Long_Bar_Row": "Kéo đầu thanh đòn một tay",
    "Bent_Over_Two-Arm_Long_Bar_Row": "Kéo đầu thanh đòn hai tay",
    "Bent_Over_Two-Dumbbell_Row": "Kéo hai tạ đơn gập người",
    "Bent_Over_Two-Dumbbell_Row_With_Palms_In": "Kéo hai tạ đơn tay trung tính",
    "Body-Up": "Duỗi tay sau bằng cẳng tay",
    "Body_Tricep_Press": "Duỗi tay sau với trọng lượng cơ thể",
    "Bottoms-Up_Clean_From_The_Hang_Position": "Bottoms-up clean từ tư thế treo",
    "Butt_Lift_Bridge": "Cầu mông",
    "Butterfly": "Ép ngực máy butterfly",
    "Cable_Hammer_Curls_-_Rope_Attachment": "Cuốn tay búa với dây cáp",
    "Cable_Incline_Pushdown": "Kéo cáp tay thẳng trên ghế nghiêng",
    "Cable_Incline_Triceps_Extension": "Duỗi tay sau cáp trên ghế nghiêng",
    "Cable_Lying_Triceps_Extension": "Duỗi tay sau cáp nằm",
    "Cable_One_Arm_Tricep_Extension": "Duỗi tay sau cáp một tay",
    "Cable_Preacher_Curl": "Cuốn tay trước preacher với cáp",
    "Cable_Shrugs": "Nhún cầu vai với cáp",
    "Cable_Wrist_Curl": "Cuốn cổ tay với cáp",
    "Calf-Machine_Shoulder_Shrug": "Nhún cầu vai trên máy bắp chân",
    "Calf_Press": "Đạp bắp chân trên máy",
    "Calf_Press_On_The_Leg_Press_Machine": "Đạp bắp chân trên máy leg press",
    "Calf_Raise_On_A_Dumbbell": "Nhón bắp chân trên tạ đơn",
    "Calf_Raises_-_With_Bands": "Nhón bắp chân với dây kháng lực",
    "Chin-Up": "Hít xà tay ngửa",
    "Close-Grip_EZ_Bar_Curl": "Cuốn thanh EZ tay hẹp",
    "Close-Grip_Front_Lat_Pulldown": "Kéo xô trước tay hẹp",
    "Close-Grip_Standing_Barbell_Curl": "Cuốn thanh đòn đứng tay hẹp",
    "Concentration_Curls": "Cuốn tạ tập trung",
    "Double_Kettlebell_Alternating_Hang_Clean": "Hang clean hai tạ ấm luân phiên",
    "Dumbbell_Clean": "Dumbbell clean",
    "Dumbbell_Lying_Pronation": "Xoay sấp cẳng tay với tạ đơn",
    "Dumbbell_Lying_Supination": "Xoay ngửa cẳng tay với tạ đơn",
    "Dumbbell_Seated_One-Leg_Calf_Raise": "Nhón bắp chân một chân ngồi với tạ đơn",
    "Dumbbell_Shrug": "Nhún cầu vai với tạ đơn",
    "Elevated_Cable_Rows": "Kéo cáp cao về thân",
    "Finger_Curls": "Cuốn ngón tay với thanh đòn",
    "Flutter_Kicks": "Đá chân luân phiên",
    "Full_Range-Of-Motion_Lat_Pulldown": "Kéo xô toàn biên độ",
    "Glute_Kickback": "Đá chân sau tập mông",
    "Hip_Extension_with_Bands": "Duỗi hông với dây kháng lực",
    "Hyperextensions_With_No_Hyperextension_Bench": "Duỗi lưng trên sàn",
    "Isometric_Neck_Exercise_-_Front_And_Back": "Giữ đẳng trường cổ trước và sau",
    "Isometric_Neck_Exercise_-_Sides": "Giữ đẳng trường cổ hai bên",
    "Kettlebell_Dead_Clean": "Kettlebell dead clean",
    "Kettlebell_Hang_Clean": "Kettlebell hang clean",
    "Kettlebell_One-Legged_Deadlift": "Deadlift một chân với tạ ấm",
    "Kettlebell_Sumo_High_Pull": "Sumo high pull với tạ ấm",
    "Kneeling_High_Pulley_Row": "Kéo cáp cao quỳ gối",
    "Leg_Lift": "Nâng chân nằm sấp",
    "Leverage_Shrug": "Nhún cầu vai với máy đòn bẩy",
    "Lunge_Pass_Through": "Chùng chân luồn tạ ấm",
    "Monster_Walk": "Bước ngang monster walk với dây",
    "One-Legged_Cable_Kickback": "Đá chân sau một chân với cáp",
    "Palms-Down_Dumbbell_Wrist_Curl_Over_A_Bench": "Duỗi cổ tay sấp với tạ đơn trên ghế",
    "Palms-Down_Wrist_Curl_Over_A_Bench": "Duỗi cổ tay sấp với thanh đòn trên ghế",
    "Pull_Through": "Cable pull-through",
    "Rocking_Standing_Calf_Raise": "Nhón bắp chân đứng chuyển trọng tâm",
    "Seated_Calf_Raise": "Nhón bắp chân ngồi với máy",
    "Stiff_Leg_Barbell_Good_Morning": "Good morning chân gần thẳng với thanh đòn",
    "Thigh_Abductor": "Dạng đùi với máy",
    "Thigh_Adductor": "Khép đùi với máy",
}


MUSCLE_NAMES = {
    "ABS": "cơ bụng và vùng core",
    "ABDUCTORS": "cơ dạng hông",
    "ADDUCTORS": "cơ khép hông",
    "BICEPS": "cơ tay trước",
    "CALVES": "cơ bắp chân",
    "CHEST": "cơ ngực",
    "FOREARMS": "cơ cẳng tay",
    "GLUTES": "cơ mông",
    "HAMSTRINGS": "cơ đùi sau",
    "LATS": "cơ lưng xô",
    "LOWER_BACK": "cơ lưng dưới",
    "NECK": "cơ cổ",
    "QUADRICEPS": "cơ đùi trước",
    "SHOULDERS": "cơ vai",
    "TRAPS": "cơ cầu vai",
    "TRICEPS": "cơ tay sau",
    "UPPER_BACK": "cơ lưng trên",
}


def movement_type(external_id: str) -> str:
    value = external_id.lower()
    if "neck" in value:
        return "neck"
    if any(token in value for token in ("clean", "high_pull")):
        return "clean"
    if any(token in value for token in ("wrist", "finger", "pronation", "supination")):
        return "forearm"
    if any(token in value for token in ("calf", "rocking_standing")):
        return "calf"
    if any(token in value for token in ("abductor", "monster_walk")):
        return "abductor"
    if "adductor" in value or "adductions" in value:
        return "adductor"
    if any(token in value for token in ("deadlift", "good_morning", "pull_through", "hyperextension")):
        return "hinge"
    if any(token in value for token in ("bridge", "kickback", "hip_extension", "leg_lift", "flutter")):
        return "glute"
    if any(token in value for token in ("squat", "lunge", "step_up")):
        return "squat"
    if any(token in value for token in ("shrug",)):
        return "shrug"
    if any(token in value for token in ("pulldown", "chin-up", "row")):
        return "pull"
    if any(token in value for token in ("tricep", "skull", "body-up", "body_up", "bench_dips")):
        return "triceps"
    if "curl" in value:
        return "biceps"
    if any(token in value for token in ("rollout", "sit-up", "crunch", "heel", "side_bend", "windmill")):
        return "core"
    if any(token in value for token in ("shoulder", "deltoid", "pull_apart", "back_fly")):
        return "shoulder"
    if any(token in value for token in ("press", "butterfly", "around_the_world", "pullover")):
        return "press"
    return "controlled"


def review_content(record: dict[str, Any]) -> dict[str, Any]:
    external_id = record["sourceExternalId"]
    name_vi = VIETNAMESE_NAMES[external_id]
    primary = next(item["code"] for item in record["muscleGroups"] if item["role"] == "PRIMARY")
    target = MUSCLE_NAMES[primary]
    movement = movement_type(external_id)
    templates = {
        "core": (
            ["Vào tư thế bắt đầu chắc chắn và siết nhẹ vùng bụng.", "Thực hiện chuyển động bằng cơ core với biên độ có kiểm soát, không giật người.", "Trở về vị trí đầu chậm rãi và tiếp tục hít thở đều."],
            ["Dùng quán tính thay cho cơ bụng", "Cong hoặc võng lưng quá mức"],
            ["Giảm biên độ hoặc dừng bài nếu đau cổ hay lưng dưới."],
        ),
        "biceps": (
            ["Giữ thân người ổn định, khuỷu tay gần thân và cổ tay trung tính.", "Cuốn tải trọng lên bằng cách gập khuỷu tay, không đưa vai ra trước.", "Hạ tải trọng chậm đến khi tay gần duỗi hoàn toàn."],
            ["Đung đưa thân người để lấy đà", "Để khuỷu tay trôi quá xa về trước"],
            ["Chọn tải trọng cho phép kiểm soát cổ tay và khuỷu tay trong toàn bộ biên độ."],
        ),
        "triceps": (
            ["Ổn định vai và giữ khuỷu tay ở vị trí phù hợp với biến thể.", "Duỗi khuỷu tay bằng cơ tay sau mà không dùng đà của thân người.", "Trở về vị trí đầu chậm rãi, duy trì lực căng."],
            ["Di chuyển khuỷu tay quá nhiều", "Khóa khớp khuỷu tay quá mạnh"],
            ["Giảm tải hoặc biên độ nếu khuỷu tay hay vai khó chịu."],
        ),
        "press": (
            ["Thiết lập tư thế chắc chắn, thu bả vai và giữ cổ tay thẳng.", "Đẩy tải trọng theo quỹ đạo ổn định trong phạm vi vai thoải mái.", "Hạ tải trọng chậm và không để mất kiểm soát ở cuối biên độ."],
            ["Xòe khuỷu tay quá mức", "Dùng đà hoặc làm mất ổn định bả vai"],
            ["Dùng người hỗ trợ hoặc chốt an toàn khi tập nặng; dừng nếu đau vai hoặc ngực."],
        ),
        "shoulder": (
            ["Giữ thân người chắc, vai hạ tự nhiên và cổ tay trung tính.", "Di chuyển tải trọng bằng cơ vai với biên độ kiểm soát.", "Hạ tải trọng chậm, tránh nhún người lấy đà."],
            ["Nhún vai về phía tai", "Ưỡn lưng hoặc đung đưa thân người"],
            ["Không cố nâng quá tầm vai nếu xuất hiện đau hoặc chèn ép khớp vai."],
        ),
        "pull": (
            ["Giữ thân người ổn định và bắt đầu bằng cách hạ bả vai.", "Kéo khuỷu tay theo hướng của bài tập, tập trung siết cơ lưng.", "Trả tải trọng chậm đến khi cơ lưng được kéo giãn có kiểm soát."],
            ["Giật tải trọng bằng lưng dưới", "Nhún vai và kéo chủ yếu bằng tay trước"],
            ["Giữ cột sống trung tính và không kéo ra sau cổ."],
        ),
        "squat": (
            ["Đặt bàn chân vững, siết thân người và giữ đầu gối theo hướng mũi chân.", "Hạ hông với biên độ kiểm soát trong khi duy trì bàn chân tiếp xúc mặt sàn.", "Đẩy đều qua bàn chân để trở về tư thế đứng."],
            ["Đầu gối đổ vào trong", "Nhấc gót chân hoặc mất vị trí lưng trung tính"],
            ["Chỉ xuống sâu trong phạm vi không đau; dùng giá và chốt an toàn với thanh đòn."],
        ),
        "hinge": (
            ["Đứng chắc, siết core và giữ cột sống trung tính.", "Đẩy hông ra sau, giữ tải trọng gần cơ thể và đầu gối hơi chùng.", "Siết mông để đưa hông về trước, không ngửa lưng ở cuối động tác."],
            ["Cong lưng để tăng biên độ", "Để tải trọng rời xa cơ thể"],
            ["Dừng pha hạ khi không còn giữ được lưng trung tính; bắt đầu với tải nhẹ."],
        ),
        "clean": (
            ["Thiết lập tư thế gập hông chắc chắn với tải trọng gần cơ thể.", "Duỗi hông dứt khoát để tạo lực, sau đó đưa tay vào vị trí đỡ tải.", "Ổn định tải trước khi hạ xuống và lặp lại."],
            ["Kéo tải chủ yếu bằng cánh tay", "Để tải va mạnh vào cổ tay hoặc cẳng tay"],
            ["Đây là động tác kỹ thuật; học với tải nhẹ và khoảng trống an toàn trước khi tăng tạ."],
        ),
        "calf": (
            ["Đặt phần trước bàn chân chắc trên bề mặt và giữ thân người ổn định.", "Nâng gót lên bằng cơ bắp chân, giữ ngắn ở vị trí cao nhất.", "Hạ gót chậm trong phạm vi mắt cá chân thoải mái."],
            ["Nảy nhanh ở đáy động tác", "Để cổ chân đổ vào trong hoặc ra ngoài"],
            ["Giữ điểm tựa chắc chắn và không để tải trượt khỏi đùi hoặc bàn chân."],
        ),
        "shrug": (
            ["Đứng hoặc ngồi chắc, giữ tải trọng cân bằng hai bên.", "Nâng vai thẳng lên bằng cơ cầu vai mà không xoay tròn vai.", "Hạ vai chậm về vị trí tự nhiên."],
            ["Xoay tròn khớp vai", "Rướn cổ hoặc dùng đà toàn thân"],
            ["Giữ cổ trung tính và chọn mức tạ không làm mất kiểm soát vai."],
        ),
        "forearm": (
            ["Cố định cẳng tay trên bề mặt chắc chắn và giữ tải trọng nhẹ.", "Di chuyển cổ tay hoặc cẳng tay đúng hướng của biến thể với biên độ chậm.", "Trở về vị trí trung tính có kiểm soát."],
            ["Dùng tải quá nặng", "Bẻ cổ tay vượt phạm vi thoải mái"],
            ["Dừng ngay nếu đau nhói ở cổ tay hoặc khuỷu tay."],
        ),
        "glute": (
            ["Ổn định thân người và siết core trước khi di chuyển chân hoặc hông.", "Duỗi hông bằng cơ mông mà không xoay chậu hoặc ưỡn lưng.", "Trở về vị trí đầu chậm rãi, duy trì kiểm soát."],
            ["Ưỡn lưng dưới thay cho duỗi hông", "Xoay hông để tăng biên độ"],
            ["Giảm biên độ nếu lưng dưới chịu lực hoặc khớp hông khó chịu."],
        ),
        "abductor": (
            ["Giữ thân người và khung chậu ổn định.", "Đưa chân ra ngoài bằng cơ hông với lực căng liên tục.", "Trở về chậm, không để máy hoặc dây kéo chân đột ngột."],
            ["Xoay thân để lấy đà", "Dùng biên độ quá lớn làm mất vị trí khung chậu"],
            ["Chọn mức kháng lực không gây đau mặt ngoài hông hoặc đầu gối."],
        ),
        "adductor": (
            ["Giữ thân người và khung chậu ổn định.", "Khép chân bằng cơ đùi trong với chuyển động chậm.", "Mở chân trở lại trong phạm vi thoải mái, không thả tải đột ngột."],
            ["Giật chân để thắng lực cản", "Mở chân quá rộng khi cơ chưa sẵn sàng"],
            ["Giảm biên độ nếu căng đau vùng háng hoặc mặt trong đùi."],
        ),
        "neck": (
            ["Ngồi hoặc đứng thẳng, giữ cổ ở vị trí trung tính.", "Đặt lực cản rất nhẹ bằng bàn tay và giữ đầu không di chuyển.", "Thả lực từ từ, nghỉ rồi lặp lại ở hướng đối diện."],
            ["Ấn đầu quá mạnh", "Nín thở hoặc xoay cổ trong lúc giữ lực"],
            ["Chỉ dùng lực nhẹ; không thực hiện khi chóng mặt, đau cổ hoặc có tiền sử chấn thương cổ chưa được đánh giá."],
        ),
        "controlled": (
            ["Thiết lập tư thế chắc chắn và chọn tải trọng phù hợp.", "Thực hiện chuyển động chậm trong phạm vi kiểm soát.", "Trở về vị trí đầu mà không thả tải đột ngột."],
            ["Dùng quán tính để hoàn thành động tác", "Mất tư thế khi mệt"],
            ["Dừng bài nếu xuất hiện đau nhói hoặc mất kiểm soát tải trọng."],
        ),
    }
    instructions, mistakes, safety = templates[movement]
    if external_id == "Barbell_Guillotine_Bench_Press":
        safety = ["Biến thể này tăng tải lên vai và không phù hợp với người mới; ưu tiên bench press tiêu chuẩn hoặc tập dưới giám sát chuyên môn."]
    elif external_id == "Barbell_Shrug_Behind_The_Back":
        safety = ["Không ép vai ra sau quá mức; đổi sang barbell shrug phía trước nếu vai khó chịu."]
    elif external_id == "Stiff_Leg_Barbell_Good_Morning":
        safety = ["Đây là biến thể đòi hỏi kiểm soát gập hông tốt; dùng tải rất nhẹ và dừng khi lưng không còn trung tính."]
    elif movement == "neck":
        safety = templates["neck"][2]
    return {
        "nameVi": name_vi,
        "descriptionVi": f"{name_vi} là bài tập tập trung vào {target}, thực hiện với kỹ thuật và biên độ có kiểm soát.",
        "instructionStepsVi": instructions,
        "commonMistakesVi": mistakes,
        "safetyNotesVi": safety,
    }


def main() -> int:
    export_path = DATASETS_ROOT / "exports" / "viegym_exercises_v1.json"
    reviews_path = DATASETS_ROOT / "exercise" / "review" / "golden_reviews.json"
    export = load_json(export_path)
    reviews = load_json(reviews_path)
    hidden = [record for record in export["records"] if record["visibility"] == "HIDDEN"]
    hidden_ids = {record["sourceExternalId"] for record in hidden}
    missing_names = sorted(hidden_ids - VIETNAMESE_NAMES.keys())
    stale_names = sorted(VIETNAMESE_NAMES.keys() - hidden_ids)
    if missing_names or stale_names:
        raise ValueError(f"Review-name coverage mismatch; missing={missing_names}, stale={stale_names}")
    for record in hidden:
        reviews[record["sourceExternalId"]] = review_content(record)
    write_json(reviews_path, reviews)
    print(f"Reviewed {len(hidden)} remaining Exercise records -> {reviews_path}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as error:
        print(f"review generation failed: {error}", file=sys.stderr)
        raise SystemExit(1)
