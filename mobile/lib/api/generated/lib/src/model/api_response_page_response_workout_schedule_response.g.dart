// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_page_response_workout_schedule_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiResponsePageResponseWorkoutScheduleResponseCWProxy {
  ApiResponsePageResponseWorkoutScheduleResponse success(bool? success);

  ApiResponsePageResponseWorkoutScheduleResponse message(String? message);

  ApiResponsePageResponseWorkoutScheduleResponse data(
    PageResponseWorkoutScheduleResponse? data,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponsePageResponseWorkoutScheduleResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponsePageResponseWorkoutScheduleResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponsePageResponseWorkoutScheduleResponse call({
    bool? success,
    String? message,
    PageResponseWorkoutScheduleResponse? data,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiResponsePageResponseWorkoutScheduleResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiResponsePageResponseWorkoutScheduleResponse.copyWith.fieldName(...)`
class _$ApiResponsePageResponseWorkoutScheduleResponseCWProxyImpl
    implements _$ApiResponsePageResponseWorkoutScheduleResponseCWProxy {
  const _$ApiResponsePageResponseWorkoutScheduleResponseCWProxyImpl(
    this._value,
  );

  final ApiResponsePageResponseWorkoutScheduleResponse _value;

  @override
  ApiResponsePageResponseWorkoutScheduleResponse success(bool? success) =>
      this(success: success);

  @override
  ApiResponsePageResponseWorkoutScheduleResponse message(String? message) =>
      this(message: message);

  @override
  ApiResponsePageResponseWorkoutScheduleResponse data(
    PageResponseWorkoutScheduleResponse? data,
  ) => this(data: data);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponsePageResponseWorkoutScheduleResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponsePageResponseWorkoutScheduleResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponsePageResponseWorkoutScheduleResponse call({
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
  }) {
    return ApiResponsePageResponseWorkoutScheduleResponse(
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
          : data as PageResponseWorkoutScheduleResponse?,
    );
  }
}

extension $ApiResponsePageResponseWorkoutScheduleResponseCopyWith
    on ApiResponsePageResponseWorkoutScheduleResponse {
  /// Returns a callable class that can be used as follows: `instanceOfApiResponsePageResponseWorkoutScheduleResponse.copyWith(...)` or like so:`instanceOfApiResponsePageResponseWorkoutScheduleResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApiResponsePageResponseWorkoutScheduleResponseCWProxy get copyWith =>
      _$ApiResponsePageResponseWorkoutScheduleResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponsePageResponseWorkoutScheduleResponse
_$ApiResponsePageResponseWorkoutScheduleResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ApiResponsePageResponseWorkoutScheduleResponse', json, (
  $checkedConvert,
) {
  final val = ApiResponsePageResponseWorkoutScheduleResponse(
    success: $checkedConvert('success', (v) => v as bool?),
    message: $checkedConvert('message', (v) => v as String?),
    data: $checkedConvert(
      'data',
      (v) => v == null
          ? null
          : PageResponseWorkoutScheduleResponse.fromJson(
              v as Map<String, dynamic>,
            ),
    ),
  );
  return val;
});

Map<String, dynamic> _$ApiResponsePageResponseWorkoutScheduleResponseToJson(
  ApiResponsePageResponseWorkoutScheduleResponse instance,
) => <String, dynamic>{
  'success': ?instance.success,
  'message': ?instance.message,
  'data': ?instance.data?.toJson(),
};
