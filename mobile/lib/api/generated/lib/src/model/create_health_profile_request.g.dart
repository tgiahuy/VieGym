// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_health_profile_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateHealthProfileRequestCWProxy {
  CreateHealthProfileRequest dateOfBirth(DateTime dateOfBirth);

  CreateHealthProfileRequest gender(
    CreateHealthProfileRequestGenderEnum gender,
  );

  CreateHealthProfileRequest calculationSex(
    CreateHealthProfileRequestCalculationSexEnum? calculationSex,
  );

  CreateHealthProfileRequest heightCm(num heightCm);

  CreateHealthProfileRequest currentWeightKg(num currentWeightKg);

  CreateHealthProfileRequest activityLevel(
    CreateHealthProfileRequestActivityLevelEnum activityLevel,
  );

  CreateHealthProfileRequest fitnessGoal(
    CreateHealthProfileRequestFitnessGoalEnum fitnessGoal,
  );

  CreateHealthProfileRequest trainingExperience(
    CreateHealthProfileRequestTrainingExperienceEnum trainingExperience,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateHealthProfileRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateHealthProfileRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateHealthProfileRequest call({
    DateTime dateOfBirth,
    CreateHealthProfileRequestGenderEnum gender,
    CreateHealthProfileRequestCalculationSexEnum? calculationSex,
    num heightCm,
    num currentWeightKg,
    CreateHealthProfileRequestActivityLevelEnum activityLevel,
    CreateHealthProfileRequestFitnessGoalEnum fitnessGoal,
    CreateHealthProfileRequestTrainingExperienceEnum trainingExperience,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateHealthProfileRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateHealthProfileRequest.copyWith.fieldName(...)`
class _$CreateHealthProfileRequestCWProxyImpl
    implements _$CreateHealthProfileRequestCWProxy {
  const _$CreateHealthProfileRequestCWProxyImpl(this._value);

  final CreateHealthProfileRequest _value;

  @override
  CreateHealthProfileRequest dateOfBirth(DateTime dateOfBirth) =>
      this(dateOfBirth: dateOfBirth);

  @override
  CreateHealthProfileRequest gender(
    CreateHealthProfileRequestGenderEnum gender,
  ) => this(gender: gender);

  @override
  CreateHealthProfileRequest calculationSex(
    CreateHealthProfileRequestCalculationSexEnum? calculationSex,
  ) => this(calculationSex: calculationSex);

  @override
  CreateHealthProfileRequest heightCm(num heightCm) => this(heightCm: heightCm);

  @override
  CreateHealthProfileRequest currentWeightKg(num currentWeightKg) =>
      this(currentWeightKg: currentWeightKg);

  @override
  CreateHealthProfileRequest activityLevel(
    CreateHealthProfileRequestActivityLevelEnum activityLevel,
  ) => this(activityLevel: activityLevel);

  @override
  CreateHealthProfileRequest fitnessGoal(
    CreateHealthProfileRequestFitnessGoalEnum fitnessGoal,
  ) => this(fitnessGoal: fitnessGoal);

  @override
  CreateHealthProfileRequest trainingExperience(
    CreateHealthProfileRequestTrainingExperienceEnum trainingExperience,
  ) => this(trainingExperience: trainingExperience);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateHealthProfileRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateHealthProfileRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateHealthProfileRequest call({
    Object? dateOfBirth = const $CopyWithPlaceholder(),
    Object? gender = const $CopyWithPlaceholder(),
    Object? calculationSex = const $CopyWithPlaceholder(),
    Object? heightCm = const $CopyWithPlaceholder(),
    Object? currentWeightKg = const $CopyWithPlaceholder(),
    Object? activityLevel = const $CopyWithPlaceholder(),
    Object? fitnessGoal = const $CopyWithPlaceholder(),
    Object? trainingExperience = const $CopyWithPlaceholder(),
  }) {
    return CreateHealthProfileRequest(
      dateOfBirth: dateOfBirth == const $CopyWithPlaceholder()
          ? _value.dateOfBirth
          // ignore: cast_nullable_to_non_nullable
          : dateOfBirth as DateTime,
      gender: gender == const $CopyWithPlaceholder()
          ? _value.gender
          // ignore: cast_nullable_to_non_nullable
          : gender as CreateHealthProfileRequestGenderEnum,
      calculationSex: calculationSex == const $CopyWithPlaceholder()
          ? _value.calculationSex
          // ignore: cast_nullable_to_non_nullable
          : calculationSex as CreateHealthProfileRequestCalculationSexEnum?,
      heightCm: heightCm == const $CopyWithPlaceholder()
          ? _value.heightCm
          // ignore: cast_nullable_to_non_nullable
          : heightCm as num,
      currentWeightKg: currentWeightKg == const $CopyWithPlaceholder()
          ? _value.currentWeightKg
          // ignore: cast_nullable_to_non_nullable
          : currentWeightKg as num,
      activityLevel: activityLevel == const $CopyWithPlaceholder()
          ? _value.activityLevel
          // ignore: cast_nullable_to_non_nullable
          : activityLevel as CreateHealthProfileRequestActivityLevelEnum,
      fitnessGoal: fitnessGoal == const $CopyWithPlaceholder()
          ? _value.fitnessGoal
          // ignore: cast_nullable_to_non_nullable
          : fitnessGoal as CreateHealthProfileRequestFitnessGoalEnum,
      trainingExperience: trainingExperience == const $CopyWithPlaceholder()
          ? _value.trainingExperience
          // ignore: cast_nullable_to_non_nullable
          : trainingExperience
                as CreateHealthProfileRequestTrainingExperienceEnum,
    );
  }
}

extension $CreateHealthProfileRequestCopyWith on CreateHealthProfileRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCreateHealthProfileRequest.copyWith(...)` or like so:`instanceOfCreateHealthProfileRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateHealthProfileRequestCWProxy get copyWith =>
      _$CreateHealthProfileRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateHealthProfileRequest _$CreateHealthProfileRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CreateHealthProfileRequest', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'dateOfBirth',
      'gender',
      'heightCm',
      'currentWeightKg',
      'activityLevel',
      'fitnessGoal',
      'trainingExperience',
    ],
  );
  final val = CreateHealthProfileRequest(
    dateOfBirth: $checkedConvert(
      'dateOfBirth',
      (v) => DateTime.parse(v as String),
    ),
    gender: $checkedConvert(
      'gender',
      (v) => $enumDecode(_$CreateHealthProfileRequestGenderEnumEnumMap, v),
    ),
    calculationSex: $checkedConvert(
      'calculationSex',
      (v) => $enumDecodeNullable(
        _$CreateHealthProfileRequestCalculationSexEnumEnumMap,
        v,
      ),
    ),
    heightCm: $checkedConvert('heightCm', (v) => v as num),
    currentWeightKg: $checkedConvert('currentWeightKg', (v) => v as num),
    activityLevel: $checkedConvert(
      'activityLevel',
      (v) =>
          $enumDecode(_$CreateHealthProfileRequestActivityLevelEnumEnumMap, v),
    ),
    fitnessGoal: $checkedConvert(
      'fitnessGoal',
      (v) => $enumDecode(_$CreateHealthProfileRequestFitnessGoalEnumEnumMap, v),
    ),
    trainingExperience: $checkedConvert(
      'trainingExperience',
      (v) => $enumDecode(
        _$CreateHealthProfileRequestTrainingExperienceEnumEnumMap,
        v,
      ),
    ),
  );
  return val;
});

Map<String, dynamic> _$CreateHealthProfileRequestToJson(
  CreateHealthProfileRequest instance,
) => <String, dynamic>{
  'dateOfBirth': instance.dateOfBirth.toIso8601String(),
  'gender': _$CreateHealthProfileRequestGenderEnumEnumMap[instance.gender]!,
  'calculationSex':
      ?_$CreateHealthProfileRequestCalculationSexEnumEnumMap[instance
          .calculationSex],
  'heightCm': instance.heightCm,
  'currentWeightKg': instance.currentWeightKg,
  'activityLevel':
      _$CreateHealthProfileRequestActivityLevelEnumEnumMap[instance
          .activityLevel]!,
  'fitnessGoal':
      _$CreateHealthProfileRequestFitnessGoalEnumEnumMap[instance.fitnessGoal]!,
  'trainingExperience':
      _$CreateHealthProfileRequestTrainingExperienceEnumEnumMap[instance
          .trainingExperience]!,
};

const _$CreateHealthProfileRequestGenderEnumEnumMap = {
  CreateHealthProfileRequestGenderEnum.MALE: 'MALE',
  CreateHealthProfileRequestGenderEnum.FEMALE: 'FEMALE',
  CreateHealthProfileRequestGenderEnum.OTHER: 'OTHER',
  CreateHealthProfileRequestGenderEnum.UNSPECIFIED: 'UNSPECIFIED',
};

const _$CreateHealthProfileRequestCalculationSexEnumEnumMap = {
  CreateHealthProfileRequestCalculationSexEnum.MALE: 'MALE',
  CreateHealthProfileRequestCalculationSexEnum.FEMALE: 'FEMALE',
  CreateHealthProfileRequestCalculationSexEnum.UNSPECIFIED: 'UNSPECIFIED',
};

const _$CreateHealthProfileRequestActivityLevelEnumEnumMap = {
  CreateHealthProfileRequestActivityLevelEnum.SEDENTARY: 'SEDENTARY',
  CreateHealthProfileRequestActivityLevelEnum.LIGHT: 'LIGHT',
  CreateHealthProfileRequestActivityLevelEnum.MODERATE: 'MODERATE',
  CreateHealthProfileRequestActivityLevelEnum.ACTIVE: 'ACTIVE',
  CreateHealthProfileRequestActivityLevelEnum.VERY_ACTIVE: 'VERY_ACTIVE',
};

const _$CreateHealthProfileRequestFitnessGoalEnumEnumMap = {
  CreateHealthProfileRequestFitnessGoalEnum.LOSE_WEIGHT: 'LOSE_WEIGHT',
  CreateHealthProfileRequestFitnessGoalEnum.MAINTAIN_WEIGHT: 'MAINTAIN_WEIGHT',
  CreateHealthProfileRequestFitnessGoalEnum.GAIN_WEIGHT: 'GAIN_WEIGHT',
  CreateHealthProfileRequestFitnessGoalEnum.GAIN_MUSCLE: 'GAIN_MUSCLE',
};

const _$CreateHealthProfileRequestTrainingExperienceEnumEnumMap = {
  CreateHealthProfileRequestTrainingExperienceEnum.BEGINNER: 'BEGINNER',
  CreateHealthProfileRequestTrainingExperienceEnum.INTERMEDIATE: 'INTERMEDIATE',
  CreateHealthProfileRequestTrainingExperienceEnum.ADVANCED: 'ADVANCED',
};
