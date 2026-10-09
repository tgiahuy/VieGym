// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_page_response_workout_log_summary_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiResponsePageResponseWorkoutLogSummaryDtoCWProxy {
  ApiResponsePageResponseWorkoutLogSummaryDto success(bool? success);

  ApiResponsePageResponseWorkoutLogSummaryDto message(String? message);

  ApiResponsePageResponseWorkoutLogSummaryDto data(
    PageResponseWorkoutLogSummaryDto? data,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponsePageResponseWorkoutLogSummaryDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponsePageResponseWorkoutLogSummaryDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponsePageResponseWorkoutLogSummaryDto call({
    bool? success,
    String? message,
    PageResponseWorkoutLogSummaryDto? data,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiResponsePageResponseWorkoutLogSummaryDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiResponsePageResponseWorkoutLogSummaryDto.copyWith.fieldName(...)`
class _$ApiResponsePageResponseWorkoutLogSummaryDtoCWProxyImpl
    implements _$ApiResponsePageResponseWorkoutLogSummaryDtoCWProxy {
  const _$ApiResponsePageResponseWorkoutLogSummaryDtoCWProxyImpl(this._value);

  final ApiResponsePageResponseWorkoutLogSummaryDto _value;

  @override
  ApiResponsePageResponseWorkoutLogSummaryDto success(bool? success) =>
      this(success: success);

  @override
  ApiResponsePageResponseWorkoutLogSummaryDto message(String? message) =>
      this(message: message);

  @override
  ApiResponsePageResponseWorkoutLogSummaryDto data(
    PageResponseWorkoutLogSummaryDto? data,
  ) => this(data: data);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponsePageResponseWorkoutLogSummaryDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponsePageResponseWorkoutLogSummaryDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponsePageResponseWorkoutLogSummaryDto call({
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
  }) {
    return ApiResponsePageResponseWorkoutLogSummaryDto(
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
          : data as PageResponseWorkoutLogSummaryDto?,
    );
  }
}

extension $ApiResponsePageResponseWorkoutLogSummaryDtoCopyWith
    on ApiResponsePageResponseWorkoutLogSummaryDto {
  /// Returns a callable class that can be used as follows: `instanceOfApiResponsePageResponseWorkoutLogSummaryDto.copyWith(...)` or like so:`instanceOfApiResponsePageResponseWorkoutLogSummaryDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApiResponsePageResponseWorkoutLogSummaryDtoCWProxy get copyWith =>
      _$ApiResponsePageResponseWorkoutLogSummaryDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponsePageResponseWorkoutLogSummaryDto
_$ApiResponsePageResponseWorkoutLogSummaryDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ApiResponsePageResponseWorkoutLogSummaryDto', json, (
  $checkedConvert,
) {
  final val = ApiResponsePageResponseWorkoutLogSummaryDto(
    success: $checkedConvert('success', (v) => v as bool?),
    message: $checkedConvert('message', (v) => v as String?),
    data: $checkedConvert(
      'data',
      (v) => v == null
          ? null
          : PageResponseWorkoutLogSummaryDto.fromJson(
              v as Map<String, dynamic>,
            ),
    ),
  );
  return val;
});

Map<String, dynamic> _$ApiResponsePageResponseWorkoutLogSummaryDtoToJson(
  ApiResponsePageResponseWorkoutLogSummaryDto instance,
) => <String, dynamic>{
  'success': ?instance.success,
  'message': ?instance.message,
  'data': ?instance.data?.toJson(),
};
