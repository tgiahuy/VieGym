// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'avatar_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AvatarResponseCWProxy {
  AvatarResponse mediaId(int? mediaId);

  AvatarResponse accessUrl(String? accessUrl);

  AvatarResponse expiresAt(DateTime? expiresAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AvatarResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AvatarResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AvatarResponse call({int? mediaId, String? accessUrl, DateTime? expiresAt});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAvatarResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAvatarResponse.copyWith.fieldName(...)`
class _$AvatarResponseCWProxyImpl implements _$AvatarResponseCWProxy {
  const _$AvatarResponseCWProxyImpl(this._value);

  final AvatarResponse _value;

  @override
  AvatarResponse mediaId(int? mediaId) => this(mediaId: mediaId);

  @override
  AvatarResponse accessUrl(String? accessUrl) => this(accessUrl: accessUrl);

  @override
  AvatarResponse expiresAt(DateTime? expiresAt) => this(expiresAt: expiresAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AvatarResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AvatarResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AvatarResponse call({
    Object? mediaId = const $CopyWithPlaceholder(),
    Object? accessUrl = const $CopyWithPlaceholder(),
    Object? expiresAt = const $CopyWithPlaceholder(),
  }) {
    return AvatarResponse(
      mediaId: mediaId == const $CopyWithPlaceholder()
          ? _value.mediaId
          // ignore: cast_nullable_to_non_nullable
          : mediaId as int?,
      accessUrl: accessUrl == const $CopyWithPlaceholder()
          ? _value.accessUrl
          // ignore: cast_nullable_to_non_nullable
          : accessUrl as String?,
      expiresAt: expiresAt == const $CopyWithPlaceholder()
          ? _value.expiresAt
          // ignore: cast_nullable_to_non_nullable
          : expiresAt as DateTime?,
    );
  }
}

extension $AvatarResponseCopyWith on AvatarResponse {
  /// Returns a callable class that can be used as follows: `instanceOfAvatarResponse.copyWith(...)` or like so:`instanceOfAvatarResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AvatarResponseCWProxy get copyWith => _$AvatarResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AvatarResponse _$AvatarResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AvatarResponse', json, ($checkedConvert) {
      final val = AvatarResponse(
        mediaId: $checkedConvert('mediaId', (v) => (v as num?)?.toInt()),
        accessUrl: $checkedConvert('accessUrl', (v) => v as String?),
        expiresAt: $checkedConvert(
          'expiresAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$AvatarResponseToJson(AvatarResponse instance) =>
    <String, dynamic>{
      'mediaId': ?instance.mediaId,
      'accessUrl': ?instance.accessUrl,
      'expiresAt': ?instance.expiresAt?.toIso8601String(),
    };
