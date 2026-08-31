// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SessionResponseCWProxy {
  SessionResponse accessToken(String? accessToken);

  SessionResponse refreshToken(String? refreshToken);

  SessionResponse tokenType(String? tokenType);

  SessionResponse expiresIn(int? expiresIn);

  SessionResponse resetProof(String? resetProof);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SessionResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SessionResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  SessionResponse call({
    String? accessToken,
    String? refreshToken,
    String? tokenType,
    int? expiresIn,
    String? resetProof,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSessionResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSessionResponse.copyWith.fieldName(...)`
class _$SessionResponseCWProxyImpl implements _$SessionResponseCWProxy {
  const _$SessionResponseCWProxyImpl(this._value);

  final SessionResponse _value;

  @override
  SessionResponse accessToken(String? accessToken) =>
      this(accessToken: accessToken);

  @override
  SessionResponse refreshToken(String? refreshToken) =>
      this(refreshToken: refreshToken);

  @override
  SessionResponse tokenType(String? tokenType) => this(tokenType: tokenType);

  @override
  SessionResponse expiresIn(int? expiresIn) => this(expiresIn: expiresIn);

  @override
  SessionResponse resetProof(String? resetProof) =>
      this(resetProof: resetProof);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SessionResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SessionResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  SessionResponse call({
    Object? accessToken = const $CopyWithPlaceholder(),
    Object? refreshToken = const $CopyWithPlaceholder(),
    Object? tokenType = const $CopyWithPlaceholder(),
    Object? expiresIn = const $CopyWithPlaceholder(),
    Object? resetProof = const $CopyWithPlaceholder(),
  }) {
    return SessionResponse(
      accessToken: accessToken == const $CopyWithPlaceholder()
          ? _value.accessToken
          // ignore: cast_nullable_to_non_nullable
          : accessToken as String?,
      refreshToken: refreshToken == const $CopyWithPlaceholder()
          ? _value.refreshToken
          // ignore: cast_nullable_to_non_nullable
          : refreshToken as String?,
      tokenType: tokenType == const $CopyWithPlaceholder()
          ? _value.tokenType
          // ignore: cast_nullable_to_non_nullable
          : tokenType as String?,
      expiresIn: expiresIn == const $CopyWithPlaceholder()
          ? _value.expiresIn
          // ignore: cast_nullable_to_non_nullable
          : expiresIn as int?,
      resetProof: resetProof == const $CopyWithPlaceholder()
          ? _value.resetProof
          // ignore: cast_nullable_to_non_nullable
          : resetProof as String?,
    );
  }
}

extension $SessionResponseCopyWith on SessionResponse {
  /// Returns a callable class that can be used as follows: `instanceOfSessionResponse.copyWith(...)` or like so:`instanceOfSessionResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SessionResponseCWProxy get copyWith => _$SessionResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionResponse _$SessionResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SessionResponse', json, ($checkedConvert) {
      final val = SessionResponse(
        accessToken: $checkedConvert('accessToken', (v) => v as String?),
        refreshToken: $checkedConvert('refreshToken', (v) => v as String?),
        tokenType: $checkedConvert('tokenType', (v) => v as String?),
        expiresIn: $checkedConvert('expiresIn', (v) => (v as num?)?.toInt()),
        resetProof: $checkedConvert('resetProof', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$SessionResponseToJson(SessionResponse instance) =>
    <String, dynamic>{
      'accessToken': ?instance.accessToken,
      'refreshToken': ?instance.refreshToken,
      'tokenType': ?instance.tokenType,
      'expiresIn': ?instance.expiresIn,
      'resetProof': ?instance.resetProof,
    };
