//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'avatar_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AvatarResponse {
  /// Returns a new [AvatarResponse] instance.
  AvatarResponse({this.mediaId, this.accessUrl, this.expiresAt});

  @JsonKey(name: r'mediaId', required: false, includeIfNull: false)
  final int? mediaId;

  @JsonKey(name: r'accessUrl', required: false, includeIfNull: false)
  final String? accessUrl;

  @JsonKey(name: r'expiresAt', required: false, includeIfNull: false)
  final DateTime? expiresAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AvatarResponse &&
          other.mediaId == mediaId &&
          other.accessUrl == accessUrl &&
          other.expiresAt == expiresAt;

  @override
  int get hashCode =>
      mediaId.hashCode + accessUrl.hashCode + expiresAt.hashCode;

  factory AvatarResponse.fromJson(Map<String, dynamic> json) =>
      _$AvatarResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AvatarResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
