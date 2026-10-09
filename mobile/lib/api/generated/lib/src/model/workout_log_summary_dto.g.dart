// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_log_summary_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WorkoutLogSummaryDtoCWProxy {
  WorkoutLogSummaryDto id(int? id);

  WorkoutLogSummaryDto workoutSessionId(int? workoutSessionId);

  WorkoutLogSummaryDto workoutScheduleId(int? workoutScheduleId);

  WorkoutLogSummaryDto title(String? title);

  WorkoutLogSummaryDto startedAt(DateTime? startedAt);

  WorkoutLogSummaryDto completedAt(DateTime? completedAt);

  WorkoutLogSummaryDto durationSeconds(int? durationSeconds);

  WorkoutLogSummaryDto totalVolumeKg(double? totalVolumeKg);

  WorkoutLogSummaryDto totalExercises(int? totalExercises);

  WorkoutLogSummaryDto prCount(int? prCount);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutLogSummaryDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutLogSummaryDto(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutLogSummaryDto call({
    int? id,
    int? workoutSessionId,
    int? workoutScheduleId,
    String? title,
    DateTime? startedAt,
    DateTime? completedAt,
    int? durationSeconds,
    double? totalVolumeKg,
    int? totalExercises,
    int? prCount,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWorkoutLogSummaryDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWorkoutLogSummaryDto.copyWith.fieldName(...)`
class _$WorkoutLogSummaryDtoCWProxyImpl
    implements _$WorkoutLogSummaryDtoCWProxy {
  const _$WorkoutLogSummaryDtoCWProxyImpl(this._value);

  final WorkoutLogSummaryDto _value;

  @override
  WorkoutLogSummaryDto id(int? id) => this(id: id);

  @override
  WorkoutLogSummaryDto workoutSessionId(int? workoutSessionId) =>
      this(workoutSessionId: workoutSessionId);

  @override
  WorkoutLogSummaryDto workoutScheduleId(int? workoutScheduleId) =>
      this(workoutScheduleId: workoutScheduleId);

  @override
  WorkoutLogSummaryDto title(String? title) => this(title: title);

  @override
  WorkoutLogSummaryDto startedAt(DateTime? startedAt) =>
      this(startedAt: startedAt);

  @override
  WorkoutLogSummaryDto completedAt(DateTime? completedAt) =>
      this(completedAt: completedAt);

  @override
  WorkoutLogSummaryDto durationSeconds(int? durationSeconds) =>
      this(durationSeconds: durationSeconds);

  @override
  WorkoutLogSummaryDto totalVolumeKg(double? totalVolumeKg) =>
      this(totalVolumeKg: totalVolumeKg);

  @override
  WorkoutLogSummaryDto totalExercises(int? totalExercises) =>
      this(totalExercises: totalExercises);

  @override
  WorkoutLogSummaryDto prCount(int? prCount) => this(prCount: prCount);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutLogSummaryDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutLogSummaryDto(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutLogSummaryDto call({
    Object? id = const $CopyWithPlaceholder(),
    Object? workoutSessionId = const $CopyWithPlaceholder(),
    Object? workoutScheduleId = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? startedAt = const $CopyWithPlaceholder(),
    Object? completedAt = const $CopyWithPlaceholder(),
    Object? durationSeconds = const $CopyWithPlaceholder(),
    Object? totalVolumeKg = const $CopyWithPlaceholder(),
    Object? totalExercises = const $CopyWithPlaceholder(),
    Object? prCount = const $CopyWithPlaceholder(),
  }) {
    return WorkoutLogSummaryDto(
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
      totalExercises: totalExercises == const $CopyWithPlaceholder()
          ? _value.totalExercises
          // ignore: cast_nullable_to_non_nullable
          : totalExercises as int?,
      prCount: prCount == const $CopyWithPlaceholder()
          ? _value.prCount
          // ignore: cast_nullable_to_non_nullable
          : prCount as int?,
    );
  }
}

extension $WorkoutLogSummaryDtoCopyWith on WorkoutLogSummaryDto {
  /// Returns a callable class that can be used as follows: `instanceOfWorkoutLogSummaryDto.copyWith(...)` or like so:`instanceOfWorkoutLogSummaryDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WorkoutLogSummaryDtoCWProxy get copyWith =>
      _$WorkoutLogSummaryDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutLogSummaryDto _$WorkoutLogSummaryDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('WorkoutLogSummaryDto', json, ($checkedConvert) {
  final val = WorkoutLogSummaryDto(
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
    totalExercises: $checkedConvert(
      'totalExercises',
      (v) => (v as num?)?.toInt(),
    ),
    prCount: $checkedConvert('prCount', (v) => (v as num?)?.toInt()),
  );
  return val;
});

Map<String, dynamic> _$WorkoutLogSummaryDtoToJson(
  WorkoutLogSummaryDto instance,
) => <String, dynamic>{
  'id': ?instance.id,
  'workoutSessionId': ?instance.workoutSessionId,
  'workoutScheduleId': ?instance.workoutScheduleId,
  'title': ?instance.title,
  'startedAt': ?instance.startedAt?.toIso8601String(),
  'completedAt': ?instance.completedAt?.toIso8601String(),
  'durationSeconds': ?instance.durationSeconds,
  'totalVolumeKg': ?instance.totalVolumeKg,
  'totalExercises': ?instance.totalExercises,
  'prCount': ?instance.prCount,
};
