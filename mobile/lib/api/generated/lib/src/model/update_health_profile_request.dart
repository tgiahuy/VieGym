//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_health_profile_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateHealthProfileRequest {
  /// Returns a new [UpdateHealthProfileRequest] instance.
  UpdateHealthProfileRequest({
    required this.dateOfBirth,

    required this.gender,

    this.calculationSex,

    required this.heightCm,

    required this.activityLevel,

    required this.fitnessGoal,

    required this.trainingExperience,
  });

  @JsonKey(name: r'dateOfBirth', required: true, includeIfNull: false)
  final DateTime dateOfBirth;

  @JsonKey(name: r'gender', required: true, includeIfNull: false)
  final UpdateHealthProfileRequestGenderEnum gender;

  @JsonKey(name: r'calculationSex', required: false, includeIfNull: false)
  final UpdateHealthProfileRequestCalculationSexEnum? calculationSex;

  // minimum: 0.01
  // maximum: 999.99
  @JsonKey(name: r'heightCm', required: true, includeIfNull: false)
  final num heightCm;

  @JsonKey(name: r'activityLevel', required: true, includeIfNull: false)
  final UpdateHealthProfileRequestActivityLevelEnum activityLevel;

  @JsonKey(name: r'fitnessGoal', required: true, includeIfNull: false)
  final UpdateHealthProfileRequestFitnessGoalEnum fitnessGoal;

  @JsonKey(name: r'trainingExperience', required: true, includeIfNull: false)
  final UpdateHealthProfileRequestTrainingExperienceEnum trainingExperience;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateHealthProfileRequest &&
          other.dateOfBirth == dateOfBirth &&
          other.gender == gender &&
          other.calculationSex == calculationSex &&
          other.heightCm == heightCm &&
          other.activityLevel == activityLevel &&
          other.fitnessGoal == fitnessGoal &&
          other.trainingExperience == trainingExperience;

  @override
  int get hashCode =>
      dateOfBirth.hashCode +
      gender.hashCode +
      calculationSex.hashCode +
      heightCm.hashCode +
      activityLevel.hashCode +
      fitnessGoal.hashCode +
      trainingExperience.hashCode;

  factory UpdateHealthProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateHealthProfileRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateHealthProfileRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum UpdateHealthProfileRequestGenderEnum {
  @JsonValue(r'MALE')
  MALE(r'MALE'),
  @JsonValue(r'FEMALE')
  FEMALE(r'FEMALE'),
  @JsonValue(r'OTHER')
  OTHER(r'OTHER'),
  @JsonValue(r'UNSPECIFIED')
  UNSPECIFIED(r'UNSPECIFIED');

  const UpdateHealthProfileRequestGenderEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum UpdateHealthProfileRequestCalculationSexEnum {
  @JsonValue(r'MALE')
  MALE(r'MALE'),
  @JsonValue(r'FEMALE')
  FEMALE(r'FEMALE'),
  @JsonValue(r'UNSPECIFIED')
  UNSPECIFIED(r'UNSPECIFIED');

  const UpdateHealthProfileRequestCalculationSexEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum UpdateHealthProfileRequestActivityLevelEnum {
  @JsonValue(r'SEDENTARY')
  SEDENTARY(r'SEDENTARY'),
  @JsonValue(r'LIGHT')
  LIGHT(r'LIGHT'),
  @JsonValue(r'MODERATE')
  MODERATE(r'MODERATE'),
  @JsonValue(r'ACTIVE')
  ACTIVE(r'ACTIVE'),
  @JsonValue(r'VERY_ACTIVE')
  VERY_ACTIVE(r'VERY_ACTIVE');

  const UpdateHealthProfileRequestActivityLevelEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum UpdateHealthProfileRequestFitnessGoalEnum {
  @JsonValue(r'LOSE_WEIGHT')
  LOSE_WEIGHT(r'LOSE_WEIGHT'),
  @JsonValue(r'MAINTAIN_WEIGHT')
  MAINTAIN_WEIGHT(r'MAINTAIN_WEIGHT'),
  @JsonValue(r'GAIN_WEIGHT')
  GAIN_WEIGHT(r'GAIN_WEIGHT'),
  @JsonValue(r'GAIN_MUSCLE')
  GAIN_MUSCLE(r'GAIN_MUSCLE');

  const UpdateHealthProfileRequestFitnessGoalEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum UpdateHealthProfileRequestTrainingExperienceEnum {
  @JsonValue(r'BEGINNER')
  BEGINNER(r'BEGINNER'),
  @JsonValue(r'INTERMEDIATE')
  INTERMEDIATE(r'INTERMEDIATE'),
  @JsonValue(r'ADVANCED')
  ADVANCED(r'ADVANCED');

  const UpdateHealthProfileRequestTrainingExperienceEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
