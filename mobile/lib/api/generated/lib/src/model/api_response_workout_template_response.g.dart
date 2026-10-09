// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_workout_template_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiResponseWorkoutTemplateResponseCWProxy {
  ApiResponseWorkoutTemplateResponse success(bool? success);

  ApiResponseWorkoutTemplateResponse message(String? message);

  ApiResponseWorkoutTemplateResponse data(WorkoutTemplateResponse? data);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseWorkoutTemplateResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseWorkoutTemplateResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseWorkoutTemplateResponse call({
    bool? success,
    String? message,
    WorkoutTemplateResponse? data,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiResponseWorkoutTemplateResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiResponseWorkoutTemplateResponse.copyWith.fieldName(...)`
class _$ApiResponseWorkoutTemplateResponseCWProxyImpl
    implements _$ApiResponseWorkoutTemplateResponseCWProxy {
  const _$ApiResponseWorkoutTemplateResponseCWProxyImpl(this._value);

  final ApiResponseWorkoutTemplateResponse _value;

  @override
  ApiResponseWorkoutTemplateResponse success(bool? success) =>
      this(success: success);

  @override
  ApiResponseWorkoutTemplateResponse message(String? message) =>
      this(message: message);

  @override
  ApiResponseWorkoutTemplateResponse data(WorkoutTemplateResponse? data) =>
      this(data: data);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseWorkoutTemplateResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseWorkoutTemplateResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseWorkoutTemplateResponse call({
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
  }) {
    return ApiResponseWorkoutTemplateResponse(
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
          : data as WorkoutTemplateResponse?,
    );
  }
}

extension $ApiResponseWorkoutTemplateResponseCopyWith
    on ApiResponseWorkoutTemplateResponse {
  /// Returns a callable class that can be used as follows: `instanceOfApiResponseWorkoutTemplateResponse.copyWith(...)` or like so:`instanceOfApiResponseWorkoutTemplateResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApiResponseWorkoutTemplateResponseCWProxy get copyWith =>
      _$ApiResponseWorkoutTemplateResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponseWorkoutTemplateResponse _$ApiResponseWorkoutTemplateResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ApiResponseWorkoutTemplateResponse', json, (
  $checkedConvert,
) {
  final val = ApiResponseWorkoutTemplateResponse(
    success: $checkedConvert('success', (v) => v as bool?),
    message: $checkedConvert('message', (v) => v as String?),
    data: $checkedConvert(
      'data',
      (v) => v == null
          ? null
          : WorkoutTemplateResponse.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$ApiResponseWorkoutTemplateResponseToJson(
  ApiResponseWorkoutTemplateResponse instance,
) => <String, dynamic>{
  'success': ?instance.success,
  'message': ?instance.message,
  'data': ?instance.data?.toJson(),
};
