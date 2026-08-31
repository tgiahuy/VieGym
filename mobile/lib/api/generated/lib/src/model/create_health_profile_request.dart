//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_health_profile_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateHealthProfileRequest {
  /// Returns a new [CreateHealthProfileRequest] instance.
  CreateHealthProfileRequest({
    required this.dateOfBirth,

    required this.gender,

    this.calculationSex,

    required this.heightCm,

    required this.currentWeightKg,

    required this.activityLevel,

    required this.fitnessGoal,

    required this.trainingExperience,
  });

  @JsonKey(name: r'dateOfBirth', required: true, includeIfNull: false)
  final DateTime dateOfBirth;

  @JsonKey(name: r'gender', required: true, includeIfNull: false)
  final CreateHealthProfileRequestGenderEnum gender;

  @JsonKey(name: r'calculationSex', required: false, includeIfNull: false)
  final CreateHealthProfileRequestCalculationSexEnum? calculationSex;

  // minimum: 0.01
  // maximum: 999.99
  @JsonKey(name: r'heightCm', required: true, includeIfNull: false)
  final num heightCm;

  // minimum: 0.01
  // maximum: 9999.99
  @JsonKey(name: r'currentWeightKg', required: true, includeIfNull: false)
  final num currentWeightKg;

  @JsonKey(name: r'activityLevel', required: true, includeIfNull: false)
  final CreateHealthProfileRequestActivityLevelEnum activityLevel;

  @JsonKey(name: r'fitnessGoal', required: true, includeIfNull: false)
  final CreateHealthProfileRequestFitnessGoalEnum fitnessGoal;

  @JsonKey(name: r'trainingExperience', required: true, includeIfNull: false)
  final CreateHealthProfileRequestTrainingExperienceEnum trainingExperience;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateHealthProfileRequest &&
          other.dateOfBirth == dateOfBirth &&
          other.gender == gender &&
          other.calculationSex == calculationSex &&
          other.heightCm == heightCm &&
          other.currentWeightKg == currentWeightKg &&
          other.activityLevel == activityLevel &&
          other.fitnessGoal == fitnessGoal &&
          other.trainingExperience == trainingExperience;

  @override
  int get hashCode =>
      dateOfBirth.hashCode +
      gender.hashCode +
      calculationSex.hashCode +
      heightCm.hashCode +
      currentWeightKg.hashCode +
      activityLevel.hashCode +
      fitnessGoal.hashCode +
      trainingExperience.hashCode;

  factory CreateHealthProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateHealthProfileRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateHealthProfileRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum CreateHealthProfileRequestGenderEnum {
  @JsonValue(r'MALE')
  MALE(r'MALE'),
  @JsonValue(r'FEMALE')
  FEMALE(r'FEMALE'),
  @JsonValue(r'OTHER')
  OTHER(r'OTHER'),
  @JsonValue(r'UNSPECIFIED')
  UNSPECIFIED(r'UNSPECIFIED');

  const CreateHealthProfileRequestGenderEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum CreateHealthProfileRequestCalculationSexEnum {
  @JsonValue(r'MALE')
  MALE(r'MALE'),
  @JsonValue(r'FEMALE')
  FEMALE(r'FEMALE'),
  @JsonValue(r'UNSPECIFIED')
  UNSPECIFIED(r'UNSPECIFIED');

  const CreateHealthProfileRequestCalculationSexEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum CreateHealthProfileRequestActivityLevelEnum {
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

  const CreateHealthProfileRequestActivityLevelEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum CreateHealthProfileRequestFitnessGoalEnum {
  @JsonValue(r'LOSE_WEIGHT')
  LOSE_WEIGHT(r'LOSE_WEIGHT'),
  @JsonValue(r'MAINTAIN_WEIGHT')
  MAINTAIN_WEIGHT(r'MAINTAIN_WEIGHT'),
  @JsonValue(r'GAIN_WEIGHT')
  GAIN_WEIGHT(r'GAIN_WEIGHT'),
  @JsonValue(r'GAIN_MUSCLE')
  GAIN_MUSCLE(r'GAIN_MUSCLE');

  const CreateHealthProfileRequestFitnessGoalEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum CreateHealthProfileRequestTrainingExperienceEnum {
  @JsonValue(r'BEGINNER')
  BEGINNER(r'BEGINNER'),
  @JsonValue(r'INTERMEDIATE')
  INTERMEDIATE(r'INTERMEDIATE'),
  @JsonValue(r'ADVANCED')
  ADVANCED(r'ADVANCED');

  const CreateHealthProfileRequestTrainingExperienceEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
