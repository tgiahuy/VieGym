//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'onboarding_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class OnboardingResponse {
  /// Returns a new [OnboardingResponse] instance.
  OnboardingResponse({this.healthProfileCompleted, this.equipmentCompleted});

  @JsonKey(
    name: r'healthProfileCompleted',
    required: false,
    includeIfNull: false,
  )
  final bool? healthProfileCompleted;

  @JsonKey(name: r'equipmentCompleted', required: false, includeIfNull: false)
  final bool? equipmentCompleted;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardingResponse &&
          other.healthProfileCompleted == healthProfileCompleted &&
          other.equipmentCompleted == equipmentCompleted;

  @override
  int get hashCode =>
      healthProfileCompleted.hashCode + equipmentCompleted.hashCode;

  factory OnboardingResponse.fromJson(Map<String, dynamic> json) =>
      _$OnboardingResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OnboardingResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
