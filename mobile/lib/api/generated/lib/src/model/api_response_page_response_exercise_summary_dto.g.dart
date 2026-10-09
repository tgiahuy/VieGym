// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_page_response_exercise_summary_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiResponsePageResponseExerciseSummaryDtoCWProxy {
  ApiResponsePageResponseExerciseSummaryDto success(bool? success);

  ApiResponsePageResponseExerciseSummaryDto message(String? message);

  ApiResponsePageResponseExerciseSummaryDto data(
    PageResponseExerciseSummaryDto? data,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponsePageResponseExerciseSummaryDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponsePageResponseExerciseSummaryDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponsePageResponseExerciseSummaryDto call({
    bool? success,
    String? message,
    PageResponseExerciseSummaryDto? data,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiResponsePageResponseExerciseSummaryDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiResponsePageResponseExerciseSummaryDto.copyWith.fieldName(...)`
class _$ApiResponsePageResponseExerciseSummaryDtoCWProxyImpl
    implements _$ApiResponsePageResponseExerciseSummaryDtoCWProxy {
  const _$ApiResponsePageResponseExerciseSummaryDtoCWProxyImpl(this._value);

  final ApiResponsePageResponseExerciseSummaryDto _value;

  @override
  ApiResponsePageResponseExerciseSummaryDto success(bool? success) =>
      this(success: success);

  @override
  ApiResponsePageResponseExerciseSummaryDto message(String? message) =>
      this(message: message);

  @override
  ApiResponsePageResponseExerciseSummaryDto data(
    PageResponseExerciseSummaryDto? data,
  ) => this(data: data);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponsePageResponseExerciseSummaryDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponsePageResponseExerciseSummaryDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponsePageResponseExerciseSummaryDto call({
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
  }) {
    return ApiResponsePageResponseExerciseSummaryDto(
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
          : data as PageResponseExerciseSummaryDto?,
    );
  }
}

extension $ApiResponsePageResponseExerciseSummaryDtoCopyWith
    on ApiResponsePageResponseExerciseSummaryDto {
  /// Returns a callable class that can be used as follows: `instanceOfApiResponsePageResponseExerciseSummaryDto.copyWith(...)` or like so:`instanceOfApiResponsePageResponseExerciseSummaryDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApiResponsePageResponseExerciseSummaryDtoCWProxy get copyWith =>
      _$ApiResponsePageResponseExerciseSummaryDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponsePageResponseExerciseSummaryDto
_$ApiResponsePageResponseExerciseSummaryDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ApiResponsePageResponseExerciseSummaryDto', json, (
  $checkedConvert,
) {
  final val = ApiResponsePageResponseExerciseSummaryDto(
    success: $checkedConvert('success', (v) => v as bool?),
    message: $checkedConvert('message', (v) => v as String?),
    data: $checkedConvert(
      'data',
      (v) => v == null
          ? null
          : PageResponseExerciseSummaryDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$ApiResponsePageResponseExerciseSummaryDtoToJson(
  ApiResponsePageResponseExerciseSummaryDto instance,
) => <String, dynamic>{
  'success': ?instance.success,
  'message': ?instance.message,
  'data': ?instance.data?.toJson(),
};
