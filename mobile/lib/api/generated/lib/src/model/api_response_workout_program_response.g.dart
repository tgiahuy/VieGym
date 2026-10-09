// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_workout_program_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiResponseWorkoutProgramResponseCWProxy {
  ApiResponseWorkoutProgramResponse success(bool? success);

  ApiResponseWorkoutProgramResponse message(String? message);

  ApiResponseWorkoutProgramResponse data(WorkoutProgramResponse? data);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseWorkoutProgramResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseWorkoutProgramResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseWorkoutProgramResponse call({
    bool? success,
    String? message,
    WorkoutProgramResponse? data,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiResponseWorkoutProgramResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiResponseWorkoutProgramResponse.copyWith.fieldName(...)`
class _$ApiResponseWorkoutProgramResponseCWProxyImpl
    implements _$ApiResponseWorkoutProgramResponseCWProxy {
  const _$ApiResponseWorkoutProgramResponseCWProxyImpl(this._value);

  final ApiResponseWorkoutProgramResponse _value;

  @override
  ApiResponseWorkoutProgramResponse success(bool? success) =>
      this(success: success);

  @override
  ApiResponseWorkoutProgramResponse message(String? message) =>
      this(message: message);

  @override
  ApiResponseWorkoutProgramResponse data(WorkoutProgramResponse? data) =>
      this(data: data);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseWorkoutProgramResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseWorkoutProgramResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseWorkoutProgramResponse call({
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
  }) {
    return ApiResponseWorkoutProgramResponse(
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
          : data as WorkoutProgramResponse?,
    );
  }
}

extension $ApiResponseWorkoutProgramResponseCopyWith
    on ApiResponseWorkoutProgramResponse {
  /// Returns a callable class that can be used as follows: `instanceOfApiResponseWorkoutProgramResponse.copyWith(...)` or like so:`instanceOfApiResponseWorkoutProgramResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApiResponseWorkoutProgramResponseCWProxy get copyWith =>
      _$ApiResponseWorkoutProgramResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponseWorkoutProgramResponse _$ApiResponseWorkoutProgramResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ApiResponseWorkoutProgramResponse', json, (
  $checkedConvert,
) {
  final val = ApiResponseWorkoutProgramResponse(
    success: $checkedConvert('success', (v) => v as bool?),
    message: $checkedConvert('message', (v) => v as String?),
    data: $checkedConvert(
      'data',
      (v) => v == null
          ? null
          : WorkoutProgramResponse.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$ApiResponseWorkoutProgramResponseToJson(
  ApiResponseWorkoutProgramResponse instance,
) => <String, dynamic>{
  'success': ?instance.success,
  'message': ?instance.message,
  'data': ?instance.data?.toJson(),
};
