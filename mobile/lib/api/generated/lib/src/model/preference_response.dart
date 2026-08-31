//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'preference_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PreferenceResponse {
  /// Returns a new [PreferenceResponse] instance.
  PreferenceResponse({
    this.dislikedFoods,

    this.allergies,

    this.dietaryConstraints,

    this.mealPreferences,

    this.trainingPreferences,

    this.preferredTrainingTime,
  });

  @JsonKey(name: r'dislikedFoods', required: false, includeIfNull: false)
  final List<String>? dislikedFoods;

  @JsonKey(name: r'allergies', required: false, includeIfNull: false)
  final List<String>? allergies;

  @JsonKey(name: r'dietaryConstraints', required: false, includeIfNull: false)
  final List<String>? dietaryConstraints;

  @JsonKey(name: r'mealPreferences', required: false, includeIfNull: false)
  final Map<String, Object>? mealPreferences;

  @JsonKey(name: r'trainingPreferences', required: false, includeIfNull: false)
  final Map<String, Object>? trainingPreferences;

  @JsonKey(
    name: r'preferredTrainingTime',
    required: false,
    includeIfNull: false,
  )
  final String? preferredTrainingTime;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PreferenceResponse &&
          other.dislikedFoods == dislikedFoods &&
          other.allergies == allergies &&
          other.dietaryConstraints == dietaryConstraints &&
          other.mealPreferences == mealPreferences &&
          other.trainingPreferences == trainingPreferences &&
          other.preferredTrainingTime == preferredTrainingTime;

  @override
  int get hashCode =>
      dislikedFoods.hashCode +
      allergies.hashCode +
      dietaryConstraints.hashCode +
      mealPreferences.hashCode +
      trainingPreferences.hashCode +
      preferredTrainingTime.hashCode;

  factory PreferenceResponse.fromJson(Map<String, dynamic> json) =>
      _$PreferenceResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PreferenceResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
