// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_log_detail_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WorkoutLogDetailDtoCWProxy {
  WorkoutLogDetailDto id(int? id);

  WorkoutLogDetailDto workoutSessionId(int? workoutSessionId);

  WorkoutLogDetailDto workoutScheduleId(int? workoutScheduleId);

  WorkoutLogDetailDto title(String? title);

  WorkoutLogDetailDto startedAt(DateTime? startedAt);

  WorkoutLogDetailDto completedAt(DateTime? completedAt);

  WorkoutLogDetailDto durationSeconds(int? durationSeconds);

  WorkoutLogDetailDto totalVolumeKg(double? totalVolumeKg);

  WorkoutLogDetailDto note(String? note);

  WorkoutLogDetailDto exercises(List<WorkoutExerciseLogDto>? exercises);

  WorkoutLogDetailDto personalRecords(List<PersonalRecordDto>? personalRecords);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutLogDetailDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutLogDetailDto(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutLogDetailDto call({
    int? id,
    int? workoutSessionId,
    int? workoutScheduleId,
    String? title,
    DateTime? startedAt,
    DateTime? completedAt,
    int? durationSeconds,
    double? totalVolumeKg,
    String? note,
    List<WorkoutExerciseLogDto>? exercises,
    List<PersonalRecordDto>? personalRecords,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWorkoutLogDetailDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWorkoutLogDetailDto.copyWith.fieldName(...)`
class _$WorkoutLogDetailDtoCWProxyImpl implements _$WorkoutLogDetailDtoCWProxy {
  const _$WorkoutLogDetailDtoCWProxyImpl(this._value);

  final WorkoutLogDetailDto _value;

  @override
  WorkoutLogDetailDto id(int? id) => this(id: id);

  @override
  WorkoutLogDetailDto workoutSessionId(int? workoutSessionId) =>
      this(workoutSessionId: workoutSessionId);

  @override
  WorkoutLogDetailDto workoutScheduleId(int? workoutScheduleId) =>
      this(workoutScheduleId: workoutScheduleId);

  @override
  WorkoutLogDetailDto title(String? title) => this(title: title);

  @override
  WorkoutLogDetailDto startedAt(DateTime? startedAt) =>
      this(startedAt: startedAt);

  @override
  WorkoutLogDetailDto completedAt(DateTime? completedAt) =>
      this(completedAt: completedAt);

  @override
  WorkoutLogDetailDto durationSeconds(int? durationSeconds) =>
      this(durationSeconds: durationSeconds);

  @override
  WorkoutLogDetailDto totalVolumeKg(double? totalVolumeKg) =>
      this(totalVolumeKg: totalVolumeKg);

  @override
  WorkoutLogDetailDto note(String? note) => this(note: note);

  @override
  WorkoutLogDetailDto exercises(List<WorkoutExerciseLogDto>? exercises) =>
      this(exercises: exercises);

  @override
  WorkoutLogDetailDto personalRecords(
    List<PersonalRecordDto>? personalRecords,
  ) => this(personalRecords: personalRecords);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutLogDetailDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutLogDetailDto(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutLogDetailDto call({
    Object? id = const $CopyWithPlaceholder(),
    Object? workoutSessionId = const $CopyWithPlaceholder(),
    Object? workoutScheduleId = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? startedAt = const $CopyWithPlaceholder(),
    Object? completedAt = const $CopyWithPlaceholder(),
    Object? durationSeconds = const $CopyWithPlaceholder(),
    Object? totalVolumeKg = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
    Object? exercises = const $CopyWithPlaceholder(),
    Object? personalRecords = const $CopyWithPlaceholder(),
  }) {
    return WorkoutLogDetailDto(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int?,
      workoutSessionId: workoutSessionId == const $CopyWithPlaceholder()
          ? _value.workoutSessionId
          // ignore: cast_nullable_to_non_nullable
          : workoutSessionId as int?,
      workoutScheduleId: workoutScheduleId == const $CopyWithPlaceholder()
          ? _value.workoutScheduleId
          // ignore: cast_nullable_to_non_nullable
          : workoutScheduleId as int?,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String?,
      startedAt: startedAt == const $CopyWithPlaceholder()
          ? _value.startedAt
          // ignore: cast_nullable_to_non_nullable
          : startedAt as DateTime?,
      completedAt: completedAt == const $CopyWithPlaceholder()
          ? _value.completedAt
          // ignore: cast_nullable_to_non_nullable
          : completedAt as DateTime?,
      durationSeconds: durationSeconds == const $CopyWithPlaceholder()
          ? _value.durationSeconds
          // ignore: cast_nullable_to_non_nullable
          : durationSeconds as int?,
      totalVolumeKg: totalVolumeKg == const $CopyWithPlaceholder()
          ? _value.totalVolumeKg
          // ignore: cast_nullable_to_non_nullable
          : totalVolumeKg as double?,
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String?,
      exercises: exercises == const $CopyWithPlaceholder()
          ? _value.exercises
          // ignore: cast_nullable_to_non_nullable
          : exercises as List<WorkoutExerciseLogDto>?,
      personalRecords: personalRecords == const $CopyWithPlaceholder()
          ? _value.personalRecords
          // ignore: cast_nullable_to_non_nullable
          : personalRecords as List<PersonalRecordDto>?,
    );
  }
}

extension $WorkoutLogDetailDtoCopyWith on WorkoutLogDetailDto {
  /// Returns a callable class that can be used as follows: `instanceOfWorkoutLogDetailDto.copyWith(...)` or like so:`instanceOfWorkoutLogDetailDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WorkoutLogDetailDtoCWProxy get copyWith =>
      _$WorkoutLogDetailDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutLogDetailDto _$WorkoutLogDetailDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('WorkoutLogDetailDto', json, ($checkedConvert) {
      final val = WorkoutLogDetailDto(
        id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
        workoutSessionId: $checkedConvert(
          'workoutSessionId',
          (v) => (v as num?)?.toInt(),
        ),
        workoutScheduleId: $checkedConvert(
          'workoutScheduleId',
          (v) => (v as num?)?.toInt(),
        ),
        title: $checkedConvert('title', (v) => v as String?),
        startedAt: $checkedConvert(
          'startedAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        completedAt: $checkedConvert(
          'completedAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        durationSeconds: $checkedConvert(
          'durationSeconds',
          (v) => (v as num?)?.toInt(),
        ),
        totalVolumeKg: $checkedConvert(
          'totalVolumeKg',
          (v) => (v as num?)?.toDouble(),
        ),
        note: $checkedConvert('note', (v) => v as String?),
        exercises: $checkedConvert(
          'exercises',
          (v) => (v as List<dynamic>?)
              ?.map(
                (e) =>
                    WorkoutExerciseLogDto.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
        ),
        personalRecords: $checkedConvert(
          'personalRecords',
          (v) => (v as List<dynamic>?)
              ?.map(
                (e) => PersonalRecordDto.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$WorkoutLogDetailDtoToJson(
  WorkoutLogDetailDto instance,
) => <String, dynamic>{
  'id': ?instance.id,
  'workoutSessionId': ?instance.workoutSessionId,
  'workoutScheduleId': ?instance.workoutScheduleId,
  'title': ?instance.title,
  'startedAt': ?instance.startedAt?.toIso8601String(),
  'completedAt': ?instance.completedAt?.toIso8601String(),
  'durationSeconds': ?instance.durationSeconds,
  'totalVolumeKg': ?instance.totalVolumeKg,
  'note': ?instance.note,
  'exercises': ?instance.exercises?.map((e) => e.toJson()).toList(),
  'personalRecords': ?instance.personalRecords?.map((e) => e.toJson()).toList(),
};
