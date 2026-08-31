//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'google_login_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GoogleLoginRequest {
  /// Returns a new [GoogleLoginRequest] instance.
  GoogleLoginRequest({this.idToken, this.deviceInfo});

  @JsonKey(name: r'idToken', required: false, includeIfNull: false)
  final String? idToken;

  @JsonKey(name: r'deviceInfo', required: false, includeIfNull: false)
  final String? deviceInfo;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoogleLoginRequest &&
          other.idToken == idToken &&
          other.deviceInfo == deviceInfo;

  @override
  int get hashCode => idToken.hashCode + deviceInfo.hashCode;

  factory GoogleLoginRequest.fromJson(Map<String, dynamic> json) =>
      _$GoogleLoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GoogleLoginRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
