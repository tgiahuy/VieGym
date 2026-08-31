//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'register_challenge_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RegisterChallengeResponse {
  /// Returns a new [RegisterChallengeResponse] instance.
  RegisterChallengeResponse({
    this.challengeId,

    this.maskedDestination,

    this.purpose,

    this.expiresAt,

    this.resendAvailableAt,
  });

  @JsonKey(name: r'challengeId', required: false, includeIfNull: false)
  final String? challengeId;

  @JsonKey(name: r'maskedDestination', required: false, includeIfNull: false)
  final String? maskedDestination;

  @JsonKey(name: r'purpose', required: false, includeIfNull: false)
  final RegisterChallengeResponsePurposeEnum? purpose;

  @JsonKey(name: r'expiresAt', required: false, includeIfNull: false)
  final DateTime? expiresAt;

  @JsonKey(name: r'resendAvailableAt', required: false, includeIfNull: false)
  final DateTime? resendAvailableAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegisterChallengeResponse &&
          other.challengeId == challengeId &&
          other.maskedDestination == maskedDestination &&
          other.purpose == purpose &&
          other.expiresAt == expiresAt &&
          other.resendAvailableAt == resendAvailableAt;

  @override
  int get hashCode =>
      challengeId.hashCode +
      maskedDestination.hashCode +
      purpose.hashCode +
      expiresAt.hashCode +
      resendAvailableAt.hashCode;

  factory RegisterChallengeResponse.fromJson(Map<String, dynamic> json) =>
      _$RegisterChallengeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterChallengeResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum RegisterChallengeResponsePurposeEnum {
  @JsonValue(r'REGISTER')
  REGISTER(r'REGISTER'),
  @JsonValue(r'PASSWORD_RESET')
  PASSWORD_RESET(r'PASSWORD_RESET');

  const RegisterChallengeResponsePurposeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
