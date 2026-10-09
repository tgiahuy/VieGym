// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_list_exercise_summary_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiResponseListExerciseSummaryDtoCWProxy {
  ApiResponseListExerciseSummaryDto success(bool? success);

  ApiResponseListExerciseSummaryDto message(String? message);

  ApiResponseListExerciseSummaryDto data(List<ExerciseSummaryDto>? data);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseListExerciseSummaryDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseListExerciseSummaryDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseListExerciseSummaryDto call({
    bool? success,
    String? message,
    List<ExerciseSummaryDto>? data,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiResponseListExerciseSummaryDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiResponseListExerciseSummaryDto.copyWith.fieldName(...)`
class _$ApiResponseListExerciseSummaryDtoCWProxyImpl
    implements _$ApiResponseListExerciseSummaryDtoCWProxy {
  const _$ApiResponseListExerciseSummaryDtoCWProxyImpl(this._value);

  final ApiResponseListExerciseSummaryDto _value;

  @override
  ApiResponseListExerciseSummaryDto success(bool? success) =>
      this(success: success);

  @override
  ApiResponseListExerciseSummaryDto message(String? message) =>
      this(message: message);

  @override
  ApiResponseListExerciseSummaryDto data(List<ExerciseSummaryDto>? data) =>
      this(data: data);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseListExerciseSummaryDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseListExerciseSummaryDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseListExerciseSummaryDto call({
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
  }) {
    return ApiResponseListExerciseSummaryDto(
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
          : data as List<ExerciseSummaryDto>?,
    );
  }
}

extension $ApiResponseListExerciseSummaryDtoCopyWith
    on ApiResponseListExerciseSummaryDto {
  /// Returns a callable class that can be used as follows: `instanceOfApiResponseListExerciseSummaryDto.copyWith(...)` or like so:`instanceOfApiResponseListExerciseSummaryDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApiResponseListExerciseSummaryDtoCWProxy get copyWith =>
      _$ApiResponseListExerciseSummaryDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponseListExerciseSummaryDto _$ApiResponseListExerciseSummaryDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ApiResponseListExerciseSummaryDto', json, (
  $checkedConvert,
) {
  final val = ApiResponseListExerciseSummaryDto(
    success: $checkedConvert('success', (v) => v as bool?),
    message: $checkedConvert('message', (v) => v as String?),
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>?)
          ?.map((e) => ExerciseSummaryDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$ApiResponseListExerciseSummaryDtoToJson(
  ApiResponseListExerciseSummaryDto instance,
) => <String, dynamic>{
  'success': ?instance.success,
  'message': ?instance.message,
  'data': ?instance.data?.map((e) => e.toJson()).toList(),
};
