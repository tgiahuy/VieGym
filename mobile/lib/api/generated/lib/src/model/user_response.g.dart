// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UserResponseCWProxy {
  UserResponse id(int? id);

  UserResponse email(String? email);

  UserResponse displayName(String? displayName);

  UserResponse avatar(AvatarResponse? avatar);

  UserResponse timezone(String? timezone);

  UserResponse locale(String? locale);

  UserResponse role(String? role);

  UserResponse authProvider(String? authProvider);

  UserResponse onboarding(OnboardingResponse? onboarding);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UserResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UserResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  UserResponse call({
    int? id,
    String? email,
    String? displayName,
    AvatarResponse? avatar,
    String? timezone,
    String? locale,
    String? role,
    String? authProvider,
    OnboardingResponse? onboarding,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUserResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUserResponse.copyWith.fieldName(...)`
class _$UserResponseCWProxyImpl implements _$UserResponseCWProxy {
  const _$UserResponseCWProxyImpl(this._value);

  final UserResponse _value;

  @override
  UserResponse id(int? id) => this(id: id);

  @override
  UserResponse email(String? email) => this(email: email);

  @override
  UserResponse displayName(String? displayName) =>
      this(displayName: displayName);

  @override
  UserResponse avatar(AvatarResponse? avatar) => this(avatar: avatar);

  @override
  UserResponse timezone(String? timezone) => this(timezone: timezone);

  @override
  UserResponse locale(String? locale) => this(locale: locale);

  @override
  UserResponse role(String? role) => this(role: role);

  @override
  UserResponse authProvider(String? authProvider) =>
      this(authProvider: authProvider);

  @override
  UserResponse onboarding(OnboardingResponse? onboarding) =>
      this(onboarding: onboarding);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UserResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UserResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  UserResponse call({
    Object? id = const $CopyWithPlaceholder(),
    Object? email = const $CopyWithPlaceholder(),
    Object? displayName = const $CopyWithPlaceholder(),
    Object? avatar = const $CopyWithPlaceholder(),
    Object? timezone = const $CopyWithPlaceholder(),
    Object? locale = const $CopyWithPlaceholder(),
    Object? role = const $CopyWithPlaceholder(),
    Object? authProvider = const $CopyWithPlaceholder(),
    Object? onboarding = const $CopyWithPlaceholder(),
  }) {
    return UserResponse(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int?,
      email: email == const $CopyWithPlaceholder()
          ? _value.email
          // ignore: cast_nullable_to_non_nullable
          : email as String?,
      displayName: displayName == const $CopyWithPlaceholder()
          ? _value.displayName
          // ignore: cast_nullable_to_non_nullable
          : displayName as String?,
      avatar: avatar == const $CopyWithPlaceholder()
          ? _value.avatar
          // ignore: cast_nullable_to_non_nullable
          : avatar as AvatarResponse?,
      timezone: timezone == const $CopyWithPlaceholder()
          ? _value.timezone
          // ignore: cast_nullable_to_non_nullable
          : timezone as String?,
      locale: locale == const $CopyWithPlaceholder()
          ? _value.locale
          // ignore: cast_nullable_to_non_nullable
          : locale as String?,
      role: role == const $CopyWithPlaceholder()
          ? _value.role
          // ignore: cast_nullable_to_non_nullable
          : role as String?,
      authProvider: authProvider == const $CopyWithPlaceholder()
          ? _value.authProvider
          // ignore: cast_nullable_to_non_nullable
          : authProvider as String?,
      onboarding: onboarding == const $CopyWithPlaceholder()
          ? _value.onboarding
          // ignore: cast_nullable_to_non_nullable
          : onboarding as OnboardingResponse?,
    );
  }
}

extension $UserResponseCopyWith on UserResponse {
  /// Returns a callable class that can be used as follows: `instanceOfUserResponse.copyWith(...)` or like so:`instanceOfUserResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UserResponseCWProxy get copyWith => _$UserResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserResponse _$UserResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('UserResponse', json, ($checkedConvert) {
      final val = UserResponse(
        id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
        email: $checkedConvert('email', (v) => v as String?),
        displayName: $checkedConvert('displayName', (v) => v as String?),
        avatar: $checkedConvert(
          'avatar',
          (v) => v == null
              ? null
              : AvatarResponse.fromJson(v as Map<String, dynamic>),
        ),
        timezone: $checkedConvert('timezone', (v) => v as String?),
        locale: $checkedConvert('locale', (v) => v as String?),
        role: $checkedConvert('role', (v) => v as String?),
        authProvider: $checkedConvert('authProvider', (v) => v as String?),
        onboarding: $checkedConvert(
          'onboarding',
          (v) => v == null
              ? null
              : OnboardingResponse.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$UserResponseToJson(UserResponse instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'email': ?instance.email,
      'displayName': ?instance.displayName,
      'avatar': ?instance.avatar?.toJson(),
      'timezone': ?instance.timezone,
      'locale': ?instance.locale,
      'role': ?instance.role,
      'authProvider': ?instance.authProvider,
      'onboarding': ?instance.onboarding?.toJson(),
    };
