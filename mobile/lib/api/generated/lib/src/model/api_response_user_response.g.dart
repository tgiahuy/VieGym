// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_user_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiResponseUserResponseCWProxy {
  ApiResponseUserResponse success(bool? success);

  ApiResponseUserResponse message(String? message);

  ApiResponseUserResponse data(UserResponse? data);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseUserResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseUserResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseUserResponse call({
    bool? success,
    String? message,
    UserResponse? data,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiResponseUserResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiResponseUserResponse.copyWith.fieldName(...)`
class _$ApiResponseUserResponseCWProxyImpl
    implements _$ApiResponseUserResponseCWProxy {
  const _$ApiResponseUserResponseCWProxyImpl(this._value);

  final ApiResponseUserResponse _value;

  @override
  ApiResponseUserResponse success(bool? success) => this(success: success);

  @override
  ApiResponseUserResponse message(String? message) => this(message: message);

  @override
  ApiResponseUserResponse data(UserResponse? data) => this(data: data);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseUserResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseUserResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseUserResponse call({
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
  }) {
    return ApiResponseUserResponse(
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
          : data as UserResponse?,
    );
  }
}

extension $ApiResponseUserResponseCopyWith on ApiResponseUserResponse {
  /// Returns a callable class that can be used as follows: `instanceOfApiResponseUserResponse.copyWith(...)` or like so:`instanceOfApiResponseUserResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApiResponseUserResponseCWProxy get copyWith =>
      _$ApiResponseUserResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponseUserResponse _$ApiResponseUserResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ApiResponseUserResponse', json, ($checkedConvert) {
  final val = ApiResponseUserResponse(
    success: $checkedConvert('success', (v) => v as bool?),
    message: $checkedConvert('message', (v) => v as String?),
    data: $checkedConvert(
      'data',
      (v) =>
          v == null ? null : UserResponse.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$ApiResponseUserResponseToJson(
  ApiResponseUserResponse instance,
) => <String, dynamic>{
  'success': ?instance.success,
  'message': ?instance.message,
  'data': ?instance.data?.toJson(),
};
