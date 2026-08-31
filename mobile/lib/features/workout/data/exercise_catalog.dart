import '../domain/workout_models.dart';

const exerciseCatalog = <ExerciseDefinition>[
  ExerciseDefinition(
    id: 'ex1',
    name: 'Barbell Bench Press',
    nameVi: 'Đẩy ngực ngang với tạ đòn',
    primaryMuscle: 'Ngực',
    primaryMuscleKey: 'chest',
    secondaryMuscles: ['Tay sau', 'Vai'],
    equipment: EquipmentType.barbell,
    description:
        'Bài compound kinh điển phát triển toàn diện cơ ngực, vai trước và tay sau.',
    instructions: [
      'Nằm trên ghế phẳng, hai chân đặt chắc chắn trên sàn.',
      'Nắm thanh đòn rộng hơn vai một chút, nhấc ra khỏi giá đỡ an toàn.',
      'Hạ thanh đòn xuống giữa ngực một cách có kiểm soát trong 2-3 giây.',
      'Đẩy mạnh thanh đòn trở lại vị trí ban đầu và siết cơ ngực.',
    ],
    commonMistakes: [
      ExerciseMistake(
        mistake: 'Banh cùi chỏ vuông góc 90 độ so với thân người khi hạ tạ.',
        fix: 'Khép khuỷu tay góc 45–60 độ so với thân để bảo vệ bao khớp vai.',
        injuryRisk: 'Gây chèn ép gân cơ chóp xoay (Rotator Cuff).',
      ),
      ExerciseMistake(
        mistake: 'Nhấc mông và cong thắt lưng quá mức khỏi mặt ghế khi đẩy.',
        fix:
            'Giữ mông luôn tiếp xúc với mặt ghế, tạo độ cong sinh lý tự nhiên.',
        injuryRisk: 'Dồn áp lực nguy hiểm lên các đốt sống thắt lưng L4-L5.',
      ),
    ],
  ),
  ExerciseDefinition(
    id: 'ex_neutral_db_press',
    name: 'Neutral-Grip Dumbbell Press',
    nameVi: 'Đẩy ngực tạ đơn tay cầm trung tính',
    primaryMuscle: 'Ngực',
    primaryMuscleKey: 'chest',
    secondaryMuscles: ['Vai', 'Tay sau'],
    equipment: EquipmentType.dumbbell,
    description:
        'Biến thể đẩy ngực với lòng bàn tay hướng vào nhau giúp bảo vệ cổ tay tối đa.',
    instructions: [
      'Nằm trên ghế phẳng, cầm 2 quả tạ đơn với lòng bàn tay hướng vào nhau.',
      'Hạ tạ chậm rãi ngang ngực, khuỷu tay khép sát thân người 30-45 độ.',
      'Đẩy tạ lên cao dứt khoát và siết cơ ngực ở đỉnh chuyển động.',
    ],
    commonMistakes: [
      ExerciseMistake(
        mistake: 'Xoay cổ tay ra ngoài khi đẩy lên cao.',
        fix:
            'Giữ cố định vị trí lòng bàn tay hướng vào nhau trong suốt chuyển động.',
        injuryRisk: 'Làm mất tác dụng giảm tải lực bẻ xoắn lên khớp cổ tay.',
      ),
    ],
  ),
  ExerciseDefinition(
    id: 'ex_chest_press_machine',
    name: 'Chest Press Machine',
    nameVi: 'Đẩy ngực trên máy cố định',
    primaryMuscle: 'Ngực',
    primaryMuscleKey: 'chest',
    secondaryMuscles: ['Vai', 'Tay sau'],
    equipment: EquipmentType.machine,
    description:
        'Quỹ đạo máy cố định giúp giảm yêu cầu giữ thăng bằng và cô lập ngực an toàn.',
    instructions: [
      'Điều chỉnh chiều cao ghế sao cho tay cầm ngang ngực giữa.',
      'Lưng áp sát vào đệm, bàn chân đặt vững chắc trên sàn.',
      'Đẩy tay cầm về phía trước có kiểm soát theo quỹ đạo máy.',
      'Hạ tạ chậm về vị trí ban đầu mà không để bánh tạ va chạm mạnh.',
    ],
    commonMistakes: [
      ExerciseMistake(
        mistake: 'Nhô vai về phía trước khi đẩy tạ hết biên độ.',
        fix: 'Giữ xương bả vai luôn ép chặt vào đệm ghế trong suốt bài tập.',
        injuryRisk: 'Chèn ép khớp vai trước và giảm áp lực lên cơ ngực.',
      ),
    ],
  ),
  ExerciseDefinition(
    id: 'ex_pec_deck_fly',
    name: 'Pec Deck Machine Fly',
    nameVi: 'Ép ngực máy Pec Deck',
    primaryMuscle: 'Ngực',
    primaryMuscleKey: 'chest',
    secondaryMuscles: ['Vai'],
    equipment: EquipmentType.machine,
    description: 'Bài cô lập cơ ngực giúp kéo giãn và ép cơ tối đa.',
    instructions: [
      'Ngồi thẳng lưng, đặt cẳng tay hoặc lòng bàn tay vào đệm ép.',
      'Dùng cơ ngực ép hai cánh tay lại gần nhau ở phía trước.',
      'Giữ 1 giây ở đỉnh để siết cơ, sau đó mở rộng tay trở lại từ từ.',
    ],
    commonMistakes: [
      ExerciseMistake(
        mistake: 'Mở tay quá sâu ra sau làm căng khớp vai quá mức.',
        fix: 'Dừng lại khi khuỷu tay ngang bằng với mặt phẳng thân người.',
        injuryRisk: 'Căng rách bao khớp vai trước.',
      ),
    ],
  ),
  ExerciseDefinition(
    id: 'ex2',
    name: 'Incline Dumbbell Press',
    nameVi: 'Đẩy ngực trên với tạ đơn',
    primaryMuscle: 'Ngực',
    primaryMuscleKey: 'chest',
    secondaryMuscles: ['Vai', 'Tay sau'],
    equipment: EquipmentType.dumbbell,
    description:
        'Tập trung phát triển phần ngực trên (Clavicular head) và tăng độ dày thân trên.',
    instructions: [
      'Chỉnh ghế dốc góc 30-45 độ.',
      'Nâng tạ lên vị trí chuẩn bị ngang ngực trên.',
      'Đẩy tạ lên theo hình vòng cung nhẹ, không chạm tạ vào nhau ở đỉnh.',
      'Hạ tạ chậm rãi cảm nhận cơ ngực trên căng giãn.',
    ],
    commonMistakes: [
      ExerciseMistake(
        mistake: 'Đặt ghế quá dốc (> 60 độ).',
        fix:
            'Chỉ nên để góc dốc 30-45 độ để lực tác động vào ngực trên thay vì vai trước.',
        injuryRisk: 'Làm vai gánh toàn bộ tải trọng.',
      ),
    ],
  ),
  ExerciseDefinition(
    id: 'ex3',
    name: 'Overhead Press (OHP)',
    nameVi: 'Đẩy vai qua đầu với tạ đòn',
    primaryMuscle: 'Vai',
    primaryMuscleKey: 'shoulders',
    secondaryMuscles: ['Tay sau', 'Cơ trọng tâm'],
    equipment: EquipmentType.barbell,
    description:
        'Bài đẩy chính phát triển sức mạnh vai toàn diện và ổn định cơ thân trên.',
    instructions: [
      'Đứng thẳng, chân rộng bằng vai, gồng chặt mông và cơ bụng.',
      'Nắm thanh tạ ngay phía trên xương đòn.',
      'Đẩy thẳng thanh tạ lên trên đầu, khóa khớp kiểm soát ở đỉnh.',
      'Hạ tạ xuống có kiểm soát về vị trí xương đòn.',
    ],
    commonMistakes: [
      ExerciseMistake(
        mistake: 'Ưỡn lưng dưới ra sau quá mức khi đẩy tạ nặng.',
        fix: 'Gồng chặt cơ mông và cơ bụng để cố định cột sống thẳng.',
        injuryRisk: 'Tổn thương cột sống thắt lưng.',
      ),
    ],
  ),
  ExerciseDefinition(
    id: 'ex4',
    name: 'Tricep Rope Pushdown',
    nameVi: 'Kéo cáp dây thừng tay sau',
    primaryMuscle: 'Tay sau',
    primaryMuscleKey: 'triceps',
    secondaryMuscles: [],
    equipment: EquipmentType.cable,
    description:
        'Bài cô lập tay sau với lực căng liên tục và khóa khớp an toàn.',
    instructions: [
      'Gắn dây thừng vào đầu cáp cao.',
      'Khuỷu tay khép sát thân người, kéo cáp xuống dưới.',
      'Tách 2 đầu dây thừng sang 2 bên ở cuối chuyển động và siết chặt tay sau.',
      'Đưa tay lên vị trí 90 độ một cách có kiểm soát.',
    ],
    commonMistakes: [
      ExerciseMistake(
        mistake: 'Đung đưa khuỷu tay ra trước sau để lấy đà.',
        fix: 'Cố định vị trí khuỷu tay sát sườn trong suốt bài tập.',
        injuryRisk: 'Giảm tải lên cơ tay sau và làm mỏi khớp vai.',
      ),
    ],
  ),
  ExerciseDefinition(
    id: 'ex5',
    name: 'Lat Pulldown',
    nameVi: 'Kéo xô máy với thanh đòn rộng',
    primaryMuscle: 'Lưng xô',
    primaryMuscleKey: 'lats',
    secondaryMuscles: ['Tay trước', 'Vai sau'],
    equipment: EquipmentType.cable,
    description: 'Bài tập chính xây dựng độ rộng cho cơ xô và cơ lưng trên.',
    instructions: [
      'Ngồi vào máy kéo xô, khóa đùi chắc chắn dưới đệm giữ.',
      'Nắm thanh đòn rộng hơn vai, hơi ngả người ra sau 10-15 độ.',
      'Kéo thanh đòn xuống sát ngực trên bằng cách ghì xương bả vai xuống.',
      'Thả tạ lên từ từ để cơ xô được kéo giãn tối đa.',
    ],
    commonMistakes: [
      ExerciseMistake(
        mistake: 'Ngả người ra sau quá nhiều và giật người lấy đà.',
        fix: 'Giữ thân người cố định, tập trung kéo bằng cùi chỏ và cơ xô.',
        injuryRisk: 'Đau thắt lưng và mất áp lực lên cơ lưng.',
      ),
    ],
  ),
  ExerciseDefinition(
    id: 'ex6',
    name: 'Barbell Squat',
    nameVi: 'Gánh tạ đòn ngồi xổm',
    primaryMuscle: 'Đùi trước',
    primaryMuscleKey: 'quads',
    secondaryMuscles: ['Mông', 'Đùi sau', 'Lưng dưới'],
    equipment: EquipmentType.barbell,
    description:
        'Vua của các bài tập thân dưới, xây dựng cơ đùi và sức mạnh bộc phát.',
    instructions: [
      'Đặt thanh tạ trên cơ cầu vai (High bar) hoặc gai xương bả vai (Low bar).',
      'Đứng chân rộng bằng vai hoặc hơn một chút, mũi chân mở 15-30 độ.',
      'Hít sâu gồng chặt bụng, hạ hông xuống thấp cho đến khi đùi song song sàn.',
      'Đạp mạnh cả bàn chân xuống sàn để đứng thẳng dậy.',
    ],
    commonMistakes: [
      ExerciseMistake(
        mistake: 'Đầu gối chụm vào trong (Knee valgus) khi đứng dậy.',
        fix: 'Chủ động mở đầu gối theo hướng mũi chân trong suốt chuyển động.',
        injuryRisk:
            'Tổn thương dây chằng chéo trước (ACL) và sụn chêm đầu gối.',
      ),
    ],
  ),
];

ExerciseDefinition? findExercise(String id) {
  for (final exercise in exerciseCatalog) {
    if (exercise.id == id) return exercise;
  }
  return null;
}

List<ExerciseDefinition> replacementCandidates({
  required String originalExerciseId,
  required Set<EquipmentType> availableEquipment,
}) {
  final original = findExercise(originalExerciseId);
  if (original == null) return const [];

  final preferredIds = originalExerciseId == 'ex1'
      ? const [
          'ex_neutral_db_press',
          'ex_chest_press_machine',
          'ex_pec_deck_fly',
        ]
      : exerciseCatalog
            .where(
              (item) =>
                  item.id != originalExerciseId &&
                  item.primaryMuscle == original.primaryMuscle,
            )
            .map((item) => item.id)
            .toList();

  return preferredIds
      .map(findExercise)
      .whereType<ExerciseDefinition>()
      .where((item) => availableEquipment.contains(item.equipment))
      .take(3)
      .toList();
}
