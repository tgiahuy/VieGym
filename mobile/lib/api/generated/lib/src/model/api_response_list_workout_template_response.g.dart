// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_list_workout_template_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiResponseListWorkoutTemplateResponseCWProxy {
  ApiResponseListWorkoutTemplateResponse success(bool? success);

  ApiResponseListWorkoutTemplateResponse message(String? message);

  ApiResponseListWorkoutTemplateResponse data(
    List<WorkoutTemplateResponse>? data,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseListWorkoutTemplateResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseListWorkoutTemplateResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseListWorkoutTemplateResponse call({
    bool? success,
    String? message,
    List<WorkoutTemplateResponse>? data,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiResponseListWorkoutTemplateResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiResponseListWorkoutTemplateResponse.copyWith.fieldName(...)`
class _$ApiResponseListWorkoutTemplateResponseCWProxyImpl
    implements _$ApiResponseListWorkoutTemplateResponseCWProxy {
  const _$ApiResponseListWorkoutTemplateResponseCWProxyImpl(this._value);

  final ApiResponseListWorkoutTemplateResponse _value;

  @override
  ApiResponseListWorkoutTemplateResponse success(bool? success) =>
      this(success: success);

  @override
  ApiResponseListWorkoutTemplateResponse message(String? message) =>
      this(message: message);

  @override
  ApiResponseListWorkoutTemplateResponse data(
    List<WorkoutTemplateResponse>? data,
  ) => this(data: data);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseListWorkoutTemplateResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseListWorkoutTemplateResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseListWorkoutTemplateResponse call({
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
  }) {
    return ApiResponseListWorkoutTemplateResponse(
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
          : data as List<WorkoutTemplateResponse>?,
    );
  }
}

extension $ApiResponseListWorkoutTemplateResponseCopyWith
    on ApiResponseListWorkoutTemplateResponse {
  /// Returns a callable class that can be used as follows: `instanceOfApiResponseListWorkoutTemplateResponse.copyWith(...)` or like so:`instanceOfApiResponseListWorkoutTemplateResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApiResponseListWorkoutTemplateResponseCWProxy get copyWith =>
      _$ApiResponseListWorkoutTemplateResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponseListWorkoutTemplateResponse
_$ApiResponseListWorkoutTemplateResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ApiResponseListWorkoutTemplateResponse', json, (
      $checkedConvert,
    ) {
      final val = ApiResponseListWorkoutTemplateResponse(
        success: $checkedConvert('success', (v) => v as bool?),
        message: $checkedConvert('message', (v) => v as String?),
        data: $checkedConvert(
          'data',
          (v) => (v as List<dynamic>?)
              ?.map(
                (e) =>
                    WorkoutTemplateResponse.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ApiResponseListWorkoutTemplateResponseToJson(
  ApiResponseListWorkoutTemplateResponse instance,
) => <String, dynamic>{
  'success': ?instance.success,
  'message': ?instance.message,
  'data': ?instance.data?.map((e) => e.toJson()).toList(),
};
