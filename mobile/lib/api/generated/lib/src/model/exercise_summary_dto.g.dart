// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_summary_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ExerciseSummaryDtoCWProxy {
  ExerciseSummaryDto id(int? id);

  ExerciseSummaryDto name(String? name);

  ExerciseSummaryDto slug(String? slug);

  ExerciseSummaryDto difficulty(String? difficulty);

  ExerciseSummaryDto description(String? description);

  ExerciseSummaryDto muscleGroups(List<ExerciseMuscleGroupDto>? muscleGroups);

  ExerciseSummaryDto equipment(List<ExerciseEquipmentDto>? equipment);

  ExerciseSummaryDto media(List<Object>? media);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExerciseSummaryDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExerciseSummaryDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ExerciseSummaryDto call({
    int? id,
    String? name,
    String? slug,
    String? difficulty,
    String? description,
    List<ExerciseMuscleGroupDto>? muscleGroups,
    List<ExerciseEquipmentDto>? equipment,
    List<Object>? media,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfExerciseSummaryDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfExerciseSummaryDto.copyWith.fieldName(...)`
class _$ExerciseSummaryDtoCWProxyImpl implements _$ExerciseSummaryDtoCWProxy {
  const _$ExerciseSummaryDtoCWProxyImpl(this._value);

  final ExerciseSummaryDto _value;

  @override
  ExerciseSummaryDto id(int? id) => this(id: id);

  @override
  ExerciseSummaryDto name(String? name) => this(name: name);

  @override
  ExerciseSummaryDto slug(String? slug) => this(slug: slug);

  @override
  ExerciseSummaryDto difficulty(String? difficulty) =>
      this(difficulty: difficulty);

  @override
  ExerciseSummaryDto description(String? description) =>
      this(description: description);

  @override
  ExerciseSummaryDto muscleGroups(List<ExerciseMuscleGroupDto>? muscleGroups) =>
      this(muscleGroups: muscleGroups);

  @override
  ExerciseSummaryDto equipment(List<ExerciseEquipmentDto>? equipment) =>
      this(equipment: equipment);

  @override
  ExerciseSummaryDto media(List<Object>? media) => this(media: media);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExerciseSummaryDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExerciseSummaryDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ExerciseSummaryDto call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? slug = const $CopyWithPlaceholder(),
    Object? difficulty = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? muscleGroups = const $CopyWithPlaceholder(),
    Object? equipment = const $CopyWithPlaceholder(),
    Object? media = const $CopyWithPlaceholder(),
  }) {
    return ExerciseSummaryDto(
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

extension $ExerciseSummaryDtoCopyWith on ExerciseSummaryDto {
  /// Returns a callable class that can be used as follows: `instanceOfExerciseSummaryDto.copyWith(...)` or like so:`instanceOfExerciseSummaryDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ExerciseSummaryDtoCWProxy get copyWith =>
      _$ExerciseSummaryDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExerciseSummaryDto _$ExerciseSummaryDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ExerciseSummaryDto', json, ($checkedConvert) {
      final val = ExerciseSummaryDto(
        id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
        name: $checkedConvert('name', (v) => v as String?),
        slug: $checkedConvert('slug', (v) => v as String?),
        difficulty: $checkedConvert('difficulty', (v) => v as String?),
        description: $checkedConvert('description', (v) => v as String?),
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

Map<String, dynamic> _$ExerciseSummaryDtoToJson(ExerciseSummaryDto instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'name': ?instance.name,
      'slug': ?instance.slug,
      'difficulty': ?instance.difficulty,
      'description': ?instance.description,
      'muscleGroups': ?instance.muscleGroups?.map((e) => e.toJson()).toList(),
      'equipment': ?instance.equipment?.map((e) => e.toJson()).toList(),
      'media': ?instance.media,
    };
