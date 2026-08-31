// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_health_profile_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiResponseHealthProfileResponseCWProxy {
  ApiResponseHealthProfileResponse success(bool? success);

  ApiResponseHealthProfileResponse message(String? message);

  ApiResponseHealthProfileResponse data(HealthProfileResponse? data);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseHealthProfileResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseHealthProfileResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseHealthProfileResponse call({
    bool? success,
    String? message,
    HealthProfileResponse? data,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiResponseHealthProfileResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiResponseHealthProfileResponse.copyWith.fieldName(...)`
class _$ApiResponseHealthProfileResponseCWProxyImpl
    implements _$ApiResponseHealthProfileResponseCWProxy {
  const _$ApiResponseHealthProfileResponseCWProxyImpl(this._value);

  final ApiResponseHealthProfileResponse _value;

  @override
  ApiResponseHealthProfileResponse success(bool? success) =>
      this(success: success);

  @override
  ApiResponseHealthProfileResponse message(String? message) =>
      this(message: message);

  @override
  ApiResponseHealthProfileResponse data(HealthProfileResponse? data) =>
      this(data: data);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseHealthProfileResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseHealthProfileResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseHealthProfileResponse call({
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
  }) {
    return ApiResponseHealthProfileResponse(
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
          : data as HealthProfileResponse?,
    );
  }
}

extension $ApiResponseHealthProfileResponseCopyWith
    on ApiResponseHealthProfileResponse {
  /// Returns a callable class that can be used as follows: `instanceOfApiResponseHealthProfileResponse.copyWith(...)` or like so:`instanceOfApiResponseHealthProfileResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApiResponseHealthProfileResponseCWProxy get copyWith =>
      _$ApiResponseHealthProfileResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponseHealthProfileResponse _$ApiResponseHealthProfileResponseFromJson(
  Map<String, dynamic> json,
) =>
    $checkedCreate('ApiResponseHealthProfileResponse', json, ($checkedConvert) {
      final val = ApiResponseHealthProfileResponse(
        success: $checkedConvert('success', (v) => v as bool?),
        message: $checkedConvert('message', (v) => v as String?),
        data: $checkedConvert(
          'data',
          (v) => v == null
              ? null
              : HealthProfileResponse.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ApiResponseHealthProfileResponseToJson(
  ApiResponseHealthProfileResponse instance,
) => <String, dynamic>{
  'success': ?instance.success,
  'message': ?instance.message,
  'data': ?instance.data?.toJson(),
};
