//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'facebook_login_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class FacebookLoginRequest {
  /// Returns a new [FacebookLoginRequest] instance.
  FacebookLoginRequest({this.accessToken, this.deviceInfo});

  @JsonKey(name: r'accessToken', required: false, includeIfNull: false)
  final String? accessToken;

  @JsonKey(name: r'deviceInfo', required: false, includeIfNull: false)
  final String? deviceInfo;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FacebookLoginRequest &&
          other.accessToken == accessToken &&
          other.deviceInfo == deviceInfo;

  @override
  int get hashCode => accessToken.hashCode + deviceInfo.hashCode;

  factory FacebookLoginRequest.fromJson(Map<String, dynamic> json) =>
      _$FacebookLoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$FacebookLoginRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
