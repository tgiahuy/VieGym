// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ProfileCWProxy {
  Profile dateOfBirth(DateTime? dateOfBirth);

  Profile gender(ProfileGenderEnum? gender);

  Profile calculationSex(ProfileCalculationSexEnum? calculationSex);

  Profile heightCm(num? heightCm);

  Profile currentWeightKg(num? currentWeightKg);

  Profile activityLevel(ProfileActivityLevelEnum? activityLevel);

  Profile fitnessGoal(ProfileFitnessGoalEnum? fitnessGoal);

  Profile trainingExperience(ProfileTrainingExperienceEnum? trainingExperience);

  Profile calculationVersion(String? calculationVersion);

  Profile calculatedAt(DateTime? calculatedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Profile(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Profile(...).copyWith(id: 12, name: "My name")
  /// ````
  Profile call({
    DateTime? dateOfBirth,
    ProfileGenderEnum? gender,
    ProfileCalculationSexEnum? calculationSex,
    num? heightCm,
    num? currentWeightKg,
    ProfileActivityLevelEnum? activityLevel,
    ProfileFitnessGoalEnum? fitnessGoal,
    ProfileTrainingExperienceEnum? trainingExperience,
    String? calculationVersion,
    DateTime? calculatedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfProfile.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfProfile.copyWith.fieldName(...)`
class _$ProfileCWProxyImpl implements _$ProfileCWProxy {
  const _$ProfileCWProxyImpl(this._value);

  final Profile _value;

  @override
  Profile dateOfBirth(DateTime? dateOfBirth) => this(dateOfBirth: dateOfBirth);

  @override
  Profile gender(ProfileGenderEnum? gender) => this(gender: gender);

  @override
  Profile calculationSex(ProfileCalculationSexEnum? calculationSex) =>
      this(calculationSex: calculationSex);

  @override
  Profile heightCm(num? heightCm) => this(heightCm: heightCm);

  @override
  Profile currentWeightKg(num? currentWeightKg) =>
      this(currentWeightKg: currentWeightKg);

  @override
  Profile activityLevel(ProfileActivityLevelEnum? activityLevel) =>
      this(activityLevel: activityLevel);

  @override
  Profile fitnessGoal(ProfileFitnessGoalEnum? fitnessGoal) =>
      this(fitnessGoal: fitnessGoal);

  @override
  Profile trainingExperience(
    ProfileTrainingExperienceEnum? trainingExperience,
  ) => this(trainingExperience: trainingExperience);

  @override
  Profile calculationVersion(String? calculationVersion) =>
      this(calculationVersion: calculationVersion);

  @override
  Profile calculatedAt(DateTime? calculatedAt) =>
      this(calculatedAt: calculatedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Profile(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Profile(...).copyWith(id: 12, name: "My name")
  /// ````
  Profile call({
    Object? dateOfBirth = const $CopyWithPlaceholder(),
    Object? gender = const $CopyWithPlaceholder(),
    Object? calculationSex = const $CopyWithPlaceholder(),
    Object? heightCm = const $CopyWithPlaceholder(),
    Object? currentWeightKg = const $CopyWithPlaceholder(),
    Object? activityLevel = const $CopyWithPlaceholder(),
    Object? fitnessGoal = const $CopyWithPlaceholder(),
    Object? trainingExperience = const $CopyWithPlaceholder(),
    Object? calculationVersion = const $CopyWithPlaceholder(),
    Object? calculatedAt = const $CopyWithPlaceholder(),
  }) {
    return Profile(
      dateOfBirth: dateOfBirth == const $CopyWithPlaceholder()
          ? _value.dateOfBirth
          // ignore: cast_nullable_to_non_nullable
          : dateOfBirth as DateTime?,
      gender: gender == const $CopyWithPlaceholder()
          ? _value.gender
          // ignore: cast_nullable_to_non_nullable
          : gender as ProfileGenderEnum?,
      calculationSex: calculationSex == const $CopyWithPlaceholder()
          ? _value.calculationSex
          // ignore: cast_nullable_to_non_nullable
          : calculationSex as ProfileCalculationSexEnum?,
      heightCm: heightCm == const $CopyWithPlaceholder()
          ? _value.heightCm
          // ignore: cast_nullable_to_non_nullable
          : heightCm as num?,
      currentWeightKg: currentWeightKg == const $CopyWithPlaceholder()
          ? _value.currentWeightKg
          // ignore: cast_nullable_to_non_nullable
          : currentWeightKg as num?,
      activityLevel: activityLevel == const $CopyWithPlaceholder()
          ? _value.activityLevel
          // ignore: cast_nullable_to_non_nullable
          : activityLevel as ProfileActivityLevelEnum?,
      fitnessGoal: fitnessGoal == const $CopyWithPlaceholder()
          ? _value.fitnessGoal
          // ignore: cast_nullable_to_non_nullable
          : fitnessGoal as ProfileFitnessGoalEnum?,
      trainingExperience: trainingExperience == const $CopyWithPlaceholder()
          ? _value.trainingExperience
          // ignore: cast_nullable_to_non_nullable
          : trainingExperience as ProfileTrainingExperienceEnum?,
      calculationVersion: calculationVersion == const $CopyWithPlaceholder()
          ? _value.calculationVersion
          // ignore: cast_nullable_to_non_nullable
          : calculationVersion as String?,
      calculatedAt: calculatedAt == const $CopyWithPlaceholder()
          ? _value.calculatedAt
          // ignore: cast_nullable_to_non_nullable
          : calculatedAt as DateTime?,
    );
  }
}

extension $ProfileCopyWith on Profile {
  /// Returns a callable class that can be used as follows: `instanceOfProfile.copyWith(...)` or like so:`instanceOfProfile.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ProfileCWProxy get copyWith => _$ProfileCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Profile', json, ($checkedConvert) {
      final val = Profile(
        dateOfBirth: $checkedConvert(
          'dateOfBirth',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        gender: $checkedConvert(
          'gender',
          (v) => $enumDecodeNullable(_$ProfileGenderEnumEnumMap, v),
        ),
        calculationSex: $checkedConvert(
          'calculationSex',
          (v) => $enumDecodeNullable(_$ProfileCalculationSexEnumEnumMap, v),
        ),
        heightCm: $checkedConvert('heightCm', (v) => v as num?),
        currentWeightKg: $checkedConvert('currentWeightKg', (v) => v as num?),
        activityLevel: $checkedConvert(
          'activityLevel',
          (v) => $enumDecodeNullable(_$ProfileActivityLevelEnumEnumMap, v),
        ),
        fitnessGoal: $checkedConvert(
          'fitnessGoal',
          (v) => $enumDecodeNullable(_$ProfileFitnessGoalEnumEnumMap, v),
        ),
        trainingExperience: $checkedConvert(
          'trainingExperience',
          (v) => $enumDecodeNullable(_$ProfileTrainingExperienceEnumEnumMap, v),
        ),
        calculationVersion: $checkedConvert(
          'calculationVersion',
          (v) => v as String?,
        ),
        calculatedAt: $checkedConvert(
          'calculatedAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
  'dateOfBirth': ?instance.dateOfBirth?.toIso8601String(),
  'gender': ?_$ProfileGenderEnumEnumMap[instance.gender],
  'calculationSex':
      ?_$ProfileCalculationSexEnumEnumMap[instance.calculationSex],
  'heightCm': ?instance.heightCm,
  'currentWeightKg': ?instance.currentWeightKg,
  'activityLevel': ?_$ProfileActivityLevelEnumEnumMap[instance.activityLevel],
  'fitnessGoal': ?_$ProfileFitnessGoalEnumEnumMap[instance.fitnessGoal],
  'trainingExperience':
      ?_$ProfileTrainingExperienceEnumEnumMap[instance.trainingExperience],
  'calculationVersion': ?instance.calculationVersion,
  'calculatedAt': ?instance.calculatedAt?.toIso8601String(),
};

const _$ProfileGenderEnumEnumMap = {
  ProfileGenderEnum.MALE: 'MALE',
  ProfileGenderEnum.FEMALE: 'FEMALE',
  ProfileGenderEnum.OTHER: 'OTHER',
  ProfileGenderEnum.UNSPECIFIED: 'UNSPECIFIED',
};

const _$ProfileCalculationSexEnumEnumMap = {
  ProfileCalculationSexEnum.MALE: 'MALE',
  ProfileCalculationSexEnum.FEMALE: 'FEMALE',
  ProfileCalculationSexEnum.UNSPECIFIED: 'UNSPECIFIED',
};

const _$ProfileActivityLevelEnumEnumMap = {
  ProfileActivityLevelEnum.SEDENTARY: 'SEDENTARY',
  ProfileActivityLevelEnum.LIGHT: 'LIGHT',
  ProfileActivityLevelEnum.MODERATE: 'MODERATE',
  ProfileActivityLevelEnum.ACTIVE: 'ACTIVE',
  ProfileActivityLevelEnum.VERY_ACTIVE: 'VERY_ACTIVE',
};

const _$ProfileFitnessGoalEnumEnumMap = {
  ProfileFitnessGoalEnum.LOSE_WEIGHT: 'LOSE_WEIGHT',
  ProfileFitnessGoalEnum.MAINTAIN_WEIGHT: 'MAINTAIN_WEIGHT',
  ProfileFitnessGoalEnum.GAIN_WEIGHT: 'GAIN_WEIGHT',
  ProfileFitnessGoalEnum.GAIN_MUSCLE: 'GAIN_MUSCLE',
};

const _$ProfileTrainingExperienceEnumEnumMap = {
  ProfileTrainingExperienceEnum.BEGINNER: 'BEGINNER',
  ProfileTrainingExperienceEnum.INTERMEDIATE: 'INTERMEDIATE',
  ProfileTrainingExperienceEnum.ADVANCED: 'ADVANCED',
};
