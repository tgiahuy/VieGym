// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_workout_schedule_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiResponseWorkoutScheduleResponseCWProxy {
  ApiResponseWorkoutScheduleResponse success(bool? success);

  ApiResponseWorkoutScheduleResponse message(String? message);

  ApiResponseWorkoutScheduleResponse data(WorkoutScheduleResponse? data);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseWorkoutScheduleResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseWorkoutScheduleResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseWorkoutScheduleResponse call({
    bool? success,
    String? message,
    WorkoutScheduleResponse? data,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiResponseWorkoutScheduleResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiResponseWorkoutScheduleResponse.copyWith.fieldName(...)`
class _$ApiResponseWorkoutScheduleResponseCWProxyImpl
    implements _$ApiResponseWorkoutScheduleResponseCWProxy {
  const _$ApiResponseWorkoutScheduleResponseCWProxyImpl(this._value);

  final ApiResponseWorkoutScheduleResponse _value;

  @override
  ApiResponseWorkoutScheduleResponse success(bool? success) =>
      this(success: success);

  @override
  ApiResponseWorkoutScheduleResponse message(String? message) =>
      this(message: message);

  @override
  ApiResponseWorkoutScheduleResponse data(WorkoutScheduleResponse? data) =>
      this(data: data);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseWorkoutScheduleResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseWorkoutScheduleResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseWorkoutScheduleResponse call({
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
  }) {
    return ApiResponseWorkoutScheduleResponse(
      success: success == const $CopyWithPlaceholder()
          ? _value.success
          // ignore: cast_nullable_to_non_nullable
          : success as bool?,
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as String?,
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as WorkoutScheduleResponse?,
    );
  }
}

extension $ApiResponseWorkoutScheduleResponseCopyWith
    on ApiResponseWorkoutScheduleResponse {
  /// Returns a callable class that can be used as follows: `instanceOfApiResponseWorkoutScheduleResponse.copyWith(...)` or like so:`instanceOfApiResponseWorkoutScheduleResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApiResponseWorkoutScheduleResponseCWProxy get copyWith =>
      _$ApiResponseWorkoutScheduleResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponseWorkoutScheduleResponse _$ApiResponseWorkoutScheduleResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ApiResponseWorkoutScheduleResponse', json, (
  $checkedConvert,
) {
  final val = ApiResponseWorkoutScheduleResponse(
    success: $checkedConvert('success', (v) => v as bool?),
    message: $checkedConvert('message', (v) => v as String?),
    data: $checkedConvert(
      'data',
      (v) => v == null
          ? null
          : WorkoutScheduleResponse.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$ApiResponseWorkoutScheduleResponseToJson(
  ApiResponseWorkoutScheduleResponse instance,
) => <String, dynamic>{
  'success': ?instance.success,
  'message': ?instance.message,
  'data': ?instance.data?.toJson(),
};
