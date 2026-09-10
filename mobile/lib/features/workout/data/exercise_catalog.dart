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
    thumbnailUrl:
        'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=400&auto=format&fit=crop&q=80',
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
    thumbnailUrl:
        'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=400&auto=format&fit=crop&q=80',
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
    thumbnailUrl:
        'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400&auto=format&fit=crop&q=80',
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
    thumbnailUrl:
        'https://images.unsplash.com/photo-1584735935682-2f2b69dff9d2?w=400&auto=format&fit=crop&q=80',
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
    thumbnailUrl:
        'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=400&auto=format&fit=crop&q=80',
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
    thumbnailUrl:
        'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?w=400&auto=format&fit=crop&q=80',
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
    thumbnailUrl:
        'https://images.unsplash.com/photo-1530822847156-5df684ec5ee1?w=400&auto=format&fit=crop&q=80',
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
    thumbnailUrl:
        'https://images.unsplash.com/photo-1605296867304-46d5465a13f1?w=400&auto=format&fit=crop&q=80',
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
    thumbnailUrl:
        'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=400&auto=format&fit=crop&q=80',
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
  ExerciseDefinition(
    id: 'ex_pushup',
    name: 'Push-Up',
    nameVi: 'Hít đất truyền thống',
    primaryMuscle: 'Ngực',
    primaryMuscleKey: 'chest',
    secondaryMuscles: ['Vai', 'Tay sau', 'Cơ bụng (Core)'],
    equipment: EquipmentType.bodyweight,
    thumbnailUrl:
        'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&auto=format&fit=crop&q=80',
    description: 'Bài tập thể trọng kinh điển tăng cường sức mạnh và khối lượng cơ ngực.',
    instructions: [
      'Đặt hai tay rộng hơn vai, thân người tạo thành một đường thẳng.',
      'Hạ ngực xuống sát sàn, khuỷu tay chếch 45 độ.',
      'Đẩy mạnh tay trở lại vị trí ban đầu và gồng cơ bụng.',
    ],
  ),
  ExerciseDefinition(
    id: 'ex_pullup',
    name: 'Pull-Up',
    nameVi: 'Hít xà đơn',
    primaryMuscle: 'Lưng xô',
    primaryMuscleKey: 'lats',
    secondaryMuscles: ['Tay trước', 'Cơ bụng (Core)'],
    equipment: EquipmentType.bodyweight,
    thumbnailUrl:
        'https://images.unsplash.com/photo-1599058945522-28d584b6f0ff?w=400&auto=format&fit=crop&q=80',
    description: 'Vua của các bài tập lưng xô thể trọng giúp mở rộng khung lưng V-Taper.',
    instructions: [
      'Nắm xà đơn rộng hơn vai, lòng bàn tay hướng ra phía trước.',
      'Kéo người lên cho đến khi cằm vượt qua thanh xà.',
      'Hạ người xuống có kiểm soát hết biên độ.',
    ],
  ),
  ExerciseDefinition(
    id: 'ex_db_row',
    name: 'Single-Arm Dumbbell Row',
    nameVi: 'Chèo tạ đơn 1 tay',
    primaryMuscle: 'Lưng xô',
    primaryMuscleKey: 'lats',
    secondaryMuscles: ['Tay trước', 'Vai sau'],
    equipment: EquipmentType.dumbbell,
    thumbnailUrl:
        'https://images.unsplash.com/photo-1586401100295-7a833e3f3e82?w=400&auto=format&fit=crop&q=80',
    description: 'Phát triển độ dày cơ lưng và cân bằng sức mạnh hai bên thân người.',
    instructions: [
      'Một tay và một đầu gối chống lên ghế tập phẳng, giữ lưng thẳng.',
      'Tay còn lại cầm tạ đơn buông thẳng xuống.',
      'Kéo tạ lên về phía hông, siết chặt cơ lưng xô ở đỉnh.',
    ],
  ),
  ExerciseDefinition(
    id: 'ex_db_shoulder_press',
    name: 'Dumbbell Shoulder Press',
    nameVi: 'Đẩy vai với tạ đơn',
    primaryMuscle: 'Vai',
    primaryMuscleKey: 'shoulders',
    secondaryMuscles: ['Tay sau'],
    equipment: EquipmentType.dumbbell,
    thumbnailUrl:
        'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=400&auto=format&fit=crop&q=80',
    description: 'Xây dựng cơ vai tròn đầy 3D với biên độ tự do thoải mái.',
    instructions: [
      'Ngồi trên ghế dốc đứng 90 độ, cầm 2 quả tạ đơn ngang vai.',
      'Đẩy tạ lên qua đầu theo đường vòng cung nhẹ.',
      'Hạ tạ chậm về vị trí ngang tai.',
    ],
  ),
  ExerciseDefinition(
    id: 'ex_db_lateral_raise',
    name: 'Dumbbell Lateral Raise',
    nameVi: 'Dang tạ đơn sang hai bên',
    primaryMuscle: 'Vai',
    primaryMuscleKey: 'shoulders',
    secondaryMuscles: [],
    equipment: EquipmentType.dumbbell,
    thumbnailUrl:
        'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?w=400&auto=format&fit=crop&q=80',
    description: 'Cô lập hoàn hảo cơ vai giữa (Lateral Deltoid) giúp vai rộng.',
    instructions: [
      'Đứng thẳng, hai tay cầm tạ đơn nhẹ đặt bên đùi.',
      'Nâng hai tay sang ngang cho đến khi cánh tay song song mặt đất.',
      'Hạ tạ xuống từ từ có kiểm soát trong 2 giây.',
    ],
  ),
  ExerciseDefinition(
    id: 'ex_db_curl',
    name: 'Dumbbell Bicep Curl',
    nameVi: 'Cuốn tạ đơn tay trước',
    primaryMuscle: 'Tay trước',
    primaryMuscleKey: 'biceps',
    secondaryMuscles: ['Cẳng tay'],
    equipment: EquipmentType.dumbbell,
    thumbnailUrl:
        'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=400&auto=format&fit=crop&q=80',
    description: 'Bài tập cơ bản phát triển đỉnh bắp tay trước căng tròn.',
    instructions: [
      'Đứng thẳng, hai tay cầm tạ đơn, khuỷu tay ép sát hông.',
      'Cuốn tạ lên và xoay cổ tay ngửa ra ngoài ở đỉnh chuyển động.',
      'Hạ tạ chậm rãi để cảm nhận cơ bắp kéo giãn.',
    ],
  ),
  ExerciseDefinition(
    id: 'ex_barbell_curl',
    name: 'Barbell Bicep Curl',
    nameVi: 'Cuốn tạ đòn tay trước',
    primaryMuscle: 'Tay trước',
    primaryMuscleKey: 'biceps',
    secondaryMuscles: ['Cẳng tay'],
    equipment: EquipmentType.barbell,
    thumbnailUrl:
        'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=400&auto=format&fit=crop&q=80',
    description: 'Xây dựng kích thước và sức mạnh tổng thể cho nhóm cơ bắp tay trước.',
    instructions: [
      'Nắm thanh tạ đòn rộng bằng vai, lòng bàn tay hướng lên.',
      'Giữ cùi chỏ cố định, cuốn tạ lên sát ngực.',
      'Siết chặt bắp tay 1 giây rồi hạ từ từ xuống.',
    ],
  ),
  ExerciseDefinition(
    id: 'ex_dips',
    name: 'Parallel Bar Dips',
    nameVi: 'Chống xà kép tập tay sau & ngực',
    primaryMuscle: 'Tay sau',
    primaryMuscleKey: 'triceps',
    secondaryMuscles: ['Ngực', 'Vai'],
    equipment: EquipmentType.bodyweight,
    thumbnailUrl:
        'https://images.unsplash.com/photo-1599058945522-28d584b6f0ff?w=400&auto=format&fit=crop&q=80',
    description: 'Bài tập thể trọng tải nặng tăng sức mạnh bộc phát cho tay sau và ngực dưới.',
    instructions: [
      'Nâng người lên trên thanh xà kép, khóa tay có kiểm soát.',
      'Hạ người xuống cho đến khi khuỷu tay vuông góc 90 độ.',
      'Đẩy người thẳng dậy và siết chặt cơ tay sau.',
    ],
  ),
  ExerciseDefinition(
    id: 'ex_leg_extension',
    name: 'Leg Extension Machine',
    nameVi: 'Đá đùi trước trên máy',
    primaryMuscle: 'Đùi trước',
    primaryMuscleKey: 'quads',
    secondaryMuscles: [],
    equipment: EquipmentType.machine,
    thumbnailUrl:
        'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400&auto=format&fit=crop&q=80',
    description: 'Cô lập tuyệt đối cơ đùi trước tạo nét cắt cơ bắp rõ rệt.',
    instructions: [
      'Ngồi vào máy, đặt cổ chân dưới đệm mút.',
      'Đá chân thẳng lên và siết chặt cơ đùi trước trong 1 giây.',
      'Hạ tạ xuống có kiểm soát.',
    ],
  ),
  ExerciseDefinition(
    id: 'ex_rdl',
    name: 'Romanian Deadlift (RDL)',
    nameVi: 'Deadlift kiểu Romania',
    primaryMuscle: 'Đùi sau & Mông',
    primaryMuscleKey: 'hamstrings',
    secondaryMuscles: ['Lưng dưới', 'Mông'],
    equipment: EquipmentType.barbell,
    thumbnailUrl:
        'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=400&auto=format&fit=crop&q=80',
    description: 'Tối ưu độ căng cơ đùi sau và cơ mông với chuyển động bản lề hông (Hip Hinge).',
    instructions: [
      'Đứng thẳng cầm tạ đòn trước đùi, đầu gối hơi chùng nhẹ cố định.',
      'Đẩy hông ra sau và hạ tạ dọc theo ống chân cho tới khi cảm nhận cơ đùi sau căng.',
      'Siết mông và đẩy hông về phía trước để đứng thẳng dậy.',
    ],
  ),
  ExerciseDefinition(
    id: 'ex_hip_thrust',
    name: 'Barbell Hip Thrust',
    nameVi: 'Đẩy hông với tạ đòn',
    primaryMuscle: 'Đùi sau & Mông',
    primaryMuscleKey: 'glutes',
    secondaryMuscles: ['Đùi sau'],
    equipment: EquipmentType.bench,
    thumbnailUrl:
        'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=400&auto=format&fit=crop&q=80',
    description: 'Bài tập số 1 giúp phát triển kích thước và sức mạnh cơ mông tối đa.',
    instructions: [
      'Tựa lưng trên vào ghế tập phẳng, thanh tạ đặt ngang hông.',
      'Đạp mạnh gót chân đẩy hông lên sao cho đùi và thân người thẳng hàng.',
      'Siết chặt mông 2 giây ở đỉnh trước khi hạ chậm xuống.',
    ],
  ),
  ExerciseDefinition(
    id: 'ex_plank',
    name: 'Core Plank',
    nameVi: 'Plank gồng cơ bụng',
    primaryMuscle: 'Cơ bụng (Core)',
    primaryMuscleKey: 'abs',
    secondaryMuscles: ['Vai', 'Mông'],
    equipment: EquipmentType.bodyweight,
    thumbnailUrl:
        'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&auto=format&fit=crop&q=80',
    description: 'Tăng cường sức bền và độ ổn định cơ lõi, bảo vệ cột sống thắt lưng.',
    instructions: [
      'Chống cùi chỏ trên thảm, thân người tạo thành một đường thẳng tắp.',
      'Gồng chặt bụng, siết mông và giữ nhịp thở đều đặn.',
    ],
  ),
  ExerciseDefinition(
    id: 'ex_cable_crunch',
    name: 'Cable Kneeling Crunch',
    nameVi: 'Gập bụng quỳ với dây cáp',
    primaryMuscle: 'Cơ bụng (Core)',
    primaryMuscleKey: 'abs',
    secondaryMuscles: [],
    equipment: EquipmentType.cable,
    thumbnailUrl:
        'https://images.unsplash.com/photo-1530822847156-5df684ec5ee1?w=400&auto=format&fit=crop&q=80',
    description: 'Tăng độ dày các múi cơ bụng với lực tải kháng liên tục từ dây cáp.',
    instructions: [
      'Quỳ gối trước máy cáp cao, nắm chặt hai đầu dây thừng áp sát trán.',
      'Gập người cuộn tròn cơ bụng, kéo cùi chỏ về phía đùi.',
      'Thả người lên từ từ để cơ bụng được kéo giãn hoàn toàn.',
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
