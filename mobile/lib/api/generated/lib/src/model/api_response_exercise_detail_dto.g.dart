// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_exercise_detail_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiResponseExerciseDetailDtoCWProxy {
  ApiResponseExerciseDetailDto success(bool? success);

  ApiResponseExerciseDetailDto message(String? message);

  ApiResponseExerciseDetailDto data(ExerciseDetailDto? data);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseExerciseDetailDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseExerciseDetailDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseExerciseDetailDto call({
    bool? success,
    String? message,
    ExerciseDetailDto? data,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiResponseExerciseDetailDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiResponseExerciseDetailDto.copyWith.fieldName(...)`
class _$ApiResponseExerciseDetailDtoCWProxyImpl
    implements _$ApiResponseExerciseDetailDtoCWProxy {
  const _$ApiResponseExerciseDetailDtoCWProxyImpl(this._value);

  final ApiResponseExerciseDetailDto _value;

  @override
  ApiResponseExerciseDetailDto success(bool? success) => this(success: success);

  @override
  ApiResponseExerciseDetailDto message(String? message) =>
      this(message: message);

  @override
  ApiResponseExerciseDetailDto data(ExerciseDetailDto? data) =>
      this(data: data);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseExerciseDetailDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseExerciseDetailDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseExerciseDetailDto call({
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
  }) {
    return ApiResponseExerciseDetailDto(
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
          : data as ExerciseDetailDto?,
    );
  }
}

extension $ApiResponseExerciseDetailDtoCopyWith
    on ApiResponseExerciseDetailDto {
  /// Returns a callable class that can be used as follows: `instanceOfApiResponseExerciseDetailDto.copyWith(...)` or like so:`instanceOfApiResponseExerciseDetailDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApiResponseExerciseDetailDtoCWProxy get copyWith =>
      _$ApiResponseExerciseDetailDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponseExerciseDetailDto _$ApiResponseExerciseDetailDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ApiResponseExerciseDetailDto', json, ($checkedConvert) {
  final val = ApiResponseExerciseDetailDto(
    success: $checkedConvert('success', (v) => v as bool?),
    message: $checkedConvert('message', (v) => v as String?),
    data: $checkedConvert(
      'data',
      (v) => v == null
          ? null
          : ExerciseDetailDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$ApiResponseExerciseDetailDtoToJson(
  ApiResponseExerciseDetailDto instance,
) => <String, dynamic>{
  'success': ?instance.success,
  'message': ?instance.message,
  'data': ?instance.data?.toJson(),
};
