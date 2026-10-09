// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_page_response_weight_log_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiResponsePageResponseWeightLogDtoCWProxy {
  ApiResponsePageResponseWeightLogDto success(bool? success);

  ApiResponsePageResponseWeightLogDto message(String? message);

  ApiResponsePageResponseWeightLogDto data(PageResponseWeightLogDto? data);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponsePageResponseWeightLogDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponsePageResponseWeightLogDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponsePageResponseWeightLogDto call({
    bool? success,
    String? message,
    PageResponseWeightLogDto? data,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiResponsePageResponseWeightLogDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiResponsePageResponseWeightLogDto.copyWith.fieldName(...)`
class _$ApiResponsePageResponseWeightLogDtoCWProxyImpl
    implements _$ApiResponsePageResponseWeightLogDtoCWProxy {
  const _$ApiResponsePageResponseWeightLogDtoCWProxyImpl(this._value);

  final ApiResponsePageResponseWeightLogDto _value;

  @override
  ApiResponsePageResponseWeightLogDto success(bool? success) =>
      this(success: success);

  @override
  ApiResponsePageResponseWeightLogDto message(String? message) =>
      this(message: message);

  @override
  ApiResponsePageResponseWeightLogDto data(PageResponseWeightLogDto? data) =>
      this(data: data);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponsePageResponseWeightLogDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponsePageResponseWeightLogDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponsePageResponseWeightLogDto call({
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
  }) {
    return ApiResponsePageResponseWeightLogDto(
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
          : data as PageResponseWeightLogDto?,
    );
  }
}

extension $ApiResponsePageResponseWeightLogDtoCopyWith
    on ApiResponsePageResponseWeightLogDto {
  /// Returns a callable class that can be used as follows: `instanceOfApiResponsePageResponseWeightLogDto.copyWith(...)` or like so:`instanceOfApiResponsePageResponseWeightLogDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApiResponsePageResponseWeightLogDtoCWProxy get copyWith =>
      _$ApiResponsePageResponseWeightLogDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponsePageResponseWeightLogDto
_$ApiResponsePageResponseWeightLogDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ApiResponsePageResponseWeightLogDto', json, (
      $checkedConvert,
    ) {
      final val = ApiResponsePageResponseWeightLogDto(
        success: $checkedConvert('success', (v) => v as bool?),
        message: $checkedConvert('message', (v) => v as String?),
        data: $checkedConvert(
          'data',
          (v) => v == null
              ? null
              : PageResponseWeightLogDto.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ApiResponsePageResponseWeightLogDtoToJson(
  ApiResponsePageResponseWeightLogDto instance,
) => <String, dynamic>{
  'success': ?instance.success,
  'message': ?instance.message,
  'data': ?instance.data?.toJson(),
};
