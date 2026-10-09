// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_workout_log_detail_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiResponseWorkoutLogDetailDtoCWProxy {
  ApiResponseWorkoutLogDetailDto success(bool? success);

  ApiResponseWorkoutLogDetailDto message(String? message);

  ApiResponseWorkoutLogDetailDto data(WorkoutLogDetailDto? data);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseWorkoutLogDetailDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseWorkoutLogDetailDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseWorkoutLogDetailDto call({
    bool? success,
    String? message,
    WorkoutLogDetailDto? data,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiResponseWorkoutLogDetailDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiResponseWorkoutLogDetailDto.copyWith.fieldName(...)`
class _$ApiResponseWorkoutLogDetailDtoCWProxyImpl
    implements _$ApiResponseWorkoutLogDetailDtoCWProxy {
  const _$ApiResponseWorkoutLogDetailDtoCWProxyImpl(this._value);

  final ApiResponseWorkoutLogDetailDto _value;

  @override
  ApiResponseWorkoutLogDetailDto success(bool? success) =>
      this(success: success);

  @override
  ApiResponseWorkoutLogDetailDto message(String? message) =>
      this(message: message);

  @override
  ApiResponseWorkoutLogDetailDto data(WorkoutLogDetailDto? data) =>
      this(data: data);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseWorkoutLogDetailDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseWorkoutLogDetailDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseWorkoutLogDetailDto call({
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
  }) {
    return ApiResponseWorkoutLogDetailDto(
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
          : data as WorkoutLogDetailDto?,
    );
  }
}

extension $ApiResponseWorkoutLogDetailDtoCopyWith
    on ApiResponseWorkoutLogDetailDto {
  /// Returns a callable class that can be used as follows: `instanceOfApiResponseWorkoutLogDetailDto.copyWith(...)` or like so:`instanceOfApiResponseWorkoutLogDetailDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApiResponseWorkoutLogDetailDtoCWProxy get copyWith =>
      _$ApiResponseWorkoutLogDetailDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponseWorkoutLogDetailDto _$ApiResponseWorkoutLogDetailDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ApiResponseWorkoutLogDetailDto', json, ($checkedConvert) {
  final val = ApiResponseWorkoutLogDetailDto(
    success: $checkedConvert('success', (v) => v as bool?),
    message: $checkedConvert('message', (v) => v as String?),
    data: $checkedConvert(
      'data',
      (v) => v == null
          ? null
          : WorkoutLogDetailDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$ApiResponseWorkoutLogDetailDtoToJson(
  ApiResponseWorkoutLogDetailDto instance,
) => <String, dynamic>{
  'success': ?instance.success,
  'message': ?instance.message,
  'data': ?instance.data?.toJson(),
};
