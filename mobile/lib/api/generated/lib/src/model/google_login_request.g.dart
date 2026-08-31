// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'google_login_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GoogleLoginRequestCWProxy {
  GoogleLoginRequest idToken(String? idToken);

  GoogleLoginRequest deviceInfo(String? deviceInfo);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GoogleLoginRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GoogleLoginRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  GoogleLoginRequest call({String? idToken, String? deviceInfo});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGoogleLoginRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGoogleLoginRequest.copyWith.fieldName(...)`
class _$GoogleLoginRequestCWProxyImpl implements _$GoogleLoginRequestCWProxy {
  const _$GoogleLoginRequestCWProxyImpl(this._value);

  final GoogleLoginRequest _value;

  @override
  GoogleLoginRequest idToken(String? idToken) => this(idToken: idToken);

  @override
  GoogleLoginRequest deviceInfo(String? deviceInfo) =>
      this(deviceInfo: deviceInfo);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GoogleLoginRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GoogleLoginRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  GoogleLoginRequest call({
    Object? idToken = const $CopyWithPlaceholder(),
    Object? deviceInfo = const $CopyWithPlaceholder(),
  }) {
    return GoogleLoginRequest(
      idToken: idToken == const $CopyWithPlaceholder()
          ? _value.idToken
          // ignore: cast_nullable_to_non_nullable
          : idToken as String?,
      deviceInfo: deviceInfo == const $CopyWithPlaceholder()
          ? _value.deviceInfo
          // ignore: cast_nullable_to_non_nullable
          : deviceInfo as String?,
    );
  }
}

extension $GoogleLoginRequestCopyWith on GoogleLoginRequest {
  /// Returns a callable class that can be used as follows: `instanceOfGoogleLoginRequest.copyWith(...)` or like so:`instanceOfGoogleLoginRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GoogleLoginRequestCWProxy get copyWith =>
      _$GoogleLoginRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoogleLoginRequest _$GoogleLoginRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('GoogleLoginRequest', json, ($checkedConvert) {
      final val = GoogleLoginRequest(
        idToken: $checkedConvert('idToken', (v) => v as String?),
        deviceInfo: $checkedConvert('deviceInfo', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$GoogleLoginRequestToJson(GoogleLoginRequest instance) =>
    <String, dynamic>{
      'idToken': ?instance.idToken,
      'deviceInfo': ?instance.deviceInfo,
    };
