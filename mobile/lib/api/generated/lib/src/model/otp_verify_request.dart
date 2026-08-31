//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'otp_verify_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class OtpVerifyRequest {
  /// Returns a new [OtpVerifyRequest] instance.
  OtpVerifyRequest({this.challengeId, this.purpose, this.code});

  @JsonKey(name: r'challengeId', required: false, includeIfNull: false)
  final String? challengeId;

  @JsonKey(name: r'purpose', required: false, includeIfNull: false)
  final OtpVerifyRequestPurposeEnum? purpose;

  @JsonKey(name: r'code', required: false, includeIfNull: false)
  final String? code;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OtpVerifyRequest &&
          other.challengeId == challengeId &&
          other.purpose == purpose &&
          other.code == code;

  @override
  int get hashCode => challengeId.hashCode + purpose.hashCode + code.hashCode;

  factory OtpVerifyRequest.fromJson(Map<String, dynamic> json) =>
      _$OtpVerifyRequestFromJson(json);

  Map<String, dynamic> toJson() => _$OtpVerifyRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum OtpVerifyRequestPurposeEnum {
  @JsonValue(r'REGISTER')
  REGISTER(r'REGISTER'),
  @JsonValue(r'PASSWORD_RESET')
  PASSWORD_RESET(r'PASSWORD_RESET');

  const OtpVerifyRequestPurposeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
