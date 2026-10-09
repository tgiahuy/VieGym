// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_schedule_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WorkoutScheduleRequestCWProxy {
  WorkoutScheduleRequest workoutProgramId(int? workoutProgramId);

  WorkoutScheduleRequest workoutDayId(int? workoutDayId);

  WorkoutScheduleRequest scheduledDate(DateTime? scheduledDate);

  WorkoutScheduleRequest scheduledTime(String? scheduledTime);

  WorkoutScheduleRequest title(String? title);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutScheduleRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutScheduleRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutScheduleRequest call({
    int? workoutProgramId,
    int? workoutDayId,
    DateTime? scheduledDate,
    String? scheduledTime,
    String? title,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWorkoutScheduleRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWorkoutScheduleRequest.copyWith.fieldName(...)`
class _$WorkoutScheduleRequestCWProxyImpl
    implements _$WorkoutScheduleRequestCWProxy {
  const _$WorkoutScheduleRequestCWProxyImpl(this._value);

  final WorkoutScheduleRequest _value;

  @override
  WorkoutScheduleRequest workoutProgramId(int? workoutProgramId) =>
      this(workoutProgramId: workoutProgramId);

  @override
  WorkoutScheduleRequest workoutDayId(int? workoutDayId) =>
      this(workoutDayId: workoutDayId);

  @override
  WorkoutScheduleRequest scheduledDate(DateTime? scheduledDate) =>
      this(scheduledDate: scheduledDate);

  @override
  WorkoutScheduleRequest scheduledTime(String? scheduledTime) =>
      this(scheduledTime: scheduledTime);

  @override
  WorkoutScheduleRequest title(String? title) => this(title: title);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutScheduleRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutScheduleRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutScheduleRequest call({
    Object? workoutProgramId = const $CopyWithPlaceholder(),
    Object? workoutDayId = const $CopyWithPlaceholder(),
    Object? scheduledDate = const $CopyWithPlaceholder(),
    Object? scheduledTime = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
  }) {
    return WorkoutScheduleRequest(
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
    );
  }
}

extension $WorkoutScheduleRequestCopyWith on WorkoutScheduleRequest {
  /// Returns a callable class that can be used as follows: `instanceOfWorkoutScheduleRequest.copyWith(...)` or like so:`instanceOfWorkoutScheduleRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WorkoutScheduleRequestCWProxy get copyWith =>
      _$WorkoutScheduleRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutScheduleRequest _$WorkoutScheduleRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('WorkoutScheduleRequest', json, ($checkedConvert) {
  final val = WorkoutScheduleRequest(
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
  );
  return val;
});

Map<String, dynamic> _$WorkoutScheduleRequestToJson(
  WorkoutScheduleRequest instance,
) => <String, dynamic>{
  'workoutProgramId': ?instance.workoutProgramId,
  'workoutDayId': ?instance.workoutDayId,
  'scheduledDate': ?instance.scheduledDate?.toIso8601String(),
  'scheduledTime': ?instance.scheduledTime,
  'title': ?instance.title,
};
