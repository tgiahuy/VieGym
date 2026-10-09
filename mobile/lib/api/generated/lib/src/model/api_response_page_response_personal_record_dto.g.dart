// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_page_response_personal_record_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiResponsePageResponsePersonalRecordDtoCWProxy {
  ApiResponsePageResponsePersonalRecordDto success(bool? success);

  ApiResponsePageResponsePersonalRecordDto message(String? message);

  ApiResponsePageResponsePersonalRecordDto data(
    PageResponsePersonalRecordDto? data,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponsePageResponsePersonalRecordDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponsePageResponsePersonalRecordDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponsePageResponsePersonalRecordDto call({
    bool? success,
    String? message,
    PageResponsePersonalRecordDto? data,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiResponsePageResponsePersonalRecordDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiResponsePageResponsePersonalRecordDto.copyWith.fieldName(...)`
class _$ApiResponsePageResponsePersonalRecordDtoCWProxyImpl
    implements _$ApiResponsePageResponsePersonalRecordDtoCWProxy {
  const _$ApiResponsePageResponsePersonalRecordDtoCWProxyImpl(this._value);

  final ApiResponsePageResponsePersonalRecordDto _value;

  @override
  ApiResponsePageResponsePersonalRecordDto success(bool? success) =>
      this(success: success);

  @override
  ApiResponsePageResponsePersonalRecordDto message(String? message) =>
      this(message: message);

  @override
  ApiResponsePageResponsePersonalRecordDto data(
    PageResponsePersonalRecordDto? data,
  ) => this(data: data);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponsePageResponsePersonalRecordDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponsePageResponsePersonalRecordDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponsePageResponsePersonalRecordDto call({
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
  }) {
    return ApiResponsePageResponsePersonalRecordDto(
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
          : data as PageResponsePersonalRecordDto?,
    );
  }
}

extension $ApiResponsePageResponsePersonalRecordDtoCopyWith
    on ApiResponsePageResponsePersonalRecordDto {
  /// Returns a callable class that can be used as follows: `instanceOfApiResponsePageResponsePersonalRecordDto.copyWith(...)` or like so:`instanceOfApiResponsePageResponsePersonalRecordDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApiResponsePageResponsePersonalRecordDtoCWProxy get copyWith =>
      _$ApiResponsePageResponsePersonalRecordDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponsePageResponsePersonalRecordDto
_$ApiResponsePageResponsePersonalRecordDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ApiResponsePageResponsePersonalRecordDto', json, (
      $checkedConvert,
    ) {
      final val = ApiResponsePageResponsePersonalRecordDto(
        success: $checkedConvert('success', (v) => v as bool?),
        message: $checkedConvert('message', (v) => v as String?),
        data: $checkedConvert(
          'data',
          (v) => v == null
              ? null
              : PageResponsePersonalRecordDto.fromJson(
                  v as Map<String, dynamic>,
                ),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ApiResponsePageResponsePersonalRecordDtoToJson(
  ApiResponsePageResponsePersonalRecordDto instance,
) => <String, dynamic>{
  'success': ?instance.success,
  'message': ?instance.message,
  'data': ?instance.data?.toJson(),
};
