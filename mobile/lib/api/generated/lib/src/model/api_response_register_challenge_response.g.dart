// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_register_challenge_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiResponseRegisterChallengeResponseCWProxy {
  ApiResponseRegisterChallengeResponse success(bool? success);

  ApiResponseRegisterChallengeResponse message(String? message);

  ApiResponseRegisterChallengeResponse data(RegisterChallengeResponse? data);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseRegisterChallengeResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseRegisterChallengeResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseRegisterChallengeResponse call({
    bool? success,
    String? message,
    RegisterChallengeResponse? data,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiResponseRegisterChallengeResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiResponseRegisterChallengeResponse.copyWith.fieldName(...)`
class _$ApiResponseRegisterChallengeResponseCWProxyImpl
    implements _$ApiResponseRegisterChallengeResponseCWProxy {
  const _$ApiResponseRegisterChallengeResponseCWProxyImpl(this._value);

  final ApiResponseRegisterChallengeResponse _value;

  @override
  ApiResponseRegisterChallengeResponse success(bool? success) =>
      this(success: success);

  @override
  ApiResponseRegisterChallengeResponse message(String? message) =>
      this(message: message);

  @override
  ApiResponseRegisterChallengeResponse data(RegisterChallengeResponse? data) =>
      this(data: data);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseRegisterChallengeResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseRegisterChallengeResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseRegisterChallengeResponse call({
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
  }) {
    return ApiResponseRegisterChallengeResponse(
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
          : data as RegisterChallengeResponse?,
    );
  }
}

extension $ApiResponseRegisterChallengeResponseCopyWith
    on ApiResponseRegisterChallengeResponse {
  /// Returns a callable class that can be used as follows: `instanceOfApiResponseRegisterChallengeResponse.copyWith(...)` or like so:`instanceOfApiResponseRegisterChallengeResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApiResponseRegisterChallengeResponseCWProxy get copyWith =>
      _$ApiResponseRegisterChallengeResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponseRegisterChallengeResponse
_$ApiResponseRegisterChallengeResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ApiResponseRegisterChallengeResponse', json, (
      $checkedConvert,
    ) {
      final val = ApiResponseRegisterChallengeResponse(
        success: $checkedConvert('success', (v) => v as bool?),
        message: $checkedConvert('message', (v) => v as String?),
        data: $checkedConvert(
          'data',
          (v) => v == null
              ? null
              : RegisterChallengeResponse.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ApiResponseRegisterChallengeResponseToJson(
  ApiResponseRegisterChallengeResponse instance,
) => <String, dynamic>{
  'success': ?instance.success,
  'message': ?instance.message,
  'data': ?instance.data?.toJson(),
};
