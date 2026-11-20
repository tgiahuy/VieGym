import '../data/exercise_catalog.dart';
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

    final mediaList = (json['media'] as List<dynamic>?) ?? [];
    String? thumb = json['thumbnailUrl'] as String?;
    String? vid = json['videoUrl'] as String?;
    for (final m in mediaList) {
      if (m is Map<String, dynamic>) {
        final role = m['role'] as String?;
        final url = m['url'] as String?;
        if ((role == 'THUMBNAIL' || role == 'GALLERY') && (thumb == null || thumb.isEmpty)) {
          thumb = url;
        } else if (role == 'PRIMARY_VIDEO' && (vid == null || vid.isEmpty)) {
          vid = url;
        }
      }
    }

    return ExerciseApiSummary(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      searchName: json['searchName'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? 'BEGINNER',
      description: json['description'] as String?,
      thumbnailUrl: thumb,
      videoUrl: vid,
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

    final existingDef = findExerciseByName(name) ?? findExercise('ex_$id');
    final thumb = (thumbnailUrl != null && thumbnailUrl!.isNotEmpty)
        ? thumbnailUrl!
        : (existingDef?.thumbnailUrl.isNotEmpty == true
            ? existingDef!.thumbnailUrl
            : resolveExerciseCdnImage(slug.isNotEmpty ? slug : name));
    final vid = (videoUrl != null && videoUrl!.isNotEmpty)
        ? videoUrl
        : (existingDef?.videoUrl ?? resolveExerciseCdnVideo(slug.isNotEmpty ? slug : name));

    return ExerciseDefinition(
      id: 'ex_$id',
      name: name,
      nameVi: (existingDef != null && existingDef.nameVi.isNotEmpty)
          ? existingDef.nameVi
          : name,
      primaryMuscle: primary.name,
      primaryMuscleKey: primary.code.toLowerCase(),
      secondaryMuscles: secondary,
      equipment: _mapEquipment(equipment),
      equipmentIds: equipment.map((item) => item.equipmentId).toList(),
      equipmentCodes: equipment.map((item) => item.code).toList(),
      description: description ?? (existingDef?.description ?? ''),
      thumbnailUrl: thumb,
      videoUrl: vid,
      instructions: existingDef?.instructions ?? const [],
      commonMistakes: existingDef?.commonMistakes ?? const [],
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

    final mediaList = (json['media'] as List<dynamic>?) ?? [];
    String? thumb = json['thumbnailUrl'] as String?;
    String? vid = json['videoUrl'] as String?;
    for (final m in mediaList) {
      if (m is Map<String, dynamic>) {
        final role = m['role'] as String?;
        final url = m['url'] as String?;
        if ((role == 'THUMBNAIL' || role == 'GALLERY') && (thumb == null || thumb.isEmpty)) {
          thumb = url;
        } else if (role == 'PRIMARY_VIDEO' && (vid == null || vid.isEmpty)) {
          vid = url;
        }
      }
    }

    return ExerciseApiDetail(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      searchName: json['searchName'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? 'BEGINNER',
      description: json['description'] as String?,
      thumbnailUrl: thumb,
      videoUrl: vid,
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

    final existingDef = findExerciseByName(name) ?? findExercise('ex_$id');
    final thumb = (thumbnailUrl != null && thumbnailUrl!.isNotEmpty)
        ? thumbnailUrl!
        : (existingDef?.thumbnailUrl.isNotEmpty == true
            ? existingDef!.thumbnailUrl
            : resolveExerciseCdnImage(slug.isNotEmpty ? slug : name));
    final vid = (videoUrl != null && videoUrl!.isNotEmpty)
        ? videoUrl
        : (existingDef?.videoUrl ?? resolveExerciseCdnVideo(slug.isNotEmpty ? slug : name));

    return ExerciseDefinition(
      id: 'ex_$id',
      name: name,
      nameVi: (existingDef != null && existingDef.nameVi.isNotEmpty)
          ? existingDef.nameVi
          : name,
      primaryMuscle: primary.name,
      primaryMuscleKey: primary.code.toLowerCase(),
      secondaryMuscles: secondary,
      equipment: ExerciseApiSummary._mapEquipment(equipment),
      equipmentIds: equipment.map((item) => item.equipmentId).toList(),
      equipmentCodes: equipment.map((item) => item.code).toList(),
      description: description ?? (existingDef?.description ?? ''),
      thumbnailUrl: thumb,
      videoUrl: vid,
      instructions: instructionSteps.isNotEmpty ? instructionSteps : (existingDef?.instructions ?? const []),
      commonMistakes: mistakeObjects.isNotEmpty ? mistakeObjects : (existingDef?.commonMistakes ?? const []),
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
