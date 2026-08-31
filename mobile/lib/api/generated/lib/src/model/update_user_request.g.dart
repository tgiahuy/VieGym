// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_user_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UpdateUserRequestCWProxy {
  UpdateUserRequest displayName(String? displayName);

  UpdateUserRequest avatarMediaId(int? avatarMediaId);

  UpdateUserRequest timezone(String? timezone);

  UpdateUserRequest locale(String? locale);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpdateUserRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpdateUserRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UpdateUserRequest call({
    String? displayName,
    int? avatarMediaId,
    String? timezone,
    String? locale,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUpdateUserRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUpdateUserRequest.copyWith.fieldName(...)`
class _$UpdateUserRequestCWProxyImpl implements _$UpdateUserRequestCWProxy {
  const _$UpdateUserRequestCWProxyImpl(this._value);

  final UpdateUserRequest _value;

  @override
  UpdateUserRequest displayName(String? displayName) =>
      this(displayName: displayName);

  @override
  UpdateUserRequest avatarMediaId(int? avatarMediaId) =>
      this(avatarMediaId: avatarMediaId);

  @override
  UpdateUserRequest timezone(String? timezone) => this(timezone: timezone);

  @override
  UpdateUserRequest locale(String? locale) => this(locale: locale);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpdateUserRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpdateUserRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UpdateUserRequest call({
    Object? displayName = const $CopyWithPlaceholder(),
    Object? avatarMediaId = const $CopyWithPlaceholder(),
    Object? timezone = const $CopyWithPlaceholder(),
    Object? locale = const $CopyWithPlaceholder(),
  }) {
    return UpdateUserRequest(
      displayName: displayName == const $CopyWithPlaceholder()
          ? _value.displayName
          // ignore: cast_nullable_to_non_nullable
          : displayName as String?,
      avatarMediaId: avatarMediaId == const $CopyWithPlaceholder()
          ? _value.avatarMediaId
          // ignore: cast_nullable_to_non_nullable
          : avatarMediaId as int?,
      timezone: timezone == const $CopyWithPlaceholder()
          ? _value.timezone
          // ignore: cast_nullable_to_non_nullable
          : timezone as String?,
      locale: locale == const $CopyWithPlaceholder()
          ? _value.locale
          // ignore: cast_nullable_to_non_nullable
          : locale as String?,
    );
  }
}

extension $UpdateUserRequestCopyWith on UpdateUserRequest {
  /// Returns a callable class that can be used as follows: `instanceOfUpdateUserRequest.copyWith(...)` or like so:`instanceOfUpdateUserRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UpdateUserRequestCWProxy get copyWith =>
      _$UpdateUserRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateUserRequest _$UpdateUserRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('UpdateUserRequest', json, ($checkedConvert) {
      final val = UpdateUserRequest(
        displayName: $checkedConvert('displayName', (v) => v as String?),
        avatarMediaId: $checkedConvert(
          'avatarMediaId',
          (v) => (v as num?)?.toInt(),
        ),
        timezone: $checkedConvert('timezone', (v) => v as String?),
        locale: $checkedConvert('locale', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$UpdateUserRequestToJson(UpdateUserRequest instance) =>
    <String, dynamic>{
      'displayName': ?instance.displayName,
      'avatarMediaId': ?instance.avatarMediaId,
      'timezone': ?instance.timezone,
      'locale': ?instance.locale,
    };
