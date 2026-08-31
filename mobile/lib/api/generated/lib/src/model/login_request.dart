//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'login_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LoginRequest {
  /// Returns a new [LoginRequest] instance.
  LoginRequest({this.email, this.password, this.deviceInfo});

  @JsonKey(name: r'email', required: false, includeIfNull: false)
  final String? email;

  @JsonKey(name: r'password', required: false, includeIfNull: false)
  final String? password;

  @JsonKey(name: r'deviceInfo', required: false, includeIfNull: false)
  final String? deviceInfo;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginRequest &&
          other.email == email &&
          other.password == password &&
          other.deviceInfo == deviceInfo;

  @override
  int get hashCode => email.hashCode + password.hashCode + deviceInfo.hashCode;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
