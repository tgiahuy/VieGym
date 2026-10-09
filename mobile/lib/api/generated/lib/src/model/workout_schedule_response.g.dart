// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_schedule_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WorkoutScheduleResponseCWProxy {
  WorkoutScheduleResponse id(int? id);

  WorkoutScheduleResponse workoutProgramId(int? workoutProgramId);

  WorkoutScheduleResponse workoutDayId(int? workoutDayId);

  WorkoutScheduleResponse scheduledDate(DateTime? scheduledDate);

  WorkoutScheduleResponse scheduledTime(String? scheduledTime);

  WorkoutScheduleResponse title(String? title);

  WorkoutScheduleResponse status(String? status);

  WorkoutScheduleResponse cancelReason(String? cancelReason);

  WorkoutScheduleResponse completedAt(DateTime? completedAt);

  WorkoutScheduleResponse activeSessionId(int? activeSessionId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutScheduleResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutScheduleResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutScheduleResponse call({
    int? id,
    int? workoutProgramId,
    int? workoutDayId,
    DateTime? scheduledDate,
    String? scheduledTime,
    String? title,
    String? status,
    String? cancelReason,
    DateTime? completedAt,
    int? activeSessionId,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWorkoutScheduleResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWorkoutScheduleResponse.copyWith.fieldName(...)`
class _$WorkoutScheduleResponseCWProxyImpl
    implements _$WorkoutScheduleResponseCWProxy {
  const _$WorkoutScheduleResponseCWProxyImpl(this._value);

  final WorkoutScheduleResponse _value;

  @override
  WorkoutScheduleResponse id(int? id) => this(id: id);

  @override
  WorkoutScheduleResponse workoutProgramId(int? workoutProgramId) =>
      this(workoutProgramId: workoutProgramId);

  @override
  WorkoutScheduleResponse workoutDayId(int? workoutDayId) =>
      this(workoutDayId: workoutDayId);

  @override
  WorkoutScheduleResponse scheduledDate(DateTime? scheduledDate) =>
      this(scheduledDate: scheduledDate);

  @override
  WorkoutScheduleResponse scheduledTime(String? scheduledTime) =>
      this(scheduledTime: scheduledTime);

  @override
  WorkoutScheduleResponse title(String? title) => this(title: title);

  @override
  WorkoutScheduleResponse status(String? status) => this(status: status);

  @override
  WorkoutScheduleResponse cancelReason(String? cancelReason) =>
      this(cancelReason: cancelReason);

  @override
  WorkoutScheduleResponse completedAt(DateTime? completedAt) =>
      this(completedAt: completedAt);

  @override
  WorkoutScheduleResponse activeSessionId(int? activeSessionId) =>
      this(activeSessionId: activeSessionId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutScheduleResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutScheduleResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutScheduleResponse call({
    Object? id = const $CopyWithPlaceholder(),
    Object? workoutProgramId = const $CopyWithPlaceholder(),
    Object? workoutDayId = const $CopyWithPlaceholder(),
    Object? scheduledDate = const $CopyWithPlaceholder(),
    Object? scheduledTime = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? cancelReason = const $CopyWithPlaceholder(),
    Object? completedAt = const $CopyWithPlaceholder(),
    Object? activeSessionId = const $CopyWithPlaceholder(),
  }) {
    return WorkoutScheduleResponse(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int?,
      workoutProgramId: workoutProgramId == const $CopyWithPlaceholder()
          ? _value.workoutProgramId
          // ignore: cast_nullable_to_non_nullable
          : workoutProgramId as int?,
      workoutDayId: workoutDayId == const $CopyWithPlaceholder()
          ? _value.workoutDayId
          // ignore: cast_nullable_to_non_nullable
          : workoutDayId as int?,
      scheduledDate: scheduledDate == const $CopyWithPlaceholder()
          ? _value.scheduledDate
          // ignore: cast_nullable_to_non_nullable
          : scheduledDate as DateTime?,
      scheduledTime: scheduledTime == const $CopyWithPlaceholder()
          ? _value.scheduledTime
          // ignore: cast_nullable_to_non_nullable
          : scheduledTime as String?,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String?,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as String?,
      cancelReason: cancelReason == const $CopyWithPlaceholder()
          ? _value.cancelReason
          // ignore: cast_nullable_to_non_nullable
          : cancelReason as String?,
      completedAt: completedAt == const $CopyWithPlaceholder()
          ? _value.completedAt
          // ignore: cast_nullable_to_non_nullable
          : completedAt as DateTime?,
      activeSessionId: activeSessionId == const $CopyWithPlaceholder()
          ? _value.activeSessionId
          // ignore: cast_nullable_to_non_nullable
          : activeSessionId as int?,
    );
  }
}

extension $WorkoutScheduleResponseCopyWith on WorkoutScheduleResponse {
  /// Returns a callable class that can be used as follows: `instanceOfWorkoutScheduleResponse.copyWith(...)` or like so:`instanceOfWorkoutScheduleResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WorkoutScheduleResponseCWProxy get copyWith =>
      _$WorkoutScheduleResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutScheduleResponse _$WorkoutScheduleResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('WorkoutScheduleResponse', json, ($checkedConvert) {
  final val = WorkoutScheduleResponse(
    id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
    workoutProgramId: $checkedConvert(
      'workoutProgramId',
      (v) => (v as num?)?.toInt(),
    ),
    workoutDayId: $checkedConvert('workoutDayId', (v) => (v as num?)?.toInt()),
    scheduledDate: $checkedConvert(
      'scheduledDate',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    scheduledTime: $checkedConvert('scheduledTime', (v) => v as String?),
    title: $checkedConvert('title', (v) => v as String?),
    status: $checkedConvert('status', (v) => v as String?),
    cancelReason: $checkedConvert('cancelReason', (v) => v as String?),
    completedAt: $checkedConvert(
      'completedAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    activeSessionId: $checkedConvert(
      'activeSessionId',
      (v) => (v as num?)?.toInt(),
    ),
  );
  return val;
});

Map<String, dynamic> _$WorkoutScheduleResponseToJson(
  WorkoutScheduleResponse instance,
) => <String, dynamic>{
  'id': ?instance.id,
  'workoutProgramId': ?instance.workoutProgramId,
  'workoutDayId': ?instance.workoutDayId,
  'scheduledDate': ?instance.scheduledDate?.toIso8601String(),
  'scheduledTime': ?instance.scheduledTime,
  'title': ?instance.title,
  'status': ?instance.status,
  'cancelReason': ?instance.cancelReason,
  'completedAt': ?instance.completedAt?.toIso8601String(),
  'activeSessionId': ?instance.activeSessionId,
};
