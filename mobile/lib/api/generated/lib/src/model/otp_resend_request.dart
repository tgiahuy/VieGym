//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'otp_resend_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class OtpResendRequest {
  /// Returns a new [OtpResendRequest] instance.
  OtpResendRequest({this.challengeId, this.purpose});

  @JsonKey(name: r'challengeId', required: false, includeIfNull: false)
  final String? challengeId;

  @JsonKey(name: r'purpose', required: false, includeIfNull: false)
  final OtpResendRequestPurposeEnum? purpose;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OtpResendRequest &&
          other.challengeId == challengeId &&
          other.purpose == purpose;

  @override
  int get hashCode => challengeId.hashCode + purpose.hashCode;

  factory OtpResendRequest.fromJson(Map<String, dynamic> json) =>
      _$OtpResendRequestFromJson(json);

  Map<String, dynamic> toJson() => _$OtpResendRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum OtpResendRequestPurposeEnum {
  @JsonValue(r'REGISTER')
  REGISTER(r'REGISTER'),
  @JsonValue(r'PASSWORD_RESET')
  PASSWORD_RESET(r'PASSWORD_RESET');

  const OtpResendRequestPurposeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
