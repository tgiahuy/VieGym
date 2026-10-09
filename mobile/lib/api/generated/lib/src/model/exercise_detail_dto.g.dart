// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_detail_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ExerciseDetailDtoCWProxy {
  ExerciseDetailDto id(int? id);

  ExerciseDetailDto name(String? name);

  ExerciseDetailDto slug(String? slug);

  ExerciseDetailDto difficulty(String? difficulty);

  ExerciseDetailDto description(String? description);

  ExerciseDetailDto instructionSteps(List<String>? instructionSteps);

  ExerciseDetailDto commonMistakes(List<String>? commonMistakes);

  ExerciseDetailDto safetyNotes(List<String>? safetyNotes);

  ExerciseDetailDto muscleGroups(List<ExerciseMuscleGroupDto>? muscleGroups);

  ExerciseDetailDto equipment(List<ExerciseEquipmentDto>? equipment);

  ExerciseDetailDto media(List<Object>? media);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExerciseDetailDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExerciseDetailDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ExerciseDetailDto call({
    int? id,
    String? name,
    String? slug,
    String? difficulty,
    String? description,
    List<String>? instructionSteps,
    List<String>? commonMistakes,
    List<String>? safetyNotes,
    List<ExerciseMuscleGroupDto>? muscleGroups,
    List<ExerciseEquipmentDto>? equipment,
    List<Object>? media,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfExerciseDetailDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfExerciseDetailDto.copyWith.fieldName(...)`
class _$ExerciseDetailDtoCWProxyImpl implements _$ExerciseDetailDtoCWProxy {
  const _$ExerciseDetailDtoCWProxyImpl(this._value);

  final ExerciseDetailDto _value;

  @override
  ExerciseDetailDto id(int? id) => this(id: id);

  @override
  ExerciseDetailDto name(String? name) => this(name: name);

  @override
  ExerciseDetailDto slug(String? slug) => this(slug: slug);

  @override
  ExerciseDetailDto difficulty(String? difficulty) =>
      this(difficulty: difficulty);

  @override
  ExerciseDetailDto description(String? description) =>
      this(description: description);

  @override
  ExerciseDetailDto instructionSteps(List<String>? instructionSteps) =>
      this(instructionSteps: instructionSteps);

  @override
  ExerciseDetailDto commonMistakes(List<String>? commonMistakes) =>
      this(commonMistakes: commonMistakes);

  @override
  ExerciseDetailDto safetyNotes(List<String>? safetyNotes) =>
      this(safetyNotes: safetyNotes);

  @override
  ExerciseDetailDto muscleGroups(List<ExerciseMuscleGroupDto>? muscleGroups) =>
      this(muscleGroups: muscleGroups);

  @override
  ExerciseDetailDto equipment(List<ExerciseEquipmentDto>? equipment) =>
      this(equipment: equipment);

  @override
  ExerciseDetailDto media(List<Object>? media) => this(media: media);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExerciseDetailDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExerciseDetailDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ExerciseDetailDto call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? slug = const $CopyWithPlaceholder(),
    Object? difficulty = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? instructionSteps = const $CopyWithPlaceholder(),
    Object? commonMistakes = const $CopyWithPlaceholder(),
    Object? safetyNotes = const $CopyWithPlaceholder(),
    Object? muscleGroups = const $CopyWithPlaceholder(),
    Object? equipment = const $CopyWithPlaceholder(),
    Object? media = const $CopyWithPlaceholder(),
  }) {
    return ExerciseDetailDto(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int?,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      slug: slug == const $CopyWithPlaceholder()
          ? _value.slug
          // ignore: cast_nullable_to_non_nullable
          : slug as String?,
      difficulty: difficulty == const $CopyWithPlaceholder()
          ? _value.difficulty
          // ignore: cast_nullable_to_non_nullable
          : difficulty as String?,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String?,
      instructionSteps: instructionSteps == const $CopyWithPlaceholder()
          ? _value.instructionSteps
          // ignore: cast_nullable_to_non_nullable
          : instructionSteps as List<String>?,
      commonMistakes: commonMistakes == const $CopyWithPlaceholder()
          ? _value.commonMistakes
          // ignore: cast_nullable_to_non_nullable
          : commonMistakes as List<String>?,
      safetyNotes: safetyNotes == const $CopyWithPlaceholder()
          ? _value.safetyNotes
          // ignore: cast_nullable_to_non_nullable
          : safetyNotes as List<String>?,
      muscleGroups: muscleGroups == const $CopyWithPlaceholder()
          ? _value.muscleGroups
          // ignore: cast_nullable_to_non_nullable
          : muscleGroups as List<ExerciseMuscleGroupDto>?,
      equipment: equipment == const $CopyWithPlaceholder()
          ? _value.equipment
          // ignore: cast_nullable_to_non_nullable
          : equipment as List<ExerciseEquipmentDto>?,
      media: media == const $CopyWithPlaceholder()
          ? _value.media
          // ignore: cast_nullable_to_non_nullable
          : media as List<Object>?,
    );
  }
}

extension $ExerciseDetailDtoCopyWith on ExerciseDetailDto {
  /// Returns a callable class that can be used as follows: `instanceOfExerciseDetailDto.copyWith(...)` or like so:`instanceOfExerciseDetailDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ExerciseDetailDtoCWProxy get copyWith =>
      _$ExerciseDetailDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExerciseDetailDto _$ExerciseDetailDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ExerciseDetailDto', json, ($checkedConvert) {
      final val = ExerciseDetailDto(
        id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
        name: $checkedConvert('name', (v) => v as String?),
        slug: $checkedConvert('slug', (v) => v as String?),
        difficulty: $checkedConvert('difficulty', (v) => v as String?),
        description: $checkedConvert('description', (v) => v as String?),
        instructionSteps: $checkedConvert(
          'instructionSteps',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
        ),
        commonMistakes: $checkedConvert(
          'commonMistakes',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
        ),
        safetyNotes: $checkedConvert(
          'safetyNotes',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
        ),
        muscleGroups: $checkedConvert(
          'muscleGroups',
          (v) => (v as List<dynamic>?)
              ?.map(
                (e) =>
                    ExerciseMuscleGroupDto.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
        ),
        equipment: $checkedConvert(
          'equipment',
          (v) => (v as List<dynamic>?)
              ?.map(
                (e) => ExerciseEquipmentDto.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
        ),
        media: $checkedConvert(
          'media',
          (v) => (v as List<dynamic>?)?.map((e) => e as Object).toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ExerciseDetailDtoToJson(ExerciseDetailDto instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'name': ?instance.name,
      'slug': ?instance.slug,
      'difficulty': ?instance.difficulty,
      'description': ?instance.description,
      'instructionSteps': ?instance.instructionSteps,
      'commonMistakes': ?instance.commonMistakes,
      'safetyNotes': ?instance.safetyNotes,
      'muscleGroups': ?instance.muscleGroups?.map((e) => e.toJson()).toList(),
      'equipment': ?instance.equipment?.map((e) => e.toJson()).toList(),
      'media': ?instance.media,
    };
