//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:viegym_api/src/model/avatar_response.dart';
import 'package:viegym_api/src/model/onboarding_response.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UserResponse {
  /// Returns a new [UserResponse] instance.
  UserResponse({
    this.id,

    this.email,

    this.displayName,

    this.avatar,

    this.timezone,

    this.locale,

    this.role,

    this.authProvider,

    this.onboarding,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final int? id;

  @JsonKey(name: r'email', required: false, includeIfNull: false)
  final String? email;

  @JsonKey(name: r'displayName', required: false, includeIfNull: false)
  final String? displayName;

  @JsonKey(name: r'avatar', required: false, includeIfNull: false)
  final AvatarResponse? avatar;

  @JsonKey(name: r'timezone', required: false, includeIfNull: false)
  final String? timezone;

  @JsonKey(name: r'locale', required: false, includeIfNull: false)
  final String? locale;

  @JsonKey(name: r'role', required: false, includeIfNull: false)
  final String? role;

  @JsonKey(name: r'authProvider', required: false, includeIfNull: false)
  final String? authProvider;

  @JsonKey(name: r'onboarding', required: false, includeIfNull: false)
  final OnboardingResponse? onboarding;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserResponse &&
          other.id == id &&
          other.email == email &&
          other.displayName == displayName &&
          other.avatar == avatar &&
          other.timezone == timezone &&
          other.locale == locale &&
          other.role == role &&
          other.authProvider == authProvider &&
          other.onboarding == onboarding;

  @override
  int get hashCode =>
      id.hashCode +
      email.hashCode +
      displayName.hashCode +
      avatar.hashCode +
      timezone.hashCode +
      locale.hashCode +
      role.hashCode +
      authProvider.hashCode +
      onboarding.hashCode;

  factory UserResponse.fromJson(Map<String, dynamic> json) =>
      _$UserResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
