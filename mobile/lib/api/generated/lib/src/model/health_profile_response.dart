//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:viegym_api/src/model/metrics.dart';
import 'package:viegym_api/src/model/nutrition_target.dart';
import 'package:viegym_api/src/model/profile.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'health_profile_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HealthProfileResponse {
  /// Returns a new [HealthProfileResponse] instance.
  HealthProfileResponse({
    this.profile,

    this.calculationStatus,

    this.metrics,

    this.nutritionTarget,

    this.incompleteReason,
  });

  @JsonKey(name: r'profile', required: false, includeIfNull: false)
  final Profile? profile;

  @JsonKey(name: r'calculationStatus', required: false, includeIfNull: false)
  final String? calculationStatus;

  @JsonKey(name: r'metrics', required: false, includeIfNull: false)
  final Metrics? metrics;

  @JsonKey(name: r'nutritionTarget', required: false, includeIfNull: false)
  final NutritionTarget? nutritionTarget;

  @JsonKey(name: r'incompleteReason', required: false, includeIfNull: false)
  final HealthProfileResponseIncompleteReasonEnum? incompleteReason;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthProfileResponse &&
          other.profile == profile &&
          other.calculationStatus == calculationStatus &&
          other.metrics == metrics &&
          other.nutritionTarget == nutritionTarget &&
          other.incompleteReason == incompleteReason;

  @override
  int get hashCode =>
      profile.hashCode +
      calculationStatus.hashCode +
      metrics.hashCode +
      nutritionTarget.hashCode +
      incompleteReason.hashCode;

  factory HealthProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$HealthProfileResponseFromJson(json);

  Map<String, dynamic> toJson() => _$HealthProfileResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum HealthProfileResponseIncompleteReasonEnum {
  @JsonValue(r'CALCULATION_SEX_REQUIRED')
  CALCULATION_SEX_REQUIRED(r'CALCULATION_SEX_REQUIRED'),
  @JsonValue(r'UNSUPPORTED_AGE')
  UNSUPPORTED_AGE(r'UNSUPPORTED_AGE'),
  @JsonValue(r'CALORIES_BELOW_SAFETY_THRESHOLD')
  CALORIES_BELOW_SAFETY_THRESHOLD(r'CALORIES_BELOW_SAFETY_THRESHOLD'),
  @JsonValue(r'INVALID_MACRO_RESULT')
  INVALID_MACRO_RESULT(r'INVALID_MACRO_RESULT');

  const HealthProfileResponseIncompleteReasonEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
