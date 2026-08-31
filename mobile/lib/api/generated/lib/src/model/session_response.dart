//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'session_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SessionResponse {
  /// Returns a new [SessionResponse] instance.
  SessionResponse({
    this.accessToken,

    this.refreshToken,

    this.tokenType,

    this.expiresIn,

    this.resetProof,
  });

  @JsonKey(name: r'accessToken', required: false, includeIfNull: false)
  final String? accessToken;

  @JsonKey(name: r'refreshToken', required: false, includeIfNull: false)
  final String? refreshToken;

  @JsonKey(name: r'tokenType', required: false, includeIfNull: false)
  final String? tokenType;

  @JsonKey(name: r'expiresIn', required: false, includeIfNull: false)
  final int? expiresIn;

  @JsonKey(name: r'resetProof', required: false, includeIfNull: false)
  final String? resetProof;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionResponse &&
          other.accessToken == accessToken &&
          other.refreshToken == refreshToken &&
          other.tokenType == tokenType &&
          other.expiresIn == expiresIn &&
          other.resetProof == resetProof;

  @override
  int get hashCode =>
      accessToken.hashCode +
      refreshToken.hashCode +
      tokenType.hashCode +
      expiresIn.hashCode +
      resetProof.hashCode;

  factory SessionResponse.fromJson(Map<String, dynamic> json) =>
      _$SessionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SessionResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
