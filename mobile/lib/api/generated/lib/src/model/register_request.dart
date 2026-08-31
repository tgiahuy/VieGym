//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'register_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RegisterRequest {
  /// Returns a new [RegisterRequest] instance.
  RegisterRequest({this.displayName, this.email, this.password});

  @JsonKey(name: r'displayName', required: false, includeIfNull: false)
  final String? displayName;

  @JsonKey(name: r'email', required: false, includeIfNull: false)
  final String? email;

  @JsonKey(name: r'password', required: false, includeIfNull: false)
  final String? password;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegisterRequest &&
          other.displayName == displayName &&
          other.email == email &&
          other.password == password;

  @override
  int get hashCode => displayName.hashCode + email.hashCode + password.hashCode;

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
