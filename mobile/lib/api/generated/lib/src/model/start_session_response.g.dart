// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'start_session_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$StartSessionResponseCWProxy {
  StartSessionResponse id(int? id);

  StartSessionResponse workoutScheduleId(int? workoutScheduleId);

  StartSessionResponse status(String? status);

  StartSessionResponse startedAt(DateTime? startedAt);

  StartSessionResponse totalPausedSeconds(int? totalPausedSeconds);

  StartSessionResponse exercises(List<WorkoutExerciseResponse>? exercises);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StartSessionResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StartSessionResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  StartSessionResponse call({
    int? id,
    int? workoutScheduleId,
    String? status,
    DateTime? startedAt,
    int? totalPausedSeconds,
    List<WorkoutExerciseResponse>? exercises,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfStartSessionResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfStartSessionResponse.copyWith.fieldName(...)`
class _$StartSessionResponseCWProxyImpl
    implements _$StartSessionResponseCWProxy {
  const _$StartSessionResponseCWProxyImpl(this._value);

  final StartSessionResponse _value;

  @override
  StartSessionResponse id(int? id) => this(id: id);

  @override
  StartSessionResponse workoutScheduleId(int? workoutScheduleId) =>
      this(workoutScheduleId: workoutScheduleId);

  @override
  StartSessionResponse status(String? status) => this(status: status);

  @override
  StartSessionResponse startedAt(DateTime? startedAt) =>
      this(startedAt: startedAt);

  @override
  StartSessionResponse totalPausedSeconds(int? totalPausedSeconds) =>
      this(totalPausedSeconds: totalPausedSeconds);

  @override
  StartSessionResponse exercises(List<WorkoutExerciseResponse>? exercises) =>
      this(exercises: exercises);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StartSessionResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StartSessionResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  StartSessionResponse call({
    Object? id = const $CopyWithPlaceholder(),
    Object? workoutScheduleId = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? startedAt = const $CopyWithPlaceholder(),
    Object? totalPausedSeconds = const $CopyWithPlaceholder(),
    Object? exercises = const $CopyWithPlaceholder(),
  }) {
    return StartSessionResponse(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int?,
      workoutScheduleId: workoutScheduleId == const $CopyWithPlaceholder()
          ? _value.workoutScheduleId
          // ignore: cast_nullable_to_non_nullable
          : workoutScheduleId as int?,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as String?,
      startedAt: startedAt == const $CopyWithPlaceholder()
          ? _value.startedAt
          // ignore: cast_nullable_to_non_nullable
          : startedAt as DateTime?,
      totalPausedSeconds: totalPausedSeconds == const $CopyWithPlaceholder()
          ? _value.totalPausedSeconds
          // ignore: cast_nullable_to_non_nullable
          : totalPausedSeconds as int?,
      exercises: exercises == const $CopyWithPlaceholder()
          ? _value.exercises
          // ignore: cast_nullable_to_non_nullable
          : exercises as List<WorkoutExerciseResponse>?,
    );
  }
}

extension $StartSessionResponseCopyWith on StartSessionResponse {
  /// Returns a callable class that can be used as follows: `instanceOfStartSessionResponse.copyWith(...)` or like so:`instanceOfStartSessionResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$StartSessionResponseCWProxy get copyWith =>
      _$StartSessionResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StartSessionResponse _$StartSessionResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('StartSessionResponse', json, ($checkedConvert) {
  final val = StartSessionResponse(
    id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
    workoutScheduleId: $checkedConvert(
      'workoutScheduleId',
      (v) => (v as num?)?.toInt(),
    ),
    status: $checkedConvert('status', (v) => v as String?),
    startedAt: $checkedConvert(
      'startedAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    totalPausedSeconds: $checkedConvert(
      'totalPausedSeconds',
      (v) => (v as num?)?.toInt(),
    ),
    exercises: $checkedConvert(
      'exercises',
      (v) => (v as List<dynamic>?)
          ?.map(
            (e) => WorkoutExerciseResponse.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$StartSessionResponseToJson(
  StartSessionResponse instance,
) => <String, dynamic>{
  'id': ?instance.id,
  'workoutScheduleId': ?instance.workoutScheduleId,
  'status': ?instance.status,
  'startedAt': ?instance.startedAt?.toIso8601String(),
  'totalPausedSeconds': ?instance.totalPausedSeconds,
  'exercises': ?instance.exercises?.map((e) => e.toJson()).toList(),
};
