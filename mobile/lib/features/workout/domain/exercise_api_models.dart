import 'workout_models.dart';

class ExerciseApiSummary {
  const ExerciseApiSummary({
    required this.id,
    required this.name,
    required this.searchName,
    required this.slug,
    required this.difficulty,
    this.description,
    this.thumbnailUrl,
    this.videoUrl,
    required this.muscleGroups,
    required this.equipment,
    this.isFavorite = false,
  });

  factory ExerciseApiSummary.fromJson(Map<String, dynamic> json) {
    final muscleGroupsList =
        (json['muscleGroups'] as List<dynamic>?)
            ?.map(
              (e) => ExerciseMuscleGroupApiItem.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList() ??
        [];
    final equipmentList =
        (json['equipment'] as List<dynamic>?)
            ?.map(
              (e) =>
                  ExerciseEquipmentApiItem.fromJson(e as Map<String, dynamic>),
            )
            .toList() ??
        [];

    return ExerciseApiSummary(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      searchName: json['searchName'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? 'BEGINNER',
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      muscleGroups: muscleGroupsList,
      equipment: equipmentList,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  final int id;
  final String name;
  final String searchName;
  final String slug;
  final String difficulty;
  final String? description;
  final String? thumbnailUrl;
  final String? videoUrl;
  final List<ExerciseMuscleGroupApiItem> muscleGroups;
  final List<ExerciseEquipmentApiItem> equipment;
  final bool isFavorite;

  ExerciseDefinition toExerciseDefinition() {
    final primary = muscleGroups.firstWhere(
      (m) => m.role == 'PRIMARY',
      orElse: () => muscleGroups.isNotEmpty
          ? muscleGroups.first
          : const ExerciseMuscleGroupApiItem(
              muscleGroupId: 0,
              code: 'other',
              name: 'Toàn thân',
              role: 'PRIMARY',
            ),
    );
    final secondary = muscleGroups
        .where((m) => m.role != 'PRIMARY')
        .map((m) => m.name)
        .toList();

    return ExerciseDefinition(
      id: 'ex_$id',
      name: name,
      nameVi: name,
      primaryMuscle: primary.name,
      primaryMuscleKey: primary.code.toLowerCase(),
      secondaryMuscles: secondary,
      equipment: _mapEquipment(equipment),
      description: description ?? '',
      instructions: const [],
      commonMistakes: const [],
    );
  }

  static EquipmentType _mapEquipment(List<ExerciseEquipmentApiItem> eqList) {
    if (eqList.isEmpty) return EquipmentType.bodyweight;
    final code = eqList.first.code.toLowerCase();
    if (code.contains('dumbbell') || code.contains('ta-don')) {
      return EquipmentType.dumbbell;
    }
    if (code.contains('barbell') || code.contains('ta-don-dai')) {
      return EquipmentType.barbell;
    }
    if (code.contains('cable') || code.contains('day-keo')) {
      return EquipmentType.cable;
    }
    if (code.contains('machine') || code.contains('may-tap')) {
      return EquipmentType.machine;
    }
    if (code.contains('bench') || code.contains('ghe')) {
      return EquipmentType.bench;
    }
    return EquipmentType.bodyweight;
  }
}

class ExerciseMuscleGroupApiItem {
  const ExerciseMuscleGroupApiItem({
    required this.muscleGroupId,
    required this.code,
    required this.name,
    required this.role,
  });

  factory ExerciseMuscleGroupApiItem.fromJson(Map<String, dynamic> json) {
    return ExerciseMuscleGroupApiItem(
      muscleGroupId: json['muscleGroupId'] as int? ?? json['id'] as int? ?? 0,
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? 'PRIMARY',
    );
  }

  final int muscleGroupId;
  final String code;
  final String name;
  final String role;
}

class ExerciseEquipmentApiItem {
  const ExerciseEquipmentApiItem({
    required this.equipmentId,
    required this.code,
    required this.name,
  });

  factory ExerciseEquipmentApiItem.fromJson(Map<String, dynamic> json) {
    return ExerciseEquipmentApiItem(
      equipmentId: json['equipmentId'] as int? ?? json['id'] as int? ?? 0,
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }

  final int equipmentId;
  final String code;
  final String name;
}

class ExerciseApiDetail {
  const ExerciseApiDetail({
    required this.id,
    required this.name,
    required this.searchName,
    required this.slug,
    required this.difficulty,
    this.description,
    this.thumbnailUrl,
    this.videoUrl,
    required this.instructionSteps,
    required this.commonMistakes,
    required this.safetyNotes,
    required this.muscleGroups,
    required this.equipment,
    this.isFavorite = false,
  });

  factory ExerciseApiDetail.fromJson(Map<String, dynamic> json) {
    final steps =
        (json['instructionSteps'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final mistakes =
        (json['commonMistakes'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final safety =
        (json['safetyNotes'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final muscleGroupsList =
        (json['muscleGroups'] as List<dynamic>?)
            ?.map(
              (e) => ExerciseMuscleGroupApiItem.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList() ??
        [];
    final equipmentList =
        (json['equipment'] as List<dynamic>?)
            ?.map(
              (e) =>
                  ExerciseEquipmentApiItem.fromJson(e as Map<String, dynamic>),
            )
            .toList() ??
        [];

    return ExerciseApiDetail(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      searchName: json['searchName'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? 'BEGINNER',
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      instructionSteps: steps,
      commonMistakes: mistakes,
      safetyNotes: safety,
      muscleGroups: muscleGroupsList,
      equipment: equipmentList,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  final int id;
  final String name;
  final String searchName;
  final String slug;
  final String difficulty;
  final String? description;
  final String? thumbnailUrl;
  final String? videoUrl;
  final List<String> instructionSteps;
  final List<String> commonMistakes;
  final List<String> safetyNotes;
  final List<ExerciseMuscleGroupApiItem> muscleGroups;
  final List<ExerciseEquipmentApiItem> equipment;
  final bool isFavorite;

  ExerciseDefinition toExerciseDefinition() {
    final primary = muscleGroups.firstWhere(
      (m) => m.role == 'PRIMARY',
      orElse: () => muscleGroups.isNotEmpty
          ? muscleGroups.first
          : const ExerciseMuscleGroupApiItem(
              muscleGroupId: 0,
              code: 'other',
              name: 'Toàn thân',
              role: 'PRIMARY',
            ),
    );
    final secondary = muscleGroups
        .where((m) => m.role != 'PRIMARY')
        .map((m) => m.name)
        .toList();

    final mistakeObjects = commonMistakes.map((m) {
      return ExerciseMistake(
        mistake: m,
        fix: 'Thực hiện động tác chậm lại, kiểm soát cơ bắp và thở đúng nhịp.',
      );
    }).toList();

    return ExerciseDefinition(
      id: 'ex_$id',
      name: name,
      nameVi: name,
      primaryMuscle: primary.name,
      primaryMuscleKey: primary.code.toLowerCase(),
      secondaryMuscles: secondary,
      equipment: ExerciseApiSummary._mapEquipment(equipment),
      description: description ?? '',
      instructions: instructionSteps,
      commonMistakes: mistakeObjects,
    );
  }
}

class MuscleGroupItem {
  const MuscleGroupItem({
    required this.id,
    required this.code,
    required this.name,
    this.description,
  });

  factory MuscleGroupItem.fromJson(Map<String, dynamic> json) {
    return MuscleGroupItem(
      id: json['id'] as int? ?? 0,
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
    );
  }

  final int id;
  final String code;
  final String name;
  final String? description;
}

class EquipmentItem {
  const EquipmentItem({
    required this.id,
    required this.code,
    required this.name,
    this.description,
  });

  factory EquipmentItem.fromJson(Map<String, dynamic> json) {
    return EquipmentItem(
      id: json['id'] as int? ?? 0,
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
    );
  }

  final int id;
  final String code;
  final String name;
  final String? description;
}
