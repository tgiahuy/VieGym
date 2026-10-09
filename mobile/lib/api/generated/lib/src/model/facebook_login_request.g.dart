// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'facebook_login_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$FacebookLoginRequestCWProxy {
  FacebookLoginRequest accessToken(String? accessToken);

  FacebookLoginRequest deviceInfo(String? deviceInfo);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FacebookLoginRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FacebookLoginRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  FacebookLoginRequest call({String? accessToken, String? deviceInfo});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfFacebookLoginRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfFacebookLoginRequest.copyWith.fieldName(...)`
class _$FacebookLoginRequestCWProxyImpl
    implements _$FacebookLoginRequestCWProxy {
  const _$FacebookLoginRequestCWProxyImpl(this._value);

  final FacebookLoginRequest _value;

  @override
  FacebookLoginRequest accessToken(String? accessToken) =>
      this(accessToken: accessToken);

  @override
  FacebookLoginRequest deviceInfo(String? deviceInfo) =>
      this(deviceInfo: deviceInfo);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FacebookLoginRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FacebookLoginRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  FacebookLoginRequest call({
    Object? accessToken = const $CopyWithPlaceholder(),
    Object? deviceInfo = const $CopyWithPlaceholder(),
  }) {
    return FacebookLoginRequest(
      accessToken: accessToken == const $CopyWithPlaceholder()
          ? _value.accessToken
          // ignore: cast_nullable_to_non_nullable
          : accessToken as String?,
      deviceInfo: deviceInfo == const $CopyWithPlaceholder()
          ? _value.deviceInfo
          // ignore: cast_nullable_to_non_nullable
          : deviceInfo as String?,
    );
  }
}

extension $FacebookLoginRequestCopyWith on FacebookLoginRequest {
  /// Returns a callable class that can be used as follows: `instanceOfFacebookLoginRequest.copyWith(...)` or like so:`instanceOfFacebookLoginRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$FacebookLoginRequestCWProxy get copyWith =>
      _$FacebookLoginRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FacebookLoginRequest _$FacebookLoginRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('FacebookLoginRequest', json, ($checkedConvert) {
  final val = FacebookLoginRequest(
    accessToken: $checkedConvert('accessToken', (v) => v as String?),
    deviceInfo: $checkedConvert('deviceInfo', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$FacebookLoginRequestToJson(
  FacebookLoginRequest instance,
) => <String, dynamic>{
  'accessToken': ?instance.accessToken,
  'deviceInfo': ?instance.deviceInfo,
};
