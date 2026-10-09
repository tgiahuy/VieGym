// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_exercise_log_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WorkoutExerciseLogDtoCWProxy {
  WorkoutExerciseLogDto id(int? id);

  WorkoutExerciseLogDto exerciseId(int? exerciseId);

  WorkoutExerciseLogDto exerciseName(String? exerciseName);

  WorkoutExerciseLogDto sortOrder(int? sortOrder);

  WorkoutExerciseLogDto durationSeconds(int? durationSeconds);

  WorkoutExerciseLogDto exerciseVolumeKg(double? exerciseVolumeKg);

  WorkoutExerciseLogDto completed(bool? completed);

  WorkoutExerciseLogDto sets(List<WorkoutSetLogDto>? sets);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutExerciseLogDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutExerciseLogDto(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutExerciseLogDto call({
    int? id,
    int? exerciseId,
    String? exerciseName,
    int? sortOrder,
    int? durationSeconds,
    double? exerciseVolumeKg,
    bool? completed,
    List<WorkoutSetLogDto>? sets,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWorkoutExerciseLogDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWorkoutExerciseLogDto.copyWith.fieldName(...)`
class _$WorkoutExerciseLogDtoCWProxyImpl
    implements _$WorkoutExerciseLogDtoCWProxy {
  const _$WorkoutExerciseLogDtoCWProxyImpl(this._value);

  final WorkoutExerciseLogDto _value;

  @override
  WorkoutExerciseLogDto id(int? id) => this(id: id);

  @override
  WorkoutExerciseLogDto exerciseId(int? exerciseId) =>
      this(exerciseId: exerciseId);

  @override
  WorkoutExerciseLogDto exerciseName(String? exerciseName) =>
      this(exerciseName: exerciseName);

  @override
  WorkoutExerciseLogDto sortOrder(int? sortOrder) => this(sortOrder: sortOrder);

  @override
  WorkoutExerciseLogDto durationSeconds(int? durationSeconds) =>
      this(durationSeconds: durationSeconds);

  @override
  WorkoutExerciseLogDto exerciseVolumeKg(double? exerciseVolumeKg) =>
      this(exerciseVolumeKg: exerciseVolumeKg);

  @override
  WorkoutExerciseLogDto completed(bool? completed) =>
      this(completed: completed);

  @override
  WorkoutExerciseLogDto sets(List<WorkoutSetLogDto>? sets) => this(sets: sets);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutExerciseLogDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutExerciseLogDto(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutExerciseLogDto call({
    Object? id = const $CopyWithPlaceholder(),
    Object? exerciseId = const $CopyWithPlaceholder(),
    Object? exerciseName = const $CopyWithPlaceholder(),
    Object? sortOrder = const $CopyWithPlaceholder(),
    Object? durationSeconds = const $CopyWithPlaceholder(),
    Object? exerciseVolumeKg = const $CopyWithPlaceholder(),
    Object? completed = const $CopyWithPlaceholder(),
    Object? sets = const $CopyWithPlaceholder(),
  }) {
    return WorkoutExerciseLogDto(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int?,
      exerciseId: exerciseId == const $CopyWithPlaceholder()
          ? _value.exerciseId
          // ignore: cast_nullable_to_non_nullable
          : exerciseId as int?,
      exerciseName: exerciseName == const $CopyWithPlaceholder()
          ? _value.exerciseName
          // ignore: cast_nullable_to_non_nullable
          : exerciseName as String?,
      sortOrder: sortOrder == const $CopyWithPlaceholder()
          ? _value.sortOrder
          // ignore: cast_nullable_to_non_nullable
          : sortOrder as int?,
      durationSeconds: durationSeconds == const $CopyWithPlaceholder()
          ? _value.durationSeconds
          // ignore: cast_nullable_to_non_nullable
          : durationSeconds as int?,
      exerciseVolumeKg: exerciseVolumeKg == const $CopyWithPlaceholder()
          ? _value.exerciseVolumeKg
          // ignore: cast_nullable_to_non_nullable
          : exerciseVolumeKg as double?,
      completed: completed == const $CopyWithPlaceholder()
          ? _value.completed
          // ignore: cast_nullable_to_non_nullable
          : completed as bool?,
      sets: sets == const $CopyWithPlaceholder()
          ? _value.sets
          // ignore: cast_nullable_to_non_nullable
          : sets as List<WorkoutSetLogDto>?,
    );
  }
}

extension $WorkoutExerciseLogDtoCopyWith on WorkoutExerciseLogDto {
  /// Returns a callable class that can be used as follows: `instanceOfWorkoutExerciseLogDto.copyWith(...)` or like so:`instanceOfWorkoutExerciseLogDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WorkoutExerciseLogDtoCWProxy get copyWith =>
      _$WorkoutExerciseLogDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutExerciseLogDto _$WorkoutExerciseLogDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('WorkoutExerciseLogDto', json, ($checkedConvert) {
  final val = WorkoutExerciseLogDto(
    id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
    exerciseId: $checkedConvert('exerciseId', (v) => (v as num?)?.toInt()),
    exerciseName: $checkedConvert('exerciseName', (v) => v as String?),
    sortOrder: $checkedConvert('sortOrder', (v) => (v as num?)?.toInt()),
    durationSeconds: $checkedConvert(
      'durationSeconds',
      (v) => (v as num?)?.toInt(),
    ),
    exerciseVolumeKg: $checkedConvert(
      'exerciseVolumeKg',
      (v) => (v as num?)?.toDouble(),
    ),
    completed: $checkedConvert('completed', (v) => v as bool?),
    sets: $checkedConvert(
      'sets',
      (v) => (v as List<dynamic>?)
          ?.map((e) => WorkoutSetLogDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$WorkoutExerciseLogDtoToJson(
  WorkoutExerciseLogDto instance,
) => <String, dynamic>{
  'id': ?instance.id,
  'exerciseId': ?instance.exerciseId,
  'exerciseName': ?instance.exerciseName,
  'sortOrder': ?instance.sortOrder,
  'durationSeconds': ?instance.durationSeconds,
  'exerciseVolumeKg': ?instance.exerciseVolumeKg,
  'completed': ?instance.completed,
  'sets': ?instance.sets?.map((e) => e.toJson()).toList(),
};
