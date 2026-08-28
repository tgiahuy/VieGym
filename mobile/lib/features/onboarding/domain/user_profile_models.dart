enum BiologicalGender {
  male('Nam', 'Thể hình & Thể lực'),
  female('Nữ', 'Săn chắc & Vóc dáng'),
  other('Khác (Non-binary)', 'Tính toán theo chuẩn trung tính'),
  preferNotToSay('Không muốn tiết lộ', 'Bảo mật tuyệt đối, dùng mức trung bình chuẩn');

  const BiologicalGender(this.label, this.description);
  final String label;
  final String description;
}

enum FitnessGoal {
  gainMuscle(
    'Tăng cơ nạc (Hypertrophy)',
    'Phát triển kích thước cơ bắp, tăng kích thước sợi cơ',
    'Phổ biến',
  ),
  loseFat(
    'Giảm mỡ & Siết cơ (Cutting)',
    'Đốt mỡ thừa, hiện rõ nét cơ với mức thâm hụt calo an toàn',
    'Đốt mỡ',
  ),
  buildStrength(
    'Tăng sức mạnh (Strength)',
    'Tối đa hóa mức tạ các bài Compound (Squat, Bench, Deadlift)',
    'Power',
  ),
  maintain(
    'Duy trì & Sống khỏe (Maintain)',
    'Cải thiện sức bền tim mạch, độ linh hoạt và giữ vóc dáng',
    'Healthy',
  );

  const FitnessGoal(this.label, this.description, this.badge);
  final String label;
  final String description;
  final String badge;
}

enum ActivityLevel {
  sedentary(
    'Ít vận động (Sedentary)',
    'Ngồi nhiều, làm việc văn phòng, ít đi lại (< 3,000 bước)',
    1.2,
  ),
  light(
    'Vận động nhẹ (Light Active)',
    'Đi bộ hoặc đứng nhiều trong ngày (4,000 - 7,000 bước)',
    1.375,
  ),
  active(
    'Năng động (Active)',
    'Di chuyển linh hoạt liên tục, đi bộ > 8,000 bước/ngày',
    1.55,
  ),
  veryActive(
    'Rất năng động (Very Active)',
    'Lao động chân tay nặng hoặc tập luyện thể thao cường độ cao',
    1.725,
  );

  const ActivityLevel(this.label, this.description, this.multiplier);
  final String label;
  final String description;
  final double multiplier;
}

enum TrainingExperience {
  beginner(
    'Mới bắt đầu (Beginner)',
    'Cần học form chuẩn bài tập cơ bản, làm quen kỹ thuật an toàn',
    '< 6 tháng',
  ),
  intermediate(
    'Trung bình (Intermediate)',
    'Đã nắm vững form, muốn tăng tiến tạ (Progressive Overload) hiệu quả',
    '6 tháng - 2 năm',
  ),
  advanced(
    'Nâng cao (Advanced)',
    'Hiểu rõ RPE, kỹ thuật chuyên sâu (Drop sets, Rest-pause, RIR)',
    '> 2 năm',
  );

  const TrainingExperience(this.label, this.description, this.badge);
  final String label;
  final String description;
  final String badge;
}

class HealthProfile {
  const HealthProfile({
    this.nickname = '',
    this.gender = BiologicalGender.male,
    this.age = 25,
    this.heightCm = 170,
    this.weightKg = 65,
    this.targetWeightKg = 65,
    this.goal = FitnessGoal.gainMuscle,
    this.activityLevel = ActivityLevel.active,
    this.experience = TrainingExperience.intermediate,
  });

  final String nickname;
  final BiologicalGender gender;
  final int age;
  final int heightCm;
  final int weightKg;
  final int targetWeightKg;
  final FitnessGoal goal;
  final ActivityLevel activityLevel;
  final TrainingExperience experience;

  double get bmi => weightKg / ((heightCm / 100) * (heightCm / 100));

  String get bmiCategory {
    if (bmi < 18.5) return 'Nhẹ cân';
    if (bmi < 24.9) return 'Bình thường';
    if (bmi < 29.9) return 'Tiền béo phì';
    return 'Béo phì';
  }

  /// Target weight difference compared to current weight (e.g. -5 kg or +3 kg)
  int get weightDifference => targetWeightKg - weightKg;

  /// Mifflin-St Jeor equation for BMR
  int get bmr {
    final base = (10 * weightKg) + (6.25 * heightCm) - (5 * age);
    return switch (gender) {
      BiologicalGender.male => (base + 5).round(),
      BiologicalGender.female => (base - 161).round(),
      BiologicalGender.other || BiologicalGender.preferNotToSay => (base - 78).round(),
    };
  }

  /// Total Daily Energy Expenditure
  int get tdee {
    final baseTdee = (bmr * activityLevel.multiplier).round();
    return switch (goal) {
      FitnessGoal.gainMuscle => baseTdee + 300,
      FitnessGoal.loseFat => baseTdee - 400,
      FitnessGoal.buildStrength => baseTdee + 150,
      FitnessGoal.maintain => baseTdee,
    };
  }

  HealthProfile copyWith({
    String? nickname,
    BiologicalGender? gender,
    int? age,
    int? heightCm,
    int? weightKg,
    int? targetWeightKg,
    FitnessGoal? goal,
    ActivityLevel? activityLevel,
    TrainingExperience? experience,
  }) {
    return HealthProfile(
      nickname: nickname ?? this.nickname,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      goal: goal ?? this.goal,
      activityLevel: activityLevel ?? this.activityLevel,
      experience: experience ?? this.experience,
    );
  }
}
