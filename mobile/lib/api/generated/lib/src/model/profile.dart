//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'profile.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Profile {
  /// Returns a new [Profile] instance.
  Profile({
    this.dateOfBirth,

    this.gender,

    this.calculationSex,

    this.heightCm,

    this.currentWeightKg,

    this.activityLevel,

    this.fitnessGoal,

    this.trainingExperience,

    this.calculationVersion,

    this.calculatedAt,
  });

  @JsonKey(name: r'dateOfBirth', required: false, includeIfNull: false)
  final DateTime? dateOfBirth;

  @JsonKey(name: r'gender', required: false, includeIfNull: false)
  final ProfileGenderEnum? gender;

  @JsonKey(name: r'calculationSex', required: false, includeIfNull: false)
  final ProfileCalculationSexEnum? calculationSex;

  @JsonKey(name: r'heightCm', required: false, includeIfNull: false)
  final num? heightCm;

  @JsonKey(name: r'currentWeightKg', required: false, includeIfNull: false)
  final num? currentWeightKg;

  @JsonKey(name: r'activityLevel', required: false, includeIfNull: false)
  final ProfileActivityLevelEnum? activityLevel;

  @JsonKey(name: r'fitnessGoal', required: false, includeIfNull: false)
  final ProfileFitnessGoalEnum? fitnessGoal;

  @JsonKey(name: r'trainingExperience', required: false, includeIfNull: false)
  final ProfileTrainingExperienceEnum? trainingExperience;

  @JsonKey(name: r'calculationVersion', required: false, includeIfNull: false)
  final String? calculationVersion;

  @JsonKey(name: r'calculatedAt', required: false, includeIfNull: false)
  final DateTime? calculatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Profile &&
          other.dateOfBirth == dateOfBirth &&
          other.gender == gender &&
          other.calculationSex == calculationSex &&
          other.heightCm == heightCm &&
          other.currentWeightKg == currentWeightKg &&
          other.activityLevel == activityLevel &&
          other.fitnessGoal == fitnessGoal &&
          other.trainingExperience == trainingExperience &&
          other.calculationVersion == calculationVersion &&
          other.calculatedAt == calculatedAt;

  @override
  int get hashCode =>
      dateOfBirth.hashCode +
      gender.hashCode +
      calculationSex.hashCode +
      heightCm.hashCode +
      currentWeightKg.hashCode +
      activityLevel.hashCode +
      fitnessGoal.hashCode +
      trainingExperience.hashCode +
      calculationVersion.hashCode +
      calculatedAt.hashCode;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum ProfileGenderEnum {
  @JsonValue(r'MALE')
  MALE(r'MALE'),
  @JsonValue(r'FEMALE')
  FEMALE(r'FEMALE'),
  @JsonValue(r'OTHER')
  OTHER(r'OTHER'),
  @JsonValue(r'UNSPECIFIED')
  UNSPECIFIED(r'UNSPECIFIED');

  const ProfileGenderEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum ProfileCalculationSexEnum {
  @JsonValue(r'MALE')
  MALE(r'MALE'),
  @JsonValue(r'FEMALE')
  FEMALE(r'FEMALE'),
  @JsonValue(r'UNSPECIFIED')
  UNSPECIFIED(r'UNSPECIFIED');

  const ProfileCalculationSexEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum ProfileActivityLevelEnum {
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

  const ProfileActivityLevelEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum ProfileFitnessGoalEnum {
  @JsonValue(r'LOSE_WEIGHT')
  LOSE_WEIGHT(r'LOSE_WEIGHT'),
  @JsonValue(r'MAINTAIN_WEIGHT')
  MAINTAIN_WEIGHT(r'MAINTAIN_WEIGHT'),
  @JsonValue(r'GAIN_WEIGHT')
  GAIN_WEIGHT(r'GAIN_WEIGHT'),
  @JsonValue(r'GAIN_MUSCLE')
  GAIN_MUSCLE(r'GAIN_MUSCLE');

  const ProfileFitnessGoalEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum ProfileTrainingExperienceEnum {
  @JsonValue(r'BEGINNER')
  BEGINNER(r'BEGINNER'),
  @JsonValue(r'INTERMEDIATE')
  INTERMEDIATE(r'INTERMEDIATE'),
  @JsonValue(r'ADVANCED')
  ADVANCED(r'ADVANCED');

  const ProfileTrainingExperienceEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
