//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_user_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateUserRequest {
  /// Returns a new [UpdateUserRequest] instance.
  UpdateUserRequest({
    this.displayName,

    this.avatarMediaId,

    this.timezone,

    this.locale,
  });

  @JsonKey(name: r'displayName', required: false, includeIfNull: false)
  final String? displayName;

  @JsonKey(name: r'avatarMediaId', required: false, includeIfNull: false)
  final int? avatarMediaId;

  @JsonKey(name: r'timezone', required: false, includeIfNull: false)
  final String? timezone;

  @JsonKey(name: r'locale', required: false, includeIfNull: false)
  final String? locale;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateUserRequest &&
          other.displayName == displayName &&
          other.avatarMediaId == avatarMediaId &&
          other.timezone == timezone &&
          other.locale == locale;

  @override
  int get hashCode =>
      displayName.hashCode +
      avatarMediaId.hashCode +
      timezone.hashCode +
      locale.hashCode;

  factory UpdateUserRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateUserRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateUserRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
