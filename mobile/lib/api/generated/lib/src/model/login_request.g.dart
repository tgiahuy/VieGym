// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LoginRequestCWProxy {
  LoginRequest email(String? email);

  LoginRequest password(String? password);

  LoginRequest deviceInfo(String? deviceInfo);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LoginRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LoginRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  LoginRequest call({String? email, String? password, String? deviceInfo});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLoginRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLoginRequest.copyWith.fieldName(...)`
class _$LoginRequestCWProxyImpl implements _$LoginRequestCWProxy {
  const _$LoginRequestCWProxyImpl(this._value);

  final LoginRequest _value;

  @override
  LoginRequest email(String? email) => this(email: email);

  @override
  LoginRequest password(String? password) => this(password: password);

  @override
  LoginRequest deviceInfo(String? deviceInfo) => this(deviceInfo: deviceInfo);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LoginRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LoginRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  LoginRequest call({
    Object? email = const $CopyWithPlaceholder(),
    Object? password = const $CopyWithPlaceholder(),
    Object? deviceInfo = const $CopyWithPlaceholder(),
  }) {
    return LoginRequest(
      email: email == const $CopyWithPlaceholder()
          ? _value.email
          // ignore: cast_nullable_to_non_nullable
          : email as String?,
      password: password == const $CopyWithPlaceholder()
          ? _value.password
          // ignore: cast_nullable_to_non_nullable
          : password as String?,
      deviceInfo: deviceInfo == const $CopyWithPlaceholder()
          ? _value.deviceInfo
          // ignore: cast_nullable_to_non_nullable
          : deviceInfo as String?,
    );
  }
}

extension $LoginRequestCopyWith on LoginRequest {
  /// Returns a callable class that can be used as follows: `instanceOfLoginRequest.copyWith(...)` or like so:`instanceOfLoginRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LoginRequestCWProxy get copyWith => _$LoginRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LoginRequest', json, ($checkedConvert) {
      final val = LoginRequest(
        email: $checkedConvert('email', (v) => v as String?),
        password: $checkedConvert('password', (v) => v as String?),
        deviceInfo: $checkedConvert('deviceInfo', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{
      'email': ?instance.email,
      'password': ?instance.password,
      'deviceInfo': ?instance.deviceInfo,
    };
