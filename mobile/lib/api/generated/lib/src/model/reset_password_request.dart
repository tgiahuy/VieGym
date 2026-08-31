//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reset_password_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ResetPasswordRequest {
  /// Returns a new [ResetPasswordRequest] instance.
  ResetPasswordRequest({this.resetProof, this.newPassword});

  @JsonKey(name: r'resetProof', required: false, includeIfNull: false)
  final String? resetProof;

  @JsonKey(name: r'newPassword', required: false, includeIfNull: false)
  final String? newPassword;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResetPasswordRequest &&
          other.resetProof == resetProof &&
          other.newPassword == newPassword;

  @override
  int get hashCode => resetProof.hashCode + newPassword.hashCode;

  factory ResetPasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ResetPasswordRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
